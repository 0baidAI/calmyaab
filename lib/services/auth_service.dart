import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class AuthResult {
  final bool success;
  final String? error;
  final StudentModel? student;

  const AuthResult({required this.success, this.error, this.student});

  factory AuthResult.ok(StudentModel student) =>
      AuthResult(success: true, student: student);

  factory AuthResult.fail(String error) =>
      AuthResult(success: false, error: error);
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String university,
    required String field,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      await cred.user!.updateDisplayName(name);

      final student = StudentModel(
        uid: cred.user!.uid,
        name: name.trim(), email: email.trim(),
        phone: phone.trim(), university: university.trim(),
        field: field, paidServices: [], createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(cred.user!.uid).set(student.toMap());
      return AuthResult.ok(student);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_authError(e.code));
    } catch (e) {
      return AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) return AuthResult.fail('Account data not found.');
      return AuthResult.ok(StudentModel.fromMap(doc.data()!, cred.user!.uid));
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_authError(e.code));
    } catch (e) {
      return AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.fail(_authError(e.code));
    } catch (e) {
      return AuthResult.fail('Something went wrong. Please try again.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<StudentModel?> fetchStudent(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return StudentModel.fromMap(doc.data()!, uid);
    } catch (_) { return null; }
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':   return 'This email is already registered. Please login instead.';
      case 'invalid-email':          return 'Please enter a valid email address.';
      case 'weak-password':          return 'Password must be at least 6 characters.';
      case 'user-not-found':         return 'No account found with this email.';
      case 'wrong-password':         return 'Incorrect password. Please try again.';
      case 'invalid-credential':     return 'Incorrect email or password.';
      case 'too-many-requests':      return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'Network error. Please check your connection.';
      default:                       return 'Authentication failed. Please try again.';
    }
  }
}
