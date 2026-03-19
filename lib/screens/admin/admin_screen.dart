import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'tabs/students_tab.dart';
import 'tabs/cv_orders_tab.dart';
import 'tabs/internships_admin_tab.dart';
import 'tabs/study_abroad_tab.dart';
import 'tabs/revenue_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/team_tab.dart';
import 'tabs/inbox_tab.dart';
import 'tabs/partners_tab.dart';
import 'tabs/applications_tab.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  int _selectedIndex = 0;
  bool _isAdmin      = false;
  bool _checking     = true;
  String _role       = 'admin';

  final _baseNavItems = const [
    _NavItem(icon: Icons.inbox_outlined,          label: 'Inbox'),
    _NavItem(icon: Icons.people_outline_rounded,  label: 'Students'),
    _NavItem(icon: Icons.description_outlined,    label: 'CV Orders'),
    _NavItem(icon: Icons.work_outline_rounded,    label: 'Internships'),
    _NavItem(icon: Icons.flight_outlined,         label: 'Study Abroad'),
    _NavItem(icon: Icons.notifications_outlined,  label: 'Notifications'),
    _NavItem(icon: Icons.business_outlined,       label: 'Partners'),
    _NavItem(icon: Icons.folder_shared_outlined,  label: 'Applications'),
  ];

  final _superAdminNavItems = const [
    _NavItem(icon: Icons.payments_outlined,        label: 'Revenue'),
    _NavItem(icon: Icons.manage_accounts_outlined, label: 'Team'),
  ];

  List<_NavItem> get _navItems => _role == 'super_admin'
      ? [..._baseNavItems, ..._superAdminNavItems]
      : _baseNavItems;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      if (mounted) context.go('/admin-login');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final role = doc.data()?['role'] ?? 'student';

    if (role != 'admin' && role != 'super_admin') {
      context.go('/dashboard');
      return;
    }

    setState(() {
      _role     = role;
      _isAdmin  = true;
      _checking = false;
    });
  }

  Future<void> _signOut() async {
    await ref.read(studentProvider.notifier).signOut();
    if (mounted) context.go('/admin-login');
  }

  Widget get _currentTab {
    final label = _navItems[_selectedIndex].label;
    switch (label) {
      case 'Inbox':         return InboxTab(role: _role);
      case 'Students':      return const StudentsTab();
      case 'CV Orders':     return const CvOrdersTab();
      case 'Internships':   return const InternshipsAdminTab();
      case 'Study Abroad': return StudyAbroadTab(role: _role);
      case 'Notifications': return const NotificationsTab();
      case 'Revenue':       return const RevenueTab();
      case 'Team':          return TeamTab(role: _role);
      case 'Partners':      return const PartnersTab();
      case 'Applications':  return const ApplicationsTab();
      default:              return const StudentsTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.yellow)),
      );
    }

    if (!_isAdmin) return const SizedBox();

    final isDesktop = MediaQuery.of(context).size.width > 768;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Row(children: [
        if (isDesktop)
          _Sidebar(
            navItems:      _navItems,
            selectedIndex: _selectedIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
            onSignOut:     _signOut,
            role:          _role,
            currentUid:    uid,
          ),
        Expanded(
          child: Column(children: [
            _AdminTopBar(
              title:     _navItems[_selectedIndex].label,
              onSignOut: _signOut,
              role:      _role,
              onMenuTap: isDesktop
                  ? null
                  : () => _showMobileDrawer(context),
            ),
            const Divider(height: 1, color: AppColors.whiteDim2),
            Expanded(child: _currentTab),
          ]),
        ),
      ]),
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black2,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppColors.gray2,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          ..._navItems.asMap().entries.map((e) => ListTile(
            leading: Icon(e.value.icon,
                color: _selectedIndex == e.key
                    ? AppColors.yellow : AppColors.gray),
            title: Text(e.value.label,
                style: AppTextStyles.body(14,
                    color: _selectedIndex == e.key
                        ? AppColors.yellow : AppColors.white)),
            onTap: () {
              setState(() => _selectedIndex = e.key);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final Function(int) onSelect;
  final VoidCallback onSignOut;
  final String role;
  final String currentUid;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
    required this.role,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: AppColors.black2,
      child: Column(children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.whiteDim2))),
          child: Row(children: [
            Text('CALMYAAB',
                style: GoogleFonts.bebasNeue(
                    fontSize: 22,
                    color: AppColors.yellow,
                    letterSpacing: 2)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Text(
                role == 'super_admin' ? 'OPS HEAD' : 'ADMIN',
                style: AppTextStyles.body(9,
                    color: Colors.redAccent,
                    weight: FontWeight.w700,
                    letterSpacing: 1.5, height: 1),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: navItems.asMap().entries.map((e) {
                if (e.value.label == 'Inbox') {
                  return _InboxNavItem(
                    item: e.value,
                    selected: selectedIndex == e.key,
                    onTap: () => onSelect(e.key),
                    currentUid: currentUid,
                  );
                }
                return _SidebarItem(
                  item: e.value,
                  selected: selectedIndex == e.key,
                  onTap: () => onSelect(e.key),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _SidebarItem(
            item: const _NavItem(
                icon: Icons.logout_rounded, label: 'Sign Out'),
            selected: false,
            onTap: onSignOut,
            isDestructive: true,
          ),
        ),
      ]),
    );
  }
}

// ── Inbox Nav Item with live red dot ──────────────────────────────────────────
class _InboxNavItem extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final String currentUid;

  const _InboxNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.currentUid,
  });

  @override
  State<_InboxNavItem> createState() => _InboxNavItemState();
}

class _InboxNavItemState extends State<_InboxNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.yellow : AppColors.gray;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin_chats')
          .where('participants', arrayContains: widget.currentUid)
          .snapshots(),
      builder: (context, chatSnapshot) {
        final chatDocs = chatSnapshot.data?.docs ?? [];

        return FutureBuilder<int>(
          future: _countUnread(chatDocs),
          builder: (context, countSnapshot) {
            final unread = countSnapshot.data ?? 0;

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hovered = true),
              onExit:  (_) => setState(() => _hovered = false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? AppColors.yellowDim
                        : _hovered
                            ? AppColors.whiteDim2
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.selected
                          ? AppColors.yellowBorder
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(children: [
                    Icon(widget.item.icon, size: 18, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.item.label,
                          style: AppTextStyles.body(14,
                              color: color,
                              weight: widget.selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              height: 1)),
                    ),
                    if (unread > 0)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<int> _countUnread(
      List<QueryDocumentSnapshot> chatDocs) async {
    int total = 0;
    for (final chatDoc in chatDocs) {
      final msgs = await FirebaseFirestore.instance
          .collection('admin_chats')
          .doc(chatDoc.id)
          .collection('messages')
          .get();

      for (final msg in msgs.docs) {
        final data = msg.data();
        final fromUid = data['from_uid'] ?? '';
        if (fromUid == widget.currentUid) continue;
        final readBy = List<String>.from(data['read_by'] ?? []);
        if (!readBy.contains(widget.currentUid)) total++;
      }
    }
    return total;
  }
}

// ── Regular Sidebar Item ──────────────────────────────────────────────────────
class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool selected, isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? Colors.redAccent
        : widget.selected ? AppColors.yellow : AppColors.gray;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.yellowDim
                : _hovered ? AppColors.whiteDim2 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.selected
                  ? AppColors.yellowBorder : Colors.transparent,
            ),
          ),
          child: Row(children: [
            Icon(widget.item.icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(widget.item.label,
                style: AppTextStyles.body(14,
                    color: color,
                    weight: widget.selected
                        ? FontWeight.w600 : FontWeight.w400,
                    height: 1)),
          ]),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────
class _AdminTopBar extends StatelessWidget {
  final String title, role;
  final VoidCallback onSignOut;
  final VoidCallback? onMenuTap;

  const _AdminTopBar({
    required this.title,
    required this.onSignOut,
    required this.role,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.black2,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        if (onMenuTap != null) ...[
          IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: AppColors.gray),
              onPressed: onMenuTap),
          const SizedBox(width: 8),
        ],
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 24,
                color: AppColors.white,
                letterSpacing: 2)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(
              role == 'super_admin'
                  ? Icons.shield_rounded
                  : Icons.admin_panel_settings_outlined,
              size: 14,
              color: Colors.redAccent,
            ),
            const SizedBox(width: 6),
            Text(
              role == 'super_admin'
                  ? 'Operations Head' : 'Admin Mode',
              style: AppTextStyles.body(12,
                  color: Colors.redAccent,
                  weight: FontWeight.w600, height: 1),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
