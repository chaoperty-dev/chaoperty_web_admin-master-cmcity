// ============================================================================
// tenant_license_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบข้อมูลผู้เช่า + ร้านค้า + เอกสาร + ใบเสร็จ
// UI ใหม่แบบ modern card + responsive (mobile / tablet / desktop)
// ใช้ model ที่สร้างเองใน models/tenant_license_detail_models.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tenant_license_detail_models.dart';
import '../theme/tenant_license_theme.dart';
import '../../viewmodels/tenant_license_detail_view_model.dart';

class TenantLicenseDetailStep1 extends StatelessWidget {
  final dynamic tenant;
  const TenantLicenseDetailStep1({super.key, this.tenant});

  @override
  Widget build(BuildContext context) {
    context.watch<TenantLicenseDetailViewModel>();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? LaSpace.sm : LaSpace.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(
                icon: Icons.badge_rounded,
                title: 'ข้อมูลผู้เช่า',
                color: LaColors.primary,
              ),
              const SizedBox(height: LaSpace.sm),
              _PersonGrid(
                isMobile: isMobile,
                isTablet: isTablet,
                tenant: tenant,
              ),
              const SizedBox(height: LaSpace.md),
              _SectionTitle(
                icon: Icons.storefront_rounded,
                title: 'ข้อมูลร้านค้า',
                color: LaColors.statusInfoFg,
              ),
              const SizedBox(height: LaSpace.sm),
              _ShopGrid(
                isMobile: isMobile,
                isTablet: isTablet,
                tenant: tenant,
              ),
              const SizedBox(height: LaSpace.md),
              _SectionTitle(
                icon: Icons.description_rounded,
                title: 'เอกสาร',
                color: LaColors.statusPendingFg,
              ),
              const SizedBox(height: LaSpace.sm),
              const _DocumentList(),
              const SizedBox(height: LaSpace.md),
              _SectionTitle(
                icon: Icons.receipt_long_rounded,
                title: 'ใบเสร็จ',
                color: LaColors.statusApprovedFg,
              ),
              const SizedBox(height: LaSpace.sm),
              const _ReceiptTable(),
              const SizedBox(height: LaSpace.sm),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: LaColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ตรวจสอบข้อมูลให้ครบถ้วนก่อนกด "ถัดไป"',
                      style: LaText.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(LaRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LaRadius.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent bar (left)
              Container(width: 4, color: color),
              const SizedBox(width: LaSpace.md),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: LaSpace.xs),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 8),
                      Text(title, style: LaText.h2.copyWith(color: color)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final dynamic tenant;
  const _PersonGrid({
    required this.isMobile,
    required this.isTablet,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: LaSpace.sm,
          crossAxisSpacing: LaSpace.sm,
          mainAxisExtent: 54,
        ),
        itemCount: tenantPersonFields.length,
        itemBuilder: (_, i) {
          final f = tenantPersonFields[i];
          final resolved = f.valueResolver?.call(tenant) ?? f.detail;
          final display = resolved.isEmpty ? '-' : resolved;
          return _InfoTile(
            icon: _iconForPersonHint(f.iconHint),
            label: f.title,
            value: display,
          );
        },
      ),
    );
  }

  IconData _iconForPersonHint(IconHint hint) {
    switch (hint) {
      case IconHint.person:
        return Icons.person_rounded;
      case IconHint.badge:
        return Icons.badge_rounded;
      case IconHint.cake:
        return Icons.cake_rounded;
      case IconHint.flag:
        return Icons.flag_rounded;
      case IconHint.home:
        return Icons.home_rounded;
      case IconHint.phone:
        return Icons.phone_rounded;
      case IconHint.note:
        return Icons.note_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _ShopGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final dynamic tenant;
  const _ShopGrid({
    required this.isMobile,
    required this.isTablet,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    final subCrossAxisCount = isMobile ? 1 : (isTablet ? 3 : 3);
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        children: [
          for (int i = 0; i < tenantShopFields.length; i++) ...[
            if (i > 0) const SizedBox(height: LaSpace.sm),
            _ShopTile(
              shop: tenantShopFields[i],
              crossAxisCount: subCrossAxisCount,
              tenant: tenant,
            ),
          ],
        ],
      ),
    );
  }
}

class _ShopTile extends StatelessWidget {
  final TenantShopField shop;
  final int crossAxisCount;
  final dynamic tenant;
  const _ShopTile({
    required this.shop,
    required this.crossAxisCount,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    final hasSub = shop.detailsub.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted.withOpacity(.5),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForShopHint(shop.iconHint),
                  size: 14, color: LaColors.statusInfoFg),
              const SizedBox(width: 6),
              Text(
                shop.title,
                style: LaText.bodyMuted
                    .copyWith(fontFamily: LaText.fontBold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (hasSub)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: shop.detailsub.length >= 3
                    ? crossAxisCount
                    : (crossAxisCount >= 2 ? 2 : 1),
                mainAxisSpacing: LaSpace.xs,
                crossAxisSpacing: LaSpace.sm,
                mainAxisExtent: 48,
              ),
              itemCount: shop.detailsub.length,
              itemBuilder: (_, i) {
                final sub = shop.detailsub[i];
                final resolved = sub.valueResolver?.call(tenant) ?? sub.detail;
                final display = resolved.isEmpty ? '-' : resolved;
                return _InfoTile(
                  icon: Icons.subdirectory_arrow_right_rounded,
                  label: sub.titlesub,
                  value: display,
                  compact: true,
                );
              },
            )
          else
            Builder(builder: (_) {
              final resolved = shop.valueResolver?.call(tenant) ?? shop.detail;
              final display = resolved.isEmpty ? '-' : resolved;
              return _InfoTile(
                icon: Icons.label_outline_rounded,
                label: 'รายละเอียด',
                value: display,
              );
            }),
        ],
      ),
    );
  }

  IconData _iconForShopHint(IconHint hint) {
    switch (hint) {
      case IconHint.area:
        return Icons.crop_square_rounded;
      case IconHint.type:
        return Icons.category_rounded;
      case IconHint.storeName:
        return Icons.storefront_rounded;
      default:
        return Icons.label_outline_rounded;
    }
  }
}

class _DocumentList extends StatelessWidget {
  const _DocumentList();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        children: [
          for (int i = 0; i < tenantDocuments.length; i++) ...[
            if (i > 0) const SizedBox(height: LaSpace.sm),
            _DocRow(doc: tenantDocuments[i], isMobile: isMobile),
          ],
        ],
      ),
    );
  }
}

class _DocRow extends StatelessWidget {
  final TenantDocument doc;
  final bool isMobile;
  const _DocRow({required this.doc, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        color: LaColors.surfaceMuted.withOpacity(.5),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: LaColors.statusPendingBg,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              doc.ser,
              style: LaText.caption.copyWith(
                  fontFamily: LaText.fontBold, color: LaColors.statusPendingFg),
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Text(
              doc.title,
              style: LaText.body,
              maxLines: isMobile ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: LaSpace.sm),
          _ActionButton(
            icon: Icons.visibility_outlined,
            color: LaColors.statusInfoFg,
            tooltip: 'ดูตัวอย่าง',
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _ActionButton(
            icon: Icons.download_rounded,
            color: LaColors.statusApprovedFg,
            tooltip: 'ดาวน์โหลด',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReceiptTable extends StatelessWidget {
  const _ReceiptTable();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        children: [
          _ReceiptHeader(isMobile: isMobile),
          const Divider(height: 1, color: LaColors.border),
          for (int i = 0; i < tenantReceipts.length; i++)
            _ReceiptRow(
              receipt: tenantReceipts[i],
              isMobile: isMobile,
              isLast: i == tenantReceipts.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ReceiptHeader extends StatelessWidget {
  final bool isMobile;
  const _ReceiptHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      child: Row(
        children: [
          const SizedBox(
              width: 36,
              child: Text('#',
                  style: LaText.tableHeader, textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Text('เลขที่ใบเสร็จ',
                  style: LaText.tableHeader.copyWith(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('วันที่',
                  style: LaText.tableHeader.copyWith(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('สถานะ',
                  style: LaText.tableHeader.copyWith(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('ผู้ตรวจ',
                  style: LaText.tableHeader.copyWith(fontSize: 12))),
          SizedBox(width: 40, child: Text('', style: LaText.tableHeader)),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final TenantReceipt receipt;
  final bool isMobile;
  final bool isLast;
  const _ReceiptRow({
    required this.receipt,
    required this.isMobile,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: LaColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      child: Row(
        children: [
          SizedBox(
              width: 36,
              child: Text(receipt.ser,
                  style: LaText.tableCell, textAlign: TextAlign.center)),
          Expanded(
              flex: 3,
              child: Text(receipt.no,
                  style: LaText.tableCell
                      .copyWith(fontFamily: LaText.fontBold, fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text(receipt.date,
                  style: LaText.tableCell.copyWith(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LaColors.statusPendingBg,
                borderRadius: BorderRadius.circular(LaRadius.pill),
              ),
              child: Text(
                receipt.status,
                style: LaText.caption.copyWith(
                    color: LaColors.statusPendingFg,
                    fontFamily: LaText.fontBold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Text(receipt.verify,
                  style: LaText.tableCell.copyWith(fontSize: 12))),
          SizedBox(
            width: 40,
            child: _ActionButton(
              icon: Icons.visibility_outlined,
              color: LaColors.statusInfoFg,
              tooltip: 'ดู',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool compact;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: LaColors.surface,
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: LaColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: LaText.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: LaText.body.copyWith(
                      fontSize: compact ? 12 : 13, fontFamily: LaText.fontBold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}
