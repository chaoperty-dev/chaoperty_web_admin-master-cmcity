// ============================================================================
// registration_detail_step1.dart
// ============================================================================
// Step 1 — ข้อมูลร้านค้าและผู้ติดต่อ (READ-ONLY)
// Layout: เหมือน registration_add_step1 (section card + icon labels)
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../../Model/GetCustomer_Model.dart';
import '../theme/registration_theme.dart';

class RegistrationDetailStep1 extends StatelessWidget {
  final CustomerModel? customer;
  const RegistrationDetailStep1({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final c = customer;
    final width = MediaQuery.of(context).size.width;
    final twoCol = width >= 700;

    if (c == null) {
      return Center(
        child: Text('ไม่พบข้อมูล', style: LaText.h2),
      );
    }

    final type = c.type ?? '-';
    final isPersonal = type.contains('ส่วนตัว') || type.contains('บุคคลธรรมดา');
    final businessLabel = isPersonal ? 'ชื่อ-นามสกุล' : 'ชื่อผู้เช่า/บริษัท';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionCard(
                icon: Icons.badge_outlined,
                title: 'ประเภทข้อมูลลูกค้า',
                subtitle: 'ประเภทที่ลงทะเบียนไว้',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [LaColors.primary, LaColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(LaRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPersonal
                                ? Icons.person_outline
                                : Icons.storefront_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.lg),
              _sectionCard(
                icon: Icons.storefront_outlined,
                title: 'ข้อมูลร้านค้าและผู้ติดต่อ',
                subtitle: 'รายละเอียดที่ลูกค้าลงทะเบียนไว้',
                child: _grid(twoCol, [
                  _valueRow(
                    icon: Icons.store_mall_directory_outlined,
                    label: 'ชื่อร้านค้า',
                    value: c.scname ?? '-',
                  ),
                  _valueRow(
                    icon: Icons.business_outlined,
                    label: businessLabel,
                    value: c.cname ?? '-',
                  ),
                  _valueRow(
                    icon: Icons.account_circle_outlined,
                    label: 'ผู้ติดต่อ',
                    value: c.attn ?? '-',
                  ),
                  _valueRow(
                    icon: Icons.phone_outlined,
                    label: 'เบอร์โทร',
                    value: c.tel ?? '-',
                  ),
                  _valueRow(
                    icon: Icons.email_outlined,
                    label: 'อีเมล',
                    value: c.email ?? '-',
                    fullWidth: true,
                  ),
                ]),
              ),
            ],
          ),
        ),
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
