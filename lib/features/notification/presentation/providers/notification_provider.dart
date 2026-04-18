import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String ticketId;
  final String status;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.ticketId,
    required this.status,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      ticketId: ticketId,
      status: status,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier()
      : super([
          NotificationModel(
            id: '1',
            title: 'Tiket Diproses',
            message: 'Tiket "Internet lambat di gedung A" sedang diproses.',
            ticketId: '2',
            status: 'in_progress',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          NotificationModel(
            id: '2',
            title: 'Tiket Diselesaikan',
            message: 'Tiket "Software tidak bisa diinstall" telah diselesaikan.',
            ticketId: '3',
            status: 'resolved',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          NotificationModel(
            id: '3',
            title: 'Tiket Baru',
            message: 'Tiket "Komputer tidak bisa menyala" telah diterima.',
            ticketId: '1',
            status: 'open',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ]);

  // Tandai satu notifikasi sudah dibaca
  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  // Tandai semua sudah dibaca
  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  // Hapus notifikasi
  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  // Jumlah yang belum dibaca
  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);

// Provider khusus untuk unread count — dipakai di badge dashboard
final unreadNotifCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationProvider);
  return notifs.where((n) => !n.isRead).length;
});