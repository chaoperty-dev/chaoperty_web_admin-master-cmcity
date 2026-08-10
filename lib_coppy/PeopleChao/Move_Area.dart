import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/Model/GetWht_Model.dart';
import 'package:chaoperty/Style/colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AdminScaffold/AdminScaffold.dart';
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetContractx_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/areak_model.dart';
import '../Model/vat_SC_model.dart';
import '../Responsive/responsive.dart';

class Move_Area extends StatefulWidget {
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  const Move_Area({
    super.key,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
  });

  @override
  State<Move_Area> createState() => _Move_AreaState();
}

class _Move_AreaState extends State<Move_Area> {
  List<TeNantModel> teNantModels = [];
  String? areanew,
      namenew,
      namemake,
      Sercid,
      cc_datecid,
      s_datecid,
      l_datecid,
      zone_contact,
      zone_qty,
      zone_rent,
      zone_contactname,
      area_more_lncode,
      area_more_area,
      area_more_rent;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<AreaModel> areaModels = [];
  List<AreaModel> _areaModels = <AreaModel>[];
  List<AreakModel> selected_Area = [];
  List<String> area_sum_Area = [];
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read_GC_teNant();
  }

  Future<Null> read_GC_teNant() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tenantlook.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      // if (result != null) {
      for (var map in result) {
        TeNantModel teNantModel = TeNantModel.fromJson(map);
        var area_sum = teNantModel.aser!.split(',');
        setState(() {
          area_sum_Area = area_sum;
          areanew = teNantModel.area_c;
          namemake = teNantModel.name_user;
          namenew = teNantModel.cname;
          Sercid = teNantModel.ser;
          cc_datecid = teNantModel.cc_date;
          s_datecid = teNantModel.sdate;
          l_datecid = teNantModel.ldate;
          zone_contact = teNantModel.zser;
          zone_contactname = teNantModel.zn;
          zone_qty = teNantModel.qty;
          zone_rent = teNantModel.area;
          teNantModels.add(teNantModel);
        });
      }
      // } else {
      //   SharedPreferences preferences = await SharedPreferences.getInstance();

      //   String? _route = preferences.getString('route');
      //   MaterialPageRoute materialPageRoute = MaterialPageRoute(
      //       builder: (BuildContext context) => AdminScafScreen(route: _route));
      //   Navigator.pushAndRemoveUntil(
      //       context, materialPageRoute, (route) => false);
      // }
    } catch (e) {}
    // print(
    //     'area_sum_Area ${area_sum_Area.map((e) => e)} ${area_sum_Area.length}');
    read_GC_area();
  }

  Future<Null> read_GC_area() async {
    if (areaModels.length != 0) {
      areaModels.clear();
      _areaModels.clear();
      selected_Area.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone_contact';
    print(url);
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);

      // if (result != null) {
      for (var map in result) {
        AreaModel areaModel = AreaModel.fromJson(map);
        setState(() {
          if (areaModel.quantity == null) {
            areaModels.add(areaModel);
          }
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppbackgroundColor.TiTile_Colors,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 25,
                            maxLines: 1,
                            'พื้นที่เดิม',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T
                                //fontSize: 10.0
                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.26,
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
                    width: MediaQuery.of(context).size.width,
                    child: area_data(),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppbackgroundColor.TiTile_Colors,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(8.0),
                              child: const Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  'เลือกพื้นที่',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T
                                      //fontSize: 10.0
                                      //fontSize: 10.0
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.width * 0.26,
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
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.count(
                                  crossAxisCount: 6,
                                  children: [
                                    for (int index = 0;
                                        index < areaModels.length;
                                        index++)
                                      Card(
                                          child: InkWell(
                                        onTap: () async {
                                          // setState(() {
                                          //   area_more_lncode =
                                          //       areaModels[index].lncode;
                                          //   area_more_area =
                                          //       areaModels[index].area;
                                          //   area_more_rent =
                                          //       areaModels[index].rent;
                                          // });

                                          if (selected_Area.length >=
                                              area_sum_Area.length) {
                                            /////---------------->
                                            setState(() {
                                              selected_Area.removeWhere(
                                                  (area) =>
                                                      area.ser ==
                                                      areaModels[index].ser);
                                            });
                                            /////---------------->
                                            if ((selected_Area.length >=
                                                area_sum_Area.length)) {
                                              Dialog_errorMax();
                                            } else {}
                                            /////---------------->
                                          } else {
                                            // print(areakModels[index].aserQout);
                                            Map<String, dynamic> map = Map();
                                            map['ser'] =
                                                '${areaModels[index].ser}';
                                            map['datex'] =
                                                '${areaModels[index].datex}';
                                            map['timex'] =
                                                '${areaModels[index].timex}';
                                            // map['cser'] = '${nodeDatas[Index].cser}';
                                            map['aser'] =
                                                '${areaModels[index].aser}';
                                            map['aserQout'] =
                                                '${areaModels[index].quantity}';
                                            map['lncode'] =
                                                '${areaModels[index].lncode}';
                                            // map['sdate'] = '${nodeDatas[Index].sdate}';
                                            // map['ldate'] = '${nodeDatas[Index].ldate}';
                                            // map['dataUpdate'] =
                                            //     '${nodeDatas[Index].dataUpdate}';
                                            map['rent'] =
                                                '${areaModels[index].rent}';
                                            map['area'] =
                                                '${areaModels[index].area}';
                                            map['zn'] =
                                                '${areaModels[index].zn}';

                                            AreakModel areakModel_add =
                                                AreakModel.fromJson(map);
                                            // print(areakModel_add.type);

                                            bool exists = selected_Area.any(
                                                (area) =>
                                                    area.ser ==
                                                    areakModel_add.ser);
                                            if (!exists) {
                                              setState(() {
                                                selected_Area
                                                    .add(areakModel_add);
                                              });
                                            } else {
                                              setState(() {
                                                selected_Area.removeWhere(
                                                    (area) =>
                                                        area.ser ==
                                                        areaModels[index].ser);
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                            color: (selected_Area.any((area) =>
                                                    area.ser ==
                                                    areaModels[index].ser))
                                                ? Colors.green[900]
                                                : Colors.white,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            height: 100,
                                            padding: EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: AutoSizeText(
                                                    minFontSize: 12,
                                                    maxFontSize: 25,
                                                    maxLines: 2,
                                                    '${areaModels[index].lncode}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: (selected_Area
                                                                .any((area) =>
                                                                    area.ser ==
                                                                    areaModels[
                                                                            index]
                                                                        .ser))
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T
                                                        //fontSize: 10.0
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ),
                                                Center(
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 16,
                                                    maxLines: 1,
                                                    '${areaModels[index].area}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: (selected_Area
                                                                .any((area) =>
                                                                    area.ser ==
                                                                    areaModels[
                                                                            index]
                                                                        .ser))
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ),
                                                Center(
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: 16,
                                                    maxLines: 1,
                                                    '${nFormat.format(double.parse(areaModels[index].rent!))}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: (selected_Area
                                                                .any((area) =>
                                                                    area.ser ==
                                                                    areaModels[
                                                                            index]
                                                                        .ser))
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppbackgroundColor.TiTile_Colors,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(8.0),
                              child: const Align(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  'ข้อมูลการย้าย',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T
                                      //fontSize: 10.0
                                      //fontSize: 10.0
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * 0.26,
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
                      padding: EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    'เลขที่สัญญา :',
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text('${widget.Get_Value_cid}'),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 15,
                                                'พื้นที่',
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text('$areanew'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 15,
                                                'โซน',
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text('$zone_contactname'),
                                            ),
                                            Expanded(
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 15,
                                                'จำนวน',
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text('$zone_qty'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 15,
                                                'ขนาด',
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text('$zone_rent'),
                                            ),
                                            Expanded(
                                              child: AutoSizeText(
                                                minFontSize: 10,
                                                maxFontSize: 15,
                                                'ตร.ม',
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    'ย้ายไป',
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: selected_Area.length == 0
                                    ? SizedBox()
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      'พื้นที่',
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                        '${selected_Area.map((e) => e.lncode).toString().substring(1, selected_Area.map((e) => e.lncode).toString().length - 1)}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      'โซน',
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        '$zone_contactname'),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      'จำนวน',
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        '${selected_Area.length}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      'ขนาด',
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                        '${nFormat.format(selected_Area.map((e) => double.parse(e.area!)).reduce((a, b) => a + b))}'),
                                                  ),
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      'ตร.ม',
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      'ราคา',
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                        '${nFormat.format(selected_Area.map((e) => double.parse(e.rent!)).reduce((a, b) => a + b))}'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (selected_Area.length !=
                                          area_sum_Area.length) {
                                        Dialog_errormove();
                                      } else {
                                        move_area_item();
                                      }
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              OutlinedBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30))),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blue.shade900),
                                    ),
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: AutoSizeText(
                                          minFontSize: 6,
                                          maxFontSize: 18,
                                          maxLines: 1,
                                          "ย้ายพื้นที่",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: Font_.Fonts_T
                                              //fontSize: 10.0
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ]);
  }

  ListView area_data() {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(8),
      itemCount: teNantModels.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'พื้นที่',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].ln}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'โซน',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].zn}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'จำนวน',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].qty}'),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'ขนาด',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].area}'),
                        ),
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'ตร.ม',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'ชื่อร้าน',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].sname}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'ประเถท',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].stype}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'ชื่อผู้เช่า',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].cname}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'ที่อยู่',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].attn}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'เบอร์โทร',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].tel}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'เลขบัตรประชาชน',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].tax}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            'Gmail',
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text('${teNantModels[index].email}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Dialog_errorMax() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "ย้ายได้สูงสุด ${area_sum_Area.length} พื้นที่",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Dialog_errormove() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "จำนวนพื้นที่ไม่ถูกต้อง",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }

  Future<Null> move_area_item() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    // var move_area = selected_Area
    //     .map((e) => e.ser)
    //     .toString()
    //     .substring(1, selected_Area.map((e) => e.ser).toString().length - 1);

    // var move_area_ln = selected_Area
    //     .map((e) => e.lncode)
    //     .toString()
    //     .substring(1, selected_Area.map((e) => e.lncode).toString().length - 1);

    for (var i = 0; i < selected_Area.length; i++) {
      var move_area = selected_Area[i].ser!.trim();
      var move_area_ln = selected_Area[i].lncode!.trim();
      var move_area_ln_old = area_sum_Area[i].trim();

      String url =
          '${MyConstant().domain}/move_area.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&move_area=$move_area&move_area_ln=$move_area_ln&move_area_ln_old=$move_area_ln_old&user=$user';
      print(url);
      try {
        var response = await httpClient.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result.toString() == 'true') {}
      } catch (e) {}
    }

    var move_area = selected_Area
        .map((e) => e.ser)
        .toString()
        .substring(1, selected_Area.map((e) => e.ser).toString().length - 1);

    var move_area_ln = selected_Area
        .map((e) => e.lncode)
        .toString()
        .substring(1, selected_Area.map((e) => e.lncode).toString().length - 1);
    String url =
        '${MyConstant().domain}/move_area_con.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&move_area=$move_area&move_area_ln=$move_area_ln&user=$user';
    // print(url);
    try {
      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs('ผู้เช่า',
            'เรียกดู>>ย้ายพื้นที่ $areanew ไป ${selected_Area.map((e) => e.lncode)}');
        String? _route = preferences.getString('route');
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
            builder: (BuildContext context) => AdminScafScreen(route: _route));
        Navigator.pushAndRemoveUntil(
            context, materialPageRoute, (route) => false);
      }
    } catch (e) {}
  }
}
