import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class TeamTab extends ConsumerStatefulWidget {
  final String role;
  const TeamTab({super.key, required this.role});

  @override
  ConsumerState<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends ConsumerState<TeamTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: widget.role == 'super_admin' ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.black2,
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppColors.yellow,
            labelColor: AppColors.yellow,
            unselectedLabelColor: AppColors.gray,
            labelStyle: AppTextStyles.body(13, weight: FontWeight.w600, height: 1),
            tabs: [
              const Tab(text: 'Team Members'),
              if (widget.role == 'super_admin') const Tab(text: 'Send Message'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _TeamMembersView(role: widget.role),
              if (widget.role == 'super_admin') const _SendMessageView(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Team Members View ─────────────────────────────────────────────────────────
class _TeamMembersView extends StatelessWidget {
  final String role;
  const _TeamMembersView({required this.role});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final admins = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TEAM MANAGEMENT',
                        style: AppTextStyles.body(11, color: AppColors.yellow,
                            weight: FontWeight.w700, letterSpacing: 3, height: 1)),
                    const SizedBox(height: 6),
                    Text('${admins.length} admin(s) in your team',
                        style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4)),
                  ]),
                  if (role == 'super_admin')
                    CalmyaabButton(
                      label: '+ Add Admin',
                      onTap: () => showDialog(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.8),
                        builder: (_) => const _AddAdminDialog(),
                      ),
                      height: 42, fontSize: 13,
                    ),
                ],
              ),
              const SizedBox(height: 32),
              _OperationsHeadCard(),
              const SizedBox(height: 20),
              Text('ADMINS',
                  style: AppTextStyles.body(11, color: AppColors.gray,
                      weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              const SizedBox(height: 12),
              admins.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Center(child: Column(children: [
                        const Text('👥', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 12),
                        Text('No admins added yet',
                            style: AppTextStyles.body(14, color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text(
                          role == 'super_admin'
                              ? 'Click "+ Add Admin" to add your first team member'
                              : 'Only Operations Head can add team members',
                          style: AppTextStyles.body(13, color: AppColors.gray2)),
                      ])),
                    )
                  : Column(
                      children: admins.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _AdminCard(
                          data: data, docId: doc.id,
                          canRemove: role == 'super_admin',
                        );
                      }).toList(),
                    ),
              if (role == 'admin') ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.yellowDim,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.yellowBorder),
                  ),
                  child: Row(children: [
                    const Icon(Icons.lock_outline_rounded, color: AppColors.yellow, size: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Only the Operations Head can add or remove team members.',
                      style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.5),
                    )),
                  ]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Operations Head Card ──────────────────────────────────────────────────────
class _OperationsHeadCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.black3,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.yellowDim,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.yellow),
              ),
              child: Center(
                child: Text(
                  (data?['name'] ?? 'R').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 22,
                    color: AppColors.yellow, height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data?['name'] ?? 'Rana Obaid Ur Rehman',
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(data?['email'] ?? '',
                      style: AppTextStyles.body(13,
                          color: AppColors.gray, height: 1)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('OPS HEAD',
                  style: AppTextStyles.body(10,
                      color: AppColors.black,
                      weight: FontWeight.w700,
                      letterSpacing: 1,
                      height: 1)),
            ),
            const SizedBox(width: 10),
            Text('You',
                style: AppTextStyles.body(12,
                    color: AppColors.yellow,
                    weight: FontWeight.w600,
                    height: 1)),
          ]),
        );
      },
    );
  }
}

// ── Admin Card ────────────────────────────────────────────────────────────────
class _AdminCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  final bool canRemove;
  const _AdminCard({required this.data, required this.docId, required this.canRemove});

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard> {
  bool _hovered = false;

  Future<void> _deleteAdmin(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: Text('Delete Admin?', style: AppTextStyles.body(16, weight: FontWeight.w700)),
        content: Text(
          'This will permanently delete ${widget.data['name']}\'s account. They will lose all access.',
          style: AppTextStyles.body(14, color: AppColors.gray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppTextStyles.body(14, color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Delete Permanently',
                  style: AppTextStyles.body(14, color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(widget.docId).delete();
      await FirebaseFirestore.instance
          .collection('admin_messages')
          .where('to_uid', isEqualTo: widget.docId)
          .get()
          .then((snap) { for (final doc in snap.docs) { doc.reference.delete(); } });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _hovered ? AppColors.yellowBorder : AppColors.whiteDim2),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.yellowDim, shape: BoxShape.circle,
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Center(child: Text(
              (widget.data['name'] ?? 'A').substring(0, 1).toUpperCase(),
              style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 20,
                  color: AppColors.yellow, height: 1),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.data['name'] ?? '-',
                style: AppTextStyles.body(15, weight: FontWeight.w700, height: 1.2)),
            Text(widget.data['email'] ?? '-',
                style: AppTextStyles.body(13, color: AppColors.gray, height: 1.2)),
            if (widget.data['phone'] != null && widget.data['phone'] != '')
              Text(widget.data['phone'],
                  style: AppTextStyles.body(12, color: AppColors.gray2, height: 1.3)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Text('ADMIN', style: AppTextStyles.body(10, color: Colors.redAccent,
                weight: FontWeight.w700, letterSpacing: 1, height: 1)),
          ),
          if (widget.canRemove) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteAdmin(context),
              tooltip: 'Delete admin permanently',
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Send Message View ─────────────────────────────────────────────────────────
class _SendMessageView extends StatefulWidget {
  const _SendMessageView();

  @override
  State<_SendMessageView> createState() => _SendMessageViewState();
}

class _SendMessageViewState extends State<_SendMessageView> {
  final _titleCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _target     = 'all';
  String _targetName = 'All Admins';
  bool _sending      = false;
  bool _sent         = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) return;
    setState(() => _sending = true);

    await FirebaseFirestore.instance.collection('admin_messages').add({
      'title':      _titleCtrl.text.trim(),
      'message':    _messageCtrl.text.trim(),
      'to':         _target,
      'to_name':    _targetName,
      'from_uid':   FirebaseAuth.instance.currentUser?.uid,
      'from_name':  'Operations Head',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'read':       false,
    });

    setState(() { _sending = false; _sent = true; });
    _titleCtrl.clear();
    _messageCtrl.clear();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SEND MESSAGE TO TEAM',
                  style: AppTextStyles.body(11, color: AppColors.yellow,
                      weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.black2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_sent) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 10),
                        Text('Message sent successfully! ✅',
                            style: AppTextStyles.body(13, color: Colors.greenAccent, height: 1)),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text('SEND TO', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _AdminDropdown(
                    value: _target,
                    onChanged: (uid, name) => setState(() { _target = uid; _targetName = name; }),
                  ),
                  const SizedBox(height: 20),
                  Text('TITLE', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    style: AppTextStyles.body(14, color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. Important Update',
                      hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
                      filled: true, fillColor: AppColors.black3,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.whiteDim2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.whiteDim2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('MESSAGE', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageCtrl,
                    maxLines: 5,
                    style: AppTextStyles.body(14, color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
                      filled: true, fillColor: AppColors.black3,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.whiteDim2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.whiteDim2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CalmyaabButton(
                    label: _sending ? 'Sending...' : 'Send Message →',
                    onTap: _sending ? null : _send,
                    width: double.infinity, height: 50,
                  ),
                ]),
              ),
            ],
          )),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SENT MESSAGES',
                  style: AppTextStyles.body(11, color: AppColors.yellow,
                      weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admin_messages')
                    .orderBy('created_at', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Center(child: Text('No messages sent yet',
                          style: AppTextStyles.body(13, color: AppColors.gray))),
                    );
                  }
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return _SentMessageCard(data: data);
                    }).toList(),
                  );
                },
              ),
            ],
          )),
        ],
      ),
    );
  }
}

// ── Admin Dropdown ────────────────────────────────────────────────────────────
class _AdminDropdown extends StatelessWidget {
  final String value;
  final Function(String uid, String name) onChanged;
  const _AdminDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .snapshots(),
      builder: (context, snapshot) {
        final admins = snapshot.data?.docs ?? [];
        final items = <DropdownMenuItem<String>>[
          const DropdownMenuItem(value: 'all', child: Text('📢 All Admins')),
          ...admins.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DropdownMenuItem(value: doc.id, child: Text('👤 ${data['name'] ?? 'Admin'}'));
          }),
        ];
        final validValue = items.any((i) => i.value == value) ? value : 'all';
        return DropdownButtonFormField<String>(
          value: validValue,
          onChanged: (v) {
            if (v == 'all') {
              onChanged('all', 'All Admins');
            } else {
              final doc = admins.firstWhere((d) => d.id == v, orElse: () => admins.first);
              final data = doc.data() as Map<String, dynamic>;
              onChanged(v!, data['name'] ?? 'Admin');
            }
          },
          dropdownColor: AppColors.black3,
          style: AppTextStyles.body(14, color: AppColors.white),
          decoration: InputDecoration(
            filled: true, fillColor: AppColors.black3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.whiteDim2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.whiteDim2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items,
        );
      },
    );
  }
}

// ── Sent Message Card ─────────────────────────────────────────────────────────
class _SentMessageCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SentMessageCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final ts = data['created_at'] as int?;
    final date = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(data['title'] ?? '',
              style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1.2))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.yellowDim,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Text(data['to_name'] ?? 'All',
                style: AppTextStyles.body(10, color: AppColors.yellow,
                    weight: FontWeight.w600, height: 1)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(data['message'] ?? '',
            style: AppTextStyles.body(12, color: AppColors.gray, height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text('${date.day}/${date.month}/${date.year}',
            style: AppTextStyles.body(11, color: AppColors.gray2, height: 1)),
      ]),
    );
  }
}

// ── Add Admin Dialog ──────────────────────────────────────────────────────────
class _AddAdminDialog extends ConsumerStatefulWidget {
  const _AddAdminDialog();

  @override
  ConsumerState<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends ConsumerState<_AddAdminDialog> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _opsPassCtrl = TextEditingController(); // Operations Head's own password
  bool _loading      = false;
  String? _error;
  bool _success      = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _phoneCtrl.dispose();
    _opsPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty || _opsPassCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all required fields');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'New admin password must be at least 6 characters');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      // Save current Operations Head info before creating new user
      final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      final opsPassword  = _opsPassCtrl.text;

      // Create new admin account (this signs you out automatically)
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // Save new admin to Firestore
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name':          _nameCtrl.text.trim(),
        'email':         _emailCtrl.text.trim(),
        'phone':         _phoneCtrl.text.trim(),
        'university':    'Calmyaab',
        'field':         'Admin',
        'role':          'admin',
        'paid_services': [],
        'created_at':    DateTime.now().millisecondsSinceEpoch,
      });

      // Sign out new admin
      await FirebaseAuth.instance.signOut();

      // Sign back in as Operations Head automatically ✅
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: currentEmail,
        password: opsPassword,
      );

      setState(() { _loading = false; _success = true; });

    } on FirebaseAuthException catch (e) {
      // Sign back in as ops head if something failed
      setState(() {
        _loading = false;
        if (e.code == 'email-already-in-use') {
          _error = 'This email is already registered!';
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _error = 'Your password is incorrect. Admin was created but you were signed out. Please login again.';
        } else {
          _error = e.message ?? 'Something went wrong';
        }
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Something went wrong. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: _success
            ? _SuccessState(
                name: _nameCtrl.text,
                email: _emailCtrl.text,
                onClose: () => Navigator.pop(context),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('ADD ADMIN',
                          style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28,
                              color: AppColors.yellow, letterSpacing: 1)),
                      const Spacer(),
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('✕', style: AppTextStyles.body(16, color: AppColors.gray))),
                    ]),
                    const SizedBox(height: 8),
                    Text('Create a new admin account for your team member.',
                        style: AppTextStyles.body(13, color: AppColors.gray, height: 1.5)),
                    const SizedBox(height: 24),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Text(_error!,
                            style: AppTextStyles.body(13, color: Colors.redAccent, height: 1.4)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New admin details
                    Text('NEW ADMIN DETAILS',
                        style: AppTextStyles.body(10, color: AppColors.gray,
                            weight: FontWeight.w700, letterSpacing: 2, height: 1)),
                    const SizedBox(height: 12),
                    KTextField(label: 'Full Name *', hint: 'e.g. Ahmed Khan',
                        controller: _nameCtrl, autofocus: true,
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                        validator: (_) => null),
                    const SizedBox(height: 14),
                    KTextField(label: 'Email Address *', hint: 'admin@example.com',
                        controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        validator: (_) => null),
                    const SizedBox(height: 14),
                    KTextField(label: 'Phone Number', hint: '03001234567',
                        controller: _phoneCtrl, keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                        validator: (_) => null),
                    const SizedBox(height: 14),
                    KPasswordField(label: 'Admin Password *', hint: 'Minimum 6 characters',
                        controller: _passCtrl, validator: (_) => null),
                    const SizedBox(height: 24),

                    // Divider
                    const Divider(color: AppColors.whiteDim2, height: 1),
                    const SizedBox(height: 20),

                    // Operations head confirmation
                    Text('YOUR CONFIRMATION',
                        style: AppTextStyles.body(10, color: AppColors.gray,
                            weight: FontWeight.w700, letterSpacing: 2, height: 1)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.lock_outline_rounded,
                            color: Colors.purpleAccent, size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          'Enter your own password to stay logged in after creating the admin.',
                          style: AppTextStyles.body(12,
                              color: Colors.purpleAccent, height: 1.4),
                        )),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    KPasswordField(
                      label: 'Your Password *',
                      hint: 'Enter your own admin password',
                      controller: _opsPassCtrl,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 24),
                    CalmyaabButton(
                      label: _loading ? 'Creating...' : 'Create Admin Account →',
                      onTap: _loading ? null : _createAdmin,
                      width: double.infinity, height: 50,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Success State ─────────────────────────────────────────────────────────────
class _SuccessState extends StatelessWidget {
  final String name, email;
  final VoidCallback onClose;

  const _SuccessState({required this.name, required this.email, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.yellowDim, shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          child: const Center(child: Text('✅', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 20),
        const Text('ADMIN CREATED!',
            style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28,
                color: AppColors.yellow, letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(
          '$name has been added as admin.\nEmail: $email',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(14, color: AppColors.gray, height: 1.6),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: Text(
            '✅ You are still logged in as Operations Head!',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(12, color: Colors.greenAccent, height: 1.5),
          ),
        ),
        const SizedBox(height: 24),
        CalmyaabButton(
          label: 'Done ✅',
          onTap: onClose,
          width: double.infinity, height: 48,
        ),
      ],
    );
  }
}