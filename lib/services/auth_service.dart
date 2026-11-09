import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'student',
    String? linkedStudentId,
  }) async {
    try {
      final normalizedRole = role == 'parent' ? 'parent' : 'student';
      if (normalizedRole == 'parent' &&
          (linkedStudentId == null || linkedStudentId.trim().isEmpty)) {
        return 'Enter the Student ID provided by the student.';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _db.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': normalizedRole,
        if (normalizedRole == 'parent')
          'linkedStudentId': linkedStudentId!.trim(),
        if (normalizedRole == 'parent') 'linkApproved': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await credential.user!.updateDisplayName(name.trim());
      return null;
    } on FirebaseAuthException catch (error) {
      return _authError(error.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      return _authError(error.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> logout() async {
    await NotificationService.unsubscribeForLogout();
    await _auth.signOut();
  }

  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.data()?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  Future<String?> getAccessibleStudentId() async {
    final user = currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data?['role'] == 'parent') {
      if (data?['linkApproved'] != true) return null;
      final linkedId = (data?['linkedStudentId'] as String?)?.trim();
      return linkedId == null || linkedId.isEmpty ? null : linkedId;
    }
    return user.uid;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

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
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
