import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '213684503300-uqpbo5ndph1mr18irme5tegmgc07677e.apps.googleusercontent.com',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ─── Email / Password ────────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _createUserDocument(credential.user!);
    return credential;
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create Firestore doc only on first sign-in
      final docRef = _firestore
          .collection(AppConfig.usersCollection)
          .doc(userCredential.user!.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await _createUserDocument(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("AUTH ERROR CODE: ${e.code}");
      print("AUTH ERROR MESSAGE: ${e.message}");
      rethrow;
    } catch (e) {
      print("GOOGLE SIGN-IN ERROR: $e");
      rethrow;
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─── Password Reset ──────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Firestore User Document ─────────────────────────────────────────────────

  Future<void> _createUserDocument(User firebaseUser) async {
    final now = DateTime.now();
    final user = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL ?? '',
      plan: 'free',
      monthlyAudioMinutesUsed: 0,
      monthlyDebatesUsed: 0,
      resetDate: DateTime(now.year, now.month + 1, 1),
      createdAt: now,
    );

    await _firestore
        .collection(AppConfig.usersCollection)
        .doc(firebaseUser.uid)
        .set(UserModel.toFirestoreMap(user));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConfig.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore
        .collection(AppConfig.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
