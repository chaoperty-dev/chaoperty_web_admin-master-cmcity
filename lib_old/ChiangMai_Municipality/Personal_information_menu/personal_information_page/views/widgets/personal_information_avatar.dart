// ============================================================================
// personal_information_avatar.dart
// ============================================================================
// Avatar circle (initials) + meta (name / position / email)
// ============================================================================

import 'package:flutter/material.dart';
import '../../models/personal_information_models.dart';
import '../theme/personal_information_theme.dart';

class PersonalInformationAvatar extends StatelessWidget {
  final AdminProfile profile;
  const PersonalInformationAvatar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isMobile = PiSpace.isMobile(context);
    final avatarSize = isMobile ? 56.0 : 80.0;
    final avatarRadius = avatarSize / 2;

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PiColors.primaryLight,
        borderRadius: BorderRadius.circular(avatarRadius),
        border: Border.all(
          color: PiColors.primary.withOpacity(.25),
          width: 2,
        ),
      ),
      child: Text(
        profile.initials,
        style: TextStyle(
          fontSize: isMobile ? 20 : 28,
          fontWeight: FontWeight.w700,
          color: PiColors.primaryDark,
        ),
      ),
    );

    final meta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          profile.fullName.isEmpty ? '-' : profile.fullName,
          style: PiText.h2.copyWith(fontSize: isMobile ? 16 : 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          profile.positionName.isEmpty ? '-' : profile.positionName,
          style: PiText.bodyMuted.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (profile.email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.alternate_email_rounded,
                size: 14,
                color: PiColors.textMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  profile.email,
                  style: PiText.caption.copyWith(
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    // Mobile: stack vertical / Desktop: row
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: avatar),
          const SizedBox(height: PiSpace.md),
          meta,
        ],
      );
    }

    return Row(
      children: [
        avatar,
        const SizedBox(width: PiSpace.xl),
        Expanded(child: meta),
      ],
    );
  }
}
