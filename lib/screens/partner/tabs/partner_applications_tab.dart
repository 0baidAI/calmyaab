import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class PartnerApplicationsTab extends StatefulWidget {
  final String partnerUid;
  const PartnerApplicationsTab({super.key, required this.partnerUid});

  @override
  State<PartnerApplicationsTab> createState() =>
      _PartnerApplicationsTabState();
}

class _PartnerApplicationsTabState
    extends State<PartnerApplicationsTab> {
  String _selectedInternshipId = 'all';
  String _selectedInternshipTitle = 'All Internships';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Left: Internships filter list ──────────────────────────────
        Container(
          width: 220,
          decoration: const BoxDecoration(
            color: AppColors.black2,
            border: Border(
                right: BorderSide(color: AppColors.whiteDim2)),
          ),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.whiteDim2)),
              ),
              child: Text('INTERNSHIPS',
                  style: AppTextStyles.body(11,
                      color: AppColors.yellow,
                      weight: FontWeight.w700,
                      letterSpacing: 3,
                      height: 1)),
            ),

            // All internships option
            _InternshipFilterTile(
              title: 'All Internships',
              isSelected: _selectedInternshipId == 'all',
              partnerUid: widget.partnerUid,
              internshipId: 'all',
              onTap: () => setState(() {
                _selectedInternshipId = 'all';
                _selectedInternshipTitle = 'All Internships';
              }),
            ),

            // Per internship tiles
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('internships')
                    .where('partner_uid',
                        isEqualTo: widget.partnerUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final internships = snapshot.data?.docs ?? [];
                  if (internships.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No internships posted yet',
                          style: AppTextStyles.body(12,
                              color: AppColors.gray2,
                              height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView(
                    children: internships.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;
                      return _InternshipFilterTile(
                        title: data['title'] ?? '',
                        isSelected:
                            _selectedInternshipId == doc.id,
                        partnerUid: widget.partnerUid,
                        internshipId: doc.id,
                        onTap: () => setState(() {
                          _selectedInternshipId = doc.id;
                          _selectedInternshipTitle =
                              data['title'] ?? '';
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ]),
        ),

        // ── Right: Applications list ────────────────────────────────────
        Expanded(
          child: Column(children: [
            // Top bar with filter
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.black2,
                border: Border(
                    bottom: BorderSide(color: AppColors.whiteDim2)),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(_selectedInternshipTitle,
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700, height: 1)),
                ),
                // Status filter
                ...[
                  'all', 'pending', 'accepted', 'rejected'
                ].map((s) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _filterStatus = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filterStatus == s
                            ? _statusColor(s)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _filterStatus == s
                              ? _statusColor(s)
                              : AppColors.whiteDim2,
                        ),
                      ),
                      child: Text(
                        s == 'all' ? 'All' : _capitalize(s),
                        style: AppTextStyles.body(11,
                            color: _filterStatus == s
                                ? (_statusColor(s) ==
                                        AppColors.yellow
                                    ? AppColors.black
                                    : Colors.white)
                                : AppColors.gray,
                            weight: _filterStatus == s
                                ? FontWeight.w700
                                : FontWeight.w400,
                            height: 1),
                      ),
                    ),
                  ),
                )),
              ]),
            ),

            // Applications
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildQuery(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.yellow));
                  }

                  final allApps = snapshot.data?.docs ?? [];

                  // Filter by status client-side
                  final apps = _filterStatus == 'all'
                      ? allApps
                      : allApps.where((d) {
                          final data =
                              d.data() as Map<String, dynamic>;
                          return data['status'] == _filterStatus;
                        }).toList();

                  if (apps.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📄',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text('No applications yet',
                              style: AppTextStyles.body(16,
                                  color: AppColors.gray)),
                          const SizedBox(height: 8),
                          Text(
                            _selectedInternshipId == 'all'
                                ? 'Student CVs will appear here once they apply'
                                : 'No applications for this internship yet',
                            style: AppTextStyles.body(13,
                                color: AppColors.gray2),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: apps.length,
                    itemBuilder: (_, i) {
                      final data =
                          apps[i].data() as Map<String, dynamic>;
                      return _ApplicationCard(
                          data: data, docId: apps[i].id);
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    if (_selectedInternshipId == 'all') {
      return FirebaseFirestore.instance
          .collection('internship_applications')
          .where('partner_uid', isEqualTo: widget.partnerUid)
          .snapshots();
    }
    return FirebaseFirestore.instance
        .collection('internship_applications')
        .where('partner_uid', isEqualTo: widget.partnerUid)
        .where('internship_id', isEqualTo: _selectedInternshipId)
        .snapshots();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.greenAccent;
      case 'rejected': return Colors.redAccent;
      case 'pending':  return Colors.orangeAccent;
      default:         return AppColors.yellow;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Internship Filter Tile ────────────────────────────────────────────────────
class _InternshipFilterTile extends StatelessWidget {
  final String title, partnerUid, internshipId;
  final bool isSelected;
  final VoidCallback onTap;

  const _InternshipFilterTile({
    required this.title,
    required this.partnerUid,
    required this.internshipId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: internshipId == 'all'
          ? FirebaseFirestore.instance
              .collection('internship_applications')
              .where('partner_uid', isEqualTo: partnerUid)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('internship_applications')
              .where('partner_uid', isEqualTo: partnerUid)
              .where('internship_id', isEqualTo: internshipId)
              .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        final pending = snapshot.data?.docs.where((d) =>
            (d.data() as Map)['status'] == 'pending').length ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.yellowDim
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected
                      ? AppColors.yellow
                      : Colors.transparent,
                  width: 3,
                ),
                bottom: const BorderSide(
                    color: AppColors.whiteDim2),
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body(13,
                            color: isSelected
                                ? AppColors.yellow
                                : AppColors.white,
                            weight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text('$count application(s)',
                        style: AppTextStyles.body(11,
                            color: AppColors.gray2, height: 1)),
                  ],
                ),
              ),
              if (pending > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('$pending',
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1)),
                ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Application Card ──────────────────────────────────────────────────────────
class _ApplicationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _ApplicationCard({required this.data, required this.docId});

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _expanded = false;

  Color get _statusColor {
    switch (widget.data['status']) {
      case 'accepted': return Colors.greenAccent;
      case 'rejected': return Colors.redAccent;
      default:         return Colors.orangeAccent;
    }
  }

  String get _statusLabel {
    switch (widget.data['status']) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      default:         return 'Pending';
    }
  }

  Future<void> _openCV() async {
    final url = widget.data['cv_url'] ?? '';
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.data['created_at'] as int?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.now();
    final cvType = widget.data['cv_type'] ?? 'link';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.data['status'] == 'pending'
              ? AppColors.whiteDim2
              : _statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(children: [
        // Header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Center(child: Text(
                  (widget.data['student_name'] ?? 'S')
                      .substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 20, color: AppColors.yellow,
                      height: 1),
                )),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data['student_name'] ?? 'Student',
                      style: AppTextStyles.body(14,
                          weight: FontWeight.w700, height: 1.2)),
                  Text(widget.data['internship_title'] ?? '',
                      style: AppTextStyles.body(12,
                          color: AppColors.gray, height: 1.2)),
                  Text('${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.body(11,
                          color: AppColors.gray2, height: 1.2)),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: _statusColor.withOpacity(0.4)),
                    ),
                    child: Text(_statusLabel,
                        style: AppTextStyles.body(12,
                            color: _statusColor,
                            weight: FontWeight.w600,
                            height: 1)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.black3,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cvType == 'service'
                          ? '✨ CV Service'
                          : '🔗 CV Link',
                      style: AppTextStyles.body(10,
                          color: AppColors.gray, height: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray, size: 20),
              ),
            ]),
          ),
        ),

        // Expanded actions
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.whiteDim2),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // View CV button
                if (widget.data['cv_url']?.isNotEmpty == true)
                  GestureDetector(
                    onTap: _openCV,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.yellowDim,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.yellowBorder),
                      ),
                      child: Row(children: [
                        const Icon(Icons.open_in_new_rounded,
                            color: AppColors.yellow, size: 18),
                        const SizedBox(width: 10),
                        Text('View CV (opens in browser)',
                            style: AppTextStyles.body(13,
                                color: AppColors.yellow,
                                weight: FontWeight.w600,
                                height: 1)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.yellow, size: 14),
                      ]),
                    ),
                  ),

                if (cvType == 'service' &&
                    widget.data['cv_url']?.isEmpty != false)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.yellowDim,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.yellowBorder),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.yellow, size: 16),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        'Student requested CV Service — our team is building their CV.',
                        style: AppTextStyles.body(12,
                            color: AppColors.yellow, height: 1.4),
                      )),
                    ]),
                  ),

                const SizedBox(height: 16),

                // Actions
                if (widget.data['status'] == 'pending') ...[
                  Row(children: [
                    Expanded(
                      child: CalmyaabButton(
                        label: '✅ Accept',
                        onTap: () => _showAcceptDialog(context),
                        height: 44, fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _showRejectDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(
                              color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(6)),
                        ),
                        child: Text('❌ Reject',
                            style: AppTextStyles.body(13,
                                color: Colors.redAccent,
                                weight: FontWeight.w600,
                                height: 1)),
                      ),
                    ),
                  ]),
                ],

                // Accepted details
                if (widget.data['status'] == 'accepted') ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INTERVIEW DETAILS',
                            style: AppTextStyles.body(10,
                                color: Colors.greenAccent,
                                weight: FontWeight.w700,
                                letterSpacing: 2,
                                height: 1)),
                        const SizedBox(height: 8),
                        if (widget.data['interview_date']
                                ?.isNotEmpty ==
                            true)
                          Row(children: [
                            const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.gray),
                            const SizedBox(width: 6),
                            Text(widget.data['interview_date'],
                                style: AppTextStyles.body(13,
                                    color: AppColors.white,
                                    height: 1)),
                          ]),
                        const SizedBox(height: 6),
                        if (widget.data['interview_venue']
                                ?.isNotEmpty ==
                            true)
                          Row(children: [
                            const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.gray),
                            const SizedBox(width: 6),
                            Text(widget.data['interview_venue'],
                                style: AppTextStyles.body(13,
                                    color: AppColors.white,
                                    height: 1)),
                          ]),
                      ],
                    ),
                  ),
                ],

                // Rejected details
                if (widget.data['status'] == 'rejected') ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REJECTION REASONS',
                            style: AppTextStyles.body(10,
                                color: Colors.redAccent,
                                weight: FontWeight.w700,
                                letterSpacing: 2,
                                height: 1)),
                        const SizedBox(height: 8),
                        ...List<String>.from(
                                widget.data['rejection_reasons'] ??
                                    [])
                            .map((r) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4),
                                  child: Row(children: [
                                    const Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: Colors.redAccent),
                                    const SizedBox(width: 6),
                                    Text(r,
                                        style: AppTextStyles.body(
                                            13,
                                            color: AppColors.white,
                                            height: 1)),
                                  ]),
                                )),
                        if (widget.data['custom_remark']
                                ?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 8),
                          Text(
                              'Remark: ${widget.data['custom_remark']}',
                              style: AppTextStyles.body(13,
                                  color: AppColors.gray,
                                  height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ]),
    );
  }

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => _AcceptDialog(docId: widget.docId),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => _RejectDialog(docId: widget.docId),
    );
  }
}

// ── Accept Dialog ─────────────────────────────────────────────────────────────
class _AcceptDialog extends StatefulWidget {
  final String docId;
  const _AcceptDialog({required this.docId});

  @override
  State<_AcceptDialog> createState() => _AcceptDialogState();
}

class _AcceptDialogState extends State<_AcceptDialog> {
  final _dateCtrl  = TextEditingController();
  final _venueCtrl = TextEditingController();
  bool _loading    = false;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    setState(() => _loading = true);

    // Get application data for notification
    final appDoc = await FirebaseFirestore.instance
        .collection('internship_applications')
        .doc(widget.docId).get();
    final appData = appDoc.data() ?? {};

    await FirebaseFirestore.instance
        .collection('internship_applications')
        .doc(widget.docId)
        .update({
      'status':          'accepted',
      'interview_date':  _dateCtrl.text.trim(),
      'interview_venue': _venueCtrl.text.trim(),
      'updated_at':      DateTime.now().millisecondsSinceEpoch,
    });

    // Notify student
    final studentUid = appData['student_uid'] ?? '';
    if (studentUid.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('student_notifications')
          .add({
        'student_uid': studentUid,
        'type':        'accepted',
        'title':       '🎉 Application Accepted!',
        'message':     'Your application for ${appData['internship_title']} at ${appData['company_name']} has been accepted!',
        'read':        false,
        'created_at':  DateTime.now().millisecondsSinceEpoch,
      });
    }

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
          border: Border.all(
              color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('ACCEPT APPLICATION',
                  style: TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 26,
                      color: Colors.greenAccent,
                      letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕',
                      style: AppTextStyles.body(16,
                          color: AppColors.gray))),
            ]),
            const SizedBox(height: 8),
            Text('Enter interview details for the student.',
                style: AppTextStyles.body(13,
                    color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 24),
            KTextField(
              label: 'Interview Date & Time',
              hint: 'e.g. 25 March 2025, 10:00 AM',
              controller: _dateCtrl,
              autofocus: true,
              prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18),
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            KTextField(
              label: 'Interview Venue',
              hint: 'e.g. Office, Zoom link, Google Meet',
              controller: _venueCtrl,
              prefixIcon: const Icon(
                  Icons.location_on_outlined, size: 18),
              validator: (_) => null,
            ),
            const SizedBox(height: 24),
            CalmyaabButton(
              label: _loading
                  ? 'Accepting...'
                  : '✅ Confirm Accept',
              onTap: _loading ? null : _accept,
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reject Dialog ─────────────────────────────────────────────────────────────
class _RejectDialog extends StatefulWidget {
  final String docId;
  const _RejectDialog({required this.docId});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _remarkCtrl        = TextEditingController();
  bool _insufficientSkills = false;
  bool _cvNotCorrect       = false;
  bool _loading            = false;

  @override
  void dispose() {
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _reject() async {
    final reasons = <String>[];
    if (_insufficientSkills) reasons.add('Insufficient skills');
    if (_cvNotCorrect) reasons.add('CV is not correct');

    setState(() => _loading = true);

    // Get application data for notification
    final appDoc = await FirebaseFirestore.instance
        .collection('internship_applications')
        .doc(widget.docId).get();
    final appData = appDoc.data() ?? {};

    await FirebaseFirestore.instance
        .collection('internship_applications')
        .doc(widget.docId)
        .update({
      'status':            'rejected',
      'rejection_reasons': reasons,
      'custom_remark':     _remarkCtrl.text.trim(),
      'updated_at':        DateTime.now().millisecondsSinceEpoch,
    });

    // Notify student
    final studentUid = appData['student_uid'] ?? '';
    if (studentUid.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('student_notifications')
          .add({
        'student_uid': studentUid,
        'type':        'rejected',
        'title':       'Application Update',
        'message':     'Your application for ${appData['internship_title']} at ${appData['company_name']} was not selected.',
        'read':        false,
        'created_at':  DateTime.now().millisecondsSinceEpoch,
      });
    }

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
          border: Border.all(
              color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('REJECT APPLICATION',
                  style: TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 26,
                      color: Colors.redAccent,
                      letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕',
                      style: AppTextStyles.body(16,
                          color: AppColors.gray))),
            ]),
            const SizedBox(height: 8),
            Text('Select reasons for rejection.',
                style: AppTextStyles.body(13,
                    color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 24),

            _ReasonCheckbox(
              label: 'Insufficient skills',
              value: _insufficientSkills,
              onChanged: (v) =>
                  setState(() => _insufficientSkills = v ?? false),
            ),
            const SizedBox(height: 8),
            _ReasonCheckbox(
              label: 'CV is not correct',
              value: _cvNotCorrect,
              onChanged: (v) =>
                  setState(() => _cvNotCorrect = v ?? false),
            ),
            const SizedBox(height: 16),

            Text('CUSTOM REMARK (optional)',
                style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextField(
              controller: _remarkCtrl,
              maxLines: 3,
              style: AppTextStyles.body(14,
                  color: AppColors.white),
              decoration: InputDecoration(
                hintText:
                    'Add a custom remark for the student...',
                hintStyle: AppTextStyles.body(14,
                    color: AppColors.gray2),
                filled: true,
                fillColor: AppColors.black3,
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
                        color:
                            Colors.redAccent.withOpacity(0.4))),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loading ? null : _reject,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                  _loading
                      ? 'Rejecting...'
                      : '❌ Confirm Reject',
                  style: AppTextStyles.body(14,
                      color: Colors.redAccent,
                      weight: FontWeight.w600,
                      height: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool?) onChanged;

  const _ReasonCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? Colors.redAccent.withOpacity(0.08)
              : AppColors.black3,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? Colors.redAccent.withOpacity(0.4)
                : AppColors.whiteDim2,
          ),
        ),
        child: Row(children: [
          Icon(
            value
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: value ? Colors.redAccent : AppColors.gray,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.body(14,
                  color: value
                      ? AppColors.white
                      : AppColors.gray,
                  height: 1)),
        ]),
      ),
    );
  }
}