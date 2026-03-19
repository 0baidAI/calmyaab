import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final uid       = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome banner ─────────────────────────────────────────
              FadeInDown(child: _WelcomeBanner(student: student)),
              const SizedBox(height: 32),

              // ── Real stats ─────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text('MY STATS',
                    style: AppTextStyles.body(11, color: AppColors.yellow,
                        weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              ),
              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: _RealStats(uid: uid, isDesktop: isDesktop),
              ),
              const SizedBox(height: 32),

              // ── Services ───────────────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text('MY SERVICES',
                    style: AppTextStyles.body(11, color: AppColors.yellow,
                        weight: FontWeight.w700, letterSpacing: 3, height: 1)),
              ),
              const SizedBox(height: 16),

              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: isDesktop
                    ? Row(children: [
                        Expanded(child: _ServiceCard(
                          icon: '🏢', title: 'Internships',
                          desc: 'Browse & apply to partner company internships',
                          btnLabel: 'Browse Internships',
                          onTap: () => onTabChange(1),
                          color: AppColors.yellow,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _ServiceCard(
                          icon: '📄', title: 'My CV',
                          desc: 'Track your CV applications and status',
                          btnLabel: 'View Applications',
                          onTap: () => onTabChange(2),
                          color: AppColors.yellow,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _ServiceCard(
                          icon: '🌍', title: 'Study Abroad',
                          desc: 'FREE consultation with our partner agencies',
                          btnLabel: 'Book Free Session',
                          onTap: () => onTabChange(3),
                          color: Colors.greenAccent,
                          isFree: true,
                        )),
                      ])
                    : Column(children: [
                        _ServiceCard(
                          icon: '🏢', title: 'Internships',
                          desc: 'Browse & apply to partner company internships',
                          btnLabel: 'Browse Internships',
                          onTap: () => onTabChange(1),
                          color: AppColors.yellow,
                        ),
                        const SizedBox(height: 16),
                        _ServiceCard(
                          icon: '📄', title: 'My CV',
                          desc: 'Track your CV applications and status',
                          btnLabel: 'View Applications',
                          onTap: () => onTabChange(2),
                          color: AppColors.yellow,
                        ),
                        const SizedBox(height: 16),
                        _ServiceCard(
                          icon: '🌍', title: 'Study Abroad',
                          desc: 'FREE consultation with our partner agencies',
                          btnLabel: 'Book Free Session',
                          onTap: () => onTabChange(3),
                          color: Colors.greenAccent,
                          isFree: true,
                        ),
                      ]),
              ),
              const SizedBox(height: 32),

              // ── Recent applications ────────────────────────────────────
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _RecentApplications(uid: uid),
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
          colors: [AppColors.yellow.withOpacity(0.12),
              AppColors.yellow.withOpacity(0.04)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowBorder),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR DASHBOARD',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                    weight: FontWeight.w700, letterSpacing: 3, height: 1)),
            const SizedBox(height: 10),
            Text('Welcome, ${student?.name ?? 'Student'}!',
                style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
                    color: AppColors.white, letterSpacing: 1, height: 1)),
            const SizedBox(height: 8),
            Text(
              student?.university != null
                  ? '${student!.university} · ${student!.field}'
                  : 'Complete your profile to get started',
              style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4),
            ),
          ],
        )),
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(
              color: AppColors.yellow, shape: BoxShape.circle),
          child: Center(child: Text(
            (student?.name ?? 'S').substring(0, 1).toUpperCase(),
            style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 32,
                color: AppColors.black, height: 1),
          )),
        ),
      ]),
    );
  }
}

// ── Real Stats from Firestore ─────────────────────────────────────────────────
class _RealStats extends StatelessWidget {
  final String uid;
  final bool isDesktop;
  const _RealStats({required this.uid, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('internship_applications')
          .where('student_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, appSnap) {
        final apps     = appSnap.data?.docs ?? [];
        final total    = apps.length;
        final pending  = apps.where((d) =>
            (d.data() as Map)['status'] == 'pending').length;
        final accepted = apps.where((d) =>
            (d.data() as Map)['status'] == 'accepted').length;
        final rejected = apps.where((d) =>
            (d.data() as Map)['status'] == 'rejected').length;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('study_abroad_bookings')
              .where('student_uid', isEqualTo: uid)
              .snapshots(),
          builder: (context, bookSnap) {
            final bookings = bookSnap.data?.docs.length ?? 0;

            final stats = [
              _StatData('📨', '$total', 'Applications'),
              _StatData('⏳', '$pending', 'Pending'),
              _StatData('✅', '$accepted', 'Accepted'),
              _StatData('🌍', '$bookings', 'Consultations'),
            ];

            return isDesktop
                ? Row(children: stats.asMap().entries.map((e) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: e.key == 0 ? 0 : 8,
                          right: e.key == stats.length - 1 ? 0 : 8),
                      child: _StatCard(data: e.value),
                    ),
                  )).toList())
                : GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: stats.map((s) => _StatCard(data: s)).toList(),
                  );
          },
        );
      },
    );
  }
}

class _StatData {
  final String icon, number, label;
  const _StatData(this.icon, this.number, this.label);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

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
          Text(data.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(data.number,
              style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 36,
                  color: AppColors.yellow, letterSpacing: 1, height: 1)),
          const SizedBox(height: 4),
          Text(data.label,
              style: AppTextStyles.body(12, color: AppColors.gray, height: 1.3)),
        ],
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final String icon, title, desc, btnLabel;
  final VoidCallback onTap;
  final Color color;
  final bool isFree;

  const _ServiceCard({
    required this.icon, required this.title, required this.desc,
    required this.btnLabel, required this.onTap, required this.color,
    this.isFree = false,
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.black3 : AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered ? AppColors.yellowBorder : AppColors.whiteDim2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(widget.icon, style: const TextStyle(fontSize: 28)),
              const Spacer(),
              if (widget.isFree)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.3)),
                  ),
                  child: Text('FREE',
                      style: AppTextStyles.body(10,
                          color: Colors.greenAccent,
                          weight: FontWeight.w700, height: 1)),
                ),
            ]),
            const SizedBox(height: 16),
            Text(widget.title,
                style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 22,
                    color: AppColors.white, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(widget.desc,
                style: AppTextStyles.body(13, color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 20),
            CalmyaabButton(
              label: widget.btnLabel,
              onTap: widget.onTap,
              width: double.infinity, height: 44, fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Applications ───────────────────────────────────────────────────────
class _RecentApplications extends StatelessWidget {
  final String uid;
  const _RecentApplications({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('internship_applications')
          .where('student_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final apps = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RECENT ACTIVITY',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                    weight: FontWeight.w700, letterSpacing: 3, height: 1)),
            const SizedBox(height: 16),

            if (apps.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.black2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.whiteDim2),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.yellowDim,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.yellowBorder),
                    ),
                    child: const Center(child: Text('🎉',
                        style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Created',
                          style: AppTextStyles.body(14,
                              weight: FontWeight.w600, height: 1.2)),
                      Text('Welcome to Calmyaab! Browse internships to get started.',
                          style: AppTextStyles.body(13,
                              color: AppColors.gray, height: 1.4)),
                    ],
                  )),
                ]),
              )
            else
              ...apps.take(5).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                final color = status == 'accepted'
                    ? Colors.greenAccent
                    : status == 'rejected'
                        ? Colors.redAccent
                        : Colors.orangeAccent;
                final icon = status == 'accepted' ? '✅'
                    : status == 'rejected' ? '❌' : '⏳';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.black2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.whiteDim2),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Center(child: Text(icon,
                          style: const TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['internship_title'] ?? '',
                            style: AppTextStyles.body(14,
                                weight: FontWeight.w600, height: 1.2)),
                        Text(data['company_name'] ?? '',
                            style: AppTextStyles.body(12,
                                color: AppColors.yellow, height: 1.2)),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        status == 'accepted' ? 'Accepted'
                            : status == 'rejected' ? 'Rejected'
                            : 'Pending',
                        style: AppTextStyles.body(11, color: color,
                            weight: FontWeight.w600, height: 1),
                      ),
                    ),
                  ]),
                );
              }),
          ],
        );
      },
    );
  }
}