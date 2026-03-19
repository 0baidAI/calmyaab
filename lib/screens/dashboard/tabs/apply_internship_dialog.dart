import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/k_text_field.dart';

class ApplyInternshipDialog extends StatefulWidget {
  final String internshipId, internshipTitle,
               companyName, partnerUid, studentUid;

  const ApplyInternshipDialog({
    super.key,
    required this.internshipId,
    required this.internshipTitle,
    required this.companyName,
    required this.partnerUid,
    required this.studentUid,
  });

  @override
  State<ApplyInternshipDialog> createState() =>
      _ApplyInternshipDialogState();
}

class _ApplyInternshipDialogState
    extends State<ApplyInternshipDialog> {
  int _step     = 0;
  bool _loading = false;
  String? _error;

  final _linkCtrl = TextEditingController();

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitWithLink() async {
    final link = _linkCtrl.text.trim();
    if (link.isEmpty) {
      setState(() => _error = 'Please paste your CV link');
      return;
    }
    if (!link.startsWith('http')) {
      setState(() => _error = 'Please enter a valid link starting with http');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentUid)
          .get();
      final studentName = studentDoc.data()?['name'] ?? 'Student';

      await FirebaseFirestore.instance
          .collection('internship_applications')
          .add({
        'student_uid':       widget.studentUid,
        'student_name':      studentName,
        'internship_id':     widget.internshipId,
        'internship_title':  widget.internshipTitle,
        'company_name':      widget.companyName,
        'partner_uid':       widget.partnerUid,
        'cv_url':            link,
        'cv_type':           'link',
        'status':            'pending',
        'rejection_reasons': [],
        'custom_remark':     '',
        'interview_date':    '',
        'interview_venue':   '',
        'created_at':        DateTime.now().millisecondsSinceEpoch,
      });

      // Notify partner
      if (widget.partnerUid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('partner_notifications')
            .add({
          'partner_uid': widget.partnerUid,
          'type':        'new_application',
          'title':       'New CV Submitted!',
          'message':     '$studentName applied for ${widget.internshipTitle}',
          'read':        false,
          'created_at':  DateTime.now().millisecondsSinceEpoch,
        });
      }

      setState(() { _loading = false; _step = 3; });
      setState(() { _loading = false; _step = 3; });
    } catch (e) {
      setState(() {
        _loading = false;
        _error   = 'Something went wrong. Please try again.';
      });
    }
  }

  Future<void> _submitCVService() async {
    setState(() { _loading = true; _error = null; });

    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentUid)
          .get();
      final studentName = studentDoc.data()?['name'] ?? 'Student';

      await FirebaseFirestore.instance
          .collection('internship_applications')
          .add({
        'student_uid':       widget.studentUid,
        'student_name':      studentName,
        'internship_id':     widget.internshipId,
        'internship_title':  widget.internshipTitle,
        'company_name':      widget.companyName,
        'partner_uid':       widget.partnerUid,
        'cv_url':            '',
        'cv_type':           'service',
        'status':            'pending',
        'rejection_reasons': [],
        'custom_remark':     '',
        'interview_date':    '',
        'interview_venue':   '',
        'created_at':        DateTime.now().millisecondsSinceEpoch,
      });

      setState(() { _loading = false; _step = 3; });
    } catch (e) {
      setState(() {
        _loading = false;
        _error   = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _StepChoose(
        internshipTitle: widget.internshipTitle,
        companyName:     widget.companyName,
        onLink:          () => setState(() => _step = 1),
        onCVService:     () => setState(() => _step = 2),
        onClose:         () => Navigator.pop(context),
      );
      case 1: return _StepLink(
        linkCtrl:  _linkCtrl,
        error:     _error,
        loading:   _loading,
        onSubmit:  _submitWithLink,
        onBack:    () => setState(() => _step = 0),
      );
      case 2: return _StepCVService(
        loading:   _loading,
        error:     _error,
        onSubmit:  _submitCVService,
        onBack:    () => setState(() => _step = 0),
      );
      case 3: return const _StepDone();
      default: return const SizedBox();
    }
  }
}

// ── Step 0: Choose ────────────────────────────────────────────────────────────
class _StepChoose extends StatelessWidget {
  final String internshipTitle, companyName;
  final VoidCallback onLink, onCVService, onClose;

  const _StepChoose({
    required this.internshipTitle,
    required this.companyName,
    required this.onLink,
    required this.onCVService,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('APPLY NOW',
              style: TextStyle(fontFamily: 'BebasNeue',
                  fontSize: 28, color: AppColors.yellow,
                  letterSpacing: 1)),
          const Spacer(),
          GestureDetector(
              onTap: onClose,
              child: Text('✕', style: AppTextStyles.body(16,
                  color: AppColors.gray))),
        ]),
        const SizedBox(height: 8),
        Text('$internshipTitle at $companyName',
            style: AppTextStyles.body(14,
                color: AppColors.gray, height: 1.4)),
        const SizedBox(height: 28),

        Text('HOW WOULD YOU LIKE TO APPLY?',
            style: AppTextStyles.body(10,
                color: AppColors.gray,
                weight: FontWeight.w700,
                letterSpacing: 2,
                height: 1)),
        const SizedBox(height: 16),

        // CV Link option
        GestureDetector(
          onTap: onLink,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.black3,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.whiteDim2),
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: const Center(child: Text('🔗',
                    style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share CV Link',
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700, height: 1.2)),
                  Text('Paste your Google Drive or PDF link',
                      style: AppTextStyles.body(12,
                          color: AppColors.gray, height: 1.4)),
                ],
              )),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.gray, size: 16),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // CV Service option
        GestureDetector(
          onTap: onCVService,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.black3,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.whiteDim2),
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: const Center(child: Text('✨',
                    style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Use Calmyaab CV Service',
                      style: AppTextStyles.body(15,
                          weight: FontWeight.w700, height: 1.2)),
                  Text('Our team builds a professional CV for you',
                      style: AppTextStyles.body(12,
                          color: AppColors.gray, height: 1.4)),
                ],
              )),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.gray, size: 16),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Step 1: CV Link ───────────────────────────────────────────────────────────
class _StepLink extends StatelessWidget {
  final TextEditingController linkCtrl;
  final String? error;
  final bool loading;
  final VoidCallback onSubmit, onBack;

  const _StepLink({
    required this.linkCtrl,
    required this.error,
    required this.loading,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.gray, size: 20)),
          const SizedBox(width: 12),
          const Text('SHARE CV LINK',
              style: TextStyle(fontFamily: 'BebasNeue',
                  fontSize: 28, color: AppColors.yellow,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 8),
        Text(
          'Paste a shareable link to your CV. Make sure the link is set to "Anyone with link can view".',
          style: AppTextStyles.body(13,
              color: AppColors.gray, height: 1.5)),
        const SizedBox(height: 24),

        // How to get link guide
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.yellowDim,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📌 How to get your CV link:',
                  style: AppTextStyles.body(12,
                      color: AppColors.yellow,
                      weight: FontWeight.w700,
                      height: 1.2)),
              const SizedBox(height: 8),
              Text('Google Drive: Upload PDF → Right click → Share → Copy link',
                  style: AppTextStyles.body(11,
                      color: AppColors.yellow, height: 1.5)),
              Text('OneDrive: Upload → Share → Anyone with link → Copy',
                  style: AppTextStyles.body(11,
                      color: AppColors.yellow, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Text(error!,
                style: AppTextStyles.body(13,
                    color: Colors.redAccent, height: 1.4)),
          ),
          const SizedBox(height: 16),
        ],

        KTextField(
          label: 'CV Link *',
          hint: 'https://drive.google.com/...',
          controller: linkCtrl,
          autofocus: true,
          prefixIcon: const Icon(Icons.link_rounded, size: 18),
          validator: (_) => null,
        ),
        const SizedBox(height: 24),

        CalmyaabButton(
          label: loading ? 'Submitting...' : 'Submit Application →',
          onTap: loading ? null : onSubmit,
          width: double.infinity,
          height: 50,
        ),
      ],
    );
  }
}

// ── Step 2: CV Service ────────────────────────────────────────────────────────
class _StepCVService extends StatelessWidget {
  final bool loading;
  final String? error;
  final VoidCallback onSubmit, onBack;

  const _StepCVService({
    required this.loading,
    required this.error,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.gray, size: 20)),
          const SizedBox(width: 12),
          const Text('CV SERVICE',
              style: TextStyle(fontFamily: 'BebasNeue',
                  fontSize: 28, color: AppColors.yellow,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.yellowDim,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✨ What happens next?',
                  style: AppTextStyles.body(15,
                      color: AppColors.yellow,
                      weight: FontWeight.w700,
                      height: 1.2)),
              const SizedBox(height: 12),
              _StepItem(n: '1', text: 'Your application is submitted'),
              _StepItem(n: '2',
                  text: 'Our team contacts you to collect your info'),
              _StepItem(n: '3', text: 'We build a professional CV for you'),
              _StepItem(n: '4',
                  text: 'CV is sent to the company on your behalf'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Text(error!,
                style: AppTextStyles.body(13,
                    color: Colors.redAccent, height: 1.4)),
          ),
          const SizedBox(height: 16),
        ],

        CalmyaabButton(
          label: loading ? 'Submitting...' : 'Request CV Service →',
          onTap: loading ? null : onSubmit,
          width: double.infinity,
          height: 50,
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final String n, text;
  const _StepItem({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(
              color: AppColors.yellow, shape: BoxShape.circle),
          child: Center(child: Text(n,
              style: const TextStyle(fontSize: 11,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                  height: 1))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: AppTextStyles.body(13,
                color: AppColors.white, height: 1))),
      ]),
    );
  }
}

// ── Step 3: Done ──────────────────────────────────────────────────────────────
class _StepDone extends StatelessWidget {
  const _StepDone();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.yellowDim,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          child: const Center(child: Text('🎉',
              style: TextStyle(fontSize: 32))),
        ),
        const SizedBox(height: 20),
        const Text('APPLICATION SUBMITTED!',
            style: TextStyle(fontFamily: 'BebasNeue',
                fontSize: 28, color: AppColors.yellow,
                letterSpacing: 1),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Your application has been submitted! Track your status in the "My CV" tab.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(14,
              color: AppColors.gray, height: 1.7),
        ),
        const SizedBox(height: 28),
        CalmyaabButton(
          label: 'Done ✅',
          onTap: () => Navigator.pop(context),
          width: double.infinity,
          height: 48,
        ),
      ],
    );
  }
}