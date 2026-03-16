import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/calmyaab_button.dart';
import '../../shared/widgets/k_text_field.dart';
import 'auth_layout.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _emailFocus.dispose(); _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    final result = await ref.read(studentProvider.notifier).login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      context.go('/dashboard');
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      form: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back to home
              BackToHomeLink(onTap: () => context.go('/')),
              const SizedBox(height: 40),

              // Header
              Text('WELCOME BACK', style: _displayStyle),
              const SizedBox(height: 8),
              Text(
                'Log in to your Calmyaab account.',
                style: AppTextStyles.body(15, color: AppColors.gray, height: 1.5),
              ),
              const SizedBox(height: 36),

              // Error banner
              if (_error != null) ...[
                KErrorBanner(message: _error!),
                const SizedBox(height: 20),
              ],

              // Email
              KTextField(
                label: 'Email Address',
                hint: 'you@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _passFocus.requestFocus(),
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              KPasswordField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passCtrl,
                focusNode: _passFocus,
                textInputAction: TextInputAction.done,
                onEditingComplete: _login,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: _ForgotLink(
                  onTap: () => showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.8),
                    builder: (_) => const ForgotPasswordDialog(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login button
              CalmyaabButton(
                label: _loading ? 'Logging in...' : 'Log In →',
                onTap: _loading ? null : _login,
                width: double.infinity,
                height: 54,
              ),
              const SizedBox(height: 24),

              // Divider
              _OrDivider(),
              const SizedBox(height: 24),

              // Switch to register
              AuthSwitchLink(
                prefix: "Don't have an account?",
                linkText: 'Create one free',
                onTap: () => context.go('/register'),
              ),
              const SizedBox(height: 32),

              // Security note
              _SecurityNote(),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _displayStyle => const TextStyle(
    fontFamily: 'BebasNeue', fontSize: 44,
    color: AppColors.white, letterSpacing: 2, height: 1,
  );
}

class _ForgotLink extends StatefulWidget {
  final VoidCallback onTap;
  const _ForgotLink({required this.onTap});

  @override
  State<_ForgotLink> createState() => _ForgotLinkState();
}

class _ForgotLinkState extends State<_ForgotLink> {
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
          style: AppTextStyles.body(13,
            color: _hovered ? AppColors.yellow : AppColors.gray,
            height: 1,
          ),
          child: const Text('Forgot password?'),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.whiteDim2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: AppTextStyles.body(11, color: AppColors.gray2, weight: FontWeight.w600, letterSpacing: 2, height: 1)),
        ),
        Expanded(child: Container(height: 1, color: AppColors.whiteDim2)),
      ],
    );
  }
}

class _SecurityNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.gray2),
        const SizedBox(width: 6),
        Text(
          'Secured by Firebase Authentication',
          style: AppTextStyles.body(12, color: AppColors.gray2, height: 1),
        ),
      ],
    );
  }
}
