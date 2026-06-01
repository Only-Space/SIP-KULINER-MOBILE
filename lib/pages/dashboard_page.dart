import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../data/providers/supabase_provider.dart';
import '../features/dashboard/providers/dashboard_places_provider.dart';
import '../widgets/dashboard/dashboard_app_bar.dart';
import '../widgets/dashboard/dashboard_hero.dart';
import '../widgets/dashboard/dashboard_search.dart';
import '../widgets/food/category_filters.dart';
import '../widgets/food/section_header.dart';
import '../widgets/food/food_grid_sliver.dart';
import '../widgets/dashboard/dashboard_footer.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';
import '../features/dashboard/widgets/ai_recommendation_section.dart';
import '../features/explore/widgets/place_card_skeleton.dart';
import 'login_pages.dart';
import 'explore_page.dart';
import 'profile_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final String userEmail;
  const DashboardPage({super.key, this.userEmail = 'Guest'});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _displayName = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    Future.microtask(() {
      ref.read(dashboardPlacesProvider.notifier).fetchPlaces(context);
    });
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
    setState(() => _selectedNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          _buildHomeView(),
          const ExplorePage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedNavIndex,
        onChanged: _handleNavTap,
      ),
    );
  }

  Widget _buildHomeView() {
    final placesState = ref.watch(dashboardPlacesProvider);
    final placesNotifier = ref.read(dashboardPlacesProvider.notifier);

    return CustomScrollView(
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
                      placesNotifier.setSearchQuery(context, value);
                    },
                  ),
                  const SizedBox(height: 24),
                  CategoryFilters(
                    categories: placesNotifier.categories,
                    selectedIndex: placesState.selectedCategory,
                    onChanged: (i) {
                      placesNotifier.setCategory(context, i);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // ── AI Recommendation Section ──────────────────────────────
          const SliverToBoxAdapter(child: AiRecommendationSection()),
          // ── Nearby section header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SectionHeader(
                    title: 'Rekomendasi Terdekat',
                    onSeeMap: () {},
                  ),
                ],
              ),
            ),
          ),
          placesState.isLoading 
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PlaceCardSkeleton(isList: true),
                ),
              )
            : placesState.error != null
              ? SliverToBoxAdapter(child: Center(child: Text('Error: ${placesState.error!.message}\nCoba muat ulang', textAlign: TextAlign.center)))
              : placesState.places.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: Text('Tidak ada rekomendasi terdekat')))
                : FoodGridSliver(items: placesState.places),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          const SliverToBoxAdapter(child: DashboardFooter()),
        ],
      );
  }
}
