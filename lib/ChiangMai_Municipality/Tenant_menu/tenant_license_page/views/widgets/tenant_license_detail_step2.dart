// ============================================================================
// tenant_license_detail_step2.dart
// ============================================================================
// Step 2 — รูปภาพหลักฐาน (โหมดดูอย่างเดียว ไม่มีปุ่มอัปโหลด/แก้ไข/บันทึก)
// - ทุก widget ในไฟล์นี้เป็นของ step2 เอง (private) ไม่แชร์กับ step1
// - Responsive (mobile / tablet / desktop)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tenant_license_detail_models.dart';
import '../theme/tenant_license_theme.dart';
import '../../viewmodels/tenant_license_detail_view_model.dart';

class TenantLicenseDetailStep2 extends StatelessWidget {
  const TenantLicenseDetailStep2({super.key});

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
              _Step2SectionHeader(
                icon: Icons.image_rounded,
                title: 'รูปภาพหลักฐาน',
                color: LaColors.statusInfoFg,
              ),
              const SizedBox(height: LaSpace.xs),
              _Step2PhotoGrid(isMobile: isMobile, isTablet: isTablet),
              const SizedBox(height: LaSpace.md),
              _Step2SectionHeader(
                icon: Icons.history_rounded,
                title: 'ประวัติการตรวจสอบ',
                subtitle: 'ไทม์ไลน์การดำเนินการตรวจสอบ',
                color: LaColors.statusApprovedFg,
              ),
              const SizedBox(height: LaSpace.xs),
              const _Step2HistorySection(),
              const SizedBox(height: LaSpace.xs),
              const Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 14,
                    color: LaColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'คลิกที่รูปเพื่อดูภาพเต็มจอ',
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

// ============================================================================
// Section Header (เฉพาะ step2)
// ============================================================================

class _Step2SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;

  const _Step2SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 8),
                          Text(title, style: LaText.h2.copyWith(color: color)),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.only(left: 26),
                          child: Text(subtitle!, style: LaText.caption),
                        ),
                      ],
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

// ============================================================================
// Photo Grid — รูปหลักฐานจาก model TenantPhoto
// ============================================================================

class _Step2PhotoGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  const _Step2PhotoGrid({required this.isMobile, required this.isTablet});

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
          mainAxisExtent: 150,
        ),
        itemCount: tenantPhotos.length,
        itemBuilder: (_, i) => _Step2PhotoCard(photo: tenantPhotos[i]),
      ),
    );
  }
}

class _Step2PhotoCard extends StatelessWidget {
  final TenantPhoto photo;
  const _Step2PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    final hasImage = photo.imageUrl != null && photo.imageUrl!.isNotEmpty;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // โหมดดูอย่างเดียว — เปิดดูภาพเต็มจอ
        },
        child: Container(
          decoration: BoxDecoration(
            color: LaColors.surface,
            borderRadius: BorderRadius.circular(LaRadius.md),
            border: Border.all(color: LaColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LaSpace.md, vertical: LaSpace.sm),
                decoration: BoxDecoration(
                  color: LaColors.surfaceMuted,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(LaRadius.md),
                    topRight: Radius.circular(LaRadius.md),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: LaColors.statusInfoBg,
                        borderRadius: BorderRadius.circular(LaRadius.sm),
                      ),
                      child: Text(photo.ser,
                          style: LaText.caption.copyWith(
                              fontFamily: LaText.fontBold,
                              color: LaColors.statusInfoFg)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(photo.title,
                          style: LaText.bodyMuted.copyWith(
                              fontFamily: LaText.fontBold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.zoom_in_rounded,
                        size: 14, color: LaColors.textMuted),
                  ],
                ),
              ),
              // Image area
              Expanded(
                child: hasImage
                    ? Image.network(
                        photo.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _Step2ImagePlaceholder(),
                      )
                    : const _Step2ImagePlaceholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step2ImagePlaceholder extends StatelessWidget {
  const _Step2ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LaColors.surfaceMuted.withOpacity(.5),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 32, color: LaColors.textMuted),
          SizedBox(height: 6),
          Text('ยังไม่มีรูปภาพ', style: LaText.caption),
        ],
      ),
    );
  }
}

// ============================================================================
// History Section — ประวัติการตรวจสอบ (read-only timeline)
// ============================================================================

class _Step2HistorySection extends StatelessWidget {
  const _Step2HistorySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: _Step2Timeline(
        items: [
          _Step2TimelineItem(
            icon: Icons.check_circle_outline,
            color: LaColors.statusApprovedFg,
            title: 'รับคำร้อง',
            subtitle: 'เจ้าหน้าที่รับเรื่องและตรวจสอบเอกสารเบื้องต้น',
            date: '21 ส.ค. 2569 10:30',
          ),
          _Step2TimelineItem(
            icon: Icons.image_search_rounded,
            color: LaColors.statusInfoFg,
            title: 'ตรวจสอบข้อเท็จจริง',
            subtitle: 'ลงพื้นที่ตรวจสอบร้านค้าและถ่ายรูป',
            date: '23 ส.ค. 2569 14:15',
          ),
          _Step2TimelineItem(
            icon: Icons.edit_note_rounded,
            color: LaColors.statusPendingFg,
            title: 'รออนุมัติ',
            subtitle: 'เสนอผู้บังคับบัญชาเพื่อพิจารณา',
            date: '-',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Step2TimelineItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String date;
  final bool isLast;
  const _Step2TimelineItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.date,
    this.isLast = false,
  });
}

class _Step2Timeline extends StatelessWidget {
  final List<_Step2TimelineItem> items;
  const _Step2Timeline({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          _Step2TimelineRow(
            item: items[i],
            isLast: i == items.length - 1,
          ),
      ],
    );
  }
}

class _Step2TimelineRow extends StatelessWidget {
  final _Step2TimelineItem item;
  final bool isLast;
  const _Step2TimelineRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                    border: Border.all(color: item.color, width: 1),
                  ),
                  child: Icon(item.icon, size: 16, color: item.color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: LaColors.borderStrong,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: LaSpace.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: LaSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: LaText.body.copyWith(
                                fontFamily: LaText.fontBold, fontSize: 14)),
                      ),
                      Text(item.date,
                          style: LaText.caption.copyWith(
                              color: item.color, fontFamily: LaText.fontBold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: LaText.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
