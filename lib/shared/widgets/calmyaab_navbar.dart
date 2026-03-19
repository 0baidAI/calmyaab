import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CalmyaabNavbar extends StatefulWidget {
  final ScrollController scrollController;
  final GlobalKey heroKey;
  final GlobalKey servicesKey;
  final GlobalKey howKey;
  final GlobalKey abroadKey;
  final GlobalKey pricingKey;

  const CalmyaabNavbar({
    super.key,
    required this.scrollController,
    required this.heroKey,
    required this.servicesKey,
    required this.howKey,
    required this.abroadKey,
    required this.pricingKey,
  });

  @override
  State<CalmyaabNavbar> createState() => _CalmyaabNavbarState();
}

class _CalmyaabNavbarState extends State<CalmyaabNavbar> {
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = widget.scrollController.offset > 40;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 70,
      decoration: BoxDecoration(
        color: _scrolled ? AppColors.black.withOpacity(0.96) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: _scrolled ? AppColors.yellowBorder : Colors.transparent,
            width: 1,
          ),
        ),
        boxShadow: _scrolled
            ? [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12)]
            : [],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 20),
            child: Row(
              children: [
                // Logo
                GestureDetector(
                  onTap: () => _scrollTo(widget.heroKey),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text('CALMYAAB',
                      style: GoogleFonts.bebasNeue(
                          fontSize: 28, color: AppColors.yellow, letterSpacing: 2),
                    ),
                  ),
                ),
                const Spacer(),
                if (isDesktop) ...[
                  _NavLink(label: 'Services',     onTap: () => _scrollTo(widget.servicesKey)),
                  const SizedBox(width: 32),
                  _NavLink(label: 'How It Works', onTap: () => _scrollTo(widget.howKey)),
                  const SizedBox(width: 32),
                  _NavLink(label: 'Study Abroad', onTap: () => _scrollTo(widget.abroadKey)),
                  const SizedBox(width: 32),
                  _NavLink(label: 'Pricing',      onTap: () => _scrollTo(widget.pricingKey)),
                  const SizedBox(width: 32),
                  // Partner portal dropdown
                  _PartnerDropdown(),
                  const SizedBox(width: 16),
                  _LoginBtn(onTap: () => context.go('/login')),
                  const SizedBox(width: 12),
                  _RegisterBtn(onTap: () => context.go('/register')),
                ] else ...[
                  _LoginBtn(onTap: () => context.go('/login')),
                  const SizedBox(width: 10),
                  _RegisterBtn(onTap: () => context.go('/register')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});
  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: AppTextStyles.body(14,
            color: _hovered ? AppColors.yellow : AppColors.gray,
            weight: FontWeight.w500, letterSpacing: 0.3, height: 1),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _LoginBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _LoginBtn({required this.onTap});
  @override
  State<_LoginBtn> createState() => _LoginBtnState();
}

class _LoginBtnState extends State<_LoginBtn> {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered ? AppColors.yellow : AppColors.gray.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text('Login',
            style: AppTextStyles.body(14,
              color: _hovered ? AppColors.yellow : AppColors.gray,
              weight: FontWeight.w600, height: 1),
          ),
        ),
      ),
    );
  }
}

class _RegisterBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _RegisterBtn({required this.onTap});
  @override
  State<_RegisterBtn> createState() => _RegisterBtnState();
}

class _RegisterBtnState extends State<_RegisterBtn> {
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.yellowDark : AppColors.yellow,
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.yellow.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]
                : [],
          ),
          child: Text('Register',
            style: AppTextStyles.body(14,
              color: AppColors.black, weight: FontWeight.w700, height: 1),
          ),
        ),
      ),
    );
  }
}

// ── Partner Dropdown ──────────────────────────────────────────────────────────
class _PartnerDropdown extends StatefulWidget {
  @override
  State<_PartnerDropdown> createState() => _PartnerDropdownState();
}

class _PartnerDropdownState extends State<_PartnerDropdown> {
  bool _hovered = false;
  bool _open    = false;
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  void _showDropdown() {
    _overlay = OverlayEntry(builder: (_) => Positioned(
      width: 200,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 36),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.yellowBorder),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4),
                  blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _DropdownItem(
                icon: Icons.login_rounded,
                label: 'Partner Login',
                onTap: () {
                  _closeDropdown();
                  context.go('/partner-login');
                },
              ),
              const Divider(height: 1, color: AppColors.whiteDim2),
              _DropdownItem(
                icon: Icons.business_center_outlined,
                label: 'Become a Partner',
                onTap: () {
                  _closeDropdown();
                  context.go('/partner-register');
                },
              ),
            ]),
          ),
        ),
      ),
    ));
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _closeDropdown() {
    _overlay?.remove();
    _overlay = null;
    setState(() => _open = false);
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit:  (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _open ? _closeDropdown : _showDropdown,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _open || _hovered
                  ? AppColors.yellowDim : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _open || _hovered
                    ? AppColors.yellowBorder : Colors.transparent,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('For Partners',
                  style: AppTextStyles.body(14,
                      color: _open || _hovered
                          ? AppColors.yellow : AppColors.gray,
                      weight: FontWeight.w500, height: 1)),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _open || _hovered
                        ? AppColors.yellow : AppColors.gray),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DropdownItem({required this.icon, required this.label,
      required this.onTap});

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: _hovered ? AppColors.yellowDim : Colors.transparent,
          child: Row(children: [
            Icon(widget.icon, size: 16,
                color: _hovered ? AppColors.yellow : AppColors.gray),
            const SizedBox(width: 10),
            Text(widget.label, style: AppTextStyles.body(13,
                color: _hovered ? AppColors.yellow : AppColors.white,
                height: 1)),
          ]),
        ),
      ),
    );
  }
}