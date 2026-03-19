import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'tabs/agency_bookings_tab.dart';
import 'tabs/agency_consultants_tab.dart';
import 'tabs/agency_profile_tab.dart';

class AgencyScreen extends StatefulWidget {
  const AgencyScreen({super.key});

  @override
  State<AgencyScreen> createState() => _AgencyScreenState();
}

class _AgencyScreenState extends State<AgencyScreen> {
  int _selectedIndex        = 0;
  bool _checking            = true;
  bool _isAgency            = false;
  Map<String, dynamic>? _agencyData;
  String _agencyId          = '';

  final _navItems = const [
    _NavItem(icon: Icons.calendar_today_outlined,  label: 'Bookings'),
    _NavItem(icon: Icons.people_outline_rounded,   label: 'Consultants'),
    _NavItem(icon: Icons.settings_outlined,        label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _checkAgency();
  }

  Future<void> _checkAgency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) context.go('/agency-login');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('agencies')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      if (mounted) context.go('/agency-login');
      return;
    }

    setState(() {
      _agencyData  = doc.data();
      _agencyId    = user.uid;
      _isAgency    = true;
      _checking    = false;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/agency-login');
  }

  Widget get _currentTab {
    switch (_selectedIndex) {
      case 0: return AgencyBookingsTab(agencyId: _agencyId,
          agencyName: _agencyData?['name'] ?? '');
      case 1: return AgencyConsultantsTab(agencyId: _agencyId);
      case 2: return AgencyProfileTab(agencyId: _agencyId);
      default: return AgencyBookingsTab(agencyId: _agencyId,
          agencyName: _agencyData?['name'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: CircularProgressIndicator(
            color: AppColors.yellow)),
      );
    }
    if (!_isAgency) return const SizedBox();

    final isDesktop = MediaQuery.of(context).size.width > 768;
    final agencyName = _agencyData?['name'] ?? 'Agency';

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Row(children: [
        if (isDesktop)
          _Sidebar(
            navItems:      _navItems,
            selectedIndex: _selectedIndex,
            onSelect: (i) => setState(() => _selectedIndex = i),
            onSignOut:     _signOut,
            agencyName:    agencyName,
            agencyId:      _agencyId,
          ),
        Expanded(child: Column(children: [
          _TopBar(
            title:      _navItems[_selectedIndex].label,
            agencyName: agencyName,
            onSignOut:  _signOut,
            onMenuTap:  isDesktop
                ? null
                : () => _showMobileDrawer(context),
          ),
          const Divider(height: 1, color: AppColors.whiteDim2),
          Expanded(child: _currentTab),
        ])),
      ]),
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(16))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.gray2,
                  borderRadius: BorderRadius.circular(2))),
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
  final String agencyName, agencyId;

  const _Sidebar({
    required this.navItems, required this.selectedIndex,
    required this.onSelect, required this.onSignOut,
    required this.agencyName, required this.agencyId,
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
              border: Border(bottom: BorderSide(
                  color: AppColors.whiteDim2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CALMYAAB',
                  style: GoogleFonts.bebasNeue(fontSize: 22,
                      color: AppColors.yellow, letterSpacing: 2)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Text('AGENCY',
                    style: AppTextStyles.body(9,
                        color: AppColors.yellow,
                        weight: FontWeight.w700,
                        letterSpacing: 1.5, height: 1)),
              ),
              const SizedBox(height: 12),
              Text(agencyName,
                  style: AppTextStyles.body(14,
                      weight: FontWeight.w700, height: 1.2)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: navItems.asMap().entries.map((e) {
                if (e.value.label == 'Bookings') {
                  return _BookingsNavItem(
                    item: e.value,
                    selected: selectedIndex == e.key,
                    onTap: () => onSelect(e.key),
                    agencyId: agencyId,
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
            item: const _NavItem(icon: Icons.logout_rounded,
                label: 'Sign Out'),
            selected: false, onTap: onSignOut,
            isDestructive: true,
          ),
        ),
      ]),
    );
  }
}

// ── Bookings Nav with red dot ─────────────────────────────────────────────────
class _BookingsNavItem extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final String agencyId;

  const _BookingsNavItem({required this.item, required this.selected,
      required this.onTap, required this.agencyId});

  @override
  State<_BookingsNavItem> createState() => _BookingsNavItemState();
}

class _BookingsNavItemState extends State<_BookingsNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.yellow : AppColors.gray;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('study_abroad_bookings')
          .where('agency_id', isEqualTo: widget.agencyId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final pending = snapshot.data?.docs.length ?? 0;

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
                    : _hovered ? AppColors.whiteDim2
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.selected
                    ? AppColors.yellowBorder : Colors.transparent),
              ),
              child: Row(children: [
                Icon(widget.item.icon, size: 18, color: color),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.item.label,
                    style: AppTextStyles.body(14, color: color,
                        weight: widget.selected
                            ? FontWeight.w600 : FontWeight.w400,
                        height: 1))),
                if (pending > 0)
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle),
                  ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool selected, isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({required this.item, required this.selected,
      required this.onTap, this.isDestructive = false});

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? Colors.redAccent
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
            color: widget.selected ? AppColors.yellowDim
                : _hovered ? AppColors.whiteDim2 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.selected
                ? AppColors.yellowBorder : Colors.transparent),
          ),
          child: Row(children: [
            Icon(widget.item.icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(widget.item.label, style: AppTextStyles.body(14,
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

class _TopBar extends StatelessWidget {
  final String title, agencyName;
  final VoidCallback onSignOut;
  final VoidCallback? onMenuTap;

  const _TopBar({required this.title, required this.agencyName,
      required this.onSignOut, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, color: AppColors.black2,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        if (onMenuTap != null) ...[
          IconButton(icon: const Icon(Icons.menu_rounded,
              color: AppColors.gray), onPressed: onMenuTap),
          const SizedBox(width: 8),
        ],
        Text(title.toUpperCase(),
            style: const TextStyle(fontFamily: 'BebasNeue',
                fontSize: 24, color: AppColors.white,
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
            Text(agencyName, style: AppTextStyles.body(12,
                color: AppColors.yellow,
                weight: FontWeight.w600, height: 1)),
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