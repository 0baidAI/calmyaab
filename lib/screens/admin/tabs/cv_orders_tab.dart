import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CvOrdersTab extends StatelessWidget {
  const CvOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cv_orders').snapshots(),
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
              // Stats
              Row(children: [
                _OrderStat(label: 'Total Orders',   value: '${docs.length}',                                                                              icon: '📄'),
                const SizedBox(width: 16),
                _OrderStat(label: 'In Progress',    value: '${docs.where((d) => (d.data() as Map)['status'] == 'in_progress').length}',    icon: '⚙️'),
                const SizedBox(width: 16),
                _OrderStat(label: 'Delivered',      value: '${docs.where((d) => (d.data() as Map)['status'] == 'delivered').length}',      icon: '✅'),
              ]),
              const SizedBox(height: 32),

              Text('CV ORDERS',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                  weight: FontWeight.w700, letterSpacing: 3, height: 1),
              ),
              const SizedBox(height: 16),

              docs.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Center(child: Text('No CV orders yet',
                        style: AppTextStyles.body(14, color: AppColors.gray))),
                    )
                  : Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _CvOrderCard(data: data, docId: doc.id);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _CvOrderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _CvOrderCard({required this.data, required this.docId});

  static const _statuses = [
    'pending',
    'info_collected',
    'in_progress',
    'review',
    'delivered',
  ];

  static const _statusLabels = {
    'pending':        'Pending',
    'info_collected': 'Info Collected',
    'in_progress':    'In Progress',
    'review':         'In Review',
    'delivered':      'Delivered ✅',
  };

  Future<void> _updateStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('cv_orders')
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📄', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(data['student_name'] ?? 'Unknown',
                  style: AppTextStyles.body(15, weight: FontWeight.w700, height: 1.2)),
                Text(data['package'] ?? 'Standard CV',
                  style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.2)),
              ]),
            ),
            // Status dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.black3,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.yellowBorder),
              ),
              child: DropdownButton<String>(
                value: status,
                onChanged: (v) => _updateStatus(v!),
                dropdownColor: AppColors.black3,
                underline: const SizedBox(),
                isDense: true,
                style: AppTextStyles.body(13, color: AppColors.yellow, height: 1),
                items: _statuses.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(_statusLabels[s] ?? s),
                )).toList(),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.whiteDim2),
          const SizedBox(height: 12),
          // Bot collected info
          if (data['bot_data'] != null) ...[
            Text('COLLECTED INFO',
              style: AppTextStyles.body(10, color: AppColors.gray,
                weight: FontWeight.w700, letterSpacing: 2, height: 1)),
            const SizedBox(height: 8),
            Text(data['bot_data'].toString(),
              style: AppTextStyles.body(13, color: AppColors.gray, height: 1.6)),
          ],
        ],
      ),
    );
  }
}

class _OrderStat extends StatelessWidget {
  final String label, value, icon;
  const _OrderStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.whiteDim2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontFamily: 'BebasNeue',
            fontSize: 36, color: AppColors.yellow, letterSpacing: 1, height: 1)),
          Text(label, style: AppTextStyles.body(12, color: AppColors.gray, height: 1.3)),
        ]),
      ),
    );
  }
}
