// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, prefer_const_constructors, unnecessary_import, implementation_imports, prefer_const_constructors_in_immutables, non_constant_identifier_names, avoid_init_to_null, prefer_void_to_null, unnecessary_brace_in_string_interps, avoid_print, empty_catches, sized_box_for_whitespace, use_build_context_synchronously, file_names, curly_braces_in_flow_control_structures
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_contract_page/views/license_contract_page.dart';
import 'package:chaoperty/ChiangMai_Municipality/Tenant_menu/tenant_license_page/views/tenant_license_page.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:flutter/foundation.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:marquee/marquee.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_sheet/side_sheet.dart';
// import 'package:timer_builder/timer_builder.dart';
import 'dart:math' as math;
import '../Account/Ac_Sub/Account_Screen.dart';
import '../Account/Play_column.dart';
import '../Beam/Beam_api_check_Pay.dart';
import '../ChiangMai_Municipality/Registration_menu/registration_page/views/registration_page.dart';
import '../ChaoArea/ChaoArea_Screen.dart';
import '../ChiangMai_Municipality/License_menu/license_announce_page.dart';
import '../ChiangMai_Municipality/License_menu/license_approve_page/views/license_approve_page.dart';
import '../ChiangMai_Municipality/License_menu/license_attach_page/views/license_attach_page.dart';
import '../ChiangMai_Municipality/License_menu/license_fact_check_page/views/license_fact_check_page.dart';
import '../ChiangMai_Municipality/License_menu/license_payment_page/views/license_payment_page.dart';
import '../ChiangMai_Municipality/License_menu/license_request_page/views/license_request_page.dart';
import '../ChiangMai_Municipality/License_menu/license_verify_page/views/license_verify_page.dart';
import '../ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
import '../ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart';
import '../ChiangMai_Municipality/List_CMM/Register_CMM/chiangMaiBackground2.dart';
import '../ChiangMai_Municipality/cignaturepad_cmm.dart';
import '../ChiangMai_Municipality/manage_personalInformation_cmm.dart';
import '../ChiangMai_Municipality/request_contract_cmm.dart';
import '../ChiangMai_Municipality/request_examiner1_cmm.dart';
import '../ChiangMai_Municipality/request_examiner2_cmm.dart';
import '../ChiangMai_Municipality/unity/API_admin_signature.dart';
import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';
import '../Constant/Myconstant.dart';
// Customer_Screen ถูกย้ายไปอยู่ใน Registration_menu (internal use only)
import '../Home/Home2.dart';
import '../Home/Home_Screen.dart';
import '../Home/dashboardHtml.dart';
import '../Home/home_screen2.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Manage/Manage_Screen.dart';
import '../Manage/Repairs_Screen.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetPerMission_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Model/Get_Chat_Model.dart';
import '../Model/areak_model.dart';
import '../PeopleChao/PeopleChao_Screen.dart';
import '../Register/SignIn_License.dart';
import '../Register/SignIn_Screen.dart';
import '../Register/SignUp_Screen.dart';
import '../Report/Report_Screen.dart';
import 'package:http/http.dart' as http;
import '../Report_Ortorkor/Report_Ortor_Screen.dart';
import '../Report_cm/Report_cm_Screen.dart';
import '../Responsive/responsive.dart';

import '../Setting/Access_Rights.dart';
import '../Setting/SettingScreen.dart';
import '../Setting/SettingScreen_user.dart';
import '../Setting/User_Information.dart';
import '../Setting/ttt.dart';
import '../Setting_NainaService/Web_view_NainaSetting.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/view_pagenow.dart';
import '../Style/test_print_name.dart';
import '../Constant/api_cache.dart';
import '../main.dart';
import '../support/admin_support.dart';
import 'Chat_Screen.dart';
import 'dart:html' as html;
import '../Model/MasterData_Model.dart';

class AdminScafScreen extends StatefulWidget {
  // final route_getdata;
  // const AdminScafScreen({super.key});

  @override
  State<AdminScafScreen> createState() => _AdminScafScreenState();
  final String? route;
  final String? route_getdata;
  final int? ser_title;
  AdminScafScreen({
    super.key,
    this.route,
    this.route_getdata,
    this.ser_title,
  });
}

class _AdminScafScreenState extends State<AdminScafScreen> {
  DateTime datex = DateTime.now();
  int serBody_modile_wiget = 0;
  String Value_Route = 'หน้าหลัก';

  String? ser_user,
      position_user,
      fname_user,
      lname_user,
      email_user,
      utype_user,
      permission_user,
      renTal_user,
      renTal_name,
      ren_ser,
      renTal_Email,
      passcode,
      time_check,
      Auto_cancel;
  int? perMissioncount;
  List<RenTalModel> renTalModels = [];
  List<PerMissionModel> perMissionModels = [];
  List<AreakModel> areakModels = [];
  List<UserModel> userModels = [];
  List<UserModel> userModels_chat = [];
  int? timeoutper = null;
  DateTime? alert;
  Timer? timer;
  bool isActive = false;
  String? rtname, type, typex, renname, pkname, ser_Zonex, pkldate, data_update;
  int? pkqty, pkuser, countarae, renTal_lavel = 0;
  String? base64_Imgmap, foder;
  String? tel_user, img_, img_logo;
  String singleDeviceName = "Unknown";
  String singleDeviceNameFromModel = "Unknown";
  String deviceNames = "Unknown";
  String deviceNamesFromModel = "Unknown";
  final _keybar = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final Formpasslok_ = TextEditingController();
  ///////////------------------------------------------->

  List<ChatModel> chatModel = [];
  List<ChatModel> chatModel_new = [];
  // List<ChatModel> _chatModel = <ChatModel>[];
  late StreamController<int> _streamController;
  late int _counter;
  late Timer _timer;
  bool? isDark_Mode;
  bool isSidebarOpen = true;

  /// แคช API 60 วินาที (1 นาที) — ป้องกันดึงซ้ำตอนรีเฟรช/rebuild
  final _apiCache = ApiCache(ttl: const Duration(seconds: 60));

  List<RenTalModel> rentalSetring = [];
  dynamic incPasscode = [];
  List<UserModel> gcUser = [];
  List<UserModel> connectedUser = [];
///////////------------------------------------------->
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await checkPreferance();
    await readMasterData();
    signInThreadMain();
    Value_Route = widget.route!;
    alert = DateTime.now().add(Duration(seconds: 300));
    readTime();
    initPlugin();
    if (kIsWeb) {
      // ดัน state ปัจจุบันเข้าไป
      html.window.history.pushState(null, '', html.window.location.href);
      // ดักปุ่ม back ของเบราว์เซอร์
      html.window.onPopState.listen((_) {
        html.window.history.pushState(null, '', html.window.location.href);
      });
    }
  }

  void _restoreMasterFromCache(dynamic cached) {
    if (cached == null) return;
    final masterData = MasterDataModel.fromJson(cached);

    setState(() {
      rentalSetring = masterData.rentalSetring;
      incPasscode = masterData.incPasscode;
      gcUser = masterData.gcUser;
      connectedUser = masterData.connectedUser;

      if (rentalSetring.isNotEmpty) {
        RenTalModel renTalModel = rentalSetring[0];
        renTalModels = [renTalModel];
        renTal_name = renTalModel.pn?.trim();
        time_check = renTalModel.time_check;
        renTal_Email = renTalModel.bill_email;
        foder = renTalModel.dbn;
        rtname = renTalModel.rtname;
        type = renTalModel.type;
        typex = renTalModel.typex;
        renname = renTalModel.pn?.trim();
        pkqty = int.tryParse(renTalModel.pkqty ?? "0");
        pkuser = int.tryParse(renTalModel.pkuser ?? "0");
        pkname = renTalModel.pk?.trim();
        img_ = renTalModel.img;
        img_logo = renTalModel.imglogo;
        pkldate = renTalModel.pkldate;
        data_update = renTalModel.data_update;

        if (renTalModel.colors_ren != null &&
            renTalModel.colors_ren!.isNotEmpty) {
          try {
            AppBarColors.hexColor = Color(int.parse(renTalModel.colors_ren!));
          } catch (_) {}
        }
        if (renTalModel.colors_subren != null &&
            renTalModel.colors_subren!.isNotEmpty) {
          try {
            AppBarColors.ABar_Colors_tab =
                Color(int.parse(renTalModel.colors_subren!));
          } catch (_) {}
        }
      }

      if (incPasscode != null &&
          incPasscode is List &&
          incPasscode.isNotEmpty) {
        var firstPass = incPasscode[0];
        if (firstPass != null && firstPass['passcode'] != null) {
          passcode = firstPass['passcode'].toString();
        }
      }

      if (gcUser.isNotEmpty) {
        UserModel user = gcUser[0];
        system_datex_ = user.system_datex;
        showst_update_ = user.showst_update;
        if (user.user_id != null) {
          renTal_lavel = int.tryParse(user.user_id!) ?? 0;
        }
      }

      userModels_chat.clear();
      userModels.clear();
      for (var user in connectedUser) {
        userModels_chat.add(user);
        if (user.connected != null) {
          try {
            DateTime connectedTime = DateTime.parse(user.connected!);
            if (DateTime.now().difference(connectedTime).inMinutes <= 15) {
              userModels.add(user);
            }
          } catch (_) {}
        }
      }
      if (connectedUser.isNotEmpty) {
        read_data_davtext = connectedUser[0].dev_text ?? "";
      }
    });
  }

  Future<void> readMasterData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var renTalSer = preferences.getString('renTalSer');
    var email_address = preferences.getString('email');
    var rental_email = preferences.getString('renTalEmail');

    final cacheKey = 'readMasterData_$renTalSer';

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        _restoreMasterFromCache(cached);
        return;
      }
    }

    final url = Uri.parse('${MyConstant().domain}/GC_admin_scaffold.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ren': renTalSer.toString(),
          'email': email_address.toString(),
          'emailrental': rental_email.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _apiCache.set(cacheKey, result);

        final masterData = MasterDataModel.fromJson(result);

        setState(() {
          rentalSetring = masterData.rentalSetring;
          incPasscode = masterData.incPasscode;
          gcUser = masterData.gcUser;
          connectedUser = masterData.connectedUser;

          if (rentalSetring.isNotEmpty) {
            RenTalModel renTalModel = rentalSetring[0];
            renTalModels = [renTalModel];

            Auto_cancel = preferences.getString('Auto_cancel');
            ren_ser = renTalSer?.trim().toString();
            preferences.setString('renTalName', renTalModel.pn?.trim() ?? "");
            preferences.setString(
                'renTalEmail', renTalModel.bill_email?.trim() ?? "");
            preferences.setString(
                'renTal_Language', renTalModel.lan_guage?.trim() ?? "");

            renTal_name = renTalModel.pn?.trim();
            time_check = renTalModel.time_check;
            renTal_Email = renTalModel.bill_email;
            foder = renTalModel.dbn;
            rtname = renTalModel.rtname;
            type = renTalModel.type;
            typex = renTalModel.typex;
            renname = renTalModel.pn?.trim();
            pkqty = int.tryParse(renTalModel.pkqty ?? "0");
            pkuser = int.tryParse(renTalModel.pkuser ?? "0");
            pkname = renTalModel.pk?.trim();
            img_ = renTalModel.img;
            img_logo = renTalModel.imglogo;
            preferences.setString(
              'renTal_logo',
              '${MyConstant().domain}/files/${renTalModel.dbn}/logo/${renTalModel.imglogo}',
            );
            pkldate = renTalModel.pkldate;
            data_update = renTalModel.data_update;

            if (renTalModel.colors_ren != null &&
                renTalModel.colors_ren != 'null' &&
                renTalModel.colors_ren!.isNotEmpty) {
              try {
                String colorStr = renTalModel.colors_ren!;
                if (colorStr.startsWith('0x')) {
                  AppBarColors.hexColor = Color(int.parse(colorStr));
                } else {
                  AppBarColors.hexColor = Color(int.parse(colorStr));
                }
              } catch (e) {
                print("Error parsing hexColor: $e");
              }
            }

            if (renTalModel.colors_subren != null &&
                renTalModel.colors_subren != 'null' &&
                renTalModel.colors_subren!.isNotEmpty) {
              try {
                String colorStr = renTalModel.colors_subren!;
                if (colorStr.startsWith('0x')) {
                  AppBarColors.ABar_Colors_tab = Color(int.parse(colorStr));
                } else {
                  AppBarColors.ABar_Colors_tab = Color(int.parse(colorStr));
                }
              } catch (e) {
                print("Error parsing ABar_Colors_tab: $e");
              }
            }
          }

          if (incPasscode != null &&
              incPasscode is List &&
              incPasscode.isNotEmpty) {
            var firstPass = incPasscode[0];
            if (firstPass != null && firstPass['passcode'] != null) {
              passcode = firstPass['passcode'].toString();
            }
          }

          if (gcUser.isNotEmpty) {
            UserModel user = gcUser[0];
            system_datex_ = user.system_datex;
            showst_update_ = user.showst_update;

            if (user.user_id != null) {
              renTal_lavel = int.tryParse(user.user_id!) ?? 0;
            }

            if (showst_update_ == '0') {
              System_New_Update();
            }
          }

          userModels_chat.clear();
          userModels.clear();
          for (var user in connectedUser) {
            userModels_chat.add(user);
            if (user.connected != null) {
              DateTime connectedTime = DateTime.parse(user.connected!);
              DateTime currentTime = DateTime.now();
              if (currentTime.difference(connectedTime).inMinutes <= 15) {
                userModels.add(user);
              }
            }
          }

          if (connectedUser.isNotEmpty) {
            read_data_davtext = connectedUser[0].dev_text ?? "";
          }
        });
      } else {
        print('API Error: ${response.body}');
      }
    } catch (e) {
      print('readMasterData error: $e');
    }
  }
  // Future<void> readMasterData() async {

  //   if (_apiCache.isValid('readMasterData')) {
  //     final cached = _apiCache.get('readMasterData');
  //     if (cached != null) {
  //       _restoreMasterFromCache(cached);
  //       return;
  //     }
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var renTalSer = preferences.getString('renTalSer');
  //   var email_address = preferences.getString('email');
  //   var rental_email = preferences.getString('renTalEmail');

  //   final url = Uri.parse('${MyConstant().domain}/GC_admin_scaffold.php');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'ren': renTalSer.toString(),
  //         'email': email_address.toString(),
  //         'emailrental': rental_email.toString(),
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final result = json.decode(response.body);
  //       _apiCache.set('readMasterData', result);
  //       final masterData = MasterDataModel.fromJson(result);

  //       setState(() {
  //         rentalSetring = masterData.rentalSetring;
  //         incPasscode = masterData.incPasscode;
  //         gcUser = masterData.gcUser;
  //         connectedUser = masterData.connectedUser;

  //         // Process rental settings (from read_GC_rental)
  //         if (rentalSetring.isNotEmpty) {
  //           RenTalModel renTalModel = rentalSetring[0];
  //           renTalModels = [
  //             renTalModel
  //           ]; // Keep old list for compatibility if needed

  //           Auto_cancel = preferences.getString('Auto_cancel');
  //           ren_ser = renTalSer?.trim().toString();
  //           preferences.setString('renTalName', renTalModel.pn?.trim() ?? "");
  //           preferences.setString(
  //               'renTalEmail', renTalModel.bill_email?.trim() ?? "");
  //           preferences.setString(
  //               'renTal_Language', renTalModel.lan_guage?.trim() ?? "");

  //           renTal_name = renTalModel.pn?.trim();
  //           time_check = renTalModel.time_check;
  //           renTal_Email = renTalModel.bill_email;
  //           foder = renTalModel.dbn;
  //           rtname = renTalModel.rtname;
  //           type = renTalModel.type;
  //           typex = renTalModel.typex;
  //           renname = renTalModel.pn?.trim();
  //           pkqty = int.tryParse(renTalModel.pkqty ?? "0");
  //           pkuser = int.tryParse(renTalModel.pkuser ?? "0");
  //           pkname = renTalModel.pk?.trim();
  //           img_ = renTalModel.img;
  //           img_logo = renTalModel.imglogo;
  //           preferences.setString('renTal_logo',
  //               '${MyConstant().domain}/files/${renTalModel.dbn}/logo/${renTalModel.imglogo}');
  //           pkldate = renTalModel.pkldate;
  //           data_update = renTalModel.data_update;

  //           if (renTalModel.colors_ren != null &&
  //               renTalModel.colors_ren != 'null' &&
  //               renTalModel.colors_ren!.isNotEmpty) {
  //             try {
  //               String colorStr = renTalModel.colors_ren!;
  //               if (colorStr.startsWith('0x')) {
  //                 AppBarColors.hexColor = Color(int.parse(colorStr));
  //               } else {
  //                 AppBarColors.hexColor = Color(int.parse(colorStr));
  //               }
  //             } catch (e) {
  //               print("Error parsing hexColor: $e");
  //             }
  //           }
  //           if (renTalModel.colors_subren != null &&
  //               renTalModel.colors_subren != 'null' &&
  //               renTalModel.colors_subren!.isNotEmpty) {
  //             try {
  //               String colorStr = renTalModel.colors_subren!;
  //               if (colorStr.startsWith('0x')) {
  //                 AppBarColors.ABar_Colors_tab = Color(int.parse(colorStr));
  //               } else {
  //                 AppBarColors.ABar_Colors_tab = Color(int.parse(colorStr));
  //               }
  //             } catch (e) {
  //               print("Error parsing ABar_Colors_tab: $e");
  //             }
  //           }
  //         }

  //         // Process passcode (from passcode_in)
  //         if (incPasscode != null &&
  //             incPasscode is List &&
  //             incPasscode.isNotEmpty) {
  //           var firstPass = incPasscode[0];
  //           if (firstPass != null && firstPass['passcode'] != null) {
  //             passcode = firstPass['passcode'].toString();
  //           }
  //         }

  //         // Process GC User (from System_User)
  //         if (gcUser.isNotEmpty) {
  //           UserModel user = gcUser[0];
  //           system_datex_ = user.system_datex;
  //           showst_update_ = user.showst_update;

  //           // Update renTal_lavel from user data if available
  //           if (user.user_id != null) {
  //             renTal_lavel = int.tryParse(user.user_id!) ?? 0;
  //           }

  //           if (showst_update_ == '0') {
  //             System_New_Update();
  //           }
  //         }

  //         // Process Connected Users (from Check_connected)
  //         userModels_chat.clear();
  //         userModels.clear();
  //         for (var user in connectedUser) {
  //           userModels_chat.add(user);
  //           if (user.connected != null) {
  //             DateTime connectedTime = DateTime.parse(user.connected!);
  //             DateTime currentTime = DateTime.now();
  //             if (currentTime.difference(connectedTime).inMinutes <= 15) {
  //               userModels.add(user);
  //             }
  //           }
  //         }
  //         if (connectedUser.isNotEmpty) {
  //           read_data_davtext = connectedUser[0].dev_text ?? "";
  //         }
  //       });
  //     } else {
  //       print('API Error: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('readMasterData error: $e');
  //   }
  // }

  String? system_datex_;
  String? showst_update_;

  Future<Null> System_New_Update() async {
    String accept_ = showst_update_!;
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: Text(
          '📢 ${system_datex_}',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontFamily: Font_.Fonts_T,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("images/pngegg.png"),
              // fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  height: 150,
                  width: 150,
                  child: Image.asset(
                    'images/update.png',
                    // fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ขออภัย ขณะนี้ระบบได้มีการอัพเดต ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'คำแนะนำโปรดออกจากระบบ และทำการรีเฟรช',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    const Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                    if (Responsive.isDesktop(context))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      accept_ = '0';
                                    });
                                  },
                                  child: Icon(
                                    (accept_ == '0')
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: (accept_ == '0')
                                        ? Colors.red
                                        : Colors.black,
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'แสดง ทุกครั้ง/ออกจากระบบ ทุกครั้ง',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[900],
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    accept_ = '1';
                                  });
                                },
                                child: Icon(
                                    (accept_ == '0')
                                        ? Icons.check_box_outline_blank
                                        : Icons.check_box,
                                    color: (accept_ == '0')
                                        ? Colors.black
                                        : Colors.red),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'แสดงอีกครั้งเมื่อมีการอัพเดต',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    if (!Responsive.isDesktop(context))
                      SizedBox(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        accept_ = '0';
                                      });
                                    },
                                    child: Icon(
                                      (accept_ == '0')
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: (accept_ == '0')
                                          ? Colors.red
                                          : Colors.black,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'แสดง ทุกครั้ง',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[900],
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      accept_ = '1';
                                    });
                                  },
                                  child: Icon(
                                      (accept_ == '0')
                                          ? Icons.check_box_outline_blank
                                          : Icons.check_box,
                                      color: (accept_ == '0')
                                          ? Colors.black
                                          : Colors.red),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'แสดงอีกครั้งเมื่อมีการอัพเดต',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
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
                          Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () async {
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                var email_ = preferences.getString('email');
                                // print(accept_);
                                if (accept_ == '1') {
                                  String url =
                                      '${MyConstant().domain}/UP_Show_System.php?isAdd=true&email=$email_';

                                  try {
                                    var response =
                                        await http.get(Uri.parse(url));

                                    var result = json.decode(response.body);

                                    if (result.toString() == 'true') {
                                      Navigator.pop(context, 'OK');
                                    } else {
                                      Navigator.pop(context, 'OK');
                                    }
                                  } catch (e) {}
                                } else {
                                  Navigator.pop(context, 'OK');
                                }
                                //   showDialog<String>(
                                //   barrierDismissible: false,
                                //   context: context,
                                //   builder: (BuildContext context) =>
                                //       AlertDialog(
                                //     shape: const RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.all(
                                //             Radius.circular(20.0))),
                                //     title: Column(
                                //       children: [
                                //         const Center(
                                //             child: Text(
                                //           'ออกจากระบบ',
                                //           style: TextStyle(
                                //               color: AdminScafScreen_Color
                                //                   .Colors_Text1_,
                                //               fontWeight: FontWeight.bold,
                                //               fontFamily: FontWeight_.Fonts_T),
                                //         )),
                                //         const Center(
                                //             child: Text(
                                //           '( บังคับออกจากระบบ เนื่องจากระบบได้มีการอัพเดต )',
                                //           style: TextStyle(
                                //               fontSize: 14,
                                //               color: Colors.grey,
                                //               fontFamily: Font_.Fonts_T),
                                //         )),
                                //         const Center(
                                //             child: Text(
                                //           '# กรุณาเข้าสู่ระบบอีกครั้ง ',
                                //           style: TextStyle(
                                //               fontSize: 14,
                                //               color: Colors.grey,
                                //               fontFamily: Font_.Fonts_T),
                                //         )),
                                //       ],
                                //     ),
                                //     actions: <Widget>[
                                //       Column(
                                //         children: [
                                //           const SizedBox(
                                //             height: 5.0,
                                //           ),
                                //           const Divider(
                                //             color: Colors.grey,
                                //             height: 4.0,
                                //           ),
                                //           const SizedBox(
                                //             height: 5.0,
                                //           ),
                                //           Padding(
                                //             padding: const EdgeInsets.all(8.0),
                                //             child: Row(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.center,
                                //               children: [
                                //                 Padding(
                                //                   padding:
                                //                       const EdgeInsets.all(8.0),
                                //                   child: Container(
                                //                     width: 100,
                                //                     decoration:
                                //                         const BoxDecoration(
                                //                       color: Colors.red,
                                //                       borderRadius:
                                //                           BorderRadius.only(
                                //                               topLeft: Radius
                                //                                   .circular(10),
                                //                               topRight: Radius
                                //                                   .circular(10),
                                //                               bottomLeft: Radius
                                //                                   .circular(10),
                                //                               bottomRight:
                                //                                   Radius
                                //                                       .circular(
                                //                                           10)),
                                //                     ),
                                //                     padding:
                                //                         const EdgeInsets.all(
                                //                             8.0),
                                //                     child: TextButton(
                                //                       onPressed: () async {
                                //                         deall_Trans_select();
                                //                         SharedPreferences
                                //                             preferences =
                                //                             await SharedPreferences
                                //                                 .getInstance();
                                //                         var ser = preferences
                                //                             .getString('ser');
                                //                         var on = '0';
                                //                         String url =
                                //                             '${MyConstant().domain}/U_user_onoff.php?isAdd=true&ser=$ser&on=$on';

                                //                         try {
                                //                           var response =
                                //                               await http.get(
                                //                                   Uri.parse(
                                //                                       url));

                                //                           var result = json
                                //                               .decode(response
                                //                                   .body);
                                //                           print(result);
                                //                           if (result
                                //                                   .toString() ==
                                //                               'true') {
                                //                             SharedPreferences
                                //                                 preferences =
                                //                                 await SharedPreferences
                                //                                     .getInstance();
                                //                             preferences.clear();
                                //                             routToService(
                                //                                 SignInScreen());
                                //                           } else {
                                //                             ScaffoldMessenger
                                //                                     .of(context)
                                //                                 .showSnackBar(
                                //                               SnackBar(
                                //                                   content: Text(
                                //                                       '(ผิดพลาด)')),
                                //                             );
                                //                           }
                                //                         } catch (e) {}
                                //                       },
                                //                       child: const Text(
                                //                         'รับทราบ',
                                //                         style: TextStyle(
                                //                             color: Colors.white,
                                //                             fontWeight:
                                //                                 FontWeight.bold,
                                //                             fontFamily:
                                //                                 FontWeight_
                                //                                     .Fonts_T),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ),
                                //                 // Padding(
                                //                 //   padding:
                                //                 //       const EdgeInsets.all(8.0),
                                //                 //   child: Row(
                                //                 //     mainAxisAlignment:
                                //                 //         MainAxisAlignment
                                //                 //             .center,
                                //                 //     children: [
                                //                 //       Container(
                                //                 //         width: 100,
                                //                 //         decoration:
                                //                 //             const BoxDecoration(
                                //                 //           color:
                                //                 //               Colors.redAccent,
                                //                 //           borderRadius: BorderRadius.only(
                                //                 //               topLeft: Radius
                                //                 //                   .circular(10),
                                //                 //               topRight: Radius
                                //                 //                   .circular(10),
                                //                 //               bottomLeft: Radius
                                //                 //                   .circular(10),
                                //                 //               bottomRight:
                                //                 //                   Radius
                                //                 //                       .circular(
                                //                 //                           10)),
                                //                 //         ),
                                //                 //         padding:
                                //                 //             const EdgeInsets
                                //                 //                 .all(8.0),
                                //                 //         child: TextButton(
                                //                 //           onPressed: () =>
                                //                 //               Navigator.pop(
                                //                 //                   context,
                                //                 //                   'OK'),
                                //                 //           child: const Text(
                                //                 //             'ยกเลิก',
                                //                 //             style: TextStyle(
                                //                 //                 color: Colors
                                //                 //                     .white,
                                //                 //                 fontWeight:
                                //                 //                     FontWeight
                                //                 //                         .bold,
                                //                 //                 fontFamily:
                                //                 //                     FontWeight_
                                //                 //                         .Fonts_T),
                                //                 //           ),
                                //                 //         ),
                                //                 //       ),
                                //                 //     ],
                                //                 //   ),
                                //                 // ),
                                //               ],
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // );
                              },
                              child: const Text(
                                'รับทราบ',
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
                );
              })
        ],
      ),
    );
  }

  // Future<Null> changLogin() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var email = preferences.getString('email');
  //   if (email != 'dzentric.com@gmail.com') {
  //     Timer.periodic(const Duration(seconds: 35), (timer) {
  //       changLoginOut(timer);
  //     });
  //   }
  // }

  // Future<Null> changLoginOut(timer) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var login = preferences.getString('login');
  //   var ipAddress = IpAddress(type: RequestType.json);

  //   /// Get the IpAddress based on requestType.
  //   dynamic data = await ipAddress.getIpAddress();
  //   // print(data.toString());

  //   var data0 = data.toString().substring(5, data.toString().length - 1).trim();
  //   // print(data0.toString());

  //   String url =
  //       '${MyConstant().domain}/changLoginOut.php?isAdd=true&user=$user&iplogin=$data0';
  //   // print(url.toString());

  //   // print('>>>>> login $login');
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print('---------------->');
  //     // print('changLoginOut >$login>$user>');
  //     // print('changLoginOut>$login>$user>>${result.toString()}');
  //     // Auto_Recheck_pay_Beam_Checkout();
  //     if (result.toString() != login) {
  //       deall_Trans_select();
  //       SharedPreferences preferences = await SharedPreferences.getInstance();
  //       preferences.clear();
  //       routToService(LoginPage());
  //       timer.cancel();
  //     }
  //   } catch (e) {}
  // }

  //////////////----------------------------------------->
  // Future<Null> Auto_Recheck_pay_Beam_Checkout() async {
  //   if (_apiCache.isValid('Auto_Recheck_pay_Beam_Checkout')) return null;
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
  //   var Pay_Ke;
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print(result);
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         PayMentModel _PayMentModel = PayMentModel.fromJson(map);

  //         var paykey = _PayMentModel.key_b;
  //         setState(() {
  //           Pay_Ke = paykey.toString();
  //         });
  //       }
  //       // Future.delayed(Duration(seconds: 100), () async {});

  //       // read_CheckBeamAll(ren, Pay_Ke);
  //       if (Pay_Ke == null ||
  //           Pay_Ke.toString() == '' ||
  //           Pay_Ke.toString() == 'null') {
  //       } else {
  //         read_CheckBeamAll(ren, Pay_Ke);
  //       }
  //       // RecheckAuto(ren, Pay_Ke);
  //     }
  //     _apiCache.set('Auto_Recheck_pay_Beam_Checkout');
  //   } catch (e) {}
  // }

  //////////////----------------------------------------->

  Future<Null> deall_Trans_select() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    String url =
        '${MyConstant().domain}/D_tran_select.php?isAdd=true&ren=$ren&user=$user';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
      } else if (result.toString() == 'false') {
        // print('rrrrrrrrrrrrrrfalse');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
      }
    } catch (e) {
      // print('rrrrrrrrrrrrrr $e');
    }
  }

  Future<void> initPlugin() async {
    const model = "Device : ";
    final deviceMarketingNames = DeviceMarketingNames();
    final currentSingleDeviceName = await deviceMarketingNames.getSingleName();
    final currentDeviceNames = await deviceMarketingNames.getNames();
    setState(() {
      singleDeviceName = currentSingleDeviceName;
      deviceNames = currentDeviceNames;
      singleDeviceNameFromModel = deviceMarketingNames.getSingleNameFromModel(
          DeviceType.android, model);
      deviceNamesFromModel =
          deviceMarketingNames.getNamesFromModel(DeviceType.android, model);
    });
  }

  String? connected_Minutes;
  Timer? _sessionTimer;
  bool _checking = false;
  bool _dialogShowing = false;

  void startTimer() {
    // ยิงเช็คครั้งแรก
    upConnected();

    // ตั้ง timer ทุก 30 วิ
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 120), (timer) {
      upConnected();
    });
  }

  Future<bool> upConnected() async {
    final String checkTokenUrl = '${MyConstant().domain_v1}/admin/me';
    final token =
        await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);

    if (token == null || token.isEmpty) {
      //  debugPrint('🔒 No stored token found');
      return false;
    }

    final headers = await MyHeaders.build();
    headers.putIfAbsent('Authorization', () => 'Bearer $token');

    if (_checking) return false; // กันยิงซ้อน
    _checking = true;

    final client = http.Client();
    try {
      final resp = await client
          .get(Uri.parse(checkTokenUrl), headers: headers)
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode == 200) {
        //debugPrint('✅ Token valid, auto-login success');
        _checking = false;
        return true;
      }

      // 401/403: หมดอายุ
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        if (!context.mounted || _dialogShowing) return false;
        _dialogShowing = true;
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Oops",
          message: "เซสชันหมดอายุ กรุณาออกแล้วเข้าระบบใหม่",
          buttonText: "รับทราบ",
          onTapDismiss: () async {
            AuthService.logout();
            if (context.mounted) Navigator.pop(context);
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            preferences.clear();

            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => LoginPage(),
            );
            Navigator.pushAndRemoveUntil(context, route, (route) {
              return false;
            });
            // await AuthService.logout();
            // if (context.mounted) Navigator.pop(context);
            _dialogShowing = false;
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false,
        );
        _checking = false;
        return false;
      }

      // อื่น ๆ
      String msg = 'ไม่สามารถตรวจสอบเซสชันได้ (${resp.statusCode})';
      try {
        final body = jsonDecode(resp.body);
        if (body is Map && body['message'] is String) msg = body['message'];
      } catch (_) {}

      if (context.mounted && !_dialogShowing) {
        _dialogShowing = true;
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "เกิดข้อผิดพลาด",
          message: msg,
          buttonText: "ปิด",
          onTapDismiss: () {
            if (context.mounted) Navigator.pop(context);
            _dialogShowing = false;
          },
          panaraDialogType: PanaraDialogType.warning,
          barrierDismissible: true,
        );
      }
      _checking = false;
      return false;
    } on TimeoutException {
      // debugPrint('⏳ Token check timed out');
      if (context.mounted && !_dialogShowing) {
        _dialogShowing = true;
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "เครือข่ายช้า",
          message: "การตรวจสอบเซสชันหมดเวลา ลองใหม่อีกครั้ง",
          buttonText: "ปิด",
          onTapDismiss: () {
            if (context.mounted) Navigator.pop(context);
            _dialogShowing = false;
          },
          panaraDialogType: PanaraDialogType.warning,
          barrierDismissible: true,
        );
      }
      _checking = false;
      return false;
    } catch (e) {
      // debugPrint('❌ Token check error: $e');
      _checking = false;
      return false;
    } finally {
      client.close();
    }
  }

  // Future<void> upConnected() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   DateTime currentTime = DateTime.now();
  //   String formattedDateTime =
  //       DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);
  //   // print('$ren-----$user ----- ${formattedDateTime}');
  //   // String url =
  //   //     '${MyConstant().domain}/UP_Connected_User.php?isAdd=true&seruser=$user&value=$formattedDateTime';
  //   try {
  //     // var response = await http.get(Uri.parse(url));

  //     // if (response.statusCode == 200) {
  //     //   // Check if the response status code is OK (200)
  //     //   print('Success: ${response.body}');
  //     // } else {
  //     //   // Handle other response status codes if needed
  //     //   print('HTTP Error: ${response.statusCode}');
  //     // }
  //   } catch (e) {
  //     // print('Error: $e');
  //   }
  // }

  String read_data_davtext = '';

  Future<Null> readTime() async {
    var now = DateTime.now();
    var reached = now.compareTo(alert!) >= 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Future.delayed(Duration(seconds: 1), () async {
      setState(() {
        timeoutper = preferences.getInt('timeoutper');
      });
      if (reached) {
        // normalDialog(context, 'Time Out');
        // print('Time Outttt $Value_Route $reached');
      } else {
        // print('${reached.toString()}');

        setState(() {
          // if (timeoutper != null) {
          //   alert = DateTime.now().add(Duration(seconds: timeoutper!));
          // }
          // readTime();

          // preferences.setInt('timeoutper', 100);

          if (timeoutper != null && timeoutper != -5) {
            alert = DateTime.now().add(Duration(seconds: timeoutper ?? 300));
          }
          preferences.setInt('timeoutper', -5);
        });
      }

      var timrNow = DateTime.now();
      String orderDates = DateFormat('yyyy-MM-dd').format(timrNow);
      final eventTime = DateTime.parse('$orderDates 00:00:00');

      const duration = const Duration(seconds: 1);
      int timeDiff = eventTime.difference(DateTime.now()).inSeconds;
      if (timer == null) {
        timer = Timer.periodic(duration, (Timer t) {
          if (timeDiff > 0) {
            if (isActive) {
              setState(() {
                // sharedPreferencesUser();
                if (eventTime != DateTime.now()) {
                  timeDiff = timeDiff - 1;
                } else {
                  // print('Times up!');
                  //Do something
                }
              });
            }
          }
        });
      }

      // int day = eventTime.difference(DateTime.now()).inDays;
      // // timeDiff ~/ (24 * 60 * 60) % 24;
      // int hour = timeDiff ~/ (60 * 60) % 24;
      // int minute = (timeDiff ~/ 60) % 60;
      // int second = timeDiff % 60;

      // setState(() {
      //   days = day;
      //   hours = hour;
      //   minutes = minute;
      //   seconds = second;
      // });
    });
  }

  String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    // We want to round up the remaining time to the nearest second
    d += Duration(microseconds: 999999);
    return "${f((d.inHours) % 24)}:${f((d.inMinutes) % 60)}:${f(d.inSeconds % 60)} \t\t";
  }

  Future<Null> signInThreadMain() async {
    signInThreadCMM();
    // (renTal_user.toString() == '50' || renTal_user.toString() == '139')
    //     ? signInThreadCMM()
    //     : signInThread();
  }

  Future<Null> signInThreadCMM() async {
    //print('signInThreadCMM');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final userStr =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);
    String? _seruser = preferences.getString('ser');

    if (userStr != null) {
      try {
        setState(() {
          position_user = preferences.getString('position');
          fname_user = preferences.getString('fname');
          lname_user = preferences.getString('lname');
          email_user = preferences.getString('email');
          ser_user = preferences.getString('ser');
          utype_user = '';
          permission_user = preferences.getString('permission');
        });
      } catch (e) {}
    }
    setState(() {
      read_GC_permission();
    });
  }

  // ❌ Dead code — signInThreadMain() เรียก signInThreadCMM() เท่านั้น ไม่เคยเรียก signInThread()
  // Future<Null> signInThread() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //
  //   String? _seruser = preferences.getString('ser');
  //   String url =
  //       '${MyConstant().domain}/GC_userHome.php?isAdd=true&ser=$_seruser';
  //
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //
  //     var result = json.decode(response.body);
  //     // print(result);
  //     for (var map in result) {
  //       UserModel userModel = UserModel.fromJson(map);
  //       setState(() {
  //         position_user = userModel.position;
  //         fname_user = userModel.fname;
  //         lname_user = userModel.lname;
  //         email_user = userModel.email;
  //         ser_user = userModel.ser;
  //         utype_user = userModel.utype;
  //         permission_user = userModel.permission;
  //       });
  //     }
  //     setState(() {
  //       read_GC_permission();
  //     });
  //   } catch (e) {}
  // }

/////----------------------------------->
  List<String> translate_menu = [];
  String more_menu = 'อื่นๆ';
/////----------------------------------->
  Future<Null> read_GC_permission() async {
    String cacheKey = 'read_GC_permission_all';

    if (permission_user != '0') {
      final preferences = await SharedPreferences.getInstance();
      final permission_userx = preferences.getString('permission') ?? '';

      List<String> permissions = permission_userx
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      String ser = permissions.join(',');
      cacheKey = 'read_GC_permission_$ser';
    }

    if (_apiCache.isValid(cacheKey)) {
      final cached = _apiCache.get(cacheKey);
      if (cached != null) {
        if (perMissionModels.isNotEmpty) {
          translate_menu.clear();
          perMissionModels.clear();
        }

        for (var map in cached) {
          PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
          perMissionModels.add(perMissionModel);
          translate_menu.add(await translateText('${perMissionModel.perm}'));
        }

        more_menu = await translateText('อื่นๆ');

        setState(() {
          perMissioncount = perMissionModels.length;
        });
        return null;
      }
    }

    startTimer();

    if (perMissionModels.isNotEmpty) {
      translate_menu.clear();
      perMissionModels.clear();
    }

    try {
      String url = '';

      if (permission_user == '0') {
        url = '${MyConstant().domain}/GC_permission_cmm.php?isAdd=true';
      } else {
        final preferences = await SharedPreferences.getInstance();
        final permission_userx = preferences.getString('permission') ?? '';

        List<String> permissions = permission_userx
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        String ser = permissions.join(',');

        url =
            '${MyConstant().domain}/GC_permission_cmm.php?isAdd=true&ser=$ser';
      }

      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      _apiCache.set(cacheKey, result);

      for (var map in result) {
        PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
        perMissionModels.add(perMissionModel);

        translate_menu.add(await translateText('${perMissionModel.perm}'));
      }

      more_menu = await translateText('อื่นๆ');

      setState(() {
        perMissioncount = perMissionModels.length;
      });
    } catch (e) {
      print('read_GC_permission error: $e');
    }

    return null;
  }
  // Future<Null> read_GC_permission() async {
  //   if (_apiCache.isValid('read_GC_permission')) {
  //     final cached = _apiCache.get('read_GC_permission');
  //     if (cached != null) {
  //       if (perMissionModels.isNotEmpty) {
  //         translate_menu.clear();
  //         perMissionModels.clear();
  //       }
  //       for (var map in cached) {
  //         PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
  //         perMissionModels.add(perMissionModel);
  //         translate_menu.add(await translateText('${perMissionModel.perm}'));
  //       }
  //       more_menu = await translateText('อื่นๆ');
  //       setState(() {
  //         perMissioncount = perMissionModels.length;
  //       });
  //       return null;
  //     }
  //   }

  //   startTimer();

  //   if (perMissionModels.isNotEmpty) {
  //     translate_menu.clear();
  //     perMissionModels.clear();
  //   }

  //   try {
  //     String url = '';

  //     if (permission_user == '0') {
  //       url = '${MyConstant().domain}/GC_permission_cmm.php?isAdd=true';
  //     } else {
  //       final preferences = await SharedPreferences.getInstance();
  //       final permission_userx = preferences.getString('permission') ?? '';

  //       List<String> permissions = permission_userx
  //           .split(',')
  //           .map((e) => e.trim())
  //           .where((e) => e.isNotEmpty)
  //           .toList();

  //       // รวมส่งครั้งเดียว เช่น ser=1,2,3,4
  //       String ser = permissions.join(',');

  //       url =
  //           '${MyConstant().domain}/GC_permission_cmm.php?isAdd=true&ser=$ser';
  //     }

  //     var response = await http.get(Uri.parse(url));
  //     var result = json.decode(response.body);
  //     _apiCache.set('read_GC_permission', result);

  //     for (var map in result) {
  //       PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
  //       perMissionModels.add(perMissionModel);

  //       translate_menu.add(await translateText('${perMissionModel.perm}'));
  //     }

  //     more_menu = await translateText('อื่นๆ');

  //     setState(() {
  //       perMissioncount = perMissionModels.length;
  //     });
  //   } catch (e) {
  //     print('read_GC_permission error: $e');
  //   }

  //   return null;
  // }

  // Future<Null> read_GC_permission() async {
  //   if (_apiCache.isValid('read_GC_permission')) return null;
  //   startTimer();
  //   if (perMissionModels.length != 0) {
  //     translate_menu.clear();
  //     perMissionModels.clear();
  //   }
  //   if (permission_user == '0') {
  //     String url = '${MyConstant().domain}/GC_permission_cmm.php?isAdd=true';

  //     try {
  //       var response = await http.get(Uri.parse(url));

  //       var result = json.decode(response.body);
  //       // print(result);
  //       for (var map in result) {
  //         PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
  //         setState(() {
  //           perMissionModels.add(perMissionModel);
  //         });
  //         translate_menu.add(await translateText('${perMissionModel.perm}'));
  //       }
  //       var more_menu2 = await translateText('อื่นๆ');
  //       setState(() {
  //         more_menu = more_menu2;
  //       });
  //     } catch (e) {}
  //   } else {
  //     final preferences = await SharedPreferences.getInstance();
  //     final permission_userx = preferences.getString('permission');
  //     List<String> permissions =
  //         (renTal_user.toString() == '50' || renTal_user.toString() == '139')
  //             ? (permission_userx!.split(','))
  //             : (permission_userx!.split(','));
  //     for (var i = 0; i < permissions.length; i++) {
  //       var permission = permissions[i];
  //       String url =
  //           '${MyConstant().domain}/GC_permission_cmm.php?isAdd=true&ser=$permission';

  //       try {
  //         var response = await http.get(Uri.parse(url));

  //         var result = json.decode(response.body);
  //         // print(result);
  //         for (var map in result) {
  //           PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
  //           setState(() {
  //             perMissionModels.add(perMissionModel);
  //           });
  //           translate_menu.add(await translateText('${perMissionModel.perm}'));
  //         }
  //         var more_menu2 = await translateText('อื่นๆ');
  //         setState(() {
  //           more_menu = more_menu2;
  //         });
  //       } catch (e) {}
  //     }
  //   }
  //   setState(() {
  //     perMissioncount = perMissionModels.length;
  //   });
  //   _apiCache.set('read_GC_permission');

  //   // print('perMissionModels  == > ${perMissionModels.length}');
  // }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var rser = preferences.getString('rser');
    var utype = preferences.getString('utype');
    var muser = preferences.getString('Muser');
    if (utype == 'MS') {
      if (preferences.getString('renTalSer') == null) {
        setState(() {
          preferences.setString('renTalSer', rser.toString());
          renTal_user = preferences.getString('renTalSer');
          renTal_lavel =
              int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
        });
      } else {
        setState(() {
          renTal_user = preferences.getString('renTalSer');
          renTal_name = preferences.getString('renTalName');
          renTal_lavel =
              int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
        });
      }
    } else {
      if (rser == '0') {
        setState(() {
          renTal_user = preferences.getString('renTalSer');
          renTal_name = preferences.getString('renTalName');
          renTal_lavel =
              int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
        });
      } else {
        setState(() {
          preferences.setString('renTalSer', rser.toString());
          renTal_user = preferences.getString('renTalSer');
          renTal_lavel =
              int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
        });
      }
    }

    //print('renTal_lavel>>> $renTal_lavel');
    setState(() {
      // passcode_in call removed
    });
    // System_User call removed
  }

  // List MenuList_ = [
  //   'หน้าหลัก',
  //   'พื้นที่เช่า',
  //   'ผู้เช่า',
  //   'บัญชี',
  //   'จัดการ',
  //   'รายงาน',
  //   'ตั้งค่า',
  // ];
  List Menu_IconList_ = [
    Icons.home,
    Icons.location_pin,
    Icons.person,
    Icons.calendar_month,
    Icons.key,
    Icons.inventory,
    Icons.settings,
  ];
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

  Future<void> _showMyDialogImg(String Url, String title_) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Center(
              child: Text(
            title_.toString(),
            style: const TextStyle(
              // fontSize: 15,
              color: Colors.black,
              fontFamily: Font_.Fonts_T,
              fontWeight: FontWeight.bold,
            ),
          )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                InteractiveViewer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: (img_logo == null || img_logo.toString() == '')
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.black,
                            ),
                          )
                        : Image.network(
                            '$Url',
                            fit: BoxFit.contain,
                          ),
                  ),
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 5.0,
                  transformationController: TransformationController()
                    ..value =
                        Matrix4.diagonal3Values(_scaleFactor, _scaleFactor, 1),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // StreamBuilder(
            //     stream: Stream.periodic(const Duration(milliseconds: 0)),
            //     builder: (
            //       context,
            //       snapshot,
            //     ) {
            //       return SizedBox(
            //         child: Row(
            //           children: [
            //             IconButton(
            //               icon: Icon(Icons.add),
            //               onPressed: _zoomIn,
            //             ),
            //             IconButton(
            //               icon: Icon(Icons.remove),
            //               onPressed: _zoomOut,
            //             ),
            //           ],
            //         ),
            //       );
            //     }),
            GestureDetector(
              child: Container(
                width: 150,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(4.0),
                child: const Center(
                  child: Text(
                    'ปิด',
                    style: TextStyle(
                      // fontSize: 15,
                      color: Colors.white,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final Dev_text = TextEditingController();
  Future<void> _showMyDialogDev(type_dev) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Translate.TranslateAndSetText(
                      'แจ้งเตือน',
                      Colors.white,
                      TextAlign.center,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: Dev_text,
                      onSaved: (String? value) {
                        // This optional block of code can be used to run
                        // code when the user saves the form.
                      },
                      validator: (String? value) {
                        return (value != null && value.contains('@'))
                            ? 'Do not use the @ char.'
                            : null;
                      },
                      decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.3),
                          filled: true,
                          prefixIcon:
                              const Icon(Icons.chat, color: Colors.black),
                          // suffixIcon: Icon(Icons.clear, color: Colors.black),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black,
                            ),
                          ),
                          errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black,
                            ),
                          ),
                          labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontFamily: Font_.Fonts_T)),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Container(
                      width: 250,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Translate.TranslateAndSetText(
                            'บันทึกข้อความแจ้งเตือน',
                            Colors.white,
                            TextAlign.center,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                      ),
                    ),
                    onTap: () async {
                      if (Dev_text.text != '') {
                        String url =
                            '${MyConstant().domain}/Awat_UP_sytem.php?isAdd=true&dev_tex=${Dev_text.text}&ser_ren=$ren&dev_type=$type_dev';

                        try {
                          var response = await http.get(Uri.parse(url));

                          var result = json.decode(response.body);
                          if (result.toString() == 'true') {
                            setState(() {
                              Dev_text.clear();
                            });
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          setState(() {
                            Dev_text.clear();
                          });
                        }
                      } else {}
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Container(
                      width: 250,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Translate.TranslateAndSetText(
                            'ยกเลิกข้อความแจ้งเตือน',
                            Colors.white,
                            TextAlign.center,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                      ),
                    ),
                    onTap: () async {
                      String tex_t = '';
                      String url =
                          '${MyConstant().domain}/Awat_UP_sytem.php?isAdd=true&dev_tex=${tex_t}&ser_ren=$ren&dev_type=$type_dev';

                      try {
                        var response = await http.get(Uri.parse(url));

                        var result = json.decode(response.body);
                        if (result.toString() == 'true') {
                          setState(() {
                            Dev_text.clear();
                          });
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        setState(() {
                          Dev_text.clear();
                        });
                      }
                    },
                  ),
                ),
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
                if (type_dev.toString() == '0')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      child: Container(
                        width: 250,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              'แจ้งเตือน Dialog หลังอัพเดต',
                              Colors.white,
                              TextAlign.center,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              14,
                              1),
                        ),
                      ),
                      onTap: () async {
                        DateTime now = DateTime.now();
                        String formattedDate =
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

                        String url =
                            '${MyConstant().domain}/OK_UP_sytem.php?isAdd=true&datex=${formattedDate}';

                        try {
                          var response = await http.get(Uri.parse(url));

                          var result = json.decode(response.body);
                          if (result.toString() == 'true') {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {}
                      },
                    ),
                  ),
                const SizedBox(
                  height: 5.0,
                ),
                if (type_dev.toString() == '0')
                  const Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                const SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Container(
                width: 100,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Translate.TranslateAndSetText(
                      'ปิด',
                      Colors.white,
                      TextAlign.center,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void changeColor() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Color tiTileColorss1 = Color.fromARGB(255, 203, 200, 219);
    Color tiTileColorss2 = Color(0xFFD9D9B7);

    setState(() {
      if (AppbackgroundColor.TiTile_Colors == tiTileColorss1) {
        AppbackgroundColor.TiTile_Colors = tiTileColorss2;
      } else {
        AppbackgroundColor.TiTile_Colors = tiTileColorss1;
      }
    });
    String? _route = preferences.getString('route');
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
        builder: (BuildContext context) => AdminScafScreen(route: _route));
    Navigator.pushAndRemoveUntil(context, materialPageRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context))
      // print(
      //     '$position_user, $fname_user, $lname_user,$email_user, $utype_user, $permission_user');
      setState(() {
        // if (passcode == null) {
        //   passcode_in(); // ❌ ดึงซ้ำทุกรอบ build → ย้ายไปเรียกใน checkPreferance() แล้ว
        // }

        serBody_modile_wiget = 0;
      });
    if (perMissionModels.length < perMissioncount!) {
      return Center(
        child: const CircularProgressIndicator(),
      );
    }
    return WillPopScope(
      onWillPop: () async => false, // ❌ กด back ไม่ทำงาน
      child: Scaffold(
        // appBar: AppBar(
        //   automaticallyImplyLeading: false, // ❌ ซ่อนปุ่ม back บน AppBar
        //   title: const Text("Home"),
        // ),
        body: (Responsive.isDesktop(context)) ? adminweb() : adminmobile(),
      ),
    );
    // return (Responsive.isDesktop(context)) ? adminweb() : adminmobile();
  }

  AdminScaffold adminweb() {
    return AdminScaffold(
      backgroundColor: AppbackgroundColor.Abg_Colors,
      leadingIcon: IconButton(
        // icon: Icon(isSidebarOpen ? Icons.menu : Icons.menu),
        tooltip: isSidebarOpen ? 'ซ่อนเมนู' : 'แสดงเมนู',
        // onPressed:
        //     _toggleSidebar, // สลับค่า isSidebarOpen แล้ว setState + (ถ้าเก็บ prefs ก็เซฟ)
        icon: Icon(!context.watch<SidebarController>().isOpen
            ? Icons.menu_open
            : Icons.menu),
        onPressed: () => context.read<SidebarController>().toggle(),
      ),
      appBar: AppBar(
        excludeHeaderSemantics: false,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.black,
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 50.2,
        // toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
          ),
        ),
        leading: IconButton(
          icon: Icon(isSidebarOpen ? Icons.menu_open : Icons.menu_open),
          onPressed: () => context.read<SidebarController>().toggle(),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (Responsive.isDesktop(context))
                        (img_logo == null || img_logo.toString() == '')
                            ? SizedBox()
                            : GestureDetector(
                                child: CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: NetworkImage(
                                      '${MyConstant().domain}/files/$foder/logo/$img_logo'),
                                  backgroundColor: Colors.transparent,
                                  onBackgroundImageError: (_, __) {},
                                ),
                                onTap: () {
                                  if (img_logo == null ||
                                      img_logo.toString() == '') {
                                  } else {
                                    String url =
                                        '${MyConstant().domain}/files/$foder/logo/$img_logo';
                                    _showMyDialogImg(
                                        url,
                                        renTal_name == null
                                            ? ' '
                                            : ' $renTal_name');
                                  }
                                },
                              ),
                      GestureDetector(
                        child: Text(
                          renTal_name == null ? ' ภาพรวม' : ' $renTal_name',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: (Responsive.isDesktop(context))
                                  ? FontWeight.bold
                                  : null,
                              fontSize:
                                  (Responsive.isDesktop(context)) ? null : 12,
                              fontFamily: FontWeight_.Fonts_T),
                        ),
                        onTap: () {
                          if (img_logo == null || img_logo.toString() == '') {
                          } else {
                            String url =
                                '${MyConstant().domain}/files/$foder/logo/$img_logo';
                            _showMyDialogImg(url,
                                renTal_name == null ? ' ' : ' $renTal_name');
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
        ),
        actions: [
          Row(
            children: [
              StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 0)),
                  builder: (context, snapshot) {
                    return Row(
                      children: [
                        if (!Responsive.isMobile(context) &&
                            read_data_davtext != '')
                          Container(
                            decoration: BoxDecoration(
                              // color: Colors.white.withOpacity(0.3),
                              // Colors.lightGreen[200],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border:
                              //     Border.all(color: Colors.grey, width: 0.5),
                            ),
                            width: (Responsive.isDesktop(context))
                                ? MediaQuery.of(context).size.width / 4
                                : MediaQuery.of(context).size.width / 2,
                            child: Marquee(
                              text:
                                  '   📢 แจ้งเตือน : $read_data_davtext     ||   ',

                              // text: '$read_data_davtext',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 253, 253, 253),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // blankSpace: 20.0,
                              // velocity: 100.0,
                              pauseAfterRound: Duration(seconds: 1),
                              // startPadding: 10.0,
                              // accelerationDuration: Duration(seconds: 5),
                              accelerationCurve: Curves.linear,
                              decelerationDuration: Duration(seconds: 5),
                              decelerationCurve: Curves.easeInOut,
                            ),
                          ),
                      ],
                    );
                  }),
              // StreamBuilder(
              //     stream: Stream.periodic(const Duration(seconds: 1)),
              //     builder: (context, snapshot) {
              //       return Container(
              //         decoration: BoxDecoration(
              //           // color: Colors.white.withOpacity(0.7),
              //           // Colors.lightGreen[200],
              //           borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(10),
              //               topRight: Radius.circular(10),
              //               bottomLeft: Radius.circular(10),
              //               bottomRight: Radius.circular(10)),
              //           // border: Border.all(color: Colors.grey, width: 0.5),
              //         ),
              //         padding: const EdgeInsets.all(0.5),
              //         child: Container(
              //           width: 100,
              //           child: Row(
              //             children: [
              //               Expanded(
              //                 flex: 1,
              //                 child: Icon(
              //                   Icons.sunny,
              //                   size: 15.0,
              //                   color: (AppbackgroundColor.TiTile_Colors ==
              //                           Color.fromARGB(255, 203, 200, 219))
              //                       ? Colors.white
              //                       : Colors.orange,
              //                 ),
              //               ),
              //               (isDark_Mode == true)
              //                   ? InkWell(
              //                       onTap: () async {
              //                         SharedPreferences preferences =
              //                             await SharedPreferences.getInstance();
              //                         setState(() {
              //                           preferences.setBool(
              //                               'isDarkMode', false);
              //                         });
              //                         // print(preferences.getBool('isDarkMode'));
              //                         // print(isDark_Mode);
              //                         String? _route =
              //                             preferences.getString('route');
              //                         MaterialPageRoute materialPageRoute =
              //                             MaterialPageRoute(
              //                                 builder: (BuildContext context) =>
              //                                     AdminScafScreen(
              //                                         route: _route));
              //                         Navigator.pushAndRemoveUntil(context,
              //                             materialPageRoute, (route) => false);
              //                         // changeColor();
              //                       },
              //                       child: Icon(
              //                         Icons.toggle_on,
              //                         color: Colors.yellow[100],
              //                         size: 35.0,
              //                       ),
              //                     )
              //                   : InkWell(
              //                       onTap: () async {
              //                         SharedPreferences preferences =
              //                             await SharedPreferences.getInstance();
              //                         setState(() {
              //                           preferences.setBool('isDarkMode', true);
              //                         });

              //                         print(preferences.getBool('isDarkMode'));
              //                         String? _route =
              //                             preferences.getString('route');
              //                         MaterialPageRoute materialPageRoute =
              //                             MaterialPageRoute(
              //                                 builder: (BuildContext context) =>
              //                                     AdminScafScreen(
              //                                         route: _route));
              //                         Navigator.pushAndRemoveUntil(context,
              //                             materialPageRoute, (route) => false);
              //                         // changeColor();
              //                       },
              //                       child: Icon(
              //                         Icons.toggle_off,
              //                         color: Colors.orange[100],
              //                         size: 35.0,
              //                       ),
              //                     ),
              //               // (AppbackgroundColor.TiTile_Colors ==
              //               //         Color.fromARGB(255, 203, 200, 219))
              //               //     ? InkWell(
              //               //         onTap: () {
              //               //           changeColor();
              //               //         },
              //               //         child: Icon(
              //               //           Icons.toggle_on,
              //               //           color: Colors.yellow[100],
              //               //           size: 35.0,
              //               //         ),
              //               //       )
              //               //     : InkWell(
              //               //         onTap: () {
              //               //           changeColor();
              //               //         },
              //               //         child: Icon(
              //               //           Icons.toggle_off,
              //               //           color: Colors.orange[100],
              //               //           size: 35.0,
              //               //         ),
              //               //       ),
              //               Expanded(
              //                   flex: 1,
              //                   child: Icon(
              //                     Icons.bedtime,
              //                     size: 15.0,
              //                     color: (AppbackgroundColor.TiTile_Colors ==
              //                             Color(0xFFD9D9B7))
              //                         ? Colors.white
              //                         : Colors.yellow,
              //                   )),
              //             ],
              //           ),
              //         ),
              //       );
              //     }),
              if (pkldate != null)
                if (datex.isAfter(DateTime.parse(pkldate == '0000-00-00'
                            ? '$data_update'
                            : '$pkldate 00:00:00.000')
                        .subtract(const Duration(days: 7))) ==
                    true)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        MaterialPageRoute route = MaterialPageRoute(
                          builder: (context) => SignInLicense(route: 'Yes'),
                        );
                        Navigator.pushAndRemoveUntil(
                            context, route, (route) => true);
                      },
                      child: Container(
                        width: 50,
                        // color: Colors.yellow,
                        child: Center(
                          child: Icon(
                            Icons.vpn_key,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

              (Responsive.isDesktop(context) &&
                      (ser_user == '63' ||
                          ser_user == '56' ||
                          ser_user == '61' ||
                          ser_user == '37' ||
                          ser_user == '268'))
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          _showMyDialogDev(0);
                        },
                        child: Container(
                          color: Colors.yellow,
                          child: Center(
                              child: Text(
                            '  DEV  ',
                            style: TextStyle(
                                color: AdminScafScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T),
                          )),
                        ),
                      ),
                    )
                  : (renTal_lavel.toString() != '5')
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              _showMyDialogDev(1);
                            },
                            child: CircleAvatar(
                              // radius: 15.0,
                              backgroundColor: Colors.deepOrange,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            //
                          ),
                        ),
              // ChatScreen(
              //     ser_user: ser_user,
              //     userModels_chat_: userModels_chat,
              //     userModels_: userModels),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  // Colors.lightGreen[200],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(0)),
                  // border: Border.all(color: Colors.grey, width: 0.5),
                ),
                padding: const EdgeInsets.all(0.5),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Icon(
                          Icons.person_4_rounded,
                          // Icons.translate,
                          color: Colors.indigo[600],
                          size: 20,
                        ),
                      ),
                    ),

                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(4, 1, 2, 1),
                    //   child: InkWell(
                    //     onTap: () async {
                    //       SharedPreferences preferences =
                    //           await SharedPreferences.getInstance();
                    //       var Lang = preferences.getString('Language');
                    //       List supportedLocales = [
                    //         {
                    //           "ser": "1",
                    //           "code": "th",
                    //           "ln": "ไทย",
                    //           "url": "images/Thailand.png"
                    //         },
                    //         {
                    //           "ser": "2",
                    //           "code": "en",
                    //           "ln": "English",
                    //           "url": "images/English.png"
                    //         },
                    //         {
                    //           "ser": "3",
                    //           "code": "lo",
                    //           "ln": "ລາວ",
                    //           "url": "images/LAO.png"
                    //         },
                    //         {
                    //           "ser": "4",
                    //           "code": "ko",
                    //           "ln": "Korea",
                    //           "url": "images/Korea.png"
                    //         },
                    //         {
                    //           "ser": "5",
                    //           "code": "ja",
                    //           "ln": "Japanese",
                    //           "url": "images/Jpan.png"
                    //         },
                    //         {
                    //           "ser": "6",
                    //           "code": "zh-cn",
                    //           "ln": "China",
                    //           "url": "images/Chaina.png"
                    //         },
                    //       ];

                    //       showDialog<String>(
                    //         context: context,
                    //         builder: (BuildContext context) => AlertDialog(
                    //           backgroundColor:
                    //               Color.fromARGB(255, 247, 246, 246),
                    //           titlePadding: const EdgeInsets.all(0.0),
                    //           contentPadding: const EdgeInsets.all(10.0),
                    //           actionsPadding: const EdgeInsets.all(6.0),
                    //           shape: const RoundedRectangleBorder(
                    //               borderRadius:
                    //                   BorderRadius.all(Radius.circular(20.0))),
                    //           title: Row(
                    //             mainAxisAlignment: MainAxisAlignment.end,
                    //             children: [
                    //               InkWell(
                    //                 onTap: () async {
                    //                   Navigator.pop(context);
                    //                 },
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.all(4.0),
                    //                   child: Icon(Icons.highlight_off,
                    //                       size: 30, color: Colors.red[700]),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           content: SingleChildScrollView(
                    //             child: ListBody(
                    //               children: <Widget>[
                    //                 SizedBox(
                    //                   height: 20,
                    //                 ),
                    //                 for (int index = 0;
                    //                     index < supportedLocales.length;
                    //                     index++)
                    //                   Padding(
                    //                     padding: const EdgeInsets.all(4.0),
                    //                     child: ListTile(
                    //                         onTap: () async {
                    //                           SharedPreferences preferences =
                    //                               await SharedPreferences
                    //                                   .getInstance();
                    //                           setState(() {
                    //                             preferences.setString(
                    //                                 'Language',
                    //                                 '${supportedLocales[index]['code']}');
                    //                           });
                    //                           Navigator.pop(context);

                    //                           String? _route = preferences
                    //                               .getString('route');

                    //                           MaterialPageRoute route =
                    //                               MaterialPageRoute(
                    //                             builder: (context) =>
                    //                                 AdminScafScreen(
                    //                                     route: _route),
                    //                           );
                    //                           Navigator.pushAndRemoveUntil(
                    //                               context,
                    //                               route,
                    //                               (route) => false);
                    //                         },
                    //                         title: Container(
                    //                           decoration: BoxDecoration(
                    //                             color: Lang.toString() ==
                    //                                     '${supportedLocales[index]['code']}'
                    //                                 ? Colors.green[400]
                    //                                 : Colors.white,
                    //                             borderRadius:
                    //                                 const BorderRadius.only(
                    //                               topLeft: Radius.circular(10),
                    //                               topRight: Radius.circular(10),
                    //                               bottomLeft:
                    //                                   Radius.circular(10),
                    //                               bottomRight:
                    //                                   Radius.circular(10),
                    //                             ),
                    //                             border: Border.all(
                    //                                 color: Colors.grey,
                    //                                 width: 0.5),
                    //                             // border: Border(
                    //                             //   bottom: BorderSide(
                    //                             //     //                    <--- top side
                    //                             //     width: 0.5,
                    //                             //   ),
                    //                             // )
                    //                           ),
                    //                           padding:
                    //                               const EdgeInsets.all(4.0),
                    //                           width: 270,
                    //                           child: Row(
                    //                             children: [
                    //                               // Icon(
                    //                               //   Iconsax.check,
                    //                               //   // color: getRandomColor(index)
                    //                               // ),
                    //                               CircleAvatar(
                    //                                 radius: 15,
                    //                                 backgroundImage: AssetImage(
                    //                                     '${supportedLocales[index]['url']}'),
                    //                               ),
                    //                               Expanded(
                    //                                 child: Padding(
                    //                                   padding: const EdgeInsets
                    //                                           .fromLTRB(
                    //                                       10, 4, 4, 4),
                    //                                   child: Text(
                    //                                     '${supportedLocales[index]['ln']}',
                    //                                     overflow: TextOverflow
                    //                                         .ellipsis,
                    //                                     style: const TextStyle(
                    //                                         color: PeopleChaoScreen_Color
                    //                                             .Colors_Text2_,
                    //                                         fontWeight:
                    //                                             FontWeight.bold,
                    //                                         fontFamily:
                    //                                             FontWeight_
                    //                                                 .Fonts_T),
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                             ],
                    //                           ),
                    //                         )),
                    //                   ),
                    //                 SizedBox(
                    //                   height: 20,
                    //                 ),
                    //                 Center(
                    //                   child: Text(
                    //                     '# Comming soon.. ',
                    //                     overflow: TextOverflow.ellipsis,
                    //                     style: const TextStyle(
                    //                         color: Colors.red,
                    //                         fontFamily: Font_.Fonts_T),
                    //                   ),
                    //                 ),
                    //                 Center(
                    //                   child: Text(
                    //                     '(ขออภัยยังไม่สามารถใช้งานได้ ณ ขณะนี้)',
                    //                     overflow: TextOverflow.ellipsis,
                    //                     style: const TextStyle(
                    //                         color: Colors.red,
                    //                         fontFamily: Font_.Fonts_T),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         color: Colors.white60,
                    //         borderRadius: BorderRadius.only(
                    //             topLeft: Radius.circular(20),
                    //             topRight: Radius.circular(20),
                    //             bottomLeft: Radius.circular(20),
                    //             bottomRight: Radius.circular(20)),
                    //       ),
                    //       padding: const EdgeInsets.all(4.0),
                    //       child:
                    // Icon(
                    //         Icons.g_translate,
                    //         // Icons.translate,
                    //         color: Colors.indigo[600],
                    //         size: 20,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(4, 1, 0, 1),
                    //   child: StreamBuilder(
                    //       stream: Stream.periodic(const Duration(seconds: 4)),
                    //       builder: (context, snapshot) {
                    //         return ChatScreen(
                    //             ser_user: ser_user,
                    //             userModels_chat_: userModels_chat,
                    //             userModels_: userModels);
                    //       }),
                    // ),
                    // StreamBuilder(
                    //     stream: Stream.periodic(const Duration(seconds: 0)),
                    //     builder: (context, snapshot) {
                    //       return Padding(
                    //         padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    //         child: InkWell(
                    //             onTap: renTal_name == null
                    //                 ? null
                    //                 : () async {
                    //                     startTimer();
                    //                     showDialog<String>(
                    //                       context: context,
                    //                       builder: (BuildContext context) =>
                    //                           AlertDialog(
                    //                         shape: const RoundedRectangleBorder(
                    //                             borderRadius: BorderRadius.all(
                    //                                 Radius.circular(20.0))),
                    //                         title: Center(
                    //                           child:
                    //                               Translate.TranslateAndSetText(
                    //                                   'ผู้ใช้งานระบบขณะนี้ ',
                    //                                   AdminScafScreen_Color
                    //                                       .Colors_Text1_,
                    //                                   TextAlign.center,
                    //                                   FontWeight.bold,
                    //                                   FontWeight_.Fonts_T,
                    //                                   14,
                    //                                   1),
                    //                         ),
                    //                         content: ScrollConfiguration(
                    //                           behavior: ScrollConfiguration.of(
                    //                                   context)
                    //                               .copyWith(dragDevices: {
                    //                             PointerDeviceKind.touch,
                    //                             PointerDeviceKind.mouse,
                    //                           }),
                    //                           child: SingleChildScrollView(
                    //                             scrollDirection:
                    //                                 Axis.horizontal,
                    //                             dragStartBehavior:
                    //                                 DragStartBehavior.start,
                    //                             child: Row(
                    //                               children: [
                    //                                 Container(
                    //                                   width: (Responsive
                    //                                           .isDesktop(
                    //                                               context))
                    //                                       ? MediaQuery.of(
                    //                                                   context)
                    //                                               .size
                    //                                               .width *
                    //                                           0.85
                    //                                       : 800,
                    //                                   child: StreamBuilder(
                    //                                       stream:
                    //                                           Stream.periodic(
                    //                                               const Duration(
                    //                                                   seconds:
                    //                                                       0)),
                    //                                       builder: (context,
                    //                                           snapshot) {
                    //                                         return Column(
                    //                                           children: [
                    //                                             Row(
                    //                                               children: [
                    //                                                 Translate.TranslateAndSetText(
                    //                                                     'ทั้งหมด : ${userModels.length} คน',
                    //                                                     AdminScafScreen_Color
                    //                                                         .Colors_Text1_,
                    //                                                     TextAlign
                    //                                                         .center,
                    //                                                     FontWeight
                    //                                                         .bold,
                    //                                                     FontWeight_
                    //                                                         .Fonts_T,
                    //                                                     14,
                    //                                                     1),
                    //                                               ],
                    //                                             ),
                    //                                             Container(
                    //                                               decoration:
                    //                                                   BoxDecoration(
                    //                                                 color: AppbackgroundColor
                    //                                                     .TiTile_Colors,
                    //                                                 borderRadius:
                    //                                                     BorderRadius
                    //                                                         .only(
                    //                                                   topLeft: Radius
                    //                                                       .circular(
                    //                                                           10),
                    //                                                   topRight:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   bottomLeft:
                    //                                                       Radius.circular(
                    //                                                           0),
                    //                                                   bottomRight:
                    //                                                       Radius.circular(
                    //                                                           0),
                    //                                                 ),
                    //                                                 // border: Border.all(
                    //                                                 //     color: Colors.grey, width: 1),
                    //                                               ),
                    //                                               padding:
                    //                                                   const EdgeInsets
                    //                                                           .all(
                    //                                                       8.0),
                    //                                               child: Row(
                    //                                                 children: [
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       '...',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       'Email',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child: Translate.TranslateAndSetText(
                    //                                                         'ชื่อ',
                    //                                                         AdminScafScreen_Color.Colors_Text1_,
                    //                                                         TextAlign.center,
                    //                                                         FontWeight.bold,
                    //                                                         FontWeight_.Fonts_T,
                    //                                                         14,
                    //                                                         1),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child: Translate.TranslateAndSetText(
                    //                                                         'ตำแหน่ง',
                    //                                                         AdminScafScreen_Color.Colors_Text1_,
                    //                                                         TextAlign.center,
                    //                                                         FontWeight.bold,
                    //                                                         FontWeight_.Fonts_T,
                    //                                                         14,
                    //                                                         1),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child: Translate.TranslateAndSetText(
                    //                                                         'เวลาอัพเดตล่าสุด',
                    //                                                         AdminScafScreen_Color.Colors_Text1_,
                    //                                                         TextAlign.center,
                    //                                                         FontWeight.bold,
                    //                                                         FontWeight_.Fonts_T,
                    //                                                         14,
                    //                                                         1),
                    //                                                   ),
                    //                                                 ],
                    //                                               ),
                    //                                             ),
                    //                                             Container(
                    //                                                 height: MediaQuery.of(context)
                    //                                                         .size
                    //                                                         .height *
                    //                                                     0.4,
                    //                                                 width: (Responsive.isDesktop(
                    //                                                         context))
                    //                                                     ? MediaQuery.of(context).size.width *
                    //                                                         0.85
                    //                                                     : 800,
                    //                                                 child: ListView.builder(
                    //                                                     padding: const EdgeInsets.all(8),
                    //                                                     itemCount: userModels.length,
                    //                                                     itemBuilder: (BuildContext context, int index) {
                    //                                                       String
                    //                                                           email =
                    //                                                           '${userModels[index].email}';
                    //                                                       int emailLength =
                    //                                                           email.length;
                    //                                                       String
                    //                                                           firstTwoCharacters =
                    //                                                           email.substring(0, 2);
                    //                                                       String
                    //                                                           lastFourCharacters =
                    //                                                           email.substring(emailLength - 4);
                    //                                                       String
                    //                                                           censoredEmail =
                    //                                                           '$firstTwoCharacters${'*' * (emailLength - 6)}$lastFourCharacters';

                    //                                                       String
                    //                                                           connected_ =
                    //                                                           '${userModels[index].connected}';

                    //                                                       DateTime
                    //                                                           connectedTime =
                    //                                                           DateTime.parse(connected_);

                    //                                                       DateTime
                    //                                                           currentTime =
                    //                                                           DateTime.now();

                    //                                                       Duration
                    //                                                           difference =
                    //                                                           currentTime.difference(connectedTime);

                    //                                                       int minutesPassed =
                    //                                                           difference.inMinutes;
                    //                                                       return Container(
                    //                                                         padding:
                    //                                                             const EdgeInsets.all(8),
                    //                                                         child:
                    //                                                             Row(
                    //                                                           children: [
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 '${index + 1}',
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 '${censoredEmail} ',
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 '${userModels[index].fname} ${userModels[index].lname}',
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 '${userModels[index].position}',
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Row(
                    //                                                                 children: [
                    //                                                                   Expanded(flex: 1, child: Icon((minutesPassed > 1) ? Icons.motion_photos_off_rounded : Icons.motion_photos_on_rounded, color: (minutesPassed > 1) ? Colors.red : Colors.green)
                    //                                                                       // Text(
                    //                                                                       //   '🟢',
                    //                                                                       //   maxLines: 2,
                    //                                                                       //   textAlign: TextAlign.end,
                    //                                                                       //   style: TextStyle(color: (minutesPassed > 1) ? Colors.red : Colors.green, fontFamily: Font_.Fonts_T),
                    //                                                                       // )
                    //                                                                       ),
                    //                                                                   Expanded(
                    //                                                                     flex: 2,
                    //                                                                     child: Translate.TranslateAndSetText((minutesPassed > 1) ? 'ใช้งานเมื่อ $minutesPassed นาทีที่แล้ว' : ' ${userModels[index].connected}', AdminScafScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                    //                                                                   ),
                    //                                                                 ],
                    //                                                               ),
                    //                                                             ),
                    //                                                           ],
                    //                                                         ),
                    //                                                       );
                    //                                                     })),
                    //                                           ],
                    //                                         );
                    //                                       }),
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         actions: <Widget>[
                    //                           Column(
                    //                             children: [
                    //                               const SizedBox(
                    //                                 height: 5.0,
                    //                               ),
                    //                               Align(
                    //                                 alignment:
                    //                                     Alignment.centerLeft,
                    //                                 child: Padding(
                    //                                   padding:
                    //                                       const EdgeInsets.all(
                    //                                           2.0),
                    //                                   child: RichText(
                    //                                     text: const TextSpan(
                    //                                       text: '**หมายเหตุ : ',
                    //                                       style: TextStyle(
                    //                                           color: AdminScafScreen_Color
                    //                                               .Colors_Text1_,
                    //                                           fontFamily:
                    //                                               FontWeight_
                    //                                                   .Fonts_T),
                    //                                       children: <TextSpan>[
                    //                                         TextSpan(
                    //                                           text: ' สีเขียว ',
                    //                                           style: TextStyle(
                    //                                               color: Colors
                    //                                                   .green,
                    //                                               fontFamily:
                    //                                                   FontWeight_
                    //                                                       .Fonts_T),
                    //                                         ),
                    //                                         TextSpan(
                    //                                           text:
                    //                                               ' กำลังใช้งาน (ไม่เกิน 1 นาที) ,',
                    //                                           style: TextStyle(
                    //                                               color: AdminScafScreen_Color
                    //                                                   .Colors_Text1_,
                    //                                               fontFamily: Font_
                    //                                                   .Fonts_T),
                    //                                         ),
                    //                                         TextSpan(
                    //                                           text: ' สีแดง ',
                    //                                           style: TextStyle(
                    //                                               color: Colors
                    //                                                   .red,
                    //                                               fontFamily:
                    //                                                   FontWeight_
                    //                                                       .Fonts_T),
                    //                                         ),
                    //                                         TextSpan(
                    //                                           text:
                    //                                               ' ใช้งานล่าสุด (ไม่เกิน 15 นาที)',
                    //                                           style: TextStyle(
                    //                                               color: AdminScafScreen_Color
                    //                                                   .Colors_Text1_,
                    //                                               fontFamily: Font_
                    //                                                   .Fonts_T),
                    //                                         ),
                    //                                       ],
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                               const Divider(
                    //                                 color: Colors.grey,
                    //                                 height: 4.0,
                    //                               ),
                    //                               const SizedBox(
                    //                                 height: 5.0,
                    //                               ),
                    //                               Padding(
                    //                                 padding:
                    //                                     const EdgeInsets.all(
                    //                                         8.0),
                    //                                 child: Row(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment.end,
                    //                                   children: [
                    //                                     Padding(
                    //                                       padding:
                    //                                           const EdgeInsets
                    //                                               .all(8.0),
                    //                                       child: Row(
                    //                                         mainAxisAlignment:
                    //                                             MainAxisAlignment
                    //                                                 .center,
                    //                                         children: [
                    //                                           Container(
                    //                                             width: 100,
                    //                                             decoration:
                    //                                                 const BoxDecoration(
                    //                                               color: Colors
                    //                                                   .black,
                    //                                               borderRadius: BorderRadius.only(
                    //                                                   topLeft:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   topRight:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   bottomLeft:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   bottomRight:
                    //                                                       Radius.circular(
                    //                                                           10)),
                    //                                             ),
                    //                                             padding:
                    //                                                 const EdgeInsets
                    //                                                         .all(
                    //                                                     8.0),
                    //                                             child:
                    //                                                 TextButton(
                    //                                               onPressed: () =>
                    //                                                   Navigator.pop(
                    //                                                       context,
                    //                                                       'OK'),
                    //                                               child: Translate.TranslateAndSetText(
                    //                                                   'ปิด',
                    //                                                   Colors
                    //                                                       .white,
                    //                                                   TextAlign
                    //                                                       .center,
                    //                                                   FontWeight
                    //                                                       .bold,
                    //                                                   FontWeight_
                    //                                                       .Fonts_T,
                    //                                                   14,
                    //                                                   1),
                    //                                             ),
                    //                                           ),
                    //                                         ],
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ],
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     );
                    //                   },
                    //             child: Stack(
                    //               children: [
                    //                 Padding(
                    //                   padding: const EdgeInsets.all(4.0),
                    //                   child: Container(
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.white54,
                    //                       borderRadius: BorderRadius.only(
                    //                           topLeft: Radius.circular(20),
                    //                           topRight: Radius.circular(20),
                    //                           bottomLeft: Radius.circular(20),
                    //                           bottomRight: Radius.circular(20)),
                    //                     ),
                    //                     padding: const EdgeInsets.all(6.0),
                    //                     child: Icon(
                    //                       Icons.people,
                    //                       color: Colors.red,
                    //                       size: 18,
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 Positioned(
                    //                     top: 0,
                    //                     left: 0,
                    //                     child: Container(
                    //                       // decoration: const BoxDecoration(
                    //                       //   color: Colors.white,
                    //                       //   borderRadius: BorderRadius.only(
                    //                       //       topLeft: Radius.circular(20),
                    //                       //       topRight: Radius.circular(20),
                    //                       //       bottomLeft: Radius.circular(20),
                    //                       //       bottomRight: Radius.circular(20)),
                    //                       // ),
                    //                       padding: const EdgeInsets.all(2.0),
                    //                       child: Text(
                    //                         renTal_name == null
                    //                             ? '0'
                    //                             : '${userModels.length}',
                    //                         // '${userModels.length}***/$connected_Minutes/$ser_user/$email_user',
                    //                         style: TextStyle(
                    //                             fontSize: 12,
                    //                             color: Colors.blue,
                    //                             fontFamily:
                    //                                 FontWeight_.Fonts_T),
                    //                       ),
                    //                     ))
                    //               ],
                    //             )),
                    //       );
                    //     }),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 0)),
                          builder: (context, snapshot) {
                            return Text(
                              'Hi $fname_user ...',
                              style: TextStyle(
                                  color: AdminScafScreen_Color.Colors_Text1_,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: FontWeight_.Fonts_T),
                            );
                          }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[200]!.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(0)),
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              title: Center(
                                child: Translate.TranslateAndSetText(
                                    'ออกจากระบบ',
                                    AdminScafScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    14,
                                    1),
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 100,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
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
                                                onPressed: (renTal_user
                                                                .toString() ==
                                                            '50' ||
                                                        renTal_user
                                                                .toString() ==
                                                            '139')
                                                    ? () async {
                                                        AuthService.logout();
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        preferences.clear();

                                                        MaterialPageRoute
                                                            route =
                                                            MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginPage(),
                                                        );
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                                context, route,
                                                                (route) {
                                                          return false;
                                                        });
                                                      }
                                                    : () async {
                                                        deall_Trans_select();
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        var ser = preferences
                                                            .getString('ser');
                                                        var on = '0';
                                                        String url =
                                                            '${MyConstant().domain}/U_user_onoff.php?isAdd=true&ser=$ser&on=$on';

                                                        try {
                                                          var response =
                                                              await http.get(
                                                                  Uri.parse(
                                                                      url));

                                                          var result = json
                                                              .decode(response
                                                                  .body);
                                                          // print(result);
                                                          if (result
                                                                  .toString() ==
                                                              'true') {
                                                            SharedPreferences
                                                                preferences =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            preferences.clear();
                                                            routToService(
                                                                LoginPage());
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      '(ผิดพลาด)')),
                                                            );
                                                          }
                                                        } catch (e) {}
                                                      },
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ยืนยัน',
                                                        Colors.white,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.redAccent,
                                                    borderRadius:
                                                        BorderRadius.only(
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
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.logout_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
        backgroundColor: AppBarColors.hexColor,
      ),
      sideBar: (!context.watch<SidebarController>().isOpen)
          ? null
          : SideBar(
              width: 250,
              key: _keybar,
              textStyle: const TextStyle(
                  color: Colors.white, fontFamily: Font_.Fonts_T),
              iconColor: Colors.white,
              backgroundColor: AppBarColors.ABar_Colors_tab,
              items: [
                for (int i = 0; i < perMissionModels.length; i++)
                  if (int.parse(perMissionModels[i].ser!) <= 3)
                    AdminMenuItem(
                      title: '${translate_menu[i]}',

                      ///'${translate_menu.length}${perMissionModels[i].perm!.trim()}',
                      route: '/${perMissionModels[i].perm!.trim()}',
                      icon: IconData(
                        int.parse(
                          '${perMissionModels[i].icon}',
                        ),
                        fontFamily: 'MaterialIcons',
                      ),
                    ),
                AdminMenuItem(
                  title: 'ใบอนุญาต',
                  // icon: Icons.more_horiz,
                  icon: IconData(
                    int.parse(
                      '0xe44f',
                    ),
                    fontFamily: 'MaterialIcons',
                  ),
                  children: [
                    AdminMenuItem(
                      title: '  ↳ ประกาศ',
                      route: '/LicenseAnnounce',
                      // icon: IconData(
                      //   int.parse('0xe94d'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                    AdminMenuItem(
                      title: '  ↳ ทำสัญญา',
                      route: '/LicenseContract',
                      // icon: IconData(
                      //   int.parse('0xe873'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                    AdminMenuItem(
                      title: '  ↳ แนบหลักฐาน',
                      route: '/LicenseAttach',
                      // icon: IconData(
                      //   int.parse('0xe226'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                    AdminMenuItem(
                      title: '  ↳ รับชำระ',
                      route: '/LicensePayment',
                      // icon: IconData(
                      //   int.parse('0xef63'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                    AdminMenuItem(
                      title: '  ↳ ตรวจสอบหลักฐาน',
                      route: '/LicenseVerify',
                      // icon: IconData(
                      //   int.parse('0xf0c5'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                    AdminMenuItem(
                      title: '  ↳ ตรวจสอบข้อเท็จจริง',
                      route: '/LicenseFactCheck',
                      // icon: IconData(
                      //   int.parse('0xe880'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                    AdminMenuItem(
                      title: '  ↳ อนุมัติคำขอ',
                      route: '/LicenseApprove',
                      // icon: IconData(
                      //   int.parse('0xe94d'),
                      //   fontFamily: 'MaterialIcons',
                      // ),
                    ),
                  ],
                ),
                AdminMenuItem(
                  title: '${more_menu}',
                  // icon: Icons.more_horiz,
                  icon: IconData(
                    int.parse(
                      '0xf8d9',
                    ),
                    fontFamily: 'MaterialIcons',
                  ),
                  children: [
                    for (int i = 0; i < perMissionModels.length; i++)
                      if (int.parse(perMissionModels[i].ser!) > 3)
                        AdminMenuItem(
                          title:
                              '${translate_menu[i]}', // '${perMissionModels[i].perm!.trim()}',
                          route: '/${perMissionModels[i].perm!.trim()}',
                          icon: IconData(
                            int.parse(
                              '${perMissionModels[i].icon}',
                            ),
                            fontFamily: 'MaterialIcons',
                          ),
                        ),
                    AdminMenuItem(
                      title: 'แอดมินซัพพอร์ต',
                      route: '/AdminSupport',
                      icon: IconData(
                        int.parse('0xe621'), // Admin Panel Settings
                        fontFamily: 'MaterialIcons',
                      ),
                    ),
                  ],
                ),
              ],
              selectedRoute: '/',
              onSelected: (item) async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                if (preferences.getString('zonesName').toString() == 'null') {
                  setState(() {
                    preferences.setString('zoneSer', '0');
                    preferences.setString('zonesName', 'ทั้งหมด');
                  });
                }
                // ✅ Static menu: แอดมิน#sym:AdminSupport
                if (item.route == '/AdminSupport') {
                  if (renTal_user != null) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('route', 'AdminSupport');
                    setState(() {
                      Value_Route = 'AdminSupport';
                      _keybar.currentState?.closeDrawer();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Translate.TranslateAndSetText(
                            'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
                            Colors.black,
                            TextAlign.center,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                      ),
                    );
                  }
                  return;
                }
                // ✅ License sub-menu routes
                const licenseRoutes = {
                  '/LicenseContract': 'LicenseContract',
                  '/LicensePayment': 'LicensePayment',
                  '/LicenseAttach': 'LicenseAttach',
                  '/LicenseVerify': 'LicenseVerify',
                  '/LicenseFactCheck': 'LicenseFactCheck',
                  '/LicenseApprove': 'LicenseApprove',
                  '/LicenseAnnounce': 'LicenseAnnounce',
                };
                if (licenseRoutes.containsKey(item.route)) {
                  if (renTal_user != null) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final routeName = licenseRoutes[item.route]!;
                    prefs.setString('route', routeName);
                    setState(() {
                      Value_Route = routeName;
                      _keybar.currentState?.closeDrawer();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Translate.TranslateAndSetText(
                            'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
                            Colors.black,
                            TextAlign.center,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                      ),
                    );
                  }
                  return;
                }
                for (int i = 0; i < perMissionModels.length; i++) {
                  if (item.route == '/${perMissionModels[i].perm!.trim()}') {
                    if (renTal_user != null) {
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString(
                          'route', perMissionModels[i].perm!.trim().toString());
                      setState(() {
                        preferences.setString('Ser_Typepay', '0');
                        Value_Route = perMissionModels[i].perm!.trim();
                        _keybar.currentState?.closeDrawer();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Translate.TranslateAndSetText(
                              'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
                              Colors.black,
                              TextAlign.center,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              14,
                              1),
                        ),
                      );
                    }
                    // read_GC_rentalColor(); // ❌ ดึง GC_rental_setring.php ซ้ำทุกครั้งที่กดแท็บ → read_GC_rental() ดึงมาแล้วตอน initState
                  }
                }
              },
              header: Container(
                color: AppBarColors.ABar_Colors_tab,
                child: Column(
                  children: [
                    if (time_check.toString() != '0' && time_check != null)
                      if (Auto_cancel.toString() == 'Yes')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                          child: GestureDetector(
                            onTap: () async {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var ren = preferences.getString('renTalSer');
                              String url =
                                  '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

                              try {
                                var response = await http.get(Uri.parse(url));

                                var result = json.decode(response.body);
                                // print('GC_rental_setring>> $result');

                                if (result != null) {
                                  for (var map in result) {
                                    RenTalModel renTalModel =
                                        RenTalModel.fromJson(map);
                                    setState(() {
                                      time_check = renTalModel.time_check;
                                    });
                                  }
                                }
                                if (time_check == null ||
                                    time_check.toString() == '0') {
                                  String? _route =
                                      preferences.getString('route');
                                  MaterialPageRoute materialPageRoute =
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              AdminScafScreen(route: _route));
                                  Navigator.pushAndRemoveUntil(context,
                                      materialPageRoute, (route) => false);
                                }
                              } catch (e) {}
                              String Formbe_c = (int.parse('${time_check}') <
                                      60)
                                  ? 'รายการเกินกำหนด $time_check นาที'
                                  : (int.parse('${time_check}') == 60)
                                      ? 'รายการเกินกำหนด 1 ชั่วโมง'
                                      : (int.parse('${time_check}') == 90)
                                          ? 'รายการเกินกำหนด 1.3 ชั่วโมง'
                                          : (int.parse('${time_check}') == 120)
                                              ? 'รายการเกินกำหนด 2 ชั่วโมง'
                                              : (int.parse('${time_check}') ==
                                                      1440)
                                                  ? 'รายการเกินกำหนด 1 วัน'
                                                  : (int.parse(
                                                              '${time_check}') ==
                                                          2880)
                                                      ? 'รายการเกินกำหนด 2 วัน'
                                                      : 'รายการเกินกำหนด $time_check นาที';
                              if (time_check != null &&
                                  time_check.toString() != '0')
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    backgroundColor:
                                        AppbackgroundColor.Sub_Abg_Colors,
                                    titlePadding: const EdgeInsets.all(4.0),
                                    contentPadding: const EdgeInsets.all(10.0),
                                    actionsPadding: const EdgeInsets.all(6.0),
                                    title: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Icon(Icons.highlight_off,
                                                    size: 30,
                                                    color: Colors.red[700]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.lock_clock,
                                          size: 30,
                                          color: Colors.blueGrey,
                                        ),
                                        Translate.TranslateAndSetText(
                                            '#หมายเหตุระบบกึ่ง Auto  :',
                                            Colors.deepOrange,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        Translate.TranslateAndSetText(
                                            'ยกเลิกรายการชำระ/จอง(รอตรวจสอบ)',
                                            AdminScafScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        Translate.TranslateAndSetText(
                                            'เงื่อนไข $Formbe_c',
                                            AdminScafScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        Translate.TranslateAndSetText(
                                            'ล็อกเสียบ/พื้นที่สำรอง',
                                            AdminScafScreen_Color.Colors_Text1_,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        Translate.TranslateAndSetText(
                                            '( รายการ ที่ไม่พบ/แนบ Slip )',
                                            Colors.grey,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            FontWeight_.Fonts_T,
                                            14,
                                            1),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 4, 4, 4),
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange[100],
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
                                            padding: EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(2.0),
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'Check Auto',
                                                          Colors.deepOrange,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    SharedPreferences
                                                        preferences =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    if (Auto_cancel
                                                            .toString() ==
                                                        'Yes') {
                                                      preferences.setString(
                                                          'Auto_cancel', 'No');
                                                    } else {
                                                      preferences.setString(
                                                          'Auto_cancel', 'Yes');
                                                    }
                                                    String? _route = preferences
                                                        .getString('route');
                                                    MaterialPageRoute
                                                        materialPageRoute =
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                AdminScafScreen(
                                                                    route:
                                                                        _route));
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            materialPageRoute,
                                                            (route) => false);
                                                  },
                                                  child: (Auto_cancel
                                                              .toString() ==
                                                          'Yes')
                                                      ? Icon(
                                                          Icons.toggle_on,
                                                          color: Colors.green,
                                                          size: 25,
                                                        )
                                                      : Icon(
                                                          Icons.toggle_off,
                                                          color: Colors.black87,
                                                          size: 30,
                                                        ),
                                                ),
                                                // Icon(
                                                //   Icons.toggle_on,
                                                //   color: Colors
                                                //       .green,
                                                //   size: 25,
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  ),
                                );
                            },
                            child: Container(
                              height: 45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppBarColors.hexColor.withOpacity(0.9),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(0),
                                    topRight: Radius.circular(0),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                              ),
                              child: Center(
                                child: Timer_Countdown(context, time_check),
                              ),
                            ),
                          ),
                        ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: AppBarColors.ABar_Colors_tab,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0)),
                      ),
                      child: const Image(
                        image: AssetImage('images/chaoperty_dark.png'),
                      ),
                    ),
                    // StreamBuilder(
                    //     stream: Stream.periodic(const Duration(seconds: 1)),
                    //     builder: (context, snapshot) {
                    //       return Stack(
                    //         children: [
                    //           // if (datex.minute == 15 ||
                    //           //     datex.minute == 30 ||
                    //           //     datex.minute == 45 ||
                    //           //     datex.minute == 00)
                    //           Positioned.fill(
                    //               child:
                    //                   ChiangMaiBackground2()), // 👈 พื้นหลังวาดด้วย Canvas
                    //           // Align(
                    //           //   alignment: Alignment.center,
                    //           //   child: Padding(
                    //           //     padding: const EdgeInsets.all(2),
                    //           //     child: ClipRRect(
                    //           //       borderRadius: BorderRadius.circular(16),
                    //           //       child: BackdropFilter(
                    //           //         filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    //           //         child: Container(
                    //           //           padding: const EdgeInsets.symmetric(
                    //           //               horizontal: 12, vertical: 8),
                    //           //           decoration: BoxDecoration(
                    //           //             gradient: LinearGradient(
                    //           //               colors: [
                    //           //                 Colors.white.withOpacity(.30),
                    //           //                 Colors.white.withOpacity(.12),
                    //           //               ],
                    //           //             ),
                    //           //             border: Border.all(
                    //           //                 color: Colors.white.withOpacity(.35),
                    //           //                 width: 1),
                    //           //             boxShadow: [
                    //           //               BoxShadow(
                    //           //                 color: Colors.black.withOpacity(.08),
                    //           //                 blurRadius: 12,
                    //           //                 offset: const Offset(0, 6),
                    //           //               ),
                    //           //             ],
                    //           //             borderRadius: BorderRadius.circular(16),
                    //           //           ),
                    //           //           child: const Image(
                    //           //             image: AssetImage('images/chaoperty_dark.png'),
                    //           //             height: 36,
                    //           //           ),
                    //           //           //  Row(
                    //           //           //   mainAxisSize: MainAxisSize.min,
                    //           //           //   children: [
                    //           //           //     const Image(
                    //           //           //       image:
                    //           //           //           AssetImage('images/chaoperty_dark.png'),
                    //           //           //       height: 36,
                    //           //           //     ),
                    //           //           //     // const SizedBox(width: 10),
                    //           //           //     // Text(
                    //           //           //     //   'Chaoperty',
                    //           //           //     //   style: TextStyle(
                    //           //           //     //     color: Colors.black.withOpacity(.8),
                    //           //           //     //     fontWeight: FontWeight.w800,
                    //           //           //     //     fontSize: 16,
                    //           //           //     //     fontFamily: Font_.Fonts_T,
                    //           //           //     //   ),
                    //           //           //     // ),
                    //           //           //     // const SizedBox(width: 8),
                    //           //           //     // _FloatingLanternDot(), // 🏮 ลูกเล่นเล็ก ๆ
                    //           //           //   ],
                    //           //           // ),
                    //           //         ),
                    //           //       ),
                    //           //     ),
                    //           //   ),
                    //           // ),
                    //           Container(
                    //             // width: 200,
                    //             decoration: BoxDecoration(
                    //               // color: AppBarColors.ABar_Colors_tab,
                    //               borderRadius: BorderRadius.only(
                    //                   topLeft: Radius.circular(0),
                    //                   topRight: Radius.circular(0),
                    //                   bottomLeft: Radius.circular(0),
                    //                   bottomRight: Radius.circular(0)),
                    //             ),
                    //             padding: const EdgeInsets.all(8.0),
                    //             child: const Image(
                    //               image:
                    //                   AssetImage('images/chaoperty_dark.png'),
                    //             ),
                    //           ),
                    //         ],
                    //       );
                    //     }),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Align(
                    //     alignment: Alignment.center,
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(2),
                    //       child: InkWell(
                    //         onTap: () async {
                    //           setState(() {
                    //             Value_Route = 'หน้าหลัก';
                    //           });
                    //           SharedPreferences preferences =
                    //               await SharedPreferences.getInstance();
                    //           preferences.setString('route', 'หน้าหลัก');
                    //           var name = preferences.getString('fname');
                    //           Insert_log.Insert_logs('หน้าหลัก', '$name>หน้าหลัก');
                    //         },
                    //         child: ClipRRect(
                    //           borderRadius: BorderRadius.circular(16),
                    //           child: BackdropFilter(
                    //             filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    //             child: Container(
                    //               padding: const EdgeInsets.symmetric(
                    //                   horizontal: 12, vertical: 8),
                    //               decoration: BoxDecoration(
                    //                 gradient: LinearGradient(
                    //                   colors: [
                    //                     Colors.white.withOpacity(.30),
                    //                     Colors.white.withOpacity(.12),
                    //                   ],
                    //                 ),
                    //                 border: Border.all(
                    //                     color: Colors.white.withOpacity(.35), width: 1),
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                     color: Colors.black.withOpacity(.08),
                    //                     blurRadius: 12,
                    //                     offset: const Offset(0, 6),
                    //                   ),
                    //                 ],
                    //                 borderRadius: BorderRadius.circular(16),
                    //               ),
                    //               child: Center(
                    //                 child: Translate.TranslateAndSetText(
                    //                     'เมนูหลัก',
                    //                     Colors.black.withOpacity(.8),
                    //                     TextAlign.center,
                    //                     FontWeight.bold,
                    //                     FontWeight_.Fonts_T,
                    //                     14,
                    //                     1),
                    //               ),
                    //               //  Row(
                    //               //   mainAxisSize: MainAxisSize.min,
                    //               //   children: [
                    //               //     const Image(
                    //               //       image:
                    //               //           AssetImage('images/chaoperty_dark.png'),
                    //               //       height: 36,
                    //               //     ),
                    //               //     // const SizedBox(width: 10),
                    //               //     // Text(
                    //               //     //   'Chaoperty',
                    //               //     //   style: TextStyle(
                    //               //     //     color: Colors.black.withOpacity(.8),
                    //               //     //     fontWeight: FontWeight.w800,
                    //               //     //     fontSize: 16,
                    //               //     //     fontFamily: Font_.Fonts_T,
                    //               //     //   ),
                    //               //     // ),
                    //               //     // const SizedBox(width: 8),
                    //               //     // _FloatingLanternDot(), // 🏮 ลูกเล่นเล็ก ๆ
                    //               //   ],
                    //               // ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          Value_Route = 'หน้าหลัก';
                        });
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences.setString('route', 'หน้าหลัก');
                        var name = preferences.getString('fname');
                        Insert_log.Insert_logs('หน้าหลัก', '$name>หน้าหลัก');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                          child: Center(
                            child: Translate.TranslateAndSetText(
                                'เมนูหลัก ',
                                Colors.black,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              footer: Container(
                // height: 50,
                width: double.infinity,
                color: AppBarColors.ABar_Colors_tab,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFEDE7F6), // lavender pastel
                        Color(0xFFD1C4E9), // soft purple gray
                        Color(0xFFFFF8E1), // warm cream
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      // bottomRight: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.12),
                        blurRadius: 14,
                        offset: const Offset(2, 6),
                      ),
                    ],
                  ),
                  // height: 40,
                  // decoration: const BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.only(
                  //       topLeft: Radius.circular(5),
                  //       topRight: Radius.circular(5),
                  //       bottomLeft: Radius.circular(0),
                  //       bottomRight: Radius.circular(0)),
                  // ),
                  child: Column(
                    children: [
                      renTal_lavel! <= 3
                          ? SizedBox()
                          : passcode == null
                              ? SizedBox()
                              : Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$passcode',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T,
                                                fontSize: 20.0),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () async {
                                              //  print(userModels_chat.length);
                                              startTimer();
                                              showDialog<String>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      20.0))),
                                                  title: Center(
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'Admin User',
                                                            Colors.orange
                                                                .shade900,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),
                                                  ),
                                                  content: ScrollConfiguration(
                                                    behavior:
                                                        ScrollConfiguration.of(
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
                                                      dragStartBehavior:
                                                          DragStartBehavior
                                                              .start,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: (Responsive
                                                                    .isDesktop(
                                                                        context))
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.85
                                                                : 800,
                                                            child:
                                                                StreamBuilder(
                                                                    stream: Stream.periodic(const Duration(
                                                                        seconds:
                                                                            0)),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      return Column(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Translate.TranslateAndSetText('ทั้งหมด : ${userModels_chat.length} คน', AdminScafScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: AppbackgroundColor.TiTile_Colors,
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(0),
                                                                                bottomRight: Radius.circular(0),
                                                                              ),
                                                                              // border: Border.all(
                                                                              //     color: Colors.grey, width: 1),
                                                                            ),
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Text(
                                                                                    '...',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Text(
                                                                                    'Email',
                                                                                    textAlign: TextAlign.start,
                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Translate.TranslateAndSetText('ชื่อ', AdminScafScreen_Color.Colors_Text1_, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Translate.TranslateAndSetText('เวลาอัพเดตล่าสุด', AdminScafScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 1,
                                                                                  child: Translate.TranslateAndSetText('Logout', AdminScafScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              height: MediaQuery.of(context).size.height * 0.55,
                                                                              width: (Responsive.isDesktop(context)) ? MediaQuery.of(context).size.width * 0.85 : 800,
                                                                              child: ListView.builder(
                                                                                  padding: const EdgeInsets.all(8),
                                                                                  itemCount: userModels_chat.length,
                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                    String email = '${userModels_chat[index].email}';
                                                                                    int emailLength = email.length;
                                                                                    String firstTwoCharacters = email.substring(0, 2);
                                                                                    String lastFourCharacters = email.substring(emailLength - 4);
                                                                                    String censoredEmail = '$firstTwoCharacters${'*' * (emailLength - 6)}$lastFourCharacters';

                                                                                    String connected_ = '${userModels_chat[index].connected}';

                                                                                    DateTime connectedTime = DateTime.parse(connected_);

                                                                                    DateTime currentTime = DateTime.now();

                                                                                    Duration difference = currentTime.difference(connectedTime);

                                                                                    int minutesPassed = difference.inMinutes;
                                                                                    return Container(
                                                                                      padding: const EdgeInsets.all(8),
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Text(
                                                                                                  '${index + 1}',
                                                                                                  textAlign: TextAlign.center,
                                                                                                  maxLines: 1,
                                                                                                  style: TextStyle(
                                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                                      // fontWeight: FontWeight.bold,
                                                                                                      fontFamily: Font_.Fonts_T),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Text(
                                                                                                  '${censoredEmail} ',
                                                                                                  textAlign: TextAlign.start,
                                                                                                  maxLines: 2,
                                                                                                  style: TextStyle(
                                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                                      // fontWeight: FontWeight.bold,
                                                                                                      fontFamily: Font_.Fonts_T),
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Text(
                                                                                                  textAlign: TextAlign.start,
                                                                                                  maxLines: 2,
                                                                                                  '${userModels_chat[index].fname} ${userModels_chat[index].lname}',
                                                                                                  style: TextStyle(
                                                                                                      color: AdminScafScreen_Color.Colors_Text1_,
                                                                                                      // fontWeight: FontWeight.bold,
                                                                                                      fontFamily: Font_.Fonts_T),
                                                                                                ),
                                                                                              ),
                                                                                              // Expanded(
                                                                                              //   flex: 1,
                                                                                              //   child: Text(
                                                                                              //     '${userModels_chat[index].position}',
                                                                                              //     textAlign: TextAlign.end,
                                                                                              //     maxLines: 2,
                                                                                              //     style: TextStyle(
                                                                                              //         color: AdminScafScreen_Color.Colors_Text1_,
                                                                                              //         // fontWeight: FontWeight.bold,
                                                                                              //         fontFamily: Font_.Fonts_T),
                                                                                              //   ),
                                                                                              // ),

                                                                                              // Expanded(
                                                                                              //   flex: 2,
                                                                                              //   child: Row(
                                                                                              //     children: [
                                                                                              //       Expanded(flex: 1, child: Icon((minutesPassed > 1) ? Icons.motion_photos_off_rounded : Icons.motion_photos_on_rounded, color: (minutesPassed > 1) ? Colors.red : Colors.green)
                                                                                              //           // Text(
                                                                                              //           //   '🟢',
                                                                                              //           //   maxLines: 2,
                                                                                              //           //   textAlign: TextAlign.end,
                                                                                              //           //   style: TextStyle(color: (minutesPassed > 1) ? Colors.red : Colors.green, fontFamily: Font_.Fonts_T),
                                                                                              //           // )
                                                                                              //           ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: Translate.TranslateAndSetText(
                                                                                                    (minutesPassed > 60)
                                                                                                        ? 'ไม่ได้ใช้งานมากกว่า 1 ช.ม.'
                                                                                                        : (minutesPassed > 1)
                                                                                                            ? 'ใช้งานเมื่อ $minutesPassed นาทีที่แล้ว'
                                                                                                            : ' ${userModels_chat[index].connected}',
                                                                                                    (minutesPassed > 60) ? Colors.red : AdminScafScreen_Color.Colors_Text1_,
                                                                                                    TextAlign.center,
                                                                                                    FontWeight.bold,
                                                                                                    FontWeight_.Fonts_T,
                                                                                                    14,
                                                                                                    1),
                                                                                              ),
                                                                                              //     ],
                                                                                              //   ),
                                                                                              // ),
                                                                                              // Expanded(
                                                                                              //   flex: 4,
                                                                                              //   child: Text(
                                                                                              //     '${userModels_chat[index].syslog}',
                                                                                              //     textAlign: TextAlign.start,
                                                                                              //     maxLines: 2,
                                                                                              //     style: TextStyle(
                                                                                              //         color: AdminScafScreen_Color.Colors_Text1_,
                                                                                              //         // fontWeight: FontWeight.bold,
                                                                                              //         fontFamily: Font_.Fonts_T),
                                                                                              //   ),
                                                                                              // ),
                                                                                              Expanded(
                                                                                                flex: 1,
                                                                                                child: TextButton(
                                                                                                  onPressed: () {
                                                                                                    showDialog<String>(
                                                                                                      context: context,
                                                                                                      builder: (BuildContext context) => AlertDialog(
                                                                                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                                                        title: Row(
                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: Center(
                                                                                                                child: Text(
                                                                                                                  'รหัสผ่านการทำรายการ', // Navigator.pop(context, 'OK');
                                                                                                                  style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            Expanded(
                                                                                                              child: Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                children: [
                                                                                                                  IconButton(
                                                                                                                      onPressed: () {
                                                                                                                        setState(() {
                                                                                                                          Formpasslok_.clear();
                                                                                                                        });
                                                                                                                        Navigator.pop(context);
                                                                                                                      },
                                                                                                                      icon: Icon(Icons.close, color: Colors.black)),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                        actions: <Widget>[
                                                                                                          Form(
                                                                                                            key: _formKey,
                                                                                                            child: Column(
                                                                                                              children: [
                                                                                                                Padding(
                                                                                                                  padding: EdgeInsets.all(8.0),
                                                                                                                  child: TextFormField(
                                                                                                                    keyboardType: TextInputType.number,
                                                                                                                    controller: Formpasslok_,
                                                                                                                    obscureText: true,
                                                                                                                    validator: (value) {
                                                                                                                      if (value == null || value.isEmpty) {
                                                                                                                        return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                                                                                      }
                                                                                                                      // if (int.parse(value.toString()) < 13) {
                                                                                                                      //   return '< 13';
                                                                                                                      // }
                                                                                                                      return null;
                                                                                                                    },
                                                                                                                    onFieldSubmitted: (value) async {
                                                                                                                      if (_formKey.currentState!.validate()) {
                                                                                                                        SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                                        var ren = preferences.getString('renTalSer');
                                                                                                                        var user = preferences.getString('ser');
                                                                                                                        //print('value>>>>$value');
                                                                                                                        String url = '${MyConstant().domain}/GC_Passcode.php?isAdd=true&puser=$value&ren=$ren';

                                                                                                                        try {
                                                                                                                          var response = await http.get(Uri.parse(url));

                                                                                                                          var result = json.decode(response.body);
                                                                                                                          //print(result);
                                                                                                                          if (result.toString() == 'true') {
                                                                                                                            de_Trans_item(index);
                                                                                                                          } else {
                                                                                                                            setState(() {
                                                                                                                              Formpasslok_.clear();
                                                                                                                            });
                                                                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                                                                              SnackBar(content: Text('Password ผิดพลาด กรุณาลองใหม่!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                                                            );
                                                                                                                            // Navigator.pop(context, 'OK');
                                                                                                                            Navigator.pop(context, 'OK');
                                                                                                                          }
                                                                                                                        } catch (e) {}
                                                                                                                      }
                                                                                                                    },

                                                                                                                    // maxLength: 13,
                                                                                                                    cursorColor: Colors.green,
                                                                                                                    decoration: InputDecoration(
                                                                                                                        fillColor: Colors.white.withOpacity(0.3),
                                                                                                                        filled: true,
                                                                                                                        // prefixIcon: const Icon(Icons.water,
                                                                                                                        //     color: Colors.blue),
                                                                                                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                                                        focusedBorder: const OutlineInputBorder(
                                                                                                                          borderRadius: BorderRadius.only(
                                                                                                                            topRight: Radius.circular(15),
                                                                                                                            topLeft: Radius.circular(15),
                                                                                                                            bottomRight: Radius.circular(15),
                                                                                                                            bottomLeft: Radius.circular(15),
                                                                                                                          ),
                                                                                                                          borderSide: BorderSide(
                                                                                                                            width: 1,
                                                                                                                            color: Colors.black,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        enabledBorder: const OutlineInputBorder(
                                                                                                                          borderRadius: BorderRadius.only(
                                                                                                                            topRight: Radius.circular(15),
                                                                                                                            topLeft: Radius.circular(15),
                                                                                                                            bottomRight: Radius.circular(15),
                                                                                                                            bottomLeft: Radius.circular(15),
                                                                                                                          ),
                                                                                                                          borderSide: BorderSide(
                                                                                                                            width: 1,
                                                                                                                            color: Colors.grey,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        labelText: 'Password',
                                                                                                                        labelStyle: const TextStyle(
                                                                                                                          color: ManageScreen_Color.Colors_Text2_,
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
                                                                                                                Padding(
                                                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                                                  child: Row(
                                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      Container(
                                                                                                                        width: 150,
                                                                                                                        decoration: const BoxDecoration(
                                                                                                                          color: Colors.black,
                                                                                                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                                                        ),
                                                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                                                        child: TextButton(
                                                                                                                          onPressed: () async {
                                                                                                                            if (_formKey.currentState!.validate()) {
                                                                                                                              SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                                              var ren = preferences.getString('renTalSer');
                                                                                                                              var user = preferences.getString('ser');
                                                                                                                              var vel = Formpasslok_.text.trim();
                                                                                                                              //  print('vel>>>>$vel');
                                                                                                                              String url = '${MyConstant().domain}/GC_Passcode.php?isAdd=true&puser=$vel&ren=$ren';

                                                                                                                              try {
                                                                                                                                var response = await http.get(Uri.parse(url));

                                                                                                                                var result = json.decode(response.body);
                                                                                                                                //  print(result);
                                                                                                                                if (result.toString() == 'true') {
                                                                                                                                  de_Trans_item(index);
                                                                                                                                } else {
                                                                                                                                  setState(() {
                                                                                                                                    Formpasslok_.clear();
                                                                                                                                  });
                                                                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                                                                    SnackBar(content: Text('Password ผิดพลาด กรุณาลองใหม่!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                                                                  );
                                                                                                                                  Navigator.pop(context, 'OK');
                                                                                                                                  // Navigator.pop(context, 'OK');
                                                                                                                                }
                                                                                                                              } catch (e) {}
                                                                                                                            }
                                                                                                                          },
                                                                                                                          child: const Text(
                                                                                                                            'Submit',
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
                                                                                                    );
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'Logout',
                                                                                                    style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          Divider(),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  })),
                                                                        ],
                                                                      );
                                                                    }),
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
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: RichText(
                                                              text:
                                                                  const TextSpan(
                                                                text:
                                                                    '**หมายเหตุ : ',
                                                                style: TextStyle(
                                                                    color: AdminScafScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T),
                                                                children: <TextSpan>[
                                                                  TextSpan(
                                                                    text:
                                                                        ' สีเขียว ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' กำลังใช้งาน (ไม่เกิน 1 นาที) ,',
                                                                    style: TextStyle(
                                                                        color: AdminScafScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' สีแดง ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        ' ใช้งานล่าสุด (ไม่เกิน 15 นาที)',
                                                                    style: TextStyle(
                                                                        color: AdminScafScreen_Color
                                                                            .Colors_Text1_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          color: Colors.grey,
                                                          height: 4.0,
                                                        ),
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          100,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(10),
                                                                            topRight: Radius.circular(10),
                                                                            bottomLeft: Radius.circular(10),
                                                                            bottomRight: Radius.circular(10)),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            context,
                                                                            'OK'),
                                                                        child: Translate.TranslateAndSetText(
                                                                            'ปิด',
                                                                            Colors.white,
                                                                            TextAlign.center,
                                                                            FontWeight.bold,
                                                                            FontWeight_.Fonts_T,
                                                                            14,
                                                                            1),
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
                                            child: Text(
                                              "Admin User",
                                              style: TextStyle(
                                                color: Colors.orange.shade900,
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '© 2023  Dzentric Co.,Ltd. All Rights Reserved',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AdminScafScreen_Color.Colors_Text2_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                                fontSize: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: (Value_Route == 'หน้าหลัก')
          ? const HomeScreen2()
          : (Value_Route == 'พื้นที่เช่า')
              ? ChaoAreaScreen()
              : (Value_Route == 'ใบอนุญาต')
                  ? RequestContract_CMM(
                      route_getdata: widget.route_getdata ?? "",
                      ser_title: widget.ser_title,
                    )
                  : (Value_Route == 'LicenseContract')
                      ? LicenseRequestPage.create(
                          routeData: widget.route_getdata,
                          serTitle: widget.ser_title,
                        )
                      : (Value_Route == 'LicensePayment')
                          ? LicensePaymentPage.create()
                          : (Value_Route == 'LicenseAttach')
                              ? LicenseAttachPage.create()
                              : (Value_Route == 'LicenseVerify')
                                  ? LicenseverifyPage.create()
                                  : (Value_Route == 'LicenseFactCheck')
                                      ? LicensefactcheckPage.create()
                                      : (Value_Route == 'LicenseApprove')
                                          ? LicenseApprovePage.create()
                                          : (Value_Route == 'LicenseAnnounce')
                                              ? const LicenseAnnouncePage()
                                              : (Value_Route ==
                                                      'RequestExaminer1_CMM')
                                                  ? const RequestExaminer1_CMM(
                                                      viewver: false,
                                                      plugin: false,
                                                    )
                                                  : (Value_Route ==
                                                          'RequestExaminer2_CMM')
                                                      ? const RequestExaminer2_CMM(
                                                          viewver: false,
                                                          plugin: false,
                                                        )
                                                      : (Value_Route ==
                                                              'SignaturePad_CMM')
                                                          ? const SignaturePad_CMM()
                                                          : (Value_Route ==
                                                                  'AdminSupport')
                                                              ? AdminSupport()
                                                              : (Value_Route ==
                                                                      'ผู้เช่า')
                                                                  ? TenantLicensePage
                                                                      .create()
                                                                  // const PeopleChaoScreen()
                                                                  : (Value_Route ==
                                                                          'บัญชี')
                                                                      ? const AccountScreen()
                                                                      : (Value_Route ==
                                                                              'จัดการ')
                                                                          ? const ManageScreen()
                                                                          : (Value_Route == 'รายงาน')
                                                                              ? ReportScreen()
                                                                              : (Value_Route == 'ทะเบียน')
                                                                                  ? RegistrationPage.create()
                                                                                  : (Value_Route == 'ตั้งค่า')
                                                                                      ? const SettingScreen()
                                                                                      : (Value_Route == 'จัดการข้อมูลส่วนตัว')
                                                                                          ? ManagePersonalInformation_CMM() //USerInformation()
                                                                                          : (Value_Route == 'TestPrintNamePage')
                                                                                              ? TestPrintNamePage()
                                                                                              : const SettingUserScreen(),
      // body: (Value_Route == 'หน้าหลัก')
      //     ? const HomeScreen()
      //     : (Value_Route == 'พื้นที่เช่า')
      //         ? const ChaoAreaScreen()
      //         : (Value_Route == 'ผู้เช่า')
      //             ? const PeopleChaoScreen()
      //             : (Value_Route == 'บัญชี')
      //                 ? const AccountScreen()
      //                 : (Value_Route == 'จัดการ')
      //                     ? const ManageScreen()
      //                     : (Value_Route == 'รายงาน' &&
      //                             (renTal_user.toString() == '72' ||
      //                                 renTal_user.toString() == '92' ||
      //                                 renTal_user.toString() == '93' ||
      //                                 renTal_user.toString() == '94'))
      //                         ? const Report_Ortor_Screen()
      //                         : (Value_Route == 'รายงาน' &&
      //                                 renTal_user.toString() == '65')
      //                             ? const Report_cm_Screen()
      //                             : (Value_Route == 'รายงาน' &&
      //                                     renTal_user.toString() != '65')
      //                                 ? ReportScreen()
      //                                 : (Value_Route == 'ทะเบียน')
      //                                     ? const BureauScreen()
      //                                     : (Value_Route == 'ตั้งค่า')
      //                                         ? const SettingScreen()
      //                                         : (Value_Route ==
      //                                                 'จัดการข้อมูลส่วนตัว')
      //                                             ? const SettingUserScreen()
      //                                             : const SettingUserScreen(),
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

  Future<Null> de_Trans_item(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var userser = userModels_chat[index].ser;

    String url =
        '${MyConstant().domain}/logout_Admin.php?isAdd=true&ren=$ren&userser=$userser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          Navigator.pop(context);
          Navigator.pop(context);
          Formpasslok_.clear();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Scaffold adminmobile() {
    return Scaffold(
      backgroundColor: AppbackgroundColor.Abg_Colors,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.black,
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 50.2,
        // toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (Responsive.isDesktop(context))
                        (img_logo == null || img_logo.toString() == '')
                            ? SizedBox()
                            : GestureDetector(
                                child: CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: NetworkImage(
                                      '${MyConstant().domain}/files/$foder/logo/$img_logo'),
                                  backgroundColor: Colors.transparent,
                                  onBackgroundImageError: (_, __) {},
                                ),
                                onTap: () {
                                  if (img_logo == null ||
                                      img_logo.toString() == '') {
                                  } else {
                                    String url =
                                        '${MyConstant().domain}/files/$foder/logo/$img_logo';
                                    _showMyDialogImg(
                                        url,
                                        renTal_name == null
                                            ? ' '
                                            : ' $renTal_name');
                                  }
                                },
                              ),
                      GestureDetector(
                        child: Text(
                          renTal_name == null ? ' ภาพรวม' : ' $renTal_name',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: (Responsive.isDesktop(context))
                                  ? FontWeight.bold
                                  : null,
                              fontSize:
                                  (Responsive.isDesktop(context)) ? null : 12,
                              fontFamily: FontWeight_.Fonts_T),
                        ),
                        onTap: () {
                          if (img_logo == null || img_logo.toString() == '') {
                          } else {
                            String url =
                                '${MyConstant().domain}/files/$foder/logo/$img_logo';
                            _showMyDialogImg(url,
                                renTal_name == null ? ' ' : ' $renTal_name');
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
        ),
        actions: [
          Row(
            children: [
              // StreamBuilder(
              //     stream: Stream.periodic(const Duration(seconds: 1)),
              //     builder: (context, snapshot) {
              //       return Container(
              //         decoration: BoxDecoration(
              //           // color: Colors.white.withOpacity(0.7),
              //           // Colors.lightGreen[200],
              //           borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(10),
              //               topRight: Radius.circular(10),
              //               bottomLeft: Radius.circular(10),
              //               bottomRight: Radius.circular(10)),
              //           // border: Border.all(color: Colors.grey, width: 0.5),
              //         ),
              //         padding: const EdgeInsets.all(0.5),
              //         child: Container(
              //           width: 100,
              //           child: Row(
              //             children: [
              //               Expanded(
              //                 flex: 1,
              //                 child: Icon(
              //                   Icons.sunny,
              //                   size: 15.0,
              //                   color: (AppbackgroundColor.TiTile_Colors ==
              //                           Color.fromARGB(255, 203, 200, 219))
              //                       ? Colors.white
              //                       : Colors.orange,
              //                 ),
              //               ),
              //               (isDark_Mode == true)
              //                   ? InkWell(
              //                       onTap: () async {
              //                         SharedPreferences preferences =
              //                             await SharedPreferences.getInstance();
              //                         setState(() {
              //                           preferences.setBool(
              //                               'isDarkMode', false);
              //                         });
              //                         // print(preferences.getBool('isDarkMode'));
              //                         // print(isDark_Mode);
              //                         String? _route =
              //                             preferences.getString('route');
              //                         MaterialPageRoute materialPageRoute =
              //                             MaterialPageRoute(
              //                                 builder: (BuildContext context) =>
              //                                     AdminScafScreen(
              //                                         route: _route));
              //                         Navigator.pushAndRemoveUntil(context,
              //                             materialPageRoute, (route) => false);
              //                         // changeColor();
              //                       },
              //                       child: Icon(
              //                         Icons.toggle_on,
              //                         color: Colors.yellow[100],
              //                         size: 35.0,
              //                       ),
              //                     )
              //                   : InkWell(
              //                       onTap: () async {
              //                         SharedPreferences preferences =
              //                             await SharedPreferences.getInstance();
              //                         setState(() {
              //                           preferences.setBool('isDarkMode', true);
              //                         });

              //                         // print(preferences.getBool('isDarkMode'));
              //                         String? _route =
              //                             preferences.getString('route');
              //                         MaterialPageRoute materialPageRoute =
              //                             MaterialPageRoute(
              //                                 builder: (BuildContext context) =>
              //                                     AdminScafScreen(
              //                                         route: _route));
              //                         Navigator.pushAndRemoveUntil(context,
              //                             materialPageRoute, (route) => false);
              //                         // changeColor();
              //                       },
              //                       child: Icon(
              //                         Icons.toggle_off,
              //                         color: Colors.orange[100],
              //                         size: 35.0,
              //                       ),
              //                     ),
              //               // (AppbackgroundColor.TiTile_Colors ==
              //               //         Color.fromARGB(255, 203, 200, 219))
              //               //     ? InkWell(
              //               //         onTap: () {
              //               //           changeColor();
              //               //         },
              //               //         child: Icon(
              //               //           Icons.toggle_on,
              //               //           color: Colors.yellow[100],
              //               //           size: 35.0,
              //               //         ),
              //               //       )
              //               //     : InkWell(
              //               //         onTap: () {
              //               //           changeColor();
              //               //         },
              //               //         child: Icon(
              //               //           Icons.toggle_off,
              //               //           color: Colors.orange[100],
              //               //           size: 35.0,
              //               //         ),
              //               //       ),
              //               Expanded(
              //                   flex: 1,
              //                   child: Icon(
              //                     Icons.bedtime,
              //                     size: 15.0,
              //                     color: (AppbackgroundColor.TiTile_Colors ==
              //                             Color(0xFFD9D9B7))
              //                         ? Colors.white
              //                         : Colors.yellow,
              //                   )),
              //             ],
              //           ),
              //         ),
              //       );
              //     }),
              // StreamBuilder(
              //     stream: Stream.periodic(const Duration(seconds: 1)),
              //     builder: (context, snapshot) {
              //       return Container(
              //         decoration: BoxDecoration(
              //           // color: Colors.white.withOpacity(0.7),
              //           // Colors.lightGreen[200],
              //           borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(10),
              //               topRight: Radius.circular(10),
              //               bottomLeft: Radius.circular(10),
              //               bottomRight: Radius.circular(10)),
              //           // border: Border.all(color: Colors.grey, width: 0.5),
              //         ),
              //         padding: const EdgeInsets.all(0.5),
              //         child: Container(
              //           width: 100,
              //           child: Row(
              //             children: [
              //               Expanded(
              //                 flex: 1,
              //                 child: Icon(
              //                   Icons.sunny,
              //                   size: 15.0,
              //                   color: (AppbackgroundColor.TiTile_Colors ==
              //                           Color.fromARGB(255, 203, 200, 219))
              //                       ? Colors.white
              //                       : Colors.orange,
              //                 ),
              //               ),
              //               (AppbackgroundColor.TiTile_Colors ==
              //                       Color.fromARGB(255, 203, 200, 219))
              //                   ? InkWell(
              //                       onTap: () {
              //                         changeColor();
              //                       },
              //                       child: Icon(
              //                         Icons.toggle_on,
              //                         color: Colors.yellow[100],
              //                         size: 35.0,
              //                       ),
              //                     )
              //                   : InkWell(
              //                       onTap: () {
              //                         changeColor();
              //                       },
              //                       child: Icon(
              //                         Icons.toggle_off,
              //                         color: Colors.orange[100],
              //                         size: 35.0,
              //                       ),
              //                     ),
              //               Expanded(
              //                   flex: 1,
              //                   child: Icon(
              //                     Icons.bedtime,
              //                     size: 15.0,
              //                     color: (AppbackgroundColor.TiTile_Colors ==
              //                             Color(0xFFD9D9B7))
              //                         ? Colors.white
              //                         : Colors.yellow,
              //                   )),
              //             ],
              //           ),
              //         ),
              //       );
              //     }),
              // (Responsive.isMobile(context))
              //     ? Text('')
              //     : StreamBuilder(
              //         stream: Stream.periodic(const Duration(seconds: 0)),
              //         builder: (context, snapshot) {
              //           return Row(
              //             children: [
              //               if (read_data_davtext != '')
              //                 Container(
              //                   width: (Responsive.isDesktop(context))
              //                       ? MediaQuery.of(context).size.width / 4
              //                       : MediaQuery.of(context).size.width / 5,
              //                   child: Marquee(
              //                     text:
              //                         '   📢 แจ้งเตือน : $read_data_davtext     ||   ',

              //                     /// velocity: 50.0, //speed
              //                     // text: '$read_data_davtext',
              //                     style: const TextStyle(
              //                         color: Color.fromARGB(255, 179, 92, 85),
              //                         fontWeight: FontWeight.bold,
              //                         fontFamily: FontWeight_.Fonts_T),
              //                     scrollAxis: Axis.horizontal,
              //                     crossAxisAlignment: CrossAxisAlignment.center,
              //                     // blankSpace: 20.0,
              //                     // velocity: 100.0,
              //                     pauseAfterRound: Duration(seconds: 1),
              //                     // startPadding: 10.0,
              //                     // accelerationDuration: Duration(seconds: 5),
              //                     accelerationCurve: Curves.linear,
              //                     decelerationDuration: Duration(seconds: 5),
              //                     decelerationCurve: Curves.easeInOut,
              //                   ),
              //                 ),
              //             ],
              //           );
              //         }),
              if (!Responsive.isMobile(context) &&
                  (ser_user == '63' ||
                      ser_user == '56' ||
                      ser_user == '61' ||
                      ser_user == '37'))
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      _showMyDialogDev(0);
                    },
                    child: Container(
                      color: Colors.yellow,
                      child: Center(
                          child: Text(
                        '  DEV  ',
                        style: TextStyle(
                            color: AdminScafScreen_Color.Colors_Text1_,
                            fontFamily: FontWeight_.Fonts_T),
                      )),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(0)),
                  // border: Border.all(color: Colors.grey, width: 0.5),
                ),
                padding: const EdgeInsets.all(0.5),
                child: Row(
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.fromLTRB(4, 1, 0, 1),
                    //   child: StreamBuilder(
                    //       stream: Stream.periodic(const Duration(seconds: 0)),
                    //       builder: (context, snapshot) {
                    //         return ChatScreen(
                    //             ser_user: ser_user,
                    //             userModels_chat_: userModels_chat,
                    //             userModels_: userModels);
                    //       }),
                    // ),
                    // StreamBuilder(
                    //     stream: Stream.periodic(const Duration(seconds: 0)),
                    //     builder: (context, snapshot) {
                    //       return Padding(
                    //         padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
                    //         child: InkWell(
                    //             onTap: renTal_name == null
                    //                 ? null
                    //                 : () async {
                    //                     startTimer();
                    //                     showDialog<String>(
                    //                       context: context,
                    //                       builder: (BuildContext context) =>
                    //                           AlertDialog(
                    //                         shape: const RoundedRectangleBorder(
                    //                             borderRadius: BorderRadius.all(
                    //                                 Radius.circular(20.0))),
                    //                         title: Center(
                    //                             child: Text(
                    //                           'ผู้ใช้งานระบบขณะนี้ $deviceNames',
                    //                           style: TextStyle(
                    //                               color: AdminScafScreen_Color
                    //                                   .Colors_Text1_,
                    //                               fontWeight: FontWeight.bold,
                    //                               fontFamily:
                    //                                   FontWeight_.Fonts_T),
                    //                         )),
                    //                         content: ScrollConfiguration(
                    //                           behavior: ScrollConfiguration.of(
                    //                                   context)
                    //                               .copyWith(dragDevices: {
                    //                             PointerDeviceKind.touch,
                    //                             PointerDeviceKind.mouse,
                    //                           }),
                    //                           child: SingleChildScrollView(
                    //                             scrollDirection:
                    //                                 Axis.horizontal,
                    //                             dragStartBehavior:
                    //                                 DragStartBehavior.start,
                    //                             child: Row(
                    //                               children: [
                    //                                 Container(
                    //                                   width: (Responsive
                    //                                           .isDesktop(
                    //                                               context))
                    //                                       ? MediaQuery.of(
                    //                                                   context)
                    //                                               .size
                    //                                               .width *
                    //                                           0.85
                    //                                       : 800,
                    //                                   child: StreamBuilder(
                    //                                       stream:
                    //                                           Stream.periodic(
                    //                                               const Duration(
                    //                                                   seconds:
                    //                                                       0)),
                    //                                       builder: (context,
                    //                                           snapshot) {
                    //                                         return Column(
                    //                                           children: [
                    //                                             Row(
                    //                                               children: [
                    //                                                 Text(
                    //                                                   'ทั้งหมด : ${userModels.length} คน',
                    //                                                   style: TextStyle(
                    //                                                       color: AdminScafScreen_Color
                    //                                                           .Colors_Text1_,
                    //                                                       fontWeight: FontWeight
                    //                                                           .bold,
                    //                                                       fontFamily:
                    //                                                           FontWeight_.Fonts_T),
                    //                                                 ),
                    //                                               ],
                    //                                             ),
                    //                                             Container(
                    //                                               decoration:
                    //                                                   BoxDecoration(
                    //                                                 color: AppbackgroundColor
                    //                                                     .TiTile_Colors,
                    //                                                 borderRadius:
                    //                                                     BorderRadius
                    //                                                         .only(
                    //                                                   topLeft: Radius
                    //                                                       .circular(
                    //                                                           10),
                    //                                                   topRight:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   bottomLeft:
                    //                                                       Radius.circular(
                    //                                                           0),
                    //                                                   bottomRight:
                    //                                                       Radius.circular(
                    //                                                           0),
                    //                                                 ),
                    //                                                 // border: Border.all(
                    //                                                 //     color: Colors.grey, width: 1),
                    //                                               ),
                    //                                               padding:
                    //                                                   const EdgeInsets
                    //                                                           .all(
                    //                                                       8.0),
                    //                                               child: Row(
                    //                                                 children: const [
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       '...',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       'Email',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       'ชื่อ',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       'ตำแหน่ง',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                   Expanded(
                    //                                                     flex: 1,
                    //                                                     child:
                    //                                                         Text(
                    //                                                       'เวลาอัพเดตล่าสุด',
                    //                                                       textAlign:
                    //                                                           TextAlign.center,
                    //                                                       style: TextStyle(
                    //                                                           color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                           fontWeight: FontWeight.bold,
                    //                                                           fontFamily: FontWeight_.Fonts_T),
                    //                                                     ),
                    //                                                   ),
                    //                                                 ],
                    //                                               ),
                    //                                             ),
                    //                                             Container(
                    //                                                 height: MediaQuery.of(context)
                    //                                                         .size
                    //                                                         .height *
                    //                                                     0.4,
                    //                                                 width: (Responsive.isDesktop(
                    //                                                         context))
                    //                                                     ? MediaQuery.of(context).size.width *
                    //                                                         0.85
                    //                                                     : 800,
                    //                                                 child: ListView.builder(
                    //                                                     padding: const EdgeInsets.all(8),
                    //                                                     itemCount: userModels.length,
                    //                                                     itemBuilder: (BuildContext context, int index) {
                    //                                                       String
                    //                                                           email =
                    //                                                           '${userModels[index].email}';
                    //                                                       int emailLength =
                    //                                                           email.length;
                    //                                                       String
                    //                                                           firstTwoCharacters =
                    //                                                           email.substring(0, 2);
                    //                                                       String
                    //                                                           lastFourCharacters =
                    //                                                           email.substring(emailLength - 4);
                    //                                                       String
                    //                                                           censoredEmail =
                    //                                                           '$firstTwoCharacters${'*' * (emailLength - 6)}$lastFourCharacters';

                    //                                                       String
                    //                                                           connected_ =
                    //                                                           '${userModels[index].connected}';

                    //                                                       DateTime
                    //                                                           connectedTime =
                    //                                                           DateTime.parse(connected_);

                    //                                                       DateTime
                    //                                                           currentTime =
                    //                                                           DateTime.now();

                    //                                                       Duration
                    //                                                           difference =
                    //                                                           currentTime.difference(connectedTime);

                    //                                                       int minutesPassed =
                    //                                                           difference.inMinutes;
                    //                                                       return Container(
                    //                                                         padding:
                    //                                                             const EdgeInsets.all(8),
                    //                                                         child:
                    //                                                             Row(
                    //                                                           children: [
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 '${index + 1}',
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 '${censoredEmail} ',
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 '${userModels[index].fname} ${userModels[index].lname}',
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Text(
                    //                                                                 '${userModels[index].position}',
                    //                                                                 textAlign: TextAlign.center,
                    //                                                                 maxLines: 2,
                    //                                                                 style: TextStyle(
                    //                                                                     color: AdminScafScreen_Color.Colors_Text1_,
                    //                                                                     // fontWeight: FontWeight.bold,
                    //                                                                     fontFamily: Font_.Fonts_T),
                    //                                                               ),
                    //                                                             ),
                    //                                                             Expanded(
                    //                                                               flex: 1,
                    //                                                               child: Row(
                    //                                                                 children: [
                    //                                                                   Expanded(flex: 1, child: Icon((minutesPassed > 1) ? Icons.motion_photos_off_rounded : Icons.motion_photos_on_rounded, color: (minutesPassed > 1) ? Colors.red : Colors.green)
                    //                                                                       // Text(
                    //                                                                       //   '🟢',
                    //                                                                       //   maxLines: 2,
                    //                                                                       //   textAlign: TextAlign.end,
                    //                                                                       //   style: TextStyle(color: (minutesPassed > 1) ? Colors.red : Colors.green, fontFamily: Font_.Fonts_T),
                    //                                                                       // )
                    //                                                                       ),
                    //                                                                   Expanded(
                    //                                                                     flex: 2,
                    //                                                                     child: Text(
                    //                                                                       (minutesPassed > 1) ? 'ใช้งานเมื่อ $minutesPassed นาทีที่แล้ว' : ' ${userModels[index].connected}',
                    //                                                                       textAlign: TextAlign.center,
                    //                                                                       maxLines: 2,
                    //                                                                       style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontFamily: Font_.Fonts_T),
                    //                                                                     ),
                    //                                                                   ),
                    //                                                                 ],
                    //                                                               ),
                    //                                                             ),
                    //                                                           ],
                    //                                                         ),
                    //                                                       );
                    //                                                     })),
                    //                                           ],
                    //                                         );
                    //                                       }),
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         actions: <Widget>[
                    //                           Column(
                    //                             children: [
                    //                               const SizedBox(
                    //                                 height: 5.0,
                    //                               ),
                    //                               Align(
                    //                                 alignment:
                    //                                     Alignment.centerLeft,
                    //                                 child: Padding(
                    //                                   padding:
                    //                                       const EdgeInsets.all(
                    //                                           2.0),
                    //                                   child: RichText(
                    //                                     text: const TextSpan(
                    //                                       text: '**หมายเหตุ : ',
                    //                                       style: TextStyle(
                    //                                           color: AdminScafScreen_Color
                    //                                               .Colors_Text1_,
                    //                                           fontFamily:
                    //                                               FontWeight_
                    //                                                   .Fonts_T),
                    //                                       children: <TextSpan>[
                    //                                         TextSpan(
                    //                                           text: ' สีเขียว ',
                    //                                           style: TextStyle(
                    //                                               color: Colors
                    //                                                   .green,
                    //                                               fontFamily:
                    //                                                   FontWeight_
                    //                                                       .Fonts_T),
                    //                                         ),
                    //                                         TextSpan(
                    //                                           text:
                    //                                               ' กำลังใช้งาน (ไม่เกิน 1 นาที) ,',
                    //                                           style: TextStyle(
                    //                                               color: AdminScafScreen_Color
                    //                                                   .Colors_Text1_,
                    //                                               fontFamily: Font_
                    //                                                   .Fonts_T),
                    //                                         ),
                    //                                         TextSpan(
                    //                                           text: ' สีแดง ',
                    //                                           style: TextStyle(
                    //                                               color: Colors
                    //                                                   .red,
                    //                                               fontFamily:
                    //                                                   FontWeight_
                    //                                                       .Fonts_T),
                    //                                         ),
                    //                                         TextSpan(
                    //                                           text:
                    //                                               ' ใช้งานล่าสุด (ไม่เกิน 15 นาที)',
                    //                                           style: TextStyle(
                    //                                               color: AdminScafScreen_Color
                    //                                                   .Colors_Text1_,
                    //                                               fontFamily: Font_
                    //                                                   .Fonts_T),
                    //                                         ),
                    //                                       ],
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                               const Divider(
                    //                                 color: Colors.grey,
                    //                                 height: 4.0,
                    //                               ),
                    //                               const SizedBox(
                    //                                 height: 5.0,
                    //                               ),
                    //                               Padding(
                    //                                 padding:
                    //                                     const EdgeInsets.all(
                    //                                         8.0),
                    //                                 child: Row(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment.end,
                    //                                   children: [
                    //                                     Padding(
                    //                                       padding:
                    //                                           const EdgeInsets
                    //                                               .all(8.0),
                    //                                       child: Row(
                    //                                         mainAxisAlignment:
                    //                                             MainAxisAlignment
                    //                                                 .center,
                    //                                         children: [
                    //                                           Container(
                    //                                             width: 100,
                    //                                             decoration:
                    //                                                 const BoxDecoration(
                    //                                               color: Colors
                    //                                                   .black,
                    //                                               borderRadius: BorderRadius.only(
                    //                                                   topLeft:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   topRight:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   bottomLeft:
                    //                                                       Radius.circular(
                    //                                                           10),
                    //                                                   bottomRight:
                    //                                                       Radius.circular(
                    //                                                           10)),
                    //                                             ),
                    //                                             padding:
                    //                                                 const EdgeInsets
                    //                                                         .all(
                    //                                                     8.0),
                    //                                             child:
                    //                                                 TextButton(
                    //                                               onPressed: () =>
                    //                                                   Navigator.pop(
                    //                                                       context,
                    //                                                       'OK'),
                    //                                               child:
                    //                                                   const Text(
                    //                                                 'ปิด',
                    //                                                 style: TextStyle(
                    //                                                     color: Colors
                    //                                                         .white,
                    //                                                     fontWeight:
                    //                                                         FontWeight
                    //                                                             .bold,
                    //                                                     fontFamily:
                    //                                                         FontWeight_.Fonts_T),
                    //                                               ),
                    //                                             ),
                    //                                           ),
                    //                                         ],
                    //                                       ),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ],
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     );
                    //                   },
                    //             child: Stack(
                    //               children: [
                    //                 Padding(
                    //                   padding: const EdgeInsets.all(2.0),
                    //                   child: Container(
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.white54,
                    //                       borderRadius: BorderRadius.only(
                    //                           topLeft: Radius.circular(20),
                    //                           topRight: Radius.circular(20),
                    //                           bottomLeft: Radius.circular(20),
                    //                           bottomRight: Radius.circular(20)),
                    //                     ),
                    //                     padding: const EdgeInsets.all(6.0),
                    //                     child: Icon(
                    //                       Icons.people,
                    //                       color: Colors.red,
                    //                       size: 18,
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 Positioned(
                    //                     top: 0,
                    //                     left: 0,
                    //                     child: Container(
                    //                       // decoration: const BoxDecoration(
                    //                       //   color: Colors.white,
                    //                       //   borderRadius: BorderRadius.only(
                    //                       //       topLeft: Radius.circular(20),
                    //                       //       topRight: Radius.circular(20),
                    //                       //       bottomLeft: Radius.circular(20),
                    //                       //       bottomRight: Radius.circular(20)),
                    //                       // ),
                    //                       padding: const EdgeInsets.all(2.0),
                    //                       child: Text(
                    //                         renTal_name == null
                    //                             ? '0'
                    //                             : '${userModels.length}',
                    //                         // '${userModels.length}***/$connected_Minutes/$ser_user/$email_user',
                    //                         style: TextStyle(
                    //                             fontSize: 12,
                    //                             color: Colors.blue,
                    //                             fontFamily:
                    //                                 FontWeight_.Fonts_T),
                    //                       ),
                    //                     ))
                    //               ],
                    //             )),
                    //       );
                    //     }),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 0)),
                          builder: (context, snapshot) {
                            return Text(
                              'Hi $fname_user ..',
                              style: TextStyle(
                                  color: AdminScafScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: Font_.Fonts_T),
                            );
                          }),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[200]!.withOpacity(0.7),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(0)),
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              title: Center(
                                child: Translate.TranslateAndSetText(
                                    'ออกจากระบบ',
                                    AdminScafScreen_Color.Colors_Text1_,
                                    TextAlign.center,
                                    FontWeight.bold,
                                    FontWeight_.Fonts_T,
                                    14,
                                    1),
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 100,
                                              decoration: const BoxDecoration(
                                                color: Colors.green,
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
                                                onPressed: (renTal_user
                                                                .toString() ==
                                                            '50' ||
                                                        renTal_user
                                                                .toString() ==
                                                            '139')
                                                    ? () async {
                                                        AuthService.logout();
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        preferences.clear();

                                                        MaterialPageRoute
                                                            route =
                                                            MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginPage(),
                                                        );
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                                context, route,
                                                                (route) {
                                                          return false;
                                                        });
                                                      }
                                                    : () async {
                                                        deall_Trans_select();
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        var ser = preferences
                                                            .getString('ser');
                                                        var on = '0';
                                                        String url =
                                                            '${MyConstant().domain}/U_user_onoff.php?isAdd=true&ser=$ser&on=$on';

                                                        try {
                                                          var response =
                                                              await http.get(
                                                                  Uri.parse(
                                                                      url));

                                                          var result = json
                                                              .decode(response
                                                                  .body);
                                                          // print(result);
                                                          if (result
                                                                  .toString() ==
                                                              'true') {
                                                            SharedPreferences
                                                                preferences =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            preferences.clear();
                                                            routToService(
                                                                LoginPage());
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      '(ผิดพลาด)')),
                                                            );
                                                          }
                                                        } catch (e) {}
                                                      },
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ยืนยัน',
                                                        Colors.white,
                                                        TextAlign.center,
                                                        FontWeight.bold,
                                                        FontWeight_.Fonts_T,
                                                        14,
                                                        1),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.redAccent,
                                                    borderRadius:
                                                        BorderRadius.only(
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
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.logout_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
        backgroundColor: AppBarColors.hexColor,
      ),
      drawer: SideBar(
        textStyle:
            const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
        iconColor: Colors.white,
        backgroundColor: AppBarColors.ABar_Colors_tab,
        items: [
          for (int i = 0; i < perMissionModels.length; i++)
            if (int.parse(perMissionModels[i].ser!) <= 3)
              AdminMenuItem(
                title:
                    '${translate_menu[i]}', //perMissionModels[i].perm!.trim(),
                route: '/${perMissionModels[i].perm!.trim()}',
                icon: IconData(
                  int.parse(
                    '${perMissionModels[i].icon}',
                  ),
                  fontFamily: 'MaterialIcons',
                ),
              ),
          AdminMenuItem(
            title: '${more_menu}', // 'อื่นๆ',
            // icon: Icons.more_horiz,
            icon: IconData(
              int.parse(
                '0xf8d9',
              ),
              fontFamily: 'MaterialIcons',
            ),
            children: [
              for (int i = 0; i < perMissionModels.length; i++)
                if (int.parse(perMissionModels[i].ser!) > 3)
                  AdminMenuItem(
                    title:
                        '${translate_menu[i]}', //perMissionModels[i].perm!.trim(),
                    route: '/${perMissionModels[i].perm!.trim()}',
                    icon: IconData(
                      int.parse(
                        '${perMissionModels[i].icon}',
                      ),
                      fontFamily: 'MaterialIcons',
                    ),
                  ),
              AdminMenuItem(
                title: 'แอดมินซัพพอร์ต',
                route: '/AdminSupport',
                icon: IconData(
                  int.parse('0xe621'), // Admin Panel Settings
                  fontFamily: 'MaterialIcons',
                ),
              ),
              // ✅ ใบอนุญาต sub-menu (mobile)
              AdminMenuItem(
                title: 'ใบอนุญาต',
                route: '/LicenseMenu',
                icon: IconData(
                  int.parse('0xe90e'), // Verified User
                  fontFamily: 'MaterialIcons',
                ),
                children: const [
                  AdminMenuItem(
                    title: 'ประกาศ',
                    route: '/LicenseAnnounce',
                    icon: IconData(0xe7f4, fontFamily: 'MaterialIcons'),
                  ),
                  AdminMenuItem(
                    title: 'ทำสัญญา',
                    route: '/LicenseContract',
                    icon: IconData(0xe53e, fontFamily: 'MaterialIcons'),
                  ),
                  AdminMenuItem(
                    title: 'แนบหลักฐาน',
                    route: '/LicenseAttach',
                    icon: IconData(0xe226, fontFamily: 'MaterialIcons'),
                  ),
                  AdminMenuItem(
                    title: 'รับชำระ',
                    route: '/LicensePayment',
                    icon: IconData(0xe227, fontFamily: 'MaterialIcons'),
                  ),
                  AdminMenuItem(
                    title: 'ตรวจสอบหลักฐาน',
                    route: '/LicenseVerify',
                    icon: IconData(0xe8e8, fontFamily: 'MaterialIcons'),
                  ),
                  AdminMenuItem(
                    title: 'ตรวจสอบข้อเท็จจริง',
                    route: '/LicenseFactCheck',
                    icon: IconData(0xe8b1, fontFamily: 'MaterialIcons'),
                  ),
                  AdminMenuItem(
                    title: 'อนุมัติคำขอ',
                    route: '/LicenseApprove',
                    icon: IconData(0xe5ca, fontFamily: 'MaterialIcons'),
                  ),
                ],
              ),
            ],
          ),
        ],
        selectedRoute: '/$Value_Route',
        onSelected: (item) async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          if (preferences.getString('zonesName').toString() == 'null') {
            setState(() {
              preferences.setString('zoneSer', '0');
              preferences.setString('zonesName', 'ทั้งหมด');
            });
          }
          // ✅ Static menu: แอดมิน#sym:AdminSupport
          if (item.route == '/AdminSupport') {
            if (renTal_user != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('route', 'AdminSupport');
              setState(() {
                Value_Route = 'AdminSupport';
                Navigator.pop(context);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Translate.TranslateAndSetText(
                      'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
                      Colors.black,
                      TextAlign.center,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1),
                ),
              );
            }
            return;
          }
          // ✅ License sub-menu routes (mobile)
          const licenseRoutes = {
            '/LicenseContract': 'LicenseContract',
            '/LicensePayment': 'LicensePayment',
            '/LicenseAttach': 'LicenseAttach',
            '/LicenseVerify': 'LicenseVerify',
            '/LicenseFactCheck': 'LicenseFactCheck',
            '/LicenseApprove': 'LicenseApprove',
            '/LicenseAnnounce': 'LicenseAnnounce',
          };
          if (licenseRoutes.containsKey(item.route)) {
            if (renTal_user != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              final routeName = licenseRoutes[item.route]!;
              prefs.setString('route', routeName);
              setState(() {
                Value_Route = routeName;
                Navigator.pop(context);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Translate.TranslateAndSetText(
                      'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
                      Colors.black,
                      TextAlign.center,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1),
                ),
              );
            }
            return;
          }
          for (int i = 0; i < perMissionModels.length; i++) {
            if (item.route == '/${perMissionModels[i].perm!.trim()}') {
              if (renTal_user != null) {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.setString(
                    'route', perMissionModels[i].perm!.trim().toString());
                setState(() {
                  preferences.setString('Ser_Typepay', '0');
                  Value_Route = perMissionModels[i].perm!.trim();
                  // print(Value_Route);
                  Navigator.pop(context);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Translate.TranslateAndSetText(
                        'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
                        Colors.black,
                        TextAlign.center,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        1),
                  ),
                );
              }
              // read_GC_rentalColor(); // ❌ ดึง GC_rental_setring.php ซ้ำทุกครั้งที่กดแท็บ → read_GC_rental() ดึงมาแล้วตอน initState
            }
          }
          // print(Value_Route);
        },
        header: Container(
          color: AppBarColors.ABar_Colors_tab,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: AppBarColors.ABar_Colors_tab,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                ),
                child: const Image(
                  image: AssetImage('images/chaoperty_dark.png'),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    Value_Route = 'หน้าหลัก';
                    Navigator.pop(context);
                  });
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setString('route', 'หน้าหลัก');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Translate.TranslateAndSetText(
                          'เมนูหลัก',
                          Colors.black,
                          TextAlign.center,
                          FontWeight.bold,
                          FontWeight_.Fonts_T,
                          14,
                          1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        footer: Container(
          // height: 50,
          width: double.infinity,
          color: AppBarColors.ABar_Colors_tab,
          child: Container(
            // height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0)),
            ),
            child: Column(
              children: [
                // (ren_ser.toString() == '114')
                //     ? Padding(
                //         padding: EdgeInsets.all(4.0),
                //         child: InkWell(
                //           onTap: () async {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => WebView_NainaSetting(),
                //               ),
                //             );
                //           },
                //           child: Container(
                //             decoration: BoxDecoration(
                //               color: AppBarColors.hexColor.withOpacity(0.9),
                //               borderRadius: BorderRadius.only(
                //                   topLeft: Radius.circular(10),
                //                   topRight: Radius.circular(10),
                //                   bottomLeft: Radius.circular(10),
                //                   bottomRight: Radius.circular(10)),
                //             ),
                //             padding: EdgeInsets.all(4.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: const [
                //                 Icon(
                //                   Icons.hotel,
                //                   color: Colors.white,
                //                 ),
                //                 Text(
                //                   'Nainaservice',
                //                   maxLines: 1,
                //                   overflow: TextOverflow.ellipsis,
                //                   softWrap: false,
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(
                //                       color: Colors.white,
                //                       fontWeight: FontWeight.bold,
                //                       fontFamily: Font_.Fonts_T,
                //                       fontSize: 16.0),
                //                 ),
                //                 Text(
                //                   '> >',
                //                   maxLines: 1,
                //                   overflow: TextOverflow.ellipsis,
                //                   softWrap: false,
                //                   textAlign: TextAlign.center,
                //                   style: TextStyle(
                //                       color: Colors.white,
                //                       fontWeight: FontWeight.bold,
                //                       fontFamily: Font_.Fonts_T,
                //                       fontSize: 16.0),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       )
                //     :
                renTal_lavel! <= 3
                    ? SizedBox()
                    : passcode == null
                        ? SizedBox()
                        : Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '$passcode',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 20.0),
                              ),
                            ),
                          ),
                // renTal_lavel! <= 1
                //     ? SizedBox()
                //     : passcode == null
                //         ? SizedBox()
                //         : Center(
                //             child: Padding(
                //               padding: EdgeInsets.all(8.0),
                //               child: Text(
                //                 '$passcode',
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //                 softWrap: false,
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                     color: Colors.orange.shade900,
                //                     fontWeight: FontWeight.bold,
                //                     fontFamily: Font_.Fonts_T,
                //                     fontSize: 20.0),
                //               ),
                //             ),
                //           ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '© 2026  Dzentric Co.,Ltd. All Rights Reserved',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AdminScafScreen_Color.Colors_Text2_,
                          // fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                          fontSize: 10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: (Value_Route == 'หน้าหลัก')
          ? const HomeScreen2()

          //  const HomeScreen()
          : (Value_Route == 'พื้นที่เช่า')
              ? ChaoAreaScreen()
              : (Value_Route == 'ใบอนุญาต')
                  ? RequestContract_CMM(
                      route_getdata:
                          widget.route_getdata ?? "") //ChaoAreaScreen()
                  : (Value_Route == 'RequestExaminer1_CMM')
                      ? const RequestExaminer1_CMM(
                          viewver: false,
                          plugin: false,
                        )
                      : (Value_Route == 'RequestExaminer2_CMM')
                          ? const RequestExaminer2_CMM(
                              viewver: false,
                              plugin: false,
                            )
                          : (Value_Route == 'SignaturePad_CMM')
                              ? const SignaturePad_CMM()
                              : (Value_Route == 'AdminSupport')
                                  ? AdminSupport()
                                  : (Value_Route == 'ผู้เช่า')
                                      ? const PeopleChaoScreen()
                                      : (Value_Route == 'บัญชี')
                                          ? const AccountScreen()
                                          : (Value_Route == 'จัดการ')
                                              ? const ManageScreen()
                                              : (Value_Route == 'รายงาน')
                                                  ? ReportScreen()
                                                  : (Value_Route == 'ทะเบียน')
                                                      ? RegistrationPage
                                                          .create()
                                                      : (Value_Route ==
                                                              'ตั้งค่า')
                                                          ? const SettingScreen()
                                                          : (Value_Route ==
                                                                  'จัดการข้อมูลส่วนตัว')
                                                              ? ManagePersonalInformation_CMM() //USerInformation()
                                                              : (Value_Route ==
                                                                      'TestPrintNamePage')
                                                                  ? TestPrintNamePage()
                                                                  : const SettingUserScreen(),
      // body: (Value_Route == 'หน้าหลัก')
      //     ? const HomeScreen()
      //     : (Value_Route == 'พื้นที่เช่า')
      //         ? const ChaoAreaScreen()
      //         : (Value_Route == 'ผู้เช่า')
      //             ? const PeopleChaoScreen()
      //             : (Value_Route == 'บัญชี')
      //                 ? const AccountScreen()
      //                 : (Value_Route == 'จัดการ')
      //                     ? const ManageScreen()
      //                     : (Value_Route == 'รายงาน' &&
      //                             (renTal_user.toString() == '72' ||
      //                                 renTal_user.toString() == '92' ||
      //                                 renTal_user.toString() == '93' ||
      //                                 renTal_user.toString() == '94'))
      //                         ? const Report_Ortor_Screen()
      //                         : (Value_Route == 'รายงาน' &&
      //                                 renTal_user.toString() == '65')
      //                             ? const Report_cm_Screen()
      //                             : (Value_Route == 'รายงาน' &&
      //                                     renTal_user.toString() != '65')
      //                                 ? ReportScreen()
      //                                 : (Value_Route == 'ทะเบียน')
      //                                     ? const BureauScreen()
      //                                     : (Value_Route == 'ตั้งค่า')
      //                                         ? const SettingScreen()
      //                                         : (Value_Route ==
      //                                                 'จัดการข้อมูลส่วนตัว')
      //                                             ? const Accessrights()
      //                                             : const Accessrights(),
    );
  }

  void routToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) {
      return false;
    });
  }

  /////////------------------------------------------->

  // ❌ ดึง API ซ้ำกับ read_GC_rental() (ใช้ GC_rental_setring.php เหมือนกัน)
  // Future<Null> read_GC_rentalColor() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //
  //   String url =
  //       '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
  //
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //
  //     var result = json.decode(response.body);
  //
  //     if (result != null) {
  //       for (var map in result) {
  //         RenTalModel renTalModels = RenTalModel.fromJson(map);
  //         dynamic colorsren = renTalModels.colors_ren;
  //         dynamic colorsren_sub = renTalModels.colors_subren;
  //         New_Appbar_color(colorsren, colorsren_sub);
  //       }
  //     } else {}
  //   } catch (e) {}
  // }

/////////------------------------------------------->
  Future<Null> New_Appbar_color(colors_ren, colorsren_sub) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic colorsren = colors_ren;
    var Check_New_color = preferences.getString('Check_New_color');
    var Check_New_colorsub = preferences.getString('Check_New_colorsub');

    if (Check_New_color.toString() == colorsren.toString() &&
        Check_New_colorsub.toString() == colorsren_sub.toString()) {
      // print(Check_New_color.toString());
      // print(colorsren.toString());
    } else {
      if (renTalModels.isNotEmpty) {
        if (colorsren is String) {
          if (colorsren != null &&
              colorsren.toString() != '' &&
              colorsren.toString() != 'null') {
            setState(() => AppBarColors.hexColor = Color(int.parse(colorsren)));
            preferences.setString('Check_New_color', '${colorsren}');
          }

          if (colorsren_sub != null &&
              colorsren_sub.toString() != '' &&
              colorsren_sub.toString() != 'null') {
            setState(() =>
                AppBarColors.ABar_Colors_tab = Color(int.parse(colorsren_sub)));
            preferences.setString('Check_New_colorsub', '${colorsren_sub}');
          }
        } else {}
      }
      String? _route = preferences.getString('route');
      MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (BuildContext context) => AdminScafScreen(route: _route));
      Navigator.pushAndRemoveUntil(
          context, materialPageRoute, (route) => false);
    }
  }

/////////------------------------------------------->
}

class _FloatingLanternDot extends StatelessWidget {
  const _FloatingLanternDot({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        // ใช้ math.sin() แทน sinSync
        final dy = math.sin(t * 2 * math.pi) * 2.0;

        return Transform.translate(
          offset: Offset(0, -dy),
          child: Container(
            width: 8,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC76D),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFE08A).withOpacity(.55),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
