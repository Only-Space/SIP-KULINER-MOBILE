import 'dart:convert';
import 'dart:math' show min;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/meal_plan.dart';
import '../models/user_preferences.dart';
import '../models/geoapify_place.dart';

class MealPlanException implements Exception {
  final String message;
  MealPlanException(this.message);
  @override
  String toString() => message;
}

class MealPlanService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  Future<MealPlan> generateMealPlan({
    required UserPreferences preferences,
    required List<GeoapifyPlace> nearbyPlaces,
    void Function(String)? onProgress,
  }) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw MealPlanException('OPENROUTER_API_KEY tidak ditemukan di .env');
    }

    final totalBudget = preferences.dailyBudget * 30;
    final allDays = <DailyMeal>[];

    try {
      onProgress?.call('Menyusun menu minggu 1... (1/4)');
      final chunk1 = await _generateChunk(1, 7, preferences, nearbyPlaces, apiKey);
      allDays.addAll(chunk1);

      await Future.delayed(const Duration(seconds: 2));

      onProgress?.call('Menyusun menu minggu 2... (2/4)');
      final chunk2 = await _generateChunk(8, 14, preferences, nearbyPlaces, apiKey);
      allDays.addAll(chunk2);

      await Future.delayed(const Duration(seconds: 2));

      onProgress?.call('Menyusun menu minggu 3... (3/4)');
      final chunk3 = await _generateChunk(15, 21, preferences, nearbyPlaces, apiKey);
      allDays.addAll(chunk3);

      await Future.delayed(const Duration(seconds: 2));

      onProgress?.call('Menyusun menu minggu 4... (4/4)');
      final chunk4 = await _generateChunk(22, 30, preferences, nearbyPlaces, apiKey);
      allDays.addAll(chunk4);

      int totalCost = 0;
      for (final day in allDays) {
        totalCost += day.totalDailyCost;
      }

      return MealPlan(
        days: allDays,
        totalBudget: totalBudget,
        totalEstimatedCost: totalCost,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[MEAL_PLAN] Error generateMealPlan keseluruhan: $e');
      throw MealPlanException('Gagal menyusun menu 30 hari: $e');
    }
  }

  Future<List<DailyMeal>> _generateChunk(
    int startDay,
    int endDay,
    UserPreferences preferences,
    List<GeoapifyPlace> nearbyPlaces,
    String apiKey, {
    bool isRetry = false,
  }) async {
    final model = dotenv.env['AI_MODEL_MEAL'] ?? 'google/gemini-flash-1.5';

    const systemMessage = 'You are a meal planner. Reply ONLY with a JSON array, no other text.';
    
    final userMessage = '''Create meal schedule for day $startDay to day $endDay.
Daily budget: Rp ${preferences.dailyBudget}
Available restaurants: ${_buildPlaceList(nearbyPlaces)}

Reply ONLY with this JSON array:
[{"day":$startDay,"breakfast_food":"food name","breakfast_warung":"restaurant name","breakfast_price":10000,"lunch_food":"food name","lunch_warung":"restaurant name","lunch_price":20000,"dinner_food":"food name","dinner_warung":"restaurant name","dinner_price":25000}]

Continue for all days up to day $endDay.''';

    try {
      final body = jsonEncode({
        'model': model,
        'max_tokens': 1500,
        'messages': [
          {'role': 'system', 'content': systemMessage},
          {'role': 'user', 'content': userMessage},
        ],
      });

      debugPrint('[MEAL_PLAN] Chunk $startDay-$endDay model: $model');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 429 && !isRetry) {
        debugPrint('[MEAL_PLAN] Error 429 (Rate Limit). Tunggu 5 detik lalu retry chunk $startDay-$endDay');
        await Future.delayed(const Duration(seconds: 5));
        return _generateChunk(startDay, endDay, preferences, nearbyPlaces, apiKey, isRetry: true);
      }

      if (response.statusCode != 200) {
        throw Exception('API error status ${response.statusCode}: ${response.body}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw Exception('Choices kosong dari OpenRouter API.');
      }

      final rawContent = (choices[0] as Map<String, dynamic>)['message']?['content'] as String? ?? '';
      debugPrint('[MEAL_PLAN] Raw response chunk $startDay-$endDay: ${rawContent.substring(0, min(500, rawContent.length))}');
      
      final jsonString = _sanitizeJson(rawContent);
      List<dynamic> parsed;
      if (jsonString == '[]') {
        debugPrint('[MEAL_PLAN] Menggunakan fallback data untuk chunk $startDay-$endDay');
        parsed = _buildFallbackChunk(startDay, endDay, nearbyPlaces, preferences);
      } else {
        try {
          parsed = jsonDecode(jsonString) as List<dynamic>;
        } catch (_) {
          debugPrint('[MEAL_PLAN] Gagal decode setelah sanitize, menggunakan fallback data untuk chunk $startDay-$endDay');
          parsed = _buildFallbackChunk(startDay, endDay, nearbyPlaces, preferences);
        }
      }
      
      final days = <DailyMeal>[];
      for (int i = 0; i < parsed.length; i++) {
        final item = parsed[i] as Map<String, dynamic>;
        
        final dayIndex = item['day'] as int? ?? startDay + i;
        
        days.add(DailyMeal(
          day: dayIndex,
          breakfast: _createMealItem(item, 'breakfast', preferences, nearbyPlaces, dayIndex),
          lunch: _createMealItem(item, 'lunch', preferences, nearbyPlaces, dayIndex),
          dinner: _createMealItem(item, 'dinner', preferences, nearbyPlaces, dayIndex),
        ));
      }
      
      if (days.isEmpty) {
        throw Exception('JSON dari AI kosong atau format array tidak sesuai.');
      }
      
      final expectedDays = endDay - startDay + 1;
      if (days.length < expectedDays) {
        final diff = expectedDays - days.length;
        debugPrint('[MEAL_PLAN] Chunk tidak lengkap, mengisi $diff hari dengan fallback');
        
        DailyMeal lastDay = days.last;
        for (int i = 0; i < diff; i++) {
          final newDayIndex = lastDay.day + 1;
          lastDay = DailyMeal(
            day: newDayIndex,
            breakfast: lastDay.breakfast,
            lunch: lastDay.lunch,
            dinner: lastDay.dinner,
          );
          days.add(lastDay);
        }
      }
      
      return days;
      
    } catch (e) {
      if (!isRetry && !e.toString().contains('TimeoutException')) {
        debugPrint('[MEAL_PLAN] Error non-timeout, mencoba retry chunk $startDay-$endDay: $e');
        await Future.delayed(const Duration(seconds: 2));
        return _generateChunk(startDay, endDay, preferences, nearbyPlaces, apiKey, isRetry: true);
      }
      
      debugPrint('[MEAL_PLAN] Terjadi error: $e, fallback total untuk chunk $startDay-$endDay digunakan');
      final parsed = _buildFallbackChunk(startDay, endDay, nearbyPlaces, preferences);
      return parsed.map((item) {
        final dayIndex = item['day'] as int;
        return DailyMeal(
          day: dayIndex,
          breakfast: _createMealItem(item, 'breakfast', preferences, nearbyPlaces, dayIndex),
          lunch: _createMealItem(item, 'lunch', preferences, nearbyPlaces, dayIndex),
          dinner: _createMealItem(item, 'dinner', preferences, nearbyPlaces, dayIndex),
        );
      }).toList();
    }
  }

  MealItem _createMealItem(
    Map<String, dynamic> json, 
    String prefix, 
    UserPreferences preferences,
    List<GeoapifyPlace> nearbyPlaces,
    int dayIndex,
  ) {
    final foodName = json['${prefix}_food'] as String? ?? 'Menu makanan';
    final rawWarungName = json['${prefix}_warung'] as String? ?? '';
    final int price = (json['${prefix}_price'] as num?)?.toInt() ?? (preferences.dailyBudget * 0.3).toInt();

    GeoapifyPlace? resolvedPlace;
    
    if (rawWarungName.isNotEmpty && nearbyPlaces.isNotEmpty) {
      final query = rawWarungName.toLowerCase();
      resolvedPlace = nearbyPlaces.cast<GeoapifyPlace?>().firstWhere(
        (p) => p!.name.toLowerCase().contains(query),
        orElse: () => null,
      );
    }
    
    // Round-robin fallback if AI hallucinates
    if (resolvedPlace == null && nearbyPlaces.isNotEmpty) {
      final index = (dayIndex + (prefix == 'breakfast' ? 0 : prefix == 'lunch' ? 1 : 2)) % nearbyPlaces.length;
      resolvedPlace = nearbyPlaces[index];
    }
    
    final tips = prefix == 'breakfast' 
        ? 'Buka pagi hari' 
        : prefix == 'lunch' 
            ? 'Cocok untuk makan siang' 
            : 'Pesan lebih awal untuk makan malam';

    return MealItem(
      foodName: foodName,
      warungName: resolvedPlace?.name ?? rawWarungName,
      warungArea: resolvedPlace?.address ?? 'Bali',
      price: price,
      tips: tips,
      placeId: resolvedPlace?.id,
    );
  }

  String _buildPlaceList(List<GeoapifyPlace> places) {
    return places
      .take(10)
      .map((p) => p.name)
      .join(', ');
  }

  String _sanitizeJson(String raw) {
    // Ekstrak array JSON
    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start == -1 || end == -1) return '[]';
    
    String json = raw.substring(start, end + 1);
    
    // Coba parse dulu
    try {
      jsonDecode(json);
      return json; // valid, langsung return
    } catch (_) {
      // JSON tidak valid, coba potong di objek terakhir yang lengkap
      final lastComplete = json.lastIndexOf('},');
      if (lastComplete == -1) return '[]';
      return '${json.substring(0, lastComplete + 1)}]';
    }
  }

  List<Map<String, dynamic>> _buildFallbackChunk(
    int startDay, int endDay, List<GeoapifyPlace> places, UserPreferences preferences) {
    final result = <Map<String, dynamic>>[];
    for (int day = startDay; day <= endDay; day++) {
      if (places.isEmpty) {
        result.add({
          'day': day,
          'breakfast_food': 'Menu sarapan',
          'breakfast_warung': 'Warung',
          'breakfast_price': (preferences.dailyBudget * 0.25).toInt(),
          'lunch_food': 'Menu makan siang',
          'lunch_warung': 'Restoran',
          'lunch_price': (preferences.dailyBudget * 0.38).toInt(),
          'dinner_food': 'Menu makan malam',
          'dinner_warung': 'Tempat Makan',
          'dinner_price': (preferences.dailyBudget * 0.37).toInt(),
        });
        continue;
      }
      
      final breakfast = places[day % places.length];
      final lunch = places[(day + 1) % places.length];
      final dinner = places[(day + 2) % places.length];
      result.add({
        'day': day,
        'breakfast_food': 'Menu sarapan',
        'breakfast_warung': breakfast.name,
        'breakfast_price': (preferences.dailyBudget * 0.25).toInt(),
        'lunch_food': 'Menu makan siang',
        'lunch_warung': lunch.name,
        'lunch_price': (preferences.dailyBudget * 0.38).toInt(),
        'dinner_food': 'Menu makan malam',
        'dinner_warung': dinner.name,
        'dinner_price': (preferences.dailyBudget * 0.37).toInt(),
      });
    }
    return result;
  }
}
