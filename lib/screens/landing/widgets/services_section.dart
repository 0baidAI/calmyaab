import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/section_wrapper.dart';

class ServicesSection extends StatelessWidget {
  final VoidCallback onInternship;
  final VoidCallback onCV;
  final VoidCallback onAbroad;

  const ServicesSection({
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
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SectionHeader(
                  tag: 'What We Offer',
                  title: 'THREE WAYS\nWE HELP YOU',
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    'From internship placements to CV building to study abroad — Calmyaab is your all-in-one student success platform.',
                    style: AppTextStyles.sectionDesc,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 64),

          // Cards
          if (isDesktop)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _ServiceCard(
                    number: '01', icon: '🏢',
                    title: 'INTERNSHIP\nACCESS',
                    desc: 'Pay once and get direct access to our network of MOU-partner companies actively looking for interns like you.',
                    price: 'PKR ${AppConstants.internshipPrice.toStringAsFixed(0)}',
                    priceSub: '/ 3 months access',
                    features: const ['Access to 50+ partner companies', 'Submit CV directly to employers', 'Track your application status', 'New companies added monthly'],
                    btnLabel: 'Get Internship Access →',
                    onTap: onInternship,
                  )),
                  const SizedBox(width: 2),
                  Expanded(child: _ServiceCard(
                    number: '02', icon: '📄',
                    title: 'CV\nBUILDING',
                    desc: 'Tell our bot your story. Our expert team handcrafts a professional, ATS-ready CV tailored to your goals.',
                    price: 'PKR ${AppConstants.cvBasicPrice.toStringAsFixed(0)}',
                    priceSub: '/ starting price',
                    features: const ['Human-crafted, not AI-generated', 'Bot collects your info (5 min)', 'Delivered within 24–48 hours', 'Tailored to your target industry'],
                    btnLabel: 'Build My CV →',
                    onTap: onCV,
                  )),
                  const SizedBox(width: 2),
                  Expanded(child: _ServiceCard(
                    number: '03', icon: '🌍',
                    title: 'STUDY\nABROAD',
                    desc: 'Want to study internationally? Our bot gathers your details and our team arranges a free consultation call.',
                    price: 'Free',
                    priceSub: '/ first consultation',
                    features: const ['UK, Germany, Malaysia & more', 'Bot books a meeting for you', 'Expert guidance from our team', 'Full package support available'],
                    btnLabel: 'Book Consultation →',
                    onTap: onAbroad,
                  )),
                ],
              ),
            )
          else
            Column(
              children: [
                _ServiceCard(
                  number: '01', icon: '🏢',
                  title: 'INTERNSHIP ACCESS',
                  desc: 'Pay once and get direct access to our network of MOU-partner companies.',
                  price: 'PKR ${AppConstants.internshipPrice.toStringAsFixed(0)}',
                  priceSub: '/ 3 months access',
                  features: const ['50+ partner companies', 'Submit CV to employers', 'Application tracking'],
                  btnLabel: 'Get Internship Access →',
                  onTap: onInternship,
                ),
                const SizedBox(height: 16),
                _ServiceCard(
                  number: '02', icon: '📄',
                  title: 'CV BUILDING',
                  desc: 'Our expert team handcrafts a professional CV tailored to your goals.',
                  price: 'PKR ${AppConstants.cvBasicPrice.toStringAsFixed(0)}',
                  priceSub: '/ starting price',
                  features: const ['Human-crafted', 'Delivered in 24–48 hours', '2 free revisions'],
                  btnLabel: 'Build My CV →',
                  onTap: onCV,
                ),
                const SizedBox(height: 16),
                _ServiceCard(
                  number: '03', icon: '🌍',
                  title: 'STUDY ABROAD',
                  desc: 'Our team arranges a free consultation for your study abroad journey.',
                  price: 'Free',
                  priceSub: '/ first consultation',
                  features: const ['UK, Germany, Malaysia & more', 'Bot books your meeting', 'Expert guidance'],
                  btnLabel: 'Book Consultation →',
                  onTap: onAbroad,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final String number, icon, title, desc, price, priceSub;
  final List<String> features;
  final String btnLabel;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.number, required this.icon, required this.title,
    required this.desc, required this.price, required this.priceSub,
    required this.features, required this.btnLabel, required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          border: Border(
            top: BorderSide(
              color: _hovered ? AppColors.yellow : Colors.transparent,
              width: 3,
            ),
            left:   const BorderSide(color: AppColors.whiteDim2, width: 1),
            right:  const BorderSide(color: AppColors.whiteDim2, width: 1),
            bottom: const BorderSide(color: AppColors.whiteDim2, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number + Icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon box
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _hovered
                        ? AppColors.yellow.withOpacity(0.2)
                        : AppColors.yellowDim,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _hovered
                          ? AppColors.yellow.withOpacity(0.4)
                          : AppColors.yellowBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 24))),
                ),
                // Background number
                Text(
                  widget.number,
                  style: TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 80,
                    color: _hovered
                        ? AppColors.yellow.withOpacity(0.12)
                        : AppColors.yellow.withOpacity(0.07),
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(widget.title,
              style: const TextStyle(
                fontFamily: 'BebasNeue', fontSize: 28,
                color: AppColors.white, letterSpacing: 1, height: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // Desc
            Text(widget.desc, style: AppTextStyles.bodySm),
            const SizedBox(height: 24),

            // Price
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: widget.price,
                  style: AppTextStyles.body(22, color: AppColors.yellow, weight: FontWeight.w700, height: 1),
                ),
                TextSpan(
                  text: '  ${widget.priceSub}',
                  style: AppTextStyles.body(13, color: AppColors.gray, height: 1),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // Features
            ...widget.features.map((f) => _FeatureItem(text: f)),
            const SizedBox(height: 32),

            // Button — stretch to bottom
            CalmyaabButton(
              label: widget.btnLabel,
              onTap: widget.onTap,
              style: CButtonStyle.ghost,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text('→', style: AppTextStyles.body(12, color: AppColors.yellow, height: 1)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodySm)),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
