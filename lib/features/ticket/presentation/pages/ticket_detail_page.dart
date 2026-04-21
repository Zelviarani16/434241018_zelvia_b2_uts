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
      ref.invalidate(ticketStatsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan berhasil disimpan!'),
            backgroundColor: Color(0xFF10B981),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
 
    // colors
    final cardColor = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF2E3147) : Colors.transparent;
    final textPrimary = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1A1D3B);
    final textSecondary = isDark ? const Color(0xFF64748B) : Colors.grey.shade500;
    final inputFill = isDark ? const Color(0xFF252839) : const Color(0xFFF4F6FB);
 
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Tiket',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ticketAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(message: e.toString()),
        data: (ticket) {
          _selectedStatus ??= ticket.status;
 
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
 
                // Info card
                _Card(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Chip(
                            label: ticket.category,
                            bg: const Color(0xFF4F7EFF)
                                .withOpacity(isDark ? 0.15 : 0.08),
                            fg: const Color(0xFF4F7EFF),
                          ),
                          const Spacer(),
                          _Chip(
                            label: ticket.status
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            bg: AppTheme.getStatusColor(ticket.status)
                                .withOpacity(isDark ? 0.15 : 0.1),
                            fg: AppTheme.getStatusColor(ticket.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ticket.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.description,
                        style: TextStyle(
                          color: textSecondary,
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.flag_rounded,
                            label: ticket.priority.toUpperCase(),
                            color: AppTheme.getPriorityColor(ticket.priority),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          if (ticket.assignedTo != null)
                            _MetaChip(
                              icon: Icons.person_rounded,
                              label: _assigneeName(ticket.assignedTo),
                              color: const Color(0xFF7C5CFC),
                              isDark: isDark,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dibuat: ${_fmt(ticket.createdAt)}',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
 
                // Tracking
                _SectionLabel(label: 'Tracking Status', textColor: textPrimary),
                const SizedBox(height: 10),
                _Card(
                  isDark: isDark,
                  child: _buildTracking(ticket.status, isDark),
                ),
                const SizedBox(height: 14),
 
                // Admin panel
                if (isAdminOrHelpdesk) ...[
                  _SectionLabel(label: 'Kelola Tiket', textColor: textPrimary),
                  const SizedBox(height: 10),
                  _Card(
                    isDark: isDark,
                    borderColor: const Color(0xFFFF9F43).withOpacity(0.3),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          dropdownColor:
                              isDark ? const Color(0xFF252839) : Colors.white,
                          style: TextStyle(
                              color: textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Update Status',
                            labelStyle: TextStyle(
                                color: textSecondary, fontSize: 13),
                            prefixIcon: Icon(Icons.update_rounded,
                                color: textSecondary, size: 20),
                            filled: true,
                            fillColor: inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: cardBorder, width: 0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: cardBorder, width: 0.8),
                            ),
                          ),
                          items: ['open', 'in_progress', 'resolved', 'closed']
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(color: textPrimary),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedStatus = v),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedAssignee ?? ticket.assignedTo,
                          dropdownColor:
                              isDark ? const Color(0xFF252839) : Colors.white,
                          style: TextStyle(
                              color: textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Assign ke Helpdesk',
                            labelStyle: TextStyle(
                                color: textSecondary, fontSize: 13),
                            prefixIcon: Icon(Icons.person_add_rounded,
                                color: textSecondary, size: 20),
                            filled: true,
                            fillColor: inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: cardBorder, width: 0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: cardBorder, width: 0.8),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('Belum di-assign',
                                  style: TextStyle(color: textPrimary)),
                            ),
                            DropdownMenuItem(
                              value: '3',
                              child: Text('Siti Helpdesk',
                                  style: TextStyle(color: textPrimary)),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedAssignee = v),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9F43),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_rounded, size: 18),
                            label: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
 
                // Komentar
                _SectionLabel(
                  label: 'Komentar',
                  trailing: '${ticket.comments.length}',
                  textColor: textPrimary,
                ),
                const SizedBox(height: 10),
 
                if (ticket.comments.isEmpty)
                  _Card(
                    isDark: isDark,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                color: textSecondary.withOpacity(0.4),
                                size: 28),
                            const SizedBox(height: 6),
                            Text(
                              'Belum ada komentar',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...ticket.comments.map((c) {
                    final isUser = c.authorRole == 'user';
                    final bubbleColor = isUser
                        ? (isDark
                            ? const Color(0xFF1C1F2E)
                            : Colors.white)
                        : (isDark
                            ? const Color(0xFF1A2040)
                            : const Color(0xFFF0F4FF));
                    final bubbleBorder = isUser
                        ? (isDark
                            ? const Color(0xFF2E3147)
                            : const Color(0xFFE4E8F0))
                        : const Color(0xFF4F7EFF).withOpacity(
                            isDark ? 0.25 : 0.15);
 
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bubbleBorder, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: isUser
                                    ? Colors.grey.withOpacity(
                                        isDark ? 0.3 : 0.15)
                                    : const Color(0xFF4F7EFF)
                                        .withOpacity(0.15),
                                child: Text(
                                  c.authorName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isUser
                                        ? textSecondary
                                        : const Color(0xFF4F7EFF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.authorName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      c.authorRole.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isUser
                                            ? textSecondary
                                            : const Color(0xFF4F7EFF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _fmt(c.createdAt),
                                style: TextStyle(
                                    fontSize: 9, color: textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            c.content,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary
                                  .withOpacity(isDark ? 1 : 0.85),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
 
                const SizedBox(height: 12),
 
                // Input komentar
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder, width: 0.8),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          maxLines: 3,
                          minLines: 1,
                          style: TextStyle(
                              color: textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: role == 'user'
                                ? 'Tulis balasan...'
                                : 'Tulis respon...',
                            hintStyle: TextStyle(
                                color: textSecondary, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _sendComment(
                            role, authState.user?.name ?? 'User'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F7EFF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
 
  String _assigneeName(String? id) {
    switch (id) {
      case '3': return 'Siti Helpdesk';
      default: return 'Belum di-assign';
    }
  }
 
  Widget _buildTracking(String currentStatus, bool isDark) {
    final steps = [
      {'status': 'open', 'label': 'Dibuat', 'icon': Icons.add_circle_rounded},
      {'status': 'in_progress', 'label': 'Diproses', 'icon': Icons.pending_rounded},
      {'status': 'resolved', 'label': 'Selesai', 'icon': Icons.check_circle_rounded},
      {'status': 'closed', 'label': 'Ditutup', 'icon': Icons.cancel_rounded},
    ];
    final order = ['open', 'in_progress', 'resolved', 'closed'];
    final currentIdx = order.indexOf(currentStatus);
 
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final done = i <= currentIdx;
        final color = done
            ? AppTheme.getStatusColor(step['status'] as String)
            : (isDark ? const Color(0xFF2E3147) : Colors.grey.shade200);
 
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: done
                            ? (AppTheme.getStatusColor(
                                    step['status'] as String))
                                .withOpacity(isDark ? 0.2 : 0.12)
                            : color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: done
                            ? AppTheme.getStatusColor(
                                step['status'] as String)
                            : (isDark
                                ? const Color(0xFF475569)
                                : Colors.grey.shade400),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      step['label'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        color: done
                            ? AppTheme.getStatusColor(
                                step['status'] as String)
                            : (isDark
                                ? const Color(0xFF475569)
                                : Colors.grey.shade400),
                        fontWeight: done
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Container(
                  height: 2,
                  width: 16,
                  color: i < currentIdx
                      ? AppTheme.successColor.withOpacity(0.6)
                      : (isDark
                          ? const Color(0xFF2E3147)
                          : Colors.grey.shade200),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
 
  String _fmt(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}
 
// Helper widgets
class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? borderColor;
  const _Card({required this.child, required this.isDark, this.borderColor});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ??
              (isDark ? const Color(0xFF2E3147) : Colors.transparent),
          width: 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }
}
 
class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
 
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  const _MetaChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.isDark});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
 
class _SectionLabel extends StatelessWidget {
  final String label;
  final String? trailing;
  final Color textColor;
  const _SectionLabel(
      {required this.label, this.trailing, required this.textColor});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor)),
        if (trailing != null) ...[
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(trailing!,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4F7EFF),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}