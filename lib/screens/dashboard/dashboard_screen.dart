import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'tabs/overview_tab.dart';
import 'tabs/internships_tab.dart';
import 'tabs/cv_status_tab.dart';
import 'tabs/study_abroad_tab.dart';
import 'tabs/profile_tab.dart';
import 'widgets/notifications_panel.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final _tabs = const [
    _TabItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,           label: 'Overview'),
    _TabItem(icon: Icons.work_outline_rounded,  activeIcon: Icons.work_rounded,            label: 'Internships'),
    _TabItem(icon: Icons.description_outlined,  activeIcon: Icons.description_rounded,     label: 'My CV'),
    _TabItem(icon: Icons.flight_outlined,       activeIcon: Icons.flight_rounded,          label: 'Study Abroad'),
    _TabItem(icon: Icons.person_outline_rounded,activeIcon: Icons.person_rounded,          label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await ref.read(studentProvider.notifier).signOut();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(studentProvider);
    final student = studentAsync.valueOrNull;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          // ── Top Bar ───────────────────────────────────────────────────────
          _DashboardTopBar(
            studentName: student?.name ?? 'Student',
            onSignOut: _signOut,
          ),

          // ── Tab Bar ───────────────────────────────────────────────────────
          Container(
            color: AppColors.black2,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: !isDesktop,
                  indicatorColor: AppColors.yellow,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.yellow,
                  unselectedLabelColor: AppColors.gray,
                  labelStyle: AppTextStyles.body(13, weight: FontWeight.w600, height: 1),
                  unselectedLabelStyle: AppTextStyles.body(13, height: 1),
                  tabs: _tabs.map((t) => Tab(
                    height: 52,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentIndex == _tabs.indexOf(t) ? t.activeIcon : t.icon,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(t.label),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.whiteDim2),

          // ── Tab Content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(student: student, onTabChange: (i) => _tabController.animateTo(i)),
                const InternshipsTab(),
                const CvStatusTab(),
                const StudyAbroadTab(role: 'student'),
                ProfileTab(student: student, onSignOut: _signOut, onProfileUpdated: () => ref.read(studentProvider.notifier).refresh()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final IconData icon, activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _DashboardTopBar extends StatelessWidget {
  final String studentName;
  final VoidCallback onSignOut;

  const _DashboardTopBar({required this.studentName, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.black2,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // Logo
              Text('CALMYAAB',
                style: GoogleFonts.bebasNeue(
                  fontSize: 24, color: AppColors.yellow, letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Text('STUDENT',
                  style: AppTextStyles.body(9, color: AppColors.yellow,
                    weight: FontWeight.w700, letterSpacing: 1.5, height: 1),
                ),
              ),
              const Spacer(),

              // Welcome message
              Text('Welcome back, ${studentName.split(' ').first}! 👋',
                style: AppTextStyles.body(14, color: AppColors.gray, height: 1),
              ),
              const SizedBox(width: 8),

              // Notification bell
              const NotificationBell(),
              const SizedBox(width: 8),

              // Sign out
              _SignOutBtn(onTap: onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _SignOutBtn({required this.onTap});

  @override
  State<_SignOutBtn> createState() => _SignOutBtnState();
}

class _SignOutBtnState extends State<_SignOutBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? Colors.redAccent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered ? Colors.redAccent.withOpacity(0.4) : AppColors.whiteDim2,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 14,
                color: _hovered ? Colors.redAccent : AppColors.gray),
              const SizedBox(width: 6),
              Text('Sign Out',
                style: AppTextStyles.body(13,
                  color: _hovered ? Colors.redAccent : AppColors.gray, height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}