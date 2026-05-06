import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primaryColor = Color(0xFF002045);
  static const Color secondaryColor = Color(0xFF875200);
  static const Color surfaceColor = Color(0xFFF9F9FF);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color secondaryContainer = Color(0xFFFFB55C);
  static const Color onSecondaryContainer = Color(0xFF744600);
  static const Color errorColor = Color(0xFFBA1A1A);

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

  final List<FoodItem> _foodItems = [
    FoodItem(
      id: 1,
      name: 'Nasi Campur Ayam Betutu Khas Gilimanuk',
      merchant: 'Warung Men Runtu',
      price: 35000,
      rating: 4.8,
      reviews: 124,
      distance: 0.8,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA5baJlq75-nm2NfayTcSdH6RcZx9Sh2Qsxc96spyteCZFUmqZ_Ew07u_OkPPslO1AFJupBxO1L0oYS5kzT92zt9ajAIRleZy04ocXdvw4L0FW8H6QFCbEcpU3VXUWtNk6wr7zaBst9Mm8aw3pj1Nf9lu3iCbLlH6tgitbRK-n1zg_eP6L6CpJIv9rqyiMODJKReiglTclJxpPmC3EKwPARc--yG80djbwF7Hs1CNWmdoVlHccA6OLWpWLIxI1R0nj8HCmqU-ESeQgX',
      tags: ['Halal'],
      isFavorite: false,
    ),
    FoodItem(
      id: 2,
      name: 'Sate Lilit Ikan Tenggiri Premium',
      merchant: 'Sate Lilit Pak Doble',
      price: 25000,
      rating: 4.9,
      reviews: 312,
      distance: 1.2,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCk0ICVnHQLhTSfLjYU5MIl4gchX39_eqkVv5l-TBVEzYxbB3aeL6ZZ7Xogl34XRHwrcBuhbTvfy2vPY-Hte572wgzMap8yJEFfP0uvuIkcBW5z5QSaRPGKN-EgY00AGhgHR6e-LwT0GfJlCcTliWTvcKWh21OIypMBz7l8OqW5F9i7l8t-1ICrTgr8Xh2MZt1GBXs62tog6y_nkZ36PDwCug_Tro7Un_2XOS5FjxD7mjksEhb0qobdIvCFZYg4Rs5kaFx1xHBBA-e0',
      tags: ['Local Favorite'],
      isFavorite: false,
    ),
    FoodItem(
      id: 3,
      name: 'Paket Jaja Klepon & Laklak Hangat',
      merchant: 'Pasar Sindu Sanur',
      price: 15000,
      rating: 4.6,
      reviews: 89,
      distance: 2.5,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCO3bxf0bdiENfzdF_qSC7OoR7xmh1RNtcKO1TyC45ejx4tkaHZW_4m_qGMMoLq_9SpLQTo23XZ7-hKjba-Z75li7TlwM893Y9uct3DiV5mQY9iRTqY1I4QGpPCLLD3Dtl7uoKwtMi9YQw6xD5ZFx2aCb1GO8P_qE0A4iofV-Flu8v51eWKoYeYGSuFV56QUMsVdZhEVQnnwCP0Jwuutg6o3JohaIeyZZ3h51eNDXupnkAuuUcYwCS3zJXnRJ3IYhV8ZWUgyNnqaSkb',
      tags: ['Jajanan Bali'],
      isFavorite: false,
    ),
    FoodItem(
      id: 4,
      name: 'Es Daluman Gula Aren Asli',
      merchant: 'Kedai Kopi & Es Bali',
      price: 12000,
      rating: 4.7,
      reviews: 210,
      distance: 3.1,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuARb6L-zczajcs-wTuoZl2ZxF9I_sjGdgrpTxXp5JlWQPOfts6shxQiauYY6nkXM0zfycrqCZOMhASk_ojyghxJ_FDrxKvQaF-c0dvLZVyASPa_K3XXNX-hPTlVXFZjVmp6PDTeXp1IHx4FqLNpYKtNzxCYrC1m2MWQoJkJH5TmVby82CbKvGLG9M442Mie2IFVYvUvug8JjP8tD06YosYA5EqKlPfE3bD5ZpF_iT5JaqcVWJiEXrzSE3otQGY8yWWrW-qNfyhjOD4g',
      tags: [],
      isFavorite: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildFoodGrid(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            const SliverToBoxAdapter(child: _Footer()),
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
      backgroundColor: surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 1,
      toolbarHeight: 72,
      title: Text(
        'SIPKULINER',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: primaryColor,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: primaryColor),
          onPressed: () {},
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: primaryColor),
              onPressed: () {},
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: errorColor,
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
              icon: const Icon(Icons.shopping_cart_outlined, color: primaryColor),
              onPressed: () {},
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: secondaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                constraints: const BoxConstraints(minWidth: 18),
                child: Text(
                  '3',
                  style: GoogleFonts.publicSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: onSecondaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: outlineVariant),
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
          'Jelajahi Rasa Denpasar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Dukung UMKM lokal dan nikmati kuliner autentik dengan jaminan kualitas.',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            color: onSurfaceVariant,
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
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: outlineVariant),
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
            color: outlineVariant,
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.search, color: onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
                color: isSelected ? primaryColor : surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected ? primaryColor : outlineVariant,
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
                  color: isSelected ? Colors.white : onSurfaceVariant,
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
            color: primaryColor,
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
              color: secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _FoodCard(item: _foodItems[index]),
        childCount: _foodItems.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900
            ? 4
            : MediaQuery.of(context).size.width > 600
                ? 2
                : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.75 : 0.85,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest.withValues(alpha: 0.9),
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

  Widget _navItem(IconData icon, String label, int index, {bool isActive = false}) {
    final color = (index == _selectedNavIndex) ? secondaryContainer : outlineVariant;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? surfaceContainerLow : Colors.transparent,
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

class FoodItem {
  final int id;
  final String name;
  final String merchant;
  final int price;
  final double rating;
  final int reviews;
  final double distance;
  final String imageUrl;
  final List<String> tags;
  bool isFavorite;

  FoodItem({
    required this.id,
    required this.name,
    required this.merchant,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.imageUrl,
    required this.tags,
    this.isFavorite = false,
  });
}

class _FoodCard extends StatelessWidget {
  final FoodItem item;

  const _FoodCard({required this.item});

  static const Color primaryColor = Color(0xFF002045);
  static const Color secondaryContainer = Color(0xFFFFB55C);
  static const Color onSecondaryContainer = Color(0xFF744600);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFD9E3F9);
  static const Color tertiaryContainer = Color(0xFF73000C);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTags(),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: GoogleFonts.publicSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF121C2C),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.storefront,
                          size: 16, color: onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.merchant,
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            color: onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildRating(),
                  const SizedBox(height: 8),
                  _buildPriceRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: surfaceVariant,
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
        ),
        if (item.tags.contains('Halal'))
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: surfaceContainerLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: tertiaryContainer, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Halal',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (item.tags.contains('Local Favorite'))
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: secondaryContainer, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Local Favorite',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (item.tags.contains('Jajanan Bali'))
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: surfaceContainerLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'Jajanan Bali',
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: surfaceContainerLowest.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.near_me, size: 14, color: onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${item.distance} km',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF121C2C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return const SizedBox.shrink();
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: secondaryContainer, size: 18),
        const SizedBox(width: 4),
        Text(
          '${item.rating}',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF121C2C),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${item.reviews} ulasan)',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: outlineVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rp ${item.price.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.',
          )}',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 20, color: onSecondaryContainer),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  static const Color primaryColor = Color(0xFF002045);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color outlineVariant = Color(0xFFC4C6CF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEFF),
        border: Border(top: BorderSide(color: outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIPKULINER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Platform resmi katalog kuliner dan pemberdayaan UMKM lokal Kota Denpasar. Menghubungkan pecinta kuliner dengan cita rasa autentik.',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        color: onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© 2024 SIPKULINER Denpasar. Supporting Local UMKM.',
                      style: GoogleFonts.publicSans(
                        fontSize: 11,
                        color: outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMASI',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _footerLink('Privacy Policy'),
                    const SizedBox(height: 8),
                    _footerLink('Terms of Service'),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BANTUAN',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _footerLink('Merchant Helpdesk'),
                    const SizedBox(height: 8),
                    _footerLink('Contact Us'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.publicSans(
          fontSize: 14,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
