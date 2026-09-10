import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ChaoArea/Chao_Return.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetTeNant_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'PeopleChao_Screen2.dart';

class Cancellation_notice extends StatefulWidget {
  final updateMessage;
  //////////---------------------------------------->การแจ้งการยกเลิกสัญญาล่วงหน้า
  const Cancellation_notice({super.key, this.updateMessage});

  @override
  State<Cancellation_notice> createState() => _Cancellation_noticeState();
}

class _Cancellation_noticeState extends State<Cancellation_notice> {
  DateTime datex = DateTime.now();
  int open_set_date = 30;
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  //////////////---------------------------->
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> limitedList_teNantModels = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  List<List<dynamic>> teNantModels_Save = [];
  //////////////---------------------------->
  String? renTal_user,
      renTal_name,
      zone_ser,
      zone_name,
      Value_cid,
      fname_,
      cname,
      lnname,
      Get_Value_NameShop_index,
      cc_date,
      cc_remark;
  String? rtname,
      type,
      typex,
      renname,
      pkname,
      ser_Zonex,
      Value_stasus,
      Status_pe;
  int contact_new = 0;
  int renTal_lavel = 0;
  String tappedIndex_ = '';
////-------------->

  ScrollController _scrollController1 = ScrollController();

  ///----------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  //-------------------------------------->
  List<String> monthsInThai = [
    'มกราคม', // January
    'กุมภาพันธ์', // February
    'มีนาคม', // March
    'เมษายน', // April
    'พฤษภาคม', // May
    'มิถุนายน', // June
    'กรกฎาคม', // July
    'สิงหาคม', // August
    'กันยายน', // September
    'ตุลาคม', // October
    'พฤศจิกายน', // November
    'ธันวาคม', // December
  ];

  ///------------------------>
  List<String> YE_Th = [];

  String? MONTH_Now, YEAR_Now;
  String Type_s = 'All';
  ///////---------------------------------------------------->
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPreferance();
    // read_GC_tenant_Cancel();
  }

////////////----------------------------------------------------->
  Future<Null> checkPreferance() async {
    int currentYear = DateTime.now().year + 1;
    for (int i = currentYear; i >= currentYear - 11; i--) {
      YE_Th.add(i.toString());
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      MONTH_Now = DateFormat('MM').format(DateTime.parse('${datex}'));
      YEAR_Now = DateFormat('yyyy').format(DateTime.parse('${datex}'));
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      fname_ = preferences.getString('fname');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
      teNantModels_Save = List.generate(300, (_) => []);
    });
    read_GC_tenant_Cancel();
  }

////////////----------------------------------------------------->(รายงาน ข้อมูลผู้เช่า(ยกเลิกสัญญา))GC_tenant_CanceNoticeAll
  Future<Null> read_GC_tenant_Cancel() async {
    if (limitedList_teNantModels.isNotEmpty) {
      limitedList_teNantModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    //print('zone>>>>>>zone>>>>>$zone');

    String url = zone == null || zone == '0'
        ? '${MyConstant().domain}/GC_tenant_CanceNoticeAll.php?isAdd=true&ren=$ren&zone=0&mont_h=$MONTH_Now&yea_r=$YEAR_Now&type=$Type_s'
        : '${MyConstant().domain}/GC_tenant_CanceNoticeAll.php?isAdd=true&ren=$ren&zone=$zone&mont_h=$MONTH_Now&yea_r=$YEAR_Now&type=$Type_s';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModelsCancel = TeNantModel.fromJson(map);
          setState(() {
            limitedList_teNantModels.add(teNantModelsCancel);
          });
        }
      } else {}
      //print('teNantModels///result ${limitedList_teNantModels.length}');
      setState(() {
        _teNantModels = limitedList_teNantModels;
      });
      read_tenant_limit();
    } catch (e) {}
  }

  /////////////////--------------------------->
  Future<Null> read_tenant_limit() async {
    setState(() {
      endIndex = offset + limit;
      teNantModels = limitedList_teNantModels.sublist(
          offset, // Start index
          (endIndex <= limitedList_teNantModels.length)
              ? endIndex
              : limitedList_teNantModels.length // End index
          );
    });
    //limitedList_teNantModels
  }

////////////----------------------------------------------------->
  Widget Next_page_Web() {
    return Row(
      children: [
        Expanded(child: Text('')),
        StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 300)),
            builder: (context, snapshot) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
                    ),
                    InkWell(
                        onTap: (offset == 0)
                            ? null
                            : () async {
                                if (offset == 0) {
                                } else {
                                  setState(() {
                                    offset = offset - limit;

                                    read_tenant_limit();
                                    tappedIndex_ = '';
                                  });
                                  _scrollController1.animateTo(
                                    0,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                        child: Icon(
                          Icons.arrow_left,
                          color:
                              (offset == 0) ? Colors.grey[200] : Colors.black,
                          size: 25,
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        /// '*//$endIndex /${limitedList_teNantModels.length} ///${(endIndex / limit)}/${(limitedList_teNantModels.length / limit).ceil()}',
                        '${(endIndex / limit)}/${(limitedList_teNantModels.length / limit).ceil()}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                          //fontSize: 10.0
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: (endIndex >= limitedList_teNantModels.length)
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  tappedIndex_ = '';
                                  read_tenant_limit();
                                });
                                _scrollController1.animateTo(
                                  0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: (endIndex >= limitedList_teNantModels.length)
                              ? Colors.grey[200]
                              : Colors.black,
                          size: 25,
                        )),
                  ],
                ),
              );
            }),
      ],
    );
  }
////////////----------------------------------------------------->

  _searchBar() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: const TextStyle(
          color: PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: const TextStyle(
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontFamily: Font_.Fonts_T),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: const BorderSide(color: Colors.white),
        //   borderRadius: BorderRadius.circular(10),
        // ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (text) {
        //print(text);
        // text = text.toLowerCase();

        setState(() {
          teNantModels = _teNantModels.where((teNantModels) {
            var cc_date_ =
                '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${teNantModels.cc_date} 00:00:00'))}';
            var notTitle = teNantModels.lncode.toString();
            var notTitle2 = teNantModels.cid.toString();
            var notTitle3 = teNantModels.docno.toString();
            var notTitle4 = teNantModels.sname.toString();
            var notTitle5 = teNantModels.cname.toString();
            var notTitle6 = teNantModels.zn.toString();
            var notTitle7 = teNantModels.zser.toString();
            var notTitle8 = teNantModels.ln.toString();
            var notTitle9 = teNantModels.fid.toString();
            var notTitle10 = cc_date_.toString().toLowerCase();
            var notTitle11 = teNantModels.wnote.toString();

            // var notTitle = teNantModels.lncode.toString().toLowerCase();
            // var notTitle2 = teNantModels.cid.toString().toLowerCase();
            // var notTitle3 = teNantModels.docno.toString().toLowerCase();
            // var notTitle4 = teNantModels.sname.toString().toLowerCase();
            // var notTitle5 = teNantModels.cname.toString().toLowerCase();
            // var notTitle6 = teNantModels.zn.toString().toLowerCase();
            // var notTitle7 = teNantModels.zser.toString().toLowerCase();
            // var notTitle8 = teNantModels.sdate.toString().toLowerCase();
            // var notTitle9 = teNantModels.fid.toString().toLowerCase();
            // var notTitle10 = teNantModels.sdate_q.toString().toLowerCase();
            // var notTitle11 = teNantModels.ldate_q.toString().toLowerCase();
            // var notTitle12 = teNantModels.wnote.toString().toLowerCase();
            return notTitle.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text) ||
                notTitle4.contains(text) ||
                notTitle5.contains(text) ||
                notTitle6.contains(text) ||
                notTitle7.contains(text) ||
                notTitle8.contains(text) ||
                notTitle9.contains(text) ||
                notTitle10.contains(text) ||
                notTitle11.contains(text);
          }).toList();
        });
      },
    );
  }

  String? _message;
  void updateMessage(newMessage, ValueNameShop_index, Valuecid) {
    setState(() {
      _message = newMessage;
      // ReturnBodyPeople = newMessage;
      Get_Value_NameShop_index = ValueNameShop_index;
      Value_cid = Valuecid;
    });
    // checkPreferance();
    // read_GC_zone();

    // read_GC_rental();
  }

  ////////////----------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return (contact_new == 1)
        ? Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          contact_new = 0;
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              PeopleChaoScreen2(
                Get_Value_cid: Value_cid,
                Get_Value_NameShop_index: Get_Value_NameShop_index,
                Get_Value_status: Value_stasus,
                Get_Value_indexpage: '0',
                updateMessage: updateMessage,
              ),
            ],
          )
        : (contact_new == 2)
            ? ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.start,
                  child: Row(
                    children: [
                      SizedBox(
                        width: (Responsive.isDesktop(context))
                            ? MediaQuery.of(context).size.width * 0.858
                            : 1200,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Container(
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.858
                                  : 1200,
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0)),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppbackgroundColor.TiTile_Colors,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                contact_new = 0;
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const Icon(
                                                Icons.arrow_back,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ยกเลิกสัญญาสัญญา',
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.left,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        2),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Translate.TranslateAndSetText(
                                                    (cc_date == null)
                                                        ? 'วันที่แจ้ง : $cc_date'
                                                        : 'วันที่แจ้ง : ${DateFormat('dd-MM').format(DateTime.parse('$cc_date 00:00:00'))}-${DateTime.parse('$cc_date 00:00:00').year + 543}',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    null,
                                                    Font_.Fonts_T,
                                                    12,
                                                    2),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'หมายเหตุ : $cc_remark',
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.left,
                                                        null,
                                                        Font_.Fonts_T,
                                                        12,
                                                        2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Expanded(
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.start,
                                        //     children: [
                                        //       Padding(
                                        //         padding: const EdgeInsets.all(4.0),
                                        //         child: Container(
                                        //           decoration: BoxDecoration(
                                        //             color: AppbackgroundColor
                                        //                 .Sub_Abg_Colors,
                                        //             borderRadius:
                                        //                 const BorderRadius.only(
                                        //                     topLeft:
                                        //                         Radius.circular(10),
                                        //                     topRight:
                                        //                         Radius.circular(10),
                                        //                     bottomLeft:
                                        //                         Radius.circular(10),
                                        //                     bottomRight:
                                        //                         Radius.circular(
                                        //                             10)),
                                        //             border: Border.all(
                                        //                 color: Colors.grey,
                                        //                 width: 1),
                                        //           ),
                                        //           child: Column(
                                        //             children: [
                                        //               const Padding(
                                        //                 padding:
                                        //                     EdgeInsets.all(4.0),
                                        //                 child: AutoSizeText(
                                        //                   minFontSize: 10,
                                        //                   maxFontSize: 15,
                                        //                   'รหัสพื้นที่ : ',
                                        //                   style: TextStyle(
                                        //                     color: TextHome_Color
                                        //                         .TextHome_Colors,
                                        //                     fontWeight:
                                        //                         FontWeight.bold,
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               Padding(
                                        //                 padding:
                                        //                     const EdgeInsets.all(
                                        //                         4.0),
                                        //                 child: Container(
                                        //                   decoration: BoxDecoration(
                                        //                     color: Colors.white,
                                        //                     borderRadius: const BorderRadius
                                        //                             .only(
                                        //                         topLeft: Radius
                                        //                             .circular(10),
                                        //                         topRight:
                                        //                             Radius.circular(
                                        //                                 10),
                                        //                         bottomLeft:
                                        //                             Radius.circular(
                                        //                                 10),
                                        //                         bottomRight:
                                        //                             Radius.circular(
                                        //                                 10)),
                                        //                     border: Border.all(
                                        //                         color: Colors.grey,
                                        //                         width: 1),
                                        //                   ),
                                        //                   padding:
                                        //                       const EdgeInsets.all(
                                        //                           8.0),
                                        //                   child: AutoSizeText(
                                        //                     minFontSize: 10,
                                        //                     maxFontSize: 15,
                                        //                     '$lnname',
                                        //                     maxLines: 2,
                                        //                     style: const TextStyle(
                                        //                       color: Colors.black,
                                        //                       fontWeight:
                                        //                           FontWeight.bold,
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppbackgroundColor
                                                              .Sub_Abg_Colors
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 15,
                                                            'รหัสพื้นที่ : ',
                                                            style: TextStyle(
                                                              color: TextHome_Color
                                                                  .TextHome_Colors,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.5),
                                                              borderRadius: const BorderRadius
                                                                      .only(
                                                                  topLeft:
                                                                      Radius.circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10)),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: AutoSizeText(
                                                              minFontSize: 10,
                                                              maxFontSize: 15,
                                                              '$lnname',
                                                              maxLines: 2,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding: const EdgeInsets.all(4.0),
                                                //   child: Container(
                                                //     decoration: BoxDecoration(
                                                //       color: AppbackgroundColor
                                                //           .Sub_Abg_Colors,
                                                //       borderRadius:
                                                //           const BorderRadius.only(
                                                //               topLeft:
                                                //                   Radius.circular(10),
                                                //               topRight:
                                                //                   Radius.circular(10),
                                                //               bottomLeft:
                                                //                   Radius.circular(10),
                                                //               bottomRight:
                                                //                   Radius.circular(10)),
                                                //       border: Border.all(
                                                //           color: Colors.grey, width: 1),
                                                //     ),
                                                //     child: Row(
                                                //       mainAxisAlignment:
                                                //           MainAxisAlignment.end,
                                                //       children: [
                                                //         SizedBox(
                                                //           child: Column(
                                                //             children: [
                                                //               const Padding(
                                                //                 padding:
                                                //                     EdgeInsets.all(4.0),
                                                //                 child: AutoSizeText(
                                                //                   minFontSize: 10,
                                                //                   maxFontSize: 15,
                                                //                   'ชื่อผู้ทำรายการ : ',
                                                //                   style: TextStyle(
                                                //                     color: TextHome_Color
                                                //                         .TextHome_Colors,
                                                //                     fontWeight:
                                                //                         FontWeight.bold,
                                                //                   ),
                                                //                 ),
                                                //               ),
                                                //               Padding(
                                                //                 padding:
                                                //                     const EdgeInsets
                                                //                         .all(4.0),
                                                //                 child: Container(
                                                //                   decoration:
                                                //                       BoxDecoration(
                                                //                     color: Colors.white,
                                                //                     borderRadius: const BorderRadius
                                                //                             .only(
                                                //                         topLeft: Radius
                                                //                             .circular(
                                                //                                 10),
                                                //                         topRight: Radius
                                                //                             .circular(
                                                //                                 10),
                                                //                         bottomLeft: Radius
                                                //                             .circular(
                                                //                                 10),
                                                //                         bottomRight: Radius
                                                //                             .circular(
                                                //                                 10)),
                                                //                     border: Border.all(
                                                //                         color:
                                                //                             Colors.grey,
                                                //                         width: 1),
                                                //                   ),
                                                //                   padding:
                                                //                       const EdgeInsets
                                                //                           .all(8.0),
                                                //                   child: AutoSizeText(
                                                //                     minFontSize: 10,
                                                //                     maxFontSize: 15,
                                                //                     '',
                                                //                     maxLines: 2,
                                                //                     style:
                                                //                         const TextStyle(
                                                //                       color:
                                                //                           Colors.black,
                                                //                       fontWeight:
                                                //                           FontWeight
                                                //                               .bold,
                                                //                     ),
                                                //                   ),
                                                //                 ),
                                                //               ),
                                                //             ],
                                                //           ),
                                                //         ),
                                                //       ],
                                                //     ),
                                                //   ),
                                                // ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppbackgroundColor
                                                              .Sub_Abg_Colors
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          child: Column(
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            4.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      15,
                                                                  'ชื่อผู้เช่า : ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: TextHome_Color
                                                                        .TextHome_Colors,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.5),
                                                                    borderRadius: const BorderRadius
                                                                            .only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                10),
                                                                        topRight:
                                                                            Radius.circular(
                                                                                10),
                                                                        bottomLeft:
                                                                            Radius.circular(
                                                                                10),
                                                                        bottomRight:
                                                                            Radius.circular(10)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    '$cname',
                                                                    maxLines: 2,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          4.0),
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        15,
                                                                    Get_Value_NameShop_index.toString() ==
                                                                            '1'
                                                                        ? 'เลขที่ใบสัญญา : '
                                                                        : 'เลขที่ใบเสนอราคา : ',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: TextHome_Color
                                                                          .TextHome_Colors,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          4.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.5),
                                                                      borderRadius: const BorderRadius
                                                                              .only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight: Radius.circular(
                                                                              10),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      minFontSize:
                                                                          10,
                                                                      maxFontSize:
                                                                          15,
                                                                      '${Value_cid}',
                                                                      maxLines:
                                                                          2,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        //0953873075
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                  ChaoReturn(
                                    Get_Value_NameShop_index:
                                        Get_Value_NameShop_index,
                                    Value_cid: Value_cid,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  dragStartBehavior: DragStartBehavior.start,
                  child: Row(
                    children: [
                      SizedBox(
                        width: (Responsive.isDesktop(context))
                            ? MediaQuery.of(context).size.width * 0.858
                            : 1200,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Container(
                                  width: (Responsive.isDesktop(context))
                                      ? MediaQuery.of(context).size.width *
                                          0.858
                                      : 1200,
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.TiTile_Colors,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ค้นหา :',
                                                      SettingScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.center,
                                                      FontWeight.bold,
                                                      FontWeight_.Fonts_T,
                                                      14,
                                                      2)),
                                          Expanded(
                                            // flex: 1,
                                            child: Container(
                                              height: 35, //Date_ser
                                              // width: 150,
                                              decoration: BoxDecoration(
                                                color: AppbackgroundColor
                                                    .Sub_Abg_Colors,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              child: _searchBar(),
                                            ),
                                          ),
                                          Container(
                                              width: 150,
                                              child: Next_page_Web())
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppbackgroundColor
                                                      .Sub_Abg_Colors
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10)),
                                              // border: Border.all(color: Colors.white, width: 1),
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ประเภท :',
                                                            SettingScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.center,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            1)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppbackgroundColor
                                                          .Sub_Abg_Colors,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                      // border: Border.all(color: Colors.grey, width: 1),
                                                    ),
                                                    width: 120,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child:
                                                        DropdownButtonFormField2(
                                                      alignment:
                                                          Alignment.center,
                                                      focusColor: Colors.white,
                                                      autofocus: false,
                                                      decoration:
                                                          InputDecoration(
                                                        floatingLabelAlignment:
                                                            FloatingLabelAlignment
                                                                .center,
                                                        enabled: true,
                                                        hoverColor:
                                                            Colors.brown,
                                                        prefixIconColor:
                                                            Colors.blue,
                                                        fillColor: Colors.white
                                                            .withOpacity(0.05),
                                                        filled: false,
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        focusedBorder:
                                                            const OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                          borderSide:
                                                              BorderSide(
                                                            width: 1,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    231,
                                                                    227,
                                                                    227),
                                                          ),
                                                        ),
                                                      ),
                                                      isExpanded: false,
                                                      //value: MONTH_Now,
                                                      hint: Translate
                                                          .TranslateAndSetText(
                                                              Type_s == 'All'
                                                                  ? 'ทั้งหมด'
                                                                  : '${Type_s}',
                                                              Colors.grey,
                                                              TextAlign.center,
                                                              null,
                                                              Font_.Fonts_T,
                                                              14,
                                                              1),

                                                      icon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        color: Colors.black,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                      iconSize: 20,
                                                      buttonHeight: 30,
                                                      buttonWidth: 200,
                                                      // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                      dropdownDecoration:
                                                          BoxDecoration(
                                                        // color: Colors
                                                        //     .amber,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 1),
                                                      ),
                                                      items: [
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: 'All',
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ทั้งหมด',
                                                                  Colors.grey,
                                                                  TextAlign
                                                                      .left,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                        ),
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: 'Months',
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'รายเดือน',
                                                                  Colors.grey,
                                                                  TextAlign
                                                                      .left,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                        ),
                                                      ],

                                                      onChanged: (value) async {
                                                        Type_s =
                                                            value.toString();
                                                        read_GC_tenant_Cancel();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                if (Type_s != 'All')
                                                  Row(
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'เดือน :',
                                                                  SettingScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1)),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            //value: MONTH_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    MONTH_Now == null
                                                                        ? 'เลือก'
                                                                        : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .center,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),

                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              for (int item = 1;
                                                                  item < 13;
                                                                  item++)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      '${item}',
                                                                  child: Translate.TranslateAndSetText(
                                                                      '${monthsInThai[item - 1]}',
                                                                      Colors
                                                                          .grey,
                                                                      TextAlign
                                                                          .left,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                )
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              MONTH_Now = value;
                                                              read_GC_tenant_Cancel();
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปี :',
                                                                PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.left,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10)),
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            // value: YEAR_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    YEAR_Now ==
                                                                            null
                                                                        ? 'เลือก'
                                                                        : '$YEAR_Now',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .left,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),

                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: YE_Th.map(
                                                                (item) =>
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          '${item}',
                                                                      child:
                                                                          Text(
                                                                        '${item}',
                                                                        // '${item} ( ${int.parse(item!) + 543} )',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              //  (item.toString() ==
                                                                              //         DateTime.now()
                                                                              //             .year
                                                                              //             .toString())
                                                                              //     ? Colors
                                                                              //         .green[400]
                                                                              //     :
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                    )).toList(),

                                                            onChanged:
                                                                (value) async {
                                                              YEAR_Now = value;
                                                              //print(YEAR_Now);
                                                              read_GC_tenant_Cancel();
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 80,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    '..',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'เลขที่สัญญา',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 2,
                                          //     'ชื่อผู้ติดต่อ',
                                          //     textAlign: TextAlign.left,
                                          //     style: TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text1_,
                                          //         fontWeight: FontWeight.bold,
                                          //         fontFamily: FontWeight_.Fonts_T
                                          //         //fontSize: 10.0
                                          //         ),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ชื่อร้านค้า',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'โซนพื้นที่',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'รหัสพื้นที่',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'ประเภท',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          // Expanded(
                                          //   flex: 1,
                                          //   child: AutoSizeText(
                                          //     minFontSize: 10,
                                          //     maxFontSize: 25,
                                          //     maxLines: 2,
                                          //     'วันที่ทำรายการ',
                                          //     textAlign: TextAlign.left,
                                          //     style: TextStyle(
                                          //         color: PeopleChaoScreen_Color
                                          //             .Colors_Text1_,
                                          //         fontWeight: FontWeight.bold,
                                          //         fontFamily: FontWeight_.Fonts_T
                                          //         //fontSize: 10.0
                                          //         ),
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'กำหนดยกเลิกล่วงหน้า',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'วันสิ้นสุดสัญญา',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'เหตุผล',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'สถานะ',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    2),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.65,
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width *
                                            0.858
                                        : 1200,
                                    decoration: const BoxDecoration(
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(0)),
                                      // border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    child: teNantModels.isEmpty
                                        ? SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const CircularProgressIndicator(),
                                                StreamBuilder(
                                                  stream: Stream.periodic(
                                                      const Duration(
                                                          milliseconds: 25),
                                                      (i) => i),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData)
                                                      return const Text('');
                                                    double elapsed =
                                                        double.parse(snapshot
                                                                .data
                                                                .toString()) *
                                                            0.05;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: (elapsed > 8.00)
                                                          ? const Text(
                                                              'ไม่พบข้อมูล',
                                                              style: TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontFamily:
                                                                      Font_
                                                                          .Fonts_T
                                                                  //fontSize: 10.0
                                                                  ),
                                                            )
                                                          : Text(
                                                              'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                              // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                              style: const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontFamily:
                                                                      Font_
                                                                          .Fonts_T
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
                                            controller: _scrollController1,
                                            // itemExtent: 50,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: teNantModels.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Material(
                                                color: (teNantModels[index]
                                                            .cc_date ==
                                                        null)
                                                    ? AppbackgroundColor
                                                        .Sub_Abg_Colors
                                                    : (DateTime.parse(
                                                                    '${teNantModels[index].cc_date}')
                                                                .isBefore(
                                                                    datex) ||
                                                            DateTime.parse(
                                                                    '${teNantModels[index].cc_date}')
                                                                .isAtSameMomentAs(
                                                                    datex))
                                                        ? Colors
                                                            .deepOrange[400]!
                                                            .withOpacity(0.2)
                                                        : AppbackgroundColor
                                                            .Sub_Abg_Colors,
                                                child: Container(
                                                  // color: Colors.white,
                                                  // color: tappedIndex_ == index.toString()
                                                  //     ? tappedIndex_Color.tappedIndex_Colors
                                                  //         .withOpacity(0.5)
                                                  //     : null,
                                                  child: ListTile(
                                                      onTap: () {
                                                        setState(() {
                                                          tappedIndex_ =
                                                              index.toString();
                                                        });
                                                      },
                                                      title: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          // color: Colors.green[100]!
                                                          //     .withOpacity(0.5),
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color: Colors
                                                                  .black12,
                                                              width: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            10),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 0.3),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child:
                                                                  PopupMenuButton(
                                                                onOpened: () {
                                                                  setState(() {
                                                                    tappedIndex_ =
                                                                        index
                                                                            .toString();
                                                                  });
                                                                },
                                                                child: Center(
                                                                  child:
                                                                      InkWell(
                                                                    // onTap: () {
                                                                    //   setState(() {
                                                                    //     tappedIndex_ =
                                                                    //         index.toString();
                                                                    //   });
                                                                    // },
                                                                    child: Translate.TranslateAndSetText(
                                                                        'เรียกดู >',
                                                                        PeopleChaoScreen_Color
                                                                            .Colors_Text1_,
                                                                        TextAlign
                                                                            .left,
                                                                        FontWeight
                                                                            .bold,
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                  ),
                                                                ),
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context) =>
                                                                        [
                                                                  PopupMenuItem(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (renTal_lavel <= 2) {
                                                                                Navigator.pop(context);
                                                                                infomation();
                                                                              } else {
                                                                                Value_stasus = teNantModels[index].quantity == '1'
                                                                                    ? datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) == true
                                                                                        ? 'หมดสัญญา'
                                                                                        : datex.isAfter(DateTime.parse('${teNantModels[index].ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) == true
                                                                                            ? 'ใกล้หมดสัญญา'
                                                                                            : 'เช่าอยู่'
                                                                                    : teNantModels[index].quantity == '2'
                                                                                        ? 'เสนอราคา'
                                                                                        : teNantModels[index].quantity == '3'
                                                                                            ? 'เสนอราคา(มัดจำ)'
                                                                                            : 'ว่าง';
                                                                                // widget.updateMessage(
                                                                                //     '${teNantModels[index].docno == null ? teNantModels[index].cid == null ? '' : '${teNantModels[index].cid}' : '${teNantModels[index].docno}'}',
                                                                                //     '${teNantModels[index].quantity}',
                                                                                //     Value_stasus);
                                                                                setState(() {
                                                                                  cc_date = '${teNantModels[index].cc_date}';
                                                                                  cc_remark = '${teNantModels[index].cc_remark}';
                                                                                  cname = '${teNantModels[index].cname}';
                                                                                  lnname = '${teNantModels[index].ln}';
                                                                                  contact_new = 1;
                                                                                  Get_Value_NameShop_index = teNantModels[index].quantity;
                                                                                  Value_cid = '${teNantModels[index].cid}';
                                                                                });
                                                                                Navigator.pop(context);
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                                padding: const EdgeInsets.all(10),
                                                                                width: MediaQuery.of(context).size.width,
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                        child: Text(
                                                                                      teNantModels[index].docno == null
                                                                                          ? teNantModels[index].cid == null
                                                                                              ? ''
                                                                                              : 'เรียกดูสัญญา: ${teNantModels[index].cid}'
                                                                                          : 'เรียกดูสัญญา: ${teNantModels[index].docno}',
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: const TextStyle(
                                                                                          color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                          //fontWeight: FontWeight.bold,
                                                                                          fontFamily: Font_.Fonts_T),
                                                                                    ))
                                                                                  ],
                                                                                ))),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  PopupMenuItem(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (renTal_lavel <= 2) {
                                                                                Navigator.pop(context);
                                                                                infomation();
                                                                              } else {
                                                                                setState(() {
                                                                                  cc_date = '${teNantModels[index].cc_date}';
                                                                                  cc_remark = '${teNantModels[index].cc_remark}';
                                                                                  cname = '${teNantModels[index].cname}';
                                                                                  lnname = '${teNantModels[index].ln}';
                                                                                  contact_new = 2;
                                                                                  Get_Value_NameShop_index = teNantModels[index].quantity;
                                                                                  Value_cid = '${teNantModels[index].cid}';
                                                                                });
                                                                                Navigator.pop(context);
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                                padding: const EdgeInsets.all(10),
                                                                                width: MediaQuery.of(context).size.width,
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                        child: Text(
                                                                                      teNantModels[index].docno == null
                                                                                          ? teNantModels[index].cid == null
                                                                                              ? ''
                                                                                              : 'ยกเลิกสัญญา: ${teNantModels[index].cid}'
                                                                                          : 'ยกเลิกสัญญา: ${teNantModels[index].docno}',
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: const TextStyle(
                                                                                          color: PeopleChaoScreen_Color.Colors_Text2_,
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
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Tooltip(
                                                                  richMessage:
                                                                      TextSpan(
                                                                    text:
                                                                        '${teNantModels[index].cid}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: HomeScreen_Color
                                                                          .Colors_Text1_,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
                                                                    ),
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                  ),
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${teNantModels[index].cid}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                        //fontWeight: FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            // Expanded(
                                                            //   flex: 1,
                                                            //   child: Padding(
                                                            //     padding:
                                                            //         const EdgeInsets
                                                            //             .all(8.0),
                                                            //     child: AutoSizeText(
                                                            //       minFontSize: 10,
                                                            //       maxFontSize: 25,
                                                            //       maxLines: 1,
                                                            //       teNantModels[index]
                                                            //                   .cname ==
                                                            //               null
                                                            //           ? teNantModels[index]
                                                            //                       .cname_q ==
                                                            //                   null
                                                            //               ? ''
                                                            //               : '${teNantModels[index].cname_q}'
                                                            //           : '${teNantModels[index].cname}',
                                                            //       textAlign:
                                                            //           TextAlign
                                                            //               .left,
                                                            //       overflow:
                                                            //           TextOverflow
                                                            //               .ellipsis,
                                                            //       style:
                                                            //           const TextStyle(
                                                            //               color: PeopleChaoScreen_Color
                                                            //                   .Colors_Text2_,
                                                            //               //fontWeight: FontWeight.bold,
                                                            //               fontFamily:
                                                            //                   Font_
                                                            //                       .Fonts_T),
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Tooltip(
                                                                  richMessage:
                                                                      TextSpan(
                                                                    text:
                                                                        '${teNantModels[index].sname}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: HomeScreen_Color
                                                                          .Colors_Text1_,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                      //fontSize: 10.0
                                                                    ),
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                  ),
                                                                  child:
                                                                      AutoSizeText(
                                                                    minFontSize:
                                                                        10,
                                                                    maxFontSize:
                                                                        25,
                                                                    maxLines: 1,
                                                                    '${teNantModels[index].sname}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                        //fontWeight: FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 25,
                                                                maxLines: 1,
                                                                '${teNantModels[index].zn}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Tooltip(
                                                                richMessage:
                                                                    TextSpan(
                                                                  text:
                                                                      '${teNantModels[index].ln}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: HomeScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                    //fontSize: 10.0
                                                                  ),
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                ),
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  '${teNantModels[index].ln}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: const TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 25,
                                                                maxLines: 1,
                                                                '${teNantModels[index].rtname}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            // Expanded(
                                                            //   flex: 1,
                                                            //   child: AutoSizeText(
                                                            //     minFontSize: 10,
                                                            //     maxFontSize: 25,
                                                            //     maxLines: 1,
                                                            //     (teNantModels[index]
                                                            //                 .daterec ==
                                                            //             null)
                                                            //         ? '${teNantModels[index].daterec}'
                                                            //         : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].daterec} 00:00:00'))}-${DateTime.parse('${teNantModels[index].daterec} 00:00:00').year + 543}',
                                                            //     textAlign:
                                                            //         TextAlign.left,
                                                            //     overflow:
                                                            //         TextOverflow
                                                            //             .ellipsis,
                                                            //     style:
                                                            //         const TextStyle(
                                                            //             color: PeopleChaoScreen_Color
                                                            //                 .Colors_Text2_,
                                                            //             //fontWeight: FontWeight.bold,
                                                            //             fontFamily:
                                                            //                 Font_
                                                            //                     .Fonts_T),
                                                            //   ),
                                                            // ),
                                                            Expanded(
                                                              flex: 2,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 25,
                                                                maxLines: 1,
                                                                (teNantModels[index]
                                                                            .cc_date ==
                                                                        null)
                                                                    ? '${teNantModels[index].cc_date}'
                                                                    : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].cc_date} 00:00:00'))}-${DateTime.parse('${teNantModels[index].cc_date} 00:00:00').year + 543}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    color: (teNantModels[index].cc_date == null)
                                                                        ? PeopleChaoScreen_Color.Colors_Text2_
                                                                        : (DateTime.parse('${teNantModels[index].cc_date}').isBefore(datex) || DateTime.parse('${teNantModels[index].cc_date}').isAtSameMomentAs(datex))
                                                                            ? Colors.deepOrange
                                                                            : PeopleChaoScreen_Color.Colors_Text2_,
                                                                    fontWeight: (teNantModels[index].cc_date == null)
                                                                        ? null
                                                                        : (DateTime.parse('${teNantModels[index].cc_date}').isBefore(datex) || DateTime.parse('${teNantModels[index].cc_date}').isAtSameMomentAs(datex))
                                                                            ? FontWeight.w500
                                                                            : null,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 25,
                                                                maxLines: 1,
                                                                (teNantModels[index]
                                                                            .ldate ==
                                                                        null)
                                                                    ? '${teNantModels[index].ldate}'
                                                                    : '${DateFormat('dd-MM').format(DateTime.parse('${teNantModels[index].ldate} 00:00:00'))}-${DateTime.parse('${teNantModels[index].ldate} 00:00:00').year + 543}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Tooltip(
                                                                richMessage:
                                                                    TextSpan(
                                                                  text:
                                                                      '${teNantModels[index].cc_remark}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: HomeScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                    //fontSize: 10.0
                                                                  ),
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                ),
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  '${teNantModels[index].cc_remark}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 25,
                                                                maxLines: 1,
                                                                '${teNantModels[index].st}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            // Expanded(
                                                            //   flex: 1,
                                                            //   child: Row(
                                                            //     mainAxisAlignment:
                                                            //         MainAxisAlignment
                                                            //             .end,
                                                            //     children: [
                                                            //       Padding(
                                                            //         padding:
                                                            //             const EdgeInsets.all(
                                                            //                 8.0),
                                                            //         child:
                                                            //             InkWell(
                                                            //           onTap:
                                                            //               () async {
                                                            //             setState(
                                                            //                 () {
                                                            //               cc_date =
                                                            //                   '${teNantModels[index].cc_date}';
                                                            //               cc_remark =
                                                            //                   '${teNantModels[index].cc_remark}';
                                                            //               cname =
                                                            //                   '${teNantModels[index].cname}';
                                                            //               lnname =
                                                            //                   '${teNantModels[index].ln}';
                                                            //               contact_new =
                                                            //                   2;
                                                            //               Get_Value_NameShop_index =
                                                            //                   teNantModels[index].quantity;
                                                            //               Value_cid =
                                                            //                   '${teNantModels[index].cid}';
                                                            //             });
                                                            //           },
                                                            //           child: Container(
                                                            //               width: 80,
                                                            //               decoration: BoxDecoration(
                                                            //                 color:
                                                            //                     Colors.pink.shade200,
                                                            //                 borderRadius: const BorderRadius.only(
                                                            //                     topLeft: Radius.circular(10),
                                                            //                     topRight: Radius.circular(10),
                                                            //                     bottomLeft: Radius.circular(10),
                                                            //                     bottomRight: Radius.circular(10)),
                                                            //               ),
                                                            //               padding: const EdgeInsets.all(2.0),
                                                            //               child: Translate.TranslateAndSetText('เรียกดู', PeopleChaoScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 14, 1)),
                                                            //         ),
                                                            //       ),
                                                            //     ],
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: const BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      _scrollController1
                                                          .animateTo(
                                                        0,
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                        curve: Curves.easeOut,
                                                      );
                                                    },
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          // color: AppbackgroundColor
                                                          //     .TiTile_Colors,
                                                          borderRadius: const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        child: const Text(
                                                          'Top',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10.0,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        )),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (_scrollController1
                                                        .hasClients) {
                                                      final position =
                                                          _scrollController1
                                                              .position
                                                              .maxScrollExtent;
                                                      _scrollController1
                                                          .animateTo(
                                                        position,
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                        curve: Curves.easeOut,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        // color: AppbackgroundColor
                                                        //     .TiTile_Colors,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(6),
                                                            topRight:
                                                                Radius.circular(
                                                                    6),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    6)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3.0),
                                                      child: const Text(
                                                        'Down',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10.0,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T),
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
                                                  onTap: _moveUp1,
                                                  child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
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
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(6),
                                                              topRight: Radius
                                                                  .circular(6),
                                                              bottomLeft: Radius
                                                                  .circular(6),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          6)),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: const Text(
                                                      'Scroll',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10.0,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    )),
                                                InkWell(
                                                  onTap: _moveDown1,
                                                  child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Future<Null> infomation() async {
    showDialog<String>(
        // barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: const Center(
                  child: Text(
                'Level ของคุณไม่สามารถเข้าถึงได้',
                style: TextStyle(
                  color: SettingScreen_Color.Colors_Text1_,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ));
  }
}
