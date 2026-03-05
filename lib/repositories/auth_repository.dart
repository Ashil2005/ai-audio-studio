import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Stream<fb.User?> get authState => _authService.authStateChanges;
  fb.User? get currentUser => _authService.currentUser;

  Future<({bool success, String? error})> signIn(
      String email, String password) async {
    try {
      await _authService.signInWithEmail(email, password);
      return (success: true, error: null);
    } on fb.FirebaseAuthException catch (e) {
      return (success: false, error: _mapAuthError(e.code));
    }
  }

  Future<({bool success, String? error})> register(
      String email, String password) async {
    try {
      await _authService.registerWithEmail(email, password);
      return (success: true, error: null);
    } on fb.FirebaseAuthException catch (e) {
      return (success: false, error: _mapAuthError(e.code));
    }
  }

  Future<({bool success, String? error})> signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) return (success: false, error: 'Sign-in cancelled');
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  Future<void> signOut() => _authService.signOut();

  Future<({bool success, String? error})> sendPasswordReset(
      String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return (success: true, error: null);
    } on fb.FirebaseAuthException catch (e) {
      return (success: false, error: _mapAuthError(e.code));
    }
  }

  Stream<UserModel?> watchProfile(String uid) =>
      _authService.watchUserProfile(uid);

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
