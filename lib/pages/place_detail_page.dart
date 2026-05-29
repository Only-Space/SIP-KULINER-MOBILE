import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/services/geoapify_service.dart';
import '../models/geoapify_place.dart';
import '../models/review_model.dart';
import '../data/services/review_service.dart';
import '../widgets/reviews/review_form_sheet.dart';
import 'route_map_page.dart';

class PlaceDetailPage extends StatefulWidget {
  const PlaceDetailPage({super.key});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  final GeoapifyService _geoapifyService = GeoapifyService();
  final ReviewService _reviewService = ReviewService();
  bool _isLoading = true;
  String? _errorMessage;
  GeoapifyPlace? _placeDetails;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mendapatkan argument ID (fsq_id) dari navigasi
    final fsqId = ModalRoute.of(context)?.settings.arguments as String?;
    debugPrint('Membuka PlaceDetailPage dengan ID: $fsqId');
    if (fsqId != null && _isLoading && _placeDetails == null) {
      _fetchDetails(fsqId);
      _fetchReviews(fsqId);
    }
  }

  Future<void> _fetchReviews(String placeId) async {
    setState(() => _isLoadingReviews = true);
    try {
      final reviews = await _reviewService.getReviews(placeId);
      if (mounted) setState(() => _reviews = reviews);
    } catch (e) {
      debugPrint('Gagal memuat ulasan: $e (Mungkin tabel belum dibuat di Supabase?)');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _fetchDetails(String fsqId) async {
    try {
      final details = await _geoapifyService.getPlaceDetails(fsqId);
      
      if (mounted) {
        setState(() {
          _placeDetails = details;
          _isLoading = false;
        });
        
        // Geoapify kadang mengembalikan place_id yang sedikit berbeda antara API Search dan API Details.
        // Atau jika kita menggunakan fallback ID, koordinatnya bisa sedikit berbeda presisinya.
        // Jika ID final berbeda dengan fsqId awal, kita harus memuat ulang ulasan menggunakan ID yang benar.
        if (details.id != fsqId) {
          debugPrint('ID berubah dari $fsqId menjadi ${details.id}. Memuat ulang ulasan...');
          _fetchReviews(details.id);
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Terjadi error saat mengambil detail tempat: $e');
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openRouteMap(double lat, double lng, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteMapPage(
          destinationLat: lat,
          destinationLng: lng,
          destinationName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tempat')),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    final place = _placeDetails!;
    final name = place.name;
    final tel = place.phone ?? 'Tidak ada telepon';
    final location = place.address;
    final openingHours = place.openingHours ?? 'Tidak ada info jam buka';
    final website = place.website;
    
    // Gunakan gambar dari toFoodItem() sebagai header
    final headerImage = place.toFoodItem().imageUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                headerImage, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.publicSans(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(location, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(tel, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(openingHours, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                  if (website != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.language, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(website, style: const TextStyle(fontSize: 16, color: Colors.blue))),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // Bagian Peta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lokasi Peta', style: GoogleFonts.publicSans(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _openRouteMap(place.latitude, place.longitude, place.name),
                        icon: const Icon(Icons.directions),
                        label: const Text('Lihat Rute'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(place.latitude, place.longitude),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.example.sipkuliner',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(place.latitude, place.longitude),
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Ulasan Pengguna', style: GoogleFonts.publicSans(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  if (_isLoadingReviews)
                    const Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Belum ada ulasan untuk tempat ini. Jadilah yang pertama!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      )
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      separatorBuilder: (context, index) => const Divider(height: 30),
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: review.userAvatarUrl != null ? NetworkImage(review.userAvatarUrl!) : null,
                                  child: review.userAvatarUrl == null ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(review.userName ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: List.generate(5, (i) => Icon(
                                          i < review.rating ? Icons.star : Icons.star_border,
                                          size: 16, color: Colors.amber,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (review.comment != null && review.comment!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(review.comment!),
                            ],
                            if (review.photos.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: review.photos.length,
                                  itemBuilder: (ctx, pIdx) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(review.photos[pIdx], width: 80, height: 80, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        );
                      },
                    ),
                  
                  const SizedBox(height: 100), // Spacing for FAB
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ReviewFormSheet(
              placeId: place.id,
              onReviewSubmitted: () => _fetchReviews(place.id),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Tulis Ulasan'),
      ),
    );
  }
}
