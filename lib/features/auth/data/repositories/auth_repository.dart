import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/models/user_model.dart';

class AuthRepository {
  // Dummy users — 3 role sesuai SRS
  static final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': '1',
      'name': 'Budi User',
      'email': 'user@example.com',
      'password': '123456',
      'role': 'user',
    },
    {
      'id': '2',
      'name': 'Admin Helpdesk',
      'email': 'admin@example.com',
      'password': '123456',
      'role': 'admin',
    },
    {
      'id': '3',
      'name': 'Siti Helpdesk',
      'email': 'helpdesk@example.com',
      'password': '123456',
      'role': 'helpdesk',
    },
  ];

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final found = _dummyUsers.where(
      (u) => u['email'] == email && u['password'] == password,
    );

    if (found.isEmpty) throw Exception('Email atau password salah');

    final u = found.first;
    return {
      'token': 'dummy_token_${u['role']}_${u['id']}',
      'user': UserModel(
        id: u['id'],
        name: u['name'],
        email: u['email'],
        role: u['role'],
      ).toJson(),
    };
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulasi sukses — role default 'user'
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}