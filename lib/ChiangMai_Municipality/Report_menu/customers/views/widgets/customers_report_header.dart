// ============================================================================
// customers_report_header.dart
// ============================================================================
// Header แบบ gradient — คล้าย Area_menu
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/customers_report_theme.dart';

class CustomersReportHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int? totalCount;
  final int? selectedCount;
  final VoidCallback onDownload;
  final bool isExporting;

  const CustomersReportHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.totalCount,
    this.selectedCount,
    required this.onDownload,
    required this.isExporting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: CrDecor.headerGradient(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CrColors.primary.withOpacity(.18),
              borderRadius: BorderRadius.circular(CrRadius.md),
              border: Border.all(
                color: CrColors.primaryLight.withOpacity(.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: CrColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: CrSpace.md),
          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CUSTOMER REPORT',
                  style: CrText.label.copyWith(
                    color: CrColors.primaryLight,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: CrText.h1.copyWith(
                    color: CrColors.textInverse,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: CrText.caption.copyWith(
                      color: Colors.white.withOpacity(.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Download button
          _DownloadButton(
            onPressed: onDownload,
            isLoading: isExporting,
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  const _DownloadButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: CrAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isLoading
                ? CrColors.surfaceMuted
                : (_hover ? CrColors.primaryDark : CrColors.primary),
            borderRadius: BorderRadius.circular(CrRadius.pill),
            boxShadow: [
              if (!widget.isLoading && _hover)
                BoxShadow(
                  color: CrColors.primary.withOpacity(.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: widget.isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(
                            CrColors.textSecondary),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.isLoading ? 'กำลังส่งออก...' : 'ดาวน์โหลด Excel',
                style: const TextStyle(
                  fontFamily: CrText.fontBold,
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

