import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class AgencyProfileTab extends StatefulWidget {
  final String agencyId;
  const AgencyProfileTab({super.key, required this.agencyId});

  @override
  State<AgencyProfileTab> createState() => _AgencyProfileTabState();
}

class _AgencyProfileTabState extends State<AgencyProfileTab>
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
            Tab(text: '🏢 Agency Info'),
            Tab(text: '🔒 Change Password'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _AgencyInfoTab(agencyId: widget.agencyId),
            const _ChangePasswordTab(),
          ],
        ),
      ),
    ]);
  }
}

class _AgencyInfoTab extends StatefulWidget {
  final String agencyId;
  const _AgencyInfoTab({required this.agencyId});

  @override
  State<_AgencyInfoTab> createState() => _AgencyInfoTabState();
}

class _AgencyInfoTabState extends State<_AgencyInfoTab> {
  final _nameCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _aboutCtrl    = TextEditingController();
  bool _loading       = false;
  bool _saved         = false;
  bool _fetched       = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('agencies')
        .doc(widget.agencyId)
        .get();
    if (!mounted) return;
    final data = doc.data() ?? {};
    setState(() {
      _nameCtrl.text     = data['name'] ?? '';
      _locationCtrl.text = data['location'] ?? '';
      _aboutCtrl.text    = data['about'] ?? '';
      _fetched           = true;
    });
  }

  Future<void> _save() async {
    setState(() { _loading = true; _saved = false; });
    await FirebaseFirestore.instance
        .collection('agencies')
        .doc(widget.agencyId)
        .update({
      'name':       _nameCtrl.text.trim(),
      'location':   _locationCtrl.text.trim(),
      'about':      _aboutCtrl.text.trim(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
    setState(() { _loading = false; _saved = true; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_fetched) {
      return const Center(child: CircularProgressIndicator(
          color: AppColors.yellow));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AGENCY INFORMATION',
                style: AppTextStyles.body(11,
                    color: AppColors.yellow,
                    weight: FontWeight.w700,
                    letterSpacing: 3, height: 1)),
            const SizedBox(height: 8),
            Text('Update your agency details visible to students.',
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
                  Text('Agency info updated! ✅',
                      style: AppTextStyles.body(13,
                          color: Colors.greenAccent, height: 1)),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            KTextField(label: 'Agency Name *',
                hint: 'e.g. Global Study Consultants',
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.business_outlined,
                    size: 18),
                validator: (_) => null),
            const SizedBox(height: 16),
            KTextField(label: 'Location',
                hint: 'e.g. Lahore, Pakistan',
                controller: _locationCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined,
                    size: 18),
                validator: (_) => null),
            const SizedBox(height: 16),
            Text('ABOUT AGENCY', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _aboutCtrl,
              maxLines: 4,
              style: AppTextStyles.body(14, color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Describe your agency...',
                hintStyle: AppTextStyles.body(14,
                    color: AppColors.gray2),
                filled: true, fillColor: AppColors.black3,
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
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 32),
            CalmyaabButton(
              label: _loading ? 'Saving...' : 'Save Changes →',
              onTap: _loading ? null : _save,
              width: double.infinity, height: 52,
            ),
          ],
        ),
      ),
    );
  }
}

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

  Future<void> _change() async {
    setState(() { _error = null; _success = false; });
    if (_currentCtrl.text.isEmpty || _newCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    if (_newCtrl.text.length < 6) {
      setState(() => _error = 'Minimum 6 characters');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: _currentCtrl.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);
      _currentCtrl.clear(); _newCtrl.clear(); _confirmCtrl.clear();
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
                    letterSpacing: 3, height: 1)),
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
                child: Text(_error!, style: AppTextStyles.body(13,
                    color: Colors.redAccent, height: 1.4)),
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
                      color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Text('Password changed! ✅',
                    style: AppTextStyles.body(13,
                        color: Colors.greenAccent, height: 1)),
              ),
              const SizedBox(height: 20),
            ],

            KPasswordField(label: 'Current Password *',
                hint: 'Enter current password',
                controller: _currentCtrl,
                validator: (_) => null),
            const SizedBox(height: 16),
            KPasswordField(label: 'New Password *',
                hint: 'Minimum 6 characters',
                controller: _newCtrl,
                validator: (_) => null),
            const SizedBox(height: 16),
            KPasswordField(label: 'Confirm New Password *',
                hint: 'Re-enter new password',
                controller: _confirmCtrl,
                validator: (_) => null),
            const SizedBox(height: 32),
            CalmyaabButton(
              label: _loading ? 'Updating...' : 'Update Password →',
              onTap: _loading ? null : _change,
              width: double.infinity, height: 52,
            ),
          ],
        ),
      ),
    );
  }
}