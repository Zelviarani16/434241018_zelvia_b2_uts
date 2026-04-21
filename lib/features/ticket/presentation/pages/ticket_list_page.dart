import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/widgets/common_widgets.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/ticket_detail_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/theme/app_theme.dart';
 
class TicketListPage extends ConsumerStatefulWidget {
  final String? filterStatus;
  const TicketListPage({super.key, this.filterStatus});
 
  @override
  ConsumerState<TicketListPage> createState() => _TicketListPageState();
}
 
class _TicketListPageState extends ConsumerState<TicketListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String?> _tabs = [null, 'open', 'in_progress', 'resolved'];
  final List<String> _tabLabels = ['Semua', 'Open', 'Proses', 'Selesai'];
 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }
 
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketNotifierProvider);
    final role = ref.watch(authProvider).user?.role ?? 'user';
    final isAdminOrHelpdesk = role == 'admin' || role == 'helpdesk';
    final isDark = Theme.of(context).brightness == Brightness.dark;
 
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdminOrHelpdesk ? 'Semua Tiket' : 'Tiket Saya',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () =>
                ref.read(ticketNotifierProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13),
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
                  ref.read(ticketNotifierProvider.notifier).refresh(),
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
                          Icons.inbox_rounded,
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
                        'Belum ada tiket di kategori ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }
 
              return RefreshIndicator(
                color: const Color(0xFF4F7EFF),
                onRefresh: () async =>
                    ref.read(ticketNotifierProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ticket = filtered[index];
                    return _TicketCard(
                      ticket: ticket,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TicketDetailPage(ticketId: ticket.id),
                        ),
                      ).then((_) {
                        ref.read(ticketNotifierProvider.notifier).refresh();
                      }),
                    );
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: !isAdminOrHelpdesk
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTicketPage()),
              ).then((_) =>
                  ref.read(ticketNotifierProvider.notifier).refresh()),
              backgroundColor: const Color(0xFF4F7EFF),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
 
class _TicketCard extends StatelessWidget {
  final dynamic ticket;
  final bool isDark;
  final VoidCallback onTap;
  const _TicketCard({required this.ticket, required this.isDark, required this.onTap});
 
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F7EFF).withOpacity(
                          isDark ? 0.15 : 0.08),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
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
              Text(
                ticket.description,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : Colors.grey.shade500,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}