import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/models/user_model.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Data dummy
    if (email == 'user@example.com' && password == '123456') {
      return {
        'token': 'dummy_token_user_123',
        'user': UserModel(
          id: '1',
          name: 'John User',
          email: email,
          role: 'user',
        ).toJson(),
      };
    } else if (email == 'admin@example.com' && password == '123456') {
      return {
        'token': 'dummy_token_admin_456',
        'user': UserModel(
          id: '2',
          name: 'Admin Helpdesk',
          email: email,
          role: 'admin',
        ).toJson(),
      };
    }
    throw Exception('Email atau password salah');
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulasi sukses register
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}