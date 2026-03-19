import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/calmyaab_button.dart';
import '../../shared/widgets/k_text_field.dart';

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
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

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      final doc = await FirebaseFirestore.instance
          .collection('agencies')
          .doc(cred.user!.uid)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _loading = false;
          _error = 'No agency account found with this email.';
        });
        return;
      }

      if (mounted) context.go('/agency');

    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.code == 'invalid-credential'
            ? 'Incorrect email or password.'
            : e.message ?? 'Something went wrong';
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Something went wrong'; });
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
                  Center(child: Column(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.yellowDim,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.yellow, width: 2),
                      ),
                      child: const Center(child: Text('🌍',
                          style: TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 16),
                    Text('CALMYAAB',
                        style: GoogleFonts.bebasNeue(
                            fontSize: 32,
                            color: AppColors.yellow,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.yellowDim,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.yellowBorder),
                      ),
                      child: Text('AGENCY PORTAL',
                          style: AppTextStyles.body(11,
                              color: AppColors.yellow,
                              weight: FontWeight.w700,
                              letterSpacing: 2,
                              height: 1)),
                    ),
                  ])),
                  const SizedBox(height: 48),

                  const Text('AGENCY LOGIN',
                      style: TextStyle(fontFamily: 'BebasNeue',
                          fontSize: 36, color: AppColors.white,
                          letterSpacing: 2, height: 1)),
                  const SizedBox(height: 8),
                  Text('Access your consultation dashboard.',
                      style: AppTextStyles.body(14,
                          color: AppColors.gray, height: 1.5)),
                  const SizedBox(height: 32),

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

                  KTextField(
                    label: 'Agency Email',
                    hint: 'agency@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    validator: (v) {
                      if (v?.isEmpty == true) return 'Email is required';
                      if (!v!.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  KPasswordField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passCtrl,
                    onEditingComplete: _login,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 32),

                  CalmyaabButton(
                    label: _loading ? 'Logging in...' : 'Access Dashboard →',
                    onTap: _loading ? null : _login,
                    width: double.infinity, height: 54,
                  ),
                  const SizedBox(height: 24),
                  Center(child: GestureDetector(
                    onTap: () => context.go('/'),
                    child: Text('← Back to main site',
                        style: AppTextStyles.body(13,
                            color: AppColors.gray, height: 1)),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}