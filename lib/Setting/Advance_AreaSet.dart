import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Canvas/generated_nodes.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/Count_area_model.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetArea_type_model.dart';
import '../Model/GetContract_Rownum_Model.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Draginto_example.dart';

class Advance_AreaSetting extends StatefulWidget {
  const Advance_AreaSetting({super.key});

  @override
  State<Advance_AreaSetting> createState() => _Advance_AreaSettingState();
}

class _Advance_AreaSettingState extends State<Advance_AreaSetting> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("#,##0", "en_US");
  final TextEditingController Dropdown_Controller = TextEditingController();
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  //////////////////------------------------------>
  List<RenTalModel> renTalModels = [];
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> _zoneModels = <ZoneModel>[];
  List<AreaModel> limitedList_areaModels = [];

  List<AreaModel> areaModels = [];
  List<AreaModel> limitedList_areaModels_ = <AreaModel>[];
  List<AreaModel> _areaModels = <AreaModel>[];
  List<Areatype> areatypes = [];
  List<Areatype> _areatypes = <Areatype>[];
  List<TextEditingController> Dropdown_Controller_zone = [];
  String? zone_ser_area, zone_name_area;
  //////////////////------------------------------>
  int edit_lock = 0;
  int Ser_Zone = 0;
  int renTal_lavel = 0;
  int? ser_indexShow;
  int? pkqty = 0, pkuser, countarae = 0, mass_on;
  String? Arrange;

  //////////////////------------------------------>
  String name_Zone = 'ทั้งหมด';
  String? renTal_user, renTal_name, renTal_ser, zone_ser, zone_name;
  String? rtname, type, typex, renname, pkname, ser_Zonex;

  String? base64_Imgmap, foder;
  String? ser_user,
      position_user,
      fname_user,
      lname_user,
      email_user,
      utype_user,
      permission_user,
      tel_user,
      img_,
      img_logo,
      acc_2,
      lineqr;
  List<ContractRownumModel> contractRownumModels = [];
  List<DragAndDropList> _contents = <DragAndDropList>[];
  final zone_text = TextEditingController();

  //////////////////------------------------------>
  @override
  void initState() {
    Dropdown_Controller_zone = List.generate(4, (_) => TextEditingController());
    super.initState();
    read_GC_rental();
    read_GC_zone();
    read_GC_area();
    read_Area_type();
    read_GC_area_count();
    read_GC_rownum().then((value) => con_row());
  }

  ///////////////--------------------------------------------->
  final ScrollController _scrollController = ScrollController();
  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _contents[oldListIndex].children.removeAt(oldItemIndex);
      _contents[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _contents.removeAt(oldListIndex);
      _contents.insert(newListIndex, movedList);
    });
  }

  ///////////////--------------------------------------------->
  Future<Null> edit_SW(int sub_zone, String zone) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? ren = preferences.getString('renTalSer');
    String? ser_user = preferences.getString('ser');
    var vser = zone;
    String url =
        '${MyConstant().domain}/UpC_rownum.php?isAdd=true&ren=$ren&vser=$vser&value=${sub_zone + 1}&ser_user=$ser_user';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() == 'true') {
        // setState(() {
        //   read_GC_rownum();
        // });
      } else {}
    } catch (e) {}
  }

///////////////--------------------------------------------->
  Future<Null> read_GC_rownum() async {
    setState(() {
      contractRownumModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = (name_Zone.toString().trim() == 'ทั้งหมด')
        ? '${MyConstant().domain}/GC_areaAll_rownum.php?isAdd=true&ren=$ren&zone=0'
        : '${MyConstant().domain}/GC_areaAll_rownum.php?isAdd=true&ren=$ren&zone=$ser_Zonex';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        if (areaModels.length != 0) {
          areaModels.clear();
        }
        for (var map in result) {
          ContractRownumModel contractRownumModel =
              ContractRownumModel.fromJson(map);
          setState(() {
            contractRownumModels.add(contractRownumModel);
          });
        }
      } else {}
    } catch (e) {}
  }

  ///////////////--------------------------------------------->
  List<DragAndDropList> con_row() {
    return _contents = List.generate(1, (index) {
      return DragAndDropList(
        contentsWhenEmpty: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            "$name_Zone",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        lastTarget: Text(
          "$name_Zone",
          style: TextStyle(color: Colors.transparent),
        ),
        header: Column(
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$name_Zone',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: <DragAndDropItem>[
          for (int indexc = 0; indexc < contractRownumModels.length; indexc++)
            DragAndDropItem(
              feedbackWidget: Text("${contractRownumModels[indexc].ser}"),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 12),
                      child: Text(
                        '${contractRownumModels[indexc].sw}',
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 12),
                      child: Text(
                        '${contractRownumModels[indexc].ln}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 12),
                      child: Text(
                        '${contractRownumModels[indexc].sname}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  )
                ],
              ),
            )
        ],
      );
    });
  }

///////////////--------------------------------------------->
  Future<Null> read_Area_type() async {
    setState(() {
      areatypes.clear();
      _areatypes.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_areatype.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      for (var map in result) {
        Areatype areatypess = Areatype.fromJson(map);
        setState(() {
          areatypes.add(areatypess);
        });
      }
      setState(() {
        _areatypes = areatypes;
      });
    } catch (e) {}
  }

  //////////////////------------------------------>
  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });
  }

  //////////////////------------------------------>
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

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
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
          var open_setx = int.parse(renTalModel.open_set!);
          var open_set_datex = int.parse(renTalModel.open_set_date!);
          var mass_onx = int.parse(renTalModel.mass_on!);
          var imglineqrx = renTalModel.imglineqr;
          setState(() {
            renTal_ser = ren!;
            acc_2 = renTalModel.acc2!;
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            pkqty = pkqtyx;
            pkuser = pkuserx;
            pkname = pkx;
            img_ = img;
            img_logo = imglogo;

            mass_on = mass_onx;
            lineqr = imglineqrx;
            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
    // //print('name>>>>>  $renname');
  }

  //////////////////------------------------------>
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      setState(() {
        zoneModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      Map<String, dynamic> map = Map();
      map['ser'] = '0';
      map['rser'] = '0';
      map['zn'] = 'ทั้งหมด';
      map['qty'] = '0';
      map['img'] = '0';
      map['data_update'] = '0';

      ZoneModel zoneModelx = ZoneModel.fromJson(map);

      setState(() {
        zoneModels.add(zoneModelx);
      });

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        setState(() {
          zoneModels.add(zoneModel);
        });
      }
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
      setState(() {
        _zoneModels = zoneModels;
      });
    } catch (e) {}
  }

  /////////---------------------------------------------------->
  Future<Null> read_GC_area_count() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_areaCount.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          AreaCountModel areaCountModel = AreaCountModel.fromJson(map);
          var c = int.parse(areaCountModel.counta!);
          setState(() {
            countarae = c;
          });
        }
      } else {}
    } catch (e) {}
  }

  /////////---------------------------------------------------->
  Future<Null> read_GC_area() async {
    var start = DateTime.now();
    setState(() {
      offset = 0;
      endIndex = 0;
      areaModels.clear();
      limitedList_areaModels.clear();
      limitedList_areaModels_.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = (name_Zone.toString().trim() == 'ทั้งหมด' || name_Zone == null)
        ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren'
        : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$Ser_Zone';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        if (areaModels.length != 0) {
          areaModels.clear();
        }
        for (var map in result) {
          AreaModel areaModel = AreaModel.fromJson(map);
          setState(() {
            limitedList_areaModels.add(areaModel);
          });
        }
      } else {}
      setState(() {
        limitedList_areaModels_ = limitedList_areaModels;
        // zone_ser = preferences.getString('zoneSer');
        // zone_name = preferences.getString('zonesName');
      });
      read_tenant_limit();
    } catch (e) {}
  }

  Future<Null> read_tenant_limit() async {
    setState(() {
      endIndex = offset + limit;
      areaModels = limitedList_areaModels.sublist(
          offset, // Start index
          (endIndex <= limitedList_areaModels.length)
              ? endIndex
              : limitedList_areaModels.length // End index
          );
    });
    //limitedList_teNantModels
  }

  /////////---------------------------------------------------->
  _searchBar_zone() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
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
        // //print(text);
        text = text.toLowerCase();
        setState(() {
          zoneModels = _zoneModels.where((zoneModelss) {
            var notTitle = zoneModelss.zn.toString().toLowerCase();
            // var notTitle2 = zoneModelss.lncode.toString().toLowerCase();
            // var notTitle3 = areaModelss.area.toString().toLowerCase();
            // var notTitle4 = areaModelss.rent.toString().toLowerCase();
            // var notTitle5 = areaModels.cname.toString().toLowerCase();
            return notTitle.contains(text);
          }).toList();
        });
      },
    );
  }

  _searchBar_areatype() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
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
        // //print(text);
        text = text.toLowerCase();
        setState(() {
          areatypes = _areatypes.where((areatypess) {
            var notTitle = areatypess.unit.toString().toLowerCase();
            // var notTitle2 = zoneModelss.lncode.toString().toLowerCase();
            // var notTitle3 = areaModelss.area.toString().toLowerCase();
            // var notTitle4 = areaModelss.rent.toString().toLowerCase();
            // var notTitle5 = areaModels.cname.toString().toLowerCase();
            return notTitle.contains(text);
          }).toList();
        });
      },
    );
  }

  /////////---------------------------------------------------->
  _searchBar_area() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
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
        // //print(text);
        text = text.toLowerCase();
        setState(() {
          areaModels = limitedList_areaModels_.where((areaModelss) {
            var notTitle = areaModelss.ln.toString().toLowerCase();
            var notTitle2 = areaModelss.lncode.toString().toLowerCase();
            var notTitle3 = areaModelss.areatype.toString().toLowerCase();
            return notTitle.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text);
          }).toList();
        });
      },
    );
  }

  /////////---------------------------------------------------->
  ScrollController _scrollController1 = ScrollController();

  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

//////---------------------------------------------->
  Widget Next_page_area() {
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
                        '${(endIndex / limit)}/${(limitedList_areaModels.length / limit).ceil()}',
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
                        onTap: (endIndex >= limitedList_areaModels.length)
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  // tappedIndex_ = '';
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
                          color: (endIndex >= limitedList_areaModels.length)
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

  ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  /////////---------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    // border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
              // Row(
              //   children: [
              //     Expanded(child: SizedBox()),
              //     Padding(
              //       padding: const EdgeInsets.all(4.0),
              //       child: ElevatedButton(
              //         onPressed: () async {
              //           setState(() {
              //             Arrange = 'Arrange_Area';
              //           });
              //         },
              //         style: ButtonStyle(
              //           //  backgroundColor:
              //           // MaterialStateProperty.all<
              //           //     Color>(Colors.green),
              //           backgroundColor: MaterialStateProperty.all<Color>(
              //               (Ser_Zone == 0 || Ser_Zone == null)
              //                   ? Color.fromARGB(255, 131, 153, 163)
              //                   : Color.fromARGB(255, 37, 118, 184)),
              //         ),
              //         child: Center(
              //           child: Translate.TranslateAndSetText(
              //               'จัดลำดับ',
              //               Colors.white,
              //               TextAlign.start,
              //               null,
              //               Font_.Fonts_T,
              //               14,
              //               1),
              //         ),
              //       ),
              //     ),
              //     Padding(
              //       padding: const EdgeInsets.all(4.0),
              //       child: ElevatedButton(
              //         onPressed: () async {
              //           setState(() {
              //             Arrange = 'Arrange_Zone';
              //           });
              //         },
              //         style: ButtonStyle(
              //           //  backgroundColor:
              //           // MaterialStateProperty.all<
              //           //     Color>(Colors.green),
              //           backgroundColor: MaterialStateProperty.all<Color>(
              //               (Ser_Zone == 0 || Ser_Zone == null)
              //                   ? Color.fromARGB(255, 145, 131, 163)
              //                   : Color.fromARGB(255, 106, 37, 184)),
              //         ),
              //         child: Center(
              //           child: Translate.TranslateAndSetText(
              //               'จัดหมวดโซนใหญ่',
              //               Colors.white,
              //               TextAlign.start,
              //               null,
              //               Font_.Fonts_T,
              //               14,
              //               1),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // if (Arrange != 'Arrange_Area' && Arrange != 'Arrange_Zone')
              Container(
                width: MediaQuery.of(context).size.width,
                // height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      Arrange = null;
                                    });
                                  },
                                  style: ButtonStyle(
                                    //  backgroundColor:
                                    // MaterialStateProperty.all<
                                    //     Color>(Colors.green),
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>((Arrange !=
                                            null)
                                        ? Color.fromARGB(255, 170, 148, 150)
                                        : Color.fromARGB(255, 184, 37, 135)),
                                  ),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'ข้อมูลพื้นที่',
                                        Colors.white,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      Arrange = 'Arrange_Map';
                                    });
                                  },
                                  style: ButtonStyle(
                                    //  backgroundColor:
                                    // MaterialStateProperty.all<
                                    //     Color>(Colors.green),
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>((Arrange !=
                                            'Arrange_Map')
                                        ? Color.fromARGB(255, 164, 170, 148)
                                        : Color.fromARGB(255, 184, 169, 37)),
                                  ),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'แผนผังพื้นที่',
                                        Colors.white,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      Arrange = 'Arrange_Area';
                                    });
                                  },
                                  style: ButtonStyle(
                                    //  backgroundColor:
                                    // MaterialStateProperty.all<
                                    //     Color>(Colors.green),
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>((Arrange !=
                                            'Arrange_Area')
                                        ? Color.fromARGB(255, 148, 157, 170)
                                        : Color.fromARGB(255, 37, 118, 184)),
                                  ),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'จัดลำดับพื้นที่',
                                        Colors.white,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      Arrange = 'Arrange_Zone';
                                    });
                                  },
                                  style: ButtonStyle(
                                    //  backgroundColor:
                                    // MaterialStateProperty.all<
                                    //     Color>(Colors.green),
                                    backgroundColor: MaterialStateProperty.all<
                                        Color>((Arrange !=
                                            'Arrange_Zone')
                                        ? Color.fromARGB(255, 160, 148, 170)
                                        : Color.fromARGB(255, 106, 37, 184)),
                                  ),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'จัดหมวดโซนใหญ่',
                                        Colors.white,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Row(
                    //   children: [
                    //     Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Container(
                    //         width: 150,
                    //         decoration: const BoxDecoration(
                    //           // color: Colors.yellow[200],
                    //           borderRadius: BorderRadius.only(
                    //               topLeft: Radius.circular(10),
                    //               topRight: Radius.circular(10),
                    //               bottomLeft: Radius.circular(10),
                    //               bottomRight: Radius.circular(10)),
                    //         ),
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Translate.TranslateAndSetText(
                    //             '4.พื้นที่ทั้งหมด',
                    //             SettingScreen_Color.Colors_Text2_,
                    //             TextAlign.start,
                    //             null,
                    //             Font_.Fonts_T,
                    //             14,
                    //             1),
                    //         // Text('4.ชื่อสถานที่',
                    //         //     textAlign: TextAlign.start,
                    //         //     maxLines: 3,
                    //         //     overflow: TextOverflow.ellipsis,
                    //         //     softWrap: false,
                    //         //     style: TextStyle(
                    //         //         fontSize: 15,
                    //         //         color: SettingScreen_Color
                    //         //             .Colors_Text2_,
                    //         //         fontFamily: Font_.Fonts_T
                    //         //         // fontWeight: FontWeight.bold,
                    //         //         )),
                    //       ),
                    //     ),
                    //     // Padding(
                    //     //     padding: EdgeInsets.all(8.0),
                    //     //     child: Translate.TranslateAndSetText(
                    //     //         'พื้นที่ทั้งหมด ',
                    //     //         SettingScreen_Color.Colors_Text2_,
                    //     //         TextAlign.start,
                    //     //         null,
                    //     //         Font_.Fonts_T,
                    //     //         14,
                    //     //         1)),
                    //     Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.all(Radius.circular(10)),
                    //         border: Border.all(color: Colors.grey, width: 1),
                    //       ),
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Text(
                    //           '${nFormat2.format(double.parse(countarae.toString()))}',

                    //           // '${areaModels.length}',
                    //           maxLines: 3,
                    //           overflow: TextOverflow.ellipsis,
                    //           softWrap: false,
                    //           textAlign: TextAlign.center,
                    //           style: const TextStyle(
                    //               fontSize: 15,
                    //               color: SettingScreen_Color.Colors_Text2_,
                    //               fontFamily: Font_.Fonts_T
                    //               // fontWeight: FontWeight.bold,
                    //               )),
                    //     ),
                    //     Padding(
                    //       padding: EdgeInsets.all(8.0),
                    //       child: Translate.TranslateAndSetText(
                    //           'พื้นที่คงเหลือ',
                    //           SettingScreen_Color.Colors_Text2_,
                    //           TextAlign.start,
                    //           null,
                    //           Font_.Fonts_T,
                    //           14,
                    //           1),
                    //     ),
                    //     Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.all(Radius.circular(10)),
                    //         border: Border.all(color: Colors.grey, width: 1),
                    //       ),
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Text(
                    //           '${nFormat2.format(double.parse(pkqty.toString()) - double.parse(countarae.toString()))}',

                    //           // '${pkqty! - countarae!}',
                    //           maxLines: 3,
                    //           overflow: TextOverflow.ellipsis,
                    //           softWrap: false,
                    //           textAlign: TextAlign.center,
                    //           style: const TextStyle(
                    //               fontSize: 15,
                    //               color: SettingScreen_Color.Colors_Text2_,
                    //               fontFamily: Font_.Fonts_T
                    //               // fontWeight: FontWeight.bold,
                    //               )),
                    //     ),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog<String>(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) => Form(
                              key: _formKey,
                              child: AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                backgroundColor:
                                    AppbackgroundColor.Sub_Abg_Colors,
                                titlePadding: const EdgeInsets.all(0.0),
                                contentPadding: const EdgeInsets.all(10.0),
                                actionsPadding: const EdgeInsets.all(6.0),
                                title: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'เพิ่มโซนพื้นที่',
                                        SettingScreen_Color.Colors_Text1_,
                                        TextAlign.left,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        16,
                                        1),
                                  ),
                                ),
                                content: Container(
                                  // height: MediaQuery.of(context).size.height / 1.5,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  decoration: const BoxDecoration(
                                    // color: Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    // border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        StreamBuilder(
                                            stream: Stream.periodic(
                                                const Duration(seconds: 0)),
                                            builder: (context, snapshot) {
                                              return (zone_text.text == '')
                                                  ? SizedBox()
                                                  : Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Translate.TranslateAndSetText(
                                                                '# ชื่อโซนที่ใกล้เครียง : ',
                                                                SettingScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.left,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                            Expanded(
                                                                flex: 1,
                                                                child:
                                                                    ScrollConfiguration(
                                                                  behavior: ScrollConfiguration.of(
                                                                          context)
                                                                      .copyWith(
                                                                          dragDevices: {
                                                                        PointerDeviceKind
                                                                            .touch,
                                                                        PointerDeviceKind
                                                                            .mouse,
                                                                      }),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          '${zoneModels.where((zoneModelss) {
                                                                                var notTitle = zoneModelss.zn.toString().trim().toLowerCase();
                                                                                var notTitle2 = zoneModelss.zn.toString().trim();

                                                                                return notTitle.contains(zone_text.text.toString().trim()) || notTitle2.contains(zone_text.text.toString().trim());
                                                                              }).map((model) => model.zn).join(' , ')}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                            // fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                        Divider(
                                                          color:
                                                              Colors.grey[300],
                                                          height: 4.0,
                                                        ),
                                                      ],
                                                    );
                                            }),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ชื่อโซน',
                                                      SettingScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.center,
                                                      FontWeight.bold,
                                                      FontWeight_.Fonts_T,
                                                      14,
                                                      1),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            // width: 200,
                                            child: TextFormField(
                                              controller: zone_text,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
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
                                                  fillColor: Colors.white
                                                      .withOpacity(0.3),
                                                  filled: true,
                                                  // prefixIcon:
                                                  //     const Icon(Icons.person_pin, color: Colors.black),
                                                  // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(15),
                                                      topLeft:
                                                          Radius.circular(15),
                                                      bottomRight:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(15),
                                                      topLeft:
                                                          Radius.circular(15),
                                                      bottomRight:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15),
                                                    ),
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  labelText: 'ชื่อโซน',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.black54,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                  )),
                                              // inputFormatters: <
                                              //     TextInputFormatter>[
                                              //   FilteringTextInputFormatter
                                              //       .deny(RegExp("[' ']")),
                                              //   // for below version 2 use this
                                              //   FilteringTextInputFormatter
                                              //       .allow(RegExp(
                                              //           r'[a-z A-Z 1-9]')),
                                              //   // for version 2 and greater youcan also use this
                                              //   // FilteringTextInputFormatter
                                              //   //     .digitsOnly
                                              // ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      const Divider(
                                        color: Colors.grey,
                                        height: 4.0,
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: StreamBuilder(
                                                  stream: Stream.periodic(
                                                      const Duration(
                                                          seconds: 10)),
                                                  builder: (context, snapshot) {
                                                    return Container(
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                        color: (zoneModels.any(
                                                                    (zoneModelss) {
                                                                  return zoneModelss
                                                                          .zn
                                                                          .toString()
                                                                          .trim() ==
                                                                      '${zone_text.text}';
                                                                }) ==
                                                                true)
                                                            ? Colors.grey
                                                            : Colors.green,
                                                        borderRadius:
                                                            BorderRadius.only(
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
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: TextButton(
                                                        onPressed: (zoneModels.any(
                                                                    (zoneModelss) {
                                                                  return zoneModelss
                                                                          .zn
                                                                          .toString()
                                                                          .trim() ==
                                                                      '${zone_text.text}';
                                                                }) ==
                                                                true)
                                                            ? null
                                                            : () async {
                                                                if (_formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  SharedPreferences
                                                                      preferences =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  String? ren =
                                                                      preferences
                                                                          .getString(
                                                                              'renTalSer');
                                                                  String?
                                                                      ser_user =
                                                                      preferences
                                                                          .getString(
                                                                              'ser');

                                                                  var zonename =
                                                                      zone_text
                                                                          .text;

                                                                  String url =
                                                                      '${MyConstant().domain}/InC_zone_setring.php?isAdd=true&ren=$ren&ser_user=$ser_user&zonename=$zonename';

                                                                  try {
                                                                    var response =
                                                                        await http
                                                                            .get(Uri.parse(url));

                                                                    var result =
                                                                        json.decode(
                                                                            response.body);
                                                                    // //print(result);
                                                                    Insert_log.Insert_logs(
                                                                        'ตั้งค่า',
                                                                        'พื้นที่>>เพิ่มโซนพื้นที่(${zone_text.text.toString()})');
                                                                    if (result
                                                                            .toString() ==
                                                                        'true') {
                                                                      setState(
                                                                          () {
                                                                        zone_text
                                                                            .clear();
                                                                        read_GC_zone();
                                                                        read_GC_area();
                                                                        read_GC_area_count();
                                                                      });

                                                                      Navigator.pop(
                                                                          context,
                                                                          'OK');
                                                                    }
                                                                  } catch (e) {
                                                                    //  //print(e);
                                                                  }
                                                                }
                                                              },
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'บันทึก',
                                                                Colors.white,
                                                                TextAlign
                                                                    .center,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                width: 100,
                                                decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ยกเลิก',
                                                          Colors.white,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          //  backgroundColor:
                          // MaterialStateProperty.all<
                          //     Color>(Colors.green),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.orange,
                          ),
                        ),
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              '+ เพิ่มโซนพื้นที่',
                              Colors.white,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final _formKeytype = GlobalKey<FormState>();
                          final Add_type = TextEditingController();
                          final Rent_add = TextEditingController();
                          setState(() {
                            Rent_add.text = '0.00';
                          });
                          int ser_tap = 0;
                          showDialog<String>(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) => Form(
                              key: _formKey,
                              child: AlertDialog(
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                backgroundColor:
                                    AppbackgroundColor.Sub_Abg_Colors,
                                titlePadding: const EdgeInsets.all(0.0),
                                contentPadding: const EdgeInsets.all(10.0),
                                actionsPadding: const EdgeInsets.all(6.0),
                                title: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          // width: 200,
                                          child: Center(
                                            child: Text(
                                              'ประเภทพื้นที่',
                                              style: TextStyle(
                                                color: SettingScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.highlight_off,
                                              size: 30, color: Colors.red[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                content: Container(
                                    // height: MediaQuery.of(context).size.height / 1.5,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: const BoxDecoration(
                                      // color: Colors.grey[300],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      // border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: StreamBuilder(
                                        stream: Stream.periodic(
                                            const Duration(seconds: 0)),
                                        builder: (context, snapshot) {
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              ser_tap = 0;
                                                            });
                                                          },
                                                          style: ButtonStyle(
                                                            //  backgroundColor:
                                                            // MaterialStateProperty.all<
                                                            //     Color>(Colors.green),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<
                                                                        Color>(
                                                                    Colors.grey
                                                                        .shade700),
                                                          ),
                                                          child: Center(
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'ข้อมูลทั้งหมด',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              ser_tap = 1;
                                                            });
                                                          },
                                                          style: ButtonStyle(
                                                            //  backgroundColor:
                                                            // MaterialStateProperty.all<
                                                            //     Color>(Colors.green),
                                                            backgroundColor:
                                                                MaterialStateProperty.all<
                                                                        Color>(
                                                                    Colors.grey
                                                                        .shade700),
                                                          ),
                                                          child: Center(
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'เพิ่มข้อมูล',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                              (ser_tap == 1)
                                                  ? Expanded(
                                                      child: SizedBox(
                                                      height: 50,
                                                      child: Center(
                                                        child: Form(
                                                          key: _formKeytype,
                                                          child: Column(
                                                            // mainAxisAlignment:
                                                            //     MainAxisAlignment
                                                            //         .center,
                                                            children: [
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Translate.TranslateAndSetText(
                                                                    'ประเภทที่ต้องการเพิ่ม',
                                                                    Colors
                                                                        .black,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                              Container(
                                                                // height: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey[
                                                                          600]!
                                                                      .withOpacity(
                                                                          0.5),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              6)),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0.5,
                                                                        0.5,
                                                                        0.5,
                                                                        0.5),
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      Add_type,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'ระบุข้อมูล..';
                                                                    }
                                                                    return null;
                                                                  },

                                                                  // maxLength: 13,
                                                                  cursorColor:
                                                                      Colors
                                                                          .green,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    filled:
                                                                        true,
                                                                    // prefixIcon:
                                                                    //     const Icon(Icons.key, color: Colors.black),
                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    // labelText:
                                                                    //     'กรุณาระบุประเภทที่ต้องการเพิ่ม..',
                                                                    labelStyle: const TextStyle(
                                                                        color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                        // fontWeight: FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Translate.TranslateAndSetText(
                                                                    'ราคาที่ต้องการบวกเพิ่ม',
                                                                    Colors
                                                                        .black,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                              Container(
                                                                // height: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey[
                                                                          600]!
                                                                      .withOpacity(
                                                                          0.5),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              6)),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0.5,
                                                                        0.5,
                                                                        0.5,
                                                                        0.5),
                                                                child:
                                                                    TextFormField(
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  controller:
                                                                      Rent_add,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'ระบุข้อมูล..';
                                                                    }
                                                                    return null;
                                                                  },

                                                                  // maxLength: 13,
                                                                  cursorColor:
                                                                      Colors
                                                                          .green,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    fillColor:
                                                                        Colors
                                                                            .white,
                                                                    filled:
                                                                        true,
                                                                    // prefixIcon:
                                                                    //     const Icon(Icons.key, color: Colors.black),
                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    // labelText:
                                                                    //     'กรุณาระบุราคาที่ต้องการบวกเพิ่ม..',
                                                                    labelStyle: const TextStyle(
                                                                        color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                        // fontWeight: FontWeight.bold,
                                                                        fontFamily: Font_.Fonts_T),
                                                                  ),
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter
                                                                        .allow(RegExp(
                                                                            r'^\d*\.?\d*$')), // Allows digits & one dot
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    width: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight: Radius.circular(
                                                                              10),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        if (_formKeytype
                                                                            .currentState!
                                                                            .validate()) {
                                                                          SharedPreferences
                                                                              preferences =
                                                                              await SharedPreferences.getInstance();
                                                                          String?
                                                                              ren =
                                                                              preferences.getString('renTalSer');
                                                                          String?
                                                                              ser_user =
                                                                              preferences.getString('ser');
                                                                          var value_x =
                                                                              Add_type.text;
                                                                          var rent_addx =
                                                                              Rent_add.text;

                                                                          String
                                                                              url =
                                                                              '${MyConstant().domain}/UpAd_area_Type.php?isAdd=true&ren=$ren&ser_user=$ser_user&type=Add&valuex=$value_x&rentadd=$rent_addx';
                                                                          // //print(
                                                                          //     url);
                                                                          try {
                                                                            var response =
                                                                                await http.get(Uri.parse(url));

                                                                            var result =
                                                                                json.decode(response.body);
                                                                            // //print(result);
                                                                            if (result.toString() ==
                                                                                'true') {
                                                                              setState(() {
                                                                                Add_type.clear();
                                                                                read_Area_type();
                                                                                ser_tap = 0;
                                                                                // read_GC_area();
                                                                              });
                                                                            } else {}
                                                                          } catch (e) {}
                                                                        }
                                                                      },
                                                                      child: Translate.TranslateAndSetText(
                                                                          'บันทึก',
                                                                          Colors
                                                                              .white,
                                                                          TextAlign
                                                                              .center,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                  : Expanded(
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            // height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppbackgroundColor
                                                                  .TiTile_Colors,
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0)),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    8, 2, 2, 0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2.0),
                                                                      child: Translate.TranslateAndSetText(
                                                                          'ค้นหา',
                                                                          SettingScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .start,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1),

                                                                      // Text(
                                                                      //   'ค้นหา :',
                                                                      //   style: TextStyle(
                                                                      //     color: ReportScreen_Color
                                                                      //         .Colors_Text2_,
                                                                      //     fontWeight: FontWeight.bold,
                                                                      //     fontFamily: Font_.Fonts_T,
                                                                      //   ),
                                                                      // ),
                                                                    ),
                                                                    Expanded(
                                                                      // flex: 1,
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35, //Date_ser
                                                                        // width: 150,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppbackgroundColor.Sub_Abg_Colors,
                                                                          borderRadius: const BorderRadius.only(
                                                                              topLeft: Radius.circular(8),
                                                                              topRight: Radius.circular(8),
                                                                              bottomLeft: Radius.circular(8),
                                                                              bottomRight: Radius.circular(8)),
                                                                          border: Border.all(
                                                                              color: Colors.grey,
                                                                              width: 1),
                                                                        ),
                                                                        child:
                                                                            _searchBar_areatype(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(children: [
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Translate.TranslateAndSetText(
                                                                        'ประเภท',
                                                                        Colors
                                                                            .black,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .bold,
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Translate.TranslateAndSetText(
                                                                        'ราคาที่บวกเพิ่ม-ล็อกเสียบ',
                                                                        Colors
                                                                            .black,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .bold,
                                                                        FontWeight_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                  ),
                                                                ]),
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: SingleChildScrollView(
                                                                child: ListView.builder(
                                                                    controller: _scrollController1,
                                                                    // itemExtent: 50,
                                                                    physics: const AlwaysScrollableScrollPhysics(), //const NeverScrollableScrollPhysics(),
                                                                    shrinkWrap: true,
                                                                    itemCount: areatypes.length,
                                                                    itemBuilder: (BuildContext context, int index) {
                                                                      return Material(
                                                                          // color: tappedIndex_ ==
                                                                          //         index.toString()
                                                                          //     ? tappedIndex_Color.tappedIndex_Colors
                                                                          //     : AppbackgroundColor.Sub_Abg_Colors,
                                                                          child: Container(
                                                                              // color: tappedIndex_ ==
                                                                              //         index.toString()
                                                                              //     ? Colors.grey.shade300
                                                                              //     : null,
                                                                              child: ListTile(
                                                                                  title: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        // color: Colors.green[100]!
                                                                                        //     .withOpacity(0.5),
                                                                                        border: Border(
                                                                                          bottom: BorderSide(
                                                                                            color: Colors.black12,
                                                                                            width: 1,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      child: Row(children: [
                                                                                        InkWell(
                                                                                          onTap: (areatypes[index].qty.toString() != '0')
                                                                                              ? null
                                                                                              : () async {
                                                                                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                  String? ren = preferences.getString('renTalSer');
                                                                                                  String? ser_user = preferences.getString('ser');
                                                                                                  var tserx = areatypes[index].ser;
                                                                                                  String url = '${MyConstant().domain}/UpAd_area_Type.php?isAdd=true&ren=$ren&tser=$tserx&ser_user=$ser_user&type=Delete';
                                                                                                  //  //print(url);
                                                                                                  try {
                                                                                                    var response = await http.get(Uri.parse(url));

                                                                                                    var result = json.decode(response.body);
                                                                                                    // //print(result);
                                                                                                    if (result.toString() == 'true') {
                                                                                                      setState(() {
                                                                                                        read_Area_type();
                                                                                                        // read_GC_area();
                                                                                                      });
                                                                                                    } else {}
                                                                                                  } catch (e) {}
                                                                                                },
                                                                                          child: Icon(Icons.delete, color: (areatypes[index].qty.toString() != '0') ? Colors.grey[300] : Colors.red),
                                                                                        ),
                                                                                        Expanded(
                                                                                          flex: 1,
                                                                                          child: Container(
                                                                                            height: 35,
                                                                                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                                                                            child: TextFormField(
                                                                                              textAlign: TextAlign.start,
                                                                                              initialValue: areatypes[index].unit,
                                                                                              onFieldSubmitted: (value) async {
                                                                                                SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                String? ren = preferences.getString('renTalSer');
                                                                                                String? ser_user = preferences.getString('ser');
                                                                                                var tserx = areatypes[index].ser;
                                                                                                var value_x = value.toString();
                                                                                                String url = '${MyConstant().domain}/UpAd_area_Type.php?isAdd=true&ren=$ren&tser=$tserx&ser_user=$ser_user&type=Edit&valuex=$value_x&typerent=no';
                                                                                                //  //print(url);
                                                                                                try {
                                                                                                  var response = await http.get(Uri.parse(url));

                                                                                                  var result = json.decode(response.body);
                                                                                                  // //print(result);
                                                                                                  if (result.toString() == 'true') {
                                                                                                    setState(() {
                                                                                                      read_Area_type();
                                                                                                      // read_GC_area();
                                                                                                    });
                                                                                                  } else {}
                                                                                                } catch (e) {}
                                                                                              },
                                                                                              // maxLength: 13,
                                                                                              cursorColor: Colors.green,
                                                                                              decoration: InputDecoration(
                                                                                                fillColor: const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                                                                                                filled: true,
                                                                                                // prefixIcon:
                                                                                                //     const Icon(Icons.key, color: Colors.black),
                                                                                                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                                  borderSide: BorderSide(
                                                                                                    width: 1,
                                                                                                    color: Colors.green.shade800,
                                                                                                  ),
                                                                                                ),
                                                                                                enabledBorder: const OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                                  borderSide: BorderSide(
                                                                                                    width: 1,
                                                                                                    color: Colors.grey,
                                                                                                  ),
                                                                                                ),
                                                                                                // labelText: 'PASSWOED',
                                                                                                labelStyle: const TextStyle(
                                                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                                    // fontWeight: FontWeight.bold,
                                                                                                    fontFamily: Font_.Fonts_T),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          flex: 1,
                                                                                          child: Container(
                                                                                            height: 35,
                                                                                            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                                                                            child: TextFormField(
                                                                                              textAlign: TextAlign.end,
                                                                                              initialValue: areatypes[index].rent_add,
                                                                                              onFieldSubmitted: (value) async {
                                                                                                SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                String? ren = preferences.getString('renTalSer');
                                                                                                String? ser_user = preferences.getString('ser');
                                                                                                var tserx = areatypes[index].ser;
                                                                                                var value_x = value.toString();
                                                                                                String url = '${MyConstant().domain}/UpAd_area_Type.php?isAdd=true&ren=$ren&tser=$tserx&ser_user=$ser_user&type=Edit&valuex=$value_x&typerent=yes';
                                                                                                //print(url);

                                                                                                try {
                                                                                                  var response = await http.get(Uri.parse(url));

                                                                                                  var result = json.decode(response.body);
                                                                                                  // //print(result);
                                                                                                  if (result.toString() == 'true') {
                                                                                                    setState(() {
                                                                                                      read_Area_type();
                                                                                                      // read_GC_area();
                                                                                                    });
                                                                                                  } else {}
                                                                                                } catch (e) {}
                                                                                              },
                                                                                              // maxLength: 13,
                                                                                              cursorColor: Colors.green,
                                                                                              decoration: InputDecoration(
                                                                                                fillColor: const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                                                                                                filled: true,
                                                                                                // prefixIcon:
                                                                                                //     const Icon(Icons.key, color: Colors.black),
                                                                                                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                                  borderSide: BorderSide(
                                                                                                    width: 1,
                                                                                                    color: Colors.green.shade800,
                                                                                                  ),
                                                                                                ),
                                                                                                enabledBorder: const OutlineInputBorder(
                                                                                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                                  borderSide: BorderSide(
                                                                                                    width: 1,
                                                                                                    color: Colors.grey,
                                                                                                  ),
                                                                                                ),
                                                                                                // labelText: 'PASSWOED',
                                                                                                labelStyle: const TextStyle(
                                                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                                    // fontWeight: FontWeight.bold,
                                                                                                    fontFamily: Font_.Fonts_T),
                                                                                              ),
                                                                                              inputFormatters: [
                                                                                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allows digits & one dot
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ])))));
                                                                    })),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ],
                                          );
                                        })),
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          //  backgroundColor:
                          // MaterialStateProperty.all<
                          //     Color>(Colors.green),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 0, 140, 255),
                          ),
                        ),
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              'ประเภทพื้นที่',
                              Colors.white,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              (Arrange == 'Arrange_Area')
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget_ser_Area())
                  : (Arrange == 'Arrange_Zone')
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DragIntoListExample())
                      : (Arrange == 'Arrange_Map')
                          ? Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: GeneratedNodes())
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(dragDevices: {
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.mouse,
                                  }),
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(children: [
                                        SizedBox(
                                          width:
                                              (!Responsive.isDesktop(context))
                                                  ? 1400.00
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                          // width:
                                          //     (!Responsive.isDesktop(context))
                                          //         ? MediaQuery.of(context)
                                          //             .size
                                          //             .width
                                          //         : MediaQuery.of(context)
                                          //                 .size
                                          //                 .width *
                                          //             0.85,
                                          // width:
                                          //     (!Responsive.isDesktop(context))
                                          //         ? 790
                                          //         : MediaQuery.of(context)
                                          //                 .size
                                          //                 .width *
                                          //             .835,

                                          // height: MediaQuery.of(context).size.height,
                                          child: Column(
                                            children: [
                                              Container(
                                                // height: 50,
                                                decoration: BoxDecoration(
                                                  color: AppbackgroundColor
                                                      .TiTile_Colors,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  0)),
                                                ),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 0, 8, 0),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2.0),
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'โซน',
                                                                    SettingScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppbackgroundColor
                                                                    .Sub_Abg_Colors,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
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
                                                                    width: 1),
                                                              ),
                                                              width: 200,
                                                              // padding: const EdgeInsets.all(8.0),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child: DropdownButton2<
                                                                        String>(
                                                                    isExpanded:
                                                                        false,
                                                                    searchController:
                                                                        Dropdown_Controller_zone[
                                                                            1],
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    focusColor:
                                                                        Colors
                                                                            .white,
                                                                    searchInnerWidget:
                                                                        Container(
                                                                      // width: 200,
                                                                      height:
                                                                          50,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .red[100]!
                                                                            .withOpacity(0.5),
                                                                        borderRadius: const BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(8),
                                                                            topRight: Radius.circular(8),
                                                                            bottomLeft: Radius.circular(8),
                                                                            bottomRight: Radius.circular(8)),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1),
                                                                      ),
                                                                      child:
                                                                          TextFormField(
                                                                        expands:
                                                                            true,
                                                                        maxLines:
                                                                            null,
                                                                        controller:
                                                                            Dropdown_Controller_zone[1],
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          contentPadding:
                                                                              const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                8,
                                                                          ),
                                                                          hintText:
                                                                              'Search...',
                                                                          // fillColor: Colors.red[300],
                                                                          hintStyle:
                                                                              const TextStyle(fontSize: 12),
                                                                          border:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    value: (name_Zone ==
                                                                            null)
                                                                        ? null
                                                                        : name_Zone,
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .arrow_drop_down,
                                                                      color: TextHome_Color
                                                                          .TextHome_Colors,
                                                                    ),
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontFamily: Font_
                                                                            .Fonts_T),
                                                                    iconSize:
                                                                        30,
                                                                    buttonHeight:
                                                                        35,
                                                                    buttonWidth:
                                                                        180,
                                                                    dropdownDecoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    items:
                                                                        zoneModels
                                                                            .map((item) =>
                                                                                DropdownMenuItem<
                                                                                    String>(
                                                                                  value: '${item.zn}',
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        item.zn!,
                                                                                        maxLines: 2,
                                                                                        style: TextStyle(fontSize: 14, fontFamily: Font_.Fonts_T),
                                                                                      ),
                                                                                      Divider(
                                                                                        color: Colors.grey[300],
                                                                                        height: 4.0,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ))
                                                                            .toList(),

                                                                    // value: selectedValue,

                                                                    onChanged:
                                                                        (value) async {
                                                                      int selectedIndex = zoneModels.indexWhere((item) =>
                                                                          item.zn ==
                                                                          value);

                                                                      // setState(() {
                                                                      //   name_Zone = value!;
                                                                      //   zone_ser = zoneModels[
                                                                      //           selectedIndex]
                                                                      //       .ser!;
                                                                      // });
                                                                      ///////////--------------->
                                                                      setState(
                                                                          () {
                                                                        name_Zone =
                                                                            value.toString();
                                                                        Ser_Zone = int.parse(zoneModels[selectedIndex]
                                                                            .ser
                                                                            .toString());
                                                                      });
                                                                      read_GC_area();
                                                                      // //print('$index');
                                                                    },
                                                                    searchMatchFn:
                                                                        (item,
                                                                            searchValue) {
                                                                      return item
                                                                          .value
                                                                          .toString()
                                                                          .contains(
                                                                              searchValue);
                                                                    },
                                                                    onMenuStateChange:
                                                                        (isOpen) {
                                                                      if (!isOpen) {
                                                                        Dropdown_Controller_zone[1]
                                                                            .clear();
                                                                      }
                                                                    }),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2.0),
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'ค้นหา',
                                                                    SettingScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),

                                                            // Text(
                                                            //   'ค้นหา :',
                                                            //   style: TextStyle(
                                                            //     color: ReportScreen_Color
                                                            //         .Colors_Text2_,
                                                            //     fontWeight: FontWeight.bold,
                                                            //     fontFamily: Font_.Fonts_T,
                                                            //   ),
                                                            // ),
                                                          ),
                                                          Expanded(
                                                            // flex: 1,
                                                            child: Container(
                                                              height:
                                                                  35, //Date_ser
                                                              // width: 150,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppbackgroundColor
                                                                    .Sub_Abg_Colors,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            8),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            8),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            8),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              child:
                                                                  _searchBar_area(),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: (Ser_Zone ==
                                                                          0 ||
                                                                      Ser_Zone ==
                                                                          null)
                                                                  ? () {
                                                                      widget_SelectZone(
                                                                          context,
                                                                          2);
                                                                    }
                                                                  : ((double.parse(pkqty.toString()) -
                                                                              double.parse(countarae.toString())) <
                                                                          1)
                                                                      ? () {
                                                                          widget_SelectZone(
                                                                              context,
                                                                              1);
                                                                        }
                                                                      : () async {
                                                                          widget_Add_Area(
                                                                              context);
                                                                        },
                                                              style:
                                                                  ButtonStyle(
                                                                //  backgroundColor:
                                                                // MaterialStateProperty.all<
                                                                //     Color>(Colors.green),
                                                                backgroundColor: MaterialStateProperty.all<
                                                                    Color>((Ser_Zone ==
                                                                            0 ||
                                                                        Ser_Zone ==
                                                                            null)
                                                                    ? Color
                                                                        .fromARGB(
                                                                            255,
                                                                            151,
                                                                            170,
                                                                            148)
                                                                    : Color
                                                                        .fromARGB(
                                                                            255,
                                                                            54,
                                                                            184,
                                                                            37)),
                                                              ),
                                                              child: Center(
                                                                child: Translate.TranslateAndSetText(
                                                                    '+เพิ่มพื้นที่',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: (Ser_Zone ==
                                                                          0 ||
                                                                      Ser_Zone ==
                                                                          null)
                                                                  ? () {
                                                                      widget_SelectZone(
                                                                          context,
                                                                          2);
                                                                    }
                                                                  : ((double.parse(pkqty.toString()) -
                                                                              double.parse(countarae.toString())) <
                                                                          1)
                                                                      ? () {
                                                                          widget_SelectZone(
                                                                              context,
                                                                              1);
                                                                        }
                                                                      : () async {
                                                                          setState(
                                                                              () {
                                                                            Add_Number_area_.text =
                                                                                '1';
                                                                            Add_name_area_.text =
                                                                                '1';
                                                                          });
                                                                          widget_Add_AreaAuto(
                                                                              context);
                                                                        },
                                                              style:
                                                                  ButtonStyle(
                                                                //  backgroundColor:
                                                                // MaterialStateProperty.all<
                                                                //     Color>(Colors.green),
                                                                backgroundColor: MaterialStateProperty.all<
                                                                    Color>((Ser_Zone ==
                                                                            0 ||
                                                                        Ser_Zone ==
                                                                            null)
                                                                    ? Color
                                                                        .fromARGB(
                                                                            255,
                                                                            170,
                                                                            158,
                                                                            148)
                                                                    : Color
                                                                        .fromARGB(
                                                                            255,
                                                                            184,
                                                                            115,
                                                                            37)),
                                                              ),
                                                              child: Center(
                                                                child: Translate.TranslateAndSetText(
                                                                    '+เพิ่มแบบAuto',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: (Ser_Zone ==
                                                                          0 ||
                                                                      Ser_Zone ==
                                                                          null)
                                                                  ? () {
                                                                      widget_SelectZone(
                                                                          context,
                                                                          2);
                                                                    }
                                                                  : (areaModels
                                                                              .length !=
                                                                          0)
                                                                      ? () {
                                                                          PanaraInfoDialog
                                                                              .showAnimatedGrow(
                                                                            context,
                                                                            title:
                                                                                "Oops",
                                                                            message:
                                                                                "ไม่สามารถลบโซนพื้นที่ได้ เนื่องจากมีข้อมูลพื้นที่อยู่ ${areaModels.length} พื้นที่",
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
                                                                              context: context,
                                                                              builder: (context) => StatefulBuilder(
                                                                                    builder: (context, setState) => AlertDialog(
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(20),
                                                                                      ),
                                                                                      title: Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Container(
                                                                                                alignment: Alignment.center,
                                                                                                width: MediaQuery.of(context).size.width * 0.2,
                                                                                                child: Text(
                                                                                                  '$name_Zone',
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 20.0,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    color: Colors.black,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 10,
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Container(
                                                                                                alignment: Alignment.center,
                                                                                                width: MediaQuery.of(context).size.width * 0.2,
                                                                                                child: Translate.TranslateAndSetText('ต้องการลบโซนพื้นที่ใช่หรือไม่ ??', SettingScreen_Color.Colors_Text2_, TextAlign.start, FontWeight.bold, Font_.Fonts_T, 14, 1),
                                                                                                // Text(
                                                                                                //   'ต้องการลบโซนพื้นที่ใช่หรือไม่ ??',
                                                                                                //   style: const TextStyle(
                                                                                                //     fontSize: 16.0,
                                                                                                //     fontWeight: FontWeight.bold,
                                                                                                //     color: Colors.red,
                                                                                                //   ),
                                                                                                // ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ), //AppBarColors2.Colors(),
                                                                                      content: Column(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              Container(
                                                                                                width: 130,
                                                                                                height: 40,
                                                                                                // ignore: deprecated_member_use
                                                                                                child: ElevatedButton(
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    backgroundColor: Colors.green,
                                                                                                  ),
                                                                                                  onPressed: () async {
                                                                                                    SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                    String? ren = preferences.getString('renTalSer');
                                                                                                    String? ser_user = preferences.getString('ser');

                                                                                                    var zonename = Ser_Zone;

                                                                                                    String url = '${MyConstant().domain}/DeC_Zone.php?isAdd=true&ren=$ren&ser_user=$ser_user&zonename=$zonename';
                                                                                                    Insert_log.Insert_logs('ตั้งค่า', 'พื้นที่: ยันยันลบโซน $name_Zone( Area  : ${areaModels.length})');
                                                                                                    try {
                                                                                                      var response = await http.get(Uri.parse(url));

                                                                                                      var result = json.decode(response.body);
                                                                                                      // //print(result);
                                                                                                      if (result.toString() == 'true') {
                                                                                                        setState(() {
                                                                                                          read_GC_zone();
                                                                                                          read_GC_area();
                                                                                                          read_GC_rownum().then((value) => con_row());
                                                                                                          read_GC_area_count();
                                                                                                          Ser_Zone = 0;
                                                                                                          ser_Zonex = null;
                                                                                                          name_Zone = 'ทั้งหมด';
                                                                                                        });
                                                                                                        Navigator.pop(context);
                                                                                                      }
                                                                                                    } catch (e) {
                                                                                                      //print(e);
                                                                                                    }
                                                                                                  },
                                                                                                  child: Translate.TranslateAndSetText('ยันยัน', Colors.white, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                                                                                                  // const Text(
                                                                                                  //   'ยันยัน',
                                                                                                  //   style: TextStyle(
                                                                                                  //     // fontSize: 20.0,
                                                                                                  //     // fontWeight: FontWeight.bold,
                                                                                                  //     color: Colors.white,
                                                                                                  //   ),
                                                                                                  // ),
                                                                                                  // color: Colors.orange[900],
                                                                                                ),
                                                                                              ),
                                                                                              Container(
                                                                                                width: 150,
                                                                                                height: 40,
                                                                                                // ignore: deprecated_member_use
                                                                                                child: ElevatedButton(
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    backgroundColor: Colors.black,
                                                                                                  ),
                                                                                                  onPressed: () => Navigator.pop(context),
                                                                                                  child: Translate.TranslateAndSetText('ยกเลิก', Colors.white, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ));
                                                                        },
                                                              style:
                                                                  ButtonStyle(
                                                                //  backgroundColor:
                                                                // MaterialStateProperty.all<
                                                                //     Color>(Colors.green),
                                                                backgroundColor: MaterialStateProperty.all<
                                                                    Color>((Ser_Zone ==
                                                                            0 ||
                                                                        Ser_Zone ==
                                                                            null)
                                                                    ? Color
                                                                        .fromARGB(
                                                                            255,
                                                                            189,
                                                                            162,
                                                                            169)
                                                                    : Color
                                                                        .fromARGB(
                                                                            255,
                                                                            184,
                                                                            37,
                                                                            62)),
                                                              ),
                                                              child: Center(
                                                                child: Translate.TranslateAndSetText(
                                                                    'ลบโซนพื้นที่',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                              width: 150,
                                                              child:
                                                                  Next_page_area())
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(),
                                                    Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width: 25,
                                                          ),
                                                          Container(
                                                            width: 200,
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'ประเภท',
                                                                    SettingScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate
                                                                .TranslateAndSetText(
                                                                    'รหัสพื้นที่',
                                                                    SettingScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .start,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate.TranslateAndSetText(
                                                                'ชื่อพื้นที่เช่า',
                                                                SettingScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate.TranslateAndSetText(
                                                                'ขนาดพื้นที่(ตร.ม.)',
                                                                SettingScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.end,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate.TranslateAndSetText(
                                                                'ค่าบริการหลัก(ต่องวด)',
                                                                SettingScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.end,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Translate.TranslateAndSetText(
                                                                'ค่าบริการ-ล็อกเสียบ(ต่องวด)',
                                                                SettingScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.end,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                          ),
                                                          // Padding(
                                                          //   padding:
                                                          //       const EdgeInsets.all(4.0),
                                                          //   child: InkWell(
                                                          //     onDoubleTap: () {
                                                          //       setState(() {
                                                          //         edit_lock = (edit_lock == 0)
                                                          //             ? 1
                                                          //             : 0;
                                                          //       });
                                                          //     },
                                                          //     child: CircleAvatar(
                                                          //       radius: 15,
                                                          //       backgroundColor:
                                                          //           (edit_lock == 1)
                                                          //               ? Colors.green[100]
                                                          //               : Colors.orange[100],
                                                          //       child: Icon(
                                                          //         size: 14,
                                                          //         Icons.border_color,
                                                          //         color: Colors.black,
                                                          //       ),
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          Container(
                                                            width: 100,
                                                            child: Center(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child: InkWell(
                                                                  onDoubleTap:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      edit_lock =
                                                                          (edit_lock == 0)
                                                                              ? 1
                                                                              : 0;
                                                                    });
                                                                  },
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius: 15,
                                                                    backgroundColor: (edit_lock ==
                                                                            1)
                                                                        ? Colors.green[
                                                                            100]
                                                                        : Colors
                                                                            .orange[100],
                                                                    child: Icon(
                                                                      size: 14,
                                                                      Icons
                                                                          .border_color,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            // Translate.TranslateAndSetText(
                                                            //     '...',
                                                            //     SettingScreen_Color
                                                            //         .Colors_Text1_,
                                                            //     TextAlign.center,
                                                            //     FontWeight.bold,
                                                            //     FontWeight_.Fonts_T,
                                                            //     14,
                                                            //     1),
                                                          ),
                                                        ]),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  width: (!Responsive.isDesktop(
                                                          context))
                                                      ? 1400.00
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.85,
                                                  // width: (!Responsive.isDesktop(
                                                  //         context))
                                                  //     ? MediaQuery.of(context)
                                                  //         .size
                                                  //         .width
                                                  //     : MediaQuery.of(context)
                                                  //             .size
                                                  //             .width *
                                                  //         0.85,
                                                  // width: (!Responsive
                                                  //         .isDesktop(context))
                                                  //     ? 790
                                                  //     : MediaQuery.of(context)
                                                  //             .size
                                                  //             .width *
                                                  //         .835,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.65,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppbackgroundColor
                                                        .Sub_Abg_Colors,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(0),
                                                      topRight:
                                                          Radius.circular(0),
                                                      bottomLeft:
                                                          Radius.circular(0),
                                                      bottomRight:
                                                          Radius.circular(0),
                                                    ),
                                                    // border: Border.all(
                                                    //     color: Colors.grey, width: 1),
                                                  ),
                                                  child: areaModels.isEmpty
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
                                                                  if (!snapshot
                                                                      .hasData)
                                                                    return const Text(
                                                                        '');
                                                                  double
                                                                      elapsed =
                                                                      double.parse(snapshot
                                                                              .data
                                                                              .toString()) *
                                                                          0.05;
                                                                  return Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: (elapsed >
                                                                            8.00)
                                                                        ? const Text(
                                                                            'ไม่พบข้อมูล',
                                                                            style: TextStyle(
                                                                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                fontFamily: Font_.Fonts_T
                                                                                //fontSize: 10.0
                                                                                ),
                                                                          )
                                                                        : Text(
                                                                            'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                                            // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                            style: const TextStyle(
                                                                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                fontFamily: Font_.Fonts_T
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
                                                              _scrollController1,
                                                          // itemExtent: 50,
                                                          physics:
                                                              const AlwaysScrollableScrollPhysics(), //const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              areaModels.length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Material(
                                                              // color: tappedIndex_ ==
                                                              //         index.toString()
                                                              //     ? tappedIndex_Color.tappedIndex_Colors
                                                              //     : AppbackgroundColor.Sub_Abg_Colors,
                                                              child: Container(
                                                                // color: tappedIndex_ ==
                                                                //         index.toString()
                                                                //     ? Colors.grey.shade300
                                                                //     : null,
                                                                child: ListTile(
                                                                    title: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: (ser_indexShow != index)
                                                                              ? null
                                                                              : Colors.green[100]!.withOpacity(0.5),
                                                                          border:
                                                                              Border(
                                                                            bottom:
                                                                                BorderSide(
                                                                              color: Colors.black12,
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child: Column(
                                                                          children: [
                                                                            (areaModels[index].quantity == null || edit_lock == 1)
                                                                                ? widget_edit(index)
                                                                                : Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: EdgeInsets.fromLTRB(2, 2, 20, 2),
                                                                                        child: SizedBox(
                                                                                          width: 20,
                                                                                          height: 20,
                                                                                          child: Align(
                                                                                            alignment: Alignment.centerRight,
                                                                                            child: InkWell(
                                                                                              onTap: () {
                                                                                                // if (renTal_lavel <= 2) {
                                                                                                //   infomation();
                                                                                                // } else {
                                                                                                setState(() {
                                                                                                  // tappedIndex_ = index.toString();
                                                                                                  if (ser_indexShow == index) {
                                                                                                    ser_indexShow = null;
                                                                                                  } else {
                                                                                                    ser_indexShow = index;
                                                                                                  }
                                                                                                });
                                                                                                // }
                                                                                              },
                                                                                              child: CircleAvatar(
                                                                                                  backgroundColor: (ser_indexShow == index) ? Colors.red[700]!.withOpacity(0.5) : Colors.grey[600]!.withOpacity(0.5),
                                                                                                  child: Icon(
                                                                                                    (ser_indexShow == index) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down_outlined,
                                                                                                    color: Colors.white,
                                                                                                    size: 20,
                                                                                                  )),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        height: 35,
                                                                                        width: 200,
                                                                                        child: Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 30,
                                                                                            ),
                                                                                            Text(
                                                                                              (areaModels[index].areatype == null) ? '' : '${areaModels[index].areatype}',
                                                                                              textAlign: TextAlign.start,
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              style: const TextStyle(color: SettingScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T

                                                                                                  //fontSize: 10.0
                                                                                                  ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 1,
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                                                                          child: Text(
                                                                                            '${areaModels[index].ln}',
                                                                                            textAlign: TextAlign.start,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: const TextStyle(color: SettingScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T

                                                                                                //fontSize: 10.0
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 1,
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                                                                          child: Text(
                                                                                            '${areaModels[index].lncode}',
                                                                                            textAlign: TextAlign.start,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: const TextStyle(color: SettingScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T

                                                                                                //fontSize: 10.0
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 1,
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                                                                          child: Text(
                                                                                            (areaModels[index].area == null || areaModels[index].area! == '') ? '' : '${nFormat.format(double.parse(areaModels[index].area!))}',
                                                                                            // '${areaModels[index].area}',
                                                                                            textAlign: TextAlign.end,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: const TextStyle(color: SettingScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T

                                                                                                //fontSize: 10.0
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 1,
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                                                                          child: Text(
                                                                                            '${nFormat.format(double.parse(areaModels[index].rent!))}',
                                                                                            // '${areaModels[index].rent}',
                                                                                            textAlign: TextAlign.end,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: const TextStyle(color: SettingScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T

                                                                                                //fontSize: 10.0
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 1,
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                                                                          child: Text(
                                                                                            '${nFormat.format(double.parse(areaModels[index].rent_maket!))}',
                                                                                            // '${areaModels[index].rent}',
                                                                                            textAlign: TextAlign.end,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: const TextStyle(color: SettingScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T

                                                                                                //fontSize: 10.0
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        width: 100,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                            if (ser_indexShow ==
                                                                                index)
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Translate.TranslateAndSetText('# ราคาที่ต้องการบวกเพิ่ม-ล็อกเสียบ(จ-อ)', Colors.blue, TextAlign.start, null, Font_.Fonts_T, 14, 1),
                                                                                ),
                                                                              ),
                                                                            if (ser_indexShow ==
                                                                                index)
                                                                              widget_Edit_rentday(index)
                                                                          ],
                                                                        ))),
                                                              ),
                                                            );
                                                          }))
                                            ],
                                          ),
                                        ),
                                      ]))),
                            )
            ]),
          ),
        ));
  }

  Widget widget_edit(int index) {
    return Row(
      children: [
        Container(
          height: 35,
          width: 200,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 20, 2),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        // if (renTal_lavel <= 2) {
                        //   infomation();
                        // } else {
                        setState(() {
                          // tappedIndex_ = index.toString();
                          if (ser_indexShow == index) {
                            ser_indexShow = null;
                          } else {
                            ser_indexShow = index;
                          }
                        });
                        // }
                      },
                      child: CircleAvatar(
                          backgroundColor: (ser_indexShow == index)
                              ? Colors.red[700]!.withOpacity(0.5)
                              : Colors.grey[600]!.withOpacity(0.5),
                          child: Icon(
                            (ser_indexShow == index)
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down_outlined,
                            color: Colors.white,
                            size: 20,
                          )),
                    ),
                  ),
                ),
              ),
              Container(
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(0),
                  ),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Center(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      dropdownWidth: 230,
                      searchController: Dropdown_Controller,
                      searchInnerWidget: Container(
                        width: 230,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red[100]!.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: Dropdown_Controller,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search...',
                            // fillColor: Colors.red[300],
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      customButton: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                      items: [
                        for (int index = 0; index < areatypes.length; index++)
                          DropdownMenuItem<String>(
                            value: '${areatypes[index].ser}',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${index + 1}. ${areatypes[index].unit}',
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontSize: 14, fontFamily: Font_.Fonts_T),
                                ),
                                Divider(
                                  color: Colors.grey[300],
                                  height: 4.0,
                                ),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        String? ren = preferences.getString('renTalSer');
                        String? ser_user = preferences.getString('ser');
                        // int selectedIndex =
                        //     areatypes.indexWhere((item) => item.ser == value);
                        // //print(value);
                        // Add_typename_area_text.text =
                        //     areatypes[selectedIndex].unit.toString();
                        // Add_typeser_area_text.text = value!;

                        var vser = areaModels[index].ser;
                        String url =
                            '${MyConstant().domain}/UpC_area_ln.php?isAdd=true&ren=$ren&vser=$vser&value=$value&ser_user=$ser_user&typearea=yes&sertype=$value';

                        try {
                          var response = await http.get(Uri.parse(url));

                          var result = json.decode(response.body);

                          if (result.toString() == 'true') {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              // //print(result);
                              setState(() {
                                read_GC_area();
                              });
                            });
                          } else {}
                        } catch (e) {}
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.start, readOnly: true,
                  initialValue: areaModels[index].areatype,
                  onFieldSubmitted: (value) async {
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    String? ren = preferences.getString('renTalSer');
                    String? ser_user = preferences.getString('ser');
                    var vser = areaModels[index].ser;
                  },
                  // maxLength: 13,
                  cursorColor: Colors.green,
                  decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 240, 224, 224)
                        .withOpacity(0.05),
                    filled: true,
                    // prefixIcon:
                    //     const Icon(Icons.key, color: Colors.black),
                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        topLeft: Radius.circular(0),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(0),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        topLeft: Radius.circular(0),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(0),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    // labelText: 'PASSWOED',
                    labelStyle: const TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        // fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 35,
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: TextFormField(
              textAlign: TextAlign.start,
              initialValue: areaModels[index].ln,
              onFieldSubmitted: (value) async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                String? ren = preferences.getString('renTalSer');
                String? ser_user = preferences.getString('ser');
                var vser = areaModels[index].ser;
                String url =
                    '${MyConstant().domain}/UpC_area_ln.php?isAdd=true&ren=$ren&vser=$vser&value=$value&ser_user=$ser_user';

                try {
                  var response = await http.get(Uri.parse(url));

                  var result = json.decode(response.body);
                  // //print(result);
                  if (result.toString() == 'true') {
                    setState(() {
                      read_GC_area();
                    });
                  } else {}
                } catch (e) {}
              },
              // maxLength: 13,
              cursorColor: Colors.green,
              decoration: InputDecoration(
                fillColor:
                    const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                filled: true,
                // prefixIcon:
                //     const Icon(Icons.key, color: Colors.black),
                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.green.shade800,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                // labelText: 'PASSWOED',
                labelStyle: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    // fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 35,
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: TextFormField(
              textAlign: TextAlign.start,
              initialValue: areaModels[index].lncode,
              onFieldSubmitted: (value) async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                String? ren = preferences.getString('renTalSer');
                String? ser_user = preferences.getString('ser');
                var vser = areaModels[index].ser;
                String url =
                    '${MyConstant().domain}/UpC_area_lncode.php?isAdd=true&ren=$ren&vser=$vser&value=$value&ser_user=$ser_user';

                try {
                  var response = await http.get(Uri.parse(url));

                  var result = json.decode(response.body);
                  // //print(result);
                  if (result.toString() == 'true') {
                    setState(() {
                      read_GC_area();
                    });
                  } else {}
                } catch (e) {}
              },
              // maxLength: 13,
              cursorColor: Colors.green,
              decoration: InputDecoration(
                fillColor:
                    const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                filled: true,
                // prefixIcon:
                //     const Icon(Icons.key, color: Colors.black),
                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.green.shade800,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                // labelText: 'PASSWOED',
                labelStyle: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    // fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 35,
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: TextFormField(
              textAlign: TextAlign.end,
              initialValue: areaModels[index].area,
              onFieldSubmitted: (value) async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                String? ren = preferences.getString('renTalSer');
                String? ser_user = preferences.getString('ser');
                var vser = areaModels[index].ser;
                String url =
                    '${MyConstant().domain}/UpC_area_area.php?isAdd=true&ren=$ren&vser=$vser&value=$value&ser_user=$ser_user';

                try {
                  var response = await http.get(Uri.parse(url));

                  var result = json.decode(response.body);
                  // //print(result);
                  if (result.toString() == 'true') {
                    setState(() {
                      read_GC_area();
                    });
                  } else {}
                } catch (e) {}
              },
              // maxLength: 13,
              cursorColor: Colors.green,
              // style: TextStyle(
              //   color: Color(0XFFFFCC00),
              //   decorationColor: Color(0XFFFFCC00), //Font color change
              //   backgroundColor: Color(
              //       0XFFFFCC00), //TextFormField title background color change
              // ),
              decoration: InputDecoration(
                fillColor:
                    const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                filled: true,
                // prefixIcon:
                //     const Icon(Icons.key, color: Colors.black),
                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.green.shade800,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                // labelText: 'PASSWOED',
                labelStyle: TextStyle(
                    // backgroundColor: Colors.grey,
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    // fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 35,
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: TextFormField(
              textAlign: TextAlign.end,
              initialValue: areaModels[index].rent,
              onFieldSubmitted: (value) async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                String? ren = preferences.getString('renTalSer');
                String? ser_user = preferences.getString('ser');
                var vser = areaModels[index].ser;
                String url =
                    '${MyConstant().domain}/UpC_area_rent.php?isAdd=true&ren=$ren&vser=$vser&value=$value&ser_user=$ser_user';

                try {
                  var response = await http.get(Uri.parse(url));

                  var result = json.decode(response.body);
                  // //print(result);
                  if (result.toString() == 'true') {
                    setState(() {
                      read_GC_area();
                    });
                  } else {}
                } catch (e) {}
              },
              // maxLength: 13,
              cursorColor: Colors.green,
              decoration: InputDecoration(
                fillColor:
                    const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                filled: true,
                // prefixIcon:
                //     const Icon(Icons.key, color: Colors.black),
                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.green.shade800,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                // labelText: 'PASSWOED',
                labelStyle: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    // fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 35,
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: TextFormField(
              textAlign: TextAlign.end,
              initialValue: areaModels[index].rent_maket,
              onFieldSubmitted: (value) async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                String? ren = preferences.getString('renTalSer');
                String? ser_user = preferences.getString('ser');
                var vser = areaModels[index].ser;
                String url =
                    '${MyConstant().domain}/UpC_area_rent.php?isAdd=true&ren=$ren&vser=$vser&value=$value&ser_user=$ser_user&typemarket=yes';

                try {
                  var response = await http.get(Uri.parse(url));

                  var result = json.decode(response.body);
                  // //print(result);
                  if (result.toString() == 'true') {
                    setState(() {
                      read_GC_area();
                    });
                  } else {}
                } catch (e) {}
              },
              // maxLength: 13,
              cursorColor: Colors.green,
              decoration: InputDecoration(
                fillColor:
                    const Color.fromARGB(255, 240, 224, 224).withOpacity(0.05),
                filled: true,
                // prefixIcon:
                //     const Icon(Icons.key, color: Colors.black),
                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.green.shade800,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                // labelText: 'PASSWOED',
                labelStyle: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    // fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
          ),
        ),
        Container(
            width: 100,
            child: (areaModels[index].quantity != null)
                ? null
                : InkWell(
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.red[700],
                      child: Icon(
                        size: 16,
                        Icons.close_outlined,
                        color: Colors.grey[850],
                      ),
                    ),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => StatefulBuilder(
                                builder: (context, setState) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: const Text(
                                                'ลบพื้นที่',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: Text(
                                                'รหัสพื้นที่ ${areaModels[index].lncode} : ชื่อพื้นที่ ${areaModels[index].ln}',
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ), //AppBarColors2.Colors(),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            width: 130,
                                            height: 40,
                                            // ignore: deprecated_member_use
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? ren = preferences
                                                    .getString('renTalSer');
                                                String? ser_user = preferences
                                                    .getString('ser');
                                                var vser =
                                                    areaModels[index].ser;
                                                String url =
                                                    '${MyConstant().domain}/DeC_area.php?isAdd=true&ren=$ren&vser=$vser&ser_user=$ser_user';

                                                try {
                                                  var response = await http
                                                      .get(Uri.parse(url));

                                                  var result = json
                                                      .decode(response.body);
                                                  // //print(result);
                                                  if (result.toString() ==
                                                      'true') {
                                                    Insert_log.Insert_logs(
                                                        'ตั้งค่า',
                                                        'พื้นที่>>ลบ(${areaModels[index].lncode} : ${areaModels[index].ln})');
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      setState(() {
                                                        areaModels.clear();
                                                        limitedList_areaModels
                                                            .clear();
                                                        limitedList_areaModels_
                                                            .clear();
                                                        read_GC_area();
                                                        read_GC_zone();

                                                        read_GC_area_count();
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                                  } else {}
                                                } catch (e) {}
                                              },
                                              child: const Text(
                                                'ยันยัน',
                                                style: TextStyle(
                                                  // fontSize: 20.0,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              // color: Colors.orange[900],
                                            ),
                                          ),
                                          Container(
                                            width: 150,
                                            height: 40,
                                            // ignore: deprecated_member_use
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text(
                                                'ยกเลิก',
                                                style: TextStyle(
                                                  // fontSize: 20.0,
                                                  // fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              // color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ));
                    },
                  )
            // : ElevatedButton(
            //     style: ButtonStyle(
            //       //  backgroundColor:
            //       // MaterialStateProperty.all<
            //       //     Color>(Colors.green),
            //       backgroundColor: MaterialStateProperty.all<Color>(
            //           Color.fromARGB(255, 211, 61, 50)),
            //     ),
            //     onPressed: () async {},
            //     child: Icon(
            //       Icons.close_outlined,
            //       color: Colors.grey[850],
            //     )
            //     // const Text(
            //     //   'ลบ',
            //     //   textAlign: TextAlign.center,
            //     //   maxLines: 1,
            //     //   overflow: TextOverflow.ellipsis,
            //     //   style: TextStyle(
            //     //       color: SettingScreen_Color.Colors_Text2_,
            //     //       fontFamily: Font_.Fonts_T),
            //     // ),
            //     ),

            //  Align(
            //   alignment: Alignment.center,
            //   child: InkWell(
            //     child: Container(
            //       width: 100,
            //       decoration: BoxDecoration(
            //         color: Colors.red[700],
            //         borderRadius: BorderRadius.only(
            //           topLeft: Radius.circular(10),
            //           topRight: Radius.circular(10),
            //           bottomLeft: Radius.circular(10),
            //           bottomRight: Radius.circular(10),
            //         ),
            //         // border: Border.all(
            //         //     color: Colors.grey, width: 1),
            //       ),
            //       padding: const EdgeInsets.all(2.0),
            //       child:
            // const Text(
            //         '...',
            //         textAlign: TextAlign.center,
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis,
            //         style: TextStyle(
            //             color: SettingScreen_Color.Colors_Text2_,
            //             fontFamily: Font_.Fonts_T),
            //       ),
            //     ),
            //     onTap: () {},
            //   ),
            // ),
            ),
      ],
    );
  }

  Widget widget_Edit_rentday(int index) {
    List<Map<String, dynamic>> days = [
      {'th': 'จ', 'en': 'Mon', 'color': Colors.red[200]},
      {'th': 'อ', 'en': 'Tue', 'color': Colors.orange[200]},
      {'th': 'พ', 'en': 'Wed', 'color': Colors.yellow[200]},
      {'th': 'พฤ', 'en': 'Thu', 'color': Colors.green[200]},
      {'th': 'ศ', 'en': 'Fri', 'color': Colors.blue[200]},
      {'th': 'ส', 'en': 'Sat', 'color': Colors.purple[200]},
      {'th': 'อา', 'en': 'Sun', 'color': Colors.pink[200]},
    ];
    List<String?> rents = [
      areaModels[index].rent_d1,
      areaModels[index].rent_d2,
      areaModels[index].rent_d3,
      areaModels[index].rent_d4,
      areaModels[index].rent_d5,
      areaModels[index].rent_d6,
      areaModels[index].rent_d7,
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.green[100]!.withOpacity(0.5),
        padding: const EdgeInsets.all(4.0),
        child: Row(children: [
          for (int indexday = 1; indexday < 8; indexday++)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      decoration: BoxDecoration(
                        color: days[indexday - 1]['color'],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(0),
                        ),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Center(
                          child: Text(
                        '${days[indexday - 1]['th']}',
                        style: TextStyle(
                          color: SettingScreen_Color.Colors_Text1_,
                          fontFamily: FontWeight_.Fonts_T,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ),
                    Expanded(
                      child: Container(
                        height: 35,
                        // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: TextFormField(
                          textAlign: TextAlign.end,
                          initialValue: (indexday >= 1 && indexday <= 7)
                              ? rents[indexday - 1]
                              : areaModels[index].rent_d1,
                          onFieldSubmitted: (value) async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            String? ren = preferences.getString('renTalSer');
                            // String? ser_user = preferences.getString('ser');
                            var vser = areaModels[index].ser;

                            String url =
                                '${MyConstant().domain}/UpC_area_rentday.php?isAdd=true&ren=$ren&vser=$vser&valueday=$value&typeday=$indexday';

                            try {
                              var response = await http.get(Uri.parse(url));

                              var result = json.decode(response.body);
                              // //print(result);
                              if (result['success'].toString() == 'true') {
                                setState(() {
                                  read_GC_area();
                                });
                              } else {}
                            } catch (e) {}
                          },
                          // maxLength: 13,
                          cursorColor: Colors.green,
                          decoration: InputDecoration(
                            fillColor: const Color.fromARGB(255, 240, 224, 224)
                                .withOpacity(0.05),
                            filled: true,
                            // prefixIcon:
                            //     const Icon(Icons.key, color: Colors.black),
                            // suffixIcon: Icon(Icons.clear, color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.green.shade800,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            // labelText: '${indexday}',
                            labelStyle: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.deny(RegExp("[' ']")),
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9 .]')),
                            // for version 2 and greater youcan also use this
                            // FilteringTextInputFormatter
                            //     .digitsOnly
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ]),
      ),
    );
  }

////////////////////------------------------------------->
  final _formKey = GlobalKey<FormState>();

  final area_ser_text = TextEditingController();

  final area_name_text = TextEditingController();
  final area_qty_text = TextEditingController();

  final area_pri_text = TextEditingController();
  final areamarket_pri_text = TextEditingController();
  final d1_pri_text = TextEditingController();
  final d2_pri_text = TextEditingController();
  final d3_pri_text = TextEditingController();
  final d4_pri_text = TextEditingController();
  final d5_pri_text = TextEditingController();
  final d6_pri_text = TextEditingController();
  final d7_pri_text = TextEditingController();
  List<Map<String, dynamic>> days = [
    {'th': 'จ', 'en': 'Mon', 'color': Colors.red[200]},
    {'th': 'อ', 'en': 'Tue', 'color': Colors.orange[200]},
    {'th': 'พ', 'en': 'Wed', 'color': Colors.yellow[200]},
    {'th': 'พฤ', 'en': 'Thu', 'color': Colors.green[200]},
    {'th': 'ศ', 'en': 'Fri', 'color': Colors.blue[200]},
    {'th': 'ส', 'en': 'Sat', 'color': Colors.purple[200]},
    {'th': 'อา', 'en': 'Sun', 'color': Colors.pink[200]},
  ];
  widget_Add_Area(context) {
    setState(() {
      d1_pri_text.text = '0.00';
      d2_pri_text.text = '0.00';
      d3_pri_text.text = '0.00';
      d4_pri_text.text = '0.00';
      d5_pri_text.text = '0.00';
      d6_pri_text.text = '0.00';
      d7_pri_text.text = '0.00';
    });
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => Form(
        key: _formKey,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          title: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.highlight_off,
                            size: 30, color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
                Center(
                    child: Text(
                  '$name_Zone',
                  style: TextStyle(
                    color: SettingScreen_Color.Colors_Text1_,
                    fontFamily: FontWeight_.Fonts_T,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ),
          content: Container(
            // height: MediaQuery.of(context).size.height / 1.5,
            width: (!Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(
              // color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(color: Colors.white, width: 1),
            ),
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,areaModels
                children: [
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return (area_ser_text.text == '')
                            ? SizedBox()
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          '# รหัสพื้นที่ใกล้เครียง : ',
                                          SettingScreen_Color.Colors_Text2_,
                                          TextAlign.start,
                                          null,
                                          Font_.Fonts_T,
                                          14,
                                          1),
                                      // Text(
                                      //   '# รหัสพื้นที่ใกล้เครียง : ',
                                      //   textAlign: TextAlign.left,
                                      //   style: TextStyle(
                                      //     color: SettingScreen_Color.Colors_Text1_,
                                      //     fontFamily: FontWeight_.Fonts_T,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      Expanded(
                                          flex: 1,
                                          child: ScrollConfiguration(
                                            behavior:
                                                ScrollConfiguration.of(context)
                                                    .copyWith(dragDevices: {
                                              PointerDeviceKind.touch,
                                              PointerDeviceKind.mouse,
                                            }),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${_areaModels.where((areaModelss) {
                                                          var notTitle =
                                                              areaModelss.ln
                                                                  .toString()
                                                                  .trim()
                                                                  .toLowerCase();
                                                          var notTitle2 =
                                                              areaModelss.ln
                                                                  .toString()
                                                                  .trim();

                                                          return notTitle.contains(
                                                                  area_ser_text
                                                                      .text
                                                                      .toString()
                                                                      .trim()) ||
                                                              notTitle2.contains(
                                                                  area_ser_text
                                                                      .text
                                                                      .toString()
                                                                      .trim());
                                                        }).map((model) => model.ln).join(', ')}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily: Font_.Fonts_T,
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[300],
                                    height: 4.0,
                                  ),
                                ],
                              );
                      }),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return (area_name_text.text == '')
                            ? SizedBox()
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Translate.TranslateAndSetText(
                                          '# ชื่อพื้นที่ใกล้เครียง : ',
                                          SettingScreen_Color.Colors_Text2_,
                                          TextAlign.start,
                                          null,
                                          Font_.Fonts_T,
                                          14,
                                          1),
                                      // Text(
                                      //   '# ชื่อพื้นที่ใกล้เครียง : ',
                                      //   textAlign: TextAlign.left,
                                      //   style: TextStyle(
                                      //     color: SettingScreen_Color.Colors_Text1_,
                                      //     fontFamily: FontWeight_.Fonts_T,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      Expanded(
                                          flex: 1,
                                          child: ScrollConfiguration(
                                            behavior:
                                                ScrollConfiguration.of(context)
                                                    .copyWith(dragDevices: {
                                              PointerDeviceKind.touch,
                                              PointerDeviceKind.mouse,
                                            }),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${_areaModels.where((areaModelss) {
                                                          var notTitle =
                                                              areaModelss.lncode
                                                                  .toString()
                                                                  .trim()
                                                                  .toLowerCase();
                                                          var notTitle2 =
                                                              areaModelss.lncode
                                                                  .toString()
                                                                  .trim();

                                                          return notTitle.contains(
                                                                  area_name_text
                                                                      .text
                                                                      .toString()
                                                                      .trim()) ||
                                                              notTitle2.contains(
                                                                  area_name_text
                                                                      .text
                                                                      .toString()
                                                                      .trim());
                                                        }).map((model) => model.lncode).join(', ')}',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily: Font_.Fonts_T,
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[300],
                                    height: 4.0,
                                  ),
                                ],
                              );
                      }),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Translate.TranslateAndSetText(
                                        'รหัสพื้นที่',
                                        SettingScreen_Color.Colors_Text2_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                    // Text(
                                    //   'รหัสพื้นที่',
                                    //   textAlign: TextAlign.left,
                                    //   style: TextStyle(
                                    //     color: SettingScreen_Color.Colors_Text1_,
                                    //     fontFamily: FontWeight_.Fonts_T,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  // width: 200, areaModels
                                  child: TextFormField(
                                    controller: area_ser_text,
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
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: 'รหัสพื้นที่',
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      // FilteringTextInputFormatter
                                      //     .allow(RegExp(
                                      //         r'[a-z A-Z 1-9]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Translate.TranslateAndSetText(
                                        'ชื่อพื้นที่',
                                        SettingScreen_Color.Colors_Text2_,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                    // Text(
                                    //   'ชื่อพื้นที่',
                                    //   textAlign: TextAlign.start,
                                    //   style: TextStyle(
                                    //     color: SettingScreen_Color.Colors_Text1_,
                                    //     fontFamily: FontWeight_.Fonts_T,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  // width: 200,
                                  child: TextFormField(
                                    controller: area_name_text,
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
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: 'ชื่อพื้นที่',
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    // inputFormatters: <
                                    //     TextInputFormatter>[
                                    //   FilteringTextInputFormatter
                                    //       .deny(RegExp("[' ']")),
                                    //   // for below version 2 use this
                                    //   FilteringTextInputFormatter
                                    //       .allow(RegExp(
                                    //           r'[a-z A-Z 1-9]')),
                                    //   // for version 2 and greater youcan also use this
                                    //   // FilteringTextInputFormatter
                                    //   //     .digitsOnly
                                    // ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Translate.TranslateAndSetText(
                              'ขนาดพื้นที่',
                              SettingScreen_Color.Colors_Text2_,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // Text(
                          //   'ขนาดพื้นที่-ค่าบริการหลัก',
                          //   textAlign: TextAlign.left,
                          //   style: TextStyle(
                          //     color: SettingScreen_Color.Colors_Text1_,
                          //     fontFamily: FontWeight_.Fonts_T,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: area_qty_text,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'ขนาดพื้นที่(ต.ร.ม.)',
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                        flex: 6,
                        child: Container(
                          height: 35,
                          width: 200,
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(6),
                                    bottomRight: Radius.circular(0),
                                  ),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      dropdownWidth: 230,
                                      searchController: Dropdown_Controller,
                                      searchInnerWidget: Container(
                                        width: 230,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red[100]!.withOpacity(0.5),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: Dropdown_Controller,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search...',
                                            // fillColor: Colors.red[300],
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      customButton: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      items: [
                                        for (int index = 0;
                                            index < areatypes.length;
                                            index++)
                                          DropdownMenuItem<String>(
                                            value: '${areatypes[index].ser}',
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${index + 1}. ${areatypes[index].unit}',
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                                Divider(
                                                  color: Colors.grey[300],
                                                  height: 4.0,
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                      onChanged: (value) {
                                        int selectedIndex =
                                            areatypes.indexWhere(
                                                (item) => item.ser == value);
                                        // //print(value);
                                        Add_typename_area_text.text =
                                            areatypes[selectedIndex]
                                                .unit
                                                .toString();
                                        Add_typeser_area_text.text = value!;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 2)),
                                      builder: (context, snapshot) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${Add_typename_area_text.text}',
                                            maxLines: 2,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ค่าบริการหลัก',
                                SettingScreen_Color.Colors_Text2_,
                                TextAlign.start,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ค่าบริการล็อกเสียบ',
                                SettingScreen_Color.Colors_Text2_,
                                TextAlign.start,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 40,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: area_pri_text,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'ค่าบริการหลัก(ต่องวด)',
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 40,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: areamarket_pri_text,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'ค่าบริการล็อกเสียบ(ต่องวด)',
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Translate.TranslateAndSetText(
                              'ราคาที่ต้องการบวกเพิ่ม-ล็อกเสียบ(จ-อ)',
                              SettingScreen_Color.Colors_Text2_,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[0]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[0]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d1_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[1]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[1]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d2_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[2]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[2]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d3_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[3]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[3]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d4_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[4]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[4]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d5_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[5]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[5]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d6_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[6]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[6]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d7_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Container(
                              height: 35,
                              // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
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
          actions: <Widget>[
            Column(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                const Divider(
                  color: Colors.grey,
                  height: 4.0,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 0)),
                            builder: (context, snapshot) {
                              return Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: (areaModels.any((areaModelss) {
                                                return areaModelss.ln
                                                        .toString()
                                                        .trim() ==
                                                    '${area_ser_text.text}';
                                              }) ==
                                              true ||
                                          areaModels.any((areaModelss) {
                                                return areaModelss.lncode
                                                        .toString()
                                                        .trim() ==
                                                    '${area_name_text.text}';
                                              }) ==
                                              true)
                                      ? Colors.grey
                                      : Colors.green,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: (areaModels.any((areaModelss) {
                                                return areaModelss.ln
                                                        .toString()
                                                        .trim() ==
                                                    '${area_ser_text.text}';
                                              }) ==
                                              true ||
                                          areaModels.any((areaModelss) {
                                                return areaModelss.lncode
                                                        .toString()
                                                        .trim() ==
                                                    '${area_name_text.text}';
                                              }) ==
                                              true)
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            SharedPreferences preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            String? ren = preferences
                                                .getString('renTalSer');
                                            String? ser_user =
                                                preferences.getString('ser');

                                            var zonename = Ser_Zone;
                                            var area_ser = area_ser_text.text;
                                            var area_name = area_name_text.text;
                                            var area_qty = area_qty_text.text;
                                            var area_pri = area_pri_text.text;
                                            var market_pri =
                                                (areamarket_pri_text.text ==
                                                            '' ||
                                                        areamarket_pri_text ==
                                                            null)
                                                    ? '0'
                                                    : areamarket_pri_text.text;
                                            var typeser =
                                                Add_typeser_area_text.text;
                                            var d1pri = d1_pri_text.text;
                                            var d2pri = d2_pri_text.text;
                                            var d3pri = d3_pri_text.text;
                                            var d4pri = d4_pri_text.text;
                                            var d5pri = d5_pri_text.text;
                                            var d6pri = d6_pri_text.text;
                                            var d7pri = d7_pri_text.text;
                                            String url =
                                                '${MyConstant().domain}/InC_area_setring.php?isAdd=true&ren=$ren';

                                            try {
                                              final response = await http.post(
                                                Uri.parse(url),
                                                body: {
                                                  'ser_user':
                                                      ser_user.toString(),
                                                  'zonename':
                                                      zonename.toString(),
                                                  'area_ser':
                                                      area_ser.toString(),
                                                  'area_name':
                                                      area_name.toString(),
                                                  'area_qty':
                                                      area_qty.toString(),
                                                  'area_pri':
                                                      area_pri.toString(),
                                                  'areamarket_pri':
                                                      market_pri.toString(),
                                                  'typeser': typeser.toString(),
                                                  'pd1': d1pri.toString(),
                                                  'pd2': d2pri.toString(),
                                                  'pd3': d3pri.toString(),
                                                  'pd4': d4pri.toString(),
                                                  'pd5': d5pri.toString(),
                                                  'pd6': d6pri.toString(),
                                                  'pd7': d7pri.toString(),
                                                },
                                              );

                                              var result =
                                                  json.decode(response.body);
                                              //print(result);
                                              if (result.toString() == 'true') {
                                                setState(() {
                                                  read_GC_zone();
                                                  read_GC_area();
                                                  read_GC_area_count();
                                                  area_ser_text.clear();
                                                  area_name_text.clear();
                                                  area_qty_text.clear();
                                                  area_pri_text.clear();
                                                  areamarket_pri_text.clear();
                                                });
                                                Navigator.pop(context, 'OK');
                                              }
                                            } catch (e) {
                                              //print(e);
                                            }
                                          }
                                        },
                                  child: Translate.TranslateAndSetText(
                                      'บันทึก',
                                      Colors.white,
                                      TextAlign.start,
                                      null,
                                      Font_.Fonts_T,
                                      14,
                                      1),
                                  // const Text(
                                  //   'บันทึก',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontFamily: FontWeight_.Fonts_T,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ),
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 100,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                area_ser_text.clear();
                                area_name_text.clear();
                                area_qty_text.clear();
                                area_pri_text.clear();
                              });
                              Navigator.pop(context, 'OK');
                            },
                            child: Translate.TranslateAndSetText(
                                'ยกเลิก',
                                Colors.white,
                                TextAlign.start,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                            //  const Text(
                            //   'ยกเลิก',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontFamily: FontWeight_.Fonts_T,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////------------------------------->
  final _formKey2 = GlobalKey<FormState>();
  final Add_totalnew_area_text = TextEditingController();
  final Add_Number_area_text = TextEditingController();
  final Add_Number_area_ = TextEditingController();
  final Add_name_area_text = TextEditingController();
  final Add_name_area_ = TextEditingController();
  final Add_qty_area_text = TextEditingController();
  final Add_pri_area_text = TextEditingController();
  final Add_typename_area_text = TextEditingController();
  final Add_typeser_area_text = TextEditingController();
  final key_text = TextEditingController();
  widget_Add_AreaAuto(context) {
    setState(() {
      d1_pri_text.text = '0.00';
      d2_pri_text.text = '0.00';
      d3_pri_text.text = '0.00';
      d4_pri_text.text = '0.00';
      d5_pri_text.text = '0.00';
      d6_pri_text.text = '0.00';
      d7_pri_text.text = '0.00';
    });
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => Form(
        key: _formKey2,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.highlight_off,
                          size: 30, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
              Center(
                  child: Text(
                '$name_Zone',
                style: TextStyle(
                  color: SettingScreen_Color.Colors_Text1_,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
          content: Container(
            // height: MediaQuery.of(context).size.height / 1.5,
            width: (!Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.5,
            decoration: const BoxDecoration(
              // color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(color: Colors.white, width: 1),
            ),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'จำนวนที่ต้องการเพิ่ม',
                            SettingScreen_Color.Colors_Text1_,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                        //     Text(
                        //   'จำนวนที่ต้องการเพิ่ม',
                        //   textAlign:
                        //       TextAlign.left,
                        //   style:
                        //       TextStyle(
                        //     color:
                        //         SettingScreen_Color.Colors_Text1_,
                        //     fontFamily:
                        //         FontWeight_.Fonts_T,
                        //     fontWeight:
                        //         FontWeight.bold,
                        //   ),
                        // ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: SizedBox(
                            height: 55,
                            // width: 200,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: Add_totalnew_area_text,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                              //   }
                              //   // if (int.parse(value.toString()) < 13) {
                              //   //   return '< 13';
                              //   // }
                              //   return null;
                              // },
                              onChanged: (value) {
                                var total_n = (double.parse(pkqty.toString()) -
                                        double.parse(countarae.toString()))
                                    .toString();
                                if (double.parse(value.toString()) >
                                    (double.parse(pkqty.toString()) -
                                        double.parse(countarae.toString()))) {
                                  setState(() {
                                    Add_totalnew_area_text.text = total_n;
                                  });
                                }
                              },
                              // maxLength: 13,
                              cursorColor: Colors.green,
                              decoration: InputDecoration(
                                  fillColor: Colors.white.withOpacity(0.3),
                                  filled: true,
                                  // prefixIcon:
                                  //     const Icon(Icons.person_pin, color: Colors.black),
                                  // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  labelText:
                                      'ระบุจำนวน (พื้นที่คงเหลือขณะนี้คือ :${nFormat2.format(double.parse(pkqty.toString()) - double.parse(countarae.toString()))})',
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontFamily: FontWeight_.Fonts_T,
                                  )),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                FilteringTextInputFormatter.deny(RegExp(r'^0')),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9 .]')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (areaModels.length == 0)
                            ? 'รหัสพื้นที่ '
                            : 'รหัสพื้นที่ (รหัสล่าสุดคือ : ${areaModels[areaModels.length - 1].ln})',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: SettingScreen_Color.Colors_Text1_,
                          fontFamily: FontWeight_.Fonts_T,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 4, 4),
                      child: Translate.TranslateAndSetText(
                          '**เหตุ : หากต้องการเพิ่มรหัสพื้นที่ คือ A1 ให้ใส่ที่ช่องตัวอักษร เท่ากับ A และให้ใส่ที่ช่องตัวเลข เท่ากับ 1',
                          Colors.red,
                          TextAlign.start,
                          null,
                          Font_.Fonts_T,
                          12,
                          1),
                      //     Text(
                      //   '**เหตุ : หากต้องการเพิ่มรหัสพื้นที่ คือ A1 ให้ใส่ที่ช่องตัวอักษร เท่ากับ A และให้ใส่ที่ช่องตัวเลข เท่ากับ 1',
                      //   textAlign:
                      //       TextAlign.left,
                      //   style: TextStyle(
                      //       color:
                      //           Colors.red,
                      //       fontFamily: FontWeight_.Fonts_T,
                      //       fontSize: 12),
                      // ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: Add_Number_area_text,
                                    // validator:
                                    //     (value) {
                                    //   if (value ==
                                    //           null ||
                                    //       value
                                    //           .isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }

                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: 'ตัวอักษร',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: Add_Number_area_,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'ใส่ข้อมูลให้ครบถ้วน ';
                                      }
                                      // if (int.parse(value.toString()) < 13) {
                                      //   return '< 13';
                                      // }
                                      return null;
                                    },
                                    // maxLength: 4,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: 'เลขเรื่มต้น 1-xxx',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^0')),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (areaModels.length == 0)
                            ? 'ชื่อพื้นที่เช่า '
                            : 'ชื่อพื้นที่เช่า(ชื่อล่าสุดคือ : ${areaModels[areaModels.length - 1].lncode})',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: SettingScreen_Color.Colors_Text1_,
                          fontFamily: FontWeight_.Fonts_T,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 4, 4),
                      child: Translate.TranslateAndSetText(
                          '**เหตุ : หากต้องการเพิ่มชื่อพื้นที่ คือ A1 ให้ใส่ที่ช่องตัวอักษร เท่ากับ A และให้ใส่ที่ช่องตัวเลข เท่ากับ 1',
                          Colors.red,
                          TextAlign.start,
                          null,
                          Font_.Fonts_T,
                          12,
                          1),
                      //     Text(
                      //   '**เหตุ : หากต้องการเพิ่มชื่อพื้นที่ คือ A1 ให้ใส่ที่ช่องตัวอักษร เท่ากับ A และให้ใส่ที่ช่องตัวเลข เท่ากับ 1',
                      //   textAlign:
                      //       TextAlign.left,
                      //   style: TextStyle(
                      //       color:
                      //           Colors.red,
                      //       fontFamily: FontWeight_.Fonts_T,
                      //       fontSize: 12),
                      // ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: Add_name_area_text,
                                    // validator:
                                    //     (value) {
                                    //   if (value ==
                                    //           null ||
                                    //       value
                                    //           .isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: 'ตัวอักษร',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: Add_name_area_,
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
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: 'เลขเรื่มต้น 1-xxx',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'^0')),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 4, 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ขนาดพื้นที่',
                                SettingScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ประเภท',
                                SettingScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: Add_qty_area_text,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'ขนาดพื้นที่(ต.ร.ม.)',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                        flex: 6,
                        child: Container(
                          height: 35,
                          width: 200,
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(6),
                                    bottomRight: Radius.circular(0),
                                  ),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      dropdownWidth: 230,
                                      searchController: Dropdown_Controller,
                                      searchInnerWidget: Container(
                                        width: 230,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red[100]!.withOpacity(0.5),
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: TextFormField(
                                          expands: true,
                                          maxLines: null,
                                          controller: Dropdown_Controller,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: 'Search...',
                                            // fillColor: Colors.red[300],
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      customButton: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      items: [
                                        for (int index = 0;
                                            index < areatypes.length;
                                            index++)
                                          DropdownMenuItem<String>(
                                            value: '${areatypes[index].ser}',
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${index + 1}. ${areatypes[index].unit}',
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                                Divider(
                                                  color: Colors.grey[300],
                                                  height: 4.0,
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                      onChanged: (value) {
                                        int selectedIndex =
                                            areatypes.indexWhere(
                                                (item) => item.ser == value);
                                        // //print(value);
                                        Add_typename_area_text.text =
                                            areatypes[selectedIndex]
                                                .unit
                                                .toString();
                                        Add_typeser_area_text.text = value!;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: StreamBuilder(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 2)),
                                    builder: (context, snapshot) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${Add_typename_area_text.text}',
                                          maxLines: 2,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ค่าบริการหลัก',
                                SettingScreen_Color.Colors_Text2_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ค่าบริการล็อกเสียบ',
                                SettingScreen_Color.Colors_Text2_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: Add_pri_area_text,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'ค่าบริการหลัก(ต่องวด)',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SizedBox(
                                  height: 35,
                                  // width: 200,
                                  child: TextFormField(
                                    controller: areamarket_pri_text,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //   }
                                    //   // if (int.parse(value.toString()) < 13) {
                                    //   //   return '< 13';
                                    //   // }
                                    //   return null;
                                    // },
                                    // maxLength: 13,
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.person_pin, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'ค่าบริการล็อกเสียบ(ต่องวด)',
                                        labelStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: FontWeight_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Translate.TranslateAndSetText(
                              'ราคาที่ต้องการบวกเพิ่ม-ล็อกเสียบ(จ-อ)',
                              SettingScreen_Color.Colors_Text2_,
                              TextAlign.start,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              14,
                              1),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[0]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[0]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d1_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[1]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[1]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d2_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[2]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[2]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d3_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[3]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[3]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d4_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[4]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[4]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d5_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[5]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[5]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d6_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: days[6]['color'],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(0),
                                    ),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${days[6]['th']}',
                                    style: TextStyle(
                                      color: SettingScreen_Color.Colors_Text1_,
                                      fontFamily: FontWeight_.Fonts_T,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: d7_pri_text,

                                      // maxLength: 13,
                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                                255, 240, 224, 224)
                                            .withOpacity(0.05),
                                        filled: true,
                                        // prefixIcon:
                                        //     const Icon(Icons.key, color: Colors.black),
                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: '${indexday}',
                                        labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Container(
                              height: 35,
                              // padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
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
          actions: <Widget>[
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 0)),
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  color: (Add_name_area_.text == '' ||
                                          Add_totalnew_area_text.text == '' ||
                                          Add_Number_area_.text == '' ||
                                          Add_qty_area_text.text == '' ||
                                          Add_pri_area_text.text == '' ||
                                          areamarket_pri_text.text == '')
                                      ? Colors.grey[300]
                                      : Colors.green,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: (Add_name_area_.text == '' ||
                                          Add_totalnew_area_text.text == '' ||
                                          Add_Number_area_.text == '' ||
                                          Add_qty_area_text.text == '' ||
                                          Add_pri_area_text.text == '' ||
                                          areamarket_pri_text.text == '')
                                      ? null
                                      : () async {
                                          if (_formKey2.currentState!
                                              .validate()) {
                                            Insert_log.Insert_logs('ตั้งค่า',
                                                'พื้นที่>>เพิ่มพื้นที่แบบAuto>>จำนวน:${Add_totalnew_area_text.text}');
                                            SharedPreferences preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            String? ren = preferences
                                                .getString('renTalSer');
                                            String? ser_user =
                                                preferences.getString('ser');
                                            // //print('*******  ${Add_totalnew_area_text.text}');

                                            var zonename = ser_Zonex;

                                            var area_qty =
                                                '${Add_qty_area_text.text}';
                                            var area_pri =
                                                '${Add_pri_area_text.text}';
                                            var market_pri =
                                                '${areamarket_pri_text.text}';
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (_) {
                                                  // Future.delayed(
                                                  //     const Duration(
                                                  //         seconds:
                                                  //             1),
                                                  //     () {
                                                  //   Navigator.of(
                                                  //           context)
                                                  //       .pop();
                                                  // });
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
                                            for (int index = 0;
                                                index <
                                                    int.parse(
                                                        '${Add_totalnew_area_text.text}');
                                                index++) {
                                              // var area_ser =
                                              //     'ADD_Auto${index + 1}';

                                              // var area_name =
                                              //     'ADD_AutoName${index + 1}';

                                              var Add_Number_area_New = (index ==
                                                      0)
                                                  ? int.parse(
                                                      '${Add_Number_area_.text}')
                                                  : int.parse(
                                                          '${Add_Number_area_.text}') +
                                                      (index);

                                              var Add_name_area__New = (index ==
                                                      0)
                                                  ? int.parse(
                                                      '${Add_name_area_.text}')
                                                  : int.parse(
                                                          '${Add_name_area_.text}') +
                                                      (index);
                                              var zonename = Ser_Zone;
                                              var typeser =
                                                  Add_typeser_area_text.text;

                                              var d1pri = d1_pri_text.text;
                                              var d2pri = d2_pri_text.text;
                                              var d3pri = d3_pri_text.text;
                                              var d4pri = d4_pri_text.text;
                                              var d5pri = d5_pri_text.text;
                                              var d6pri = d6_pri_text.text;
                                              var d7pri = d7_pri_text.text;
                                              String url =
                                                  '${MyConstant().domain}/InC_area_setring.php?isAdd=true&ren=$ren';

                                              try {
                                                final response =
                                                    await http.post(
                                                  Uri.parse(url),
                                                  body: {
                                                    'ser_user':
                                                        ser_user.toString(),
                                                    'zonename':
                                                        zonename.toString(),
                                                    'area_ser':
                                                        Add_Number_area_text
                                                                .text
                                                                .toString() +
                                                            Add_Number_area_New
                                                                .toString(),
                                                    'area_name':
                                                        Add_name_area_text.text
                                                                .toString() +
                                                            Add_name_area__New
                                                                .toString(),
                                                    'area_qty':
                                                        area_qty.toString(),
                                                    'area_pri':
                                                        area_pri.toString(),
                                                    'areamarket_pri':
                                                        market_pri.toString(),
                                                    'typeser':
                                                        typeser.toString(),
                                                    'pd1': d1pri.toString(),
                                                    'pd2': d2pri.toString(),
                                                    'pd3': d3pri.toString(),
                                                    'pd4': d4pri.toString(),
                                                    'pd5': d5pri.toString(),
                                                    'pd6': d6pri.toString(),
                                                    'pd7': d7pri.toString(),
                                                  },
                                                );

                                                var result =
                                                    json.decode(response.body);
                                                //print(result);
                                                if (index + 1 ==
                                                    int.parse(
                                                        Add_totalnew_area_text
                                                            .text)) {
                                                  if (result.toString() ==
                                                      'true') {
                                                    setState(() {
                                                      read_GC_zone();
                                                      read_GC_area();
                                                      read_GC_area_count();
                                                      area_ser_text.clear();
                                                      area_name_text.clear();
                                                      area_qty_text.clear();
                                                      area_pri_text.clear();
                                                      areamarket_pri_text
                                                          .clear();
                                                    });
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    Navigator.pop(
                                                        context, 'OK');
                                                  } else {
                                                    Navigator.pop(
                                                        context, 'OK');
                                                    Navigator.pop(
                                                        context, 'OK');
                                                  }
                                                }
                                              } catch (e) {
                                                //print(e);
                                              }
                                            }
                                          } else {
                                            //print('No Data ');
                                          }
                                        },
                                  child: Translate.TranslateAndSetText(
                                      'บันทึก',
                                      Colors.white,
                                      TextAlign.start,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      14,
                                      1),
                                  //     const Text(
                                  //   'บันทึก',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontFamily: FontWeight_.Fonts_T,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Container(
                            //     width: 100,
                            //     decoration: const BoxDecoration(
                            //       color: Colors.black,
                            //       borderRadius: BorderRadius.only(
                            //           topLeft: Radius.circular(10),
                            //           topRight: Radius.circular(10),
                            //           bottomLeft: Radius.circular(10),
                            //           bottomRight: Radius.circular(10)),
                            //     ),
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: TextButton(
                            //       onPressed: () async {
                            //         setState(() {
                            //           Add_totalnew_area_text.clear();

                            //           Add_Number_area_text.clear();
                            //           Add_Number_area_.clear();

                            //           Add_name_area_text.clear();
                            //           Add_name_area_.clear();

                            //           Add_qty_area_text.clear();

                            //           Add_pri_area_text.clear();
                            //         });
                            //         Navigator.pop(context, 'OK');
                            //       },
                            //       child: Translate.TranslateAndSetText(
                            //           'ยกเลิก',
                            //           Colors.white,
                            //           TextAlign.start,
                            //           FontWeight.bold,
                            //           FontWeight_.Fonts_T,
                            //           14,
                            //           1),
                            //       //     const Text(
                            //       //   'ยกเลิก',
                            //       //   style: TextStyle(
                            //       //     color: Colors.white,
                            //       //     fontFamily: FontWeight_.Fonts_T,
                            //       //     fontWeight: FontWeight.bold,
                            //       //   ),
                            //       // ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  /////////////////----------------->

  widget_ser_Area() {
    var backgroundColor2 = Color.fromARGB(255, 191, 189, 201);
    return Container(
      child: Column(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              dragStartBehavior: DragStartBehavior.start,
              child: Row(
                children: [
                  SizedBox(
                    width: (!Responsive.isDesktop(context))
                        ? 1400.00
                        : MediaQuery.of(context).size.width * 0.85,
                    // height: MediaQuery.of(context).size.height,
                    // width: (!Responsive.isDesktop(context))
                    //     ? 790
                    //     : MediaQuery.of(context).size.width * 0.83,
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
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  'ลำดับ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  'รหัสพื้นที่',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  'ชื่อผู้เช่า',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    for (int index = 0;
                                        index < _contents.length;
                                        index++) {
                                      var sub_zone =
                                          (_contents[index].lastTarget as Text)
                                              .data;

                                      List<DragAndDropItem> reverseOrder =
                                          _contents[index].children;

                                      for (int i = 0;
                                          i < reverseOrder.length;
                                          i++) {
                                        var zone = (reverseOrder[i]
                                                .feedbackWidget as Text)
                                            .data;

                                        edit_SW(i, zone!);
                                      }
                                    }
                                    setState(() {
                                      read_GC_rownum()
                                          .then((value) => con_row());
                                    });
                                  },
                                  style: ButtonStyle(
                                    //  backgroundColor:
                                    // MaterialStateProperty.all<
                                    //     Color>(Colors.green),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color.fromARGB(255, 133, 184, 37)),
                                  ),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'บันทึกทั้งหมด',
                                        Colors.white,
                                        TextAlign.start,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 0)),
                          builder: (context, snapshot) {
                            return Container(
                              width: (!Responsive.isDesktop(context))
                                  ? 1400.00
                                  : MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.height,
                              // height: MediaQuery.of(context).size.width * 0.35,
                              // width: MediaQuery.of(context).size.width,
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
                              child: DragAndDropLists(
                                children: _contents,
                                onItemReorder: _onItemReorder,
                                onListReorder: _onListReorder,
                                scrollController: _scrollController,
                                axis: Axis.horizontal,
                                listWidth: Responsive.isDesktop(context)
                                    ? MediaQuery.of(context).size.width * 0.8
                                    : MediaQuery.of(context).size.width * 0.8,
                                listDraggingWidth: Responsive.isDesktop(context)
                                    ? MediaQuery.of(context).size.width * 0.8
                                    : MediaQuery.of(context).size.width * 0.8,
                                listPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                itemDivider: Divider(
                                  thickness: 1,
                                  height: 0.5,
                                  color: backgroundColor2,
                                ),
                                itemDecorationWhileDragging: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                listInnerDecoration: BoxDecoration(
                                  // color: Colors.grey[300]!.withOpacity(0.5),
                                  color: Theme.of(context).canvasColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)),
                                ),
                                lastItemTargetHeight: 8,
                                addLastItemTargetHeightToTop: true,
                                lastListTargetSize: 40,
                                listDragHandle: const DragHandle(
                                  verticalAlignment:
                                      DragHandleVerticalAlignment.top,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.menu,
                                      color: Colors.black26,
                                    ),
                                  ),
                                ),
                                itemDragHandle: const DragHandle(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.menu,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
    );
  }

  widget_SelectZone(context, type) {
    return PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: (type == 1)
          ? "จำนวนพื้นที่ครบตาม Package แล้ว...!!"
          : "กรุณาเลือกโซนพื้นที่...!!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false, // optional parameter (default is true)
    );
  }
}
