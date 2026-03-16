import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class StudyAbroadTab extends StatefulWidget {
  const StudyAbroadTab({super.key});

  @override
  State<StudyAbroadTab> createState() => _StudyAbroadTabState();
}

class _StudyAbroadTabState extends State<StudyAbroadTab> {
  // TODO: Replace with real Firestore data
  final bool _hasBooking = false;
  String _selectedCountry = 'United Kingdom 🇬🇧';

  final _countries = [
    'United Kingdom 🇬🇧',
    'Germany 🇩🇪',
    'Malaysia 🇲🇾',
    'Canada 🇨🇦',
    'Australia 🇦🇺',
    'Not sure yet',
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: _hasBooking ? _BookedSlot() : _BookConsultation(
            selectedCountry: _selectedCountry,
            countries: _countries,
            onCountryChanged: (v) => setState(() => _selectedCountry = v!),
          ),
        ),
      ),
    );
  }
}

// ── No booking yet ────────────────────────────────────────────────────────────
class _BookConsultation extends StatelessWidget {
  final String selectedCountry;
  final List<String> countries;
  final ValueChanged<String?> onCountryChanged;

  const _BookConsultation({
    required this.selectedCountry,
    required this.countries,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STUDY ABROAD',
          style: TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
            color: AppColors.white, letterSpacing: 2, height: 1),
        ),
        const SizedBox(height: 8),
        Text('Book your free consultation with our study abroad experts.',
          style: AppTextStyles.body(15, color: AppColors.gray, height: 1.6),
        ),
        const SizedBox(height: 32),

        // Countries grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.8 : 1.4,
          children: const [
            _CountryCard(flag: '🇬🇧', name: 'UK',        desc: 'Post-study work visa'),
            _CountryCard(flag: '🇩🇪', name: 'Germany',   desc: 'Low/free tuition'),
            _CountryCard(flag: '🇲🇾', name: 'Malaysia',  desc: 'Affordable & close'),
            _CountryCard(flag: '🇨🇦', name: 'Canada',    desc: 'PR pathway'),
            _CountryCard(flag: '🇦🇺', name: 'Australia', desc: '2-4yr work rights'),
            _CountryCard(flag: '🌍',  name: 'Other',     desc: 'Tell us your choice'),
          ],
        ),
        const SizedBox(height: 32),

        // Booking form
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.black2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BOOK FREE CONSULTATION',
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28,
                  color: AppColors.yellow, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text('Our team will contact you within 24 hours to schedule your call.',
                style: AppTextStyles.body(14, color: AppColors.gray, height: 1.5),
              ),
              const SizedBox(height: 24),

              // Country selector
              Text('PREFERRED COUNTRY', style: AppTextStyles.label),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                onChanged: onCountryChanged,
                dropdownColor: AppColors.black3,
                style: AppTextStyles.body(14, color: AppColors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.black3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.whiteDim2)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.yellow.withOpacity(0.4))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ),
              const SizedBox(height: 24),

              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.yellowDim,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.yellowBorder),
                ),
                child: Row(children: [
                  const Text('✅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    'First consultation is completely FREE. No payment required.',
                    style: AppTextStyles.body(13, color: AppColors.yellow, height: 1.5),
                  )),
                ]),
              ),
              const SizedBox(height: 24),

              CalmyaabButton(
                label: 'Book Free Consultation →',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Consultation request sent! Our team will contact you within 24 hours. ✅'),
                      backgroundColor: AppColors.black2,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                width: double.infinity,
                height: 52,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountryCard extends StatefulWidget {
  final String flag, name, desc;
  const _CountryCard({required this.flag, required this.name, required this.desc});

  @override
  State<_CountryCard> createState() => _CountryCardState();
}

class _CountryCardState extends State<_CountryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.yellowDim : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered ? AppColors.yellowBorder : AppColors.whiteDim2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.flag, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(widget.name,
              style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 20,
                color: AppColors.white, letterSpacing: 1),
            ),
            Text(widget.desc,
              style: AppTextStyles.body(11, color: AppColors.gray, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booked slot ───────────────────────────────────────────────────────────────
class _BookedSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MY CONSULTATION',
          style: TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
            color: AppColors.white, letterSpacing: 2, height: 1),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.black2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.yellowBorder),
            gradient: LinearGradient(
              colors: [AppColors.yellow.withOpacity(0.08), Colors.transparent],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.yellow, borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('📅', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('CONSULTATION BOOKED',
                    style: TextStyle(fontFamily: 'BebasNeue', fontSize: 24,
                      color: AppColors.yellow, letterSpacing: 1),
                  ),
                  Text('Your slot is confirmed ✅',
                    style: AppTextStyles.body(14, color: AppColors.gray, height: 1.3)),
                ]),
              ]),
              const SizedBox(height: 28),
              const Divider(color: AppColors.whiteDim2, height: 1),
              const SizedBox(height: 20),
              _BookingDetail(label: 'Date',       value: 'To be confirmed by team'),
              _BookingDetail(label: 'Time',       value: 'To be confirmed by team'),
              _BookingDetail(label: 'Country',    value: 'United Kingdom 🇬🇧'),
              _BookingDetail(label: 'Consultant', value: 'Calmyaab Study Team'),
              _BookingDetail(label: 'Status',     value: '⏳ Awaiting team confirmation'),
              const SizedBox(height: 28),
              Text(
                'Our team will reach out on your WhatsApp number within 24 hours to confirm your slot.',
                style: AppTextStyles.body(14, color: AppColors.gray, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingDetail extends StatelessWidget {
  final String label, value;
  const _BookingDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        SizedBox(width: 100,
          child: Text(label, style: AppTextStyles.body(13, color: AppColors.gray, height: 1))),
        Expanded(child: Text(value,
          style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1))),
      ]),
    );
  }
}
