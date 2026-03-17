import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }

        final docs = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(children: [
                _StatBox(label: 'Total Students', value: '${docs.length}', icon: '👥'),
                const SizedBox(width: 16),
                _StatBox(label: 'Paid Students',
                  value: '${docs.where((d) => ((d.data() as Map)['paid_services'] as List?)?.isNotEmpty == true).length}',
                  icon: '💰'),
                const SizedBox(width: 16),
                _StatBox(label: 'This Month',
                  value: '${docs.where((d) {
                    final ts = (d.data() as Map)['created_at'] as int?;
                    if (ts == null) return false;
                    final date = DateTime.fromMillisecondsSinceEpoch(ts);
                    final now = DateTime.now();
                    return date.month == now.month && date.year == now.year;
                  }).length}',
                  icon: '📅'),
              ]),
              const SizedBox(height: 32),

              // Table header
              Text('ALL STUDENTS',
                style: AppTextStyles.body(11, color: AppColors.yellow,
                  weight: FontWeight.w700, letterSpacing: 3, height: 1),
              ),
              const SizedBox(height: 16),

              // Table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.whiteDim2),
                ),
                child: docs.isEmpty
                    ? _EmptyState(message: 'No students registered yet')
                    : Column(
                        children: [
                          // Header row
                          _TableHeader(),
                          const Divider(height: 1, color: AppColors.whiteDim2),
                          // Rows
                          ...docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return _StudentRow(data: data, uid: doc.id);
                          }),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Expanded(flex: 2, child: Text('NAME', style: _headerStyle)),
        Expanded(flex: 3, child: Text('EMAIL', style: _headerStyle)),
        Expanded(flex: 2, child: Text('UNIVERSITY', style: _headerStyle)),
        Expanded(flex: 2, child: Text('SERVICES', style: _headerStyle)),
        Expanded(flex: 1, child: Text('JOINED', style: _headerStyle)),
      ]),
    );
  }

  TextStyle get _headerStyle => AppTextStyles.body(11,
    color: AppColors.gray, weight: FontWeight.w700, letterSpacing: 1.5, height: 1);
}

class _StudentRow extends StatefulWidget {
  final Map<String, dynamic> data;
  final String uid;
  const _StudentRow({required this.data, required this.uid});

  @override
  State<_StudentRow> createState() => _StudentRowState();
}

class _StudentRowState extends State<_StudentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final services = List<String>.from(widget.data['paid_services'] ?? []);
    final ts = widget.data['created_at'] as int?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts)
        : DateTime.now();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered ? AppColors.yellowDim2 : Colors.transparent,
        child: Column(
          children: [
            const Divider(height: 1, color: AppColors.whiteDim2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                // Name
                Expanded(flex: 2, child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.yellowDim, shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(
                      (widget.data['name'] ?? 'S').substring(0, 1).toUpperCase(),
                      style: AppTextStyles.body(14, color: AppColors.yellow,
                        weight: FontWeight.w700, height: 1),
                    )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.data['name'] ?? '-',
                    style: AppTextStyles.body(13, weight: FontWeight.w600, height: 1),
                    overflow: TextOverflow.ellipsis)),
                ])),

                // Email
                Expanded(flex: 3, child: Text(widget.data['email'] ?? '-',
                  style: AppTextStyles.body(13, color: AppColors.gray, height: 1),
                  overflow: TextOverflow.ellipsis)),

                // University
                Expanded(flex: 2, child: Text(widget.data['university'] ?? '-',
                  style: AppTextStyles.body(13, color: AppColors.gray, height: 1),
                  overflow: TextOverflow.ellipsis)),

                // Services
                Expanded(flex: 2, child: Wrap(spacing: 4, runSpacing: 4,
                  children: services.isEmpty
                      ? [Text('None', style: AppTextStyles.body(11, color: AppColors.gray2, height: 1))]
                      : services.map((s) => _ServiceBadge(service: s)).toList(),
                )),

                // Date
                Expanded(flex: 1, child: Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: AppTextStyles.body(12, color: AppColors.gray2, height: 1))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  final String service;
  const _ServiceBadge({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.yellowDim,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.yellowBorder),
      ),
      child: Text(service,
        style: AppTextStyles.body(10, color: AppColors.yellow,
          weight: FontWeight.w600, height: 1),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value, icon;
  const _StatBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.black2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.whiteDim2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontFamily: 'BebasNeue',
            fontSize: 36, color: AppColors.yellow, letterSpacing: 1, height: 1)),
          Text(label, style: AppTextStyles.body(12, color: AppColors.gray, height: 1.3)),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Text(message,
          style: AppTextStyles.body(14, color: AppColors.gray, height: 1)),
      ),
    );
  }
}
