import 'package:flutter/material.dart';

import '../../models/tenant_permit_models.dart';

/// Step 2 — ข้อมูลส่วนตัว (read-only)
///
/// โครง UI คัดลอกจาก license request detail step 1 โดยตรง
/// เปลี่ยนเฉพาะแหล่งข้อมูลเป็น TenantPermitDetail
class TenantLicenseDetailPersonal extends StatelessWidget {
  final TenantPermitDetail permit;

  const TenantLicenseDetailPersonal({super.key, required this.permit});

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final personFields = _personFields();
    final shopFields = _shopFields();
    final contractFields = _contractFields();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Title bar ───
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7).withOpacity(.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 18, color: Color(0xFF15803D)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ข้อมูลส่วนตัว',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Zone row (read-only) ───
              _RequestZoneRow(permit: permit),
              const SizedBox(height: 16),

              // ─── Form card ───
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: mediaWidth < 1100
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _RequestSectionTitle(
                              icon: Icons.person, title: 'ข้อมูลผู้เช่า'),
                          _PersonFields(fields: personFields),
                          const SizedBox(height: 16),
                          const _RequestSectionTitle(
                              icon: Icons.store, title: 'ข้อมูลร้านค้า'),
                          _ShopFields(fields: shopFields),
                          const SizedBox(height: 16),
                          const _RequestSectionTitle(
                              icon: Icons.receipt_long, title: 'ข้อมูลสัญญา'),
                          _ContractFields(fields: contractFields),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _RequestSectionTitle(
                                    icon: Icons.person, title: 'ข้อมูลผู้เช่า'),
                                _PersonFields(fields: personFields),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _RequestSectionTitle(
                                    icon: Icons.store, title: 'ข้อมูลร้านค้า'),
                                _ShopFields(fields: shopFields),
                                const SizedBox(height: 16),
                                const _RequestSectionTitle(
                                    icon: Icons.receipt_long,
                                    title: 'ข้อมูลสัญญา'),
                                _ContractFields(fields: contractFields),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              // ─── Info row ───
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'โหมดดูข้อมูลอย่างเดียว ไม่สามารถแก้ไขได้',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_DisplayField> _personFields() => [
        _DisplayField('ชื่อ-นามสกุล*',
            _value(permit.customer['cname'] ?? permit.customerName)),
        _DisplayField('เลขบัตรประจำตัวประชาชน*',
            _value(permit.customer['tax'] ?? permit.customer['taxno'])),
        _DisplayField('อายุ*', _value(permit.customer['age'])),
        _DisplayField('สัญชาติ*', _value(permit.customer['national'])),
        _DisplayField('บ้านเลขที่*', _address('number')),
        _DisplayField('หมู่ที่', _address('moo')),
        _DisplayField('ตรอก/ซอย', _address('soi')),
        _DisplayField('ถนน*', _address('road')),
        _DisplayField('ตำบล/แขวง*', _address('tambon')),
        _DisplayField('อำเภอ/เขต*', _address('amphoe')),
        _DisplayField('จังหวัด*', _address('province')),
        _DisplayField('เบอร์โทร*', _value(permit.customer['tel'])),
        _DisplayField('หมายเหตุ', _value(permit.customer['addr_1']),
            maxLines: 3),
      ];

  _ShopData _shopFields() => _ShopData(
        subFields: [
          _DisplayField('บริเวณ', _value(permit.details['subzone'])),
          _DisplayField('โซน', _value(permit.details['zn'] ?? permit.zoneId)),
          _DisplayField(
              'ล็อกที่', _value(permit.details['ln'] ?? permit.lockCode)),
        ],
        fields: [
          _DisplayField(
              'ขนาดพื้นที่เช่า (ตร.ม.)', _value(permit.details['qty'])),
          _DisplayField('ประเภทสินค้า', _value(permit.customer['stype'])),
          _DisplayField('ชื่อร้าน', _value(permit.customer['scname'])),
        ],
      );

  List<_ContractFieldData> _contractFields() => [
        _ContractFieldData(
          'วันที่เริ่มต้น',
          _date(permit.details['sdate'] ?? permit.validFrom),
          isDate: true,
        ),
        _ContractFieldData(
          'วันที่สิ้นสุด',
          _date(permit.details['ldate'] ?? permit.validUntil),
          isDate: true,
        ),
        _ContractFieldData('ประเภทสัญญา', _value(permit.details['type'])),
        _ContractFieldData(
          'ระยะเวลาเช่า',
          _value(permit.details['lease_term_months'] ??
              permit.details['leaseTermMonths']),
        ),
      ];

  String _address(String key) => _value(permit.addressField(key));

  static String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }

  static String _date(dynamic value) {
    final text = _value(value);
    if (text == '-') return text;
    try {
      final date = DateTime.parse(text).toLocal();
      return '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-${date.year + 543}';
    } catch (_) {
      return '-';
    }
  }
}

class _RequestZoneRow extends StatelessWidget {
  final TenantPermitDetail permit;

  const _RequestZoneRow({required this.permit});

  @override
  Widget build(BuildContext context) {
    final subZone = _value(permit.details['subzone']);
    final zone = _value(permit.details['zn'] ?? permit.zoneId);
    final lock = _value(permit.details['ln'] ?? permit.lockCode);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InputField(
                  field: _DisplayField(
                    'โซนพื้นที่เช่า',
                    subZone,
                    icon: Icons.layers_outlined,
                    zoneStyle: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  field: _DisplayField(
                    'โซน',
                    zone,
                    icon: Icons.place_outlined,
                    zoneStyle: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            field: _DisplayField(
              'รหัสพื้นที่',
              lock,
              icon: Icons.numbers_rounded,
              zoneStyle: true,
            ),
          ),
        ],
      ),
    );
  }

  static String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text == 'null' ? '-' : text;
  }
}

class _PersonFields extends StatelessWidget {
  final List<_DisplayField> fields;

  const _PersonFields({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final field in fields)
          _RequestFieldRow(
              label: field.label, child: _InputField(field: field)),
      ],
    );
  }
}

class _ShopData {
  final List<_DisplayField> subFields;
  final List<_DisplayField> fields;

  const _ShopData({required this.subFields, required this.fields});
}

class _ShopFields extends StatelessWidget {
  final _ShopData fields;

  const _ShopFields({required this.fields});

  @override
  Widget build(BuildContext context) {
    final subs = fields.subFields;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (int i = 0; i < subs.length - 1; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _InputField(field: subs[i], showLabel: true),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (int i = 2; i < subs.length; i++) ...[
                    if (i > 2) const SizedBox(width: 8),
                    Expanded(
                      child: _InputField(field: subs[i], showLabel: true),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        for (final field in fields.fields)
          _RequestFieldRow(
              label: field.label, child: _InputField(field: field)),
      ],
    );
  }
}

class _ContractFields extends StatelessWidget {
  final List<_ContractFieldData> fields;

  const _ContractFields({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final field in fields)
          _RequestFieldRow(
            label: field.label,
            child: _ContractInputField(field: field),
          ),
      ],
    );
  }
}

class _RequestSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _RequestSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF15803D);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withOpacity(.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestFieldRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _RequestFieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 4),
              child: Text(
                label,
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
          Expanded(flex: 2, child: child),
        ],
      ),
    );
  }
}

class _DisplayField {
  final String label;
  final String value;
  final IconData? icon;
  final bool zoneStyle;
  final int maxLines;

  const _DisplayField(
    this.label,
    this.value, {
    this.icon,
    this.zoneStyle = false,
    this.maxLines = 2,
  });
}

class _InputField extends StatelessWidget {
  final _DisplayField field;
  final bool showLabel;

  const _InputField({required this.field, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    if (field.zoneStyle) {
      final empty = field.value.isEmpty || field.value == '-';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Row(
              children: [
                Icon(field.icon, size: 14, color: const Color(0xFF15803D)),
                const SizedBox(width: 4),
                Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withOpacity(.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    field.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: empty
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return TextFormField(
      readOnly: true,
      initialValue: field.value,
      minLines: 1,
      maxLines: field.maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
      ),
      decoration:
          showLabel ? _shopSubDecoration(field.label) : _inputDecoration(null),
    );
  }
}

class _ContractFieldData {
  final String label;
  final String value;
  final bool isDate;

  const _ContractFieldData(this.label, this.value, {this.isDate = false});
}

class _ContractInputField extends StatelessWidget {
  final _ContractFieldData field;

  const _ContractInputField({required this.field});

  @override
  Widget build(BuildContext context) {
    final empty = field.value.isEmpty || field.value == '-';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              field.isDate ? Icons.event_rounded : Icons.info_outline_rounded,
              size: 16,
              color: empty ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                empty ? '-' : field.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      empty ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _shopSubDecoration(String label) {
  return InputDecoration(
    labelText: label,
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
    fillColor: const Color(0xFFF8FAFC),
    filled: true,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

InputDecoration _inputDecoration(String? label) {
  return InputDecoration(
    labelText: label,
    fillColor: const Color(0xFFF8FAFC),
    filled: true,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
