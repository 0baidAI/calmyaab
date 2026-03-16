import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/calmyaab_button.dart';
import '../../shared/widgets/k_text_field.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  bool   _loading   = false;
  bool   _sent      = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _sendReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    final result = await ref.read(authServiceProvider).forgotPassword(_emailCtrl.text);

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _sent = true;
      } else {
        _error = result.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: _sent ? _SuccessState() : _FormState(
          formKey:   _formKey,
          emailCtrl: _emailCtrl,
          loading:   _loading,
          error:     _error,
          onSend:    _sendReset,
          onClose:   () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _FormState extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final String? error;
  final VoidCallback onSend, onClose;

  const _FormState({
    required this.formKey, required this.emailCtrl, required this.loading,
    this.error, required this.onSend, required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('RESET PASSWORD',
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: AppColors.yellow, letterSpacing: 1),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onClose,
                  child: Text('✕', style: AppTextStyles.body(16, color: AppColors.gray)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we\'ll send you a reset link.',
            style: AppTextStyles.body(14, color: AppColors.gray, height: 1.5),
          ),
          const SizedBox(height: 28),

          if (error != null) ...[
            KErrorBanner(message: error!),
            const SizedBox(height: 16),
          ],

          KTextField(
            label: 'Email Address',
            hint: 'you@example.com',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          CalmyaabButton(
            label: loading ? 'Sending...' : 'Send Reset Link →',
            onTap: loading ? null : onSend,
            width: double.infinity,
            height: 50,
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.yellowDim,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.yellow, size: 28),
        ),
        const SizedBox(height: 24),
        const Text('CHECK YOUR EMAIL',
          style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: AppColors.yellow, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a password reset link to your email. Check your inbox (and spam folder).',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(14, color: AppColors.gray, height: 1.6),
        ),
        const SizedBox(height: 28),
        CalmyaabButton(
          label: 'Close',
          onTap: () => Navigator.pop(context),
          style: CButtonStyle.outline,
          width: double.infinity,
          height: 48,
        ),
      ],
    );
  }
}
