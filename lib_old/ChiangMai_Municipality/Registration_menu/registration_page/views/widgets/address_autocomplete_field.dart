// ============================================================================
// address_autocomplete_field.dart
// ============================================================================
// TextField wrapper ที่มี Autocomplete สำหรับจังหวัด/อำเภอ/ตำบล
// - ใช้ raw_options_view_options ปรับ look ให้เข้ากับ theme Registration
// - กด Esc หรือคลิกข้างนอกเพื่อปิด
// - รองรับ free-typing (พิมพ์เองได้ ถ้าไม่ตรง list)
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/thai_address.dart';

/// TextField + Autocomplete สำหรับเลือก จังหวัด/อำเภอ/ตำบล
/// ทำงานแบบ cascading: เลือกจังหวัด → เลือกอำเภอ → เลือกตำบล
/// (แต่พิมพ์เองได้ทุกช่อง — แม้ยังไม่ได้เลือก parent)
class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final AddressAutocompleteKind kind;
  final String? provinceName; // required for district/subDistrict
  final String? districtName; // required for subDistrict
  final String? subDistrictName; // optional for zipcode
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.kind,
    this.provinceName,
    this.districtName,
    this.subDistrictName,
    this.validator,
    this.onChanged,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _options(String query) {
    switch (widget.kind) {
      case AddressAutocompleteKind.province:
        return filterProvinces(query);
      case AddressAutocompleteKind.district:
        // ถ้ายังไม่เลือกจังหวัด → ใช้จังหวัดแรกเป็น guide
        final prov = (widget.provinceName ?? '').isEmpty
            ? (kThaiProvinces.isNotEmpty ? kThaiProvinces.first.name : '')
            : widget.provinceName!;
        if (prov.isEmpty) return const [];
        return filterDistricts(prov, query);
      case AddressAutocompleteKind.subDistrict:
        // ถ้ายังไม่เลือกจังหวัด/อำเภอ → ใช้ค่าแรกเป็น guide
        final prov = (widget.provinceName ?? '').isEmpty
            ? (kThaiProvinces.isNotEmpty ? kThaiProvinces.first.name : '')
            : widget.provinceName!;
        final ds = districtsOf(prov);
        final dist = (widget.districtName ?? '').isEmpty
            ? (ds.isNotEmpty ? ds.first.name : '')
            : widget.districtName!;
        if (prov.isEmpty || dist.isEmpty) return const [];
        return filterSubDistricts(prov, dist, query);
      case AddressAutocompleteKind.zipcode:
        final prov = (widget.provinceName ?? '').isEmpty
            ? (kThaiProvinces.isNotEmpty ? kThaiProvinces.first.name : '')
            : widget.provinceName!;
        final ds = districtsOf(prov);
        final dist = (widget.districtName ?? '').isEmpty
            ? (ds.isNotEmpty ? ds.first.name : '')
            : widget.districtName!;
        return filterZipcodes(prov, dist, widget.subDistrictName ?? '', query);
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) {
        return _options(value.text);
      },
      fieldViewBuilder: (context, textController, fn, onFieldSubmitted) {
        return TextFormField(
          controller: textController,
          focusNode: fn,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.icon, size: 20, color: cs.onSurfaceVariant),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: Icon(Icons.arrow_drop_down,
                size: 20, color: cs.onSurfaceVariant),
          ),
          validator: widget.validator,
          onChanged: (v) {
            // sync ค่ากลับไปยัง controller หลัก (กันพิมพ์แล้วหายตอน rebuild)
            if (widget.controller.text != v) {
              widget.controller.text = v;
              widget.controller.selection =
                  TextSelection.collapsed(offset: v.length);
            }
            widget.onChanged?.call(v);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 360,
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: options.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ไม่พบ — พิมพ์เองได้',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        final opt = options.elementAt(i);
                        return InkWell(
                          hoverColor: cs.primary.withOpacity(.08),
                          onTap: () {
                            // เคลียร์ textController ก่อน แล้วใส่ค่าใหม่
                            widget.controller.text = opt;
                            widget.controller.selection =
                                TextSelection.collapsed(offset: opt.length);
                            // trigger onChanged เพื่อให้ parent rebuild/emit
                            widget.onChanged?.call(opt);
                            onSelected(opt);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.place_outlined,
                                    size: 16, color: cs.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(opt,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                                Icon(Icons.east,
                                    size: 14, color: cs.onSurfaceVariant),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}

enum AddressAutocompleteKind {
  province,
  district,
  subDistrict,
  zipcode,
}
