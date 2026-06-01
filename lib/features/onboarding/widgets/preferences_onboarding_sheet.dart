import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';
import 'package:usada_rare/features/dashboard/providers/preferences_provider.dart';

class PreferencesOnboardingSheet extends ConsumerStatefulWidget {
  const PreferencesOnboardingSheet({super.key});

  @override
  ConsumerState<PreferencesOnboardingSheet> createState() =>
      _PreferencesOnboardingSheetState();
}

class _PreferencesOnboardingSheetState
    extends ConsumerState<PreferencesOnboardingSheet> {
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

  final List<String> _selectedFavs = [];
  final List<String> _selectedAvoids = [];

  double _budget = 50000;
  double _radius = 5;

  bool _isLoading = false;
  final TextEditingController _customFavController = TextEditingController();

  @override
  void dispose() {
    _customFavController.dispose();
    super.dispose();
  }

  void _addCustomFav() {
    final text = _customFavController.text.trim();
    if (text.isNotEmpty && !_favOptions.contains(text) && !_selectedFavs.contains(text)) {
      setState(() {
        _selectedFavs.add(text);
      });
      _customFavController.clear();
    }
  }

  Future<void> _submit(bool isSkip) async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final favs = isSkip ? const [] : _selectedFavs;
      final avoids = isSkip ? const [] : _selectedAvoids;
      final budget = isSkip ? 50000 : _budget.toInt();
      final radius = isSkip ? 5.0 : _radius;

      await supabase.from('preferences').upsert({
        'user_id': user.id,
        'favorite_foods': favs,
        'avoid_foods': avoids,
        'daily_budget': budget,
        'max_radius_km': radius,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');

      // Invalidate provider so dashboard fetches new data
      ref.invalidate(preferencesProvider);

      if (mounted) {
        Navigator.pop(context); // Tutup bottom sheet
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan preferensi: $e')),
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
              // Judul & Subjudul
              const Text(
                'Bantu kami mengenalmu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Agar rekomendasi makanan lebih tepat untukmu',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
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
                  ..._selectedFavs.where((f) => !_favOptions.contains(f)).map((customFav) {
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ],
              ),
              Slider(
                value: _budget,
                min: 10000,
                max: 200000,
                divisions: 38, // (200000 - 10000) / 5000 = 38
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
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
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
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => _submit(true),
                      child: const Text('Lewati', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : () => _submit(false),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Simpan Preferensi'),
                    ),
                  ),
                ],
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
