import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../app_theme.dart';
import '../data/services/geoapify_service.dart';
import '../models/food_item.dart';
import '../data/providers/supabase_provider.dart';
import '../widgets/dashboard/dashboard_app_bar.dart';
import '../widgets/dashboard/dashboard_hero.dart';
import '../widgets/dashboard/dashboard_search.dart';
import '../widgets/food/category_filters.dart';
import '../widgets/food/section_header.dart';
import '../widgets/food/food_grid_sliver.dart';
import '../widgets/food/food_grid_skeleton_sliver.dart';
import '../widgets/dashboard/dashboard_footer.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';
import 'login_pages.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final String userEmail;
  const DashboardPage({super.key, this.userEmail = 'Guest'});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedCategory = 0;
  int _selectedNavIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _displayName = 'Guest';

  bool _isLoadingPlaces = true;
  List<FoodItem> _places = [];
  String? _errorMessage;
  final GeoapifyService _geoapifyService = GeoapifyService();

  final _categories = const [
    'Semua Kategori', 'Jajanan Bali', 'Nasi Campur',
    'Sate & Panggang', 'Minuman Segar', 'Oleh-Oleh',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchPlaces();
  }

  Future<void> _loadUserProfile() async {
    final user = ref.read(supabaseProvider).auth.currentUser;
    if (user == null) return;
    final name = user.userMetadata?['full_name'] as String?
        ?? user.userMetadata?['name'] as String?
        ?? user.email?.split('@').first
        ?? 'Guest';
    // Capitalize first word
    final display = name.split(' ').map((w) => w.isNotEmpty
        ? '${w[0].toUpperCase()}${w.substring(1)}'
        : '').join(' ');
    if (mounted) setState(() => _displayName = display);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlaces() async {
    setState(() {
      _isLoadingPlaces = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen. Izinkan melalui pengaturan HP.');
      }

      Position position = await Geolocator.getCurrentPosition();
      
      // Ambil radius dari preferensi jika ada
      double radiusKm = 5.0;
      final session = ref.read(supabaseProvider).auth.currentSession;
      if (session != null) {
        final prefs = await ref.read(supabaseProvider).from('preferences').select('max_radius_km').eq('user_id', session.user.id).maybeSingle();
        if (prefs != null && prefs['max_radius_km'] != null) {
          radiusKm = (prefs['max_radius_km'] as num).toDouble();
        }
      }

      final String query = _categories[_selectedCategory];
      
      debugPrint('Mencari tempat dengan query: $query, search: $_searchQuery');
      final results = await _geoapifyService.searchPlaces(
        lat: position.latitude,
        lng: position.longitude,
        radiusKm: radiusKm,
        categoryQuery: query,
        searchQuery: _searchQuery,
      );
      debugPrint('Mendapatkan ${results.length} hasil');

      if (mounted) {
        setState(() {
          _places = results.map((e) => e.toFoodItem()).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Terjadi error saat mencari tempat: $e');
        setState(() {
          _errorMessage = e.toString();
          _isLoadingPlaces = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPages()),
        (route) => false,
      );
    }
  }

  void _handleProfileTap() => Navigator.pushNamed(context, '/profile');

  void _handleNavTap(int index) {
    if (index == 3) {
      _handleProfileTap();
    } else {
      setState(() => _selectedNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          DashboardAppBar(
            userEmail: _displayName,
            onLogout: _handleLogout,
            onProfileTap: _handleProfileTap,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  DashboardHero(userEmail: _displayName),
                  const SizedBox(height: 20),
                  DashboardSearch(
                    controller: _searchController,
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _fetchPlaces();
                    },
                  ),
                  const SizedBox(height: 24),
                  CategoryFilters(
                    categories: _categories,
                    selectedIndex: _selectedCategory,
                    onChanged: (i) {
                      setState(() => _selectedCategory = i);
                      _fetchPlaces(); // Refresh data saat kategori diubah
                    },
                  ),
                  const SizedBox(height: 32),
                  SectionHeader(
                    title: 'Rekomendasi Terdekat',
                    onSeeMap: () {},
                  ),
                ],
              ),
            ),
          ),
          _isLoadingPlaces 
            ? const FoodGridSkeletonSliver(itemCount: 4)
            : _errorMessage != null
              ? SliverToBoxAdapter(child: Center(child: Text('Error: $_errorMessage\nCoba muat ulang', textAlign: TextAlign.center)))
              : _places.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: Text('Tidak ada rekomendasi terdekat')))
                : FoodGridSliver(items: _places),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          const SliverToBoxAdapter(child: DashboardFooter()),
        ],
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedNavIndex,
        onChanged: _handleNavTap,
      ),
    );
  }
}
