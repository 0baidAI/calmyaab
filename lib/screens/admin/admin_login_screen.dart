import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/calmyaab_button.dart';
import '../../shared/widgets/k_text_field.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
      if (result.student?.role == 'admin' ||
          result.student?.role == 'super_admin') {
        context.go('/admin');
      } else {
        await ref.read(studentProvider.notifier).signOut();
        setState(() => _error = 'Access denied. This portal is for admins only.');
      }
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.redAccent, size: 30),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('CALMYAAB',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 32, color: AppColors.yellow, letterSpacing: 2),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: Text('ADMIN PORTAL',
                            style: AppTextStyles.body(11,
                              color: Colors.redAccent,
                              weight: FontWeight.w700,
                              letterSpacing: 2, height: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Title
                  const Text('ADMIN LOGIN',
                    style: TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
                      color: AppColors.white, letterSpacing: 2, height: 1),
                  ),
                  const SizedBox(height: 8),
                  Text('Restricted access — authorized personnel only.',
                    style: AppTextStyles.body(14, color: AppColors.gray, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Error
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded,
                          color: Colors.redAccent, size: 16),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!,
                          style: AppTextStyles.body(13,
                            color: Colors.redAccent, height: 1.4))),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Email
                  KTextField(
                    label: 'Admin Email',
                    hint: 'admin@calmyaab.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
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
                    hint: 'Enter admin password',
                    controller: _passCtrl,
                    onEditingComplete: _login,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  CalmyaabButton(
                    label: _loading ? 'Verifying...' : 'Access Admin Panel →',
                    onTap: _loading ? null : _login,
                    width: double.infinity,
                    height: 54,
                  ),
                  const SizedBox(height: 24),

                  // Back to main site
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text('← Back to main site',
                        style: AppTextStyles.body(13,
                          color: AppColors.gray, height: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}