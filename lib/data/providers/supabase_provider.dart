import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(supabaseProvider).auth.onAuthStateChange;
});

final userProvider = Provider<User?>((ref) {
  return ref.read(supabaseProvider).auth.currentUser;
});
