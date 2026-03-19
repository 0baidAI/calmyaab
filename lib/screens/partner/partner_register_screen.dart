import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/calmyaab_button.dart';
import '../../shared/widgets/k_text_field.dart';

class PartnerRegisterScreen extends StatefulWidget {
  const PartnerRegisterScreen({super.key});

  @override
  State<PartnerRegisterScreen> createState() =>
      _PartnerRegisterScreenState();
}

class _PartnerRegisterScreenState
    extends State<PartnerRegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _companyCtrl  = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _websiteCtrl  = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _cpassCtrl    = TextEditingController();
  String _industry    = 'Technology';
  bool _loading       = false;
  String? _error;
  bool _submitted     = false;

  static const _industries = [
    'Technology', 'Marketing', 'Finance', 'Engineering',
    'Media', 'Healthcare', 'Education', 'Retail', 'Other',
  ];

  @override
  void dispose() {
    _companyCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _websiteCtrl.dispose();
    _passCtrl.dispose(); _cpassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('partners')
          .doc(cred.user!.uid)
          .set({
        'company_name': _companyCtrl.text.trim(),
        'email':        _emailCtrl.text.trim(),
        'phone':        _phoneCtrl.text.trim(),
        'website':      _websiteCtrl.text.trim(),
        'industry':     _industry,
        'status':       'pending',
        'role':         'partner',
        'created_at':   DateTime.now().millisecondsSinceEpoch,
      });

      // Sign out immediately — wait for approval
      await FirebaseAuth.instance.signOut();

      setState(() { _loading = false; _submitted = true; });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.code == 'email-already-in-use'
            ? 'This email is already registered!'
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: _submitted
                ? _SubmittedState(onLogin: () => context.go('/partner-login'))
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Center(child: Column(children: [
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
                            child: Text('PARTNER PORTAL',
                                style: AppTextStyles.body(11,
                                    color: AppColors.yellow,
                                    weight: FontWeight.w700,
                                    letterSpacing: 2,
                                    height: 1)),
                          ),
                        ])),
                        const SizedBox(height: 40),

                        const Text('REGISTER YOUR COMPANY',
                            style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: 36,
                                color: AppColors.white,
                                letterSpacing: 2,
                                height: 1)),
                        const SizedBox(height: 8),
                        Text(
                          'Join Calmyaab as a hiring partner and connect with talented students.',
                          style: AppTextStyles.body(14,
                              color: AppColors.gray, height: 1.5),
                        ),
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
                          label: 'Company Name *',
                          hint: 'e.g. TechCorp Pakistan',
                          controller: _companyCtrl,
                          autofocus: true,
                          prefixIcon: const Icon(Icons.business_outlined, size: 18),
                          validator: (v) => v?.isEmpty == true
                              ? 'Company name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        KTextField(
                          label: 'Business Email *',
                          hint: 'hr@company.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, size: 18),
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Email is required';
                            if (!v!.contains('@')) return 'Enter valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        KTextField(
                          label: 'Phone Number *',
                          hint: '03001234567',
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                          validator: (v) => v?.isEmpty == true
                              ? 'Phone is required' : null,
                        ),
                        const SizedBox(height: 16),
                        KTextField(
                          label: 'Website (optional)',
                          hint: 'https://company.com',
                          controller: _websiteCtrl,
                          prefixIcon: const Icon(Icons.language_outlined, size: 18),
                          validator: (_) => null,
                        ),
                        const SizedBox(height: 16),

                        // Industry dropdown
                        Text('INDUSTRY *', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _industry,
                          onChanged: (v) => setState(() => _industry = v!),
                          dropdownColor: AppColors.black3,
                          style: AppTextStyles.body(14, color: AppColors.white),
                          decoration: InputDecoration(
                            filled: true, fillColor: AppColors.black3,
                            prefixIcon: const Icon(Icons.category_outlined,
                                size: 18, color: AppColors.gray2),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                    color: AppColors.whiteDim2)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                    color: AppColors.whiteDim2)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                    color: AppColors.yellow.withOpacity(0.4))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          items: _industries.map((i) => DropdownMenuItem(
                              value: i, child: Text(i))).toList(),
                        ),
                        const SizedBox(height: 16),

                        KPasswordField(
                          label: 'Password *',
                          hint: 'Minimum 6 characters',
                          controller: _passCtrl,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Password required';
                            if (v!.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        KPasswordField(
                          label: 'Confirm Password *',
                          hint: 'Re-enter password',
                          controller: _cpassCtrl,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Please confirm password';
                            if (v != _passCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.yellowDim,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.yellowBorder),
                          ),
                          child: Row(children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.yellow, size: 16),
                            const SizedBox(width: 10),
                            Expanded(child: Text(
                              'Your account will be reviewed by our team. You\'ll receive access within 24 hours.',
                              style: AppTextStyles.body(12,
                                  color: AppColors.yellow, height: 1.4),
                            )),
                          ]),
                        ),
                        const SizedBox(height: 28),

                        CalmyaabButton(
                          label: _loading ? 'Submitting...' : 'Submit Application →',
                          onTap: _loading ? null : _register,
                          width: double.infinity, height: 54,
                        ),
                        const SizedBox(height: 20),

                        Center(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already approved? ',
                                style: AppTextStyles.body(14,
                                    color: AppColors.gray, height: 1)),
                            GestureDetector(
                              onTap: () => context.go('/partner-login'),
                              child: Text('Login here',
                                  style: AppTextStyles.body(14,
                                      color: AppColors.yellow,
                                      weight: FontWeight.w600,
                                      height: 1)),
                            ),
                          ],
                        )),
                        const SizedBox(height: 16),
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

class _SubmittedState extends StatelessWidget {
  final VoidCallback onLogin;
  const _SubmittedState({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.yellowDim,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          child: const Center(child: Text('🎉',
              style: TextStyle(fontSize: 36))),
        ),
        const SizedBox(height: 24),
        const Text('APPLICATION SUBMITTED!',
            style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32,
                color: AppColors.yellow, letterSpacing: 1),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Your application has been received. Our team will review it and approve your access within 24 hours.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(14, color: AppColors.gray, height: 1.7),
        ),
        const SizedBox(height: 32),
        CalmyaabButton(
          label: 'Go to Partner Login →',
          onTap: onLogin,
          width: double.infinity, height: 50,
        ),
      ],
    );
  }
}
