import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:chaoperty/Model/GetWht_Model.dart';
import 'package:chaoperty/Style/colors.dart';
import 'package:chaoperty_floating_loader/chaoperty_floating_loader.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AdminScaffold/AdminScaffold.dart';

import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetContractx_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/vat_SC_model.dart';
import '../Responsive/responsive.dart';

class SettringListMenu extends StatefulWidget {
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  const SettringListMenu({
    super.key,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
  });

  @override
  State<SettringListMenu> createState() => _SettringListMenuState();
}

class _SettringListMenuState extends State<SettringListMenu> {
// ================== fields ==================
  final List<TransBillModel> _TransBillModels = <TransBillModel>[];
  final List<ContractxModel> contractxModels = <ContractxModel>[];
  final List<VatSeModel> vatSeModels = <VatSeModel>[];
  final List<WhtModel> whtModels = <WhtModel>[];

// Controllers
  final edit_textall = TextEditingController();
  final edit_texttotal = TextEditingController();
  final edit_textvat = TextEditingController();
  final edit_textwht = TextEditingController();
  final Formposlok_ = TextEditingController();

  final _formKey = GlobalKey<FormState>();

// Filters / selections (คงโครงสร้างเดิม)
  String ptype = 'ทั้งหมด', File_Names = '', Dropdown_expname = 'ทั้งหมด';
  String? edit_data_ser,
      edit_data_date,
      edit_data_pvat,
      edit_data_vser,
      edit_data_vtype,
      edit_data_nvat,
      edit_data_nwht,
      edit_data_docno,
      edit_data_total,
      con_pser,
      se_vser,
      se_vtype,
      se_wht,
      se_nwht;
  int edit_data = 0;

// Networking
  late final Dio _dio;
  final CancelToken _cancelToken =
      CancelToken(); // ยกเลิกทุก request ตอน dispose
// ================== lifecycle ==================

  @override
  void initState() {
    super.initState();

    // ตั้งค่า Dio ให้ robust ขึ้น แต่ไม่เปลี่ยนลอจิกเรียกใช้เดิม
    _dio = Dio(BaseOptions(
      baseUrl: MyConstant().domain,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      // ให้เราตรวจจับ 4xx/5xx เอง (จะไม่ throw อัตโนมัติ)
      validateStatus: (code) => code != null && code >= 200 && code < 500,
    ))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final auth = Security.generateAuthHeaders();
            options.headers.addAll(auth);
            // options.headers['Content-Type'] ??= 'application/json';
            return handler.next(options);
          },
        ),
      );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ));
    }

    red_Trans_billAll(ptype);
    read_GC_Exp();
    read_GC_vat();
    read_GC_wht();
  }

  @override
  void dispose() {
    // ยกเลิก request ค้าง (กัน callback หลังถูก dispose)
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('dispose');
    }

    // เคลียร์ controllers กัน memory leak
    edit_textall.dispose();
    edit_texttotal.dispose();
    edit_textvat.dispose();
    edit_textwht.dispose();
    Formposlok_.dispose();

    super.dispose();
  }

  /// ---------------- read_GC_wht (ดึงประเภทค่าใช้จ่าย/wht) ----------------
  Future<void> read_GC_wht() async {
    if (!mounted) return;

    if (whtModels.isNotEmpty) {
      setState(() => whtModels.clear());
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '';

      final res = await _dio.get(
        '/GC_wht.php',
        queryParameters: {'isAdd': 'true', 'ren': ren},
      );

      if (res.statusCode != 200 || res.data == null) return;

      // รองรับทั้ง array ตรง ๆ หรือ object ที่มี data เป็น array
      final dynamic data = res.data;
      final List list = data is List
          ? data
          : (data is Map && data['data'] is List
              ? data['data'] as List
              : const []);

      if (list.isEmpty) return;

      final next = <WhtModel>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          next.add(WhtModel.fromJson(item));
        } else if (item is Map) {
          next.add(WhtModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (!mounted) return;
      setState(() {
        whtModels.addAll(next);
      });
    } on DioException catch (e) {
      debugPrint('read_GC_wht dio error: ${e.message}');
    } catch (e) {
      debugPrint('read_GC_wht error: $e');
    }
  }

// ---------------- read_GC_vat (ดึงประเภทค่าใช้จ่าย/vat) ----------------
  Future<void> read_GC_vat() async {
    if (!mounted) return;

    if (vatSeModels.isNotEmpty) {
      setState(() => vatSeModels.clear());
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '';

      final res = await _dio.get(
        '/GC_vat_setring.php',
        queryParameters: {'isAdd': 'true', 'ren': ren},
      );

      if (res.statusCode != 200 || res.data == null) return;

      final dynamic data = res.data;
      final List list = data is List
          ? data
          : (data is Map && data['data'] is List
              ? data['data'] as List
              : const []);

      if (list.isEmpty) return;

      final next = <VatSeModel>[];
      for (final item in list) {
        final map = (item is Map<String, dynamic>)
            ? item
            : (item is Map ? Map<String, dynamic>.from(item) : null);
        if (map == null) continue;

        final v = VatSeModel.fromJson(map);
        if (v.st != '0') {
          next.add(v); // ⬅️ คงเงื่อนไขเดิม
        }
      }

      if (!mounted) return;
      setState(() {
        vatSeModels.addAll(next);
      });
    } on DioException catch (e) {
      // debugPrint('read_GC_vat dio error: ${e.message}');
    } catch (e) {
      // debugPrint('read_GC_vat error: $e');
    }
  }

// ---------------- read_GC_Exp (ดึงประเภทค่าใช้จ่าย/exp) ----------------
  Future<void> read_GC_Exp() async {
    if (!mounted) return;

    if (contractxModels.isNotEmpty) {
      setState(() => contractxModels.clear());
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '';
      final ciddoc = widget.Get_Value_cid;

      final res = await _dio.get(
        '/GC_conx.php',
        queryParameters: {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': '$ciddoc',
        },
      );

      if (res.statusCode != 200 || res.data == null) return;

      // print(res.data); // ถ้าต้องการ log เหมือนเดิม

      final next = <ContractxModel>[];

      // เพิ่ม "ทั้งหมด" ser=0 ตามเดิม
      next.add(ContractxModel.fromJson({'ser': '0', 'expname': 'ทั้งหมด'}));

      final dynamic data = res.data;
      final List list = data is List
          ? data
          : (data is Map && data['data'] is List
              ? data['data'] as List
              : const []);

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          next.add(ContractxModel.fromJson(item));
        } else if (item is Map) {
          next.add(ContractxModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (!mounted) return;
      setState(() => contractxModels.addAll(next));
    } on DioException catch (_) {
      // debugPrint('read_GC_Exp dio error: ${e.message}');
    } catch (_) {
      // debugPrint('read_GC_Exp error: $e');
    }
  }

// ---------------- red_Trans_billAll (ดึงบิลทั้งหมด) ----------------
  Future<void> red_Trans_billAll(String ptype) async {
    if (!mounted) return;

    if (_TransBillModels.isNotEmpty) {
      setState(() => _TransBillModels.clear());
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer') ?? '';
      final ciddoc = widget.Get_Value_cid;
      final qutser = widget.Get_Value_NameShop_index;

      final res = await _dio.get(
        '/GC_tran_bill_All_V2.php',
        queryParameters: {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': '$ciddoc',
          'qutser': '$qutser',
        },
      );

      if (res.statusCode != 200 || res.data == null) return;

      print(res.data); // ถ้าต้องการ

      final dynamic data = res.data;
      final List list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : (data is List ? data : const []);

      if (list.isEmpty) return;

      final next = <TransBillModel>[];
      for (final item in list) {
        final map = (item is Map<String, dynamic>)
            ? item
            : (item is Map ? Map<String, dynamic>.from(item) : null);
        if (map == null) continue;

        final tb = TransBillModel.fromJson(map);
        final serCon = tb.ser_con; // ตามเดิม
        final noInvoice = tb.invoice == null;

        if (noInvoice) {
          if (con_pser == serCon) {
            next.add(tb);
          } else if (ptype == 'ทั้งหมด') {
            next.add(tb);
          }
        }
      }

      if (!mounted) return;
      setState(() => _TransBillModels.addAll(next));
    } on DioException catch (_) {
      // debugPrint('red_Trans_billAll dio error: ${e.message}');
    } catch (_) {
      // debugPrint('red_Trans_billAll error: $e');
    }
  }

  ////////------------------------------------------------------>
  String priceType = 'ก่อน VAT';
  final TextEditingController _priceController =
      TextEditingController(text: '0');
  double vatPercent = 7;
  double whtPercent = 3;
  Widget _buildPercentageRow(
      String type, String label, TextEditingController controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            child: Row(
          children: [
            Text(label),
            SizedBox(
              width: 20,
              child: PopupMenuButton(
                // onOpened: () {

                // },
                child: Center(
                  child: InkWell(
                      child: Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.blue,
                  )),
                ),
                itemBuilder: (type == 'VAT')
                    ? (BuildContext context) => [
                          for (int index = 0;
                              index < vatSeModels.length;
                              index++)
                            PopupMenuItem(
                              child: Column(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          se_vser = vatSeModels[index].ser!;

                                          se_vtype = vatSeModels[index].vat!;
                                          controllers.text =
                                              vatSeModels[index].pct!;
                                        });

                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                vatSeModels[index].vat!,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ))
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                        ]
                    : (BuildContext context) => [
                          for (int index = 0; index < whtModels.length; index++)
                            PopupMenuItem(
                              child: Column(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        // var zones = value!.indexOf(':');
                                        var vat_ser = whtModels[index].ser;
                                        var vat_name = whtModels[index].wht;
                                        print(
                                            'mmmmm ${vat_ser.toString()} $vat_name');

                                        setState(() {
                                          se_wht = vat_ser;
                                          se_nwht = vat_name;
                                          controllers.text =
                                              whtModels[index].pct!;
                                        });

                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                whtModels[index].wht!,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ))
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                        ],
              ),
            ),
          ],
        )),
        // InkWell(onTap: () {}, child: Icon(Icons.info_outline)),

        Container(
          width: 130,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  // controller:
                  //     _priceController,
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  controller: controllers, readOnly: true,
                  decoration: InputDecoration(
                    // prefixText: '฿',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    // for below version 2 use this
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
                    // for version 2 and greater youcan also use this
                    // FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              ),
              // Text('${percent.toStringAsFixed(0)}'),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text('%', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //////////////////--------------------------->
  String thaiDate(String? ymd) {
    if (ymd == null || ymd.isEmpty) return '';
    final dt = DateTime.tryParse('$ymd 00:00:00');
    if (dt == null) return '';
    final ddmm = DateFormat('dd-MM').format(dt);
    final byear = dt.year + 0; //543;
    return '$ddmm-$byear';
  }

  //////////////////--------------------------->
  Widget _TitalContent() {
    List<String> data = [
      // 'เลขตั้งหนี้',
      'กำหนดชำระ',
      'รายการ',
      'ก่อนVAT',
      'ประเภทVAT',
      'VAT',
      'ประเภทWHT',
      'WHT',
      'ยอดสุทธิ',
    ];

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (int index = 0; index < data.length; index++)
        Expanded(
          flex: 1,
          child: Text(
            data[index],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: (index > 2) ? TextAlign.end : TextAlign.start,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double minSize = 8.00;
    double maxSize = 14.00;
    return Container(
        width: (!Responsive.isDesktop(context))
            ? 1600
            : MediaQuery.of(context).size.width * 0.84,
        decoration: const BoxDecoration(
          // color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          // border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(children: [
          ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                dragStartBehavior: DragStartBehavior.start,
                child: SizedBox(
                  width: (!Responsive.isDesktop(context))
                      ? 1600
                      : MediaQuery.of(context).size.width * 0.84,
                  child: Row(
                    children: [
                      // Expanded(
                      //   flex: 2,
                      //   child: Column(
                      //     children: [
                      //       Container(
                      //         // height: 50,
                      //         decoration: BoxDecoration(
                      //           color: AppbackgroundColor.TiTile_Colors,
                      //           borderRadius: BorderRadius.only(
                      //               topLeft: Radius.circular(10),
                      //               topRight: Radius.circular(10),
                      //               bottomLeft: Radius.circular(0),
                      //               bottomRight: Radius.circular(0)),
                      //         ),
                      //         padding: const EdgeInsets.all(2.0),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Expanded(
                      //               child: Container(
                      //                 padding: const EdgeInsets.all(2.0),
                      //                 child: AutoSizeText(
                      //                   minFontSize: 8,
                      //                   maxFontSize: 14,
                      //                   maxLines: 1,
                      //                   'รายการตั้งหนี้',
                      //                   textAlign: TextAlign.center,
                      //                   style: TextStyle(
                      //                       color: PeopleChaoScreen_Color
                      //                           .Colors_Text1_,
                      //                       fontWeight: FontWeight.bold,
                      //                       fontFamily: FontWeight_.Fonts_T
                      //                       //fontSize: 10.0
                      //                       //fontSize: 10.0
                      //                       ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Container(
                      //         height: MediaQuery.of(context).size.width * 0.26,
                      //         decoration: const BoxDecoration(
                      //           color: AppbackgroundColor.Sub_Abg_Colors,
                      //           borderRadius: BorderRadius.only(
                      //             topLeft: Radius.circular(0),
                      //             topRight: Radius.circular(0),
                      //             bottomLeft: Radius.circular(0),
                      //             bottomRight: Radius.circular(0),
                      //           ),
                      //           // border: Border.all(
                      //           //     color: Colors.grey, width: 1),
                      //         ),
                      //         width: MediaQuery.of(context).size.width,
                      //         child: ListView.builder(
                      //           // controller: _scrollController1,
                      //           // itemExtent: 50,
                      //           physics: const AlwaysScrollableScrollPhysics(),
                      //           shrinkWrap: true,
                      //           itemCount: contractxModels.length,
                      //           itemBuilder: (BuildContext context, int index) {
                      //             return Material(
                      //               color: con_pser ==
                      //                       contractxModels[index].ser
                      //                   ? tappedIndex_Color.tappedIndex_Colors
                      //                   : null,
                      //               child: InkWell(
                      //                 onTap: () {},
                      //                 child: ListTile(
                      //                   onTap: () {
                      //                     setState(() {
                      //                       ptype = contractxModels[index]
                      //                           .expname
                      //                           .toString();
                      //                       con_pser = contractxModels[index]
                      //                           .ser
                      //                           .toString();
                      //                       edit_data = 1;
                      //                       edit_data_ser = null;
                      //                       edit_data_date = null;
                      //                       edit_data_vtype = null;
                      //                       edit_data_pvat = null;
                      //                       edit_data_nvat = null;
                      //                       edit_data_nwht = null;
                      //                       edit_data_docno = null;
                      //                       edit_data_total = null;

                      //                       edit_textall.text =
                      //                           contractxModels[index]
                      //                               .amt
                      //                               .toString();
                      //                       edit_texttotal.text =
                      //                           contractxModels[index]
                      //                               .total
                      //                               .toString();
                      //                       edit_textvat.text =
                      //                           contractxModels[index]
                      //                               .vat
                      //                               .toString();
                      //                       edit_textwht.text =
                      //                           contractxModels[index]
                      //                               .wht
                      //                               .toString();

                      //                       se_vser =
                      //                           contractxModels[index].vser;
                      //                       se_vtype =
                      //                           contractxModels[index].vtype;
                      //                       se_wht = null;
                      //                       se_nwht =
                      //                           contractxModels[index].nwht;

                      //                       print(se_nwht);
                      //                       edit_data_pvat =
                      //                           contractxModels[index]
                      //                               .pvat
                      //                               .toString();
                      //                       edit_data_vtype =
                      //                           contractxModels[index]
                      //                               .vtype
                      //                               .toString();

                      //                       red_Trans_billAll(
                      //                           contractxModels[index]
                      //                               .expname
                      //                               .toString());
                      //                     });
                      //                   },
                      //                   title: Container(
                      //                     decoration: BoxDecoration(
                      //                       // color: Colors.green[100]!
                      //                       //     .withOpacity(0.5),
                      //                       border: Border(
                      //                         bottom: BorderSide(
                      //                           color: Colors.black12,
                      //                           width: 1,
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     // _TransModelsdocno
                      //                     // color: ptype == contractxModels[index].expname
                      //                     //     ? tappedIndex_Color.tappedIndex_Colors
                      //                     //     : null,
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.start,
                      //                       children: [
                      //                         Expanded(
                      //                           child: AutoSizeText(
                      //                               minFontSize: minSize,
                      //                               maxFontSize: maxSize,
                      //                               maxLines: 1,
                      //                               '${contractxModels[index].expname}',
                      //                               textAlign: TextAlign.start,
                      //                               style: TextStyle(
                      //                                   color:
                      //                                       PeopleChaoScreen_Color
                      //                                           .Colors_Text2_,
                      //                                   fontFamily:
                      //                                       Font_.Fonts_T)),
                      //                         ),
                      //                         con_pser ==
                      //                                 contractxModels[index].ser
                      //                             ? Expanded(
                      //                                 child: AutoSizeText(
                      //                                     minFontSize: minSize,
                      //                                     maxFontSize: maxSize,
                      //                                     maxLines: 1,
                      //                                     '${_TransBillModels.map((e) => e.ser_con == con_pser).length}',
                      //                                     textAlign:
                      //                                         TextAlign.end,
                      //                                     style: TextStyle(
                      //                                         color: PeopleChaoScreen_Color
                      //                                             .Colors_Text2_,
                      //                                         fontFamily: Font_
                      //                                             .Fonts_T)),
                      //                               )
                      //                             : SizedBox(),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.width * 0.29,
                            child: Column(
                              children: [
                                Container(
                                  // height: 50,
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.TiTile_Colors,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'รายการตั้งหนี้ : ',
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                2, 2, 2, 0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppbackgroundColor
                                                        .TiTile_Colors
                                                    .withOpacity(0.5),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(6),
                                                    topRight:
                                                        Radius.circular(6),
                                                    bottomLeft:
                                                        Radius.circular(6),
                                                    bottomRight:
                                                        Radius.circular(6)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              width: 220,
                                              height: 35,
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: Text(
                                                    '$Dropdown_expname',
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: ReportScreen_Color
                                                          .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                  items: contractxModels
                                                      .map((item) {
                                                    return DropdownMenuItem(
                                                      value: item.ser,
                                                      //disable default onTap to avoid closing menu when selecting an item
                                                      enabled: false,
                                                      child: StatefulBuilder(
                                                        builder: (context,
                                                            menuSetState) {
                                                          // final isSelected = selectedItems.contains(item);
                                                          return InkWell(
                                                            onTap: () async {
                                                              int index = contractxModels
                                                                  .indexWhere((items) =>
                                                                      items
                                                                          .ser ==
                                                                      item.ser);
                                                              setState(() {
                                                                Dropdown_expname =
                                                                    contractxModels[
                                                                            index]
                                                                        .expname
                                                                        .toString();
                                                                ptype = contractxModels[
                                                                        index]
                                                                    .expname
                                                                    .toString();
                                                                con_pser =
                                                                    contractxModels[
                                                                            index]
                                                                        .ser
                                                                        .toString();
                                                                edit_data = 1;
                                                                edit_data_ser =
                                                                    null;
                                                                edit_data_date =
                                                                    null;
                                                                edit_data_vtype =
                                                                    null;
                                                                edit_data_pvat =
                                                                    null;
                                                                edit_data_nvat =
                                                                    null;
                                                                edit_data_nwht =
                                                                    null;
                                                                edit_data_docno =
                                                                    null;
                                                                edit_data_total =
                                                                    null;

                                                                edit_textall
                                                                        .text =
                                                                    contractxModels[
                                                                            index]
                                                                        .amt
                                                                        .toString();
                                                                edit_texttotal
                                                                        .text =
                                                                    contractxModels[
                                                                            index]
                                                                        .total
                                                                        .toString();
                                                                edit_textvat
                                                                        .text =
                                                                    contractxModels[
                                                                            index]
                                                                        .vat
                                                                        .toString();
                                                                edit_textwht
                                                                        .text =
                                                                    contractxModels[
                                                                            index]
                                                                        .wht
                                                                        .toString();

                                                                se_vser =
                                                                    contractxModels[
                                                                            index]
                                                                        .vser;
                                                                se_vtype =
                                                                    contractxModels[
                                                                            index]
                                                                        .vtype;
                                                                se_wht = null;
                                                                se_nwht =
                                                                    contractxModels[
                                                                            index]
                                                                        .nwht;

                                                                print(se_nwht);
                                                                edit_data_pvat =
                                                                    contractxModels[
                                                                            index]
                                                                        .pvat
                                                                        .toString();
                                                                edit_data_vtype =
                                                                    contractxModels[
                                                                            index]
                                                                        .vtype
                                                                        .toString();
                                                              });
                                                              await red_Trans_billAll(
                                                                  contractxModels[
                                                                          index]
                                                                      .expname
                                                                      .toString());
                                                              Navigator.pop(
                                                                  context);

                                                              menuSetState(
                                                                  () {});
                                                            },
                                                            child: Container(
                                                              height: double
                                                                  .infinity,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      16.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      item.expname!,
                                                                      maxLines:
                                                                          1,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }).toList(),
                                                  //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                                                  // value: selectedItems.isEmpty ? null : selectedItems.last,
                                                  onChanged: (value) {},
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.center,
                                      //   children: [
                                      //     Expanded(
                                      //       child: Container(
                                      //         padding:
                                      //             const EdgeInsets.all(2.0),
                                      //         child: AutoSizeText(
                                      //           minFontSize: 8,
                                      //           maxFontSize: 14,
                                      //           maxLines: 1,
                                      //           'รายการตั้งหนี้',
                                      //           textAlign: TextAlign.center,
                                      //           style: TextStyle(
                                      //               color:
                                      //                   PeopleChaoScreen_Color
                                      //                       .Colors_Text1_,
                                      //               fontWeight: FontWeight.bold,
                                      //               fontFamily:
                                      //                   FontWeight_.Fonts_T
                                      //               //fontSize: 10.0
                                      //               //fontSize: 10.0
                                      //               ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: _TitalContent(),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TransBillListStateful(
                                    items: _TransBillModels,
                                    selectedSer: edit_data_ser,
                                    // -- ส่ง TextEditingController เดิม --
                                    editTextTotal: edit_texttotal,
                                    editTextVat: edit_textvat,
                                    editTextWht: edit_textwht,
                                    editTextAll: edit_textall,
                                    // -- ส่ง setters ที่เดิมคุณ setState กำหนดค่า --
                                    setEditData: (v) =>
                                        setState(() => edit_data = v),
                                    setEditDataSer: (v) =>
                                        setState(() => edit_data_ser = v),
                                    setEditDataDate: (v) =>
                                        setState(() => edit_data_date = v),
                                    setEditDataPvat: (v) =>
                                        setState(() => edit_data_pvat = v),
                                    setEditDataVser: (v) =>
                                        setState(() => se_vser = v),
                                    setEditDataVtype: (v) =>
                                        setState(() => edit_data_vtype = v),
                                    setEditDataNvat: (v) =>
                                        setState(() => edit_data_nvat = v),
                                    setEditDataNwht: (v) =>
                                        setState(() => edit_data_nwht = v),
                                    setEditDataDocno: (v) =>
                                        setState(() => edit_data_docno = v),
                                    setEditDataTotal: (v) =>
                                        setState(() => edit_data_total = v),
                                    // ถ้าอยู่ใน SingleChildScrollView ให้ isNestedScroll: true
                                    isNestedScroll: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 16, 2, 8),
                          child: Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.width * 0.29,
                            child: ListView(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height:
                                                73, // เดิม 63 ให้กะทัดรัดขึ้น
                                            decoration: BoxDecoration(
                                              // ไล่เฉดจากสีเดิม ให้มีมิติขึ้น (ยังอิงสี TiTile_Colors)
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppbackgroundColor
                                                          .TiTile_Colors
                                                      .withOpacity(0.95),
                                                  AppbackgroundColor
                                                      .TiTile_Colors,
                                                ],
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.06),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.black12
                                                    .withOpacity(0.08),
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            child: Builder(
                                              builder: (context) {
                                                // ---------- คงลอจิกเดิมทุกบรรทัด ----------
                                                final bool isAll =
                                                    (ptype == 'ทั้งหมด');
                                                final String title = isAll
                                                    ? (edit_data == 1
                                                        ? ''
                                                        : 'แก้ไขข้อมูล')
                                                    : (edit_data == 1
                                                        ? 'แก้ไขข้อมูลทั้งหมด'
                                                        : 'แก้ไขข้อมูลรายรายการ');
                                                // ----------------------------------------

                                                if (title.isEmpty) {
                                                  // เคสเดิม: Text('') -> ใช้ shrink ให้เนียนกว่า
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                // ไอคอนตามโหมด (แค่เพิ่มความสวยงาม ไม่มีผลลอจิก)
                                                final IconData iconData = isAll
                                                    ? Icons.edit_note_rounded
                                                    : (edit_data == 1
                                                        ? Icons
                                                            .border_color_rounded
                                                        : Icons
                                                            .edit_attributes_rounded);

                                                return Center(
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    switchInCurve:
                                                        Curves.easeOut,
                                                    switchOutCurve:
                                                        Curves.easeIn,
                                                    child: Row(
                                                      key: ValueKey<String>(
                                                          title),
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          height: 28,
                                                          width: 28,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.15),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.20),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            iconData,
                                                            size: 18,
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          title,
                                                          style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            // ขนาดกำลังดีสำหรับ header
                                                            fontSize: 15,
                                                            letterSpacing: 0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: edit_data == 1
                                                ? ptype == 'ทั้งหมด'
                                                    ? SizedBox()
                                                    : _TransBillModels.length ==
                                                            0
                                                        ? SizedBox()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // ลบรายการทั้งหมด (ลิงก์มุมขวาบน)
                                                                // ===== ลิงก์ "ลบรายการทั้งหมด" มุมขวาบน =====
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child: TextButton
                                                                      .icon(
                                                                          style: TextButton
                                                                              .styleFrom(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                            foregroundColor:
                                                                                Colors.red,
                                                                            tapTargetSize:
                                                                                MaterialTapTargetSize.shrinkWrap,
                                                                          ),
                                                                          icon: const Icon(Icons.delete_forever_rounded,
                                                                              size:
                                                                                  18),
                                                                          label:
                                                                              const Text(
                                                                            'ลบรายการทั้งหมด',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              decoration: TextDecoration.underline,
                                                                              fontFamily: Font_.Fonts_T,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await showDialog<String>(
                                                                              context: context,
                                                                              barrierDismissible: true,
                                                                              builder: (BuildContext dialogCtx) {
                                                                                final formKey = GlobalKey<FormState>();
                                                                                bool isLoading = false;

                                                                                return StatefulBuilder(
                                                                                  builder: (ctx, setStateDialog) {
                                                                                    Future<void> _submit() async {
                                                                                      if (isLoading) return;
                                                                                      if (!formKey.currentState!.validate()) return;

                                                                                      setStateDialog(() => isLoading = true);

                                                                                      try {
                                                                                        // == ลอจิกเดิม ==
                                                                                        await de_Trans_item_all();

                                                                                        // อัปเดต state ของหน้าปัจจุบัน (ไม่ใช่ของ dialog)
                                                                                        if (mounted) {
                                                                                          setState(() {
                                                                                            Formposlok_.clear();
                                                                                            edit_data = 1;
                                                                                            edit_data_ser = null;
                                                                                            edit_data_date = null;
                                                                                            edit_data_vtype = null;
                                                                                            edit_data_pvat = null;
                                                                                            edit_data_nvat = null;
                                                                                            edit_data_nwht = null;
                                                                                            edit_data_docno = null;
                                                                                            edit_data_total = null;
                                                                                            edit_textall.clear();
                                                                                            edit_texttotal.clear();
                                                                                            edit_textvat.clear();
                                                                                            edit_textwht.clear();
                                                                                            red_Trans_billAll(ptype);
                                                                                            read_GC_Exp();
                                                                                          });
                                                                                        }

                                                                                        if (Navigator.of(dialogCtx).canPop()) {
                                                                                          Navigator.pop(dialogCtx, 'OK');
                                                                                        }
                                                                                      } catch (e) {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(content: Text('ลบไม่สำเร็จ: $e')),
                                                                                        );
                                                                                      } finally {
                                                                                        if (mounted) setStateDialog(() => isLoading = false);
                                                                                      }
                                                                                    }

                                                                                    return AlertDialog(
                                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                      backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
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
                                                                                              color: Colors.red.withOpacity(0.10),
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                            ),
                                                                                            child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                                                                          ),
                                                                                          const SizedBox(width: 10),
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              'ลบรายการ $ptype ทั้งหมด',
                                                                                              style: const TextStyle(
                                                                                                color: Colors.black87,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                fontSize: 18,
                                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          InkWell(
                                                                                            borderRadius: BorderRadius.circular(20),
                                                                                            onTap: () => Navigator.pop(dialogCtx),
                                                                                            child: const Padding(
                                                                                              padding: EdgeInsets.all(6.0),
                                                                                              child: Icon(
                                                                                                Icons.close,
                                                                                                size: 22,
                                                                                                color: Colors.red,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),

                                                                                      // ---------- Content ----------
                                                                                      content: SingleChildScrollView(
                                                                                        child: Form(
                                                                                          key: formKey,
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                            children: [
                                                                                              // CID chip
                                                                                              Container(
                                                                                                width: double.infinity,
                                                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                                                                                        border: Border.all(color: Colors.blue.withOpacity(0.25)),
                                                                                                      ),
                                                                                                      child: Text(
                                                                                                        '$ptype',
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
                                                                                                        'จำนวน : ${_TransBillModels.length} รายการ',
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
                                                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.red.withOpacity(0.06),
                                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                                  border: Border.all(color: Colors.red.withOpacity(0.18)),
                                                                                                ),
                                                                                                child: Text(
                                                                                                  'ระบุเหตุผลการยกเลิกให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                                                                                                  style: TextStyle(
                                                                                                    color: Colors.red.shade700,
                                                                                                    fontFamily: Font_.Fonts_T,
                                                                                                  ),
                                                                                                ),
                                                                                              ),

                                                                                              const SizedBox(height: 12),

                                                                                              // Reason field
                                                                                              Text(
                                                                                                'ใส่หมายเหตุ',
                                                                                                style: TextStyle(
                                                                                                  color: ManageScreen_Color.Colors_Text2_,
                                                                                                  fontFamily: Font_.Fonts_T,
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(height: 6),
                                                                                              TextFormField(
                                                                                                controller: Formposlok_,
                                                                                                maxLines: 2,
                                                                                                maxLength: 200,
                                                                                                cursorColor: Colors.blueGrey,
                                                                                                validator: (value) => (value == null || value.trim().isEmpty) ? 'ใส่ข้อมูลให้ครบถ้วน' : null,
                                                                                                decoration: InputDecoration(
                                                                                                  hintText: 'ระบุเหตุผลการลบรายการทั้งหมด',
                                                                                                  counterText: '',
                                                                                                  isDense: true,
                                                                                                  filled: true,
                                                                                                  fillColor: Colors.white.withOpacity(0.3),
                                                                                                  labelText: 'หมายเหตุ',
                                                                                                  labelStyle: TextStyle(
                                                                                                    color: ManageScreen_Color.Colors_Text2_,
                                                                                                    fontFamily: Font_.Fonts_T,
                                                                                                  ),
                                                                                                  enabledBorder: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                                                                  ),
                                                                                                  focusedBorder: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                    borderSide: const BorderSide(color: Colors.black, width: 1),
                                                                                                  ),
                                                                                                  errorBorder: OutlineInputBorder(
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                    borderSide: const BorderSide(color: Colors.red, width: 1),
                                                                                                  ),
                                                                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),

                                                                                      // ---------- Actions ----------
                                                                                      actions: [
                                                                                        ValueListenableBuilder<TextEditingValue>(
                                                                                          valueListenable: Formposlok_,
                                                                                          builder: (ctx, value, _) {
                                                                                            final disabled = value.text.trim().isEmpty || isLoading;

                                                                                            return SizedBox(
                                                                                              width: double.infinity,
                                                                                              child: IgnorePointer(
                                                                                                ignoring: disabled,
                                                                                                child: AnimatedOpacity(
                                                                                                  duration: const Duration(milliseconds: 150),
                                                                                                  opacity: disabled ? 0.6 : 1,
                                                                                                  child: ElevatedButton.icon(
                                                                                                    icon: isLoading
                                                                                                        ? const SizedBox(
                                                                                                            height: 18,
                                                                                                            width: 18,
                                                                                                            child: CircularProgressIndicator(
                                                                                                              strokeWidth: 2,
                                                                                                              color: Colors.white,
                                                                                                            ),
                                                                                                          )
                                                                                                        : const Icon(Icons.check_circle_outline),
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                      backgroundColor: Colors.black,
                                                                                                      minimumSize: const Size.fromHeight(44),
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                      ),
                                                                                                    ),
                                                                                                    onPressed: _submit,
                                                                                                    label: const Text(
                                                                                                      'ยืนยัน',
                                                                                                      style: TextStyle(
                                                                                                        color: Colors.white,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        fontFamily: FontWeight_.Fonts_T,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                            );
                                                                          }),
                                                                ),

                                                                const SizedBox(
                                                                    height: 6),

                                                                // ===== หัวข้อรายการ (Chip แสดงประเภท) =====
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'รายการ : ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .blue
                                                                            .shade700,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              4),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .blue
                                                                            .withOpacity(0.08),
                                                                        borderRadius:
                                                                            BorderRadius.circular(999),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.blue.withOpacity(0.20)),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        ptype,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontFamily:
                                                                              FontWeight_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                // ===== หัวข้อ "แก้ไขราคาทั้งหมด" =====
                                                                const SizedBox(
                                                                    height: 6),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: const [
                                                                    Icon(
                                                                        Icons
                                                                            .price_change_outlined,
                                                                        size:
                                                                            18,
                                                                        color: Colors
                                                                            .black54),
                                                                    SizedBox(
                                                                        width:
                                                                            6),
                                                                    Text(
                                                                      'แก้ไขราคาทั้งหมด',
                                                                      style:
                                                                          TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                const SizedBox(
                                                                    height: 6),
                                                                // ===== แก้ไขราคาทั้งหมด =====
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          TextFormField(
                                                                        keyboardType:
                                                                            const TextInputType.numberWithOptions(decimal: true),
                                                                        controller:
                                                                            edit_textall,
                                                                        onFieldSubmitted:
                                                                            (val) =>
                                                                                print(edit_textall.text), // ✅ เดิม
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontFamily:
                                                                                Font_.Fonts_T),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          filled:
                                                                              true,
                                                                          fillColor: Colors
                                                                              .white
                                                                              .withOpacity(0.3),
                                                                          prefixIcon: const Icon(
                                                                              Icons.calculate_outlined,
                                                                              size: 18,
                                                                              color: Colors.black54),
                                                                          suffixText:
                                                                              'บาท',
                                                                          suffixStyle: const TextStyle(
                                                                              fontFamily: Font_.Fonts_T,
                                                                              color: Colors.black54),
                                                                          hintText:
                                                                              'กรอกราคาใหม่สำหรับทั้งหมด',
                                                                          hintStyle: const TextStyle(
                                                                              color: Colors.black45,
                                                                              fontFamily: Font_.Fonts_T,
                                                                              fontSize: 13),
                                                                          contentPadding: const EdgeInsets.symmetric(
                                                                              horizontal: 12,
                                                                              vertical: 10),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            borderSide:
                                                                                const BorderSide(color: Colors.grey, width: 1),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            borderSide:
                                                                                const BorderSide(color: Colors.black, width: 1),
                                                                          ),
                                                                          labelStyle: const TextStyle(
                                                                              color: Colors.black54,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                        inputFormatters: <TextInputFormatter>[
                                                                          // ✅ คงเดิม (อนุญาตตัวเลข/จุด/เว้นวรรค)
                                                                          FilteringTextInputFormatter.allow(
                                                                              RegExp(r'[0-9 .]')),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                const SizedBox(
                                                                    height: 10),

// ===== แก้ไข VAT % ทั้งหมด =====
                                                                const Text(
                                                                  'แก้ไข VAT % ทั้งหมด',
                                                                  style:
                                                                      TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          DropdownButtonFormField2(
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding:
                                                                              EdgeInsets.zero,
                                                                          prefixIcon:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 10, right: 6),
                                                                            child: Icon(Icons.receipt_long_outlined,
                                                                                size: 18,
                                                                                color: Colors.black54),
                                                                          ),
                                                                          prefixIconConstraints: const BoxConstraints(
                                                                              minWidth: 0,
                                                                              minHeight: 0),
                                                                          border:
                                                                              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                                        ),
                                                                        isExpanded:
                                                                            true,
                                                                        hint:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: AutoSizeText(
                                                                                '$se_vtype',
                                                                                minFontSize: 5,
                                                                                maxFontSize: 14,
                                                                                maxLines: 1,
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(
                                                                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                  fontFamily: Font_.Fonts_T,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .arrow_drop_down,
                                                                            color:
                                                                                Colors.black45),
                                                                        iconSize:
                                                                            20,
                                                                        buttonHeight:
                                                                            44,
                                                                        buttonPadding:
                                                                            const EdgeInsets.only(right: 6),
                                                                        dropdownDecoration:
                                                                            BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                        items: vatSeModels
                                                                            .map((item) => DropdownMenuItem<String>(
                                                                                  value: '${item.ser}:${item.vtype}',
                                                                                  child: AutoSizeText(
                                                                                    item.vtype!,
                                                                                    minFontSize: 5,
                                                                                    maxFontSize: 14,
                                                                                    maxLines: 1,
                                                                                    textAlign: TextAlign.end,
                                                                                    style: const TextStyle(
                                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                    ),
                                                                                  ),
                                                                                ))
                                                                            .toList(),
                                                                        onChanged:
                                                                            (value) async {
                                                                          final zones =
                                                                              value!.indexOf(':');
                                                                          final vat_ser = value.substring(
                                                                              0,
                                                                              zones);
                                                                          final vat_name =
                                                                              value.substring(zones + 1);
                                                                          // ignore: avoid_print
                                                                          print(
                                                                              'mmmmm $vat_ser $vat_name');
                                                                          setState(
                                                                              () {
                                                                            se_vser =
                                                                                vat_ser;
                                                                            se_vtype =
                                                                                vat_name;
                                                                          });
                                                                        },
                                                                        onSaved:
                                                                            (value) {},
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                const SizedBox(
                                                                    height: 10),

// ===== แก้ไข WHT % ทั้งหมด =====
                                                                const Text(
                                                                  'แก้ไข WHT % ทั้งหมด',
                                                                  style:
                                                                      TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 6),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          DropdownButtonFormField2(
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding:
                                                                              EdgeInsets.zero,
                                                                          prefixIcon:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 10, right: 6),
                                                                            child: Icon(Icons.percent_rounded,
                                                                                size: 18,
                                                                                color: Colors.black54),
                                                                          ),
                                                                          prefixIconConstraints: const BoxConstraints(
                                                                              minWidth: 0,
                                                                              minHeight: 0),
                                                                          border:
                                                                              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                                        ),
                                                                        isExpanded:
                                                                            true,
                                                                        hint:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: AutoSizeText(
                                                                                se_nwht == '0.00' ? 'ไม่มี' : 'หัก ${whtModels.indexWhere((item) => item.pct == se_nwht.toString())}%',
                                                                                // 👆 คงลอจิกการแสดงผลเดิม (ตามโค้ดคุณ)
                                                                                minFontSize: 5,
                                                                                maxFontSize: 14,
                                                                                maxLines: 1,
                                                                                textAlign: TextAlign.end,
                                                                                style: const TextStyle(
                                                                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                  fontFamily: Font_.Fonts_T,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .arrow_drop_down,
                                                                            color:
                                                                                Colors.black45),
                                                                        iconSize:
                                                                            20,
                                                                        buttonHeight:
                                                                            44,
                                                                        buttonPadding:
                                                                            const EdgeInsets.only(right: 6),
                                                                        dropdownDecoration:
                                                                            BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                                        items: whtModels
                                                                            .map((item) => DropdownMenuItem<String>(
                                                                                  value: '${item.ser}:${item.pct}',
                                                                                  child: AutoSizeText(
                                                                                    item.wht!,
                                                                                    minFontSize: 5,
                                                                                    maxFontSize: 14,
                                                                                    maxLines: 1,
                                                                                    textAlign: TextAlign.end,
                                                                                    style: const TextStyle(
                                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                      fontFamily: Font_.Fonts_T,
                                                                                    ),
                                                                                  ),
                                                                                ))
                                                                            .toList(),
                                                                        onChanged:
                                                                            (value) async {
                                                                          final zones =
                                                                              value!.indexOf(':');
                                                                          final vat_ser = value.substring(
                                                                              0,
                                                                              zones);
                                                                          final vat_name =
                                                                              value.substring(zones + 1);
                                                                          // ignore: avoid_print
                                                                          print(
                                                                              'mmmmm $vat_ser $vat_name');
                                                                          setState(
                                                                              () {
                                                                            se_wht =
                                                                                vat_ser;
                                                                            se_nwht =
                                                                                vat_name;
                                                                          });
                                                                        },
                                                                        onSaved:
                                                                            (value) {},
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                const SizedBox(
                                                                    height: 16),

                                                                // ปุ่มคำนวณ & บันทึก (ใหญ่ เต็มแถว)
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .blue,
                                                                      minimumSize:
                                                                          const Size.fromHeight(
                                                                              44),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10)),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      // 1) เปิด Loader (เหมือนเดิม)
                                                                      ChaoAppLoader
                                                                          .show(
                                                                        asset:
                                                                            'images/LOGO.png', // หรือ .gif ก็ได้
                                                                        assetFromPackage:
                                                                            false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                                                        useCard:
                                                                            false,
                                                                        dimBackground:
                                                                            true,
                                                                        dismissible:
                                                                            true,
                                                                        message:
                                                                            'กำลังโหลด...',
                                                                        messageStyle:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                          fontFamily:
                                                                              FontWeight_.Fonts_T,
                                                                        ),
                                                                        slideAcross:
                                                                            false,
                                                                        vSlideAcross:
                                                                            false,
                                                                        motion:
                                                                            Motion.pingPong,
                                                                        rangeMinAt:
                                                                            0.48,
                                                                        rangeMaxAt:
                                                                            0.52,
                                                                        slideMs:
                                                                            1800,
                                                                        verticalFactor:
                                                                            0.5,
                                                                        size:
                                                                            150,
                                                                      );
                                                                      try {
                                                                        SharedPreferences
                                                                            preferences =
                                                                            await SharedPreferences.getInstance();
                                                                        var ren =
                                                                            preferences.getString('renTalSer');
                                                                        var user =
                                                                            preferences.getString('ser');
                                                                        Insert_log.Insert_logs(
                                                                            'ผู้เช่า',
                                                                            '${widget.Get_Value_cid}>แก้ไขข้อมูลทั้งหมดรายการ$ptype');

                                                                        var s_con_pser =
                                                                            con_pser;
                                                                        var s_textall =
                                                                            double.parse(edit_textall.text);
                                                                        var s_se_vser =
                                                                            se_vser;
                                                                        var s_se_vtype =
                                                                            se_vtype;
                                                                        var s_se_nwht =
                                                                            se_nwht;
                                                                        var s_serse_wht = se_wht ==
                                                                                null
                                                                            ? '1'
                                                                            : se_wht;
                                                                        var ciddoc =
                                                                            widget.Get_Value_cid;

                                                                        String
                                                                            url =
                                                                            '${MyConstant().domain}/UP_tran_Edit_all_new.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&s_con_pser=$s_con_pser&s_textall=$s_textall&s_se_vser=$s_se_vser&s_se_vtype=$s_se_vtype&s_se_nwht=$s_se_nwht&s_serse_wht=$s_serse_wht';

                                                                        var response =
                                                                            await httpClient.get(Uri.parse(url));
                                                                        var result =
                                                                            json.decode(response.body);
                                                                        if (result.toString() ==
                                                                            'true') {
                                                                          setState(() =>
                                                                              red_Trans_billAll(ptype));
                                                                          // Timer(
                                                                          //     const Duration(seconds: 2),
                                                                          //     () => Navigator.of(context).pop());
                                                                        }
                                                                      } catch (e) {
                                                                      } finally {
                                                                        // 7) ปิด Loader ให้ชัวร์ที่เดียว
                                                                        ChaoAppLoader
                                                                            .hide();
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                        'คำนวณ&บันทึก',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                : edit_data_ser == null
                                                    ? Text('')
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(
                                                                height: 8),
                                                            Center(
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                        maxWidth:
                                                                            420), // 👈 รีไซซ์สวยทั้งจอเล็ก/ใหญ่
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(16),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black12
                                                                            .withOpacity(0.05)),
                                                                    // boxShadow: [
                                                                    //   BoxShadow(
                                                                    //     color: Colors
                                                                    //         .black
                                                                    //         .withOpacity(0.04),
                                                                    //     blurRadius:
                                                                    //         10,
                                                                    //     offset: const Offset(
                                                                    //         0,
                                                                    //         4),
                                                                    //   ),
                                                                    // ],
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      // ---------- หัวการ์ด ----------
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                32,
                                                                            width:
                                                                                32,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.blue.withOpacity(0.10),
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            child:
                                                                                const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                                                                          ),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Expanded(
                                                                            child:
                                                                                AutoSizeText(
                                                                              'เลขตั้งหนี้ $edit_data_docno',
                                                                              minFontSize: minSize,
                                                                              maxFontSize: maxSize,
                                                                              maxLines: 1,
                                                                              style: const TextStyle(
                                                                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                fontFamily: Font_.Fonts_T,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              // ==== Dialog ลบ "รายรายการ" (ลอจิกเดิม) ====
                                                                              await showDialog<String>(
                                                                                context: context,
                                                                                barrierDismissible: true,
                                                                                builder: (BuildContext dialogCtx) {
                                                                                  final formKey = GlobalKey<FormState>();
                                                                                  bool isLoading = false;
                                                                                  return StatefulBuilder(
                                                                                    builder: (ctx, setStateDialog) {
                                                                                      Future<void> _submit() async {
                                                                                        if (isLoading) return;
                                                                                        if (!formKey.currentState!.validate()) return;
                                                                                        setStateDialog(() => isLoading = true);
                                                                                        try {
                                                                                          await de_Trans_item(); // ✅ ลอจิกเดิม

                                                                                          if (mounted) {
                                                                                            setState(() {
                                                                                              Formposlok_.clear();
                                                                                              edit_data = 1;
                                                                                              edit_data_ser = null;
                                                                                              edit_data_date = null;
                                                                                              edit_data_vtype = null;
                                                                                              edit_data_pvat = null;
                                                                                              edit_data_nvat = null;
                                                                                              edit_data_nwht = null;
                                                                                              edit_data_docno = null;
                                                                                              edit_data_total = null;
                                                                                              edit_textall.clear();
                                                                                              edit_texttotal.clear();
                                                                                              edit_textvat.clear();
                                                                                              edit_textwht.clear();
                                                                                              red_Trans_billAll(ptype);
                                                                                              read_GC_Exp();
                                                                                            });
                                                                                          }
                                                                                          if (Navigator.of(dialogCtx).canPop()) {
                                                                                            Navigator.pop(dialogCtx, 'OK');
                                                                                          }
                                                                                        } catch (e) {
                                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                                            SnackBar(content: Text('ลบไม่สำเร็จ: $e')),
                                                                                          );
                                                                                        } finally {
                                                                                          if (mounted) setStateDialog(() => isLoading = false);
                                                                                        }
                                                                                      }

                                                                                      return AlertDialog(
                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                        backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                                                                                        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                                                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                                                                        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                                                        title: Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              height: 36,
                                                                                              width: 36,
                                                                                              decoration: BoxDecoration(
                                                                                                color: Colors.red.withOpacity(0.10),
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                                                                            ),
                                                                                            const SizedBox(width: 10),
                                                                                            const Expanded(
                                                                                              child: Text(
                                                                                                'ลบรายการ',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black87,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  fontSize: 18,
                                                                                                  fontFamily: FontWeight_.Fonts_T,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            InkWell(
                                                                                              borderRadius: BorderRadius.circular(20),
                                                                                              onTap: () => Navigator.pop(dialogCtx),
                                                                                              child: const Padding(
                                                                                                padding: EdgeInsets.all(6.0),
                                                                                                child: Icon(Icons.close, size: 22, color: Colors.red),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        content: SingleChildScrollView(
                                                                                          child: Form(
                                                                                            key: formKey,
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                              children: [
                                                                                                // chip แสดง docno
                                                                                                Container(
                                                                                                  width: double.infinity,
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                                                                                          border: Border.all(color: Colors.blue.withOpacity(0.25)),
                                                                                                        ),
                                                                                                        child: Text(
                                                                                                          '$ptype',
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
                                                                                                          'รายการตั้งหนี้ : $edit_data_docno',
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
                                                                                                // คำเตือน
                                                                                                Container(
                                                                                                  width: double.infinity,
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.red.withOpacity(0.06),
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                    border: Border.all(color: Colors.red.withOpacity(0.18)),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    'ระบุเหตุผลการยกเลิกให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.red.shade700,
                                                                                                      fontFamily: Font_.Fonts_T,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 12),
                                                                                                // หมายเหตุ
                                                                                                Text(
                                                                                                  'ใส่หมายเหตุ',
                                                                                                  style: TextStyle(
                                                                                                    color: ManageScreen_Color.Colors_Text2_,
                                                                                                    fontFamily: Font_.Fonts_T,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 6),
                                                                                                TextFormField(
                                                                                                  controller: Formposlok_,
                                                                                                  maxLines: 2,
                                                                                                  maxLength: 200,
                                                                                                  cursorColor: Colors.blueGrey,
                                                                                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'ใส่ข้อมูลให้ครบถ้วน' : null,
                                                                                                  decoration: InputDecoration(
                                                                                                    hintText: 'ระบุเหตุผลการลบรายการ',
                                                                                                    counterText: '',
                                                                                                    isDense: true,
                                                                                                    filled: true,
                                                                                                    fillColor: Colors.white.withOpacity(0.3),
                                                                                                    labelText: 'หมายเหตุ',
                                                                                                    labelStyle: TextStyle(
                                                                                                      color: ManageScreen_Color.Colors_Text2_,
                                                                                                      fontFamily: Font_.Fonts_T,
                                                                                                    ),
                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                                                                    ),
                                                                                                    focusedBorder: OutlineInputBorder(
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                      borderSide: const BorderSide(color: Colors.black, width: 1),
                                                                                                    ),
                                                                                                    errorBorder: OutlineInputBorder(
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                      borderSide: const BorderSide(color: Colors.red, width: 1),
                                                                                                    ),
                                                                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        actions: [
                                                                                          ValueListenableBuilder<TextEditingValue>(
                                                                                            valueListenable: Formposlok_,
                                                                                            builder: (ctx, value, _) {
                                                                                              final disabled = value.text.trim().isEmpty || isLoading;
                                                                                              return SizedBox(
                                                                                                width: double.infinity,
                                                                                                child: IgnorePointer(
                                                                                                  ignoring: disabled,
                                                                                                  child: AnimatedOpacity(
                                                                                                    duration: const Duration(milliseconds: 150),
                                                                                                    opacity: disabled ? 0.6 : 1,
                                                                                                    child: ElevatedButton.icon(
                                                                                                      icon: isLoading
                                                                                                          ? const SizedBox(
                                                                                                              height: 18,
                                                                                                              width: 18,
                                                                                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                                                                            )
                                                                                                          : const Icon(Icons.check_circle_outline),
                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                        backgroundColor: Colors.black,
                                                                                                        minimumSize: const Size.fromHeight(44),
                                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                      ),
                                                                                                      onPressed: _submit,
                                                                                                      label: const Text(
                                                                                                        'ยืนยัน',
                                                                                                        style: TextStyle(
                                                                                                          color: Colors.white,
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                          fontFamily: FontWeight_.Fonts_T,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                            child:
                                                                                const Icon(Icons.delete_outline, color: Colors.red),
                                                                          ),
                                                                        ],
                                                                      ),

                                                                      const Divider(
                                                                          height:
                                                                              20),

                                                                      // ---------- กำหนดชำระ ----------
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 4.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Text('กำหนดชำระ ',
                                                                                style: TextStyle(fontSize: 16)),
                                                                            const SizedBox(width: 6),
                                                                            Expanded(
                                                                              child: InkWell(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                                onTap: () async {
                                                                                  DateTime? newDate = await showDatePicker(
                                                                                    locale: const Locale('th', 'TH'),
                                                                                    context: context,
                                                                                    initialDate: DateTime.parse('$edit_data_date 00:00:00'),
                                                                                    firstDate: DateTime(1000, 1, 01),
                                                                                    lastDate: DateTime.parse('$edit_data_date 00:00:00').add(const Duration(days: 365)),
                                                                                    builder: (context, child) {
                                                                                      return Theme(
                                                                                        data: Theme.of(context).copyWith(
                                                                                          colorScheme: const ColorScheme.light(
                                                                                            primary: AppBarColors.ABar_Colors,
                                                                                            onPrimary: Colors.white,
                                                                                            onSurface: Colors.black,
                                                                                          ),
                                                                                          textButtonTheme: TextButtonThemeData(
                                                                                            style: TextButton.styleFrom(foregroundColor: Colors.black),
                                                                                          ),
                                                                                        ),
                                                                                        child: child!,
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                  if (newDate == null) return;

                                                                                  final start = DateFormat('yyyy-MM-dd').format(newDate);
                                                                                  // final endThai = DateFormat('dd-MM-yyy').format(newDate); // 👈 ถ้าอยากแสดงไทยแบบเดิม

                                                                                  showDialog<void>(
                                                                                    context: context,
                                                                                    barrierDismissible: false,
                                                                                    builder: (_) => const AlertDialog(
                                                                                      backgroundColor: Colors.transparent,
                                                                                      content: SizedBox(height: 150, child: CircularProgressIndicator()),
                                                                                    ),
                                                                                  );

                                                                                  try {
                                                                                    final prefs = await SharedPreferences.getInstance();
                                                                                    final ren = prefs.getString('renTalSer');
                                                                                    final serconx = edit_data_ser;

                                                                                    final url = '${MyConstant().domain}/UP_tran_Edit_all_date.php?isAdd=true&ren=$ren&serconx=$serconx&start=$start';
                                                                                    final res = await httpClient.get(Uri.parse(url));
                                                                                    final result = json.decode(res.body);
                                                                                    if (result.toString() == 'true') {
                                                                                      setState(() {
                                                                                        edit_data_date = start;
                                                                                        red_Trans_billAll(ptype);
                                                                                      });
                                                                                    }
                                                                                  } catch (_) {}
                                                                                  Navigator.of(context).pop(); // ปิด loading
                                                                                },
                                                                                child: Container(
                                                                                  height: 38,
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    border: Border.all(color: Colors.grey, width: 1),
                                                                                  ),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      const Icon(Icons.event_note_outlined, size: 18, color: Colors.black54),
                                                                                      const SizedBox(width: 8),
                                                                                      Expanded(
                                                                                        child: AutoSizeText(
                                                                                          (edit_data_date == null) ? '' : '${DateFormat('dd-MM-yyy').format(DateTime.parse('$edit_data_date 00:00:00'))}',
                                                                                          minFontSize: minSize,
                                                                                          maxFontSize: maxSize,
                                                                                          maxLines: 1,
                                                                                          style: const TextStyle(
                                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                            fontFamily: Font_.Fonts_T,
                                                                                          ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ),
                                                                                      const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black45),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),

                                                                      const SizedBox(
                                                                          height:
                                                                              12),

                                                                      // ---------- ราคา ----------
                                                                      TextField(
                                                                        controller:
                                                                            edit_texttotal,
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        keyboardType:
                                                                            const TextInputType.numberWithOptions(decimal: true),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          prefixText:
                                                                              'ราคา ',
                                                                          suffixText:
                                                                              'บาท',
                                                                          border:
                                                                              const OutlineInputBorder(),
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: const EdgeInsets.symmetric(
                                                                              horizontal: 12,
                                                                              vertical: 10),
                                                                        ),
                                                                        inputFormatters: <TextInputFormatter>[
                                                                          FilteringTextInputFormatter.allow(
                                                                              RegExp(r'[0-9 .]')),
                                                                        ],
                                                                      ),

                                                                      const SizedBox(
                                                                          height:
                                                                              12),

                                                                      // ---------- VAT & WHT ----------
                                                                      _buildPercentageRow(
                                                                          'VAT',
                                                                          'ภาษีมูลค่าเพิ่ม (VAT)',
                                                                          edit_textvat),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      _buildPercentageRow(
                                                                          'WHT',
                                                                          'หักภาษี ณ ที่จ่าย',
                                                                          edit_textwht),

                                                                      const SizedBox(
                                                                          height:
                                                                              16),

                                                                      // ---------- ปุ่มบันทึก ----------
                                                                      SizedBox(
                                                                        width: double
                                                                            .infinity,
                                                                        child:
                                                                            ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.green,
                                                                            minimumSize:
                                                                                const Size.fromHeight(46),
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            // โชว์โหลดครั้งเดียว
                                                                            ChaoAppLoader.show(
                                                                              asset: 'images/LOGO.png', // หรือ .gif ก็ได้
                                                                              assetFromPackage: false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                                                              useCard: false,
                                                                              dimBackground: true,
                                                                              dismissible: true,
                                                                              message: 'กำลังโหลด...',
                                                                              messageStyle: const TextStyle(
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Colors.black,
                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                              ),
                                                                              // ปิดการวิ่งทั้งหมดให้เป็น static ในกรณีโหลดสั้น ๆ
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
                                                                              // 1) เตรียมค่า (อ่าน prefs แบบขนานให้ไวขึ้น)
                                                                              final prefs = await SharedPreferences.getInstance();
                                                                              final ren = prefs.getString('renTalSer');
                                                                              final user = prefs.getString('ser');

                                                                              // ป้องกัน null ก่อนใช้งาน
                                                                              if (ren == null || user == null) {
                                                                                throw Exception('ไม่พบข้อมูลผู้ใช้/เรนทัลในเครื่อง');
                                                                              }

                                                                              // 2) แปลงค่าอินพุตให้ปลอดภัย
                                                                              final s_con_pser = con_pser; // สมมติว่าเป็น int/num อยู่แล้ว
                                                                              final s_textall = edit_texttotal.text.trim().isEmpty ? 0.0 : (double.tryParse(edit_texttotal.text.trim()) ?? 0.0);
                                                                              final s_se_vser = se_vser;
                                                                              final s_se_vtype = se_vtype;
                                                                              final s_se_nwht = se_nwht;
                                                                              final s_serse_wht = (se_wht == null ? '1' : se_wht);
                                                                              final ciddoc = widget.Get_Value_cid;

                                                                              // log การทำงาน
                                                                              Insert_log.Insert_logs('ผู้เช่า', '$user>สัญญา$ciddoc>ปรับตั้งหนี้$edit_data_docno');

                                                                              // 3) ยิง API (กำหนด timeout และตรวจ response)
                                                                              final url = Uri.parse('${MyConstant().domain}/UP_tran_Edit_exp_new.php?isAdd=true&ren=$ren');

                                                                              final body = {
                                                                                'ciddoc': ciddoc.toString(),
                                                                                's_con_pser': s_con_pser.toString(),
                                                                                's_textall': s_textall.toString(),
                                                                                's_se_vser': s_se_vser.toString(),
                                                                                's_se_vtype': s_se_vtype.toString(),
                                                                                's_se_nwht': s_se_nwht.toString(),
                                                                                's_serse_wht': s_serse_wht.toString(),
                                                                                'pct_vat': (edit_textvat.text.trim().isEmpty ? '0' : edit_textvat.text.trim()),
                                                                                'pct_wht': (edit_textwht.text.trim().isEmpty ? '0' : edit_textwht.text.trim()),
                                                                                'serconx': edit_data_ser.toString(),
                                                                              };

                                                                              // ถ้าต้องส่งเป็น form-urlencoded ตามเดิมก็พอแล้ว
                                                                              final res = await httpClient.post(url, body: body).timeout(const Duration(seconds: 20));

                                                                              if (res.statusCode != 200) {
                                                                                throw Exception('HTTP ${res.statusCode}');
                                                                              }

                                                                              final dynamic result = json.decode(res.body);

                                                                              if (!mounted)
                                                                                return;

                                                                              // TODO: เช็คโครงสร้าง result ตามฟอร์แมตจริง เช่น result['success'] == true
                                                                              // ถ้า API ส่งสถานะล้มเหลวกรณีเชิงธุรกิจ ให้โยน error ที่อ่านง่าย
                                                                              // if (result is Map && result['success'] != true) {
                                                                              //   throw Exception(result['message'] ?? 'บันทึกไม่สำเร็จ');
                                                                              // }

                                                                              // 4) รีเฟรชรายการ (ลอจิกเดิม)
                                                                              await red_Trans_billAll(ptype.toString());

                                                                              if (!mounted)
                                                                                return;

                                                                              // แจ้งเตือนสำเร็จแบบสั้น ๆ
                                                                              Dialog_success(context, 'บันทึกสำเร็จ');
                                                                              // showSuccessDialog(context: context);
                                                                              // ScaffoldMessenger.of(context).showSnackBar(
                                                                              //   const SnackBar(content: Text('บันทึกสำเร็จ')),
                                                                              // );
                                                                            } on TimeoutException {
                                                                              if (mounted) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(content: Text('เชื่อมต่อช้าเกินไป (Timeout)')),
                                                                                );
                                                                              }
                                                                            } catch (e) {
                                                                              if (mounted) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                                                                                );
                                                                              }
                                                                            } finally {
                                                                              // ✅ ซ่อน loader ที่เดียวให้ชัวร์ (เลิกใช้ Future.delayed ปิดเอง)
                                                                              ChaoAppLoader.hide();
                                                                              // ❌ หลีกเลี่ยงการซ่อน AppLoader ตัวอื่นซ้ำซ้อน
                                                                              // AppLoader.hide(); // ลบออก ถ้าไม่ได้โชว์ตัวนี้ไว้
                                                                            }
                                                                          },
                                                                          child: const Text(
                                                                              'คำนวณ&บันทึก',
                                                                              style: TextStyle(fontSize: 16)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))
        ]));
  }

  Future<Null> de_Trans_item() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = edit_data_ser;
    var tdocno = edit_data_docno;
    var poslok = Formposlok_.text;
    Insert_log.Insert_logs('ผู้เช่า', '$user>สัญญา${ciddoc}>ลบตั้งหนี้$tdocno');
    // print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_edit_item.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user&poslok=$poslok';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result['status'].toString() == 'true') {
        setState(() {
          Formposlok_.clear();
          edit_data = 1;
          edit_data_ser = null;
          edit_data_date = null;
          edit_data_vtype = null;
          edit_data_nvat = null;
          edit_data_nwht = null;
          edit_data_docno = null;
          edit_data_total = null;
          edit_textall.clear();
          edit_textvat.clear();
          edit_textwht.clear();
          red_Trans_billAll(ptype);
          Navigator.pop(context);
        });
        print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> de_Trans_item_all() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    // for (var i = 0; i < _TransBillModels.length; i++) {
    var tser = con_pser;
    // var tdocno = _TransBillModels[i].docno;
    // var poslok = Formposlok_.text;

    print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_edit_item_all.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&user=$user';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
    // }
  }

  Future<Null> de_cons_item() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var con_pserx = con_pser;
    var poslok = Formposlok_.text;

    print('tser >>.> $con_pserx');

    String url =
        '${MyConstant().domain}/De_tran_edit_item_main.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&con_pserx=$con_pserx&user=$user&poslok=$poslok';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          Formposlok_.clear();
          edit_data = 0;
          edit_data_ser = null;
          edit_data_date = null;
          edit_data_vtype = null;
          edit_data_nvat = null;
          edit_data_nwht = null;
          edit_data_docno = null;
          edit_data_total = null;
          edit_textall.clear();
          edit_textvat.clear();
          edit_textwht.clear();
          read_GC_Exp();
          Navigator.pop(context);
          Navigator.pop(context);
        });
        // SharedPreferences preferences = await SharedPreferences.getInstance();
        // String? _route = preferences.getString('route');
        // MaterialPageRoute materialPageRoute = MaterialPageRoute(
        //     builder: (BuildContext context) => AdminScafScreen(route: _route));
        // Navigator.pushAndRemoveUntil(
        //     context, materialPageRoute, (route) => false);
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }
}

/// Stateful + เดิมลอจิกเดิม ๆ (ไม่เปลี่ยนลำดับ/ค่าที่ set)
/// -----------------------------------------------------
/// ใช้แทน ListView.builder เดิม โดยยังคง onTap/setState เดิมไว้
/// เพียงย้ายมากำหนดผ่าน callback setters เพื่อคง business logic เดิมเป๊ะ ๆ
///
/// วิธีใช้ (ตัวอย่าง):
///
/// TransBillListStateful(
///   items: _TransBillModels,
///   selectedSer: edit_data_ser,
///   // -- ส่ง TextEditingController เดิม --
///   editTextTotal: edit_texttotal,
///   editTextVat: edit_textvat,
///   editTextWht: edit_textwht,
///   editTextAll: edit_textall,
///   // -- ส่ง setters ที่เดิมคุณ setState กำหนดค่า --
///   setEditData: (v) => setState(() => edit_data = v),
///   setEditDataSer: (v) => setState(() => edit_data_ser = v),
///   setEditDataDate: (v) => setState(() => edit_data_date = v),
///   setEditDataPvat: (v) => setState(() => edit_data_pvat = v),
///   setEditDataVtype: (v) => setState(() => edit_data_vtype = v),
///   setEditDataNvat: (v) => setState(() => edit_data_nvat = v),
///   setEditDataNwht: (v) => setState(() => edit_data_nwht = v),
///   setEditDataDocno: (v) => setState(() => edit_data_docno = v),
///   setEditDataTotal: (v) => setState(() => edit_data_total = v),
///   // ถ้าอยู่ใน SingleChildScrollView ให้ isNestedScroll: true
///   isNestedScroll: true,
/// )
///
/// หมายเหตุ: ลอจิกเดิมยังอยู่ครบใน onTap (ลำดับการเซ็ตค่าทุกตัวเหมือนเดิม)
class TransBillListStateful extends StatefulWidget {
  const TransBillListStateful({
    super.key,
    required this.items,
    required this.setEditData,
    required this.setEditDataSer,
    required this.setEditDataDate,
    required this.setEditDataPvat,
    required this.setEditDataVser,
    required this.setEditDataVtype,
    required this.setEditDataNvat,
    required this.setEditDataNwht,
    required this.setEditDataDocno,
    required this.setEditDataTotal,
    required this.editTextTotal,
    required this.editTextVat,
    required this.editTextWht,
    required this.editTextAll,
    this.selectedSer,
    this.isNestedScroll = false,
    this.controller,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.cardRadius = 14,
    this.sizeScale = 0.85, // 👈 0.85 = เล็กลง 15%
  });

  final List<dynamic> items;
  final String? selectedSer;
  final bool isNestedScroll;
  final ScrollController? controller;

  // TextEditingControllers เดิม
  final TextEditingController editTextTotal;
  final TextEditingController editTextVat;
  final TextEditingController editTextWht;
  final TextEditingController editTextAll;

  // setters ลอจิกเดิม (setState ภายนอก)
  final ValueChanged<int> setEditData;
  final ValueChanged<String> setEditDataSer;
  final ValueChanged<String> setEditDataDate;
  final ValueChanged<String> setEditDataPvat;
  final ValueChanged<String> setEditDataVser;
  final ValueChanged<String> setEditDataVtype;
  final ValueChanged<String> setEditDataNvat;
  final ValueChanged<String> setEditDataNwht;
  final ValueChanged<String> setEditDataDocno;
  final ValueChanged<String> setEditDataTotal;

  // UI tuning
  final EdgeInsets itemPadding;
  final double cardRadius;
  final double sizeScale; // 0.7 - 1.0 แนะนำ

  @override
  State<TransBillListStateful> createState() => _TransBillListStatefulState();
}

class _TransBillListStatefulState extends State<TransBillListStateful> {
  late String? _selectedSer;
  static final NumberFormat _money = NumberFormat('#,##0.00', 'th_TH');

  @override
  void initState() {
    super.initState();
    _selectedSer = widget.selectedSer;
  }

  @override
  void didUpdateWidget(covariant TransBillListStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSer != widget.selectedSer) {
      _selectedSer = widget.selectedSer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.isNestedScroll
        ? const NeverScrollableScrollPhysics()
        : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return ListView.separated(
      controller: widget.controller,
      physics: physics,
      shrinkWrap: widget.isNestedScroll,
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => SizedBox(height: 8 * widget.sizeScale),
      padding: EdgeInsets.all(12 * widget.sizeScale),
      itemBuilder: (context, index) {
        final m = widget.items[index];

        // ดึงค่าแบบปลอดภัย (รองรับ Map / model / model.toJson())
        final ser = _getString(m, 'ser');
        final docno = _getString(m, 'docno');
        final date = _getString(m, 'date');
        final pvat = _getString(m, 'pvat');
        final vser = _getString(m, 'vser');
        final vtype = _getString(m, 'vtype');
        final nvat = _getString(m, 'nvat');
        final nwht = _getString(m, 'nwht');
        final wht = _getString(m, 'wht');
        final total = _getString(m, 'total');
        final expname = _getString(m, 'expname');
        final descr = _getString(m, 'descr');

        final isSelected = _selectedSer != null && _selectedSer == ser;
        final dateStr = _thaiDate(date);

        final nvatF = _money.format(_toDouble(nvat));
        final pvatF = _money.format(_toDouble(pvat));
        final wtype = _getString(m, 'wtype');
        final nwhtF = _money.format(_toDouble(nwht));
        final whtF = _money.format(_toDouble(wht));
        final totalF = _money.format(_toDouble(total));

        // scale padding
        final pad = EdgeInsets.only(
          left: widget.itemPadding.left * widget.sizeScale,
          right: widget.itemPadding.right * widget.sizeScale,
          top: widget.itemPadding.top * widget.sizeScale,
          bottom: widget.itemPadding.bottom * widget.sizeScale,
        );

        return _TransTile(
          key: ValueKey(ser.isEmpty ? docno : ser),
          selected: isSelected,
          dateStr: dateStr,
          docno: docno,
          titleText: (descr.isNotEmpty ? descr : expname),
          vtype: vtype,
          nvat: nvatF,
          pvat: pvatF,
          nwht: nwhtF,
          wtype: wtype,
          wht: whtF,
          total: totalF,
          padding: pad,
          radius: widget.cardRadius * widget.sizeScale,
          sizeScale: widget.sizeScale,
          onTap: () {
            // ====== ลอจิกเดิม (ไม่เปลี่ยนลำดับ/ค่าที่ set) ======
            setState(() {
              widget.setEditData(2);
              widget.setEditDataSer(ser);
              widget.setEditDataDate(date);
              widget.setEditDataPvat(pvat);
              widget.setEditDataVser(vser);
              widget.setEditDataVtype(vtype);
              widget.setEditDataNvat(nvat);
              widget.setEditDataNwht(nwht);
              widget.setEditDataDocno(docno);
              widget.setEditDataTotal(total);

              widget.editTextTotal.text = total;
              widget.editTextVat.text = nvat; // ✅ คงพฤติกรรมเดิม
              widget.editTextWht.text = nwht;
              widget.editTextAll.text = total;

              _selectedSer = ser;
            });

            // ignore: avoid_print
            print('$ser $docno');
          },
        );
      },
    );
  }
}

class _TransTile extends StatelessWidget {
  const _TransTile({
    super.key,
    required this.selected,
    required this.dateStr,
    required this.docno,
    required this.titleText,
    required this.vtype,
    required this.nvat,
    required this.pvat,
    required this.nwht,
    required this.wtype,
    required this.wht,
    required this.total,
    required this.onTap,
    required this.padding,
    required this.radius,
    required this.sizeScale,
  });

  final bool selected;
  final String dateStr;
  final String docno;
  final String titleText;
  final String vtype;
  final String nvat;
  final String pvat;
  final String nwht;
  final String wtype;
  final String wht;
  final String total;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double radius;
  final double sizeScale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    final gradient = selected
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEF7FF), Color(0xFFDDEBFF)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FAFB), Color(0xFFFFFFFF)],
          );

    return
        // _compactContent();

        AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        // boxShadow: [
        //   if (selected)
        //     BoxShadow(
        //       color: theme.colorScheme.primary.withOpacity(0.16),
        //       blurRadius: 12 * sizeScale,
        //       offset: const Offset(0, 5),
        //     )
        //   else
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.04),
        //       blurRadius: 8 * sizeScale,
        //       offset: const Offset(0, 4),
        //     ),
        // ],
        // border: Border.all(
        //   color: selected
        //       ? theme.colorScheme.primary.withOpacity(0.32)
        //       : const Color(0xFFE8EDF2),
        // ),
        // border: Border(
        //   bottom: BorderSide(
        //     color: Colors.black12,
        //     width: 1,
        //   ),
        // ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: const BoxDecoration(
            // color: Colors.green[100]!
            //     .withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 1,
              ),
            ),
          ),
          child: InkWell(
            // borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Padding(
              padding: padding,
              child:
                  // isWide ? _wideContent() :
                  _compactContent(),
            ),
          ),
        ),
      ),
    );
  }

  double get _fzDoc => 17 * sizeScale;
  double get _fzDocWide => 17 * sizeScale;
  double get _fzValue => 14 * sizeScale;
  double get _gapSmall => 6 * sizeScale;
  double get _gapRow => 13 * sizeScale;
  double get _chipFont => 12 * sizeScale;
  double get _avatarRadius => 16 * sizeScale;

  Widget _chip(String label, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * sizeScale,
        vertical: 4 * sizeScale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12 * sizeScale, color: const Color(0xFF2563EB)),
            SizedBox(width: 6 * sizeScale),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: _chipFont, color: Colors.black,
              // color: const Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactContent() {
    List<String> data = [
      // docno,
      dateStr,
      titleText,

      // dateStr,
      pvat,
      vtype,
      nvat,
      wtype,
      wht,
      total
    ];

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (int index = 0; index < data.length; index++)
        Expanded(
          flex: 1,
          child: (index < 2)
              ? Tooltip(
                  richMessage: TextSpan(
                    text:
                        (index == 1) ? data[index] + ' : $docno' : data[index],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                      //fontSize: 10.0
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200],
                  ),
                  child: Text(
                    data[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: (index > 2) ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                      fontSize: _fzDoc,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ))
              : Text(
                  data[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: (index > 2) ? TextAlign.end : TextAlign.start,
                  style: TextStyle(
                    fontSize: _fzDoc,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
    ]);

    // Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     _leadingAvatar(),
    //     SizedBox(width: 10 * sizeScale),
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Row(
    //             children: [
    //               Expanded(
    //                 child: Row(
    //                   children: [
    //                     Text(
    //                       titleText,
    //                       maxLines: 1,
    //                       overflow: TextOverflow.ellipsis,
    //                       style: TextStyle(
    //                         fontSize: _fzDoc,
    //                         fontWeight: FontWeight.w700,
    //                         letterSpacing: 0.2,
    //                       ),
    //                     ),
    //                     SizedBox(width: _gapSmall),
    //                     Text(
    //                       docno,
    //                       maxLines: 2,
    //                       overflow: TextOverflow.ellipsis,
    //                       style: TextStyle(
    //                         color: Colors.grey.shade700,
    //                         height: 1.15,
    //                         fontSize: _fzValue,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               Text(
    //                 total,
    //                 style: TextStyle(
    //                   fontFeatures: const [FontFeature.tabularFigures()],
    //                   fontWeight: FontWeight.w700,
    //                   fontSize: _fzValue + 2,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           // SizedBox(height: _gapSmall),
    //           // Text(
    //           //   titleText,
    //           //   maxLines: 2,
    //           //   overflow: TextOverflow.ellipsis,
    //           //   style: TextStyle(
    //           //     color: Colors.grey.shade700,
    //           //     height: 1.15,
    //           //     fontSize: _fzValue,
    //           //   ),
    //           // ),
    //           SizedBox(height: _gapSmall),
    //           Wrap(
    //             spacing: 6 * sizeScale,
    //             runSpacing: 6 * sizeScale,
    //             children: [
    //               _chip(dateStr, icon: Icons.event),
    //               if (vtype.isNotEmpty) _chip(vtype),
    //               _chip('NVAT $nvat'),
    //               _chip('PVAT $pvat'),
    //               _chip('WHT $nwht'),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget _wideContent() {
    final labelStyle =
        TextStyle(color: Colors.grey.shade600, fontSize: _fzValue - 1);
    final valueStyle = TextStyle(
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w700,
      fontSize: _fzValue,
    );

    return Row(
      children: [
        _leadingAvatar(),
        SizedBox(width: _gapRow),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      docno,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _fzDocWide,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * sizeScale),
                  _chip(dateStr, icon: Icons.event),
                ],
              ),
              SizedBox(height: _gapSmall),
              Text(
                titleText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.15,
                    fontSize: _fzValue),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              _metric('PVAT', pvat, labelStyle, valueStyle),
              _metric('VTYPE', vtype.isEmpty ? '-' : vtype, labelStyle,
                  valueStyle.copyWith(fontWeight: FontWeight.w700)),
              _metric('NVAT', nvat, labelStyle, valueStyle),
              _metric('NWHT', nwht, labelStyle, valueStyle),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TOTAL', style: labelStyle),
                    SizedBox(height: _gapSmall),
                    Text(
                      total,
                      style: valueStyle.copyWith(fontSize: _fzDoc),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(
      String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: labelStyle),
          SizedBox(height: _gapSmall),
          Text(value, style: valueStyle, textAlign: TextAlign.end),
        ],
      ),
    );
  }

  Widget _leadingAvatar() {
    final initials = docno.isNotEmpty ? docno.characters.first : '#';
    return CircleAvatar(
      radius: _avatarRadius,
      backgroundColor: const Color(0xFFE6F0FF),
      child: Text(
        initials,
        style: TextStyle(
          color: const Color(0xFF1D4ED8),
          fontWeight: FontWeight.w800,
          fontSize: _fzValue,
        ),
      ),
    );
  }
}

// ---------------- Helpers ----------------

String _thaiDate(String? ymd) {
  if (ymd == null || ymd.isEmpty) return '';
  final dt = DateTime.tryParse('$ymd 00:00:00');
  if (dt == null) return '';
  final ddmm = DateFormat('dd-MM').format(dt);
  final byear = dt.year + 543;
  return '$ddmm-$byear';
}

double _toDouble(String? v) {
  if (v == null || v.trim().isEmpty) return 0;
  return double.tryParse(v.replaceAll(',', '')) ?? 0;
}

String _getString(dynamic m, String key) {
  // 1) Map<String, dynamic>
  if (m is Map<String, dynamic>) {
    final val = m[key];
    return val == null ? '' : val.toString();
  }

  // 2) model with direct fields
  try {
    switch (key) {
      case 'ser':
        return (m.ser ?? '').toString();
      case 'docno':
        return (m.docno ?? '').toString();
      case 'date':
        return (m.date ?? '').toString();
      case 'pvat':
        return (m.pvat ?? '').toString();
      case 'vtype':
        return (m.vtype ?? '').toString();
      case 'nvat':
        return (m.nvat ?? '').toString();
      case 'nwht':
        return (m.nwht ?? '').toString();
      case 'total':
        return (m.total ?? '').toString();
      case 'expname':
        return (m.expname ?? '').toString();
      case 'descr':
        return (m.descr ?? '').toString();
    }
  } catch (_) {/* fallthrough */}

  // 3) model with toJson()
  try {
    final map = m.toJson();
    if (map is Map<String, dynamic>) {
      final val = map[key];
      return val == null ? '' : val.toString();
    }
  } catch (_) {/* fallthrough */}

  return '';
}
