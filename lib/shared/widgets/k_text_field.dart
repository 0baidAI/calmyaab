import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class KTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool autofocus;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const KTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  State<KTextField> createState() => _KTextFieldState();
}

class _KTextFieldState extends State<KTextField> {
  bool _focused = false;
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _node,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autofocus: widget.autofocus,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          style: AppTextStyles.body(14, color: AppColors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
            prefixIcon: widget.prefixIcon,
            prefixIconColor: _focused ? AppColors.yellow : AppColors.gray2,
            filled: true,
            fillColor: AppColors.black3,
            border: _border(AppColors.whiteDim2),
            enabledBorder: _border(AppColors.whiteDim2),
            focusedBorder: _border(AppColors.yellow.withOpacity(0.4)),
            errorBorder: _border(Colors.redAccent.withOpacity(0.5)),
            focusedErrorBorder: _border(Colors.redAccent.withOpacity(0.7)),
            errorStyle: AppTextStyles.body(11, color: Colors.redAccent, height: 1.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: color, width: 1),
  );
}

class KPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const KPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  State<KPasswordField> createState() => _KPasswordFieldState();
}

class _KPasswordFieldState extends State<KPasswordField> {
  bool _obscure = true;
  bool _focused = false;
  late FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
    _node.addListener(() => setState(() => _focused = _node.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _node,
          obscureText: _obscure,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onEditingComplete: widget.onEditingComplete,
          style: AppTextStyles.body(14, color: AppColors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 18),
            prefixIconColor: _focused ? AppColors.yellow : AppColors.gray2,
            suffixIcon: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: _focused ? AppColors.yellow : AppColors.gray2,
                ),
              ),
            ),
            filled: true,
            fillColor: AppColors.black3,
            border: _border(AppColors.whiteDim2),
            enabledBorder: _border(AppColors.whiteDim2),
            focusedBorder: _border(AppColors.yellow.withOpacity(0.4)),
            errorBorder: _border(Colors.redAccent.withOpacity(0.5)),
            focusedErrorBorder: _border(Colors.redAccent.withOpacity(0.7)),
            errorStyle: AppTextStyles.body(11, color: Colors.redAccent, height: 1.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: color, width: 1),
  );
}

// ── Error banner ─────────────────────────────────────────────────────────────
class KErrorBanner extends StatelessWidget {
  final String message;
  const KErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTextStyles.body(13, color: Colors.redAccent, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ── Success banner ────────────────────────────────────────────────────────────
class KSuccessBanner extends StatelessWidget {
  final String message;
  const KSuccessBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.yellow, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
