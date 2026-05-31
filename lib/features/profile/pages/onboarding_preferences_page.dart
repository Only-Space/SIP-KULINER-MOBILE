import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usada_rare/data/providers/supabase_provider.dart';

class OnboardingPreferencesPage extends ConsumerStatefulWidget {
  const OnboardingPreferencesPage({super.key});

  @override
  ConsumerState<OnboardingPreferencesPage> createState() =>
      _OnboardingPreferencesPageState();
}

class _OnboardingPreferencesPageState
    extends ConsumerState<OnboardingPreferencesPage> {
  final List<String> _categories = [
    'Bali',
    'Western',
    'Vegetarian',
    'Seafood',
    'Halal',
    'Fast Food'
  ];
  
  final List<String> _selectedCategories = [];
  
  final TextEditingController _allergyController = TextEditingController();
  final List<String> _allergies = [];
  
  double _maxRadius = 5.0;
  bool _isLoading = false;

  void _submitPreferences() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userProvider);
      if (user == null) throw Exception('User not logged in');

      await ref.read(supabaseProvider).from('preferences').upsert({
        'user_id': user.id,
        'categories': _selectedCategories,
        'allergies': _allergies,
        'max_radius_km': _maxRadius,
      });

      if (!mounted) return;
      // Berhasil, arahkan ke dashboard dan hilangkan riwayat navigasi
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth Error: ${e.message}')),
      );
      // Auto-redirect to login if session expired
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan preferensi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferensi Makanan'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Kategori Makanan Favorit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Alergi atau Pantangan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _allergyController,
                    decoration: const InputDecoration(
                      hintText: 'Cth: Kacang, Susu (Ketik lalu klik Add)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          _allergies.add(value.trim());
                          _allergyController.clear();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    final value = _allergyController.text;
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        _allergies.add(value.trim());
                        _allergyController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _allergies.map((allergy) {
                return Chip(
                  label: Text(allergy),
                  onDeleted: () {
                    setState(() {
                      _allergies.remove(allergy);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Jarak Pencarian Maksimal: ${_maxRadius.toInt()} km',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _maxRadius,
              min: 1,
              max: 20,
              divisions: 19,
              label: '${_maxRadius.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _maxRadius = value;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPreferences,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan & Lanjutkan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}