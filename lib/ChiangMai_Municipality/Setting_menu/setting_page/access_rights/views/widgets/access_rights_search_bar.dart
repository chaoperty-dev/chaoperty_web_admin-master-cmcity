// ============================================================================
// access_rights_search_bar.dart
// ============================================================================
// Search bar แบบ modern (focus ring + clear button + loading)
// - debounce 500ms ก่อน trigger filter
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/access_rights_theme.dart';
import '../../viewmodels/access_rights_view_model.dart';

class AccessRightsSearchBar extends StatefulWidget {
  const AccessRightsSearchBar({super.key});

  @override
  State<AccessRightsSearchBar> createState() => _AccessRightsSearchBarState();
}

class _AccessRightsSearchBarState extends State<AccessRightsSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AccessRightsViewModel>();
    if (vm.searchQuery.isNotEmpty) {
      _controller.text = vm.searchQuery;
    }
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final vm = context.read<AccessRightsViewModel>();
    vm.setSearch(value);
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      vm.executeSearch();
    });
  }

  void _onClear() {
    _controller.clear();
    _debounce?.cancel();
    final vm = context.read<AccessRightsViewModel>();
    vm.setSearch('');
    vm.executeSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccessRightsViewModel>();
    final hasText = _controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: ArAnimations.medium,
      curve: Curves.easeOut,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ArRadius.md),
        border: Border.all(
          color: _focused ? ArColors.primary : ArColors.border,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          if (_focused)
            BoxShadow(
              color: ArColors.primary.withOpacity(.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: ArAnimations.fast,
            child: Icon(
              _focused ? Icons.search_rounded : Icons.search,
              key: ValueKey(_focused),
              color: _focused ? ArColors.primary : ArColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                final vm2 = context.read<AccessRightsViewModel>();
                vm2.setSearch(v);
                vm2.executeSearch();
              },
              style: ArText.body,
              cursorColor: ArColors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hasText
                    ? 'ค้นหา "${_controller.text}"'
                    : 'ค้นหา... (ชื่อผู้ใช้, อีเมล, ตำแหน่ง, สิทธิ์)',
                hintStyle: ArText.bodyMuted.copyWith(
                  color: ArColors.textMuted,
                ),
              ),
            ),
          ),
          if (vm.isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(ArColors.primary),
              ),
            )
          else if (hasText)
            _IconChip(
              icon: Icons.close_rounded,
              tooltip: 'ล้าง',
              onTap: _onClear,
            ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconChip({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ArRadius.pill),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ArColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: ArColors.textSecondary),
        ),
      ),
    );
  }
}
