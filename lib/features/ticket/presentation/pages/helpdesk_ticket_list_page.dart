import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/widgets/common_widgets.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/data/models/ticket_model.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/theme/app_theme.dart';

/// Halaman daftar tiket khusus helpdesk.
/// Hanya menampilkan tiket yang ditugaskan kepada helpdesk yang sedang login.
/// Sesuai SRS FR-006: Melihat semua tiket yang ditugaskan.
class HelpdeskTicketListPage extends ConsumerStatefulWidget {
  /// Jika diisi, daftar difilter berdasarkan status ini.
  final String? filterStatus;

  const HelpdeskTicketListPage({super.key, this.filterStatus});

  @override
  ConsumerState<HelpdeskTicketListPage> createState() =>
      _HelpdeskTicketListPageState();
}

class _HelpdeskTicketListPageState
    extends ConsumerState<HelpdeskTicketListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab: Semua / Open / In Progress / Resolved / Closed
  static const _tabs = <String?>[null, 'open', 'in_progress', 'resolved', 'closed'];
  static const _tabLabels = ['Semua', 'Open', 'Proses', 'Selesai', 'Tutup'];

  @override
  void initState() {
    super.initState();
    // Bila ada filterStatus bawaan, pilih tab yang sesuai
    final initialIndex = widget.filterStatus == null
        ? 0
        : _tabs.indexOf(widget.filterStatus).clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(helpdeskTicketNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tiket Ditugaskan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(helpdeskTicketNotifierProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorWeight: 3,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((status) {
          return ticketState.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => CustomErrorWidget(
              message: e.toString(),
              onRetry: () =>
                  ref.read(helpdeskTicketNotifierProvider.notifier).refresh(),
            ),
            data: (tickets) {
              final filtered = status == null
                  ? tickets
                  : tickets.where((t) => t.status == status).toList();

              if (filtered.isEmpty) {
                return Center(
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
                          Icons.assignment_outlined,
                          size: 44,
                          color: const Color(0xFF4F7EFF).withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada tiket',
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
                        status == null
                            ? 'Belum ada tiket yang ditugaskan ke Anda'
                            : 'Tidak ada tiket dengan status ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF4F7EFF),
                onRefresh: () async =>
                    ref.read(helpdeskTicketNotifierProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ticket = filtered[index];
                    return _HelpdeskTicketCard(
                      ticket: ticket,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailPage(ticketId: ticket.id),
                        ),
                      ).then((_) {
                        ref
                            .read(helpdeskTicketNotifierProvider.notifier)
                            .refresh();
                        ref.invalidate(helpdeskStatsProvider);
                      }),
                      onClose: ticket.status == 'resolved'
                          ? () => _closeTicket(ticket)
                          : null,
                    );
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// FR-006 point 6: Menutup tiket yang ditugaskan.
  Future<void> _closeTicket(TicketModel ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Tutup Tiket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tutup tiket "${ticket.title}"?\nStatus akan berubah menjadi CLOSED.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final token = ref.read(tokenProvider);
      await ref
          .read(ticketRepositoryProvider)
          .updateTicketStatus(
            ticketId: ticket.id,
            status: 'closed',
            token: token,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket berhasil ditutup'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
      ref.read(helpdeskTicketNotifierProvider.notifier).refresh();
      ref.invalidate(helpdeskStatsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card widget tiket untuk helpdesk
// ─────────────────────────────────────────────────────────────────────────────
class _HelpdeskTicketCard extends StatelessWidget {
  final TicketModel ticket;
  final bool isDark;
  final VoidCallback onTap;
  /// Bila non-null, tombol "Tutup" muncul (FR-006 point 6)
  final VoidCallback? onClose;

  const _HelpdeskTicketCard({
    required this.ticket,
    required this.isDark,
    required this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(ticket.status);
    final priorityColor = AppTheme.getPriorityColor(ticket.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: const Color(0xFF2E3147), width: 0.5)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: kategori + status badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F7EFF)
                          .withOpacity(isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      ticket.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4F7EFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),

              // Judul tiket
              Text(
                ticket.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF1A1D3B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),

              // Deskripsi
              Text(
                ticket.description,
                style: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Row bawah: priority + tanggal + tombol tutup
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    ticket.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // FR-006 point 6: Tombol tutup muncul jika status resolved
                  if (onClose != null)
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B)
                              .withOpacity(isDark ? 0.18 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded,
                                size: 11,
                                color: const Color(0xFFFF6B6B)),
                            const SizedBox(width: 3),
                            const Text(
                              'Tutup',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
