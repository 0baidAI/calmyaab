import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../core/constants/app_constants.dart';

class SectionWrapper extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool animate;

  const SectionWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.animate = true,
  });

  @override
  State<SectionWrapper> createState() => _SectionWrapperState();
}

class _SectionWrapperState extends State<SectionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppConstants.tabletBreak;
    final hPad = isDesktop ? AppConstants.sectionPaddingH : AppConstants.mobilePaddingH;
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: hPad,
      vertical: AppConstants.sectionPaddingV,
    );

    Widget content = Container(
      color: widget.backgroundColor,
      width: double.infinity,
      padding: widget.padding ?? defaultPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxWidth),
          child: widget.child,
        ),
      ),
    );

    if (!widget.animate) return content;

    return VisibilityDetector(
      key: Key(widget.hashCode.toString()),
      onVisibilityChanged: (info) {
        if (!_triggered && info.visibleFraction > 0.1) {
          _triggered = true;
          _ctrl.forward();
        }
      },
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _slide, child: content),
      ),
    );
  }
}

// Section tag + title + desc header
class SectionHeader extends StatelessWidget {
  final String tag;
  final String title;
  final String? desc;
  final CrossAxisAlignment alignment;

  const SectionHeader({
    super.key,
    required this.tag,
    required this.title,
    this.desc,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isCenter = alignment == CrossAxisAlignment.center;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(tag.toUpperCase(), style: _tagStyle),
        const SizedBox(height: 14),
        Text(title, style: _titleStyle, textAlign: isCenter ? TextAlign.center : TextAlign.start),
        if (desc != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: isCenter ? 520 : double.infinity,
            child: Text(
              desc!,
              style: _descStyle,
              textAlign: isCenter ? TextAlign.center : TextAlign.start,
            ),
          ),
        ],
      ],
    );
  }

  TextStyle get _tagStyle => const TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3,
    color: Color(0xFFFFD100), height: 1,
  );

  TextStyle get _titleStyle => TextStyle(
    fontFamily: 'BebasNeue', fontSize: 58, color: const Color(0xFFF5F5F0),
    letterSpacing: 2, height: 1.0,
    shadows: [],
  );

  TextStyle get _descStyle => const TextStyle(
    fontSize: 16, color: Color(0xFF888888), height: 1.7,
  );
}

// Yellow horizontal divider
class YellowDivider extends StatelessWidget {
  const YellowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          Color(0x33FFD100),
          Colors.transparent,
        ]),
      ),
    );
  }
}
