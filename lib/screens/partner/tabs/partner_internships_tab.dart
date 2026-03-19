import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class PartnerInternshipsTab extends StatelessWidget {
  final String partnerUid, companyName;
  const PartnerInternshipsTab({
    super.key,
    required this.partnerUid,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('internships')
          .where('partner_uid', isEqualTo: partnerUid)
          
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final internships = snapshot.data?.docs ?? [];

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
                      Text('MY INTERNSHIPS',
                          style: AppTextStyles.body(11,
                              color: AppColors.yellow,
                              weight: FontWeight.w700,
                              letterSpacing: 3,
                              height: 1)),
                      const SizedBox(height: 6),
                      Text('${internships.length} posted',
                          style: AppTextStyles.body(14,
                              color: AppColors.gray, height: 1.4)),
                    ],
                  ),
                  CalmyaabButton(
                    label: '+ Post Internship',
                    onTap: () => _showAddDialog(context),
                    height: 42, fontSize: 13,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              internships.isEmpty
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
                        Text('No internships posted yet',
                            style: AppTextStyles.body(16,
                                color: AppColors.gray)),
                        const SizedBox(height: 8),
                        Text('Click "+ Post Internship" to get started',
                            style: AppTextStyles.body(13,
                                color: AppColors.gray2)),
                      ]),
                    )
                  : Column(
                      children: internships.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _InternshipCard(
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

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => _AddInternshipDialog(
        partnerUid: partnerUid,
        companyName: companyName,
      ),
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
  bool _hovered = false;

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: Text('Delete Internship?',
            style: AppTextStyles.body(16, weight: FontWeight.w700)),
        content: Text(
            'This will remove the internship and all its applications.',
            style: AppTextStyles.body(14, color: AppColors.gray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: AppTextStyles.body(14, color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('Delete',
                  style: AppTextStyles.body(14,
                      color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('internships')
          .doc(widget.docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
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
                  ? AppColors.yellowBorder : AppColors.whiteDim2),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.yellowDim,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: const Center(child: Text('💼',
                style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['title'] ?? '',
                  style: AppTextStyles.body(15,
                      weight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 4),
              Row(children: [
                Text(data['location'] ?? '',
                    style: AppTextStyles.body(12,
                        color: AppColors.gray, height: 1)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.yellowDim,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.yellowBorder),
                  ),
                  child: Text(data['type'] ?? 'On-site',
                      style: AppTextStyles.body(10,
                          color: AppColors.yellow,
                          weight: FontWeight.w600,
                          height: 1)),
                ),
              ]),
              if (data['stipend']?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text('PKR ${data['stipend']} / month',
                    style: AppTextStyles.body(12,
                        color: Colors.greenAccent, height: 1)),
              ],
            ],
          )),
          // Applications count
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('internship_applications')
                .where('internship_id', isEqualTo: widget.docId)
                .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.black3,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.whiteDim2),
                ),
                child: Column(children: [
                  Text('$count',
                      style: AppTextStyles.body(18,
                          color: AppColors.yellow,
                          weight: FontWeight.w700,
                          height: 1)),
                  Text('CVs',
                      style: AppTextStyles.body(10,
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
            tooltip: 'Delete internship',
          ),
        ]),
      ),
    );
  }
}

// ── Add Internship Dialog ─────────────────────────────────────────────────────
class _AddInternshipDialog extends StatefulWidget {
  final String partnerUid, companyName;
  const _AddInternshipDialog({
    required this.partnerUid,
    required this.companyName,
  });

  @override
  State<_AddInternshipDialog> createState() =>
      _AddInternshipDialogState();
}

class _AddInternshipDialogState extends State<_AddInternshipDialog> {
  final _titleCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _stipendCtrl  = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _skillsCtrl   = TextEditingController();
  final _durationCtrl = TextEditingController();
  String _type        = 'On-site';
  bool _loading       = false;

  static const _types = ['On-site', 'Remote', 'Hybrid'];

  @override
  void dispose() {
    _titleCtrl.dispose(); _locationCtrl.dispose();
    _stipendCtrl.dispose(); _descCtrl.dispose();
    _skillsCtrl.dispose(); _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_titleCtrl.text.isEmpty || _locationCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('internships')
        .add({
      'title':       _titleCtrl.text.trim(),
      'company':     widget.companyName,
      'partner_uid': widget.partnerUid,
      'location':    _locationCtrl.text.trim(),
      'stipend':     _stipendCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'skills':      _skillsCtrl.text.trim(),
      'duration':    _durationCtrl.text.trim(),
      'type':        _type,
      'created_at':  DateTime.now().millisecondsSinceEpoch,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('POST INTERNSHIP',
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

              KTextField(label: 'Job Title *',
                  hint: 'e.g. Flutter Developer Intern',
                  controller: _titleCtrl, autofocus: true,
                  prefixIcon: const Icon(Icons.work_outline_rounded, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),
              KTextField(label: 'Location *',
                  hint: 'e.g. Lahore, Pakistan',
                  controller: _locationCtrl,
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),
              KTextField(label: 'Stipend (PKR/month)',
                  hint: 'e.g. 15000',
                  controller: _stipendCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),
              KTextField(label: 'Duration',
                  hint: 'e.g. 3 months',
                  controller: _durationCtrl,
                  prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),

              // Type dropdown
              Text('TYPE', style: AppTextStyles.label),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                onChanged: (v) => setState(() => _type = v!),
                dropdownColor: AppColors.black3,
                style: AppTextStyles.body(14, color: AppColors.white),
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.black3,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                items: _types.map((t) => DropdownMenuItem(
                    value: t, child: Text(t))).toList(),
              ),
              const SizedBox(height: 14),

              KTextField(label: 'Required Skills',
                  hint: 'e.g. Flutter, Dart, Firebase',
                  controller: _skillsCtrl,
                  prefixIcon: const Icon(Icons.code_outlined, size: 18),
                  validator: (_) => null),
              const SizedBox(height: 14),

              Text('DESCRIPTION', style: AppTextStyles.label),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                style: AppTextStyles.body(14, color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Describe the internship role...',
                  hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
                  filled: true, fillColor: AppColors.black3,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                          color: AppColors.yellow.withOpacity(0.4))),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              CalmyaabButton(
                label: _loading ? 'Posting...' : 'Post Internship →',
                onTap: _loading ? null : _post,
                width: double.infinity, height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}