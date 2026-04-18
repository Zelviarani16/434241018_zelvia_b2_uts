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
  String? _selectedStatus;
  String? _selectedAssignee;
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _sendComment(String role, String name) async {
    if (_commentController.text.trim().isEmpty) return;
    final content = _commentController.text.trim();
    _commentController.clear();

    await TicketRepository().addComment(
      ticketId: widget.ticketId,
      content: content,
      authorName: name,
      authorRole: role,
    );
    // Refresh detail agar komentar tampil
    ref.invalidate(ticketDetailProvider(widget.ticketId));
    ref.invalidate(ticketNotifierProvider);
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      if (_selectedStatus != null) {
        await TicketRepository().updateTicketStatus(
          ticketId: widget.ticketId,
          status: _selectedStatus!,
        );
      }
      if (_selectedAssignee != null) {
        await TicketRepository().assignTicket(
          ticketId: widget.ticketId,
          assignedTo: _selectedAssignee,
        );
      }
      ref.invalidate(ticketDetailProvider(widget.ticketId));
      ref.invalidate(ticketNotifierProvider);
      ref.invalidate(ticketStatsProvider); // Update statistik dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedStatus = null;
          _selectedAssignee = null;
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final authState = ref.watch(authProvider);
    final role = authState.user?.role ?? 'user';
    final isAdminOrHelpdesk = role == 'admin' || role == 'helpdesk';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: ticketAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(message: e.toString()),
        data: (ticket) {
          // Inisialisasi nilai dropdown dari data tiket
          _selectedStatus ??= ticket.status;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER CARD =====
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
                              child: Text(ticket.category,
                                  style: const TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(ticket.description,
                            style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Text(
                          'Dibuat: ${_formatDate(ticket.createdAt)}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        if (ticket.assignedTo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Assigned ke: ${_getAssigneeName(ticket.assignedTo)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.blue.shade600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ===== TRACKING STATUS =====
                const Text('Tracking Status',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildTracking(ticket.status),
                const SizedBox(height: 16),

                // ===== PANEL KELOLA (ADMIN & HELPDESK) =====
                if (isAdminOrHelpdesk) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings_outlined,
                                color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Panel Kelola Tiket (${role.toUpperCase()})',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Update Status
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Update Status',
                            prefixIcon: Icon(Icons.update_outlined),
                          ),
                          items: ['open', 'in_progress', 'resolved', 'closed']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                        s.replaceAll('_', ' ').toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedStatus = v),
                        ),
                        const SizedBox(height: 12),

                        // Assign Tiket (Admin & Helpdesk sesuai FR-006)
                        // DropdownButtonFormField<String>(
                        //   value: _selectedAssignee ?? ticket.assignedTo,
                        //   decoration: const InputDecoration(
                        //     labelText: 'Assign ke Helpdesk',
                        //     prefixIcon: Icon(Icons.person_add_outlined),
                        //   ),
                        //   items: const [
                        //     DropdownMenuItem(
                        //         value: null,
                        //         child: Text('Belum di-assign')),
                        //     DropdownMenuItem(
                        //         value: '2',
                        //         child: Text('Admin Helpdesk')),
                        //     DropdownMenuItem(
                        //         value: '3', child: Text('Helpdesk - Siti')),
                        //   ],
                        //   onChanged: (v) =>
                        //       setState(() => _selectedAssignee = v),


                        // Assign Tiket — target HANYA helpdesk (bukan admin)
DropdownButtonFormField<String>(
  value: _selectedAssignee ?? ticket.assignedTo,
  decoration: const InputDecoration(
    labelText: 'Assign ke Helpdesk',
    prefixIcon: Icon(Icons.person_add_outlined),
  ),
  items: const [
    DropdownMenuItem(
      value: null,
      child: Text('Belum di-assign'),
    ),
    DropdownMenuItem(
      value: '3',
      child: Text('Siti Helpdesk'),
    ),
    // Tambah helpdesk lain di sini kalau ada
  ],
  onChanged: (v) => setState(() => _selectedAssignee = v),

                        ),
                        const SizedBox(height: 16),

                        // Tombol Simpan Perubahan
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: const Text('Simpan Perubahan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ===== KOMENTAR =====
                const Text('Komentar',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (ticket.comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Belum ada komentar')),
                  )
                else
                  ...ticket.comments.map((comment) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: comment.authorRole == 'user'
                              ? Colors.grey.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: comment.authorRole == 'user'
                                ? Colors.grey.shade200
                                : Colors.blue.shade200,
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
                                    color: comment.authorRole == 'user'
                                        ? Colors.grey
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    comment.authorRole.toUpperCase(),
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

                // ===== INPUT KOMENTAR — semua role bisa =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: role == 'user'
                              ? 'Tulis balasan...'
                              : 'Tulis respon helpdesk...',
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _sendComment(
                        role,
                        authState.user?.name ?? 'User',
                      ),
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getAssigneeName(String? id) {
    switch (id) {
      case '2':
        return 'Admin Helpdesk';
      case '3':
        return 'Helpdesk - Siti';
      default:
        return 'Belum di-assign';
    }
  }

  Widget _buildTracking(String currentStatus) {
    final steps = [
      {'status': 'open', 'label': 'Dibuat', 'icon': Icons.add_circle},
      {'status': 'in_progress', 'label': 'Diproses', 'icon': Icons.pending},
      {'status': 'resolved', 'label': 'Selesai', 'icon': Icons.check_circle},
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