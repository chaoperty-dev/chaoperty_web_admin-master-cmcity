// ============================================================================
// registration_detail_step2.dart
// ============================================================================
// Step 2 — ข้อมูลส่วนบุคคล + ที่อยู่ (READ-ONLY)
// Layout: เหมือน registration_add_step2 (section card + icon labels)
// - TAX / วันเกิด / อายุ
// - ที่อยู่ + สรุป auto-built
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../Model/GetCustomer_Model.dart';
import '../theme/registration_theme.dart';

class RegistrationDetailStep2 extends StatelessWidget {
  final CustomerModel? customer;
  const RegistrationDetailStep2({super.key, required this.customer});

  // ─── Helper: คำนวณอายุจาก yyyy-MM-dd ───
  ({int years, int months, int days})? _calculateAge(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final birth = DateTime.tryParse(raw);
    if (birth == null) return null;

    final now = DateTime.now();
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) return null;
    return (years: years, months: months, days: days);
  }

  // ─── Helper: format date ───
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = customer;
    final width = MediaQuery.of(context).size.width;
    final twoCol = width >= 700;

    if (c == null) {
      return Center(child: Text('ไม่พบข้อมูล', style: LaText.h2));
    }

    final birth = c.birth;
    final age = _calculateAge(birth);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionCard(
                icon: Icons.person_outline,
                title: 'ข้อมูลส่วนบุคคล',
                subtitle: 'เลขประจำตัวผู้เสียภาษีและวันเกิด',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _grid(twoCol, [
                      _valueRow(
                        icon: Icons.badge_outlined,
                        label: 'เลขประจำตัวผู้เสียภาษี',
                        value: c.tax ?? '-',
                      ),
                      _valueRow(
                        icon: Icons.cake_outlined,
                        label: 'วันเกิด',
                        value: _formatDate(birth),
                      ),
                    ]),
                    const SizedBox(height: LaSpace.sm),
                    _ageSummary(age),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.lg),
              _sectionCard(
                icon: Icons.location_on_outlined,
                title: 'ที่อยู่',
                subtitle: 'ที่อยู่ที่ลงทะเบียนไว้',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _valueRow(
                      icon: Icons.home_outlined,
                      label: 'ที่อยู่',
                      value: (c.addr1 ?? '').trim().isEmpty
                          ? (c.addr2 ?? '—')
                          : (c.addr1 ?? '—'),
                      fullWidth: true,
                    ),
                    _valueRow(
                      icon: Icons.markunread_mailbox_outlined,
                      label: 'รหัสไปรษณีย์',
                      value: c.zip ?? '—',
                    ),
                    const SizedBox(height: LaSpace.md),
                    _addressSummary((c.addr1 ?? '').trim().isNotEmpty
                        ? c.addr1 ?? ''
                        : (c.addr2 ?? '')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Age summary (read-only) ───
  Widget _ageSummary(({int years, int months, int days})? age) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LaColors.primaryLight.withOpacity(.18),
            LaColors.primary.withOpacity(.06),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.primary.withOpacity(.30), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: LaColors.primary,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: const Icon(Icons.cake, size: 16, color: Colors.white),
          ),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: LaColors.primary,
                        borderRadius: BorderRadius.circular(LaRadius.pill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 10, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'อายุ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  age == null
                      ? 'ไม่ได้ระบุวันเกิด'
                      : '${age.years} ปี ${age.months} เดือน ${age.days} วัน',
                  style: TextStyle(
                    color:
                        age != null ? LaColors.textPrimary : LaColors.textMuted,
                    fontSize: 14,
                    fontWeight: age != null ? FontWeight.w700 : FontWeight.w500,
                    fontStyle:
                        age == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (age != null)
            Text(
              '${age.years}',
              style: TextStyle(
                fontSize: 28,
                fontFamily: LaText.fontBold,
                fontWeight: FontWeight.w900,
                color: LaColors.primary,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Address summary (read-only) ───
  Widget _addressSummary(String summary) {
    final hasContent = summary.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LaColors.primary.withOpacity(.06),
            LaColors.primaryLight.withOpacity(.30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.primary.withOpacity(.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LaColors.primary,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 11, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'ที่อยู่',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: LaText.fontBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.sm),
          Text(
            hasContent ? summary : 'ไม่ได้ระบุที่อยู่',
            style: TextStyle(
              color: hasContent ? LaColors.textPrimary : LaColors.textMuted,
              fontSize: 14,
              fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section card ───
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: LaDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
                LaSpace.md, LaSpace.md, LaSpace.md, LaSpace.sm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: LaColors.border.withOpacity(.5), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LaColors.primary.withOpacity(.25),
                        LaColors.primary.withOpacity(.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                    border: Border.all(
                        color: LaColors.primary.withOpacity(.30), width: 1),
                  ),
                  child: Icon(icon, size: 18, color: LaColors.primaryDark),
                ),
                const SizedBox(width: LaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: LaText.h2),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: LaText.bodyMuted.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LaSpace.md),
            child: child,
          ),
        ],
      ),
    );
  }

  // ─── Grid ───
  Widget _grid(bool twoCol, List<Widget> children) {
    if (!twoCol) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 16),
            Expanded(child: children[i + 1]),
          ],
        ));
      } else {
        rows.add(Row(children: [Expanded(child: children[i])]));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  // ─── Label + value row (read-only) ───
  Widget _valueRow({
    required IconData icon,
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    final isEmpty = value.isEmpty || value == '-';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: LaColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: LaText.body.copyWith(
                  fontSize: 13,
                  color: LaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: LaColors.surfaceMuted.withOpacity(.6),
              borderRadius: BorderRadius.circular(LaRadius.sm),
              border: Border.all(color: LaColors.border),
            ),
            child: Text(
              isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 14,
                color: isEmpty ? LaColors.textMuted : LaColors.textPrimary,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
