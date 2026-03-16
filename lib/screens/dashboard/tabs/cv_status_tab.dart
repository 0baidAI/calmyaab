import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class CvStatusTab extends StatelessWidget {
  const CvStatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    // TODO: Replace with real Firestore data
    const hasCvOrder = false;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: hasCvOrder ? _CvOrderStatus() : _NoCvOrder(),
        ),
      ),
    );
  }
}

// ── No order yet ──────────────────────────────────────────────────────────────
class _NoCvOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.yellowDim,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellowBorder, width: 2),
          ),
          child: const Center(child: Text('📄', style: TextStyle(fontSize: 36))),
        ),
        const SizedBox(height: 24),
        const Text('NO CV ORDER YET',
          style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32,
            color: AppColors.white, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        Text(
          'Get a professionally crafted CV from our expert team.\nDelivered within 24-48 hours.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(15, color: AppColors.gray, height: 1.7),
        ),
        const SizedBox(height: 32),

        // Packages
        _CvPackages(),
      ],
    );
  }
}

class _CvPackages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    final packages = [
      _Package(name: 'BASIC',    price: 'PKR 1,200', features: ['1-page CV', '1 revision', '48hr delivery'], popular: false),
      _Package(name: 'STANDARD', price: 'PKR 1,800', features: ['2-page CV', 'Cover letter', '2 revisions', '24hr delivery'], popular: true),
      _Package(name: 'PREMIUM',  price: 'PKR 2,500', features: ['2-page CV', 'Cover letter', 'LinkedIn profile', '3 revisions', '24hr delivery'], popular: false),
    ];

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: packages.map((p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _PackageCard(package: p),
              ),
            )).toList(),
          )
        : Column(
            children: packages.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PackageCard(package: p),
            )).toList(),
          );
  }
}

class _PackageCard extends StatelessWidget {
  final _Package package;
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: package.popular ? AppColors.yellow : AppColors.whiteDim2,
          width: package.popular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (package.popular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('POPULAR',
                style: AppTextStyles.body(10, color: AppColors.black,
                  weight: FontWeight.w700, letterSpacing: 1, height: 1),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(package.name,
            style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 28,
              color: AppColors.white, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(package.price,
            style: AppTextStyles.body(24, color: AppColors.yellow,
              weight: FontWeight.w700, height: 1),
          ),
          const SizedBox(height: 20),
          ...package.features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              const Text('→', style: TextStyle(color: AppColors.yellow, fontSize: 12)),
              const SizedBox(width: 10),
              Text(f, style: AppTextStyles.body(13, color: AppColors.gray, height: 1)),
            ]),
          )),
          const SizedBox(height: 24),
          CalmyaabButton(
            label: 'Order Now →',
            onTap: () {},
            style: package.popular ? CButtonStyle.primary : CButtonStyle.ghost,
            width: double.infinity,
            height: 44,
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}

// ── Has order ─────────────────────────────────────────────────────────────────
class _CvOrderStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MY CV ORDER',
          style: TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
            color: AppColors.white, letterSpacing: 2, height: 1),
        ),
        const SizedBox(height: 24),

        // Progress tracker
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.black2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.yellowBorder),
          ),
          child: Column(
            children: [
              const Text('CV PROGRESS',
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 22,
                  color: AppColors.yellow, letterSpacing: 1),
              ),
              const SizedBox(height: 28),
              _ProgressStep(step: 1, label: 'Order Placed',     done: true,  active: false),
              _ProgressStep(step: 2, label: 'Info Collected',   done: true,  active: false),
              _ProgressStep(step: 3, label: 'CV Being Written', done: false, active: true),
              _ProgressStep(step: 4, label: 'Review & Polish',  done: false, active: false),
              _ProgressStep(step: 5, label: 'Delivered! 🎉',    done: false, active: false, isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final int step;
  final String label;
  final bool done, active;
  final bool isLast;

  const _ProgressStep({
    required this.step, required this.label,
    required this.done, required this.active,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: done ? AppColors.yellow : active ? AppColors.yellowDim : AppColors.black3,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done || active ? AppColors.yellow : AppColors.gray2,
                  width: 2,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColors.black)
                    : Text('$step',
                        style: TextStyle(
                          fontFamily: 'BebasNeue', fontSize: 16, height: 1,
                          color: active ? AppColors.yellow : AppColors.gray2,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 32,
                color: done ? AppColors.yellow : AppColors.whiteDim2),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Text(label,
            style: AppTextStyles.body(14,
              color: done || active ? AppColors.white : AppColors.gray,
              weight: active ? FontWeight.w600 : FontWeight.w400,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _Package {
  final String name, price;
  final List<String> features;
  final bool popular;
  const _Package({required this.name, required this.price, required this.features, required this.popular});
}
