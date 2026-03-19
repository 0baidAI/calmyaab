import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'tabs/partner_internships_tab.dart';
import 'tabs/partner_applications_tab.dart';
import 'tabs/partner_notifications_tab.dart';
import 'tabs/partner_profile_tab.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  int _selectedIndex        = 0;
  bool _checking            = true;
  bool _isPartner           = false;
  Map<String, dynamic>? _partnerData;

  final _navItems = const [
    _NavItem(icon: Icons.work_outline_rounded,        label: 'My Internships'),
    _NavItem(icon: Icons.description_outlined,        label: 'Applications'),
    _NavItem(icon: Icons.notifications_outlined,      label: 'Notifications'),
    _NavItem(icon: Icons.settings_outlined,           label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _checkPartner();
  }

  Future<void> _checkPartner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/partner-login');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (!doc.exists || doc.data()?['status'] != 'active') {
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go('/partner-login');
      return;
    }

    setState(() {
      _partnerData = doc.data();
      _isPartner   = true;
      _checking    = false;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/partner-login');
  }

  Widget get _currentTab {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    switch (_selectedIndex) {
      case 0: return PartnerInternshipsTab(
          partnerUid: uid,
          companyName: _partnerData?['company_name'] ?? '');
      case 1: return PartnerApplicationsTab(partnerUid: uid);
      case 2: return const PartnerNotificationsTab();
      case 3: return const PartnerProfileTab();
      default: return PartnerInternshipsTab(
          partnerUid: uid,
          companyName: _partnerData?['company_name'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
            child: CircularProgressIndicator(
                color: AppColors.yellow)),
      );
    }

    if (!_isPartner) return const SizedBox();

    final isDesktop = MediaQuery.of(context).size.width > 768;
    final uid         = FirebaseAuth.instance.currentUser?.uid ?? '';
    final companyName = _partnerData?['company_name'] ?? 'Partner';
    final industry    = _partnerData?['industry'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Row(children: [
        if (isDesktop)
          _Sidebar(
            navItems:      _navItems,
            selectedIndex: _selectedIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
            onSignOut:     _signOut,
            companyName:   companyName,
            industry:      industry,
            partnerUid:    uid,
          ),
        Expanded(
          child: Column(children: [
            _TopBar(
              title:       _navItems[_selectedIndex].label,
              companyName: companyName,
              onSignOut:   _signOut,
              onMenuTap:   isDesktop
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
                    ? AppColors.yellow
                    : AppColors.gray),
            title: Text(e.value.label,
                style: AppTextStyles.body(14,
                    color: _selectedIndex == e.key
                        ? AppColors.yellow
                        : AppColors.white)),
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
  final String companyName, industry, partnerUid;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
    required this.companyName,
    required this.industry,
    required this.partnerUid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: AppColors.black2,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: AppColors.whiteDim2))),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text('CALMYAAB',
                style: GoogleFonts.bebasNeue(
                    fontSize: 22,
                    color: AppColors.yellow,
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellowDim,
                borderRadius: BorderRadius.circular(4),
                border:
                    Border.all(color: AppColors.yellowBorder),
              ),
              child: Text('PARTNER',
                  style: AppTextStyles.body(9,
                      color: AppColors.yellow,
                      weight: FontWeight.w700,
                      letterSpacing: 1.5,
                      height: 1)),
            ),
            const SizedBox(height: 12),
            Text(companyName,
                style: AppTextStyles.body(14,
                    weight: FontWeight.w700, height: 1.2)),
            if (industry.isNotEmpty)
              Text(industry,
                  style: AppTextStyles.body(12,
                      color: AppColors.gray, height: 1.3)),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: navItems.asMap().entries.map((e) {
                if (e.value.label == 'Notifications') {
                  return _NotifNavItem(
                    item: e.value,
                    selected: selectedIndex == e.key,
                    onTap: () => onSelect(e.key),
                    partnerUid: partnerUid,
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
            selected:      false,
            onTap:         onSignOut,
            isDestructive: true,
          ),
        ),
      ]),
    );
  }
}

// ── Notifications Nav Item with red dot ───────────────────────────────────────
class _NotifNavItem extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final String partnerUid;

  const _NotifNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.partnerUid,
  });

  @override
  State<_NotifNavItem> createState() => _NotifNavItemState();
}

class _NotifNavItemState extends State<_NotifNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color =
        widget.selected ? AppColors.yellow : AppColors.gray;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partner_notifications')
          .where('partner_uid', isEqualTo: widget.partnerUid)
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unread = snapshot.data?.docs.length ?? 0;

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
        : widget.selected
            ? AppColors.yellow
            : AppColors.gray;

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
            Text(widget.item.label,
                style: AppTextStyles.body(14,
                    color: color,
                    weight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    height: 1)),
          ]),
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String title, companyName;
  final VoidCallback onSignOut;
  final VoidCallback? onMenuTap;

  const _TopBar({
    required this.title,
    required this.companyName,
    required this.onSignOut,
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
            color: AppColors.yellowDim,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Row(children: [
            const Icon(Icons.business_outlined,
                size: 14, color: AppColors.yellow),
            const SizedBox(width: 6),
            Text(companyName,
                style: AppTextStyles.body(12,
                    color: AppColors.yellow,
                    weight: FontWeight.w600,
                    height: 1)),
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