// ============================================================================
// request_detail_shop_section.dart
// ============================================================================
// Section "ข้อมูลร้านค้า" — แบบ read-only (ของตัวเอง)
// - Row เดี่ยว: label + read-only TextField
// - Row พิเศษ (ser=1): แสดง sub fields (2 row x N col)
// ใช้ LicenseRequestDetailStep1ViewModel ของ license_request_page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/license_request_detail_step1_view_model.dart';

class RequestDetailShopSection extends StatelessWidget {
  const RequestDetailShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseRequestDetailStep1ViewModel>();
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

  Widget _shopTextField(LicenseRequestDetailStep1ViewModel vm, int shop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 4),
            child: Text(
              vm.dataShop[shop].title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: TextFormField(
              textAlign: TextAlign.left,
              readOnly: true,
              controller: vm.controllersShop[shop],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
              decoration: _inputDecoration(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shopSubFields(LicenseRequestDetailStep1ViewModel vm, int shop) {
    final subs = vm.dataShop[shop].detailsub;
    if (subs.isEmpty) return _shopTextField(vm, shop);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: subs 0..n-1
        Row(
          children: [
            for (int i = 0; i < subs.length - 1; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _shopSubField(vm, shop, i)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: subs 2..n
        Row(
          children: [
            for (int i = 2; i < subs.length; i++) ...[
              if (i > 2) const SizedBox(width: 8),
              Expanded(child: _shopSubField(vm, shop, i)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _shopSubField(
      LicenseRequestDetailStep1ViewModel vm, int shop, int i) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextFormField(
        textAlign: TextAlign.left,
        readOnly: true,
        controller: vm.controllersShopSub[i],
        maxLines: 1,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          fillColor: const Color(0xFFF8FAFC),
          filled: true,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          labelText: vm.dataShop[shop].detailsub[i].titlesub,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 11,
            color: Color(0xFF16A34A),
            fontWeight: FontWeight.w700,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(width: 1, color: Color(0xFF16A34A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      fillColor: const Color(0xFFF8FAFC),
      filled: true,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(width: 1, color: Color(0xFF16A34A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
    );
  }
}
