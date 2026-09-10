import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tenant_permit_models.dart';
import '../../viewmodels/tenant_license_view_model.dart';
import '../tenant_license_detail_page.dart';
import '../theme/tenant_license_theme.dart';

class TenantLicenseTable extends StatelessWidget {
  const TenantLicenseTable({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TenantLicenseViewModel>();
    final permits = vm.tenants;
    if (vm.isLoading && permits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (permits.isEmpty) {
      return _EmptyState(
        filtered: vm.searchQuery.isNotEmpty || vm.selectedZoneSer != '0',
        onRefresh: vm.refresh,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: [
              if (vm.isLoading) const LinearProgressIndicator(minHeight: 2),
              for (var i = 0; i < permits.length; i++) ...[
                _PermitCard(
                  permit: permits[i],
                  statusLabel: vm.statusLabel(permits[i].status),
                  onView: () => _openDetail(context, permits[i]),
                ),
                if (i < permits.length - 1) const SizedBox(height: LaSpace.sm),
              ],
            ],
          );
        }
        return Container(
          decoration: LaDecor.card(),
          child: Column(
            children: [
              const _TableHeader(),
              const Divider(height: 1, color: LaColors.border),
              if (vm.isLoading) const LinearProgressIndicator(minHeight: 2),
              for (var i = 0; i < permits.length; i++)
                _PermitRow(
                  permit: permits[i],
                  index: i,
                  statusLabel: vm.statusLabel(permits[i].status),
                  onView: () => _openDetail(context, permits[i]),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, TenantPermitListItem permit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TenantLicenseDetailPage.create(
          routeData: permit.uuid,
          title: permit.permitNo.isEmpty ? 'ข้อมูลใบอนุญาต' : permit.permitNo,
          tenant: permit,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LaSpace.md,
        vertical: LaSpace.md,
      ),
      decoration: const BoxDecoration(
        color: LaColors.surfaceMuted,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LaRadius.lg),
          topRight: Radius.circular(LaRadius.lg),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 110),
          Expanded(
              flex: 3,
              child: Text('เลขที่ใบอนุญาต', style: LaText.tableHeader)),
          Expanded(
              flex: 4,
              child: Text('ผู้ถือใบอนุญาต', style: LaText.tableHeader)),
          Expanded(flex: 2, child: Text('โซน', style: LaText.tableHeader)),
          Expanded(
              flex: 2, child: Text('รหัสพื้นที่', style: LaText.tableHeader)),
          Expanded(flex: 2, child: Text('วันมีผล', style: LaText.tableHeader)),
          Expanded(
              flex: 2, child: Text('วันหมดอายุ', style: LaText.tableHeader)),
          Expanded(
              flex: 2, child: Text('วันที่ออก', style: LaText.tableHeader)),
          Expanded(flex: 2, child: Text('สถานะ', style: LaText.tableHeader)),
        ],
      ),
    );
  }
}

class _PermitRow extends StatelessWidget {
  final TenantPermitListItem permit;
  final int index;
  final String statusLabel;
  final VoidCallback onView;

  const _PermitRow({
    required this.permit,
    required this.index,
    required this.statusLabel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final palette = StatusPalette.of(permit.status);
    return Container(
      color: index.isOdd ? LaColors.surfaceMuted : Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: LaSpace.md,
        vertical: LaSpace.md,
      ),
      child: Row(
        children: [
          SizedBox(width: 110, child: _ViewButton(onTap: onView)),
          Expanded(flex: 3, child: _Cell(permit.permitNo, mono: true)),
          Expanded(
              flex: 4,
              child: _Cell(permit.customerName, tooltip: permit.customerName)),
          Expanded(flex: 2, child: _Cell(permit.zoneId)),
          Expanded(flex: 2, child: _Cell(permit.lockCode, mono: true)),
          Expanded(
              flex: 2, child: _Cell(_formatDate(permit.validFrom), mono: true)),
          Expanded(
              flex: 2,
              child: _Cell(_formatDate(permit.validUntil), mono: true)),
          Expanded(
              flex: 2, child: _Cell(_formatDate(permit.issuedAt), mono: true)),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusPill(label: statusLabel, palette: palette))),
        ],
      ),
    );
  }
}

class _PermitCard extends StatelessWidget {
  final TenantPermitListItem permit;
  final String statusLabel;
  final VoidCallback onView;

  const _PermitCard({
    required this.permit,
    required this.statusLabel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final palette = StatusPalette.of(permit.status);
    return Container(
      decoration: LaDecor.card(),
      padding: const EdgeInsets.all(LaSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(LaRadius.sm),
                ),
                child: const Icon(Icons.description_outlined,
                    color: LaColors.primaryDark, size: 20),
              ),
              const SizedBox(width: LaSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(permit.permitNo.isEmpty ? '-' : permit.permitNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LaText.tableCell.copyWith(
                            fontFamily: LaText.fontBold,
                            fontWeight: FontWeight.w700)),
                    Text(
                        permit.customerName.isEmpty ? '-' : permit.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LaText.caption),
                  ],
                ),
              ),
              _StatusPill(label: statusLabel, palette: palette),
            ],
          ),
          const Divider(height: LaSpace.lg, color: LaColors.border),
          _InfoLine(
              label: 'โซน / รหัสพื้นที่',
              value:
                  '${permit.zoneId.isEmpty ? '-' : permit.zoneId} / ${permit.lockCode.isEmpty ? '-' : permit.lockCode}'),
          _InfoLine(
              label: 'วันมีผล - วันหมดอายุ',
              value:
                  '${_formatDate(permit.validFrom)} - ${_formatDate(permit.validUntil)}'),
          if (permit.issuedBy.isNotEmpty)
            _InfoLine(label: 'ออกโดย', value: permit.issuedBy),
          if (permit.failureMessage.isNotEmpty)
            _InfoLine(label: 'ข้อผิดพลาด', value: permit.failureMessage),
          const SizedBox(height: LaSpace.sm),
          Align(
              alignment: Alignment.centerRight,
              child: _ViewButton(onTap: onView)),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 145, child: Text(label, style: LaText.caption)),
          Expanded(
              child: Text(value.isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LaText.tableCell.copyWith(fontSize: 12))),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final bool mono;
  final String? tooltip;
  const _Cell(this.value, {this.mono = false, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Tooltip(
        message: tooltip ?? value,
        child: Text(
          value.isEmpty ? '-' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LaText.tableCell
              .copyWith(fontFamily: mono ? 'monospace' : LaText.fontRegular),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final StatusPalette palette;
  const _StatusPill({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: LaDecor.pill(palette.bg, palette.fg),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: LaText.fontBold,
              fontSize: 11,
              color: palette.fg,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.visibility_outlined, size: 14),
      label: const Text('เรียกดู'),
      style: TextButton.styleFrom(
          foregroundColor: LaColors.primaryDark,
          visualDensity: VisualDensity.compact),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool filtered;
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.filtered, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined,
                size: 48, color: LaColors.textMuted),
            const SizedBox(height: 8),
            Text(filtered ? 'ไม่พบใบอนุญาตที่ตรงกัน' : 'ยังไม่มีใบอนุญาต',
                style: LaText.bodyMuted),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('รีเฟรช')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(String raw) {
  if (raw.isEmpty) return '-';
  try {
    final date = DateTime.parse(raw).toLocal();
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year + 543}';
  } catch (_) {
    return '-';
  }
}
