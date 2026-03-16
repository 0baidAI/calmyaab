import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum CButtonStyle { primary, outline, ghost }

class CalmyaabButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final CButtonStyle style;
  final double? width;
  final double height;
  final double fontSize;

  const CalmyaabButton({
    super.key,
    required this.label,
    this.onTap,
    this.style = CButtonStyle.primary,
    this.width,
    this.height = 52,
    this.fontSize = 15,
  });

  @override
  State<CalmyaabButton> createState() => _CalmyaabButtonState();
}

class _CalmyaabButtonState extends State<CalmyaabButton> {
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
          width:  widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: _decoration,
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyles.body(
                widget.fontSize,
                color: _textColor,
                weight: FontWeight.w700,
                letterSpacing: 0.3,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration get _decoration {
    switch (widget.style) {
      case CButtonStyle.primary:
        return BoxDecoration(
          color: _hovered ? AppColors.yellowDark : AppColors.yellow,
          borderRadius: BorderRadius.circular(4),
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.yellow.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))]
              : [],
        );
      case CButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _hovered ? AppColors.yellow : AppColors.white.withOpacity(0.2),
            width: 1,
          ),
        );
      case CButtonStyle.ghost:
        return BoxDecoration(
          color: _hovered ? AppColors.yellowDim : AppColors.yellowDim2,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.yellowBorder, width: 1),
        );
    }
  }

  Color get _textColor {
    switch (widget.style) {
      case CButtonStyle.primary: return AppColors.black;
      case CButtonStyle.outline: return _hovered ? AppColors.yellow : AppColors.white;
      case CButtonStyle.ghost:   return AppColors.yellow;
    }
  }
}
