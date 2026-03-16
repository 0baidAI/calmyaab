import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/student_model.dart';
import '../../../shared/widgets/calmyaab_button.dart';

class ProfileTab extends StatelessWidget {
  final StudentModel? student;
  final VoidCallback onSignOut;

  const ProfileTab({super.key, this.student, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.yellowBorder, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          (student?.name ?? 'S').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'BebasNeue', fontSize: 44,
                            color: AppColors.black, height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(student?.name ?? 'Student',
                      style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 32,
                        color: AppColors.white, letterSpacing: 1),
                    ),
                    Text(student?.email ?? '',
                      style: AppTextStyles.body(14, color: AppColors.gray, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Profile details
              _SectionTitle(title: 'PROFILE DETAILS'),
              const SizedBox(height: 16),
              _ProfileCard(
                items: [
                  _ProfileItem(icon: Icons.person_outline_rounded,   label: 'Full Name',   value: student?.name ?? '-'),
                  _ProfileItem(icon: Icons.email_outlined,           label: 'Email',       value: student?.email ?? '-'),
                  _ProfileItem(icon: Icons.phone_outlined,           label: 'Phone',       value: student?.phone ?? '-'),
                  _ProfileItem(icon: Icons.school_outlined,          label: 'University',  value: student?.university ?? '-'),
                  _ProfileItem(icon: Icons.book_outlined,            label: 'Field',       value: student?.field ?? '-'),
                ],
              ),
              const SizedBox(height: 32),

              // My services
              _SectionTitle(title: 'MY SERVICES'),
              const SizedBox(height: 16),
              _ProfileCard(
                items: [
                  _ProfileItem(
                    icon: Icons.work_outline_rounded,
                    label: 'Internship Access',
                    value: student?.hasPaid('internship') ?? false ? '✅ Active' : '🔒 Not purchased',
                  ),
                  _ProfileItem(
                    icon: Icons.description_outlined,
                    label: 'CV Service',
                    value: student?.hasPaid('cv') ?? false ? '✅ Active' : '🔒 Not purchased',
                  ),
                  _ProfileItem(
                    icon: Icons.flight_outlined,
                    label: 'Study Abroad',
                    value: student?.hasPaid('abroad') ?? false ? '✅ Booked' : '🔒 Not booked',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Account actions
              _SectionTitle(title: 'ACCOUNT'),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.black2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.whiteDim2),
                ),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _ActionTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.whiteDim2),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      onTap: onSignOut,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: Text('Calmyaab v1.0.0 · Made in Pakistan 🇵🇰',
                  style: AppTextStyles.body(12, color: AppColors.gray2, height: 1),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
      style: AppTextStyles.body(11, color: AppColors.yellow,
        weight: FontWeight.w700, letterSpacing: 3, height: 1),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<_ProfileItem> items;
  const _ProfileCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.whiteDim2),
      ),
      child: Column(
        children: List.generate(items.length, (i) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(children: [
                Icon(items[i].icon, size: 18, color: AppColors.gray),
                const SizedBox(width: 16),
                SizedBox(width: 120,
                  child: Text(items[i].label,
                    style: AppTextStyles.body(13, color: AppColors.gray, height: 1))),
                Expanded(child: Text(items[i].value,
                  style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1))),
              ]),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, color: AppColors.whiteDim2),
          ],
        )),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon, required this.label,
    required this.onTap, this.isDestructive = false,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? Colors.redAccent : AppColors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovered
              ? (widget.isDestructive ? Colors.redAccent.withOpacity(0.05) : AppColors.whiteDim2)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(children: [
            Icon(widget.icon, size: 18, color: _hovered ? color : AppColors.gray),
            const SizedBox(width: 16),
            Expanded(child: Text(widget.label,
              style: AppTextStyles.body(14, color: _hovered ? color : AppColors.white, height: 1))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray),
          ]),
        ),
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String label, value;
  const _ProfileItem({required this.icon, required this.label, required this.value});
}
