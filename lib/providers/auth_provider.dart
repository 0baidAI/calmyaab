import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class StudentNotifier extends StateNotifier<AsyncValue<StudentModel?>> {
  StudentNotifier(this._authService) : super(const AsyncValue.data(null));
  final AuthService _authService;

  Future<AuthResult> register({
    required String name, required String email, required String password,
    required String phone, required String university, required String field,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authService.register(
      name: name, email: email, password: password,
      phone: phone, university: university, field: field,
    );
    state = result.success ? AsyncValue.data(result.student) : const AsyncValue.data(null);
    return result;
  }

  Future<AuthResult> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await _authService.login(email: email, password: password);
    state = result.success ? AsyncValue.data(result.student) : const AsyncValue.data(null);
    return result;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}

final studentProvider = StateNotifierProvider<StudentNotifier, AsyncValue<StudentModel?>>(
  (ref) => StudentNotifier(ref.watch(authServiceProvider)),
);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});
