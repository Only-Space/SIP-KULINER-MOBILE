import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';
import 'package:usada_rare/features/dashboard/providers/ai_recommendation_provider.dart';
import 'package:usada_rare/models/user_preferences.dart';
import 'package:usada_rare/features/meal_plan/providers/meal_plan_provider.dart';

class PreferencesEditSheet extends ConsumerStatefulWidget {
  final UserPreferences initialPrefs;

  const PreferencesEditSheet({super.key, required this.initialPrefs});

  @override
  ConsumerState<PreferencesEditSheet> createState() =>
      _PreferencesEditSheetState();
}

class _PreferencesEditSheetState extends ConsumerState<PreferencesEditSheet> {
  final List<String> _favOptions = [
    'Nasi',
    'Ayam',
    'Seafood',
    'Vegetarian',
    'Pedas',
    'Manis',
    'Bakso',
    'Soto'
  ];
  final List<String> _avoidOptions = [
    'Babi',
    'Seafood',
    'Pedas',
    'Manis',
    'Gluten'
  ];

  late final List<String> _selectedFavs;
  late final List<String> _selectedAvoids;

  late double _budget;
  late double _radius;

  bool _isLoading = false;
  final TextEditingController _customFavController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFavs = List.from(widget.initialPrefs.favoriteFoods);
    _selectedAvoids = List.from(widget.initialPrefs.avoidFoods);
    _budget = widget.initialPrefs.dailyBudget.toDouble();
    _radius = widget.initialPrefs.maxRadiusKm;
  }

  @override
  void dispose() {
    _customFavController.dispose();
    super.dispose();
  }

  void _addCustomFav() {
    final text = _customFavController.text.trim();
    if (text.isNotEmpty &&
        !_favOptions.contains(text) &&
        !_selectedFavs.contains(text)) {
      setState(() {
        _selectedFavs.add(text);
      });
      _customFavController.clear();
    }
  }

  Future<void> _submit() async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final oldBudget = widget.initialPrefs.dailyBudget;
      final newBudget = _budget.toInt();

      await supabase.from('preferences').upsert({
        'user_id': user.id,
        'favorite_foods': _selectedFavs,
        'avoid_foods': _selectedAvoids,
        'daily_budget': newBudget,
        'max_radius_km': _radius,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');

      // Invalidations
      ref.invalidate(preferencesProvider);
      ref.invalidate(aiRecommendationProvider);

      if (oldBudget != newBudget) {
        // HANYA jika daily_budget berubah: invalidate mealPlanProvider
        ref.read(mealPlanProvider.notifier).regenerate();
      }

      if (mounted) {
        Navigator.pop(context); // Tutup bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferensi berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui preferensi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Judul
              const Text(
                'Ubah preferensi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // ── Makanan Favorit ───────────────────────────────────────
              const Text(
                'Makanan favorit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._favOptions.map((fav) {
                    final isSelected = _selectedFavs.contains(fav);
                    return FilterChip(
                      label: Text(fav),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFavs.add(fav);
                          } else {
                            _selectedFavs.remove(fav);
                          }
                        });
                      },
                      selectedColor: _SheetColors.primaryContainer,
                      checkmarkColor: _SheetColors.onPrimaryContainer,
                    );
                  }),
                  ..._selectedFavs
                      .where((f) => !_favOptions.contains(f))
                      .map((customFav) {
                    return InputChip(
                      label: Text(customFav),
                      onDeleted: () {
                        setState(() => _selectedFavs.remove(customFav));
                      },
                      backgroundColor: _SheetColors.primaryContainer,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customFavController,
                      decoration: InputDecoration(
                        hintText: 'Tambah makanan lain...',
                        hintStyle: const TextStyle(fontSize: 13),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (_) => _addCustomFav(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addCustomFav,
                    icon: const Icon(Icons.add_circle, color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Makanan yang Dihindari ────────────────────────────────
              const Text(
                'Makanan yang dihindari',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _avoidOptions.map((avoid) {
                  final isSelected = _selectedAvoids.contains(avoid);
                  return FilterChip(
                    label: Text(avoid),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAvoids.add(avoid);
                        } else {
                          _selectedAvoids.remove(avoid);
                        }
                      });
                    },
                    selectedColor: _SheetColors.errorContainer,
                    checkmarkColor: _SheetColors.onErrorContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Slider Budget ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget harian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Rp ${_budget.toInt().toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => '.')}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ],
              ),
              Slider(
                value: _budget,
                min: 10000,
                max: 200000,
                divisions: 38,
                activeColor: AppColors.accent,
                onChanged: (val) => setState(() => _budget = val),
              ),
              const SizedBox(height: 16),

              // ── Slider Radius ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jarak maksimal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_radius.toInt()} km',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ],
              ),
              Slider(
                value: _radius,
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: AppColors.accent,
                onChanged: (val) => setState(() => _radius = val),
              ),
              const SizedBox(height: 32),

              // ── Buttons ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Perbarui Preferensi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetColors {
  static const primaryContainer = Color(0xFFD6E3FF);
  static const onPrimaryContainer = Color(0xFF001B3E);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);
}
