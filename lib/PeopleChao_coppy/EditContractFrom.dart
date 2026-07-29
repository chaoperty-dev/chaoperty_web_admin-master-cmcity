import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../Style/colors.dart';

// ====== ปรับตามโปรเจ็กต์คุณได้ ======
const _labelWidth = 120.0; // ความกว้างคอลัมน์ label
const _gap = 8.0; // ระยะห่างแนวนอน
const _fieldHeight = 45.0; // ความสูงช่องกรอกมาตรฐาน

final _pillBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(6),
  borderSide: const BorderSide(width: 1, color: Colors.grey),
);
final _pillBorderFocused = OutlineInputBorder(
  borderRadius: BorderRadius.circular(6),
  borderSide: const BorderSide(width: 1, color: Colors.black),
);

// ====== FieldConfig ======
class FieldConfig {
  final String label;
  final String column;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool _owned; // true = สร้างเองในคลาสนี้ (ต้อง dispose เอง)

  FieldConfig({
    required this.label,
    required this.column,
    required this.keyboardType,
    TextEditingController? controller,
  })  : controller = controller ?? TextEditingController(),
        _owned = controller == null;

  void dispose() {
    if (_owned) controller.dispose();
  }
}

// ====== ฟอร์มแสดง/แก้ไขสัญญา ======
class EditContractForm extends StatefulWidget {
  final String cid;
  // final String serren;
  // controllers ที่ส่งมาจากภายนอก
  final TextEditingController Form_nameshop;
  final TextEditingController Form_typeshop; // ประเภทร้านค้า
  final TextEditingController Form_bussshop;
  final TextEditingController Form_bussscontact;
  final TextEditingController Form_address;
  final TextEditingController Form_tel;
  final TextEditingController Form_email;
  final TextEditingController Form_tax;
  final TextEditingController Form_wnote;
  final bool readOnlys;
// ✅  callback
  final void Function(String cid, String column, String value)?
      onFieldSubmitted;
  const EditContractForm({
    super.key,
    required this.cid,
    // required this.serren,
    required this.Form_nameshop,
    required this.Form_typeshop,
    required this.Form_bussshop,
    required this.Form_bussscontact,
    required this.Form_address,
    required this.Form_tel,
    required this.Form_email,
    required this.Form_tax,
    required this.Form_wnote,
    required this.readOnlys, // <- optional
    this.onFieldSubmitted,
  });

  @override
  State<EditContractForm> createState() => _EditContractFormState();
}

class _EditContractFormState extends State<EditContractForm> {
  late final List<FieldConfig> _contractFields;

  @override
  void initState() {
    super.initState();
    _contractFields = <FieldConfig>[
      FieldConfig(
        label: 'ชื่อร้านค้า',
        column: 'sname',
        keyboardType: TextInputType.text,
        controller: widget.Form_nameshop,
      ),
      FieldConfig(
        label: 'ประเภทร้าน',
        column: 'stype',
        keyboardType: TextInputType.text,
        controller: widget.Form_typeshop,
      ),
      FieldConfig(
        label: 'ชื่อผู้เช่า/บริษัท',
        column: 'cname',
        keyboardType: TextInputType.text,
        controller: widget.Form_bussshop,
      ),
      FieldConfig(
        label: 'ชื่อผู้ติดต่อ',
        column: 'attn',
        keyboardType: TextInputType.text,
        controller: widget.Form_bussscontact,
      ),
      FieldConfig(
        label: 'ที่อยู่',
        column: 'addr',
        keyboardType: TextInputType.streetAddress,
        controller: widget.Form_address,
      ),
      FieldConfig(
        label: 'เบอร์โทร',
        column: 'tel',
        keyboardType: TextInputType.phone,
        controller: widget.Form_tel,
      ),
      FieldConfig(
        label: 'อีเมล',
        column: 'email',
        keyboardType: TextInputType.emailAddress,
        controller: widget.Form_email,
      ),
      FieldConfig(
        label: 'ID/TAX ID',
        column: 'tax',
        keyboardType: TextInputType.number,
        controller: widget.Form_tax,
      ),
      FieldConfig(
        label: 'เลขที่อ้างอิง',
        column: 'wnote',
        keyboardType: TextInputType.number,
        controller: widget.Form_wnote,
      ),
    ];

    // TODO: preload ค่าเริ่มต้นจาก API ถ้าต้องการ เช่น:
    // for (final f in _contractFields) f.controller.text = ...
  }

  @override
  void dispose() {
    for (final f in _contractFields) {
      f.dispose(); // dispose เฉพาะตัวที่สร้างเอง
    }
    super.dispose();
  }

  /// อัปเดตฟิลด์ไป PHP
  Future<bool> _updateField({
    required String cid,
    required String ren,
    required String field,
    required String value,
    String? authToken,
  }) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.cid;
    //  '${MyConstant().domain}/UP_wnote.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&value=$value'; update_field
    final uri =
        Uri.parse('${MyConstant().domain}/UP_wnote.php?isAdd=true&ren=$ren');
    // .replace(queryParameters: {'ren': ren});

    try {
      final res = await http.post(
        uri,
        // headers: {
        //   'Accept': 'application/json',
        //   if (authToken != null) 'Authorization': 'Bearer $authToken',
        // },
        body: {'cid': cid, 'field': field, 'value': value},
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        _showSnack('HTTP ${res.statusCode}: ${res.reasonPhrase}');
        return false;
      }

      final data = json.decode(res.body);
      // print(data);
      if (data is Map && data['ok'] == true) {
        Dialog_success(context, 'อัปเดตสำเร็จ');
        // _showSnack('บันทึกสำเร็จ');
        return true;
      }
      Dialog_error(context, 'อัปเดตไม่สำเร็จ');
      // _showSnack(
      //     '${(data is Map) ? (data['error'] ?? 'อัปเดตไม่สำเร็จ') : 'อัปเดตไม่สำเร็จ'}');
      return false;
    } on TimeoutException {
      Dialog_error(context, 'เกิดข้อผิดพลาด');
      //   print('เชื่อมต่อนานเกินไป (timeout)');
      // _showSnack('เชื่อมต่อนานเกินไป (timeout)');
      return false;
    } catch (e) {
      _showSnack('ผิดพลาด: $e');
      return false;
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return buildTwoColForm(
      context: context,
      fields: _contractFields,
      readOnly: widget.readOnlys, // ✅ คุม readonly ที่นี่
      onSubmit: (column, value) async {
        // ChaoAppLoader.show(
        //   useCard: false,
        //   dimBackground: true,
        //   dismissible: true,
        //   message: 'กำลังดำเนินการ...',
        //   messageStyle: const TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.black,
        //     fontFamily: FontWeight_.Fonts_T,
        //   ),
        //   slideAcross: false,
        //   vSlideAcross: false,
        //   motion: Motion.pingPong,
        //   rangeMinAt: 0.48,
        //   rangeMaxAt: 0.52,
        //   slideMs: 1800,
        //   verticalFactor: 0.5,
        //   size: 150,
        // );

        try {
          final prefs = await SharedPreferences.getInstance();
          final ren = prefs.getString('renTalSer') ?? '';
          final ciddoc = widget.cid;
          final v = value.trim();

          if (ciddoc == null || ciddoc.isEmpty) {
            _showSnack('CID ไม่ถูกต้อง');
            return;
          }
          // ถ้ามีค่าเดิมไว้เทียบ
          // if (v == (widget.Form_wnote.text ?? '')) return;

          // debugPrint({
          //   'cid': ciddoc,
          //   'ren': ren,
          //   'field': column, // ✅ ใช้ตัวแปร column
          //   'value': v,
          // }.toString());

          // ตั้ง timeout กันแขวน
          final ok = await _updateField(
            cid: ciddoc,
            ren: ren,
            field: column,
            value: v,
          ).timeout(const Duration(seconds: 20));

          if (!mounted) return;

          if (ok) {
            // call back ไปหน้าแม่
            widget.onFieldSubmitted?.call(widget.cid, column, v);

            // ปิด dialog ถ้ายังเปิดอยู่
            // final nav = Navigator.of(context);

            // if (nav.canPop()) nav.pop();

            // โชว์สำเร็จ (ไม่ต้องหน่วงก็ได้)
            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              Dialog_success(context, 'success');
            }
          } else {
            Dialog_error(context, 'บันทึกไม่สำเร็จ');
          }
        } on TimeoutException {
          if (mounted) Dialog_error(context, 'หมดเวลาการเชื่อมต่อ');
        } catch (e, st) {
          //   debugPrint('onSubmit error: $e\n$st');
          if (mounted) Dialog_error(context, 'เกิดข้อผิดพลาด: $e');
        } finally {
          // ChaoAppLoader.hide();
          // _busy = false;
        }
      },
    );
  }
}

// ====== วิว 2 คอลัมน์ (label + field, แถวละ 2 ฟิลด์) ======
Widget buildTwoColForm({
  required BuildContext context,
  required List<FieldConfig> fields,
  required bool readOnly,
  required void Function(String column, String value) onSubmit,
}) {
  final width = MediaQuery.of(context).size.width;
  final isNarrow = width < 700; // จอแคบ → คอลัมน์เดียว

  if (isNarrow) {
    // —— โหมดคอลัมน์เดียว (มือถือ/จอแคบ) ——
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: fields.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final f = fields[i];
        final h = _heightFor(f);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: _labelWidth, child: _LabelCell(text: f.label)),
            Expanded(
              child: _FieldCell(
                  height: h,
                  child: _buildField(f, onSubmit, readOnly: readOnly)),
            ),
          ],
        );
      },
    );
  }

  // —— โหมด 2 คอลัมน์เต็ม (เดสก์ท็อป/จอกว้าง) ——
  List<TableRow> rows = [];
  for (int i = 0; i < fields.length; i += 2) {
    final f1 = fields[i];
    final FieldConfig? f2 = (i + 1 < fields.length) ? fields[i + 1] : null;

    rows.add(
      TableRow(
        children: [
          _LabelCell(text: f1.label),
          _FieldCell(
              height: _heightFor(f1),
              child: _buildField(f1, onSubmit, readOnly: readOnly)),
          if (f2 != null) _LabelCell(text: f2.label) else const SizedBox(),
          if (f2 != null)
            _FieldCell(
                height: _heightFor(f2),
                child: _buildField(f2, onSubmit, readOnly: readOnly))
          else
            const SizedBox(),
        ],
      ),
    );

    // spacer แนวตั้งระหว่างแถว
    rows.add(const TableRow(children: [
      SizedBox(height: 10),
      SizedBox(height: 10),
      SizedBox(height: 10),
      SizedBox(height: 10),
    ]));
  }
  if (rows.isNotEmpty) rows.removeLast();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(_labelWidth),
        2: FixedColumnWidth(_labelWidth),
      },
      children: rows,
    ),
  );
}

double _heightFor(FieldConfig f) =>
    (f.column == 'address') ? 80.0 : _fieldHeight;

class _LabelCell extends StatelessWidget {
  const _LabelCell({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: _gap),
      child: Text(
        text,
        textAlign: TextAlign.start,
        // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
      ),
    );
  }
}

class _FieldCell extends StatelessWidget {
  const _FieldCell({required this.child, required this.height});
  final Widget child;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: _gap),
      child: SizedBox(height: height, child: child),
    );
  }
}

Widget _buildField(
  FieldConfig f,
  void Function(String column, String value) onSubmit, {
  required bool readOnly, // ✅
}) {
  // formatter ตามคอลัมน์จริง
  List<TextInputFormatter>? fmts;
  if (f.column == 'tel') {
    fmts = [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]'))];
  } else if (f.column == 'tax') {
    fmts = [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]'))];
  }

  final isAddress = f.column == 'addr';

  return TextFormField(
    controller: f.controller,
    readOnly: readOnly, // ✅ เคารพ readOnlys
    enableInteractiveSelection: !readOnly,
    inputFormatters: fmts,
    keyboardType: f.keyboardType,
    textInputAction: isAddress ? TextInputAction.newline : TextInputAction.done,
    minLines: isAddress ? 2 : 1,
    maxLines: isAddress ? 3 : 1,
    decoration: InputDecoration(
      hintText: f.label,
      isDense: true,
      filled: true,
      fillColor: readOnly == true
          ? Colors.white.withOpacity(0.3)
          : Colors.green.withOpacity(0.1),
      enabledBorder: _pillBorder,
      focusedBorder: _pillBorderFocused,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    onFieldSubmitted:
        readOnly ? null : (value) => onSubmit(f.column, value.trim()),
  );
}
