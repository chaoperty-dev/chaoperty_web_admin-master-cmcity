// ============================================================================
// personal_information_info_grid.dart
// ============================================================================
// Grid ของ info fields (2 cols on desktop, 1 col on mobile)
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/personal_information_theme.dart';

class InfoFieldData {
  final String label;
  final String value;
  final IconData icon;
  final bool mono;
  final Color? tone;
  const InfoFieldData({
    required this.label,
    required this.value,
    required this.icon,
    this.mono = false,
    this.tone,
  });
}

class PersonalInformationInfoGrid extends StatelessWidget {
  final List<InfoFieldData> fields;
  const PersonalInformationInfoGrid({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCols = constraints.maxWidth > 600;
        if (twoCols) {
          return Column(
            children: [
              for (int i = 0; i < fields.length; i += 2) ...[
                Row(
                  children: [
                    Expanded(child: _Field(data: fields[i])),
                    if (i + 1 < fields.length) ...[
                      const SizedBox(width: PiSpace.md),
                      Expanded(child: _Field(data: fields[i + 1])),
                    ],
                  ],
                ),
                if (i + 2 < fields.length) const SizedBox(height: PiSpace.md),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (int i = 0; i < fields.length; i++) ...[
              _Field(data: fields[i]),
              if (i < fields.length - 1) const SizedBox(height: PiSpace.md),
            ],
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final InfoFieldData data;
  const _Field({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PiSpace.md),
      decoration: PiDecor.softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                data.icon,
                size: 14,
                color: data.tone ?? PiColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(data.label, style: PiText.label),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: data.mono ? 'monospace' : null,
              color: data.tone ?? PiColors.textPrimary,
              fontWeight: data.mono ? FontWeight.w500 : FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
