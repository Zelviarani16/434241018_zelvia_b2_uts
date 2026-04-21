import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/widgets/common_widgets.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/theme/app_theme.dart';
 
class TicketHistoryPage extends ConsumerWidget {
  const TicketHistoryPage({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketState = ref.watch(ticketNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
 
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Tiket',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () =>
                ref.read(ticketNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: ticketState.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(message: e.toString()),
        data: (tickets) {
          final history = tickets
              .where((t) =>
                  t.status == 'resolved' || t.status == 'closed')
              .toList();
 
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 44,
                      color: const Color(0xFF10B981).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF1A1D3B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tiket yang selesai akan muncul di sini',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
 
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final ticket = history[index];
              final statusColor = AppTheme.getStatusColor(ticket.status);
 
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isDark
                      ? Border.all(
                          color: const Color(0xFF2E3147), width: 0.5)
                      : null,
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TicketDetailPage(ticketId: ticket.id),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: statusColor
                                .withOpacity(isDark ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            ticket.status == 'resolved'
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: statusColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFF1A1D3B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                ticket.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor
                                    .withOpacity(isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                ticket.status
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ticket.updatedAt.day}/${ticket.updatedAt.month}/${ticket.updatedAt.year}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}