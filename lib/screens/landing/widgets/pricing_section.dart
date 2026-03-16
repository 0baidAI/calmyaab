import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/section_wrapper.dart';

class PricingSection extends StatelessWidget {
  final VoidCallback onInternship;
  final VoidCallback onCV;
  final VoidCallback onAbroad;

  const PricingSection({
    super.key,
    required this.onInternship,
    required this.onCV,
    required this.onAbroad,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppConstants.tabletBreak;

    return SectionWrapper(
      backgroundColor: AppColors.black2,
      child: Column(
        children: [
          SectionHeader(
            tag: 'Transparent Pricing',
            title: 'SIMPLE,\nHONEST PRICES',
            desc: 'No hidden fees. No subscriptions you didn\'t ask for. Pay for exactly what you need.',
            alignment: CrossAxisAlignment.center,
          ),
          const SizedBox(height: 64),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _PriceCard(
                      service: 'Internship', name: 'ACCESS PASS',
                      amount: AppConstants.internshipPrice, period: '3 months access',
                      features: const ['50+ partner companies', 'CV submission portal', 'Application tracking', 'New listings monthly', 'Email support'],
                      btnLabel: 'Get Access →', onTap: onInternship,
                    )),
                    const SizedBox(width: 20),
                    Expanded(child: _PriceCard(
                      service: 'CV Service', name: 'STANDARD CV',
                      amount: AppConstants.cvStandardPrice, period: 'one-time payment',
                      features: const ['2-page professional CV', 'Cover letter included', 'Human-crafted by our team', '2 free revisions', 'Delivered in 24–48 hrs'],
                      btnLabel: 'Build My CV →', onTap: onCV,
                      featured: true,
                    )),
                    const SizedBox(width: 20),
                    Expanded(child: _PriceCard(
                      service: 'Study Abroad', name: 'CONSULTATION',
                      amount: 0, period: 'first call is free',
                      features: const ['Free first consultation', 'Country & university guidance', 'Bot books your meeting', 'Application support (paid)', 'Visa prep guidance (paid)'],
                      btnLabel: 'Book Free Call →', onTap: onAbroad,
                    )),
                  ],
                )
              : Column(
                  children: [
                    _PriceCard(
                      service: 'Internship', name: 'ACCESS PASS',
                      amount: AppConstants.internshipPrice, period: '3 months',
                      features: const ['50+ partner companies', 'CV submission', 'Application tracking'],
                      btnLabel: 'Get Access →', onTap: onInternship,
                    ),
                    const SizedBox(height: 20),
                    _PriceCard(
                      service: 'CV Service', name: 'STANDARD CV',
                      amount: AppConstants.cvStandardPrice, period: 'one-time',
                      features: const ['2-page CV + Cover Letter', 'Human-crafted', '2 free revisions'],
                      btnLabel: 'Build My CV →', onTap: onCV, featured: true,
                    ),
                    const SizedBox(height: 20),
                    _PriceCard(
                      service: 'Study Abroad', name: 'CONSULTATION',
                      amount: 0, period: 'free',
                      features: const ['Free first call', 'Country guidance', 'Bot books meeting'],
                      btnLabel: 'Book Free Call →', onTap: onAbroad,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  final String service, name, period, btnLabel;
  final int amount;
  final List<String> features;
  final VoidCallback onTap;
  final bool featured;

  const _PriceCard({
    required this.service, required this.name, required this.amount,
    required this.period, required this.features, required this.btnLabel,
    required this.onTap, this.featured = false,
  });

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: widget.featured
              ? AppColors.black3
              : AppColors.black3,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.featured
                ? (_hovered ? AppColors.yellow : AppColors.yellow.withOpacity(0.6))
                : (_hovered ? AppColors.yellowBorder : AppColors.whiteDim2),
            width: widget.featured ? 1.5 : 1,
          ),
          gradient: widget.featured
              ? LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.black3, AppColors.yellow.withOpacity(0.04)],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.featured)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('POPULAR',
                    style: AppTextStyles.body(10, color: AppColors.black, weight: FontWeight.w700, letterSpacing: 1, height: 1),
                  ),
                ),
              ),
            if (widget.featured) const SizedBox(height: 16),

            Text(widget.service.toUpperCase(),
              style: AppTextStyles.body(12, color: AppColors.yellow, weight: FontWeight.w700, letterSpacing: 2, height: 1),
            ),
            const SizedBox(height: 10),
            Text(widget.name,
              style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 30, color: AppColors.white, letterSpacing: 1),
            ),
            const SizedBox(height: 20),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.amount > 0) ...[
                  Text('PKR ', style: AppTextStyles.body(16, color: AppColors.yellow, weight: FontWeight.w700, height: 1.3)),
                  Text('${widget.amount}',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: AppColors.yellow, height: 1),
                  ),
                ] else
                  Text('FREE',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: AppColors.yellow, height: 1),
                  ),
              ],
            ),
            Text(widget.period, style: AppTextStyles.body(13, color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 28),

            // Features
            ...widget.features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text('✦', style: AppTextStyles.body(11, color: AppColors.yellow, height: 1)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f, style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4))),
                  const Divider(),
                ],
              ),
            )),
            const SizedBox(height: 32),

            CalmyaabButton(
              label: widget.btnLabel,
              onTap: widget.onTap,
              style: widget.featured ? CButtonStyle.primary : CButtonStyle.ghost,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
