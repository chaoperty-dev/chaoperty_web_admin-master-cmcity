// ============================================================================
// position_page.dart
// ============================================================================
// View — หน้า "จัดการตำแหน่ง" (Setting > จัดการตำแหน่ง)
// - Header + ช่องค้นหา + รายการตำแหน่งเป็นการ์ดกางได้
// - แต่ละการ์ด: อวาตารตัวย่อ + ชื่อตำแหน่ง + code + นับสิทธิ์ที่เปิด
// - กาง → checkbox สิทธิ์ทั้งหมด (toggle = POST /admin/role-positions)
// - error → snack แดง
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/position_matrix_model.dart';
import '../viewmodels/position_view_model.dart';

class PositionPage extends StatelessWidget {
  const PositionPage._({super.key});

  /// Factory สร้าง Page พร้อม Provider — เรียกจาก setting hub
  static Widget create() {
    return ChangeNotifierProvider<PositionViewModel>(
      create: (_) => PositionViewModel(),
      child: const PositionPage._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            const _ErrorListener(),
            const _SearchBar(),
            const Expanded(child: _PositionList()),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: const Color(0xFF374151),
          ),
          const SizedBox(width: 4),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.badge_outlined,
              size: 20,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'จัดการตำแหน่ง',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'กำหนดสิทธิ์การเข้าถึงระบบของแต่ละตำแหน่ง',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.2,
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

// ─────────────────────────────────────────────────────────────────────────
// Error snack listener — โชว์ snack เมื่อ vm.errorMessage ไม่ว่าง
// ─────────────────────────────────────────────────────────────────────────
class _ErrorListener extends StatefulWidget {
  const _ErrorListener();

  @override
  State<_ErrorListener> createState() => _ErrorListenerState();
}

class _ErrorListenerState extends State<_ErrorListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.watch<PositionViewModel>();
    final error = vm.errorMessage;
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFB91C1C),
            behavior: SnackBarBehavior.floating,
          ),
        );
        vm.clearError();
      });
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ─────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<PositionViewModel>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        onChanged: vm.setSearch,
        decoration: InputDecoration(
          hintText: 'ค้นหาตำแหน่ง / สิทธิ์...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: Color(0xFF6B7280)),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB)),
          ),
        ),
      ),
    );
  }
}
// ----------------------------------------------------------------------------
// List of position cards
// ----------------------------------------------------------------------------
class _PositionList extends StatelessWidget {
  const _PositionList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PositionViewModel>();
    final rows = vm.filtered;

    if (vm.isLoading && rows.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }
    if (rows.isEmpty) {
      // "ไม่พบตำแหน่งที่ค้นหา"
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge_outlined, size: 44, color: Color(0xFFD1D5DB)),
            SizedBox(height: 8),
            Text(
              'ไม่พบตำแหน่งที่ค้นหา',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _PositionCard(position: rows[i]),
    );
  }
}

// ----------------------------------------------------------------------------
// Position card — expandable, shows role checkboxes when expanded
// ----------------------------------------------------------------------------
class _PositionCard extends StatefulWidget {
  final PositionMatrixModel position;
  const _PositionCard({required this.position});

  @override
  State<_PositionCard> createState() => _PositionCardState();
}

class _PositionCardState extends State<_PositionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PositionViewModel>();
    final position = widget.position;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // header row (tap to expand/collapse)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        const Color(0xFF2563EB).withValues(alpha: .12),
                    child: Text(
                      _initials(position.displayName),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          position.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // enabled-count pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${position.enabledCount}/${position.roles.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // expanded: all role checkboxes
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 0,
                    children: [
                      for (final role in position.roles)
                        _RoleChip(
                          label: role.nameTh,
                          enabled: role.enabled,
                          saving: vm.isSaving(position.id, role.roleId),
                          onToggle: () => vm.toggleRole(position, role),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+'))..removeWhere((e) => e.isEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

// ----------------------------------------------------------------------------
// Role checkbox chip
// ----------------------------------------------------------------------------
class _RoleChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool saving;
  final VoidCallback onToggle;

  const _RoleChip({
    required this.label,
    required this.enabled,
    required this.saving,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? const Color(0xFF1E40AF) : const Color(0xFF6B7280);
    return SizedBox(
      width: 260,
      child: InkWell(
        onTap: saving ? null : onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: saving
                    ? const Padding(
                        padding: EdgeInsets.all(3),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Checkbox(
                        value: enabled,
                        onChanged: (_) => onToggle(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        activeColor: const Color(0xFF1E40AF),
                        side: const BorderSide(color: Color(0xFF9CA3AF)),
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: enabled ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
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