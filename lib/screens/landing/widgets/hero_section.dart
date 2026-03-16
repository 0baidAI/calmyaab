import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onHowItWorks;

  const HeroSection({
    super.key,
    required this.onExplore,
    required this.onHowItWorks,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > AppConstants.tabletBreak;
    final hPad = isDesktop ? 64.0 : 20.0;

    return SizedBox(
      width: double.infinity,
      height: isDesktop ? size.height : null,
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: CustomPaint(painter: _HeroBgPainter()),
          ),
          // Grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
              child: Padding(
                padding: EdgeInsets.only(
                  left: hPad, right: hPad,
                  top: isDesktop ? 130 : 100,
                  bottom: isDesktop ? 80 : 60,
                ),
                child: isDesktop
                    ? _DesktopHero(onExplore: onExplore, onHowItWorks: onHowItWorks)
                    : _MobileHero(onExplore: onExplore, onHowItWorks: onHowItWorks),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  final VoidCallback onExplore, onHowItWorks;
  const _DesktopHero({required this.onExplore, required this.onHowItWorks});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _HeroContent(onExplore: onExplore, onHowItWorks: onHowItWorks),
        ),
        const SizedBox(width: 64),
        _StatsColumn(),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  final VoidCallback onExplore, onHowItWorks;
  const _MobileHero({required this.onExplore, required this.onHowItWorks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroContent(onExplore: onExplore, onHowItWorks: onHowItWorks),
        const SizedBox(height: 48),
        _StatsRow(),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  final VoidCallback onExplore, onHowItWorks;
  const _HeroContent({required this.onExplore, required this.onHowItWorks});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: _HeroBadge(),
        ),
        const SizedBox(height: 28),

        // Title
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR ', style: _displayStyle(AppColors.white)),
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'FIRST ', style: _displayStyle(AppColors.yellow)),
                  TextSpan(text: 'STEP TO', style: _displayStyle(AppColors.white)),
                ]),
              ),
              Text('SUCCESS', style: _displayStyle(AppColors.gray2)),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Description
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Internships with top companies, professionally crafted CVs, and study abroad guidance — all in one place. Calmyaab karo apna future.',
              style: AppTextStyles.body(17, color: AppColors.gray, height: 1.7),
            ),
          ),
        ),
        const SizedBox(height: 44),

        // Buttons
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 600),
          child: Wrap(
            spacing: 16, runSpacing: 12,
            children: [
              CalmyaabButton(label: 'Explore Services', onTap: onExplore),
              CalmyaabButton(label: 'How It Works', onTap: onHowItWorks, style: CButtonStyle.outline),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _displayStyle(Color color) => GoogleFonts.bebasNeue(
    fontSize: 96, color: color, letterSpacing: 2, height: 0.95,
  );
}

class _HeroBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.yellowDim,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.yellow.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(),
          const SizedBox(width: 8),
          Text(
            "PAKISTAN'S #1 STUDENT CAREER PLATFORM",
            style: AppTextStyles.body(11, color: AppColors.yellow, weight: FontWeight.w700, letterSpacing: 1.5, height: 1),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
      ),
    );
  }
}

class _StatsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      delay: const Duration(milliseconds: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          _StatItem(number: '50+', label: 'Partner Companies'),
          SizedBox(height: 28),
          _StatItem(number: '500+', label: 'Students Placed'),
          SizedBox(height: 28),
          _StatItem(number: '95%', label: 'Success Rate'),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _StatItem(number: '50+', label: 'Partner\nCompanies', isRow: true),
        SizedBox(width: 32),
        _StatItem(number: '500+', label: 'Students\nPlaced', isRow: true),
        SizedBox(width: 32),
        _StatItem(number: '95%', label: 'Success\nRate', isRow: true),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  final bool isRow;

  const _StatItem({required this.number, required this.label, this.isRow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: isRow ? 0 : 16,
        left:  isRow ? 16 : 0,
      ),
      decoration: BoxDecoration(
        border: isRow
            ? const Border(left: BorderSide(color: AppColors.yellow, width: 2))
            : const Border(right: BorderSide(color: AppColors.yellow, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: isRow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            number,
            style: GoogleFonts.bebasNeue(
              fontSize: 44, color: AppColors.yellow, letterSpacing: 1, height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body(12, color: AppColors.gray, weight: FontWeight.w500, letterSpacing: 0.3, height: 1.4),
            textAlign: isRow ? TextAlign.left : TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// Background painters
class _HeroBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = RadialGradient(
      center: const Alignment(0.4, 0),
      radius: 0.8,
      colors: [const Color(0xFFFFD100).withOpacity(0.07), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD100).withOpacity(0.03)
      ..strokeWidth = 1;

    const step = 60.0;
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
