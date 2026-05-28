import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:chaoperty_floating_loader/chaoperty_floating_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
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
  final TextEditingController Form_areaaddrx;
  final TextEditingController Form_stime;
  final TextEditingController Form_ltime;
  final bool readOnlys;

  final int isMon;
  final int isTue;
  final int isWed;
  final int isThu;
  final int isFri;
  final int isSat;
  final int isSun;
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
    required this.Form_areaaddrx,
    required this.Form_stime,
    required this.Form_ltime,
    required this.readOnlys, // <- optional
    this.onFieldSubmitted,
    required this.isMon,
    required this.isTue,
    required this.isWed,
    required this.isThu,
    required this.isFri,
    required this.isSat,
    required this.isSun,
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
      // if (widget.readOnlys == false)
      FieldConfig(
        label: 'ที่อยู่พื้นที่เช่า',
        column: 'addrx',
        keyboardType: TextInputType.number,
        controller: widget.Form_areaaddrx,
      ),
      FieldConfig(
        label: 'เวลาเปิดเช่า/ทำการ',
        column: 'stime',
        keyboardType: TextInputType.number,
        controller: widget.Form_stime,
      ),
      FieldConfig(
        label: 'เวลาปิดเช่า/ทำการ',
        column: 'ltime',
        keyboardType: TextInputType.number,
        controller: widget.Form_ltime,
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
      final res = await httpClient.post(
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
      print(data);
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
      print('เชื่อมต่อนานเกินไป (timeout)');
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
    return Column(
      children: [
        buildTwoColForm(
          context: context,
          fields: (widget.readOnlys == true)
              ? _contractFields.where((e) => e.column != 'addrx').toList()
              : _contractFields,
          readOnly: widget.readOnlys, // ✅ คุม readonly ที่นี่
          onSubmit: (column, value) async {
            ChaoAppLoader.show(
              asset: 'images/LOGO.png', // หรือ .gif ก็ได้
              assetFromPackage: false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
              useCard: false,
              dimBackground: true,
              dismissible: true,
              message: 'กำลังดำเนินการ...',
              messageStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: FontWeight_.Fonts_T,
              ),
              slideAcross: false,
              vSlideAcross: false,
              motion: Motion.pingPong,
              rangeMinAt: 0.48,
              rangeMaxAt: 0.52,
              slideMs: 1800,
              verticalFactor: 0.5,
              size: 150,
            );

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

              debugPrint({
                'cid': ciddoc,
                'ren': ren,
                'field': column, // ✅ ใช้ตัวแปร column
                'value': v,
              }.toString());

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
                final nav = Navigator.of(context);

                if (nav.canPop()) nav.pop();

                // โชว์สำเร็จ (ไม่ต้องหน่วงก็ได้)
                await Future.delayed(const Duration(seconds: 1));
                if (context.mounted) {
                  Dialog_success(context, 'Successfully');
                }
              } else {
                Dialog_error(context, 'บันทึกไม่สำเร็จ');
              }
            } on TimeoutException {
              if (mounted) Dialog_error(context, 'หมดเวลาการเชื่อมต่อ');
            } catch (e, st) {
              debugPrint('onSubmit error: $e\n$st');
              if (mounted) Dialog_error(context, 'เกิดข้อผิดพลาด: $e');
            } finally {
              ChaoAppLoader.hide();
              // _busy = false;
            }
          },
        ),
        CheckDay(
            cid: widget.cid,
            readOnlys: widget.readOnlys,
            isMon: widget.isMon,
            isTue: widget.isTue,
            isWed: widget.isWed,
            isThu: widget.isThu,
            isFri: widget.isFri,
            isSat: widget.isSat,
            isSun: widget.isSun)
      ],
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

class CheckDay extends StatefulWidget {
  final cid;
  final bool readOnlys;
  final int isMon, isTue, isWed, isThu, isFri, isSat, isSun;

  const CheckDay({
    super.key,
    required this.cid,
    required this.readOnlys,
    required this.isMon,
    required this.isTue,
    required this.isWed,
    required this.isThu,
    required this.isFri,
    required this.isSat,
    required this.isSun,
  });

  @override
  State<CheckDay> createState() => _CheckDayState();
}

class _CheckDayState extends State<CheckDay> {
  late List<Map<String, dynamic>> _isDay; // ค่าของวันต่าง ๆ
  late List<bool> _checked; // สถานะติ๊ก
  final List<int> _selectedSer = <int>[]; // รายการ value ที่ถูกเลือก

  // ---------- helpers ----------
  void _buildIsDayFromWidget() {
    _isDay = [
      {'nameTh': 'จันทร์(Mon)', 'key': 'd1', 'value': widget.isMon},
      {'nameTh': 'อังคาร(Tue)', 'key': 'd2', 'value': widget.isTue},
      {'nameTh': 'พุธ(Wed)', 'key': 'd3', 'value': widget.isWed},
      {'nameTh': 'พฤหัส(Thu)', 'key': 'd4', 'value': widget.isThu},
      {'nameTh': 'ศุกร์(Fri)', 'key': 'd5', 'value': widget.isFri},
      {'nameTh': 'เสาร์(Sat)', 'key': 'd6', 'value': widget.isSat},
      {'nameTh': 'อาทิตย์(Sun)', 'key': 'd7', 'value': widget.isSun},
    ];
  }

  void _recalcSelected() {
    _selectedSer
      ..clear()
      ..addAll([
        for (int i = 0; i < _checked.length; i++)
          if (_checked[i]) _isDay[i]['value'] as int,
      ])
      ..sort();
  }

  // ---------- lifecycle ----------
  @override
  void initState() {
    super.initState();
    _buildIsDayFromWidget();
    // ค่าเริ่มต้น: ติ๊กเมื่อ value == 0 (ตามตรรกะที่คุณเขียนไว้)
    _checked = List<bool>.generate(
      _isDay.length,
      (i) => (_isDay[i]['value'] as int) == 0,
    );
    _recalcSelected();
  }

  @override
  void didUpdateWidget(covariant CheckDay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ถ้าพร็อพเกี่ยวกับวันเปลี่ยน ให้รีบิลด์ข้อมูลและรีเซ็ตสถานะตามค่าใหม่
    if (oldWidget.isMon != widget.isMon ||
        oldWidget.isTue != widget.isTue ||
        oldWidget.isWed != widget.isWed ||
        oldWidget.isThu != widget.isThu ||
        oldWidget.isFri != widget.isFri ||
        oldWidget.isSat != widget.isSat ||
        oldWidget.isSun != widget.isSun) {
      _buildIsDayFromWidget();
      _checked = List<bool>.generate(
        _isDay.length,
        (i) => (_isDay[i]['value'] as int) == 0,
      );
      _recalcSelected();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'วันที่เช่า/ทำการ',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: ReportScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.readOnlys == true
                      ? Colors.white.withOpacity(0.8)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                height: 50,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    // ป้องกันกริดไร้ความกว้าง
                    width: MediaQuery.of(context).size.width,
                    child: GridView.builder(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _isDay.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 4,
                        childAspectRatio: 3.6,
                      ),
                      itemBuilder: (context, i) {
                        final nameTh =
                            _isDay[i]['nameTh'] as String? ?? 'error';
                        final disabled = widget
                            .readOnlys; // ถ้าจะปิดตาม value ก็ OR เพิ่มได้
                        final checked =
                            (i < _checked.length) ? _checked[i] : false;

                        return Opacity(
                          opacity: disabled ? 0.85 : 1,
                          child: CheckboxListTile(
                            key: ValueKey('day_$i'),
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            mouseCursor: disabled
                                ? SystemMouseCursors.forbidden
                                : SystemMouseCursors.click,
                            title: Text(
                              nameTh,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: Font_.Fonts_T,
                                color: Colors.black,
                              ),
                            ),
                            value: checked,
                            onChanged: disabled
                                ? null
                                : (bool? v) async {
                                    if (i >= _checked.length) return;
                                    setState(() {
                                      _checked[i] = v ?? false;
                                      _recalcSelected();
                                    });

                                    // print(_isDay[i]);
                                    // Debug ดูค่า
                                    // print(_checked);
                                    // print(_selectedSer);
                                    // print(_selectedSer);
                                    // print(v);
                                    // print(_isDay[i]['key']);

                                    ChaoAppLoader.show(
                                      asset:
                                          'images/LOGO.png', // หรือ .gif ก็ได้
                                      assetFromPackage:
                                          false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                      useCard: false,
                                      dimBackground: true,
                                      dismissible: true,
                                      message: 'กำลังดำเนินการ...',
                                      messageStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                      slideAcross: false,
                                      vSlideAcross: false,
                                      motion: Motion.pingPong,
                                      rangeMinAt: 0.48,
                                      rangeMaxAt: 0.52,
                                      slideMs: 1800,
                                      verticalFactor: 0.5,
                                      size: 150,
                                    );

                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final ren =
                                          prefs.getString('renTalSer') ?? '';
                                      final ciddoc = widget.cid;
                                      int value = v == true ? 0 : 1;

                                      if (ciddoc == null || ciddoc.isEmpty) {
                                        _showSnack('CID ไม่ถูกต้อง');
                                        return;
                                      }
                                      // ถ้ามีค่าเดิมไว้เทียบ
                                      // if (v == (widget.Form_wnote.text ?? '')) return;

                                      debugPrint({
                                        'cid': ciddoc,
                                        'ren': ren,
                                        'field': _isDay[i]
                                            ['key'], // ✅ ใช้ตัวแปร column
                                        'value': value,
                                      }.toString());

                                      // ตั้ง timeout กันแขวน
                                      final ok = await _updateField(
                                        cid: ciddoc,
                                        ren: ren,
                                        field: _isDay[i]['key'],
                                        value: value.toString(),
                                      ).timeout(const Duration(seconds: 20));

                                      if (!mounted) return;

                                      if (ok) {
                                        // call back ไปหน้าแม่
                                        // widget.onFieldSubmitted
                                        //     ?.call(widget.cid, column, v);

                                        // ปิด dialog ถ้ายังเปิดอยู่
                                        final nav = Navigator.of(context);

                                        if (nav.canPop()) nav.pop();

                                        // โชว์สำเร็จ (ไม่ต้องหน่วงก็ได้)
                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                        if (context.mounted) {
                                          Dialog_success(
                                              context, 'Successfully');
                                        }
                                      } else {
                                        Dialog_error(
                                            context, 'บันทึกไม่สำเร็จ');
                                      }
                                    } on TimeoutException {
                                      if (mounted)
                                        Dialog_error(
                                            context, 'หมดเวลาการเชื่อมต่อ');
                                    } catch (e, st) {
                                      debugPrint('onSubmit error: $e\n$st');
                                      if (mounted)
                                        Dialog_error(
                                            context, 'เกิดข้อผิดพลาด: $e');
                                    } finally {
                                      ChaoAppLoader.hide();
                                      // _busy = false;
                                    }
                                  },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
      final res = await httpClient.post(
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
      print(data);
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
      print('เชื่อมต่อนานเกินไป (timeout)');
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
}
