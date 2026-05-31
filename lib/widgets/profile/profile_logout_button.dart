import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: () async {
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
          if (confirm == true && context.mounted) {
            try {
              // Sign out secara nyata dari Supabase dan hapus session lokal secara paksa
              await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
            } catch (e) {
              debugPrint('Logout error: $e');
            }
            
            if (context.mounted) {
              // Kembali ke AuthWrapper (rute '/') agar state di-reset
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout, size: 20), const SizedBox(width: 8),
          Text('Keluar', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      )));
  }
}
