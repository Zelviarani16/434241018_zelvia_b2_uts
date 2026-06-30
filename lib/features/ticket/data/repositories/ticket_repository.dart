import 'package:dio/dio.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/constants/app_constants.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';

class TicketRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  Options _authHeader(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<TicketModel>> getTickets({String? status, String? userId, required String token}) async {
    try {
      final response = await _dio.get('/tickets', options: _authHeader(token));
      final List data = response.data['tickets'];
      return data.map((e) => TicketModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengambil tiket');
    }
  }

  Future<TicketModel> getTicketDetail(String id, {required String token}) async {
    try {
      final response = await _dio.get('/tickets/$id', options: _authHeader(token));
      return TicketModel.fromJson(response.data['ticket']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Tiket tidak ditemukan');
    }
  }

  Future<List<Map<String, dynamic>>> getHelpdeskUsers({required String token}) async {
  try {
    final response = await _dio.get('/users/helpdesk', options: _authHeader(token));
    final List data = response.data['helpdesks'];
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  } on DioException catch (e) {
    throw Exception(e.response?.data?['message'] ?? 'Gagal mengambil helpdesk');
  }
}

  Future<TicketStatsModel> getTicketStats({String? userId, required String token}) async {
    try {
      final response = await _dio.get('/tickets/stats', options: _authHeader(token));
      final s = response.data['stats'];
      return TicketStatsModel(
        total: s['total'],
        open: s['open'],
        inProgress: s['in_progress'],
        resolved: s['resolved'],
        closed: s['closed'],
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengambil statistik');
    }
  }

  /// Stats untuk helpdesk: hanya tiket yang di-assign ke user dengan [helpdeskId]
  Future<TicketStatsModel> getHelpdeskStats({required String helpdeskId, required String token}) async {
    try {
      final response = await _dio.get(
        '/tickets/stats',
        queryParameters: {'assigned_to': helpdeskId},
        options: _authHeader(token),
      );
      final s = response.data['stats'];
      return TicketStatsModel(
        total: s['total'],
        open: s['open'],
        inProgress: s['in_progress'],
        resolved: s['resolved'],
        closed: s['closed'],
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengambil statistik helpdesk');
    }
  }

  /// Daftar tiket yang di-assign ke helpdesk tertentu
  Future<List<TicketModel>> getAssignedTickets({required String helpdeskId, String? status, required String token}) async {
    try {
      final Map<String, dynamic> queryParams = {'assigned_to': helpdeskId};
      if (status != null) queryParams['status'] = status;
      final response = await _dio.get(
        '/tickets',
        queryParameters: queryParams,
        options: _authHeader(token),
      );
      final List data = response.data['tickets'];
      return data.map((e) => TicketModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengambil tiket helpdesk');
    }
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required String category,
    required String createdBy,
    required String token,
  }) async {
    try {
      final response = await _dio.post('/tickets',
        data: {'title': title, 'description': description, 'priority': priority, 'category': category},
        options: _authHeader(token),
      );
      return TicketModel.fromJson(response.data['ticket']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal membuat tiket');
    }
  }

  Future<void> updateTicketStatus({required String ticketId, required String status, required String token}) async {
    try {
      await _dio.patch('/tickets/$ticketId',
        data: {'status': status},
        options: _authHeader(token),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal update tiket');
    }
  }

  Future<void> assignTicket({required String ticketId, String? assignedTo, required String token}) async {
    try {
      await _dio.patch('/tickets/$ticketId',
        data: {'assigned_to': assignedTo},
        options: _authHeader(token),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal assign tiket');
    }
  }

  Future<void> addComment({
    required String ticketId,
    required String content,
    required String authorName,
    required String authorRole,
    required String token,
  }) async {
    try {
      await _dio.post('/tickets/$ticketId/comments',
        data: {'content': content},
        options: _authHeader(token),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal menambah komentar');
    }
  }
}