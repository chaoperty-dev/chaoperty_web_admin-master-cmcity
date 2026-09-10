// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, duplicate_import, must_be_immutable, body_might_complete_normally_nullable
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty_floating_loader/chaoperty_floating_loader.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_BillingNoteInvlice_PDF.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetRegis_model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../PDF/PDF_Billing/pdf_BillingNote_IV.dart';
import '../PDF_TP2/PDF_Billing_TP2/pdf_BillingNote_IV_TP2.dart';
import '../PDF_TP3/PDF_Billing_TP3/pdf_BillingNote_IV_TP3.dart';
import '../PDF_TP4/PDF_Billing_TP4/pdf_BillingNote_IV_TP4.dart';
import '../PDF_TP5/PDF_Billing_TP5/pdf_BillingNote_IV_TP5.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class BillsHistory extends StatefulWidget {
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  final namenew;

  const BillsHistory({
    super.key,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
    this.namenew,
  });

  @override
  State<BillsHistory> createState() => _BillsHistoryState();
}

class _BillsHistoryState extends State<BillsHistory> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("#,##0.000", "en_US");
  @override
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<TeNantModel> teNantModels = [];
  List<RenTalModel> renTalModels = [];
  List<Regis_model> regis_models = [];

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      sum_dislist = 0;

  String? numinvoice;
  String? Form_nameshop;
  String? Form_typeshop;
  String? Form_bussshop;
  String? Form_bussscontact;
  String? Form_address;
  String? Form_tel;
  String? Form_email;
  String? Form_tax;
  String? rental_count_text;
  String? Form_area;
  String? Form_ln;
  String? Form_sdate;
  String? Form_ldate;
  String? Form_period;
  String? Form_rtname;
  String? Form_docno;
  String? Form_zn;
  String? Form_aser;
  String? Form_qty;
  String? ADDR;
  String? base64_Imgmap, foder, tem_page_ser;
  String? Datex_invoice;
  String? payment_Ptser1,
      payment_Ptname1,
      payment_Bno1,
      payment_refapi,
      payment_ref1,
      payment_ref2,
      payment_cid,
      ser_notiline;
  String? payment_Ptser2, payment_Ptname2, payment_Bno2, renTal_Ser, custno_Ser;
  int TitleType_Default_Receipt = 0;
  int select_meter = 0;
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'สำเนา',
  ];
  @override
  void initState() {
    super.initState();
    red_Invoice();
    read_data();
    read_GC_rental();
  }

  Future<Null> read_GC_Line(index) async {
    if (regis_models.isNotEmpty) {
      setState(() {
        regis_models.clear();
      });
    }
    var custno = _InvoiceModels[index].custno;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_line_regis.php?isAdd=true&ren=$ren&custno=$custno';
    // renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          Regis_model regis_model = Regis_model.fromJson(map);
          setState(() {
            if (regis_model.userid != '') {
              regis_models.add(regis_model);
            }
          });
        }
      } else {}
    } catch (e) {
      //print('Error-Dis(read_GC_rental) : ${e}');
    }
    // //print('name>>>>>  $renname');
  }

  Future<Null> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // var seruser = preferences.getString('ser');
    // var utype = preferences.getString('utype');
    // String url =
    //     '${MyConstant().domain}/GC_rental.php?isAdd=true&ser=$seruser&type=$utype';

    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    setState(() {
      renTal_Ser = ren.toString();
    });
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print('read_GC_rental///// $result');
      for (var map in result) {
        RenTalModel renTalModel = RenTalModel.fromJson(map);
        var rtnamex = renTalModel.rtname;
        var typexs = renTalModel.type;
        var typexx = renTalModel.typex;
        var name = renTalModel.pn!.trim();
        var pkqtyx = int.parse(renTalModel.pkqty!);
        var pkuserx = int.parse(renTalModel.pkuser!);
        var pkx = renTalModel.pk!.trim();
        var foderx = renTalModel.dbn;
        var img = renTalModel.img;
        var imglogo = renTalModel.imglogo;
        setState(() {
          foder = foderx;
          tem_page_ser = renTalModel.tem_page!.trim();
          renTalModels.add(renTalModel);
        });
      }
    } catch (e) {}
  }

  ///------------------------------------------------------>
  Future<Null> read_data() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);

            Form_nameshop = teNantModel.sname.toString();
            Form_typeshop = teNantModel.stype.toString();
            Form_bussshop = teNantModel.cname.toString();
            Form_bussscontact = teNantModel.attn.toString();
            Form_address = teNantModel.addr.toString();
            Form_tel = teNantModel.tel.toString();
            Form_email = teNantModel.email.toString();
            Form_tax =
                teNantModel.tax == null ? "-" : teNantModel.tax.toString();
            Form_area = teNantModel.area.toString();
            Form_ln = teNantModel.area_c.toString();

            Form_sdate = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
                .toString();
            Form_ldate = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
                .toString();
            Form_period = teNantModel.period.toString();
            Form_rtname = teNantModel.rtname.toString();
            Form_docno = teNantModel.docno.toString();
            Form_zn = teNantModel.zn.toString();
            Form_aser = teNantModel.aser.toString();
            Form_qty = teNantModel.qty.toString();
          });
        }
      }
    } catch (e) {}
  }

  double getTotalByField(
    List<InvoiceHistoryModel> invoices,
    String? Function(InvoiceHistoryModel item) getter,
  ) {
    return invoices.fold(0.0, (sum, item) {
      final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
      return sum + value;
    });
  }

  Future<Null> red_Trans_select(index) async {
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_disamt = 0;
        sum_disp = 0;
        sum_dislist = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var docnoin = _InvoiceModels[index].docno;
    // String url =
    //     '${MyConstant().domain}/GC_bill_invoice_History.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    String url =
        '${MyConstant().domain}/GC_bill_invoiceHistory_v2.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // //print(url);
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      //print(result);

      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);

          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;

            numinvoice = _InvoiceHistoryModel.docno;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Invoice() async {
    if (_InvoiceModels.length != 0) {
      setState(() {
        _InvoiceModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
          setState(() {
            _InvoiceModels.add(_InvoiceModel);
          });
        }
      }
    } catch (e) {}
  }

  ///----------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  final Set<int> _pressedIndices = Set();

  ///--------------------------------------------------------->
  Widget Bills_(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: (Responsive.isDesktop(context))
              ? MediaQuery.of(context).size.width / 3.5
              : MediaQuery.of(context).size.width / 2.2,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  blurRadius: 18,
                  color: Colors.black.withOpacity(.06),
                  offset: const Offset(0, 2))
            ],
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          child: Column(
            children: [
              // ======== Segmented Tabs (ค่าบริการ | ค่าน้ำ-ค่าไฟ) ========
              Container(
                height: 52,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // color: Color(0xFFF7F7F7),
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.orange[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    _segmentTab(
                      context: context,
                      active: select_meter == 0,
                      activeColor: Colors.amber.shade600,
                      icon: Icons.history,
                      label: 'ประวัติรายการวางบิล',
                      onTap: () async {},
                    ),
                    // const SizedBox(width: 6),
                    // _segmentTab(
                    //   context: context,
                    //   active: select_meter == 1,
                    //   activeColor: Colors.lightBlue.shade500,
                    //   icon: Icons.ev_station_rounded,
                    //   label: 'ค่าน้ำ - ค่าไฟ',
                    //   onTap: () async {
                    //     if (select_meter == 1) return;
                    //     setState(() => select_meter = 1);
                    //     await red_Trans_bill_meter(typex: '');
                    //   },
                    // ),
                  ],
                ),
              ),

              // ======== Header Row ========
              _headerRow(
                context: context,
                onChevronTap: () {},
              ),

              // ======== List ========
              Container(
                height: 486,
                decoration: const BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(14)),
                ),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _InvoiceModels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final row = _InvoiceModels[index];
                    final selected =
                        _InvoiceHistoryModels.any((a) => a.docno == row.docno);

                    final expName = row.dtype == 'KU'
                        ? (row.meter == '')
                            ? '${row.descr} ${DateFormat.MMM('th_TH').format(DateTime.parse('${row.date} 00:00:00'))}'
                            : '${row.descr} ${DateFormat.MMM('th_TH').format(DateTime.parse('${row.date} 00:00:00'))} (${row.meter})'
                        : '${row.descr}';

                    final dueText = row.dtype == 'KU'
                        ? '${DateFormat('dd-MM').format(DateTime.parse('${row.date} 00:00:00'))}-${DateTime.parse('${row.date} 00:00:00').year + 0}'
                        : '${DateFormat('dd-MM').format(DateTime.parse('${row.date} 00:00:00'))}-${DateTime.parse('${row.date} 00:00:00').year + 0}';

                    return _billRowTile(
                      context: context,
                      selected: selected,
                      expName: expName,
                      tooltipMain: '${row.descr}',
                      dueText: dueText,
                      docno: row.docno ?? '',
                      onTap: () async {
                        // //print(
                        //     '${_InvoiceModels[index].ser} ${_InvoiceModels[index].docno}');

                        setState(() {
                          custno_Ser = _InvoiceModels[index].custno.toString();
                          payment_Ptser1 = _InvoiceModels[index].ptser;
                          payment_Ptname1 = _InvoiceModels[index].ptname;
                          payment_Bno1 = _InvoiceModels[index].bno;

                          Datex_invoice = _InvoiceModels[index].date;
                          payment_refapi = _InvoiceModels[index].refapi;
                          payment_ref1 = _InvoiceModels[index].ref1;
                          payment_ref2 = _InvoiceModels[index].ref2;
                          payment_cid = _InvoiceModels[index].cid;
                          ser_notiline = _InvoiceModels[index].ser_noti;
                        });

                        final ok = await red_Trans_select(index);
                        if (!ok) return;
                        await read_GC_Line(index);
                        if (mounted) setState(() {});
                        // final ok = await in_Trans_select(index);
                        // if (!ok) return;
                        // await in_Trans_fine(index);
                        // await red_Trans_select();
                        // if (mounted) setState(() {});
                      },
                    );
                  },
                ),
              ),

              // ======== Footer Actions ========
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              //   decoration: const BoxDecoration(
              //     color: AppbackgroundColor.Sub_Abg_Colors,
              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(14),
              //       bottomRight: Radius.circular(14),
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       _primaryBtn(
              //         label: '+ เพิ่มใหม่',
              //         color: Colors.green,
              //         onTap: addPlaySelect,
              //       ),
              //       const Spacer(),
              //       _ghostBtn(
              //         label: select_meter == 1
              //             ? 'ค่าน้ำ-ไฟทั้งหมด'
              //             : 'ค่าบริการทั้งหมด',
              //         onTap: () async {
              //           if (select_meter == 1) {
              //             await red_Trans_bill_meter(typex: 'All');
              //           } else {
              //             await red_Trans_billAll();
              //           }

              //           if (mounted) setState(() {});
              //         },
              //       ),
              //       const SizedBox(width: 8),
              //       _accentBtn(
              //         label: 'ประวัติวางบิล',
              //         color: Colors.amber.shade700,
              //         onTap: () => setState(() => indexbill = 1),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
// -------------------- Widget helpers (no classes) --------------------

  Widget _segmentTab({
    required BuildContext context,
    required bool active,
    required Color activeColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activeColor.withOpacity(.95),
                      activeColor.withOpacity(.80),
                    ],
                  )
                : null,
            color: active ? null : Colors.white,
            boxShadow: active
                ? [
                    BoxShadow(
                        color: activeColor.withOpacity(.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
            border: Border.all(
                color: active ? Colors.transparent : const Color(0xFFE6E6E6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: active ? Colors.white : Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : PeopleChaoScreen_Color.Colors_Text1_,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerRow({
    required BuildContext context,
    VoidCallback? onChevronTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade200, Colors.brown.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: const BorderSide(color: Colors.black12, width: .8),
          // right: rightBorder
          //     ? const BorderSide(color: Colors.white30, width: .8)
          //     : BorderSide.none,
        ),
      ),
      // color: const Color(0xFFF1E8E1),
      child: Row(
        children: [
          _headerCell(label: 'ประเภท', flex: 2),
          _headerCell(label: 'กำหนดชำระ', flex: 1, center: true),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.086,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const AutoSizeText(
                    'เลขตั้งหนี้',
                    minFontSize: 10,
                    maxFontSize: 25,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onChevronTap,
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.027,
                    child: const Center(child: Icon(Icons.chevron_right)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell({
    required String label,
    int flex = 1,
    bool center = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: center ? Alignment.center : Alignment.centerLeft,
        // color: const Color(0xFFF1E8E1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade200, Colors.brown.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            bottom: const BorderSide(color: Colors.black12, width: .8),
            // right: rightBorder
            //     ? const BorderSide(color: Colors.white30, width: .8)
            //     : BorderSide.none,
          ),
        ),
        child: AutoSizeText(
          label,
          minFontSize: 10,
          maxFontSize: 25,
          maxLines: 1,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontWeight: FontWeight.bold,
            fontFamily: Font_.Fonts_T,
          ),
        ),
      ),
    );
  }

  Widget _billRowTile({
    required BuildContext context,
    required bool selected,
    required String expName,
    required String tooltipMain,
    required String dueText,
    required String docno,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppbackgroundColor.Sub_Abg_Colors,
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? tappedIndex_Color.tappedIndex_Colors.withOpacity(0.5)
              //  Colors.orange.shade100
              : null,
          border: const Border(
            bottom: BorderSide(color: Colors.grey, width: 0.3),
          ),
        ),
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          onTap: onTap,
          title: Row(
            children: [
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: tooltipMain,
                  child: AutoSizeText(
                    expName,
                    minFontSize: 14,
                    maxFontSize: 20,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  dueText,
                  minFontSize: 14,
                  maxFontSize: 20,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: docno,
                  child: AutoSizeText(
                    docno,
                    minFontSize: 14,
                    maxFontSize: 20,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- ตัวช่วยเล็กๆ (ไม่ใช่ class) ----------
  Widget _hdrCell(
    String text, {
    int flex = 1,
    double? width,
    TextAlign align = TextAlign.center,
    bool rightBorder = true,
    VoidCallback? onTap, // เผื่อคลิก sort ได้ในอนาคต
  }) {
    final label = AutoSizeText(
      text,
      minFontSize: 11,
      maxFontSize: 16,
      maxLines: 1,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: PeopleChaoScreen_Color.Colors_Text1_,
        fontWeight: FontWeight.w700,
        fontFamily: FontWeight_.Fonts_T,
        letterSpacing: .2,
      ),
    );

    final box = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade200, Colors.brown.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: const BorderSide(color: Colors.black12, width: .8),
          right: rightBorder
              ? const BorderSide(color: Colors.white30, width: .8)
              : BorderSide.none,
        ),
      ),
      child: Center(child: label),
    );

    final child = onTap == null
        ? box
        : InkWell(
            onTap: onTap,
            hoverColor: Colors.black12,
            child: box,
          );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

// ---------- หัวตารางแบบสวยขึ้น ----------
  Widget billHeaderTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0)),
        // borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Colors.black12),
        ],
      ),
      clipBehavior: Clip.antiAlias, // ให้มุมมนทำงานกับ ripple
      child: Column(
        children: [
          // แถบหัว "รายละเอียดบิล" — โค้งมน + เงาเบาๆ
          Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[100]!, Colors.orange[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: const [
                // SizedBox(width: 12),
                // Icon(Icons.receipt_long,
                //     size: 20, color: PeopleChaoScreen_Color.Colors_Text1_),
                // SizedBox(width: 8),
                Expanded(
                  child: AutoSizeText(
                    'รายละเอียดบิล',
                    minFontSize: 12,
                    maxFontSize: 18,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PeopleChaoScreen_Color.Colors_Text1_,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),

          // หัวคอลัมน์ (ใช้ gradient อ่อน + เส้นแบ่ง)
          Row(
            children: [
              _hdrCell('ลำดับ', width: 56),
              _hdrCell('กำหนดชำระ', flex: 1, align: TextAlign.left),
              _hdrCell('รายการ', flex: 2),
              _hdrCell('จำนวน', flex: 1, align: TextAlign.right),
              _hdrCell('หน่วย', flex: 1, align: TextAlign.right),
              _hdrCell('ก่อนVAT', flex: 1, align: TextAlign.right),
              _hdrCell('VAT', flex: 1, align: TextAlign.right),
              _hdrCell('WHT', flex: 1, align: TextAlign.right),
              _hdrCell('ยอดสุทธิ',
                  flex: 1, align: TextAlign.right, rightBorder: false),
              // _hdrIconCell(
              //   icon: Icons.close_rounded,
              //   width: 44,
              //   tooltip: 'ล้างการเลือก',
              //   onTap: () => deall_Trans_select(), // ถ้าไม่ใช้ context ให้ลบออก
              // ),
            ],
          ),
        ],
      ),
    );
  }

  //////------------------------->
  ///----------------->
  Widget build(BuildContext context) {
    final isOpen =
        context.watch<SidebarController>().isOpen; // ← อ่านสถานะข้ามหน้า
    return LayoutBuilder(builder: (context, constraints) {
      // ถ้า AdminScaffold "ไม่ตัด sidebar ให้" ต้องลบเอง
      final viewportW = Responsive.isDesktop(context)
          ? (isOpen ? constraints.maxWidth - 295 : constraints.maxWidth - 260)
          : 1200.00;
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          dragStartBehavior: DragStartBehavior.start,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: viewportW),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: SizedBox(
                width: viewportW *
                    1.2, // 👈 บังคับให้ Row มีความกว้างแน่นอน (มากกว่าจอ → เลื่อนได้)
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Bills_(context),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 18,
                                    color: Colors.black.withOpacity(.06),
                                    offset: const Offset(0, 2))
                              ],
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 0.5),
                            ),
                            // width: MediaQuery.of(context).size.width * 0.52,
                            child: Column(children: [
                              billHeaderTable(context),
                              Container(
                                height: 290,
                                decoration: const BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                  ),
                                  // border: Border.all(
                                  //     color: Colors.grey, width: 1),
                                ),
                                child: ListView.builder(
                                  controller: _scrollController2,
                                  // itemExtent: 50,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _InvoiceHistoryModels.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        padding: EdgeInsets.all(8.0),
                                        // padding: const EdgeInsets.symmetric(
                                        //     vertical: 8, horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: const Border(
                                            bottom: BorderSide(
                                              color: Colors.black12,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            if ((double.tryParse(
                                                        _InvoiceHistoryModels[
                                                                    index]
                                                                .dis_list ??
                                                            '0') ??
                                                    0) >
                                                0)
                                              Row(children: [
                                                Container(
                                                  width: 50,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    '${index + 1}',
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    DateFormat('dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                                '${_InvoiceHistoryModels[index].date} 00:00:00')) ??
                                                        '',
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    _InvoiceHistoryModels[index]
                                                            .descr ??
                                                        '',
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    _InvoiceHistoryModels[index]
                                                            .qty ??
                                                        '0',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        // decoration:
                                                        //     TextDecoration.lineThrough,
                                                        // decorationColor: Colors.red,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    (_InvoiceHistoryModels[
                                                                    index]
                                                                .dtype
                                                                .toString() ==
                                                            'KU')
                                                        ? '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pri!))}'
                                                        : '-',
                                                    textAlign:
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .dtype
                                                                    .toString() ==
                                                                'KU')
                                                            ? TextAlign.right
                                                            : TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        // decoration:
                                                        //     TextDecoration.lineThrough,
                                                        // decorationColor: Colors.red,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    nFormat.format(double.tryParse(
                                                            _InvoiceHistoryModels[
                                                                        index]
                                                                    .pvat_original ??
                                                                '0') ??
                                                        0),
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.red,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    nFormat.format(double.tryParse(
                                                            _InvoiceHistoryModels[
                                                                        index]
                                                                    .vat_original ??
                                                                '0') ??
                                                        0),
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.red,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    '${_InvoiceHistoryModels[index].wht_original}',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.red,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    '${nFormat.format(double.parse(_InvoiceHistoryModels[index].amount_original!))}',
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.red,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ]),
                                            Row(children: [
                                              Container(
                                                width: 50,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  ((double.tryParse(_InvoiceHistoryModels[
                                                                          index]
                                                                      .dis_list ??
                                                                  '0') ??
                                                              0) >
                                                          0)
                                                      ? ''
                                                      : '${index + 1}',
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  ((double.tryParse(_InvoiceHistoryModels[
                                                                          index]
                                                                      .dis_list ??
                                                                  '0') ??
                                                              0) >
                                                          0)
                                                      ? ''
                                                      : DateFormat('dd-MM-yyyy')
                                                              .format(DateTime
                                                                  .parse(
                                                                      '${_InvoiceHistoryModels[index].date} 00:00:00')) ??
                                                          '',
                                                  textAlign: TextAlign.left,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: ((double.tryParse(
                                                                _InvoiceHistoryModels[
                                                                            index]
                                                                        .dis_list ??
                                                                    '0') ??
                                                            0) >
                                                        0)
                                                    ? Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .subdirectory_arrow_right,
                                                            color: Colors.grey,
                                                            size: 16,
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: AutoSizeText(
                                                              minFontSize: 10,
                                                              maxFontSize: 12,
                                                              'discount ${nFormat.format(double.parse(_InvoiceHistoryModels[index].dis_list!))}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 15,
                                                        _InvoiceHistoryModels[
                                                                    index]
                                                                .descr ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  ((double.tryParse(_InvoiceHistoryModels[
                                                                          index]
                                                                      .dis_list ??
                                                                  '0') ??
                                                              0) >
                                                          0)
                                                      ? ''
                                                      : _InvoiceHistoryModels[
                                                                  index]
                                                              .qty ??
                                                          '0',
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  ((double.tryParse(_InvoiceHistoryModels[
                                                                          index]
                                                                      .dis_list ??
                                                                  '0') ??
                                                              0) >
                                                          0)
                                                      ? ''
                                                      : (_InvoiceHistoryModels[
                                                                      index]
                                                                  .dtype
                                                                  .toString() ==
                                                              'KU')
                                                          ? '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pri!))}'
                                                          : '-',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign:
                                                      (_InvoiceHistoryModels[
                                                                      index]
                                                                  .dtype
                                                                  .toString() ==
                                                              'KU')
                                                          ? TextAlign.right
                                                          : TextAlign.center,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  nFormat.format(double.tryParse(
                                                          _InvoiceHistoryModels[
                                                                      index]
                                                                  .pvat ??
                                                              '0') ??
                                                      0),
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  nFormat.format(double.tryParse(
                                                          _InvoiceHistoryModels[
                                                                      index]
                                                                  .vat ??
                                                              '0') ??
                                                      0),
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  '${_InvoiceHistoryModels[index].wht}',
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  nFormat.format(double.parse(
                                                      _InvoiceHistoryModels[
                                                                      index]
                                                                  .pvat ==
                                                              null
                                                          ? '0'
                                                          : _InvoiceHistoryModels[
                                                                  index]
                                                              .total!)),
                                                  textAlign: TextAlign.right,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                            ]),
                                          ],
                                        ));
                                  },
                                ),
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                  ),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child:
                                            //  Container(
                                            //   color: Colors.grey.shade300,
                                            //   // height: 100,
                                            //   width: 600,
                                            //   padding: EdgeInsets.all(8.0),
                                            Row(
                                          children: [
                                            Expanded(child: SizedBox()),
                                            Expanded(
                                              child: Card(
                                                color: Colors.grey.shade300,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                clipBehavior: Clip.antiAlias,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'รวม(บาท)',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            textAlign:
                                                                TextAlign.end,
                                                            '${nFormat.format(getTotalByField(_InvoiceHistoryModels, (item) => item.pvat))}', // Convert sum to String
                                                            // '${nFormat.format(sum_pvat)}',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'ภาษีมูลค่าเพิ่ม(vat)',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            textAlign:
                                                                TextAlign.end,
                                                            '${nFormat.format(getTotalByField(_InvoiceHistoryModels, (item) => item.vat))}',
                                                            // '${nFormat.format(sum_vat)}',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'หัก ณ ที่จ่าย',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            textAlign:
                                                                TextAlign.end,
                                                            '${nFormat.format(getTotalByField(_InvoiceHistoryModels, (item) => item.wht))}',
                                                            // '${nFormat.format(sum_wht)}',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'ยอดรวม',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            textAlign:
                                                                TextAlign.end,
                                                            '${nFormat.format(getTotalByField(_InvoiceHistoryModels, (item) => item.total))}',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Row(
                                                            children: [
                                                              AutoSizeText(
                                                                minFontSize: 12,
                                                                maxFontSize: 14,
                                                                'ส่วนลด',
                                                                style: TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              SizedBox(
                                                                width: 60,
                                                                height: 20,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      12,
                                                                  maxFontSize:
                                                                      14,
                                                                  '$sum_disp  %',
                                                                  style: TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${nFormat.format(_InvoiceHistoryModels.isNotEmpty ? double.tryParse(_InvoiceHistoryModels.first.disendbillper ?? '0.00') ?? 0.00 : 0.00)}',
                                                            // '${nFormat.format(sum_disamt)}',
                                                            // '${nFormat.format(sum_disamt - sum_dislist)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'ยอดชำระ',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            textAlign:
                                                                TextAlign.end,
                                                            '${nFormat.format(getTotalByField(_InvoiceHistoryModels, (item) => item.total))}',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    const Divider(),
                                                    SizedBox(
                                                      height: 2,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'รายการทั้งหมด : ${_InvoiceHistoryModels.length}',
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: ElevatedButton
                                                              .icon(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .deepPurple,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                              ),
                                                            ),
                                                            icon: const Icon(
                                                                Icons
                                                                    .receipt_outlined,
                                                                size: 18),
                                                            label: const Text(
                                                                'รายละเอียด',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T)),
                                                            onPressed:
                                                                _InvoiceHistoryModels
                                                                            .length <
                                                                        1
                                                                    ? null
                                                                    : () async {
                                                                        dialogOk(
                                                                            context);
                                                                      },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ))
                            ])),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

///////////////-------------------------------------------->
  final Formbecause_ = TextEditingController();
  Future<void> dialogOk(BuildContext context) {
    bool _openDeINV = false;
    // วางนอก onPressed (เช่นเป็นฟิลด์ของ State)
    bool _savingInvoice = false;
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
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

            // ---------- Title ----------
            title: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_sharp,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'รายละเอียดวางบิล',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                      if (payment_refapi != '')
                        Container(
                          width: 110,
                          padding: EdgeInsets.all(4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor:
                                  PeopleChaoScreen_Color.Colors_Text3_,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            onPressed: _savingInvoice
                                ? null // กันกดซ้ำระหว่างกำลังบันทึก
                                : () async {
                                    Gen_QRAPINEW();
                                  },
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text('แสดง QR',
                                  style: TextStyle(fontFamily: Font_.Fonts_T)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.close, size: 22, color: Colors.black54),
                  ),
                ),
              ],
            ),

            // ---------- Content ----------
            content: Container(
              width: double.infinity,
              // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              // decoration: BoxDecoration(
              //   // color: toneColor.withOpacity(0.06),
              //   borderRadius: BorderRadius.circular(10),
              //   // border: Border.all(color: Colors.grey.withOpacity(0.18)),
              // ),
              // child:
              //  ConstrainedBox(
              // constraints: const BoxConstraints(
              //   maxWidth: 200, // ⬅️ ความกว้างสูงสุด (สวยบนจอใหญ่/เล็ก)
              // ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==== Header card ====
                    // Container(
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         Colors.green.shade400,
                    //         Colors.green.shade300,
                    //       ],
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //     ),
                    //     borderRadius:
                    //         const BorderRadius.vertical(top: Radius.circular(14)),
                    //     boxShadow: const [
                    //       BoxShadow(
                    //         blurRadius: 10,
                    //         offset: Offset(0, 4),
                    //         color: Color(0x1A000000),
                    //       ),
                    //     ],
                    //   ),
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 16, vertical: 12),
                    //   child: const Center(
                    //     child: Text(
                    //       'ยอดชำระทั้งหมด',
                    //       style: TextStyle(
                    //         color: PeopleChaoScreen_Color.Colors_Text3_,
                    //         fontWeight: FontWeight.bold,
                    //         fontFamily: FontWeight_.Fonts_T,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.25)),
                            ),
                            child: Text(
                              '${widget.Get_Value_NameShop_index}' == '1'
                                  ? 'เลขที่ใบสัญญา'
                                  : 'เลขที่ใบเสนอราคา',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              '${widget.Get_Value_cid}',
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.deepPurple.withOpacity(0.25)),
                            ),
                            child: Text(
                              'ใบวางบิล',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              '${numinvoice}',
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.18)),
                      ),
                      child: Text(
                        'ตรวจสอบข้อมูลให้ถูกต้องก่อนทำรายการ',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // ==== Body card ====
                    Container(
                      decoration: BoxDecoration(
                        color: AppbackgroundColor.Sub_Abg_Colors,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                            bottom: Radius.circular(14)),
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: Column(
                        children: [
                          // ยอดชำระรวม
                          Row(
                            children: [
                              const Text(
                                'ยอดชำระรวม : ',
                                style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 13,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50]!.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Text(
                                    '${nFormat.format(getTotalByField(_InvoiceHistoryModels, (item) => item.total))}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // วันที่ครบกำหนด
                          InkWell(
                            onTap: () async => null,
                            borderRadius: BorderRadius.circular(10),
                            child: Row(
                              children: [
                                const Text(
                                  'วันที่ครบกำหนดชำระ : ',
                                  style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 13,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50]!.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            (Datex_invoice == null)
                                                ? 'วันที่ครบ ( ไม่พบ ) !!!'
                                                : (Datex_invoice == null)
                                                    ? '${Datex_invoice}  '
                                                    : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${Datex_invoice}'))}',
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontFamily: Font_.Fonts_T,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // const Icon(Icons.arrow_drop_down,
                                        //     color: Colors.black54),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // หัวบิล
                          Row(
                            children: [
                              const Text(
                                'หัวบิล :',
                                style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField2(
                                  alignment: Alignment.center,
                                  focusColor: Colors.white,
                                  autofocus: false,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE7E3E3)),
                                    ),
                                  ),
                                  hint: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.black54),
                                  iconSize: 22,
                                  buttonHeight: 44,
                                  buttonPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  items: TitleType_Default_Receipt_.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: '$item',
                                      child: Text(
                                        '$item',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    final i =
                                        TitleType_Default_Receipt_.indexWhere(
                                            (e) => e == value);
                                    setState(
                                        () => TitleType_Default_Receipt = i);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // รูปแบบชำระ
                          Row(
                            children: [
                              const Text(
                                'รูปแบบชำระ :',
                                style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  width: 320,
                                  height: 45,
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: Center(
                                    child: AutoSizeText(
                                      minFontSize: 8,
                                      maxFontSize: 12,
                                      textAlign: TextAlign.end,
                                      (payment_Ptname1 == null)
                                          ? 'รูปแบบ ( ไม่พบ ) !!!'
                                          : (payment_Bno1 == null)
                                              ? '${payment_Ptname1}  '
                                              : '${payment_Ptname1} : ${payment_Bno1}',
                                      style: TextStyle(
                                          color: (payment_Ptname1 == null)
                                              ? Colors.red
                                              : PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_openDeINV == true) const SizedBox(height: 10),
                          if (_openDeINV == true)
                            Row(
                              children: [
                                const Text(
                                  'หมายเหตุ :',
                                  style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SizedBox(
                                      height: 45,
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: Formbecause_,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'ใส่ข้อมูลให้ครบถ้วน ';
                                          }
                                          // if (int.parse(value.toString()) < 13) {
                                          //   return '< 13';
                                          // }
                                          return null;
                                        },
                                        // maxLength: 13,
                                        cursorColor: Colors.green,
                                        decoration: InputDecoration(
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            // prefixIcon: const Icon(Icons.water,
                                            //     color: Colors.blue),
                                            // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            // labelText: 'หมายเหตุ-Note',
                                            labelStyle: const TextStyle(
                                              color: AccountScreen_Color
                                                  .Colors_Text2_,
                                              // fontWeight:
                                              //     FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                            )),
                                        // inputFormatters: <TextInputFormatter>[
                                        //   // for below version 2 use this
                                        //   FilteringTextInputFormatter.allow(
                                        //       RegExp(r'[0-9]')),
                                        //   // for version 2 and greater youcan also use this
                                        //   FilteringTextInputFormatter.digitsOnly
                                        // ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // ),
            ),

            // ---------- Actions ----------
            actionsAlignment:
                MainAxisAlignment.center, // ⬅️ จัดกึ่งกลาง (เฉพาะ AlertDialog)

            actions: [
              //  payment_refapi != '' Gen_QRAPINEW();
              if (payment_Ptname1 == null || payment_Ptname1.toString() == '')
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'พิมพ์ ไม่ได้ไม่พบช่องทางรับชำระ !!!( โปรดตรวจสอบหรือยกเลิก )',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ========== พิมพ์/บันทึก ==========
                    SizedBox(
                      width: 170,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: PeopleChaoScreen_Color.Colors_Text3_,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: _savingInvoice
                            ? null // กันกดซ้ำระหว่างกำลังบันทึก
                            : () async {
                                // กันกดซ้ำ
                                _savingInvoice = true;

                                // 1) เปิด Loader
                                ChaoAppLoader.show(
                                  asset: 'images/LOGO.png', // หรือ .gif ก็ได้
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

                                final navigator =
                                    Navigator.of(ctx); // ใช้ ctx ใน dialog

                                try {
                                  // 2) เตรียมข้อมูล
                                  List newValuePDFimg = [];
                                  for (int index = 0; index < 1; index++) {
                                    if (renTalModels[0].imglogo!.trim() == '') {
                                      // newValuePDFimg.add(
                                      //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                    } else {
                                      newValuePDFimg.add(
                                          '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                    }
                                  }
                                  SharedPreferences preferences =
                                      await SharedPreferences.getInstance();
                                  var renTal_name =
                                      preferences.getString('renTalName');

                                  final tableData003 = [
                                    for (int index = 0;
                                        index < _InvoiceHistoryModels.length;
                                        index++)
                                      [
                                        '${index + 1}',
                                        '${_InvoiceHistoryModels[index].date}',
                                        '${_InvoiceHistoryModels[index].descr}',
                                        // '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}',
                                        '${nFormat.format(double.parse(_InvoiceHistoryModels[index].nvat!))}',
                                        '${nFormat.format(double.parse(_InvoiceHistoryModels[index].vat!))}',
                                        '${nFormat.format(double.parse(_InvoiceHistoryModels[index].pvat!))}',
                                        '${nFormat.format(double.parse(_InvoiceHistoryModels[index].amt!))}',
                                      ],
                                  ];
                                  await BillingNoteInvlice_History_Tempage(
                                      tableData003,
                                      newValuePDFimg,
                                      renTal_name);

                                  // 4) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิด)
                                  if (navigator.canPop()) navigator.pop();

                                  // 5) หน่วง 1 วิ แล้วแจ้งสำเร็จ (ถ้าหน้ายังอยู่)
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  if (ctx.mounted) {
                                    Dialog_success(ctx, 'success');
                                  }
                                } catch (e) {
                                 //  debug//print('in_Trans_invoice error: $e');
                                  if (ctx.mounted) {
                                    Dialog_error(
                                        ctx, 'เกิดข้อผิดพลาด: ${e.toString()}');
                                  }
                                } finally {
                                  // 6) ปิด Loader เสมอ
                                  ChaoAppLoader.hide();

                                  // ปล่อยปุ่มให้กดใหม่ได้
                                  _savingInvoice = false;
                                  if (mounted)
                                    setState(
                                        () {}); // รีเฟรชปุ่ม disabled/enabled
                                }
                              },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('พิมพ์',
                              style: TextStyle(fontFamily: Font_.Fonts_T)),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),
                    // ========== บันทึก ==========
                    SizedBox(
                      width: 170,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_openDeINV == false)
                              ? Colors.orange.shade800
                              : Colors.red.shade800,
                          foregroundColor: PeopleChaoScreen_Color.Colors_Text3_,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: _savingInvoice
                            ? null
                            : (numinvoice == null)
                                ? null
                                : (_openDeINV == false)
                                    ? () async {
                                        setState(() {
                                          _openDeINV = true;
                                          Formbecause_.text = 'ข้อมูลผิดพลาด';
                                        });
                                      }
                                    : (renTal_Ser.toString() == '106')
                                        ? () async {
                                            //print(renTal_Ser);
                                            SharedPreferences preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            var ren = preferences
                                                .getString('renTalSer');
                                            String url =
                                                '${MyConstant().domain}/v2/choice/check_genqr_new.php';

                                            try {
                                              final response = await http.post(
                                                Uri.parse(url),
                                                headers: {
                                                  "Content-Type":
                                                      "application/json",
                                                },
                                                body: jsonEncode({
                                                  "isAdd": true,
                                                  "ren": ren.toString(),
                                                  "invoice":
                                                      "'${numinvoice.toString()}'",
                                                  "custno": custno_Ser,
                                                }),
                                              );

                                              //print(
                                                 //  "=== Response Status Code: ${response.statusCode} ===");
                                              // //print(
                                              //     "=== Response Body: ${response.body} ===");

                                              // ตรวจสอบว่าได้ response 200 และมีข้อมูลไม่ว่าง
                                              if (response.statusCode == 200 &&
                                                  response.body.isNotEmpty) {
                                                PanaraInfoDialog
                                                    .showAnimatedGrow(
                                                  context,
                                                  title: "คำเตือน",
                                                  message:
                                                      "ไม่สามารถยกเลิกบิลได้ เนื่องจากผู้เช่ามีการ Gen QR เพื่อเตรียมชำระแล้ว",

                                                  buttonText: "รับทราบ",
                                                  onTapDismiss: () async {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop();
                                                  },
                                                  panaraDialogType:
                                                      PanaraDialogType.warning,
                                                  barrierDismissible:
                                                      false, // optional parameter (default is true)
                                                );
                                              } else {
                                                setState(() => _savingInvoice =
                                                    true); // กันกดซ้ำทันที

                                                // 1) เปิด Loader
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
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
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

                                                final navigator = Navigator.of(
                                                    ctx); // ใช้ ctx ของ dialog

                                                try {
                                                  Insert_log.Insert_logs(
                                                      'ผู้เช่า',
                                                      'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                                  // 2) งานหลัก
                                                  await de_invoice();

                                                  // 3) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิดอยู่)
                                                  if (navigator.canPop())
                                                    navigator.pop();

                                                  // 4) รอ 1 วิ แล้วโชว์ success (ถ้าหน้ายังอยู่)
                                                  await Future.delayed(
                                                      const Duration(
                                                          seconds: 1));
                                                  if (ctx.mounted) {
                                                    Dialog_success(
                                                        ctx, 'success');
                                                  }
                                                } catch (e) {
                                                  // debug//print(
                                                    //   'in_Trans_invoice error: $e');
                                                  if (ctx.mounted) {
                                                    Dialog_error(ctx,
                                                        'เกิดข้อผิดพลาด: ${e.toString()}');
                                                  }
                                                } finally {
                                                  // 5) ปิด Loader เสมอ
                                                  ChaoAppLoader.hide();

                                                  // 6) ปลดล็อกปุ่ม
                                                  if (mounted)
                                                    setState(() =>
                                                        _savingInvoice = false);
                                                }
                                              }
                                            } catch (e) {}
                                          }
                                        : () async {
                                            setState(() => _savingInvoice =
                                                true); // กันกดซ้ำทันที

                                            // 1) เปิด Loader
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

                                            final navigator = Navigator.of(
                                                ctx); // ใช้ ctx ของ dialog

                                            try {
                                              Insert_log.Insert_logs('ผู้เช่า',
                                                  'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                              // 2) งานหลัก
                                              await de_invoice();

                                              // 3) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิดอยู่)
                                              if (navigator.canPop())
                                                navigator.pop();

                                              // 4) รอ 1 วิ แล้วโชว์ success (ถ้าหน้ายังอยู่)
                                              await Future.delayed(
                                                  const Duration(seconds: 1));
                                              if (ctx.mounted) {
                                                Dialog_success(ctx, 'success');
                                              }
                                            } catch (e) {
                                               //debug//print(
                                                 //  'in_Trans_invoice error: $e');
                                              if (ctx.mounted) {
                                                Dialog_error(ctx,
                                                    'เกิดข้อผิดพลาด: ${e.toString()}');
                                              }
                                            } finally {
                                              // 5) ปิด Loader เสมอ
                                              ChaoAppLoader.hide();

                                              // 6) ปลดล็อกปุ่ม
                                              if (mounted)
                                                setState(() =>
                                                    _savingInvoice = false);
                                            }

                                            // if (numinvoice != null) {
                                            //   Insert_log.Insert_logs('ผู้เช่า',
                                            //       'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                            //   //print(numinvoice);
                                            //   de_invoice();
                                            //   Navigator.pop(context);
                                            // }
                                          },
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                              (_openDeINV == false)
                                  ? 'ยกเลิกการวางบิล'
                                  : 'ยืนยันการยกเลิก',
                              style: TextStyle(fontFamily: Font_.Fonts_T)),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        });
      },
    );
  }

  ////////////////////////-------------------------------------->
  Future<Null> Gen_QRAPINEW() async {
    var total_QRsend = (sum_amt - sum_disamt).toStringAsFixed(2);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, 'OK');
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 22,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 1),
                  Divider(),
                  SizedBox(height: 1),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Online Standard QR',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ref1 : $payment_ref1',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ref2 : ${payment_ref2}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Total : ${total_QRsend} ',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ],
                        );
                      }),
                  SizedBox(height: 1),
                  Divider(),
                  SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'SCAN ME',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Container(
                              width: 500,
                              height: 500,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${MyConstant().domain}/gen_qr_img.php?ren=$ren&ref_id=$payment_refapi&incid=$payment_cid&sum=$total_QRsend&extension=.png'),
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    // border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      PanaraConfirmDialog.showAnimatedGrow(
                                        context,
                                        title: "Line Notification",
                                        message:
                                            "แจ้งเตือนชำระค่าบริการผ่านไลน์",
                                        confirmButtonText: "Confirm",
                                        cancelButtonText: "Cancel",
                                        onTapConfirm: () async {
                                          if (ser_notiline != null ||
                                              ser_notiline != '') {
                                            var serregis = ser_notiline;
                                            var incid = payment_cid;
                                            var indocno = numinvoice;
                                            var insum = total_QRsend;
                                            SharedPreferences preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            var ren = preferences
                                                .getString('renTalSer');
                                            String url =
                                                '${MyConstant().domain}/sent_line_noti_image.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                                            // renTal_name = preferences.getString('renTalName');
                                            try {
                                              var response = await http
                                                  .get(Uri.parse(url));

                                              var result =
                                                  json.decode(response.body);

                                              if (result.toString() ==
                                                  'Line Successfully') {
                                                ////print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Translate
                                                        .TranslateAndSetText(
                                                            'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                            Colors.white,
                                                            TextAlign.start,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),
                                                    // Text(
                                                    //   'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                    //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                );
                                              } else {
                                                // //print('Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Translate
                                                        .TranslateAndSetText(
                                                            'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                            Colors.white,
                                                            TextAlign.start,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),
                                                    // Text(
                                                    //   'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                    //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                    // ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              //print(
                                                //   'Error-Dis(read_GC_rental) : ${e}');
                                            }
                                          }
                                          Navigator.pop(context);
                                        },
                                        onTapCancel: () {
                                          Navigator.pop(context);
                                        },
                                        panaraDialogType:
                                            PanaraDialogType.success,
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Send Line ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.send_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }),
                ],
              ),
            ));
      },
    );
  }

  Future<Null> de_invoice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    //print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=${Formbecause_.text}';
    try {
      //print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print('result>>>>>>> $result');
      //print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          //print('numinvoice 4 $numinvoice');
          red_Invoice();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        //print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  //////////////////////////------------------------------>
  Future<Null> BillingNoteInvlice_History_Tempage(
      tableData003, newValuePDFimg, renTal_name) async {
    String? TitleType_Default_Receipt_Name;
    if (TitleType_Default_Receipt == 0) {
    } else {
      setState(() {
        TitleType_Default_Receipt_Name =
            '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}';
      });
    }
    Man_BillingNoteInvlice_PDF.ManBillingNoteInvlice_PDF(
        TitleType_Default_Receipt_Name,
        foder,
        '${widget.Get_Value_NameShop_index}',
        tem_page_ser,
        context,
        '${widget.Get_Value_cid}',
        '${widget.namenew}',
        '${renTalModels[0].bill_addr}',
        '${renTalModels[0].bill_email}',
        '${renTalModels[0].bill_tel}',
        '${renTalModels[0].bill_tax}',
        '${renTalModels[0].bill_name}',
        newValuePDFimg,
        numinvoice,
        '0');
  }
}
