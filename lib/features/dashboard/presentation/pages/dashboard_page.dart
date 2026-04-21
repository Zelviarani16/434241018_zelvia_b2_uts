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

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotifCountProvider);
    final role = ref.watch(authProvider).user?.role ?? 'user';
    final isAdminOrHelpdesk = role == 'admin' || role == 'helpdesk';

    final pages = [
      const _DashboardContent(),
      const TicketListPage(),
      const NotificationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.confirmation_number_outlined),
              activeIcon: const Icon(Icons.confirmation_number_rounded),
              label: isAdminOrHelpdesk ? 'Tiket' : 'Tiket Saya',
            ),
            BottomNavigationBarItem(
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount.toString()),
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
              activeIcon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount.toString()),
                      child: const Icon(Icons.notifications_rounded),
                    )
                  : const Icon(Icons.notifications_rounded),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Dashboard content (tanpa Scaffold agar bisa dibungkus MainShell)
class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statsAsync = ref.watch(ticketStatsProvider);
    final isDark = ref.watch(themeModeProvider);
    final role = authState.user?.role ?? 'user';
    final isAdminOrHelpdesk = role == 'admin' || role == 'helpdesk';
    final name = authState.user?.name ?? 'User';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F7EFF), Color(0xFF7C5CFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 24),
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
                                _getGreeting(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _headerBtn(
                                icon: isDark
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                                onTap: () =>
                                    ref.read(themeModeProvider.notifier).state =
                                        !isDark,
                              ),
                              const SizedBox(width: 6),
                              _headerBtn(
                                icon: Icons.logout_rounded,
                                onTap: () async {
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
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role == 'admin'
                              ? 'Admin - Pengelola Sistem'
                              : role == 'helpdesk'
                              ? 'Helpdesk - Petugas Support'
                              : 'User - Pelapor Tiket',
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
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(
                    context,
                    isAdminOrHelpdesk
                        ? 'Statistik Semua Tiket'
                        : 'Statistik Tiket Saya',
                  ),
                  const SizedBox(height: 14),
                  statsAsync.when(
                    loading: () => const LoadingWidget(),
                    error: (e, _) => CustomErrorWidget(message: e.toString()),
                    data: (stats) => Column(
                      children: [
                        // Total card
                        _TotalCard(total: stats.total, isDark: isDarkMode),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: 'Open',
                                value: stats.open,
                                color: const Color(0xFF4F7EFF),
                                icon: Icons.folder_open_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                label: 'In Progress',
                                value: stats.inProgress,
                                color: const Color(0xFFFF9F43),
                                icon: Icons.pending_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStat(
                                label: 'Resolved',
                                value: stats.resolved,
                                color: const Color(0xFF10B981),
                                icon: Icons.check_circle_rounded,
                                isDark: isDarkMode,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  _sectionTitle(context, 'Menu'),
                  const SizedBox(height: 14),

                  // Menu USER
                  if (!isAdminOrHelpdesk)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.55,
                      children: [
                        _MenuCard(
                          label: 'Buat Tiket',
                          subtitle: 'Laporkan masalah',
                          icon: Icons.add_circle_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F7EFF), Color(0xFF7C5CFC)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateTicketPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Tiket Saya',
                          subtitle: 'Lihat semua tiket',
                          icon: Icons.list_alt_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3ECFF6), Color(0xFF4F7EFF)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketListPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Riwayat',
                          subtitle: 'Tiket selesai',
                          icon: Icons.history_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketHistoryPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Profile',
                          subtitle: 'Data akun saya',
                          icon: Icons.person_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C5CFC), Color(0xFFAB7BFF)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Menu ADMIN / HELPDESK
                  if (isAdminOrHelpdesk)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.55,
                      children: [
                        _MenuCard(
                          label: 'Semua Tiket',
                          subtitle: 'Kelola tiket masuk',
                          icon: Icons.list_alt_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F7EFF), Color(0xFF7C5CFC)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketListPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Tiket Open',
                          subtitle: 'Perlu ditangani',
                          icon: Icons.folder_open_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3ECFF6), Color(0xFF4F7EFF)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const TicketListPage(filterStatus: 'open'),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Riwayat',
                          subtitle: 'Tiket selesai',
                          icon: Icons.history_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9F43), Color(0xFFFF6B6B)],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketHistoryPage(),
                            ),
                          ),
                        ),
                        _MenuCard(
                          label: 'Profile',
                          subtitle: 'Data akun saya',
                          icon: Icons.person_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C5CFC), Color(0xFFAB7BFF)],
                          ),
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
      // Tidak ada FAB — sudah ada di menu card
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Widget _headerBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1A1D3B),
      ),
    );
  }
}

// ---- Stat widgets ----
class _TotalCard extends StatelessWidget {
  final int total;
  final bool isDark;
  const _TotalCard({required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: Color(0xFF4F7EFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1D3B),
                ),
              ),
              Text(
                'Total Tiket',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.1 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _MenuCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
