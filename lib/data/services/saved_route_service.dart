import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/saved_route.dart';

class SavedRouteService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveRoute(SavedRoute route) async {
    try {
      await _client.from('saved_routes').insert(route.toJson());
    } on PostgrestException catch (e) {
      throw Exception('Gagal menyimpan rute: ${e.message}');
    } catch (e) {
      throw Exception('Gagal menyimpan rute: $e');
    }
  }

  Future<List<SavedRoute>> getSavedRoutes(String userId) async {
    try {
      final response = await _client
          .from('saved_routes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => SavedRoute.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal memuat rute tersimpan: ${e.message}');
    } catch (e) {
      throw Exception('Gagal memuat rute tersimpan: $e');
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      await _client.from('saved_routes').delete().eq('id', routeId);
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus rute: ${e.message}');
    } catch (e) {
      throw Exception('Gagal menghapus rute: $e');
    }
  }
}
