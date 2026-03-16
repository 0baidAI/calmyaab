import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/calmyaab_button.dart';
import '../../../shared/widgets/section_wrapper.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  static const _faqs = [
    _Faq('Is payment refundable if I don\'t get an internship?',
        'We offer a 60-day satisfaction guarantee. If we\'re unable to match you with any opportunity within 60 days of purchase, we\'ll issue a full refund — no questions asked.'),
    _Faq('How long does CV delivery take?',
        'Our team delivers your professionally written CV within 24–48 hours after the bot has collected all your information. Standard turnaround is 24 hours for most orders.'),
    _Faq('What companies are in your internship network?',
        'We have MOUs with 50+ companies across tech, marketing, finance, media, and operations sectors in Pakistan. We continuously add new partners every month.'),
    _Faq('Is the study abroad consultation really free?',
        'Yes — the first consultation call is completely free. Our bot will collect your info and our team will arrange a call. Full application and visa support packages are available as paid services.'),
    _Faq('Which payment methods do you accept?',
        'We accept JazzCash, Easypaisa, and Debit/Credit cards (Visa & Mastercard) through our secure payment gateway. All transactions are encrypted and safe.'),
    _Faq('Can I get both internship access and CV service together?',
        'Absolutely! Many students buy both. We offer a bundle discount — contact us on WhatsApp and we\'ll set you up with a combined package at a reduced price.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > AppConstants.tabletBreak;

    return SectionWrapper(
      backgroundColor: AppColors.black,
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _FaqLeft()),
                const SizedBox(width: 80),
                Expanded(flex: 3, child: _FaqList(faqs: _faqs)),
              ],
            )
          : Column(
              children: [
                _FaqLeft(),
                const SizedBox(height: 48),
                _FaqList(faqs: _faqs),
              ],
            ),
    );
  }
}

class _FaqLeft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(tag: 'Got Questions?', title: 'WE\'VE GOT\nANSWERS'),
        const SizedBox(height: 16),
        Text(
          'Can\'t find what you\'re looking for? Reach us on WhatsApp or Instagram.',
          style: AppTextStyles.sectionDesc,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: [
            CalmyaabButton(label: 'WhatsApp Us', onTap: () {}, fontSize: 13),
            CalmyaabButton(label: 'Instagram', onTap: () {}, style: CButtonStyle.outline, fontSize: 13),
          ],
        ),
      ],
    );
  }
}

class _FaqList extends StatelessWidget {
  final List<_Faq> faqs;
  const _FaqList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: faqs
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _FaqItem(faq: f),
              ))
          .toList(),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final _Faq faq;
  const _FaqItem({required this.faq});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _expand;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _rotate = Tween<double>(begin: 0, end: 0.125).animate(_expand); // 45deg
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.whiteDim2, width: 1),
        borderRadius: BorderRadius.circular(6),
        color: _open ? AppColors.yellowDim2 : Colors.transparent,
      ),
      child: Column(
        children: [
          // Question row
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _toggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: AppTextStyles.body(15, color: _open ? AppColors.yellow : AppColors.white, weight: FontWeight.w600, height: 1.3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    RotationTransition(
                      turns: _rotate,
                      child: Text('+', style: AppTextStyles.body(20, color: AppColors.yellow, weight: FontWeight.w300, height: 1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Answer
          SizeTransition(
            sizeFactor: _expand,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(widget.faq.answer, style: AppTextStyles.bodySm),
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq {
  final String question, answer;
  const _Faq(this.question, this.answer);
}
