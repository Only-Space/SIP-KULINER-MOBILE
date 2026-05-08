# SIPKULINER

Aplikasi mobile untuk menjelajahi kuliner lokal Bali. SIPKULINER membantu pengguna menemukan rekomendasi makanan terdekat, menjelajahi berbagai kategori kuliner khas Bali, dan mengelola profil pengguna.

## Fitur

- **Login**: Autentikasi pengguna dengan validasi email dan password
- **Lupa Password**: Halaman pemulihan password dengan validasi email
- **Dashboard**: Halaman utama dengan rekomendasi kuliner terdekat
- **Pencarian**: Fitur pencarian makanan
- **Kategori**: Filter makanan berdasarkan kategori (Jajanan Bali, Nasi Campur, Sate & Panggang, Minuman Segar, Oleh-Oleh)
- **Profil**: Halaman profil pengguna dengan menu pengaturan dan opsi logout
- **Bottom Navigation**: Navigasi mudah antar halaman utama

## Cara Menjalankan Aplikasi

1. Pastikan Flutter sudah terinstall di komputer Anda
2. Clone repository ini
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Screenshot

| Login Page | Dashboard Page | Profile Page | Forgot Password Page |
|------------|----------------|--------------|---------------------|
| ![Login](assets/images/WhatsApp%20Image%202026-05-08%20at%2010.26.40.jpeg) | ![Dashboard](assets/images/WhatsApp%20Image%202026-05-08%20at%2010.26.40%281%29.jpeg) | ![Profile](assets/images/WhatsApp%20Image%202026-05-08%20at%2010.26.40%282%29.jpeg) | ![Forgot](assets/images/WhatsApp%20Image%202026-05-08%20at%2010.26.41.jpeg) |
| <sub>Halaman login dengan validasi email dan password</sub> | <sub>Halaman utama dengan rekomendasi kuliner terdekat</sub> | <sub>Halaman profil pengguna</sub> | <sub>Halaman lupa password</sub> |

## Assets

Aplikasi ini menggunakan gambar yang tersimpan di folder `assets/images/`:

| File | Deskripsi |
|------|-----------|
| `WhatsApp Image 2026-05-08 at 10.26.40.jpeg` | Screenshot Login Page |
| `WhatsApp Image 2026-05-08 at 10.26.40(1).jpeg` | Screenshot Dashboard Page |
| `WhatsApp Image 2026-05-08 at 10.26.40(2).jpeg` | Screenshot Profile Page |
| `WhatsApp Image 2026-05-08 at 10.26.41.jpeg` | Screenshot Forgot Password Page |

Pastikan folder `assets/images/` terdaftar di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

## Package yang Digunakan

| Package | Versi | Deskripsi |
|---------|-------|-----------|
| `flutter` | SDK | Framework utama Flutter |
| `cupertino_icons` | ^1.0.8 | Ikon Cupertino untuk iOS style |
| `google_fonts` | ^8.1.0 | Font Google (Plus Jakarta Sans, Public Sans) |
| `flutter_test` | SDK | Testing framework (dev) |
| `flutter_lints` | ^6.0.0 | Lint rules untuk kode Flutter (dev) |

## Struktur Halaman

- `/` - Login Page
- `/forgot-password` - Forgot Password Page
- `/dashboard` - Dashboard Page (setelah login)
- `/profile` - Profile Page
