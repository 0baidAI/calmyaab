import 'package:flutter/material.dart';
import '../../shared/widgets/calmyaab_navbar.dart';
import '../../shared/widgets/section_wrapper.dart';
import 'widgets/hero_section.dart';
import 'widgets/services_section.dart';
import 'widgets/how_it_works_section.dart';
import 'widgets/pricing_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/service_modal.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollCtrl = ScrollController();

  // Section keys for navbar scroll
  final _heroKey     = GlobalKey();
  final _servicesKey = GlobalKey();
  final _howKey      = GlobalKey();
  final _abroadKey   = GlobalKey();
  final _pricingKey  = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openModal(ServiceType type) => showServiceModal(context, type);

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // ── Main scroll ──
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                // 1. Hero
                SizedBox(
                  key: _heroKey,
                  child: HeroSection(
                    onExplore:    () => _scrollTo(_servicesKey),
                    onHowItWorks: () => _scrollTo(_howKey),
                  ),
                ),

                const YellowDivider(),

                // 2. Services
                SizedBox(
                  key: _servicesKey,
                  child: ServicesSection(
                    onInternship: () => _openModal(ServiceType.internship),
                    onCV:         () => _openModal(ServiceType.cv),
                    onAbroad:     () => _openModal(ServiceType.abroad),
                  ),
                ),

                const YellowDivider(),

                // 3. How It Works
                SizedBox(
                  key: _howKey,
                  child: const HowItWorksSection(),
                ),

                const YellowDivider(),

                // 4. Payment Methods (inline info block)
                _PaymentInfoSection(),

                const YellowDivider(),

                // 5. Study Abroad
                SizedBox(
                  key: _abroadKey,
                  child: _AbroadSection(
                    onBook: () => _openModal(ServiceType.abroad),
                  ),
                ),

                const YellowDivider(),

                // 6. Pricing
                SizedBox(
                  key: _pricingKey,
                  child: PricingSection(
                    onInternship: () => _openModal(ServiceType.internship),
                    onCV:         () => _openModal(ServiceType.cv),
                    onAbroad:     () => _openModal(ServiceType.abroad),
                  ),
                ),

                const YellowDivider(),

                // 7. FAQ
                const FaqSection(),

                // 8. CTA Banner
                CtaBanner(onGetStarted: () => _scrollTo(_servicesKey)),

                // 9. Footer
                const FooterSection(),
              ],
            ),
          ),

          // ── Fixed Navbar overlay ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: CalmyaabNavbar(
              scrollController: _scrollCtrl,
              heroKey:     _heroKey,
              servicesKey: _servicesKey,
              howKey:      _howKey,
              abroadKey:   _abroadKey,
              pricingKey:  _pricingKey,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Info Section ────────────────────────────────────────────────────

class _PaymentInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return SectionWrapper(
      backgroundColor: const Color(0xFF111111),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _PaymentText()),
                const SizedBox(width: 80),
                Expanded(child: _PaymentFlowCard()),
              ],
            )
          : Column(
              children: [
                _PaymentText(),
                const SizedBox(height: 48),
                _PaymentFlowCard(),
              ],
            ),
    );
  }
}

class _PaymentText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(tag: 'Payments', title: 'PAY YOUR\nWAY'),
        const SizedBox(height: 20),
        const Text(
          'We support all major Pakistani payment methods. No bank account required — pay with your mobile wallet instantly.',
          style: TextStyle(fontSize: 16, color: Color(0xFF888888), height: 1.7),
        ),
        const SizedBox(height: 40),
        ...[
          _PayMethod(icon: '💛', name: 'JazzCash',         desc: 'Pay directly from your JazzCash mobile account'),
          _PayMethod(icon: '🟢', name: 'Easypaisa',        desc: 'Instant payment via Easypaisa wallet'),
          _PayMethod(icon: '💳', name: 'Debit / Credit Card', desc: 'Visa and Mastercard accepted'),
        ].map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
      ],
    );
  }
}

class _PayMethod extends StatefulWidget {
  final String icon, name, desc;
  const _PayMethod({required this.icon, required this.name, required this.desc});

  @override
  State<_PayMethod> createState() => _PayMethodState();
}

class _PayMethodState extends State<_PayMethod> {
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
          color: _hovered ? const Color(0x1FFFD100) : const Color(0x0DFFD100),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _hovered ? const Color(0x4DFFD100) : const Color(0x1AFFD100),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD100),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFFF5F5F0))),
                const SizedBox(height: 2),
                Text(widget.desc, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentFlowCard extends StatelessWidget {
  const _PaymentFlowCard();

  static const _steps = [
    ('Click "Get Started"', 'Choose your service and click the payment button'),
    ('Secure Checkout', "You're redirected to our secure payment gateway (Safepay)"),
    ('Payment Confirmed', 'Instant confirmation via SMS and email'),
    ('Access Unlocked', 'Dashboard access granted immediately after payment'),
    ('Bot Activated', 'Our bot reaches out to collect your information'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1AFFD100)),
      ),
      child: Column(
        children: [
          const Text('PAYMENT FLOW',
            style: TextStyle(fontFamily: 'BebasNeue', fontSize: 22, color: Color(0xFFFFD100), letterSpacing: 1),
          ),
          const SizedBox(height: 28),
          ...List.generate(_steps.length, (i) => _FlowStep(
            num: '${i + 1}',
            title: _steps[i].$1,
            desc: _steps[i].$2,
            isLast: i == _steps.length - 1,
          )),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String num, title, desc;
  final bool isLast;
  const _FlowStep({required this.num, required this.title, required this.desc, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: const BoxDecoration(color: Color(0xFFFFD100), shape: BoxShape.circle),
            child: Center(
              child: Text(num, style: const TextStyle(color: Color(0xFF0A0A0A), fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFF5F5F0), fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFF888888), fontSize: 13, height: 1.5)),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0x0FFFFFFF), height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Abroad Section ───────────────────────────────────────────────────────────

class _AbroadSection extends StatelessWidget {
  final VoidCallback onBook;
  const _AbroadSection({required this.onBook});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return SectionWrapper(
      backgroundColor: const Color(0xFF111111),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            tag: 'Study Abroad',
            title: 'YOUR WORLD\nAWAITS',
            desc: "We'll connect you with the right university in the right country for your goals and budget.",
          ),
          const SizedBox(height: 64),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isDesktop ? 1.3 : 2.5,
            children: [
              _CountryCard(flag: '🇬🇧', name: 'UNITED KINGDOM', desc: 'Top universities, post-study work visas, and a strong Pakistani student community.', tags: const ['Work Visa', 'Scholarships', '1-Year Masters']),
              _CountryCard(flag: '🇩🇪', name: 'GERMANY',         desc: 'Free or low-cost tuition at world-class universities. Ideal for engineering students.', tags: const ['Low Tuition', 'Engineering', 'Job Market']),
              _CountryCard(flag: '🇲🇾', name: 'MALAYSIA',        desc: 'Affordable, English-medium education close to home with a smooth application process.', tags: const ['Affordable', 'Easy Visa', 'English Medium']),
              _CountryCard(flag: '🇨🇦', name: 'CANADA',          desc: 'PR pathway, diverse culture, and high employment rates for international graduates.', tags: const ['PR Pathway', 'Co-op Programs', 'High Salaries']),
              _CountryCard(flag: '🇦🇺', name: 'AUSTRALIA',       desc: '2–4 year post-study work rights with globally ranked universities.', tags: const ['Post-Study Work', 'Research', 'Quality of Life']),
              _RequestCard(onTap: onBook),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryCard extends StatefulWidget {
  final String flag, name, desc;
  final List<String> tags;
  const _CountryCard({required this.flag, required this.name, required this.desc, required this.tags});

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
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _hovered ? const Color(0x4DFFD100) : const Color(0x0FFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 14),
            Text(widget.name,
              style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 24, color: Color(0xFFF5F5F0), letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(widget.desc,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.6),
              maxLines: 3, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: widget.tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFD100),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0x33FFD100)),
                ),
                child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFFFD100), letterSpacing: 0.5)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final VoidCallback onTap;
  const _RequestCard({required this.onTap});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0x1AFFD100) : const Color(0x0DFFD100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? const Color(0x66FFD100) : const Color(0x1AFFD100),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('+', style: TextStyle(fontSize: 36, color: Color(0xFFFFD100))),
              const SizedBox(height: 12),
              const Text('MORE COMING',
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, color: Color(0xFFF5F5F0), letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              const Text('Tell us where you want to go.',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFD100),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0x33FFD100)),
                ),
                child: const Text('Request a Country',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFFD100)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
