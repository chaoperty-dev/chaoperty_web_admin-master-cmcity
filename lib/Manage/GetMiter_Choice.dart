import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetSubZone_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_tran_meter_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';

//transMeterModels[index].ln
class GetMiter_Choice extends StatefulWidget {
  const GetMiter_Choice({super.key});

  @override
  State<GetMiter_Choice> createState() => _GetMiter_ChoiceState();
}

class _GetMiter_ChoiceState extends State<GetMiter_Choice> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  DateTime datex = DateTime.now();
  ///////////--------------------------------------------->
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  int Get_all = 0;
  List<ZoneModel> check_zser = [];
  String? Get_all_now;
  int Statas_Get_all = 0;
  ///////---------------------------------------------------->
  List<RenTalModel> renTalModels = [];
  List<TransMeterModel> transMeterModels = [];
  List<ZoneModel> zoneModels = [];
  List<SubZoneModel> subzoneModels = [];
  List<ZoneModel> limitedList_zone = [];
  List<ZoneModel> limitedList_zoneModels = [];
  List<ZoneModel> _zoneModels = <ZoneModel>[];
  ///////---------------------------------------------------->
  int Ser_BodySta1 = 0;
  String? serarea,
      lncodearea,
      lnarea,
      Value_D_start,
      snamearea,
      custnoarea,
      zone_ser,
      zone_name,
      zone_Subser,
      zone_Subname;
  String? rtname,
      type,
      typex,
      renname,
      bill_name,
      bill_addr,
      bill_tax,
      bill_tel,
      bill_email,
      expbill,
      cFinn,
      expbill_name,
      bill_default,
      bill_tser,
      Slip_status,
      foder,
      bills_name_,
      renTal_name,
      api_key,
      datemiter;
  int renTal_lavel = 0;
  void initState() {
    // TODO: implement initState
    super.initState();
    read_GC_rental();
    checkPreferance();
    read_GC_Sub_zone();
    read_GC_zone();
    red_Trans_bill();
  }

  Future<Null> red_Trans_bill() async {
    if (transMeterModels.length != 0) {
      setState(() {
        transMeterModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone_Sub = preferences.getString('zoneSubSer');
    // print('Ser_BodySta1 >>>>  $Ser_BodySta1');
    String url =
        '${MyConstant().domain}/GC_trans_mitter_subCount.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0&serzonesub=$zone_Sub';
    // String url = zone_Sub == null || zone_Sub == '0'
    //     ? (zone_ser.toString() == 'null')
    //         ? '${MyConstant().domain}/GC_trans_mitter.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0'
    //         : '${MyConstant().domain}/GC_trans_mitter.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=$zone_ser'
    //     : (zone_ser.toString() == 'null')
    //         ? '${MyConstant().domain}/GC_trans_mitter_sub.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0&serzonesub=$zone_Sub'
    //         : '${MyConstant().domain}/GC_trans_mitter_sub.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=$zone_ser&serzonesub=$zone_Sub';
    print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransMeterModel transMeterModel = TransMeterModel.fromJson(map);
          setState(() {
            transMeterModels.add(transMeterModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }
      transMeterModels.sort(
          (a, b) => int.parse(a.serzone!).compareTo(int.parse(b.serzone!)));
    } catch (e) {}
  }

  ///----------------------->
  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      setState(() {
        renTalModels.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname!.trim();
          var typexs = renTalModel.type!.trim();
          var typexx = renTalModel.typex!.trim();
          var bill_namex = renTalModel.bill_name!.trim();
          var bill_addrx = renTalModel.bill_addr!.trim();
          var bill_taxx = renTalModel.bill_tax!.trim();
          var bill_telx = renTalModel.bill_tel!.trim();
          var bill_emailx = renTalModel.bill_email!.trim();
          var bill_defaultx = renTalModel.bill_default;
          var bill_tserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          var api = renTalModel.api_key;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = bill_namex;
            bill_addr = bill_addrx;
            bill_tax = bill_taxx;
            bill_tel = bill_telx;
            bill_email = bill_emailx;
            bill_default = bill_defaultx;
            bill_tser = bill_tserx;
            api_key = api;
            renTalModels.add(renTalModel);
            if (bill_defaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      zone_ser = preferences.getString('zonePSer');
      zone_name = preferences.getString('zonesPName');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });
  }

//////////////------------------------------------->
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      limitedList_zoneModels.clear();
      zoneModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var zoneSubSer = preferences.getString('zoneSubSer');
    // var zonesSubName = preferences.getString('zonesSubName');
    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_zone_Getmiter.php?isAdd=true&ren=$ren';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      // Map<String, dynamic> map = Map();
      // map['ser'] = '0';
      // map['rser'] = '0';
      // map['zn'] = 'ทั้งหมด';
      // map['qty'] = '0';
      // map['img'] = '0';
      // map['data_update'] = '0';

      // ZoneModel zoneModelx = ZoneModel.fromJson(map);

      // setState(() {
      //   zoneModels.add(zoneModelx);
      // });

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        var sub = zoneModel.sub_zone;
        setState(() {
          if (zoneSubSer == null || zoneSubSer == '0') {
            limitedList_zoneModels.add(zoneModel);
            // zoneModels.add(zoneModel);
          } else {
            if (sub == zoneSubSer) {
              limitedList_zoneModels.add(zoneModel);
              // zoneModels.add(zoneModel);
            }
          }
        });
      }
      setState(() {
        _zoneModels = limitedList_zoneModels;
      });
      zoneModels.sort((a, b) {
        if (a.zn == 'ทั้งหมด') {
          return -1; // 'all' should come before other elements
        } else if (b.zn == 'ทั้งหมด') {
          return 1; // 'all' should come after other elements
        } else {
          return a.zn!
              .compareTo(b.zn!); // sort other elements in ascending order
        }
      });
      read_Zone_limit();
    } catch (e) {}
    // setState(() {
    //   zone_ser = preferences.getString('zonePSer');
    //   zone_name = preferences.getString('zonesPName');
    //   zone_Subser = preferences.getString('zoneSubSer');
    //   zone_Subname = preferences.getString('zonesSubName');
    // });
  }

  Future<Null> read_GC_Sub_zone() async {
    if (subzoneModels.length != 0) {
      setState(() {
        subzoneModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone_sub.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      Map<String, dynamic> map = Map();
      map['ser'] = '0';
      map['rser'] = '0';
      map['zn'] = 'ทั้งหมด';
      map['qty'] = '0';
      map['img'] = '0';
      map['data_update'] = '0';

      SubZoneModel subzoneModelx = SubZoneModel.fromJson(map);

      setState(() {
        subzoneModels.add(subzoneModelx);
      });

      for (var map in result) {
        SubZoneModel subzoneModel = SubZoneModel.fromJson(map);
        setState(() {
          subzoneModels.add(subzoneModel);
        });
      }
    } catch (e) {}
  }

  ///----------------------->

  Future<Null> read_Zone_limit() async {
    setState(() {
      endIndex = offset + limit;
      limitedList_zone = limitedList_zoneModels.sublist(
          offset, // Start index
          (endIndex <= limitedList_zoneModels.length)
              ? endIndex
              : limitedList_zoneModels.length // End index
          );
    });
  }

//////////////----------------------------->
  Widget Next_page() {
    return Row(
      children: [
        const Expanded(child: Text('')),
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
                    const Icon(
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

                                    read_Zone_limit();
                                    // tappedIndex_ = '';
                                  });
                                  // _scrollController2.animateTo(
                                  //   0,
                                  //   duration: const Duration(seconds: 1),
                                  //   curve: Curves.easeOut,
                                  // );
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
                        '${(endIndex / limit)}/${(limitedList_zoneModels.length / limit).ceil()}',
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
                        onTap: (endIndex >= limitedList_zoneModels.length)
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  // tappedIndex_ = '';
                                  read_Zone_limit();
                                });
                                // _scrollController2.animateTo(
                                //   0,
                                //   duration: const Duration(seconds: 1),
                                //   curve: Curves.easeOut,
                                // );
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: (endIndex >= limitedList_zoneModels.length)
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

  ////////--------------------------------------------------------------->
  _searchBarMain1() {
    return TextField(
      textAlign: TextAlign.start,
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
          limitedList_zone = _zoneModels.where((Invoice) {
            var notTitle = Invoice.zn.toString();
            // var notTitle2 = Invoice.qty.toString();

            return notTitle.contains(text);
          }).toList();
        });
      },
    );
  }

  ////------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    //////////////----------------------------->
    Widget Next_page() {
      return Row(
        children: [
          const Expanded(child: Text('')),
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
                      const Icon(
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

                                      read_Zone_limit();
                                      // tappedIndex_ = '';
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
                          '${(endIndex / limit)}/${(limitedList_zoneModels.length / limit).ceil()}',
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
                          onTap: (endIndex >= limitedList_zoneModels.length)
                              ? null
                              : () async {
                                  setState(() {
                                    offset = offset + limit;
                                    // tappedIndex_ = '';
                                    read_Zone_limit();
                                  });
                                  _scrollController1.animateTo(
                                    0,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeOut,
                                  );
                                },
                          child: Icon(
                            Icons.arrow_right,
                            color: (endIndex >= limitedList_zoneModels.length)
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

    ////------------------------------------------------->
    Future<void> check_up_meter(SerZone) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      // var user = preferences.getString('ser');

      String url =
          '${MyConstant().domain}/UP_meter_api.php?isAdd=true&ren=$ren&zser=$SerZone&datemiter=$datemiter';
      // print(url);
      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);

        if (result.toString() == 'true') {
          //print(result);
          // Navigator.pop(context);
          setState(() {
            // red_Trans_bill();
          });
        }
      } catch (e) {
        setState(() {
          Statas_Get_all = 1;
        });
        print('******************** > $e');
      }
    }

    ////------------------------------------------------->
    Future<void> Get_All() async {
      for (int index = 0; index < limitedList_zone.length; index++) {
        if (Statas_Get_all == 1) {
          print('${index + 1} : break');
          Navigator.pop(context);
          break; // Exit the loop if statas is 1
        }
        await check_up_meter(limitedList_zone[index].ser);
        // print(
        //     'Checked meter $datemiter for: ${limitedList_zone[index].ser} (${limitedList_zone[index].zn})');

        if (check_zser
                .where((e) =>
                    e.ser.toString() == '${limitedList_zone[index].ser}' &&
                    e.qty.toString() == '$datemiter')
                .length ==
            0) {
          Map<String, dynamic> map = Map();
          map['ser'] = '${limitedList_zone[index].ser}';
          map['qty'] = '$datemiter';

          map['zn'] = '${limitedList_zone[index].zn}';

          ZoneModel zoneModelx = ZoneModel.fromJson(map);

          setState(() {
            check_zser.add(zoneModelx);
          });
        }
        setState(() {
          Get_all_now =
              '${index + 1} / ${limitedList_zone.length} : ${limitedList_zone[index].zn}';
        });
        // print('${index + 1} : ${limitedList_zone[index].zn}');

        if (index + 1 == limitedList_zone.length) {
          SharedPreferences preferences = await SharedPreferences.getInstance();

          var zonesSubName = preferences.getString('zonesSubName');
          setState(() {
            red_Trans_bill(); // Uncomment this if needed
          });
          Future.delayed(const Duration(seconds: 1), () {
            (zonesSubName == null)
                ? Insert_log.Insert_logs('จัดการ',
                    'ดึงรายการค่าน้ำ-ค่าไฟ เดือน:$datemiter ( โซนทั้งหมด ${(endIndex / limit)}/${(limitedList_zoneModels.length / limit).ceil()}) ${limitedList_zone.length} โซน')
                : Insert_log.Insert_logs('จัดการ',
                    'ดึงรายการค่าน้ำ-ค่าไฟ เดือน:$datemiter ($zonesSubName  ${(endIndex / limit)}/${(limitedList_zoneModels.length / limit).ceil()}) ${limitedList_zone.length} โซน');
            Navigator.pop(context);
            // Navigator.pop(
            //     context);
          });
        }
      }
    }

    ////------------------------------------------------->
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppbackgroundColor.Sub_Abg_Colors,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(
              //     color: Colors.grey, width: 1),
            ),
            height: MediaQuery.of(context).size.height * 0.83,
            // width: MediaQuery.of(context).size.width / 3,
            child: Column(
              children: [
                ScrollConfiguration(
                  behavior:
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                            width: (Responsive.isDesktop(context))
                                ? MediaQuery.of(context).size.width * 0.85
                                : 1200,
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.TiTile_Colors,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                ),
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Translate.TranslateAndSetText(
                                              'ค้นหา :',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.start,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              1),
                                        ),
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
                                                  color: Colors.grey, width: 1),
                                            ),
                                            child: _searchBarMain1(),
                                          ),
                                        ),

                                        Container(
                                            width: 150, child: Next_page())
                                        // Expanded(
                                        //     child:
                                        //         Next_page_billCancel())
                                      ],
                                    ),
                                    const Divider(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              // const Divider(),
                              Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.TiTile_Colors,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                    // border: Border.all(
                                    //     color: Colors.grey, width: 1),
                                  ),
                                  padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: Row(children: [
                                    Container(
                                      height: 50,
                                      width: 100,
                                      // color: Colors.lightGreen[300],
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Translate.TranslateAndSetText(
                                            'ลำดับ',
                                            ManageScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            2),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 50,
                                        // color: Colors.lightGreen[300],
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Translate.TranslateAndSetText(
                                              'โซนหลัก',
                                              ManageScreen_Color.Colors_Text1_,
                                              TextAlign.left,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              2),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 50,
                                        // color: Colors.lightGreen[300],
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Translate.TranslateAndSetText(
                                              'โซนย่อย',
                                              ManageScreen_Color.Colors_Text1_,
                                              TextAlign.left,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              2),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        color: datemiter ==
                                                (datex.month - 1)
                                                    .toString()
                                                    .padLeft(2, '0')
                                            ? Colors.lightGreen[500]
                                            : Colors.lightGreen[300],
                                        padding: const EdgeInsets.all(4.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              datemiter = (datex.month - 1)
                                                  .toString()
                                                  .padLeft(2, '0');
                                            });

                                            // print(datemiter);
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                              border: datemiter !=
                                                      (datex.month - 1)
                                                          .toString()
                                                          .padLeft(2, '0')
                                                  ? null
                                                  : Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      width: 1),
                                            ),
                                            child: Center(
                                              child: Translate.TranslateAndSetText(
                                                  'เลขมิเตอร์เดือน ${DateFormat.MMM('th_TH').format(DateTime.parse('${DateFormat('yyyy').format(datex)}-${(datex.month - 1).toString().padLeft(2, '0')}-${DateFormat('dd').format(datex)} 00:00:00'))}',
                                                  datemiter ==
                                                          (datex.month - 1)
                                                              .toString()
                                                              .padLeft(2, '0')
                                                      ? Colors.white
                                                          .withOpacity(0.8)
                                                      : ManageScreen_Color
                                                          .Colors_Text1_,
                                                  TextAlign.center,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  14,
                                                  2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        color: datemiter ==
                                                (datex.month)
                                                    .toString()
                                                    .padLeft(2, '0')
                                            ? Colors.orange[500]
                                            : Colors.orange[300],
                                        padding: const EdgeInsets.all(4.0),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              datemiter = (datex.month)
                                                  .toString()
                                                  .padLeft(2, '0');
                                            });

                                            // print(datemiter);
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                              border: datemiter !=
                                                      (datex.month)
                                                          .toString()
                                                          .padLeft(2, '0')
                                                  ? null
                                                  : Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      width: 1),
                                            ),
                                            child: Center(
                                              child: Translate.TranslateAndSetText(
                                                  'เลขมิเตอร์เดือน ${DateFormat.MMM('th_TH').format(datex)}',
                                                  (datemiter ==
                                                          (datex.month)
                                                              .toString()
                                                              .padLeft(2, '0'))
                                                      ? Colors.white
                                                          .withOpacity(0.8)
                                                      : ManageScreen_Color
                                                          .Colors_Text1_,
                                                  TextAlign.center,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  14,
                                                  2),

                                              // ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 50,
                                        color: Colors.orange[300],
                                        child: (datemiter == null)
                                            ? Center(
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        '...',
                                                        ManageScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        2),
                                              )
                                            : (Get_all == 0)
                                                ? Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 0, 4, 0),
                                                      child: Container(
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              topRight: Radius
                                                                  .circular(8),
                                                              bottomLeft: Radius
                                                                  .circular(8),
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
                                                                .all(2.0),
                                                        width: 100,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            setState(() {
                                                              Get_all = 1;
                                                            });
                                                          },
                                                          child: Text(
                                                            'All: ${(endIndex / limit)}/${(limitedList_zone.length / limit).ceil()} [✔]',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              // fontWeight:
                                                              //     FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius: const BorderRadius
                                                                      .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0)),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2),
                                                            child: Text(
                                                              'ดึง ( ${limitedList_zone.length} )',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey[800],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                              ),
                                                            ),
                                                          ),
                                                          PopupMenuButton(
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .orange,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            8),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            0),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2),
                                                              child: const Icon(
                                                                Icons.post_add,
                                                                color: Colors
                                                                    .white,
                                                                size: 22,
                                                              ),
                                                            ),
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context) =>
                                                                    [
                                                              PopupMenuItem(
                                                                  onTap:
                                                                      () async {
                                                                    // Navigator.pop(
                                                                    //     context);
                                                                    Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                300),
                                                                        () {
                                                                      _showMyDialog();
                                                                    });

                                                                    Future.delayed(
                                                                        const Duration(
                                                                            seconds:
                                                                                1),
                                                                        () {
                                                                      Get_All();
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // color: Colors.green[100]!
                                                                      //     .withOpacity(0.5),
                                                                      border:
                                                                          Border(
                                                                        bottom:
                                                                            BorderSide(
                                                                          color:
                                                                              Colors.black12,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    // width: 200,
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          'ดึงน้ำไฟเดือน:$datemiter ( ${limitedList_zone.length} โซน )  ',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                ReportScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                            Icons
                                                                                .post_add,
                                                                            color:
                                                                                Colors.amber[600])
                                                                      ],
                                                                    ),
                                                                  )),
                                                              PopupMenuItem(
                                                                  onTap:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      Get_all =
                                                                          0;
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // color: Colors.green[100]!
                                                                      //     .withOpacity(0.5),
                                                                      border:
                                                                          Border(
                                                                        bottom:
                                                                            BorderSide(
                                                                          color:
                                                                              Colors.black12,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    // width: 200,
                                                                    child: Row(
                                                                      children: [
                                                                        Translate.TranslateAndSetText(
                                                                            'ยกเลิกทั้งหมด( ${limitedList_zone.length} ) : ',
                                                                            AccountScreen_Color.Colors_Text1_,
                                                                            TextAlign.start,
                                                                            FontWeight.bold,
                                                                            FontWeight_.Fonts_T,
                                                                            14,
                                                                            1),
                                                                        // Text(
                                                                        //   'ยกเลิกทั้งหมด( ${invoice_select.length} ) : ',
                                                                        //   style: const TextStyle(
                                                                        //     fontSize: 14,
                                                                        //     color: ReportScreen_Color.Colors_Text2_,
                                                                        //     // fontWeight: FontWeight.bold,
                                                                        //     fontFamily: Font_.Fonts_T,
                                                                        //   ),
                                                                        // ),
                                                                        const Icon(
                                                                          Icons
                                                                              .check_box_outline_blank,
                                                                          color:
                                                                              Colors.red,
                                                                          size:
                                                                              22,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Translate.TranslateAndSetText(
                                                    //     '...',
                                                    //     ManageScreen_Color.Colors_Text1_,
                                                    //     TextAlign.center,
                                                    //     FontWeight.bold,
                                                    //     FontWeight_.Fonts_T,
                                                    //     14,
                                                    //     2),
                                                  ),
                                      ),
                                    ),
                                  ])),
                              Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.63,
                                  decoration: const BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    // border: Border.all(
                                    //     color: Colors.grey, width: 1),
                                  ),
                                  child: ListView.builder(
                                      controller: _scrollController1,
                                      scrollDirection: Axis.vertical,
                                      itemCount: limitedList_zone.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        // int matches =
                                        //     transMeterModels.where((e) {
                                        //   String serzone =
                                        //       e.serzone.toString().trim();
                                        //   String ser = limitedList_zone[index]
                                        //       .ser
                                        //       .toString()
                                        //       .trim();

                                        //   print(
                                        //       "Comparing serzone: '$serzone' with ser: '$ser'");

                                        //   return serzone == ser;
                                        // }).length;

                                        // print(
                                        //     "Total matches for index $index: $matches");

                                        return Material(
                                            // color: tappedIndex_ == index
                                            //     ? tappedIndex_Color
                                            //         .tappedIndex_Colors
                                            //     : AppbackgroundColor
                                            //         .Sub_Abg_Colors,
                                            child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    4, 0, 4, 0),
                                                child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    title: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        // color: Colors.green[100]!
                                                        //     .withOpacity(0.5),
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color:
                                                                Colors.black12,
                                                            width: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(children: [
                                                        Container(
                                                          height: 50,
                                                          width: 100,
                                                          child: Text(
                                                            '${(index + 1)}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color: ManageScreen_Color
                                                                  .Colors_Text2_,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              //fontSize: 10.0
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            (limitedList_zone[index]
                                                                            .sub_zone ==
                                                                        null ||
                                                                    limitedList_zone[index]
                                                                            .sub_zone
                                                                            .toString() ==
                                                                        '0')
                                                                ? ''
                                                                : '${subzoneModels.where((model) => model.ser.toString() == '${limitedList_zone[index].sub_zone}').map((model) => model.zn).join(', ')}',
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color: ManageScreen_Color
                                                                  .Colors_Text2_,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              //fontSize: 10.0 transMeterModels
                                                            ),
                                                          ),
                                                        ),
                                                        // Expanded(
                                                        //   flex: 2,
                                                        //   child: Text(
                                                        //     '${zoneModels[index].sub_zone}',
                                                        //     textAlign:
                                                        //         TextAlign
                                                        //             .left,
                                                        //     overflow:
                                                        //         TextOverflow
                                                        //             .ellipsis,
                                                        //     style:
                                                        //         const TextStyle(
                                                        //       color: ManageScreen_Color
                                                        //           .Colors_Text2_,
                                                        //       // fontWeight: FontWeight.bold,
                                                        //       fontFamily: Font_
                                                        //           .Fonts_T,
                                                        //       //fontSize: 10.0
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${limitedList_zone[index].zn}',
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color: ManageScreen_Color
                                                                  .Colors_Text2_,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              //fontSize: 10.0 transMeterModels
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'ดึงแล้ว : ',
                                                                // '${index + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: ManageScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                              Text(
                                                                (transMeterModels
                                                                        .where((model) =>
                                                                            model.serzone.toString() ==
                                                                            '${limitedList_zone[index].ser}')
                                                                        .map((model) =>
                                                                            model
                                                                                .ovalue_count)
                                                                        .join(
                                                                            ', ')
                                                                        .isEmpty)
                                                                    ? '0 รายการ'
                                                                    : '${transMeterModels.where((model) => model.serzone.toString() == '${limitedList_zone[index].ser}').map((model) => model.ovalue_count).join(', ')} รายการ',
                                                                // '${transMeterModels.where((model) => model.serzone.toString() == '${limitedList_zone[index].ser}').map((model) => model.ovalue_count).join(', ')}',
                                                                // '${transMeterModels.where((e) => e.serzone.toString() == '${limitedList_zone[index].ser}' ).length} รายการ',
                                                                // '${index + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: (transMeterModels
                                                                          .where((model) =>
                                                                              model.serzone.toString() ==
                                                                              '${limitedList_zone[index].ser}')
                                                                          .map((model) => model
                                                                              .ovalue_count)
                                                                          .join(
                                                                              ', ')
                                                                          .isEmpty)
                                                                      ? Colors
                                                                          .red
                                                                      : Colors.green[
                                                                          700],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   'พื้นที่',
                                                              //   // '${index + 1}',
                                                              //   textAlign:
                                                              //       TextAlign
                                                              //           .center,
                                                              //   overflow:
                                                              //       TextOverflow
                                                              //           .ellipsis,
                                                              //   style:
                                                              //       TextStyle(
                                                              //     color: ManageScreen_Color
                                                              //         .Colors_Text2_,
                                                              //     // fontWeight: FontWeight.bold,
                                                              //     fontFamily:
                                                              //         Font_
                                                              //             .Fonts_T,
                                                              //     //fontSize: 10.0
                                                              //   ),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),

                                                        Expanded(
                                                          flex: 2,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'ดึงแล้ว : ',
                                                                // '${index + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: ManageScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                              Text(
                                                                (transMeterModels
                                                                        .where((model) =>
                                                                            model.serzone.toString() ==
                                                                            '${limitedList_zone[index].ser}')
                                                                        .map((model) =>
                                                                            model
                                                                                .nvalue_count)
                                                                        .join(
                                                                            ', ')
                                                                        .isEmpty)
                                                                    ? '0 รายการ'
                                                                    : '${transMeterModels.where((model) => model.serzone.toString() == '${limitedList_zone[index].ser}').map((model) => model.nvalue_count).join(', ')} รายการ',
                                                                //'${transMeterModels.where((e) => e.serzone.toString() == '${limitedList_zone[index].ser}' && e.nvalue.toString() != '0.00' && e.nvalue.toString() != '0').length} รายการ',
                                                                // '${index + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: (transMeterModels
                                                                          .where((model) =>
                                                                              model.serzone.toString() ==
                                                                              '${limitedList_zone[index].ser}')
                                                                          .map((model) => model
                                                                              .nvalue_count)
                                                                          .join(
                                                                              ', ')
                                                                          .isEmpty)
                                                                      ? Colors
                                                                          .red
                                                                      : Colors.green[
                                                                          700],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   'พื้นที่',
                                                              //   // '${index + 1}',
                                                              //   textAlign:
                                                              //       TextAlign
                                                              //           .center,
                                                              //   overflow:
                                                              //       TextOverflow
                                                              //           .ellipsis,
                                                              //   style:
                                                              //       TextStyle(
                                                              //     color: ManageScreen_Color
                                                              //         .Colors_Text2_,
                                                              //     // fontWeight: FontWeight.bold,
                                                              //     fontFamily:
                                                              //         Font_
                                                              //             .Fonts_T,
                                                              //     //fontSize: 10.0
                                                              //   ),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: (datemiter ==
                                                                      null)
                                                                  ? Colors
                                                                      .grey[300]
                                                                  : (check_zser.where((e) => e.ser.toString() == '${limitedList_zone[index].ser}' && e.qty.toString() == '$datemiter').length !=
                                                                          0)
                                                                      ? Colors.green[
                                                                          200]
                                                                      : Colors.orange[
                                                                          300],
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          8)),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1),
                                                            ),
                                                            height: 35,
                                                            child: InkWell(
                                                              onTap:
                                                                  (datemiter ==
                                                                          null)
                                                                      ? () {
                                                                          PanaraInfoDialog
                                                                              .showAnimatedGrow(
                                                                            context,
                                                                            title:
                                                                                "Oops",
                                                                            message:
                                                                                "กรุณาเลือกเดือน..",
                                                                            buttonText:
                                                                                "รับทราบ",
                                                                            onTapDismiss:
                                                                                () async {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            panaraDialogType:
                                                                                PanaraDialogType.error,
                                                                            barrierDismissible:
                                                                                false, // optional parameter (default is true)
                                                                          );
                                                                        }
                                                                      : () async {
                                                                          showDialog(
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
                                                                          await check_up_meter(
                                                                              limitedList_zone[index].ser);
                                                                          print(
                                                                              'Checked meter $datemiter for: ${limitedList_zone[index].ser} (${limitedList_zone[index].zn})');

                                                                          if (check_zser.where((e) => e.ser.toString() == '${limitedList_zone[index].ser}' && e.qty.toString() == '$datemiter').length ==
                                                                              0) {
                                                                            Map<String, dynamic>
                                                                                map =
                                                                                Map();
                                                                            map['ser'] =
                                                                                '${limitedList_zone[index].ser}';
                                                                            map['qty'] =
                                                                                '$datemiter';

                                                                            map['zn'] =
                                                                                '${limitedList_zone[index].zn}';

                                                                            ZoneModel
                                                                                zoneModelx =
                                                                                ZoneModel.fromJson(map);

                                                                            setState(() {
                                                                              check_zser.add(zoneModelx);
                                                                            });
                                                                          }

                                                                          setState(
                                                                              () {
                                                                            red_Trans_bill(); // Uncomment this if needed
                                                                          });
                                                                          Future.delayed(
                                                                              const Duration(seconds: 1),
                                                                              () {
                                                                            Insert_log.Insert_logs('จัดการ',
                                                                                'ดึงรายการค่าน้ำ-ค่าไฟ เดือน:$datemiter (${limitedList_zone[index].zn})');
                                                                            Navigator.pop(context);
                                                                          });
                                                                        },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  (check_zser.where((e) => e.ser.toString() == '${limitedList_zone[index].ser}' && e.qty.toString() == '$datemiter').length !=
                                                                          0)
                                                                      // (check_zser.contains('${limitedList_zone[index].ser}') ==
                                                                      //         true)
                                                                      ? Icon(
                                                                          Icons
                                                                              .check_box,
                                                                          color:
                                                                              Colors.green[800])
                                                                      : SizedBox(),
                                                                  Container(
                                                                    child:
                                                                        Center(
                                                                      child: Translate.TranslateAndSetText(
                                                                          (check_zser.where((e) => e.ser.toString() == '${limitedList_zone[index].ser}' && e.qty.toString() == '$datemiter').length != 0)
                                                                              ? 'ดึงอีกครั้ง'
                                                                              : 'ดึงมิเตอร์ น้ำ-ไฟ',
                                                                          ManageScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          2),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                    ))));
                                      })),
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
                                                  _scrollController1.animateTo(
                                                    0,
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    curve: Curves.easeOut,
                                                  );
                                                },
                                                child: Container(
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
                                                                          8)),
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: const Text(
                                                      'Top',
                                                      style: TextStyle(
                                                          color: Colors.grey,
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
                                                  _scrollController1.animateTo(
                                                    position,
                                                    duration: const Duration(
                                                        seconds: 1),
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
                                                                Radius.circular(
                                                                    6),
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
                                                      const EdgeInsets.all(3.0),
                                                  child: const Text(
                                                    'Down',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 10.0,
                                                        fontFamily: FontWeight_
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
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                          topLeft:
                                                              Radius.circular(
                                                                  6),
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
                                                    const EdgeInsets.all(3.0),
                                                child: const Text(
                                                  'Scroll',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10.0,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T),
                                                )),
                                            InkWell(
                                              onTap: _moveDown1,
                                              child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
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
                            ]))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///----------------->

  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  ///Get_all_now
  _showMyDialog() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
            titlePadding: const EdgeInsets.all(0.0),
            contentPadding: const EdgeInsets.all(10.0),
            actionsPadding: const EdgeInsets.all(6.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      Statas_Get_all = 1;
                    });
                    // Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.highlight_off,
                        size: 30, color: Colors.red[700]),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 80,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.orange[700],
                    ),
                    //  Image.asset(
                    //   "images/gif-LOGOchao.gif",
                    //   fit: BoxFit.cover,
                    //   height: 50,
                    //   width: 80,
                    // ),
                  ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            (Statas_Get_all == 1)
                                ? 'กำลังหยุดดึง'
                                : (Get_all_now == null)
                                    ? '...'
                                    : '${Get_all_now}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (Statas_Get_all == 1)
                                  ? Colors.orange[700]
                                  : Colors.green[700],
                              // fontWeight:
                              //     FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        );
                      })
                ],
              ),
            ),
          );
        });
  }
}
