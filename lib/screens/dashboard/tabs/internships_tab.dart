import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import 'apply_internship_dialog.dart';

class InternshipsTab extends StatefulWidget {
  const InternshipsTab({super.key});

  @override
  State<InternshipsTab> createState() => _InternshipsTabState();
}

class _InternshipsTabState extends State<InternshipsTab> {
  String _search = '';
  String _filter = 'All';

  static const _filters = ['All', 'On-site', 'Remote', 'Hybrid'];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('internships')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final all = snapshot.data?.docs ?? [];

        // Filter by type and search
        final filtered = all.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title   = (data['title'] ?? '').toLowerCase();
          final company = (data['company'] ?? '').toLowerCase();
          final type    = data['type'] ?? 'On-site';
          final matchSearch = _search.isEmpty ||
              title.contains(_search.toLowerCase()) ||
              company.contains(_search.toLowerCase());
          final matchFilter = _filter == 'All' || type == _filter;
          return matchSearch && matchFilter;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('INTERNSHIPS',
                  style: AppTextStyles.body(11,
                      color: AppColors.yellow,
                      weight: FontWeight.w700,
                      letterSpacing: 3,
                      height: 1)),
              const SizedBox(height: 6),
              Text('${filtered.length} opportunities available',
                  style: AppTextStyles.body(14,
                      color: AppColors.gray, height: 1.4)),
              const SizedBox(height: 24),

              // Search bar
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: AppTextStyles.body(14, color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Search by title or company...',
                  hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.gray2, size: 20),
                  filled: true,
                  fillColor: AppColors.black2,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.yellow.withOpacity(0.4))),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Filter chips
              Row(children: _filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _filter == f
                          ? AppColors.yellow
                          : AppColors.black2,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: _filter == f
                            ? AppColors.yellow
                            : AppColors.whiteDim2,
                      ),
                    ),
                    child: Text(f,
                        style: AppTextStyles.body(12,
                            color: _filter == f
                                ? AppColors.black
                                : AppColors.gray,
                            weight: _filter == f
                                ? FontWeight.w700
                                : FontWeight.w400,
                            height: 1)),
                  ),
                ),
              )).toList()),
              const SizedBox(height: 24),

              // Internships list
              filtered.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Column(children: [
                        const Text('💼', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No internships found',
                            style: AppTextStyles.body(16,
                                color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text('Check back soon for new opportunities',
                            style: AppTextStyles.body(13,
                                color: AppColors.gray2)),
                      ]),
                    )
                  : Column(
                      children: filtered.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _InternshipCard(
                            data: data, docId: doc.id);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}

// ── Internship Card ───────────────────────────────────────────────────────────
class _InternshipCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _InternshipCard({required this.data, required this.docId});

  @override
  State<_InternshipCard> createState() => _InternshipCardState();
}

class _InternshipCardState extends State<_InternshipCard> {
  bool _expanded = false;
  bool _hovered  = false;

  @override
  Widget build(BuildContext context) {
    final data       = widget.data;
    final uid        = FirebaseAuth.instance.currentUser?.uid ?? '';
    final hasStipend = data['stipend']?.isNotEmpty == true;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _hovered
                  ? AppColors.yellowBorder
                  : AppColors.whiteDim2),
        ),
        child: Column(children: [
          // Main row
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                // Company icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.yellowDim,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.yellowBorder),
                  ),
                  child: Center(child: Text(
                    (data['company'] ?? 'C')
                        .substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontFamily: 'BebasNeue',
                        fontSize: 24, color: AppColors.yellow, height: 1),
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'] ?? '',
                        style: AppTextStyles.body(16,
                            weight: FontWeight.w700, height: 1.2)),
                    const SizedBox(height: 4),
                    Text(data['company'] ?? '',
                        style: AppTextStyles.body(13,
                            color: AppColors.yellow, height: 1)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 8, children: [
                      _Tag(label: data['location'] ?? '',
                          icon: Icons.location_on_outlined),
                      _Tag(label: data['type'] ?? 'On-site',
                          icon: Icons.work_outline_rounded),
                      if (data['duration']?.isNotEmpty == true)
                        _Tag(label: data['duration'],
                            icon: Icons.schedule_outlined),
                    ]),
                  ],
                )),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  if (hasStipend)
                    Text('PKR ${data['stipend']}',
                        style: AppTextStyles.body(13,
                            color: Colors.greenAccent,
                            weight: FontWeight.w700,
                            height: 1)),
                  if (hasStipend)
                    Text('/month',
                        style: AppTextStyles.body(10,
                            color: AppColors.gray2, height: 1.3)),
                  const SizedBox(height: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.gray, size: 20),
                  ),
                ]),
              ]),
            ),
          ),

          // Expanded details + apply
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.whiteDim2),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data['description']?.isNotEmpty == true) ...[
                    Text('ABOUT THIS ROLE',
                        style: AppTextStyles.body(10,
                            color: AppColors.gray,
                            weight: FontWeight.w700,
                            letterSpacing: 2,
                            height: 1)),
                    const SizedBox(height: 8),
                    Text(data['description'],
                        style: AppTextStyles.body(14,
                            color: AppColors.white, height: 1.7)),
                    const SizedBox(height: 16),
                  ],
                  if (data['skills']?.isNotEmpty == true) ...[
                    Text('REQUIRED SKILLS',
                        style: AppTextStyles.body(10,
                            color: AppColors.gray,
                            weight: FontWeight.w700,
                            letterSpacing: 2,
                            height: 1)),
                    const SizedBox(height: 8),
                    Text(data['skills'],
                        style: AppTextStyles.body(14,
                            color: AppColors.yellow, height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // Check if already applied
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('internship_applications')
                        .where('student_uid', isEqualTo: uid)
                        .where('internship_id',
                            isEqualTo: widget.docId)
                        .snapshots(),
                    builder: (context, appSnapshot) {
                      final alreadyApplied =
                          appSnapshot.data?.docs.isNotEmpty == true;

                      if (alreadyApplied) {
                        final status = (appSnapshot.data!.docs.first
                            .data() as Map)['status'] ?? 'pending';
                        return _AlreadyAppliedBadge(status: status);
                      }

                      return CalmyaabButton(
                        label: 'Apply Now →',
                        onTap: () => _showApplyDialog(context, uid),
                        height: 46,
                        fontSize: 14,
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

  void _showApplyDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => ApplyInternshipDialog(
        internshipId:    widget.docId,
        internshipTitle: widget.data['title'] ?? '',
        companyName:     widget.data['company'] ?? '',
        partnerUid:      widget.data['partner_uid'] ?? '',
        studentUid:      uid,
      ),
    );
  }
}

// ── Tag widget ────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Tag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black3,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.gray2),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.body(11,
                color: AppColors.gray, height: 1)),
      ]),
    );
  }
}

// ── Already Applied Badge ─────────────────────────────────────────────────────
class _AlreadyAppliedBadge extends StatelessWidget {
  final String status;
  const _AlreadyAppliedBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'accepted': return Colors.greenAccent;
      case 'rejected': return Colors.redAccent;
      default:         return Colors.orangeAccent;
    }
  }

  String get _label {
    switch (status) {
      case 'accepted': return '✅ Application Accepted';
      case 'rejected': return '❌ Application Rejected';
      default:         return '⏳ Application Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.check_circle_outline, color: _color, size: 16),
        const SizedBox(width: 10),
        Text(_label,
            style: AppTextStyles.body(13,
                color: _color,
                weight: FontWeight.w600,
                height: 1)),
        const Spacer(),
        Text('Check My CV tab for details',
            style: AppTextStyles.body(11,
                color: AppColors.gray, height: 1)),
      ]),
    );
  }
}
