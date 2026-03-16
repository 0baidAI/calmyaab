import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';

enum ServiceType { internship, cv, abroad }

class ServiceModal extends StatefulWidget {
  final ServiceType type;
  const ServiceModal({super.key, required this.type});

  @override
  State<ServiceModal> createState() => _ServiceModalState();
}

class _ServiceModalState extends State<ServiceModal> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _uniCtrl     = TextEditingController();
  String _fieldValue = 'Computer Science / IT';
  String _pkgValue   = 'Basic — 1 page CV (PKR 1,200)';
  String _countryVal = 'United Kingdom 🇬🇧';
  String _eduVal     = 'Bachelors (Current Student)';

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _uniCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case ServiceType.internship: return 'INTERNSHIP ACCESS';
      case ServiceType.cv:         return 'CV SERVICE';
      case ServiceType.abroad:     return 'STUDY ABROAD';
    }
  }

  String get _subtitle {
    switch (widget.type) {
      case ServiceType.internship: return 'Fill in your details to proceed to payment (PKR 2,000)';
      case ServiceType.cv:         return 'Our bot will WhatsApp you after payment to collect your info';
      case ServiceType.abroad:     return 'Free first consultation — our team will contact you within 24 hours';
    }
  }

  String get _btnLabel {
    switch (widget.type) {
      case ServiceType.internship: return 'Proceed to Payment (PKR 2,000) →';
      case ServiceType.cv:         return 'Proceed to Payment →';
      case ServiceType.abroad:     return 'Book Free Consultation →';
    }
  }

  String get _note {
    switch (widget.type) {
      case ServiceType.internship: return '🔒 Secure payment via JazzCash, Easypaisa or Card';
      case ServiceType.cv:         return '🔒 Bot will WhatsApp you within 1 hour of payment';
      case ServiceType.abroad:     return '✅ Completely free — no payment required';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellow.withOpacity(0.2), width: 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close
              Align(
                alignment: Alignment.topRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('✕', style: AppTextStyles.body(18, color: AppColors.gray)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(_title,
                style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 36, color: AppColors.yellow, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(_subtitle, style: AppTextStyles.bodySm),
              const SizedBox(height: 32),

              // Fields — vary by type
              _FormField(label: 'Full Name', controller: _nameCtrl, hint: 'e.g. Ahmed Khan'),
              const SizedBox(height: 20),
              _FormField(
                label: widget.type == ServiceType.internship ? 'Phone Number' : 'WhatsApp Number',
                controller: _phoneCtrl,
                hint: 'e.g. 0300-1234567',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              if (widget.type == ServiceType.internship) ...[
                _FormField(label: 'University', controller: _uniCtrl, hint: 'e.g. LUMS, FAST, UET'),
                const SizedBox(height: 20),
                _DropdownField(
                  label: 'Field of Study',
                  value: _fieldValue,
                  items: const ['Computer Science / IT', 'Business / BBA / MBA', 'Engineering', 'Marketing / Media', 'Finance / Accounting', 'Other'],
                  onChanged: (v) => setState(() => _fieldValue = v!),
                ),
              ],

              if (widget.type == ServiceType.cv) ...[
                _DropdownField(
                  label: 'CV Package',
                  value: _pkgValue,
                  items: const ['Basic — 1 page CV (PKR 1,200)', 'Standard — 2 page CV + Cover Letter (PKR 1,800)', 'Premium — CV + Cover Letter + LinkedIn (PKR 2,500)'],
                  onChanged: (v) => setState(() => _pkgValue = v!),
                ),
                const SizedBox(height: 20),
                _DropdownField(
                  label: 'Target Industry',
                  value: _fieldValue,
                  items: const ['Technology / Software', 'Marketing / Digital Media', 'Finance / Banking', 'Engineering / Manufacturing', 'Other'],
                  onChanged: (v) => setState(() => _fieldValue = v!),
                ),
              ],

              if (widget.type == ServiceType.abroad) ...[
                _DropdownField(
                  label: 'Preferred Country',
                  value: _countryVal,
                  items: const ['United Kingdom 🇬🇧', 'Germany 🇩🇪', 'Malaysia 🇲🇾', 'Canada 🇨🇦', 'Australia 🇦🇺', 'Not sure yet'],
                  onChanged: (v) => setState(() => _countryVal = v!),
                ),
                const SizedBox(height: 20),
                _DropdownField(
                  label: 'Current Education Level',
                  value: _eduVal,
                  items: const ['A-Levels / Intermediate', 'Bachelors (Current Student)', 'Bachelors (Completed)', 'Masters'],
                  onChanged: (v) => setState(() => _eduVal = v!),
                ),
              ],

              const SizedBox(height: 32),
              CalmyaabButton(
                label: _btnLabel,
                onTap: () {
                  // TODO: Connect to payment service
                  Navigator.pop(context);
                },
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(_note, style: AppTextStyles.body(12, color: AppColors.gray2, height: 1.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
          style: AppTextStyles.body(12, color: AppColors.gray, weight: FontWeight.w600, letterSpacing: 1, height: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body(14, color: AppColors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body(14, color: AppColors.gray2),
            filled: true,
            fillColor: AppColors.black3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.whiteDim2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.whiteDim2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label, required this.value,
    required this.items, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
          style: AppTextStyles.body(12, color: AppColors.gray, weight: FontWeight.w600, letterSpacing: 1, height: 1),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          dropdownColor: AppColors.black3,
          style: AppTextStyles.body(14, color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.black3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.whiteDim2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.whiteDim2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
        ),
      ],
    );
  }
}

// Helper to open modal
void showServiceModal(BuildContext context, ServiceType type) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.85),
    builder: (_) => ServiceModal(type: type),
  );
}
