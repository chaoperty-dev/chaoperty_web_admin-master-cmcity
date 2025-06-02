import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_canvas/infinite_canvas.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu_plus/popup_menu_plus.dart';
import 'package:random_color/random_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../AdminScaffold/AdminScaffold.dart';
import '../ChaoArea/ChaoAreaBid_Screen.dart';
import '../ChaoArea/ChaoAreaRenew_Screen.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetArea_quot.dart';
import '../Model/GetAreax_con_Model.dart';
import '../Model/GetOverdue_floorplans_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetSubZone_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/trans_re_bill_model.dart';
import '../PeopleChao/PeopleChao_Screen2.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/view_pagenow.dart';
import 'Custom_Painter/CustomPainter_Circle.dart';
import 'Custom_Painter/CustomPainter_Crop.dart';
import 'Custom_Painter/CustomPainter_Crop2.dart';
import 'Custom_Painter/CustomPainter_Drink.dart';
import 'Custom_Painter/CustomPainter_Foods.dart';
import 'Custom_Painter/CustomPainter_Map.dart';
import 'Custom_Painter/CustomPainter_Rectangle.dart';
import 'Custom_Painter/CustomPainter_Shop.dart';
import 'Custom_Painter/CustomPainter_Shop2.dart';
import 'Custom_Painter/CustomPainter_Triangle.dart';
import 'Type_Node.dart';

class NodeDataScreen2_Ac extends StatefulWidget {
  const NodeDataScreen2_Ac({
    super.key,
  });

  @override
  State<NodeDataScreen2_Ac> createState() => _NodeDataScreen2_AcState();
}

class _NodeDataScreen2_AcState extends State<NodeDataScreen2_Ac> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  String Ser_nowpage = '3';
  late InfiniteCanvasController controller;
  final gridSize = const Size.square(20);
  List<NodeData2> nodeDatas = [];
  List<AreaModel> areaModels = [];
  List<ZoneModel> zoneModels = [];
  List<AreaQuotModel> areaQuotModels = [];
  List<AreaxConModel> areaxConModels = [];
  List<SubZoneModel> subzoneModels = [];
  List<GlobalKey> _btnKeys = [];
  List<Overdue_floorplansModel> areaModelsOverdue = [];
  // List<InfiniteCanvasNode> nodess = const [];
  String tappedIndex_ = '';
  String? zone_Subname, zone_name, zone_Subser, zone_ser;
  final TextEditingController Dropdown_Controller_zone_Sub =
      TextEditingController();
  final TextEditingController Dropdown_Controller = TextEditingController();
  // int Touch_ = 0;
  // int Create_ = 0;
  final colors = RandomColor();
////////////////////////---------------------------------->
  List<Overdue_floorplansModel> areaModelsAll = [];
  List<TransReBillModel> _TransReBillModels = [];
////////////////////////---------------------------------->
  int renTal_lavel = 0;
  int Ser_Body = 0;
  String? a_ser,
      a_area,
      a_rent,
      a_ln,
      a_page,
      ser_cidtan,
      Value_stasus,
      Value_cid,
      renTal_user,
      renTal_name,
      foder,
      Imge_zone;
  var Value_Daily;
  //////------------------------->
  List<String> YE_Th = [];
  String? MONTH_Now, YEAR_Now;
  //////-------------------------->

  int open_set_date = 30;
  PopupMenu? menu;
  //////-------------------------->
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
  //////------------------------->
  @override
  void initState() {
    super.initState();
    checkPreferance();
    // read_GC_areaOverdue();
    read_GC_rental();
    checkPreferance();
    read_GC_zone();
    controller = InfiniteCanvasController(nodes: [], edges: []);
  }

  //////----------------------------------------------------->
  Future<Null> checkPreferance() async {
    int currentYear = DateTime.now().year;
    setState(() {
      YE_Th.clear();
    });
    for (int i = currentYear; i >= currentYear - 10; i--) {
      YE_Th.add(i.toString());
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      MONTH_Now = DateFormat('MM').format(DateTime.parse('${datex}'));
      YEAR_Now = DateFormat('yyyy').format(DateTime.parse('${datex}'));

      renTal_lavel = int.parse(preferences.getString('lavel').toString());
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
    });
  }

  //////----------------------------------------------------->
  Future<Null> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);

          var foderx = renTalModel.dbn;

          setState(() {
            foder = foderx;
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }

  //////----------------------------------------------------->
  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      zoneModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      for (var map in result) {
        ZoneModel zoneModel = ZoneModel.fromJson(map);
        var sub = zoneModel.sub_zone;
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
      if (zoneModels.length != 0) {
        setState(() {
          Imge_zone = zoneModels[0].img!;
          zone_ser = zoneModels[0].ser!;
          zone_name = zoneModels[0].zn;
        });
        read_GC_areaOverdue().then((value) => {
              red_Node_Accessories().then((value) => {red_Node()})
            });

        // red_area();
      }
    } catch (e) {}
  }

  //////----------------------------------------------------->
  Future<void> red_Node() async {
    // if (nodeDatas.isNotEmpty) {
    //   setState(() {
    //     nodeDatas.clear();
    //   });
    // }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_nodes_area.php?isAdd=true&ren=$ren&zser=$zone_ser';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          NodeData2 nodeData = NodeData2.fromJson(map);
          AreaModel areaModel = AreaModel.fromJson(map);
          setState(() {
            nodeDatas.add(nodeData);
            areaModels.add(areaModel);
          });
          if (areaModel.quantity != '1' && areaModel.quantity != null) {
            var qin = areaModel.ln_q;
            var qinser = areaModel.ser;
            String url =
                '${MyConstant().domain}/GC_area_quot.php?isAdd=true&ren=$ren&qin=$qin&qinser=$qinser';

            try {
              var response = await http.get(Uri.parse(url));

              var result = json.decode(response.body);
              // print(result);
              if (result != null) {
                for (var map in result) {
                  AreaQuotModel areaQuotModel = AreaQuotModel.fromJson(map);
                  setState(() {
                    areaQuotModels.add(areaQuotModel);
                  });
                }
              }
            } catch (e) {}
          }
        }
        _btnKeys = List.generate(nodeDatas.length, (_) => GlobalKey());

        _updateNodes();
        // read_GC_areaOverdue();
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  //////----------------------------------------------------->
  Future<void> red_Node_Accessories() async {
    setState(() {
      nodeDatas.clear();
      areaModels.clear();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_nodes_area_Accessories.php?isAdd=true&ren=$ren&zser=$zone_ser';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          NodeData2 nodeData = NodeData2.fromJson(map);

          setState(() {
            nodeDatas.add(nodeData);
            // areaModels.add(areaModel);
          });
        }
        // _btnKeys = List.generate(nodeDatas.length, (_) => GlobalKey());

        // _updateNodes();
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  //////----------------------------------------------------->
  Future<Null> read_GC_areaOverdue() async {
    var datex_Now = (Value_Daily == null)
        ? DateFormat('yyyy-MM-dd').format(DateTime.parse('${datex}'))
        : Value_Daily;
    if (areaModelsOverdue.length != 0) {
      setState(() {
        areaModelsOverdue.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    String url =
        '${MyConstant().domain}/GC_Overduefloor.php?isAdd=true&ren=$ren&serzone=$zone_ser&_monts=${MONTH_Now}&yex=${YEAR_Now}';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(url);
      if (result != null) {
        for (var map in result) {
          Overdue_floorplansModel areaModel =
              Overdue_floorplansModel.fromJson(map);

          setState(() {
            areaModelsOverdue.add(areaModel);
          });
        }

        // if (zone == null || zone == '0') {
        //   setState(() {
        //     areaFloorplanModels.clear();
        //   });
        // } else {}
      } else {}

      // _btnKeys = List.generate(areaModels.length, (_) => GlobalKey());
      print(
          'zoneModels >>. ${zoneModels.length} ${areaModelsOverdue.map((e) => e.zser).toString()}');
    } catch (e) {}
  }

  //////----------------------------------------------------->
  void _updateNodes() {
    final nodes = nodeDatas.map((nodeData) {
      int Index = nodeDatas
          .indexWhere((item) => item.ser.toString() == nodeData.ser.toString());
      int Index_area = areaModels
          .indexWhere((item) => item.ser.toString() == nodeData.ser.toString());
      // print(
      //     '${nodeDatas.length} ${_btnKeys.length} ///  _btnKeys : ${_btnKeys[Index]} *,*  aser : ${nodeDatas[Index].aser}  ,  Index: $Index, NodeData: ${nodeData.ser}');
      bool hasNonCashTransaction6 = (areaModelsOverdue.any((transaction) {
        return transaction.ser_area.toString() == '${nodeData.aser}';
      }));
      final color = (nodeData.quantity == null || nodeData.quantity! == '2')
          ? Colors.grey[400]!.withOpacity(0.9)
          : (!hasNonCashTransaction6)
              ? Colors.green.shade200
              : Colors.red.shade200;

      final color_text = Colors.white;
      return InfiniteCanvasNode(
        key: UniqueKey(),
        value: nodeDatas[Index].aser.toString(),
        // label: nodeData.lncode.toString(),
        allowResize: false,
        allowMove: false,
        offset: Offset(
          double.parse(nodeData.dx.toString()),
          double.parse(nodeData.dy.toString()),
        ),
        size: Size(
          double.parse(nodeData.width.toString()),
          double.parse(nodeData.height.toString()),
        ),
        child: MaterialButton(
          key: _btnKeys[Index],
          onPressed: (nodeDatas[Index].aser.toString() == '0')
              ? null
              : (nodeData.quantity == null || nodeData.quantity! == '2')
                  ? () {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        // red_Trans_bill(areaModels[Index_area].cid);
                        maxColumn_Freespace(Index_area, context);
                        menu!.show(widgetKey: _btnKeys[Index]);

                        // TypeNode2(context, color, color_text, nodeData, nodeData.type);
                      });
                    }
                  : () {
                      // red_Trans_bill(areaModels[Index_area].cid);
                      // print('${areaModels[Index_area].cid}');
                      // print(
                      //     '//${nodeData.quantity}//${areaModelsOverdue.length}');
                      // print(
                      //     '${areaModelsOverdue.where((model) => model.ser_area == '${nodeData.aser}').map((model) => model.ser_area).join(', ')}');
                      // print(
                      //     '_btnKeys : ${_btnKeys[Index]} *,* Index: $Index_area, NodeData: $nodeData');
                      // print(
                      //     'Node Size: ${nodeData.cid} ---- ${nodeData.ln}------${nodeDatas[Index].ser_area}----${Index}');
                      read_GC_con_area(Index_area);
                      // print(
                      //     'Index --${_btnKeys.length}///${nodeDatas.length} ///// ${_btnKeys[Index]}');
                      Future.delayed(const Duration(milliseconds: 400), () {
                        // dialog_svg(Index_area, context, 'nameln');
                        maxColumn(Index_area, context);
                        menu!.show(widgetKey: _btnKeys[Index]);

                        // TypeNode2(context, color, color_text, nodeData, nodeData.type);
                      });
                    },
          child: TypeNode(context, color, color_text, nodeData, nodeData.type),
        ),
      );
    }).toList();

    setState(() {
      controller = InfiniteCanvasController(nodes: nodes, edges: []);
      controller.formatter = (node) {
        node.offset = Offset(
          (node.offset.dx / gridSize.width).roundToDouble() * gridSize.width,
          (node.offset.dy / gridSize.height).roundToDouble() * gridSize.height,
        );
      };
    });
  }

  Future<Null> read_GC_con_area(int index) async {
    if (areaxConModels.length != 0) {
      setState(() {
        areaxConModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // var zoneSubSer = preferences.getString('zoneSubSer');
    // var zonesSubName = preferences.getString('zonesSubName');
    var ren = preferences.getString('renTalSer');
    var aser = areaModels[index].aser.toString();

    String url =
        '${MyConstant().domain}/GC_areax_con.php?isAdd=true&ren=$ren&aser=$aser';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      areaxConModels.clear();
      for (var map in result) {
        AreaxConModel areaxConModel = AreaxConModel.fromJson(map);
        var cid = areaModels[index].cid;
        var cser = areaxConModel.cser;
        setState(() {
          if (cid != cser) {
            areaxConModels.add(areaxConModel);
          }
        });
      }
    } catch (e) {}
  }

  // Future<Null> red_Trans_bill(Valuecid) async {
  //   if (_TransReBillModels.length != 0) {
  //     setState(() {
  //       _TransReBillModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var ciddoc = Valuecid;
  //   var da_tex = (Value_Daily == null)
  //       ? DateFormat('yyyy-MM-dd').format(DateTime.parse('${datex}'))
  //       : Value_Daily;
  //   String url =
  //       '${MyConstant().domain}/GC_bill_pay_BCFloorP.php?isAdd=true&ren=$ren&cid=$ciddoc&dat_e=$da_tex';
  //   // String url =
  //   //     '${MyConstant().domain}/GC_bill_pay_BC.php?isAdd=true&ren=$ren';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print('result $ciddoc');
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
  //         if (transReBillModel.pos != '1') {
  //           setState(() {
  //             _TransReBillModels.add(transReBillModel);
  //           });
  //         }
  //       }

  //       print('result ${_TransReBillModels.length}');
  //     }
  //   } catch (e) {}
  // }

  Future<Null> infomation(context) async {
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

  String? _message;
  void updateMessage(String newMessage) {
    setState(() {
      _message = newMessage;
      Ser_Body = 0;
    });
    checkPreferance();
  }

  // dialog_svg(int index, context, nameln) {
  //   return showDialog<String>(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       backgroundColor: Colors.white.withOpacity(0.91),
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //       title: Center(
  //           child: Column(
  //         children: [
  //           // Text(
  //           //   (nameln == '2')
  //           //       ? (_TransReBillModels.length == 0)
  //           //           ? '${areaModelsAll[index].lncode} (${areaModelsAll[index].ln}) '
  //           //           : 'ชำระแล้ว : ${areaModelsAll[index].lncode} (${areaModelsAll[index].ln}) '
  //           //       : '${areaModelsOverdue[index].lncode} (${areaModelsOverdue[index].ln})',
  //           //   style: const TextStyle(
  //           //       color: AdminScafScreen_Color.Colors_Text1_,
  //           //       fontWeight: FontWeight.bold,
  //           //       fontFamily: FontWeight_.Fonts_T),
  //           // ),
  //           const SizedBox(
  //             height: 2.0,
  //           ),
  //           Divider(
  //             color: Colors.grey[100],
  //             height: 3.0,
  //           ),
  //           const SizedBox(
  //             height: 2.0,
  //           ),
  //         ],
  //       )),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: <Widget>[
  //             if (nameln == '1')
  //               Container(
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       '${areaModelsOverdue[index].sname}',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                     Text(
  //                       'เลขที่สัญญา : ${areaModelsOverdue[index].refno}',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             if (nameln == '1')
  //               ListTile(
  //                   onTap: () async {
  //                     // if (nameln == '1') {
  //                     //   widget.updateMessage(
  //                     //       '1',
  //                     //       '${areaModelsOverdue[index].refno}',
  //                     //       'PeopleChaoScreen2');
  //                     // } else {}

  //                     Navigator.pop(context, 'OK');
  //                   },
  //                   title: Container(
  //                     decoration: const BoxDecoration(
  //                         border: Border(
  //                       bottom: BorderSide(
  //                         //                    <--- top side
  //                         width: 0.5,
  //                       ),
  //                     )),
  //                     padding: const EdgeInsets.all(4.0),
  //                     width: 270,
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: Column(
  //                             children: [
  //                               const Text(
  //                                 'รับชำระ :',
  //                                 style: TextStyle(
  //                                   color: Colors.red,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: Font_.Fonts_T,
  //                                 ),
  //                               ),
  //                               Container(
  //                                 child: Column(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     children: areaModelsOverdue[index]
  //                                         .docno! // Assuming docno is non-null
  //                                         .split(
  //                                             ',') // Split the string by commas
  //                                         .asMap() // Convert the list to a map
  //                                         .entries // Get the entries of the map
  //                                         .map(
  //                                           (entry) => Text(
  //                                             '${entry.key + 1} : ${entry.value.trim()}', // Displaying index + 1 and the trimmed docno
  //                                             style: const TextStyle(
  //                                               color: PeopleChaoScreen_Color
  //                                                   .Colors_Text2_,
  //                                               //fontWeight: FontWeight.bold,
  //                                               fontFamily: Font_.Fonts_T,
  //                                             ),
  //                                           ),
  //                                         )
  //                                         .toList()),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         // Icon(Iconsax.arrow_circle_right,
  //                         //     color: getRandomColor(index, '${areaModels[index].ln}')),
  //                       ],
  //                     ),
  //                   )),
  //             if (_TransReBillModels.length == 0 && nameln == '2')
  //               ListTile(
  //                   title: Container(
  //                 decoration: const BoxDecoration(
  //                     border: Border(
  //                   bottom: BorderSide(
  //                     //                    <--- top side
  //                     width: 0.5,
  //                   ),
  //                 )),
  //                 padding: const EdgeInsets.all(4.0),
  //                 width: 270,
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       '${areaModelsAll[index].sname}',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                     Text(
  //                       'เลขที่สัญญา : ${areaModelsAll[index].cid}',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                     const Text(
  //                       '( ไม่มีรายการที่ต้องชำระ ณ วันที่เลือก )',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                   ],
  //                 ),
  //               )),
  //             if (_TransReBillModels.length != 0 && nameln == '2')
  //               Container(
  //                 child: Column(
  //                   children: [
  //                     Text(
  //                       '${areaModelsAll[index].sname}',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                     Text(
  //                       'เลขที่สัญญา : ${areaModelsAll[index].cid}',
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(
  //                           color: PeopleChaoScreen_Color.Colors_Text2_,
  //                           //fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             if (nameln == '2')
  //               for (int index = 0; index < _TransReBillModels.length; index++)
  //                 ListTile(
  //                     onTap: () async {
  //                       // setState(() {
  //                       //   red_Trans_select(index);
  //                       //   red_Invoice(index);
  //                       // });

  //                       // Future.delayed(const Duration(milliseconds: 150),
  //                       //     () async {
  //                       //   Navigator.pop(context, 'OK');
  //                       //   checkshowDialog(index);
  //                       // });
  //                     },
  //                     title: Container(
  //                       decoration: const BoxDecoration(
  //                           border: Border(
  //                         bottom: BorderSide(
  //                           //                    <--- top side
  //                           width: 0.5,
  //                         ),
  //                       )),
  //                       padding: const EdgeInsets.all(4.0),
  //                       width: 270,
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               'เรียกดู : ${_TransReBillModels[index].docno}',
  //                               overflow: TextOverflow.ellipsis,
  //                               style: const TextStyle(
  //                                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                   //fontWeight: FontWeight.bold,
  //                                   fontFamily: Font_.Fonts_T),
  //                             ),
  //                           ),
  //                           // Icon(Iconsax.arrow_circle_right,
  //                           //     color: getRandomColor(
  //                           //         index, areaModels[index].ln)),
  //                         ],
  //                       ),
  //                     )),
  //           ],
  //         ),
  //       ),
  //       actions: <Widget>[
  //         Column(
  //           children: [
  //             const SizedBox(
  //               height: 2.0,
  //             ),
  //             const Divider(
  //               color: Colors.grey,
  //               height: 4.0,
  //             ),
  //             const SizedBox(
  //               height: 2.0,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(4.0),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.redAccent,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(5.0),
  //                           child: TextButton(
  //                             onPressed: () async {
  //                               Navigator.pop(context, 'OK');
  //                             },
  //                             child: const Text(
  //                               'ปิด',
  //                               style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: FontWeight_.Fonts_T),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  maxColumn_Freespace(int index, context) {
    menu = PopupMenu(
        onDismiss: () {
          // print('maxColumn');
        },
        context: context,
        // config: const MenuConfig(
        //   type: MenuType.custom,
        //   itemHeight: 200,
        //   itemWidth: 200,
        //   backgroundColor: Colors.green,
        // ),
        config: MenuConfig(
            border: BorderConfig(
              color: Color.fromARGB(255, 56, 56, 56),
            ),
            itemWidth: 300,
            backgroundColor:
                Color.fromARGB(255, 252, 251, 251).withOpacity(0.95),
            type: MenuType.list,
            lineColor: Colors.greenAccent,
            maxColumn: 10),
        items: [
          PopUpMenuItem(
              // title:
              //     'เสนอราคา: ${areaModels[index].lncode} (${areaModels[index].ln})',
              // textStyle: const TextStyle(
              //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //     //fontWeight: FontWeight.bold,
              //     fontFamily: Font_.Fonts_T),
              image: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Translate.TranslateAndSetText(
                    (areaModels[index].quantity.toString() == '2')
                        ? 'พื้นที่ถูก/ติด เสนอราคา:'
                        : 'พื้นที่ว่าง:',
                    PeopleChaoScreen_Color.Colors_Text2_,
                    TextAlign.center,
                    null,
                    Font_.Fonts_T,
                    14,
                    1),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '${areaModels[index].lncode} (${areaModels[index].ln}) ',
                  style: const TextStyle(
                      color: AdminScafScreen_Color.Colors_Text1_,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T),
                ),
              ),
            ],
          ))
        ]);
  }

  maxColumn(
    int index,
    context,
  ) {
    bool hasNonCashTransaction6 = (areaModelsOverdue.any((transaction) {
      return transaction.ser_area.toString() == '${areaModels[index].aser}';
    }));
    print('${areaModels[index].aser}');
    // int index_2 = areaModelsOverdue.indexWhere((area) =>
    //     area.ser_area.toString().trim() ==
    //     areaModels[index].ser.toString().trim());
    menu = PopupMenu(
      onDismiss: () {
        // print('maxColumn');
      },
      context: context,
      // config: const MenuConfig(
      //   type: MenuType.custom,
      //   itemHeight: 200,
      //   itemWidth: 200,
      //   backgroundColor: Colors.green,
      // ),
      config: MenuConfig(
          border: BorderConfig(
            color: Color.fromARGB(255, 56, 56, 56),
          ),
          itemWidth: 300,
          backgroundColor: Color.fromARGB(255, 252, 251, 251).withOpacity(0.95),
          type: MenuType.list,
          lineColor: Colors.greenAccent,
          maxColumn: 10),
      items: [
        if (areaModels[index].quantity == '1')
          PopUpMenuItem(
              image: InkWell(
                  onTap: () async {
                    if (renTal_lavel <= 2) {
                      menu!.dismiss();
                      infomation(context);
                    } else {
                      setState(() {
                        Value_stasus = areaModels[index].quantity == '1'
                            ? datex.isAfter(DateTime.parse(
                                            '${areaModels[index].ldate} 00:00:00.000')
                                        .subtract(const Duration(days: 0))) ==
                                    true
                                ? 'หมดสัญญา'
                                : datex.isAfter(DateTime.parse(
                                                '${areaModels[index].ldate} 00:00:00.000')
                                            .subtract(Duration(
                                                days: open_set_date))) ==
                                        true
                                    ? 'ใกล้หมดสัญญา'
                                    : 'เช่าอยู่'
                            : areaModels[index].quantity == '2'
                                ? 'เสนอราคา'
                                : areaModels[index].quantity == '3'
                                    ? 'เสนอราคา(มัดจำ)'
                                    : 'ว่าง';
                        Ser_Body = 4;
                        Value_cid = areaModels[index].cid;
                        ser_cidtan = '1';
                      });
                      menu!.dismiss();
                    }
                    // Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                        //                    <--- top side
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    )),
                    padding: const EdgeInsets.all(4.0),
                    width: 270,
                    child: Row(
                      children: [
                        Translate.TranslateAndSetText(
                            areaModels[index].scfid == 'N' ? 'N:' : 'รับชำระ:',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            null,
                            Font_.Fonts_T,
                            14,
                            1),
                        Expanded(
                          child: Text(
                            areaModels[index].scfid == 'N'
                                ? '${areaModels[index].cid} (${areaModels[index].cname})'
                                : '${areaModels[index].cid} (${areaModels[index].cname})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Icon(Iconsax.arrow_circle_right,
                            color: getRandomColor(index, '1')),
                      ],
                    ),
                  ))),
        if (areaModels[index].quantity == '1' && areaModels[index].cfid != null)
          PopUpMenuItem(
              // title:
              //     'เช่าอยู่: ${areaModels[index].cid} (${areaModels[index].cname})',
              // textStyle: const TextStyle(
              //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //     //fontWeight: FontWeight.bold,
              //     fontFamily: Font_.Fonts_T),
              image: InkWell(
                  onTap: () async {
                    if (renTal_lavel <= 2) {
                      menu!.dismiss();
                    } else {
                      setState(() {
                        Ser_Body = 4;
                        // Ser_Body = 3;
                        Value_stasus = areaModels[index].quantity == '1'
                            ? datex.isAfter(DateTime.parse(
                                            '${areaModels[index].ldate} 00:00:00.000')
                                        .subtract(const Duration(days: 0))) ==
                                    true
                                ? 'หมดสัญญา'
                                : datex.isAfter(DateTime.parse(
                                                '${areaModels[index].ldate} 00:00:00.000')
                                            .subtract(Duration(
                                                days: open_set_date))) ==
                                        true
                                    ? 'ใกล้หมดสัญญา'
                                    : 'เช่าอยู่'
                            : areaModels[index].quantity == '2'
                                ? 'เสนอราคา'
                                : areaModels[index].quantity == '3'
                                    ? 'เสนอราคา(มัดจำ)'
                                    : 'ว่าง';
                        Value_cid = areaModels[index].cfid;
                        ser_cidtan = '1';
                      });
                      menu!.dismiss();
                    }
                    // Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                        //                    <--- top side
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    )),
                    padding: const EdgeInsets.all(4.0),
                    width: 270,
                    child: Row(
                      children: [
                        Translate.TranslateAndSetText(
                            'เช่าอยู่: ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            14,
                            1),
                        Expanded(
                          child: Text(
                            ' ${areaModels[index].cfid}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Icon(Iconsax.arrow_circle_right,
                            color: getRandomColor(index, '2')),
                      ],
                    ),
                  ))),
      ],
    );
  }

  Color getRandomColor(index, type) {
    bool hasNonCashTransaction6 = (areaModelsOverdue.any((transaction) {
      return transaction.refno.toString() ==
          '${(type == '1') ? areaModels[index].cid : areaModels[index].cfid}';
    }));

    final random = Random();
    return (hasNonCashTransaction6)
        ? Colors.red.shade700
        : Colors.green.shade700;
    // return areaModels[index].quantity == '1'
    //     ? datex.isAfter(
    //                 DateTime.parse('${areaModels[index].ldate} 00:00:00.000')
    //                     .subtract(Duration(days: open_set_date))) ==
    //             true
    //         ? Colors.grey.shade700
    //         : Colors.red.shade700
    //     : areaModels[index].quantity == '2'
    //         ? Colors.blue.shade700
    //         : areaModels[index].quantity == '3'
    //             ? Colors.purple.shade700
    //             : Colors.green.shade700;
  }

  Offset _canvasOffset = Offset.zero;
  Offset _startOffset = Offset.zero;

///////////--------------------------------------->
  @override
  Widget build(BuildContext context) {
    const inset = 2.0;
    return controller == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                if (Ser_Body == 0 || Ser_Body == 4)
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 2, 0),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.TiTile_Box,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Translate.TranslateAndSetText(
                                        'บัญชี ',
                                        ChaoAreaScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        2),
                                    const AutoSizeText(
                                      ' > > ',
                                      overflow: TextOverflow.ellipsis,
                                      minFontSize: 8,
                                      maxFontSize: 20,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      (Ser_Body == 0)
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: viewpage(context, '$Ser_nowpage'),
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Column(
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //   children: [
                                    //     Padding(
                                    //       padding: const EdgeInsets.fromLTRB(
                                    //           4, 4, 4, 0),
                                    //       child: Translate.TranslateAndSetText(
                                    //           'ภาพรวมค้างชำระ:',
                                    //           PeopleChaoScreen_Color
                                    //               .Colors_Text2_,
                                    //           TextAlign.center,
                                    //           FontWeight.bold,
                                    //           FontWeight_.Fonts_T,
                                    //           14,
                                    //           1),
                                    //     ),
                                    //   ],
                                    // ),
                                    InkWell(
                                      onTap: () async {
                                        Dia_log();
                                        setState(() {
                                          Ser_Body = 0;
                                        });
                                        read_GC_areaOverdue().then((value) => {
                                              red_Node_Accessories()
                                                  .then((value) => {red_Node()})
                                            });
                                        // SharedPreferences preferences =
                                        //     await SharedPreferences.getInstance();

                                        // String? _route = preferences.getString('route');

                                        // MaterialPageRoute route = MaterialPageRoute(
                                        //   builder: (context) =>
                                        //       AdminScafScreen(route: _route),
                                        // );
                                        // Navigator.pushAndRemoveUntil(
                                        //     context, route, (route) => false);
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.navigate_before_outlined,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ย้อนกลับ',
                                                      Colors.white,
                                                      TextAlign.center,
                                                      FontWeight.bold,
                                                      FontWeight_.Fonts_T,
                                                      14,
                                                      2),
                                            ),
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
                //      if ((Ser_Body == 0))  Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Align(
                //       alignment: Alignment.topLeft,
                //       child: viewpage(context, '$Ser_nowpage'),
                //     ),
                //   ],
                // ),
                // if ((Ser_Body != 0 && Ser_Body != 5))
                //   Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           children: [
                //             Padding(
                //               padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                //               child: Translate.TranslateAndSetText(
                //                   'ภาพรวมค้างชำระ:',
                //                   PeopleChaoScreen_Color.Colors_Text2_,
                //                   TextAlign.center,
                //                   FontWeight.bold,
                //                   FontWeight_.Fonts_T,
                //                   14,
                //                   1),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                //               child: Align(
                //                 alignment: Alignment.centerRight,
                //                 child: Padding(
                //                   padding: const EdgeInsets.all(2.0),
                //                   child: RichText(
                //                     text: TextSpan(
                //                       text: '(หมายเหตุ :',
                //                       style: TextStyle(
                //                           color: PeopleChaoScreen_Color
                //                               .Colors_Text2_,
                //                           fontSize: 10,
                //                           fontFamily: FontWeight_.Fonts_T),
                //                       children: <TextSpan>[
                //                         TextSpan(
                //                           text: ' ค้างชำระ ,',
                //                           style: TextStyle(
                //                               color: Colors.red.shade300,
                //                               fontSize: 10,
                //                               fontFamily: FontWeight_.Fonts_T),
                //                         ),
                //                         TextSpan(
                //                           text: ' ไม่มีรายการค้าง ,',
                //                           style: TextStyle(
                //                               color: Colors.grey.shade500,
                //                               fontSize: 10,
                //                               fontFamily: FontWeight_.Fonts_T),
                //                         ),
                //                         TextSpan(
                //                           text: ' พื้นที่ว่าง',
                //                           style: TextStyle(
                //                               color: Colors.red.shade300,
                //                               fontSize: 10,
                //                               fontFamily: FontWeight_.Fonts_T),
                //                         ),
                //                         TextSpan(
                //                           text: ')',
                //                           style: TextStyle(
                //                               color: PeopleChaoScreen_Color
                //                                   .Colors_Text2_,
                //                               fontSize: 10,
                //                               fontFamily: FontWeight_.Fonts_T),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //         Expanded(child: SizedBox()),
                //         InkWell(
                //           onTap: () async {
                //             Dia_log();
                //             setState(() {
                //               Ser_Body = 0;
                //             });
                //             read_GC_areaOverdue().then((value) => {
                //                   red_Node_Accessories()
                //                       .then((value) => {red_Node()})
                //                 });
                //             // SharedPreferences preferences =
                //             //     await SharedPreferences.getInstance();

                //             // String? _route = preferences.getString('route');

                //             // MaterialPageRoute route = MaterialPageRoute(
                //             //   builder: (context) =>
                //             //       AdminScafScreen(route: _route),
                //             // );
                //             // Navigator.pushAndRemoveUntil(
                //             //     context, route, (route) => false);
                //           },
                //           child: Container(
                //             decoration: const BoxDecoration(
                //               color: Colors.black,
                //               borderRadius: BorderRadius.only(
                //                   topLeft: Radius.circular(10),
                //                   topRight: Radius.circular(10),
                //                   bottomLeft: Radius.circular(10),
                //                   bottomRight: Radius.circular(10)),
                //             ),
                //             padding: const EdgeInsets.all(8.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 Padding(
                //                   padding: EdgeInsets.all(4.0),
                //                   child: Icon(
                //                     Icons.navigate_before_outlined,
                //                     color: Colors.white,
                //                   ),
                //                 ),
                //                 Padding(
                //                   padding: EdgeInsets.all(4.0),
                //                   child: Translate.TranslateAndSetText(
                //                       'ย้อนกลับ',
                //                       Colors.white,
                //                       TextAlign.center,
                //                       FontWeight.bold,
                //                       FontWeight_.Fonts_T,
                //                       14,
                //                       2),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                (Ser_Body == 1)
                    ? 
                    ChaoAreaBidScreen(
                        Get_Value_area_index: a_ser,
                        Get_Value_area_ln: a_ln,
                        Get_Value_area_sum: a_area,
                        Get_Value_rent_sum: a_rent,
                        Get_Value_page: a_page,
                      )
                    : (Ser_Body == 2)
                        ? ChaoAreaRenewScreen(
                            Get_Value_area_index: a_ser,
                            Get_Value_area_ln: a_ln,
                            Get_Value_area_sum: a_area,
                            Get_Value_rent_sum: a_rent,
                            Get_Value_page: a_page,
                          )
                        : (Ser_Body == 3)
                            ? PeopleChaoScreen2(
                                Get_Value_cid: Value_cid,
                                Get_Value_NameShop_index: ser_cidtan,
                                Get_Value_status: Value_stasus,
                                Get_Value_indexpage: '0',
                                updateMessage: updateMessage,
                              )
                            : (Ser_Body == 4)
                                ? PeopleChaoScreen2(
                                    Get_Value_cid: Value_cid,
                                    Get_Value_NameShop_index: ser_cidtan,
                                    Get_Value_status: Value_stasus,
                                    Get_Value_indexpage: '4',
                                    updateMessage: updateMessage,
                                  )
                                : Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 8),
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
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                // color: Color.fromARGB(
                                                //     255, 27, 26, 39),
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              width: (Responsive.isDesktop(
                                                      context))
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.18
                                                  : 1200,
                                              // width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.85,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppbackgroundColor
                                                          .TiTile_Box,
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
                                                      // border: Border.all(color: Colors.white, width: 1),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      4,
                                                                      4,
                                                                      4,
                                                                      0),
                                                              child: Translate.TranslateAndSetText(
                                                                  'ภาพรวมค้างชำระ:',
                                                                  PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  TextAlign
                                                                      .center,
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
                                                                          .fromLTRB(
                                                                      8,
                                                                      2,
                                                                      8,
                                                                      0),
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      text:
                                                                          '(หมายเหตุ :',
                                                                      style: TextStyle(
                                                                          color: PeopleChaoScreen_Color
                                                                              .Colors_Text2_,
                                                                          fontSize:
                                                                              10,
                                                                          fontFamily:
                                                                              FontWeight_.Fonts_T),
                                                                      children: <TextSpan>[
                                                                        TextSpan(
                                                                          text:
                                                                              ' ค้างชำระ ,',
                                                                          style: TextStyle(
                                                                              color: Colors.red.shade300,
                                                                              fontSize: 10,
                                                                              fontFamily: FontWeight_.Fonts_T),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' ไม่มีรายการค้าง ,',
                                                                          style: TextStyle(
                                                                              color: Colors.grey.shade500,
                                                                              fontSize: 10,
                                                                              fontFamily: FontWeight_.Fonts_T),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' พื้นที่ว่าง',
                                                                          style: TextStyle(
                                                                              color: Colors.red.shade300,
                                                                              fontSize: 10,
                                                                              fontFamily: FontWeight_.Fonts_T),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ')',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontSize: 10,
                                                                              fontFamily: FontWeight_.Fonts_T),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Translate.TranslateAndSetText(
                                                                    'มุมมอง :',
                                                                    Colors
                                                                        .white,
                                                                    TextAlign
                                                                        .end,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    2),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () {},
                                                                    child:
                                                                        SlideSwitcher(
                                                                      containerBorderRadius:
                                                                          10,
                                                                      initialIndex:
                                                                          3,
                                                                      onSelect:
                                                                          (index) async {
                                                                        if (index ==
                                                                            3) {
                                                                        } else {
                                                                          SharedPreferences
                                                                              preferences =
                                                                              await SharedPreferences.getInstance();

                                                                          String?
                                                                              _route =
                                                                              preferences.getString('route');

                                                                          MaterialPageRoute
                                                                              route =
                                                                              MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                AdminScafScreen(route: _route),
                                                                          );
                                                                          Navigator.pushAndRemoveUntil(
                                                                              context,
                                                                              route,
                                                                              (route) => false);
                                                                        }
                                                                      },
                                                                      containerHeight:
                                                                          40,
                                                                      containerWight:
                                                                          130,
                                                                      containerColor:
                                                                          Colors
                                                                              .grey,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .grid_view_rounded,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .calendar_month_rounded,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .list,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .map_outlined,
                                                                          color:
                                                                              Colors.blue[900],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 8, 8, 0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .TiTile_Colors,
                                                        // color: Color.fromARGB(
                                                        //     255, 27, 26, 39),
                                                        borderRadius: const BorderRadius
                                                                .only(
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
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      width: (Responsive
                                                              .isDesktop(
                                                                  context))
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.18
                                                          : 1200,
                                                      height: 40,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                if (tappedIndex_ ==
                                                                    'Touch') {
                                                                  tappedIndex_ =
                                                                      '';
                                                                } else {
                                                                  tappedIndex_ =
                                                                      'Touch';
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .touch_app,
                                                                    color: (tappedIndex_ ==
                                                                            'Touch')
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                  Translate.TranslateAndSetText(
                                                                      'สัมผัส',
                                                                      (tappedIndex_ ==
                                                                              'Touch')
                                                                          ? Colors
                                                                              .blue
                                                                          : Colors
                                                                              .black,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .bold,
                                                                      FontWeight_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  // Text(
                                                                  //   ' Touch ',
                                                                  //   style: TextStyle(
                                                                  //       color:
                                                                  //(tappedIndex_ == 'Touch')
                                                                  //           ? Colors.blue
                                                                  //           : Colors.white,
                                                                  //       fontFamily: Font_.Fonts_T),
                                                                  // ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 30,
                                                            width: 1,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        24),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              controller
                                                                  .zoomIn();
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.zoom_in,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 18,
                                                                ),
                                                                Translate.TranslateAndSetText(
                                                                    'ซูมเข้า',
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
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            height: 30,
                                                            width: 1,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        24),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              controller
                                                                  .zoomOut();
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.zoom_in,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 18,
                                                                ),
                                                                Translate.TranslateAndSetText(
                                                                    'ซูมออก',
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
                                                              ],
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppbackgroundColor
                                                                      .Sub_Abg_Colors
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
                                                              // border: Border.all(color: Colors.white, width: 1),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2.0),
                                                                  child: Text(
                                                                    'เดือน :',
                                                                    style:
                                                                        TextStyle(
                                                                      color: ReportScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: AppbackgroundColor
                                                                          .Sub_Abg_Colors,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight: Radius.circular(
                                                                              10),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                      // border: Border.all(color: Colors.grey, width: 1),
                                                                    ),
                                                                    width: 120,
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child:
                                                                        DropdownButtonFormField2(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      focusColor:
                                                                          Colors
                                                                              .white,
                                                                      autofocus:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        floatingLabelAlignment:
                                                                            FloatingLabelAlignment.center,
                                                                        enabled:
                                                                            true,
                                                                        hoverColor:
                                                                            Colors.brown,
                                                                        prefixIconColor:
                                                                            Colors.blue,
                                                                        fillColor: Colors
                                                                            .white
                                                                            .withOpacity(0.05),
                                                                        filled:
                                                                            false,
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              const BorderSide(color: Colors.red),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        focusedBorder:
                                                                            const OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(10),
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            bottomRight:
                                                                                Radius.circular(10),
                                                                            bottomLeft:
                                                                                Radius.circular(10),
                                                                          ),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            width:
                                                                                1,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                231,
                                                                                227,
                                                                                227),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      isExpanded:
                                                                          false,
                                                                      //value: MONTH_Now,
                                                                      hint:
                                                                          Text(
                                                                        MONTH_Now ==
                                                                                null
                                                                            ? 'เลือก'
                                                                            : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                                                        maxLines:
                                                                            2,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                      iconSize:
                                                                          20,
                                                                      buttonHeight:
                                                                          30,
                                                                      buttonWidth:
                                                                          200,
                                                                      // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                                      dropdownDecoration:
                                                                          BoxDecoration(
                                                                        // color: Colors
                                                                        //     .amber,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width: 1),
                                                                      ),
                                                                      items: [
                                                                        for (int item =
                                                                                1;
                                                                            item <
                                                                                13;
                                                                            item++)
                                                                          DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                '${item}',
                                                                            child:
                                                                                Text(
                                                                              '${monthsInThai[item - 1]}',
                                                                              // '${item}',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(
                                                                                overflow: TextOverflow.ellipsis,
                                                                                fontSize: 14,
                                                                                color: Colors.grey,
                                                                              ),
                                                                            ),
                                                                          )
                                                                      ],

                                                                      onChanged:
                                                                          (value) async {
                                                                        setState(
                                                                            () {
                                                                          MONTH_Now =
                                                                              value;
                                                                          // read_GC_zone();
                                                                        });
                                                                        read_GC_areaOverdue().then((value) =>
                                                                            {
                                                                              red_Node_Accessories().then((value) => {
                                                                                    red_Node()
                                                                                  })
                                                                            });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              2.0),
                                                                  child: Text(
                                                                    'ปี :',
                                                                    style:
                                                                        TextStyle(
                                                                      color: ReportScreen_Color
                                                                          .Colors_Text2_,
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: AppbackgroundColor
                                                                          .Sub_Abg_Colors,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight: Radius.circular(
                                                                              10),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                      // border: Border.all(color: Colors.grey, width: 1),
                                                                    ),
                                                                    width: 120,
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child:
                                                                        DropdownButtonFormField2(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      focusColor:
                                                                          Colors
                                                                              .white,
                                                                      autofocus:
                                                                          false,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        floatingLabelAlignment:
                                                                            FloatingLabelAlignment.center,
                                                                        enabled:
                                                                            true,
                                                                        hoverColor:
                                                                            Colors.brown,
                                                                        prefixIconColor:
                                                                            Colors.blue,
                                                                        fillColor: Colors
                                                                            .white
                                                                            .withOpacity(0.05),
                                                                        filled:
                                                                            false,
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderSide:
                                                                              const BorderSide(color: Colors.red),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        focusedBorder:
                                                                            const OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(10),
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            bottomRight:
                                                                                Radius.circular(10),
                                                                            bottomLeft:
                                                                                Radius.circular(10),
                                                                          ),
                                                                          borderSide:
                                                                              BorderSide(
                                                                            width:
                                                                                1,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                231,
                                                                                227,
                                                                                227),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      isExpanded:
                                                                          false,
                                                                      // value: YEAR_Now,
                                                                      hint:
                                                                          Text(
                                                                        YEAR_Now ==
                                                                                null
                                                                            ? 'เลือก'
                                                                            : '$YEAR_Now',
                                                                        maxLines:
                                                                            2,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                      iconSize:
                                                                          20,
                                                                      buttonHeight:
                                                                          30,
                                                                      buttonWidth:
                                                                          200,
                                                                      // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                                      dropdownDecoration:
                                                                          BoxDecoration(
                                                                        // color: Colors
                                                                        //     .amber,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width: 1),
                                                                      ),
                                                                      items: YE_Th.map((item) =>
                                                                          DropdownMenuItem<
                                                                              String>(
                                                                            value:
                                                                                '${item}',
                                                                            child:
                                                                                Text(
                                                                              '${item}',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(
                                                                                overflow: TextOverflow.ellipsis,
                                                                                fontSize: 14,
                                                                                color: Colors.grey,
                                                                              ),
                                                                            ),
                                                                          )).toList(),

                                                                      onChanged:
                                                                          (value) async {
                                                                        setState(
                                                                            () {
                                                                          YEAR_Now =
                                                                              value;
                                                                          // read_GC_zone();
                                                                        });
                                                                        read_GC_areaOverdue().then((value) =>
                                                                            {
                                                                              red_Node_Accessories().then((value) => {
                                                                                    red_Node()
                                                                                  })
                                                                            });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4.0),
                                                                  child: Translate.TranslateAndSetText(
                                                                      ' โซน ',
                                                                      Colors
                                                                          .black,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .bold,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  // Text(
                                                                  //   'โซน : ',
                                                                  //   style: TextStyle(
                                                                  //       color: Colors.white,
                                                                  //       fontFamily: Font_.Fonts_T),
                                                                  // ),
                                                                ),
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    // color: Color
                                                                    //     .fromARGB(
                                                                    //         255,
                                                                    //         56,
                                                                    //         55,
                                                                    //         70),
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
                                                                            0.5),
                                                                  ),
                                                                  width: 200,
                                                                  child:
                                                                      DropdownButtonHideUnderline(
                                                                    child: DropdownButton2<
                                                                            String>(
                                                                        isExpanded:
                                                                            true,
                                                                        searchController:
                                                                            Dropdown_Controller,
                                                                        searchInnerWidget:
                                                                            Container(
                                                                          // width: 200,
                                                                          height:
                                                                              40,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.red[100]!.withOpacity(0.5),
                                                                            borderRadius: const BorderRadius.only(
                                                                                topLeft: Radius.circular(8),
                                                                                topRight: Radius.circular(8),
                                                                                bottomLeft: Radius.circular(8),
                                                                                bottomRight: Radius.circular(8)),
                                                                            border:
                                                                                Border.all(color: Colors.grey, width: 1),
                                                                          ),
                                                                          child:
                                                                              TextFormField(
                                                                            expands:
                                                                                true,
                                                                            maxLines:
                                                                                null,
                                                                            controller:
                                                                                Dropdown_Controller,
                                                                            decoration:
                                                                                InputDecoration(
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
                                                                        hint: (zone_name ==
                                                                                null)
                                                                            ? Translate.TranslateAndSetText(
                                                                                'ทั้งหมด',
                                                                                PeopleChaoScreen_Color
                                                                                    .Colors_Text1_,
                                                                                TextAlign
                                                                                    .center,
                                                                                null,
                                                                                Font_
                                                                                    .Fonts_T,
                                                                                16,
                                                                                1)
                                                                            : Text(
                                                                                zone_name == null ? 'ทั้งหมด' : '$zone_name',
                                                                                maxLines: 1,
                                                                                style: const TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          color:
                                                                              TextHome_Color.TextHome_Colors,
                                                                        ),
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .green,
                                                                            fontFamily: Font_
                                                                                .Fonts_T),
                                                                        iconSize:
                                                                            30,
                                                                        buttonHeight:
                                                                            35,
                                                                        dropdownDecoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        items: zoneModels
                                                                            .map((item) => DropdownMenuItem<String>(
                                                                                  value: '${item.ser},${item.zn}',
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                        item.zn!,
                                                                                        maxLines: 2,
                                                                                        style: const TextStyle(fontSize: 14, fontFamily: Font_.Fonts_T),
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

                                                                        onChanged: (value) async {
                                                                          var zones =
                                                                              value!.indexOf(',');
                                                                          var zoneSer = value.substring(
                                                                              0,
                                                                              zones);
                                                                          var zonesName =
                                                                              value.substring(zones + 1);
                                                                          int selectedIndex = zoneModels.indexWhere((item) =>
                                                                              item.ser ==
                                                                              zoneSer);
                                                                          setState(
                                                                              () {
                                                                            controller =
                                                                                InfiniteCanvasController(nodes: [], edges: []);
                                                                            zone_ser =
                                                                                zoneSer.toString();
                                                                            zone_name =
                                                                                zonesName.toString();

                                                                            Imge_zone = (zoneModels[selectedIndex].img.toString() == '' || zoneModels[selectedIndex].img == null)
                                                                                ? null
                                                                                : zoneModels[selectedIndex].img.toString();
                                                                          });
                                                                          read_GC_areaOverdue().then((value) =>
                                                                              {
                                                                                red_Node_Accessories().then((value) => {
                                                                                      red_Node()
                                                                                    })
                                                                              });
                                                                          // red_Node_Accessories().then((value) =>
                                                                          //     {
                                                                          //       red_Node()
                                                                          //     });
                                                                          // red_Node();
                                                                          // red_area();
                                                                        },
                                                                        searchMatchFn: (item, searchValue) {
                                                                          return item
                                                                              .value
                                                                              .toString()
                                                                              .contains(searchValue);
                                                                        },
                                                                        onMenuStateChange: (isOpen) {
                                                                          if (!isOpen) {
                                                                            Dropdown_Controller.clear();
                                                                          }
                                                                        }),
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
                                                    // flex: 3,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Listener(
                                                        onPointerDown:
                                                            (tappedIndex_ !=
                                                                    'Touch')
                                                                ? null
                                                                : (details) {
                                                                    controller
                                                                            .mouseDown =
                                                                        true;
                                                                    controller.checkSelection(
                                                                        details
                                                                            .localPosition);

                                                                    _startOffset =
                                                                        details
                                                                            .position;
                                                                  },
                                                        onPointerMove:
                                                            (tappedIndex_ !=
                                                                    'Touch')
                                                                ? null
                                                                : (details) {
                                                                    if (controller
                                                                        .mouseDown) {
                                                                      controller.pan(
                                                                          details
                                                                              .delta);
                                                                    }
                                                                  },
                                                        onPointerUp:
                                                            (tappedIndex_ !=
                                                                    'Touch')
                                                                ? null
                                                                : (details) {
                                                                    controller
                                                                            .mouseDown =
                                                                        false;
                                                                  },
                                                        onPointerCancel:
                                                            (tappedIndex_ !=
                                                                    'Touch')
                                                                ? null
                                                                : (details) {
                                                                    controller
                                                                            .mouseDown =
                                                                        false;
                                                                  },
                                                        child: (nodeDatas
                                                                    .length ==
                                                                0)
                                                            ? Center(
                                                                child: Translate.TranslateAndSetText(
                                                                    ' ไม่พบข้อมูล ',
                                                                    Colors.red,
                                                                    TextAlign
                                                                        .center,
                                                                    FontWeight
                                                                        .bold,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              )
                                                            : InfiniteCanvas(
                                                                menuVisible:
                                                                    false,
                                                                drawVisibleOnly:
                                                                    false,
                                                                canAddEdges:
                                                                    false,
                                                                controller:
                                                                    controller,
                                                                backgroundBuilder:
                                                                    (context,
                                                                        rect) {
                                                                  return Container(
                                                                    width: 600,
                                                                    height: 400,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white24,
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
                                                                      image: (Imge_zone ==
                                                                              null)
                                                                          ? null
                                                                          : DecorationImage(
                                                                              image: NetworkImage('${MyConstant().domain}/files/$foder/zone/$Imge_zone'),
                                                                              // "${MyConstant().domain}//${Imge_zone}"),
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                    ),
                                                                    // child:
                                                                    //     CustomPaint(
                                                                    //   size: rect
                                                                    //       .size,
                                                                    //   painter: GridPainter(
                                                                    //       gridSize:
                                                                    //           gridSize),
                                                                    // ),
                                                                  );
                                                                },
                                                                // gridSize: gridSize,
                                                              ),
                                                        //  InfiniteCanvas(
                                                        //   menuVisible: false,
                                                        //   drawVisibleOnly:
                                                        //       false,
                                                        //   canAddEdges: false,
                                                        //   controller:
                                                        //       controller,
                                                        //   backgroundBuilder:
                                                        //       (context, rect) {
                                                        //     return Container(
                                                        //       width: 300,
                                                        //       height: 300,
                                                        //       decoration:
                                                        //           BoxDecoration(
                                                        //         color: Colors
                                                        //             .grey
                                                        //             .withOpacity(
                                                        //                 0.5),
                                                        //         borderRadius: BorderRadius.only(
                                                        //             topLeft: Radius
                                                        //                 .circular(
                                                        //                     10),
                                                        //             topRight: Radius
                                                        //                 .circular(
                                                        //                     10),
                                                        //             bottomLeft:
                                                        //                 Radius.circular(
                                                        //                     10),
                                                        //             bottomRight:
                                                        //                 Radius.circular(
                                                        //                     10)),
                                                        //         border: Border.all(
                                                        //             color: Colors
                                                        //                 .grey,
                                                        //             width: 1),
                                                        //       ),
                                                        //       child:
                                                        //           CustomPaint(
                                                        //         size: rect.size,
                                                        //         painter: GridPainter(
                                                        //             gridSize:
                                                        //                 gridSize),
                                                        //       ),
                                                        //     );
                                                        //   },
                                                        //   // gridSize: gridSize,
                                                        // ),
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
                                  ),
              ],
            ),
          );
  }

  ///////////////-------------------------------->
  Dia_log() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(Duration(milliseconds: 2400), () {
            Navigator.of(context).pop();
          });
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
}

class InlineCustomPainter extends CustomPainter {
  const InlineCustomPainter({
    required this.brush,
    required this.builder,
    this.isAntiAlias = true,
  });
  final Paint brush;
  final bool isAntiAlias;
  final void Function(Paint paint, Canvas canvas, Rect rect) builder;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    brush.isAntiAlias = isAntiAlias;
    canvas.save();
    builder(brush, canvas, rect);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class NodeData {
  final String label;
  final Offset offset;
  final Size size;
  final int color; // Use int for color value

  NodeData({
    required this.label,
    required this.offset,
    required this.size,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'offset': {'dx': offset.dx, 'dy': offset.dy},
        'size': {'width': size.width, 'height': size.height},
        'color': color,
      };

  static NodeData fromJson(Map<String, dynamic> json) {
    return NodeData(
      label: json['label'],
      offset: Offset(json['offset']['dx'], json['offset']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      color: json['color'],
    );
  }

  @override
  String toString() {
    return 'NodeData(label: $label, offset: $offset, size: $size, color: $color)';
  }
}

class GridPainter extends CustomPainter {
  final Size gridSize;
  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += gridSize.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class NodeData2 {
  String? ser;
  String? user;
  String? datex;
  String? timex;
  String? zser;
  String? aser;
  String? lncode;
  String? ln;
  String? offset;
  String? size;
  String? color;
  String? st;
  String? dx;
  String? dy;
  String? width;
  String? height;
  String? type;

  String? data_update;
  String? custno;
  String? dtype;
  String? date;
  String? total;
  String? refno;

  String? no;
  String? sname;
  String? zn;

  String? ln_c;
  String? in_docno;
  String? docno;
  String? ser_docno;
  String? quantity;
  String? id;
  String? path;

  String? name;
  String? ser_area;
  String? cid;
  String? ldate;
  String? cc_date;

  NodeData2(
      {this.ser,
      this.user,
      this.datex,
      this.timex,
      this.zser,
      this.aser,
      this.lncode,
      this.ln,
      this.offset,
      this.size,
      this.color,
      this.st,
      this.dx,
      this.dy,
      this.width,
      this.height,
      this.type,
      this.data_update,
      this.custno,
      this.dtype,
      this.date,
      this.total,
      this.refno,
      this.no,
      this.sname,
      this.zn,
      this.ln_c,
      this.in_docno,
      this.docno,
      this.ser_docno,
      this.quantity,
      this.id,
      this.path,
      this.name,
      this.ser_area,
      this.cid,
      this.ldate,
      this.cc_date});

  NodeData2.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    user = json['user'];
    datex = json['datex'];
    timex = json['timex'];
    zser = json['zser'];
    aser = json['aser'];
    lncode = json['lncode'];
    ln = json['ln'];
    offset = json['offset'];
    size = json['size'];
    color = json['color'];
    st = json['st'];
    dx = json['dx'];
    dy = json['dy'];
    width = json['width'];
    height = json['height'];
    type = json['type'];
    data_update = json['data_update'];

    custno = json['custno'];
    dtype = json['dtype'];
    date = json['date'];
    total = json['total'];
    refno = json['refno'];

    no = json['no'];
    sname = json['sname'];
    zn = json['zn'];

    ln_c = json['ln_c'];
    in_docno = json['in_docno'];
    docno = json['docno'];
    ser_docno = json['ser_docno'];
    quantity = json['quantity'];
    id = json['id'];
    path = json['path'];

    name = json['name'];
    ser_area = json['ser_area'];
    cid = json['cid'];
    ldate = json['ldate'];
    cc_date = json['cc_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['user'] = this.user;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['zser'] = this.zser;
    data['aser'] = this.aser;
    data['lncode'] = this.lncode;
    data['ln'] = this.ln;
    data['offset'] = this.offset;
    data['size'] = this.size;
    data['color'] = this.color;
    data['st'] = this.st;
    data['dx'] = this.dx;
    data['dy'] = this.dy;
    data['width'] = this.width;
    data['height'] = this.height;
    data['type'] = this.type;
    data['data_update'] = this.data_update;
    data['custno'] = this.custno;
    data['dtype'] = this.dtype;
    data['date'] = this.date;
    data['total'] = this.total;
    data['refno'] = this.refno;

    data['no'] = this.no;
    data['sname'] = this.sname;
    data['zn'] = this.zn;

    data['ln_c'] = this.ln_c;
    data['in_docno'] = this.in_docno;
    data['docno'] = this.docno;
    data['ser_docno'] = this.ser_docno;
    data['quantity'] = this.quantity;
    data['id'] = this.id;
    data['path'] = this.path;

    data['name'] = this.name;
    data['ser_area'] = this.ser_area;
    data['cid'] = this.cid;
    data['ldate'] = this.ldate;
    data['cc_date'] = this.cc_date;
    return data;
  }
}
