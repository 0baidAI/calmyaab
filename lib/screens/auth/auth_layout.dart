import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class AuthLayout extends StatelessWidget {
  final Widget form;

  const AuthLayout({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppConstants.tabletBreak;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: isDesktop
          ? Row(children: [
              Expanded(child: _BrandPanel()),
              Expanded(child: _FormPanel(child: form)),
            ])
          : _FormPanel(child: form, mobile: true),
    );
  }
}

// ── Left brand panel (desktop only) ─────────────────────────────────────────
class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.black2,
        border: Border(right: BorderSide(color: AppColors.yellowBorder, width: 1)),
      ),
      child: Stack(
        children: [
          // Grid background
          Positioned.fill(child: CustomPaint(painter: _AuthGridPainter())),
          // Radial glow
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.yellow.withOpacity(0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                FadeInDown(
                  child: Text('CALMYAAB',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 36, color: AppColors.yellow, letterSpacing: 2,
                    ),
                  ),
                ),
                const Spacer(),

                // Big headline
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR CAREER', style: _displayStyle(AppColors.white)),
                      Text('STARTS', style: _displayStyle(AppColors.white)),
                      Text('HERE.', style: _displayStyle(AppColors.yellow)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Join thousands of Pakistani students building their future with Calmyaab.',
                    style: AppTextStyles.body(16, color: AppColors.gray, height: 1.7),
                  ),
                ),
                const SizedBox(height: 48),

                // Stats row
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Row(children: const [
                    _MiniStat(number: '50+',  label: 'Companies'),
                    SizedBox(width: 32),
                    _MiniStat(number: '500+', label: 'Students'),
                    SizedBox(width: 32),
                    _MiniStat(number: '95%',  label: 'Success'),
                  ]),
                ),
                const SizedBox(height: 48),

                // Testimonial
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.yellowDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.yellowBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Got my first internship at a tech company within 3 weeks of signing up. Calmyaab actually delivers."',
                          style: AppTextStyles.body(14, color: AppColors.white, height: 1.65),
                        ),
                        const SizedBox(height: 16),
                        Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.yellow, shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('A',
                                style: AppTextStyles.body(16, color: AppColors.black, weight: FontWeight.w700, height: 1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ahmed Raza', style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1)),
                              Text('CS Student, FAST Lahore', style: AppTextStyles.body(11, color: AppColors.gray, height: 1.3)),
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _displayStyle(Color color) => GoogleFonts.bebasNeue(
    fontSize: 64, color: color, letterSpacing: 2, height: 1.0,
  );
}

class _MiniStat extends StatelessWidget {
  final String number, label;
  const _MiniStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(number,
          style: GoogleFonts.bebasNeue(fontSize: 32, color: AppColors.yellow, letterSpacing: 1, height: 1),
        ),
        Text(label, style: AppTextStyles.body(12, color: AppColors.gray, height: 1.3)),
      ],
    );
  }
}

// ── Right form panel ─────────────────────────────────────────────────────────
class _FormPanel extends StatelessWidget {
  final Widget child;
  final bool mobile;
  const _FormPanel({required this.child, this.mobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 20 : 56,
            vertical: 48,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Grid background painter ──────────────────────────────────────────────────
class _AuthGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.yellow.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Back to home link ────────────────────────────────────────────────────────
class BackToHomeLink extends StatefulWidget {
  final VoidCallback onTap;
  const BackToHomeLink({super.key, required this.onTap});

  @override
  State<BackToHomeLink> createState() => _BackToHomeLinkState();
}

class _BackToHomeLinkState extends State<BackToHomeLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _hovered ? -0.05 : 0,
              child: const Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.gray),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: AppTextStyles.body(13, color: _hovered ? AppColors.white : AppColors.gray, height: 1),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auth link (e.g. "Already have an account? Login") ────────────────────────
class AuthSwitchLink extends StatelessWidget {
  final String prefix;
  final String linkText;
  final VoidCallback onTap;

  const AuthSwitchLink({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prefix, style: AppTextStyles.body(14, color: AppColors.gray, height: 1)),
        const SizedBox(width: 4),
        _Link(text: linkText, onTap: onTap),
      ],
    );
  }
}

class _Link extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _Link({required this.text, required this.onTap});

  @override
  State<_Link> createState() => _LinkState();
}

class _LinkState extends State<_Link> {
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
          duration: const Duration(milliseconds: 150),
          style: AppTextStyles.body(14,
            color: _hovered ? AppColors.yellow : AppColors.yellow.withOpacity(0.7),
            weight: FontWeight.w600, height: 1,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
