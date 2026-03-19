import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class StudyAbroadTab extends StatefulWidget {
  final String role;
  const StudyAbroadTab({super.key, required this.role});

  @override
  State<StudyAbroadTab> createState() => _StudyAbroadTabState();
}

class _StudyAbroadTabState extends State<StudyAbroadTab>
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
            Tab(text: '🏢 Agencies'),
            Tab(text: '📅 Bookings'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _AgenciesView(role: widget.role),
            _BookingsView(),
          ],
        ),
      ),
    ]);
  }
}

// ── Agencies View ─────────────────────────────────────────────────────────────
class _AgenciesView extends StatelessWidget {
  final String role;
  const _AgenciesView({required this.role});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agencies')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final agencies = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AFFILIATED AGENCIES',
                        style: AppTextStyles.body(11, color: AppColors.yellow,
                            weight: FontWeight.w700, letterSpacing: 3, height: 1)),
                    const SizedBox(height: 6),
                    Text('${agencies.length} agenc(ies)',
                        style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4)),
                  ]),
                  if (role == 'super_admin')
                    CalmyaabButton(
                      label: '+ Add Agency',
                      onTap: () => showDialog(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.8),
                        builder: (_) => const _AddAgencyDialog(),
                      ),
                      height: 42, fontSize: 13,
                    ),
                ],
              ),
              const SizedBox(height: 32),

              agencies.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Column(children: [
                        const Text('🌍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No agencies added yet',
                            style: AppTextStyles.body(16, color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text(
                          role == 'super_admin'
                              ? 'Click "+ Add Agency" to add your first partner agency'
                              : 'Operations Head will add agencies soon',
                          style: AppTextStyles.body(13, color: AppColors.gray2),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                    )
                  : Column(
                      children: agencies.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _AgencyCard(data: data, docId: doc.id, role: role);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}

// ── Agency Card ───────────────────────────────────────────────────────────────
class _AgencyCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId, role;
  const _AgencyCard({required this.data, required this.docId, required this.role});

  @override
  State<_AgencyCard> createState() => _AgencyCardState();
}

class _AgencyCardState extends State<_AgencyCard> {
  bool _expanded = false;
  bool _hovered  = false;

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: Text('Delete Agency?', style: AppTextStyles.body(16, weight: FontWeight.w700)),
        content: Text('This will delete the agency and all its consultants.',
            style: AppTextStyles.body(14, color: AppColors.gray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppTextStyles.body(14, color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: AppTextStyles.body(14, color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('agencies').doc(widget.docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final days = List<String>.from(data['working_days'] ?? []);
    final type = data['consultation_type'] ?? 'both';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? AppColors.yellowBorder : AppColors.whiteDim2),
        ),
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.yellowDim,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.yellowBorder),
                  ),
                  child: Center(child: Text(
                    (data['name'] ?? 'A').substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontFamily: 'BebasNeue',
                        fontSize: 24, color: AppColors.yellow, height: 1),
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? '',
                        style: AppTextStyles.body(16, weight: FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.gray2),
                      const SizedBox(width: 4),
                      Text(data['location'] ?? '',
                          style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule_outlined, size: 13, color: AppColors.gray2),
                      const SizedBox(width: 4),
                      Text('${data['office_hours_start'] ?? '9:00 AM'} - ${data['office_hours_end'] ?? '5:00 PM'}',
                          style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.yellowDim,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.yellowBorder),
                      ),
                      child: Text(
                        type == 'online' ? '💻 Online'
                            : type == 'in-person' ? '🏢 In-Person'
                            : '💻🏢 Online & In-Person',
                        style: AppTextStyles.body(10, color: AppColors.yellow,
                            weight: FontWeight.w600, height: 1),
                      ),
                    ),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('agencies').doc(widget.docId)
                        .collection('consultants').snapshots(),
                    builder: (context, snap) {
                      final count = snap.data?.docs.length ?? 0;
                      return Text('$count consultant(s)',
                          style: AppTextStyles.body(12, color: AppColors.gray, height: 1));
                    },
                  ),
                  const SizedBox(height: 8),
                  if (widget.role == 'super_admin')
                    GestureDetector(
                      onTap: () => _delete(context),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 18),
                    ),
                ]),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray, size: 20),
                ),
              ]),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.whiteDim2),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WORKING DAYS', style: AppTextStyles.body(10, color: AppColors.gray,
                      weight: FontWeight.w700, letterSpacing: 2, height: 1)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8,
                    children: days.map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.yellowDim,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.yellowBorder),
                      ),
                      child: Text(d, style: AppTextStyles.body(11, color: AppColors.yellow,
                          weight: FontWeight.w600, height: 1)),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (data['about']?.isNotEmpty == true) ...[
                    Text('ABOUT', style: AppTextStyles.body(10, color: AppColors.gray,
                        weight: FontWeight.w700, letterSpacing: 2, height: 1)),
                    const SizedBox(height: 8),
                    Text(data['about'], style: AppTextStyles.body(13,
                        color: AppColors.white, height: 1.6)),
                    const SizedBox(height: 20),
                  ],

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('CONSULTANTS', style: AppTextStyles.body(10, color: AppColors.gray,
                        weight: FontWeight.w700, letterSpacing: 2, height: 1)),
                    if (widget.role == 'super_admin')
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.8),
                          builder: (_) => _AddConsultantDialog(agencyId: widget.docId),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.yellowDim,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.yellowBorder),
                          ),
                          child: Text('+ Add Consultant', style: AppTextStyles.body(11,
                              color: AppColors.yellow, weight: FontWeight.w600, height: 1)),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('agencies').doc(widget.docId)
                        .collection('consultants').snapshots(),
                    builder: (context, snap) {
                      final consultants = snap.data?.docs ?? [];
                      if (consultants.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.black3,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.whiteDim2),
                          ),
                          child: Center(child: Text(
                            widget.role == 'super_admin'
                                ? 'No consultants yet. Click "+ Add Consultant"'
                                : 'No consultants added yet',
                            style: AppTextStyles.body(13, color: AppColors.gray),
                            textAlign: TextAlign.center,
                          )),
                        );
                      }
                      return Column(
                        children: consultants.map((c) {
                          final cd = c.data() as Map<String, dynamic>;
                          return _ConsultantTile(
                              data: cd, docId: c.id,
                              agencyId: widget.docId, role: widget.role);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Consultant Tile ───────────────────────────────────────────────────────────
class _ConsultantTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId, agencyId, role;
  const _ConsultantTile({required this.data, required this.docId,
      required this.agencyId, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.black3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.yellowDim, shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Center(child: Text(
            (data['name'] ?? 'C').substring(0, 1).toUpperCase(),
            style: const TextStyle(fontFamily: 'BebasNeue',
                fontSize: 16, color: AppColors.yellow, height: 1),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'] ?? '', style: AppTextStyles.body(14,
                weight: FontWeight.w600, height: 1.2)),
            Text(data['specialization'] ?? '', style: AppTextStyles.body(12,
                color: AppColors.yellow, height: 1.2)),
            if (data['zoom_link']?.isNotEmpty == true)
              Text('💻 Online available', style: AppTextStyles.body(11,
                  color: AppColors.gray, height: 1.2)),
          ],
        )),
        if (role == 'super_admin')
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 18),
            onPressed: () => FirebaseFirestore.instance
                .collection('agencies').doc(agencyId)
                .collection('consultants').doc(docId).delete(),
            tooltip: 'Remove consultant',
          ),
      ]),
    );
  }
}

// ── Add Agency Dialog ─────────────────────────────────────────────────────────
class _AddAgencyDialog extends StatefulWidget {
  const _AddAgencyDialog();

  @override
  State<_AddAgencyDialog> createState() => _AddAgencyDialogState();
}

class _AddAgencyDialogState extends State<_AddAgencyDialog> {
  final _nameCtrl      = TextEditingController();
  final _locationCtrl  = TextEditingController();
  final _aboutCtrl     = TextEditingController();
  final _startCtrl     = TextEditingController(text: '9:00 AM');
  final _endCtrl       = TextEditingController(text: '5:00 PM');
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _opsPassCtrl   = TextEditingController();
  String _type         = 'both';
  List<String> _selectedDays = [];
  bool _loading        = false;
  String? _error;

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _locationCtrl.dispose();
    _aboutCtrl.dispose(); _startCtrl.dispose();
    _endCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _opsPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _locationCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty ||
        _opsPassCtrl.text.isEmpty || _selectedDays.isEmpty) {
      setState(() => _error = 'Please fill all required fields and select working days');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Agency password must be at least 6 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      await FirebaseFirestore.instance
          .collection('agencies')
          .doc(cred.user!.uid)
          .set({
        'name':               _nameCtrl.text.trim(),
        'email':              _emailCtrl.text.trim(),
        'location':           _locationCtrl.text.trim(),
        'about':              _aboutCtrl.text.trim(),
        'working_days':       _selectedDays,
        'office_hours_start': _startCtrl.text.trim(),
        'office_hours_end':   _endCtrl.text.trim(),
        'consultation_type':  _type,
        'created_at':         DateTime.now().millisecondsSinceEpoch,
      });

      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: currentEmail,
        password: _opsPassCtrl.text,
      );

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.code == 'email-already-in-use'
            ? 'This email is already registered!'
            : e.code == 'wrong-password' || e.code == 'invalid-credential'
                ? 'Your password is incorrect'
                : e.message ?? 'Something went wrong';
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Something went wrong'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('ADD AGENCY',
                    style: TextStyle(fontFamily: 'BebasNeue',
                        fontSize: 28, color: AppColors.yellow, letterSpacing: 1)),
                const Spacer(),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('✕', style: AppTextStyles.body(16, color: AppColors.gray))),
              ]),
              const SizedBox(height: 24),

              KTextField(label: 'Agency Name *', hint: 'e.g. Global Study Consultants',
                  controller: _nameCtrl, autofocus: true,
                  prefixIcon: const Icon(Icons.business_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),
              KTextField(label: 'Location *', hint: 'e.g. Lahore, Pakistan',
                  controller: _locationCtrl,
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),

              Row(children: [
                Expanded(child: KTextField(label: 'Opens At *', hint: '9:00 AM',
                    controller: _startCtrl,
                    prefixIcon: const Icon(Icons.schedule_outlined, size: 18),
                    validator: (_) => null)),
                const SizedBox(width: 12),
                Expanded(child: KTextField(label: 'Closes At *', hint: '5:00 PM',
                    controller: _endCtrl,
                    prefixIcon: const Icon(Icons.schedule_outlined, size: 18),
                    validator: (_) => null)),
              ]),
              const SizedBox(height: 14),

              Text('CONSULTATION TYPE', style: AppTextStyles.label),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                onChanged: (v) => setState(() => _type = v!),
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
                items: const [
                  DropdownMenuItem(value: 'online', child: Text('💻 Online Only')),
                  DropdownMenuItem(value: 'in-person', child: Text('🏢 In-Person Only')),
                  DropdownMenuItem(value: 'both', child: Text('💻🏢 Both')),
                ],
              ),
              const SizedBox(height: 14),

              Text('WORKING DAYS *', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _days.map((d) {
                  final selected = _selectedDays.contains(d);
                  return GestureDetector(
                    onTap: () => setState(() => selected
                        ? _selectedDays.remove(d) : _selectedDays.add(d)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.yellow : AppColors.black3,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: selected ? AppColors.yellow : AppColors.whiteDim2),
                      ),
                      child: Text(d, style: AppTextStyles.body(12,
                          color: selected ? AppColors.black : AppColors.gray,
                          weight: selected ? FontWeight.w700 : FontWeight.w400,
                          height: 1)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              Text('ABOUT AGENCY (optional)', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: _aboutCtrl, maxLines: 3,
                style: AppTextStyles.body(14, color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Brief description of the agency...',
                  hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
                  filled: true, fillColor: AppColors.black3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              const Divider(color: AppColors.whiteDim2, height: 1),
              const SizedBox(height: 16),
              Text('AGENCY LOGIN CREDENTIALS',
                  style: AppTextStyles.body(10, color: AppColors.gray,
                      weight: FontWeight.w700, letterSpacing: 2, height: 1)),
              const SizedBox(height: 4),
              Text('Agency will use these to login at /agency-login',
                  style: AppTextStyles.body(12, color: AppColors.gray2, height: 1.4)),
              const SizedBox(height: 12),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: AppTextStyles.body(13,
                      color: Colors.redAccent, height: 1.4)),
                ),
                const SizedBox(height: 12),
              ],

              KTextField(label: 'Agency Email *', hint: 'agency@example.com',
                  controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 12),
              KPasswordField(label: 'Agency Password *', hint: 'Minimum 6 characters',
                  controller: _passCtrl, validator: (_) => null),
              const SizedBox(height: 20),

              const Divider(color: AppColors.whiteDim2, height: 1),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.yellow, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Enter your password to stay logged in after creating the agency.',
                    style: AppTextStyles.body(12, color: AppColors.yellow, height: 1.4),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              KPasswordField(label: 'Your Password *',
                  hint: 'Enter your own admin password',
                  controller: _opsPassCtrl, validator: (_) => null),
              const SizedBox(height: 24),

              CalmyaabButton(
                label: _loading ? 'Creating...' : 'Create Agency →',
                onTap: _loading ? null : _save,
                width: double.infinity, height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add Consultant Dialog ─────────────────────────────────────────────────────
class _AddConsultantDialog extends StatefulWidget {
  final String agencyId;
  const _AddConsultantDialog({required this.agencyId});

  @override
  State<_AddConsultantDialog> createState() => _AddConsultantDialogState();
}

class _AddConsultantDialogState extends State<_AddConsultantDialog> {
  final _nameCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _zoomCtrl = TextEditingController();
  bool _loading   = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _specCtrl.dispose(); _zoomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _specCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await FirebaseFirestore.instance
        .collection('agencies').doc(widget.agencyId)
        .collection('consultants').add({
      'name':           _nameCtrl.text.trim(),
      'specialization': _specCtrl.text.trim(),
      'zoom_link':      _zoomCtrl.text.trim(),
      'created_at':     DateTime.now().millisecondsSinceEpoch,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('ADD CONSULTANT',
                  style: TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 28, color: AppColors.yellow, letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕', style: AppTextStyles.body(16, color: AppColors.gray))),
            ]),
            const SizedBox(height: 24),
            KTextField(label: 'Full Name *', hint: 'e.g. Ahmed Khan',
                controller: _nameCtrl, autofocus: true,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                validator: (_) => null),
            const SizedBox(height: 14),
            KTextField(label: 'Specialization *', hint: 'e.g. UK/Canada Admissions',
                controller: _specCtrl,
                prefixIcon: const Icon(Icons.school_outlined, size: 18),
                validator: (_) => null),
            const SizedBox(height: 14),
            KTextField(label: 'Zoom Link (for online sessions)',
                hint: 'https://zoom.us/j/...',
                controller: _zoomCtrl,
                prefixIcon: const Icon(Icons.videocam_outlined, size: 18),
                validator: (_) => null),
            const SizedBox(height: 24),
            CalmyaabButton(
              label: _loading ? 'Adding...' : 'Add Consultant →',
              onTap: _loading ? null : _save,
              width: double.infinity, height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bookings View (read-only for admin) ───────────────────────────────────────
class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
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
          labelStyle: AppTextStyles.body(12, weight: FontWeight.w600, height: 1),
          tabs: const [
            Tab(text: '⏳ Pending'),
            Tab(text: '✅ Confirmed'),
            Tab(text: '🏁 Completed'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _BookingsList(status: 'pending'),
            _BookingsList(status: 'confirmed'),
            _BookingsList(status: 'completed'),
          ],
        ),
      ),
    ]);
  }
}

class _BookingsList extends StatelessWidget {
  final String status;
  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('study_abroad_bookings')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final bookings = snapshot.data?.docs ?? [];

        if (bookings.isEmpty) {
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status == 'pending' ? '⏳' : status == 'confirmed' ? '✅' : '🏁',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('No $status bookings', style: AppTextStyles.body(16, color: AppColors.gray)),
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: bookings.length,
          itemBuilder: (_, i) {
            final data = bookings[i].data() as Map<String, dynamic>;
            return _BookingCard(data: data);
          },
        );
      },
    );
  }
}

// Read-only booking card for admin
class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _BookingCard({required this.data});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ts = widget.data['created_at'] as int?;
    final date = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.yellowDim, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Center(child: Text(
                  (widget.data['student_name'] ?? 'S').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 20, color: AppColors.yellow, height: 1),
                )),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data['student_name'] ?? '',
                      style: AppTextStyles.body(15, weight: FontWeight.w700, height: 1.2)),
                  Text(widget.data['agency_name'] ?? '',
                      style: AppTextStyles.body(12, color: AppColors.yellow, height: 1.2)),
                  Text(
                    '${widget.data['preferred_day']} · ${widget.data['preferred_time_from']} - ${widget.data['preferred_time_to']}',
                    style: AppTextStyles.body(12, color: AppColors.gray, height: 1.2),
                  ),
                  Text('${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.body(11, color: AppColors.gray2, height: 1.2)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Text(
                  widget.data['consultation_type'] == 'online' ? '💻 Online' : '🏢 In-Person',
                  style: AppTextStyles.body(10, color: AppColors.yellow,
                      weight: FontWeight.w600, height: 1),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray, size: 20),
              ),
            ]),
          ),
        ),

        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.whiteDim2),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.data['message']?.isNotEmpty == true) ...[
                  Text('STUDENT MESSAGE', style: AppTextStyles.body(10, color: AppColors.gray,
                      weight: FontWeight.w700, letterSpacing: 2, height: 1)),
                  const SizedBox(height: 8),
                  Text(widget.data['message'], style: AppTextStyles.body(13,
                      color: AppColors.white, height: 1.6)),
                ],
                if (widget.data['confirmed_time']?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.schedule_outlined, size: 14, color: Colors.greenAccent),
                      const SizedBox(width: 6),
                      Text('Confirmed: ${widget.data['confirmed_time']}',
                          style: AppTextStyles.body(13, color: Colors.greenAccent,
                              weight: FontWeight.w600, height: 1)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ]),
    );
  }
}