import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/models/user_preferences.dart';

class PreferencesForm extends StatefulWidget {
  final UserPreferences? initialData;
  final String submitLabel;
  final bool showSkipButton;
  final Future<void> Function()? onSkip;
  final Future<void> Function(UserPreferences) onSubmit;

  const PreferencesForm({
    super.key,
    this.initialData,
    required this.submitLabel,
    required this.showSkipButton,
    this.onSkip,
    required this.onSubmit,
  });

  @override
  State<PreferencesForm> createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  final List<String> _favOptions = [
    'Nasi', 'Ayam', 'Seafood', 'Vegetarian', 'Pedas', 'Manis', 'Bakso', 'Soto'
  ];
  final List<String> _avoidOptions = [
    'Babi', 'Seafood', 'Pedas', 'Manis', 'Gluten'
  ];

  late List<String> _selectedFavs;
  late List<String> _selectedAvoids;
  late double _budget;
  late double _radius;
  final TextEditingController _customFavController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedFavs = List.from(widget.initialData?.favoriteFoods ?? []);
    _selectedAvoids = List.from(widget.initialData?.avoidFoods ?? []);
    _budget = widget.initialData?.dailyBudget.toDouble() ?? 50000;
    _radius = widget.initialData?.maxRadiusKm ?? 5.0;
  }

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

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      final prefs = UserPreferences(
        favoriteFoods: _selectedFavs,
        avoidFoods: _selectedAvoids,
        dailyBudget: _budget.toInt(),
        maxRadiusKm: _radius,
      );
      await widget.onSubmit(prefs);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSkip() async {
    setState(() => _isLoading = true);
    try {
      if (widget.onSkip != null) await widget.onSkip!();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Makanan favorit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._favOptions.map((fav) {
              final isSelected = _selectedFavs.contains(fav);
              return _buildFavChip(fav, isSelected, () {
                setState(() {
                  isSelected ? _selectedFavs.remove(fav) : _selectedFavs.add(fav);
                });
              });
            }),
            ..._selectedFavs.where((f) => !_favOptions.contains(f)).map((customFav) {
              return _buildFavChip(customFav, true, () {
                setState(() => _selectedFavs.remove(customFav));
              });
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
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
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

        const Text(
          'Makanan yang dihindari',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _avoidOptions.map((avoid) {
            final isSelected = _selectedAvoids.contains(avoid);
            return _buildAvoidChip(avoid, isSelected, () {
              setState(() {
                isSelected ? _selectedAvoids.remove(avoid) : _selectedAvoids.add(avoid);
              });
            });
          }).toList(),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget harian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
            Text(
              'Rp ${_budget.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.amber,
            inactiveTrackColor: AppColors.outlineVariant.withValues(alpha: 0.3),
            thumbColor: AppColors.amber,
            overlayColor: AppColors.amber.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: _budget,
            min: 10000,
            max: 200000,
            divisions: 38,
            onChanged: (val) => setState(() => _budget = val),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jarak maksimal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
            Text(
              '${_radius.toInt()} km',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.amber,
            inactiveTrackColor: AppColors.outlineVariant.withValues(alpha: 0.3),
            thumbColor: AppColors.amber,
            overlayColor: AppColors.amber.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: _radius,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (val) => setState(() => _radius = val),
          ),
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            if (widget.showSkipButton) ...[
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : _handleSkip,
                  child: const Text('Lewati', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: widget.showSkipButton ? 2 : 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(widget.submitLabel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.chipActiveGradient : null,
          color: isSelected ? null : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.amber),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAvoidChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade100 : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.amber),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red.shade800 : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
