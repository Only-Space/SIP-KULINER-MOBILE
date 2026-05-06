import 'package:flutter/material.dart';
import '../widgets/dashboard/dashboard_app_bar.dart';
import '../widgets/dashboard/dashboard_hero.dart';
import '../widgets/dashboard/dashboard_search.dart';
import '../widgets/food/category_filters.dart';
import '../widgets/food/section_header.dart';
import '../widgets/food/food_grid_sliver.dart';
import '../widgets/dashboard/dashboard_footer.dart';
import '../widgets/dashboard/dashboard_bottom_nav.dart';
import 'login_pages.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;
  const DashboardPage({super.key, this.userEmail = 'Guest'});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedCategory = 0;
  int _selectedNavIndex = 0;

  final _categories = const [
    'Semua Kategori', 'Jajanan Bali', 'Nasi Campur',
    'Sate & Panggang', 'Minuman Segar', 'Oleh-Oleh',
  ];

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            DashboardAppBar(
              userEmail: widget.userEmail,
              onLogout: _handleLogout,
              onProfileTap: _handleProfileTap,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    DashboardHero(userEmail: widget.userEmail),
                    const SizedBox(height: 24),
                    const DashboardSearch(),
                    const SizedBox(height: 24),
                    CategoryFilters(
                      categories: _categories,
                      selectedIndex: _selectedCategory,
                      onChanged: (i) => setState(() => _selectedCategory = i),
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
            FoodGridSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            const SliverToBoxAdapter(child: DashboardFooter()),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedNavIndex,
        onChanged: _handleNavTap,
      ),
    );
  }
}
