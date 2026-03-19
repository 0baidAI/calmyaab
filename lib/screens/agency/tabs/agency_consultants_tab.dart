import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class AgencyConsultantsTab extends StatelessWidget {
  final String agencyId;
  const AgencyConsultantsTab({super.key, required this.agencyId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agencies')
          .doc(agencyId)
          .collection('consultants')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.yellow));
        }

        final consultants = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OUR CONSULTANTS',
                          style: AppTextStyles.body(11,
                              color: AppColors.yellow,
                              weight: FontWeight.w700,
                              letterSpacing: 3, height: 1)),
                      const SizedBox(height: 6),
                      Text('${consultants.length} consultant(s)',
                          style: AppTextStyles.body(14,
                              color: AppColors.gray, height: 1.4)),
                    ],
                  ),
                  CalmyaabButton(
                    label: '+ Add Consultant',
                    onTap: () => showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.8),
                      builder: (_) => _AddConsultantDialog(
                          agencyId: agencyId),
                    ),
                    height: 42, fontSize: 13,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              consultants.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Column(children: [
                        const Text('👤',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('No consultants yet',
                            style: AppTextStyles.body(16,
                                color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text('Add your team members who will handle consultations',
                            style: AppTextStyles.body(13,
                                color: AppColors.gray2),
                            textAlign: TextAlign.center),
                      ]),
                    )
                  : Column(
                      children: consultants.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _ConsultantCard(
                            data: data, docId: doc.id,
                            agencyId: agencyId);
                      }).toList(),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _ConsultantCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId, agencyId;
  const _ConsultantCard({required this.data, required this.docId,
      required this.agencyId});

  @override
  State<_ConsultantCard> createState() => _ConsultantCardState();
}

class _ConsultantCardState extends State<_ConsultantCard> {
  bool _hovered = false;

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: Text('Remove Consultant?',
            style: AppTextStyles.body(16, weight: FontWeight.w700)),
        content: Text('Are you sure you want to remove ${widget.data['name']}?',
            style: AppTextStyles.body(14, color: AppColors.gray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppTextStyles.body(14,
                  color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Remove', style: AppTextStyles.body(14,
                  color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('agencies')
          .doc(widget.agencyId)
          .collection('consultants')
          .doc(widget.docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(color: _hovered
              ? AppColors.yellowBorder : AppColors.whiteDim2),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.yellowDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Center(child: Text(
              (widget.data['name'] ?? 'C')
                  .substring(0, 1).toUpperCase(),
              style: const TextStyle(fontFamily: 'BebasNeue',
                  fontSize: 22, color: AppColors.yellow, height: 1),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data['name'] ?? '',
                  style: AppTextStyles.body(15,
                      weight: FontWeight.w700, height: 1.2)),
              Text(widget.data['specialization'] ?? '',
                  style: AppTextStyles.body(13,
                      color: AppColors.yellow, height: 1.2)),
              if (widget.data['zoom_link']?.isNotEmpty == true)
                Row(children: [
                  const Icon(Icons.videocam_outlined,
                      size: 13, color: AppColors.gray2),
                  const SizedBox(width: 4),
                  Text('Online sessions available',
                      style: AppTextStyles.body(12,
                          color: AppColors.gray, height: 1.2)),
                ]),
            ],
          )),
          // Bookings count
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('study_abroad_bookings')
                .where('consultant_id', isEqualTo: widget.docId)
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.black3,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.whiteDim2),
                ),
                child: Column(children: [
                  Text('$count', style: AppTextStyles.body(18,
                      color: AppColors.yellow,
                      weight: FontWeight.w700, height: 1)),
                  Text('sessions', style: AppTextStyles.body(10,
                      color: AppColors.gray, height: 1)),
                ]),
              );
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 20),
            onPressed: () => _delete(context),
            tooltip: 'Remove consultant',
          ),
        ]),
      ),
    );
  }
}

class _AddConsultantDialog extends StatefulWidget {
  final String agencyId;
  const _AddConsultantDialog({required this.agencyId});

  @override
  State<_AddConsultantDialog> createState() =>
      _AddConsultantDialogState();
}

class _AddConsultantDialogState
    extends State<_AddConsultantDialog> {
  final _nameCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _zoomCtrl = TextEditingController();
  bool _loading   = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specCtrl.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _specCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('agencies')
        .doc(widget.agencyId)
        .collection('consultants')
        .add({
      'name':           _nameCtrl.text.trim(),
      'specialization': _specCtrl.text.trim(),
      'zoom_link':      _zoomCtrl.text.trim(),
      'created_at':     DateTime.now().millisecondsSinceEpoch,
    });

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
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('ADD CONSULTANT',
                  style: TextStyle(fontFamily: 'BebasNeue',
                      fontSize: 28, color: AppColors.yellow,
                      letterSpacing: 1)),
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕', style: AppTextStyles.body(16,
                      color: AppColors.gray))),
            ]),
            const SizedBox(height: 24),
            KTextField(label: 'Full Name *',
                hint: 'e.g. Ahmed Khan',
                controller: _nameCtrl, autofocus: true,
                prefixIcon: const Icon(
                    Icons.person_outline_rounded, size: 18),
                validator: (_) => null),
            const SizedBox(height: 14),
            KTextField(label: 'Specialization *',
                hint: 'e.g. UK/Canada Admissions',
                controller: _specCtrl,
                prefixIcon: const Icon(Icons.school_outlined,
                    size: 18),
                validator: (_) => null),
            const SizedBox(height: 14),
            KTextField(label: 'Zoom Link (optional)',
                hint: 'https://zoom.us/j/...',
                controller: _zoomCtrl,
                prefixIcon: const Icon(Icons.videocam_outlined,
                    size: 18),
                validator: (_) => null),
            const SizedBox(height: 24),
            CalmyaabButton(
              label: _loading ? 'Adding...' : 'Add Consultant →',
              onTap: _loading ? null : _save,
              width: double.infinity, height: 50,
            ),
          ],
        ),
      ),
    );
  }
}