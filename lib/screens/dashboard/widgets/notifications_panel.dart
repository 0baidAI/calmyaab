import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NotificationsPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.gray2,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            const Text('NOTIFICATIONS',
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 24,
                    color: AppColors.white, letterSpacing: 1)),
            const Spacer(),
            GestureDetector(
              onTap: () => _markAllRead(uid),
              child: Text('Mark all read',
                  style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.whiteDim2, height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('student_notifications')
                .where('student_uid', isEqualTo: uid)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                    color: AppColors.yellow));
              }
              final notifs = snapshot.data?.docs ?? [];
              if (notifs.isEmpty) {
                return Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔔', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text('No notifications yet',
                        style: AppTextStyles.body(16, color: AppColors.gray)),
                    const SizedBox(height: 8),
                    Text('You\'ll be notified when your applications are reviewed',
                        style: AppTextStyles.body(13, color: AppColors.gray2),
                        textAlign: TextAlign.center),
                  ],
                ));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifs.length,
                itemBuilder: (_, i) {
                  final data = notifs[i].data() as Map<String, dynamic>;
                  return _NotifCard(data: data, docId: notifs[i].id);
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  Future<void> _markAllRead(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final snap = await FirebaseFirestore.instance
        .collection('student_notifications')
        .where('student_uid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  const _NotifCard({required this.data, required this.docId});

  Color get _color {
    switch (data['type']) {
      case 'accepted': return Colors.greenAccent;
      case 'rejected': return Colors.redAccent;
      case 'booking':  return AppColors.yellow;
      default:         return Colors.blueAccent;
    }
  }

  String get _icon {
    switch (data['type']) {
      case 'accepted': return '✅';
      case 'rejected': return '❌';
      case 'booking':  return '📅';
      default:         return '🔔';
    }
  }

  Future<void> _markRead() async {
    if (data['read'] == true) return;
    await FirebaseFirestore.instance
        .collection('student_notifications')
        .doc(docId)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    final ts   = data['created_at'] as int?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now();
    final isRead = data['read'] ?? false;

    return GestureDetector(
      onTap: _markRead,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.black3 : AppColors.black,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRead ? AppColors.whiteDim2 : _color.withOpacity(0.4),
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Row(children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(
                color: isRead ? Colors.transparent : _color,
                shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _color.withOpacity(0.3)),
            ),
            child: Center(child: Text(_icon,
                style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'] ?? '',
                  style: AppTextStyles.body(14,
                      weight: isRead ? FontWeight.w400 : FontWeight.w700,
                      height: 1.2)),
              const SizedBox(height: 3),
              Text(data['message'] ?? '',
                  style: AppTextStyles.body(12,
                      color: AppColors.gray, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          )),
          const SizedBox(width: 8),
          Text(_formatTime(date),
              style: AppTextStyles.body(10, color: AppColors.gray2, height: 1)),
        ]),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now  = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ── Bell Icon with unread badge ───────────────────────────────────────────────
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('student_notifications')
          .where('student_uid', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unread = snapshot.data?.docs.length ?? 0;
        return GestureDetector(
          onTap: () => NotificationsPanel.show(context),
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.gray, size: 22),
            ),
            if (unread > 0)
              Positioned(top: 4, right: 4,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }
}