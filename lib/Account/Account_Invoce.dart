import 'dart:async';
import 'dart:convert';

import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Model/GetPayMent_Model.dart';

class AccountInvoice extends StatefulWidget {
  const AccountInvoice({super.key});

  @override
  State<AccountInvoice> createState() => _AccountInvoiceState();
}

class _AccountInvoiceState extends State<AccountInvoice> {
  String tappedIndex_ = '';
  DateTime newDatetime = DateTime.now();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var End_Bill_Paydate;
  List<TransModel> _TransModels = [];
  List<TransModel> TransModels = <TransModel>[];
  List<PayMentModel> _PayMentModels = [];
  List<ExpModel> expModels = [];
  DateTime? _selected;
  String? paymentSer1, paymentName1, paymentSer2, paymentName2, selectedValue;
  @override
  void initState() {
    super.initState();
    End_Bill_Paydate = DateFormat('yyyy-MM-dd').format(newDatetime);
    read_Trans_invoice_all();
    red_payMent();
    read_GC_Exp();
  }

  Future<Null> read_GC_Exp() async {
    if (expModels.isNotEmpty) {
      expModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_exp_Report.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          ExpModel expModel = ExpModel.fromJson(map);

          setState(() {
            expModels.add(expModel);
          });
        }
      } else {}
    } catch (e) {}
  }

  Future<Null> red_payMent() async {
    if (_PayMentModels.length != 0) {
      setState(() {
        _PayMentModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        Map<String, dynamic> map = Map();
        map['ser'] = '0';
        map['datex'] = '';
        map['timex'] = '';
        map['ptser'] = '';
        map['ptname'] = 'เลือกการชำระ';
        map['bser'] = '';
        map['bank'] = '';
        map['bno'] = '';
        map['bname'] = '';
        map['bsaka'] = '';
        map['btser'] = '';
        map['btype'] = '';
        map['st'] = '1';
        map['rser'] = '';
        map['accode'] = '';
        map['co'] = '';
        map['data_update'] = '';
        map['auto'] = '0';

        PayMentModel _PayMentModel = PayMentModel.fromJson(map);
        setState(() {
          _PayMentModels.add(_PayMentModel);
        });

        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          setState(() {
            _PayMentModels.add(_PayMentModel);
            // if (autox == '1') {
            //   paymentSer1 = serx.toString();
            //   paymentName1 = ptnamex.toString();
            // }
          });
          if (_PayMentModel.btser.toString() == '1') {
          } else {}
        }

        if (paymentSer1 == null) {
          paymentSer1 = 0.toString();
          paymentName1 = 'เลือก'.toString();
        }
      }
    } catch (e) {}
  }

  Future<Null> read_Trans_invoice_all() async {
    if (_TransModels.isNotEmpty) {
      setState(() {
        _TransModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var zone = preferences.getString('zoneSer');
    var zone_ser = preferences.getString('zoneSubSer');
    var serMONTH = _selected == null
        ? DateFormat('MM').format(newDatetime)
        : DateFormat('MM').format(_selected!);
    var serYEAR = _selected == null
        ? DateFormat('yyyy').format(newDatetime)
        : DateFormat('yyyy').format(_selected!);

    // print('zone_ser >> $zone_ser $zone');

    String url =
        '${MyConstant().domain}/GC_tran_invoice_all_account.php?isAdd=true&ren=$ren&user=$user&serMONTH=$serMONTH&serYEAR=$serYEAR&zone=$zone&zone_ser=$zone_ser';
    //print('zone_serurl >> $url');

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'true') {
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);
          setState(() {
            _TransModels.add(_TransModel);
          });
          // print('zzzzasaaa123454>>>>  $cFinn');
          // print('docnodocnodocnodocnodocno123456>>>>  ${transBillModel.docno}');
        }
        setState(() {
          TransModels = _TransModels;
        });
      }
    } catch (e) {}
    // Future.delayed(const Duration(milliseconds: 200), () async {
    //   setState(() {
    //     red_Trans_bill();
    //   });
    // });
  }

  ////////--------------------------------------------------------------->
  _searchBarMain1() {
    return TextField(
      textAlign: TextAlign.start,
      // controller: Text_searchBar_main1,
      autofocus: false,
      cursorHeight: 20,
      keyboardType: TextInputType.text,
      style: const TextStyle(
          color: PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100]!.withOpacity(0.5),
        hintText: ' Search...',
        hintStyle: const TextStyle(
            // fontSize: 12,
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontFamily: Font_.Fonts_T),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (text) {
        // var Text_searchBar2_ = Text_searchBar_main1.text.toLowerCase();
        setState(() {
          _TransModels = TransModels.where((Invoice) {
            var notTitle = Invoice.cid.toString();
            var notTitle2 = Invoice.docno.toString();
            var notTitle3 = Invoice.ln.toString();
            var notTitle4 = Invoice.sname.toString();
            var notTitle5 = Invoice.cname.toString();
            var notTitle6 = Invoice.zn.toString();

            // var notTitle2 = Invoice.docno.toString().toLowerCase();
            // var notTitle3 = Invoice.ln.toString().toLowerCase();
            // var notTitle4 = Invoice.btype.toString().toLowerCase();
            // var notTitle5 = Invoice.bank.toString().toLowerCase();
            // var notTitle6 = Invoice.cname.toString().toLowerCase();
            // var notTitle7 = Invoice.expname.toString().toLowerCase();
            // var notTitle8 = Invoice.date.toString().toLowerCase();
            // var notTitle9 = Invoice.remark.toString().toLowerCase();
            return notTitle.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text) ||
                notTitle4.contains(text) ||
                notTitle5.contains(text) ||
                notTitle6.contains(text);
          }).toList();
        });

        if (text.isEmpty) {
        } else {}
      },
    );
  }

///////////----------------------------->
  Future<void> _onshowMonth({
    required BuildContext context,
    String? locale, // เช่น 'th' หรือ 'en'
  }) async {
    final now = DateTime.now();

    // กำหนดกรอบช่วงให้เป็น "ต้นเดือน" เพื่อความเนียน
    final first = now.subtract(const Duration(days: 120));
    final last = now.add(const Duration(days: 150));
    final firstMonth = DateTime(first.year, first.month, 1);
    final lastMonth = DateTime(last.year, last.month, 1);

    // ค่าเริ่มต้น (ถ้าเคยเลือกไว้ ใช้อันนั้น, ไม่งั้นใช้เดือนปัจจุบัน) และ normalize เป็นต้นเดือน
    final init = (_selected ?? now);
    final initialMonth = DateTime(init.year, init.month, 1);

    final picked = await showMonthYearPicker(
      context: context,
      initialDate: initialMonth,
      firstDate: firstMonth,
      lastDate: lastMonth,
      locale: (locale != null) ? Locale(locale) : null,
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            // ปรับเฉดสีให้อ่านง่ายทั้ง Light/Dark
            colorScheme: cs.copyWith(
              primary: Colors.green.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return; // ✅ กัน setState หลัง widget ถูกถอด
    if (picked != null) {
      setState(() {
        _selected = DateTime(picked.year, picked.month, 1); // normalize
      });
      Dia_log1(context);
      // ถ้า read_Trans_invoice_all เป็น Future ให้ await ได้
      final r = read_Trans_invoice_all();
      if (r is Future) await r;
    }
  }

  ///////////--------------------------------------------->
  // ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

// === helpers สั้น ๆ (วางไว้บนสุดของไฟล์/บน widget) ==========================
  String _fmtDdMMyyyySafe(String? s, {String dash = '-'}) {
    if (s == null || s.trim().isEmpty || s == '0000-00-00') return dash;
    final dt = DateTime.tryParse(s.trim());
    return (dt == null) ? dash : DateFormat('dd-MM-yyyy').format(dt);
  }

  BoxDecoration get _whiteCard => BoxDecoration(
        color: AppbackgroundColor.TiTile_Colors,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0)),
        // borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );

  Widget _pillCard(Widget child) => Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        alignment: Alignment.center,
        child: child,
      );

  Widget _label(String text) => Translate.TranslateAndSetText(
      text,
      AccountScreen_Color.Colors_Text1_,
      TextAlign.start,
      FontWeight.bold,
      FontWeight_.Fonts_T,
      14,
      1);
  final searchCtrl = TextEditingController();

  // เก็บ key ของรายการที่เลือกให้ตรงกับ value ของ items
  String? selectedPaymentKey; // เช่น 'ser:ptname'

// helper แปลง ptser → label

  String _pt(String? s) =>
      ({
        '1': '( รับชำระแบบเงินสด )',
        '2': '( แบบแนบรูป QR เอง )',
        '5': '( ระบบ Gen PromptPay QR ให้ )',
        '6': '( ระบบ Gen Standard QR [ref.1 , ref.2] ให้ )',
        '7': '( ตัวกลางรับชำระ )',
        '8': '( AIP รับชำระ ชอยส์ )'
      })[s] ??
      '';
  String _fee(it) => it.fine == '1'
      ? (it.fine_c == '0.00'
          ? 'ค่าธรรมเนียม ${it.fine_a}'
          : 'ค่าธรรมเนียม ${it.fine_c} %')
      : '';
  ImageProvider _logo(it) =>
      AssetImage((it.ptname == 'เงินสด' || it.bser == null)
          ? 'images/LogoBank/CASH.png'
          : 'images/LogoBank/${it.bcode}.png');
  Widget _tile(it) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            CircleAvatar(
                radius: 8,
                backgroundImage: _logo(it),
                backgroundColor: Colors.transparent),
            const SizedBox(width: 6),
            Expanded(
                child: Text(it.ptname ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T))),
            const SizedBox(width: 6),
            Text(it.bno ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T)),
          ]),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
                flex: 2,
                child: Text(_pt(it.ptser?.toString()),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontFamily: Font_.Fonts_T))),
            Expanded(
                flex: 1,
                child: Text(_fee(it),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.red,
                        fontFamily: Font_.Fonts_T))),
            Expanded(
                flex: 2,
                child: Text(it.bname ?? '',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontFamily: Font_.Fonts_T))),
          ]),
        ],
      );

// ==============================================================================
// ใช้แทน Row ยาว ๆ เดิมทั้งหมด
  Widget buildFiltersBarWhite(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final maxW = isDesktop ? MediaQuery.of(context).size.width * 0.85 : 1400.00;

    return Container(
      width: maxW,
      decoration: _whiteCard,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: maxW),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // ชื่อส่วน + ไอคอนข้อมูล
              _pillCard(Row(children: [
                // Icon(Icons.receipt_long_rounded,
                //     color: Colors.black87, size: 18),
                // const SizedBox(width: 8),
                // Translate.TranslateAndSetText(
                //     'วางบิล',
                //     Colors.black87,
                //     TextAlign.center,
                //     FontWeight.w700,
                //     FontWeight_.Fonts_T,
                //     14,
                //     1),
                // const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        content: SizedBox(
                          width: 360,
                          // height: 400,
                          child: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.amber[800]),
                                    const SizedBox(width: 8),
                                    Text('คำอธิบายเพิ่มเติม',
                                        style: TextStyle(
                                            color: Colors.deepOrange[700],
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '• ถ้าเลือก เดือน/ปี = ธ.ค. ค่าน้ำไฟเป็นของ พ.ย. ส่วนค่าเช่า/บริการ/อื่นๆ เป็นของ ธ.ค.\n'
                                  '• กำหนดชำระ = วันสุดท้ายที่สามารถชำระบิลนั้นๆ ได้\n'
                                  '• มีค่าปรับ หากชำระหลังวันครบกำหนด',
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text1_,
                                      fontFamily: Font_.Fonts_T,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.info_outline,
                      color: Colors.amber[800], size: 18),
                ),
              ])),

              // // ค้นหา
              // _label('ค้นหา'),
              // Container(
              //   width: 200,
              //   height: 38,
              //   decoration: BoxDecoration(
              //     color: AppbackgroundColor.Sub_Abg_Colors,
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(color: const Color(0xFFE0E0E0)),
              //   ),
              //   padding: const EdgeInsets.symmetric(horizontal: 8),
              //   child: _searchBarMain1(),
              // ),

              // เดือน/ปี
              _label('เดือน/ปี'),
              _pillCard(
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AccountScreen_Color.Colors_Text2_,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _onshowMonth(context: context, locale: 'th'),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text(
                    DateFormat('MM/yyyy').format(_selected ?? newDatetime),
                    // (_selected == null
                    //     ? DateFormat.yMMMM().format(newDatetime)
                    //     : DateFormat.yMMMM().format(_selected!)),
                    style: TextStyle(fontSize: 12, fontFamily: Font_.Fonts_T),
                  ),
                ),
              ),

              // กำหนดชำระ (ถ้ามีรายการ)
              if (_TransModels.isNotEmpty) ...[
                _label('ครบกำหนด'),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => select_Date(context),
                  child: _pillCard(Row(children: [
                    const Icon(Icons.event_available_rounded,
                        size: 18, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      _fmtDdMMyyyySafe(End_Bill_Paydate),
                      style: const TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontSize: 12,
                          fontFamily: Font_.Fonts_T),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_drop_down,
                        size: 18, color: Colors.black54),
                  ])),
                ),
              ],

              // รูปแบบชำระ (ถ้ามีรายการ)
              if (_TransModels.isNotEmpty) ...[
                _label('ชำระโดย'),
                Container(
                  width: 320,
                  height: 45,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: DropdownButtonFormField2<String>(
                    value: selectedPaymentKey,
                    isExpanded: true,
                    dropdownMaxHeight: 280,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    hint: Text(paymentName1 ?? 'เลือก',
                        style: const TextStyle(
                            fontSize: 12,
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T)),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.black45),
                    iconSize: 22,
                    buttonHeight: 60,
                    buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                    dropdownDecoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    items: _PayMentModels.map((it) => DropdownMenuItem<String>(
                          value: '${it.ser}:${it.ptname}',
                          child: _tile(it),
                        )).toList(),
                    selectedItemBuilder: (_) =>
                        _PayMentModels.map(_tile).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final i = v.indexOf(':'),
                          ser = v.substring(0, i),
                          name = v.substring(i + 1);
                      setState(() {
                        selectedPaymentKey = v;
                        paymentSer1 = ser;
                        paymentName1 = (ser == '0') ? null : name;
                      });
                    },
                  ),
                ),
                // Container(
                //   width: 320,
                //   height: 42,
                //   padding: const EdgeInsets.all(6),
                //   decoration: BoxDecoration(
                //     color: AppbackgroundColor.Sub_Abg_Colors,
                //     borderRadius: BorderRadius.circular(10),
                //     border: Border.all(color: const Color(0xFFE0E0E0)),
                //   ),
                //   child: DropdownButtonFormField2<String>(
                //     decoration: InputDecoration(
                //       isDense: true,
                //       contentPadding: EdgeInsets.zero,
                //       border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(10)),
                //     ),
                //     isExpanded: true,
                //     hint: Text(
                //       '$paymentName1',
                //       style: const TextStyle(
                //           fontSize: 14,
                //           color: PeopleChaoScreen_Color.Colors_Text2_,
                //           fontFamily: Font_.Fonts_T),
                //     ),
                //     buttonHeight: 42,
                //     icon: const Icon(Icons.arrow_drop_down,
                //         color: Colors.black45),
                //     iconSize: 22,
                //     dropdownDecoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     items:
                //         _PayMentModels.map((item) => DropdownMenuItem<String>(
                //               value: '${item.ser}:${item.ptname}',
                //               onTap: () =>
                //                   setState(() => selectedValue = item.bno!),
                //               child: Row(children: [
                //                 Expanded(
                //                     child: Text('${item.ptname!}',
                //                         style: const TextStyle(
                //                             fontSize: 14,
                //                             color: PeopleChaoScreen_Color
                //                                 .Colors_Text2_,
                //                             fontFamily: Font_.Fonts_T))),
                //                 const SizedBox(width: 8),
                //                 Text('${item.bno!}',
                //                     style: const TextStyle(
                //                         fontSize: 14,
                //                         color: PeopleChaoScreen_Color
                //                             .Colors_Text2_,
                //                         fontFamily: Font_.Fonts_T)),
                //               ]),
                //             )).toList(),
                //     onChanged: (value) {
                //       if (value == null) return;
                //       final i = value.indexOf(':');
                //       final ser = value.substring(0, i);
                //       final name = value.substring(i + 1);
                //       setState(() {
                //         paymentSer1 = ser;
                //         paymentName1 = (ser == '0') ? null : name;
                //       });
                //     },
                //   ),
                // ),
              ],

              // เลือกค่าบริการหลายรายการ (มี "เลือกทั้งหมด")
              _label('ค่าบริการ'),
              Container(
                width: 240,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: StatefulBuilder(
                    builder: (context, outerSetState) {
                      // ใช้ตัวนี้ “กระตุก” ให้ overlay ทั้งเมนูรีเฟรชทันทีที่แก้ expModels
                      final menuTick = ValueNotifier<int>(0);
                      final searchCtrl = TextEditingController();

                      return DropdownButton2<String>(
                        isExpanded: true,
                        hint: Text(
                          (expModels.where((e) => e.st == '1').isNotEmpty)
                              ? 'เลือกแล้ว ${expModels.where((e) => e.st == "1").length}/${expModels.length}'
                              : 'เลือกค่าบริการ ที่จะแสดง',
                          style: const TextStyle(
                            fontSize: 13,
                            color: ReportScreen_Color.Colors_Text1_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),

                        // ============== รายการในเมนู ==============
                        items: [
                          // 0) ช่องค้นหา (แสดงเสมอด้านบน)
                          DropdownMenuItem<String>(
                            enabled: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
                              child: TextField(
                                controller: searchCtrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'พิมพ์เพื่อค้นหา...',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ),

                          // 1) แถว “เลือกทั้งหมด”
                          DropdownMenuItem<String>(
                            value: '__select_all__',
                            enabled: false, // กันเมนูปิดเอง
                            child: InkWell(
                              onTap: () {
                                final total = expModels.length;
                                final selected =
                                    expModels.where((e) => e.st == '1').length;
                                final isAll = total > 0 && selected == total;

                                // อัปเดต parent + รีเฟรชเมนู
                                outerSetState(() {
                                  for (final e in expModels) {
                                    e.st = isAll ? '0' : '1';
                                  }
                                });
                                menuTick.value++;
                              },
                              child: ValueListenableBuilder<int>(
                                valueListenable: menuTick,
                                builder: (_, __, ___) {
                                  final total = expModels.length;
                                  final selected = expModels
                                      .where((e) => e.st == '1')
                                      .length;
                                  final isAll = total > 0 && selected == total;
                                  final isNone = selected == 0;
                                  final icon = isAll
                                      ? Icons.check_box_outlined
                                      : (isNone
                                          ? Icons.check_box_outline_blank
                                          : Icons
                                              .indeterminate_check_box_outlined);

                                  return Row(children: [
                                    Icon(icon, color: Colors.green[600]),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text('เลือกทั้งหมด',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    Text('$selected/$total',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontFamily: Font_.Fonts_T,
                                            color: Colors.black54)),
                                  ]);
                                },
                              ),
                            ),
                          ),

                          const DropdownMenuItem<String>(
                              enabled: false, child: Divider(height: 0.5)),

                          // 2) รายการจริง
                          ...expModels.map((item) => DropdownMenuItem<String>(
                                value: item.ser, // สมมติ ser เป็น String
                                enabled: false, // ไม่ให้ปิดเมนูออโต้
                                child: InkWell(
                                  onTap: () {
                                    final idx = expModels
                                        .indexWhere((e) => e.ser == item.ser);
                                    if (idx < 0) return;
                                    outerSetState(() {
                                      expModels[idx].st =
                                          (expModels[idx].st == '1')
                                              ? '0'
                                              : '1';
                                    });
                                    menuTick.value++;
                                  },
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: menuTick,
                                    builder: (_, __, ___) {
                                      final isChecked = item.st == '1';
                                      return Row(children: [
                                        Icon(
                                          isChecked
                                              ? Icons.check_box_outlined
                                              : Icons.check_box_outline_blank,
                                          color: isChecked
                                              ? Colors.green[400]
                                              : null,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.expname ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                      ]);
                                    },
                                  ),
                                ),
                              )),
                        ],

                        // ============== ค้นหา (API ของแพ็กเกจ) ==============
                        searchController: searchCtrl,
                        searchInnerWidget: const SizedBox
                            .shrink(), // เราใช้ช่องค้นหาที่เป็น item แรกอยู่แล้ว
                        searchMatchFn: (menuItem, searchValue) {
                          // ให้ “เลือกทั้งหมด” และ Divider แสดงเสมอ
                          if (menuItem.value == '__select_all__' ||
                              menuItem.value == null) return true;

                          // filter จากชื่อ/ser
                          final idx = expModels
                              .indexWhere((e) => e.ser == menuItem.value);
                          if (idx == -1) return false;
                          final name =
                              (expModels[idx].expname ?? '').toLowerCase();
                          final ser = (expModels[idx].ser ?? '').toLowerCase();
                          final q = searchValue.toLowerCase();
                          return name.contains(q) || ser.contains(q);
                        },
                        onMenuStateChange: (open) {
                          if (!open) {
                            // ปิดเมนู: เคลียร์ช่องค้นหา
                            searchCtrl.clear();
                          } else {
                            // เปิดเมนู: รีเฟรชหนึ่งทีให้ไอคอน/ตัวเลขตรงกับ state ปัจจุบัน
                            menuTick.value++;
                          }
                        },

                        // ออปชันหน้าตา
                        dropdownMaxHeight: 420,
                        onChanged: (v) {}, // ไม่ใช้ (เรา control ด้วย InkWell)
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              // ปุ่มทำบิล (ถ้ามีรายการ)
              if (_TransModels.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ButtonBill(),

                  //  ElevatedButton.icon(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.black,
                  //     foregroundColor: Colors.white,
                  //     elevation: 0,
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(10)),
                  //     padding: const EdgeInsets.symmetric(horizontal: 14),
                  //   ),
                  //   icon:
                  //       const Icon(Icons.playlist_add_check_rounded, size: 18),
                  //   label: Translate.TranslateAndSetText(
                  //       'วางบิล',
                  //       Colors.white,
                  //       TextAlign.center,
                  //       FontWeight.bold,
                  //       FontWeight_.Fonts_T,
                  //       14,
                  //       1),
                  //   onPressed: () => ButtonBill(), // หรือเรียกฟังก์ชันของคุณ
                  // ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  ///////////--------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.85
                : 1400,
            decoration: const BoxDecoration(
              color: AppbackgroundColor.Sub_Abg_Colors,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              children: [
                Container(
                    width: (Responsive.isDesktop(context))
                        ? MediaQuery.of(context).size.width * 0.85
                        : 1400,
                    child: Column(
                      children: [
                        ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          }),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            dragStartBehavior: DragStartBehavior.start,
                            child: Row(
                              children: [
                                SizedBox(
                                  child: Column(
                                    children: [
                                      buildFiltersBarWhite(context),
                                      Container(
                                        width: (Responsive.isDesktop(context))
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85
                                            : 1400,
                                        decoration: BoxDecoration(
                                          color:
                                              AppbackgroundColor.TiTile_Colors,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0)),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            // buildFiltersBarWhite(context),
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       width: (Responsive.isDesktop(
                                            //               context))
                                            //           ? MediaQuery.of(context)
                                            //                   .size
                                            //                   .width *
                                            //               0.83
                                            //           : 1300,
                                            //       decoration: BoxDecoration(
                                            //         // color: AppbackgroundColor
                                            //         //         .Sub_Abg_Colors
                                            //         //     .withOpacity(0.5),
                                            //         borderRadius:
                                            //             const BorderRadius.only(
                                            //                 topLeft:
                                            //                     Radius.circular(
                                            //                         10),
                                            //                 topRight:
                                            //                     Radius.circular(
                                            //                         10),
                                            //                 bottomLeft:
                                            //                     Radius.circular(
                                            //                         10),
                                            //                 bottomRight:
                                            //                     Radius.circular(
                                            //                         10)),
                                            //         // border: Border.all(color: Colors.white, width: 1),
                                            //       ),
                                            //       child: Row(
                                            //         children: [
                                            //           SizedBox(
                                            //             width: 10,
                                            //           ),
                                            //           Container(
                                            //             decoration:
                                            //                 BoxDecoration(
                                            //               color: AppbackgroundColor
                                            //                       .Sub_Abg_Colors
                                            //                   .withOpacity(0.5),
                                            //               borderRadius: const BorderRadius
                                            //                       .only(
                                            //                   topLeft: Radius
                                            //                       .circular(10),
                                            //                   topRight: Radius
                                            //                       .circular(10),
                                            //                   bottomLeft: Radius
                                            //                       .circular(10),
                                            //                   bottomRight:
                                            //                       Radius
                                            //                           .circular(
                                            //                               10)),
                                            //               // border: Border.all(color: Colors.white, width: 1),
                                            //             ),
                                            //             child:
                                            //                 SingleChildScrollView(
                                            //               scrollDirection:
                                            //                   Axis.horizontal,
                                            //               child: Row(
                                            //                 children: [
                                            //                   IconButton(
                                            //                       onPressed:
                                            //                           () async {
                                            //                         showDialog<
                                            //                             String>(
                                            //                           context:
                                            //                               context,
                                            //                           builder: (BuildContext
                                            //                                   context) =>
                                            //                               AlertDialog(
                                            //                             shape:
                                            //                                 RoundedRectangleBorder(
                                            //                               borderRadius:
                                            //                                   BorderRadius.circular(20),
                                            //                             ),
                                            //                             backgroundColor:
                                            //                                 AppbackgroundColor.Sub_Abg_Colors,
                                            //                             titlePadding:
                                            //                                 const EdgeInsets.all(0.0),
                                            //                             contentPadding:
                                            //                                 const EdgeInsets.all(10.0),
                                            //                             actionsPadding:
                                            //                                 const EdgeInsets.all(6.0),
                                            //                             title: Column(
                                            //                                 children: [
                                            //                                   Row(
                                            //                                     mainAxisAlignment: MainAxisAlignment.end,
                                            //                                     children: [
                                            //                                       InkWell(
                                            //                                         onTap: () {
                                            //                                           Navigator.pop(context);
                                            //                                         },
                                            //                                         child: Padding(
                                            //                                           padding: const EdgeInsets.all(4.0),
                                            //                                           child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                                            //                                         ),
                                            //                                       ),
                                            //                                     ],
                                            //                                   ),
                                            //                                 ]),
                                            //                             content:
                                            //                                 Container(
                                            //                               width:
                                            //                                   360,
                                            //                               child:
                                            //                                   SingleChildScrollView(
                                            //                                 child:
                                            //                                     ListBody(
                                            //                                   children: <Widget>[
                                            //                                     Center(
                                            //                                       child: Icon(
                                            //                                         Icons.info_outline,
                                            //                                         color: Colors.yellow[800],
                                            //                                       ),
                                            //                                     ),
                                            //                                     Padding(
                                            //                                       padding: const EdgeInsets.all(8.0),
                                            //                                       child: Center(
                                            //                                         child: Text(
                                            //                                           'คำอธิบายเพิ่มเติม',
                                            //                                           textAlign: TextAlign.center,
                                            //                                           style: TextStyle(color: Colors.deepOrange[700], fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T
                                            //                                               //fontSize: 10.0
                                            //                                               //fontSize: 10.0
                                            //                                               ),
                                            //                                         ),
                                            //                                       ),
                                            //                                     ),
                                            //                                     Padding(
                                            //                                       padding: const EdgeInsets.all(8.0),
                                            //                                       child: Text(
                                            //                                         '        ถ้ากด #เดือน/ปี เดือน ธ.ค. ค่าน้ำไฟจะเป็นของ เดือน พ.ย. \nและค่าเช่า/ค่าบริการ/ค่าอื่นๆที่ตั้งหนี้ จะเป็นของ เดือน ธ.ค.',
                                            //                                         maxLines: 4,
                                            //                                         textAlign: TextAlign.left,
                                            //                                         style: const TextStyle(
                                            //                                             color: PeopleChaoScreen_Color.Colors_Text1_,
                                            //                                             // fontWeight: FontWeight.bold,
                                            //                                             fontFamily: Font_.Fonts_T,
                                            //                                             fontSize: 14.0
                                            //                                             //fontSize: 10.0
                                            //                                             ),
                                            //                                       ),
                                            //                                     ),
                                            //                                     Padding(
                                            //                                       padding: const EdgeInsets.all(8.0),
                                            //                                       child: Text(
                                            //                                         '        วันที่ครบกำหนดชำระคือ วันสุดท้ายที่สามารถชำระใบวางบิล/ใบแจ้งหนี้นั้นๆได้ ',
                                            //                                         maxLines: 4,
                                            //                                         textAlign: TextAlign.left,
                                            //                                         style: const TextStyle(
                                            //                                             color: PeopleChaoScreen_Color.Colors_Text1_,
                                            //                                             // fontWeight: FontWeight.bold,
                                            //                                             fontFamily: Font_.Fonts_T,
                                            //                                             fontSize: 15.0
                                            //                                             //fontSize: 10.0
                                            //                                             ),
                                            //                                       ),
                                            //                                     ),
                                            //                                     Padding(
                                            //                                       padding: const EdgeInsets.all(8.0),
                                            //                                       child: Text(
                                            //                                         '        กรณีที่มีค่าปรับ ถ้าชำระใบวางบิล/ใบแจ้งหนี้ หลังวันที่ครบกำหนด จะมีค่าปรับของใบวางบิล/ใบแจ้งหนี้นั้นๆ',
                                            //                                         maxLines: 4,
                                            //                                         textAlign: TextAlign.left,
                                            //                                         style: const TextStyle(
                                            //                                             color: PeopleChaoScreen_Color.Colors_Text1_,
                                            //                                             // fontWeight: FontWeight.bold,
                                            //                                             fontFamily: Font_.Fonts_T,
                                            //                                             fontSize: 15.0
                                            //                                             //fontSize: 10.0
                                            //                                             ),
                                            //                                       ),
                                            //                                     ),
                                            //                                   ],
                                            //                                 ),
                                            //                               ),
                                            //                             ),
                                            //                           ),
                                            //                         );
                                            //                       },
                                            //                       icon: Icon(
                                            //                         Icons
                                            //                             .info_outline,
                                            //                         color: Colors
                                            //                                 .yellow[
                                            //                             800],
                                            //                       )),
                                            //                   Padding(
                                            //                     padding:
                                            //                         EdgeInsets
                                            //                             .all(
                                            //                                 2.0),
                                            //                     child: Translate.TranslateAndSetText(
                                            //                         'ค้นหา :',
                                            //                         AccountScreen_Color
                                            //                             .Colors_Text1_,
                                            //                         TextAlign
                                            //                             .start,
                                            //                         FontWeight
                                            //                             .bold,
                                            //                         FontWeight_
                                            //                             .Fonts_T,
                                            //                         14,
                                            //                         1),
                                            //                   ),
                                            //                   Padding(
                                            //                     padding:
                                            //                         const EdgeInsets
                                            //                                 .all(
                                            //                             8.0),
                                            //                     child:
                                            //                         Container(
                                            //                       height:
                                            //                           35, //Date_ser
                                            //                       width: 150,
                                            //                       decoration:
                                            //                           BoxDecoration(
                                            //                         color: AppbackgroundColor
                                            //                             .Sub_Abg_Colors,
                                            //                         borderRadius: const BorderRadius
                                            //                                 .only(
                                            //                             topLeft:
                                            //                                 Radius.circular(
                                            //                                     8),
                                            //                             topRight:
                                            //                                 Radius.circular(
                                            //                                     8),
                                            //                             bottomLeft:
                                            //                                 Radius.circular(
                                            //                                     8),
                                            //                             bottomRight:
                                            //                                 Radius.circular(8)),
                                            //                         border: Border.all(
                                            //                             color: Colors
                                            //                                 .grey,
                                            //                             width:
                                            //                                 1),
                                            //                       ),
                                            //                       child:
                                            //                           _searchBarMain1(),
                                            //                     ),
                                            //                   ),
                                            //                   Translate.TranslateAndSetText(
                                            //                       'เดือน/ปี : ',
                                            //                       AccountScreen_Color
                                            //                           .Colors_Text1_,
                                            //                       TextAlign
                                            //                           .start,
                                            //                       FontWeight
                                            //                           .bold,
                                            //                       FontWeight_
                                            //                           .Fonts_T,
                                            //                       14,
                                            //                       1),
                                            //                   // Text(
                                            //                   //   'เดือน/ปี : ',
                                            //                   //   textAlign:
                                            //                   //       TextAlign.center,
                                            //                   //   style: TextStyle(
                                            //                   //     color:
                                            //                   //         AccountScreen_Color
                                            //                   //             .Colors_Text2_,
                                            //                   //     // fontWeight: FontWeight.bold,
                                            //                   //     fontFamily:
                                            //                   //         Font_.Fonts_T,
                                            //                   //   ),
                                            //                   // ),
                                            //                   SizedBox(
                                            //                     width: 10,
                                            //                   ),
                                            //                   Padding(
                                            //                     padding:
                                            //                         const EdgeInsets
                                            //                                 .all(
                                            //                             2.0),
                                            //                     child:
                                            //                         Container(
                                            //                       height: 30,
                                            //                       decoration:
                                            //                           BoxDecoration(
                                            //                         color: AppbackgroundColor
                                            //                             .Sub_Abg_Colors,
                                            //                         borderRadius: BorderRadius.only(
                                            //                             topLeft:
                                            //                                 Radius.circular(
                                            //                                     10),
                                            //                             topRight:
                                            //                                 Radius.circular(
                                            //                                     10),
                                            //                             bottomLeft:
                                            //                                 Radius.circular(
                                            //                                     10),
                                            //                             bottomRight:
                                            //                                 Radius.circular(10)),
                                            //                         border: Border.all(
                                            //                             color: Colors
                                            //                                 .grey,
                                            //                             width:
                                            //                                 1),
                                            //                       ),
                                            //                       padding:
                                            //                           const EdgeInsets
                                            //                                   .all(
                                            //                               0.0),
                                            //                       child:
                                            //                           TextButton(
                                            //                         onPressed:
                                            //                             () async {
                                            //                           _onshowMonth(
                                            //                               context:
                                            //                                   context,
                                            //                               locale:
                                            //                                   'th');
                                            //                         },
                                            //                         child: Text(
                                            //                           _selected ==
                                            //                                   null
                                            //                               ? DateFormat.yMMMM('th_TH')
                                            //                                   .format(
                                            //                                       newDatetime)
                                            //                                   .toString()
                                            //                               : DateFormat.yMMMM('th_TH')
                                            //                                   .format(_selected!)
                                            //                                   .toString(),
                                            //                           textAlign:
                                            //                               TextAlign
                                            //                                   .center,
                                            //                           style:
                                            //                               TextStyle(
                                            //                             fontSize:
                                            //                                 12,
                                            //                             color: AccountScreen_Color
                                            //                                 .Colors_Text2_,
                                            //                             // fontWeight: FontWeight.bold,
                                            //                             fontFamily:
                                            //                                 Font_.Fonts_T,
                                            //                           ),
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                     width: 10,
                                            //                   ),
                                            //                   (_TransModels
                                            //                           .isEmpty)
                                            //                       ? SizedBox()
                                            //                       : SizedBox(
                                            //                           height:
                                            //                               40,
                                            //                           child:
                                            //                               InkWell(
                                            //                             onTap:
                                            //                                 () async {
                                            //                               select_Date(
                                            //                                   context);
                                            //                             },
                                            //                             child:
                                            //                                 Row(
                                            //                               children: [
                                            //                                 Translate.TranslateAndSetText(
                                            //                                     'วันที่ครบกำหนดชำระ : ',
                                            //                                     AccountScreen_Color.Colors_Text1_,
                                            //                                     TextAlign.start,
                                            //                                     FontWeight.bold,
                                            //                                     FontWeight_.Fonts_T,
                                            //                                     14,
                                            //                                     1),
                                            //                                 // Text(
                                            //                                 //   'วันที่ครบกำหนดชำระ : ',
                                            //                                 //   style: TextStyle(
                                            //                                 //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //                                 //       //fontWeight: FontWeight.bold,
                                            //                                 //       fontFamily: Font_.Fonts_T),
                                            //                                 // ),
                                            //                                 Padding(
                                            //                                   padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
                                            //                                   child: Container(
                                            //                                     decoration: BoxDecoration(
                                            //                                       color: Colors.white,
                                            //                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(0), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(0)),
                                            //                                       border: Border.all(color: Colors.grey, width: 1),
                                            //                                     ),
                                            //                                     // width: 120,
                                            //                                     padding: const EdgeInsets.all(2.0),
                                            //                                     child: Center(
                                            //                                       child: Text(
                                            //                                         '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${End_Bill_Paydate}'))}',
                                            //                                         // '${End_Bill_Paydate}',
                                            //                                         style: const TextStyle(
                                            //                                             color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //                                             //fontWeight: FontWeight.bold,
                                            //                                             fontFamily: Font_.Fonts_T),
                                            //                                       ),
                                            //                                     ),
                                            //                                   ),
                                            //                                 ),
                                            //                                 Container(
                                            //                                     decoration: BoxDecoration(
                                            //                                       color: Colors.white,
                                            //                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(10), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(10)),
                                            //                                       border: Border.all(color: Colors.grey, width: 1),
                                            //                                     ),
                                            //                                     // width: 120,
                                            //                                     child: Icon(
                                            //                                       Icons.arrow_drop_down,
                                            //                                       color: Colors.black,
                                            //                                     )),
                                            //                               ],
                                            //                             ),
                                            //                           ),
                                            //                         ),
                                            //                   (_TransModels
                                            //                           .isEmpty)
                                            //                       ? SizedBox()
                                            //                       : SizedBox(
                                            //                           width: 10,
                                            //                         ),
                                            //                   (_TransModels
                                            //                           .isEmpty)
                                            //                       ? SizedBox()
                                            //                       : Translate.TranslateAndSetText(
                                            //                           'รูปแบบชำระ',
                                            //                           AccountScreen_Color
                                            //                               .Colors_Text1_,
                                            //                           TextAlign
                                            //                               .start,
                                            //                           FontWeight
                                            //                               .bold,
                                            //                           FontWeight_
                                            //                               .Fonts_T,
                                            //                           14,
                                            //                           1),
                                            //                   //  Text(
                                            //                   //     'รูปแบบชำระ',
                                            //                   //     style:
                                            //                   //         const TextStyle(
                                            //                   //             color: PeopleChaoScreen_Color
                                            //                   //                 .Colors_Text2_,
                                            //                   //             //fontWeight: FontWeight.bold,
                                            //                   //             fontFamily:
                                            //                   //                 Font_
                                            //                   //                     .Fonts_T),
                                            //                   // ),
                                            //                   (_TransModels
                                            //                           .isEmpty)
                                            //                       ? SizedBox()
                                            //                       : Container(
                                            //                           height:
                                            //                               50,
                                            //                           width:
                                            //                               350,
                                            //                           // color:
                                            //                           //     AppbackgroundColor
                                            //                           //         .Sub_Abg_Colors,
                                            //                           padding:
                                            //                               const EdgeInsets.all(
                                            //                                   8.0),
                                            //                           child:
                                            //                               Container(
                                            //                             decoration:
                                            //                                 BoxDecoration(
                                            //                               color:
                                            //                                   AppbackgroundColor.Sub_Abg_Colors,
                                            //                               borderRadius: const BorderRadius.only(
                                            //                                   topLeft: Radius.circular(10),
                                            //                                   topRight: Radius.circular(10),
                                            //                                   bottomLeft: Radius.circular(10),
                                            //                                   bottomRight: Radius.circular(10)),
                                            //                               // border: Border.all(
                                            //                               //     color: Colors.grey, width: 1),
                                            //                             ),
                                            //                             width:
                                            //                                 120,
                                            //                             child:
                                            //                                 DropdownButtonFormField2(
                                            //                               decoration:
                                            //                                   InputDecoration(
                                            //                                 //Add isDense true and zero Padding.
                                            //                                 //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                            //                                 isDense:
                                            //                                     true,
                                            //                                 contentPadding:
                                            //                                     EdgeInsets.zero,
                                            //                                 border:
                                            //                                     OutlineInputBorder(
                                            //                                   borderRadius: BorderRadius.circular(15),
                                            //                                 ),
                                            //                                 //Add more decoration as you want here
                                            //                                 //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                            //                               ),
                                            //                               isExpanded:
                                            //                                   true,
                                            //                               // disabledHint: Icon(Icons.time_to_leave, color: Colors.black),
                                            //                               hint:
                                            //                                   Row(
                                            //                                 children: [
                                            //                                   Text(
                                            //                                     '$paymentName1',
                                            //                                     style: const TextStyle(
                                            //                                         fontSize: 14,
                                            //                                         color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //                                         // fontWeight: FontWeight.bold,
                                            //                                         fontFamily: Font_.Fonts_T),
                                            //                                   ),
                                            //                                 ],
                                            //                               ),
                                            //                               icon:
                                            //                                   const Icon(
                                            //                                 Icons.arrow_drop_down,
                                            //                                 color:
                                            //                                     Colors.black45,
                                            //                               ),
                                            //                               iconSize:
                                            //                                   25,
                                            //                               buttonHeight:
                                            //                                   42,
                                            //                               // buttonPadding:
                                            //                               //     const EdgeInsets
                                            //                               //         .only(
                                            //                               //         left:
                                            //                               //             10,
                                            //                               //         right:
                                            //                               //             10),
                                            //                               dropdownDecoration:
                                            //                                   BoxDecoration(
                                            //                                 borderRadius:
                                            //                                     BorderRadius.circular(15),
                                            //                               ),
                                            //                               items: _PayMentModels.map((item) =>
                                            //                                   DropdownMenuItem<String>(
                                            //                                     onTap: () {
                                            //                                       setState(() {
                                            //                                         selectedValue = item.bno!;
                                            //                                       });
                                            //                                       // print(
                                            //                                       //     '**/*/*   --- ${selectedValue}');
                                            //                                     },
                                            //                                     value: '${item.ser}:${item.ptname}',
                                            //                                     child: Row(
                                            //                                       children: [
                                            //                                         Expanded(
                                            //                                           child: Text(
                                            //                                             '${item.ptname!}',
                                            //                                             textAlign: TextAlign.start,
                                            //                                             style: const TextStyle(
                                            //                                                 fontSize: 14,
                                            //                                                 color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //                                                 // fontWeight: FontWeight.bold,
                                            //                                                 fontFamily: Font_.Fonts_T),
                                            //                                           ),
                                            //                                         ),
                                            //                                         Expanded(
                                            //                                           child: Text(
                                            //                                             '${item.bno!}',
                                            //                                             textAlign: TextAlign.end,
                                            //                                             style: const TextStyle(
                                            //                                                 fontSize: 14,
                                            //                                                 color: PeopleChaoScreen_Color.Colors_Text2_,
                                            //                                                 // fontWeight: FontWeight.bold,
                                            //                                                 fontFamily: Font_.Fonts_T),
                                            //                                           ),
                                            //                                         ),
                                            //                                       ],
                                            //                                     ),
                                            //                                   )).toList(),
                                            //                               onChanged:
                                            //                                   (value) async {
                                            //                                 // print(
                                            //                                 //     value);
                                            //                                 // Do something when changing the item if you want.

                                            //                                 var zones =
                                            //                                     value!.indexOf(':');
                                            //                                 var rtnameSer =
                                            //                                     value.substring(0, zones);
                                            //                                 var rtnameName =
                                            //                                     value.substring(zones + 1);
                                            //                                 // print(
                                            //                                 //     'mmmmm ${rtnameSer.toString()} $rtnameName');
                                            //                                 setState(() {
                                            //                                   paymentSer1 = rtnameSer.toString();

                                            //                                   if (rtnameSer.toString() == '0') {
                                            //                                     paymentName1 = null;
                                            //                                   } else {
                                            //                                     paymentName1 = rtnameName.toString();
                                            //                                   }
                                            //                                   // paymentSer1 =
                                            //                                   //     rtnameSer;
                                            //                                 });
                                            //                                 // print(
                                            //                                 //     'mmmmm ${rtnameSer.toString()} $rtnameName');
                                            //                                 // print(
                                            //                                 //     'pppppp $paymentSer1 $paymentName1');
                                            //                                 // print('Form_payment1.text');
                                            //                                 // print(Form_payment1.text);
                                            //                                 // print(Form_payment2.text);
                                            //                                 // print('Form_payment1.text');
                                            //                               },
                                            //                               // onSaved: (value) {

                                            //                               // },
                                            //                             ),
                                            //                           ),
                                            //                         ),
                                            //                   Padding(
                                            //                     padding:
                                            //                         const EdgeInsets
                                            //                                 .fromLTRB(
                                            //                             2,
                                            //                             2,
                                            //                             2,
                                            //                             0),
                                            //                     child:
                                            //                         Container(
                                            //                       height: 30,
                                            //                       decoration:
                                            //                           BoxDecoration(
                                            //                         color: AppbackgroundColor
                                            //                                 .TiTile_Colors
                                            //                             .withOpacity(
                                            //                                 0.5),
                                            //                         borderRadius: BorderRadius.only(
                                            //                             topLeft:
                                            //                                 Radius.circular(
                                            //                                     10),
                                            //                             topRight:
                                            //                                 Radius.circular(
                                            //                                     10),
                                            //                             bottomLeft:
                                            //                                 Radius.circular(
                                            //                                     10),
                                            //                             bottomRight:
                                            //                                 Radius.circular(10)),
                                            //                         border: Border.all(
                                            //                             color: Colors
                                            //                                 .grey,
                                            //                             width:
                                            //                                 1),
                                            //                       ),
                                            //                       width: 220,
                                            //                       // height: 30,
                                            //                       padding:
                                            //                           const EdgeInsets
                                            //                                   .all(
                                            //                               2.0),
                                            //                       child:
                                            //                           DropdownButtonHideUnderline(
                                            //                         child: DropdownButton2<
                                            //                             String>(
                                            //                           isExpanded:
                                            //                               true,
                                            //                           hint:
                                            //                               Text(
                                            //                             (expModels.where((e) => e.st == '1').length >
                                            //                                     0)
                                            //                                 ? 'เลือกแล้ว ${expModels.where((e) => e.st == "1").length}/${expModels.length}'
                                            //                                 : 'เลือกค่าบริการ ที่จะแสดง',
                                            //                             style:
                                            //                                 const TextStyle(
                                            //                               fontSize:
                                            //                                   14,
                                            //                               color:
                                            //                                   ReportScreen_Color.Colors_Text1_,
                                            //                               fontFamily:
                                            //                                   Font_.Fonts_T,
                                            //                             ),
                                            //                           ),
                                            //                           items: [
                                            //                             // =========================
                                            //                             // 1) แถว "เลือกทั้งหมด"
                                            //                             // =========================
                                            //                             DropdownMenuItem<
                                            //                                 String>(
                                            //                               value:
                                            //                                   '__select_all__',
                                            //                               enabled:
                                            //                                   false, // กัน onChanged ปิดเมนู
                                            //                               child:
                                            //                                   StatefulBuilder(
                                            //                                 builder:
                                            //                                     (context, menuSetState) {
                                            //                                   final total = expModels.length;
                                            //                                   final selected = expModels.where((e) => e.st == '1').length;
                                            //                                   final isAll = total > 0 && selected == total;
                                            //                                   final isNone = selected == 0;

                                            //                                   final icon = isAll ? Icons.check_box_outlined : (isNone ? Icons.check_box_outline_blank : Icons.indeterminate_check_box_outlined);

                                            //                                   return InkWell(
                                            //                                     onTap: () {
                                            //                                       // ถ้าเลือกครบแล้ว -> ยกเลิกทั้งหมด, ถ้ายังไม่ครบ -> เลือกทั้งหมด
                                            //                                       final selectAll = !isAll;
                                            //                                       // อัปเดตที่ parent
                                            //                                       setState(() {
                                            //                                         for (final e in expModels) {
                                            //                                           e.st = selectAll ? '1' : '0';
                                            //                                         }
                                            //                                       });
                                            //                                       // อัปเดตภาพในเมนู
                                            //                                       menuSetState(() {});
                                            //                                     },
                                            //                                     child: Container(
                                            //                                       height: 48,
                                            //                                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            //                                       child: Row(
                                            //                                         children: [
                                            //                                           Icon(icon, color: Colors.green[600]),
                                            //                                           const SizedBox(width: 16),
                                            //                                           const Expanded(
                                            //                                             child: Text(
                                            //                                               'เลือกทั้งหมด',
                                            //                                               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                            //                                             ),
                                            //                                           ),
                                            //                                           Text(
                                            //                                             '$selected/$total',
                                            //                                             style: const TextStyle(fontSize: 12, color: Colors.black54),
                                            //                                           ),
                                            //                                         ],
                                            //                                       ),
                                            //                                     ),
                                            //                                   );
                                            //                                 },
                                            //                               ),
                                            //                             ),

                                            //                             // 2) เส้นคั่น
                                            //                             const DropdownMenuItem<
                                            //                                 String>(
                                            //                               enabled:
                                            //                                   false,
                                            //                               child:
                                            //                                   Divider(height: 1),
                                            //                             ),

                                            //                             // =========================
                                            //                             // 3) รายการจริงของ expModels
                                            //                             // =========================
                                            //                             ...expModels
                                            //                                 .map((item) {
                                            //                               return DropdownMenuItem<
                                            //                                   String>(
                                            //                                 value:
                                            //                                     item.ser, // สมมติ ser เป็น String
                                            //                                 enabled:
                                            //                                     false, // กันเมนูปิดเอง
                                            //                                 child:
                                            //                                     StatefulBuilder(
                                            //                                   builder: (context, menuSetState) {
                                            //                                     final isChecked = item.st == '1';
                                            //                                     return InkWell(
                                            //                                       onTap: () {
                                            //                                         final idx = expModels.indexWhere((e) => e.ser == item.ser);
                                            //                                         if (idx < 0) return;
                                            //                                         setState(() {
                                            //                                           expModels[idx].st = isChecked ? '0' : '1';
                                            //                                         });
                                            //                                         menuSetState(() {}); // รีเฟรชเฉพาะเมนู
                                            //                                       },
                                            //                                       child: Container(
                                            //                                         height: 48,
                                            //                                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            //                                         child: Row(
                                            //                                           children: [
                                            //                                             Icon(
                                            //                                               isChecked ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                            //                                               color: isChecked ? Colors.green[400] : null,
                                            //                                             ),
                                            //                                             const SizedBox(width: 16),
                                            //                                             Expanded(
                                            //                                               child: Text(
                                            //                                                 item.expname ?? '',
                                            //                                                 style: const TextStyle(fontSize: 14),
                                            //                                                 overflow: TextOverflow.ellipsis,
                                            //                                               ),
                                            //                                             ),
                                            //                                           ],
                                            //                                         ),
                                            //                                       ),
                                            //                                     );
                                            //                                   },
                                            //                                 ),
                                            //                               );
                                            //                             }).toList(),
                                            //                           ],

                                            //                           // ไม่ใช้ onChanged เพราะเราคุมปิด/เปิดเองด้วย enabled:false + InkWell
                                            //                           onChanged:
                                            //                               (value) {},

                                            //                           // (ออปชัน) จำกัดความสูงเมนู
                                            //                           dropdownMaxHeight:
                                            //                               360,
                                            //                           // (ออปชัน) ความกว้างเมนู/ปุ่มปรับเองได้
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           (_TransModels.isEmpty)
                                            //               ? SizedBox()
                                            //               : SizedBox(
                                            //                   child:
                                            //                       ButtonBill(),
                                            //                 ),
                                            //         ],
                                            //       ),
                                            //     ),

                                            //     // Expanded(
                                            //     //     child: (_TransModels
                                            //     //             .isEmpty)
                                            //     //         ? SizedBox()
                                            //     //         : SizedBox(
                                            //     //             child: ButtonBill(),
                                            //     //           ))
                                            //   ],
                                            // ),
                                            const Divider(
                                              height: 1,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ลำดับ',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'เลขที่สัญญา',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'โซนพื้นที่',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'รหัสพื้นที่',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ชื่อร้านค้า',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ชื่อผู้เช่า',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'เดือน/ปี',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'ปี',
                                                //           AccountScreen_Color
                                                //               .Colors_Text2_,
                                                //           TextAlign.left,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'Qty/รายการ',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.end,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ยอดรวม',
                                                          AccountScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.end,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.63,
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85
                                              : 1400,
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(0)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          child: _TransModels.isEmpty
                                              ? SizedBox(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const CircularProgressIndicator(),
                                                      StreamBuilder(
                                                        stream: Stream.periodic(
                                                            const Duration(
                                                                milliseconds:
                                                                    25),
                                                            (i) => i),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot.hasData)
                                                            return const Text(
                                                                '');
                                                          double elapsed = double
                                                                  .parse(snapshot
                                                                      .data
                                                                      .toString()) *
                                                              0.05;
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: (elapsed >
                                                                    8.00)
                                                                ? Translate.TranslateAndSetText(
                                                                    'ไม่พบข้อมูล',
                                                                    AccountScreen_Color
                                                                        .Colors_Text2_,
                                                                    TextAlign
                                                                        .center,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1)
                                                                : Text(
                                                                    'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                                    // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                    style: const TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T
                                                                        //fontSize: 10.0
                                                                        ),
                                                                  ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : ListView.builder(
                                                  controller:
                                                      _scrollController2,
                                                  // itemExtent: 50,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _TransModels.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Column(
                                                      children: [
                                                        Material(
                                                          color: tappedIndex_ ==
                                                                  index
                                                                      .toString()
                                                              ? tappedIndex_Color
                                                                  .tappedIndex_Colors
                                                              : AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          child: Container(
                                                            child: ListTile(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    tappedIndex_ =
                                                                        '${index}';
                                                                  });
                                                                },
                                                                title:
                                                                    Container(
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    // color: Colors.green[100]!
                                                                    //     .withOpacity(0.5),
                                                                    border:
                                                                        Border(
                                                                      bottom:
                                                                          BorderSide(
                                                                        color: Colors
                                                                            .black12,
                                                                        width:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          '${index + 1}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Copy_Text(context,
                                                                                '${_TransModels[index].refno}'),
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${_TransModels[index].refno}',
                                                                                textAlign: TextAlign.left,
                                                                                maxLines: 1,
                                                                                style: const TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: AccountScreen_Color.Colors_Text2_,
                                                                                  // fontWeight:
                                                                                  //     FontWeight.bold,
                                                                                  fontFamily: Font_.Fonts_T,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          '${_TransModels[index].zn}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          '${_TransModels[index].ln}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          '${_TransModels[index].sname}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          '${_TransModels[index].cname}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          (_TransModels[index].date == null)
                                                                              ? '-'
                                                                              : DateFormat('MMM', 'th').format(DateTime.parse(_TransModels[index].date!)).toString() + '' + DateFormat.y('th_TH').format(DateTime.parse('${_TransModels[index].date} 00:00:00')).toString(),
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // Expanded(
                                                                      //   flex: 1,
                                                                      //   child:
                                                                      //       Text((_TransModels[index].date == null)
                                                                      //         ? '-'
                                                                      //         :
                                                                      //     DateFormat.y('th_TH')
                                                                      //         .format(DateTime.parse('${_TransModels[index].date} 00:00:00'))
                                                                      //         .toString(),
                                                                      //     textAlign:
                                                                      //         TextAlign.left,
                                                                      //     maxLines:
                                                                      //         1,
                                                                      //     style:
                                                                      //         const TextStyle( fontSize:
                                                                      //           14,
                                                                      //       color:
                                                                      //           AccountScreen_Color.Colors_Text2_,
                                                                      //       // fontWeight:
                                                                      //       //     FontWeight.bold,
                                                                      //       fontFamily:
                                                                      //           Font_.Fonts_T,
                                                                      //     ),
                                                                      //   ),
                                                                      // ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          (_TransModels[index].count_ser == null)
                                                                              ? '0 รายการ'
                                                                              : '${_TransModels[index].count_ser} รายการ',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          (_TransModels[index].c_amt == null)
                                                                              ? '0.00'
                                                                              : '${nFormat.format(double.parse(_TransModels[index].c_amt!))}',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                AccountScreen_Color.Colors_Text2_,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  })),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            width: (Responsive.isDesktop(context))
                                ? MediaQuery.of(context).size.width * 0.85
                                : MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () {
                                            _scrollController2.animateTo(
                                              0,
                                              duration:
                                                  const Duration(seconds: 1),
                                              curve: Curves.easeOut,
                                            );
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                // color: AppbackgroundColor
                                                //     .TiTile_Colors,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(8)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: const Text(
                                                'Top',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (_scrollController2.hasClients) {
                                            final position = _scrollController2
                                                .position.maxScrollExtent;
                                            _scrollController2.animateTo(
                                              position,
                                              duration:
                                                  const Duration(seconds: 1),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              // color: AppbackgroundColor
                                              //     .TiTile_Colors,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(6),
                                                      topRight:
                                                          Radius.circular(6),
                                                      bottomLeft:
                                                          Radius.circular(6),
                                                      bottomRight:
                                                          Radius.circular(6)),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(3.0),
                                            child: const Text(
                                              'Down',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: _moveUp2,
                                        child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Icon(
                                                Icons.arrow_upward,
                                                color: Colors.grey,
                                              ),
                                            )),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                            // color: AppbackgroundColor
                                            //     .TiTile_Colors,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(6),
                                                    topRight:
                                                        Radius.circular(6),
                                                    bottomLeft:
                                                        Radius.circular(6),
                                                    bottomRight:
                                                        Radius.circular(6)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          padding: const EdgeInsets.all(3.0),
                                          child: const Text(
                                            'Scroll',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                      InkWell(
                                        onTap: _moveDown2,
                                        child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.arrow_downward,
                                                color: Colors.grey,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Future<Null> select_Date(BuildContext context) async {
    final Future<DateTime?> picked = showDatePicker(
      // locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่ครบกำหนด', confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      context: context,
      initialDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month + 6, DateTime.now().day),
      // selectableDayPredicate: _decideWhichDayToEnable,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppBarColors.ABar_Colors, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    picked.then((result) {
      // ignore: unnecessary_null_comparison
      if (picked != null) {
        var formatter = DateFormat('yyyy-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          End_Bill_Paydate = "${formatter.format(result)}";
        });
      }
    });
  }

  String _formatDdMMyyyy({DateTime? selected, String? fallback}) {
    // กันค่าที่ไม่โอเคจากฝั่งเซิร์ฟเวอร์
    const bad = {'', 'null', 'NULL', '0000-00-00', '0000-00-00 00:00:00'};
    if (selected != null) {
      return DateFormat('dd-MM-yyyy').format(selected);
    }
    if (fallback == null || bad.contains(fallback.trim())) return '-';

    // ลอง parse แบบยืดหยุ่น
    final s = fallback.trim();
    DateTime? dt;

    // 1) รูป ISO หรือ parse ได้ตรง ๆ
    dt = DateTime.tryParse(s);

    // 2) รูปแบบยอดฮิตจาก PHP/MySQL
    dt ??= _tryParseMany(s, const [
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'yyyy-MM-dd HH:mm:ss',
      "yyyy-MM-dd'T'HH:mm:ss",
    ]);

    return (dt != null) ? DateFormat('dd-MM-yyyy').format(dt) : '-';
  }

  DateTime? _tryParseMany(String s, List<String> patterns) {
    for (final p in patterns) {
      try {
        return DateFormat(p).parseStrict(s);
      } catch (_) {}
    }
    return null;
  }

  Widget ButtonBill() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
      label: Translate.TranslateAndSetText('วางบิล', Colors.white,
          TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
      onPressed: () async {
        if (expModels.every((e) => e.st != '1')) {
          Dialog_error(context, 'กรุณาเลือกค่าบริการอย่างน้อย 1 รายการ');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //       content: Text('กรุณาเลือกค่าบริการอย่างน้อย 1 รายการ')),
          // );
          return;
        }
        if (paymentName1 == null ||
            paymentName1!.isEmpty ||
            paymentName1 == 'เลือก' ||
            paymentName1 == 'null') {
          Dialog_error(context, 'กรุณาเลือกรูปแบบชำระเงิน');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('กรุณาเลือกรูปแบบชำระเงิน')),
          // );
          return;
        }

        // final List<int> ser_expModels = expModels
        //     .where((e) => e.st == '1')
        //     .map((e) => int.tryParse(e.ser ?? ''))
        //     .whereType<int>() // ตัด null ออก
        //     .toList();

        // print(ser_expModels);

        final w = (Responsive.isDesktop(context))
            ? (MediaQuery.of(context).size.width * 0.47 - 16) / 2
            : double.infinity;
        final parentCtx = context;

        await showDialog<bool>(
          context: parentCtx,
          barrierDismissible: false,
          builder: (dialogCtx) {
            bool submitting = false;
            double _progress = 0.0; // 0..1 (<=0 = indeterminate)
            int? _done, _total;

            Widget _pill(IconData icon, String label) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFEFEFEF)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                );

            return StatefulBuilder(
              builder: (ctx, setD) => Dialog(
                backgroundColor: Colors.white,
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: w,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // เน้นขาว
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEFEFEF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // หัวเรื่อง
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_rounded,
                              color: Colors.black87),
                          const SizedBox(width: 8),
                          Translate.TranslateAndSetText(
                            'ยืนยันการวางบิลทั้งหมด',
                            Colors.black87,
                            TextAlign.center,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            16,
                            1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // สลับ "สรุป" <-> "กำลังทำงาน" ด้วย AnimatedSwitcher
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child:
                              //  !submitting
                              //     ?
                              Column(
                            key: const ValueKey('summary'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _pill(Icons.list_alt_rounded,
                                      'ทั้งหมด : ${_TransModels.length} รายการ'),
                                  //  '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${End_Bill_Paydate}'))}',
                                  // _pill(
                                  //     Icons
                                  //         .calendar_month_rounded,

                                  //     DateFormat('dd-MM-yyyy')
                                  //         .format(_selected ??
                                  //             newDatetime)),
                                  _pill(
                                    Icons.calendar_month_rounded,
                                    _formatDdMMyyyy(
                                      selected:
                                          _selected, // ถ้ามี DateTime จาก date picker
                                      fallback:
                                          End_Bill_Paydate, // ถ้าไม่มี ให้ลองจาก string ฝั่งเซิร์ฟเวอร์
                                    ),
                                  ),

                                  if (paymentSer1 != null &&
                                      '$paymentSer1'.isNotEmpty)
                                    _pill(Icons.payments_rounded,
                                        'วิธีชำระ : $paymentName1'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              !submitting
                                  ? SizedBox()
                                  : SizedBox(
                                      child: Column(
                                        key: const ValueKey('progress'),
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: _progress <= 0.0
                                                        ? null
                                                        : _progress,
                                                    minHeight: 8,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                _total == null
                                                    ? '${(_progress * 100).toStringAsFixed(0)}%'
                                                    : '${(_progress * 100).toStringAsFixed(0)}%  (${_done ?? 0}/${_total})',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                              'กำลังวางบิล โปรดอย่าปิดหน้าต่างนี้',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                            ],
                          )
                          // : Column(
                          //     key: const ValueKey('progress'),
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             child: ClipRRect(
                          //               borderRadius:
                          //                   BorderRadius.circular(
                          //                       8),
                          //               child:
                          //                   LinearProgressIndicator(
                          //                 value: _progress <= 0.0
                          //                     ? null
                          //                     : _progress,
                          //                 minHeight: 8,
                          //                 backgroundColor: Colors
                          //                     .grey.shade200,
                          //               ),
                          //             ),
                          //           ),
                          //           const SizedBox(width: 12),
                          //           Text(
                          //             _total == null
                          //                 ? '${(_progress * 100).toStringAsFixed(0)}%'
                          //                 : '${(_progress * 100).toStringAsFixed(0)}%  (${_done ?? 0}/${_total})',
                          //             style: const TextStyle(
                          //                 fontWeight:
                          //                     FontWeight.w600),
                          //           ),
                          //         ],
                          //       ),
                          //       const SizedBox(height: 8),
                          //       const Text(
                          //           'กำลังวางบิล โปรดอย่าปิดหน้าต่างนี้',
                          //           style: TextStyle(
                          //               color: Colors.black54,
                          //               fontSize: 12)),
                          //     ],
                          //   ),
                          ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEFEFEF)),
                      const SizedBox(height: 20),

                      // ปุ่ม
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: submitting
                                  ? null
                                  : () => Navigator.pop(dialogCtx, false),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Translate.TranslateAndSetText(
                                    'ยกเลิก',
                                    Colors.black87,
                                    TextAlign.center,
                                    FontWeight.w600,
                                    FontWeight_.Fonts_T,
                                    14,
                                    1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.black26,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              icon: submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.check_circle_rounded,
                                      size: 18),
                              label: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Translate.TranslateAndSetText(
                                    submitting ? 'กำลังบันทึก...' : 'ยืนยัน',
                                    Colors.white,
                                    TextAlign.center,
                                    FontWeight.w700,
                                    FontWeight_.Fonts_T,
                                    14,
                                    1),
                              ),
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      if (_TransModels.isEmpty) {
                                        ScaffoldMessenger.of(parentCtx)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Translate.TranslateAndSetText(
                                                      'กรุณาเลือก เดือน ปี ที่ต้องการวางบิล',
                                                      Colors.white,
                                                      TextAlign.start,
                                                      FontWeight.bold,
                                                      FontWeight_.Fonts_T,
                                                      14,
                                                      1)),
                                        );
                                        return;
                                      }

                                      setD(() {
                                        submitting = true;
                                        _progress = 0.0;
                                        _done = _total = null;
                                      });

                                      // ✅ ผูก Progress จริงจากเซิร์ฟเวอร์
                                      final ok = await inTransInvoiceAll(
                                        parentCtx,
                                        onProgress: (p,
                                            {int? done,
                                            int? total,
                                            String? status}) {
                                          setD(() {
                                            _progress = (p.isNaN ? 0.0 : p)
                                                .clamp(0.0, 1.0);
                                            _done = done;
                                            _total = total;
                                          });
                                        },
                                      );

                                      if (!mounted) return;
                                      Navigator.pop(dialogCtx, ok);
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }, // หรือเรียกฟังก์ชันของคุณ
    );

    // Container(
    //   // color: Colors.white,
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.end,
    //       children: [
    //         Container(
    //           // width: 200,
    //           decoration: BoxDecoration(
    //             color: Colors.green,
    //             borderRadius: const BorderRadius.only(
    //                 topLeft: Radius.circular(6),
    //                 topRight: Radius.circular(6),
    //                 bottomLeft: Radius.circular(6),
    //                 bottomRight: Radius.circular(6)),
    //             border: Border.all(color: Colors.white, width: 1),
    //           ),
    //           child: Padding(
    //             padding: const EdgeInsets.all(2.0),
    //             child: TextButton(
    //               onPressed: () async {
    //                 final w = (Responsive.isDesktop(context))
    //                     ? (MediaQuery.of(context).size.width * 0.47 - 16) / 2
    //                     : double.infinity;
    //                 final parentCtx = context;

    //                 await showDialog<bool>(
    //                   context: parentCtx,
    //                   barrierDismissible: false,
    //                   builder: (dialogCtx) {
    //                     bool submitting = false;
    //                     double _progress = 0.0; // 0..1 (<=0 = indeterminate)
    //                     int? _done, _total;

    //                     Widget _pill(IconData icon, String label) => Container(
    //                           padding: const EdgeInsets.symmetric(
    //                               horizontal: 10, vertical: 6),
    //                           decoration: BoxDecoration(
    //                             color: const Color(0xFFF5F7FA),
    //                             borderRadius: BorderRadius.circular(999),
    //                             border:
    //                                 Border.all(color: const Color(0xFFEFEFEF)),
    //                           ),
    //                           child: Row(
    //                               mainAxisSize: MainAxisSize.min,
    //                               children: [
    //                                 Icon(icon, size: 16, color: Colors.black54),
    //                                 const SizedBox(width: 6),
    //                                 Text(label,
    //                                     style: const TextStyle(
    //                                         color: Colors.black87,
    //                                         fontSize: 12,
    //                                         fontWeight: FontWeight.w600)),
    //                               ]),
    //                         );

    //                     return StatefulBuilder(
    //                       builder: (ctx, setD) => Dialog(
    //                         backgroundColor: Colors.white,
    //                         insetPadding: const EdgeInsets.symmetric(
    //                             horizontal: 24, vertical: 24),
    //                         shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.circular(20)),
    //                         child: Container(
    //                           width: w,
    //                           padding:
    //                               const EdgeInsets.fromLTRB(16, 20, 16, 12),
    //                           decoration: BoxDecoration(
    //                             color: Colors.white, // เน้นขาว
    //                             borderRadius: BorderRadius.circular(20),
    //                             border:
    //                                 Border.all(color: const Color(0xFFEFEFEF)),
    //                             boxShadow: [
    //                               BoxShadow(
    //                                 color: Colors.black.withOpacity(0.08),
    //                                 blurRadius: 20,
    //                                 offset: const Offset(0, 10),
    //                               ),
    //                             ],
    //                           ),
    //                           child: Column(
    //                             mainAxisSize: MainAxisSize.min,
    //                             children: [
    //                               // หัวเรื่อง
    //                               Row(
    //                                 mainAxisAlignment: MainAxisAlignment.center,
    //                                 children: [
    //                                   const Icon(Icons.receipt_long_rounded,
    //                                       color: Colors.black87),
    //                                   const SizedBox(width: 8),
    //                                   Translate.TranslateAndSetText(
    //                                     'ยืนยันการวางบิลทั้งหมด',
    //                                     Colors.black87,
    //                                     TextAlign.center,
    //                                     FontWeight.bold,
    //                                     FontWeight_.Fonts_T,
    //                                     16,
    //                                     1,
    //                                   ),
    //                                 ],
    //                               ),
    //                               const SizedBox(height: 20),

    //                               // สลับ "สรุป" <-> "กำลังทำงาน" ด้วย AnimatedSwitcher
    //                               AnimatedSwitcher(
    //                                   duration:
    //                                       const Duration(milliseconds: 220),
    //                                   child:
    //                                       //  !submitting
    //                                       //     ?
    //                                       Column(
    //                                     key: const ValueKey('summary'),
    //                                     mainAxisSize: MainAxisSize.min,
    //                                     children: [
    //                                       Wrap(
    //                                         alignment: WrapAlignment.center,
    //                                         spacing: 8,
    //                                         runSpacing: 8,
    //                                         children: [
    //                                           _pill(Icons.list_alt_rounded,
    //                                               'ทั้งหมด : ${_TransModels.length} รายการ'),
    //                                           //  '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${End_Bill_Paydate}'))}',
    //                                           // _pill(
    //                                           //     Icons
    //                                           //         .calendar_month_rounded,

    //                                           //     DateFormat('dd-MM-yyyy')
    //                                           //         .format(_selected ??
    //                                           //             newDatetime)),
    //                                           _pill(
    //                                             Icons.calendar_month_rounded,
    //                                             _formatDdMMyyyy(
    //                                               selected:
    //                                                   _selected, // ถ้ามี DateTime จาก date picker
    //                                               fallback:
    //                                                   End_Bill_Paydate, // ถ้าไม่มี ให้ลองจาก string ฝั่งเซิร์ฟเวอร์
    //                                             ),
    //                                           ),

    //                                           if (paymentSer1 != null &&
    //                                               '$paymentSer1'.isNotEmpty)
    //                                             _pill(Icons.payments_rounded,
    //                                                 'วิธีชำระ : $paymentName1'),
    //                                         ],
    //                                       ),
    //                                       const SizedBox(height: 20),
    //                                       !submitting
    //                                           ? SizedBox()
    //                                           : SizedBox(
    //                                               child: Column(
    //                                                 key: const ValueKey(
    //                                                     'progress'),
    //                                                 mainAxisSize:
    //                                                     MainAxisSize.min,
    //                                                 children: [
    //                                                   Row(
    //                                                     children: [
    //                                                       Expanded(
    //                                                         child: ClipRRect(
    //                                                           borderRadius:
    //                                                               BorderRadius
    //                                                                   .circular(
    //                                                                       8),
    //                                                           child:
    //                                                               LinearProgressIndicator(
    //                                                             value: _progress <=
    //                                                                     0.0
    //                                                                 ? null
    //                                                                 : _progress,
    //                                                             minHeight: 8,
    //                                                             backgroundColor:
    //                                                                 Colors.grey
    //                                                                     .shade200,
    //                                                           ),
    //                                                         ),
    //                                                       ),
    //                                                       const SizedBox(
    //                                                           width: 12),
    //                                                       Text(
    //                                                         _total == null
    //                                                             ? '${(_progress * 100).toStringAsFixed(0)}%'
    //                                                             : '${(_progress * 100).toStringAsFixed(0)}%  (${_done ?? 0}/${_total})',
    //                                                         style: const TextStyle(
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .w600),
    //                                                       ),
    //                                                     ],
    //                                                   ),
    //                                                   const SizedBox(height: 8),
    //                                                   const Text(
    //                                                       'กำลังวางบิล โปรดอย่าปิดหน้าต่างนี้',
    //                                                       style: TextStyle(
    //                                                           color: Colors
    //                                                               .black54,
    //                                                           fontSize: 12)),
    //                                                 ],
    //                                               ),
    //                                             ),
    //                                     ],
    //                                   )
    //                                   // : Column(
    //                                   //     key: const ValueKey('progress'),
    //                                   //     mainAxisSize: MainAxisSize.min,
    //                                   //     children: [
    //                                   //       Row(
    //                                   //         children: [
    //                                   //           Expanded(
    //                                   //             child: ClipRRect(
    //                                   //               borderRadius:
    //                                   //                   BorderRadius.circular(
    //                                   //                       8),
    //                                   //               child:
    //                                   //                   LinearProgressIndicator(
    //                                   //                 value: _progress <= 0.0
    //                                   //                     ? null
    //                                   //                     : _progress,
    //                                   //                 minHeight: 8,
    //                                   //                 backgroundColor: Colors
    //                                   //                     .grey.shade200,
    //                                   //               ),
    //                                   //             ),
    //                                   //           ),
    //                                   //           const SizedBox(width: 12),
    //                                   //           Text(
    //                                   //             _total == null
    //                                   //                 ? '${(_progress * 100).toStringAsFixed(0)}%'
    //                                   //                 : '${(_progress * 100).toStringAsFixed(0)}%  (${_done ?? 0}/${_total})',
    //                                   //             style: const TextStyle(
    //                                   //                 fontWeight:
    //                                   //                     FontWeight.w600),
    //                                   //           ),
    //                                   //         ],
    //                                   //       ),
    //                                   //       const SizedBox(height: 8),
    //                                   //       const Text(
    //                                   //           'กำลังวางบิล โปรดอย่าปิดหน้าต่างนี้',
    //                                   //           style: TextStyle(
    //                                   //               color: Colors.black54,
    //                                   //               fontSize: 12)),
    //                                   //     ],
    //                                   //   ),
    //                                   ),

    //                               const SizedBox(height: 20),
    //                               const Divider(
    //                                   height: 1, color: Color(0xFFEFEFEF)),
    //                               const SizedBox(height: 20),

    //                               // ปุ่ม
    //                               Row(
    //                                 children: [
    //                                   Expanded(
    //                                     child: TextButton(
    //                                       style: TextButton.styleFrom(
    //                                         foregroundColor: Colors.black87,
    //                                         padding: const EdgeInsets.symmetric(
    //                                             vertical: 12),
    //                                         shape: RoundedRectangleBorder(
    //                                             borderRadius:
    //                                                 BorderRadius.circular(6)),
    //                                       ),
    //                                       onPressed: submitting
    //                                           ? null
    //                                           : () => Navigator.pop(
    //                                               dialogCtx, false),
    //                                       child: Padding(
    //                                         padding: const EdgeInsets.all(2.0),
    //                                         child:
    //                                             Translate.TranslateAndSetText(
    //                                                 'ยกเลิก',
    //                                                 Colors.black87,
    //                                                 TextAlign.center,
    //                                                 FontWeight.w600,
    //                                                 FontWeight_.Fonts_T,
    //                                                 14,
    //                                                 1),
    //                                       ),
    //                                     ),
    //                                   ),
    //                                   const SizedBox(width: 10),
    //                                   Expanded(
    //                                     child: ElevatedButton.icon(
    //                                       style: ElevatedButton.styleFrom(
    //                                         backgroundColor: Colors.black,
    //                                         foregroundColor: Colors.white,
    //                                         disabledBackgroundColor:
    //                                             Colors.black26,
    //                                         padding: const EdgeInsets.symmetric(
    //                                             vertical: 12),
    //                                         shape: RoundedRectangleBorder(
    //                                             borderRadius:
    //                                                 BorderRadius.circular(6)),
    //                                         elevation: 0,
    //                                       ),
    //                                       icon: submitting
    //                                           ? const SizedBox(
    //                                               width: 18,
    //                                               height: 18,
    //                                               child:
    //                                                   CircularProgressIndicator(
    //                                                       strokeWidth: 2))
    //                                           : const Icon(
    //                                               Icons.check_circle_rounded,
    //                                               size: 18),
    //                                       label: Padding(
    //                                         padding: const EdgeInsets.all(2.0),
    //                                         child:
    //                                             Translate.TranslateAndSetText(
    //                                                 submitting
    //                                                     ? 'กำลังบันทึก...'
    //                                                     : 'ยืนยัน',
    //                                                 Colors.white,
    //                                                 TextAlign.center,
    //                                                 FontWeight.w700,
    //                                                 FontWeight_.Fonts_T,
    //                                                 14,
    //                                                 1),
    //                                       ),
    //                                       onPressed: submitting
    //                                           ? null
    //                                           : () async {
    //                                               if (_TransModels.isEmpty) {
    //                                                 ScaffoldMessenger.of(
    //                                                         parentCtx)
    //                                                     .showSnackBar(
    //                                                   SnackBar(
    //                                                       content: Translate
    //                                                           .TranslateAndSetText(
    //                                                               'กรุณาเลือก เดือน ปี ที่ต้องการวางบิล',
    //                                                               Colors.white,
    //                                                               TextAlign
    //                                                                   .start,
    //                                                               FontWeight
    //                                                                   .bold,
    //                                                               FontWeight_
    //                                                                   .Fonts_T,
    //                                                               14,
    //                                                               1)),
    //                                                 );
    //                                                 return;
    //                                               }

    //                                               setD(() {
    //                                                 submitting = true;
    //                                                 _progress = 0.0;
    //                                                 _done = _total = null;
    //                                               });

    //                                               // ✅ ผูก Progress จริงจากเซิร์ฟเวอร์
    //                                               final ok =
    //                                                   await inTransInvoiceAll(
    //                                                 parentCtx,
    //                                                 onProgress: (p,
    //                                                     {int? done,
    //                                                     int? total,
    //                                                     String? status}) {
    //                                                   setD(() {
    //                                                     _progress = (p.isNaN
    //                                                             ? 0.0
    //                                                             : p)
    //                                                         .clamp(0.0, 1.0);
    //                                                     _done = done;
    //                                                     _total = total;
    //                                                   });
    //                                                 },
    //                                               );

    //                                               if (!mounted) return;
    //                                               Navigator.pop(dialogCtx, ok);
    //                                             },
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                 );
    //               },
    //               // onPressed: () async {
    //               //   // print('docno$paymentSer1>>>>  $End_Bill_Paydate');
    //               //   showDialog<String>(
    //               //     barrierDismissible: false,
    //               //     context: context,
    //               //     builder: (BuildContext context) => AlertDialog(
    //               //       shape: const RoundedRectangleBorder(
    //               //           borderRadius:
    //               //               BorderRadius.all(Radius.circular(20.0))),
    //               //       title: Center(
    //               //         child: Translate.TranslateAndSetText(
    //               //             'ยืนยันการวางบิลทั้งหมด',
    //               //             PeopleChaoScreen_Color.Colors_Text1_,
    //               //             TextAlign.center,
    //               //             FontWeight.bold,
    //               //             FontWeight_.Fonts_T,
    //               //             14,
    //               //             1),
    //               //         // Text(
    //               //         //   'ยืนยันการวางบิลทั้งหมด',
    //               //         //   style: TextStyle(
    //               //         //     color: PeopleChaoScreen_Color.Colors_Text1_,
    //               //         //     // fontWeight: FontWeight.bold,
    //               //         //     fontFamily: FontWeight_.Fonts_T,
    //               //         //     fontWeight: FontWeight.bold,
    //               //         //   ),
    //               //         // )
    //               //       ),
    //               //       content: SingleChildScrollView(
    //               //         child: Container(
    //               //           child: Column(
    //               //             children: [
    //               //               Row(
    //               //                 mainAxisAlignment: MainAxisAlignment.center,
    //               //                 children: [
    //               //                   Expanded(
    //               //                     child: Translate.TranslateAndSetText(
    //               //                         'ทั้งหมด ${_TransModels.length} รายการ',
    //               //                         PeopleChaoScreen_Color.Colors_Text2_,
    //               //                         TextAlign.center,
    //               //                         FontWeight.bold,
    //               //                         FontWeight_.Fonts_T,
    //               //                         14,
    //               //                         1),
    //               //                     // Text(
    //               //                     //   'ทั้งหมด ${_TransModels.length} รายการ',
    //               //                     //   textAlign: TextAlign.center,
    //               //                     //   style: const TextStyle(
    //               //                     //       color: PeopleChaoScreen_Color
    //               //                     //           .Colors_Text2_,
    //               //                     //       //fontWeight: FontWeight.bold,
    //               //                     //       fontFamily: Font_.Fonts_T),
    //               //                     // ),
    //               //                   ),
    //               //                 ],
    //               //               ),
    //               //               SizedBox(
    //               //                 height: 10,
    //               //               ),
    //               //               const SizedBox(height: 1),
    //               //               const Divider(),
    //               //               const SizedBox(height: 1),
    //               //               Row(
    //               //                 children: [
    //               //                   Expanded(
    //               //                     child: Padding(
    //               //                       padding: const EdgeInsets.all(8.0),
    //               //                       child:

    //               //                       InkWell(
    //               //                         onTap: () {
    //               //                           // print(
    //               //                           //     'docno$paymentSer1>>>>  $End_Bill_Paydate');
    //               //                           if (_TransModels.length != 0) {
    //               //                             Dia_log();
    //               //                             in_Trans_invoice_all();
    //               //                           } else {
    //               //                             Navigator.pop(context);
    //               //                             ScaffoldMessenger.of(context)
    //               //                                 .showSnackBar(
    //               //                               SnackBar(
    //               //                                 content: Translate
    //               //                                     .TranslateAndSetText(
    //               //                                         'กรุณาเลือก เดือน ปี ที่ต้องการวางบิล',
    //               //                                         Colors.white,
    //               //                                         TextAlign.start,
    //               //                                         FontWeight.bold,
    //               //                                         FontWeight_.Fonts_T,
    //               //                                         14,
    //               //                                         1),
    //               //                                 // Text(
    //               //                                 //     'กรุณาเลือก เดือน ปี ที่ต้องการวางบิล',
    //               //                                 //     style: TextStyle(
    //               //                                 //         color: Colors.white,
    //               //                                 //         fontFamily: Font_
    //               //                                 //             .Fonts_T))
    //               //                               ),
    //               //                             );
    //               //                           }
    //               //                         },
    //               //                         child: Container(
    //               //                             // height: 50,
    //               //                             decoration: BoxDecoration(
    //               //                               color: Colors.green.shade500,
    //               //                               borderRadius:
    //               //                                   const BorderRadius.only(
    //               //                                       topLeft:
    //               //                                           Radius.circular(10),
    //               //                                       topRight:
    //               //                                           Radius.circular(10),
    //               //                                       bottomLeft:
    //               //                                           Radius.circular(10),
    //               //                                       bottomRight:
    //               //                                           Radius.circular(
    //               //                                               10)),
    //               //                               // border: Border.all(
    //               //                               //     color: Colors.grey,
    //               //                               //     width: 1),
    //               //                             ),
    //               //                             padding:
    //               //                                 const EdgeInsets.all(8.0),
    //               //                             child: Center(
    //               //                               child: Translate
    //               //                                   .TranslateAndSetText(
    //               //                                       'ตกลง',
    //               //                                       Colors.white,
    //               //                                       TextAlign.start,
    //               //                                       FontWeight.bold,
    //               //                                       FontWeight_.Fonts_T,
    //               //                                       14,
    //               //                                       1),

    //               //                               //  Text(
    //               //                               //   'ตกลง',
    //               //                               //   style: TextStyle(
    //               //                               //       color: Colors.white,
    //               //                               //       // fontSize: 10.0,
    //               //                               //       fontFamily:
    //               //                               //           FontWeight_.Fonts_T),
    //               //                               // ),
    //               //                             )),
    //               //                       ),
    //               //                     ),
    //               //                   ),
    //               //                   Expanded(
    //               //                     child: Padding(
    //               //                       padding: const EdgeInsets.all(8.0),
    //               //                       child: InkWell(
    //               //                         onTap: () {
    //               //                           Navigator.pop(context);
    //               //                         },
    //               //                         child: Container(
    //               //                             // height: 50,
    //               //                             decoration: BoxDecoration(
    //               //                               color: Colors.red,
    //               //                               borderRadius:
    //               //                                   const BorderRadius.only(
    //               //                                       topLeft:
    //               //                                           Radius.circular(10),
    //               //                                       topRight:
    //               //                                           Radius.circular(10),
    //               //                                       bottomLeft:
    //               //                                           Radius.circular(10),
    //               //                                       bottomRight:
    //               //                                           Radius.circular(
    //               //                                               10)),
    //               //                               // border: Border.all(
    //               //                               //     color: Colors.grey,
    //               //                               //     width: 1),
    //               //                             ),
    //               //                             padding:
    //               //                                 const EdgeInsets.all(8.0),
    //               //                             child: Center(
    //               //                               child: Translate
    //               //                                   .TranslateAndSetText(
    //               //                                       'ยกเลิก',
    //               //                                       Colors.white,
    //               //                                       TextAlign.start,
    //               //                                       FontWeight.bold,
    //               //                                       FontWeight_.Fonts_T,
    //               //                                       14,
    //               //                                       1),

    //               //                               // Text(
    //               //                               //   'ยกเลิก',
    //               //                               //   style: TextStyle(
    //               //                               //       color: Colors.white,
    //               //                               //       // fontSize: 10.0,
    //               //                               //       fontFamily:
    //               //                               //           FontWeight_.Fonts_T),
    //               //                               // ),
    //               //                             )),
    //               //                       ),
    //               //                     ),
    //               //                   ),
    //               //                 ],
    //               //               ),
    //               //             ],
    //               //           ),
    //               //         ),
    //               //       ),
    //               //     ),
    //               //   );
    //               // },
    //               child: Translate.TranslateAndSetText(
    //                   "+ วางบิลทั้งหมด",
    //                   Colors.white,
    //                   TextAlign.start,
    //                   FontWeight.bold,
    //                   FontWeight_.Fonts_T,
    //                   14,
    //                   1),
    //               //  const Text(
    //               //   "+ วางบิลทั้งหมด",
    //               //   style: TextStyle(
    //               //     color: Colors.white,
    //               //     fontFamily: FontWeight_.Fonts_T,
    //               //     fontWeight: FontWeight.bold,
    //               //   ),
    //               // ),
    //             ),
    //           ),
    //         ),
    //         // Container(
    //         //   width: 200,
    //         //   color: Colors.green,
    //         //   child: Padding(
    //         //     padding: const EdgeInsets.all(8.0),
    //         //     child: TextButton(
    //         //       onPressed: () async {
    //         //         if (_TransModels.length != 0) {
    //         //           in_Trans_invoice_all();
    //         //         } else {
    //         //           ScaffoldMessenger.of(context).showSnackBar(
    //         //             const SnackBar(
    //         //                 content: Text(
    //         //                     'กรุณาเลือก เดือน ปี ที่ต้องการวางบิล',
    //         //                     style: TextStyle(
    //         //                         color: Colors.white,
    //         //                         fontFamily: Font_.Fonts_T))),
    //         //           );
    //         //         }
    //         //       },
    //         //       child: const Text(
    //         //         "วางบิลทั้งหมด",
    //         //         style: TextStyle(
    //         //           color: Colors.black,
    //         //           fontFamily: Font_.Fonts_T,
    //         //           fontWeight: FontWeight.bold,
    //         //         ),
    //         //       ),
    //         //     ),
    //         //   ),
    //         // ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            child: SizedBox(
              height: 20,
              width: 80,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset(
                  "images/gif-LOGOchao.gif",
                  fit: BoxFit.cover,
                  height: 20,
                  width: 80,
                ),
              ),
            ),
          );
        });
  }

  // Future<Null> in_Trans_invoice_all() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var zone = preferences.getString('zoneSer');
  //   var zone_ser = preferences.getString('zoneSubSer');
  //   var serMONTH = _selected == null
  //       ? DateFormat('MM').format(newDatetime)
  //       : DateFormat('MM').format(_selected!);
  //   var serYEAR = _selected == null
  //       ? DateFormat('yyyy').format(newDatetime)
  //       : DateFormat('yyyy').format(_selected!);

  //   var c_payment_Ser = paymentSer1;
  //   var End_Bill_Paydate_ = End_Bill_Paydate;

  //   // print('docno$paymentSer1>>>>  $End_Bill_Paydate');

  //   String url =
  //       '${MyConstant().domain}/In_tran_invoice_all_account.php?isAdd=true&ren=$ren&user=$user&serMONTH=$serMONTH&serYEAR=$serYEAR&pay_Ser1=$paymentSer1&pay_date=$End_Bill_Paydate&zone=$zone&zone_ser=$zone_ser';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print(result);
  //     if (result.toString() == 'true') {
  //       // for (var map in result) {
  //       //   // TransBillModel transBillModel = TransBillModel.fromJson(map);
  //       //   // setState(() {
  //       //   //   cFinn = transBillModel.docno;
  //       //   // });
  //       //   // print('zzzzasaaa123454>>>>  $cFinn');
  //       //   // print('docnodocnodocnodocnodocno123456>>>>  ${transBillModel.docno}');
  //       // }

  //       Insert_log.Insert_logs(
  //           'บัญชี', 'วางบิลทั้งหมด>>บันทึก(${user.toString()})');
  //       setState(() {
  //         read_Trans_invoice_all();
  //       });
  //       Navigator.pop(context);
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Translate.TranslateAndSetText(
  //                 'บันทึกรายการวางบิลสำเร็จ',
  //                 Colors.white,
  //                 TextAlign.left,
  //                 FontWeight.bold,
  //                 FontWeight_.Fonts_T,
  //                 14,
  //                 1)),
  //       );
  //       // print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}
  //   // Future.delayed(const Duration(milliseconds: 200), () async {
  //   //   setState(() {
  //   //     red_Trans_bill();
  //   //   });
  //   // });
  // }

  // ใน State
  bool _submitting = false;

  Future<bool> inTransInvoiceAll(
    BuildContext context, {
    void Function(double progress, {int? done, int? total, String? status})?
        onProgress,
    Duration pollInterval = const Duration(milliseconds: 800),
    Duration overallTimeout = const Duration(minutes: 3),
  }) async {
    /////////////----------------------->
    // final List<int> ser_expModels = expModels
    //     .where((e) => e.st == '1')
    //     .map((e) => int.tryParse(e.ser ?? ''))
    //     .whereType<int>() // ตัด null ออก
    //     .toList();

    final selectedIds = expModels
        .where((e) => e.st == '1')
        .map((e) => int.tryParse(e.ser ?? ''))
        .whereType<int>()
        .toList();

    final totalSelectable =
        expModels.map((e) => int.tryParse(e.ser ?? '')).whereType<int>().length;

// เลือกครบ = เท่ากับจำนวนที่ selectable จริง ๆ และต้อง > 0
    final allSelected =
        totalSelectable > 0 && selectedIds.length == totalSelectable;

// ถ้าไม่เลือกอะไรเลย → ส่ง '0' เพื่อให้ PHP ได้ $ids ว่าง แล้วตีเป็น AND 1=0
    final serInParam = allSelected
        ? 'All'
        : (selectedIds.isEmpty ? '0' : selectedIds.join(','));
    print(serInParam);
    /////////////----------------------->
    if (_submitting) return false;
    setState(() => _submitting = true);

    final startedAt = DateTime.now();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      final user = prefs.getString('ser');
      final zone = prefs.getString('zoneSer');
      final zoneSer = prefs.getString('zoneSubSer');

      final baseDate = _selected ?? newDatetime;
      final serMONTH = DateFormat('MM').format(baseDate);
      final serYEAR = DateFormat('yyyy').format(baseDate);

      if (ren == null || user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Translate.TranslateAndSetText(
                  'ข้อมูลผู้ใช้ไม่ครบ (ren/user)',
                  Colors.white,
                  TextAlign.left,
                  FontWeight.bold,
                  FontWeight_.Fonts_T,
                  14,
                  1)),
        );
        return false;
      }

      final baseUri =
          Uri.parse('${MyConstant().domain}/In_tran_invoice_all_account.php')
              .replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'user': user,
        'serMONTH': serMONTH,
        'serYEAR': serYEAR,
        'pay_Ser1': '$paymentSer1',
        'pay_date': '$End_Bill_Paydate',
        'zone': zone ?? '',
        'zone_ser': zoneSer ?? '',
        'serIn': serInParam, // 👈 ส่ง 'All' / '1,2,3' / '0'
      });
      // final baseUri =
      //     Uri.parse('${MyConstant().domain}/In_tran_invoice_all_account.php')
      //         .replace(queryParameters: {
      //   'isAdd': 'true',
      //   'ren': ren,
      //   'user': user,
      //   'serMONTH': serMONTH,
      //   'serYEAR': serYEAR,
      //   'pay_Ser1': '$paymentSer1',
      //   'pay_date': '$End_Bill_Paydate',
      //   'zone': zone ?? '',
      //   'zone_ser': zoneSer ?? '',
      //   'serIn': expModels
      //               .where((e) => e.st == '1')
      //               .map((e) => int.tryParse(e.ser ?? ''))
      //               .whereType<int>() // ตัด null ออก
      //               .toList()
      //               .length ==
      //           expModels.length
      //       ? 'All'
      //       : ser_expModels.join(','), // 👈 "1,2,3"
      // });

      // เริ่ม progress
      onProgress?.call(0.0, done: 0, total: null, status: 'start');

      while (true) {
        // กันวนเกินเวลา
        if (DateTime.now().difference(startedAt) > overallTimeout) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Translate.TranslateAndSetText(
                    'หมดเวลาเชื่อมต่อ (Timeout)',
                    Colors.white,
                    TextAlign.left,
                    FontWeight.bold,
                    FontWeight_.Fonts_T,
                    14,
                    1)),
          );
          return false;
        }

        final resp =
            await http.get(baseUri).timeout(const Duration(seconds: 20));
        if (resp.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Translate.TranslateAndSetText(
                    'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ (${resp.statusCode})',
                    Colors.white,
                    TextAlign.left,
                    FontWeight.bold,
                    FontWeight_.Fonts_T,
                    14,
                    1)),
          );
          return false;
        }

        final body = resp.body.trim();

        // 1) พยายามอ่านเป็น JSON {status, done, total}
        try {
          final parsed = json.decode(body);
          if (parsed is Map && parsed['status'] is String) {
            final status = (parsed['status'] as String).toLowerCase();

            if (status == 'processing') {
              final done = (parsed['done'] ?? 0) as int;
              final total = (parsed['total'] ?? 0) as int;
              final p = (total > 0) ? (done / total).clamp(0.0, 1.0) : 0.0;
              onProgress?.call(p, done: done, total: total, status: status);
              await Future.delayed(pollInterval);
              continue; // ยิงต่อ
            }

            if (status == 'complete') {
              onProgress?.call(1.0, status: status);
              // สำเร็จ
              Insert_log.Insert_logs(
                  'บัญชี', 'วางบิลทั้งหมด>>บันทึก(${user.toString()})');
              try {
                await read_Trans_invoice_all();
              } catch (_) {}
              if (mounted) {
                Navigator.of(context).maybePop();
                Navigator.of(context).maybePop();
                final nav = Navigator.of(context, rootNavigator: true);
                PanaraInfoDialog.showAnimatedGrow(
                  context,
                  title: "เสร็จสิ้น",
                  message: "บันทึกรายการวางบิลสำเร็จ",
                  buttonText: "รับทราบ",
                  onTapDismiss: () async {
                    // ไม่อิง context ตอนที่มันอาจ deactivated แล้ว
                    if (nav.canPop()) nav.pop();
                    // Navigator.pop(context);
                  },
                  panaraDialogType: PanaraDialogType.success,
                  barrierDismissible: false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.green,
                      content: Translate.TranslateAndSetText(
                          'บันทึกรายการวางบิลสำเร็จ',
                          Colors.white,
                          TextAlign.left,
                          FontWeight.bold,
                          FontWeight_.Fonts_T,
                          14,
                          1)),
                );
              }
              return true;
            }
          }
        } catch (_) {
          // ไม่เป็น JSON map — ไปเช็ครูปแบบเก่า
        }

        // 2) รองรับรูปแบบเก่า: 'true' เป็นสตริง
        if (body == 'true') {
          onProgress?.call(1.0, status: 'complete');
          Insert_log.Insert_logs(
              'บัญชี', 'วางบิลทั้งหมด>>บันทึก(${user.toString()})');
          try {
            await read_Trans_invoice_all();
          } catch (_) {}
          if (mounted) {
            Navigator.of(context).maybePop();
            Navigator.of(context).maybePop();
            // final nav = Navigator.of(context, rootNavigator: true);
            // PanaraInfoDialog.showAnimatedGrow(
            //   context,
            //   title: "เสร็จสิ้น",
            //   message: "บันทึกรายการวางบิลสำเร็จ",
            //   buttonText: "รับทราบ",
            //   onTapDismiss: () async {
            //     // ไม่อิง context ตอนที่มันอาจ deactivated แล้ว
            //     if (nav.canPop()) nav.pop();
            //     // Navigator.pop(context);
            //   },
            //   panaraDialogType: PanaraDialogType.success,
            //   barrierDismissible: false,
            // );
            // Dialog_success(context, 'บันทึกรายการวางบิลสำเร็จ');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.green,
                  content: Translate.TranslateAndSetText(
                      'บันทึกรายการวางบิลสำเร็จ',
                      Colors.white,
                      TextAlign.left,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1)),
            );
          }
          return true;
        }

        // 3) รูปแบบไม่รู้จัก -> ลองดึง error/message
        try {
          final j = json.decode(body);
          if (j is Map && (j['error'] != null || j['message'] != null)) {
            final msg = j['error']?.toString() ??
                j['message']?.toString() ??
                'บันทึกล้มเหลว';
            // Dialog_error(context, msg);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.red,
                  content: Translate.TranslateAndSetText(
                      msg,
                      Colors.white,
                      TextAlign.left,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1)),
            );
            return false;
          }
        } catch (_) {}

        // ถ้าไม่ใช่ processing / complete / true ให้หน่วงแล้ววนใหม่เล็กน้อย
        await Future.delayed(pollInterval);
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Translate.TranslateAndSetText(
                'หมดเวลาเชื่อมต่อ (Timeout)',
                Colors.white,
                TextAlign.left,
                FontWeight.bold,
                FontWeight_.Fonts_T,
                14,
                1)),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Translate.TranslateAndSetText(
                'เกิดข้อผิดพลาด: $e',
                Colors.white,
                TextAlign.left,
                FontWeight.bold,
                FontWeight_.Fonts_T,
                14,
                1)),
      );
      return false;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
