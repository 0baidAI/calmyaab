import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class InternshipsTab extends StatefulWidget {
  const InternshipsTab({super.key});

  @override
  State<InternshipsTab> createState() => _InternshipsTabState();
}

class _InternshipsTabState extends State<InternshipsTab> {
  String _selectedField = 'All';
  final _fields = ['All', 'Technology', 'Marketing', 'Finance', 'Engineering', 'Media'];

  // Sample internship data — replace with Firestore later
  final _internships = [
    _Internship(company: 'TechCorp Pakistan',   role: 'Flutter Developer Intern',    field: 'Technology', location: 'Lahore',    type: 'On-site',  stipend: 'PKR 15,000/month', logo: '💻'),
    _Internship(company: 'NexaDigital',         role: 'Digital Marketing Intern',    field: 'Marketing',  location: 'Karachi',   type: 'Remote',   stipend: 'PKR 12,000/month', logo: '📱'),
    _Internship(company: 'PakFinance Ltd',      role: 'Finance Analyst Intern',      field: 'Finance',    location: 'Islamabad', type: 'On-site',  stipend: 'PKR 18,000/month', logo: '💰'),
    _Internship(company: 'CyberWave Solutions', role: 'Backend Developer Intern',    field: 'Technology', location: 'Lahore',    type: 'Hybrid',   stipend: 'PKR 20,000/month', logo: '🌐'),
    _Internship(company: 'GrowthLab Agency',    role: 'Content Creator Intern',      field: 'Media',      location: 'Remote',    type: 'Remote',   stipend: 'PKR 10,000/month', logo: '✍️'),
    _Internship(company: 'Innova Engineering',  role: 'Civil Engineering Intern',    field: 'Engineering', location: 'Karachi',  type: 'On-site',  stipend: 'PKR 16,000/month', logo: '🏗️'),
    _Internship(company: 'DataSync AI',         role: 'Machine Learning Intern',     field: 'Technology', location: 'Lahore',    type: 'Hybrid',   stipend: 'PKR 25,000/month', logo: '🤖'),
    _Internship(company: 'MediaPulse',          role: 'Social Media Manager Intern', field: 'Marketing',  location: 'Remote',    type: 'Remote',   stipend: 'PKR 8,000/month',  logo: '📸'),
  ];

  List<_Internship> get _filtered => _selectedField == 'All'
      ? _internships
      : _internships.where((i) => i.field == _selectedField).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INTERNSHIPS',
                        style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
                          color: AppColors.white, letterSpacing: 2, height: 1),
                      ),
                      Text('${_filtered.length} opportunities available',
                        style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _fields.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: f,
                      selected: _selectedField == f,
                      onTap: () => setState(() => _selectedField = f),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Grid
              isDesktop
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _InternshipCard(internship: _filtered[i]),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _InternshipCard(internship: _filtered[i]),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.yellow : AppColors.black2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.yellow : AppColors.whiteDim2,
          ),
        ),
        child: Text(label,
          style: AppTextStyles.body(13,
            color: selected ? AppColors.black : AppColors.gray,
            weight: selected ? FontWeight.w700 : FontWeight.w400,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _InternshipCard extends StatefulWidget {
  final _Internship internship;
  const _InternshipCard({required this.internship});

  @override
  State<_InternshipCard> createState() => _InternshipCardState();
}

class _InternshipCardState extends State<_InternshipCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final i = widget.internship;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered ? AppColors.yellowBorder : AppColors.whiteDim2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.yellowDim,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.yellowBorder),
                  ),
                  child: Center(child: Text(i.logo, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i.company,
                        style: AppTextStyles.body(14, weight: FontWeight.w700, height: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(i.role,
                        style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _TypeBadge(type: i.type),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _InfoChip(icon: Icons.location_on_outlined, label: i.location),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.payments_outlined, label: i.stipend),
              ],
            ),
            const SizedBox(height: 14),
            CalmyaabButton(
              label: 'Apply Now →',
              onTap: () => _showApplyDialog(context, i),
              style: CButtonStyle.ghost,
              width: double.infinity,
              height: 38,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context, _Internship i) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => _ApplyDialog(internship: i),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  Color get _color {
    switch (type) {
      case 'Remote':  return Colors.greenAccent;
      case 'Hybrid':  return Colors.orangeAccent;
      default:        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(type,
        style: AppTextStyles.body(11, color: _color, weight: FontWeight.w600, height: 1),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.gray),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.body(12, color: AppColors.gray, height: 1)),
      ],
    );
  }
}

class _ApplyDialog extends StatelessWidget {
  final _Internship internship;
  const _ApplyDialog({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.yellowBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(internship.logo, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(internship.company,
                        style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 22,
                          color: AppColors.white, letterSpacing: 1),
                      ),
                      Text(internship.role,
                        style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.2),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('✕', style: AppTextStyles.body(16, color: AppColors.gray)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DialogRow(label: 'Location', value: internship.location),
            _DialogRow(label: 'Type',     value: internship.type),
            _DialogRow(label: 'Stipend',  value: internship.stipend),
            _DialogRow(label: 'Field',    value: internship.field),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.yellowDim,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.yellowBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.yellow, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your CV will be submitted to ${internship.company}. Our team will follow up within 48 hours.',
                      style: AppTextStyles.body(12, color: AppColors.yellow, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CalmyaabButton(
              label: 'Submit Application →',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Application submitted to ${internship.company}! ✅'),
                    backgroundColor: AppColors.black2,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              width: double.infinity,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label, value;
  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.body(13, color: AppColors.gray, height: 1)),
          ),
          Text(value, style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1)),
        ],
      ),
    );
  }
}

class _Internship {
  final String company, role, field, location, type, stipend, logo;
  const _Internship({
    required this.company, required this.role, required this.field,
    required this.location, required this.type, required this.stipend,
    required this.logo,
  });
}
