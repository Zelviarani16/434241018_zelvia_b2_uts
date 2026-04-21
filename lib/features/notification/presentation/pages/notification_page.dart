import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/theme/app_theme.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/notification/presentation/providers/notification_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/ticket_detail_page.dart';
 
class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadNotifCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
 
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount belum dibaca',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF94A3B8)
                      : Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationProvider.notifier).markAllAsRead(),
            child: Text(
              'Baca Semua',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF4F7EFF)
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F7EFF).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 44,
                      color: const Color(0xFF4F7EFF).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1A1D3B),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final statusColor = AppTheme.getStatusColor(notif.status);
 
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) =>
                      ref.read(notificationProvider.notifier).remove(notif.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 18),
                    child: const Icon(Icons.delete_rounded,
                        color: Colors.white, size: 20),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? (isDark
                              ? const Color(0xFF1C1F2E)
                              : Colors.white)
                          : (isDark
                              ? const Color(0xFF1C2240)
                              : const Color(0xFFF0F4FF)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: notif.isRead
                            ? (isDark
                                ? const Color(0xFF2E3147)
                                : Colors.transparent)
                            : const Color(0xFF4F7EFF).withOpacity(
                                isDark ? 0.3 : 0.2),
                        width: 0.8,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        ref
                            .read(notificationProvider.notifier)
                            .markAsRead(notif.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailPage(ticketId: notif.ticketId),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: statusColor
                                    .withOpacity(isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                _icon(notif.status),
                                color: statusColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif.title,
                                          style: TextStyle(
                                            fontWeight: notif.isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                            fontSize: 13,
                                            color: isDark
                                                ? const Color(0xFFE2E8F0)
                                                : const Color(0xFF1A1D3B),
                                          ),
                                        ),
                                      ),
                                      if (!notif.isRead)
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4F7EFF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    notif.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : Colors.grey.shade500,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _time(notif.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? const Color(0xFF475569)
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
 
  IconData _icon(String status) {
    switch (status) {
      case 'open': return Icons.folder_open_rounded;
      case 'in_progress': return Icons.pending_rounded;
      case 'resolved': return Icons.check_circle_rounded;
      case 'closed': return Icons.cancel_rounded;
      default: return Icons.notifications_rounded;
    }
  }
 
  String _time(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}