import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class CtaBanner extends StatelessWidget {
  final VoidCallback onGetStarted;
  const CtaBanner({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.yellow,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background text
          Positioned.fill(
            child: Center(
              child: Text(
                'CALMYAAB',
                style: GoogleFonts.bebasNeue(
                  fontSize: 200, color: Colors.black.withOpacity(0.04),
                  letterSpacing: 10,
                ),
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              Text(
                'READY TO BE CALMYAAB?',
                style: GoogleFonts.bebasNeue(
                  fontSize: 64, color: AppColors.black,
                  letterSpacing: 2, height: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Join hundreds of students already building their careers with us.',
                style: AppTextStyles.body(17, color: AppColors.black.withOpacity(0.65), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _DarkButton(label: 'Start Your Journey →', onTap: onGetStarted),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _DarkButton({required this.label, required this.onTap});

  @override
  State<_DarkButton> createState() => _DarkButtonState();
}

class _DarkButtonState extends State<_DarkButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(4),
            boxShadow: _hovered
                ? [const BoxShadow(color: Colors.black38, blurRadius: 32, offset: Offset(0, 12))]
                : [],
          ),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          child: Text(
            widget.label,
            style: AppTextStyles.body(16, color: AppColors.yellow, weight: FontWeight.w700, height: 1),
          ),
        ),
      ),
    );
  }
}

// ─── FOOTER ───────────────────────────────────────────────────────────────────

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppConstants.tabletBreak;
    final hPad = isDesktop ? 64.0 : 20.0;

    return Container(
      width: double.infinity,
      color: AppColors.black2,
      padding: EdgeInsets.fromLTRB(hPad, 64, hPad, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
          child: Column(
            children: [
              isDesktop ? _FooterDesktop() : _FooterMobile(),
              const SizedBox(height: 48),
              const Divider(color: AppColors.whiteDim2, height: 1),
              const SizedBox(height: 28),
              _FooterBottom(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _FooterBrand()),
        const SizedBox(width: 48),
        Expanded(child: _FooterCol(title: 'Services', items: const ['Internship Access', 'CV Building', 'Study Abroad', 'Bundle Packages'])),
        Expanded(child: _FooterCol(title: 'Company', items: const ['About Us', 'Partner Companies', 'Success Stories', 'Blog'])),
        Expanded(child: _FooterCol(title: 'Support', items: const ['WhatsApp', 'Instagram', 'FAQ', 'Refund Policy'])),
      ],
    );
  }
}

class _FooterMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FooterBrand(),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _FooterCol(title: 'Services', items: const ['Internship Access', 'CV Building', 'Study Abroad'])),
            Expanded(child: _FooterCol(title: 'Support', items: const ['WhatsApp', 'Instagram', 'FAQ'])),
          ],
        ),
      ],
    );
  }
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CALMYAAB',
          style: GoogleFonts.bebasNeue(fontSize: 32, color: AppColors.yellow, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Text(
          "Pakistan's student career platform — connecting students with internships, professional CVs, and global education opportunities.",
          style: AppTextStyles.body(14, color: AppColors.gray, height: 1.7),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _SocialBtn(icon: '📸'),
            const SizedBox(width: 10),
            _SocialBtn(icon: '💼'),
            const SizedBox(width: 10),
            _SocialBtn(icon: '💬'),
          ],
        ),
      ],
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final String icon;
  const _SocialBtn({required this.icon});

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _hovered ? AppColors.yellow : AppColors.yellowDim,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.yellowBorder, width: 1),
        ),
        child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterCol({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
          style: AppTextStyles.body(12, color: AppColors.yellow, weight: FontWeight.w700, letterSpacing: 2, height: 1),
        ),
        const SizedBox(height: 20),
        ...items.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FooterLink(label: i),
        )),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink({required this.label});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: AppTextStyles.body(14, color: _hovered ? AppColors.white : AppColors.gray, height: 1),
        child: Text(widget.label),
      ),
    );
  }
}

class _FooterBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('© 2025 Calmyaab. All rights reserved. Made in Pakistan 🇵🇰',
          style: AppTextStyles.body(13, color: AppColors.gray2, height: 1),
        ),
        Text('Privacy Policy · Terms of Service',
          style: AppTextStyles.body(13, color: AppColors.gray2, height: 1),
        ),
      ],
    );
  }
}
