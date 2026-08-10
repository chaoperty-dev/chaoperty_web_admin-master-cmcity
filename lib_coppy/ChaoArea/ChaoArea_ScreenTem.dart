// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/AdminScaffold/AdminScaffold.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:im_stepper/stepper.dart';

import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:popup_menu_plus/popup_menu_plus.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../Canvas/view_nodes.dart';
import '../ChiangMai_Municipality/Make_contract_CMM/contractParams.dart';
import '../ChiangMai_Municipality/Make_contract_CMM/new_contract_cmm.dart';
import '../ChiangMai_Municipality/Model/Properties_Model.dart';
import '../ChiangMai_Municipality/unity/API_properties.dart';
import '../ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import '../Constant/Myconstant.dart';

import '../Home/home_reservespace_calendar.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetArea_quot.dart';
import '../Model/GetAreax_con_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetSubZone_Model.dart';
import '../Model/GetZone_Model.dart';

import '../Model/Get_maintenance_model.dart';
import '../PeopleChao/PeopleChao_Screen2.dart';
import '../Responsive/responsive.dart';

import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'package:http/http.dart' as http;

import 'ChaoAreaBid_Screen.dart';
import 'ChaoAreaRenew_Screen.dart';
import 'package:xml/xml.dart';
import 'ChaoArrea_List/Chao_List_Title.dart';
import 'loadSvgImage.dart';
import '../Style/view_pagenow.dart';

// พาร์ส List<dynamic> -> List<AreaModel> บน isolate
List<AreaModel> parseAreasIsolate(List<dynamic> data) {
  return data.map((m) => AreaModel.fromJson(m)).toList();
}

// แบ่งลิสต์เป็นชิ้น ๆ เพื่อจำกัด concurrency
List<List<T>> chunked<T>(List<T> list, int size) {
  final chunks = <List<T>>[];
  for (var i = 0; i < list.length; i += size) {
    final end = (i + size < list.length) ? i + size : list.length;
    chunks.add(list.sublist(i, end));
  }
  return chunks;
}

// ใช้เก็บผลลัพธ์จากการโหลดพื้นที่
class _AreaLoadResult {
  _AreaLoadResult({
    required this.areaModels,
    required this.areaQuotModels,
    required this.zone,
    required this.zoneName,
    required this.totalMatched,
  });

  final List<AreaModel> areaModels;
  final List<AreaQuotModel> areaQuotModels;
  final String? zone;
  final String? zoneName;
  final int totalMatched;
}

///////////----------------------------------------->
class ChaoAreaScreen extends StatefulWidget {
  const ChaoAreaScreen({super.key});

  @override
  State<ChaoAreaScreen> createState() => _ChaoAreaScreenState();
}

class _ChaoAreaScreenState extends State<ChaoAreaScreen> {
  List<GlobalKey> _btnKeys = [];
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  int switcherIndex1 = 0;
  int Status_ = 1;
  int Ser_Body = 0;
  String Visit_ = 'grid'; //มุมมอง Visit_ = 'grid';
  String Ser_nowpage = '1';
  List<Map<String, String>> chaolist1 = [];
  ///////---------------------------------------------------->
  String tappedIndex_ = '';
  final TextEditingController Dropdown_Controller_zone_Sub =
      TextEditingController();
  final TextEditingController Dropdown_Controller = TextEditingController();
  final TextEditingController searchBar_Controller = TextEditingController();
  ///////---------------------------------------------------->
  String? ser_Floor_plans;
  List<ZoneModel> zoneModels = [];
  List<AreaModel> areaModels = [];
  List<AreaQuotModel> areaQuotModels = [];
  List<AreaModel> areaFloorplanModels = [];
  List<AreaModel> _areaModels = <AreaModel>[];
  List<ZoneModel> _zoneModels = <ZoneModel>[];
  List<RenTalModel> renTalModels = [];
  List<SubZoneModel> subzoneModels = [];
  List<AreaxConModel> areaxConModels = [];
  List<MaintenanceModel> maintenanceModels = [];
  List<PropertiesModel> propertiesModel = [];
  List Area_ = [
    'คอมมูนิตี้มอลล์',
    'ออฟฟิศให้เช่า',
    'ตลาดนัด',
    'อื่นๆ',
  ];
  List buttonview_ = [
    'เรียกดู'
    // 'ข้อมูลการเช่า',
    // 'ตั้งหนี้/วางบิล',
    // 'รับชำระ',
    // 'ลดหนี้',
    // 'ประวัติบิล',
  ];
  List buttonview_2 = [
    '+เสนอราคา'
        '+ทำ/ต่อสัญญา',
  ];
  List Status = [
    'ทั้งหมด',
    'ใกล้หมดสัญญา',
    // 'เสนอราคา',
    'ว่าง',
    'เช่าอยู่',
    'หมดสัญญา',
  ];
  List Year_ = [
    'ทั้งหมด',
    for (int i = 0; i < 10; i++) '${2565 - i}',
  ];

  String? renTal_user,
      renTal_name,
      zone_ser,
      zone_name,
      Value_cid,
      Ln_name,
      Img_Zone,
      Imgfloorplan,
      zone_Subser,
      zone_Subname,
      Value_stasus,
      textsearch,
      textzonesearch;
  String? ser_user,
      foder,
      position_user,
      fname_user,
      lname_user,
      email_user,
      utype_user,
      permission_user,
      tel_user,
      img_,
      img_logo;
  String? a_ser, a_area, a_rent, a_ln, a_page, ser_cidtan;
  String? rtname, type, typex, renname, pkname, ser_Zonex;
  int? pkqty, pkuser, countarae;
  /////////////----------------------------------------->
  // List<Country> countries = [];
  AreaModel? areaFloorplanModelss;
  TransformationController _controller = TransformationController();
  Key _countriesKey = UniqueKey();
  void _zoomInSVG() {
    _controller.value *= Matrix4.identity()..scale(1.2);
  }

  void _zoomOutSVG() {
    _controller.value *= Matrix4.identity()..scale(0.8);
  }

  //////////////---------------------------------------------->
  String? Name_, Img_, Img_logo_, Province_, DBN_, Typex_, Img_rental_;
  int open_set_date = 30;
  int renTal_lavel = 0;
  String? data_uuid, requestStep, payment_uuid, payment_uuid_amount;
  List<Map<String, dynamic>> payment_jsonx = [];
  var reques_tstatusx;

  /////////////////--------------------------->
  List<ZoneModel> limitedList_zoneModels = [];
  int limit = 6; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  /////////////////--------------------------->
  // @override
  // void initState() {
  //   super.initState();
  //   checkPreferance();
  //   read_GC_Sub_zone();
  //   read_GC_zone();
  //   Data_Properties();
  //   read_GC_rental();
  //   addAcListTitle();
  //   _areaModels = areaModels;
  //   _zoneModels = zoneModels;
  // }
  @override
  void initState() {
    super.initState();
    checkPreferance();
    read_GC_Sub_zone();
    read_GC_zone().then((_) {
      Data_Properties();
    });

    read_GC_rental();
    addAcListTitle();
    _areaModels = areaModels;
    _zoneModels = zoneModels;
  }

  void add_ContractStore(index) {
    final aln = areaModels[index].lncode;
    final aser = areaModels[index].ser;
    final aarea = areaModels[index].area;
    final arent = areaModels[index].rent;

    final store = ContractStore();
    store
      ..areaIndex = aser.toString()
      ..areaLn = aln.toString()
      ..areaSum = aarea.toString()
      ..rentSum = arent.toString()
      ..page = a_page.toString()
      ..uuid = data_uuid.toString()
      ..step = requestStep.toString()
      ..paymentUuid = payment_uuid.toString()
      ..paymentAmount = payment_uuid_amount.toString()
      ..paymentJson = payment_jsonx;
  }

  ////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1
      chaolist1.addAll(
          ChaoListTitle().chao_1); // Use addAll to add the contents of the list
    });
  }

  ////////////----------------------------------->
  where_chao1(String ser) {
    if (chaolist1
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  ////////////----------------------------------->
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

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });

    // print('textsearchstart>>>>  $textsearch');
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //  print(result);
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
          var open_set_datex = int.parse(renTalModel.open_set_date!);
          setState(() {
            open_set_date = open_set_datex == 0 ? 30 : open_set_datex;
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            pkqty = pkqtyx;
            pkuser = pkuserx;
            DBN_ = renTalModel.dbn;
            pkname = pkx;
            img_ = img;
            img_logo = imglogo;
            ser_Floor_plans = renTalModel.Floor_plans!;
            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }

  String _norm(dynamic v) => v == null ? '' : v.toString().trim();

  void sortZoneModels() {
    if (limitedList_zoneModels.isEmpty) return;

    // 1) เซ็ตของ zser ที่ใช้ได้จาก areaModels (ไม่นับ '', '0')
    final Set<String> validZser = {
      for (final a in areaModels)
        if (_norm(a.zser).isNotEmpty && _norm(a.zser) != '0') _norm(a.zser)
    };

    // 2) แบ่งเป็น 3 กอง: ทั้งหมด → match → notMatch (คงลำดับเดิมในแต่ละกอง)
    final allItems = <ZoneModel>[];
    final match = <ZoneModel>[];
    final notMatch = <ZoneModel>[];

    for (final z in limitedList_zoneModels) {
      if (_norm(z.zn) == 'ทั้งหมด') {
        allItems.add(z);
      } else if (validZser.contains(_norm(z.ser))) {
        match.add(z);
      } else {
        notMatch.add(z);
      }
    }

    // 3) ต่อกลับ: 'ทั้งหมด' ก่อนเสมอ แล้ว match, แล้ว notMatch
    limitedList_zoneModels
      ..clear()
      ..addAll(allItems)
      ..addAll(match)
      ..addAll(notMatch);

    // เรียกฟังก์ชันตัดหน้า-หลังแบบมี setState ภายใน
    read_zone_limit();
  }

  Future<void> read_zone_limit() async {
    // 1) ตัด 'ทั้งหมด' ออก (ser == '0' หรือว่าง)
    final filtered = <ZoneModel>[
      for (final z in limitedList_zoneModels)
        if (_norm(z.ser).isNotEmpty && _norm(z.ser) != '0') z,
    ];

    final total = filtered.length;
    final safeOffset = offset.clamp(0, total);
    final safeEnd = (safeOffset + limit).clamp(0, total);

    setState(() {
      endIndex = safeEnd;
      zoneModels = filtered.sublist(safeOffset, safeEnd);
    });
  }

  Future<void> read_GC_zone() async {
    // ==== clear state ชุดใหญ่ครั้งเดียวตอนต้น ====
    setState(() {
      limit = 6; // max items คุณใช้ต่อที่อื่น
      offset = 0;
      endIndex = 0;
      limitedList_zoneModels.clear();
      zoneModels.clear();
      _zoneModels.clear();
    });

    // prefs เอามาใช้ครั้งเดียว
    final prefs = await SharedPreferences.getInstance();
    final zoneSubSer = prefs.getString('zoneSubSer');
    final ren = prefs.getString('renTalSer');

    // เตรียมตัวแปรที่จะอัปเดต UI หลังโหลดครบ
    List<ZoneModel> nextLimited = [];
    List<ZoneModel> nextZones = [];
    String? nextZoneSer;
    String? nextZoneName;
    String? nextZoneSubSer;
    String? nextZoneSubName;
    String? nextImgZone;
    String? nextImgFloorplan;

    try {
      final uri = Uri.parse('${MyConstant().domain}/GC_zone.php')
          .replace(queryParameters: {'isAdd': 'true', 'ren': ren ?? ''});
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        // คุณจะโชว์ SnackBar/log ตรงนี้ก็ได้
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data is! List) {
        throw Exception('Invalid JSON: expected List');
      }

      // “ทั้งหมด” ใส่ไว้หัวลิสต์เสมอ
      final allItem = ZoneModel.fromJson({
        'ser': '0',
        'rser': '0',
        'zn': 'ทั้งหมด',
        'qty': '0',
        'img': '0',
        'data_update': '0'
      });

      final tmp = <ZoneModel>[allItem];

      for (final map in data) {
        final z = ZoneModel.fromJson(map);
        final sub = z.sub_zone;
        final allowBySub =
            (zoneSubSer == null || zoneSubSer == '0' || sub == zoneSubSer);
        final hasQty = z.qty.toString() != '0';
        if (allowBySub && hasQty) {
          tmp.add(z);
        }
      }

      // เก็บไว้ก่อน รอ setState ทีเดียว
      nextLimited = tmp;

      // เรียงตามกฎ: 'ทั้งหมด' → พบใน areaModels.zser → ไม่พบ
      if (Status_ == 1) {
        // ให้ limitedList_zoneModels เป็นฐาน แล้วค่อยไป sort ด้วยฟังก์ชันเดิมของคุณ
        // ใส่ค่าไว้ก่อน เดี๋ยว setState แล้วเรียก sortZoneModels()
        nextZones = tmp;
      } else {
        nextZones = tmp;
      }

      // default zoneSer/zonesName ถ้ายังไม่เคยตั้ง หรือเป็น '0'
      nextZoneSer = prefs.getString('zoneSer');
      nextZoneName = prefs.getString('zonesName');

      // if (nextZones.length > 1 && (nextZoneSer == null || nextZoneSer == '0')) {
      //   nextZoneSer = nextZones[1].ser?.toString();
      //   nextZoneName = nextZones[1].zn?.toString();
      //   await prefs.setString('zoneSer', nextZoneSer ?? '0');
      //   await prefs.setString('zonesName', nextZoneName ?? 'ทั้งหมด');
      // }

      // ถ้า zonesName เคยเป็นสตริง "null" → รีเซ็ต
      if ((prefs.getString('zonesName') ?? '').toLowerCase() == 'null') {
        await prefs.setString('zoneSer', '0');
        await prefs.setString('zonesName', 'ทั้งหมด');
        nextZoneSer = '0';
        nextZoneName = 'ทั้งหมด';
      }

      // อัปเดตค่าที่เหลือจาก prefs
      nextZoneSubSer = prefs.getString('zoneSubSer');
      nextZoneSubName = prefs.getString('zonesSubName');

      // หา index ที่เลือกไว้เพื่อเซ็ตภาพ
      final idx = nextZones.indexWhere(
        (e) => e.ser == nextZoneSer && e.zn == nextZoneName,
      );
      if (idx >= 0) {
        final img = nextZones[idx].img;
        final imgFloor = nextZones[idx].img_floorplan;
        nextImgZone = (img == null || img == '0')
            ? null
            : '${MyConstant().domain}/files/$DBN_/zone/$img';
        nextImgFloorplan = (imgFloor == null || imgFloor == '0')
            ? null
            : '${MyConstant().domain}/files/$DBN_/zone/$imgFloor';
      }
    } catch (e) {
      // TODO: คุณจะ log/แจ้งผู้ใช้ก็ได้
    }

    // ---- setState ทีเดียว ----
    setState(() {
      limitedList_zoneModels = nextLimited;
      zoneModels = nextZones;
      _zoneModels = nextLimited;

      zone_ser = nextZoneSer ?? prefs.getString('zoneSer');
      zone_name = nextZoneName ?? prefs.getString('zonesName');
      zone_Subser = nextZoneSubSer ?? prefs.getString('zoneSubSer');
      zone_Subname = nextZoneSubName ?? prefs.getString('zonesSubName');

      Img_Zone = nextImgZone;
      Imgfloorplan = nextImgFloorplan;

      // เคลียร์ floorplan/area ต่อเนื่อง
      areaFloorplanModels.clear();
      areaModels.clear();
      _areaModels.clear();
    });

    // ถ้าต้องการให้กฎเรียงโซนแบบพิเศษ (เฉพาะ Status_ == 1) หลัง setState แล้วเรียกได้
    if (Status_ == 1) {
      sortZoneModels(); // ใช้ลิสต์ใน state ปัจจุบัน
    }

    // ถ้าต้องโหลดพื้นที่ต่อทันที:
    // await read_GC_area();
  }
  // Future<Null> read_GC_zone() async {
  //   if (zoneModels.length != 0) {
  //     zoneModels.clear();
  //     _zoneModels.clear();
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var zoneSubSer = preferences.getString('zoneSubSer');
  //   var zonesSubName = preferences.getString('zonesSubName');
  //   var ren = preferences.getString('renTalSer');

  //   String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     Map<String, dynamic> map = Map();
  //     map['ser'] = '0';
  //     map['rser'] = '0';
  //     map['zn'] = 'ทั้งหมด';
  //     map['qty'] = '0';
  //     map['img'] = '0';
  //     map['data_update'] = '0';

  //     ZoneModel zoneModelx = ZoneModel.fromJson(map);

  //     setState(() {
  //       zoneModels.add(zoneModelx);
  //     });

  //     for (var map in result) {
  //       ZoneModel zoneModel = ZoneModel.fromJson(map);
  //       var sub = zoneModel.sub_zone;
  //       setState(() {
  //         if (zoneSubSer == null || zoneSubSer == '0') {
  //           zoneModels.add(zoneModel);
  //         } else {
  //           if (sub == zoneSubSer) {
  //             zoneModels.add(zoneModel);
  //           }
  //         }
  //       });
  //     }
  //     zoneModels.sort((a, b) {
  //       if (a.zn == 'ทั้งหมด') {
  //         return -1; // 'all' should come before other elements
  //       } else if (b.zn == 'ทั้งหมด') {
  //         return 1; // 'all' should come after other elements
  //       } else {
  //         return a.zn!
  //             .compareTo(b.zn!); // sort other elements in ascending order
  //       }
  //     });
  //   } catch (e) {}
  //   if (preferences.getString('zonesName').toString() == 'null') {
  //     setState(() {
  //       preferences.setString('zoneSer', '0');
  //       preferences.setString('zonesName', 'ทั้งหมด');
  //     });
  //   }

  //   setState(() {
  //     _zoneModels = zoneModels;
  //     zone_ser = preferences.getString('zoneSer');
  //     zone_name = preferences.getString('zonesName');
  //     zone_Subser = preferences.getString('zoneSubSer');
  //     zone_Subname = preferences.getString('zonesSubName');
  //   });

  //   int selectedIndex = zoneModels.indexWhere(
  //       (element) => element.ser == zone_ser && element.zn == zone_name);

  //   // print('Selected index: $selectedIndex');
  //   if (selectedIndex == 0) {
  //   } else {
  //     Img_Zone =
  //         '${MyConstant().domain}/files/$DBN_/zone/${zoneModels[selectedIndex].img}';
  //     // Img_Zone =
  //     //     'https://dzentric.com/chao_perty/chao_api/files/${DBN_}/zone/${zoneModels[selectedIndex].img}';
  //     Imgfloorplan =
  //         '${MyConstant().domain}/files/$DBN_/zone/${zoneModels[selectedIndex].img_floorplan}';
  //   }

  //   setState(() {
  //     areaFloorplanModels.clear;
  //     areaModels.clear();
  //     _areaModels.clear();
  //     // read_GC_area();
  //   });
  // }

// ============================================================
// ภายใน State class ของคุณ
// ============================================================

  final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
  ));
  final CancelToken cancelToken = CancelToken();

  bool _isLoadingAreas = false;

// ------------------ STEP 1: โหลด properties แล้วค่อยโหลด area ------------------
  Future<void> Data_Properties() async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer');
    zone_ser = prefs.getString('zoneSer');
    zone_name = prefs.getString('zonesName');

    // เงื่อนไขเดิม (ไม่เข้า workflow นี้ก็จบ)
    if (ren != '50' && ren != '139' && ren != '195') {
      // await read_GC_area(); // ถ้ามี workflow อื่น
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingAreas = true;
      propertiesModel.clear();
    });

    try {
      // 1) โหลด properties ก่อน
      final props = await read_GC_properties(zone_ser, null, null);
      if (props.isEmpty) {
        // debugPrint('⚠️ ไม่พบ Properties ใด ๆ');
      }

      // 2) โหลด area โดยส่ง properties เข้าไปด้วย (ลดการอ้าง state ภายใน)
      final updated = await _readGcAreaCmmFast(
        ren: ren,
        zone: zone_ser,
        zoneName: zone_name,
        properties: props,
        dio: dio,
        cancelToken: cancelToken,
      );

      if (!mounted) return;
      setState(() {
        propertiesModel = props;
        areaModels = updated.areaModels;
        _areaModels = [...updated.areaModels];
        areaQuotModels = updated.areaQuotModels;
        zone_ser = updated.zone;
        zone_name = updated.zoneName;
        _btnKeys = List.generate(areaModels.length, (_) => GlobalKey());
      });

      if (zone_ser != null && zone_ser != '0') {
        loadSvg();
      }
    } catch (e, st) {
      //  debugPrint('❌ dataProperties error: $e\n$st');
      if (!mounted) return;
      // อาจจะแจ้งเตือนผู้ใช้
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('โหลดข้อมูลไม่สำเร็จ')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingAreas = false);
    }
  }

  Future<_AreaLoadResult> _readGcAreaCmmFast({
    required String? ren,
    required String? zone,
    required String? zoneName,
    required List<PropertiesModel> properties,
    required Dio dio,
    CancelToken? cancelToken,
  }) async {
    final List<AreaModel> areaLocal = [];
    final List<AreaQuotModel> quotLocal = [];

    // 1) ดึง area ทั้งหมด
    final url = Uri.parse(
      '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone',
    );
    // debugPrint('🔸 GC_areaAll: $url');

    final res = await dio.getUri(url, cancelToken: cancelToken);
    final raw = res.data;

    // 2) พาร์ส JSON หนัก ๆ ด้วย compute (แยก isolate)
    if (raw == null || raw is! List) {
      return _AreaLoadResult(
        areaModels: areaLocal,
        areaQuotModels: quotLocal,
        zone: zone,
        zoneName: zoneName,
        totalMatched: 0,
      );
    }

    final List<dynamic> listDyn = raw;
    final parsedAreas = await compute(parseAreasIsolate, listDyn);

    // 3) ทำ map aser -> props (O(1) lookup)
    final propMap = <String, List<PropertiesModel>>{};
    for (final p in properties) {
      final key = p.newRequest?.aser?.toString();
      if (key == null) continue;
      (propMap[key] ??= []).add(p);
    }

    // 4) จับคู่ properties กับ area (ไม่แตะ UI)
    int totalMatched = 0;
    for (final area in parsedAreas) {
      final key = area.ser?.toString();
      final matched = (key != null)
          ? (propMap[key] ?? const <PropertiesModel>[])
          : const <PropertiesModel>[];
      area.properties = matched;
      areaLocal.add(area);
      totalMatched += matched.length;
    }
    // debugPrint('✅ จับคู่สำเร็จทั้งหมด: $totalMatched รายการ');

    // 5) โหลด quot เฉพาะที่จำเป็น + จำกัด concurrency
    final targets = areaLocal
        .where((a) => a.quantity != null && a.quantity != '1')
        .toList();
    const parallel = 6;
    for (final chunk in chunked(targets, parallel)) {
      await Future.wait(chunk.map((area) async {
        final quotUrl = Uri.parse(
          '${MyConstant().domain}/GC_area_quot.php'
          '?isAdd=true&ren=$ren&qin=${area.ln_q}&qinser=${area.ser}',
        );
        try {
          final r = await dio.getUri(
            quotUrl,
            cancelToken: cancelToken,
            options: Options(responseType: ResponseType.json),
          );
          final data = r.data;
          if (data is List) {
            quotLocal.addAll(data.map((e) => AreaQuotModel.fromJson(e)));
          }
        } catch (e) {
          //debugPrint('⚠️ quot load error: $e');
        }
      }));
    }

    return _AreaLoadResult(
      areaModels: areaLocal,
      areaQuotModels: quotLocal,
      zone: zone,
      zoneName: zoneName,
      totalMatched: totalMatched,
    );
  }

  //////------------------------------------------->
  // Future<void> Data_Properties() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var ren = preferences.getString('renTalSer');
  //   zone_ser = preferences.getString('zoneSer');
  //   zone_name = preferences.getString('zonesName');

  //   if (ren.toString() == '50' || ren.toString() == '139') {
  //     setState(() {
  //       propertiesModel.clear();
  //     });

  //     print('⏳ กำลังโหลด Properties...');
  //     final result = await read_GC_properties(
  //         zone_ser, null, areaModels.length.toString());

  //     print('📦 Properties ที่โหลดได้: ${result.length}');
  //     // print(result);
  //     // for (var p in result) {
  //     //   print('🔸 Property: ${p.newRequest?.aser}');
  //     // }

  //     if (result.isEmpty) {
  //       print('⚠️ ไม่พบ Properties ใด ๆ');
  //     }

  //     setState(() {
  //       propertiesModel = result;
  //     });
  //     await read_GC_area_CMM(); // ควรรอหลังจาก setState เพื่อให้ propertiesModel พร้อม
  //   } else {
  //     // await read_GC_area();
  //   }
  // }

  // Future<void> read_GC_area_CMM() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final ren = prefs.getString('renTalSer');
  //   final zone = prefs.getString('zoneSer');
  //   final zoneName = prefs.getString('zonesName');

  //   setState(() {
  //     areaModels.clear();
  //     areaQuotModels.clear();
  //     _areaModels.clear();
  //     if (zone == null || zone == '0') areaFloorplanModels.clear();
  //   });

  //   final url = Uri.parse(
  //     (zone == null || zone == '0')
  //         ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
  //         : '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone',
  //     // '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone',
  //   );
  //   print('🔸 Property: ${url}');
  //   try {
  //     final res = await dio.get(url.toString(), cancelToken: cancelToken);
  //     final data = res.data;

  //     if (data == null || data is! List) return;

  //     // 🧠 Map aser → List<PropertiesModel>
  //     final propMap = <String, List<PropertiesModel>>{};
  //     for (var p in propertiesModel) {
  //       final key = p.newRequest?.aser?.toString();
  //       print('🔸 Property: ${key}');
  //       if (key != null) propMap.putIfAbsent(key, () => []).add(p);
  //     }

  //     int totalMatched = 0; // 👈 ตัวนับรวม

  //     for (var m in data) {
  //       final area = AreaModel.fromJson(m);
  //       final key = area.ser?.toString();
  //       final matched = propMap[key] ?? [];

  //       area.properties = matched;
  //       areaModels.add(area);

  //       totalMatched += matched.length; // 👈 นับ match ต่อรอบ

  //       if (area.quantity != null && area.quantity != '1') {
  //         final quotUrl =
  //             '${MyConstant().domain}/GC_area_quot.php?isAdd=true&ren=$ren&qin=${area.ln_q}&qinser=${area.ser}';
  //         final res = await http.get(Uri.parse(quotUrl));
  //         final quotList = json.decode(res.body);
  //         if (quotList is List) {
  //           areaQuotModels.addAll(
  //               quotList.map((e) => AreaQuotModel.fromJson(e)).toList());
  //         }
  //       }
  //     }

  //     print('✅ จับคู่สำเร็จทั้งหมด: $totalMatched รายการ');

  //     setState(() {
  //       _areaModels = [...areaModels];
  //       zone_ser = zone;
  //       zone_name = zoneName;
  //       _btnKeys = List.generate(areaModels.length, (_) => GlobalKey());
  //     });

  //     if (zone != null && zone != '0') loadSvg();
  //   } catch (e) {
  //     print('❌ Error loading area: $e');
  //   }
  // }

  // Future<Null> read_GC_area() async {
  //   if (areaModels.isNotEmpty) {
  //     setState(() {
  //       areaQuotModels.clear();
  //       areaModels.clear();
  //       _areaModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var ren = preferences.getString('renTalSer');
  //   var zone = preferences.getString('zoneSer');

  //   //print('zone >>>>>> $zone');

  //   String url = zone == null
  //       ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
  //       : zone == '0'
  //           ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
  //           : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

  //   try {
  //     // var response = await http.get(Uri.parse(url));
  //     final response = await dio.get(
  //       Uri.parse(url).toString(),
  //       cancelToken: cancelToken,
  //     );
  //     var result = response.data;
  //     // var result = json.decode(response.body);
  //     // print(result);
  //     if (result != null) {
  //       for (var map in result) {
  //         AreaModel areaModel = AreaModel.fromJson(map);

  //         setState(() {
  //           areaModels.add(areaModel);
  //         });

  //         if (areaModel.quantity != '1' && areaModel.quantity != null) {
  //           var qin = areaModel.ln_q;
  //           var qinser = areaModel.ser;
  //           String url =
  //               '${MyConstant().domain}/GC_area_quot.php?isAdd=true&ren=$ren&qin=$qin&qinser=$qinser';

  //           try {
  //             var response = await http.get(Uri.parse(url));

  //             var result = json.decode(response.body);
  //             // print(result);
  //             if (result != null) {
  //               for (var map in result) {
  //                 AreaQuotModel areaQuotModel = AreaQuotModel.fromJson(map);
  //                 setState(() {
  //                   areaQuotModels.add(areaQuotModel);
  //                 });
  //               }
  //             }
  //           } catch (e) {}
  //         }
  //       }
  //       // print(
  //       //     'areaQuotModels.length>>>>>>>> ${areaQuotModels.length} ${areaQuotModels.map((e) => '152' == e.ser ? e.docno : '0').toString()}');
  //       if (zone == null || zone == '0') {
  //         setState(() {
  //           areaFloorplanModels.clear();
  //         });
  //       } else {
  //         setState(() {
  //           loadSvg();
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         if (areaModels.isEmpty) {
  //           preferences.remove('zoneSer');
  //           preferences.remove('zonesName');
  //           zone_ser = null;
  //           zone_name = null;
  //         }
  //       });
  //     }
  //     setState(() {
  //       _areaModels = areaModels;
  //       zone_ser = preferences.getString('zoneSer');
  //       zone_name = preferences.getString('zonesName');
  //     });
  //     _btnKeys = List.generate(areaModels.length, (_) => GlobalKey());

  //     // print(
  //     //     'zoneModels >>. ${zoneModels.length} ${areaModels.map((e) => e.zser).toString()}');
  //   } on DioException catch (e) {
  //     if (CancelToken.isCancel(e)) {
  //       print('⛔ API ถูกยกเลิก: $e');
  //     } else {
  //       print('❌ Dio Error: ${e.message}');
  //     }
  //   } catch (e) {
  //     print('❌ Unknown Error: $e');
  //   }
  // }

  @override
  void dispose() {
    cancelToken.cancel("🔹 User left the page");
    // ยกเลิกงาน network ที่ค้างอยู่เมื่อ widget ถูกปิด
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('Widget disposed');
    }
    super.dispose();
  }

  // @override
  // void dispose() {
  //   cancelToken.cancel("🔹 User left the page");
  //   super.dispose();
  // }

  ////////////------------------------------------------>
  Future<Null> loadareaQuot(index) async {
    if (areaQuotModels.isNotEmpty) {
      setState(() {
        areaQuotModels.clear();
      });

      SharedPreferences preferences = await SharedPreferences.getInstance();

      var ren = preferences.getString('renTalSer');
      var zone = preferences.getString('zoneSer');

      var qin = areaModels[index].ln_q;
      var qinser = areaModels[index].ser;

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

  void loadSvg() async {
    setState(() {
      areaFloorplanModels.clear();
      areaFloorplanModels.clear();
    });

    // Update the key of the KeyedSubtree widget
    _countriesKey = UniqueKey();

    List<AreaModel> loadedCountries =
        await loadSvgImage(svgImage: '$Imgfloorplan', areaModels: areaModels);

    setState(() {
      areaFloorplanModels = loadedCountries;
    });
  }

  void onCountrySelected(AreaModel areaFloorplanModel) {
    if (areaFloorplanModel.name == null || areaFloorplanModel.name! == 'null') {
    } else {
      setState(() {
        if (areaFloorplanModelss != areaFloorplanModel) {
          areaFloorplanModelss = areaFloorplanModel;
        } else {
          areaFloorplanModelss = null;
        }
      });
    }
  }

  Future<Null> read_GC_areaSelect(int select) async {
    if (areaModels.length != 0) {
      areaModels.clear();
      _areaModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $select');

    if (select == 1) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            AreaModel areaModel = AreaModel.fromJson(map);
            setState(() {
              areaModels.add(areaModel);
            });
          }
        } else {
          setState(() {
            if (areaModels.isEmpty) {
              preferences.remove('zoneSer');
              preferences.remove('zonesName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          _areaModels = areaModels;
          zone_ser = preferences.getString('zoneSer');
          zone_name = preferences.getString('zonesName');
        });
      } catch (e) {}
    } else if (select == 2) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            AreaModel areaModel = AreaModel.fromJson(map);
            var daterx = areaModel.ldate;

            if (daterx != null) {
              int daysBetween(DateTime from, DateTime to) {
                from = DateTime(from.year, from.month, from.day);
                to = DateTime(to.year, to.month, to.day);
                return (to.difference(from).inHours / 24).round();
              }

              var birthday = DateTime.parse('$daterx 00:00:00.000')
                  .add(const Duration(days: -30));
              var date2 = DateTime.now();
              var difference = daysBetween(birthday, date2);

              // print('difference == $difference');

              if (difference < 30 && difference > 0) {
                setState(() {
                  areaModels.add(areaModel);
                });
              }
            }
          }
        } else {
          setState(() {
            if (areaModels.isEmpty) {
              preferences.remove('zoneSer');
              preferences.remove('zonesName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          _areaModels = areaModels;
          zone_ser = preferences.getString('zoneSer');
          zone_name = preferences.getString('zonesName');
        });
      } catch (e) {}
    }
    //  else if (select == 3) {
    //   String url = zone == null
    //       ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
    //       : zone == '0'
    //           ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
    //           : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

    //   try {
    //     var response = await http.get(Uri.parse(url));

    //     var result = json.decode(response.body);
    //     // print(result);
    //     if (result != null) {
    //       for (var map in result) {
    //         AreaModel areaModel = AreaModel.fromJson(map);
    //         if (areaModel.quantity == '2' || areaModel.quantity == '3') {
    //           setState(() {
    //             areaModels.add(areaModel);
    //           });
    //         }
    //       }
    //     } else {
    //       setState(() {
    //         if (areaModels.isEmpty) {
    //           preferences.remove('zoneSer');
    //           preferences.remove('zonesName');
    //           zone_ser = null;
    //           zone_name = null;
    //         }
    //       });
    //     }
    //     setState(() {
    //       _areaModels = areaModels;
    //       zone_ser = preferences.getString('zoneSer');
    //       zone_name = preferences.getString('zonesName');
    //     });
    //   } catch (e) {}
    // }
    else if (select == 3) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            AreaModel areaModel = AreaModel.fromJson(map);
            if (areaModel.quantity == null) {
              setState(() {
                areaModels.add(areaModel);
              });
            }
          }
        } else {
          setState(() {
            if (areaModels.isEmpty) {
              preferences.remove('zoneSer');
              preferences.remove('zonesName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          _areaModels = areaModels;
          zone_ser = preferences.getString('zoneSer');
          zone_name = preferences.getString('zonesName');
        });
      } catch (e) {}
    } else if (select == 4) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            AreaModel areaModel = AreaModel.fromJson(map);

            if (areaModel.quantity == '1') {
              setState(() {
                if (datex.isAfter(
                            DateTime.parse('${areaModel.ldate} 00:00:00.000')
                                .subtract(const Duration(days: 0))) !=
                        true ||
                    datex.isAfter(
                            DateTime.parse('${areaModel.ldate} 00:00:00.000')
                                .subtract(Duration(days: open_set_date))) !=
                        true) {
                  areaModels.add(areaModel);
                }
              });
            }
          }
        } else {
          setState(() {
            if (areaModels.isEmpty) {
              preferences.remove('zoneSer');
              preferences.remove('zonesName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          _areaModels = areaModels;
          zone_ser = preferences.getString('zoneSer');
          zone_name = preferences.getString('zonesName');
        });
      } catch (e) {}
    } else if (select == 5) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            AreaModel areaModel = AreaModel.fromJson(map);
            if (areaModel.quantity == '1') {
              setState(() {
                if (datex.isAfter(
                        DateTime.parse('${areaModel.ldate} 00:00:00.000')
                            .subtract(const Duration(days: 0))) ==
                    true) {
                  areaModels.add(areaModel);
                }
              });
            }
          }
        } else {
          setState(() {
            if (areaModels.isEmpty) {
              preferences.remove('zoneSer');
              preferences.remove('zonesName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          _areaModels = areaModels;
          zone_ser = preferences.getString('zoneSer');
          zone_name = preferences.getString('zonesName');
        });
      } catch (e) {}
    } else if (select == 6) {
      String url = zone == null
          ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
          : zone == '0'
              ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
              : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';

      try {
        var response = await http.get(Uri.parse(url));

        var result = json.decode(response.body);
        // print(result);
        if (result != null) {
          for (var map in result) {
            AreaModel areaModel = AreaModel.fromJson(map);
            if (areaModel.quantity == '1' || areaModel.quantity == null) {
              setState(() {
                areaModels.add(areaModel);
              });
            }
          }
        } else {
          setState(() {
            if (areaModels.isEmpty) {
              preferences.remove('zoneSer');
              preferences.remove('zonesName');
              zone_ser = null;
              zone_name = null;
            }
          });
        }
        setState(() {
          _areaModels = areaModels;
          zone_ser = preferences.getString('zoneSer');
          zone_name = preferences.getString('zonesName');
        });
      } catch (e) {}
    }
  }

  ////////-------------------------------------------------------->

  Future<Null> red_Trans_c_maintenance(aser) async {
    setState(() {
      maintenanceModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zoneSer');

    // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>> $select');

    String url =
        '${MyConstant().domain}/GC_maintenance.php?isAdd=true&ren=$ren&aser=$aser';
    //print('result $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          MaintenanceModel maintenanceModel = MaintenanceModel.fromJson(map);
          setState(() {
            maintenanceModels.add(maintenanceModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }
    } catch (e) {}
  }

/////////--------------------------------->
  _searchBar() {
    return TextField(
      autofocus: false,
      controller: searchBar_Controller,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        // fontSize: 22.0,
        color: TextHome_Color.TextHome_Colors,
      ),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: const TextStyle(
          // fontSize: 20.0,
          color: TextHome_Color.TextHome_Colors,
        ),
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
        text = text;
        setState(() {
          textsearch = text;
          areaModels = _areaModels.where((areaModel) {
            var notTitle0 = areaModel.zn.toString();
            var notTitle1 = areaModel.ln.toString();
            var notTitle = areaModel.lncode.toString();
            var notsname = areaModel.sname.toString();
            var notcname = areaModel.cname.toString();
            var notcid = areaModel.cid.toString();
            var notfid = areaModel.fid.toString();
            return notTitle.contains(text) ||
                notTitle0.contains(text) ||
                notTitle1.contains(text) ||
                notsname.contains(text) ||
                notcname.contains(text) ||
                notcid.contains(text) ||
                notfid.contains(text);
          }).toList();
        });
        //print('textsearch>>>>  $textsearch');
      },
    );
  }

  final TextEditingController textEditingController = TextEditingController();
  _searchBar_zone() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        // fontSize: 22.0,
        color: TextHome_Color.TextHome_Colors,
      ),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: const TextStyle(
          // fontSize: 20.0,
          color: TextHome_Color.TextHome_Colors,
        ),
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
        text = text;
        setState(() {
          textzonesearch = text;
          zoneModels = _zoneModels.where((zoneModel) {
            var notTitle = zoneModel.zn.toString();

            return notTitle.contains(text);
          }).toList();
        });
        //  print('textsearchzone>>>>  $text');
      },
    );
  }

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

  ///////////////------------------------------------------------->
  double _scaleFactor = 1.0; // define the initial scale factor

  void _zoomIn() {
    setState(() {
      _scaleFactor *= 1.2; // increase the scale factor by 20%
    });
  }

  void _zoomOut() {
    setState(() {
      _scaleFactor /= 1.2; // decrease the scale factor by 20%
    });
  }

  ///----------------->
  @override
  Widget build(BuildContext context) {
    double hi_ = MediaQuery.of(context).size.height / 1.7;
    return (Visit_ == 'map')
        ? NodeDataScreen2(
            data_uuid: data_uuid,
            requestStep: requestStep,
            payment_uuid: payment_uuid,
            payment_uuid_amount: payment_uuid_amount,
            payment_jsonx: payment_jsonx)
        // NodeDataScreen2()
        : SingleChildScrollView(
            child: Column(
              children: [
                if ((Ser_Body == 0))
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
                                        'พื้นที่เช่า ',
                                        ChaoAreaScreen_Color.Colors_Text1_,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        2),
                                    AutoSizeText(
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: viewpage(context, '$Ser_nowpage'),
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
                if ((Ser_Body != 0 && Ser_Body != 5))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 8,
                          child: Translate.TranslateAndSet_TextAutoSize(
                              Ser_Body == 1
                                  ? 'เสนอราคา'
                                  : Ser_Body == 2
                                      ? 'ทำ/ต่อสัญญา'
                                      : '',
                              ChaoAreaScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              8,
                              20,
                              1),
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () async {
                              Dia_log1(context);
                              Data_Properties();
                              setState(() {
                                Ser_Body = 0;
                              });
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
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Translate.TranslateAndSetText(
                                        'ปิด',
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
                        ),
                      ],
                    ),
                  ),
                if ((Ser_Body == 0))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppbackgroundColor.TiTile_Box,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        // border: Border.all(color: Colors.white, width: 1),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          subzoneModels.length == 1
                              ? SizedBox()
                              : MediaQuery.of(context).size.shortestSide <
                                      MediaQuery.of(context).size.width * 1
                                  ? Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Translate.TranslateAndSetText(
                                            'โซน:',
                                            ChaoAreaScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            2),
                                      ))
                                  : const SizedBox(),

                          subzoneModels.length == 1
                              ? SizedBox()
                              : Expanded(
                                  flex: MediaQuery.of(context)
                                              .size
                                              .shortestSide <
                                          MediaQuery.of(context).size.width * 1
                                      ? 2
                                      : 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      width: 200,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                            isExpanded: true,
                                            searchController:
                                                Dropdown_Controller_zone_Sub,
                                            searchInnerWidget: Container(
                                              width: 200,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red[100]!
                                                    .withOpacity(0.5),
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
                                              child: TextFormField(
                                                expands: true,
                                                maxLines: null,
                                                controller:
                                                    Dropdown_Controller_zone_Sub,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                                  hintText: 'Search...',
                                                  // fillColor: Colors.red[300],
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            hint: Translate.TranslateAndSetText(
                                                zone_Subname == null
                                                    ? 'ทั้งหมด'
                                                    : '$zone_Subname',
                                                ChaoAreaScreen_Color
                                                    .Colors_Text2_,
                                                TextAlign.center,
                                                FontWeight.bold,
                                                FontWeight_.Fonts_T,
                                                14,
                                                2),
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: TextHome_Color
                                                  .TextHome_Colors,
                                            ),
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontFamily: Font_.Fonts_T),
                                            iconSize: 30,
                                            buttonHeight: 35,
                                            dropdownDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            items: subzoneModels
                                                .map((item) =>
                                                    DropdownMenuItem<String>(
                                                      value:
                                                          '${item.ser},${item.zn}',
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item.zn!,
                                                            maxLines: 2,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                          Divider(
                                                            color: Colors
                                                                .grey[300],
                                                            height: 4.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),

                                            // value: selectedValue,

                                            onChanged: (value) async {
                                              var zones = value!.indexOf(',');
                                              var zoneSer =
                                                  value.substring(0, zones);
                                              var zonesName =
                                                  value.substring(zones + 1);
                                              // print(
                                              //     'mmmmm ${zoneSer.toString()} $zonesName');

                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              preferences.setString(
                                                  'zoneSubSer',
                                                  zoneSer.toString());
                                              preferences.setString(
                                                  'zonesSubName',
                                                  zonesName.toString());
                                              preferences.remove("zoneSer");
                                              preferences.remove("zonesName");

                                              // setState(() {
                                              //   zoneModels.clear();
                                              //   zone_ser =
                                              //       preferences.getString('zoneSer');
                                              //   zone_name =
                                              //       preferences.getString('zonesName');
                                              //   zone_Subser =
                                              //       preferences.getString('zoneSubSer');
                                              //   zone_Subname =
                                              //       preferences.getString('zonesSubName');
                                              //   read_GC_Sub_zone().then((value) =>
                                              //       read_GC_zone()
                                              //           .then((value) => read_GC_area()));
                                              // });

                                              String? _route = preferences
                                                  .getString('route');
                                              MaterialPageRoute
                                                  materialPageRoute =
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          AdminScafScreen(
                                                              route: _route));
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  materialPageRoute,
                                                  (route) => false);
                                            },
                                            searchMatchFn: (item, searchValue) {
                                              return item.value
                                                  .toString()
                                                  .contains(searchValue);
                                            },
                                            onMenuStateChange: (isOpen) {
                                              if (!isOpen) {
                                                Dropdown_Controller_zone_Sub
                                                    .clear();
                                              }
                                            }),
                                      ),

                                      //  DropdownButtonFormField2(
                                      //   decoration: InputDecoration(
                                      //     isDense: true,
                                      //     contentPadding: EdgeInsets.zero,
                                      //     border: OutlineInputBorder(
                                      //       borderRadius:
                                      //           BorderRadius.circular(10),
                                      //     ),
                                      //   ),
                                      //   isExpanded: true,
                                      //   hint: Translate.TranslateAndSetText(
                                      //       zone_Subname == null
                                      //           ? 'ทั้งหมด'
                                      //           : '$zone_Subname',
                                      //       ChaoAreaScreen_Color.Colors_Text2_,
                                      //       TextAlign.center,
                                      //       FontWeight.bold,
                                      //       FontWeight_.Fonts_T,
                                      //       14,
                                      //       2),

                                      //   icon: const Icon(
                                      //     Icons.arrow_drop_down,
                                      //     color: TextHome_Color.TextHome_Colors,
                                      //   ),
                                      //   style: const TextStyle(
                                      //       color: Colors.green,
                                      //       fontFamily: Font_.Fonts_T),
                                      //   iconSize: 30,
                                      //   buttonHeight: 40,
                                      //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                      //   dropdownDecoration: BoxDecoration(
                                      //     borderRadius:
                                      //         BorderRadius.circular(10),
                                      //   ),
                                      //   items: subzoneModels
                                      //       .map((item) =>
                                      //           DropdownMenuItem<String>(
                                      //             value:
                                      //                 '${item.ser},${item.zn}',
                                      //             child: Text(
                                      //               item.zn!,
                                      //               style: const TextStyle(
                                      //                   fontSize: 14,
                                      //                   fontFamily:
                                      //                       Font_.Fonts_T),
                                      //             ),
                                      //           ))
                                      //       .toList(),

                                      //   onChanged: (value) async {
                                      //     var zones = value!.indexOf(',');
                                      //     var zoneSer =
                                      //         value.substring(0, zones);
                                      //     var zonesName =
                                      //         value.substring(zones + 1);
                                      //     // print(
                                      //     //     'mmmmm ${zoneSer.toString()} $zonesName');

                                      //     SharedPreferences preferences =
                                      //         await SharedPreferences
                                      //             .getInstance();
                                      //     preferences.setString(
                                      //         'zoneSubSer', zoneSer.toString());
                                      //     preferences.setString('zonesSubName',
                                      //         zonesName.toString());
                                      //     preferences.remove("zoneSer");
                                      //     preferences.remove("zonesName");

                                      //     // setState(() {
                                      //     //   zoneModels.clear();
                                      //     //   zone_ser =
                                      //     //       preferences.getString('zoneSer');
                                      //     //   zone_name =
                                      //     //       preferences.getString('zonesName');
                                      //     //   zone_Subser =
                                      //     //       preferences.getString('zoneSubSer');
                                      //     //   zone_Subname =
                                      //     //       preferences.getString('zonesSubName');
                                      //     //   read_GC_Sub_zone().then((value) =>
                                      //     //       read_GC_zone()
                                      //     //           .then((value) => read_GC_area()));
                                      //     // });

                                      //     String? _route =
                                      //         preferences.getString('route');
                                      //     MaterialPageRoute materialPageRoute =
                                      //         MaterialPageRoute(
                                      //             builder:
                                      //                 (BuildContext context) =>
                                      //                     AdminScafScreen(
                                      //                         route: _route));
                                      //     Navigator.pushAndRemoveUntil(
                                      //         context,
                                      //         materialPageRoute,
                                      //         (route) => false);
                                      //   },
                                      //   // onSaved: (value) {
                                      //   //   // selectedValue = value.toString();
                                      //   // },
                                      // ),
                                    ),
                                  ),
                                ),
                          MediaQuery.of(context).size.shortestSide <
                                  MediaQuery.of(context).size.width * 1
                              ? Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Translate.TranslateAndSetText(
                                        'โซนพื้นที่เช่า:',
                                        ChaoAreaScreen_Color.Colors_Text2_,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        2),
                                  ))
                              : const SizedBox(),
                          Expanded(
                            flex: MediaQuery.of(context).size.shortestSide <
                                    MediaQuery.of(context).size.width * 1
                                ? 2
                                : 3,
                            child: StreamBuilder<Object>(
                                stream: Stream.periodic(
                                    const Duration(milliseconds: 15), (i) => i),
                                builder: (context, snapshot) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      width: 200,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                            isExpanded: true,
                                            searchController:
                                                Dropdown_Controller,
                                            searchInnerWidget: Container(
                                              width: 200,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red[100]!
                                                    .withOpacity(0.5),
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
                                              child: TextFormField(
                                                expands: true,
                                                maxLines: null,
                                                controller: Dropdown_Controller,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                                  hintText: 'Search...',
                                                  // fillColor: Colors.red[300],
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            hint: Translate.TranslateAndSetText(
                                                zone_name == null
                                                    ? 'ทั้งหมด'
                                                    : '$zone_name',
                                                ChaoAreaScreen_Color
                                                    .Colors_Text2_,
                                                TextAlign.center,
                                                FontWeight.bold,
                                                FontWeight_.Fonts_T,
                                                14,
                                                2),
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: TextHome_Color
                                                  .TextHome_Colors,
                                            ),
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontFamily: Font_.Fonts_T),
                                            iconSize: 30,
                                            buttonHeight: 35,
                                            dropdownDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            items: zoneModels
                                                .map((item) =>
                                                    DropdownMenuItem<String>(
                                                      value:
                                                          '${item.ser},${item.zn}',
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item.zn!,
                                                            maxLines: 2,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                          Divider(
                                                            color: Colors
                                                                .grey[300],
                                                            height: 4.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),

                                            // value: selectedValue,
                                            onChanged: (value) async {
                                              //   var zones = value!.indexOf(',');
                                              // var zoneSer = value.substring(0, zones);
                                              // var zonesName = value.substring(zones + 1);
                                              // var zonesNames = zonesName.indexOf(',');
                                              // var zonesNamenew =
                                              //     zonesName.substring(0, zonesNames);
                                              // var zonesNamesub =
                                              //     zonesName.substring(zonesNames + 1);
                                              // print(
                                              //     'mmmmm>> zoneSer $zoneSer mmmm>>zonesName $zonesName mmmm>>zonesNames $zonesNames mmmm>>zonesNamenew $zonesNamenew mmmm>>zonesNamesub $zonesNamesub');

                                              var zones = value!.indexOf(',');
                                              var zoneSer =
                                                  value.substring(0, zones);
                                              var zonesName =
                                                  value.substring(zones + 1);
                                              // print('mmmmm ${zoneSer.toString()} $zonesName');

                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              preferences.setString('zoneSer',
                                                  zoneSer.toString());
                                              preferences.setString('zonesName',
                                                  zonesName.toString());

                                              int selectedIndex = zoneModels
                                                  .indexWhere((element) =>
                                                      element.ser == zoneSer &&
                                                      element.zn == zonesName);

                                              // print('Selected index: $selectedIndex');
                                              if (selectedIndex == 0) {
                                              } else {
                                                Img_Zone =
                                                    '${MyConstant().domain}/files/${DBN_}/zone/${zoneModels[selectedIndex].img}';
                                                // Img_Zone =
                                                //     'https://dzentric.com/chao_perty/chao_api/files/${DBN_}/zone/${zoneModels[selectedIndex].img}';
                                                Imgfloorplan =
                                                    '${MyConstant().domain}/files/${DBN_}/zone/${zoneModels[selectedIndex].img_floorplan}';
                                              }
                                              String? _route = preferences
                                                  .getString('route');
                                              MaterialPageRoute
                                                  materialPageRoute =
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          AdminScafScreen(
                                                              route: _route));
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  materialPageRoute,
                                                  (route) => false);
                                              setState(() {
                                                areaFloorplanModels.clear;
                                                Data_Properties();
                                                // read_GC_area();
                                              });
                                              // print(selectedIndex);
                                              // print(selectedIndex);
                                              // print(selectedIndex);
                                              // print(selectedIndex);
                                            },
                                            searchMatchFn: (item, searchValue) {
                                              return item.value
                                                  .toString()
                                                  .contains(searchValue);
                                            },
                                            onMenuStateChange: (isOpen) {
                                              if (!isOpen) {
                                                Dropdown_Controller.clear();
                                              }
                                            }),
                                      ),

                                      //  DropdownButtonFormField2(
                                      //   decoration: InputDecoration(
                                      //     isDense: true,
                                      //     contentPadding: EdgeInsets.zero,
                                      //     border: OutlineInputBorder(
                                      //       borderRadius:
                                      //           BorderRadius.circular(10),
                                      //     ),
                                      //   ),
                                      //   isExpanded: true,
                                      //   searchInnerWidget: _searchBar_zone(),
                                      //   searchController: textEditingController,
                                      //   searchMatchFn: (item, searchValue) {
                                      //     if (textzonesearch == null) {
                                      //       return zoneModels
                                      //           .map((item) =>
                                      //               DropdownMenuItem<String>(
                                      //                 value:
                                      //                     '${item.ser},${item.zn}',
                                      //                 child: Text(
                                      //                   item.zn!,
                                      //                   style: const TextStyle(
                                      //                       fontSize: 14,
                                      //                       fontFamily:
                                      //                           Font_.Fonts_T),
                                      //                 ),
                                      //               ))
                                      //           .toList()
                                      //           .contains(searchValue);
                                      //     } else {
                                      //       return zoneModels
                                      //           .map((item) =>
                                      //               DropdownMenuItem<String>(
                                      //                 value:
                                      //                     '${item.ser},${item.zn}',
                                      //                 child: Text(
                                      //                   item.zn!,
                                      //                   style: const TextStyle(
                                      //                       fontSize: 14,
                                      //                       fontFamily:
                                      //                           Font_.Fonts_T),
                                      //                 ),
                                      //               ))
                                      //           .toList()
                                      //           .contains(textzonesearch);
                                      //     }
                                      //   },
                                      //   hint: Translate.TranslateAndSetText(
                                      //       zone_name == null
                                      //           ? 'ทั้งหมด'
                                      //           : '$zone_name',
                                      //       ChaoAreaScreen_Color.Colors_Text2_,
                                      //       TextAlign.center,
                                      //       FontWeight.bold,
                                      //       FontWeight_.Fonts_T,
                                      //       14,
                                      //       2),

                                      //   icon: const Icon(
                                      //     Icons.arrow_drop_down,
                                      //     color: TextHome_Color.TextHome_Colors,
                                      //   ),
                                      //   style: const TextStyle(
                                      //       color: Colors.green,
                                      //       fontFamily: Font_.Fonts_T),
                                      //   iconSize: 30,
                                      //   buttonHeight: 40,
                                      //   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                      //   dropdownDecoration: BoxDecoration(
                                      //     borderRadius:
                                      //         BorderRadius.circular(10),
                                      //   ),
                                      //   items: zoneModels
                                      //       .map((item) =>
                                      //           DropdownMenuItem<String>(
                                      //             value:
                                      //                 '${item.ser},${item.zn}',
                                      //             child: Text(
                                      //               item.zn!,
                                      //               style: const TextStyle(
                                      //                   fontSize: 14,
                                      //                   fontFamily:
                                      //                       Font_.Fonts_T),
                                      //             ),
                                      //           ))
                                      //       .toList(),

                                      //   onChanged: (value) async {
                                      //     //   var zones = value!.indexOf(',');
                                      //     // var zoneSer = value.substring(0, zones);
                                      //     // var zonesName = value.substring(zones + 1);
                                      //     // var zonesNames = zonesName.indexOf(',');
                                      //     // var zonesNamenew =
                                      //     //     zonesName.substring(0, zonesNames);
                                      //     // var zonesNamesub =
                                      //     //     zonesName.substring(zonesNames + 1);
                                      //     // print(
                                      //     //     'mmmmm>> zoneSer $zoneSer mmmm>>zonesName $zonesName mmmm>>zonesNames $zonesNames mmmm>>zonesNamenew $zonesNamenew mmmm>>zonesNamesub $zonesNamesub');

                                      //     var zones = value!.indexOf(',');
                                      //     var zoneSer =
                                      //         value.substring(0, zones);
                                      //     var zonesName =
                                      //         value.substring(zones + 1);
                                      //     // print('mmmmm ${zoneSer.toString()} $zonesName');

                                      //     SharedPreferences preferences =
                                      //         await SharedPreferences
                                      //             .getInstance();
                                      //     preferences.setString(
                                      //         'zoneSer', zoneSer.toString());
                                      //     preferences.setString('zonesName',
                                      //         zonesName.toString());

                                      //     int selectedIndex =
                                      //         zoneModels.indexWhere((element) =>
                                      //             element.ser == zoneSer &&
                                      //             element.zn == zonesName);

                                      //     // print('Selected index: $selectedIndex');
                                      //     if (selectedIndex == 0) {
                                      //     } else {
                                      //       Img_Zone =
                                      //           '${MyConstant().domain}/files/${DBN_}/zone/${zoneModels[selectedIndex].img}';
                                      //       // Img_Zone =
                                      //       //     'https://dzentric.com/chao_perty/chao_api/files/${DBN_}/zone/${zoneModels[selectedIndex].img}';
                                      //       Imgfloorplan =
                                      //           '${MyConstant().domain}/files/${DBN_}/zone/${zoneModels[selectedIndex].img_floorplan}';
                                      //     }

                                      //     setState(() {
                                      //       areaFloorplanModels.clear;
                                      //       read_GC_area();
                                      //     });
                                      //     // print(selectedIndex);
                                      //     // print(selectedIndex);
                                      //     // print(selectedIndex);
                                      //     // print(selectedIndex);
                                      //   },
                                      //   // onSaved: (value) {
                                      //   //   // selectedValue = value.toString();
                                      //   // },
                                      // ),
                                    ),
                                  );
                                }),
                          ),
                          Expanded(
                            flex: MediaQuery.of(context).size.shortestSide <
                                    MediaQuery.of(context).size.width * 1
                                ? 1
                                : 2,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Translate.TranslateAndSetText(
                                  'ค้นหา:',
                                  ChaoAreaScreen_Color.Colors_Text2_,
                                  TextAlign.center,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
                                  14,
                                  2),
                            ),
                          ),
                          Expanded(
                            flex: MediaQuery.of(context).size.shortestSide <
                                    MediaQuery.of(context).size.width * 1
                                ? 8
                                : 6,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                // width: 120,
                                height: 40,
                                child: _searchBar(),
                              ),
                            ),
                          ),

                          // Expanded(
                          //   flex: 2,
                          //   child: SingleChildScrollView(
                          //     scrollDirection: Axis.horizontal,
                          //     child: Row(
                          //       children: [
                          //         Container(
                          //           child: Row(
                          //             children: [

                          //               const Padding(
                          //                 padding: EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   'โซนพื้นที่เช่า:',
                          //                   style: TextStyle(
                          //                       color: PeopleChaoScreen_Color
                          //                           .Colors_Text1_,
                          //                       fontWeight: FontWeight.bold,
                          //                       fontFamily: FontWeight_.Fonts_T),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Container(
                          //                   decoration: BoxDecoration(
                          //                     color:
                          //                         AppbackgroundColor.Sub_Abg_Colors,
                          //                     borderRadius: const BorderRadius.only(
                          //                         topLeft: Radius.circular(10),
                          //                         topRight: Radius.circular(10),
                          //                         bottomLeft: Radius.circular(10),
                          //                         bottomRight: Radius.circular(10)),
                          //                     border: Border.all(
                          //                         color: Colors.grey, width: 1),
                          //                   ),
                          //                   width: 150,
                          //                   child: DropdownButtonFormField2(
                          //                     decoration: InputDecoration(
                          //                       isDense: true,
                          //                       contentPadding: EdgeInsets.zero,
                          //                       border: OutlineInputBorder(
                          //                         borderRadius:
                          //                             BorderRadius.circular(10),
                          //                       ),
                          //                     ),
                          //                     isExpanded: true,
                          //                     hint: Text(
                          //                       zone_name == null
                          //                           ? 'ทั้งหมด'
                          //                           : '$zone_name',
                          //                       maxLines: 1,
                          //                       style: const TextStyle(
                          //                           fontSize: 14,
                          //                           color: PeopleChaoScreen_Color
                          //                               .Colors_Text2_,
                          //                           fontFamily: Font_.Fonts_T),
                          //                     ),
                          //                     icon: const Icon(
                          //                       Icons.arrow_drop_down,
                          //                       color: TextHome_Color.TextHome_Colors,
                          //                     ),
                          //                     style: const TextStyle(
                          //                         color: Colors.green,
                          //                         fontFamily: Font_.Fonts_T),
                          //                     iconSize: 30,
                          //                     buttonHeight: 40,
                          //                     // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                          //                     dropdownDecoration: BoxDecoration(
                          //                       borderRadius:
                          //                           BorderRadius.circular(10),
                          //                     ),
                          //                     items: zoneModels
                          //                         .map((item) =>
                          //                             DropdownMenuItem<String>(
                          //                               value:
                          //                                   '${item.ser},${item.zn}',
                          //                               child: Text(
                          //                                 item.zn!,
                          //                                 style: const TextStyle(
                          //                                     fontSize: 14,
                          //                                     fontFamily:
                          //                                         Font_.Fonts_T),
                          //                               ),
                          //                             ))
                          //                         .toList(),

                          //                     onChanged: (value) async {
                          //                       var zones = value!.indexOf(',');
                          //                       var zoneSer =
                          //                           value.substring(0, zones);
                          //                       var zonesName =
                          //                           value.substring(zones + 1);
                          //                       print(
                          //                           'mmmmm ${zoneSer.toString()} $zonesName');

                          //                       SharedPreferences preferences =
                          //                           await SharedPreferences
                          //                               .getInstance();
                          //                       preferences.setString(
                          //                           'zoneSer', zoneSer.toString());
                          //                       preferences.setString('zonesName',
                          //                           zonesName.toString());

                          //                       setState(() {
                          //                         read_GC_area();
                          //                       });
                          //                     },
                          //                     // onSaved: (value) {
                          //                     //   // selectedValue = value.toString();
                          //                     // },
                          //                   ),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: EdgeInsets.all(8.0),
                          //                 child: Text(
                          //                   'ค้นหา:',
                          //                   textAlign: TextAlign.end,
                          //                   style: TextStyle(
                          //                       color: PeopleChaoScreen_Color
                          //                           .Colors_Text1_,
                          //                       fontWeight: FontWeight.bold,
                          //                       fontFamily: FontWeight_.Fonts_T),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.all(8.0),
                          //                 child: Container(
                          //                   decoration: BoxDecoration(
                          //                     color:
                          //                         AppbackgroundColor.Sub_Abg_Colors,
                          //                     borderRadius: const BorderRadius.only(
                          //                         topLeft: Radius.circular(10),
                          //                         topRight: Radius.circular(10),
                          //                         bottomLeft: Radius.circular(10),
                          //                         bottomRight: Radius.circular(10)),
                          //                     border: Border.all(
                          //                         color: Colors.grey, width: 1),
                          //                   ),
                          //                   width: 120,
                          //                   height: 35,
                          //                   child: _searchBar(),
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
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: Container(
                                // width: 100,
                                // height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)),
                                  // border: Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Translate.TranslateAndSetText(
                                      'ดูแผนผัง',
                                      Colors.white,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      14,
                                      2),
                                ),
                              ),
                              onTap: () {
                                showDialog<String>(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    title: Center(
                                      child: Translate.TranslateAndSetText(
                                          'แผนผัง',
                                          ChaoAreaScreen_Color.Colors_Text2_,
                                          TextAlign.center,
                                          FontWeight.bold,
                                          FontWeight_.Fonts_T,
                                          14,
                                          2),
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          InteractiveViewer(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.brown[100],
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: (img_ == null ||
                                                      img_.toString() == '')
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  : Image.network(
                                                      '${MyConstant().domain}/files/$foder/contract/$img_',
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                            scaleEnabled: true,
                                            minScale: 0.5,
                                            maxScale: 5.0,
                                            transformationController:
                                                TransformationController()
                                                  ..value =
                                                      Matrix4.diagonal3Values(
                                                          _scaleFactor,
                                                          _scaleFactor,
                                                          1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 100,
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
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
                                              child: TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'OK'),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ปิด',
                                                        Colors.white,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          InkWell(
                            child: Container(
                                // padding: EdgeInsets.all(8.0),
                                child: CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 20,
                              child: PopupMenuButton(
                                child: const Center(
                                    child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                )),
                                itemBuilder: (BuildContext context) => [
                                  // PopupMenuItem(
                                  //   child: InkWell(
                                  //       onTap: () async {
                                  //         if (renTal_lavel <= 2) {
                                  //           Navigator.pop(context);
                                  //           infomation();
                                  //         } else {
                                  //           SharedPreferences preferences =
                                  //               await SharedPreferences
                                  //                   .getInstance();
                                  //           var zone = preferences
                                  //               .getString('zoneSer');
                                  //           if (zone == '0' || zone == null) {
                                  //             ScaffoldMessenger.of(context)
                                  //                 .showSnackBar(
                                  //               SnackBar(
                                  //                 content: Translate
                                  //                     .TranslateAndSetText(
                                  //                         'กรุณาเลือกโซนพื้นที่เช่า',
                                  //                         Colors.white,
                                  //                         TextAlign.center,
                                  //                         FontWeight.bold,
                                  //                         FontWeight_.Fonts_T,
                                  //                         14,
                                  //                         2),
                                  //               ),
                                  //             );
                                  //           } else {
                                  //             setState(() {
                                  //               Ser_Body = 1;
                                  //               a_ln = null;
                                  //               a_ser = null;
                                  //               a_area = null;
                                  //               a_rent = null;
                                  //               a_page = '0';
                                  //             });
                                  //             Navigator.pop(context);
                                  //           }
                                  //         }
                                  //       },
                                  //       child: Container(
                                  //           padding: const EdgeInsets.all(10),
                                  //           width: MediaQuery.of(context)
                                  //               .size
                                  //               .width,
                                  //           child: Row(
                                  //             children: [
                                  //               Expanded(
                                  //                 child: Translate
                                  //                     .TranslateAndSetText(
                                  //                         '+ เสนอราคา',
                                  //                         ChaoAreaScreen_Color
                                  //                             .Colors_Text2_,
                                  //                         TextAlign.center,
                                  //                         FontWeight.bold,
                                  //                         FontWeight_.Fonts_T,
                                  //                         14,
                                  //                         2),
                                  //               )
                                  //             ],
                                  //           ))),
                                  // ),
                                  PopupMenuItem(
                                    child: InkWell(
                                        onTap: () async {
                                          if (renTal_lavel <= 2) {
                                            Navigator.pop(context);
                                            infomation();
                                          } else {
                                            SharedPreferences preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            var zone = preferences
                                                .getString('zoneSer');
                                            if (zone == '0' || zone == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Translate
                                                        .TranslateAndSetText(
                                                            'กรุณาเลือกโซนพื้นที่เช่า',
                                                            Colors.white,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            2)),
                                              );
                                            } else {
                                              setState(() {
                                                Ser_Body = 2;
                                                a_ln = null;
                                                a_ser = null;
                                                a_area = null;
                                                a_rent = null;
                                                a_page = '0';
                                              });
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          '+ ทำ/ต่อสัญญา',
                                                          ChaoAreaScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          2),
                                                )
                                              ],
                                            ))),
                                  ),
                                ],
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                if ((Ser_Body == 0))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white60,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          // border: Border.all(color: Colors.grey, width: 1),
                        ),
                        // padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            if (!Responsive.isDesktop(context))
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(dragDevices: {
                                    PointerDeviceKind.touch,
                                    PointerDeviceKind.mouse,
                                  }),
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(children: [
                                        Translate.TranslateAndSetText(
                                            'สถานะ : ',
                                            ChaoAreaScreen_Color.Colors_Text2_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            2),
                                        for (int i = 0; i < Status.length; i++)
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    tappedIndex_ = '';
                                                  });
                                                  setState(() {
                                                    Status_ = i + 1;
                                                  });
                                                  read_GC_areaSelect(i + 1);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: (i + 1 == 1)
                                                        ? (Status_ == i + 1)
                                                            ? Colors.grey[700]
                                                            : Colors.grey[300]
                                                        : (i + 1 == 2)
                                                            ? (Status_ == i + 1)
                                                                ? Colors
                                                                    .orange[700]
                                                                : Colors
                                                                    .orange[200]
                                                            // :
                                                            //  (i + 1 == 3)
                                                            //     ? (Status_ ==
                                                            //             i + 1)
                                                            //         ? Colors.blue[
                                                            //             700]
                                                            //         : Colors.blue[
                                                            //             200]
                                                            : (i + 1 == 3)
                                                                ? (Status_ ==
                                                                        i + 1)
                                                                    ? Colors.green[
                                                                        700]
                                                                    : Colors.green[
                                                                        200]
                                                                : (i + 1 == 4)
                                                                    ? (Status_ ==
                                                                            i +
                                                                                1)
                                                                        ? Colors.red[
                                                                            700]
                                                                        : Colors.red[
                                                                            200]
                                                                    : (Status_ ==
                                                                            i +
                                                                                1)
                                                                        ? Colors.grey[
                                                                            700]
                                                                        : Colors
                                                                            .grey[300],
                                                    borderRadius:
                                                        const BorderRadius.only(
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
                                                                Radius.circular(
                                                                    10)),
                                                    border: (Status_ == i + 1)
                                                        ? Border.all(
                                                            color: Colors.white,
                                                            width: 1)
                                                        : null,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            Status[i],
                                                            (Status_ == i + 1)
                                                                ? Colors.white
                                                                : ChaoAreaScreen_Color
                                                                    .Colors_Text2_,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            2),
                                                  ),
                                                ),
                                              )),
                                      ])),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Expanded(
                                //   flex: 3,
                                //   child: Row(
                                //     children: [
                                //       const Padding(
                                //         padding: EdgeInsets.all(8.0),
                                //         child: Text(
                                //           'ปี',
                                //           style: TextStyle(
                                //             color: Colors.black,
                                //             fontWeight: FontWeight.bold,
                                //           ),
                                //         ),
                                //       ),
                                //       Padding(
                                //         padding: const EdgeInsets.all(8.0),
                                //         child: Container(
                                //           decoration: BoxDecoration(
                                //             color: AppbackgroundColor.Sub_Abg_Colors,
                                //             borderRadius: const BorderRadius.only(
                                //                 topLeft: Radius.circular(10),
                                //                 topRight: Radius.circular(10),
                                //                 bottomLeft: Radius.circular(10),
                                //                 bottomRight: Radius.circular(10)),
                                //             border: Border.all(
                                //                 color: Colors.grey, width: 1),
                                //           ),
                                //           width: 120,
                                //           child: DropdownButtonFormField2(
                                //             itemHighlightColor:
                                //                 TextHome_Color.TextHome_Colors,

                                //             decoration: InputDecoration(
                                //               isDense: true,
                                //               contentPadding: EdgeInsets.zero,
                                //               border: OutlineInputBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(10),
                                //               ),
                                //             ),
                                //             isExpanded: true,
                                //             style: TextStyle(
                                //               color: Colors.green,
                                //             ),
                                //             hint: const Text(
                                //               'ทั้งหมด',
                                //               style: TextStyle(
                                //                 fontSize: 14,
                                //                 color: TextHome_Color.TextHome_Colors,
                                //               ),
                                //             ),
                                //             icon: const Icon(
                                //               Icons.arrow_drop_down,
                                //               color: TextHome_Color.TextHome_Colors,
                                //             ),
                                //             iconSize: 30,
                                //             buttonHeight: 40,
                                //             // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                //             dropdownDecoration: BoxDecoration(
                                //               borderRadius: BorderRadius.circular(10),
                                //             ),
                                //             items: Year_.map(
                                //                 (item) => DropdownMenuItem<String>(
                                //                       value: item,
                                //                       child: Text(
                                //                         item,
                                //                         style: const TextStyle(
                                //                           fontSize: 14,
                                //                         ),
                                //                       ),
                                //                     )).toList(),
                                //             // validator: (value) {
                                //             //   if (value == null) {
                                //             //     return 'ค้นหายี่ห้อ.';
                                //             //   } else {}
                                //             // },
                                //             onChanged: (value) async {},
                                //             onSaved: (value) {
                                //               // selectedValue = value.toString();
                                //             },
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                if (Responsive.isDesktop(context))
                                  Expanded(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ScrollConfiguration(
                                        behavior:
                                            ScrollConfiguration.of(context)
                                                .copyWith(dragDevices: {
                                          PointerDeviceKind.touch,
                                          PointerDeviceKind.mouse,
                                        }),
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(children: [
                                              Translate.TranslateAndSetText(
                                                  'สถานะ : ',
                                                  ChaoAreaScreen_Color
                                                      .Colors_Text2_,
                                                  TextAlign.center,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  14,
                                                  2),
                                              for (int i = 0;
                                                  i < Status.length;
                                                  i++)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          tappedIndex_ = '';
                                                        });
                                                        setState(() {
                                                          Status_ = i + 1;
                                                        });
                                                        read_GC_areaSelect(
                                                            Status_);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: (i + 1 == 1)
                                                              ? (Status_ ==
                                                                      i + 1)
                                                                  ? Colors
                                                                      .grey[700]
                                                                  : Colors
                                                                      .grey[300]
                                                              : (i + 1 == 2)
                                                                  ? (Status_ ==
                                                                          i + 1)
                                                                      ? Colors.orange[
                                                                          700]
                                                                      : Colors.orange[
                                                                          200]
                                                                  // :
                                                                  //  (i + 1 == 3)
                                                                  //     ? (Status_ ==
                                                                  //             i +
                                                                  //                 1)
                                                                  //         ? Colors.blue[
                                                                  //             700]
                                                                  //         : Colors.blue[
                                                                  //             200]
                                                                  : (i + 1 == 3)
                                                                      ? (Status_ ==
                                                                              i +
                                                                                  1)
                                                                          ? Colors.green[
                                                                              700]
                                                                          : Colors.green[
                                                                              200]
                                                                      : (i + 1 ==
                                                                              4)
                                                                          ? (Status_ == i + 1)
                                                                              ? Colors.red[700]
                                                                              : Colors.red[200]
                                                                          : (Status_ == i + 1)
                                                                              ? Colors.grey[700]
                                                                              : Colors.grey[300],
                                                          borderRadius: const BorderRadius
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
                                                          border: (Status_ ==
                                                                  i + 1)
                                                              ? Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1)
                                                              : null,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Center(
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  Status[i],
                                                                  (Status_ ==
                                                                          i + 1)
                                                                      ? Colors
                                                                          .white
                                                                      : ChaoAreaScreen_Color
                                                                          .Colors_Text2_,
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
                                                    )),
                                            ])),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Translate.TranslateAndSetText(
                                            'มุมมอง :',
                                            ChaoAreaScreen_Color.Colors_Text2_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            2),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () {},
                                          child: SlideSwitcher(
                                            containerBorderRadius: 10,
                                            onSelect: (index) async {
                                              setState(() {
                                                switcherIndex1 = index;
                                              });
                                              if (index + 1 == 1) {
                                                setState(() {
                                                  Visit_ = 'grid';
                                                });
                                              } else if (index + 1 == 2) {
                                                setState(() {
                                                  Visit_ = 'list';
                                                });
                                              } else if (index + 1 == 3) {
                                                setState(() {
                                                  Visit_ = 'map';
                                                });
                                                Data_Properties();
                                                // read_GC_area();
                                              }
                                              // if (index + 1 == 1) {
                                              //   setState(() {
                                              //     Visit_ = 'grid';
                                              //   });
                                              // } else if (index + 1 == 2) {
                                              //   setState(() {
                                              //     Ser_Body = 5;
                                              //     Visit_ = 'calendar';
                                              //   });
                                              // } else if (index + 1 == 3) {
                                              //   setState(() {
                                              //     Visit_ = 'list';
                                              //   });
                                              // } else if (index + 1 == 4) {
                                              //   setState(() {
                                              //     Visit_ = 'map';
                                              //   });
                                              //   Data_Properties();
                                              //   // read_GC_area();
                                              // }
                                            },
                                            containerHeight: 40,
                                            containerWight: 130,
                                            containerColor: Colors.grey,
                                            children: [
                                              Icon(
                                                Icons.grid_view_rounded,
                                                color: (Visit_ == 'grid')
                                                    ? Colors.blue[900]
                                                    : Colors.black,
                                              ),
                                              // Icon(
                                              //   Icons.calendar_month_rounded,
                                              //   color: (Visit_ == 'calendar')
                                              //       ? Colors.blue[900]
                                              //       : Colors.black,
                                              // ),
                                              Icon(
                                                Icons.list,
                                                color: (Visit_ == 'list')
                                                    ? Colors.blue[900]
                                                    : Colors.black,
                                              ),
                                              // Icon(
                                              //   Icons.map_outlined,
                                              //   color: (Visit_ == 'map')
                                              //       ? Colors.blue[900]
                                              //       : Colors.black,
                                              // )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                (Ser_Body == 0)
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            BodyHome_Web(context),
                          ],
                        ))
                    : (Ser_Body == 1)
                        ? Body_bid(context)
                        : (Ser_Body == 2)
                            ? Body_Renew(context)
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
                                    : SizedBox()
                // Homereservespace_calendar()
              ],
            ),
          );
  }

  String? _message;
  void updateMessage(String newMessage) {
    setState(() {
      _message = newMessage;
      Ser_Body = 0;
    });
    checkPreferance();
    read_GC_zone();
    read_GC_rental();
    Data_Properties();
    // read_GC_area();
  }

  Widget BodyHome_Web(context) {
    return (Visit_ == 'list')
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 2, 2),
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                // .withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                // border: Border.all(
                                //     color:
                                //         Colors.grey,
                                //     width: 1),
                              ),
                              width: 130,
                              // height: 30,
                              padding: const EdgeInsets.all(2.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: Center(
                                    child: Text(
                                      'หัวข้อ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color:
                                            AccountScreen_Color.Colors_Text1_,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),

                                  items: chaolist1.asMap().entries.map((entry) {
                                    int index = entry.key; // Get the index
                                    var item = entry.value;
                                    return DropdownMenuItem<String>(
                                      value:
                                          item["ser"], // Use "ser" as the value
                                      enabled:
                                          false, // Set to true to allow selection
                                      child: StatefulBuilder(
                                        builder: (context, menuSetState) {
                                          // final isSelected = selectedItems.contains(item);
                                          return InkWell(
                                            onTap: () {
                                              int selectedIndex = chaolist1
                                                  .indexWhere((items) =>
                                                      items["ser"] ==
                                                      item["ser"]);
                                              // print(ac1[selectedIndex]
                                              //     [
                                              //     "pn"]);
                                              // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                              //This rebuilds the StatefulWidget to update the button's text
                                              setState(() {
                                                if (item["st"]! == '1') {
                                                  chaolist1[selectedIndex]
                                                      ["st"] = '0';
                                                } else {
                                                  chaolist1[selectedIndex]
                                                      ["st"] = '1';
                                                }
                                              });
                                              //This rebuilds the dropdownMenu Widget to update the check mark
                                              menuSetState(() {});
                                            },
                                            child: Container(
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: Row(
                                                children: [
                                                  if (item["st"]! == '1')
                                                    Icon(
                                                      Icons.check_box_outlined,
                                                      color: Colors.green[400],
                                                    )
                                                  else
                                                    const Icon(Icons
                                                        .check_box_outline_blank),
                                                  Expanded(
                                                    child: Text(
                                                      item["pn"]!,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            Font_.Fonts_T,
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: chaolist1
                              .where(
                                  (item) => item["st"] == '1') // Filter items
                              .toList() // Convert to a list
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key; // Get the index
                            var item = entry.value; // Get the item

                            return Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Translate.TranslateAndSetText(
                                  item["pn"] ??
                                      "", // Use "pn" or an empty string if null
                                  AccountScreen_Color.Colors_Text1_,
                                  (item["ser"] == '2' ||
                                          item["ser"] == '3' ||
                                          item["ser"] == '6' ||
                                          item["ser"] == '7')
                                      ? TextAlign.right
                                      : (item["ser"] == '4' ||
                                              item["ser"] == '5' ||
                                              item["ser"] == '8')
                                          ? TextAlign.center
                                          : TextAlign.start,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
                                  14,
                                  1,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  children: [
                    Container(
                        height: (!Responsive.isDesktop(context))
                            ? MediaQuery.of(context).size.height * 0.85
                            : MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: AppbackgroundColor.Sub_Abg_Colors,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          // border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: areaModels.isEmpty
                            ? SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(milliseconds: 25),
                                          (i) => i),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData)
                                          return const Text('');
                                        double elapsed = double.parse(
                                                snapshot.data.toString()) *
                                            0.05;
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: (elapsed > 8.00)
                                              ? const Text(
                                                  'ไม่พบข้อมูล',
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                )
                                              : Text(
                                                  'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                  // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
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
                                controller: _scrollController1,
                                // itemExtent: 50,
                                physics:
                                    const AlwaysScrollableScrollPhysics(), //const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: areaModels.length,
                                itemBuilder: (BuildContext context, int index) {
                                  int daysBetween(DateTime from, DateTime to) {
                                    from = DateTime(
                                        from.year, from.month, from.day);
                                    to = DateTime(to.year, to.month, to.day);
                                    return (to.difference(from).inHours / 24)
                                        .round();
                                  }

                                  var daterz = areaModels[index].ldate == null
                                      ? '0000-00-00'
                                      : areaModels[index].ldate;

                                  var birthday =
                                      DateTime.parse('$daterz 00:00:00.000')
                                          .add(const Duration(days: -30));
                                  var date2 = DateTime.now();
                                  var difference = daysBetween(birthday, date2);

                                  return Material(
                                    color: tappedIndex_ == index.toString()
                                        ? tappedIndex_Color.tappedIndex_Colors
                                        : AppbackgroundColor.Sub_Abg_Colors,
                                    child: Container(
                                      child: ListTile(
                                          onTap: () {
                                            setState(() {
                                              tappedIndex_ = index.toString();
                                            });
                                          },
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
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (where_chao1("0") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        (areaModels[index].zn ==
                                                                null)
                                                            ? ''
                                                            : '${areaModels[index].zn}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                if (where_chao1("1") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].ln_c ==
                                                              null
                                                          ? areaModels[index]
                                                                      .ln_q ==
                                                                  null
                                                              ? '${areaModels[index].lncode}'
                                                              : '${areaModels[index].ln_q}'
                                                          : '${areaModels[index].ln_c}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                if (where_chao1("2") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index]
                                                                  .area_c ==
                                                              null
                                                          ? areaModels[index]
                                                                      .ln_q ==
                                                                  null
                                                              ? nFormat.format(
                                                                  double.parse(
                                                                      areaModels[index]
                                                                          .area!))
                                                              : nFormat.format(
                                                                  double.parse(
                                                                      areaModels[index]
                                                                          .area_q!))
                                                          : nFormat.format(
                                                              double.parse(
                                                                  areaModels[index]
                                                                      .area_c!)),
                                                      textAlign: TextAlign.end,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                if (where_chao1("3") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].total ==
                                                              null
                                                          ? areaModels[index]
                                                                      .total_q ==
                                                                  null
                                                              ? nFormat.format(
                                                                  double.parse(
                                                                      areaModels[index]
                                                                          .rent!))
                                                              : nFormat.format(
                                                                  double.parse(
                                                                      areaModels[index]
                                                                          .total_q!))
                                                          : nFormat.format(
                                                              double.parse(
                                                                  areaModels[index]
                                                                      .total!)),
                                                      textAlign: TextAlign.end,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                if (where_chao1("4") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].cid ==
                                                              null
                                                          ? ''
                                                          : '${areaModels[index].cid}',
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
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
                                                if (where_chao1("5") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].docno ==
                                                              null
                                                          ? ''
                                                          : '${areaModels[index].docno}',
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: areaModels[
                                                                          index]
                                                                      .docno !=
                                                                  null
                                                              ? Colors.blue
                                                              : PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                if (where_chao1("6") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].sdate ==
                                                              null
                                                          ? areaModels[index]
                                                                      .sdate ==
                                                                  null
                                                              ? ''
                                                              : DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(DateTime
                                                                      .parse(
                                                                          '${areaModels[index].sdate_q} 00:00:00'))
                                                                  .toString()
                                                          : DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime
                                                                  .parse(
                                                                      '${areaModels[index].sdate} 00:00:00'))
                                                              .toString(),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                if (where_chao1("7") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].ldate ==
                                                              null
                                                          ? areaModels[index]
                                                                      .ldate_q ==
                                                                  null
                                                              ? ''
                                                              : DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(DateTime
                                                                      .parse(
                                                                          '${areaModels[index].ldate_q} 00:00:00'))
                                                                  .toString()
                                                          : DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(DateTime
                                                                  .parse(
                                                                      '${areaModels[index].ldate} 00:00:00'))
                                                              .toString(),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: areaModels[
                                                                          index]
                                                                      .quantity ==
                                                                  '1'
                                                              ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) ==
                                                                      true
                                                                  ? Colors.red
                                                                  : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) ==
                                                                          true
                                                                      ? Colors
                                                                          .orange
                                                                          .shade900
                                                                      : Colors
                                                                          .black
                                                              : areaModels[index]
                                                                          .quantity ==
                                                                      '2'
                                                                  ? Colors.blue
                                                                  : areaModels[index]
                                                                              .quantity ==
                                                                          '3'
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .green,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                if (where_chao1("8") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      areaModels[index].stype ==
                                                              null
                                                          ? ''
                                                          : '${areaModels[index].stype}',
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: areaModels[
                                                                          index]
                                                                      .docno !=
                                                                  null
                                                              ? Colors.blue
                                                              : PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                if (where_chao1("9") == false)
                                                  Expanded(
                                                    flex: 1,
                                                    child: Card(
                                                      color: areaModels[index]
                                                                  .quantity ==
                                                              '1'
                                                          ? (areaModels[index].ldate ==
                                                                  null)
                                                              ? Colors
                                                                  .red.shade200
                                                              : datex.isAfter(DateTime.parse('${areaModels[index].ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) ==
                                                                      true //datex
                                                                  ? datex.isAfter(DateTime.parse('${areaModels[index].ldate} 00:00:00.000').subtract(Duration(days: 0))) ==
                                                                          false
                                                                      ? Colors
                                                                          .orange
                                                                          .shade200
                                                                      : Colors
                                                                          .grey
                                                                          .shade200
                                                                  : Colors.red
                                                                      .shade200
                                                          : areaModels[index]
                                                                      .quantity ==
                                                                  '2'
                                                              ? Colors
                                                                  .blue.shade200
                                                              : areaModels[index].quantity ==
                                                                      '3'
                                                                  ? Colors
                                                                      .purple
                                                                      .shade200
                                                                  : Colors.green
                                                                      .shade200,
                                                      child: MaterialButton(
                                                        key: _btnKeys[index],
                                                        onPressed: () async {
                                                          setState(() {
                                                            read_GC_con_area(
                                                                index);
                                                          });
                                                          if (areaModels[index]
                                                                  .quantity !=
                                                              '1') {
                                                            for (int i = 0;
                                                                i <
                                                                    areaQuotModels
                                                                        .length;
                                                                i++) {
                                                              var oo = areaQuotModels[
                                                                      i]
                                                                  .ln_q!
                                                                  .contains(areaModels[
                                                                          index]
                                                                      .ln
                                                                      .toString());
                                                            }
                                                          }
                                                          add_ContractStore(
                                                              index);
                                                          Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      400), () {
                                                            maxColumn(
                                                                index, context);
                                                          });
                                                        },
                                                        child: Translate.TranslateAndSetText(
                                                            areaModels[index].quantity == '1'
                                                                ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) == true
                                                                    ? 'หมดสัญญา'
                                                                    : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) == true
                                                                        ? 'ใกล้หมดสัญญา'
                                                                        : 'เช่าอยู่'
                                                                : areaModels[index].quantity == '2'
                                                                    ? 'เสนอราคา'
                                                                    : areaModels[index].quantity == '3'
                                                                        ? 'เสนอราคา(มัดจำ)'
                                                                        : 'ว่าง',
                                                            areaModels[index].quantity == '1'
                                                                ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) == true
                                                                    ? Colors.red
                                                                    : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) == true
                                                                        ? Colors.orange.shade900
                                                                        : Colors.black
                                                                : areaModels[index].quantity == '2'
                                                                    ? Colors.blue
                                                                    : areaModels[index].quantity == '3'
                                                                        ? Colors.blue
                                                                        : Colors.green,
                                                            TextAlign.end,
                                                            null,
                                                            Font_.Fonts_T,
                                                            14,
                                                            2),
                                                      ),
                                                    ),

                                                    // Text(
                                                    //   areaModels[index].quantity ==
                                                    //           '1'
                                                    //       ? datex.isAfter(DateTime.parse(
                                                    //                       '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
                                                    //                   .subtract(const Duration(
                                                    //                       days:
                                                    //                           0))) ==
                                                    //               true
                                                    //           ? 'หมดสัญญา'
                                                    //           : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
                                                    //                       Duration(
                                                    //                           days:
                                                    //                               open_set_date))) ==
                                                    //                   true
                                                    //               ? 'ใกล้หมดสัญญา'
                                                    //               : 'เช่าอยู่'
                                                    //       : areaModels[index]
                                                    //                   .quantity ==
                                                    //               '2'
                                                    //           ? 'เสนอราคา'
                                                    //           : areaModels[index]
                                                    //                       .quantity ==
                                                    //                   '3'
                                                    //               ? 'เสนอราคา(มัดจำ)'
                                                    //               : 'ว่าง',
                                                    //   textAlign: TextAlign.end,
                                                    //   style: TextStyle(
                                                    //       color: areaModels[index]
                                                    //                   .quantity ==
                                                    //               '1'
                                                    //           ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(
                                                    //                       const Duration(
                                                    //                           days:
                                                    //                               0))) ==
                                                    //                   true
                                                    //               ? Colors.red
                                                    //               : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) ==
                                                    //                       true
                                                    //                   ? Colors
                                                    //                       .orange
                                                    //                       .shade900
                                                    //                   : Colors
                                                    //                       .black
                                                    //           : areaModels[index]
                                                    //                       .quantity ==
                                                    //                   '2'
                                                    //               ? Colors.blue
                                                    //               : areaModels[index]
                                                    //                           .quantity ==
                                                    //                       '3'
                                                    //                   ? Colors.blue
                                                    //                   : Colors.green,
                                                    //       fontFamily: Font_.Fonts_T
                                                    //       //fontSize: 10.0
                                                    //       ),
                                                    // ),
                                                  ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
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
                                        _scrollController1.animateTo(
                                          0,
                                          duration: const Duration(seconds: 1),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      child: Container(
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
                                                        Radius.circular(8)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          padding: const EdgeInsets.all(3.0),
                                          child: const Text(
                                            'Top',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontFamily:
                                                    FontWeight_.Fonts_T),
                                          )),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (_scrollController1.hasClients) {
                                        final position = _scrollController1
                                            .position.maxScrollExtent;
                                        _scrollController1.animateTo(
                                          position,
                                          duration: const Duration(seconds: 1),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          // color: AppbackgroundColor
                                          //     .TiTile_Colors,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(3.0),
                                        child: const Text(
                                          'Down',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10.0,
                                              fontFamily: FontWeight_.Fonts_T),
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
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6)),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      padding: const EdgeInsets.all(3.0),
                                      child: const Text(
                                        'Scroll',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10.0,
                                            fontFamily: FontWeight_.Fonts_T),
                                      )),
                                  InkWell(
                                    onTap: _moveDown1,
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
                ),
              )
            ],
          )
        : (Visit_ == 'grid')
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppbackgroundColor.Sub_Abg_Colors,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                        // border: Border.all(color: Colors.grey, width: 1),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: (Status_ != 1)
                          ? Row(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                          : (zone_ser.toString() != '0' && zone_ser != null)
                              ? Row(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // TextButton.icon(
                                    //   onPressed:
                                    //       (_zonePage > 0) ? prevZonePage : null,
                                    //   icon: const Icon(Icons.chevron_left),
                                    //   label: Text('ก่อนหน้า'),
                                    // ),
                                    InkWell(
                                        onTap: (offset == 0)
                                            ? null
                                            : () async {
                                                if (offset == 0) {
                                                } else {
                                                  setState(() {
                                                    // quotxSelectModels_Select.clear();
                                                    // ser_indexShow = null;
                                                    offset = offset - limit;

                                                    read_zone_limit();
                                                    tappedIndex_ = '';
                                                  });
                                                  _scrollController1.animateTo(
                                                    0,
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    curve: Curves.easeOut,
                                                  );
                                                }
                                              },
                                        child: Icon(
                                          Icons.arrow_left,
                                          color: (offset == 0)
                                              ? Colors.grey[200]
                                              : Colors.black,
                                          size: 25,
                                        )),
                                    SizedBox(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.menu_book,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          Text(
                                              ' ${(endIndex / limit).ceil()}/${(limitedList_zoneModels.length / limit).ceil()}'

                                              // ' ${(endIndex / limit)}/${(limitedList_zoneModels.length / limit).ceil()}',
                                              // 'หน้า ${_zonePage + 1} / ${_totalZonePages}'
                                              ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                        onTap: (endIndex >=
                                                limitedList_zoneModels.length)
                                            ? null
                                            : () async {
                                                setState(() {
                                                  offset = offset + limit;
                                                  tappedIndex_ = '';
                                                  read_zone_limit();
                                                });
                                                _scrollController1.animateTo(
                                                  0,
                                                  duration: const Duration(
                                                      seconds: 1),
                                                  curve: Curves.easeOut,
                                                );
                                              },
                                        child: Icon(
                                          Icons.chevron_right,
                                          color: (endIndex >=
                                                  limitedList_zoneModels.length)
                                              ? Colors.grey[200]
                                              : Colors.black,
                                          size: 25,
                                        )),
                                    // TextButton.icon(
                                    //   onPressed: (_zonePage < _totalZonePages - 1)
                                    //       ? nextZonePage
                                    //       : null,
                                    //   icon: const Icon(Icons.chevron_right),
                                    //   label: const Text('ถัดไป'),
                                    // ),
                                  ],
                                ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppbackgroundColor.Sub_Abg_Colors,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        // border: Border.all(color: Colors.grey, width: 1),
                      ),
                      padding: const EdgeInsets.all(20),
                      // color: Colors.white,
                      child: (areaModels.isEmpty)
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: StreamBuilder(
                                  stream: Stream.periodic(
                                      const Duration(milliseconds: 30),
                                      (i) => i),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return const Text('');
                                    double elapsed =
                                        double.parse(snapshot.data.toString()) *
                                            0.05;
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (elapsed < 20.00)
                                          CircularProgressIndicator(),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: (elapsed > 20.00)
                                              ? const Text(
                                                  'ไม่พบข้อมูล',
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    fontFamily: Font_.Fonts_T,
                                                    fontWeight: FontWeight.w500,
                                                    //fontSize: 10.0
                                                  ),
                                                )
                                              : Text(
                                                  'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                  // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                  style: const TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            )
                          : zone_ser == '0' ||
                                  zone_ser == '' ||
                                  zone_ser == null
                              ? textsearch != null && textsearch != ''
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ScrollConfiguration(
                                              behavior: ScrollConfiguration.of(
                                                      context)
                                                  .copyWith(dragDevices: {
                                                PointerDeviceKind.touch,
                                                PointerDeviceKind.mouse,
                                              }),
                                              child: GridView.count(
                                                crossAxisCount: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .shortestSide <
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1
                                                    ? 12
                                                    : (MediaQuery.of(context)
                                                                .size
                                                                .width <
                                                            400)
                                                        ? 4
                                                        : 6,
                                                children: [
                                                  for (int i = 0;
                                                      i < areaModels.length;
                                                      i++)
                                                    createCard(i, context),
                                                ],
                                              ))),
                                    )
                                  : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: zoneModels.length,
                                      itemBuilder:
                                          (BuildContext context, int zindex) {
                                        return (zoneModels[zindex].ser == '0')
                                            ? const SizedBox()
                                            : (searchBar_Controller.text
                                                            .toString() !=
                                                        '' &&
                                                    areaModels
                                                        .where((item) =>
                                                            item.zser ==
                                                            zoneModels[zindex]
                                                                .ser)
                                                        .toList()
                                                        .isEmpty)
                                                ? SizedBox()
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (areaModels
                                                              .where((item) =>
                                                                  item.zser ==
                                                                  zoneModels[
                                                                          zindex]
                                                                      .ser)
                                                              .toList()
                                                              .length !=
                                                          0)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppbackgroundColor.TiTile_Colors,
                                                                          borderRadius:
                                                                              const BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            topRight:
                                                                                Radius.circular(10),
                                                                            bottomLeft:
                                                                                Radius.circular(10),
                                                                            bottomRight:
                                                                                Radius.circular(10),
                                                                          ),
                                                                          border: Border.all(
                                                                              color: Colors.white,
                                                                              width: 2),
                                                                        ),
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                5.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Translate.TranslateAndSetText(
                                                                                'โซน:',
                                                                                ChaoAreaScreen_Color.Colors_Text1_,
                                                                                TextAlign.center,
                                                                                FontWeight.bold,
                                                                                FontWeight_.Fonts_T,
                                                                                14,
                                                                                2),
                                                                            RichText(
                                                                              text: TextSpan(
                                                                                text: '${zoneModels[zindex].zn}  ',
                                                                                style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T

                                                                                    //fontSize: 10.0
                                                                                    ),
                                                                                children: <TextSpan>[
                                                                                  TextSpan(
                                                                                    text: '[ ${areaModels.where((item) => item.zser == zoneModels[zindex].ser).toList().length} ',
                                                                                    style: TextStyle(
                                                                                        fontSize: 13,
                                                                                        color: Colors.grey.shade800.withOpacity(0.45),
                                                                                        // fontWeight: FontWeight
                                                                                        //     .bold,
                                                                                        fontFamily: Font_.Fonts_T

                                                                                        //fontSize: 10.0
                                                                                        ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Translate.TranslateAndSetText(
                                                                                ' พื้นที่ ]',
                                                                                Colors.grey.shade800.withOpacity(0.45),
                                                                                TextAlign.center,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                14,
                                                                                2),
                                                                          ],
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                              // Expanded(
                                                              //     flex: 1, child: Text('')),
                                                            ],
                                                          ),
                                                        ),
                                                      if (areaModels
                                                              .where((item) =>
                                                                  item.zser ==
                                                                  zoneModels[
                                                                          zindex]
                                                                      .ser)
                                                              .toList()
                                                              .length !=
                                                          0)
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                ScrollConfiguration(
                                                              behavior: ScrollConfiguration
                                                                      .of(
                                                                          context)
                                                                  .copyWith(
                                                                      dragDevices: {
                                                                    PointerDeviceKind
                                                                        .touch,
                                                                    PointerDeviceKind
                                                                        .mouse,
                                                                  }),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    height: (areaModels
                                                                            .where((item) =>
                                                                                item.zser ==
                                                                                zoneModels[zindex].ser)
                                                                            .toList()
                                                                            .isEmpty)
                                                                        ? null
                                                                        : ((areaModels.where((item) => item.zser == zoneModels[zindex].ser).toList().length / 12) < 1.5)
                                                                            ? 145
                                                                            : ((areaModels.where((item) => item.zser == zoneModels[zindex].ser).toList().length / 12) < 2.5)
                                                                                ? 245
                                                                                : 320,
                                                                    // height: MediaQuery.of(
                                                                    //                 context)
                                                                    //             .size
                                                                    //             .shortestSide <
                                                                    //         MediaQuery.of(
                                                                    //                     context)
                                                                    //                 .size
                                                                    //                 .height *
                                                                    //             1
                                                                    //     ? 420
                                                                    //     : 320,
                                                                    child: (areaModels
                                                                            .where((item) =>
                                                                                item.zser ==
                                                                                zoneModels[zindex].ser)
                                                                            .toList()
                                                                            .isEmpty)
                                                                        ? SizedBox(
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                StreamBuilder(
                                                                                  stream: Stream.periodic(const Duration(milliseconds: 15), (i) => i),
                                                                                  builder: (context, snapshot) {
                                                                                    if (!snapshot.hasData) return const Text('');
                                                                                    double elapsed = double.parse(snapshot.data.toString()) * 0.05;
                                                                                    return Column(
                                                                                      children: [
                                                                                        if (elapsed < 8.00) CircularProgressIndicator(),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: (elapsed > 8.00)
                                                                                              ? const Text(
                                                                                                  'ไม่พบข้อมูล',
                                                                                                  style: TextStyle(
                                                                                                    color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T, fontWeight: FontWeight.w500,
                                                                                                    //fontSize: 10.0
                                                                                                  ),
                                                                                                )
                                                                                              : Text(
                                                                                                  'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                                                                  // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
                                                                                                      //fontSize: 10.0
                                                                                                      ),
                                                                                                ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : GridView.count(
                                                                            crossAxisCount: MediaQuery.of(context).size.shortestSide < MediaQuery.of(context).size.width * 1
                                                                                ? 12
                                                                                : (MediaQuery.of(context).size.width < 400)
                                                                                    ? 4
                                                                                    : 6,
                                                                            children: [
                                                                              for (int i = 0; i < areaModels.length; i++)
                                                                                if (zoneModels[zindex].ser == areaModels[i].zser) createCard(i, context),
                                                                            ],
                                                                          ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Divider(
                                                                          color:
                                                                              Colors.grey[300],
                                                                          height:
                                                                              4.0,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                ],
                                                              ),
                                                            ))
                                                    ],
                                                  );
                                      })
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: AppbackgroundColor
                                                          .TiTile_Colors,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      ),
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 2),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: zone_ser == null
                                                            ? 'โซน ทั้งหมด  '
                                                            : 'โซน $zone_name  ',
                                                        style: const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T

                                                            //fontSize: 10.0
                                                            ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text:
                                                                '[ ${areaModels.where((item) => item.zser == zone_ser).toList().length} พื้นที่ ]',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800
                                                                    .withOpacity(
                                                                        0.45),
                                                                // fontWeight: FontWeight
                                                                //     .bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T

                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    // Text(
                                                    //   zone_ser == null
                                                    //       ? 'โซน ทั้งหมด'
                                                    //       : 'โซน ($zone_name)',
                                                    //   style: const TextStyle(
                                                    //       color:
                                                    //           PeopleChaoScreen_Color
                                                    //               .Colors_Text2_,
                                                    //       fontWeight: FontWeight.bold,
                                                    //       fontFamily:
                                                    //           FontWeight_.Fonts_T

                                                    //       //fontSize: 10.0
                                                    //       ),
                                                    // ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                          // Expanded(flex: 1, child: Text('')),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ScrollConfiguration(
                                          behavior:
                                              ScrollConfiguration.of(context)
                                                  .copyWith(dragDevices: {
                                            PointerDeviceKind.touch,
                                            PointerDeviceKind.mouse,
                                          }),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: (areaModels.length == 0)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.6
                                                    : 600,
                                                child: (areaModels.length == 0)
                                                    ? SizedBox(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            StreamBuilder(
                                                              stream: Stream.periodic(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          15),
                                                                  (i) => i),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData)
                                                                  return const Text(
                                                                      '');
                                                                double elapsed =
                                                                    double.parse(snapshot
                                                                            .data
                                                                            .toString()) *
                                                                        0.05;
                                                                return Column(
                                                                  children: [
                                                                    if (elapsed <
                                                                        8.00)
                                                                      CircularProgressIndicator(),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child: (elapsed >
                                                                              8.00)
                                                                          ? const Text(
                                                                              'ไม่พบข้อมูล',
                                                                              style: TextStyle(
                                                                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                fontFamily: Font_.Fonts_T,
                                                                                fontWeight: FontWeight.w500,
                                                                                //fontSize: 10.0
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                                                              // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                              style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
                                                                                  //fontSize: 10.0
                                                                                  ),
                                                                            ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : GridView.count(
                                                        crossAxisCount: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .shortestSide <
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    1
                                                            ? 12
                                                            : (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    400)
                                                                ? 4
                                                                : 6,
                                                        children: [
                                                          for (int i = 0;
                                                              i <
                                                                  areaModels
                                                                      .length;
                                                              i++)
                                                            createCard(
                                                                i, context),
                                                        ],
                                                      ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                    ),
                  )
                ],
              )

            // ? Column(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: Container(
            //           decoration: const BoxDecoration(
            //             color: AppbackgroundColor.Sub_Abg_Colors,
            //             borderRadius: BorderRadius.only(
            //                 topLeft: Radius.circular(10),
            //                 topRight: Radius.circular(10),
            //                 bottomLeft: Radius.circular(10),
            //                 bottomRight: Radius.circular(10)),
            //             // border: Border.all(color: Colors.grey, width: 1),
            //           ),
            //           padding: const EdgeInsets.all(20),
            //           // color: Colors.white,
            //           child: (areaModels.isEmpty)
            //               ? Container(
            //                   height: MediaQuery.of(context).size.height * 0.6,
            //                   child: Center(
            //                     child: StreamBuilder(
            //                       stream: Stream.periodic(
            //                           const Duration(milliseconds: 30),
            //                           (i) => i),
            //                       builder: (context, snapshot) {
            //                         if (!snapshot.hasData)
            //                           return const Text('');
            //                         double elapsed =
            //                             double.parse(snapshot.data.toString()) *
            //                                 0.05;
            //                         return Column(
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.center,
            //                           children: [
            //                             if (elapsed < 20.00)
            //                               CircularProgressIndicator(),
            //                             Padding(
            //                               padding: const EdgeInsets.all(8.0),
            //                               child: (elapsed > 20.00)
            //                                   ? const Text(
            //                                       'ไม่พบข้อมูล',
            //                                       style: TextStyle(
            //                                         color:
            //                                             PeopleChaoScreen_Color
            //                                                 .Colors_Text2_,
            //                                         fontFamily: Font_.Fonts_T,
            //                                         fontWeight: FontWeight.w500,
            //                                         //fontSize: 10.0
            //                                       ),
            //                                     )
            //                                   : Text(
            //                                       'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
            //                                       // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
            //                                       style: const TextStyle(
            //                                           color:
            //                                               PeopleChaoScreen_Color
            //                                                   .Colors_Text2_,
            //                                           fontFamily: Font_.Fonts_T
            //                                           //fontSize: 10.0
            //                                           ),
            //                                     ),
            //                             ),
            //                           ],
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                 )
            //               : zone_ser == '0' ||
            //                       zone_ser == '' ||
            //                       zone_ser == null
            //                   ? textsearch != null && textsearch != ''
            //                       ? Container(
            //                           width: MediaQuery.of(context).size.width,
            //                           height: MediaQuery.of(context).size.width,
            //                           child: Padding(
            //                               padding: const EdgeInsets.all(8.0),
            //                               child: ScrollConfiguration(
            //                                   behavior: ScrollConfiguration.of(
            //                                           context)
            //                                       .copyWith(dragDevices: {
            //                                     PointerDeviceKind.touch,
            //                                     PointerDeviceKind.mouse,
            //                                   }),
            //                                   child: GridView.count(
            //                                     crossAxisCount: MediaQuery.of(
            //                                                     context)
            //                                                 .size
            //                                                 .shortestSide <
            //                                             MediaQuery.of(context)
            //                                                     .size
            //                                                     .width *
            //                                                 1
            //                                         ? 12
            //                                         : (MediaQuery.of(context)
            //                                                     .size
            //                                                     .width <
            //                                                 400)
            //                                             ? 4
            //                                             : 6,
            //                                     children: [
            //                                       for (int i = 0;
            //                                           i < areaModels.length;
            //                                           i++)
            //                                         createCard(i, context),
            //                                     ],
            //                                   ))),
            //                         )
            //                       : ListView.builder(
            //                           physics:
            //                               const AlwaysScrollableScrollPhysics(),
            //                           shrinkWrap: true,
            //                           itemCount: zoneModels.length,
            //                           itemBuilder:
            //                               (BuildContext context, int zindex) {
            //                             return (zoneModels[zindex].ser == '0')
            //                                 ? const SizedBox()
            //                                 : (searchBar_Controller.text
            //                                                 .toString() !=
            //                                             '' &&
            //                                         areaModels
            //                                             .where((item) =>
            //                                                 item.zser ==
            //                                                 zoneModels[zindex]
            //                                                     .ser)
            //                                             .toList()
            //                                             .isEmpty)
            //                                     ? SizedBox()
            //                                     : Column(
            //                                         crossAxisAlignment:
            //                                             CrossAxisAlignment
            //                                                 .start,
            //                                         children: [
            //                                           if (areaModels
            //                                                   .where((item) =>
            //                                                       item.zser ==
            //                                                       zoneModels[
            //                                                               zindex]
            //                                                           .ser)
            //                                                   .toList()
            //                                                   .length !=
            //                                               0)
            //                                             Padding(
            //                                               padding:
            //                                                   const EdgeInsets
            //                                                       .all(8.0),
            //                                               child: Row(
            //                                                 children: [
            //                                                   Expanded(
            //                                                     flex: 1,
            //                                                     child: Row(
            //                                                       children: [
            //                                                         Container(
            //                                                             decoration:
            //                                                                 BoxDecoration(
            //                                                               color:
            //                                                                   AppbackgroundColor.TiTile_Colors,
            //                                                               borderRadius:
            //                                                                   const BorderRadius.only(
            //                                                                 topLeft:
            //                                                                     Radius.circular(10),
            //                                                                 topRight:
            //                                                                     Radius.circular(10),
            //                                                                 bottomLeft:
            //                                                                     Radius.circular(10),
            //                                                                 bottomRight:
            //                                                                     Radius.circular(10),
            //                                                               ),
            //                                                               border: Border.all(
            //                                                                   color: Colors.white,
            //                                                                   width: 2),
            //                                                             ),
            //                                                             padding:
            //                                                                 const EdgeInsets.all(
            //                                                                     5.0),
            //                                                             child:
            //                                                                 Row(
            //                                                               children: [
            //                                                                 Translate.TranslateAndSetText(
            //                                                                     'โซน:',
            //                                                                     ChaoAreaScreen_Color.Colors_Text1_,
            //                                                                     TextAlign.center,
            //                                                                     FontWeight.bold,
            //                                                                     FontWeight_.Fonts_T,
            //                                                                     14,
            //                                                                     2),
            //                                                                 RichText(
            //                                                                   text: TextSpan(
            //                                                                     text: '${zoneModels[zindex].zn}  ',
            //                                                                     style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T

            //                                                                         //fontSize: 10.0
            //                                                                         ),
            //                                                                     children: <TextSpan>[
            //                                                                       TextSpan(
            //                                                                         text: '[ ${areaModels.where((item) => item.zser == zoneModels[zindex].ser).toList().length} ',
            //                                                                         style: TextStyle(
            //                                                                             fontSize: 13,
            //                                                                             color: Colors.grey.shade800.withOpacity(0.45),
            //                                                                             // fontWeight: FontWeight
            //                                                                             //     .bold,
            //                                                                             fontFamily: Font_.Fonts_T

            //                                                                             //fontSize: 10.0
            //                                                                             ),
            //                                                                       ),
            //                                                                     ],
            //                                                                   ),
            //                                                                 ),
            //                                                                 Translate.TranslateAndSetText(
            //                                                                     ' พื้นที่ ]',
            //                                                                     Colors.grey.shade800.withOpacity(0.45),
            //                                                                     TextAlign.center,
            //                                                                     null,
            //                                                                     Font_.Fonts_T,
            //                                                                     14,
            //                                                                     2),
            //                                                               ],
            //                                                             )),
            //                                                       ],
            //                                                     ),
            //                                                   ),
            //                                                   // Expanded(
            //                                                   //     flex: 1, child: Text('')),
            //                                                 ],
            //                                               ),
            //                                             ),
            //                                           if (areaModels
            //                                                   .where((item) =>
            //                                                       item.zser ==
            //                                                       zoneModels[
            //                                                               zindex]
            //                                                           .ser)
            //                                                   .toList()
            //                                                   .length !=
            //                                               0)
            //                                             Padding(
            //                                                 padding:
            //                                                     const EdgeInsets
            //                                                         .all(8.0),
            //                                                 child:
            //                                                     ScrollConfiguration(
            //                                                   behavior: ScrollConfiguration
            //                                                           .of(
            //                                                               context)
            //                                                       .copyWith(
            //                                                           dragDevices: {
            //                                                         PointerDeviceKind
            //                                                             .touch,
            //                                                         PointerDeviceKind
            //                                                             .mouse,
            //                                                       }),
            //                                                   child: Column(
            //                                                     crossAxisAlignment:
            //                                                         CrossAxisAlignment
            //                                                             .start,
            //                                                     children: [
            //                                                       Container(
            //                                                         width: MediaQuery.of(
            //                                                                 context)
            //                                                             .size
            //                                                             .width,
            //                                                         height: (areaModels
            //                                                                 .where((item) =>
            //                                                                     item.zser ==
            //                                                                     zoneModels[zindex].ser)
            //                                                                 .toList()
            //                                                                 .isEmpty)
            //                                                             ? null
            //                                                             : ((areaModels.where((item) => item.zser == zoneModels[zindex].ser).toList().length / 12) < 1.5)
            //                                                                 ? 145
            //                                                                 : ((areaModels.where((item) => item.zser == zoneModels[zindex].ser).toList().length / 12) < 2.5)
            //                                                                     ? 245
            //                                                                     : 320,
            //                                                         // height: MediaQuery.of(
            //                                                         //                 context)
            //                                                         //             .size
            //                                                         //             .shortestSide <
            //                                                         //         MediaQuery.of(
            //                                                         //                     context)
            //                                                         //                 .size
            //                                                         //                 .height *
            //                                                         //             1
            //                                                         //     ? 420
            //                                                         //     : 320,
            //                                                         child: (areaModels
            //                                                                 .where((item) =>
            //                                                                     item.zser ==
            //                                                                     zoneModels[zindex].ser)
            //                                                                 .toList()
            //                                                                 .isEmpty)
            //                                                             ? SizedBox(
            //                                                                 child:
            //                                                                     Column(
            //                                                                   mainAxisAlignment: MainAxisAlignment.center,
            //                                                                   children: [
            //                                                                     StreamBuilder(
            //                                                                       stream: Stream.periodic(const Duration(milliseconds: 15), (i) => i),
            //                                                                       builder: (context, snapshot) {
            //                                                                         if (!snapshot.hasData) return const Text('');
            //                                                                         double elapsed = double.parse(snapshot.data.toString()) * 0.05;
            //                                                                         return Column(
            //                                                                           children: [
            //                                                                             if (elapsed < 8.00) CircularProgressIndicator(),
            //                                                                             Padding(
            //                                                                               padding: const EdgeInsets.all(8.0),
            //                                                                               child: (elapsed > 8.00)
            //                                                                                   ? const Text(
            //                                                                                       'ไม่พบข้อมูล',
            //                                                                                       style: TextStyle(
            //                                                                                         color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T, fontWeight: FontWeight.w500,
            //                                                                                         //fontSize: 10.0
            //                                                                                       ),
            //                                                                                     )
            //                                                                                   : Text(
            //                                                                                       'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
            //                                                                                       // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
            //                                                                                       style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
            //                                                                                           //fontSize: 10.0
            //                                                                                           ),
            //                                                                                     ),
            //                                                                             ),
            //                                                                           ],
            //                                                                         );
            //                                                                       },
            //                                                                     ),
            //                                                                   ],
            //                                                                 ),
            //                                                               )
            //                                                             : GridView.count(
            //                                                                 crossAxisCount: MediaQuery.of(context).size.shortestSide < MediaQuery.of(context).size.width * 1
            //                                                                     ? 12
            //                                                                     : (MediaQuery.of(context).size.width < 400)
            //                                                                         ? 4
            //                                                                         : 6,
            //                                                                 children: [
            //                                                                   for (int i = 0; i < areaModels.length; i++)
            //                                                                     if (zoneModels[zindex].ser == areaModels[i].zser) createCard(i, context),
            //                                                                 ],
            //                                                               ),
            //                                                       ),
            //                                                       const SizedBox(
            //                                                         height: 5.0,
            //                                                       ),
            //                                                       Row(
            //                                                         children: [
            //                                                           Expanded(
            //                                                             child:
            //                                                                 Divider(
            //                                                               color:
            //                                                                   Colors.grey[300],
            //                                                               height:
            //                                                                   4.0,
            //                                                             ),
            //                                                           ),
            //                                                         ],
            //                                                       ),
            //                                                       const SizedBox(
            //                                                         height: 5.0,
            //                                                       ),
            //                                                     ],
            //                                                   ),
            //                                                 ))
            //                                         ],
            //                                       );
            //                           })
            //                   : Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Padding(
            //                           padding: const EdgeInsets.all(8.0),
            //                           child: Row(
            //                             children: [
            //                               Expanded(
            //                                 flex: 1,
            //                                 child: Row(
            //                                   children: [
            //                                     Container(
            //                                         decoration: BoxDecoration(
            //                                           color: AppbackgroundColor
            //                                               .TiTile_Colors,
            //                                           borderRadius:
            //                                               const BorderRadius
            //                                                   .only(
            //                                             topLeft:
            //                                                 Radius.circular(10),
            //                                             topRight:
            //                                                 Radius.circular(10),
            //                                             bottomLeft:
            //                                                 Radius.circular(10),
            //                                             bottomRight:
            //                                                 Radius.circular(10),
            //                                           ),
            //                                           border: Border.all(
            //                                               color: Colors.white,
            //                                               width: 2),
            //                                         ),
            //                                         padding:
            //                                             const EdgeInsets.all(
            //                                                 5.0),
            //                                         child: RichText(
            //                                           text: TextSpan(
            //                                             text: zone_ser == null
            //                                                 ? 'โซน ทั้งหมด  '
            //                                                 : 'โซน $zone_name  ',
            //                                             style: const TextStyle(
            //                                                 color: PeopleChaoScreen_Color
            //                                                     .Colors_Text2_,
            //                                                 fontWeight:
            //                                                     FontWeight.bold,
            //                                                 fontFamily:
            //                                                     FontWeight_
            //                                                         .Fonts_T

            //                                                 //fontSize: 10.0
            //                                                 ),
            //                                             children: <TextSpan>[
            //                                               TextSpan(
            //                                                 text:
            //                                                     '[ ${areaModels.where((item) => item.zser == zone_ser).toList().length} พื้นที่ ]',
            //                                                 style: TextStyle(
            //                                                     fontSize: 13,
            //                                                     color: Colors
            //                                                         .grey
            //                                                         .shade800
            //                                                         .withOpacity(
            //                                                             0.45),
            //                                                     // fontWeight: FontWeight
            //                                                     //     .bold,
            //                                                     fontFamily:
            //                                                         Font_
            //                                                             .Fonts_T

            //                                                     //fontSize: 10.0
            //                                                     ),
            //                                               ),
            //                                             ],
            //                                           ),
            //                                         )
            //                                         // Text(
            //                                         //   zone_ser == null
            //                                         //       ? 'โซน ทั้งหมด'
            //                                         //       : 'โซน ($zone_name)',
            //                                         //   style: const TextStyle(
            //                                         //       color:
            //                                         //           PeopleChaoScreen_Color
            //                                         //               .Colors_Text2_,
            //                                         //       fontWeight: FontWeight.bold,
            //                                         //       fontFamily:
            //                                         //           FontWeight_.Fonts_T

            //                                         //       //fontSize: 10.0
            //                                         //       ),
            //                                         // ),
            //                                         ),
            //                                   ],
            //                                 ),
            //                               ),
            //                               // Expanded(flex: 1, child: Text('')),
            //                             ],
            //                           ),
            //                         ),
            //                         Padding(
            //                             padding: const EdgeInsets.all(8.0),
            //                             child: ScrollConfiguration(
            //                               behavior:
            //                                   ScrollConfiguration.of(context)
            //                                       .copyWith(dragDevices: {
            //                                 PointerDeviceKind.touch,
            //                                 PointerDeviceKind.mouse,
            //                               }),
            //                               child: Column(
            //                                 crossAxisAlignment:
            //                                     CrossAxisAlignment.start,
            //                                 children: [
            //                                   Container(
            //                                     width: MediaQuery.of(context)
            //                                         .size
            //                                         .width,
            //                                     height: (areaModels.length == 0)
            //                                         ? MediaQuery.of(context)
            //                                                 .size
            //                                                 .height *
            //                                             0.6
            //                                         : 600,
            //                                     child: (areaModels.length == 0)
            //                                         ? SizedBox(
            //                                             child: Column(
            //                                               mainAxisAlignment:
            //                                                   MainAxisAlignment
            //                                                       .center,
            //                                               children: [
            //                                                 StreamBuilder(
            //                                                   stream: Stream.periodic(
            //                                                       const Duration(
            //                                                           milliseconds:
            //                                                               15),
            //                                                       (i) => i),
            //                                                   builder: (context,
            //                                                       snapshot) {
            //                                                     if (!snapshot
            //                                                         .hasData)
            //                                                       return const Text(
            //                                                           '');
            //                                                     double elapsed =
            //                                                         double.parse(snapshot
            //                                                                 .data
            //                                                                 .toString()) *
            //                                                             0.05;
            //                                                     return Column(
            //                                                       children: [
            //                                                         if (elapsed <
            //                                                             8.00)
            //                                                           CircularProgressIndicator(),
            //                                                         Padding(
            //                                                           padding:
            //                                                               const EdgeInsets.all(
            //                                                                   8.0),
            //                                                           child: (elapsed >
            //                                                                   8.00)
            //                                                               ? const Text(
            //                                                                   'ไม่พบข้อมูล',
            //                                                                   style: TextStyle(
            //                                                                     color: PeopleChaoScreen_Color.Colors_Text2_,
            //                                                                     fontFamily: Font_.Fonts_T,
            //                                                                     fontWeight: FontWeight.w500,
            //                                                                     //fontSize: 10.0
            //                                                                   ),
            //                                                                 )
            //                                                               : Text(
            //                                                                   'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
            //                                                                   // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
            //                                                                   style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
            //                                                                       //fontSize: 10.0
            //                                                                       ),
            //                                                                 ),
            //                                                         ),
            //                                                       ],
            //                                                     );
            //                                                   },
            //                                                 ),
            //                                               ],
            //                                             ),
            //                                           )
            //                                         : GridView.count(
            //                                             crossAxisCount: MediaQuery.of(
            //                                                             context)
            //                                                         .size
            //                                                         .shortestSide <
            //                                                     MediaQuery.of(
            //                                                                 context)
            //                                                             .size
            //                                                             .width *
            //                                                         1
            //                                                 ? 12
            //                                                 : (MediaQuery.of(
            //                                                                 context)
            //                                                             .size
            //                                                             .width <
            //                                                         400)
            //                                                     ? 4
            //                                                     : 6,
            //                                             children: [
            //                                               for (int i = 0;
            //                                                   i <
            //                                                       areaModels
            //                                                           .length;
            //                                                   i++)
            //                                                 createCard(
            //                                                     i, context),
            //                                             ],
            //                                           ),
            //                                   )
            //                                 ],
            //                               ),
            //                             )),
            //                         // Container(
            //                         //   width: MediaQuery.of(context).size.width,
            //                         //   height: 500,
            //                         //   child: Column(
            //                         //     crossAxisAlignment: CrossAxisAlignment.start,
            //                         //     children: [
            //                         //       ScrollConfiguration(
            //                         //         behavior: ScrollConfiguration.of(context)
            //                         //             .copyWith(dragDevices: {
            //                         //           PointerDeviceKind.touch,
            //                         //           PointerDeviceKind.mouse,
            //                         //         }),
            //                         //         child: SingleChildScrollView(
            //                         //           scrollDirection: Axis.horizontal,
            //                         //           dragStartBehavior: DragStartBehavior.start,
            //                         //           child: Row(
            //                         //               mainAxisAlignment:
            //                         //                   MainAxisAlignment.start,
            //                         //               children: [
            //                         //                 for (int i = 0;
            //                         //                     i < areaModels.length;
            //                         //                     i++)
            //                         //                   Column(
            //                         //                     crossAxisAlignment:
            //                         //                         CrossAxisAlignment.start,
            //                         //                     children: [
            //                         //                       areaModels[i].quantity == null
            //                         //                           ? Row(
            //                         //                               mainAxisAlignment:
            //                         //                                   MainAxisAlignment
            //                         //                                       .start,
            //                         //                               children: [
            //                         //                                 createCard(i),
            //                         //                               ],
            //                         //                             )
            //                         //                           : SizedBox()
            //                         //                     ],
            //                         //                   ),
            //                         //                 SizedBox(
            //                         //                   width: 300,
            //                         //                 )
            //                         //               ]),
            //                         //         ),
            //                         //       ),
            //                         //       ScrollConfiguration(
            //                         //         behavior: ScrollConfiguration.of(context)
            //                         //             .copyWith(dragDevices: {
            //                         //           PointerDeviceKind.touch,
            //                         //           PointerDeviceKind.mouse,
            //                         //         }),
            //                         //         child: SingleChildScrollView(
            //                         //           scrollDirection: Axis.horizontal,
            //                         //           dragStartBehavior: DragStartBehavior.start,
            //                         //           child: Row(
            //                         //               mainAxisAlignment:
            //                         //                   MainAxisAlignment.start,
            //                         //               children: [
            //                         //                 for (int i = 0;
            //                         //                     i < areaModels.length;
            //                         //                     i++)
            //                         //                   Column(
            //                         //                     crossAxisAlignment:
            //                         //                         CrossAxisAlignment.start,
            //                         //                     children: [
            //                         //                       areaModels[i].quantity == '2'
            //                         //                           ? Row(
            //                         //                               mainAxisAlignment:
            //                         //                                   MainAxisAlignment
            //                         //                                       .start,
            //                         //                               children: [
            //                         //                                 createCard(i),
            //                         //                               ],
            //                         //                             )
            //                         //                           : SizedBox(),
            //                         //                     ],
            //                         //                   ),
            //                         //                 SizedBox(
            //                         //                   width: 300,
            //                         //                 )
            //                         //               ]),
            //                         //         ),
            //                         //       ),
            //                         //       ScrollConfiguration(
            //                         //         behavior: ScrollConfiguration.of(context)
            //                         //             .copyWith(dragDevices: {
            //                         //           PointerDeviceKind.touch,
            //                         //           PointerDeviceKind.mouse,
            //                         //         }),
            //                         //         child: SingleChildScrollView(
            //                         //           scrollDirection: Axis.horizontal,
            //                         //           dragStartBehavior: DragStartBehavior.start,
            //                         //           child: Row(
            //                         //               mainAxisAlignment:
            //                         //                   MainAxisAlignment.start,
            //                         //               children: [
            //                         //                 for (int i = 0;
            //                         //                     i < areaModels.length;
            //                         //                     i++)
            //                         //                   Column(
            //                         //                     crossAxisAlignment:
            //                         //                         CrossAxisAlignment.start,
            //                         //                     children: [
            //                         //                       areaModels[i].quantity == '1'
            //                         //                           ? Row(
            //                         //                               mainAxisAlignment:
            //                         //                                   MainAxisAlignment
            //                         //                                       .start,
            //                         //                               children: [
            //                         //                                 createCard(i),
            //                         //                               ],
            //                         //                             )
            //                         //                           : SizedBox(),
            //                         //                     ],
            //                         //                   ),
            //                         //                 const SizedBox(
            //                         //                   width: 300,
            //                         //                 )
            //                         //               ]),
            //                         //         ),
            //                         //       ),
            //                         //       ScrollConfiguration(
            //                         //         behavior: ScrollConfiguration.of(context)
            //                         //             .copyWith(dragDevices: {
            //                         //           PointerDeviceKind.touch,
            //                         //           PointerDeviceKind.mouse,
            //                         //         }),
            //                         //         child: SingleChildScrollView(
            //                         //           scrollDirection: Axis.horizontal,
            //                         //           dragStartBehavior: DragStartBehavior.start,
            //                         //           child: Row(
            //                         //               mainAxisAlignment:
            //                         //                   MainAxisAlignment.start,
            //                         //               children: [
            //                         //                 for (int i = 0;
            //                         //                     i < areaModels.length;
            //                         //                     i++)
            //                         //                   Column(
            //                         //                     crossAxisAlignment:
            //                         //                         CrossAxisAlignment.start,
            //                         //                     children: [
            //                         //                       areaModels[i].quantity == '3'
            //                         //                           ? Row(
            //                         //                               mainAxisAlignment:
            //                         //                                   MainAxisAlignment
            //                         //                                       .start,
            //                         //                               children: [
            //                         //                                 createCard(i),
            //                         //                               ],
            //                         //                             )
            //                         //                           : SizedBox(),
            //                         //                     ],
            //                         //                   ),
            //                         //                 SizedBox(
            //                         //                   width: 300,
            //                         //                 )
            //                         //               ]),
            //                         //         ),
            //                         //       ),
            //                         //     ],
            //                         //   ),
            //                         // ),
            //                       ],
            //                     ),
            //         ),
            //       )
            //     ],
            //   )
            : (ser_Floor_plans == '0')
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 600,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            // border: Border.all(color: Colors.grey, width: 1),
                          ),
                          // padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (!Responsive.isDesktop(
                                                  context))
                                                Stack(
                                                  children: [
                                                    Container(
                                                      height: 300,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Container(
                                                              width: 300,
                                                              height: 300,
                                                              child:
                                                                  InteractiveViewer(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                scaleEnabled:
                                                                    false,
                                                                trackpadScrollCausesScale:
                                                                    false,
                                                                transformationController:
                                                                    _controller,
                                                                minScale: 0.8,
                                                                maxScale: 2.0,
                                                                constrained:
                                                                    true,
                                                                boundaryMargin:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        double
                                                                            .infinity),
                                                                child: Stack(
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          300,
                                                                      height:
                                                                          300,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[50],
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              AssetImage("images/Floor-plan-try.png"),
                                                                          // fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: 80,
                                                                      right: 33,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog<
                                                                              String>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                AlertDialog(
                                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                              title: const Center(
                                                                                  child: Column(
                                                                                children: [
                                                                                  Text(
                                                                                    'พื้นที่ : A',
                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                              content: const SingleChildScrollView(
                                                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                                Text(
                                                                                  'สถานะ : เช่าแล้ว',
                                                                                  style: TextStyle(
                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ])),
                                                                              actions: <Widget>[
                                                                                Column(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    const Divider(
                                                                                      color: Colors.grey,
                                                                                      height: 4.0,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(4.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 100,
                                                                                                  decoration: const BoxDecoration(
                                                                                                    color: Colors.redAccent,
                                                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                                  ),
                                                                                                  padding: const EdgeInsets.all(5.0),
                                                                                                  child: TextButton(
                                                                                                    onPressed: () => Navigator.pop(context, 'OK'),
                                                                                                    child: const Text(
                                                                                                      'ปิด',
                                                                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              80,
                                                                          height:
                                                                              60,
                                                                          color: Colors
                                                                              .red[200]!
                                                                              .withOpacity(0.5),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Text(
                                                                              'A',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: 95,
                                                                      left: 70,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog<
                                                                              String>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                AlertDialog(
                                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                              title: const Center(
                                                                                  child: Column(
                                                                                children: [
                                                                                  Text(
                                                                                    'พื้นที่ : B',
                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                              content: const SingleChildScrollView(
                                                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                                Text(
                                                                                  'สถานะ : ว่าง',
                                                                                  style: TextStyle(
                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ])),
                                                                              actions: <Widget>[
                                                                                Column(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    const Divider(
                                                                                      color: Colors.grey,
                                                                                      height: 4.0,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(4.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 100,
                                                                                                  decoration: const BoxDecoration(
                                                                                                    color: Colors.redAccent,
                                                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                                  ),
                                                                                                  padding: const EdgeInsets.all(5.0),
                                                                                                  child: TextButton(
                                                                                                    onPressed: () => Navigator.pop(context, 'OK'),
                                                                                                    child: const Text(
                                                                                                      'ปิด',
                                                                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              105,
                                                                          height:
                                                                              45,
                                                                          color: Colors
                                                                              .green[200]!
                                                                              .withOpacity(0.5),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Text(
                                                                              'B',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      bottom:
                                                                          75,
                                                                      left: 72,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog<
                                                                              String>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                AlertDialog(
                                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                              title: const Center(
                                                                                  child: Column(
                                                                                children: [
                                                                                  Text(
                                                                                    'พื้นที่ : C',
                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                              content: const SingleChildScrollView(
                                                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                                Text(
                                                                                  'สถานะ : ว่าง',
                                                                                  style: TextStyle(
                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ])),
                                                                              actions: <Widget>[
                                                                                Column(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    const Divider(
                                                                                      color: Colors.grey,
                                                                                      height: 4.0,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(4.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 100,
                                                                                                  decoration: const BoxDecoration(
                                                                                                    color: Colors.redAccent,
                                                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                                  ),
                                                                                                  padding: const EdgeInsets.all(5.0),
                                                                                                  child: TextButton(
                                                                                                    onPressed: () => Navigator.pop(context, 'OK'),
                                                                                                    child: const Text(
                                                                                                      'ปิด',
                                                                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              193,
                                                                          height:
                                                                              65,
                                                                          color: Colors
                                                                              .green[200]!
                                                                              .withOpacity(0.5),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Text(
                                                                              'C',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      bottom:
                                                                          75,
                                                                      left: 25,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          showDialog<
                                                                              String>(
                                                                            context:
                                                                                context,
                                                                            builder: (BuildContext context) =>
                                                                                AlertDialog(
                                                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                              title: const Center(
                                                                                  child: Column(
                                                                                children: [
                                                                                  Text(
                                                                                    'พื้นที่ : D',
                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                              content: const SingleChildScrollView(
                                                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                                Text(
                                                                                  'สถานะ : เช่าแล้ว',
                                                                                  style: TextStyle(
                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                      // fontWeight: FontWeight.bold,
                                                                                      fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ])),
                                                                              actions: <Widget>[
                                                                                Column(
                                                                                  children: [
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    const Divider(
                                                                                      color: Colors.grey,
                                                                                      height: 4.0,
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 2.0,
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(4.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 100,
                                                                                                  decoration: const BoxDecoration(
                                                                                                    color: Colors.redAccent,
                                                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                                  ),
                                                                                                  padding: const EdgeInsets.all(5.0),
                                                                                                  child: TextButton(
                                                                                                    onPressed: () => Navigator.pop(context, 'OK'),
                                                                                                    child: const Text(
                                                                                                      'ปิด',
                                                                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              45,
                                                                          height:
                                                                              100,
                                                                          color: Colors
                                                                              .red[200]!
                                                                              .withOpacity(0.5),
                                                                          child:
                                                                              const Center(
                                                                            child:
                                                                                Text(
                                                                              'D',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 10,
                                                      right: 10,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.blueGrey
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5),
                                                            topRight:
                                                                Radius.circular(
                                                                    5),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    5),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    5),
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.zoom_in,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed:
                                                                  _zoomInSVG,
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.zoom_out,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed:
                                                                  _zoomOutSVG,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Floorplans แผนผังพื้นที่ ',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'ดูสถานะพื้นที่เช่าได้อย่างง่ายดายด้วย Floorplans แผนผังพื้นที่',
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () {},
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.orange[600],
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
                                                        // border: Border.all(color: Colors.grey, width: 1),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: const Text(
                                                        'อัพเกรด ( Upgrade ) ',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (Responsive.isDesktop(context))
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            image: DecorationImage(
                                              image:
                                                  AssetImage("images/Lap2.png"),
                                              // fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 500,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        width: 400,
                                                        height: 250,
                                                        child:
                                                            InteractiveViewer(
                                                          alignment:
                                                              Alignment.center,
                                                          scaleEnabled: false,
                                                          trackpadScrollCausesScale:
                                                              false,
                                                          transformationController:
                                                              _controller,
                                                          minScale: 0.8,
                                                          maxScale: 1.5,
                                                          constrained: true,
                                                          boundaryMargin:
                                                              const EdgeInsets
                                                                      .all(
                                                                  double
                                                                      .infinity),
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                width: 280,
                                                                height: 280,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        "images/Floor-plan-try.png"),
                                                                    // fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 55,
                                                                right: 150,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showDialog<
                                                                        String>(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          AlertDialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20.0))),
                                                                        title: const Center(
                                                                            child: Column(
                                                                          children: [
                                                                            Text(
                                                                              'พื้นที่ : A',
                                                                              style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                        content:
                                                                            const SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                'สถานะ : เช่าแล้ว',
                                                                                style: TextStyle(
                                                                                    color: AdminScafScreen_Color.Colors_Text1_,
                                                                                    // fontWeight: FontWeight.bold,
                                                                                    fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        actions: <Widget>[
                                                                          Column(
                                                                            children: [
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              const Divider(
                                                                                color: Colors.grey,
                                                                                height: 4.0,
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(4.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 100,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Colors.redAccent,
                                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            ),
                                                                                            padding: const EdgeInsets.all(5.0),
                                                                                            child: TextButton(
                                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                                              child: const Text(
                                                                                                'ปิด',
                                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 75,
                                                                    height: 58,
                                                                    color: Colors
                                                                        .red[
                                                                            200]!
                                                                        .withOpacity(
                                                                            0.5),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Text(
                                                                        'A',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                top: 55,
                                                                left: 70,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showDialog<
                                                                        String>(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          AlertDialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20.0))),
                                                                        title: const Center(
                                                                            child: Column(
                                                                          children: [
                                                                            Text(
                                                                              'พื้นที่ : B',
                                                                              style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                        content:
                                                                            const SingleChildScrollView(
                                                                                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                          Text(
                                                                            'สถานะ : ว่าง',
                                                                            style: TextStyle(
                                                                                color: AdminScafScreen_Color.Colors_Text1_,
                                                                                // fontWeight: FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                        ])),
                                                                        actions: <Widget>[
                                                                          Column(
                                                                            children: [
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              const Divider(
                                                                                color: Colors.grey,
                                                                                height: 4.0,
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(4.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 100,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Colors.redAccent,
                                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            ),
                                                                                            padding: const EdgeInsets.all(5.0),
                                                                                            child: TextButton(
                                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                                              child: const Text(
                                                                                                'ปิด',
                                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 105,
                                                                    height: 53,
                                                                    color: Colors
                                                                        .green[
                                                                            200]!
                                                                        .withOpacity(
                                                                            0.5),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Text(
                                                                        'B',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                bottom: 55,
                                                                left: 65,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showDialog<
                                                                        String>(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          AlertDialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20.0))),
                                                                        title: const Center(
                                                                            child: Column(
                                                                          children: [
                                                                            Text(
                                                                              'พื้นที่ : C',
                                                                              style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                        content:
                                                                            const SingleChildScrollView(
                                                                                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                          Text(
                                                                            'สถานะ : ว่าง',
                                                                            style: TextStyle(
                                                                                color: AdminScafScreen_Color.Colors_Text1_,
                                                                                // fontWeight: FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                        ])),
                                                                        actions: <Widget>[
                                                                          Column(
                                                                            children: [
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              const Divider(
                                                                                color: Colors.grey,
                                                                                height: 4.0,
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(4.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 100,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Colors.redAccent,
                                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            ),
                                                                                            padding: const EdgeInsets.all(5.0),
                                                                                            child: TextButton(
                                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                                              child: const Text(
                                                                                                'ปิด',
                                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 185,
                                                                    height: 65,
                                                                    color: Colors
                                                                        .green[
                                                                            200]!
                                                                        .withOpacity(
                                                                            0.5),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Text(
                                                                        'C',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                bottom: 50,
                                                                left: 22,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    showDialog<
                                                                        String>(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          AlertDialog(
                                                                        shape: const RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20.0))),
                                                                        title: const Center(
                                                                            child: Column(
                                                                          children: [
                                                                            Text(
                                                                              'พื้นที่ : D',
                                                                              style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                        content:
                                                                            const SingleChildScrollView(
                                                                                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                                                          Text(
                                                                            'สถานะ : เช่าแล้ว',
                                                                            style: TextStyle(
                                                                                color: AdminScafScreen_Color.Colors_Text1_,
                                                                                // fontWeight: FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                        ])),
                                                                        actions: <Widget>[
                                                                          Column(
                                                                            children: [
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              const Divider(
                                                                                color: Colors.grey,
                                                                                height: 4.0,
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 2.0,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(4.0),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 100,
                                                                                            decoration: const BoxDecoration(
                                                                                              color: Colors.redAccent,
                                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                            ),
                                                                                            padding: const EdgeInsets.all(5.0),
                                                                                            child: TextButton(
                                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                                              child: const Text(
                                                                                                'ปิด',
                                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 45,
                                                                    height: 100,
                                                                    color: Colors
                                                                        .red[
                                                                            200]!
                                                                        .withOpacity(
                                                                            0.5),
                                                                    child:
                                                                        const Center(
                                                                      child:
                                                                          Text(
                                                                        'D',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5),
                                                      topRight:
                                                          Radius.circular(5),
                                                      bottomLeft:
                                                          Radius.circular(5),
                                                      bottomRight:
                                                          Radius.circular(5),
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.zoom_in,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: _zoomInSVG,
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.zoom_out,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: _zoomOutSVG,
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
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    // color: AppBarColors.ABar_Colors,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(0)),
                                    // border: Border.all(color: Colors.grey, width: 1),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white,
                                        // Color.fromARGB(255, 244, 245, 242),
                                        Color.fromARGB(255, 216, 231, 199),
                                        Color.fromARGB(255, 199, 219, 175),
                                        AppBarColors.ABar_Colors,
                                      ],
                                    )),
                                height: 80,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (zone_ser == '0' || zone_ser == null)
                        ? Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 520,
                                            width: 850,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'กรุณาเลือกโซนพื้นที่',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          // color: AppBarColors.ABar_Colors,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(100),
                                              topRight: Radius.circular(100),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0)),
                                          // border: Border.all(color: Colors.grey, width: 1),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white,
                                              // Color.fromARGB(255, 244, 245, 242),
                                              Color.fromARGB(
                                                  255, 216, 231, 199),
                                              Color.fromARGB(
                                                  255, 199, 219, 175),
                                              AppBarColors.ABar_Colors,
                                            ],
                                          )),
                                      height: 80,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 510,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: ScrollConfiguration(
                                                behavior:
                                                    ScrollConfiguration.of(
                                                            context)
                                                        .copyWith(dragDevices: {
                                                  PointerDeviceKind.touch,
                                                  PointerDeviceKind.mouse,
                                                }),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Stack(
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius: BorderRadius.only(
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
                                                                          Radius.circular(
                                                                              10)),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 5),
                                                                ),
                                                                child:
                                                                    InteractiveViewer(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  scaleEnabled:
                                                                      false,
                                                                  trackpadScrollCausesScale:
                                                                      false,
                                                                  transformationController:
                                                                      _controller,
                                                                  minScale: 0.8,
                                                                  maxScale: 2.0,
                                                                  constrained:
                                                                      true,
                                                                  boundaryMargin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              150.0),
                                                                  // boundaryMargin:
                                                                  //     const EdgeInsets.all(
                                                                  //         double.infinity),
                                                                  child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        // color: Colors.purple,
                                                                        height:
                                                                            520,
                                                                        width:
                                                                            850,
                                                                        child: KeyedSubtree(
                                                                            key: _countriesKey,
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                image: DecorationImage(
                                                                                  image: NetworkImage("$Img_Zone"),
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              child: Stack(alignment: Alignment.center, children: [
                                                                                for (var areaModel in areaFloorplanModels)
                                                                                  Stack(
                                                                                    children: [
                                                                                      ClipPath(
                                                                                        clipper: Clipper(
                                                                                          svgPath: areaModel.path!,
                                                                                          // height:
                                                                                          //     17.0,
                                                                                          // width:
                                                                                          //     26.2,
                                                                                        ),
                                                                                        child: InkWell(
                                                                                          onTap: () async {
                                                                                            int index = areaModels.indexWhere((area) => area.ser.toString().trim() == areaModel.ser);
                                                                                            onCountrySelected.call(areaModel);
                                                                                            // print('${areaModel.id}  ');
                                                                                            Future.delayed(const Duration(milliseconds: 200), () {
                                                                                              dialog_svg(index, context);
                                                                                            });
                                                                                          },
                                                                                          child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                              color: (areaFloorplanModelss?.id == areaModel.id)
                                                                                                  ? areaModel.quantity == '1'
                                                                                                      ? datex.isAfter(DateTime.parse('${areaModel.ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) == true //datex
                                                                                                          ? datex.isAfter(DateTime.parse('${areaModel.ldate} 00:00:00.000').subtract(Duration(days: 0))) == false
                                                                                                              ? Colors.orange[900]!.withOpacity(0.5)
                                                                                                              : Colors.grey[900]!.withOpacity(0.5)
                                                                                                          : Colors.red[900]!.withOpacity(0.5)
                                                                                                      : areaModel.quantity == '2'
                                                                                                          ? Colors.blue[900]!.withOpacity(0.5)
                                                                                                          : areaModel.quantity == '3'
                                                                                                              ? Colors.purple[900]!.withOpacity(0.5)
                                                                                                              : Colors.green[900]!.withOpacity(0.5)
                                                                                                  : (areaFloorplanModelss != null)
                                                                                                      ? Colors.grey[200]!.withOpacity(0.4)
                                                                                                      : areaModel.quantity == '1'
                                                                                                          ? datex.isAfter(DateTime.parse('${areaModel.ldate} 00:00:00.000').subtract(Duration(days: open_set_date))) == true //datex
                                                                                                              ? datex.isAfter(DateTime.parse('${areaModel.ldate} 00:00:00.000').subtract(Duration(days: 0))) == false
                                                                                                                  ? Colors.orange[900]!.withOpacity(0.4)
                                                                                                                  : Colors.grey[900]!.withOpacity(0.4)
                                                                                                              : Colors.red[200]!.withOpacity(0.4)
                                                                                                          : areaModel.quantity == '2'
                                                                                                              ? Colors.blue[200]!.withOpacity(0.4)
                                                                                                              : areaModel.quantity == '3'
                                                                                                                  ? Colors.purple[200]!.withOpacity(0.4)
                                                                                                                  : Colors.green[200]!.withOpacity(0.4),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                              ]),
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
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
                                    Container(
                                      decoration: const BoxDecoration(
                                          // color: AppBarColors.ABar_Colors,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(100),
                                              topRight: Radius.circular(100),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0)),
                                          // border: Border.all(color: Colors.grey, width: 1),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white,
                                              // Color.fromARGB(255, 244, 245, 242),
                                              Color.fromARGB(
                                                  255, 216, 231, 199),
                                              Color.fromARGB(
                                                  255, 199, 219, 175),
                                              AppBarColors.ABar_Colors,
                                            ],
                                          )),
                                      height: 80,
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child: Text(
                                      'Floorplans แผนผังพื้นที่',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontFamily: FontWeight_.Fonts_T),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5),
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                        ),
                                        onPressed: _zoomInSVG,
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.zoom_out,
                                          color: Colors.white,
                                        ),
                                        onPressed: _zoomOutSVG,
                                      ),
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.grey,
                                      //     borderRadius: const BorderRadius.only(
                                      //       topLeft: Radius.circular(5),
                                      //       topRight: Radius.circular(5),
                                      //       bottomLeft: Radius.circular(5),
                                      //       bottomRight: Radius.circular(5),
                                      //     ),
                                      //   ),
                                      //   child: Text(
                                      //     '${MediaQuery.of(context).size.width}',
                                      //     overflow: TextOverflow.ellipsis,
                                      //     // minFontSize: 1,
                                      //     // maxFontSize: 12,
                                      //     maxLines: 1,
                                      //     textAlign: TextAlign.left,
                                      //     style: TextStyle(
                                      //       color: Colors.white,
                                      //       fontFamily: Font_.Fonts_T,

                                      //       //fontSize: 10.0s
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );

    // Column(children: [
    //     Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Container(
    //         height: MediaQuery.of(context).size.height / 1.2,
    //         width: 1600,
    //         decoration: const BoxDecoration(
    //           color: Colors.red,
    //           borderRadius: BorderRadius.only(
    //               topLeft: Radius.circular(10),
    //               topRight: Radius.circular(10),
    //               bottomLeft: Radius.circular(10),
    //               bottomRight: Radius.circular(10)),
    //           // border: Border.all(color: Colors.grey, width: 1),
    //         ),
    //         padding: const EdgeInsets.all(20),
    //         // color: Colors.white,
    //         child:
    // Stack(
    //           children: [
    //             InteractiveViewer(
    //               alignment: Alignment.center,
    //               scaleEnabled: false,
    //               trackpadScrollCausesScale: false,
    //               transformationController: _controller,
    //               minScale: 0.8,
    //               maxScale: 2.0,
    //               constrained: true,
    //               boundaryMargin:
    //                   const EdgeInsets.all(double.infinity),
    //               child: Container(
    //                 height: 500,
    //                 width: 850,
    //                 decoration: BoxDecoration(
    //                   color: Colors.white,
    //                   image: DecorationImage(
    //                     image: NetworkImage("$Img_Zone"),
    //                     // fit: BoxFit.cover,
    //                   ),
    //                 ),
    //                 child: Align(
    //                   alignment: Alignment.center,
    //                   child: KeyedSubtree(
    //                       key: _countriesKey,
    //                       child: Container(
    //                         child: Stack(children: [
    //                           for (var areaModels
    //                               in areaFloorplanModels)
    //                             Center(
    //                               child: ClipPath(
    //                                 clipper: Clipper(
    //                                   svgPath: areaModels.path!,
    //                                   height: 15.0,
    //                                   width: 23.2,
    //                                 ),
    //                                 child: InkWell(
    //                                   onTap: () async {
    //                                     onCountrySelected
    //                                         .call(areaModels);
    //                                     print('${areaModels.id}  ');
    //                                     setState(() {
    //                                       Ln_name =
    //                                           '${areaModels.lncode} (${areaModels.ln})';
    //                                       // Ln_name = '${country.}//${areaModels.length}';
    //                                     });
    //                                     showDialog<String>(
    //                                       context: context,
    //                                       builder: (BuildContext
    //                                               context) =>
    //                                           AlertDialog(
    //                                         shape: const RoundedRectangleBorder(
    //                                             borderRadius:
    //                                                 BorderRadius.all(
    //                                                     Radius.circular(
    //                                                         20.0))),
    //                                         title: Center(
    //                                             child: Column(
    //                                           children: [
    //                                             Text(
    //                                               '$Ln_name',
    //                                               style: const TextStyle(
    //                                                   color: AdminScafScreen_Color
    //                                                       .Colors_Text1_,
    //                                                   fontWeight:
    //                                                       FontWeight
    //                                                           .bold,
    //                                                   fontFamily:
    //                                                       FontWeight_
    //                                                           .Fonts_T),
    //                                             ),
    //                                             const SizedBox(
    //                                               height: 5.0,
    //                                             ),
    //                                             Divider(
    //                                               color: Colors
    //                                                   .grey[100],
    //                                               height: 4.0,
    //                                             ),
    //                                             const SizedBox(
    //                                               height: 5.0,
    //                                             ),
    //                                           ],
    //                                         )),
    //                                         content:
    //                                             SingleChildScrollView(
    //                                           child: Column(
    //                                             crossAxisAlignment:
    //                                                 CrossAxisAlignment
    //                                                     .center,
    //                                             children: <Widget>[
    //                                               if (areaModels
    //                                                       .quantity !=
    //                                                   '1')
    //                                                 ListTile(
    //                                                     onTap:
    //                                                         () async {
    //                                                       SharedPreferences
    //                                                           preferences =
    //                                                           await SharedPreferences
    //                                                               .getInstance();
    //                                                       preferences.setString(
    //                                                           'zoneSer',
    //                                                           areaModels
    //                                                               .zser
    //                                                               .toString());
    //                                                       preferences.setString(
    //                                                           'zonesName',
    //                                                           areaModels
    //                                                               .zn
    //                                                               .toString());
    //                                                       setState(
    //                                                           () {
    //                                                         Ser_Body =
    //                                                             1;
    //                                                         a_ln = areaModels
    //                                                             .lncode;
    //                                                         a_ser =
    //                                                             areaModels.ser;
    //                                                         a_area =
    //                                                             areaModels.area;
    //                                                         a_rent =
    //                                                             areaModels.rent;
    //                                                         a_page =
    //                                                             '1';
    //                                                       });

    //                                                       Navigator.pop(
    //                                                           context);
    //                                                     },
    //                                                     title: Container(
    //                                                         decoration: BoxDecoration(
    //                                                           color:
    //                                                               Colors.grey[100],
    //                                                           borderRadius: const BorderRadius.only(
    //                                                               topLeft: Radius.circular(10),
    //                                                               topRight: Radius.circular(10),
    //                                                               bottomLeft: Radius.circular(10),
    //                                                               bottomRight: Radius.circular(10)),
    //                                                         ),
    //                                                         padding: const EdgeInsets.all(10),
    //                                                         // width: MediaQuery.of(context).size.width,
    //                                                         child: Row(
    //                                                           children: [
    //                                                             Expanded(
    //                                                                 child: Text(
    //                                                               'เสนอราคา: ${areaModels.lncode} (${areaModels.ln})',
    //                                                               overflow: TextOverflow.ellipsis,
    //                                                               style: const TextStyle(
    //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                                   //fontWeight: FontWeight.bold,
    //                                                                   fontFamily: Font_.Fonts_T),
    //                                                             ))
    //                                                           ],
    //                                                         ))),
    //                                               if (areaModels
    //                                                       .quantity !=
    //                                                   '1')
    //                                                 ListTile(
    //                                                     onTap:
    //                                                         () async {
    //                                                       SharedPreferences
    //                                                           preferences =
    //                                                           await SharedPreferences
    //                                                               .getInstance();
    //                                                       preferences.setString(
    //                                                           'zoneSer',
    //                                                           areaModels
    //                                                               .zser
    //                                                               .toString());
    //                                                       preferences.setString(
    //                                                           'zonesName',
    //                                                           areaModels
    //                                                               .zn
    //                                                               .toString());

    //                                                       setState(
    //                                                           () {
    //                                                         Ser_Body =
    //                                                             2;
    //                                                         a_ln = areaModels
    //                                                             .lncode;
    //                                                         a_ser =
    //                                                             areaModels.ser;
    //                                                         a_area =
    //                                                             areaModels.area;
    //                                                         a_rent =
    //                                                             areaModels.rent;
    //                                                         a_page =
    //                                                             '1';
    //                                                       });
    //                                                       Navigator.pop(
    //                                                           context);
    //                                                     },
    //                                                     title: Container(
    //                                                         decoration: BoxDecoration(
    //                                                           color:
    //                                                               Colors.grey[100],
    //                                                           borderRadius: const BorderRadius.only(
    //                                                               topLeft: Radius.circular(10),
    //                                                               topRight: Radius.circular(10),
    //                                                               bottomLeft: Radius.circular(10),
    //                                                               bottomRight: Radius.circular(10)),
    //                                                         ),
    //                                                         padding: const EdgeInsets.all(10),
    //                                                         // width: MediaQuery.of(context).size.width,
    //                                                         child: Row(
    //                                                           children: [
    //                                                             Expanded(
    //                                                                 child: Text(
    //                                                               'ทำสัญญา: ${areaModels.lncode} (${areaModels.ln})',
    //                                                               overflow: TextOverflow.ellipsis,
    //                                                               style: const TextStyle(
    //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                                   //fontWeight: FontWeight.bold,
    //                                                                   fontFamily: Font_.Fonts_T),
    //                                                             ))
    //                                                           ],
    //                                                         ))),
    //                                               if (areaModels
    //                                                       .quantity ==
    //                                                   '1')
    //                                                 ListTile(
    //                                                     onTap:
    //                                                         () async {
    //                                                       setState(
    //                                                           () {
    //                                                         Ser_Body =
    //                                                             3;
    //                                                         Value_cid =
    //                                                             areaModels.cid;
    //                                                         ser_cidtan =
    //                                                             '1';
    //                                                       });
    //                                                       Navigator.pop(
    //                                                           context);
    //                                                     },
    //                                                     title: Container(
    //                                                         decoration: BoxDecoration(
    //                                                           color:
    //                                                               Colors.grey[100],
    //                                                           borderRadius: const BorderRadius.only(
    //                                                               topLeft: Radius.circular(10),
    //                                                               topRight: Radius.circular(10),
    //                                                               bottomLeft: Radius.circular(10),
    //                                                               bottomRight: Radius.circular(10)),
    //                                                         ),
    //                                                         padding: const EdgeInsets.all(10),
    //                                                         // width: MediaQuery.of(context).size.width,
    //                                                         child: Row(
    //                                                           children: [
    //                                                             Expanded(
    //                                                                 child: Text(
    //                                                               'เช่าอยู่: ${areaModels.cid}',
    //                                                               overflow: TextOverflow.ellipsis,
    //                                                               style: const TextStyle(
    //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                                   //fontWeight: FontWeight.bold,
    //                                                                   fontFamily: Font_.Fonts_T),
    //                                                             ))
    //                                                           ],
    //                                                         ))),
    //                                               if (areaModels
    //                                                       .quantity ==
    //                                                   '1')
    //                                                 ListTile(
    //                                                     onTap:
    //                                                         () async {
    //                                                       setState(
    //                                                           () {
    //                                                         Ser_Body =
    //                                                             4;
    //                                                         Value_cid =
    //                                                             areaModels.cid;
    //                                                         ser_cidtan =
    //                                                             '1';
    //                                                       });
    //                                                       Navigator.pop(
    //                                                           context);
    //                                                     },
    //                                                     title: Container(
    //                                                         decoration: BoxDecoration(
    //                                                           color:
    //                                                               Colors.grey[100],
    //                                                           borderRadius: const BorderRadius.only(
    //                                                               topLeft: Radius.circular(10),
    //                                                               topRight: Radius.circular(10),
    //                                                               bottomLeft: Radius.circular(10),
    //                                                               bottomRight: Radius.circular(10)),
    //                                                         ),
    //                                                         padding: const EdgeInsets.all(10),
    //                                                         // width: MediaQuery.of(context).size.width,
    //                                                         child: Row(
    //                                                           children: [
    //                                                             Expanded(
    //                                                                 child: Text(
    //                                                               'รับชำระ: ${areaModels.cid}',
    //                                                               overflow: TextOverflow.ellipsis,
    //                                                               style: const TextStyle(
    //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                                   //fontWeight: FontWeight.bold,
    //                                                                   fontFamily: Font_.Fonts_T),
    //                                                             ))
    //                                                           ],
    //                                                         ))),
    //                                               if (areaModels
    //                                                       .quantity ==
    //                                                   '2')
    //                                                 ListTile(
    //                                                     onTap:
    //                                                         () async {
    //                                                       setState(
    //                                                           () {
    //                                                         Ser_Body =
    //                                                             3;
    //                                                         Value_cid =
    //                                                             areaModels.docno;
    //                                                         ser_cidtan =
    //                                                             '2';
    //                                                       });
    //                                                       Navigator.pop(
    //                                                           context);
    //                                                     },
    //                                                     title: Container(
    //                                                         decoration: BoxDecoration(
    //                                                           color:
    //                                                               Colors.grey[100],
    //                                                           borderRadius: const BorderRadius.only(
    //                                                               topLeft: Radius.circular(10),
    //                                                               topRight: Radius.circular(10),
    //                                                               bottomLeft: Radius.circular(10),
    //                                                               bottomRight: Radius.circular(10)),
    //                                                         ),
    //                                                         padding: const EdgeInsets.all(10),
    //                                                         // width: MediaQuery.of(context).size.width,
    //                                                         child: Row(
    //                                                           children: [
    //                                                             Expanded(
    //                                                                 child: Text(
    //                                                               'เสนอราคา: ${areaModels.docno}',
    //                                                               overflow: TextOverflow.ellipsis,
    //                                                               style: const TextStyle(
    //                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                                   //fontWeight: FontWeight.bold,
    //                                                                   fontFamily: Font_.Fonts_T),
    //                                                             ))
    //                                                           ],
    //                                                         ))),
    //                                             ],
    //                                           ),
    //                                         ),
    //                                         actions: <Widget>[
    //                                           Column(
    //                                             children: [
    //                                               const SizedBox(
    //                                                 height: 2.0,
    //                                               ),
    //                                               const Divider(
    //                                                 color:
    //                                                     Colors.grey,
    //                                                 height: 4.0,
    //                                               ),
    //                                               const SizedBox(
    //                                                 height: 2.0,
    //                                               ),
    //                                               Padding(
    //                                                 padding:
    //                                                     const EdgeInsets
    //                                                             .all(
    //                                                         8.0),
    //                                                 child: Row(
    //                                                   mainAxisAlignment:
    //                                                       MainAxisAlignment
    //                                                           .center,
    //                                                   children: [
    //                                                     Padding(
    //                                                       padding:
    //                                                           const EdgeInsets.all(
    //                                                               4.0),
    //                                                       child:
    //                                                           Row(
    //                                                         mainAxisAlignment:
    //                                                             MainAxisAlignment.center,
    //                                                         children: [
    //                                                           Container(
    //                                                             width:
    //                                                                 100,
    //                                                             decoration:
    //                                                                 const BoxDecoration(
    //                                                               color: Colors.redAccent,
    //                                                               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
    //                                                             ),
    //                                                             padding:
    //                                                                 const EdgeInsets.all(5.0),
    //                                                             child:
    //                                                                 TextButton(
    //                                                               onPressed: () => Navigator.pop(context, 'OK'),
    //                                                               child: const Text(
    //                                                                 'ปิด',
    //                                                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                               ),
    //                                                             ),
    //                                                           ),
    //                                                         ],
    //                                                       ),
    //                                                     ),
    //                                                   ],
    //                                                 ),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     );
    //                                   },
    //                                   child: Container(
    //                                     decoration: BoxDecoration(
    //                                       color: (areaFloorplanModelss
    //                                                   ?.id ==
    //                                               areaModels.id)
    //                                           ? areaModels.quantity ==
    //                                                   '1'
    //                                               ? Colors.red[800]!
    //                                                   .withOpacity(
    //                                                       0.5)
    //                                               : areaModels.quantity ==
    //                                                       '2'
    //                                                   ? Colors.blue[800]!
    //                                                       .withOpacity(
    //                                                           0.5)
    //                                                   : areaModels.quantity ==
    //                                                           '3'
    //                                                       ? Colors.purple[800]!.withOpacity(
    //                                                           0.5)
    //                                                       : Colors.green[800]!
    //                                                           .withOpacity(
    //                                                               0.5)
    //                                           : areaModels.quantity ==
    //                                                   '1'
    //                                               ? Colors.red[200]!
    //                                                   .withOpacity(
    //                                                       0.5)
    //                                               : areaModels.quantity ==
    //                                                       '2'
    //                                                   ? Colors
    //                                                       .blue[200]!
    //                                                       .withOpacity(0.5)
    //                                                   : areaModels.quantity == '3'
    //                                                       ? Colors.purple[200]!.withOpacity(0.5)
    //                                                       : Colors.green[200]!.withOpacity(0.5),
    //                                       //  color: (areaFloorplanModelss?.id == areaModels.id) ? Colors.deepPurple[400]!.withOpacity(0.5) : Colors.blue[600]!.withOpacity(0.5),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                         ]),
    //                       )),
    //                 ),
    //               ),
    //             ),
    //             Positioned(
    //               top: 10,
    //               right: 10,
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                   color: Colors.blueGrey.withOpacity(0.5),
    //                   borderRadius: const BorderRadius.only(
    //                     topLeft: Radius.circular(5),
    //                     topRight: Radius.circular(5),
    //                     bottomLeft: Radius.circular(5),
    //                     bottomRight: Radius.circular(5),
    //                   ),
    //                 ),
    //                 padding: const EdgeInsets.all(2.0),
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     IconButton(
    //                       icon: const Icon(
    //                         Icons.zoom_in,
    //                         color: Colors.white,
    //                       ),
    //                       onPressed: _zoomInSVG,
    //                     ),
    //                     IconButton(
    //                       icon: const Icon(
    //                         Icons.zoom_out,
    //                         color: Colors.white,
    //                       ),
    //                       onPressed: _zoomOutSVG,
    //                     ),
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.grey,
    //                         borderRadius: const BorderRadius.only(
    //                           topLeft: Radius.circular(5),
    //                           topRight: Radius.circular(5),
    //                           bottomLeft: Radius.circular(5),
    //                           bottomRight: Radius.circular(5),
    //                         ),
    //                       ),
    //                       child: Text(
    //                         '${MediaQuery.of(context).size.width}',
    //                         overflow: TextOverflow.ellipsis,
    //                         // minFontSize: 1,
    //                         // maxFontSize: 12,
    //                         maxLines: 1,
    //                         textAlign: TextAlign.left,
    //                         style: TextStyle(
    //                           color: Colors.white,
    //                           fontFamily: Font_.Fonts_T,

    //                           //fontSize: 10.0s
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     )
    //   ]);
  }

  Future<Null> read_GC_con_area(int index) async {
    if (areaxConModels.length != 0) {
      setState(() {
        areaxConModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var zoneSubSer = preferences.getString('zoneSubSer');
    var zonesSubName = preferences.getString('zonesSubName');
    var ren = preferences.getString('renTalSer');
    var aser = areaModels[index].ser.toString();

    String url =
        '${MyConstant().domain}/GC_areax_con.php?isAdd=true&ren=$ren&aser=$aser';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //  print(result);
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

/////-------------------------------------------->
  Color getRandomColor(index) {
    final random = Random();
    return areaModels[index].quantity == '1'
        ? datex.isAfter(
                    DateTime.parse('${areaModels[index].ldate} 00:00:00.000')
                        .subtract(Duration(days: open_set_date))) ==
                true
            ? Colors.grey.shade700
            : Colors.red.shade700
        : areaModels[index].quantity == '2'
            ? Colors.blue.shade700
            : areaModels[index].quantity == '3'
                ? Colors.purple.shade700
                : Colors.green.shade700;
  }

  dialog_svg(int index, context) {
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.91),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Center(
            child: Column(
          children: [
            Text(
              ' ${areaModels[index].lncode} (${areaModels[index].ln})',
              style: const TextStyle(
                  color: AdminScafScreen_Color.Colors_Text1_,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T),
            ),
            const SizedBox(
              height: 2.0,
            ),
            Divider(
              color: Colors.grey[100],
              height: 3.0,
            ),
            const SizedBox(
              height: 2.0,
            ),
          ],
        )),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // if (areaModels[index].quantity != '1')
              //   ListTile(
              //       onTap: () async {
              //         if (renTal_lavel <= 2) {
              //           infomation();
              //         } else {
              //           SharedPreferences preferences =
              //               await SharedPreferences.getInstance();
              //           preferences.setString(
              //               'zoneSer', areaModels[index].zser.toString());
              //           preferences.setString(
              //               'zonesName', areaModels[index].zn.toString());
              //           setState(() {
              //             Ser_Body = 1;
              //             a_ln = areaModels[index].lncode;
              //             a_ser = areaModels[index].ser;
              //             a_area = areaModels[index].area;
              //             a_rent = areaModels[index].rent;
              //             a_page = '1';
              //           });
              //           Navigator.pop(context, 'OK');
              //         }
              //       },
              //       title: Container(
              //         decoration: const BoxDecoration(
              //             border: Border(
              //           bottom: BorderSide(
              //             //                    <--- top side
              //             width: 0.5,
              //           ),
              //         )),
              //         padding: const EdgeInsets.all(4.0),
              //         width: 270,
              //         child: Row(
              //           children: [
              //             Expanded(
              //               child: Text(
              //                 'เสนอราคา: ${areaModels[index].lncode} (${areaModels[index].ln})',
              //                 overflow: TextOverflow.ellipsis,
              //                 style: const TextStyle(
              //                     color: PeopleChaoScreen_Color.Colors_Text2_,
              //                     //fontWeight: FontWeight.bold,
              //                     fontFamily: Font_.Fonts_T),
              //               ),
              //             ),
              //             Icon(Iconsax.arrow_circle_right,
              //                 color: getRandomColor(index)),
              //           ],
              //         ),
              //       )),
////////////-------------------------->
              if (areaModels[index].quantity != '1')
                ListTile(
                    onTap: () async {
                      if (renTal_lavel <= 2) {
                        infomation();
                      } else {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'zoneSer', areaModels[index].zser.toString());
                        preferences.setString(
                            'zonesName', areaModels[index].zn.toString());

                        setState(() {
                          Ser_Body = 2;
                          a_ln = areaModels[index].lncode;
                          a_ser = areaModels[index].ser;
                          a_area = areaModels[index].area;
                          a_rent = areaModels[index].rent;
                          a_page = '1';
                        });
                        Navigator.pop(context, 'OK');
                      }
                    },
                    title: Container(
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
                          Expanded(
                            child: Text(
                              'ทำสัญญา: ${areaModels[index].lncode} (${areaModels[index].ln})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Icon(Icons.arrow_circle_right,
                              color: getRandomColor(index)),
                        ],
                      ),
                    )),
////////////-------------------------->
              if (areaModels[index].quantity == '1')
                for (int i = 0; i < areaxConModels.length; i++)
                  ListTile(
                      onTap: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'zoneSer', areaModels[index].zser.toString());
                        preferences.setString(
                            'zonesName', areaModels[index].zn.toString());
                        if (renTal_lavel <= 2) {
                          infomation();
                        } else {
                          setState(() {
                            Ser_Body = 3;
                            Value_stasus = '0';
                            Value_cid = areaxConModels[i].cser;
                            ser_cidtan = '1';
                          });
                          Navigator.pop(context, 'OK');
                        }
                      },
                      // title: '${areaxConModels[i].cser} (${areaxConModels[i].cname})',
                      // textStyle: const TextStyle(
                      //     color: PeopleChaoScreen_Color.Colors_Text2_,
                      //     //fontWeight: FontWeight.bold,
                      //     fontFamily: Font_.Fonts_T),
                      title: Container(
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
                            Expanded(
                              child: Text(
                                '${areaxConModels[i].cser} (${areaxConModels[i].cname})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    //fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Icon(Icons.arrow_circle_right,
                                color: getRandomColor(index)),
                          ],
                        ),
                      )),
              if (areaModels[index].quantity == '1')
                if (areaModels[index].cid != areaModels[index].fid &&
                    areaModels[index].con_st_cid == 'สัญญาปัจจุบัน')
                  ListTile(
                      onTap: () async {
                        if (renTal_lavel <= 2) {
                          infomation();
                        } else {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences.setString(
                              'zoneSer', areaModels[index].zser.toString());
                          preferences.setString(
                              'zonesName', areaModels[index].zn.toString());
                          setState(() {
                            Ser_Body = 3;
                            Value_stasus = areaModels[index].quantity == '1'
                                ? datex.isAfter(DateTime.parse(
                                                '${areaModels[index].ldate} 00:00:00.000')
                                            .subtract(
                                                const Duration(days: 0))) ==
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
                            Value_cid = areaModels[index].fid;
                            ser_cidtan = '1';
                          });
                          add_ContractStore(index);
                          Navigator.pop(context, 'OK');
                        }
                      },
                      // title:
                      //     'เช่าอยู่: ${areaModels[index].cid} (${areaModels[index].cname})',
                      // textStyle: const TextStyle(
                      //     color: PeopleChaoScreen_Color.Colors_Text2_,
                      //     //fontWeight: FontWeight.bold,
                      //     fontFamily: Font_.Fonts_T),
                      title: Container(
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
                            Expanded(
                              child: Text(
                                'สัญญาเดิม: ${areaModels[index].fid} (${areaModels[index].cname})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    //fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Icon(Icons.arrow_circle_right,
                                color: getRandomColor(index)),
                          ],
                        ),
                      )),

////////////-------------------------->
              if (areaModels[index].quantity == '1')
                ListTile(
                    onTap: () async {
                      if (renTal_lavel <= 2) {
                        infomation();
                      } else {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'zoneSer', areaModels[index].zser.toString());
                        preferences.setString(
                            'zonesName', areaModels[index].zn.toString());
                        setState(() {
                          Ser_Body = 3;
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
                          Value_cid = areaModels[index].cid;
                          ser_cidtan = '1';
                        });
                        add_ContractStore(index);
                        Navigator.pop(context, 'OK');
                      }
                    },
                    // title:
                    //     'เช่าอยู่: ${areaModels[index].cid} (${areaModels[index].cname})',
                    // textStyle: const TextStyle(
                    //     color: PeopleChaoScreen_Color.Colors_Text2_,
                    //     //fontWeight: FontWeight.bold,
                    //     fontFamily: Font_.Fonts_T),
                    title: Container(
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
                          Expanded(
                            child: Text(
                              'เช่าอยู่: ${areaModels[index].cid} (${areaModels[index].cname})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Icon(Icons.arrow_circle_right,
                              color: getRandomColor(index)),
                        ],
                      ),
                    )),

////////////-------------------------->
              if (areaModels[index].quantity == '1')
                ListTile(
                    onTap: () async {
                      if (renTal_lavel <= 2) {
                        infomation();
                      } else {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'zoneSer', areaModels[index].zser.toString());
                        preferences.setString(
                            'zonesName', areaModels[index].zn.toString());
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
                        add_ContractStore(index);
                        Navigator.pop(context, 'OK');
                      }
                    },
                    // title:
                    //     'รับชำระ: ${areaModels[index].cid} (${areaModels[index].cname})',
                    // textStyle: const TextStyle(
                    //     color: PeopleChaoScreen_Color.Colors_Text2_,
                    //     //fontWeight: FontWeight.bold,
                    //     fontFamily: Font_.Fonts_T),
                    title: Container(
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
                          Expanded(
                            child: Text(
                              'รับชำระ: ${areaModels[index].cid} (${areaModels[index].cname})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Icon(Icons.arrow_circle_right,
                              color: getRandomColor(index)),
                        ],
                      ),
                    )),
              ////////////-------------------------->
              // if (areaModels[index].quantity == '2')
              //   for (int i = 0; i < areaQuotModels.length; i++)
              //     if (areaQuotModels[i]
              //             .ln_q!
              //             .contains(areaModels[index].lncode.toString()) ==
              //         true)
              //       ListTile(
              //           onTap: () async {
              //             if (renTal_lavel <= 2) {
              //               infomation();
              //             } else {
              //               setState(() {
              //                 Ser_Body = 3;
              //                 Value_stasus = '1';
              //                 Value_cid = areaQuotModels[i].docno;
              //                 ser_cidtan = '2';
              //               });
              //               Navigator.pop(context, 'OK');
              //             }
              //           },
              //           // title: 'เสนอราคา: ${areaQuotModels[i].docno}',
              //           // textStyle: const TextStyle(
              //           //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //           //     //fontWeight: FontWeight.bold,
              //           //     fontFamily: Font_.Fonts_T),
              //           title: Container(
              //             decoration: BoxDecoration(
              //                 border: Border(
              //               bottom: BorderSide(
              //                 //                    <--- top side
              //                 color: Colors.grey,
              //                 width: 0.5,
              //               ),
              //             )),
              //             padding: const EdgeInsets.all(4.0),
              //             width: 270,
              //             child: Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     'เสนอราคา: ${areaQuotModels[i].docno}',
              //                     overflow: TextOverflow.ellipsis,
              //                     style: const TextStyle(
              //                         color:
              //                             PeopleChaoScreen_Color.Colors_Text2_,
              //                         //fontWeight: FontWeight.bold,
              //                         fontFamily: Font_.Fonts_T),
              //                   ),
              //                 ),
              //                 Icon(Iconsax.arrow_circle_right,
              //                     color: getRandomColor(index)),
              //               ],
              //             ),
              //           )),
              ////////////-------------------------->
              // if (areaModels[index].quantity == '3')
              //   // for (int i = 0; i < areaQuotModels.length; i++)
              //   for (int i = 0; i < areaQuotModels.length; i++)
              //     if (areaQuotModels[i]
              //             .ln_q!
              //             .contains(areaModels[index].lncode.toString()) ==
              //         true)
              //       ListTile(
              //           onTap: () async {
              //             if (renTal_lavel <= 2) {
              //               infomation();
              //             } else {
              //               setState(() {
              //                 Ser_Body = 3;
              //                 Value_stasus = '1';
              //                 Value_cid = areaQuotModels[i].docno;
              //                 ser_cidtan = '2';
              //               });
              //               Navigator.pop(context, 'OK');
              //             }
              //           },
              //           // title: 'เสนอราคา: (มัดจำ) ${areaQuotModels[i].docno}',
              //           // textStyle: const TextStyle(
              //           //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //           //     //fontWeight: FontWeight.bold,
              //           //     fontFamily: Font_.Fonts_T),
              //           title: Container(
              //             decoration: BoxDecoration(
              //                 border: Border(
              //               bottom: BorderSide(
              //                 //                    <--- top side
              //                 color: Colors.grey,
              //                 width: 0.5,
              //               ),
              //             )),
              //             padding: const EdgeInsets.all(4.0),
              //             width: 270,
              //             child: Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(
              //                     'เสนอราคา: (มัดจำ) ${areaQuotModels[i].docno}',
              //                     overflow: TextOverflow.ellipsis,
              //                     style: const TextStyle(
              //                         color:
              //                             PeopleChaoScreen_Color.Colors_Text2_,
              //                         //fontWeight: FontWeight.bold,
              //                         fontFamily: Font_.Fonts_T),
              //                   ),
              //                 ),
              //                 Icon(Iconsax.arrow_circle_right,
              //                     color: getRandomColor(index)),
              //               ],
              //             ),
              //           )),
            ],
          ),
        ),
        actions: <Widget>[
          Column(
            children: [
              const SizedBox(
                height: 2.0,
              ),
              const Divider(
                color: Colors.grey,
                height: 4.0,
              ),
              const SizedBox(
                height: 2.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(5.0),
                            child: TextButton(
                              onPressed: () async {
                                setState(() {
                                  areaFloorplanModelss = null;
                                });

                                Navigator.pop(context, 'OK');
                              },
                              child: const Text(
                                'ปิด',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenu? menu;
  maxColumn2(int index, context) async {
    await red_Trans_c_maintenance('${areaModels[index].ser}');
    menu = PopupMenu(
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
            itemWidth: 330,
            backgroundColor: Color.fromARGB(255, 252, 251, 251),
            type: MenuType.list,
            lineColor: Colors.greenAccent,
            maxColumn: 10),
        items: [
          PopUpMenuItem(
            image: Container(
              padding: const EdgeInsets.all(2.0),
              width: 290,
              child: Center(
                child: InkWell(
                  onTap: () {},
                  child: IconStepper(
                    activeStepBorderColor: Colors.deepPurple[200],
                    // (areaModels[index].mainten.toString() == '2')
                    //     ? Colors.orange[600]
                    //     : Colors.grey.shade300,
                    activeStepColor: Colors.deepPurple[200],
                    // (areaModels[index].mainten.toString() == '2')
                    //     ? Colors.orange[600]
                    //     : Colors.red[600],
                    alignment: Alignment.center,
                    enableNextPreviousButtons: false,
                    enableStepTapping: false,
                    icons: [
                      Icon(
                        Icons.filter_1,
                        // color: (areaModels[index].mainten.toString() == '2') 106,782.79
                        //     ? Colors.orange[600]
                        //     : null,
                        // size: 16,
                      ),
                      Icon(
                        Icons.filter_2,
                        // size: 16,
                      ),
                      Icon(
                        Icons.beenhere,
                        // size: 16,lส
                      ),
                    ],

                    // activeStep property set to activeStep variable defined above.
                    activeStep:
                        (areaModels[index].mainten.toString() == '2') ? 1 : 0,

                    // This ensures step-tapping updates the activeStep.
                    // onStepReached: (index) {},
                  ),
                ),
              ),
            ),
          ),
          PopUpMenuItem(
            image: Container(
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  //                    <--- top side
                  width: 0.5,
                ),
              )),
              padding: const EdgeInsets.all(2.0),
              width: 290,
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Translate.TranslateAndSetText(
                      ' รอดำเนินการ',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.center,
                      FontWeight.w500,
                      Font_.Fonts_T,
                      14,
                      1),
                  Translate.TranslateAndSetText(
                      ' กำลังดำเนินการ',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.center,
                      FontWeight.w500,
                      Font_.Fonts_T,
                      14,
                      1),
                  Translate.TranslateAndSetText(
                      'เสร็จสิ้น',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.center,
                      FontWeight.w500,
                      Font_.Fonts_T,
                      14,
                      1),
                ],
              ),
            ),
          ),
          PopUpMenuItem(
            textAlign: TextAlign.start,
            image: Container(
              decoration: BoxDecoration(
                color: getRandomColor(index).withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.all(2.0),
              width: 270,
              // height: 100,
              child: InkWell(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Translate.TranslateAndSetText(
                        'วันที่แจ้งซ่อม : ',
                        PeopleChaoScreen_Color.Colors_Text2_,
                        TextAlign.center,
                        FontWeight.w500,
                        Font_.Fonts_T,
                        14,
                        1),
                    Expanded(
                      child: Text(
                        (areaModels[index].date_note1 == null ||
                                areaModels[index].date_note1! == '0000-00-00')
                            ? '-'
                            : '${DateFormat('dd-MM').format(DateTime.parse('${areaModels[index].date_note1} 00:00:00'))}-${DateTime.parse('${areaModels[index].date_note1} 00:00:00').year + 0}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            //fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopUpMenuItem(
            textAlign: TextAlign.start,
            image: Container(
              decoration: BoxDecoration(
                  // borderRadius: BorderRadius.all(Radius.circular(6)),
                  // border: Border.all(color: Colors.grey, width: 0.3),
                  ),
              padding: const EdgeInsets.all(2.0),
              width: 270,
              // height: 100,
              child: InkWell(
                onTap: null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, color: getRandomColor(index)),
                    Expanded(
                      child: Text(
                        ' : ${areaModels[index].mainten_note1}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            //fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (areaModels[index].mainten.toString() == '2')
            PopUpMenuItem(
              textAlign: TextAlign.start,
              image: InkWell(
                onTap: () async {},
                child: Container(
                  decoration: BoxDecoration(
                    color: getRandomColor(index).withOpacity(0.3),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  width: 270,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Translate.TranslateAndSetText(
                          'วันที่เริ่มดำเนินการ : ',
                          PeopleChaoScreen_Color.Colors_Text2_,
                          TextAlign.center,
                          FontWeight.w500,
                          Font_.Fonts_T,
                          14,
                          1),
                      Expanded(
                        child: Text(
                          (areaModels[index].date_note2 == null ||
                                  areaModels[index].date_note2! == '0000-00-00')
                              ? '-'
                              : '${DateFormat('dd-MM').format(DateTime.parse('${areaModels[index].date_note2} 00:00:00'))}-${DateTime.parse('${areaModels[index].date_note2} 00:00:00').year + 0}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text2_,
                              //fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (areaModels[index].mainten.toString() == '2')
            PopUpMenuItem(
              textAlign: TextAlign.start,
              image: Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                    //                    <--- top side
                    width: 0.5,
                  ),
                )),
                padding: const EdgeInsets.all(2.0),
                width: 270,
                // height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, color: getRandomColor(index)),
                    Expanded(
                      child: Text(
                        (areaModels[index].date_note2.toString() ==
                                    '0000-00-00' ||
                                areaModels[index].date_note2 == null)
                            ? ' : -'
                            : ' : ${areaModels[index].mainten_note2}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: const TextStyle(
                            fontSize: 13,
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            //fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (maintenanceModels.length > 1)
            PopUpMenuItem(
              textAlign: TextAlign.center,
              image: SizedBox(
                width: 270,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[400],
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.all(0.0),
                    width: 125,
                    height: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () async {
                          menu!.dismiss();
                          final data = await SideSheet.right(
                              width: 350,
                              body: Container(
                                height: MediaQuery.of(context).size.height,
                                color: AppbackgroundColor.Abg_Colors,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
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
                                                  const EdgeInsets.all(4.0),
                                              child: const Icon(
                                                Icons.arrow_back,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              '${areaModels[index].lncode} (${areaModels[index].ln})',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: SingupScreen_Color
                                                      .Colors_Text1_,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(10, 4, 2, 2),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          ' # ข้อมูลการแจ้งซ่อม',
                                          style: TextStyle(
                                              color: SingupScreen_Color
                                                  .Colors_Text1_,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: FontWeight_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                          padding: const EdgeInsets.all(0.0),
                                          child: ListView.builder(
                                              padding: const EdgeInsets.all(8),
                                              itemCount:
                                                  maintenanceModels.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index_sub) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          2, 4, 2, 4),
                                                  child: Card(
                                                      color: Colors.grey[50],
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: AutoSizeText(
                                                                  'ผู้แจ้ง : ${maintenanceModels[index_sub].sname}',
                                                                  maxLines: 1,
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      20,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  softWrap:
                                                                      false,
                                                                  style: TextStyle(
                                                                      // fontSize: 20,
                                                                      color: SingupScreen_Color.Colors_Text1_,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontFamily: FontWeight_.Fonts_T)),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            // width: 290,
                                                            child: Center(
                                                              child: InkWell(
                                                                onTap: () {},
                                                                child:
                                                                    IconStepper(
                                                                  activeStepBorderColor:
                                                                      Colors.deepPurple[
                                                                          200],
                                                                  // (areaModels[index].mainten.toString() == '2')
                                                                  //     ? Colors.orange[600]
                                                                  //     : Colors.grey.shade300,
                                                                  activeStepColor:
                                                                      Colors.deepPurple[
                                                                          200],
                                                                  // (areaModels[index].mainten.toString() == '2')
                                                                  //     ? Colors.orange[600]
                                                                  //     : Colors.red[600],
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  enableNextPreviousButtons:
                                                                      false,
                                                                  enableStepTapping:
                                                                      false,
                                                                  icons: [
                                                                    Icon(
                                                                      Icons
                                                                          .filter_1,
                                                                      // color: (areaModels[index].mainten.toString() == '2')
                                                                      //     ? Colors.orange[600]
                                                                      //     : null,
                                                                      // size: 16,
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .filter_2,
                                                                      // size: 16,
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .beenhere,
                                                                      // size: 16,
                                                                    ),
                                                                  ],

                                                                  // activeStep property set to activeStep variable defined above.
                                                                  activeStep:
                                                                      (maintenanceModels[index_sub].mst.toString() ==
                                                                              '2')
                                                                          ? 1
                                                                          : 0,

                                                                  // This ensures step-tapping updates the activeStep.
                                                                  // onStepReached: (index) {},
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  //                    <--- top side
                                                                  width: 0.5,
                                                                ),
                                                              )),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              // width: 290,
                                                              height: 40,
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Translate.TranslateAndSetText(
                                                                      ' รอดำเนินการ',
                                                                      PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .w500,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  Translate.TranslateAndSetText(
                                                                      ' กำลังดำเนินการ',
                                                                      PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .w500,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                  Translate.TranslateAndSetText(
                                                                      'เสร็จสิ้น',
                                                                      PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      TextAlign
                                                                          .center,
                                                                      FontWeight
                                                                          .w500,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: getRandomColor(
                                                                          index)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                // width: 270,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Translate.TranslateAndSetText(
                                                                        'วันที่แจ้งซ่อม : ',
                                                                        PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .w500,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        (maintenanceModels[index_sub].mdate == null ||
                                                                                maintenanceModels[index_sub].mdate! == '0000-00-00')
                                                                            ? '-'
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${maintenanceModels[index_sub].mdate} 00:00:00'))}-${DateTime.parse('${maintenanceModels[index_sub].mdate} 00:00:00').year + 0}',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  // borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                  // border: Border.all(color: Colors.grey, width: 0.3),
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              // width: 270,
                                                              // height: 100,
                                                              child: InkWell(
                                                                onTap: null,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .note,
                                                                        color: getRandomColor(
                                                                            index)),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        ' : ${maintenanceModels[index_sub].mdescr}',
                                                                        maxLines:
                                                                            3,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            fontSize: 13,
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          if (maintenanceModels[
                                                                      index_sub]
                                                                  .mst
                                                                  .toString() ==
                                                              '2')
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: getRandomColor(
                                                                          index)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                // width: 270,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Translate.TranslateAndSetText(
                                                                        'วันที่เริ่มดำเนินการ : ',
                                                                        PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        TextAlign
                                                                            .center,
                                                                        FontWeight
                                                                            .w500,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        (maintenanceModels[index_sub].rdate == null ||
                                                                                maintenanceModels[index_sub].rdate! == '0000-00-00')
                                                                            ? '-'
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${maintenanceModels[index_sub].rdate} 00:00:00'))}-${DateTime.parse('${maintenanceModels[index_sub].rdate} 00:00:00').year + 0}',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          if (maintenanceModels[
                                                                      index_sub]
                                                                  .mst
                                                                  .toString() ==
                                                              '2')
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Container(
                                                                decoration:
                                                                    const BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                  bottom:
                                                                      BorderSide(
                                                                    //                    <--- top side
                                                                    width: 0.5,
                                                                  ),
                                                                )),
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                // width: 270,
                                                                // height: 200,
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .note,
                                                                        color: getRandomColor(
                                                                            index)),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        (maintenanceModels[index_sub].rdate.toString() == '0000-00-00' ||
                                                                                maintenanceModels[index_sub].rdate == null)
                                                                            ? ' : -'
                                                                            : ' : ${maintenanceModels[index_sub].rdescr}',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            3,
                                                                        style: const TextStyle(
                                                                            fontSize: 13,
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      )),
                                                );
                                              })),
                                    ),
                                    Container(
                                      // height: 40,
                                      decoration: BoxDecoration(
                                        color: getRandomColor(index)
                                            .withOpacity(0.7),
                                        // AppBarColors.ABar_Colors,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                      ),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Text(
                                            '',
                                            // '© 2023-2024  Dzentric Co.,Ltd. All Rights Reserved',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: SingupScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T,
                                                // fontWeight: FontWeight.bold,
                                                fontSize: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              context: context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Translate.TranslateAndSetText(
                                  'ดูข้อมูลเพิ่มเติม',
                                  Colors.white,
                                  TextAlign.center,
                                  FontWeight.w400,
                                  Font_.Fonts_T,
                                  14,
                                  1),
                              Icon(
                                Icons.arrow_circle_right,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ]);
    menu!.show(widgetKey: _btnKeys[index]);
  }

  maxColumn_Approved(int index, context, reques_tstatus, requestStepx) {
    menu = PopupMenu(
      context: context,

      config: MenuConfig(
          border: BorderConfig(
            color: Color.fromARGB(255, 56, 56, 56),
          ),
          itemWidth: 300,
          backgroundColor: Color.fromARGB(255, 252, 251, 251),
          type: MenuType.list,
          lineColor: Colors.greenAccent,
          maxColumn: 10),
      items: [
        PopUpMenuItem(
          image: InkWell(
            // onTap: () async {
            //   // menu!.dismiss();
            //   // Future.delayed(const Duration(milliseconds: 300), () {
            //   //   maxColumn2(index, context);
            //   // });
            // },
            child: Container(
              // decoration: BoxDecoration(
              //   color: Colors.blue.withOpacity(0.3),
              //   borderRadius: const BorderRadius.only(
              //     topLeft: Radius.circular(8),
              //     topRight: Radius.circular(8),
              //     bottomLeft: Radius.circular(8),
              //     bottomRight: Radius.circular(8),
              //   ),
              //   border: Border.all(color: Colors.grey, width: 1),

              //   //     border: Border(
              //   //   bottom: BorderSide(
              //   //     //                    <--- top side
              //   //     width: 0.5,
              //   //   ),
              //   // )
              // ),
              padding: const EdgeInsets.all(4.0),
              width: 270,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications),
                  Text(
                    ' ใบอนุญาต',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        //fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T),
                  ),
                  // Text(
                  //   '(Step: $requestStepx)',
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(
                  //       color: PeopleChaoScreen_Color.Colors_Text2_,
                  //       //fontWeight: FontWeight.bold,
                  //       fontFamily: Font_.Fonts_T),
                  // ),
                  // Icon(Iconsax.arrow_circle_right,
                  //     color: getRandomColor(index)),
                ],
              ),
            ),
          ),
        ),
        PopUpMenuItem(
          image: InkWell(
            onTap: (requestStepx.toString() == '4' ||
                    requestStepx.toString() == '5')
                ? () async {
                    menu!.dismiss();
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    String? _route = preferences.getString('route');
                    MaterialPageRoute materialPageRoute = MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AdminScafScreen(route: 'ใบอนุญาต'));
                    Navigator.pushAndRemoveUntil(
                        context, materialPageRoute, (route) => false);
                  }
                : () async {
                    if (renTal_lavel <= 2) {
                      menu!.dismiss();
                      infomation();
                    } else {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());

                      setState(() {
                        Ser_Body = 2;
                        a_ln = areaModels[index].lncode;
                        a_ser = areaModels[index].ser;
                        a_area = areaModels[index].area;
                        a_rent = areaModels[index].rent;
                        a_page = '1';
                      });
                      menu!.dismiss();
                    }
                  },
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  //                    <--- top side
                  width: 0.5,
                ),
              )),
              padding: const EdgeInsets.all(4.0),
              width: 270,
              child: Row(
                children: [
                  Translate.TranslateAndSetText(
                      'สถานะ : ',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.center,
                      FontWeight.w500,
                      Font_.Fonts_T,
                      14,
                      1),
                  Expanded(
                    child: Text(
                      ' $reques_tstatus',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          //fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                  Icon(Icons.arrow_circle_right, color: getRandomColor(index)),
                ],
              ),
            ),
          ),
        ),
        // PopUpMenuItem(
        //   image: InkWell(
        //     onTap: () async {
        //       // menu!.dismiss();
        //       // Future.delayed(const Duration(milliseconds: 300), () {
        //       //   maxColumn2(index, context);
        //       // });
        //     },
        //     child: Container(
        //       decoration: const BoxDecoration(
        //           border: Border(
        //         bottom: BorderSide(
        //           //                    <--- top side
        //           width: 0.5,
        //         ),
        //       )),
        //       padding: const EdgeInsets.all(4.0),
        //       width: 270,
        //       child: Row(
        //         children: [
        //           Translate.TranslateAndSetText(
        //               'แจ้งซ่อม: ',
        //               PeopleChaoScreen_Color.Colors_Text2_,
        //               TextAlign.center,
        //               FontWeight.w500,
        //               Font_.Fonts_T,
        //               14,
        //               1),
        //           Expanded(
        //             child: Text(
        //               ' (กำลังดำเนินการ)',
        //               overflow: TextOverflow.ellipsis,
        //               style: const TextStyle(
        //                   color: PeopleChaoScreen_Color.Colors_Text2_,
        //                   //fontWeight: FontWeight.bold,
        //                   fontFamily: Font_.Fonts_T),
        //             ),
        //           ),
        //           Icon(Iconsax.arrow_circle_right,
        //               color: getRandomColor(index)),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],

      // onDismiss: onDismiss,
    );
    menu!.show(widgetKey: _btnKeys[index]);

    // Future.delayed(const Duration(seconds: 1), () {

    //   menu!.dismiss();
    // });
  }

  maxColumn(int index, context) {
    menu = PopupMenu(
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
          backgroundColor: Color.fromARGB(255, 252, 251, 251),
          type: MenuType.list,
          lineColor: Colors.greenAccent,
          maxColumn: 10),
      items: [
        if (areaModels[index].mainten.toString() == '1' ||
            areaModels[index].mainten.toString() == '2')
          PopUpMenuItem(
            image: InkWell(
              onTap: () async {
                menu!.dismiss();
                Future.delayed(const Duration(milliseconds: 300), () {
                  maxColumn2(index, context);
                });

                // PanaraInfoDialog.showAnimatedGrow(
                //   context,
                //   title: "Oops",
                //   message: "กรุณากรอกข้อมูลให้ครบถ้วน...!",
                //   buttonText: "รับทราบ",
                //   onTapDismiss: () async {
                //     Navigator.pop(context);
                //   },
                //   panaraDialogType: PanaraDialogType.warning,
                //   barrierDismissible:
                //       false, // optional parameter (default is true)
                // );
              },
              child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(
                    //                    <--- top side
                    width: 0.5,
                  ),
                )),
                padding: const EdgeInsets.all(4.0),
                width: 270,
                child: Row(
                  children: [
                    Translate.TranslateAndSetText(
                        'แจ้งซ่อม: ',
                        PeopleChaoScreen_Color.Colors_Text2_,
                        TextAlign.center,
                        FontWeight.w500,
                        Font_.Fonts_T,
                        14,
                        1),
                    Expanded(
                      child: Text(
                        areaModels[index].mainten.toString() == '1'
                            ? ' (รอดำเนินการ)'
                            : ' (กำลังดำเนินการ)',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            //fontWeight: FontWeight.bold,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                    Icon(Icons.arrow_circle_right,
                        color: getRandomColor(index)),
                  ],
                ),
              ),
            ),
          ),
        // if (areaModels[index].quantity == '1' &&
        //     areaModels[index].docno != null)
        //   PopUpMenuItem(
        //       // title:
        //       //     'เสนอราคา: ${areaModels[index].lncode} (${areaModels[index].ln})',
        //       // textStyle: const TextStyle(
        //       //     color: PeopleChaoScreen_Color.Colors_Text2_,
        //       //     //fontWeight: FontWeight.bold,
        //       //     fontFamily: Font_.Fonts_T),
        //       image: InkWell(
        //           onTap: () async {
        //             if (renTal_lavel <= 2) {
        //               menu!.dismiss();
        //               infomation();
        //             } else {
        //               setState(() {
        //                 Ser_Body = 3;
        //                 Value_stasus = '1';
        //                 Value_cid = areaModels[index].docno;
        //                 ser_cidtan = '2';
        //               });
        //               menu!.dismiss();
        //             }
        //             // if (renTal_lavel <= 2) {
        //             //   menu!.dismiss();
        //             //   infomation();
        //             // } else {
        //             //   SharedPreferences preferences =
        //             //       await SharedPreferences.getInstance();
        //             //   preferences.setString(
        //             //       'zoneSer', areaModels[index].zser.toString());
        //             //   preferences.setString(
        //             //       'zonesName', areaModels[index].zn.toString());
        //             //   setState(() {
        //             //     Ser_Body = 1;
        //             //     a_ln = areaModels[index].lncode;
        //             //     a_ser = areaModels[index].ser;
        //             //     a_area = areaModels[index].area;
        //             //     a_rent = areaModels[index].rent;
        //             //     a_page = '1';
        //             //   });
        //             //   menu!.dismiss();
        //             // }
        //             // Navigator.pop(context);
        //           },
        //           child: Container(
        //             decoration: const BoxDecoration(
        //                 border: Border(
        //               bottom: BorderSide(
        //                 //                    <--- top side
        //                 width: 0.5,
        //               ),
        //             )),
        //             padding: const EdgeInsets.all(4.0),
        //             width: 270,
        //             child: Row(
        //               children: [
        //                 Translate.TranslateAndSetText(
        //                     'เสนอราคา: ',
        //                     PeopleChaoScreen_Color.Colors_Text2_,
        //                     TextAlign.center,
        //                     FontWeight.w500,
        //                     Font_.Fonts_T,
        //                     14,
        //                     1),
        //                 Expanded(
        //                   child: Text(
        //                     ' ${areaModels[index].docno} (${areaModels[index].sname_q})',
        //                     overflow: TextOverflow.ellipsis,
        //                     style: const TextStyle(
        //                         color: PeopleChaoScreen_Color.Colors_Text2_,
        //                         //fontWeight: FontWeight.bold,
        //                         fontFamily: Font_.Fonts_T),
        //                   ),
        //                 ),
        //                 Icon(Iconsax.arrow_circle_right,
        //                     color: getRandomColor(index)),
        //               ],
        //             ),
        //           ))),
        // if (areaModels[index].quantity != '1')
        //   PopUpMenuItem(
        //       // title:
        //       //     'เสนอราคา: ${areaModels[index].lncode} (${areaModels[index].ln})',
        //       // textStyle: const TextStyle(
        //       //     color: PeopleChaoScreen_Color.Colors_Text2_,
        //       //     //fontWeight: FontWeight.bold,
        //       //     fontFamily: Font_.Fonts_T),
        //       image: InkWell(
        //           onTap: () async {
        //             if (renTal_lavel <= 2) {
        //               menu!.dismiss();
        //               infomation();
        //             } else {
        //               SharedPreferences preferences =
        //                   await SharedPreferences.getInstance();
        //               preferences.setString(
        //                   'zoneSer', areaModels[index].zser.toString());
        //               preferences.setString(
        //                   'zonesName', areaModels[index].zn.toString());
        //               setState(() {
        //                 Ser_Body = 1;
        //                 a_ln = areaModels[index].lncode;
        //                 a_ser = areaModels[index].ser;
        //                 a_area = areaModels[index].area;
        //                 a_rent = areaModels[index].rent;
        //                 a_page = '1';
        //               });
        //               menu!.dismiss();
        //             }
        //             // Navigator.pop(context);
        //           },
        //           child: Container(
        //             decoration: const BoxDecoration(
        //                 border: Border(
        //               bottom: BorderSide(
        //                 //                    <--- top side
        //                 width: 0.5,
        //               ),
        //             )),
        //             padding: const EdgeInsets.all(4.0),
        //             width: 270,
        //             child: Row(
        //               children: [
        //                 Translate.TranslateAndSetText(
        //                     'เสนอราคา: ',
        //                     PeopleChaoScreen_Color.Colors_Text2_,
        //                     TextAlign.center,
        //                     FontWeight.w500,
        //                     Font_.Fonts_T,
        //                     14,
        //                     1),
        //                 Expanded(
        //                   child: Text(
        //                     ' ${areaModels[index].lncode} (${areaModels[index].ln})',
        //                     overflow: TextOverflow.ellipsis,
        //                     style: const TextStyle(
        //                         color: PeopleChaoScreen_Color.Colors_Text2_,
        //                         //fontWeight: FontWeight.bold,
        //                         fontFamily: Font_.Fonts_T),
        //                   ),
        //                 ),
        //                 Icon(Iconsax.arrow_circle_right,
        //                     color: getRandomColor(index)),
        //               ],
        //             ),
        //           ))),
        // if (areaModels[index].quantity == '1' &&
        //     areaModels[index].cc_date != null &&
        //     areaModels[index].cc_date.toString() != "0000-00-00")
        //   PopUpMenuItem(
        //       // title:
        //       //     'เสนอราคา: ${areaModels[index].lncode} (${areaModels[index].ln})',
        //       // textStyle: const TextStyle(
        //       //     color: PeopleChaoScreen_Color.Colors_Text2_,
        //       //     //fontWeight: FontWeight.bold,
        //       //     fontFamily: Font_.Fonts_T),
        //       image: InkWell(
        //           onTap: () async {
        //             if (renTal_lavel <= 2) {
        //               menu!.dismiss();
        //               infomation();
        //             } else {
        //               SharedPreferences preferences =
        //                   await SharedPreferences.getInstance();
        //               preferences.setString(
        //                   'zoneSer', areaModels[index].zser.toString());
        //               preferences.setString(
        //                   'zonesName', areaModels[index].zn.toString());
        //               setState(() {
        //                 Ser_Body = 1;
        //                 a_ln = areaModels[index].lncode;
        //                 a_ser = areaModels[index].ser;
        //                 a_area = areaModels[index].area;
        //                 a_rent = areaModels[index].rent;
        //                 a_page = '1';
        //               });
        //               menu!.dismiss();
        //             }
        //             // Navigator.pop(context);
        //           },
        //           child: Container(
        //             decoration: const BoxDecoration(
        //                 border: Border(
        //               bottom: BorderSide(
        //                 //                    <--- top side
        //                 width: 0.5,
        //               ),
        //             )),
        //             padding: const EdgeInsets.all(4.0),
        //             width: 270,
        //             child: Row(
        //               children: [
        //                 Translate.TranslateAndSetText(
        //                     'เสนอราคา: ',
        //                     PeopleChaoScreen_Color.Colors_Text2_,
        //                     TextAlign.center,
        //                     FontWeight.w500,
        //                     Font_.Fonts_T,
        //                     14,
        //                     1),
        //                 Expanded(
        //                   child: Text(
        //                     '  ${areaModels[index].lncode} (${areaModels[index].ln})',
        //                     overflow: TextOverflow.ellipsis,
        //                     style: const TextStyle(
        //                         color: PeopleChaoScreen_Color.Colors_Text2_,
        //                         //fontWeight: FontWeight.bold,
        //                         fontFamily: Font_.Fonts_T),
        //                   ),
        //                 ),
        //                 Icon(Iconsax.arrow_circle_right,
        //                     color: getRandomColor(index)),
        //               ],
        //             ),
        //           ))),

////////////-------------------------->
        ///
        if (areaModels[index].quantity != '1')
          PopUpMenuItem(
              // title:
              //     'ทำสัญญา: ${areaModels[index].lncode} (${areaModels[index].ln})',
              // textStyle: const TextStyle(
              //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //     //fontWeight: FontWeight.bold,
              //     fontFamily: Font_.Fonts_T),
              image: InkWell(
                  onTap: () async {
                    if (renTal_lavel <= 2) {
                      menu!.dismiss();
                      infomation();
                    } else {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());

                      setState(() {
                        Ser_Body = 2;
                        a_ln = areaModels[index].lncode;
                        a_ser = areaModels[index].ser;
                        a_area = areaModels[index].area;
                        a_rent = areaModels[index].rent;
                        a_page = '1';
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
                            'ทำสัญญา: ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            14,
                            1),
                        Expanded(
                          child: Text(
                            ' ${areaModels[index].lncode} (${areaModels[index].ln})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Icon(Icons.arrow_circle_right,
                            color: getRandomColor(index)),
                      ],
                    ),
                  ))),

        if (areaModels[index].quantity == '1' &&
            areaModels[index].cc_date != null &&
            areaModels[index].cc_date.toString() != "0000-00-00")
          PopUpMenuItem(
              // title:
              //     'ทำสัญญา: ${areaModels[index].lncode} (${areaModels[index].ln})',
              // textStyle: const TextStyle(
              //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //     //fontWeight: FontWeight.bold,
              //     fontFamily: Font_.Fonts_T),
              image: InkWell(
                  onTap: () async {
                    if (renTal_lavel <= 2) {
                      menu!.dismiss();
                      infomation();
                    } else {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());

                      setState(() {
                        Ser_Body = 2;
                        a_ln = areaModels[index].lncode;
                        a_ser = areaModels[index].ser;
                        a_area = areaModels[index].area;
                        a_rent = areaModels[index].rent;
                        a_page = '1';
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
                            'ทำสัญญา: ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            14,
                            1),
                        Expanded(
                          child: Text(
                            ' ${areaModels[index].lncode} (${areaModels[index].ln})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Icon(Icons.arrow_circle_right,
                            color: getRandomColor(index)),
                      ],
                    ),
                  ))),
////////////-------------------------->
        if (areaModels[index].quantity == '1')
          for (int i = 0; i < areaxConModels.length; i++)
            PopUpMenuItem(
                // title: '${areaxConModels[i].cser} (${areaxConModels[i].cname})',
                // textStyle: const TextStyle(
                //     color: PeopleChaoScreen_Color.Colors_Text2_,
                //     //fontWeight: FontWeight.bold,
                //     fontFamily: Font_.Fonts_T),
                image: InkWell(
                    onTap: () async {
                      if (renTal_lavel <= 2) {
                        menu!.dismiss();
                        infomation();
                      } else {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'zoneSer', areaModels[index].zser.toString());
                        preferences.setString(
                            'zonesName', areaModels[index].zn.toString());
                        setState(() {
                          Ser_Body = 3;
                          Value_stasus = '0';
                          Value_cid = areaxConModels[i].cser;
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
                          Expanded(
                            child: Text(
                              '${areaxConModels[i].cser} (${areaxConModels[i].cname})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Icon(Icons.arrow_circle_right,
                              color: getRandomColor(index)),
                        ],
                      ),
                    ))),
        if (areaModels[index].quantity == '1')
          if (areaModels[index].cid != areaModels[index].fid &&
              areaModels[index].con_st_cid == 'สัญญาปัจจุบัน')
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
                        infomation();
                      } else {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString(
                            'zoneSer', areaModels[index].zser.toString());
                        preferences.setString(
                            'zonesName', areaModels[index].zn.toString());
                        setState(() {
                          Ser_Body = 3;
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
                          Value_cid = areaModels[index].fid;
                          ser_cidtan = '1';
                        });
                        menu!.dismiss();
                        add_ContractStore(index);
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
                              'สัญญาเดิม: ',
                              PeopleChaoScreen_Color.Colors_Text2_,
                              TextAlign.center,
                              FontWeight.w500,
                              Font_.Fonts_T,
                              14,
                              1),
                          Expanded(
                            child: Text(
                              ' ${areaModels[index].fid} (${areaModels[index].cname})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Icon(Icons.arrow_circle_right,
                              color: getRandomColor(index)),
                        ],
                      ),
                    ))),
////////////-------------------------->
        if (areaModels[index].quantity == '1')
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
                      infomation();
                    } else {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());
                      setState(() {
                        Ser_Body = 3;
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
                        Value_cid = areaModels[index].cid;
                        ser_cidtan = '1';
                      });
                      add_ContractStore(index);
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
                            areaModels[index].scfid == 'N' ? 'N:' : 'เช่าอยู่:',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            14,
                            1),
                        Expanded(
                          child: Text(
                            areaModels[index].scfid == 'N'
                                ? ' ${areaModels[index].cid} (${areaModels[index].cname})'
                                : ' ${areaModels[index].cid} (${areaModels[index].cname})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Icon(Icons.arrow_circle_right,
                            color: getRandomColor(index)),
                      ],
                    ),
                  ))),

////////////-------------------------->
        if (areaModels[index].quantity == '1')
          PopUpMenuItem(
              // title:
              //     'รับชำระ: ${areaModels[index].cid} (${areaModels[index].cname})',
              // textStyle: const TextStyle(
              //     color: PeopleChaoScreen_Color.Colors_Text2_,
              //     //fontWeight: FontWeight.bold,
              //     fontFamily: Font_.Fonts_T),
              image: InkWell(
                  onTap: () async {
                    if (renTal_lavel <= 2) {
                      menu!.dismiss();
                      infomation();
                    } else {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());
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
                      add_ContractStore(index);
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
                            areaModels[index].scfid == 'N' ? 'N:' : 'รับชำระ: ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.w500,
                            Font_.Fonts_T,
                            14,
                            1),
                        Expanded(
                          child: Text(
                            areaModels[index].scfid == 'N'
                                ? ' ${areaModels[index].cid} (${areaModels[index].cname})'
                                : ' ${areaModels[index].cid} (${areaModels[index].cname})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Icon(Icons.arrow_circle_right,
                            color: getRandomColor(index)),
                      ],
                    ),
                  ))),
        ////////////-------------------------->
        // if (areaModels[index].quantity == '2')
        //   for (int i = 0; i < areaQuotModels.length; i++)
        //     if (areaQuotModels[i]
        //             .ln_q!
        //             .contains(areaModels[index].lncode.toString()) ==
        //         true)
        //       PopUpMenuItem(
        //           // title: 'เสนอราคา: ${areaQuotModels[i].docno}',
        //           // textStyle: const TextStyle(
        //           //     color: PeopleChaoScreen_Color.Colors_Text2_,
        //           //     //fontWeight: FontWeight.bold,
        //           //     fontFamily: Font_.Fonts_T),
        //           image: InkWell(
        //               onTap: () async {
        //                 if (renTal_lavel <= 2) {
        //                   menu!.dismiss();
        //                   infomation();
        //                 } else {
        //                   setState(() {
        //                     Ser_Body = 3;
        //                     Value_stasus = '1';
        //                     Value_cid = areaQuotModels[i].docno;
        //                     ser_cidtan = '2';
        //                   });
        //                   menu!.dismiss();
        //                 }
        //                 // Navigator.pop(context);
        //               },
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     border: Border(
        //                   bottom: BorderSide(
        //                     //                    <--- top side
        //                     color: Colors.grey,
        //                     width: 0.5,
        //                   ),
        //                 )),
        //                 padding: const EdgeInsets.all(4.0),
        //                 width: 270,
        //                 child: Row(
        //                   children: [
        //                     Translate.TranslateAndSetText(
        //                         'เสนอราคา: ',
        //                         PeopleChaoScreen_Color.Colors_Text2_,
        //                         TextAlign.center,
        //                         FontWeight.w500,
        //                         Font_.Fonts_T,
        //                         14,
        //                         1),
        //                     Expanded(
        //                       child: Text(
        //                         ' ${areaQuotModels[i].docno}',
        //                         overflow: TextOverflow.ellipsis,
        //                         style: const TextStyle(
        //                             color: PeopleChaoScreen_Color.Colors_Text2_,
        //                             //fontWeight: FontWeight.bold,
        //                             fontFamily: Font_.Fonts_T),
        //                       ),
        //                     ),
        //                     Icon(Iconsax.arrow_circle_right,
        //                         color: getRandomColor(index)),
        //                   ],
        //                 ),
        //               ))),
        ////////////-------------------------->
        // if (areaModels[index].quantity == '3')
        //   // for (int i = 0; i < areaQuotModels.length; i++)
        //   for (int i = 0; i < areaQuotModels.length; i++)
        //     if (areaQuotModels[i]
        //             .ln_q!
        //             .contains(areaModels[index].lncode.toString()) ==
        //         true)
        //       PopUpMenuItem(
        //           // title: 'เสนอราคา: (มัดจำ) ${areaQuotModels[i].docno}',
        //           // textStyle: const TextStyle(
        //           //     color: PeopleChaoScreen_Color.Colors_Text2_,
        //           //     //fontWeight: FontWeight.bold,
        //           //     fontFamily: Font_.Fonts_T),
        //           image: InkWell(
        //               onTap: () async {
        //                 if (renTal_lavel <= 2) {
        //                   menu!.dismiss();
        //                   infomation();
        //                 } else {
        //                   setState(() {
        //                     Ser_Body = 3;
        //                     Value_stasus = '1';
        //                     Value_cid = areaQuotModels[i].docno;
        //                     ser_cidtan = '2';
        //                   });
        //                   menu!.dismiss();
        //                 }
        //                 // Navigator.pop(context);
        //               },
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     border: Border(
        //                   bottom: BorderSide(
        //                     //                    <--- top side
        //                     color: Colors.grey,
        //                     width: 0.5,
        //                   ),
        //                 )),
        //                 padding: const EdgeInsets.all(4.0),
        //                 width: 270,
        //                 child: Row(
        //                   children: [
        //                     Translate.TranslateAndSetText(
        //                         'เสนอราคา: (มัดจำ) ',
        //                         PeopleChaoScreen_Color.Colors_Text2_,
        //                         TextAlign.center,
        //                         FontWeight.w500,
        //                         Font_.Fonts_T,
        //                         14,
        //                         1),
        //                     Expanded(
        //                       child: Text(
        //                         ' ${areaQuotModels[i].docno}',
        //                         overflow: TextOverflow.ellipsis,
        //                         style: const TextStyle(
        //                             color: PeopleChaoScreen_Color.Colors_Text2_,
        //                             //fontWeight: FontWeight.bold,
        //                             fontFamily: Font_.Fonts_T),
        //                       ),
        //                     ),
        //                     Icon(Iconsax.arrow_circle_right,
        //                         color: getRandomColor(index)),
        //                   ],
        //                 ),
        //               ))),

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
                      infomation();
                    } else {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());
                      setState(() {
                        Ser_Body = 3;
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
                      add_ContractStore(index);
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
                        Icon(Icons.arrow_back, color: getRandomColor(index)),
                      ],
                    ),
                  ))),
      ],

      // onDismiss: onDismiss,
    );
    menu!.show(widgetKey: _btnKeys[index]);

    // Future.delayed(const Duration(seconds: 1), () {

    //   menu!.dismiss();
    // });
  }

  void showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Container(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    showDialog(
      barrierDismissible:
          false, // Set to true if you want to allow dismissing the dialog by tapping outside
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget createCard(int index, context) {
    return (_btnKeys.length == 0)
        ? SizedBox()
        : Stack(
            children: [
              Card(
                  color: areaModels[index].quantity == '1'
                      ? (areaModels[index].ldate == null)
                          ? Colors.red.shade200
                          : datex.isAfter(DateTime.parse(
                                          '${areaModels[index].ldate} 00:00:00.000')
                                      .subtract(
                                          Duration(days: open_set_date))) ==
                                  true //datex
                              ? datex.isAfter(DateTime.parse(
                                              '${areaModels[index].ldate} 00:00:00.000')
                                          .subtract(Duration(days: 0))) ==
                                      false
                                  ? Colors.orange.shade200
                                  : Colors.grey.shade200
                              : Colors.red.shade200
                      : areaModels[index].quantity == '2'
                          ? Colors.blue.shade200
                          : areaModels[index].quantity == '3'
                              ? Colors.purple.shade200
                              : Colors.green.shade200,
                  child: MaterialButton(
                    key: _btnKeys[index],
                    onPressed:
                        // (renTal_user.toString() == '50' ||
                        //         renTal_user.toString() == '139')
                        //     ?
                        () async {
                      var uuidx;
                      var requestStepx;
                      var payment_uuidx;
                      var payment_amountx;

                      // List<Map<String, dynamic>> payment_jsonx = [];
                      areaModels[index].properties.forEach((p) {
                        // print('🔹 request_uuid: ${p.newRequest?.requestUuid}');
                        uuidx = p.newRequest?.requestUuid;
                        requestStepx = p.newRequest?.requestStep;
                        payment_uuidx = p.newRequest?.paymentUuid;
                        payment_amountx = p.newRequest?.paymentAmount;
                        reques_tstatusx = p.newRequest?.requestStatus;
                        if (p.newRequest?.payment_json != null) {
                          try {
                            final raw = p.newRequest?.payment_json;

                            if (raw is String) {
                              final decoded = json.decode(raw);
                              if (decoded is List) {
                                setState(() {
                                  payment_jsonx =
                                      List<Map<String, dynamic>>.from(decoded);
                                });
                              }
                            } else if (raw is List) {
                              setState(() {
                                payment_jsonx =
                                    List<Map<String, dynamic>>.from(raw!);
                              });
                            }
                          } catch (e) {
                            //  print('❌ Error while parsing payment_json: $e');
                          }
                        }
                      });
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'zoneSer', areaModels[index].zser.toString());
                      preferences.setString(
                          'zonesName', areaModels[index].zn.toString());
                      // print('📦 payment_jsonx payment_jsonx: $payment_jsonx');
                      setState(() {
                        data_uuid = areaModels[index].properties.isNotEmpty
                            ? uuidx
                            : null;
                        requestStep = areaModels[index].properties.isNotEmpty
                            ? requestStepx
                            : null;
                        reques_tstatusx =
                            areaModels[index].properties.isNotEmpty
                                ? reques_tstatusx
                                : null;
                        payment_uuid = areaModels[index].properties.isNotEmpty
                            ? payment_uuidx.toString()
                            : null;
                        payment_uuid_amount =
                            areaModels[index].properties.isNotEmpty
                                ? payment_amountx.toString()
                                : '0.00';
                        // payment_jsonx = areaModels[index].properties.isNotEmpty under_review
                        //     ? jsonx
                        //     : {};
                        read_GC_con_area(index);
                        // if (areaModels[index].quantity == '2' ||
                        //     areaModels[index].quantity == '3') {
                        //   loadareaQuot(index);
                        // }
                      });
                      if (areaModels[index].quantity != '1') {
                        for (int i = 0; i < areaQuotModels.length; i++) {
                          var oo = areaQuotModels[i]
                              .ln_q!
                              .contains(areaModels[index].ln.toString());
                          // print('$oo');
                          // print('${areaQuotModels[i].ln_q}');
                          // print('${areaModels[index].ln}');
                        }
                      }

                      // showLoaderDialog(context);
                      Future.delayed(const Duration(milliseconds: 400), () {
                        add_ContractStore(index);
                        // print(
                        //     '📦 $data_uuid   // reques_tstatusx: $reques_tstatusx');
                        (reques_tstatusx == null)
                            ? maxColumn(index, context)
                            : maxColumn_Approved(
                                index, context, reques_tstatusx, requestStepx);
                        // maxColumn(index, context);
                      });
                    },
                    // : () async {
                    //     setState(() {
                    //       read_GC_con_area(index);
                    //       // if (areaModels[index].quantity == '2' ||
                    //       //     areaModels[index].quantity == '3') {
                    //       //   loadareaQuot(index);
                    //       // }
                    //     });
                    //     if (areaModels[index].quantity != '1') {
                    //       for (int i = 0; i < areaQuotModels.length; i++) {
                    //         var oo = areaQuotModels[i]
                    //             .ln_q!
                    //             .contains(areaModels[index].ln.toString());
                    //         // print('$oo');
                    //         // print('${areaQuotModels[i].ln_q}');
                    //         // print('${areaModels[index].ln}');
                    //       }
                    //     }

                    //     // showLoaderDialog(context);
                    //     Future.delayed(const Duration(milliseconds: 400),
                    //         () {
                    //       maxColumn(index, context);
                    //     });
                    //   },
                    child: Container(
                        color: areaModels[index].quantity == '1'
                            ? (areaModels[index].ldate == null)
                                ? Colors.red.shade200
                                : datex.isAfter(DateTime.parse(
                                                '${areaModels[index].ldate} 00:00:00.000')
                                            .subtract(Duration(
                                                days: open_set_date))) ==
                                        true //datex
                                    ? datex.isAfter(DateTime.parse(
                                                    '${areaModels[index].ldate} 00:00:00.000')
                                                .subtract(Duration(days: 0))) ==
                                            false
                                        ? Colors.orange.shade200
                                        : Colors.grey.shade200
                                    : Colors.red.shade200
                            : areaModels[index].quantity == '2'
                                ? Colors.blue.shade200
                                : areaModels[index].quantity == '3'
                                    ? Colors.purple.shade200
                                    : Colors.green.shade200,
                        width: MediaQuery.of(context).size.width * 0.1,
                        // height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: AutoSizeText(
                              '${areaModels[index].lncode} (${areaModels[index].ln})',
                              minFontSize: 8,
                              maxFontSize:
                                  (Responsive.isDesktop(context)) ? 18 : 12,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                // fontSize: 20,
                                fontFamily: Font_.Fonts_T,
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                              ),
                              maxLines: (Responsive.isDesktop(context)) ? 4 : 2,
                              overflow: TextOverflow.ellipsis,
                            )),
                            Translate.TranslateAndSet_TextAutoSize(
                                areaModels[index].quantity == '1'
                                    ? (areaModels[index].ldate == null)
                                        ? 'หมดสัญญา'
                                        : datex.isAfter(DateTime.parse(
                                                        '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
                                                    .subtract(const Duration(
                                                        days: 0))) ==
                                                true
                                            ? 'หมดสัญญา ${areaModels[index].cc_date != null ? areaModels[index].cc_date == "0000-00-00" ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse('${areaModels[index].cc_date} 00:00:00.000')) : ''}'
                                            : datex.isAfter(DateTime.parse(
                                                            '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
                                                        .subtract(Duration(
                                                            days:
                                                                open_set_date))) ==
                                                    true
                                                ? 'ใกล้หมดสัญญา ${areaModels[index].cc_date != null ? areaModels[index].cc_date == "0000-00-00" ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse('${areaModels[index].cc_date} 00:00:00.000')) : ''}'
                                                : 'เช่าอยู่ ${areaModels[index].cc_date != null ? areaModels[index].cc_date == "0000-00-00" ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse('${areaModels[index].cc_date} 00:00:00.000')) : ''}'
                                    : areaModels[index].quantity == '2'
                                        ? 'เสนอราคา'
                                        : areaModels[index].quantity == '3'
                                            ? 'เสนอราคา(มัดจำ)'
                                            : (areaModels[index]
                                                        .properties
                                                        .toList()
                                                        .length !=
                                                    0)
                                                ? (areaModels[index]
                                                            .properties
                                                            .first
                                                            .newRequest!
                                                            .requestStep ==
                                                        null)
                                                    ? '${areaModels[index].properties.first.newRequest!.requestStep ?? "⚠️Warning"}'
                                                    : 'กำลังดำเดินการ'
                                                //'เกือบว่าง(Step:${areaModels[index].properties.first.newRequest!.requestStep ?? "0"})'
                                                : 'ว่าง',
                                CustomerScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                null,
                                Font_.Fonts_T,
                                8,
                                18,
                                3),
                            // AutoSizeText(
                            //   areaModels[index].quantity == '1'
                            //       ? (areaModels[index].ldate == null)
                            //           ? 'หมดสัญญา'
                            //           : datex.isAfter(DateTime.parse(
                            //                           '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
                            //                       .subtract(const Duration(
                            //                           days: 0))) ==
                            //                   true
                            //               ? 'หมดสัญญา ${areaModels[index].cc_date != null ? areaModels[index].cc_date == "0000-00-00" ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse('${areaModels[index].cc_date} 00:00:00.000')) : ''}'
                            //               : datex.isAfter(DateTime.parse(
                            //                               '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
                            //                           .subtract(Duration(
                            //                               days:
                            //                                   open_set_date))) ==
                            //                       true
                            //                   ? 'ใกล้หมดสัญญา ${areaModels[index].cc_date != null ? areaModels[index].cc_date == "0000-00-00" ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse('${areaModels[index].cc_date} 00:00:00.000')) : ''}'
                            //                   : 'เช่าอยู่ ${areaModels[index].cc_date != null ? areaModels[index].cc_date == "0000-00-00" ? '' : DateFormat('dd-MM-yyyy').format(DateTime.parse('${areaModels[index].cc_date} 00:00:00.000')) : ''}'
                            //       : areaModels[index].quantity == '2'
                            //           ? 'เสนอราคา'
                            //           : areaModels[index].quantity == '3'
                            //               ? 'เสนอราคา(มัดจำ)'
                            //               : 'ว่าง',
                            //   minFontSize: 8,
                            //   maxFontSize: 12,
                            //   textAlign: TextAlign.center,
                            //   style: const TextStyle(
                            //     // fontSize: 20,
                            //     fontFamily: Font_.Fonts_T,
                            //     color: PeopleChaoScreen_Color.Colors_Text2_,
                            //   ),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            // )
                          ],
                        )),
                  )),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      areaModels[index].cc_date != null
                          ? areaModels[index].cc_date == "0000-00-00"
                              ? SizedBox()
                              : Icon(
                                  Icons.closed_caption,
                                )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
              if (areaModels[index].mainten.toString() == '1' ||
                  areaModels[index].mainten.toString() == '2')
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 12,
                    child: Icon(
                      Icons.build,
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
            ],
          );

    // PopupMenuButton(
    //   onOpened: () {
    //     setState(() {
    //       read_GC_con_area(index);
    //     });
    //   },
    //   itemBuilder: (BuildContext context) => [
    //     if (areaModels[index].quantity != '1')
    //       PopupMenuItem(
    //         child: InkWell(
    //             onTap: () async {
    //               SharedPreferences preferences =
    //                   await SharedPreferences.getInstance();
    //               preferences.setString(
    //                   'zoneSer', areaModels[index].zser.toString());
    //               preferences.setString(
    //                   'zonesName', areaModels[index].zn.toString());
    //               setState(() {
    //                 Ser_Body = 1;
    //                 a_ln = areaModels[index].lncode;
    //                 a_ser = areaModels[index].ser;
    //                 a_area = areaModels[index].area;
    //                 a_rent = areaModels[index].rent;
    //                 a_page = '1';
    //               });

    //               Navigator.pop(context);
    //             },
    //             child: Container(
    //                 padding: const EdgeInsets.all(10),
    //                 width: MediaQuery.of(context).size.width,
    //                 child: Row(
    //                   children: [
    //                     Expanded(
    //                         child:
    // Text(
    //                       'เสนอราคา: ${areaModels[index].lncode} (${areaModels[index].ln})',
    //                       overflow: TextOverflow.ellipsis,
    //                       style: const TextStyle(
    //                           color: PeopleChaoScreen_Color.Colors_Text2_,
    //                           //fontWeight: FontWeight.bold,
    //                           fontFamily: Font_.Fonts_T),
    //                     )
    // )
    //                   ],
    //                 ))),
    //       ),
    //     if (areaModels[index].quantity != '1')
    //       PopupMenuItem(
    //         child: InkWell(
    //             onTap: () async {
    //               SharedPreferences preferences =
    //                   await SharedPreferences.getInstance();
    //               preferences.setString(
    //                   'zoneSer', areaModels[index].zser.toString());
    //               preferences.setString(
    //                   'zonesName', areaModels[index].zn.toString());

    //               setState(() {
    //                 Ser_Body = 2;
    //                 a_ln = areaModels[index].lncode;
    //                 a_ser = areaModels[index].ser;
    //                 a_area = areaModels[index].area;
    //                 a_rent = areaModels[index].rent;
    //                 a_page = '1';
    //               });
    //               Navigator.pop(context);
    //             },
    //             child: Container(
    //                 padding: const EdgeInsets.all(10),
    //                 width: MediaQuery.of(context).size.width,
    //                 child: Row(
    //                   children: [
    //                     Expanded(
    //                         child: Text(
    //                       'ทำสัญญา: ${areaModels[index].lncode} (${areaModels[index].ln})',
    //                       overflow: TextOverflow.ellipsis,
    //                       style: const TextStyle(
    //                           color: PeopleChaoScreen_Color.Colors_Text2_,
    //                           //fontWeight: FontWeight.bold,
    //                           fontFamily: Font_.Fonts_T),
    //                     ))
    //                   ],
    //                 ))),
    //       ),
    //     if (areaModels[index].quantity == '1')
    //       for (int i = 0; i < areaxConModels.length; i++)
    //         PopupMenuItem(
    //           child: InkWell(
    //               onTap: () async {
    //                 setState(() {
    //                   Ser_Body = 3;
    //                   Value_stasus = '0';
    //                   Value_cid = areaxConModels[i].cser;
    //                   ser_cidtan = '1';
    //                 });
    //                 Navigator.pop(context);
    //               },
    //               child: Container(
    //                   padding: const EdgeInsets.all(10),
    //                   width: MediaQuery.of(context).size.width,
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                           child: Text(
    //                         '${areaxConModels[i].cser} (${areaxConModels[i].cname})',
    //                         overflow: TextOverflow.ellipsis,
    //                         style: const TextStyle(
    //                             color: PeopleChaoScreen_Color.Colors_Text2_,
    //                             //fontWeight: FontWeight.bold,
    //                             fontFamily: Font_.Fonts_T),
    //                       ))
    //                     ],
    //                   ))),
    //         ),
    //     if (areaModels[index].quantity == '1')
    //       PopupMenuItem(
    //         child: InkWell(
    //             onTap: () async {
    //               setState(() {
    //                 Ser_Body = 3;
    //                 Value_stasus = areaModels[index].quantity == '1'
    //                     ? datex.isAfter(DateTime.parse(
    //                                     '${areaModels[index].ldate} 00:00:00.000')
    //                                 .subtract(const Duration(days: 0))) ==
    //                             true
    //                         ? 'หมดสัญญา'
    //                         : datex.isAfter(DateTime.parse(
    //                                         '${areaModels[index].ldate} 00:00:00.000')
    //                                     .subtract(const Duration(days: open_set_date))) ==
    //                                 true
    //                             ? 'ใกล้หมดสัญญา'
    //                             : 'เช่าอยู่'
    //                     : areaModels[index].quantity == '2'
    //                         ? 'เสนอราคา'
    //                         : areaModels[index].quantity == '3'
    //                             ? 'เสนอราคา(มัดจำ)'
    //                             : 'ว่าง';
    //                 Value_cid = areaModels[index].cid;
    //                 ser_cidtan = '1';
    //               });
    //               Navigator.pop(context);
    //             },
    //             child: Container(
    //                 padding: const EdgeInsets.all(10),
    //                 width: MediaQuery.of(context).size.width,
    //                 child: Row(
    //                   children: [
    //                     Expanded(
    //                         child: Text(
    //                       'เช่าอยู่: ${areaModels[index].cid} (${areaModels[index].cname})',
    //                       overflow: TextOverflow.ellipsis,
    //                       style: const TextStyle(
    //                           color: PeopleChaoScreen_Color.Colors_Text2_,
    //                           //fontWeight: FontWeight.bold,
    //                           fontFamily: Font_.Fonts_T),
    //                     ))
    //                   ],
    //                 ))),
    //       ),
    //     if (areaModels[index].quantity == '1')
    //       PopupMenuItem(
    //         child: InkWell(
    //             onTap: () async {
    //               setState(() {
    //                 Value_stasus = areaModels[index].quantity == '1'
    //                     ? datex.isAfter(DateTime.parse(
    //                                     '${areaModels[index].ldate} 00:00:00.000')
    //                                 .subtract(const Duration(days: 0))) ==
    //                             true
    //                         ? 'หมดสัญญา'
    //                         : datex.isAfter(DateTime.parse(
    //                                         '${areaModels[index].ldate} 00:00:00.000')
    //                                     .subtract(const Duration(days: open_set_date))) ==
    //                                 true
    //                             ? 'ใกล้หมดสัญญา'
    //                             : 'เช่าอยู่'
    //                     : areaModels[index].quantity == '2'
    //                         ? 'เสนอราคา'
    //                         : areaModels[index].quantity == '3'
    //                             ? 'เสนอราคา(มัดจำ)'
    //                             : 'ว่าง';
    //                 Ser_Body = 4;
    //                 Value_cid = areaModels[index].cid;
    //                 ser_cidtan = '1';
    //               });
    //               Navigator.pop(context);
    //             },
    //             child: Container(
    //                 padding: const EdgeInsets.all(10),
    //                 width: MediaQuery.of(context).size.width,
    //                 child: Row(
    //                   children: [
    //                     Expanded(
    //                         child: Text(
    //                       'รับชำระ: ${areaModels[index].cid} (${areaModels[index].cname})',
    //                       overflow: TextOverflow.ellipsis,
    //                       style: const TextStyle(
    //                           color: PeopleChaoScreen_Color.Colors_Text2_,
    //                           //fontWeight: FontWeight.bold,
    //                           fontFamily: Font_.Fonts_T),
    //                     ))
    //                   ],
    //                 ))),
    //       ),
    //     if (areaModels[index].quantity == '2')
    //       for (int i = 0; i < areaQuotModels.length; i++)
    //         if (areaModels[index].ser == areaQuotModels[i].ser)
    //           PopupMenuItem(
    //             child: InkWell(
    //                 onTap: () async {
    //                   setState(() {
    //                     Ser_Body = 3;
    //                     Value_stasus = '1';
    //                     Value_cid = areaQuotModels[i].docno;
    //                     ser_cidtan = '2';
    //                   });
    //                   Navigator.pop(context);
    //                 },
    //                 child: Container(
    //                     padding: const EdgeInsets.all(10),
    //                     width: MediaQuery.of(context).size.width,
    //                     child: Row(
    //                       children: [
    //                         Expanded(
    //                             child: Text(
    //                           'เสนอราคา: ${areaQuotModels[i].docno}',
    //                           overflow: TextOverflow.ellipsis,
    //                           style: const TextStyle(
    //                               color: PeopleChaoScreen_Color.Colors_Text2_,
    //                               //fontWeight: FontWeight.bold,
    //                               fontFamily: Font_.Fonts_T),
    //                         ))
    //                       ],
    //                     ))),
    //           ),
    //     if (areaModels[index].quantity == '3')
    //       for (int i = 0; i < areaQuotModels.length; i++)
    //         if (areaModels[index].ser == areaQuotModels[i].ser)
    //           PopupMenuItem(
    //             child: InkWell(
    //                 onTap: () async {
    //                   setState(() {
    //                     Ser_Body = 3;
    //                     Value_stasus = '1';
    //                     Value_cid = areaQuotModels[i].docno;
    //                     ser_cidtan = '2';
    //                   });
    //                   Navigator.pop(context);
    //                 },
    //                 child: Container(
    //                     padding: const EdgeInsets.all(10),
    //                     width: MediaQuery.of(context).size.width,
    //                     child: Row(
    //                       children: [
    //                         Expanded(
    //                             child: Text(
    //                           'เสนอราคา: (มัดจำ) ${areaQuotModels[i].docno}',
    //                           overflow: TextOverflow.ellipsis,
    //                           style: const TextStyle(
    //                               color: PeopleChaoScreen_Color.Colors_Text2_,
    //                               //fontWeight: FontWeight.bold,
    //                               fontFamily: Font_.Fonts_T),
    //                         ))
    //                       ],
    //                     ))),
    //           ),
    //   ],
    //   child: Card(
    //       child: InkWell(
    //     // onTap: () async {},
    //     child: Container(
    //         color: areaModels[index].quantity == '1'
    //             ? Colors.red.shade200
    //             : areaModels[index].quantity == '2'
    //                 ? Colors.blue.shade200
    //                 : areaModels[index].quantity == '3'
    //                     ? Colors.purple.shade200
    //                     : Colors.green.shade200,
    //         width: MediaQuery.of(context).size.width * 0.1,
    //         height: 50,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Center(
    //                 child: AutoSizeText(
    //               '${areaModels[index].lncode} (${areaModels[index].ln})',
    //               minFontSize: 10,
    //               maxFontSize: 18,
    //               textAlign: TextAlign.center,
    //               style: const TextStyle(
    //                 // fontSize: 20,
    //                 fontFamily: Font_.Fonts_T,
    //                 color: PeopleChaoScreen_Color.Colors_Text2_,
    //               ),
    //               maxLines: 4,
    //               overflow: TextOverflow.ellipsis,
    //             )),
    //             AutoSizeText(
    //               areaModels[index].quantity == '1'
    //                   ? datex.isAfter(DateTime.parse(
    //                                   '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
    //                               .subtract(const Duration(days: 0))) ==
    //                           true
    //                       ? 'หมดสัญญา'
    //                       : datex.isAfter(DateTime.parse(
    //                                       '${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000')
    //                                   .subtract(const Duration(days: open_set_date))) ==
    //                               true
    //                           ? 'ใกล้หมดสัญญา'
    //                           : 'เช่าอยู่'
    //                   : areaModels[index].quantity == '2'
    //                       ? 'เสนอราคา'
    //                       : areaModels[index].quantity == '3'
    //                           ? 'เสนอราคา(มัดจำ)'
    //                           : 'ว่าง',
    //               minFontSize: 8,
    //               maxFontSize: 12,
    //               textAlign: TextAlign.center,
    //               style: const TextStyle(
    //                 // fontSize: 20,
    //                 fontFamily: Font_.Fonts_T,
    //                 color: PeopleChaoScreen_Color.Colors_Text2_,
    //               ),
    //               maxLines: 1,
    //               overflow: TextOverflow.ellipsis,
    //             )
    //           ],
    //         )),
    //   )),
    // );
  }

  Widget createCardNull(value) {
    return Card(
        child: InkWell(
      onTap: () async {},
      child: Container(
          color: Colors.grey.shade200,
          width: MediaQuery.of(context).size.width * 0.1,
          height: 100,
          child: Center(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: PeopleChaoScreen_Color.Colors_Text2_,
                  // fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          )),
    ));
  }

  // Widget BodyHome_mobile() {
  //   return (Visit_ == 'list')
  //       ? Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Container(
  //             width: MediaQuery.of(context).size.width,
  //             decoration: const BoxDecoration(
  //               color: AppbackgroundColor.Sub_Abg_Colors,
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(10),
  //                   topRight: Radius.circular(10),
  //                   bottomLeft: Radius.circular(10),
  //                   bottomRight: Radius.circular(10)),
  //               // border: Border.all(color: Colors.grey, width: 1),
  //             ),
  //             child: Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
  //                   child: ScrollConfiguration(
  //                     behavior: ScrollConfiguration.of(context)
  //                         .copyWith(dragDevices: {
  //                       PointerDeviceKind.touch,
  //                       PointerDeviceKind.mouse,
  //                     }),
  //                     child: SingleChildScrollView(
  //                       scrollDirection: Axis.horizontal,
  //                       dragStartBehavior: DragStartBehavior.start,
  //                       child: Row(
  //                         children: [
  //                           Container(
  //                               width: 1000,
  //                               child: Column(
  //                                 children: [
  //                                   Container(
  //                                       width: 1000,
  //                                       decoration: const BoxDecoration(
  //                                         color:
  //                                             AppbackgroundColor.TiTile_Colors,
  //                                         borderRadius: BorderRadius.only(
  //                                             topLeft: Radius.circular(10),
  //                                             topRight: Radius.circular(10),
  //                                             bottomLeft: Radius.circular(0),
  //                                             bottomRight: Radius.circular(0)),
  //                                       ),
  //                                       padding: const EdgeInsets.all(8.0),
  //                                       child: Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.center,
  //                                         children: const [
  //                                           // Expanded(
  //                                           //   flex: 1,
  //                                           //   child: Padding(
  //                                           //     padding: EdgeInsets.all(8.0),
  //                                           //     child: Text(
  //                                           //       '',
  //                                           //       style: TextStyle(
  //                                           //         color: Colors.black,
  //                                           //         fontWeight: FontWeight.bold,
  //                                           //         //fontSize: 10.0
  //                                           //       ),
  //                                           //     ),
  //                                           //   ),
  //                                           // ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'โซนพื้นที่',
  //                                                 textAlign: TextAlign.center,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'รหัสพื้นที่',
  //                                                 textAlign: TextAlign.center,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'ขนาดพื้นที่(ต.ร.ม.)',
  //                                                 textAlign: TextAlign.end,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'ค่าเช่าต่องวด',
  //                                                 textAlign: TextAlign.end,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'เลขที่ใบสัญญา',
  //                                                 textAlign: TextAlign.end,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'เลขที่ใบเสนอราคา',
  //                                                 textAlign: TextAlign.end,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'วันสิ้นสุดสัญญา',
  //                                                 textAlign: TextAlign.end,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           Expanded(
  //                                             flex: 1,
  //                                             child: Padding(
  //                                               padding: EdgeInsets.all(8.0),
  //                                               child: Text(
  //                                                 'สถานะ',
  //                                                 textAlign: TextAlign.end,
  //                                                 style: TextStyle(
  //                                                     color:
  //                                                         PeopleChaoScreen_Color
  //                                                             .Colors_Text1_,
  //                                                     fontWeight:
  //                                                         FontWeight.bold,
  //                                                     fontFamily:
  //                                                         FontWeight_.Fonts_T
  //                                                     //fontSize: 10.0
  //                                                     ),
  //                                               ),
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       )),
  //                                   Container(
  //                                       height:
  //                                           MediaQuery.of(context).size.height /
  //                                               1.7,
  //                                       width: 1000,
  //                                       decoration: const BoxDecoration(
  //                                         color:
  //                                             AppbackgroundColor.Sub_Abg_Colors,
  //                                         borderRadius: BorderRadius.only(
  //                                             topLeft: Radius.circular(0),
  //                                             topRight: Radius.circular(0),
  //                                             bottomLeft: Radius.circular(0),
  //                                             bottomRight: Radius.circular(0)),
  //                                         // border: Border.all(color: Colors.grey, width: 1),
  //                                       ),
  //                                       child: ListView.builder(
  //                                           controller: _scrollController1,
  //                                           // itemExtent: 50,
  //                                           physics:
  //                                               const AlwaysScrollableScrollPhysics(), //const NeverScrollableScrollPhysics(),
  //                                           shrinkWrap: true,
  //                                           itemCount: areaModels.length,
  //                                           itemBuilder: (BuildContext context,
  //                                               int index) {
  //                                             int daysBetween(
  //                                                 DateTime from, DateTime to) {
  //                                               from = DateTime(from.year,
  //                                                   from.month, from.day);
  //                                               to = DateTime(
  //                                                   to.year, to.month, to.day);
  //                                               return (to
  //                                                           .difference(from)
  //                                                           .inHours /
  //                                                       24)
  //                                                   .round();
  //                                             }

  //                                             var daterz =
  //                                                 areaModels[index].ldate ==
  //                                                         null
  //                                                     ? '0000-00-00'
  //                                                     : areaModels[index].ldate;

  //                                             var birthday = DateTime.parse(
  //                                                     '$daterz 00:00:00.000')
  //                                                 .add(const Duration(
  //                                                     days: -30));
  //                                             var date2 = DateTime.now();
  //                                             var difference =
  //                                                 daysBetween(birthday, date2);

  //                                             return Container(
  //                                               color: tappedIndex_ ==
  //                                                       index.toString()
  //                                                   ? tappedIndex_Color
  //                                                       .tappedIndex_Colors
  //                                                   : null,
  //                                               child: ListTile(
  //                                                   onTap: () {
  //                                                     setState(() {
  //                                                       tappedIndex_ =
  //                                                           index.toString();
  //                                                     });
  //                                                   },
  //                                                   title: Row(
  //                                                     mainAxisAlignment:
  //                                                         MainAxisAlignment
  //                                                             .center,
  //                                                     children: [
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Padding(
  //                                                           padding:
  //                                                               const EdgeInsets
  //                                                                   .all(8.0),
  //                                                           child: Text(
  //                                                             'โซน ${areaModels[index].zser} (${areaModels[index].zn})',
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .center,
  //                                                             style: const TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text2_,
  //                                                                 fontFamily:
  //                                                                     Font_
  //                                                                         .Fonts_T
  //                                                                 //fontSize: 10.0
  //                                                                 ),
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Padding(
  //                                                           padding:
  //                                                               const EdgeInsets
  //                                                                   .all(8.0),
  //                                                           child: Text(
  //                                                             areaModels[index]
  //                                                                         .ln_c ==
  //                                                                     null
  //                                                                 ? areaModels[index]
  //                                                                             .ln_q ==
  //                                                                         null
  //                                                                     ? '${areaModels[index].lncode}'
  //                                                                     : '${areaModels[index].ln_q}'
  //                                                                 : '${areaModels[index].ln_c}',
  //                                                             textAlign:
  //                                                                 TextAlign
  //                                                                     .center,
  //                                                             style: const TextStyle(
  //                                                                 color: PeopleChaoScreen_Color
  //                                                                     .Colors_Text2_,
  //                                                                 fontFamily:
  //                                                                     Font_
  //                                                                         .Fonts_T
  //                                                                 //fontSize: 10.0
  //                                                                 ),
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Text(
  //                                                           areaModels[index]
  //                                                                       .area_c ==
  //                                                                   null
  //                                                               ? areaModels[index]
  //                                                                           .ln_q ==
  //                                                                       null
  //                                                                   ? nFormat.format(double.parse(
  //                                                                       areaModels[index]
  //                                                                           .area!))
  //                                                                   : nFormat.format(
  //                                                                       double.parse(areaModels[index]
  //                                                                           .area_q!))
  //                                                               : nFormat.format(
  //                                                                   double.parse(
  //                                                                       areaModels[index]
  //                                                                           .area_c!)),
  //                                                           textAlign:
  //                                                               TextAlign.end,
  //                                                           style: const TextStyle(
  //                                                               color: PeopleChaoScreen_Color
  //                                                                   .Colors_Text2_,
  //                                                               fontFamily:
  //                                                                   Font_
  //                                                                       .Fonts_T
  //                                                               //fontSize: 10.0
  //                                                               ),
  //                                                         ),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Text(
  //                                                           areaModels[index]
  //                                                                       .total ==
  //                                                                   null
  //                                                               ? areaModels[index]
  //                                                                           .total_q ==
  //                                                                       null
  //                                                                   ? nFormat.format(double.parse(
  //                                                                       areaModels[index]
  //                                                                           .rent!))
  //                                                                   : nFormat.format(
  //                                                                       double.parse(areaModels[index]
  //                                                                           .total_q!))
  //                                                               : nFormat.format(
  //                                                                   double.parse(
  //                                                                       areaModels[index]
  //                                                                           .total!)),
  //                                                           textAlign:
  //                                                               TextAlign.end,
  //                                                           style: const TextStyle(
  //                                                               color: PeopleChaoScreen_Color
  //                                                                   .Colors_Text2_,
  //                                                               fontFamily:
  //                                                                   Font_
  //                                                                       .Fonts_T
  //                                                               //fontSize: 10.0
  //                                                               ),
  //                                                         ),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child: Text(
  //                                                               areaModels[index]
  //                                                                           .cid ==
  //                                                                       null
  //                                                                   ? ''
  //                                                                   : '${areaModels[index].cid}',
  //                                                               maxLines: 2,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               overflow:
  //                                                                   TextOverflow
  //                                                                       .ellipsis,
  //                                                               style: const TextStyle(
  //                                                                   color: PeopleChaoScreen_Color
  //                                                                       .Colors_Text2_,
  //                                                                   fontFamily:
  //                                                                       Font_
  //                                                                           .Fonts_T),
  //                                                             )),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Padding(
  //                                                             padding:
  //                                                                 const EdgeInsets
  //                                                                     .all(8.0),
  //                                                             child: Text(
  //                                                               areaModels[index]
  //                                                                           .docno ==
  //                                                                       null
  //                                                                   ? ''
  //                                                                   : '${areaModels[index].docno}',
  //                                                               maxLines: 2,
  //                                                               textAlign:
  //                                                                   TextAlign
  //                                                                       .end,
  //                                                               overflow:
  //                                                                   TextOverflow
  //                                                                       .ellipsis,
  //                                                               style: TextStyle(
  //                                                                   color: areaModels[index].docno !=
  //                                                                           null
  //                                                                       ? Colors
  //                                                                           .blue
  //                                                                       : PeopleChaoScreen_Color
  //                                                                           .Colors_Text2_,
  //                                                                   fontFamily:
  //                                                                       Font_
  //                                                                           .Fonts_T),
  //                                                             )),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Padding(
  //                                                           padding:
  //                                                               const EdgeInsets
  //                                                                   .all(8.0),
  //                                                           child: Text(
  //                                                             areaModels[index]
  //                                                                         .ldate ==
  //                                                                     null
  //                                                                 ? areaModels[index]
  //                                                                             .ldate_q ==
  //                                                                         null
  //                                                                     ? ''
  //                                                                     : DateFormat(
  //                                                                             'dd-MM-yyyy')
  //                                                                         .format(DateTime.parse(
  //                                                                             '${areaModels[index].ldate_q} 00:00:00'))
  //                                                                         .toString()
  //                                                                 : DateFormat(
  //                                                                         'dd-MM-yyyy')
  //                                                                     .format(DateTime
  //                                                                         .parse(
  //                                                                             '${areaModels[index].ldate} 00:00:00'))
  //                                                                     .toString(),
  //                                                             maxLines: 1,
  //                                                             textAlign:
  //                                                                 TextAlign.end,
  //                                                             overflow:
  //                                                                 TextOverflow
  //                                                                     .ellipsis,
  //                                                             style: TextStyle(
  //                                                                 color: areaModels[index]
  //                                                                             .quantity ==
  //                                                                         '1'
  //                                                                     ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) ==
  //                                                                             true
  //                                                                         ? Colors
  //                                                                             .red
  //                                                                         : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: open_set_date))) ==
  //                                                                                 true
  //                                                                             ? Colors
  //                                                                                 .orange.shade900
  //                                                                             : PeopleChaoScreen_Color
  //                                                                                 .Colors_Text2_
  //                                                                     : areaModels[index].quantity ==
  //                                                                             '2'
  //                                                                         ? Colors
  //                                                                             .blue
  //                                                                         : areaModels[index].quantity ==
  //                                                                                 '3'
  //                                                                             ? Colors
  //                                                                                 .blue
  //                                                                             : Colors
  //                                                                                 .green,
  //                                                                 fontFamily: Font_
  //                                                                     .Fonts_T),
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       Expanded(
  //                                                         flex: 1,
  //                                                         child: Text(
  //                                                           areaModels[index]
  //                                                                       .quantity ==
  //                                                                   '1'
  //                                                               ? datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(
  //                                                                           days:
  //                                                                               0))) ==
  //                                                                       true
  //                                                                   ? 'หมดสัญญา'
  //                                                                   : datex.isAfter(DateTime.parse('${areaModels[index].ldate == null ? DateFormat('yyyy-MM-dd').format(datex) : areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: open_set_date))) ==
  //                                                                           true
  //                                                                       ? 'ใกล้หมดสัญญา'
  //                                                                       : 'เช่าอยู่'
  //                                                               : areaModels[index]
  //                                                                           .quantity ==
  //                                                                       '2'
  //                                                                   ? 'เสนอราคา'
  //                                                                   : areaModels[index].quantity ==
  //                                                                           '3'
  //                                                                       ? 'เสนอราคา(มัดจำ)'
  //                                                                       : 'ว่าง',
  //                                                           textAlign:
  //                                                               TextAlign.end,
  //                                                           style: TextStyle(
  //                                                               color: areaModels[index]
  //                                                                           .quantity ==
  //                                                                       '1'
  //                                                                   ? datex.isAfter(DateTime.parse('${areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: 0))) ==
  //                                                                           true
  //                                                                       ? Colors
  //                                                                           .red
  //                                                                       : datex.isAfter(DateTime.parse('${areaModels[index].ldate} 00:00:00.000').subtract(const Duration(days: open_set_date))) ==
  //                                                                               true
  //                                                                           ? Colors
  //                                                                               .orange.shade900
  //                                                                           : PeopleChaoScreen_Color
  //                                                                               .Colors_Text2_
  //                                                                   : areaModels[index].quantity ==
  //                                                                           '2'
  //                                                                       ? Colors
  //                                                                           .blue
  //                                                                       : areaModels[index].quantity ==
  //                                                                               '3'
  //                                                                           ? Colors
  //                                                                               .blue
  //                                                                           : Colors
  //                                                                               .green,
  //                                                               fontFamily:
  //                                                                   Font_
  //                                                                       .Fonts_T

  //                                                               //fontSize: 10.0
  //                                                               ),
  //                                                         ),
  //                                                       ),
  //                                                     ],
  //                                                   )),
  //                                             );
  //                                           })),
  //                                 ],
  //                               )),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     decoration: const BoxDecoration(
  //                       color: AppbackgroundColor.Sub_Abg_Colors,
  //                       borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(0),
  //                           topRight: Radius.circular(0),
  //                           bottomLeft: Radius.circular(10),
  //                           bottomRight: Radius.circular(10)),
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Align(
  //                           alignment: Alignment.centerLeft,
  //                           child: Row(
  //                             children: [
  //                               Padding(
  //                                 padding: const EdgeInsets.all(8.0),
  //                                 child: InkWell(
  //                                   onTap: () {
  //                                     _scrollController1.animateTo(
  //                                       0,
  //                                       duration: const Duration(seconds: 1),
  //                                       curve: Curves.easeOut,
  //                                     );
  //                                   },
  //                                   child: Container(
  //                                       decoration: BoxDecoration(
  //                                         // color: AppbackgroundColor
  //                                         //     .TiTile_Colors,
  //                                         borderRadius: const BorderRadius.only(
  //                                             topLeft: Radius.circular(6),
  //                                             topRight: Radius.circular(6),
  //                                             bottomLeft: Radius.circular(6),
  //                                             bottomRight: Radius.circular(8)),
  //                                         border: Border.all(
  //                                             color: Colors.grey, width: 1),
  //                                       ),
  //                                       padding: const EdgeInsets.all(3.0),
  //                                       child: const Text(
  //                                         'Top',
  //                                         style: TextStyle(
  //                                             color: Colors.grey,
  //                                             fontSize: 10.0),
  //                                       )),
  //                                 ),
  //                               ),
  //                               InkWell(
  //                                 onTap: () {
  //                                   if (_scrollController1.hasClients) {
  //                                     final position = _scrollController1
  //                                         .position.maxScrollExtent;
  //                                     _scrollController1.animateTo(
  //                                       position,
  //                                       duration: const Duration(seconds: 1),
  //                                       curve: Curves.easeOut,
  //                                     );
  //                                   }
  //                                 },
  //                                 child: Container(
  //                                     decoration: BoxDecoration(
  //                                       // color: AppbackgroundColor
  //                                       //     .TiTile_Colors,
  //                                       borderRadius: const BorderRadius.only(
  //                                           topLeft: Radius.circular(6),
  //                                           topRight: Radius.circular(6),
  //                                           bottomLeft: Radius.circular(6),
  //                                           bottomRight: Radius.circular(6)),
  //                                       border: Border.all(
  //                                           color: Colors.grey, width: 1),
  //                                     ),
  //                                     padding: const EdgeInsets.all(3.0),
  //                                     child: const Text(
  //                                       'Down',
  //                                       style: TextStyle(
  //                                           color: Colors.grey, fontSize: 10.0),
  //                                     )),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Align(
  //                           alignment: Alignment.centerRight,
  //                           child: Row(
  //                             children: [
  //                               InkWell(
  //                                 onTap: _moveUp1,
  //                                 child: const Padding(
  //                                     padding: EdgeInsets.all(8.0),
  //                                     child: Align(
  //                                       alignment: Alignment.centerLeft,
  //                                       child: Icon(
  //                                         Icons.arrow_upward,
  //                                         color: Colors.grey,
  //                                       ),
  //                                     )),
  //                               ),
  //                               Container(
  //                                   decoration: BoxDecoration(
  //                                     // color: AppbackgroundColor
  //                                     //     .TiTile_Colors,
  //                                     borderRadius: const BorderRadius.only(
  //                                         topLeft: Radius.circular(6),
  //                                         topRight: Radius.circular(6),
  //                                         bottomLeft: Radius.circular(6),
  //                                         bottomRight: Radius.circular(6)),
  //                                     border: Border.all(
  //                                         color: Colors.grey, width: 1),
  //                                   ),
  //                                   padding: const EdgeInsets.all(3.0),
  //                                   child: const Text(
  //                                     'Scroll',
  //                                     style: TextStyle(
  //                                         color: Colors.grey, fontSize: 10.0),
  //                                   )),
  //                               InkWell(
  //                                 onTap: _moveDown1,
  //                                 child: const Padding(
  //                                     padding: EdgeInsets.all(8.0),
  //                                     child: Align(
  //                                       alignment: Alignment.centerRight,
  //                                       child: Icon(
  //                                         Icons.arrow_downward,
  //                                         color: Colors.grey,
  //                                       ),
  //                                     )),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       ],
  //                     )),
  //                 const SizedBox(
  //                   height: 20,
  //                 )
  //               ],
  //             ),
  //           ),
  //         )
  //       : Column(
  //           children: [
  //             Container(
  //               decoration: const BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(10),
  //                     topRight: Radius.circular(10),
  //                     bottomLeft: Radius.circular(10),
  //                     bottomRight: Radius.circular(10)),
  //                 // border: Border.all(color: Colors.grey, width: 1),
  //               ),
  //               padding: const EdgeInsets.all(20),
  //               // color: Colors.white,
  //               child: Column(
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           flex: 1,
  //                           child: Container(
  //                             child: Text(
  //                               zone_ser == null
  //                                   ? 'โซน ทั้งหมด'
  //                                   : zone_ser == '0'
  //                                       ? 'โซน ($zone_name)'
  //                                       : 'โซน $zone_ser ($zone_name)',
  //                               style: const TextStyle(
  //                                   color: PeopleChaoScreen_Color.Colors_Text1_,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: FontWeight_.Fonts_T
  //                                   //fontSize: 10.0
  //                                   ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     height: 500,
  //                     child: ScrollConfiguration(
  //                       behavior: ScrollConfiguration.of(context)
  //                           .copyWith(dragDevices: {
  //                         PointerDeviceKind.touch,
  //                         PointerDeviceKind.mouse,
  //                       }),
  //                       child: ResponsiveGridList(
  //                         horizontalGridSpacing:
  //                             16, // Horizontal space between grid items

  //                         horizontalGridMargin:
  //                             50, // Horizontal space around the grid
  //                         verticalGridMargin:
  //                             50, // Vertical space around the grid
  //                         minItemWidth:
  //                             300, // The minimum item width (can be smaller, if the layout constraints are smaller)
  //                         minItemsPerRow:
  //                             2, // The minimum items to show in a single row. Takes precedence over minItemWidth
  //                         maxItemsPerRow:
  //                             12, // The maximum items to show in a single row. Can be useful on large screens
  //                         listViewBuilderOptions:
  //                             ListViewBuilderOptions(), // Options that are getting passed to the ListView.builder() function
  //                         children: List.generate(
  //                           areaModels.length,
  //                           (index) => Padding(
  //                             padding: const EdgeInsets.all(2.0),
  //                             child: Container(
  //                               width: MediaQuery.of(context).size.width * 0.07,
  //                               height: 50,
  //                               decoration: BoxDecoration(
  //                                 color: areaModels[index].quantity == '1'
  //                                     ? Colors.red.shade200
  //                                     : areaModels[index].quantity == '2'
  //                                         ? Colors.blue.shade200
  //                                         : areaModels[index].quantity == '3'
  //                                             ? Colors.blue.shade200
  //                                             : Colors.green.shade200,
  //                                 borderRadius: const BorderRadius.only(
  //                                     topLeft: Radius.circular(10),
  //                                     topRight: Radius.circular(10),
  //                                     bottomLeft: Radius.circular(10),
  //                                     bottomRight: Radius.circular(10)),
  //                                 // border: Border.all(color: Colors.grey, width: 1),
  //                               ),
  //                               // padding: const EdgeInsets.all(8.0),
  //                               child: Row(
  //                                 mainAxisAlignment: MainAxisAlignment.center,
  //                                 children: [
  //                                   Text(
  //                                     '${areaModels[index].lncode} (${areaModels[index].zn})',
  //                                     textAlign: TextAlign.center,
  //                                     style: const TextStyle(
  //                                         color: PeopleChaoScreen_Color
  //                                             .Colors_Text2_,
  //                                         // fontWeight: FontWeight.bold,
  //                                         fontFamily: Font_.Fonts_T
  //                                         //fontSize: 10.0
  //                                         ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )
  //           ],
  //         );
  // }

  Widget Body_Renew(context) {
    return Newcontract_cmm(
      Get_Value_area_index: a_ser,
      Get_Value_area_ln: a_ln,
      Get_Value_area_sum: a_area,
      Get_Value_rent_sum: a_rent,
      Get_Value_page: a_page,
      Get_Value_uuid: data_uuid.toString(),
      Get_Value_step: requestStep.toString(),
      Get_Value_payment_uuid: payment_uuid.toString(),
      Get_Value_payment_amount: payment_uuid_amount.toString(),
      paymentjsonx: payment_jsonx,
      Get_TeNantModels: [],
      status_uuid: reques_tstatusx.toString(),
    );

    // (renTal_user.toString() == '50' || renTal_user.toString() == '139')
    //     ?
    // Newcontract_cmm(
    //         Get_Value_area_index: a_ser,
    //         Get_Value_area_ln: a_ln,
    //         Get_Value_area_sum: a_area,
    //         Get_Value_rent_sum: a_rent,
    //         Get_Value_page: a_page,
    //         Get_Value_uuid: data_uuid.toString(),
    //         Get_Value_step: requestStep.toString(),
    //         Get_Value_payment_uuid: payment_uuid.toString(),
    //         Get_Value_payment_amount: payment_uuid_amount.toString(),
    //         paymentjsonx: payment_jsonx,
    //         Get_TeNantModels: [],
    //       )
    //     : ChaoAreaRenewScreen(
    //         Get_Value_area_index: a_ser,
    //         Get_Value_area_ln: a_ln,
    //         Get_Value_area_sum: a_area,
    //         Get_Value_rent_sum: a_rent,
    //         Get_Value_page: a_page,
    //       );
  }

  Widget Body_bid(context) {
    return Newcontract_cmm(
      Get_Value_area_index: a_ser,
      Get_Value_area_ln: a_ln,
      Get_Value_area_sum: a_area,
      Get_Value_rent_sum: a_rent,
      Get_Value_page: a_page,
      Get_Value_uuid: data_uuid.toString(),
      Get_Value_step: requestStep.toString(),
      Get_Value_payment_uuid: payment_uuid.toString(),
      Get_Value_payment_amount: payment_uuid_amount.toString(),
      paymentjsonx: payment_jsonx,
      Get_TeNantModels: [],
      status_uuid: reques_tstatusx.toString(),
    );

    // ChaoAreaBidScreen(
    //   Get_Value_area_index: a_ser,
    //   Get_Value_area_ln: a_ln,
    //   Get_Value_area_sum: a_area,
    //   Get_Value_rent_sum: a_rent,
    //   Get_Value_page: a_page,
    // );
  }
}
