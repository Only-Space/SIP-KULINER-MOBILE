import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../data/services/geoapify_service.dart';

class RouteWaypointSheet extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final Function(String name, double lat, double lng) onPlaceSelected;

  const RouteWaypointSheet({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.onPlaceSelected,
  });

  @override
  State<RouteWaypointSheet> createState() => _RouteWaypointSheetState();
}

class _RouteWaypointSheetState extends State<RouteWaypointSheet> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final results = await _geoapifyService.searchPlaces(
        lat: widget.currentLat,
        lng: widget.currentLng,
        radiusKm: 50,
        categoryQuery: query,
        limit: 10,
      );
      if (mounted) setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencari: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Tambah Tujuan Berikutnya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Cari tempat kuliner...',
                hintStyle: GoogleFonts.publicSans(color: AppColors.outlineVariant),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'Ketik untuk mencari tujuan baru',
                        style: GoogleFonts.publicSans(color: AppColors.outlineVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                         final place = _searchResults[index];
                         return ListTile(
                           leading: Container(
                             width: 40, height: 40,
                             decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(10)),
                             child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 20),
                           ),
                           title: Text(place.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                           subtitle: Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                           onTap: () {
                             Navigator.pop(context);
                             widget.onPlaceSelected(place.name, place.latitude, place.longitude);
                           },
                         );
                      },
                    ),
        ),
      ]),
    );
  }
}
