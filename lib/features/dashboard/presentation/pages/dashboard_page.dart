import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/core/widgets/common_widgets.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/auth/presentation/pages/login_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/ticket_list_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/ticket/presentation/pages/ticket_history_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/profile/presentation/pages/profile_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/notification/presentation/pages/notification_page.dart';
import 'package:ticketing_434241018_zelvia_b2_uts/features/notification/presentation/providers/notification_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(ticketStatsProvider); // auto update
    final isDark = ref.watch(themeModeProvider);
    final unreadCount = ref.watch(unreadNotifCountProvider); // dynamic badge
    final role = authState.user?.role ?? 'user';
    final isAdminOrHelpdesk = role == 'admin' || role == 'helpdesk';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${authState.user?.name ?? 'User'} 👋',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'E-Ticketing Helpdesk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Badge notifikasi DYNAMIC
                              IconButton(
                                icon: Badge(
                                  isLabelVisible: unreadCount > 0,
                                  label: Text(unreadCount.toString()),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationPage(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isDark
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () => ref
                                    .read(themeModeProvider.notifier)
                                    .state = !isDark,
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout,
                                    color: Colors.white),
                                onPressed: () async {
                                  await ref
                                      .read(authProvider.notifier)
                                      .logout();
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role == 'admin'
                              ? '👑 ADMIN — Pengelola Sistem'
                              : role == 'helpdesk'
                                  ? '🛠 HELPDESK — Petugas Support'
                                  : '👤 USER — Pelapor Tiket',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdminOrHelpdesk
                        ? 'Statistik Semua Tiket'
                        : 'Statistik Tiket Saya',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Statistik AUTO UPDATE karena pakai ref.watch
                  statsAsync.when(
                    loading: () => const LoadingWidget(),
                    error: (e, _) =>
                        CustomErrorWidget(message: e.toString()),
                    data: (stats) => GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          label: 'Total',
                          value: stats.total.toString(),
                          icon: Icons.confirmation_number_outlined,
                          color: const Color(0xFF2563EB),
                        ),
                        _StatCard(
                          label: 'Open',
                          value: stats.open.toString(),
                          icon: Icons.folder_open_outlined,
                          color: const Color(0xFF3B82F6),
                        ),
                        _StatCard(
                          label: 'In Progress',
                          value: stats.inProgress.toString(),
                          icon: Icons.pending_outlined,
                          color: const Color(0xFFF59E0B),
                        ),
                        _StatCard(
                          label: 'Resolved',
                          value: stats.resolved.toString(),
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Menu',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // ===== MENU USER =====
                  if (!isAdminOrHelpdesk)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _MenuCard(
                          label: 'Buat Tiket',
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFF10B981),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateTicketPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Tiket Saya',
                          icon: Icons.list_alt_outlined,
                          color: const Color(0xFF2563EB),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketListPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Riwayat',
                          icon: Icons.history_outlined,
                          color: const Color(0xFFF59E0B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketHistoryPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Profile',
                          icon: Icons.person_outline,
                          color: const Color(0xFF7C3AED),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // ===== MENU ADMIN / HELPDESK =====
                  if (isAdminOrHelpdesk)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _MenuCard(
                          label: 'Semua Tiket',
                          icon: Icons.list_alt_outlined,
                          color: const Color(0xFF2563EB),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketListPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Tiket Open',
                          icon: Icons.folder_open_outlined,
                          color: const Color(0xFF3B82F6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketListPage(
                                  filterStatus: 'open'),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Riwayat',
                          icon: Icons.history_outlined,
                          color: const Color(0xFFF59E0B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketHistoryPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Profile',
                          icon: Icons.person_outline,
                          color: const Color(0xFF7C3AED),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // FAB hanya untuk USER — admin/helpdesk TIDAK bisa buat tiket
      floatingActionButton: !isAdminOrHelpdesk
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTicketPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Buat Tiket'),
            )
          : null,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}