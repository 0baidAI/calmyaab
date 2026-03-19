import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PartnerNotificationsTab extends StatelessWidget {
  const PartnerNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partner_notifications')
          .where('partner_uid', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final notifications = snapshot.data?.docs ?? [];
        final unread = notifications.where((d) =>
            (d.data() as Map)['read'] == false).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NOTIFICATIONS',
                          style: AppTextStyles.body(11,
                              color: AppColors.yellow,
                              weight: FontWeight.w700,
                              letterSpacing: 3,
                              height: 1)),
                      const SizedBox(height: 6),
                      Text('${notifications.length} notification(s)',
                          style: AppTextStyles.body(14,
                              color: AppColors.gray, height: 1.4)),
                    ],
                  ),
                  // Mark all as read
                  if (unread > 0)
                    GestureDetector(
                      onTap: () => _markAllRead(uid),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.black2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.whiteDim2),
                        ),
                        child: Text('Mark all as read',
                            style: AppTextStyles.body(12,
                                color: AppColors.gray,
                                height: 1)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              notifications.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Column(children: [
                        const Text('🔔',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No notifications yet',
                            style: AppTextStyles.body(16,
                                color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll be notified when students apply to your internships',
                          style: AppTextStyles.body(13,
                              color: AppColors.gray2),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                    )
                  : Column(
                      children: notifications.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>;
                        return _NotificationCard(
                          data: data,
                          docId: doc.id,
                        );
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAllRead(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final snap = await FirebaseFirestore.instance
        .collection('partner_notifications')
        .where('partner_uid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _NotificationCard({required this.data, required this.docId});

  Future<void> _markRead() async {
    if (data['read'] == true) return;
    await FirebaseFirestore.instance
        .collection('partner_notifications')
        .doc(docId)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    final ts = data['created_at'] as int?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.now();
    final isRead = data['read'] ?? false;
    final type   = data['type'] ?? 'new_application';

    return GestureDetector(
      onTap: _markRead,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isRead ? AppColors.black2 : AppColors.black3,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRead
                ? AppColors.whiteDim2
                : AppColors.yellowBorder,
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Row(children: [
          // Unread dot
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.transparent
                  : Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.yellowDim,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Center(child: Text(
              type == 'new_application' ? '📄' : '🔔',
              style: const TextStyle(fontSize: 18),
            )),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'] ?? '',
                  style: AppTextStyles.body(14,
                      weight: isRead
                          ? FontWeight.w400
                          : FontWeight.w700,
                      height: 1.2)),
              const SizedBox(height: 3),
              Text(data['message'] ?? '',
                  style: AppTextStyles.body(12,
                      color: AppColors.gray, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          )),
          const SizedBox(width: 12),

          // Time
          Text(
            _formatTime(date),
            style: AppTextStyles.body(11,
                color: AppColors.gray2, height: 1),
          ),
        ]),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}