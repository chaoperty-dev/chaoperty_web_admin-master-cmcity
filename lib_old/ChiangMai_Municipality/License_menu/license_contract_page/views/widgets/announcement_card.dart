// ============================================================================
// announcement_card.dart
// ============================================================================
// Alert-style card แสดงประกาศ (หรือ "ไม่พบประกาศ" ถ้าว่าง)
// - Modern gradient + glass icon + icon badge
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseContractViewModel>();
    final hasAnnouncement = vm.announcementMessage?.trim().isNotEmpty ?? false;

    return AnimatedContainer(
      duration: LcAnimations.medium,
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(LcSpace.md),
      decoration: BoxDecoration(
        gradient: hasAnnouncement
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF334155), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(LcRadius.lg),
        border: Border.all(
          color: hasAnnouncement
              ? const Color(0xFFA78BFA).withOpacity(.5)
              : const Color(0xFF475569).withOpacity(.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasAnnouncement
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFF334155))
                .withOpacity(.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(LcRadius.sm),
              border: Border.all(
                color: Colors.white.withOpacity(.25),
                width: 1,
              ),
            ),
            child: Icon(
              hasAnnouncement
                  ? Icons.campaign_rounded
                  : Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: LcSpace.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'ประกาศ',
                      style: LcText.h2.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: hasAnnouncement
                            ? Colors.white.withOpacity(.25)
                            : Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(LcRadius.pill),
                      ),
                      child: Text(
                        hasAnnouncement ? 'มีประกาศใหม่' : 'ไม่มีประกาศ',
                        style: LcText.caption.copyWith(
                          color: Colors.white,
                          fontFamily: LcText.fontBold,
                          fontSize: 9,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasAnnouncement
                      ? vm.announcementMessage!
                      : 'ไม่พบประกาศในขณะนี้',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: LcText.body.copyWith(
                    color: Colors.white.withOpacity(.92),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
