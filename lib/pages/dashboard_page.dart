import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/food_card.dart';
import '../widgets/dashboard_footer.dart';
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

  final List<String> _categories = [
    'Semua Kategori',
    'Jajanan Bali',
    'Nasi Campur',
    'Sate & Panggang',
    'Minuman Segar',
    'Oleh-Oleh',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    _buildHero(),
                    const SizedBox(height: 24),
                    _buildMobileSearch(),
                    const SizedBox(height: 24),
                    _buildCategoryFilters(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(),
                  ],
                ),
              ),
            ),
            _buildFoodGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            const SliverToBoxAdapter(child: DashboardFooter()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 1,
      toolbarHeight: 72,
      title: Text(
        'SIPKULINER',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: () {},
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.primary),
              onPressed: () {},
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.primary),
              onPressed: () {},
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                constraints: const BoxConstraints(minWidth: 18),
                child: Text(
                  '3',
                  style: GoogleFonts.publicSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.primary),
          tooltip: 'Keluar',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPages()),
              (route) => false,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBAHD65XDZkfXMU0KcnlMJO5mkQAl0e0DZ-Ymalw19L3eD82owQOXfi9P6FeA2mF7daEwuYa6TNIIF14fBqsQJ0oaYDy53uXZkL952sjf3axogX3OZseRIjz0xUONZHQv4yMbEziEkXZmjQci2kK3iE_Oe7oqSgv_wpZXrBu-YA-qw9oIJ4YcJVyKA5dKq6KKypGzY1bg31Vm87D0XEttKx4UJToChvIKp5w4MZRZmghfNes79V6zDuKeowc4eRVVvEbbtNdM_-pbNt',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Text(
          'Selamat Datang, ${widget.userEmail}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Jelajahi kuliner autentik Denpasar dan dukung UMKM lokal.',
          style: GoogleFonts.publicSans(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileSearch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari kuliner...',
          hintStyle: GoogleFonts.publicSans(
            color: AppColors.outlineVariant,
            fontSize: 16,
          ),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: GoogleFonts.publicSans(fontSize: 16),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _categories[index],
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : AppColors.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Rekomendasi Terdekat',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            height: 1.3,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'Lihat Peta',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => FoodCard(item: DummyData.foodItems[index]),
          childCount: DummyData.foodItems.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900
              ? 4
              : MediaQuery.of(context).size.width > 600
                  ? 2
                  : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              MediaQuery.of(context).size.width > 600 ? 0.75 : 0.85,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', 0),
              _navItem(Icons.search, 'Explore', 1, isActive: true),
              _navItem(Icons.receipt_long_outlined, 'My Orders', 2),
              _navItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index,
      {bool isActive = false}) {
    final color = (index == _selectedNavIndex)
        ? AppColors.secondaryContainer
        : AppColors.outlineVariant;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.surfaceContainerLow
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: isActive ? 1.1 : 1.0,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
