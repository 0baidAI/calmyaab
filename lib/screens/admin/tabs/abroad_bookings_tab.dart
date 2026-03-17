// ─── Abroad Bookings Tab ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AbroadBookingsTab extends StatelessWidget {
  const AbroadBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('abroad_inquiries').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final docs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STUDY ABROAD BOOKINGS',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                  weight: FontWeight.w700, letterSpacing: 3, height: 1),
              ),
              const SizedBox(height: 8),
              Text('${docs.length} total bookings',
                style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4)),
              const SizedBox(height: 24),

              docs.isEmpty
                  ? _EmptyCard(message: 'No study abroad bookings yet')
                  : Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _BookingCard(data: data, docId: doc.id);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _BookingCard({required this.data, required this.docId});

  Future<void> _updateStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('abroad_inquiries')
        .doc(docId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Row(children: [
        const Text('🌍', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['student_name'] ?? 'Unknown',
              style: AppTextStyles.body(15, weight: FontWeight.w700, height: 1.2)),
            Text(data['country'] ?? 'Not specified',
              style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.2)),
            const SizedBox(height: 4),
            Text('Phone: ${data['phone'] ?? '-'}',
              style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
          ]),
        ),
        // Status update
        DropdownButton<String>(
          value: status,
          onChanged: (v) => _updateStatus(v!),
          dropdownColor: AppColors.black3,
          underline: const SizedBox(),
          style: AppTextStyles.body(13, color: AppColors.yellow, height: 1),
          items: const [
            DropdownMenuItem(value: 'pending',   child: Text('Pending')),
            DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
            DropdownMenuItem(value: 'scheduled', child: Text('Scheduled ✅')),
            DropdownMenuItem(value: 'completed', child: Text('Completed 🎉')),
          ],
        ),
      ]),
    );
  }
}

// ─── Revenue Tab ──────────────────────────────────────────────────────────────
class RevenueTab extends StatelessWidget {
  const RevenueTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('payments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final docs = snapshot.data?.docs ?? [];
        int total = 0;
        int internshipRev = 0;
        int cvRev = 0;
        int abroadRev = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] as num?)?.toInt() ?? 0;
          final service = data['service'] ?? '';
          total += amount;
          if (service == 'internship') internshipRev += amount;
          if (service == 'cv')         cvRev += amount;
          if (service == 'abroad')     abroadRev += amount;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REVENUE & PAYMENTS',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                  weight: FontWeight.w700, letterSpacing: 3, height: 1),
              ),
              const SizedBox(height: 24),

              // Total revenue card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.yellow.withOpacity(0.15), AppColors.yellow.withOpacity(0.05)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TOTAL REVENUE',
                    style: AppTextStyles.body(11, color: AppColors.yellow,
                      weight: FontWeight.w700, letterSpacing: 3, height: 1)),
                  const SizedBox(height: 12),
                  Text('PKR ${_format(total)}',
                    style: const TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 52, color: AppColors.yellow, letterSpacing: 1, height: 1)),
                  Text('from ${docs.length} payments',
                    style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4)),
                ]),
              ),
              const SizedBox(height: 24),

              // Breakdown
              Row(children: [
                Expanded(child: _RevCard(label: 'Internship', amount: internshipRev, icon: '🏢')),
                const SizedBox(width: 16),
                Expanded(child: _RevCard(label: 'CV Service',  amount: cvRev,         icon: '📄')),
                const SizedBox(width: 16),
                Expanded(child: _RevCard(label: 'Study Abroad', amount: abroadRev,    icon: '🌍')),
              ]),
              const SizedBox(height: 32),

              // Payments list
              Text('PAYMENT HISTORY',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                  weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              const SizedBox(height: 16),

              docs.isEmpty
                  ? _EmptyCard(message: 'No payments recorded yet')
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _PaymentRow(data: data);
                        }).toList(),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  String _format(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '$amount';
  }
}

class _RevCard extends StatelessWidget {
  final String label, icon;
  final int amount;
  const _RevCard({required this.label, required this.amount, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 12),
        Text('PKR $amount',
          style: const TextStyle(fontFamily: 'BebasNeue',
            fontSize: 28, color: AppColors.yellow, letterSpacing: 1, height: 1)),
        Text(label, style: AppTextStyles.body(12, color: AppColors.gray, height: 1.3)),
      ]),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PaymentRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Expanded(flex: 2, child: Text(data['student_name'] ?? '-',
            style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1))),
          Expanded(flex: 2, child: Text(data['service'] ?? '-',
            style: AppTextStyles.body(13, color: AppColors.yellow, height: 1))),
          Expanded(flex: 1, child: Text('PKR ${data['amount'] ?? 0}',
            style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1))),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            ),
            child: Text('Paid',
              style: AppTextStyles.body(11, color: Colors.greenAccent,
                weight: FontWeight.w600, height: 1)),
          )),
        ]),
      ),
      const Divider(height: 1, color: AppColors.whiteDim2),
    ]);
  }
}

// ─── Notifications Tab ────────────────────────────────────────────────────────
class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final _titleCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _target = 'all';
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleCtrl.text.isEmpty || _messageCtrl.text.isEmpty) return;
    setState(() => _sending = true);

    await FirebaseFirestore.instance.collection('notifications').add({
      'title':      _titleCtrl.text.trim(),
      'message':    _messageCtrl.text.trim(),
      'target':     _target,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'sent_by':    'admin',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SEND NOTIFICATION',
            style: AppTextStyles.body(11, color: AppColors.yellow,
              weight: FontWeight.w700, letterSpacing: 3, height: 1),
          ),
          const SizedBox(height: 24),

          // Send form
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.black2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      Text('Notification sent successfully! ✅',
                        style: AppTextStyles.body(13, color: Colors.greenAccent, height: 1)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Target
                Text('SEND TO', style: AppTextStyles.label),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _target,
                  onChanged: (v) => setState(() => _target = v!),
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
                    DropdownMenuItem(value: 'all',         child: Text('All Students')),
                    DropdownMenuItem(value: 'internship',  child: Text('Internship Users')),
                    DropdownMenuItem(value: 'cv',          child: Text('CV Service Users')),
                    DropdownMenuItem(value: 'abroad',      child: Text('Study Abroad Users')),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                Text('TITLE', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleCtrl,
                  style: AppTextStyles.body(14, color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. New internship available!',
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

                // Message
                Text('MESSAGE', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageCtrl,
                  maxLines: 4,
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
                const SizedBox(height: 28),

                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(
                      _sending ? 'Sending...' : 'Send Notification →',
                      style: AppTextStyles.body(14, color: AppColors.black,
                        weight: FontWeight.w700, height: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Past notifications
          Text('SENT NOTIFICATIONS',
            style: AppTextStyles.body(11, color: AppColors.yellow,
              weight: FontWeight.w700, letterSpacing: 3, height: 1),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('created_at', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return _EmptyCard(message: 'No notifications sent yet');

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.black2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.whiteDim2),
                    ),
                    child: Row(children: [
                      const Text('🔔', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['title'] ?? '',
                            style: AppTextStyles.body(14, weight: FontWeight.w600, height: 1.2)),
                          Text(data['message'] ?? '',
                            style: AppTextStyles.body(12, color: AppColors.gray, height: 1.4),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.yellowDim,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.yellowBorder),
                        ),
                        child: Text(data['target'] ?? 'all',
                          style: AppTextStyles.body(10, color: AppColors.yellow,
                            weight: FontWeight.w600, height: 1)),
                      ),
                    ]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Shared empty card ─────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Center(child: Text(message,
        style: AppTextStyles.body(14, color: AppColors.gray))),
    );
  }
}
