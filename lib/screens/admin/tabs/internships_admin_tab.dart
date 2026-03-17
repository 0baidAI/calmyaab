import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class InternshipsAdminTab extends StatelessWidget {
  const InternshipsAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('internships').snapshots(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('INTERNSHIP LISTINGS',
                    style: AppTextStyles.body(11, color: AppColors.yellow,
                      weight: FontWeight.w700, letterSpacing: 3, height: 1),
                  ),
                  CalmyaabButton(
                    label: '+ Add Internship',
                    onTap: () => _showAddDialog(context),
                    height: 42, fontSize: 13,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              docs.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppColors.black2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.whiteDim2),
                      ),
                      child: Center(
                        child: Column(children: [
                          const Text('🏢', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 16),
                          Text('No internships added yet',
                            style: AppTextStyles.body(14, color: AppColors.gray)),
                          const SizedBox(height: 8),
                          Text('Click "+ Add Internship" to add your first listing',
                            style: AppTextStyles.body(13, color: AppColors.gray2)),
                        ]),
                      ),
                    )
                  : Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _InternshipAdminCard(data: data, docId: doc.id);
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
      builder: (_) => const _AddInternshipDialog(),
    );
  }
}

class _InternshipAdminCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const _InternshipAdminCard({required this.data, required this.docId});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: Text('Delete?', style: AppTextStyles.body(16, weight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this listing?',
          style: AppTextStyles.body(14, color: AppColors.gray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.body(14, color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: AppTextStyles.body(14, color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('internships').doc(docId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Row(children: [
        Text(data['logo'] ?? '🏢', style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['company'] ?? '-',
              style: AppTextStyles.body(15, weight: FontWeight.w700, height: 1.2)),
            Text(data['role'] ?? '-',
              style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.2)),
            const SizedBox(height: 4),
            Row(children: [
              Text(data['location'] ?? '-',
                style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
              const SizedBox(width: 12),
              Text(data['stipend'] ?? '-',
                style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
            ]),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
          onPressed: () => _delete(context),
        ),
      ]),
    );
  }
}

class _AddInternshipDialog extends StatefulWidget {
  const _AddInternshipDialog();

  @override
  State<_AddInternshipDialog> createState() => _AddInternshipDialogState();
}

class _AddInternshipDialogState extends State<_AddInternshipDialog> {
  final _companyCtrl  = TextEditingController();
  final _roleCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _stipendCtrl  = TextEditingController();
  final _logoCtrl     = TextEditingController();
  String _field = 'Technology';
  String _type  = 'On-site';
  bool _loading = false;

  @override
  void dispose() {
    _companyCtrl.dispose(); _roleCtrl.dispose();
    _locationCtrl.dispose(); _stipendCtrl.dispose(); _logoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_companyCtrl.text.isEmpty || _roleCtrl.text.isEmpty) return;
    setState(() => _loading = true);

    await FirebaseFirestore.instance.collection('internships').add({
      'company':  _companyCtrl.text.trim(),
      'role':     _roleCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'stipend':  _stipendCtrl.text.trim(),
      'field':    _field,
      'type':     _type,
      'logo':     _logoCtrl.text.trim().isEmpty ? '🏢' : _logoCtrl.text.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Text('ADD INTERNSHIP',
                  style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28,
                    color: AppColors.yellow, letterSpacing: 1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕', style: AppTextStyles.body(16, color: AppColors.gray))),
              ]),
              const SizedBox(height: 24),
              _Field(label: 'Company Name', ctrl: _companyCtrl, hint: 'e.g. TechCorp Pakistan'),
              const SizedBox(height: 16),
              _Field(label: 'Role', ctrl: _roleCtrl, hint: 'e.g. Flutter Developer Intern'),
              const SizedBox(height: 16),
              _Field(label: 'Location', ctrl: _locationCtrl, hint: 'e.g. Lahore / Remote'),
              const SizedBox(height: 16),
              _Field(label: 'Stipend', ctrl: _stipendCtrl, hint: 'e.g. PKR 15,000/month'),
              const SizedBox(height: 16),
              _Field(label: 'Logo Emoji', ctrl: _logoCtrl, hint: 'e.g. 💻 (optional)'),
              const SizedBox(height: 16),
              _Dropdown(label: 'Field', value: _field,
                items: const ['Technology', 'Marketing', 'Finance', 'Engineering', 'Media'],
                onChanged: (v) => setState(() => _field = v!)),
              const SizedBox(height: 16),
              _Dropdown(label: 'Type', value: _type,
                items: const ['On-site', 'Remote', 'Hybrid'],
                onChanged: (v) => setState(() => _type = v!)),
              const SizedBox(height: 28),
              CalmyaabButton(
                label: _loading ? 'Saving...' : 'Add Internship →',
                onTap: _loading ? null : _save,
                width: double.infinity, height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;

  const _Field({required this.label, required this.ctrl, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: AppTextStyles.label),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        style: AppTextStyles.body(14, color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
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
    ]);
  }
}

class _Dropdown extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({required this.label, required this.value,
    required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: AppTextStyles.label),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value, onChanged: onChanged,
        dropdownColor: AppColors.black3,
        style: AppTextStyles.body(14, color: AppColors.white),
        decoration: InputDecoration(
          filled: true, fillColor: AppColors.black3,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.whiteDim2)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.whiteDim2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      ),
    ]);
  }
}
