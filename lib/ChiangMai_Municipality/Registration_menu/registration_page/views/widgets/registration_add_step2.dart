// ============================================================================
// registration_add_step2.dart
// ============================================================================
// Step 2 — ข้อมูลส่วนบุคคล + ที่อยู่ (แยกช่องกรอก + สรุปข้างล่าง)
// - TAX / วันเกิด
// - บ้านเลขที่ / ตำบล / อำเภอ / จังหวัด / รหัสไปรษณีย์
// - สรุปที่อยู่เป็นข้อความเดียว (auto-built)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../theme/registration_theme.dart';
import 'address_autocomplete_field.dart';

class RegistrationAddStep2 extends StatefulWidget {
  final TextEditingController tax;
  final TextEditingController birth;

  // ─── Address fields ───
  final TextEditingController houseNo;
  final TextEditingController moo;
  final TextEditingController street;
  final TextEditingController subDistrict;
  final TextEditingController district;
  final TextEditingController province;
  final TextEditingController zipcode;

  // ─── Callback ส่งที่อยู่ที่ join แล้วกลับไปที่ page ───
  final ValueChanged<String> onAddressChanged;

  const RegistrationAddStep2({
    super.key,
    required this.tax,
    required this.birth,
    required this.houseNo,
    required this.moo,
    required this.street,
    required this.subDistrict,
    required this.district,
    required this.province,
    required this.zipcode,
    required this.onAddressChanged,
  });

  @override
  State<RegistrationAddStep2> createState() => _RegistrationAddStep2State();
}

class _RegistrationAddStep2State extends State<RegistrationAddStep2> {
  Future<void> _selectDate() async {
    DateTime initial = DateTime.now();
    if (widget.birth.text.isNotEmpty) {
      initial = DateTime.tryParse(widget.birth.text) ?? initial;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LaColors.primary,
              onPrimary: Colors.white,
              onSurface: LaColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        widget.birth.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// รวมที่อยู่เป็นข้อความเดียว (ส่งไปบันทึกที่ API)
  /// รูปแบบ: "บ้านเลขที่ หมู่ที่ ถนน ตำบล อำเภอ จังหวัด รหัสไปรษณีย์"
  String _buildAddress() {
    final parts = <String>[];
    final house = widget.houseNo.text.trim();
    final moo = widget.moo.text.trim();
    final street = widget.street.text.trim();
    final sub = widget.subDistrict.text.trim();
    final dist = widget.district.text.trim();
    final prov = widget.province.text.trim();
    final zip = widget.zipcode.text.trim();

    // บ้านเลขที่ + หมู่ (รวมเป็นชิ้นเดียว: "123/45 หมู่ 2")
    final addrHead = <String>[];
    if (house.isNotEmpty) addrHead.add(house);
    if (moo.isNotEmpty) addrHead.add('หมู่ $moo');
    if (addrHead.isNotEmpty) parts.add(addrHead.join(' '));
    if (street.isNotEmpty) parts.add('ถ.$street');
    if (sub.isNotEmpty) parts.add('ต.$sub');
    if (dist.isNotEmpty) parts.add('อ.$dist');
    if (prov.isNotEmpty) parts.add('จ.$prov');
    if (zip.isNotEmpty) parts.add(zip);
    return parts.join(' ');
  }

  void _emitAddress() {
    widget.onAddressChanged(_buildAddress());
  }

  /// คำนวณอายุจาก yyyy-MM-dd → (years, months, days)
  /// return null ถ้าไม่มีวันเกิด หรือ format ผิด
  ({int years, int months, int days})? _calculateAge() {
    final raw = widget.birth.text.trim();
    if (raw.isEmpty) return null;
    final birth = DateTime.tryParse(raw);
    if (birth == null) return null;

    final now = DateTime.now();
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;

    if (days < 0) {
      months -= 1;
      // ยืมวันจากเดือนก่อน
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) return null;
    return (years: years, months: months, days: days);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoCol = width >= 700;

    // คำนวณสรุปที่อยู่ realtime
    final summary = _buildAddress();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionCard(
                icon: Icons.person_outline,
                title: 'ข้อมูลส่วนบุคคล',
                subtitle: 'เลขประจำตัวผู้เสียภาษีและวันเกิด',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _grid(twoCol, [
                      _fieldRow(
                        icon: Icons.badge_outlined,
                        label: 'เลขประจำตัวผู้เสียภาษี',
                        required: true,
                        child: _field(
                          controller: widget.tax,
                          hint: 'ระบุ 13 หลัก',
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'กรอกข้อมูลให้ครบถ้วน';
                            if (v.length < 13) return 'กรอกอย่างน้อย 13 หลัก';
                            return null;
                          },
                        ),
                      ),
                      _fieldRow(
                        icon: Icons.cake_outlined,
                        label: 'วันเกิด',
                        child: _dateField(),
                      ),
                    ]),
                    const SizedBox(height: LaSpace.sm),
                    _ageSummary(),
                  ],
                ),
              ),
              const SizedBox(height: LaSpace.lg),
              _sectionCard(
                icon: Icons.location_on_outlined,
                title: 'ที่อยู่',
                subtitle:
                    'กรอกที่อยู่แยกตามช่อง — ระบบจะรวมเป็นข้อความเดียวให้อัตโนมัติ',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Row 1: บ้านเลขที่ + หมู่ที่ ───
                    _grid(twoCol, [
                      _fieldRow(
                        icon: Icons.home_outlined,
                        label: 'บ้านเลขที่',
                        child: _field(
                          controller: widget.houseNo,
                          hint: 'เช่น 123/45',
                          onChanged: (_) => _emitAddress(),
                        ),
                      ),
                      _fieldRow(
                        icon: Icons.format_list_numbered_rounded,
                        label: 'หมู่ที่',
                        child: _field(
                          controller: widget.moo,
                          hint: 'เช่น 2',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _emitAddress(),
                        ),
                      ),
                    ]),
                    // ─── Row 2: ถนน + จังหวัด ───
                    const SizedBox(height: 6),
                    _grid(twoCol, [
                      _fieldRow(
                        icon: Icons.signpost_outlined,
                        label: 'ถนน',
                        child: _field(
                          controller: widget.street,
                          hint: 'เช่น ถนนนิมมานเหมินท์',
                          onChanged: (_) => _emitAddress(),
                        ),
                      ),
                      _fieldRow(
                        icon: Icons.flag_outlined,
                        label: 'จังหวัด',
                        child: AddressAutocompleteField(
                          controller: widget.province,
                          label: 'จังหวัด',
                          hintText: 'พิมพ์หรือเลือก',
                          icon: Icons.flag_outlined,
                          kind: AddressAutocompleteKind.province,
                          onChanged: (_) {
                            setState(() {});
                            _emitAddress();
                          },
                        ),
                      ),
                    ]),
                    // ─── Row 3: อำเภอ + ตำบล ───
                    const SizedBox(height: 6),
                    _grid(twoCol, [
                      _fieldRow(
                        icon: Icons.account_balance_outlined,
                        label: 'อำเภอ/เขต',
                        child: AddressAutocompleteField(
                          controller: widget.district,
                          label: 'อำเภอ/เขต',
                          hintText: 'พิมพ์หรือเลือก',
                          icon: Icons.account_balance_outlined,
                          kind: AddressAutocompleteKind.district,
                          provinceName: widget.province.text,
                          onChanged: (_) {
                            setState(() {});
                            _emitAddress();
                          },
                        ),
                      ),
                      _fieldRow(
                        icon: Icons.location_city_outlined,
                        label: 'ตำบล/แขวง',
                        child: AddressAutocompleteField(
                          controller: widget.subDistrict,
                          label: 'ตำบล/แขวง',
                          hintText: 'พิมพ์หรือเลือก',
                          icon: Icons.location_city_outlined,
                          kind: AddressAutocompleteKind.subDistrict,
                          provinceName: widget.province.text,
                          districtName: widget.district.text,
                          onChanged: (_) => _emitAddress(),
                        ),
                      ),
                    ]),
                    // ─── Row 4: รหัสไปรษณีย์ (เต็มแถว สำหรับใส่ 5 หลัก) ───
                    const SizedBox(height: 6),
                    _fieldRow(
                      icon: Icons.markunread_mailbox_outlined,
                      label: 'รหัสไปรษณีย์',
                      child: AddressAutocompleteField(
                        controller: widget.zipcode,
                        label: 'รหัสไปรษณีย์',
                        hintText: 'พิมพ์หรือเลือก 5 หลัก',
                        icon: Icons.markunread_mailbox_outlined,
                        kind: AddressAutocompleteKind.zipcode,
                        provinceName: widget.province.text,
                        districtName: widget.district.text,
                        subDistrictName: widget.subDistrict.text,
                        onChanged: (_) => _emitAddress(),
                      ),
                    ),
                    // ─── Summary (auto-built) ───
                    const SizedBox(height: LaSpace.md),
                    _addressSummary(summary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Age summary ───
  Widget _ageSummary() {
    final age = _calculateAge();
    final hasBirth = widget.birth.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LaSpace.md, vertical: LaSpace.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LaColors.primaryLight.withOpacity(.18),
            LaColors.primary.withOpacity(.06),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.sm),
        border: Border.all(color: LaColors.primary.withOpacity(.30), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: LaColors.primary,
              borderRadius: BorderRadius.circular(LaRadius.sm),
            ),
            child: Icon(Icons.cake, size: 16, color: Colors.white),
          ),
          const SizedBox(width: LaSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: LaColors.primary,
                        borderRadius: BorderRadius.circular(LaRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          const Text(
                            'อายุ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: LaText.fontBold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  age == null
                      ? (hasBirth
                          ? 'รูปแบบวันเกิดไม่ถูกต้อง'
                          : 'เลือกวันเกิดเพื่อคำนวณอายุอัตโนมัติ')
                      : '${age.years} ปี ${age.months} เดือน ${age.days} วัน',
                  style: TextStyle(
                    color:
                        age != null ? LaColors.textPrimary : LaColors.textMuted,
                    fontSize: 14,
                    fontWeight: age != null ? FontWeight.w700 : FontWeight.w500,
                    fontStyle:
                        age == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          if (age != null)
            Text(
              '${age.years}',
              style: TextStyle(
                fontSize: 28,
                fontFamily: LaText.fontBold,
                fontWeight: FontWeight.w900,
                color: LaColors.primary,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Address summary (realtime preview) ───
  Widget _addressSummary(String summary) {
    final hasContent = summary.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(LaSpace.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LaColors.primary.withOpacity(.06),
            LaColors.primaryLight.withOpacity(.30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.md),
        border: Border.all(color: LaColors.primary.withOpacity(.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LaColors.primary,
                  borderRadius: BorderRadius.circular(LaRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'สรุปที่อยู่อัตโนมัติ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: LaText.fontBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.sm),
          Text(
            hasContent ? summary : 'กรอกข้อมูลที่อยู่เพื่อดูสรุป',
            style: TextStyle(
              color: hasContent ? LaColors.textPrimary : LaColors.textMuted,
              fontSize: 14,
              fontStyle: hasContent ? FontStyle.normal : FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section card ───
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: LaDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
                LaSpace.md, LaSpace.md, LaSpace.md, LaSpace.sm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: LaColors.border.withOpacity(.5), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LaColors.primary.withOpacity(.25),
                        LaColors.primary.withOpacity(.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                    border: Border.all(
                        color: LaColors.primary.withOpacity(.30), width: 1),
                  ),
                  child: Icon(icon, size: 18, color: LaColors.primaryDark),
                ),
                const SizedBox(width: LaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: LaText.h2),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: LaText.bodyMuted.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LaSpace.md),
            child: child,
          ),
        ],
      ),
    );
  }

  // ─── Grid ───
  Widget _grid(bool twoCol, List<Widget> children) {
    if (!twoCol) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 6),
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 16),
            Expanded(child: children[i + 1]),
          ],
        ));
      } else {
        rows.add(Row(children: [Expanded(child: children[i])]));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget _fieldRow({
    required IconData icon,
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: LaColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                required ? '$label *' : label,
                style: LaText.body.copyWith(
                  fontSize: 13,
                  color: LaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
    int minLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      cursorColor: LaColors.primary,
      validator: validator,
      onChanged: onChanged,
      decoration: _inputDecor(hint),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(LaRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: LaColors.surfaceMuted.withOpacity(.6),
          borderRadius: BorderRadius.circular(LaRadius.sm),
          border: Border.all(color: LaColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: LaColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.birth.text.isNotEmpty
                    ? DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(widget.birth.text))
                    : 'ระบุวันเกิด',
                style: TextStyle(
                  color: widget.birth.text.isNotEmpty
                      ? LaColors.textPrimary
                      : LaColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: LaColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: LaColors.surfaceMuted.withOpacity(.6),
      hintText: hint,
      hintStyle: LaText.caption,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide: BorderSide(color: LaColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide: BorderSide(color: LaColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide: const BorderSide(color: LaColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide:
            const BorderSide(color: LaColors.statusRejectedFg, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide:
            const BorderSide(color: LaColors.statusRejectedFg, width: 1.6),
      ),
    );
  }
}
