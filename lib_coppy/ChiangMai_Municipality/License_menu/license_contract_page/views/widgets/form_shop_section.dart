// ============================================================================
// form_shop_section.dart
// ============================================================================
// Section "ข้อมูลร้านค้า" — modern form rows
// - Row เดี่ยว: label + TextField
// - Row พิเศษ (ser=1): แสดง sub fields (2 row x N col)
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/license_contract_theme.dart';
import '../../viewmodels/license_contract_view_model.dart';

class FormShopSection extends StatelessWidget {
  const FormShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseContractViewModel>();
    return Column(
      children: [
        for (int shop = 0; shop < vm.dataShop.length; shop++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: vm.dataShop[shop].ser.toString() == '1'
                ? _shopSubFields(vm, shop)
                : _shopTextField(vm, shop),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Single field row (label + input)
  // ---------------------------------------------------------------------
  Widget _shopTextField(LicenseContractViewModel vm, int shop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 4),
            child: Row(
              children: [
                Flexible(
                  child: AutoSizeText(
                    '${vm.dataShop[shop].title} *',
                    minFontSize: 11,
                    maxFontSize: 13,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LcText.label.copyWith(
                      color: LcColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: LcColors.required,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: TextFormField(
              textAlign: TextAlign.left,
              keyboardType: TextInputType.number,
              showCursor: !vm.readOnly,
              readOnly: vm.readOnly,
              controller: vm.controllersShop[shop],
              style: LcText.input,
              decoration: LcDecor.inputDecor(
                hintText: 'กรอก${vm.dataShop[shop].title}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Sub fields (2 rows × N cols)
  // ---------------------------------------------------------------------
  Widget _shopSubFields(LicenseContractViewModel vm, int shop) {
    final subs = vm.dataShop[shop].detailsub;
    if (subs.isEmpty) return _shopTextField(vm, shop);
    return Container(
      padding: const EdgeInsets.all(LcSpace.sm),
      decoration: BoxDecoration(
        color: LcColors.surfaceMuted.withOpacity(.4),
        borderRadius: BorderRadius.circular(LcRadius.sm),
        border: Border.all(color: LcColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: LcSpace.sm, left: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 14,
                  color: LcColors.primaryDark,
                ),
                const SizedBox(width: 4),
                Text(
                  vm.dataShop[shop].title,
                  style: LcText.label.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          // Row 1: subs 0..n-2
          Row(
            children: [
              for (int i = 0; i < subs.length - 1; i++) ...[
                if (i > 0) const SizedBox(width: LcSpace.sm),
                Expanded(child: _shopSubField(vm, shop, i)),
              ],
            ],
          ),
          const SizedBox(height: LcSpace.sm),
          // Row 2: subs 2..n
          Row(
            children: [
              for (int i = 2; i < subs.length; i++) ...[
                if (i > 2) const SizedBox(width: LcSpace.sm),
                Expanded(child: _shopSubField(vm, shop, i)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Single sub field
  // ---------------------------------------------------------------------
  Widget _shopSubField(LicenseContractViewModel vm, int shop, int i) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextFormField(
        textAlign: TextAlign.left,
        keyboardType: TextInputType.number,
        showCursor: !vm.readOnly,
        readOnly: vm.readOnly,
        controller: vm.controllersShopSub[i],
        maxLines: 1,
        style: LcText.input,
        decoration: LcDecor.inputDecor(
          labelText: vm.dataShop[shop].detailsub[i].titlesub,
        ),
      ),
    );
  }
}
