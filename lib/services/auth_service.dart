import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // ─── Register ────────────────────────────────────────────────────────────────
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Save user profile to Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await cred.user!.updateDisplayName(name.trim());
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ─── Login ───────────────────────────────────────────────────────────────────
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Check if admin ──────────────────────────────────────────────────────────
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    try {
      final doc = await _db.collection('users').doc(currentUser!.uid).get();
      return doc.data()?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  // ─── Get user profile ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    try {
      final doc = await _db.collection('users').doc(currentUser!.uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ─── Human-readable error messages ───────────────────────────────────────────
  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
