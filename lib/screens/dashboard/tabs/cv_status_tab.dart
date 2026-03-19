import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CvStatusTab extends StatelessWidget {
  const CvStatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('internship_applications')
          .where('student_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final apps = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MY APPLICATIONS',
                  style: AppTextStyles.body(11,
                      color: AppColors.yellow,
                      weight: FontWeight.w700,
                      letterSpacing: 3,
                      height: 1)),
              const SizedBox(height: 6),
              Text('${apps.length} application(s)',
                  style: AppTextStyles.body(14,
                      color: AppColors.gray, height: 1.4)),
              const SizedBox(height: 24),

              // Stats
              if (apps.isNotEmpty) ...[
                Row(children: [
                  _StatChip(
                    label: 'Pending',
                    count: apps.where((d) =>
                        (d.data() as Map)['status'] == 'pending').length,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    label: 'Accepted',
                    count: apps.where((d) =>
                        (d.data() as Map)['status'] == 'accepted').length,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 10),
                  _StatChip(
                    label: 'Rejected',
                    count: apps.where((d) =>
                        (d.data() as Map)['status'] == 'rejected').length,
                    color: Colors.redAccent,
                  ),
                ]),
                const SizedBox(height: 28),
              ],

              apps.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Column(children: [
                        const Text('📋', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No applications yet',
                            style: AppTextStyles.body(16,
                                color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text(
                          'Go to Internships tab and apply for a position',
                          style: AppTextStyles.body(13,
                              color: AppColors.gray2),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                    )
                  : Column(
                      children: apps.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _ApplicationCard(data: data);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({required this.label, required this.count,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$count $label',
            style: AppTextStyles.body(12, color: color,
                weight: FontWeight.w600, height: 1)),
      ]),
    );
  }
}

// ── Application Card ──────────────────────────────────────────────────────────
class _ApplicationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _ApplicationCard({required this.data});

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

  IconData get _statusIcon {
    switch (widget.data['status']) {
      case 'accepted': return Icons.check_circle_outline_rounded;
      case 'rejected': return Icons.cancel_outlined;
      default:         return Icons.hourglass_empty_rounded;
    }
  }

  String get _statusLabel {
    switch (widget.data['status']) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      default:         return 'Pending Review';
    }
  }

  Future<void> _viewCV() async {
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
    final cvType = widget.data['cv_type'] ?? 'uploaded';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              // Status icon
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _statusColor.withOpacity(0.3)),
                ),
                child: Center(child: Icon(_statusIcon,
                    color: _statusColor, size: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data['internship_title'] ?? '',
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700, height: 1.2)),
                  Text(widget.data['company_name'] ?? '',
                      style: AppTextStyles.body(13,
                          color: AppColors.yellow, height: 1.2)),
                  Text('Applied ${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.body(11,
                          color: AppColors.gray2, height: 1.2)),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(_statusLabel,
                      style: AppTextStyles.body(11,
                          color: _statusColor,
                          weight: FontWeight.w600,
                          height: 1)),
                ),
                const SizedBox(height: 8),
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
                        : '📄 Own CV',
                    style: AppTextStyles.body(10,
                        color: AppColors.gray, height: 1),
                  ),
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

        // Expanded details
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.whiteDim2),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // View CV button
                if (widget.data['cv_url']?.isNotEmpty == true)
                  GestureDetector(
                    onTap: _viewCV,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.yellowDim,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.yellowBorder),
                      ),
                      child: Row(children: [
                        const Icon(Icons.picture_as_pdf_rounded,
                            color: AppColors.yellow, size: 18),
                        const SizedBox(width: 8),
                        Text('View My CV',
                            style: AppTextStyles.body(13,
                                color: AppColors.yellow,
                                weight: FontWeight.w600,
                                height: 1)),
                        const Spacer(),
                        const Icon(Icons.open_in_new_rounded,
                            color: AppColors.yellow, size: 14),
                      ]),
                    ),
                  ),

                // Accepted details
                if (widget.data['status'] == 'accepted') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🎉 CONGRATULATIONS!',
                            style: AppTextStyles.body(12,
                                color: Colors.greenAccent,
                                weight: FontWeight.w700,
                                letterSpacing: 1,
                                height: 1)),
                        const SizedBox(height: 12),
                        if (widget.data['interview_date']
                            ?.isNotEmpty == true)
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Interview Date',
                            value: widget.data['interview_date'],
                          ),
                        const SizedBox(height: 8),
                        if (widget.data['interview_venue']
                            ?.isNotEmpty == true)
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Venue',
                            value: widget.data['interview_venue'],
                          ),
                      ],
                    ),
                  ),
                ],

                // Rejected details
                if (widget.data['status'] == 'rejected') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REJECTION FEEDBACK',
                            style: AppTextStyles.body(11,
                                color: Colors.redAccent,
                                weight: FontWeight.w700,
                                letterSpacing: 2,
                                height: 1)),
                        const SizedBox(height: 12),
                        ...List<String>.from(
                                widget.data['rejection_reasons'] ?? [])
                            .map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(children: [
                                    const Icon(Icons.close_rounded,
                                        size: 14, color: Colors.redAccent),
                                    const SizedBox(width: 6),
                                    Text(r,
                                        style: AppTextStyles.body(13,
                                            color: AppColors.white,
                                            height: 1)),
                                  ]),
                                )),
                        if (widget.data['custom_remark']
                            ?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          const Divider(
                              height: 1, color: AppColors.whiteDim2),
                          const SizedBox(height: 8),
                          Text('Remark from company:',
                              style: AppTextStyles.body(11,
                                  color: AppColors.gray,
                                  weight: FontWeight.w600,
                                  height: 1)),
                          const SizedBox(height: 6),
                          Text(widget.data['custom_remark'],
                              style: AppTextStyles.body(13,
                                  color: AppColors.white, height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                ],

                // CV Service pending message
                if (cvType == 'service' &&
                    widget.data['status'] == 'pending') ...[
                  const SizedBox(height: 16),
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
                        'Our team will contact you soon to build your professional CV.',
                        style: AppTextStyles.body(12,
                            color: AppColors.yellow, height: 1.4),
                      )),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow({required this.icon, required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: Colors.greenAccent),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTextStyles.body(11,
                color: AppColors.gray, height: 1)),
        Text(value,
            style: AppTextStyles.body(14,
                color: AppColors.white,
                weight: FontWeight.w600,
                height: 1.3)),
      ]),
    ]);
  }
}
