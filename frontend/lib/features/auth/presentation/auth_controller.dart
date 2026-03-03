import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_to_go/features/auth/data/auth_repository.dart';
import 'package:good_to_go/shared/models/user_model.dart';
import 'package:good_to_go/core/network/dio_provider.dart';

// We need to provide the repository first
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    return _checkAuthStatus();
  }

  Future<User?> _checkAuthStatus() async {
    try {
      final repo = ref.read(authRepositoryProvider);
      return await repo.getCurrentUser();
    } catch (e) {
      // If error (e.g. no token), return null (not logged in)
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email, password);
      return _checkAuthStatus();
    });
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(email, password, name);
      await repo.login(email, password);
      return _checkAuthStatus();
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return null;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      return _checkAuthStatus();
    });
  }
}
