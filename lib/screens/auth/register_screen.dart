import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/calmyaab_button.dart';
import '../../shared/widgets/k_text_field.dart';
import 'auth_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey1 = GlobalKey<FormState>(); // Step 1: personal
  final _formKey2 = GlobalKey<FormState>(); // Step 2: academic + password

  // Step 1 controllers
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Step 2 controllers
  final _uniCtrl    = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _cpassCtrl  = TextEditingController();

  String _field   = 'Computer Science / IT';
  int    _step    = 1;
  bool   _loading = false;
  String? _error;

  static const _fields = [
    'Computer Science / IT',
    'Business / BBA / MBA',
    'Engineering',
    'Marketing / Media',
    'Finance / Accounting',
    'Medicine / Health Sciences',
    'Social Sciences',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _uniCtrl.dispose(); _passCtrl.dispose(); _cpassCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey1.currentState?.validate() ?? false) {
      setState(() { _step = 2; _error = null; });
    }
  }

  Future<void> _register() async {
    if (!(_formKey2.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });

    final result = await ref.read(studentProvider.notifier).register(
      name:       _nameCtrl.text,
      email:      _emailCtrl.text,
      password:   _passCtrl.text,
      phone:      _phoneCtrl.text,
      university: _uniCtrl.text,
      field:      _field,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      context.go('/dashboard');
    } else {
      setState(() { _error = result.error; _step = 1; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackToHomeLink(onTap: () => context.go('/')),
          const SizedBox(height: 40),

          // Header
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CREATE ACCOUNT', style: _displayStyle),
                const SizedBox(height: 8),
                Text(
                  'Start your journey to success with Calmyaab.',
                  style: AppTextStyles.body(15, color: AppColors.gray, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Step indicator
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: _StepIndicator(currentStep: _step),
          ),
          const SizedBox(height: 32),

          // Error banner
          if (_error != null) ...[
            KErrorBanner(message: _error!),
            const SizedBox(height: 20),
          ],

          // Forms
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: _step == 1
                ? _Step1Form(
                    key: const ValueKey('step1'),
                    formKey:   _formKey1,
                    nameCtrl:  _nameCtrl,
                    emailCtrl: _emailCtrl,
                    phoneCtrl: _phoneCtrl,
                    onNext:    _nextStep,
                    error:     _error,
                  )
                : _Step2Form(
                    key: const ValueKey('step2'),
                    formKey:  _formKey2,
                    uniCtrl:  _uniCtrl,
                    passCtrl: _passCtrl,
                    cpassCtrl: _cpassCtrl,
                    field:    _field,
                    fields:   _fields,
                    onFieldChanged: (v) => setState(() => _field = v!),
                    onBack:   () => setState(() { _step = 1; _error = null; }),
                    onSubmit: _register,
                    loading:  _loading,
                  ),
          ),
          const SizedBox(height: 28),

          // Switch to login
          AuthSwitchLink(
            prefix: 'Already have an account?',
            linkText: 'Log in',
            onTap: () => context.go('/login'),
          ),
          const SizedBox(height: 24),

          // Terms note
          Center(
            child: Text(
              'By registering, you agree to our Terms of Service\nand Privacy Policy.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(11, color: AppColors.gray2, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _displayStyle => const TextStyle(
    fontFamily: 'BebasNeue', fontSize: 44,
    color: AppColors.white, letterSpacing: 2, height: 1,
  );
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(label: '1', title: 'Personal Info', active: currentStep == 1, done: currentStep > 1),
        Expanded(child: Container(height: 1, color: currentStep > 1 ? AppColors.yellow : AppColors.whiteDim2)),
        _StepDot(label: '2', title: 'Academic Info', active: currentStep == 2, done: false),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label, title;
  final bool active, done;
  const _StepDot({required this.label, required this.title, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: done ? AppColors.yellow : active ? AppColors.yellow : AppColors.black3,
            shape: BoxShape.circle,
            border: Border.all(
              color: active || done ? AppColors.yellow : AppColors.gray2, width: 2,
            ),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 16, color: AppColors.black)
                : Text(label,
                    style: TextStyle(
                      fontFamily: 'BebasNeue', fontSize: 16,
                      color: active ? AppColors.black : AppColors.gray2,
                      height: 1,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(title,
          style: AppTextStyles.body(11,
            color: active || done ? AppColors.yellow : AppColors.gray2,
            weight: FontWeight.w600, letterSpacing: 0.3, height: 1,
          ),
        ),
      ],
    );
  }
}

// ── Step 1 form ───────────────────────────────────────────────────────────────
class _Step1Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl;
  final VoidCallback onNext;
  final String? error;

  const _Step1Form({
    super.key,
    required this.formKey, required this.nameCtrl,
    required this.emailCtrl, required this.phoneCtrl,
    required this.onNext, this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          KTextField(
            label: 'Full Name',
            hint: 'e.g. Ahmed Khan',
            controller: nameCtrl,
            autofocus: true,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Full name is required';
              if (v.trim().length < 3) return 'Name must be at least 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),
          KTextField(
            label: 'Email Address',
            hint: 'you@example.com',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          KTextField(
            label: 'WhatsApp / Phone',
            hint: 'e.g. 0300-1234567',
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined, size: 18),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Phone number is required';
              if (v.trim().length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 32),
          CalmyaabButton(
            label: 'Next: Academic Info →',
            onTap: onNext,
            width: double.infinity,
            height: 54,
          ),
        ],
      ),
    );
  }
}

// ── Step 2 form ───────────────────────────────────────────────────────────────
class _Step2Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController uniCtrl, passCtrl, cpassCtrl;
  final String field;
  final List<String> fields;
  final ValueChanged<String?> onFieldChanged;
  final VoidCallback onBack, onSubmit;
  final bool loading;

  const _Step2Form({
    super.key,
    required this.formKey, required this.uniCtrl,
    required this.passCtrl, required this.cpassCtrl,
    required this.field, required this.fields,
    required this.onFieldChanged, required this.onBack,
    required this.onSubmit, required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          KTextField(
            label: 'University / College',
            hint: 'e.g. LUMS, FAST, UET, NUST',
            controller: uniCtrl,
            autofocus: true,
            prefixIcon: const Icon(Icons.school_outlined, size: 18),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'University name is required';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Field of study dropdown
          _FieldDropdown(
            value: field, items: fields, onChanged: onFieldChanged,
          ),
          const SizedBox(height: 20),

          KPasswordField(
            label: 'Password',
            hint: 'Minimum 6 characters',
            controller: passCtrl,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),

          KPasswordField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: cpassCtrl,
            textInputAction: TextInputAction.done,
            onEditingComplete: onSubmit,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != passCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              CalmyaabButton(
                label: '← Back',
                onTap: onBack,
                style: CButtonStyle.outline,
                height: 54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CalmyaabButton(
                  label: loading ? 'Creating Account...' : 'Create Account →',
                  onTap: loading ? null : onSubmit,
                  height: 54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FieldDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FIELD OF STUDY', style: AppTextStyles.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: AppColors.black3,
          style: AppTextStyles.body(14, color: AppColors.white),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.book_outlined, size: 18),
            prefixIconColor: AppColors.gray2,
            filled: true,
            fillColor: AppColors.black3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.whiteDim2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.whiteDim2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis)))
              .toList(),
        ),
      ],
    );
  }
}
