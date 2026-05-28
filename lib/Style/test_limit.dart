import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetArea_quot.dart';
import '../Model/GetAreax_con_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetSubZone_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/Get_maintenance_model.dart';

class MyWidget_Test_limit extends StatefulWidget {
  const MyWidget_Test_limit({super.key});

  @override
  State<MyWidget_Test_limit> createState() => _MyWidget_Test_limitState();
}

class _MyWidget_Test_limitState extends State<MyWidget_Test_limit> {
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
  List<UserModel> userModels = [];
  ///////---------------------------------------------------->
  final Dio dio = Dio();
  final CancelToken cancelToken = CancelToken();

  int serren = 0;
  String? ser_user;
  bool isLoading = true;
  int seconds = 0;
  Timer? timer;
  ///////---------------------------------------------------->
  @override
  void initState() {
    super.initState();
    startTimer();
    Line_IoginAuto();

    // read_GC_Sub_zone();
    // read_GC_zone();

    // addAcListTitle();
    _areaModels = areaModels;
    _zoneModels = zoneModels;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  Future<int> Line_IoginAuto() async {
    String url = Uri.base.toString(); // ตัวอย่าง: https://.../#/userren=118
    // String url = 'https://chaoperties.com/Admin_Test/#/userren=118';
    int serren = 0;

    try {
      //print('try : 1');

      int index = url.indexOf('userren=');

      if (index != -1) {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        await preferences.clear(); // ต้องใช้ await

        //print('try : 2');

        index += 'userren='.length;

        int endIndex = url.indexOf(',', index);
        if (endIndex == -1) {
          endIndex = url.length;
        }

        String userren = url.substring(index, endIndex);
        //print('userren: $userren');
        setState(() {
          ser_user = 'userren: $userren';
        });
        // แปลงเป็น int และเก็บไว้
        serren = int.tryParse(userren) ?? 0;
        await preferences.setString('renTalSer', serren.toString());

        //print('try : 3 => serren: $serren');
      }
    } catch (e) {
      //print('catch_Line_IoginAuto : $e');
    }
    await checkPreferance();
    await read_GC_rental();
    await read_GC_User();
    await read_GC_zone();
    await read_GC_area();

    return serren;
  }

  Future<Null> read_GC_User() async {
    if (userModels.isNotEmpty) {
      setState(() {
        userModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_userSetting.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          UserModel userModel = UserModel.fromJson(map);
          setState(() {
            userModels.add(userModel);
          });
        }
      } else {}
    } catch (e) {}
  }

  Future<Null> read_GC_zone() async {
    if (zoneModels.length != 0) {
      zoneModels.clear();
      _zoneModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var zoneSubSer = preferences.getString('zoneSubSer');
    var zonesSubName = preferences.getString('zonesSubName');
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      ////print(result);
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
        var sub = zoneModel.sub_zone;
        setState(() {
          if (zoneSubSer == null || zoneSubSer == '0') {
            zoneModels.add(zoneModel);
          } else {
            if (sub == zoneSubSer) {
              zoneModels.add(zoneModel);
            }
          }
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
    } catch (e) {}

    setState(() {
      _zoneModels = zoneModels;
    });

    setState(() {
      areaFloorplanModels.clear;
      areaModels.clear();
      _areaModels.clear();
      // read_GC_area();
    });
  }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // setState(() {
    //   renTal_user = preferences.getString('renTalSer');
    //   renTal_name = preferences.getString('renTalName');
    //   renTal_lavel = int.parse(preferences.getString('lavel').toString());
    // });

    //print('textsearchstart>>>>  checkPreferance');
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer'); // ✅ ต้องดึงจาก preferences
    var zone = preferences.getString('zoneSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //  //print(result);
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
            ser_Floor_plans = renTalModel.Floor_plans!;
            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
    // //print('name>>>>>  $renname');
  }

  //////////-------------------------------->
  Future<Null> read_GC_area() async {
    setState(() {
      isLoading = true;
    });
    if (areaModels.isNotEmpty) {
      setState(() {
        areaQuotModels.clear();
        areaModels.clear();
        _areaModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer'); // ✅ ต้องดึงจาก preferences
    var zone = preferences.getString('zoneSer');
    ////print('zone >>>>>> $zone');

    String url = zone == null
        ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
        : zone == '0'
            ? '${MyConstant().domain}/GC_areaAll.php?isAdd=true&ren=$ren&zone=$zone'
            : '${MyConstant().domain}/GC_area.php?isAdd=true&ren=$ren&zone=$zone';
    //print(url);
    try {
      // var response = await http.get(Uri.parse(url));
      final response = await dio.get(
        Uri.parse(url).toString(),
        cancelToken: cancelToken,
      );
      var result = response.data;
      // var result = json.decode(response.body);
      // //print(result);
      if (result != null) {
        for (var map in result) {
          AreaModel areaModel = AreaModel.fromJson(map);

          setState(() {
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
              // //print(result);
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
        // //print(
        //     'areaQuotModels.length>>>>>>>> ${areaQuotModels.length} ${areaQuotModels.map((e) => '152' == e.ser ? e.docno : '0').toString()}');
        if (zone == null || zone == '0') {
          setState(() {
            areaFloorplanModels.clear();
          });
        } else {}
      } else {
        setState(() {
          if (areaModels.isEmpty) {
            preferences.remove('zoneSer');
            preferences.remove('zonesName');
          }
        });
      }
    } on DioException catch (e) {
    } catch (e) {}
    //print('areaModels.length');
    //print(areaModels.length); // โหลดข้อมูลเสร็จ
    setState(() {
      isLoading = false;
    });
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${ser_user} [ Area All : ${areaModels.length} , Zone All : ${zoneModels.length} , User All : ${userModels.length} ] ')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('กำลังโหลด... $seconds วินาที'),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: areaModels.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
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
                    child: ListTile(
                      title: Text('${index + 1}'),
                      subtitle: Text(
                          '--> ${areaModels[index].ln} (${areaModels[index].zn})'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
