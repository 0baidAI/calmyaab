import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PartnersTab extends StatefulWidget {
  const PartnersTab({super.key});

  @override
  State<PartnersTab> createState() => _PartnersTabState();
}

class _PartnersTabState extends State<PartnersTab>
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
            // Pending tab with live badge
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('partners')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pending'),
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
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const Tab(text: 'Active'),
            const Tab(text: 'Rejected'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _PartnersList(status: 'pending'),
            _PartnersList(status: 'active'),
            _PartnersList(status: 'rejected'),
          ],
        ),
      ),
    ]);
  }
}

// ── Partners List ─────────────────────────────────────────────────────────────
class _PartnersList extends StatelessWidget {
  final String status;
  const _PartnersList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partners')
          .where('status', isEqualTo: status)
          
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.yellow));
        }

        final partners = snapshot.data?.docs ?? [];

        if (partners.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(status == 'pending' ? '🕐' :
                     status == 'active'  ? '✅' : '❌',
                    style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('No $status partners',
                    style: AppTextStyles.body(16,
                        color: AppColors.gray)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${partners.length} partner(s)',
                  style: AppTextStyles.body(14,
                      color: AppColors.gray, height: 1.4)),
              const SizedBox(height: 20),
              ...partners.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _PartnerCard(
                    data: data, docId: doc.id, status: status);
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Partner Card ──────────────────────────────────────────────────────────────
class _PartnerCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId, status;
  const _PartnerCard({
    required this.data,
    required this.docId,
    required this.status,
  });

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard> {
  bool _hovered = false;

  Future<void> _updateStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('partners')
        .doc(widget.docId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final ts = data['created_at'] as int?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.now();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered
                ? AppColors.yellowBorder : AppColors.whiteDim2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // Company avatar
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Center(child: Text(
                  (data['company_name'] ?? 'C')
                      .substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 22, color: AppColors.yellow,
                      height: 1),
                )),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['company_name'] ?? '',
                      style: AppTextStyles.body(16,
                          weight: FontWeight.w700, height: 1.2)),
                  Text(data['industry'] ?? '',
                      style: AppTextStyles.body(13,
                          color: AppColors.yellow, height: 1.2)),
                  Text(data['email'] ?? '',
                      style: AppTextStyles.body(12,
                          color: AppColors.gray, height: 1.2)),
                ],
              )),
              Text('${date.day}/${date.month}/${date.year}',
                  style: AppTextStyles.body(11,
                      color: AppColors.gray2, height: 1)),
            ]),

            // Extra info
            const SizedBox(height: 12),
            Row(children: [
              if (data['phone']?.isNotEmpty == true) ...[
                const Icon(Icons.phone_outlined,
                    size: 13, color: AppColors.gray2),
                const SizedBox(width: 4),
                Text(data['phone'],
                    style: AppTextStyles.body(12,
                        color: AppColors.gray, height: 1)),
                const SizedBox(width: 16),
              ],
              if (data['website']?.isNotEmpty == true) ...[
                const Icon(Icons.language_outlined,
                    size: 13, color: AppColors.gray2),
                const SizedBox(width: 4),
                Text(data['website'],
                    style: AppTextStyles.body(12,
                        color: AppColors.gray, height: 1)),
              ],
            ]),

            // Action buttons
            const SizedBox(height: 16),
            if (widget.status == 'pending') ...[
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus('active'),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus('rejected'),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.redAccent),
                    label: Text('Reject',
                        style: AppTextStyles.body(14,
                            color: Colors.redAccent,
                            weight: FontWeight.w600,
                            height: 1)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ]),
            ],
            if (widget.status == 'active') ...[
              OutlinedButton.icon(
                onPressed: () => _updateStatus('rejected'),
                icon: const Icon(Icons.block_rounded,
                    size: 16, color: Colors.redAccent),
                label: Text('Revoke Access',
                    style: AppTextStyles.body(13,
                        color: Colors.redAccent,
                        weight: FontWeight.w600,
                        height: 1)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
            if (widget.status == 'rejected') ...[
              ElevatedButton.icon(
                onPressed: () => _updateStatus('active'),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Re-Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}