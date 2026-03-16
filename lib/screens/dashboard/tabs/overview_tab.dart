import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/student_model.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class OverviewTab extends StatelessWidget {
  final StudentModel? student;
  final Function(int) onTabChange;

  const OverviewTab({super.key, this.student, required this.onTabChange});

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
              // ── Welcome banner ───────────────────────────────────────────
              FadeInDown(
                child: _WelcomeBanner(student: student),
              ),
              const SizedBox(height: 32),

              // ── Service cards ────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text('MY SERVICES',
                  style: AppTextStyles.body(11, color: AppColors.yellow,
                    weight: FontWeight.w700, letterSpacing: 3, height: 1),
                ),
              ),
              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(child: _ServiceStatusCard(
                            icon: '🏢', title: 'Internship Access',
                            paid: student?.hasPaid('internship') ?? false,
                            activeDesc: 'You have access to 50+ partner companies',
                            lockedDesc: 'Unlock access to 50+ partner companies',
                            btnLabel: 'View Internships',
                            onTap: () => onTabChange(1),
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: _ServiceStatusCard(
                            icon: '📄', title: 'CV Service',
                            paid: student?.hasPaid('cv') ?? false,
                            activeDesc: 'Your CV is being crafted by our team',
                            lockedDesc: 'Get a professional CV built by our team',
                            btnLabel: 'View CV Status',
                            onTap: () => onTabChange(2),
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: _ServiceStatusCard(
                            icon: '🌍', title: 'Study Abroad',
                            paid: student?.hasPaid('abroad') ?? false,
                            activeDesc: 'Your consultation slot is booked',
                            lockedDesc: 'Book a free consultation with our team',
                            btnLabel: 'View Booking',
                            onTap: () => onTabChange(3),
                          )),
                        ],
                      )
                    : Column(
                        children: [
                          _ServiceStatusCard(
                            icon: '🏢', title: 'Internship Access',
                            paid: student?.hasPaid('internship') ?? false,
                            activeDesc: 'You have access to 50+ partner companies',
                            lockedDesc: 'Unlock access to 50+ partner companies',
                            btnLabel: 'View Internships',
                            onTap: () => onTabChange(1),
                          ),
                          const SizedBox(height: 16),
                          _ServiceStatusCard(
                            icon: '📄', title: 'CV Service',
                            paid: student?.hasPaid('cv') ?? false,
                            activeDesc: 'Your CV is being crafted by our team',
                            lockedDesc: 'Get a professional CV built by our team',
                            btnLabel: 'View CV Status',
                            onTap: () => onTabChange(2),
                          ),
                          const SizedBox(height: 16),
                          _ServiceStatusCard(
                            icon: '🌍', title: 'Study Abroad',
                            paid: student?.hasPaid('abroad') ?? false,
                            activeDesc: 'Your consultation slot is booked',
                            lockedDesc: 'Book a free consultation with our team',
                            btnLabel: 'View Booking',
                            onTap: () => onTabChange(3),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // ── Quick stats ──────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QUICK STATS',
                      style: AppTextStyles.body(11, color: AppColors.yellow,
                        weight: FontWeight.w700, letterSpacing: 3, height: 1),
                    ),
                    const SizedBox(height: 16),
                    isDesktop
                        ? Row(children: [
                            Expanded(child: _StatCard(number: '50+', label: 'Partner Companies', icon: '🏢')),
                            const SizedBox(width: 16),
                            Expanded(child: _StatCard(number: '0', label: 'Applications Sent', icon: '📨')),
                            const SizedBox(width: 16),
                            Expanded(child: _StatCard(number: '0', label: 'Interviews Scheduled', icon: '📅')),
                            const SizedBox(width: 16),
                            Expanded(child: _StatCard(number: '24h', label: 'CV Delivery Time', icon: '⚡')),
                          ])
                        : GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: const [
                              _StatCard(number: '50+', label: 'Partner Companies', icon: '🏢'),
                              _StatCard(number: '0',   label: 'Applications Sent', icon: '📨'),
                              _StatCard(number: '0',   label: 'Interviews',        icon: '📅'),
                              _StatCard(number: '24h', label: 'CV Delivery',       icon: '⚡'),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Recent activity ──────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RECENT ACTIVITY',
                      style: AppTextStyles.body(11, color: AppColors.yellow,
                        weight: FontWeight.w700, letterSpacing: 3, height: 1),
                    ),
                    const SizedBox(height: 16),
                    _ActivityItem(
                      icon: '🎉', title: 'Account Created',
                      desc: 'Welcome to Calmyaab! Start by purchasing a service.',
                      time: 'Just now',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Welcome Banner ────────────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final StudentModel? student;
  const _WelcomeBanner({this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.yellow.withOpacity(0.12), AppColors.yellow.withOpacity(0.04)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR DASHBOARD',
                  style: AppTextStyles.body(11, color: AppColors.yellow,
                    weight: FontWeight.w700, letterSpacing: 3, height: 1),
                ),
                const SizedBox(height: 10),
                Text('Welcome, ${student?.name ?? 'Student'}!',
                  style: const TextStyle(
                    fontFamily: 'BebasNeue', fontSize: 36,
                    color: AppColors.white, letterSpacing: 1, height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  student?.university != null
                      ? '${student!.university} · ${student!.field}'
                      : 'Complete your profile to get started',
                  style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4),
                ),
              ],
            ),
          ),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (student?.name ?? 'S').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'BebasNeue', fontSize: 32,
                  color: AppColors.black, height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Status Card ───────────────────────────────────────────────────────
class _ServiceStatusCard extends StatefulWidget {
  final String icon, title, activeDesc, lockedDesc, btnLabel;
  final bool paid;
  final VoidCallback onTap;

  const _ServiceStatusCard({
    required this.icon, required this.title, required this.paid,
    required this.activeDesc, required this.lockedDesc,
    required this.btnLabel, required this.onTap,
  });

  @override
  State<_ServiceStatusCard> createState() => _ServiceStatusCardState();
}

class _ServiceStatusCardState extends State<_ServiceStatusCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.paid
                ? (_hovered ? AppColors.yellow : AppColors.yellowBorder)
                : AppColors.whiteDim2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.icon, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                _StatusBadge(paid: widget.paid),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.title,
              style: const TextStyle(
                fontFamily: 'BebasNeue', fontSize: 22,
                color: AppColors.white, letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.paid ? widget.activeDesc : widget.lockedDesc,
              style: AppTextStyles.body(13, color: AppColors.gray, height: 1.5),
            ),
            const SizedBox(height: 20),
            CalmyaabButton(
              label: widget.paid ? widget.btnLabel : 'Purchase →',
              onTap: widget.onTap,
              style: widget.paid ? CButtonStyle.ghost : CButtonStyle.primary,
              width: double.infinity,
              height: 44,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool paid;
  const _StatusBadge({required this.paid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: paid
            ? Colors.greenAccent.withOpacity(0.1)
            : AppColors.gray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: paid
              ? Colors.greenAccent.withOpacity(0.3)
              : AppColors.gray.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: paid ? Colors.greenAccent : AppColors.gray,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(paid ? 'Active' : 'Locked',
            style: AppTextStyles.body(11,
              color: paid ? Colors.greenAccent : AppColors.gray,
              weight: FontWeight.w600, height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String number, label, icon;
  const _StatCard({required this.number, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(number,
            style: const TextStyle(
              fontFamily: 'BebasNeue', fontSize: 36,
              color: AppColors.yellow, letterSpacing: 1, height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.body(12, color: AppColors.gray, height: 1.3)),
        ],
      ),
    );
  }
}

// ── Activity Item ─────────────────────────────────────────────────────────────
class _ActivityItem extends StatelessWidget {
  final String icon, title, desc, time;
  const _ActivityItem({required this.icon, required this.title, required this.desc, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.yellowDim,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body(14, weight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.body(13, color: AppColors.gray, height: 1.4)),
              ],
            ),
          ),
          Text(time, style: AppTextStyles.body(12, color: AppColors.gray2, height: 1)),
        ],
      ),
    );
  }
}
