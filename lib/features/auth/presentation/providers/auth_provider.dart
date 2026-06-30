import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/models/user_model.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/repositories/auth_repository.dart';

class AuthState {
  final UserModel? user;
  final String? token;  // ← tambah token
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.token, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, String? token, bool? isLoading, String? error}) {
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

  AuthNotifier(this._repository) : super(const AuthState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final token = prefs.getString('auth_token');
    if (userData != null && token != null) {
      final user = UserModel.fromJson(jsonDecode(userData));
      state = state.copyWith(user: user, token: token);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.login(email: email, password: password);
      final user = UserModel.fromJson(result['user']);
      final token = result['token'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('auth_token', token);

      state = state.copyWith(user: user, token: token, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    if (state.token != null) {
      await _repository.logout(token: state.token!);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository());
});