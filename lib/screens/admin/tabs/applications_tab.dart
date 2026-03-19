import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ApplicationsTab extends StatefulWidget {
  const ApplicationsTab({super.key});

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Stats bar
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('internship_applications')
            .snapshots(),
        builder: (context, snapshot) {
          final all      = snapshot.data?.docs ?? [];
          final pending  = all.where((d) =>
              (d.data() as Map)['status'] == 'pending').length;
          final accepted = all.where((d) =>
              (d.data() as Map)['status'] == 'accepted').length;
          final rejected = all.where((d) =>
              (d.data() as Map)['status'] == 'rejected').length;

          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 14),
            color: AppColors.black2,
            child: Row(children: [
              _StatPill(label: 'Total',    value: all.length,
                  color: AppColors.yellow),
              const SizedBox(width: 10),
              _StatPill(label: 'Pending',  value: pending,
                  color: Colors.orangeAccent),
              const SizedBox(width: 10),
              _StatPill(label: 'Accepted', value: accepted,
                  color: Colors.greenAccent),
              const SizedBox(width: 10),
              _StatPill(label: 'Rejected', value: rejected,
                  color: Colors.redAccent),
              const Spacer(),
              // Search
              SizedBox(
                width: 220,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: AppTextStyles.body(13,
                      color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Search student or company...',
                    hintStyle: AppTextStyles.body(13,
                        color: AppColors.gray2),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.gray2, size: 18),
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
                            color: AppColors.yellow
                                .withOpacity(0.4))),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ]),
          );
        },
      ),

      // Tab bar
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
            Tab(text: 'All'),
            Tab(text: '⏳ Pending'),
            Tab(text: '✅ Accepted'),
            Tab(text: '❌ Rejected'),
          ],
        ),
      ),

      // Tab views
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _AppList(status: 'all',      search: _search),
            _AppList(status: 'pending',  search: _search),
            _AppList(status: 'accepted', search: _search),
            _AppList(status: 'rejected', search: _search),
          ],
        ),
      ),
    ]);
  }
}

// ── Stat Pill ─────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatPill({required this.label, required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$value $label',
            style: AppTextStyles.body(12,
                color: color,
                weight: FontWeight.w600,
                height: 1)),
      ]),
    );
  }
}

// ── Applications List ─────────────────────────────────────────────────────────
class _AppList extends StatelessWidget {
  final String status, search;
  const _AppList({required this.status, required this.search});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: status == 'all'
          ? FirebaseFirestore.instance
              .collection('internship_applications')
              .snapshots()
          : FirebaseFirestore.instance
              .collection('internship_applications')
              .where('status', isEqualTo: status)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.yellow));
        }

        var apps = snapshot.data?.docs ?? [];

        // Filter by search
        if (search.isNotEmpty) {
          apps = apps.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name    = (data['student_name'] ?? '')
                .toLowerCase();
            final company = (data['company_name'] ?? '')
                .toLowerCase();
            final title   = (data['internship_title'] ?? '')
                .toLowerCase();
            final q = search.toLowerCase();
            return name.contains(q) ||
                company.contains(q) ||
                title.contains(q);
          }).toList();
        }

        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📋',
                    style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('No applications found',
                    style: AppTextStyles.body(16,
                        color: AppColors.gray)),
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
            return _AdminApplicationCard(
                data: data, docId: apps[i].id);
          },
        );
      },
    );
  }
}

// ── Admin Application Card ────────────────────────────────────────────────────
class _AdminApplicationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _AdminApplicationCard(
      {required this.data, required this.docId});

  @override
  State<_AdminApplicationCard> createState() =>
      _AdminApplicationCardState();
}

class _AdminApplicationCardState
    extends State<_AdminApplicationCard> {
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
      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
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
        GestureDetector(
          onTap: () =>
              setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              // Avatar
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.yellowBorder),
                ),
                child: Center(child: Text(
                  (widget.data['student_name'] ?? 'S')
                      .substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 20,
                      color: AppColors.yellow,
                      height: 1),
                )),
              ),
              const SizedBox(width: 14),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      widget.data['student_name'] ??
                          'Student',
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700,
                          height: 1.2)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text(
                        widget.data['internship_title'] ??
                            '',
                        style: AppTextStyles.body(12,
                            color: AppColors.yellow,
                            height: 1)),
                    Text(' · ',
                        style: AppTextStyles.body(12,
                            color: AppColors.gray2,
                            height: 1)),
                    Text(
                        widget.data['company_name'] ?? '',
                        style: AppTextStyles.body(12,
                            color: AppColors.gray,
                            height: 1)),
                  ]),
                  Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.body(11,
                          color: AppColors.gray2,
                          height: 1.3)),
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
                          color: _statusColor
                              .withOpacity(0.4)),
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

        // Expanded details
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.whiteDim2),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // View CV
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
                        const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.yellow, size: 14),
                      ]),
                    ),
                  ),

                if (cvType == 'service') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.yellowDim,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.yellowBorder),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.yellow, size: 14),
                      const SizedBox(width: 8),
                      Text(
                          'Student requested CV Service',
                          style: AppTextStyles.body(12,
                              color: AppColors.yellow,
                              height: 1)),
                    ]),
                  ),
                ],

                // Accepted details
                if (widget.data['status'] == 'accepted') ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.greenAccent
                              .withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                                size: 13,
                                color: AppColors.gray),
                            const SizedBox(width: 6),
                            Text(
                                widget.data['interview_date'],
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
                                size: 13,
                                color: AppColors.gray),
                            const SizedBox(width: 6),
                            Text(
                                widget.data['interview_venue'],
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.redAccent
                              .withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('REJECTION REASONS',
                            style: AppTextStyles.body(10,
                                color: Colors.redAccent,
                                weight: FontWeight.w700,
                                letterSpacing: 2,
                                height: 1)),
                        const SizedBox(height: 8),
                        ...List<String>.from(widget
                                .data['rejection_reasons'] ??
                            []).map((r) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4),
                              child: Row(children: [
                                const Icon(Icons.close_rounded,
                                    size: 13,
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
}