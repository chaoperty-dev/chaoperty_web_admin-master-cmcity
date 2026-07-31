// ============================================================================
// registration_search_bar.dart
// ============================================================================
// Search bar สำหรับกรองรายการลูกค้า
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/registration_theme.dart';
import '../../viewmodels/registration_view_model.dart';

class RegistrationSearchBar extends StatefulWidget {
  const RegistrationSearchBar({super.key});

  @override
  State<RegistrationSearchBar> createState() => _RegistrationSearchBarState();
}

class _RegistrationSearchBarState extends State<RegistrationSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegistrationViewModel>();
    _controller = TextEditingController(text: vm.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final vm = context.read<RegistrationViewModel>();
    vm.setSearch(value);
    vm.executeSearch();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrationViewModel>();
    return Container(
      decoration: RgDecor.softCard(),
      padding: const EdgeInsets.symmetric(
        horizontal: RgSpace.md,
        vertical: RgSpace.xs,
      ),
      child: Row(
        children: [
          // Field dropdown (เลือก column ที่จะค้น)
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: vm.searchField,
              iconSize: 16,
              isDense: true,
              style: RgText.body.copyWith(fontSize: 12),
              items: [
                for (final f in RegistrationViewModel.kSearchFields)
                  DropdownMenuItem<String>(
                    value: f['value'],
                    child: Text(f['label']!),
                  ),
              ],
              onChanged: (v) {
                if (v != null) vm.setSearchField(v);
              },
            ),
          ),
          Container(
            width: 1,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: RgColors.border,
          ),
          const Icon(Icons.search, size: 18, color: RgColors.textSecondary),
          const SizedBox(width: RgSpace.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              style: RgText.body.copyWith(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'พิมพ์คำค้น...',
                hintStyle: TextStyle(
                  color: RgColors.textMuted,
                  fontSize: 13,
                ),
              ),
              onSubmitted: _submit,
              onChanged: (v) =>
                  context.read<RegistrationViewModel>().setSearch(v),
            ),
          ),
          IconButton(
            tooltip: 'ค้นหา',
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            color: RgColors.primary,
            onPressed: () => _submit(_controller.text),
          ),
        ],
      ),
    );
  }
}
