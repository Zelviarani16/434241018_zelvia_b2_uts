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

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdminOrHelpdesk ? 'Semua Tiket' : 'Tiket Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(ticketNotifierProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada tiket',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.read(ticketNotifierProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ticket = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailPage(ticketId: ticket.id),
                          ),
                        ).then((_) {
                          // Refresh setelah kembali dari detail
                          ref
                              .read(ticketNotifierProvider.notifier)
                              .refresh();
                        }),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ticket.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  StatusBadge(status: ticket.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ticket.description,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
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
                                  const Spacer(),
                                  Text(
                                    _formatDate(ticket.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
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
                ),
              );
            },
          );
        }).toList(),
      ),
      // FAB hanya untuk USER
      floatingActionButton: !isAdminOrHelpdesk
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTicketPage()),
              ).then((_) =>
                  ref.read(ticketNotifierProvider.notifier).refresh()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}