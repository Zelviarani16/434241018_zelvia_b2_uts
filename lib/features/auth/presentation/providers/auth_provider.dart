import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/services/local_storage_service.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/models/user_model.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => token != null && user != null;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final LocalStorageService _storage;

  AuthNotifier(this._repository, this._storage) : super(AuthState()) {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await _storage.getToken();
    final userData = await _storage.getUser();
    if (token != null && userData != null) {
      state = state.copyWith(
        token: token,
        user: UserModel.fromJson(userData),
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );
      final user = UserModel.fromJson(result['user']);
      final token = result['token'] as String;

      await _storage.saveToken(token);
      await _storage.saveUser(result['user']);

      state = state.copyWith(
        user: user,
        token: token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final storage = ref.watch(localStorageProvider);
  return AuthNotifier(repository, storage);
});