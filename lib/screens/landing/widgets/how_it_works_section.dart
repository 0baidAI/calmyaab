import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/section_wrapper.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const _steps = [
    _Step(number: '1', title: 'Choose a Service',    desc: 'Select the service that fits your need — internship access, CV building, or study abroad guidance.'),
    _Step(number: '2', title: 'Complete Payment',    desc: 'Pay securely via JazzCash, Easypaisa, or card through our trusted payment gateway.'),
    _Step(number: '3', title: 'Bot Collects Info',   desc: 'Our smart bot gathers your details in minutes and sends everything to the right team.'),
    _Step(number: '4', title: 'We Deliver Results',  desc: 'Get matched to internships, receive your handcrafted CV, or get a consultation call booked.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppConstants.tabletBreak;

    return SectionWrapper(
      backgroundColor: AppColors.black,
      child: Column(
        children: [
          SectionHeader(
            tag: 'The Process',
            title: 'HOW IT WORKS',
            desc: 'Simple, fast, and transparent. From payment to placement in just a few steps.',
            alignment: CrossAxisAlignment.center,
          ),
          const SizedBox(height: 80),
          isDesktop
              ? _DesktopSteps()
              : _MobileSteps(),
        ],
      ),
    );
  }
}

class _DesktopSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Connector line
        Positioned(
          top: 36,
          left: MediaQuery.of(context).size.width * 0.12,
          right: MediaQuery.of(context).size.width * 0.12,
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.yellow,
                Color(0x33FFD100),
                AppColors.yellow,
              ]),
            ),
          ),
        ),
        Row(
          children: HowItWorksSection._steps
              .map((s) => Expanded(child: _StepCard(step: s)))
              .toList(),
        ),
      ],
    );
  }
}

class _MobileSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: HowItWorksSection._steps
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _StepCardMobile(step: s),
              ))
          .toList(),
    );
  }
}

class _StepCard extends StatefulWidget {
  final _Step step;
  const _StepCard({required this.step});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            // Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _hovered ? AppColors.yellow : AppColors.black2,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.yellow, width: 2),
                boxShadow: _hovered
                    ? [BoxShadow(color: AppColors.yellow.withOpacity(0.35), blurRadius: 32)]
                    : [BoxShadow(color: AppColors.yellow.withOpacity(0.15), blurRadius: 16)],
              ),
              child: Center(
                child: Text(
                  widget.step.number,
                  style: TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 28,
                    color: _hovered ? AppColors.black : AppColors.yellow,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              widget.step.title,
              style: AppTextStyles.body(16, color: AppColors.white, weight: FontWeight.w700, height: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.step.desc,
              style: AppTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCardMobile extends StatelessWidget {
  final _Step step;
  const _StepCardMobile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.black2,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          child: Center(
            child: Text(step.number,
              style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 22, color: AppColors.yellow),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(step.title, style: AppTextStyles.body(16, weight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 8),
              Text(step.desc, style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step {
  final String number, title, desc;
  const _Step({required this.number, required this.title, required this.desc});
}
