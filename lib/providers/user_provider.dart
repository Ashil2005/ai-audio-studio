import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

// Stream of current user's full Firestore profile
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final firebaseUser = ref.watch(currentUserProvider);
  if (firebaseUser == null) return const Stream.empty();
  return ref.watch(authServiceProvider).watchUserProfile(firebaseUser.uid);
});

// Simple bool indicating premium status (local flag only for MVP)
final isPremiumProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.plan == 'premium';
});
