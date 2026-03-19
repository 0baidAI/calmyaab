import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class AgencyBookingsTab extends StatefulWidget {
  final String agencyId, agencyName;
  const AgencyBookingsTab({super.key,
      required this.agencyId, required this.agencyName});

  @override
  State<AgencyBookingsTab> createState() => _AgencyBookingsTabState();
}

class _AgencyBookingsTabState extends State<AgencyBookingsTab>
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
          labelStyle: AppTextStyles.body(13,
              weight: FontWeight.w600, height: 1),
          tabs: [
            // Pending with live badge
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('study_abroad_bookings')
                  .where('agency_id', isEqualTo: widget.agencyId)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Tab(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⏳ Pending'),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('$count',
                            style: const TextStyle(fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1)),
                      ),
                    ],
                  ],
                ));
              },
            ),
            const Tab(text: '✅ Confirmed'),
            const Tab(text: '🏁 Completed'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _BookingsList(agencyId: widget.agencyId,
                status: 'pending'),
            _BookingsList(agencyId: widget.agencyId,
                status: 'confirmed'),
            _BookingsList(agencyId: widget.agencyId,
                status: 'completed'),
          ],
        ),
      ),
    ]);
  }
}

class _BookingsList extends StatelessWidget {
  final String agencyId, status;
  const _BookingsList({required this.agencyId, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('study_abroad_bookings')
          .where('agency_id', isEqualTo: agencyId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.yellow));
        }

        final bookings = snapshot.data?.docs ?? [];

        if (bookings.isEmpty) {
          return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status == 'pending' ? '⏳'
                  : status == 'confirmed' ? '✅' : '🏁',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('No $status bookings',
                  style: AppTextStyles.body(16,
                      color: AppColors.gray)),
              if (status == 'pending') ...[
                const SizedBox(height: 8),
                Text('Student bookings will appear here',
                    style: AppTextStyles.body(13,
                        color: AppColors.gray2)),
              ],
            ],
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: bookings.length,
          itemBuilder: (_, i) {
            final data = bookings[i].data() as Map<String, dynamic>;
            return _BookingCard(data: data, docId: bookings[i].id,
                status: status);
          },
        );
      },
    );
  }
}

class _BookingCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId, status;
  const _BookingCard({required this.data, required this.docId,
      required this.status});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _expanded = false;
  final _timeCtrl = TextEditingController();
  bool _loading   = false;

  @override
  void dispose() {
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_timeCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('study_abroad_bookings')
        .doc(widget.docId)
        .update({
      'status':         'confirmed',
      'confirmed_time': _timeCtrl.text.trim(),
      'updated_at':     DateTime.now().millisecondsSinceEpoch,
    });

    // Notify student
    final studentUid = widget.data['student_uid'] ?? '';
    if (studentUid.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('student_notifications')
          .add({
        'student_uid': studentUid,
        'type':        'booking',
        'title':       '📅 Consultation Confirmed!',
        'message':     'Your consultation with ${widget.data['agency_name'] ?? ''} is confirmed for ${_timeCtrl.text.trim()}',
        'read':        false,
        'created_at':  DateTime.now().millisecondsSinceEpoch,
      });
    }

    setState(() => _loading = false);
  }

  Future<void> _markCompleted() async {
    await FirebaseFirestore.instance
        .collection('study_abroad_bookings')
        .doc(widget.docId)
        .update({'status': 'completed'});
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.data['created_at'] as int?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now();
    final consultType =
        widget.data['consultation_type'] ?? 'in-person';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.status == 'pending'
              ? AppColors.yellowBorder.withOpacity(0.5)
              : AppColors.whiteDim2,
        ),
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
                  Text(widget.data['student_name'] ?? '',
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppColors.gray2),
                    const SizedBox(width: 4),
                    Text(widget.data['preferred_day'] ?? '',
                        style: AppTextStyles.body(12,
                            color: AppColors.gray, height: 1)),
                    const SizedBox(width: 10),
                    const Icon(Icons.schedule_outlined,
                        size: 13, color: AppColors.gray2),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.data['preferred_time_from'] ?? ''}'
                      ' - ${widget.data['preferred_time_to'] ?? ''}',
                      style: AppTextStyles.body(12,
                          color: AppColors.gray, height: 1),
                    ),
                  ]),
                  Text('${date.day}/${date.month}/${date.year}',
                      style: AppTextStyles.body(11,
                          color: AppColors.gray2, height: 1.3)),
                ],
              )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.yellowDim,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: AppColors.yellowBorder),
                    ),
                    child: Text(
                      consultType == 'online'
                          ? '💻 Online' : '🏢 In-Person',
                      style: AppTextStyles.body(10,
                          color: AppColors.yellow,
                          weight: FontWeight.w600, height: 1),
                    ),
                  ),
                ],
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
                // Student message
                if (widget.data['message']?.isNotEmpty == true) ...[
                  Text('STUDENT MESSAGE',
                      style: AppTextStyles.body(10,
                          color: AppColors.gray,
                          weight: FontWeight.w700,
                          letterSpacing: 2, height: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.black3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.whiteDim2),
                    ),
                    child: Text(widget.data['message'],
                        style: AppTextStyles.body(13,
                            color: AppColors.white, height: 1.6)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Confirm time (pending only)
                if (widget.status == 'pending') ...[
                  Text('SET APPOINTMENT TIME',
                      style: AppTextStyles.body(10,
                          color: AppColors.gray,
                          weight: FontWeight.w700,
                          letterSpacing: 2, height: 1)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: KTextField(
                      label: '',
                      hint: 'e.g. Monday, 11:00 AM',
                      controller: _timeCtrl,
                      prefixIcon: const Icon(
                          Icons.schedule_outlined, size: 18),
                      validator: (_) => null,
                    )),
                    const SizedBox(width: 12),
                    CalmyaabButton(
                      label: _loading ? '...' : '✅ Confirm',
                      onTap: _loading ? null : _confirm,
                      height: 50, fontSize: 13,
                    ),
                  ]),
                ],

                // Confirmed time
                if (widget.status == 'confirmed') ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.greenAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONFIRMED TIME',
                            style: AppTextStyles.body(10,
                                color: Colors.greenAccent,
                                weight: FontWeight.w700,
                                letterSpacing: 2, height: 1)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.schedule_outlined,
                              size: 14,
                              color: Colors.greenAccent),
                          const SizedBox(width: 6),
                          Text(widget.data['confirmed_time'] ?? '',
                              style: AppTextStyles.body(14,
                                  color: AppColors.white,
                                  weight: FontWeight.w600,
                                  height: 1)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _markCompleted,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.greenAccent,
                      side: const BorderSide(
                          color: Colors.greenAccent),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('Mark as Completed',
                        style: AppTextStyles.body(13,
                            color: Colors.greenAccent,
                            weight: FontWeight.w600, height: 1)),
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