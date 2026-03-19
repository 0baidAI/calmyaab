import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/student_model.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class ProfileTab extends StatefulWidget {
  final StudentModel? student;
  final VoidCallback onSignOut;
  final VoidCallback? onProfileUpdated;

  const ProfileTab({super.key, this.student, required this.onSignOut, this.onProfileUpdated});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
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
            Tab(text: '👤 My Info'),
            Tab(text: '🔒 Change Password'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _InfoTab(student: widget.student, onSignOut: widget.onSignOut, onProfileUpdated: widget.onProfileUpdated),
            const _ChangePasswordTab(),
          ],
        ),
      ),
    ]);
  }
}

// ── Info Tab ──────────────────────────────────────────────────────────────────
class _InfoTab extends StatefulWidget {
  final StudentModel? student;
  final VoidCallback onSignOut;
  final VoidCallback? onProfileUpdated;
  const _InfoTab({this.student, required this.onSignOut, this.onProfileUpdated});

  @override
  State<_InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<_InfoTab> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _uniCtrl   = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _cityCtrl  = TextEditingController();
  bool _loading    = false;
  bool _saved      = false;
  bool _editing    = false;

  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _nameCtrl.text  = widget.student?.name ?? '';
    _phoneCtrl.text = widget.student?.phone ?? '';
    _uniCtrl.text   = widget.student?.university ?? '';
    _fieldCtrl.text = widget.student?.field ?? '';
    _cityCtrl.text  = widget.student?.city ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _uniCtrl.dispose(); _fieldCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() { _loading = true; _saved = false; });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .update({
      'name':       _nameCtrl.text.trim(),
      'phone':      _phoneCtrl.text.trim(),
      'university': _uniCtrl.text.trim(),
      'field':      _fieldCtrl.text.trim(),
      'city':       _cityCtrl.text.trim(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() { _loading = false; _saved = true; _editing = false; });
    widget.onProfileUpdated?.call();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(child: Column(children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.yellowBorder, width: 3),
                  ),
                  child: Center(child: Text(
                    (_nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text : 'S')
                        .substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontFamily: 'BebasNeue',
                        fontSize: 44, color: AppColors.black, height: 1),
                  )),
                ),
                const SizedBox(height: 12),
                Text(_nameCtrl.text.isNotEmpty
                    ? _nameCtrl.text : 'Student',
                    style: const TextStyle(fontFamily: 'BebasNeue',
                        fontSize: 28, color: AppColors.white, letterSpacing: 1)),
                Text(FirebaseAuth.instance.currentUser?.email ?? '',
                    style: AppTextStyles.body(13,
                        color: AppColors.gray, height: 1.3)),
              ])),
              const SizedBox(height: 36),

              // Success message
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
                    Text('Profile updated successfully! ✅',
                        style: AppTextStyles.body(13,
                            color: Colors.greenAccent, height: 1)),
                  ]),
                ),
                const SizedBox(height: 20),
              ],

              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PERSONAL INFO',
                      style: AppTextStyles.body(11,
                          color: AppColors.yellow,
                          weight: FontWeight.w700,
                          letterSpacing: 3, height: 1)),
                  if (!_editing)
                    GestureDetector(
                      onTap: () => setState(() => _editing = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.yellowDim,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.yellowBorder),
                        ),
                        child: Row(children: [
                          const Icon(Icons.edit_outlined,
                              size: 14, color: AppColors.yellow),
                          const SizedBox(width: 6),
                          Text('Edit Profile',
                              style: AppTextStyles.body(12,
                                  color: AppColors.yellow,
                                  weight: FontWeight.w600, height: 1)),
                        ]),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (!_editing)
                // Read-only view
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.black2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.whiteDim2),
                  ),
                  child: Column(children: [
                    _InfoRow(icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: _nameCtrl.text.isNotEmpty
                            ? _nameCtrl.text : '-'),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _InfoRow(icon: Icons.email_outlined,
                        label: 'Email',
                        value: FirebaseAuth.instance.currentUser?.email ?? '-'),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _InfoRow(icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _phoneCtrl.text.isNotEmpty
                            ? _phoneCtrl.text : '-'),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _InfoRow(icon: Icons.school_outlined,
                        label: 'University',
                        value: _uniCtrl.text.isNotEmpty
                            ? _uniCtrl.text : '-'),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _InfoRow(icon: Icons.book_outlined,
                        label: 'Field of Study',
                        value: _fieldCtrl.text.isNotEmpty
                            ? _fieldCtrl.text : '-'),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _InfoRow(icon: Icons.location_city_outlined,
                        label: 'City',
                        value: _cityCtrl.text.isNotEmpty
                            ? _cityCtrl.text : '-'),
                  ]),
                )
              else
                // Edit form
                Column(children: [
                  KTextField(label: 'Full Name *',
                      hint: 'e.g. Ahmed Khan',
                      controller: _nameCtrl, autofocus: true,
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          size: 18),
                      validator: (_) => null),
                  const SizedBox(height: 14),
                  // Email read-only
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
                      Text('Cannot change',
                          style: AppTextStyles.body(10,
                              color: AppColors.gray2, height: 1)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  KTextField(label: 'Phone Number',
                      hint: '03001234567',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                      validator: (_) => null),
                  const SizedBox(height: 14),
                  KTextField(label: 'University',
                      hint: 'e.g. LUMS, UCP, FAST',
                      controller: _uniCtrl,
                      prefixIcon: const Icon(Icons.school_outlined, size: 18),
                      validator: (_) => null),
                  const SizedBox(height: 14),
                  KTextField(label: 'Field of Study',
                      hint: 'e.g. Computer Science, Business',
                      controller: _fieldCtrl,
                      prefixIcon: const Icon(Icons.book_outlined, size: 18),
                      validator: (_) => null),
                  const SizedBox(height: 14),
                  KTextField(label: 'City',
                      hint: 'e.g. Lahore, Karachi',
                      controller: _cityCtrl,
                      prefixIcon: const Icon(Icons.location_city_outlined,
                          size: 18),
                      validator: (_) => null),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => setState(() => _editing = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray,
                        side: const BorderSide(color: AppColors.whiteDim2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('Cancel', style: AppTextStyles.body(14,
                          color: AppColors.gray, height: 1)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: CalmyaabButton(
                      label: _loading ? 'Saving...' : 'Save Changes →',
                      onTap: _loading ? null : _save,
                      height: 50,
                    )),
                  ]),
                ]),

              const SizedBox(height: 32),

              // Account actions
              Text('ACCOUNT',
                  style: AppTextStyles.body(11, color: AppColors.yellow,
                      weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.whiteDim2),
                ),
                child: Column(children: [
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    onTap: widget.onSignOut,
                    isDestructive: true,
                  ),
                ]),
              ),
              const SizedBox(height: 32),
              Center(child: Text('Calmyaab v1.0.0 · Made in Pakistan 🇵🇰',
                  style: AppTextStyles.body(12,
                      color: AppColors.gray2, height: 1))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Change Password Tab ───────────────────────────────────────────────────────
class _ChangePasswordTab extends StatefulWidget {
  const _ChangePasswordTab();

  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
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
      setState(() => _error = 'New password must be at least 6 characters');
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
        _error = e.code == 'wrong-password' || e.code == 'invalid-credential'
            ? 'Current password is incorrect'
            : e.code == 'requires-recent-login'
                ? 'Please sign out and sign back in before changing your password'
                : e.message ?? 'Error: ${e.code}';
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHANGE PASSWORD',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                    weight: FontWeight.w700, letterSpacing: 3, height: 1)),
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
                  Expanded(child: Text(_error!, style: AppTextStyles.body(13,
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
                      color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                      color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 10),
                  Text('Password changed successfully! ✅',
                      style: AppTextStyles.body(13,
                          color: Colors.greenAccent, height: 1)),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            KPasswordField(label: 'Current Password *',
                hint: 'Enter your current password',
                controller: _currentCtrl, validator: (_) => null),
            const SizedBox(height: 16),
            KPasswordField(label: 'New Password *',
                hint: 'Minimum 6 characters',
                controller: _newCtrl, validator: (_) => null),
            const SizedBox(height: 16),
            KPasswordField(label: 'Confirm New Password *',
                hint: 'Re-enter new password',
                controller: _confirmCtrl, validator: (_) => null),
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

// ── Info Row (read-only) ──────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.gray),
        const SizedBox(width: 16),
        SizedBox(width: 120, child: Text(label,
            style: AppTextStyles.body(13, color: AppColors.gray, height: 1))),
        Expanded(child: Text(value,
            style: AppTextStyles.body(13,
                weight: FontWeight.w600, height: 1))),
      ]),
    );
  }
}

// ── Action Tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({required this.icon, required this.label,
      required this.onTap, this.isDestructive = false});

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? Colors.redAccent : AppColors.white;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovered
              ? (widget.isDestructive
                  ? Colors.redAccent.withOpacity(0.05)
                  : AppColors.whiteDim2)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(children: [
            Icon(widget.icon, size: 18,
                color: _hovered ? color : AppColors.gray),
            const SizedBox(width: 16),
            Expanded(child: Text(widget.label,
                style: AppTextStyles.body(14,
                    color: _hovered ? color : AppColors.white, height: 1))),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.gray),
          ]),
        ),
      ),
    );
  }
}