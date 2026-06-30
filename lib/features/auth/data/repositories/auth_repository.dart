import 'package:dio/dio.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/constants/app_constants.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return {
        'token': response.data['token'],
        'user': response.data['user'],
      };
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Gagal terhubung ke server');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
    } on DioException catch (e) {
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Registrasi gagal');
    }
  }

  Future<void> logout({required String token}) async {
    try {
      await _dio.post('/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {}
  }
}