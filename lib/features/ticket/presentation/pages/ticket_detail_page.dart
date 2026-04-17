import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/widgets/common_widgets.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/repositories/ticket_repository.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/theme/app_theme.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: ticketAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(message: e.toString()),
        data: (ticket) {
          // ✅ Deklarasi variabel di sini, sebelum return
          final authState = ref.watch(authProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            StatusBadge(status: ticket.status),
                            const SizedBox(width: 8),
                            PriorityBadge(priority: ticket.priority),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ticket.category,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ticket.description,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dibuat: ${_formatDate(ticket.createdAt)}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tracking Status
                const Text(
                  'Tracking Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildTracking(ticket.status),
                const SizedBox(height: 16),

                // ✅ Admin Panel - posisi benar di dalam children
                if (authState.user?.role == 'admin') ...[
                  const Text(
                    'Kelola Tiket (Admin)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Update Status
                  DropdownButtonFormField<String>(
                    value: ticket.status,
                    decoration: const InputDecoration(
                      labelText: 'Update Status',
                      prefixIcon: Icon(Icons.update_outlined),
                    ),
                    items: ['open', 'in_progress', 'resolved', 'closed']
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.replaceAll('_', ' ').toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (newStatus) async {
                      if (newStatus != null) {
                        await TicketRepository().updateTicketStatus(
                          ticketId: ticket.id,
                          status: newStatus,
                        );
                        ref.invalidate(ticketDetailProvider(ticket.id));
                        ref.invalidate(ticketNotifierProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Status diubah ke $newStatus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Assign Tiket
                  DropdownButtonFormField<String>(
                    value: ticket.assignedTo,
                    decoration: const InputDecoration(
                      labelText: 'Assign ke Helpdesk',
                      prefixIcon: Icon(Icons.person_add_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Belum di-assign')),
                      DropdownMenuItem(value: '2', child: Text('Admin Helpdesk')),
                      DropdownMenuItem(value: '3', child: Text('Helpdesk 1')),
                      DropdownMenuItem(value: '4', child: Text('Helpdesk 2')),
                    ],
                    onChanged: (assignedTo) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tiket di-assign ke $assignedTo'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Komentar
                const Text(
                  'Komentar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (ticket.comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Belum ada komentar'),
                    ),
                  )
                else
                  ...ticket.comments.map((comment) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: comment.authorRole == 'admin'
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: comment.authorRole == 'admin'
                                ? Colors.blue.shade200
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: comment.authorRole == 'admin'
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    comment.authorRole,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(comment.content),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(comment.createdAt),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 16),

                // Input Komentar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Komentar terkirim!')),
                          );
                          _commentController.clear();
                        }
                      },
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTracking(String currentStatus) {
    final steps = [
      {'status': 'open', 'label': 'Tiket Dibuat', 'icon': Icons.add_circle},
      {'status': 'in_progress', 'label': 'Sedang Diproses', 'icon': Icons.pending},
      {'status': 'resolved', 'label': 'Diselesaikan', 'icon': Icons.check_circle},
      {'status': 'closed', 'label': 'Ditutup', 'icon': Icons.cancel},
    ];

    final statusOrder = ['open', 'in_progress', 'resolved', 'closed'];
    final currentIndex = statusOrder.indexOf(currentStatus);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index <= currentIndex;
        final color = isCompleted
            ? AppTheme.getStatusColor(step['status'] as String)
            : Colors.grey.shade300;

        return Expanded(
          child: Column(
            children: [
              Icon(step['icon'] as IconData, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                step['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: isCompleted ? color : Colors.grey,
                  fontWeight:
                      isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              if (index < steps.length - 1)
                Container(
                  height: 2,
                  color: index < currentIndex
                      ? AppTheme.successColor
                      : Colors.grey.shade300,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}