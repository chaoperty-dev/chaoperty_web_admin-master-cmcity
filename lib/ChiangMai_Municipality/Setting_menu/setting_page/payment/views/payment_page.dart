import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payment_method_model.dart';
import '../viewmodels/payment_method_view_model.dart';
import '../../views/theme/setting_page_theme.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage._();

  static Widget create() => ChangeNotifierProvider(
        create: (_) => PaymentMethodViewModel(),
        child: const _PaymentMethodsBody(),
      );

  @override
  Widget build(BuildContext context) => create();
}

class _PaymentMethodsBody extends StatelessWidget {
  const _PaymentMethodsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentMethodViewModel>();
    final visibleItems = vm.pagedItems;
    return Scaffold(
      backgroundColor: SetColors.surface,
      body: SafeArea(
        child: Padding(
          padding: SetResponsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PaymentHeader(
                total: vm.filteredItems.length,
                onBack: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                onAdd: () => _showForm(context),
              ),
              const SizedBox(height: SetSpace.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  final mobile = constraints.maxWidth < 560;
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _PaymentSearchBar(),
                        const SizedBox(height: SetSpace.sm),
                        Row(
                          children: [
                            if (!mobile)
                              _ViewModeToggle(
                                mode: vm.viewMode,
                                onChanged: vm.setViewMode,
                              ),
                            const Spacer(),
                            const _PaymentPagination(compact: true),
                          ],
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      const Expanded(child: _PaymentSearchBar()),
                      const SizedBox(width: SetSpace.md),
                      _ViewModeToggle(
                        mode: vm.viewMode,
                        onChanged: vm.setViewMode,
                      ),
                      const SizedBox(width: SetSpace.md),
                      const _PaymentPagination(),
                    ],
                  );
                },
              ),
              const SizedBox(height: SetSpace.lg),
              Expanded(
                child: vm.loading && vm.items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null && vm.items.isEmpty
                        ? _ErrorState(message: vm.error!, onRetry: vm.load)
                        : visibleItems.isEmpty
                            ? _PaymentEmptyState(
                                hasSearch: vm.searchQuery.trim().isNotEmpty,
                                onAction: vm.searchQuery.trim().isNotEmpty
                                    ? vm.clearSearch
                                    : vm.load,
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  if (vm.viewMode ==
                                      PaymentMethodViewMode.card) {
                                    return RefreshIndicator(
                                      onRefresh: vm.load,
                                      child: GridView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.only(
                                          bottom: SetSpace.lg,
                                        ),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              constraints.maxWidth >= 1180
                                                  ? 3
                                                  : constraints.maxWidth >= 760
                                                      ? 2
                                                      : 1,
                                          crossAxisSpacing: SetSpace.md,
                                          mainAxisSpacing: SetSpace.md,
                                          mainAxisExtent: 230,
                                        ),
                                        itemCount: visibleItems.length,
                                        itemBuilder: (context, index) =>
                                            _PaymentMethodCard(
                                          item: visibleItems[index],
                                          onEdit: () => _showForm(
                                              context, visibleItems[index]),
                                        ),
                                      ),
                                    );
                                  }

                                  final tableWidth = constraints.maxWidth < 980
                                      ? 980.0
                                      : constraints.maxWidth;
                                  return Scrollbar(
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: tableWidth,
                                        child: SingleChildScrollView(
                                          child: _PaymentMethodTable(
                                            items: visibleItems,
                                            onEdit: (item) =>
                                                _showForm(context, item),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showForm(BuildContext context,
      [PaymentMethodModel? item]) async {
    final vm = context.read<PaymentMethodViewModel>();
    final result = await showDialog<_PaymentMethodFormResult>(
      context: context,
      builder: (_) => _PaymentMethodDialog(item: item),
    );
    if (result == null) return;
    final ok = item == null
        ? await vm.create(
            code: result.code,
            nameTh: result.nameTh,
            description: result.description,
            paymentSystem: result.paymentSystem,
            payTypes: result.payTypes,
            sortOrder: result.sortOrder,
            active: result.active,
          )
        : await vm.update(
            item,
            nameTh: result.nameTh,
            description: result.description,
            paymentSystem: result.paymentSystem,
            payTypes: result.payTypes,
            sortOrder: result.sortOrder,
            active: result.active,
          );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(ok ? 'บันทึกสำเร็จ' : (vm.error ?? 'บันทึกล้มเหลว'))),
    );
  }
}

/* class _PaymentDeleteDialog extends StatelessWidget {
  final String name;
  const _PaymentDeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(SetSpace.xl),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: SetColors.surface,
            borderRadius: BorderRadius.circular(SetRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .14),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB91C1C), Color(0xFFC62828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SetRadius.lg),
                    topRight: Radius.circular(SetRadius.lg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(SetRadius.md),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .30),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: SetSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ยืนยันการลบช่องทาง',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: SetText.fontBold,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'การดำเนินการนี้ไม่สามารถยกเลิกได้',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
                child: Text(
                  'ต้องการลบช่องทาง "$name" หรือไม่?',
                  style: SetText.body.copyWith(fontSize: 14, height: 1.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _PaymentDialogButton(
                        label: 'ยกเลิก',
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: SetSpace.sm),
                    Expanded(
                      child: _PaymentDialogButton(
                        label: 'ลบช่องทาง',
                        icon: Icons.delete_sweep_outlined,
                        primary: true,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _PaymentDialogButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _PaymentDialogButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  State<_PaymentDialogButton> createState() => _PaymentDialogButtonState();
}

class _PaymentDialogButtonState extends State<_PaymentDialogButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.primary
        ? Colors.white
        : (_hover ? SetColors.textPrimary : SetColors.textSecondary);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: widget.primary
                ? LinearGradient(
                    colors: _hover
                        ? const [Color(0xFFC62828), Color(0xFFB91C1C)]
                        : const [Color(0xFFB91C1C), Color(0xFFC62828)],
                  )
                : null,
            color: widget.primary
                ? null
                : (_hover ? SetColors.surfaceMuted : Colors.white),
            borderRadius: BorderRadius.circular(SetRadius.md),
            border: Border.all(
              color: widget.primary
                  ? Colors.transparent
                  : (_hover ? SetColors.textSecondary : SetColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: foreground),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: foreground,
                  fontFamily: SetText.fontBold,
                  fontSize: 14,
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

*/

class _PaymentSearchBar extends StatefulWidget {
  const _PaymentSearchBar();

  @override
  State<_PaymentSearchBar> createState() => _PaymentSearchBarState();
}

class _PaymentSearchBarState extends State<_PaymentSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller.text = context.read<PaymentMethodViewModel>().searchQuery;
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _onChanged(String value) {
    context.read<PaymentMethodViewModel>().setSearch(value);
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    context.read<PaymentMethodViewModel>().clearSearch();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentMethodViewModel>();
    final hasText = _controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: SetColors.cardBg,
        borderRadius: BorderRadius.circular(SetRadius.md),
        border: Border.all(
          color: _focused ? SetColors.primary : SetColors.border,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? SetColors.primary.withValues(alpha: .12)
                : Colors.black.withValues(alpha: .02),
            blurRadius: _focused ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: _focused ? SetColors.primary : SetColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onChanged,
              style: SetText.body,
              cursorColor: SetColors.primary,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'ค้นหารหัส ชื่อช่องทาง ระบบ หรือประเภทการจ่าย',
                hintStyle: SetText.bodyMuted,
              ),
            ),
          ),
          if (vm.loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else if (hasText)
            Tooltip(
              message: 'ล้าง',
              child: InkWell(
                onTap: _clear,
                borderRadius: BorderRadius.circular(SetRadius.pill),
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: SetColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentPagination extends StatefulWidget {
  final bool compact;
  const _PaymentPagination({this.compact = false});

  @override
  State<_PaymentPagination> createState() => _PaymentPaginationState();
}

class _PaymentPaginationState extends State<_PaymentPagination> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentMethodViewModel>();
    final canPrev = vm.currentPage > 1 && !vm.loading;
    final canNext = vm.currentPage < vm.totalPages && !vm.loading;
    final label = '${vm.currentPage} / ${vm.totalPages}';

    if (!widget.compact) {
      return _PaginationFrame(
        child: _PaginationContent(
          label: label,
          canPrev: canPrev,
          canNext: canNext,
          onPrev: vm.previousPage,
          onNext: vm.nextPage,
        ),
      );
    }

    return _PaginationFrame(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(SetRadius.md),
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? _PaginationContent(
                    label: label,
                    canPrev: canPrev,
                    canNext: canNext,
                    onPrev: () {
                      vm.previousPage();
                      setState(() => _expanded = false);
                    },
                    onNext: () {
                      vm.nextPage();
                      setState(() => _expanded = false);
                    },
                  )
                : const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: SetColors.textSecondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PaginationFrame extends StatelessWidget {
  final Widget child;
  const _PaginationFrame({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: SetColors.cardBg,
          borderRadius: BorderRadius.circular(SetRadius.md),
          border: Border.all(color: SetColors.border),
        ),
        child: child,
      );
}

class _PaginationContent extends StatelessWidget {
  final String label;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaginationContent({
    required this.label,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PaginationButton(
            icon: Icons.chevron_left_rounded,
            enabled: canPrev,
            onTap: onPrev,
            tooltip: 'หน้าก่อนหน้า',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              style: SetText.bodyMuted.copyWith(
                color: SetColors.primaryDark,
                fontFamily: SetText.fontBold,
              ),
            ),
          ),
          _PaginationButton(
            icon: Icons.chevron_right_rounded,
            enabled: canNext,
            onTap: onNext,
            tooltip: 'หน้าถัดไป',
          ),
        ],
      );
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(SetRadius.pill),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled ? SetColors.cardBg : SetColors.surfaceMuted,
              borderRadius: BorderRadius.circular(SetRadius.pill),
              border: Border.all(
                color: enabled ? SetColors.borderStrong : SetColors.border,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? SetColors.textSecondary : SetColors.textMuted,
            ),
          ),
        ),
      );
}

class _PaymentEmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onAction;

  const _PaymentEmptyState({
    required this.hasSearch,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payments_outlined,
              size: 48,
              color: SetColors.textMuted,
            ),
            const SizedBox(height: SetSpace.md),
            Text(
              hasSearch
                  ? 'ไม่พบช่องทางการรับชำระ'
                  : 'ยังไม่มีช่องทางการรับชำระ',
              style: SetText.h2,
            ),
            const SizedBox(height: SetSpace.sm),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(hasSearch ? Icons.close_rounded : Icons.refresh),
              label: Text(hasSearch ? 'ล้างคำค้นหา' : 'โหลดข้อมูลใหม่'),
            ),
          ],
        ),
      );
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethodModel item;
  final VoidCallback onEdit;

  const _PaymentMethodCard({
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final payTypes = item.payTypes.isEmpty ? '-' : item.payTypes.join(', ');
    final system = item.paymentSystem.isEmpty ? '-' : item.paymentSystem;
    final description = item.description.isEmpty ? '-' : item.description;

    return Container(
      decoration: SetDecor.card(),
      padding: const EdgeInsets.all(SetSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SetColors.primaryLight,
                  borderRadius: BorderRadius.circular(SetRadius.md),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: SetColors.primaryDark,
                ),
              ),
              const SizedBox(width: SetSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nameTh.isEmpty ? '-' : item.nameTh,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SetText.body.copyWith(
                        fontFamily: SetText.fontBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.code.isEmpty ? '-' : item.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SetText.caption,
                    ),
                  ],
                ),
              ),
              _PaymentStatusPill(active: item.active),
            ],
          ),
          const Divider(height: SetSpace.lg, color: SetColors.border),
          _PaymentCardInfoLine(
            icon: Icons.settings_outlined,
            value: system,
          ),
          const SizedBox(height: 6),
          _PaymentCardInfoLine(
            icon: Icons.account_balance_wallet_outlined,
            value: payTypes,
          ),
          const SizedBox(height: 6),
          _PaymentCardInfoLine(
            icon: Icons.description_outlined,
            value: description,
            maxLines: 2,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _PaymentMiniButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                color: const Color(0xFF2563EB),
                onTap: onEdit,
              ),
              const SizedBox(width: SetSpace.sm),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentCardInfoLine extends StatelessWidget {
  final IconData icon;
  final String value;
  final int maxLines;

  const _PaymentCardInfoLine({
    required this.icon,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: value,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 15, color: SetColors.textMuted),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: SetText.bodyMuted.copyWith(
                  fontSize: 12,
                  color: SetColors.textSecondary,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ViewModeToggle extends StatelessWidget {
  final PaymentMethodViewMode mode;
  final ValueChanged<PaymentMethodViewMode> onChanged;
  const _ViewModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: SetColors.surfaceMuted,
          borderRadius: BorderRadius.circular(SetRadius.pill),
          border: Border.all(color: SetColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _button(
              Icons.view_agenda_outlined, 'การ์ด', PaymentMethodViewMode.card),
          _button(
              Icons.table_rows_outlined, 'ตาราง', PaymentMethodViewMode.table),
        ]),
      );

  Widget _button(IconData icon, String label, PaymentMethodViewMode value) {
    final selected = mode == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(SetRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? SetColors.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(SetRadius.pill),
          boxShadow: selected
              ? [const BoxShadow(color: Color(0x14000000), blurRadius: 4)]
              : const [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 16,
              color: selected ? SetColors.primary : SetColors.textMuted),
          const SizedBox(width: 5),
          Text(label,
              style: SetText.bodyMuted.copyWith(
                color: selected ? SetColors.primary : SetColors.textSecondary,
                fontFamily: selected ? SetText.fontBold : SetText.fontRegular,
              )),
        ]),
      ),
    );
  }
}

class _PaymentMethodTable extends StatelessWidget {
  final List<PaymentMethodModel> items;
  final ValueChanged<PaymentMethodModel> onEdit;
  const _PaymentMethodTable({
    required this.items,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: SetDecor.card(),
        child: Column(
          children: [
            _headerRow(),
            const Divider(height: 1, color: SetColors.border),
            for (int index = 0; index < items.length; index++)
              _PaymentTableRow(
                item: items[index],
                index: index,
                onEdit: () => onEdit(items[index]),
              ),
          ],
        ),
      );

  Widget _headerRow() => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SetSpace.md,
          vertical: SetSpace.md,
        ),
        decoration: const BoxDecoration(
          color: SetColors.surfaceMuted,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SetRadius.lg),
            topRight: Radius.circular(SetRadius.lg),
          ),
        ),
        child: const Row(
          children: [
            _PaymentHeaderCell(label: 'Code', flex: 2),
            _PaymentHeaderCell(label: 'ชื่อช่องทาง', flex: 3),
            _PaymentHeaderCell(label: 'ระบบ', flex: 2),
            _PaymentHeaderCell(label: 'ประเภทการจ่าย', flex: 3),
            _PaymentHeaderCell(label: 'สถานะ', flex: 2),
            SizedBox(
              width: 170,
              child: Text(
                'จัดการ',
                textAlign: TextAlign.center,
                style: _paymentTableHeaderStyle,
              ),
            ),
          ],
        ),
      );
}

const _paymentTableHeaderStyle = TextStyle(
  fontFamily: SetText.fontBold,
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: SetColors.textSecondary,
  letterSpacing: .4,
);

class _PaymentHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _PaymentHeaderCell({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _paymentTableHeaderStyle,
          ),
        ),
      );
}

class _PaymentTableRow extends StatefulWidget {
  final PaymentMethodModel item;
  final int index;
  final VoidCallback onEdit;

  const _PaymentTableRow({
    required this.item,
    required this.index,
    required this.onEdit,
  });

  @override
  State<_PaymentTableRow> createState() => _PaymentTableRowState();
}

class _PaymentTableRowState extends State<_PaymentTableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hover
            ? SetColors.primaryLight.withValues(alpha: .4)
            : (widget.index.isOdd ? SetColors.surfaceMuted : SetColors.cardBg),
        padding: const EdgeInsets.symmetric(
          horizontal: SetSpace.md,
          vertical: SetSpace.md,
        ),
        child: Row(
          children: [
            _PaymentTableCell(value: item.code, flex: 2),
            _PaymentTableCell(value: item.nameTh, flex: 3),
            _PaymentTableCell(value: item.paymentSystem, flex: 2),
            _PaymentTableCell(value: item.payTypes.join(', '), flex: 3),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _PaymentStatusPill(active: item.active),
              ),
            ),
            SizedBox(
              width: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PaymentMiniButton(
                    icon: Icons.edit_rounded,
                    label: 'แก้ไข',
                    color: const Color(0xFF2563EB),
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: SetSpace.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTableCell extends StatelessWidget {
  final String value;
  final int flex;
  const _PaymentTableCell({required this.value, required this.flex});

  @override
  Widget build(BuildContext context) {
    final text = value.isEmpty ? '-' : value;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Tooltip(
          message: text,
          waitDuration: const Duration(milliseconds: 300),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SetText.bodyMuted.copyWith(
              color: SetColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentStatusPill extends StatelessWidget {
  final bool active;
  const _PaymentStatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? SetColors.primaryDark : SetColors.textSecondary;
    final background = active ? SetColors.primaryLight : SetColors.surfaceMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SetRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.pause_circle_outline,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'เปิดใช้งาน' : 'ปิดใช้งาน',
            style: SetText.label.copyWith(
              color: color,
              fontSize: 10,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMiniButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentMiniButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PaymentMiniButton> createState() => _PaymentMiniButtonState();
}

class _PaymentMiniButtonState extends State<_PaymentMiniButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final foreground = _hover ? Colors.white : widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hover ? widget.color : widget.color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(SetRadius.pill),
            border: Border.all(
              color:
                  _hover ? widget.color : widget.color.withValues(alpha: .25),
            ),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: widget.color.withValues(alpha: .28),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: foreground),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: SetText.fontBold,
                  fontSize: 11,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  final int total;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  const _PaymentHeader(
      {required this.total, required this.onBack, required this.onAdd});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SetColors.headerBg, SetColors.headerAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(SetRadius.lg),
          boxShadow: [
            BoxShadow(
              color: SetColors.primary.withValues(alpha: .15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 680;
            return Row(
              children: [
                _PaymentHeaderBackButton(onTap: onBack),
                const SizedBox(width: SetSpace.sm),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: SetColors.primary.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(SetRadius.md),
                    border: Border.all(
                      color: SetColors.primaryAccent.withValues(alpha: .35),
                    ),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: SetColors.primaryAccent,
                  ),
                ),
                const SizedBox(width: SetSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAYMENT MANAGEMENT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SetText.label.copyWith(
                          color: SetColors.primaryAccent,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ช่องทางการรับชำระ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SetText.h1.copyWith(
                          color: SetColors.textInverse,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'จัดการวิธีการรับชำระเงินของระบบ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SetText.caption.copyWith(
                          color: Colors.white.withValues(alpha: .65),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(SetRadius.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .18),
                      ),
                    ),
                    child: Text(
                      '$total รายการ',
                      style: SetText.bodyMuted.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: SetSpace.sm),
                ],
                _PaymentHeaderActionButton(
                  compact: compact,
                  onTap: onAdd,
                ),
              ],
            );
          },
        ),
      );
}

class _PaymentHeaderBackButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PaymentHeaderBackButton({required this.onTap});

  @override
  State<_PaymentHeaderBackButton> createState() =>
      _PaymentHeaderBackButtonState();
}

class _PaymentHeaderBackButtonState extends State<_PaymentHeaderBackButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Tooltip(
          message: 'ย้อนกลับ',
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _hover ? .18 : .08),
                borderRadius: BorderRadius.circular(SetRadius.sm),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .20),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}

class _PaymentHeaderActionButton extends StatefulWidget {
  final bool compact;
  final VoidCallback onTap;
  const _PaymentHeaderActionButton({
    required this.compact,
    required this.onTap,
  });

  @override
  State<_PaymentHeaderActionButton> createState() =>
      _PaymentHeaderActionButtonState();
}

class _PaymentHeaderActionButtonState
    extends State<_PaymentHeaderActionButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.compact ? 40 : null,
            height: 40,
            padding: widget.compact
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _down
                  ? SetColors.primaryDark
                  : (_hover ? SetColors.primary : SetColors.primaryAccent),
              borderRadius: BorderRadius.circular(SetRadius.md),
              boxShadow: [
                if (_hover)
                  BoxShadow(
                    color: SetColors.primary.withValues(alpha: .35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                if (!widget.compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    'เพิ่มช่องทาง',
                    style: SetText.bodyMuted.copyWith(
                      color: Colors.white,
                      fontFamily: SetText.fontBold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ]),
      );
}

class _PaymentMethodFormResult {
  final String code;
  final String nameTh;
  final String description;
  final String paymentSystem;
  final List<String> payTypes;
  final int sortOrder;
  final bool active;
  const _PaymentMethodFormResult(
      {required this.code,
      required this.nameTh,
      required this.description,
      required this.paymentSystem,
      required this.payTypes,
      required this.sortOrder,
      required this.active});
}

class _PaymentMethodDialog extends StatefulWidget {
  final PaymentMethodModel? item;
  const _PaymentMethodDialog({this.item});
  @override
  State<_PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentFormSectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PaymentFormSectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SetColors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(SetRadius.sm),
            ),
            child: Icon(icon, size: 15, color: SetColors.primary),
          ),
          const SizedBox(width: SetSpace.sm),
          Text(text, style: SetText.h2.copyWith(fontSize: 14)),
        ],
      );
}

class _PaymentFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;

  const _PaymentFormField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
  });

  OutlineInputBorder _border([Color? color, double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(SetRadius.sm),
        borderSide: BorderSide(color: color ?? SetColors.border, width: width),
      );

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: SetText.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: SetText.bodyMuted,
          filled: true,
          fillColor: SetColors.surfaceMuted.withValues(alpha: .35),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: _border(),
          enabledBorder: _border(),
          disabledBorder: _border(SetColors.border),
          focusedBorder: _border(SetColors.primary, 1.4),
          isDense: true,
        ),
      );
}

class _PaymentFormActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool primary;
  final VoidCallback onTap;

  const _PaymentFormActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
  });

  @override
  State<_PaymentFormActionButton> createState() =>
      _PaymentFormActionButtonState();
}

class _PaymentFormActionButtonState extends State<_PaymentFormActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.primary
        ? Colors.white
        : (_hover ? SetColors.textPrimary : SetColors.textSecondary);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: widget.primary
                ? (_hover ? SetColors.primary : SetColors.primaryDark)
                : (_hover ? SetColors.surfaceMuted : Colors.white),
            borderRadius: BorderRadius.circular(SetRadius.md),
            border: Border.all(
              color: widget.primary
                  ? Colors.transparent
                  : (_hover ? SetColors.textSecondary : SetColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 17, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: foreground,
                  fontFamily: SetText.fontBold,
                  fontSize: 14,
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

class _PaymentMethodDialogState extends State<_PaymentMethodDialog> {
  late final TextEditingController code;
  late final TextEditingController name;
  late final TextEditingController description;
  late final TextEditingController system;
  late final TextEditingController types;
  late final TextEditingController order;
  late bool active;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    code = TextEditingController(text: item?.code ?? '');
    name = TextEditingController(text: item?.nameTh ?? '');
    description = TextEditingController(text: item?.description ?? '');
    system = TextEditingController(text: item?.paymentSystem ?? 'internal');
    types =
        TextEditingController(text: item?.payTypes.join(', ') ?? 'fee, fine');
    order = TextEditingController(text: '${item?.sortOrder ?? 0}');
    active = item?.active ?? true;
  }

  @override
  void dispose() {
    for (final controller in [code, name, description, system, types, order]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item == null
        ? 'เพิ่มช่องทางการรับชำระ'
        : 'แก้ไขช่องทางการรับชำระ';
    final isCreate = widget.item == null;

    return Dialog(
      backgroundColor: SetColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SetRadius.lg),
      ),
      insetPadding: const EdgeInsets.all(SetSpace.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SetSpace.lg,
                SetSpace.md,
                SetSpace.md,
                SetSpace.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: SetColors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(SetRadius.md),
                      border: Border.all(
                        color: SetColors.primary.withValues(alpha: .28),
                      ),
                    ),
                    child: Icon(
                      isCreate ? Icons.add_rounded : Icons.edit_rounded,
                      color: SetColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: SetSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: SetText.h1),
                        Text(
                          isCreate
                              ? 'กรอกข้อมูลช่องทางการรับชำระ'
                              : 'แก้ไขข้อมูลช่องทางการรับชำระ',
                          style: SetText.bodyMuted.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'ปิด',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: SetColors.textSecondary,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: SetColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SetSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _PaymentFormSectionLabel(
                      icon: Icons.payments_outlined,
                      text: 'ข้อมูลช่องทางการรับชำระ',
                    ),
                    const SizedBox(height: SetSpace.sm),
                    _PaymentFormField(
                      controller: code,
                      label: 'Code',
                      enabled: isCreate,
                    ),
                    const SizedBox(height: SetSpace.sm),
                    _PaymentFormField(
                      controller: name,
                      label: 'ชื่อภาษาไทย',
                    ),
                    const SizedBox(height: SetSpace.sm),
                    _PaymentFormField(
                      controller: description,
                      label: 'รายละเอียด',
                      maxLines: 2,
                    ),
                    const SizedBox(height: SetSpace.lg),
                    const _PaymentFormSectionLabel(
                      icon: Icons.settings_outlined,
                      text: 'การตั้งค่าระบบ',
                    ),
                    const SizedBox(height: SetSpace.sm),
                    _PaymentFormField(
                      controller: system,
                      label: 'Payment system',
                    ),
                    const SizedBox(height: SetSpace.sm),
                    _PaymentFormField(
                      controller: types,
                      label: 'Pay types (คั่นด้วย comma)',
                    ),
                    const SizedBox(height: SetSpace.sm),
                    _PaymentFormField(
                      controller: order,
                      label: 'ลำดับ',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: SetSpace.sm),
                    Container(
                      decoration: SetDecor.softCard(),
                      child: SwitchListTile(
                        value: active,
                        onChanged: (value) => setState(() => active = value),
                        title: const Text('เปิดใช้งาน', style: SetText.body),
                        subtitle: Text(
                          active
                              ? 'ช่องทางนี้พร้อมใช้งาน'
                              : 'ปิดการใช้งานชั่วคราว',
                          style: SetText.caption,
                        ),
                        activeThumbColor: SetColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: SetColors.border),
            Padding(
              padding: const EdgeInsets.all(SetSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: _PaymentFormActionButton(
                      label: 'ยกเลิก',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: SetSpace.sm),
                  Expanded(
                    child: _PaymentFormActionButton(
                      label: 'บันทึก',
                      icon: Icons.check_rounded,
                      primary: true,
                      onTap: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (code.text.trim().isEmpty || name.text.trim().isEmpty) return;
    Navigator.pop(
        context,
        _PaymentMethodFormResult(
          code: code.text.trim(),
          nameTh: name.text.trim(),
          description: description.text.trim(),
          paymentSystem: system.text.trim(),
          payTypes: types.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          sortOrder: int.tryParse(order.text.trim()) ?? 0,
          active: active,
        ));
  }
}

class PaymentHost extends StatelessWidget {
  const PaymentHost({super.key});
  @override
  Widget build(BuildContext context) => PaymentPage.create();
}
