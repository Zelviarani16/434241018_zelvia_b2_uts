import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/constants/app_constants.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String ticketId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.ticketId,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      ticketId: json['ticket_id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id, title: title, message: message,
      ticketId: ticketId, createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  NotificationNotifier() : super([]) {
    loadNotifications();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> loadNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await _dio.get('/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List data = response.data['notifications'];
      state = data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      await _dio.patch('/notifications/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      state = [
        for (final n in state)
          if (n.id == id) n.copyWith(isRead: true) else n,
      ];
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      await _dio.patch('/notifications/read-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      state = [for (final n in state) n.copyWith(isRead: true)];
    } catch (_) {}
  }

  Future<void> remove(String id) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      await _dio.delete('/notifications/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      state = state.where((n) => n.id != id).toList();
    } catch (_) {
      // Jika terjadi error dari API, tetap hapus dari state lokal (optimistic update)
      // atau biarkan tergantung kebutuhan. Kita hapus saja dari UI.
      state = state.where((n) => n.id != id).toList();
    }
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);

final unreadNotifCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationProvider);
  return notifs.where((n) => !n.isRead).length;
});