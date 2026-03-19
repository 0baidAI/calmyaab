import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class PartnerProfileTab extends StatefulWidget {
  const PartnerProfileTab({super.key});

  @override
  State<PartnerProfileTab> createState() => _PartnerProfileTabState();
}

class _PartnerProfileTabState extends State<PartnerProfileTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: AppColors.black2,
        child: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.yellow,
          labelColor: AppColors.yellow,
          unselectedLabelColor: AppColors.gray,
          labelStyle: AppTextStyles.body(13,
              weight: FontWeight.w600, height: 1),
          tabs: const [
            Tab(text: '🏢 Company Info'),
            Tab(text: '🔒 Change Password'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: const [
            _CompanyInfoTab(),
            _ChangePasswordTab(),
          ],
        ),
      ),
    ]);
  }
}

// ── Company Info Tab ──────────────────────────────────────────────────────────
class _CompanyInfoTab extends StatefulWidget {
  const _CompanyInfoTab();

  @override
  State<_CompanyInfoTab> createState() => _CompanyInfoTabState();
}

class _CompanyInfoTabState extends State<_CompanyInfoTab> {
  final _companyCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _websiteCtrl = TextEditingController();
  String _industry   = 'Technology';
  bool _loading      = false;
  bool _saved        = false;
  bool _fetched      = false;

  static const _industries = [
    'Technology', 'Marketing', 'Finance', 'Engineering',
    'Media', 'Healthcare', 'Education', 'Retail', 'Other',
  ];

  final String _uid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('partners')
        .doc(_uid)
        .get();
    if (!mounted) return;
    final data = doc.data() ?? {};
    setState(() {
      _companyCtrl.text = data['company_name'] ?? '';
      _phoneCtrl.text   = data['phone'] ?? '';
      _websiteCtrl.text = data['website'] ?? '';
      _industry         = data['industry'] ?? 'Technology';
      _fetched          = true;
    });
  }

  Future<void> _save() async {
    if (_companyCtrl.text.isEmpty) return;
    setState(() { _loading = true; _saved = false; });

    await FirebaseFirestore.instance
        .collection('partners')
        .doc(_uid)
        .update({
      'company_name': _companyCtrl.text.trim(),
      'phone':        _phoneCtrl.text.trim(),
      'website':      _websiteCtrl.text.trim(),
      'industry':     _industry,
      'updated_at':   DateTime.now().millisecondsSinceEpoch,
    });

    setState(() { _loading = false; _saved = true; });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_fetched) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.yellow));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMPANY INFORMATION',
                style: AppTextStyles.body(11,
                    color: AppColors.yellow,
                    weight: FontWeight.w700,
                    letterSpacing: 3,
                    height: 1)),
            const SizedBox(height: 8),
            Text('Update your company details visible to students.',
                style: AppTextStyles.body(14,
                    color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 32),

            if (_saved) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 10),
                  Text('Company info updated successfully! ✅',
                      style: AppTextStyles.body(13,
                          color: Colors.greenAccent, height: 1)),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            KTextField(
              label: 'Company Name *',
              hint: 'e.g. TechCorp Pakistan',
              controller: _companyCtrl,
              prefixIcon: const Icon(
                  Icons.business_outlined, size: 18),
              validator: (_) => null,
            ),
            const SizedBox(height: 16),

            // Email (read only)
            Text('EMAIL ADDRESS', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.black3,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.whiteDim2),
              ),
              child: Row(children: [
                const Icon(Icons.email_outlined,
                    size: 18, color: AppColors.gray2),
                const SizedBox(width: 10),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: AppTextStyles.body(14,
                      color: AppColors.gray, height: 1),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.black2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Cannot change',
                      style: AppTextStyles.body(10,
                          color: AppColors.gray2, height: 1)),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            KTextField(
              label: 'Phone Number',
              hint: '03001234567',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(
                  Icons.phone_outlined, size: 18),
              validator: (_) => null,
            ),
            const SizedBox(height: 16),

            KTextField(
              label: 'Website',
              hint: 'https://company.com',
              controller: _websiteCtrl,
              prefixIcon: const Icon(
                  Icons.language_outlined, size: 18),
              validator: (_) => null,
            ),
            const SizedBox(height: 16),

            Text('INDUSTRY', style: AppTextStyles.label),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _industry,
              onChanged: (v) =>
                  setState(() => _industry = v!),
              dropdownColor: AppColors.black3,
              style: AppTextStyles.body(14,
                  color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.black3,
                prefixIcon: const Icon(
                    Icons.category_outlined,
                    size: 18,
                    color: AppColors.gray2),
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
                        color: AppColors.yellow
                            .withOpacity(0.4))),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
              items: _industries
                  .map((i) =>
                      DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
            ),
            const SizedBox(height: 32),

            CalmyaabButton(
              label: _loading
                  ? 'Saving...'
                  : 'Save Changes →',
              onTap: _loading ? null : _save,
              width: double.infinity,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Change Password Tab ───────────────────────────────────────────────────────
class _ChangePasswordTab extends StatefulWidget {
  const _ChangePasswordTab();

  @override
  State<_ChangePasswordTab> createState() =>
      _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading      = false;
  String? _error;
  bool _success      = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() { _error = null; _success = false; });

    if (_currentCtrl.text.isEmpty ||
        _newCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    if (_newCtrl.text.length < 6) {
      setState(() =>
          _error = 'New password must be at least 6 characters');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Re-authenticate first
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newCtrl.text);

      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();

      setState(() { _loading = false; _success = true; });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _success = false);
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.code == 'wrong-password'
            ? 'Current password is incorrect'
            : e.message ?? 'Something went wrong';
      });
    } catch (e) {
      setState(() {
          _loading = false;
          _error = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHANGE PASSWORD',
                style: AppTextStyles.body(11,
                    color: AppColors.yellow,
                    weight: FontWeight.w700,
                    letterSpacing: 3,
                    height: 1)),
            const SizedBox(height: 8),
            Text('Keep your account secure with a strong password.',
                style: AppTextStyles.body(14,
                    color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 32),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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

            if (_success) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 10),
                  Text('Password changed successfully! ✅',
                      style: AppTextStyles.body(13,
                          color: Colors.greenAccent,
                          height: 1)),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            KPasswordField(
              label: 'Current Password *',
              hint: 'Enter your current password',
              controller: _currentCtrl,
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            KPasswordField(
              label: 'New Password *',
              hint: 'Minimum 6 characters',
              controller: _newCtrl,
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            KPasswordField(
              label: 'Confirm New Password *',
              hint: 'Re-enter new password',
              controller: _confirmCtrl,
              validator: (_) => null,
            ),
            const SizedBox(height: 32),

            CalmyaabButton(
              label: _loading
                  ? 'Updating...'
                  : 'Update Password →',
              onTap: _loading ? null : _changePassword,
              width: double.infinity,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}