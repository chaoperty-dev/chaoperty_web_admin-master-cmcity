// // ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, prefer_const_constructors, unnecessary_import, implementation_imports, prefer_const_constructors_in_immutables, non_constant_identifier_names, avoid_init_to_null, prefer_void_to_null, unnecessary_brace_in_string_interps, avoid_print, empty_catches, sized_box_for_whitespace, use_build_context_synchronously, file_names, curly_braces_in_flow_control_structures
// import 'dart:async';
// import 'dart:convert';
// import 'package:get_ip_address/get_ip_address.dart';
// import 'package:marquee/marquee.dart';
// import 'package:device_marketing_names/device_marketing_names.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_admin_scaffold/admin_scaffold.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:side_sheet/side_sheet.dart';
// // import 'package:timer_builder/timer_builder.dart';

// import '../Account/Ac_Sub/Account_Screen.dart';
// import '../Account/Play_column.dart';
// import '../Beam/Beam_api_check_Pay.dart';
// import '../Bureau_Registration/Bureau_Screen.dart';
// import '../ChaoArea/ChaoArea_Screen.dart';
// import '../ChiangMai_Municipality/List_CMM/Register_CMM/AuthService.dart';
// import '../ChiangMai_Municipality/List_CMM/Register_CMM/Login_page_cmm.dart';
// import '../ChiangMai_Municipality/cignaturepad_cmm.dart';
// import '../ChiangMai_Municipality/request_contract_cmm.dart';
// import '../ChiangMai_Municipality/request_examiner1_cmm.dart';
// import '../ChiangMai_Municipality/request_examiner2_cmm.dart';
// import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';
// import '../Constant/Myconstant.dart';
// import '../Bureau_Registration/Customer_Screen.dart';
// import '../Constant/global_http.dart';
// import '../Home/Home_Screen.dart';
// import '../INSERT_Log/Insert_log.dart';
// import '../Manage/Manage_Screen.dart';
// import '../Manage/Repairs_Screen.dart';
// import '../Model/GetPayMent_Model.dart';
// import '../Model/GetPerMission_Model.dart';
// import '../Model/GetRenTal_Model.dart';
// import '../Model/GetUser_Model.dart';
// import '../Model/Get_Chat_Model.dart';
// import '../Model/areak_model.dart';
// import '../Model/connecAmin_model.dart';
// import '../PeopleChao/PeopleChao_Screen.dart';
// import '../Register/SignIn_License.dart';
// import '../Register/SignIn_Screen.dart';
// import '../Register/SignIn_ScreenTp3.dart';
// import '../Register/SignUp_Screen.dart';
// import '../Report/Report_Screen.dart';
// import 'package:http/http.dart' as http;
// import '../Report_Ortorkor/Report_Ortor_Screen.dart';
// import '../Report_cm/Report_cm_Screen.dart';
// import '../Responsive/responsive.dart';

// import '../Setting/Access_Rights.dart';
// import '../Setting/SettingScreen.dart';
// import '../Setting/SettingScreen_user.dart';
// import '../Setting/ttt.dart';
// import '../Setting_NainaService/Web_view_NainaSetting.dart';
// import '../Style/Translate.dart';
// import '../Style/colors.dart';
// import '../Style/view_pagenow.dart';
// import '../main.dart';
// import 'Chat_Screen.dart';
// import 'package:provider/provider.dart';

// import 'Ribbon.dart';

// class AdminScafScreen extends StatefulWidget {
//   // const AdminScafScreen({super.key});

//   @override
//   State<AdminScafScreen> createState() => _AdminScafScreenState();
//   final String? route;
//   AdminScafScreen({
//     super.key,
//     this.route,
//   });
// }

// class _AdminScafScreenState extends State<AdminScafScreen> {
//   DateTime datex = DateTime.now();
//   int serBody_modile_wiget = 0;
//   String Value_Route = 'หน้าหลัก';

//   String? ser_user,
//       position_user,
//       fname_user,
//       lname_user,
//       email_user,
//       utype_user,
//       permission_user,
//       renTal_user,
//       renTal_name,
//       ren_ser,
//       renTal_Email,
//       passcode,
//       time_check,
//       Auto_cancel;
//   int? perMissioncount;
//   List<RenTalModel> renTalModels = [];
//   List<PerMissionModel> perMissionModels = [];
//   List<AreakModel> areakModels = [];
//   List<UserModel> userModels = [];
//   List<UserModel> userModels_chat = [];
//   int? timeoutper = null;
//   DateTime? alert;
//   Timer? timer;
//   bool isActive = false;
//   bool _timerStarted = false; // guard ป้องกัน startTimer() วนซ้ำ
//   String? rtname, type, typex, renname, pkname, ser_Zonex, pkldate, data_update;
//   int? pkqty, pkuser, countarae, renTal_lavel = 0;
//   String? base64_Imgmap, foder;
//   String? tel_user, img_, img_logo;
//   String singleDeviceName = "Unknown";
//   String singleDeviceNameFromModel = "Unknown";
//   String deviceNames = "Unknown";
//   String deviceNamesFromModel = "Unknown";
//   final _keybar = GlobalKey<ScaffoldState>();

//   final _formKey = GlobalKey<FormState>();
//   final Formpasslok_ = TextEditingController();
//   ///////////------------------------------------------->

//   List<ChatModel> chatModel = [];
//   List<ChatModel> chatModel_new = [];
//   // List<ChatModel> _chatModel = <ChatModel>[];
//   late StreamController<int> _streamController;
//   late int _counter;
//   late Timer _timer;
//   bool? isDark_Mode;
//   bool isSidebarOpen = true;
// ///////////------------------------------------------->
//   @override
//   void initState() {
//     super.initState();
//     serBody_modile_wiget = 0; // ตั้งค่าเริ่มต้นที่นี่ ไม่ใช่ใน build()
//     checkPreferance();
//     read_GC_rental().then((value) => signInThreadMain());

//     Value_Route = widget.route!;
//     alert = DateTime.now().add(Duration(seconds: 300));
//     readTime();
//     read_GC_areak();
//     initPlugin();
//     _loadSidebarState();
//     // changLogin();
//   }

//   String? system_datex_;
//   String? showst_update_;

//   Future<void> _loadSidebarState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getBool('isSidebarOpen') ?? true;
//     setState(() {
//       isSidebarOpen = saved;
//     });
//   }

//   Future<void> _toggleSidebar() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isSidebarOpen = !isSidebarOpen;
//     });
//     await prefs.setBool('isSidebarOpen', isSidebarOpen);

//     print('_toggleSidebar');
//   }

//   Future<Null> System_User() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var email_ = preferences.getString('email');
//     String url = '${MyConstant().domain}/GC_user.php?isAdd=true&email=$email_';

//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result != null) {
//         for (var map in result) {
//           UserModel userModel = UserModel.fromJson(map);

//           setState(() {
//             system_datex_ = userModel.system_datex!;
//             showst_update_ = userModel.showst_update!;
//           });
//         }
//       } else {}
//     } catch (e) {}
//     // print('userModel  --------- >${system_datex_}');
//     // print('userModel  --------- >${showst_update_}');
//     if (showst_update_ == '0') {
//       System_New_Update();
//     }
//   }

//   Future<Null> System_New_Update() async {
//     String accept_ = showst_update_!;
//     showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => AlertDialog(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0))),
//         title: Text(
//           '📢 ${system_datex_}',
//           textAlign: TextAlign.end,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.black,
//             fontFamily: Font_.Fonts_T,
//           ),
//         ),
//         content: Container(
//           decoration: BoxDecoration(
//             image: const DecorationImage(
//               image: AssetImage("images/pngegg.png"),
//               // fit: BoxFit.cover,
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Container(
//                   height: 150,
//                   width: 150,
//                   child: Image.asset(
//                     'images/update.png',
//                     // fit: BoxFit.contain,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'ขออภัย ขณะนี้ระบบได้มีการอัพเดต ',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: FontWeight_.Fonts_T,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     'คำแนะนำโปรดออกจากระบบ และทำการรีเฟรช',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: FontWeight_.Fonts_T,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: <Widget>[
//           StreamBuilder(
//               stream: Stream.periodic(const Duration(seconds: 1)),
//               builder: (context, snapshot) {
//                 return Column(
//                   children: [
//                     const Divider(
//                       color: Colors.grey,
//                       height: 4.0,
//                     ),
//                     if (Responsive.isDesktop(context))
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Row(
//                             children: [
//                               InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       accept_ = '0';
//                                     });
//                                   },
//                                   child: Icon(
//                                     (accept_ == '0')
//                                         ? Icons.check_box
//                                         : Icons.check_box_outline_blank,
//                                     color: (accept_ == '0')
//                                         ? Colors.red
//                                         : Colors.black,
//                                   )),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   'แสดง ทุกครั้ง/ออกจากระบบ ทุกครั้ง',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.blue[900],
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               InkWell(
//                                 onTap: () {
//                                   setState(() {
//                                     accept_ = '1';
//                                   });
//                                 },
//                                 child: Icon(
//                                     (accept_ == '0')
//                                         ? Icons.check_box_outline_blank
//                                         : Icons.check_box,
//                                     color: (accept_ == '0')
//                                         ? Colors.black
//                                         : Colors.red),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   'แสดงอีกครั้งเมื่อมีการอัพเดต',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.black,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     if (!Responsive.isDesktop(context))
//                       SizedBox(
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         accept_ = '0';
//                                       });
//                                     },
//                                     child: Icon(
//                                       (accept_ == '0')
//                                           ? Icons.check_box
//                                           : Icons.check_box_outline_blank,
//                                       color: (accept_ == '0')
//                                           ? Colors.red
//                                           : Colors.black,
//                                     )),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'แสดง ทุกครั้ง',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.blue[900],
//                                       fontFamily: Font_.Fonts_T,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 InkWell(
//                                   onTap: () {
//                                     setState(() {
//                                       accept_ = '1';
//                                     });
//                                   },
//                                   child: Icon(
//                                       (accept_ == '0')
//                                           ? Icons.check_box_outline_blank
//                                           : Icons.check_box,
//                                       color: (accept_ == '0')
//                                           ? Colors.black
//                                           : Colors.red),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     'แสดงอีกครั้งเมื่อมีการอัพเดต',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black,
//                                       fontFamily: Font_.Fonts_T,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     const SizedBox(
//                       height: 5.0,
//                     ),
//                     const Divider(
//                       color: Colors.grey,
//                       height: 4.0,
//                     ),
//                     const SizedBox(
//                       height: 5.0,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 100,
//                             decoration: const BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: TextButton(
//                               onPressed: () async {
//                                 SharedPreferences preferences =
//                                     await SharedPreferences.getInstance();
//                                 var email_ = preferences.getString('email');
//                                 // print(accept_);
//                                 if (accept_ == '1') {
//                                   String url =
//                                       '${MyConstant().domain}/UP_Show_System.php?isAdd=true&email=$email_';

//                                   try {
//                                     var response =
//                                         await httpClient.get(Uri.parse(url));

//                                     var result = json.decode(response.body);

//                                     if (result.toString() == 'true') {
//                                       Navigator.pop(context, 'OK');
//                                     } else {
//                                       Navigator.pop(context, 'OK');
//                                     }
//                                   } catch (e) {}
//                                 } else {
//                                   Navigator.pop(context, 'OK');
//                                 }
//                                 //   showDialog<String>(
//                                 //   barrierDismissible: false,
//                                 //   context: context,
//                                 //   builder: (BuildContext context) =>
//                                 //       AlertDialog(
//                                 //     shape: const RoundedRectangleBorder(
//                                 //         borderRadius: BorderRadius.all(
//                                 //             Radius.circular(20.0))),
//                                 //     title: Column(
//                                 //       children: [
//                                 //         const Center(
//                                 //             child: Text(
//                                 //           'ออกจากระบบ',
//                                 //           style: TextStyle(
//                                 //               color: AdminScafScreen_Color
//                                 //                   .Colors_Text1_,
//                                 //               fontWeight: FontWeight.bold,
//                                 //               fontFamily: FontWeight_.Fonts_T),
//                                 //         )),
//                                 //         const Center(
//                                 //             child: Text(
//                                 //           '( บังคับออกจากระบบ เนื่องจากระบบได้มีการอัพเดต )',
//                                 //           style: TextStyle(
//                                 //               fontSize: 14,
//                                 //               color: Colors.grey,
//                                 //               fontFamily: Font_.Fonts_T),
//                                 //         )),
//                                 //         const Center(
//                                 //             child: Text(
//                                 //           '# กรุณาเข้าสู่ระบบอีกครั้ง ',
//                                 //           style: TextStyle(
//                                 //               fontSize: 14,
//                                 //               color: Colors.grey,
//                                 //               fontFamily: Font_.Fonts_T),
//                                 //         )),
//                                 //       ],
//                                 //     ),
//                                 //     actions: <Widget>[
//                                 //       Column(
//                                 //         children: [
//                                 //           const SizedBox(
//                                 //             height: 5.0,
//                                 //           ),
//                                 //           const Divider(
//                                 //             color: Colors.grey,
//                                 //             height: 4.0,
//                                 //           ),
//                                 //           const SizedBox(
//                                 //             height: 5.0,
//                                 //           ),
//                                 //           Padding(
//                                 //             padding: const EdgeInsets.all(8.0),
//                                 //             child: Row(
//                                 //               mainAxisAlignment:
//                                 //                   MainAxisAlignment.center,
//                                 //               children: [
//                                 //                 Padding(
//                                 //                   padding:
//                                 //                       const EdgeInsets.all(8.0),
//                                 //                   child: Container(
//                                 //                     width: 100,
//                                 //                     decoration:
//                                 //                         const BoxDecoration(
//                                 //                       color: Colors.red,
//                                 //                       borderRadius:
//                                 //                           BorderRadius.only(
//                                 //                               topLeft: Radius
//                                 //                                   .circular(10),
//                                 //                               topRight: Radius
//                                 //                                   .circular(10),
//                                 //                               bottomLeft: Radius
//                                 //                                   .circular(10),
//                                 //                               bottomRight:
//                                 //                                   Radius
//                                 //                                       .circular(
//                                 //                                           10)),
//                                 //                     ),
//                                 //                     padding:
//                                 //                         const EdgeInsets.all(
//                                 //                             8.0),
//                                 //                     child: TextButton(
//                                 //                       onPressed: () async {
//                                 //                         deall_Trans_select();
//                                 //                         SharedPreferences
//                                 //                             preferences =
//                                 //                             await SharedPreferences
//                                 //                                 .getInstance();
//                                 //                         var ser = preferences
//                                 //                             .getString('ser');
//                                 //                         var on = '0';
//                                 //                         String url =
//                                 //                             '${MyConstant().domain}/U_user_onoff.php?isAdd=true&ser=$ser&on=$on';

//                                 //                         try {
//                                 //                           var response =
//                                 //                               await httpClient.get(
//                                 //                                   Uri.parse(
//                                 //                                       url));

//                                 //                           var result = json
//                                 //                               .decode(response
//                                 //                                   .body);
//                                 //                           print(result);
//                                 //                           if (result
//                                 //                                   .toString() ==
//                                 //                               'true') {
//                                 //                             SharedPreferences
//                                 //                                 preferences =
//                                 //                                 await SharedPreferences
//                                 //                                     .getInstance();
//                                 //                             preferences.clear();
//                                 //                             routToService(
//                                 //                                 SignInScreen());
//                                 //                           } else {
//                                 //                             ScaffoldMessenger
//                                 //                                     .of(context)
//                                 //                                 .showSnackBar(
//                                 //                               SnackBar(
//                                 //                                   content: Text(
//                                 //                                       '(ผิดพลาด)')),
//                                 //                             );
//                                 //                           }
//                                 //                         } catch (e) {}
//                                 //                       },
//                                 //                       child: const Text(
//                                 //                         'รับทราบ',
//                                 //                         style: TextStyle(
//                                 //                             color: Colors.white,
//                                 //                             fontWeight:
//                                 //                                 FontWeight.bold,
//                                 //                             fontFamily:
//                                 //                                 FontWeight_
//                                 //                                     .Fonts_T),
//                                 //                       ),
//                                 //                     ),
//                                 //                   ),
//                                 //                 ),
//                                 //                 // Padding(
//                                 //                 //   padding:
//                                 //                 //       const EdgeInsets.all(8.0),
//                                 //                 //   child: Row(
//                                 //                 //     mainAxisAlignment:
//                                 //                 //         MainAxisAlignment
//                                 //                 //             .center,
//                                 //                 //     children: [
//                                 //                 //       Container(
//                                 //                 //         width: 100,
//                                 //                 //         decoration:
//                                 //                 //             const BoxDecoration(
//                                 //                 //           color:
//                                 //                 //               Colors.redAccent,
//                                 //                 //           borderRadius: BorderRadius.only(
//                                 //                 //               topLeft: Radius
//                                 //                 //                   .circular(10),
//                                 //                 //               topRight: Radius
//                                 //                 //                   .circular(10),
//                                 //                 //               bottomLeft: Radius
//                                 //                 //                   .circular(10),
//                                 //                 //               bottomRight:
//                                 //                 //                   Radius
//                                 //                 //                       .circular(
//                                 //                 //                           10)),
//                                 //                 //         ),
//                                 //                 //         padding:
//                                 //                 //             const EdgeInsets
//                                 //                 //                 .all(8.0),
//                                 //                 //         child: TextButton(
//                                 //                 //           onPressed: () =>
//                                 //                 //               Navigator.pop(
//                                 //                 //                   context,
//                                 //                 //                   'OK'),
//                                 //                 //           child: const Text(
//                                 //                 //             'ยกเลิก',
//                                 //                 //             style: TextStyle(
//                                 //                 //                 color: Colors
//                                 //                 //                     .white,
//                                 //                 //                 fontWeight:
//                                 //                 //                     FontWeight
//                                 //                 //                         .bold,
//                                 //                 //                 fontFamily:
//                                 //                 //                     FontWeight_
//                                 //                 //                         .Fonts_T),
//                                 //                 //           ),
//                                 //                 //         ),
//                                 //                 //       ),
//                                 //                 //     ],
//                                 //                 //   ),
//                                 //                 // ),
//                                 //               ],
//                                 //             ),
//                                 //           ),
//                                 //         ],
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 // );
//                               },
//                               child: const Text(
//                                 'รับทราบ',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: FontWeight_.Fonts_T),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               })
//         ],
//       ),
//     );
//   }

//   Future<Null> changLogin() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var email = preferences.getString('email');
//     if (email != 'dzentric.com@gmail.com') {
//       Timer.periodic(const Duration(seconds: 35), (timer) {
//         changLoginOut(timer);
//       });
//     }
//   }

//   Future<Null> changLoginOut(timer) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var login = preferences.getString('login');
//     var ipAddress = IpAddress(type: RequestType.json);

//     /// Get the IpAddress based on requestType.
//     dynamic data = await ipAddress.getIpAddress();
//     // print(data.toString());

//     var data0 = data.toString().substring(5, data.toString().length - 1).trim();
//     // print(data0.toString());

//     String url =
//         '${MyConstant().domain}/changLoginOut.php?isAdd=true&user=$user&iplogin=$data0';
//     // print(url.toString());

//     // print('>>>>> login $login');
//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       print('---------------->');
//       print('changLoginOut >$login>$user>');
//       // print('changLoginOut>$login>$user>>${result.toString()}');
//       Auto_Recheck_pay_Beam_Checkout();
//       if (result.toString() != login) {
//         deall_Trans_select();
//         SharedPreferences preferences = await SharedPreferences.getInstance();
//         preferences.clear();
//         routToService(SignInScreen());
//         timer.cancel();
//       }
//     } catch (e) {}
//   }

//   //////////////----------------------------------------->
//   Future<Null> Auto_Recheck_pay_Beam_Checkout() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
//     var Pay_Ke;
//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result.toString() != 'null') {
//         // ✅ อ่านค่าสุดท้ายใน loop แล้ว setState ครั้งเดียวนอก
//         String? lastPayKey;
//         for (var map in result) {
//           PayMentModel _PayMentModel = PayMentModel.fromJson(map);
//           lastPayKey = _PayMentModel.key_b?.toString();
//         }
//         if (lastPayKey != null) {
//           setState(() {
//             Pay_Ke = lastPayKey;
//           });
//         }
//         // Future.delayed(Duration(seconds: 100), () async {});

//         // read_CheckBeamAll(ren, Pay_Ke);
//         if (Pay_Ke == null ||
//             Pay_Ke.toString() == '' ||
//             Pay_Ke.toString() == 'null') {
//         } else {
//           read_CheckBeamAll(ren, Pay_Ke);
//         }
//         // RecheckAuto(ren, Pay_Ke);
//       }
//     } catch (e) {}
//   }

//   //////////////----------------------------------------->
//   Future<Null> passcode_in() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');

//     String url =
//         '${MyConstant().domain}/Inc_passcode.php?isAdd=true&ren=$ren&user=$user';
//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result.toString() != 'false') {
//         // print('Inc_passcode>>>>true');
//         setState(() {
//           passcode = result.toString();
//         });
//       } else {
//         // print('Inc_passcode>>>>false $result');
//       }
//     } catch (e) {
//       // print('rrrrrrrrrrrrrr $e');
//     }
//   }

//   Future<Null> deall_Trans_select() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');

//     String url =
//         '${MyConstant().domain}/D_tran_select.php?isAdd=true&ren=$ren&user=$user';
//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result.toString() == 'true') {
//       } else if (result.toString() == 'false') {
//         // print('rrrrrrrrrrrrrrfalse');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
//                   style: TextStyle(
//                       color: Colors.white, fontFamily: Font_.Fonts_T))),
//         );
//       }
//     } catch (e) {
//       // print('rrrrrrrrrrrrrr $e');
//     }
//   }

//   Future<void> initPlugin() async {
//     const model = "Device : ";
//     final deviceMarketingNames = DeviceMarketingNames();
//     final currentSingleDeviceName = await deviceMarketingNames.getSingleName();
//     final currentDeviceNames = await deviceMarketingNames.getNames();
//     setState(() {
//       singleDeviceName = currentSingleDeviceName;
//       deviceNames = currentDeviceNames;
//       singleDeviceNameFromModel = deviceMarketingNames.getSingleNameFromModel(
//           DeviceType.android, model);
//       deviceNamesFromModel =
//           deviceMarketingNames.getNamesFromModel(DeviceType.android, model);
//     });
//   }

//   String? connected_Minutes;
//   void startTimer() {
//     // Guard: ป้องกันสร้าง Timer ซ้อนทับทุกครั้งที่กดปุ่ม
//     if (_timerStarted) return;
//     _timerStarted = true;

//     checkConnected();
//     upConnected();

//     // Create a timer that runs the read_connected function every 5 minutes
//     Timer.periodic(Duration(seconds: 300), (t) {
//       if (!mounted) {
//         t.cancel();
//         return;
//       }
//       checkConnected();
//       upConnected();
//     });
//   }

//   Future<void> upConnected() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     DateTime currentTime = DateTime.now();
//     String formattedDateTime =
//         DateFormat('yyyy-MM-dd HH:mm:ss').format(currentTime);
//     // print('$ren-----$user ----- ${formattedDateTime}');
//     // String url =
//     //     '${MyConstant().domain}/UP_Connected_User.php?isAdd=true&seruser=$user&value=$formattedDateTime';
//     try {
//       // var response = await httpClient.get(Uri.parse(url));

//       // if (response.statusCode == 200) {
//       //   // Check if the response status code is OK (200)
//       //   print('Success: ${response.body}');
//       // } else {
//       //   // Handle other response status codes if needed
//       //   print('HTTP Error: ${response.statusCode}');
//       // }
//     } catch (e) {
//       // print('Error: $e');
//     }
//   }

//   String read_data_davtext = '';

//   List<ConnecAminModel> ConnecAmins = [];
//   List<ConnecAminModel> _ConnecAmins = <ConnecAminModel>[];
//   Future<void> checkConnected() async {
//     const onlineWindow = Duration(minutes: 0);

//     // เคลียร์เก่าถ้ามี
//     if (ConnecAmins.isNotEmpty) {
//       ConnecAmins.clear();
//     }

//     final prefs = await SharedPreferences.getInstance();
//     final ren = prefs.getString('renTalSer');
//     if (ren == null || ren.isEmpty) {
//       // ไม่มีค่า ren ใน prefs
//       return;
//     }

//     final uri = Uri.parse('${MyConstant().domain}/Connected_AminSelect.php')
//         .replace(queryParameters: {
//       'isAdd': 'true',
//       'ren': ren,
//       // 'emailrental': renTal_Email,
//     });
//     print(uri);
//     try {
//       final res = await httpClient.get(uri);
//       if (res.statusCode != 200) {
//         print('HTTP ${res.statusCode}: ${res.body}');
//         return;
//       }

//       final decoded = json.decode(res.body);
//       if (decoded is! List) {
//         print('Unexpected JSON shape: not a List');
//         return;
//       }

//       final now = DateTime.now();
//       final items = <ConnecAminModel>[];

//       for (final e in decoded) {
//         if (e is! Map<String, dynamic>) continue;

//         final m = ConnecAminModel.fromJson(e);

//         // connected อาจเป็น null/ว่าง → ป้องกันไว้
//         final connectedStr = m.connected;
//         final connectedAt = DateTime.tryParse(connectedStr ?? '');

//         final isOnline =
//             connectedAt != null && now.difference(connectedAt) <= onlineWindow;

//         // ✅ ถ้าต้องการ “เฉพาะคนที่ออนไลน์ใน 15 นาที”
//         // if (isOnline) {
//         //   items.add(m);
//         // }
//         items.add(m);

//         // ❗ถ้าต้องการ “เก็บทั้งหมด” แต่ใช้แยกสถานะออนไลน์ทีหลัง:
//         // m.isOnline = isOnline;  // (เพิ่มฟิลด์ในโมเดล) แล้ว items.add(m);
//       }

//       // ✅ ตรวจ mounted ก่อน setState เสมอ เพี่อกัน setState after dispose
//       if (!mounted) return;
//       setState(() {
//         ConnecAmins
//           ..clear()
//           ..addAll(items);

//         _ConnecAmins = ConnecAmins;
//       });
//     } catch (e) {
//       print('checkConnected error: $e');
//     }
//   }

//   // Future<Null> Check_connected() async {
//   //   if (userModels.isNotEmpty) {
//   //     userModels.clear();
//   //     userModels_chat.clear();
//   //   }
//   //   SharedPreferences preferences = await SharedPreferences.getInstance();
//   //   var ren = preferences.getString('renTalSer');
//   //   String url =
//   //       '${MyConstant().domain}/Connected_AminSelect.php?isAdd=true&ren=$ren&emailrental=$renTal_Email';
//   //   int indexfor = 0;
//   //   try {
//   //     var response = await httpClient.get(Uri.parse(url));

//   //     var result = json.decode(response.body);
//   //     // print(result);
//   //     if (result != null) {
//   //       for (var map in result) {
//   //         UserModel userModel = UserModel.fromJson(map);
//   //         String connected_ = '${userModel.connected}';

//   //         DateTime connectedTime = DateTime.parse(connected_);

//   //         DateTime currentTime = DateTime.now();

//   //         Duration difference = currentTime.difference(connectedTime);

//   //         int minutesPassed = difference.inMinutes;
//   //         setState(() {
//   //           userModels_chat.add(userModel);
//   //         });
//   //         if (minutesPassed > 15) {
//   //         } else {
//   //           setState(() {
//   //             userModels.add(userModel);
//   //           });
//   //         }
//   //         if (indexfor == 0) {
//   //           read_data_davtext = '${userModel.dev_text}';
//   //         }
//   //         indexfor++;
//   //       }
//   //     } else {}
//   //   } catch (e) {}
//   //   // print('name>>>>>  $renname');
//   // }

//   Future<Null> read_GC_areak() async {
//     if (areakModels.isNotEmpty) {
//       areakModels.clear();
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     String url = '${MyConstant().domain}/In_c_areak.php?isAdd=true&ren=$ren';

//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result != null) {
//         // ✅ เก็บใน temp list และ setState ครั้งเดียวแทนการ setState ทุก item
//         final tempAreak = <AreakModel>[];
//         for (var map in result) {
//           tempAreak.add(AreakModel.fromJson(map));
//         }
//         setState(() {
//           areakModels.addAll(tempAreak);
//         });
//       } else {}
//     } catch (e) {}
//     // print('name>>>>>  $renname');
//   }

//   Future<Null> read_GC_rental() async {
//     String open_RIP_Dialog = '0';
//     if (renTalModels.isNotEmpty) {
//       renTalModels.clear();
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     String url =
//         '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);

//       if (result != null) {
//         for (var map in result) {
//           RenTalModel renTalModel = RenTalModel.fromJson(map);

//           // ✅ ทำ preferences I/O นอก setState (เป็น async ไม่ควรอยู่ใน setState)
//           await preferences.setString(
//               'renTalName', renTalModel.pn!.trim().toString());
//           await preferences.setString(
//               'renTalEmail', renTalModel.bill_email!.trim().toString());
//           await preferences.setString(
//               'renTal_Language', renTalModel.lan_guage!.trim().toString());
//           final foderx = renTalModel.dbn;
//           await preferences.setString('renTal_logo',
//               '${MyConstant().domain}/files/$foderx/logo/${renTalModel.imglogo}');

//           // ✅ batch setState ครั้งเดียวหลังจาก I/O เสร็จ
//           if (!mounted) return;
//           setState(() {
//             open_RIP_Dialog = renTalModel.his.toString();
//             Auto_cancel = preferences.getString('Auto_cancel');
//             ren_ser = ren!.trim().toString();
//             renTal_name = preferences.getString('renTalName');
//             time_check = renTalModel.time_check;
//             renTal_Email = renTalModel.bill_email.toString();
//             foder = foderx;
//             rtname = renTalModel.rtname;
//             type = renTalModel.type;
//             typex = renTalModel.typex;
//             renname = renTalModel.pn!.trim();
//             pkqty = int.parse(renTalModel.pkqty!);
//             pkuser = int.parse(renTalModel.pkuser!);
//             pkname = renTalModel.pk!.trim();
//             img_ = renTalModel.img;
//             img_logo = renTalModel.imglogo;
//             pkldate = renTalModel.pkldate;
//             data_update = renTalModel.data_update;
//             renTalModels.add(renTalModel);
//           });
//         }

//         if (renTalModels.isNotEmpty) {
//           final dynamic colorsren = renTalModels[0].colors_ren.toString();
//           final dynamic colorsren_sub = renTalModels[0].colors_subren;
//           final dynamic colors_light = renTalModels[0].colors_light;
//           final dynamic colors_dark = renTalModels[0].colors_dark;

//           if (colorsren is String) {
//             // ✅ รวม setState สีจาก 3 ครั้งเหลือ 1 ครั้ง
//             Color? newHexColor;
//             Color? newTabColor;
//             Color? newTitleColor;

//             if (renTalModels[0].colors_ren.toString() != '' &&
//                 renTalModels[0].colors_ren != null &&
//                 renTalModels[0].colors_ren.toString() != 'null') {
//               newHexColor = Color(int.parse(colorsren));
//             }
//             if (renTalModels[0].colors_subren.toString() != '' &&
//                 renTalModels[0].colors_subren != null &&
//                 renTalModels[0].colors_subren.toString() != 'null') {
//               newTabColor = Color(int.parse(colorsren_sub));
//             }

//             if (renTalModels[0].colors_light.toString() != '' &&
//                 renTalModels[0].colors_light != null &&
//                 renTalModels[0].colors_light.toString() != 'null') {
//               final bool isDarkMode =
//                   preferences.getBool('isDarkMode') ?? false;
//               newTitleColor = isDarkMode
//                   ? Color(int.parse(colors_dark))
//                   : Color(int.parse(colors_light));

//               if (!mounted) return;
//               setState(() {
//                 isDark_Mode = isDarkMode;
//                 if (newHexColor != null) AppBarColors.hexColor = newHexColor;
//                 if (newTabColor != null)
//                   AppBarColors.ABar_Colors_tab = newTabColor;
//                 if (newTitleColor != null)
//                   AppbackgroundColor.TiTile_Colors = newTitleColor;
//               });
//             } else {
//               // ตั้งค่าเริ่มต้นแล้วเสนอเป็นค่าเริ่มต้นไปยัง API
//               var Color_App_Bar = 0xFF102456;
//               var Color_Side_Bar = 0xFF8BB63B;
//               var Color_Light_Mode = 0xFFD9D9B7;
//               var Color_Dark_Mode = 0xff9ba2cb;
//               await preferences.setBool('isDarkMode', false);
//               String url1 =
//                   '${MyConstant().domain}/UP_ColorsRen.php?isAdd=true&colors_ren=${Color_App_Bar}&colors_type=1&ser_ren=${ren}&ser_tap=0';
//               String url2 =
//                   '${MyConstant().domain}/UP_ColorsRen.php?isAdd=true&colors_ren=${Color_Side_Bar}&colors_type=1&ser_ren=${ren}&ser_tap=1';
//               String url3 =
//                   '${MyConstant().domain}/UP_ColorsRen_Mode.php?isAdd=true&colors_ren=${Color_Light_Mode}&colors_type=1&ser_ren=${ren}&ser_tap=2';
//               String url4 =
//                   '${MyConstant().domain}/UP_ColorsRen_Mode.php?isAdd=true&colors_ren=${Color_Dark_Mode}&colors_type=1&ser_ren=${ren}&ser_tap=3';
//               await Future.wait([
//                 httpClient.get(Uri.parse(url1)),
//                 httpClient.get(Uri.parse(url2)),
//                 httpClient.get(Uri.parse(url3)),
//                 httpClient.get(Uri.parse(url4)),
//               ]);
//               if (!mounted) return;
//               String? _route = preferences.getString('route');
//               MaterialPageRoute materialPageRoute = MaterialPageRoute(
//                   builder: (BuildContext context) =>
//                       AdminScafScreen(route: _route));
//               Navigator.pushAndRemoveUntil(
//                   context, materialPageRoute, (route) => false);
//             }
//           }
//         }
//       } else {}
//     } catch (e) {}
//   }
//   // Future<Null> read_GC_rental() async {
//   //   if (renTalModels.isNotEmpty) {
//   //     renTalModels.clear();
//   //   }
//   //   SharedPreferences preferences = await SharedPreferences.getInstance();
//   //   var ren = preferences.getString('renTalSer');
//   //   String url =
//   //       '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

//   //   try {
//   //     var response = await httpClient.get(Uri.parse(url));

//   //     var result = json.decode(response.body);
//   //     print('GC_rental_setring>> $result');

//   //     if (result != null) {
//   //       for (var map in result) {
//   //         RenTalModel renTalModel = RenTalModel.fromJson(map);
//   //         var rtnamex = renTalModel.rtname;
//   //         var typexs = renTalModel.type;
//   //         var typexx = renTalModel.typex;
//   //         var name = renTalModel.pn!.trim();
//   //         var pkqtyx = int.parse(renTalModel.pkqty!);
//   //         var pkuserx = int.parse(renTalModel.pkuser!);
//   //         var pkx = renTalModel.pk!.trim();
//   //         var foderx = renTalModel.dbn;
//   //         var img = renTalModel.img;
//   //         var imglogo = renTalModel.imglogo;
//   //         var pksdatex = renTalModel.pksdate;
//   //         var pkldatex = renTalModel.pkldate;
//   //         var data_updatex = renTalModel.data_update;
//   //         setState(() {
//   //           preferences.setString(
//   //               'renTalName', renTalModel.pn!.trim().toString());
//   //           preferences.setString(
//   //               'renTalEmail', renTalModel.bill_email!.trim().toString());
//   //           renTal_name = preferences.getString('renTalName');
//   //           renTal_Email = renTalModel.bill_email.toString();
//   //           foder = foderx;
//   //           rtname = rtnamex;
//   //           type = typexs;
//   //           typex = typexx;
//   //           renname = name;
//   //           pkqty = pkqtyx;
//   //           pkuser = pkuserx;
//   //           pkname = pkx;
//   //           img_ = img;
//   //           img_logo = imglogo;
//   //           pkldate = pkldatex;
//   //           data_update = data_updatex;
//   //           renTalModels.add(renTalModel);
//   //         });
//   //       }
//   //       if (renTalModels.isNotEmpty) {
//   //         dynamic colorsren = renTalModels[0].colors_ren;
//   //         dynamic colorsren_sub = renTalModels[0].colors_subren;
//   //         if (colorsren is String) {
//   //           if (renTalModels[0].colors_ren.toString() != '' &&
//   //               renTalModels[0].colors_ren != null &&
//   //               renTalModels[0].colors_ren.toString() != 'null') {
//   //             setState(
//   //                 () => AppBarColors.hexColor = Color(int.parse(colorsren)));
//   //           }
//   //           if (renTalModels[0].colors_subren.toString() != '' &&
//   //               renTalModels[0].colors_subren != null &&
//   //               renTalModels[0].colors_subren.toString() != 'null') {
//   //             setState(() => AppBarColors.ABar_Colors_tab =
//   //                 Color(int.parse(colorsren_sub)));
//   //           }

//   //           // print('Color(int.parse(colorsren))');
//   //           // print(Color(int.parse(colorsren)));
//   //           // print(pickerColor);
//   //         } else {
//   //           // Handle the case where colorsren is not a String
//   //         }
//   //       }
//   //     } else {}
//   //   } catch (e) {}
//   // }

//   Future<Null> readTime() async {
//     var now = DateTime.now();
//     var reached = now.compareTo(alert!) >= 0;
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     Future.delayed(Duration(seconds: 1), () async {
//       setState(() {
//         timeoutper = preferences.getInt('timeoutper');
//       });
//       if (reached) {
//         // normalDialog(context, 'Time Out');
//         // print('Time Outttt $Value_Route $reached');
//       } else {
//         // print('${reached.toString()}');

//         // ✅ ตรวจ null ก่อนใช้ timeoutper
//         if (timeoutper != null && timeoutper != -5) {
//           setState(() {
//             alert = DateTime.now().add(Duration(seconds: timeoutper!));
//           });
//         }
//         preferences.setInt('timeoutper', -5);
//       }

//       var timrNow = DateTime.now();
//       String orderDates = DateFormat('yyyy-MM-dd').format(timrNow);
//       final eventTime = DateTime.parse('$orderDates 00:00:00');

//       const duration = const Duration(seconds: 1);
//       int timeDiff = eventTime.difference(DateTime.now()).inSeconds;
//       if (timer == null) {
//         timer = Timer.periodic(duration, (Timer t) {
//           if (timeDiff > 0) {
//             if (isActive) {
//               setState(() {
//                 // sharedPreferencesUser();
//                 if (eventTime != DateTime.now()) {
//                   timeDiff = timeDiff - 1;
//                 } else {
//                   // print('Times up!');
//                   //Do something
//                 }
//               });
//             }
//           }
//         });
//       }

//       // int day = eventTime.difference(DateTime.now()).inDays;
//       // // timeDiff ~/ (24 * 60 * 60) % 24;
//       // int hour = timeDiff ~/ (60 * 60) % 24;
//       // int minute = (timeDiff ~/ 60) % 60;
//       // int second = timeDiff % 60;

//       // setState(() {
//       //   days = day;
//       //   hours = hour;
//       //   minutes = minute;
//       //   seconds = second;
//       // });
//     });
//   }

//   String formatDuration(Duration d) {
//     String f(int n) {
//       return n.toString().padLeft(2, '0');
//     }

//     // We want to round up the remaining time to the nearest second
//     d += Duration(microseconds: 999999);
//     return "${f((d.inHours) % 24)}:${f((d.inMinutes) % 60)}:${f(d.inSeconds % 60)} \t\t";
//   }

//   Future<Null> signInThreadMain() async {
//     (renTal_user.toString() == '50' || renTal_user.toString() == '139')
//         ? signInThreadCMM()
//         : signInThread();
//   }

//   Future<Null> signInThreadCMM() async {
//     print('signInThreadCMM');
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     final userStr =
//         await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);
//     String? _seruser = preferences.getString('ser');

//     if (userStr != null) {
//       try {
//         setState(() {
//           position_user = preferences.getString('position');
//           fname_user = preferences.getString('fname');
//           lname_user = preferences.getString('lname');
//           email_user = preferences.getString('email');
//           ser_user = preferences.getString('ser');
//           utype_user = '';
//           permission_user = preferences.getString('permission');
//         });
//       } catch (e) {}
//     }
//     // ✅ เรียกตรงๆ ไม่ห่อม setState เพราะ async fn ใน setState จะถูกไกล์ทั้งหมด
//     read_GC_permission();
//   }

//   Future<Null> signInThread() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     String? _seruser = preferences.getString('ser');
//     String url =
//         '${MyConstant().domain}/GC_userHome.php?isAdd=true&ser=$_seruser';

//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       for (var map in result) {
//         UserModel userModel = UserModel.fromJson(map);
//         // ✅ ใช้ setState ครั้งเดียวสำหรับทุกแฟีลด์ (loop มีแค่  1 item ด้วย)
//         setState(() {
//           position_user = userModel.position;
//           fname_user = userModel.fname;
//           lname_user = userModel.lname;
//           email_user = userModel.email;
//           ser_user = userModel.ser;
//           utype_user = userModel.utype;
//           permission_user = userModel.permission;
//         });
//       }
//       // ✅ เรียกตรงๆ ไม่ห่อม setState wrapper
//       read_GC_permission();
//     } catch (e) {}
//   }

// /////----------------------------------->
//   List<String> translate_menu = [];
//   String more_menu = 'อื่นๆ';
// /////----------------------------------->
//   Future<Null> read_GC_permission() async {
//     startTimer();
//     if (perMissionModels.length != 0) {
//       translate_menu.clear();
//       perMissionModels.clear();
//     }
//     if (permission_user == '0') {
//       String url = '${MyConstant().domain}/GC_permissionAll.php?isAdd=true';

//       try {
//         var response = await httpClient.get(Uri.parse(url));
//         var result = json.decode(response.body);

//         // ✅ รวบรวมใน temp list ก่อน และ setState ครั้งเดียว
//         final tempModels = <PerMissionModel>[];
//         final tempTranslate = <String>[];
//         for (var map in result) {
//           PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
//           tempModels.add(perMissionModel);
//           tempTranslate.add(await translateText('${perMissionModel.perm}'));
//         }
//         // ✅ translateText('อื่นๆ') เรียกครั้งเดียวนอก loop
//         final more_menu2 = await translateText('อื่นๆ');
//         setState(() {
//           perMissionModels.addAll(tempModels);
//           translate_menu.addAll(tempTranslate);
//           more_menu = more_menu2;
//         });
//       } catch (e) {}
//     } else {
//       final preferences = await SharedPreferences.getInstance();
//       final permission_userx = preferences.getString('permission');
//       List<String> permissions = (permission_userx!.split(','));

//       // ✅ รวม ser ทั้งหมดเป็น "1,2,3,4,5,6,7,8" แล้วเรียกครั้งเดียว (ลดจาก N calls → 1 call)
//       final tempModels = <PerMissionModel>[];
//       final tempTranslate = <String>[];

//       final serParam = permissions.map((p) => p.trim()).join(',');
//       String url =
//           '${MyConstant().domain}/GC_permission.php?isAdd=true&ser=$serParam';

//       try {
//         var response = await httpClient.get(Uri.parse(url));
//         var result = json.decode(response.body);
//         for (var map in result) {
//           PerMissionModel perMissionModel = PerMissionModel.fromJson(map);
//           tempModels.add(perMissionModel);
//           tempTranslate.add(await translateText('${perMissionModel.perm}'));
//         }
//       } catch (e) {}

//       // ✅ translateText('อื่นๆ') เรียกครั้งเดียวหลัง loop ทั้งหมด
//       final more_menu2 = await translateText('อื่นๆ');
//       setState(() {
//         perMissionModels.addAll(tempModels);
//         translate_menu.addAll(tempTranslate);
//         more_menu = more_menu2;
//       });
//     }
//     setState(() {
//       perMissioncount = perMissionModels.length;
//     });

//     // print('perMissionModels  == > ${perMissionModels.length}');
//   }

//   Future<Null> checkPreferance() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var rser = preferences.getString('rser');
//     var utype = preferences.getString('utype');
//     var muser = preferences.getString('Muser');
//     if (utype == 'MS') {
//       if (preferences.getString('renTalSer') == null) {
//         // ✅ ย้าย setString ออกนอก setState
//         await preferences.setString('renTalSer', rser.toString());
//         setState(() {
//           renTal_user = preferences.getString('renTalSer');
//           // ✅ null-safe: ถ้าไม่มีค่า lavel ให้ default = 0
//           renTal_lavel =
//               int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
//         });
//       } else {
//         setState(() {
//           renTal_user = preferences.getString('renTalSer');
//           renTal_name = preferences.getString('renTalName');
//           renTal_lavel =
//               int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
//         });
//       }
//     } else {
//       if (rser == '0') {
//         setState(() {
//           renTal_user = preferences.getString('renTalSer');
//           renTal_name = preferences.getString('renTalName');
//           renTal_lavel =
//               int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
//         });
//       } else {
//         // ✅ ย้าย setString ออกนอก setState
//         await preferences.setString('renTalSer', rser.toString());
//         setState(() {
//           renTal_user = preferences.getString('renTalSer');
//           renTal_lavel =
//               int.tryParse(preferences.getString('lavel') ?? '0') ?? 0;
//         });
//       }
//     }

//     print('renTal_lavel>>> $renTal_lavel');
//     passcode_in(); // เรียกตรงๆ ไม่ใน setState (async function ต้องไม่อยู่ใน setState)
//     System_User();
//   }

//   // List MenuList_ = [
//   //   'หน้าหลัก',
//   //   'พื้นที่เช่า',
//   //   'ผู้เช่า',
//   //   'บัญชี',
//   //   'จัดการ',
//   //   'รายงาน',
//   //   'ตั้งค่า',
//   // ];
//   List Menu_IconList_ = [
//     Icons.home,
//     Icons.location_pin,
//     Icons.person,
//     Icons.calendar_month,
//     Icons.key,
//     Icons.inventory,
//     Icons.settings,
//   ];
//   double _scaleFactor = 1.0; // define the initial scale factor

//   void _zoomIn() {
//     setState(() {
//       _scaleFactor *= 1.2; // increase the scale factor by 20%
//     });
//   }

//   void _zoomOut() {
//     setState(() {
//       _scaleFactor /= 1.2; // decrease the scale factor by 20%
//     });
//   }

//   Future<void> _showMyDialogImg(String Url, String title_) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(20.0))),
//           title: Center(
//               child: Text(
//             title_.toString(),
//             style: const TextStyle(
//               // fontSize: 15,
//               color: Colors.black,
//               fontFamily: Font_.Fonts_T,
//               fontWeight: FontWeight.bold,
//             ),
//           )),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 InteractiveViewer(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.brown[100],
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         topRight: Radius.circular(10),
//                         bottomLeft: Radius.circular(10),
//                         bottomRight: Radius.circular(10),
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(8.0),
//                     child: (img_logo == null || img_logo.toString() == '')
//                         ? const Center(
//                             child: Icon(
//                               Icons.image_not_supported,
//                               color: Colors.black,
//                             ),
//                           )
//                         : Image.network(
//                             '$Url',
//                             fit: BoxFit.contain,
//                           ),
//                   ),
//                   scaleEnabled: true,
//                   minScale: 0.5,
//                   maxScale: 5.0,
//                   transformationController: TransformationController()
//                     ..value =
//                         Matrix4.diagonal3Values(_scaleFactor, _scaleFactor, 1),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             // StreamBuilder(
//             //     stream: Stream.periodic(const Duration(milliseconds: 0)),
//             //     builder: (
//             //       context,
//             //       snapshot,
//             //     ) {
//             //       return SizedBox(
//             //         child: Row(
//             //           children: [
//             //             IconButton(
//             //               icon: Icon(Icons.add),
//             //               onPressed: _zoomIn,
//             //             ),
//             //             IconButton(
//             //               icon: Icon(Icons.remove),
//             //               onPressed: _zoomOut,
//             //             ),
//             //           ],
//             //         ),
//             //       );
//             //     }),
//             InkWell(
//               child: Container(
//                 width: 150,
//                 decoration: const BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                     bottomLeft: Radius.circular(10),
//                     bottomRight: Radius.circular(10),
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(4.0),
//                 child: const Center(
//                   child: Text(
//                     'ปิด',
//                     style: TextStyle(
//                       // fontSize: 15,
//                       color: Colors.white,
//                       fontFamily: Font_.Fonts_T,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   final Dev_text = TextEditingController();
//   Future<void> _showMyDialogDev(type_dev) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(20.0))),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Center(
//                   child: Translate.TranslateAndSetText(
//                       'แจ้งเตือน',
//                       Colors.white,
//                       TextAlign.center,
//                       FontWeight.bold,
//                       FontWeight_.Fonts_T,
//                       14,
//                       1),
//                 ),
//                 Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: TextFormField(
//                       controller: Dev_text,
//                       onSaved: (String? value) {
//                         // This optional block of code can be used to run
//                         // code when the user saves the form.
//                       },
//                       validator: (String? value) {
//                         return (value != null && value.contains('@'))
//                             ? 'Do not use the @ char.'
//                             : null;
//                       },
//                       decoration: InputDecoration(
//                           fillColor: Colors.white.withOpacity(0.3),
//                           filled: true,
//                           prefixIcon:
//                               const Icon(Icons.chat, color: Colors.black),
//                           // suffixIcon: Icon(Icons.clear, color: Colors.black),
//                           focusedBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.only(
//                               topRight: Radius.circular(15),
//                               topLeft: Radius.circular(15),
//                               bottomRight: Radius.circular(15),
//                               bottomLeft: Radius.circular(15),
//                             ),
//                             borderSide: BorderSide(
//                               width: 1,
//                               color: Colors.black,
//                             ),
//                           ),
//                           errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
//                           enabledBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.only(
//                               topRight: Radius.circular(15),
//                               topLeft: Radius.circular(15),
//                               bottomRight: Radius.circular(15),
//                               bottomLeft: Radius.circular(15),
//                             ),
//                             borderSide: BorderSide(
//                               width: 1,
//                               color: Colors.black,
//                             ),
//                           ),
//                           labelStyle: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black54,
//                               fontFamily: Font_.Fonts_T)),
//                     )),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: InkWell(
//                     child: Container(
//                       width: 250,
//                       decoration: const BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           topRight: Radius.circular(10),
//                           bottomLeft: Radius.circular(10),
//                           bottomRight: Radius.circular(10),
//                         ),
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: Center(
//                         child: Translate.TranslateAndSetText(
//                             'บันทึกข้อความแจ้งเตือน',
//                             Colors.white,
//                             TextAlign.center,
//                             FontWeight.bold,
//                             FontWeight_.Fonts_T,
//                             14,
//                             1),
//                       ),
//                     ),
//                     onTap: () async {
//                       if (Dev_text.text != '') {
//                         String url =
//                             '${MyConstant().domain}/Awat_UP_sytem.php?isAdd=true&dev_tex=${Dev_text.text}&ser_ren=$ren&dev_type=$type_dev';

//                         try {
//                           var response = await httpClient.get(Uri.parse(url));

//                           var result = json.decode(response.body);
//                           if (result.toString() == 'true') {
//                             setState(() {
//                               Dev_text.clear();
//                             });
//                             Navigator.of(context).pop();
//                           }
//                         } catch (e) {
//                           setState(() {
//                             Dev_text.clear();
//                           });
//                         }
//                       } else {}
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: InkWell(
//                     child: Container(
//                       width: 250,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           topRight: Radius.circular(10),
//                           bottomLeft: Radius.circular(10),
//                           bottomRight: Radius.circular(10),
//                         ),
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: Center(
//                         child: Translate.TranslateAndSetText(
//                             'ยกเลิกข้อความแจ้งเตือน',
//                             Colors.white,
//                             TextAlign.center,
//                             FontWeight.bold,
//                             FontWeight_.Fonts_T,
//                             14,
//                             1),
//                       ),
//                     ),
//                     onTap: () async {
//                       String tex_t = '';
//                       String url =
//                           '${MyConstant().domain}/Awat_UP_sytem.php?isAdd=true&dev_tex=${tex_t}&ser_ren=$ren&dev_type=$type_dev';

//                       try {
//                         var response = await httpClient.get(Uri.parse(url));

//                         var result = json.decode(response.body);
//                         if (result.toString() == 'true') {
//                           setState(() {
//                             Dev_text.clear();
//                           });
//                           Navigator.of(context).pop();
//                         }
//                       } catch (e) {
//                         setState(() {
//                           Dev_text.clear();
//                         });
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 5.0,
//                 ),
//                 const Divider(
//                   color: Colors.grey,
//                   height: 4.0,
//                 ),
//                 const SizedBox(
//                   height: 5.0,
//                 ),
//                 if (type_dev.toString() == '0')
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: InkWell(
//                       child: Container(
//                         width: 250,
//                         decoration: const BoxDecoration(
//                           color: Colors.green,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10),
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(10),
//                           ),
//                         ),
//                         padding: const EdgeInsets.all(8.0),
//                         child: Center(
//                           child: Translate.TranslateAndSetText(
//                               'แจ้งเตือน Dialog หลังอัพเดต',
//                               Colors.white,
//                               TextAlign.center,
//                               FontWeight.bold,
//                               FontWeight_.Fonts_T,
//                               14,
//                               1),
//                         ),
//                       ),
//                       onTap: () async {
//                         DateTime now = DateTime.now();
//                         String formattedDate =
//                             DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

//                         String url =
//                             '${MyConstant().domain}/OK_UP_sytem.php?isAdd=true&datex=${formattedDate}';

//                         try {
//                           var response = await httpClient.get(Uri.parse(url));

//                           var result = json.decode(response.body);
//                           if (result.toString() == 'true') {
//                             Navigator.of(context).pop();
//                           }
//                         } catch (e) {}
//                       },
//                     ),
//                   ),
//                 const SizedBox(
//                   height: 5.0,
//                 ),
//                 if (type_dev.toString() == '0')
//                   const Divider(
//                     color: Colors.grey,
//                     height: 4.0,
//                   ),
//                 const SizedBox(
//                   height: 5.0,
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             InkWell(
//               child: Container(
//                 width: 100,
//                 decoration: const BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(10),
//                     topRight: Radius.circular(10),
//                     bottomLeft: Radius.circular(10),
//                     bottomRight: Radius.circular(10),
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(8.0),
//                 child: Center(
//                   child: Translate.TranslateAndSetText(
//                       'ปิด',
//                       Colors.white,
//                       TextAlign.center,
//                       FontWeight.bold,
//                       FontWeight_.Fonts_T,
//                       14,
//                       1),
//                 ),
//               ),
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void changeColor() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     Color tiTileColorss1 = Color.fromARGB(255, 203, 200, 219);
//     Color tiTileColorss2 = Color(0xFFD9D9B7);

//     setState(() {
//       if (AppbackgroundColor.TiTile_Colors == tiTileColorss1) {
//         AppbackgroundColor.TiTile_Colors = tiTileColorss2;
//       } else {
//         AppbackgroundColor.TiTile_Colors = tiTileColorss1;
//       }
//     });
//     String? _route = preferences.getString('route');
//     MaterialPageRoute materialPageRoute = MaterialPageRoute(
//         builder: (BuildContext context) => AdminScafScreen(route: _route));
//     Navigator.pushAndRemoveUntil(context, materialPageRoute, (route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ❌ ลบ setState()+passcode_in() ออกจาก build() แล้ว:
//     //    เรียก API ใน build → rebuild วนไม่สิ้นสุด
//     //    ย้ายไปเรียกใน initState() และ checkPreferance() แทน
//     if (perMissionModels.length < perMissioncount!) {
//       return Center(
//         child: const CircularProgressIndicator(),
//       );
//     }

//     return (Responsive.isDesktop(context)) ? adminweb() : adminmobile();
//   }

//   AdminScaffold adminweb() {
//     return AdminScaffold(
//       backgroundColor: AppbackgroundColor.Abg_Colors,
//       leadingIcon: IconButton(
//         // icon: Icon(isSidebarOpen ? Icons.menu : Icons.menu),
//         tooltip: isSidebarOpen ? 'ซ่อนเมนู' : 'แสดงเมนู',
//         // onPressed:
//         //     _toggleSidebar, // สลับค่า isSidebarOpen แล้ว setState + (ถ้าเก็บ prefs ก็เซฟ)
//         icon: Icon(context.watch<SidebarController>().isOpen
//             ? Icons.menu
//             : Icons.menu_open),
//         onPressed: () => context.read<SidebarController>().toggle(),
//       ),
//       appBar: AppBar(
//         excludeHeaderSemantics: false,
//         automaticallyImplyLeading: false,
//         iconTheme: const IconThemeData(color: Colors.white),
//         foregroundColor: Colors.black,
//         titleSpacing: 00.0,
//         centerTitle: true,
//         toolbarHeight: 50.2,
//         // toolbarOpacity: 0.8,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(0),
//             bottomLeft: Radius.circular(0),
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(isSidebarOpen ? Icons.menu : Icons.menu_open),
//           onPressed: () => context.read<SidebarController>().toggle(),
//         ),
//         title: Align(
//           alignment: Alignment.centerLeft,
//           // ✅ เอา StreamBuilder(1s) ออก ชื่อร้านไม่เคยเปลี่ยนระหว่าง session
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 if (Responsive.isDesktop(context))
//                   (img_logo == null || img_logo.toString() == '')
//                       ? SizedBox()
//                       : InkWell(
//                           child: CircleAvatar(
//                             radius: 20.0,
//                             backgroundImage: NetworkImage(
//                                 '${MyConstant().domain}/files/$foder/logo/$img_logo'),
//                             backgroundColor: Colors.transparent,
//                           ),
//                           onTap: () {
//                             if (img_logo == null || img_logo.toString() == '') {
//                             } else {
//                               String url =
//                                   '${MyConstant().domain}/files/$foder/logo/$img_logo';
//                               _showMyDialogImg(url,
//                                   renTal_name == null ? ' ' : ' $renTal_name');
//                             }
//                           },
//                         ),
//                 InkWell(
//                   child: Text(
//                     renTal_name == null ? ' ภาพรวม' : ' $renTal_name',
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: (Responsive.isDesktop(context))
//                             ? FontWeight.bold
//                             : null,
//                         fontSize: (Responsive.isDesktop(context)) ? null : 12,
//                         fontFamily: FontWeight_.Fonts_T),
//                   ),
//                   onTap: () {
//                     if (img_logo == null || img_logo.toString() == '') {
//                     } else {
//                       String url =
//                           '${MyConstant().domain}/files/$foder/logo/$img_logo';
//                       _showMyDialogImg(
//                           url, renTal_name == null ? ' ' : ' $renTal_name');
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           Row(
//             children: [
//               StreamBuilder(
//                   // ใช้ Duration(seconds:5) แทน 0 เพื่อไม่ rebuild ทุก frame
//                   stream: Stream.periodic(const Duration(seconds: 5)),
//                   builder: (context, snapshot) {
//                     return Row(
//                       children: [
//                         if (!Responsive.isMobile(context) &&
//                             read_data_davtext != '')
//                           Container(
//                             decoration: BoxDecoration(
//                               // color: Colors.white.withOpacity(0.3),
//                               // Colors.lightGreen[200],
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                               // border:
//                               //     Border.all(color: Colors.grey, width: 0.5),
//                             ),
//                             width: (Responsive.isDesktop(context))
//                                 ? MediaQuery.of(context).size.width / 4
//                                 : MediaQuery.of(context).size.width / 2,
//                             child: Marquee(
//                               text:
//                                   '   📢 แจ้งเตือน : $read_data_davtext     ||   ',

//                               // text: '$read_data_davtext',
//                               style: TextStyle(
//                                   color: Color.fromARGB(255, 253, 253, 253),
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: FontWeight_.Fonts_T),
//                               scrollAxis: Axis.horizontal,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               // blankSpace: 20.0,
//                               // velocity: 100.0,
//                               pauseAfterRound: Duration(seconds: 1),
//                               // startPadding: 10.0,
//                               // accelerationDuration: Duration(seconds: 5),
//                               accelerationCurve: Curves.linear,
//                               decelerationDuration: Duration(seconds: 5),
//                               decelerationCurve: Curves.easeInOut,
//                             ),
//                           ),
//                       ],
//                     );
//                   }),
//               StreamBuilder(
//                   stream: Stream.periodic(const Duration(seconds: 1)),
//                   builder: (context, snapshot) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         // color: Colors.white.withOpacity(0.7),
//                         // Colors.lightGreen[200],
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10),
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(10)),
//                         // border: Border.all(color: Colors.grey, width: 0.5),
//                       ),
//                       padding: const EdgeInsets.all(0.5),
//                       child: Container(
//                         width: 100,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Icon(
//                                 Icons.sunny,
//                                 size: 15.0,
//                                 color: (AppbackgroundColor.TiTile_Colors ==
//                                         Color.fromARGB(255, 203, 200, 219))
//                                     ? Colors.white
//                                     : Colors.orange,
//                               ),
//                             ),
//                             (isDark_Mode == true)
//                                 ? InkWell(
//                                     onTap: () async {
//                                       SharedPreferences preferences =
//                                           await SharedPreferences.getInstance();
//                                       setState(() {
//                                         preferences.setBool(
//                                             'isDarkMode', false);
//                                       });
//                                       // print(preferences.getBool('isDarkMode'));
//                                       // print(isDark_Mode);
//                                       String? _route =
//                                           preferences.getString('route');
//                                       MaterialPageRoute materialPageRoute =
//                                           MaterialPageRoute(
//                                               builder: (BuildContext context) =>
//                                                   AdminScafScreen(
//                                                       route: _route));
//                                       Navigator.pushAndRemoveUntil(context,
//                                           materialPageRoute, (route) => false);
//                                       // changeColor();
//                                     },
//                                     child: Icon(
//                                       Icons.toggle_on,
//                                       color: Colors.yellow[100],
//                                       size: 35.0,
//                                     ),
//                                   )
//                                 : InkWell(
//                                     onTap: () async {
//                                       SharedPreferences preferences =
//                                           await SharedPreferences.getInstance();
//                                       setState(() {
//                                         preferences.setBool('isDarkMode', true);
//                                       });

//                                       print(preferences.getBool('isDarkMode'));
//                                       String? _route =
//                                           preferences.getString('route');
//                                       MaterialPageRoute materialPageRoute =
//                                           MaterialPageRoute(
//                                               builder: (BuildContext context) =>
//                                                   AdminScafScreen(
//                                                       route: _route));
//                                       Navigator.pushAndRemoveUntil(context,
//                                           materialPageRoute, (route) => false);
//                                       // changeColor();
//                                     },
//                                     child: Icon(
//                                       Icons.toggle_off,
//                                       color: Colors.orange[100],
//                                       size: 35.0,
//                                     ),
//                                   ),
//                             // (AppbackgroundColor.TiTile_Colors ==
//                             //         Color.fromARGB(255, 203, 200, 219))
//                             //     ? InkWell(
//                             //         onTap: () {
//                             //           changeColor();
//                             //         },
//                             //         child: Icon(
//                             //           Icons.toggle_on,
//                             //           color: Colors.yellow[100],
//                             //           size: 35.0,
//                             //         ),
//                             //       )
//                             //     : InkWell(
//                             //         onTap: () {
//                             //           changeColor();
//                             //         },
//                             //         child: Icon(
//                             //           Icons.toggle_off,
//                             //           color: Colors.orange[100],
//                             //           size: 35.0,
//                             //         ),
//                             //       ),
//                             Expanded(
//                                 flex: 1,
//                                 child: Icon(
//                                   Icons.bedtime,
//                                   size: 15.0,
//                                   color: (AppbackgroundColor.TiTile_Colors ==
//                                           Color(0xFFD9D9B7))
//                                       ? Colors.white
//                                       : Colors.yellow,
//                                 )),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//               if (pkldate != null)
//                 if (datex.isAfter(DateTime.parse(pkldate == '0000-00-00'
//                             ? '$data_update'
//                             : '$pkldate 00:00:00.000')
//                         .subtract(const Duration(days: 7))) ==
//                     true)
//                   Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: InkWell(
//                       onTap: () {
//                         MaterialPageRoute route = MaterialPageRoute(
//                           builder: (context) => SignInLicense(route: 'Yes'),
//                         );
//                         Navigator.pushAndRemoveUntil(
//                             context, route, (route) => true);
//                       },
//                       child: Container(
//                         width: 50,
//                         // color: Colors.yellow,
//                         child: Center(
//                           child: Icon(
//                             Icons.vpn_key,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//               (Responsive.isDesktop(context) &&
//                       (ser_user == '63' ||
//                           ser_user == '56' ||
//                           ser_user == '61' ||
//                           ser_user == '37' ||
//                           ser_user == '268'))
//                   ? Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: InkWell(
//                         onTap: () {
//                           _showMyDialogDev(0);
//                         },
//                         child: Container(
//                           color: Colors.yellow,
//                           child: Center(
//                               child: Text(
//                             '  DEV  ',
//                             style: TextStyle(
//                                 color: AdminScafScreen_Color.Colors_Text1_,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: FontWeight_.Fonts_T),
//                           )),
//                         ),
//                       ),
//                     )
//                   : (renTal_lavel.toString() != '5')
//                       ? SizedBox()
//                       : Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: InkWell(
//                             onTap: () {
//                               _showMyDialogDev(1);
//                             },
//                             child: CircleAvatar(
//                               // radius: 15.0,
//                               backgroundColor: Colors.deepOrange,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Icon(
//                                   Icons.warning,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                             //
//                           ),
//                         ),
//               // ChatScreen(
//               //     ser_user: ser_user,
//               //     userModels_chat_: userModels_chat,
//               //     userModels_: userModels),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.7),
//                   // Colors.lightGreen[200],
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(0),
//                       bottomLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(0)),
//                   // border: Border.all(color: Colors.grey, width: 0.5),
//                 ),
//                 padding: const EdgeInsets.all(0.5),
//                 child: Row(
//                   children: [
//                     // Padding(
//                     //   padding: EdgeInsets.fromLTRB(4, 1, 2, 1),
//                     //   child: InkWell(
//                     //     onTap: () async {
//                     //       SharedPreferences preferences =
//                     //           await SharedPreferences.getInstance();
//                     //       var Lang = preferences.getString('Language');
//                     //       List supportedLocales = [
//                     //         {
//                     //           "ser": "1",
//                     //           "code": "th",
//                     //           "ln": "ไทย",
//                     //           "url": "images/Thailand.png"
//                     //         },
//                     //         {
//                     //           "ser": "2",
//                     //           "code": "en",
//                     //           "ln": "English",
//                     //           "url": "images/English.png"
//                     //         },
//                     //         {
//                     //           "ser": "3",
//                     //           "code": "lo",
//                     //           "ln": "ລາວ",
//                     //           "url": "images/LAO.png"
//                     //         },
//                     //         {
//                     //           "ser": "4",
//                     //           "code": "ko",
//                     //           "ln": "Korea",
//                     //           "url": "images/Korea.png"
//                     //         },
//                     //         {
//                     //           "ser": "5",
//                     //           "code": "ja",
//                     //           "ln": "Japanese",
//                     //           "url": "images/Jpan.png"
//                     //         },
//                     //         {
//                     //           "ser": "6",
//                     //           "code": "zh-cn",
//                     //           "ln": "China",
//                     //           "url": "images/Chaina.png"
//                     //         },
//                     //       ];

//                     //       showDialog<String>(
//                     //         context: context,
//                     //         builder: (BuildContext context) => AlertDialog(
//                     //           backgroundColor:
//                     //               Color.fromARGB(255, 247, 246, 246),
//                     //           titlePadding: const EdgeInsets.all(0.0),
//                     //           contentPadding: const EdgeInsets.all(10.0),
//                     //           actionsPadding: const EdgeInsets.all(6.0),
//                     //           shape: const RoundedRectangleBorder(
//                     //               borderRadius:
//                     //                   BorderRadius.all(Radius.circular(20.0))),
//                     //           title: Row(
//                     //             mainAxisAlignment: MainAxisAlignment.end,
//                     //             children: [
//                     //               InkWell(
//                     //                 onTap: () async {
//                     //                   Navigator.pop(context);
//                     //                 },
//                     //                 child: Padding(
//                     //                   padding: const EdgeInsets.all(4.0),
//                     //                   child: Icon(Icons.highlight_off,
//                     //                       size: 30, color: Colors.red[700]),
//                     //                 ),
//                     //               ),
//                     //             ],
//                     //           ),
//                     //           content: SingleChildScrollView(
//                     //             child: ListBody(
//                     //               children: <Widget>[
//                     //                 SizedBox(
//                     //                   height: 20,
//                     //                 ),
//                     //                 for (int index = 0;
//                     //                     index < supportedLocales.length;
//                     //                     index++)
//                     //                   Padding(
//                     //                     padding: const EdgeInsets.all(4.0),
//                     //                     child: ListTile(
//                     //                         onTap: () async {
//                     //                           SharedPreferences preferences =
//                     //                               await SharedPreferences
//                     //                                   .getInstance();
//                     //                           setState(() {
//                     //                             preferences.setString(
//                     //                                 'Language',
//                     //                                 '${supportedLocales[index]['code']}');
//                     //                           });
//                     //                           Navigator.pop(context);

//                     //                           String? _route = preferences
//                     //                               .getString('route');

//                     //                           MaterialPageRoute route =
//                     //                               MaterialPageRoute(
//                     //                             builder: (context) =>
//                     //                                 AdminScafScreen(
//                     //                                     route: _route),
//                     //                           );
//                     //                           Navigator.pushAndRemoveUntil(
//                     //                               context,
//                     //                               route,
//                     //                               (route) => false);
//                     //                         },
//                     //                         title: Container(
//                     //                           decoration: BoxDecoration(
//                     //                             color: Lang.toString() ==
//                     //                                     '${supportedLocales[index]['code']}'
//                     //                                 ? Colors.green[400]
//                     //                                 : Colors.white,
//                     //                             borderRadius:
//                     //                                 const BorderRadius.only(
//                     //                               topLeft: Radius.circular(10),
//                     //                               topRight: Radius.circular(10),
//                     //                               bottomLeft:
//                     //                                   Radius.circular(10),
//                     //                               bottomRight:
//                     //                                   Radius.circular(10),
//                     //                             ),
//                     //                             border: Border.all(
//                     //                                 color: Colors.grey,
//                     //                                 width: 0.5),
//                     //                             // border: Border(
//                     //                             //   bottom: BorderSide(
//                     //                             //     //                    <--- top side
//                     //                             //     width: 0.5,
//                     //                             //   ),
//                     //                             // )
//                     //                           ),
//                     //                           padding:
//                     //                               const EdgeInsets.all(4.0),
//                     //                           width: 270,
//                     //                           child: Row(
//                     //                             children: [
//                     //                               // Icon(
//                     //                               //   Iconsax.check,
//                     //                               //   // color: getRandomColor(index)
//                     //                               // ),
//                     //                               CircleAvatar(
//                     //                                 radius: 15,
//                     //                                 backgroundImage: AssetImage(
//                     //                                     '${supportedLocales[index]['url']}'),
//                     //                               ),
//                     //                               Expanded(
//                     //                                 child: Padding(
//                     //                                   padding: const EdgeInsets
//                     //                                           .fromLTRB(
//                     //                                       10, 4, 4, 4),
//                     //                                   child: Text(
//                     //                                     '${supportedLocales[index]['ln']}',
//                     //                                     overflow: TextOverflow
//                     //                                         .ellipsis,
//                     //                                     style: const TextStyle(
//                     //                                         color: PeopleChaoScreen_Color
//                     //                                             .Colors_Text2_,
//                     //                                         fontWeight:
//                     //                                             FontWeight.bold,
//                     //                                         fontFamily:
//                     //                                             FontWeight_
//                     //                                                 .Fonts_T),
//                     //                                   ),
//                     //                                 ),
//                     //                               ),
//                     //                             ],
//                     //                           ),
//                     //                         )),
//                     //                   ),
//                     //                 SizedBox(
//                     //                   height: 20,
//                     //                 ),
//                     //                 Center(
//                     //                   child: Text(
//                     //                     '# Comming soon.. ',
//                     //                     overflow: TextOverflow.ellipsis,
//                     //                     style: const TextStyle(
//                     //                         color: Colors.red,
//                     //                         fontFamily: Font_.Fonts_T),
//                     //                   ),
//                     //                 ),
//                     //                 Center(
//                     //                   child: Text(
//                     //                     '(ขออภัยยังไม่สามารถใช้งานได้ ณ ขณะนี้)',
//                     //                     overflow: TextOverflow.ellipsis,
//                     //                     style: const TextStyle(
//                     //                         color: Colors.red,
//                     //                         fontFamily: Font_.Fonts_T),
//                     //                   ),
//                     //                 ),
//                     //               ],
//                     //             ),
//                     //           ),
//                     //         ),
//                     //       );
//                     //     },
//                     //     child: Container(
//                     //       decoration: BoxDecoration(
//                     //         color: Colors.white60,
//                     //         borderRadius: BorderRadius.only(
//                     //             topLeft: Radius.circular(20),
//                     //             topRight: Radius.circular(20),
//                     //             bottomLeft: Radius.circular(20),
//                     //             bottomRight: Radius.circular(20)),
//                     //       ),
//                     //       padding: const EdgeInsets.all(4.0),
//                     //       child: Icon(
//                     //         Icons.g_translate,
//                     //         // Icons.translate,
//                     //         color: Colors.indigo[600],
//                     //         size: 20,
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                     // Padding(
//                     //   padding: EdgeInsets.fromLTRB(4, 1, 0, 1),
//                     //   child: StreamBuilder(
//                     //       stream: Stream.periodic(const Duration(seconds: 4)),
//                     //       builder: (context, snapshot) {
//                     //         return ChatScreen(
//                     //             ser_user: ser_user,
//                     //             userModels_chat_: userModels_chat,
//                     //             userModels_: userModels);
//                     //       }),
//                     // ),
//                     StreamBuilder(
//                         // ไม่ต้องการอัปเดตอัตโนมัติ ใช้ Duration ว่างแทน 0
//                         stream: Stream.periodic(const Duration(seconds: 30)),
//                         builder: (context, snapshot) {
//                           return Padding(
//                             padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
//                             child: InkWell(
//                                 onTap: renTal_name == null
//                                     ? null
//                                     : () async {
//                                         startTimer();
//                                         showDialog<String>(
//                                           context: context,
//                                           builder: (BuildContext context) =>
//                                               AlertDialog(
//                                             shape: const RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.all(
//                                                     Radius.circular(20.0))),
//                                             title: Center(
//                                               child:
//                                                   Translate.TranslateAndSetText(
//                                                       'ผู้ใช้งานระบบขณะนี้ ',
//                                                       AdminScafScreen_Color
//                                                           .Colors_Text1_,
//                                                       TextAlign.center,
//                                                       FontWeight.bold,
//                                                       FontWeight_.Fonts_T,
//                                                       14,
//                                                       1),
//                                             ),
//                                             content: ScrollConfiguration(
//                                               behavior: ScrollConfiguration.of(
//                                                       context)
//                                                   .copyWith(dragDevices: {
//                                                 PointerDeviceKind.touch,
//                                                 PointerDeviceKind.mouse,
//                                               }),
//                                               child: SingleChildScrollView(
//                                                 scrollDirection:
//                                                     Axis.horizontal,
//                                                 dragStartBehavior:
//                                                     DragStartBehavior.start,
//                                                 child: Row(
//                                                   children: [
//                                                     Container(
//                                                       width: (Responsive
//                                                               .isDesktop(
//                                                                   context))
//                                                           ? MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width *
//                                                               0.85
//                                                           : 800,
//                                                       child: StreamBuilder(
//                                                           stream:
//                                                               Stream.periodic(
//                                                                   const Duration(
//                                                                       seconds:
//                                                                           0)),
//                                                           builder: (context,
//                                                               snapshot) {
//                                                             return Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Translate.TranslateAndSetText(
//                                                                         'ทั้งหมด : ${userModels.length} คน',
//                                                                         AdminScafScreen_Color
//                                                                             .Colors_Text1_,
//                                                                         TextAlign
//                                                                             .center,
//                                                                         FontWeight
//                                                                             .bold,
//                                                                         FontWeight_
//                                                                             .Fonts_T,
//                                                                         14,
//                                                                         1),
//                                                                   ],
//                                                                 ),
//                                                                 Container(
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     color: AppbackgroundColor
//                                                                         .TiTile_Colors,
//                                                                     borderRadius:
//                                                                         BorderRadius
//                                                                             .only(
//                                                                       topLeft: Radius
//                                                                           .circular(
//                                                                               10),
//                                                                       topRight:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       bottomLeft:
//                                                                           Radius.circular(
//                                                                               0),
//                                                                       bottomRight:
//                                                                           Radius.circular(
//                                                                               0),
//                                                                     ),
//                                                                     // border: Border.all(
//                                                                     //     color: Colors.grey, width: 1),
//                                                                   ),
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                               .all(
//                                                                           8.0),
//                                                                   child: Row(
//                                                                     children: [
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           '...',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           'Email',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child: Translate.TranslateAndSetText(
//                                                                             'ชื่อ',
//                                                                             AdminScafScreen_Color.Colors_Text1_,
//                                                                             TextAlign.center,
//                                                                             FontWeight.bold,
//                                                                             FontWeight_.Fonts_T,
//                                                                             14,
//                                                                             1),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child: Translate.TranslateAndSetText(
//                                                                             'ตำแหน่ง',
//                                                                             AdminScafScreen_Color.Colors_Text1_,
//                                                                             TextAlign.center,
//                                                                             FontWeight.bold,
//                                                                             FontWeight_.Fonts_T,
//                                                                             14,
//                                                                             1),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child: Translate.TranslateAndSetText(
//                                                                             'เวลาอัพเดตล่าสุด',
//                                                                             AdminScafScreen_Color.Colors_Text1_,
//                                                                             TextAlign.center,
//                                                                             FontWeight.bold,
//                                                                             FontWeight_.Fonts_T,
//                                                                             14,
//                                                                             1),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                     height: MediaQuery.of(context)
//                                                                             .size
//                                                                             .height *
//                                                                         0.4,
//                                                                     width: (Responsive.isDesktop(
//                                                                             context))
//                                                                         ? MediaQuery.of(context).size.width *
//                                                                             0.85
//                                                                         : 800,
//                                                                     child: ListView.builder(
//                                                                         padding: const EdgeInsets.all(8),
//                                                                         itemCount: userModels.length,
//                                                                         itemBuilder: (BuildContext context, int index) {
//                                                                           String
//                                                                               email =
//                                                                               '${userModels[index].email}';
//                                                                           int emailLength =
//                                                                               email.length;
//                                                                           String
//                                                                               firstTwoCharacters =
//                                                                               email.substring(0, 2);
//                                                                           String
//                                                                               lastFourCharacters =
//                                                                               email.substring(emailLength - 4);
//                                                                           String
//                                                                               censoredEmail =
//                                                                               '$firstTwoCharacters${'*' * (emailLength - 6)}$lastFourCharacters';

//                                                                           String
//                                                                               connected_ =
//                                                                               '${userModels[index].connected}';

//                                                                           DateTime
//                                                                               connectedTime =
//                                                                               DateTime.parse(connected_);

//                                                                           DateTime
//                                                                               currentTime =
//                                                                               DateTime.now();

//                                                                           Duration
//                                                                               difference =
//                                                                               currentTime.difference(connectedTime);

//                                                                           int minutesPassed =
//                                                                               difference.inMinutes;
//                                                                           return Container(
//                                                                             padding:
//                                                                                 const EdgeInsets.all(8),
//                                                                             child:
//                                                                                 Row(
//                                                                               children: [
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     '${index + 1}',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     '${censoredEmail} ',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     '${userModels[index].fname} ${userModels[index].lname}',
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     '${userModels[index].position}',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Row(
//                                                                                     children: [
//                                                                                       Expanded(flex: 1, child: Icon((minutesPassed > 1) ? Icons.motion_photos_off_rounded : Icons.motion_photos_on_rounded, color: (minutesPassed > 1) ? Colors.red : Colors.green)
//                                                                                           // Text(
//                                                                                           //   '🟢',
//                                                                                           //   maxLines: 2,
//                                                                                           //   textAlign: TextAlign.end,
//                                                                                           //   style: TextStyle(color: (minutesPassed > 1) ? Colors.red : Colors.green, fontFamily: Font_.Fonts_T),
//                                                                                           // )
//                                                                                           ),
//                                                                                       Expanded(
//                                                                                         flex: 2,
//                                                                                         child: Translate.TranslateAndSetText((minutesPassed > 1) ? 'ใช้งานเมื่อ $minutesPassed นาทีที่แล้ว' : ' ${userModels[index].connected}', AdminScafScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
//                                                                                       ),
//                                                                                     ],
//                                                                                   ),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           );
//                                                                         })),
//                                                               ],
//                                                             );
//                                                           }),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             actions: <Widget>[
//                                               Column(
//                                                 children: [
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Align(
//                                                     alignment:
//                                                         Alignment.centerLeft,
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               2.0),
//                                                       child: RichText(
//                                                         text: const TextSpan(
//                                                           text: '**หมายเหตุ : ',
//                                                           style: TextStyle(
//                                                               color: AdminScafScreen_Color
//                                                                   .Colors_Text1_,
//                                                               fontFamily:
//                                                                   FontWeight_
//                                                                       .Fonts_T),
//                                                           children: <TextSpan>[
//                                                             TextSpan(
//                                                               text: ' สีเขียว ',
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .green,
//                                                                   fontFamily:
//                                                                       FontWeight_
//                                                                           .Fonts_T),
//                                                             ),
//                                                             TextSpan(
//                                                               text:
//                                                                   ' กำลังใช้งาน (ไม่เกิน 1 นาที) ,',
//                                                               style: TextStyle(
//                                                                   color: AdminScafScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T),
//                                                             ),
//                                                             TextSpan(
//                                                               text: ' สีแดง ',
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .red,
//                                                                   fontFamily:
//                                                                       FontWeight_
//                                                                           .Fonts_T),
//                                                             ),
//                                                             TextSpan(
//                                                               text:
//                                                                   ' ใช้งานล่าสุด (ไม่เกิน 15 นาที)',
//                                                               style: TextStyle(
//                                                                   color: AdminScafScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const Divider(
//                                                     color: Colors.grey,
//                                                     height: 4.0,
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             8.0),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment.end,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Container(
//                                                                 width: 100,
//                                                                 decoration:
//                                                                     const BoxDecoration(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   borderRadius: BorderRadius.only(
//                                                                       topLeft:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       topRight:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       bottomLeft:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       bottomRight:
//                                                                           Radius.circular(
//                                                                               10)),
//                                                                 ),
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .all(
//                                                                         8.0),
//                                                                 child:
//                                                                     TextButton(
//                                                                   onPressed: () =>
//                                                                       Navigator.pop(
//                                                                           context,
//                                                                           'OK'),
//                                                                   child: Translate.TranslateAndSetText(
//                                                                       'ปิด',
//                                                                       Colors
//                                                                           .white,
//                                                                       TextAlign
//                                                                           .center,
//                                                                       FontWeight
//                                                                           .bold,
//                                                                       FontWeight_
//                                                                           .Fonts_T,
//                                                                       14,
//                                                                       1),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                 child: Stack(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(4.0),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.white54,
//                                           borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(20),
//                                               topRight: Radius.circular(20),
//                                               bottomLeft: Radius.circular(20),
//                                               bottomRight: Radius.circular(20)),
//                                         ),
//                                         padding: const EdgeInsets.all(6.0),
//                                         child: Icon(
//                                           Icons.people,
//                                           color: Colors.red,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                         top: 0,
//                                         left: 0,
//                                         child: Container(
//                                           // decoration: const BoxDecoration(
//                                           //   color: Colors.white,
//                                           //   borderRadius: BorderRadius.only(
//                                           //       topLeft: Radius.circular(20),
//                                           //       topRight: Radius.circular(20),
//                                           //       bottomLeft: Radius.circular(20),
//                                           //       bottomRight: Radius.circular(20)),
//                                           // ),
//                                           padding: const EdgeInsets.all(2.0),
//                                           child: Text(
//                                             renTal_name == null
//                                                 ? '0'
//                                                 : '${userModels.length}',
//                                             // '${userModels.length}***/$connected_Minutes/$ser_user/$email_user',
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.blue,
//                                                 fontFamily:
//                                                     FontWeight_.Fonts_T),
//                                           ),
//                                         ))
//                                   ],
//                                 )),
//                           );
//                         }),
//                     Padding(
//                       padding: EdgeInsets.all(4.0),
//                       child: StreamBuilder(
//                           stream: Stream.periodic(const Duration(seconds: 0)),
//                           builder: (context, snapshot) {
//                             return Text(
//                               'Hi $fname_user ...',
//                               style: TextStyle(
//                                   color: AdminScafScreen_Color.Colors_Text1_,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   fontFamily: FontWeight_.Fonts_T),
//                             );
//                           }),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.lightGreen[200]!.withOpacity(0.7),
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(0),
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(0)),
//                       ),
//                       padding: const EdgeInsets.all(2.0),
//                       child: InkWell(
//                         onTap: () {
//                           showDialog<String>(
//                             context: context,
//                             builder: (BuildContext context) => AlertDialog(
//                               shape: const RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(20.0))),
//                               title: Center(
//                                 child: Translate.TranslateAndSetText(
//                                     'ออกจากระบบ',
//                                     AdminScafScreen_Color.Colors_Text1_,
//                                     TextAlign.center,
//                                     FontWeight.bold,
//                                     FontWeight_.Fonts_T,
//                                     14,
//                                     1),
//                               ),
//                               actions: <Widget>[
//                                 Column(
//                                   children: [
//                                     const SizedBox(
//                                       height: 5.0,
//                                     ),
//                                     const Divider(
//                                       color: Colors.grey,
//                                       height: 4.0,
//                                     ),
//                                     const SizedBox(
//                                       height: 5.0,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Container(
//                                               width: 100,
//                                               decoration: const BoxDecoration(
//                                                 color: Colors.green,
//                                                 borderRadius: BorderRadius.only(
//                                                     topLeft:
//                                                         Radius.circular(10),
//                                                     topRight:
//                                                         Radius.circular(10),
//                                                     bottomLeft:
//                                                         Radius.circular(10),
//                                                     bottomRight:
//                                                         Radius.circular(10)),
//                                               ),
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: TextButton(
//                                                 onPressed: (renTal_user
//                                                                 .toString() ==
//                                                             '50' ||
//                                                         renTal_user
//                                                                 .toString() ==
//                                                             '139')
//                                                     ? () async {
//                                                         AuthService.logout();
//                                                         SharedPreferences
//                                                             preferences =
//                                                             await SharedPreferences
//                                                                 .getInstance();
//                                                         preferences.clear();

//                                                         MaterialPageRoute
//                                                             route =
//                                                             MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               LoginPage(),
//                                                         );
//                                                         Navigator
//                                                             .pushAndRemoveUntil(
//                                                                 context, route,
//                                                                 (route) {
//                                                           return false;
//                                                         });
//                                                       }
//                                                     : () async {
//                                                         deall_Trans_select();
//                                                         SharedPreferences
//                                                             preferences =
//                                                             await SharedPreferences
//                                                                 .getInstance();
//                                                         var ser = preferences
//                                                             .getString('ser');
//                                                         var on = '0';
//                                                         String url =
//                                                             '${MyConstant().domain}/U_user_onoff.php?isAdd=true&ser=$ser&on=$on';

//                                                         try {
//                                                           var response =
//                                                               await httpClient
//                                                                   .get(
//                                                                       Uri.parse(
//                                                                           url));

//                                                           var result = json
//                                                               .decode(response
//                                                                   .body);
//                                                           // print(result);
//                                                           if (result
//                                                                   .toString() ==
//                                                               'true') {
//                                                             SharedPreferences
//                                                                 preferences =
//                                                                 await SharedPreferences
//                                                                     .getInstance();
//                                                             preferences.clear();
//                                                             routToService(
//                                                                 SignInScreen());
//                                                           } else {
//                                                             ScaffoldMessenger
//                                                                     .of(context)
//                                                                 .showSnackBar(
//                                                               SnackBar(
//                                                                   content: Text(
//                                                                       '(ผิดพลาด)')),
//                                                             );
//                                                           }
//                                                         } catch (e) {}
//                                                       },
//                                                 child: Translate
//                                                     .TranslateAndSetText(
//                                                         'ยืนยัน',
//                                                         Colors.white,
//                                                         TextAlign.center,
//                                                         FontWeight.bold,
//                                                         FontWeight_.Fonts_T,
//                                                         14,
//                                                         1),
//                                               ),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                   width: 100,
//                                                   decoration:
//                                                       const BoxDecoration(
//                                                     color: Colors.redAccent,
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                             topLeft:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             bottomLeft:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             bottomRight:
//                                                                 Radius.circular(
//                                                                     10)),
//                                                   ),
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: TextButton(
//                                                     onPressed: () =>
//                                                         Navigator.pop(
//                                                             context, 'OK'),
//                                                     child: Translate
//                                                         .TranslateAndSetText(
//                                                             'ยกเลิก',
//                                                             Colors.white,
//                                                             TextAlign.center,
//                                                             FontWeight.bold,
//                                                             FontWeight_.Fonts_T,
//                                                             14,
//                                                             1),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: const Padding(
//                           padding: EdgeInsets.all(4.0),
//                           child: Icon(Icons.logout_rounded),
//                         ),
//                       ),
//                     ),
//                     // TimerBuilder.scheduled([alert!], builder: (context) {
//                     //   // This function will be called once the alert time is reached
//                     //   var now = DateTime.now();
//                     //   var reached = now.compareTo(alert!) >= 0;
//                     //   // final textStyle = Theme.of(context).textTheme.title;
//                     //   return Center(
//                     //     child: Column(
//                     //       mainAxisAlignment: MainAxisAlignment.center,
//                     //       crossAxisAlignment: CrossAxisAlignment.center,
//                     //       children: <Widget>[
//                     //         // Icon(
//                     //         //   reached ? Icons.alarm_on : Icons.alarm,
//                     //         //   color: reached ? Colors.red : Colors.green,
//                     //         //   size: 48,
//                     //         // ),
//                     //         !reached
//                     //             ? TimerBuilder.periodic(Duration(seconds: 1),
//                     //                 alignment: Duration.zero,
//                     //                 builder: (context) {
//                     //                 // This function will be called every second until the alert time
//                     //                 var now = DateTime.now();
//                     //                 var remaining = alert!.difference(now);
//                     //                 return Text(
//                     //                   formatDuration(remaining),
//                     //                   // style: textStyle,
//                     //                 );
//                     //               })
//                     //             : Text(
//                     //                 "00:00:00 \t\t",
//                     //                 // style: textStyle
//                     //               ),
//                     //         // RaisedButton(
//                     //         //   child: Text("Reset"),
//                     //         //   onPressed: () {
//                     //         //     setState(() {
//                     //         //       alert =
//                     //         //           DateTime.now().add(Duration(seconds: 120));
//                     //         //     });
//                     //         //   },
//                     //         // ),
//                     //       ],
//                     //     ),
//                     //   );
//                     // }),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//         elevation: 0,
//         backgroundColor: AppBarColors.hexColor,
//       ),
//       sideBar: (context.watch<SidebarController>().isOpen)
//           ? SideBar(
//               width: 250,
//               key: _keybar,
//               textStyle: const TextStyle(
//                   color: Colors.white, fontFamily: Font_.Fonts_T),
//               iconColor: Colors.white,
//               backgroundColor: AppBarColors.ABar_Colors_tab,
//               items: [
//                 for (int i = 0; i < perMissionModels.length; i++)
//                   if (int.parse(perMissionModels[i].ser!) <= 3)
//                     AdminMenuItem(
//                       title: '${translate_menu[i]}',

//                       ///'${translate_menu.length}${perMissionModels[i].perm!.trim()}',
//                       route: '/${perMissionModels[i].perm!.trim()}',
//                       icon: IconData(
//                         int.parse(
//                           '${perMissionModels[i].icon}',
//                         ),
//                         fontFamily: 'MaterialIcons',
//                       ),
//                     ),
//                 AdminMenuItem(
//                   title: '${more_menu}',
//                   // icon: Icons.more_horiz,
//                   icon: IconData(
//                     int.parse(
//                       '0xf8d9',
//                     ),
//                     fontFamily: 'MaterialIcons',
//                   ),
//                   children: [
//                     for (int i = 0; i < perMissionModels.length; i++)
//                       if (int.parse(perMissionModels[i].ser!) > 3)
//                         AdminMenuItem(
//                           title:
//                               '${translate_menu[i]}', // '${perMissionModels[i].perm!.trim()}',
//                           route: '/${perMissionModels[i].perm!.trim()}',
//                           icon: IconData(
//                             int.parse(
//                               '${perMissionModels[i].icon}',
//                             ),
//                             fontFamily: 'MaterialIcons',
//                           ),
//                         ),
//                   ],
//                 ),
//                 // AdminMenuItem(
//                 //   title: perMissionModels[i].perm!.trim(),
//                 //   route: '/${perMissionModels[i].perm!.trim()}',
//                 //   icon: IconData(
//                 //     int.parse(
//                 //       '${perMissionModels[i].icon}',
//                 //     ),
//                 //     fontFamily: 'MaterialIcons',
//                 //   ),
//                 // ),
//                 // AdminMenuItem(
//                 //   title: 'อื่นๆ',
//                 //   // icon: Icons.more_horiz,
//                 //   icon: IconData(
//                 //     int.parse(
//                 //       '0xf8d9',
//                 //     ),
//                 //     fontFamily: 'MaterialIcons',
//                 //   ),
//                 //   children: [
//                 //     for (int i = 0; i < perMissionModels.length; i++)
//                 //       if (int.parse(perMissionModels[i].ser!) > 3)
//                 //         AdminMenuItem(
//                 //           title: perMissionModels[i].perm!.trim(),
//                 //           route: '/${perMissionModels[i].perm!.trim()}',
//                 //           icon: IconData(
//                 //             int.parse(
//                 //               '${perMissionModels[i].icon}',
//                 //             ),
//                 //             fontFamily: 'MaterialIcons',
//                 //           ),
//                 //         ),
//                 //   ],
//                 // ),
//               ],
//               selectedRoute: '/',
//               onSelected: (item) async {
//                 SharedPreferences preferences =
//                     await SharedPreferences.getInstance();
//                 if (preferences.getString('zonesName').toString() == 'null') {
//                   // ✅ แยก preferences I/O ออกนอก setState
//                   await preferences.setString('zoneSer', '0');
//                   await preferences.setString('zonesName', 'ทั้งหมด');
//                 }
//                 for (int i = 0; i < perMissionModels.length; i++) {
//                   if (item.route == '/${perMissionModels[i].perm!.trim()}') {
//                     if (renTal_user != null) {
//                       SharedPreferences preferences =
//                           await SharedPreferences.getInstance();
//                       await preferences.setString(
//                           'route', perMissionModels[i].perm!.trim().toString());
//                       // ✅ แยก preferences.setString ออกนอก setState
//                       await preferences.setString('Ser_Typepay', '0');
//                       setState(() {
//                         Value_Route = perMissionModels[i].perm!.trim();
//                         _keybar.currentState?.closeDrawer();
//                       });
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Translate.TranslateAndSetText(
//                               'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
//                               Colors.black,
//                               TextAlign.center,
//                               FontWeight.bold,
//                               FontWeight_.Fonts_T,
//                               14,
//                               1),
//                         ),
//                       );
//                     }
//                     read_GC_rentalColor();
//                   }
//                 }
//                 // if (item.route == '/หน้าหลัก') {
//                 //   setState(() {
//                 //     Value_Route = 'หน้าหลัก';
//                 //   });
//                 //   // Navigator.push(context,
//                 //   //     MaterialPageRoute(builder: (context) => const HomeScreen()));
//                 //   print('1หน้าหลัก');
//                 // } else if ((item.route == '/พื้นที่เช่า')) {
//                 //   setState(() {
//                 //     Value_Route = 'พื้นที่เช่า';
//                 //   });
//                 //   // Navigator.push(
//                 //   //     context,
//                 //   //     MaterialPageRoute(
//                 //   //         builder: (context) => const ChaoAreaScreen()));
//                 //   print('2พื้นที่เช่า');
//                 // } else if ((item.route == '/ผู้เช่า')) {
//                 //   setState(() {
//                 //     Value_Route = 'ผู้เช่า';
//                 //   });
//                 //   // Navigator.push(
//                 //   //     context,
//                 //   //     MaterialPageRoute(
//                 //   //         builder: (context) => const PeopleChaoScreen()));
//                 //   print('3');
//                 // } else if ((item.route == '/บัญชี')) {
//                 //   setState(() {
//                 //     Value_Route = 'บัญชี';
//                 //   });
//                 //   // Navigator.push(
//                 //   //     context,
//                 //   //     MaterialPageRoute(
//                 //   //         builder: (context) => const AccountScreen()));
//                 //   print('4บัญชี');
//                 // } else if ((item.route == '/จัดการ')) {
//                 //   setState(() {
//                 //     Value_Route = 'จัดการ';
//                 //   });
//                 //   // Navigator.push(
//                 //   //     context,
//                 //   //     MaterialPageRoute(
//                 //   //         builder: (context) => const ManageScreen()));
//                 //   print('5');
//                 // } else if ((item.route == '/รายงาน')) {
//                 //   setState(() {
//                 //     Value_Route = 'รายงาน';
//                 //   });
//                 //   // Navigator.push(
//                 //   //     context,
//                 //   //     MaterialPageRoute(
//                 //   //         builder: (context) => const ReportScreen()));
//                 //   print('6รายงาน');
//                 // } else if ((item.route == '/ตั้งค่า')) {
//                 //   setState(() {
//                 //     Value_Route = 'ตั้งค่า';
//                 //   });
//                 //   // Navigator.push(
//                 //   //     context,
//                 //   //     MaterialPageRoute(
//                 //   //         builder: (context) => const SettingScreen()));
//                 //   print('7ตั้งค่า');
//                 // }
//               },
//               header: Container(
//                 color: AppBarColors.ABar_Colors_tab,
//                 child: Column(
//                   children: [
//                     if (time_check.toString() != '0' && time_check != null)
//                       if (Auto_cancel.toString() == 'Yes')
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
//                           child: InkWell(
//                             onTap: () async {
//                               SharedPreferences preferences =
//                                   await SharedPreferences.getInstance();
//                               var ren = preferences.getString('renTalSer');
//                               String url =
//                                   '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

//                               try {
//                                 var response =
//                                     await httpClient.get(Uri.parse(url));

//                                 var result = json.decode(response.body);
//                                 // print('GC_rental_setring>> $result');

//                                 if (result != null) {
//                                   for (var map in result) {
//                                     RenTalModel renTalModel =
//                                         RenTalModel.fromJson(map);
//                                     setState(() {
//                                       time_check = renTalModel.time_check;
//                                     });
//                                   }
//                                 }
//                                 if (time_check == null ||
//                                     time_check.toString() == '0') {
//                                   String? _route =
//                                       preferences.getString('route');
//                                   MaterialPageRoute materialPageRoute =
//                                       MaterialPageRoute(
//                                           builder: (BuildContext context) =>
//                                               AdminScafScreen(route: _route));
//                                   Navigator.pushAndRemoveUntil(context,
//                                       materialPageRoute, (route) => false);
//                                 }
//                               } catch (e) {}
//                               String Formbe_c = (int.parse('${time_check}') <
//                                       60)
//                                   ? 'รายการเกินกำหนด $time_check นาที'
//                                   : (int.parse('${time_check}') == 60)
//                                       ? 'รายการเกินกำหนด 1 ชั่วโมง'
//                                       : (int.parse('${time_check}') == 90)
//                                           ? 'รายการเกินกำหนด 1.3 ชั่วโมง'
//                                           : (int.parse('${time_check}') == 120)
//                                               ? 'รายการเกินกำหนด 2 ชั่วโมง'
//                                               : (int.parse('${time_check}') ==
//                                                       1440)
//                                                   ? 'รายการเกินกำหนด 1 วัน'
//                                                   : (int.parse(
//                                                               '${time_check}') ==
//                                                           2880)
//                                                       ? 'รายการเกินกำหนด 2 วัน'
//                                                       : 'รายการเกินกำหนด $time_check นาที';
//                               if (time_check != null &&
//                                   time_check.toString() != '0')
//                                 showDialog<String>(
//                                   context: context,
//                                   builder: (BuildContext context) =>
//                                       AlertDialog(
//                                     shape: const RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(20.0))),
//                                     backgroundColor:
//                                         AppbackgroundColor.Sub_Abg_Colors,
//                                     titlePadding: const EdgeInsets.all(4.0),
//                                     contentPadding: const EdgeInsets.all(10.0),
//                                     actionsPadding: const EdgeInsets.all(6.0),
//                                     title: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.end,
//                                           children: [
//                                             InkWell(
//                                               onTap: () {
//                                                 Navigator.pop(context, 'OK');
//                                               },
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(4.0),
//                                                 child: Icon(Icons.highlight_off,
//                                                     size: 30,
//                                                     color: Colors.red[700]),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Icon(
//                                           Icons.lock_clock,
//                                           size: 30,
//                                           color: Colors.blueGrey,
//                                         ),
//                                         Translate.TranslateAndSetText(
//                                             '#หมายเหตุระบบกึ่ง Auto  :',
//                                             Colors.deepOrange,
//                                             TextAlign.center,
//                                             FontWeight.bold,
//                                             FontWeight_.Fonts_T,
//                                             14,
//                                             1),
//                                         Translate.TranslateAndSetText(
//                                             'ยกเลิกรายการชำระ/จอง(รอตรวจสอบ)',
//                                             AdminScafScreen_Color.Colors_Text1_,
//                                             TextAlign.center,
//                                             FontWeight.bold,
//                                             FontWeight_.Fonts_T,
//                                             14,
//                                             1),
//                                         Translate.TranslateAndSetText(
//                                             'เงื่อนไข $Formbe_c',
//                                             AdminScafScreen_Color.Colors_Text1_,
//                                             TextAlign.center,
//                                             FontWeight.bold,
//                                             FontWeight_.Fonts_T,
//                                             14,
//                                             1),
//                                         Translate.TranslateAndSetText(
//                                             'ล็อกเสียบ/พื้นที่สำรอง',
//                                             AdminScafScreen_Color.Colors_Text1_,
//                                             TextAlign.center,
//                                             FontWeight.bold,
//                                             FontWeight_.Fonts_T,
//                                             14,
//                                             1),
//                                         Translate.TranslateAndSetText(
//                                             '( รายการ ที่ไม่พบ/แนบ Slip )',
//                                             Colors.grey,
//                                             TextAlign.center,
//                                             FontWeight.bold,
//                                             FontWeight_.Fonts_T,
//                                             14,
//                                             1),
//                                         const Divider(),
//                                         Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               0, 4, 4, 4),
//                                           child: Container(
//                                             width: 150,
//                                             decoration: BoxDecoration(
//                                               color: Colors.deepOrange[100],
//                                               borderRadius:
//                                                   const BorderRadius.only(
//                                                       topLeft:
//                                                           Radius.circular(8),
//                                                       topRight:
//                                                           Radius.circular(8),
//                                                       bottomLeft:
//                                                           Radius.circular(8),
//                                                       bottomRight:
//                                                           Radius.circular(8)),
//                                               border: Border.all(
//                                                   color: Colors.grey, width: 1),
//                                             ),
//                                             padding: EdgeInsets.all(2.0),
//                                             child: Row(
//                                               children: [
//                                                 Padding(
//                                                   padding: EdgeInsets.all(2.0),
//                                                   child: Translate
//                                                       .TranslateAndSetText(
//                                                           'Check Auto',
//                                                           Colors.deepOrange,
//                                                           TextAlign.center,
//                                                           FontWeight.bold,
//                                                           FontWeight_.Fonts_T,
//                                                           14,
//                                                           1),
//                                                 ),
//                                                 InkWell(
//                                                   onTap: () async {
//                                                     SharedPreferences
//                                                         preferences =
//                                                         await SharedPreferences
//                                                             .getInstance();
//                                                     if (Auto_cancel
//                                                             .toString() ==
//                                                         'Yes') {
//                                                       preferences.setString(
//                                                           'Auto_cancel', 'No');
//                                                     } else {
//                                                       preferences.setString(
//                                                           'Auto_cancel', 'Yes');
//                                                     }
//                                                     String? _route = preferences
//                                                         .getString('route');
//                                                     MaterialPageRoute
//                                                         materialPageRoute =
//                                                         MaterialPageRoute(
//                                                             builder: (BuildContext
//                                                                     context) =>
//                                                                 AdminScafScreen(
//                                                                     route:
//                                                                         _route));
//                                                     Navigator
//                                                         .pushAndRemoveUntil(
//                                                             context,
//                                                             materialPageRoute,
//                                                             (route) => false);
//                                                   },
//                                                   child: (Auto_cancel
//                                                               .toString() ==
//                                                           'Yes')
//                                                       ? Icon(
//                                                           Icons.toggle_on,
//                                                           color: Colors.green,
//                                                           size: 25,
//                                                         )
//                                                       : Icon(
//                                                           Icons.toggle_off,
//                                                           color: Colors.black87,
//                                                           size: 30,
//                                                         ),
//                                                 ),
//                                                 // Icon(
//                                                 //   Icons.toggle_on,
//                                                 //   color: Colors
//                                                 //       .green,
//                                                 //   size: 25,
//                                                 // ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         const Divider(),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                             },
//                             child: Container(
//                               height: 45,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 color: AppBarColors.hexColor.withOpacity(0.9),
//                                 borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(0),
//                                     topRight: Radius.circular(0),
//                                     bottomLeft: Radius.circular(8),
//                                     bottomRight: Radius.circular(8)),
//                               ),
//                               child: Center(
//                                 child: Timer_Countdown(context, time_check),
//                               ),
//                             ),
//                           ),
//                         ),
//                     Container(
//                       // width: 200,
//                       decoration: BoxDecoration(
//                         color: AppBarColors.ABar_Colors_tab,
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(0),
//                             topRight: Radius.circular(0),
//                             bottomLeft: Radius.circular(0),
//                             bottomRight: Radius.circular(0)),
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: const Image(
//                         image: AssetImage('images/chaoperty_dark.png'),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () async {
//                         setState(() {
//                           Value_Route = 'หน้าหลัก';
//                         });
//                         SharedPreferences preferences =
//                             await SharedPreferences.getInstance();
//                         preferences.setString('route', 'หน้าหลัก');
//                         var name = preferences.getString('fname');
//                         Insert_log.Insert_logs('หน้าหลัก', '$name>หน้าหลัก');
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           height: 40,
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(20),
//                                 topRight: Radius.circular(20),
//                                 bottomLeft: Radius.circular(20),
//                                 bottomRight: Radius.circular(20)),
//                           ),
//                           child: Center(
//                             child: Translate.TranslateAndSetText(
//                                 'เมนูหลัก',
//                                 Colors.black,
//                                 TextAlign.center,
//                                 FontWeight.bold,
//                                 FontWeight_.Fonts_T,
//                                 14,
//                                 1),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               footer: Container(
//                 // height: 50,
//                 width: double.infinity,
//                 color: AppBarColors.ABar_Colors_tab,
//                 child: Container(
//                   // height: 40,
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(5),
//                         topRight: Radius.circular(5),
//                         bottomLeft: Radius.circular(0),
//                         bottomRight: Radius.circular(0)),
//                   ),
//                   child: Column(
//                     children: [
//                       // (ren_ser.toString() == '114')
//                       //     ? Padding(
//                       //         padding: EdgeInsets.all(4.0),
//                       //         child: InkWell(
//                       //           onTap: () async {
//                       //             Navigator.push(
//                       //               context,
//                       //               MaterialPageRoute(
//                       //                 builder: (context) => WebView_NainaSetting(),
//                       //               ),
//                       //             );
//                       //           },
//                       //           child: Container(
//                       //             decoration: BoxDecoration(
//                       //               color: AppBarColors.hexColor.withOpacity(0.9),
//                       //               borderRadius: BorderRadius.only(
//                       //                   topLeft: Radius.circular(10),
//                       //                   topRight: Radius.circular(10),
//                       //                   bottomLeft: Radius.circular(10),
//                       //                   bottomRight: Radius.circular(10)),
//                       //             ),
//                       //             padding: EdgeInsets.all(4.0),
//                       //             child: Row(
//                       //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       //               children: const [
//                       //                 Icon(
//                       //                   Icons.hotel,
//                       //                   color: Colors.white,
//                       //                 ),
//                       //                 Text(
//                       //                   'Nainaservice',
//                       //                   maxLines: 1,
//                       //                   overflow: TextOverflow.ellipsis,
//                       //                   softWrap: false,
//                       //                   textAlign: TextAlign.center,
//                       //                   style: TextStyle(
//                       //                       color: Colors.white,
//                       //                       fontWeight: FontWeight.bold,
//                       //                       fontFamily: Font_.Fonts_T,
//                       //                       fontSize: 16.0),
//                       //                 ),
//                       //                 Text(
//                       //                   '> >',
//                       //                   maxLines: 1,
//                       //                   overflow: TextOverflow.ellipsis,
//                       //                   softWrap: false,
//                       //                   textAlign: TextAlign.center,
//                       //                   style: TextStyle(
//                       //                       color: Colors.white,
//                       //                       fontWeight: FontWeight.bold,
//                       //                       fontFamily: Font_.Fonts_T,
//                       //                       fontSize: 16.0),
//                       //                 ),
//                       //               ],
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       )
//                       //     :
//                       renTal_lavel! <= 3
//                           ? SizedBox()
//                           : passcode == null
//                               ? SizedBox()
//                               : Center(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             '$passcode',
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             softWrap: false,
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                                 color: Colors.orange.shade900,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: Font_.Fonts_T,
//                                                 fontSize: 20.0),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: TextButton(
//                                             onPressed: () async {
//                                               await checkConnected();
//                                               showDialog<String>(
//                                                 barrierDismissible: false,
//                                                 context: context,
//                                                 builder: (ctx) =>
//                                                     _UserPickerDialog(
//                                                   context: ctx,
//                                                   namemake: '-',
//                                                   userModels: ConnecAmins,
//                                                   onPicked: (picked) async {},
//                                                 ),
//                                               );
//                                             },
//                                             child: Text(
//                                               "Admin User",
//                                               style: TextStyle(
//                                                 color: Colors.orange.shade900,
//                                                 fontFamily: Font_.Fonts_T,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                       const Center(
//                         child: Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(
//                             '© Dzentric Co.,Ltd. All Rights Reserved',
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             softWrap: false,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 color: AdminScafScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                                 fontSize: 10.0),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           : null,
//       body: Stack(children: [
//         (Value_Route == 'หน้าหลัก')
//             ? const HomeScreen()
//             : (Value_Route == 'พื้นที่เช่า')
//                 ? ChaoAreaScreen()
//                 : (Value_Route == 'ใบอนุญาต')
//                     ? RequestContract_CMM() //ChaoAreaScreen()
//                     : (Value_Route == 'RequestExaminer1_CMM')
//                         ? const RequestExaminer1_CMM()
//                         : (Value_Route == 'RequestExaminer2_CMM')
//                             ? const RequestExaminer2_CMM()
//                             : (Value_Route == 'SignaturePad_CMM')
//                                 ? const SignaturePad_CMM()
//                                 : (Value_Route == 'ผู้เช่า')
//                                     ? const PeopleChaoScreen()
//                                     : (Value_Route == 'บัญชี')
//                                         ? const AccountScreen()
//                                         : (Value_Route == 'จัดการ')
//                                             ? const ManageScreen()
//                                             : (Value_Route == 'รายงาน')
//                                                 ? ReportScreen()
//                                                 : (Value_Route == 'ทะเบียน')
//                                                     ? const BureauScreen()
//                                                     : (Value_Route == 'ตั้งค่า')
//                                                         ? const SettingScreen()
//                                                         : (Value_Route ==
//                                                                 'จัดการข้อมูลส่วนตัว')
//                                                             ? const SettingUserScreen()
//                                                             : const SettingUserScreen(),
//         // MourningRibbonOverlay(),
//       ]),
//       // body: (Value_Route == 'หน้าหลัก')
//       //     ? const HomeScreen()
//       //     : (Value_Route == 'พื้นที่เช่า')
//       //         ? const ChaoAreaScreen()
//       //         : (Value_Route == 'ผู้เช่า')
//       //             ? const PeopleChaoScreen()
//       //             : (Value_Route == 'บัญชี')
//       //                 ? const AccountScreen()
//       //                 : (Value_Route == 'จัดการ')
//       //                     ? const ManageScreen()
//       //                     : (Value_Route == 'รายงาน' &&
//       //                             (renTal_user.toString() == '72' ||
//       //                                 renTal_user.toString() == '92' ||
//       //                                 renTal_user.toString() == '93' ||
//       //                                 renTal_user.toString() == '94'))
//       //                         ? const Report_Ortor_Screen()
//       //                         : (Value_Route == 'รายงาน' &&
//       //                                 renTal_user.toString() == '65')
//       //                             ? const Report_cm_Screen()
//       //                             : (Value_Route == 'รายงาน' &&
//       //                                     renTal_user.toString() != '65')
//       //                                 ? ReportScreen()
//       //                                 : (Value_Route == 'ทะเบียน')
//       //                                     ? const BureauScreen()
//       //                                     : (Value_Route == 'ตั้งค่า')
//       //                                         ? const SettingScreen()
//       //                                         : (Value_Route ==
//       //                                                 'จัดการข้อมูลส่วนตัว')
//       //                                             ? const SettingUserScreen()
//       //                                             : const SettingUserScreen(),
//     );
//   }

//   Future<Null> infomation() async {
//     showDialog<String>(
//         // barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//               shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(20.0))),
//               title: const Center(
//                   child: Text(
//                 'Level ของคุณไม่สามารถเข้าถึงได้',
//                 style: TextStyle(
//                   color: SettingScreen_Color.Colors_Text1_,
//                   fontFamily: FontWeight_.Fonts_T,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )),
//             ));
//   }

//   Future<Null> de_Trans_item(index) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var user = preferences.getString('ser');
//     var userser = userModels_chat[index].ser;

//     String url =
//         '${MyConstant().domain}/logout_Admin.php?isAdd=true&ren=$ren&userser=$userser';
//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // print(result);
//       if (result.toString() == 'true') {
//         setState(() {
//           Navigator.pop(context);
//           Navigator.pop(context);
//           Formpasslok_.clear();
//         });
//         print('rrrrrrrrrrrrrr');
//       }
//     } catch (e) {}
//   }

//   Scaffold adminmobile() {
//     return Scaffold(
//       backgroundColor: AppbackgroundColor.Abg_Colors,
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         foregroundColor: Colors.black,
//         titleSpacing: 00.0,
//         centerTitle: true,
//         toolbarHeight: 50.2,
//         // toolbarOpacity: 0.8,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(0),
//             bottomLeft: Radius.circular(0),
//           ),
//         ),
//         title: Align(
//           alignment: Alignment.centerLeft,
//           child: StreamBuilder(
//               stream: Stream.periodic(const Duration(seconds: 1)),
//               builder: (context, snapshot) {
//                 return SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       if (Responsive.isDesktop(context))
//                         (img_logo == null || img_logo.toString() == '')
//                             ? SizedBox()
//                             : InkWell(
//                                 child: CircleAvatar(
//                                   radius: 20.0,
//                                   backgroundImage: NetworkImage(
//                                       '${MyConstant().domain}/files/$foder/logo/$img_logo'),
//                                   backgroundColor: Colors.transparent,
//                                 ),
//                                 onTap: () {
//                                   if (img_logo == null ||
//                                       img_logo.toString() == '') {
//                                   } else {
//                                     String url =
//                                         '${MyConstant().domain}/files/$foder/logo/$img_logo';
//                                     _showMyDialogImg(
//                                         url,
//                                         renTal_name == null
//                                             ? ' '
//                                             : ' $renTal_name');
//                                   }
//                                 },
//                               ),
//                       InkWell(
//                         child: Text(
//                           renTal_name == null ? ' ภาพรวม' : ' $renTal_name',
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: (Responsive.isDesktop(context))
//                                   ? FontWeight.bold
//                                   : null,
//                               fontSize:
//                                   (Responsive.isDesktop(context)) ? null : 12,
//                               fontFamily: FontWeight_.Fonts_T),
//                         ),
//                         onTap: () {
//                           if (img_logo == null || img_logo.toString() == '') {
//                           } else {
//                             String url =
//                                 '${MyConstant().domain}/files/$foder/logo/$img_logo';
//                             _showMyDialogImg(url,
//                                 renTal_name == null ? ' ' : ' $renTal_name');
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//         ),
//         actions: [
//           Row(
//             children: [
//               StreamBuilder(
//                   stream: Stream.periodic(const Duration(seconds: 1)),
//                   builder: (context, snapshot) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         // color: Colors.white.withOpacity(0.7),
//                         // Colors.lightGreen[200],
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10),
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(10)),
//                         // border: Border.all(color: Colors.grey, width: 0.5),
//                       ),
//                       padding: const EdgeInsets.all(0.5),
//                       child: Container(
//                         width: 100,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Icon(
//                                 Icons.sunny,
//                                 size: 15.0,
//                                 color: (AppbackgroundColor.TiTile_Colors ==
//                                         Color.fromARGB(255, 203, 200, 219))
//                                     ? Colors.white
//                                     : Colors.orange,
//                               ),
//                             ),
//                             (isDark_Mode == true)
//                                 ? InkWell(
//                                     onTap: () async {
//                                       SharedPreferences preferences =
//                                           await SharedPreferences.getInstance();
//                                       setState(() {
//                                         preferences.setBool(
//                                             'isDarkMode', false);
//                                       });
//                                       // print(preferences.getBool('isDarkMode'));
//                                       // print(isDark_Mode);
//                                       String? _route =
//                                           preferences.getString('route');
//                                       MaterialPageRoute materialPageRoute =
//                                           MaterialPageRoute(
//                                               builder: (BuildContext context) =>
//                                                   AdminScafScreen(
//                                                       route: _route));
//                                       Navigator.pushAndRemoveUntil(context,
//                                           materialPageRoute, (route) => false);
//                                       // changeColor();
//                                     },
//                                     child: Icon(
//                                       Icons.toggle_on,
//                                       color: Colors.yellow[100],
//                                       size: 35.0,
//                                     ),
//                                   )
//                                 : InkWell(
//                                     onTap: () async {
//                                       SharedPreferences preferences =
//                                           await SharedPreferences.getInstance();
//                                       setState(() {
//                                         preferences.setBool('isDarkMode', true);
//                                       });

//                                       // print(preferences.getBool('isDarkMode'));
//                                       String? _route =
//                                           preferences.getString('route');
//                                       MaterialPageRoute materialPageRoute =
//                                           MaterialPageRoute(
//                                               builder: (BuildContext context) =>
//                                                   AdminScafScreen(
//                                                       route: _route));
//                                       Navigator.pushAndRemoveUntil(context,
//                                           materialPageRoute, (route) => false);
//                                       // changeColor();
//                                     },
//                                     child: Icon(
//                                       Icons.toggle_off,
//                                       color: Colors.orange[100],
//                                       size: 35.0,
//                                     ),
//                                   ),
//                             // (AppbackgroundColor.TiTile_Colors ==
//                             //         Color.fromARGB(255, 203, 200, 219))
//                             //     ? InkWell(
//                             //         onTap: () {
//                             //           changeColor();
//                             //         },
//                             //         child: Icon(
//                             //           Icons.toggle_on,
//                             //           color: Colors.yellow[100],
//                             //           size: 35.0,
//                             //         ),
//                             //       )
//                             //     : InkWell(
//                             //         onTap: () {
//                             //           changeColor();
//                             //         },
//                             //         child: Icon(
//                             //           Icons.toggle_off,
//                             //           color: Colors.orange[100],
//                             //           size: 35.0,
//                             //         ),
//                             //       ),
//                             Expanded(
//                                 flex: 1,
//                                 child: Icon(
//                                   Icons.bedtime,
//                                   size: 15.0,
//                                   color: (AppbackgroundColor.TiTile_Colors ==
//                                           Color(0xFFD9D9B7))
//                                       ? Colors.white
//                                       : Colors.yellow,
//                                 )),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//               // StreamBuilder(
//               //     stream: Stream.periodic(const Duration(seconds: 1)),
//               //     builder: (context, snapshot) {
//               //       return Container(
//               //         decoration: BoxDecoration(
//               //           // color: Colors.white.withOpacity(0.7),
//               //           // Colors.lightGreen[200],
//               //           borderRadius: BorderRadius.only(
//               //               topLeft: Radius.circular(10),
//               //               topRight: Radius.circular(10),
//               //               bottomLeft: Radius.circular(10),
//               //               bottomRight: Radius.circular(10)),
//               //           // border: Border.all(color: Colors.grey, width: 0.5),
//               //         ),
//               //         padding: const EdgeInsets.all(0.5),
//               //         child: Container(
//               //           width: 100,
//               //           child: Row(
//               //             children: [
//               //               Expanded(
//               //                 flex: 1,
//               //                 child: Icon(
//               //                   Icons.sunny,
//               //                   size: 15.0,
//               //                   color: (AppbackgroundColor.TiTile_Colors ==
//               //                           Color.fromARGB(255, 203, 200, 219))
//               //                       ? Colors.white
//               //                       : Colors.orange,
//               //                 ),
//               //               ),
//               //               (AppbackgroundColor.TiTile_Colors ==
//               //                       Color.fromARGB(255, 203, 200, 219))
//               //                   ? InkWell(
//               //                       onTap: () {
//               //                         changeColor();
//               //                       },
//               //                       child: Icon(
//               //                         Icons.toggle_on,
//               //                         color: Colors.yellow[100],
//               //                         size: 35.0,
//               //                       ),
//               //                     )
//               //                   : InkWell(
//               //                       onTap: () {
//               //                         changeColor();
//               //                       },
//               //                       child: Icon(
//               //                         Icons.toggle_off,
//               //                         color: Colors.orange[100],
//               //                         size: 35.0,
//               //                       ),
//               //                     ),
//               //               Expanded(
//               //                   flex: 1,
//               //                   child: Icon(
//               //                     Icons.bedtime,
//               //                     size: 15.0,
//               //                     color: (AppbackgroundColor.TiTile_Colors ==
//               //                             Color(0xFFD9D9B7))
//               //                         ? Colors.white
//               //                         : Colors.yellow,
//               //                   )),
//               //             ],
//               //           ),
//               //         ),
//               //       );
//               //     }),
//               // (Responsive.isMobile(context))
//               //     ? Text('')
//               //     : StreamBuilder(
//               //         stream: Stream.periodic(const Duration(seconds: 0)),
//               //         builder: (context, snapshot) {
//               //           return Row(
//               //             children: [
//               //               if (read_data_davtext != '')
//               //                 Container(
//               //                   width: (Responsive.isDesktop(context))
//               //                       ? MediaQuery.of(context).size.width / 4
//               //                       : MediaQuery.of(context).size.width / 5,
//               //                   child: Marquee(
//               //                     text:
//               //                         '   📢 แจ้งเตือน : $read_data_davtext     ||   ',

//               //                     /// velocity: 50.0, //speed
//               //                     // text: '$read_data_davtext',
//               //                     style: const TextStyle(
//               //                         color: Color.fromARGB(255, 179, 92, 85),
//               //                         fontWeight: FontWeight.bold,
//               //                         fontFamily: FontWeight_.Fonts_T),
//               //                     scrollAxis: Axis.horizontal,
//               //                     crossAxisAlignment: CrossAxisAlignment.center,
//               //                     // blankSpace: 20.0,
//               //                     // velocity: 100.0,
//               //                     pauseAfterRound: Duration(seconds: 1),
//               //                     // startPadding: 10.0,
//               //                     // accelerationDuration: Duration(seconds: 5),
//               //                     accelerationCurve: Curves.linear,
//               //                     decelerationDuration: Duration(seconds: 5),
//               //                     decelerationCurve: Curves.easeInOut,
//               //                   ),
//               //                 ),
//               //             ],
//               //           );
//               //         }),
//               if (!Responsive.isMobile(context) &&
//                   (ser_user == '63' ||
//                       ser_user == '56' ||
//                       ser_user == '61' ||
//                       ser_user == '37'))
//                 Padding(
//                   padding: const EdgeInsets.all(4.0),
//                   child: InkWell(
//                     onTap: () {
//                       _showMyDialogDev(0);
//                     },
//                     child: Container(
//                       color: Colors.yellow,
//                       child: Center(
//                           child: Text(
//                         '  DEV  ',
//                         style: TextStyle(
//                             color: AdminScafScreen_Color.Colors_Text1_,
//                             fontFamily: FontWeight_.Fonts_T),
//                       )),
//                     ),
//                   ),
//                 ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.7),
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(0),
//                       bottomLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(0)),
//                   // border: Border.all(color: Colors.grey, width: 0.5),
//                 ),
//                 padding: const EdgeInsets.all(0.5),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(4, 1, 0, 1),
//                       child: StreamBuilder(
//                           // ChatScreen ไม่ต้องการ refresh ทุก frame
//                           stream: Stream.periodic(const Duration(seconds: 10)),
//                           builder: (context, snapshot) {
//                             return ChatScreen(
//                                 ser_user: ser_user,
//                                 userModels_chat_: userModels_chat,
//                                 userModels_: userModels);
//                           }),
//                     ),
//                     StreamBuilder(
//                         // ไม่ต้องการอัปเดตอัตโนมัติ ใช้ Duration ว่างแทน 0
//                         stream: Stream.periodic(const Duration(seconds: 30)),
//                         builder: (context, snapshot) {
//                           return Padding(
//                             padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
//                             child: InkWell(
//                                 onTap: renTal_name == null
//                                     ? null
//                                     : () async {
//                                         startTimer();
//                                         showDialog<String>(
//                                           context: context,
//                                           builder: (BuildContext context) =>
//                                               AlertDialog(
//                                             shape: const RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.all(
//                                                     Radius.circular(20.0))),
//                                             title: Center(
//                                                 child: Text(
//                                               'ผู้ใช้งานระบบขณะนี้ $deviceNames',
//                                               style: TextStyle(
//                                                   color: AdminScafScreen_Color
//                                                       .Colors_Text1_,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontFamily:
//                                                       FontWeight_.Fonts_T),
//                                             )),
//                                             content: ScrollConfiguration(
//                                               behavior: ScrollConfiguration.of(
//                                                       context)
//                                                   .copyWith(dragDevices: {
//                                                 PointerDeviceKind.touch,
//                                                 PointerDeviceKind.mouse,
//                                               }),
//                                               child: SingleChildScrollView(
//                                                 scrollDirection:
//                                                     Axis.horizontal,
//                                                 dragStartBehavior:
//                                                     DragStartBehavior.start,
//                                                 child: Row(
//                                                   children: [
//                                                     Container(
//                                                       width: (Responsive
//                                                               .isDesktop(
//                                                                   context))
//                                                           ? MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width *
//                                                               0.85
//                                                           : 800,
//                                                       child: StreamBuilder(
//                                                           stream:
//                                                               Stream.periodic(
//                                                                   const Duration(
//                                                                       seconds:
//                                                                           0)),
//                                                           builder: (context,
//                                                               snapshot) {
//                                                             return Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Text(
//                                                                       'ทั้งหมด : ${userModels.length} คน',
//                                                                       style: TextStyle(
//                                                                           color: AdminScafScreen_Color
//                                                                               .Colors_Text1_,
//                                                                           fontWeight: FontWeight
//                                                                               .bold,
//                                                                           fontFamily:
//                                                                               FontWeight_.Fonts_T),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                                 Container(
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     color: AppbackgroundColor
//                                                                         .TiTile_Colors,
//                                                                     borderRadius:
//                                                                         BorderRadius
//                                                                             .only(
//                                                                       topLeft: Radius
//                                                                           .circular(
//                                                                               10),
//                                                                       topRight:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       bottomLeft:
//                                                                           Radius.circular(
//                                                                               0),
//                                                                       bottomRight:
//                                                                           Radius.circular(
//                                                                               0),
//                                                                     ),
//                                                                     // border: Border.all(
//                                                                     //     color: Colors.grey, width: 1),
//                                                                   ),
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                               .all(
//                                                                           8.0),
//                                                                   child: Row(
//                                                                     children: const [
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           '...',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           'Email',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           'ชื่อ',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           'ตำแหน่ง',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 1,
//                                                                         child:
//                                                                             Text(
//                                                                           'เวลาอัพเดตล่าสุด',
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                           style: TextStyle(
//                                                                               color: AdminScafScreen_Color.Colors_Text1_,
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontFamily: FontWeight_.Fonts_T),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                     height: MediaQuery.of(context)
//                                                                             .size
//                                                                             .height *
//                                                                         0.4,
//                                                                     width: (Responsive.isDesktop(
//                                                                             context))
//                                                                         ? MediaQuery.of(context).size.width *
//                                                                             0.85
//                                                                         : 800,
//                                                                     child: ListView.builder(
//                                                                         padding: const EdgeInsets.all(8),
//                                                                         itemCount: userModels.length,
//                                                                         itemBuilder: (BuildContext context, int index) {
//                                                                           String
//                                                                               email =
//                                                                               '${userModels[index].email}';
//                                                                           int emailLength =
//                                                                               email.length;
//                                                                           String
//                                                                               firstTwoCharacters =
//                                                                               email.substring(0, 2);
//                                                                           String
//                                                                               lastFourCharacters =
//                                                                               email.substring(emailLength - 4);
//                                                                           String
//                                                                               censoredEmail =
//                                                                               '$firstTwoCharacters${'*' * (emailLength - 6)}$lastFourCharacters';

//                                                                           String
//                                                                               connected_ =
//                                                                               '${userModels[index].connected}';

//                                                                           DateTime
//                                                                               connectedTime =
//                                                                               DateTime.parse(connected_);

//                                                                           DateTime
//                                                                               currentTime =
//                                                                               DateTime.now();

//                                                                           Duration
//                                                                               difference =
//                                                                               currentTime.difference(connectedTime);

//                                                                           int minutesPassed =
//                                                                               difference.inMinutes;
//                                                                           return Container(
//                                                                             padding:
//                                                                                 const EdgeInsets.all(8),
//                                                                             child:
//                                                                                 Row(
//                                                                               children: [
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     '${index + 1}',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     '${censoredEmail} ',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     '${userModels[index].fname} ${userModels[index].lname}',
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Text(
//                                                                                     '${userModels[index].position}',
//                                                                                     textAlign: TextAlign.center,
//                                                                                     maxLines: 2,
//                                                                                     style: TextStyle(
//                                                                                         color: AdminScafScreen_Color.Colors_Text1_,
//                                                                                         // fontWeight: FontWeight.bold,
//                                                                                         fontFamily: Font_.Fonts_T),
//                                                                                   ),
//                                                                                 ),
//                                                                                 Expanded(
//                                                                                   flex: 1,
//                                                                                   child: Row(
//                                                                                     children: [
//                                                                                       Expanded(flex: 1, child: Icon((minutesPassed > 1) ? Icons.motion_photos_off_rounded : Icons.motion_photos_on_rounded, color: (minutesPassed > 1) ? Colors.red : Colors.green)
//                                                                                           // Text(
//                                                                                           //   '🟢',
//                                                                                           //   maxLines: 2,
//                                                                                           //   textAlign: TextAlign.end,
//                                                                                           //   style: TextStyle(color: (minutesPassed > 1) ? Colors.red : Colors.green, fontFamily: Font_.Fonts_T),
//                                                                                           // )
//                                                                                           ),
//                                                                                       Expanded(
//                                                                                         flex: 2,
//                                                                                         child: Text(
//                                                                                           (minutesPassed > 1) ? 'ใช้งานเมื่อ $minutesPassed นาทีที่แล้ว' : ' ${userModels[index].connected}',
//                                                                                           textAlign: TextAlign.center,
//                                                                                           maxLines: 2,
//                                                                                           style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontFamily: Font_.Fonts_T),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ],
//                                                                                   ),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           );
//                                                                         })),
//                                                               ],
//                                                             );
//                                                           }),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                             actions: <Widget>[
//                                               Column(
//                                                 children: [
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Align(
//                                                     alignment:
//                                                         Alignment.centerLeft,
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               2.0),
//                                                       child: RichText(
//                                                         text: const TextSpan(
//                                                           text: '**หมายเหตุ : ',
//                                                           style: TextStyle(
//                                                               color: AdminScafScreen_Color
//                                                                   .Colors_Text1_,
//                                                               fontFamily:
//                                                                   FontWeight_
//                                                                       .Fonts_T),
//                                                           children: <TextSpan>[
//                                                             TextSpan(
//                                                               text: ' สีเขียว ',
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .green,
//                                                                   fontFamily:
//                                                                       FontWeight_
//                                                                           .Fonts_T),
//                                                             ),
//                                                             TextSpan(
//                                                               text:
//                                                                   ' กำลังใช้งาน (ไม่เกิน 1 นาที) ,',
//                                                               style: TextStyle(
//                                                                   color: AdminScafScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T),
//                                                             ),
//                                                             TextSpan(
//                                                               text: ' สีแดง ',
//                                                               style: TextStyle(
//                                                                   color: Colors
//                                                                       .red,
//                                                                   fontFamily:
//                                                                       FontWeight_
//                                                                           .Fonts_T),
//                                                             ),
//                                                             TextSpan(
//                                                               text:
//                                                                   ' ใช้งานล่าสุด (ไม่เกิน 15 นาที)',
//                                                               style: TextStyle(
//                                                                   color: AdminScafScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const Divider(
//                                                     color: Colors.grey,
//                                                     height: 4.0,
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(
//                                                             8.0),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment.end,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Container(
//                                                                 width: 100,
//                                                                 decoration:
//                                                                     const BoxDecoration(
//                                                                   color: Colors
//                                                                       .black,
//                                                                   borderRadius: BorderRadius.only(
//                                                                       topLeft:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       topRight:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       bottomLeft:
//                                                                           Radius.circular(
//                                                                               10),
//                                                                       bottomRight:
//                                                                           Radius.circular(
//                                                                               10)),
//                                                                 ),
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .all(
//                                                                         8.0),
//                                                                 child:
//                                                                     TextButton(
//                                                                   onPressed: () =>
//                                                                       Navigator.pop(
//                                                                           context,
//                                                                           'OK'),
//                                                                   child:
//                                                                       const Text(
//                                                                     'ปิด',
//                                                                     style: TextStyle(
//                                                                         color: Colors
//                                                                             .white,
//                                                                         fontWeight:
//                                                                             FontWeight
//                                                                                 .bold,
//                                                                         fontFamily:
//                                                                             FontWeight_.Fonts_T),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                 child: Stack(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.white54,
//                                           borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(20),
//                                               topRight: Radius.circular(20),
//                                               bottomLeft: Radius.circular(20),
//                                               bottomRight: Radius.circular(20)),
//                                         ),
//                                         padding: const EdgeInsets.all(6.0),
//                                         child: Icon(
//                                           Icons.people,
//                                           color: Colors.red,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                         top: 0,
//                                         left: 0,
//                                         child: Container(
//                                           // decoration: const BoxDecoration(
//                                           //   color: Colors.white,
//                                           //   borderRadius: BorderRadius.only(
//                                           //       topLeft: Radius.circular(20),
//                                           //       topRight: Radius.circular(20),
//                                           //       bottomLeft: Radius.circular(20),
//                                           //       bottomRight: Radius.circular(20)),
//                                           // ),
//                                           padding: const EdgeInsets.all(2.0),
//                                           child: Text(
//                                             renTal_name == null
//                                                 ? '0'
//                                                 : '${userModels.length}',
//                                             // '${userModels.length}***/$connected_Minutes/$ser_user/$email_user',
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.blue,
//                                                 fontFamily:
//                                                     FontWeight_.Fonts_T),
//                                           ),
//                                         ))
//                                   ],
//                                 )),
//                           );
//                         }),
//                     Padding(
//                       padding: EdgeInsets.all(4.0),
//                       // ✅ เอา StreamBuilder(0s) ออก เพราะชื่อไม่เคยเปลี่ยนระหว่าง session
//                       child: Text(
//                         'Hi $fname_user ..',
//                         style: TextStyle(
//                             color: AdminScafScreen_Color.Colors_Text1_,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             fontFamily: Font_.Fonts_T),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.lightGreen[200]!.withOpacity(0.7),
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(0),
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(0)),
//                       ),
//                       padding: const EdgeInsets.all(2.0),
//                       child: InkWell(
//                         onTap: () {
//                           showDialog<String>(
//                             context: context,
//                             builder: (BuildContext context) => AlertDialog(
//                               shape: const RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(20.0))),
//                               title: Center(
//                                 child: Translate.TranslateAndSetText(
//                                     'ออกจากระบบ',
//                                     AdminScafScreen_Color.Colors_Text1_,
//                                     TextAlign.center,
//                                     FontWeight.bold,
//                                     FontWeight_.Fonts_T,
//                                     14,
//                                     1),
//                               ),
//                               actions: <Widget>[
//                                 Column(
//                                   children: [
//                                     const SizedBox(
//                                       height: 5.0,
//                                     ),
//                                     const Divider(
//                                       color: Colors.grey,
//                                       height: 4.0,
//                                     ),
//                                     const SizedBox(
//                                       height: 5.0,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Container(
//                                               width: 100,
//                                               decoration: const BoxDecoration(
//                                                 color: Colors.green,
//                                                 borderRadius: BorderRadius.only(
//                                                     topLeft:
//                                                         Radius.circular(10),
//                                                     topRight:
//                                                         Radius.circular(10),
//                                                     bottomLeft:
//                                                         Radius.circular(10),
//                                                     bottomRight:
//                                                         Radius.circular(10)),
//                                               ),
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: TextButton(
//                                                 onPressed: (renTal_user
//                                                                 .toString() ==
//                                                             '50' ||
//                                                         renTal_user
//                                                                 .toString() ==
//                                                             '139')
//                                                     ? () async {
//                                                         AuthService.logout();
//                                                         SharedPreferences
//                                                             preferences =
//                                                             await SharedPreferences
//                                                                 .getInstance();
//                                                         preferences.clear();

//                                                         MaterialPageRoute
//                                                             route =
//                                                             MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               LoginPage(),
//                                                         );
//                                                         Navigator
//                                                             .pushAndRemoveUntil(
//                                                                 context, route,
//                                                                 (route) {
//                                                           return false;
//                                                         });
//                                                       }
//                                                     : () async {
//                                                         deall_Trans_select();
//                                                         SharedPreferences
//                                                             preferences =
//                                                             await SharedPreferences
//                                                                 .getInstance();
//                                                         var ser = preferences
//                                                             .getString('ser');
//                                                         var on = '0';
//                                                         String url =
//                                                             '${MyConstant().domain}/U_user_onoff.php?isAdd=true&ser=$ser&on=$on';

//                                                         try {
//                                                           var response =
//                                                               await httpClient
//                                                                   .get(
//                                                                       Uri.parse(
//                                                                           url));

//                                                           var result = json
//                                                               .decode(response
//                                                                   .body);
//                                                           // print(result);
//                                                           if (result
//                                                                   .toString() ==
//                                                               'true') {
//                                                             SharedPreferences
//                                                                 preferences =
//                                                                 await SharedPreferences
//                                                                     .getInstance();
//                                                             preferences.clear();
//                                                             routToService(
//                                                                 SignInScreen());
//                                                           } else {
//                                                             ScaffoldMessenger
//                                                                     .of(context)
//                                                                 .showSnackBar(
//                                                               SnackBar(
//                                                                   content: Text(
//                                                                       '(ผิดพลาด)')),
//                                                             );
//                                                           }
//                                                         } catch (e) {}
//                                                       },
//                                                 child: Translate
//                                                     .TranslateAndSetText(
//                                                         'ยืนยัน',
//                                                         Colors.white,
//                                                         TextAlign.center,
//                                                         FontWeight.bold,
//                                                         FontWeight_.Fonts_T,
//                                                         14,
//                                                         1),
//                                               ),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                   width: 100,
//                                                   decoration:
//                                                       const BoxDecoration(
//                                                     color: Colors.redAccent,
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                             topLeft:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             bottomLeft:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             bottomRight:
//                                                                 Radius.circular(
//                                                                     10)),
//                                                   ),
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: TextButton(
//                                                     onPressed: () =>
//                                                         Navigator.pop(
//                                                             context, 'OK'),
//                                                     child: Translate
//                                                         .TranslateAndSetText(
//                                                             'ยกเลิก',
//                                                             Colors.white,
//                                                             TextAlign.center,
//                                                             FontWeight.bold,
//                                                             FontWeight_.Fonts_T,
//                                                             14,
//                                                             1),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: const Padding(
//                           padding: EdgeInsets.all(4.0),
//                           child: Icon(Icons.logout_rounded),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//         elevation: 0,
//         backgroundColor: AppBarColors.hexColor,
//       ),
//       drawer: SideBar(
//         textStyle:
//             const TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
//         iconColor: Colors.white,
//         backgroundColor: AppBarColors.ABar_Colors_tab,
//         items: [
//           for (int i = 0; i < perMissionModels.length; i++)
//             if (int.parse(perMissionModels[i].ser!) <= 3)
//               AdminMenuItem(
//                 title:
//                     '${translate_menu[i]}', //perMissionModels[i].perm!.trim(),
//                 route: '/${perMissionModels[i].perm!.trim()}',
//                 icon: IconData(
//                   int.parse(
//                     '${perMissionModels[i].icon}',
//                   ),
//                   fontFamily: 'MaterialIcons',
//                 ),
//               ),
//           AdminMenuItem(
//             title: '${more_menu}', // 'อื่นๆ',
//             // icon: Icons.more_horiz,
//             icon: IconData(
//               int.parse(
//                 '0xf8d9',
//               ),
//               fontFamily: 'MaterialIcons',
//             ),
//             children: [
//               for (int i = 0; i < perMissionModels.length; i++)
//                 if (int.parse(perMissionModels[i].ser!) > 3)
//                   AdminMenuItem(
//                     title:
//                         '${translate_menu[i]}', //perMissionModels[i].perm!.trim(),
//                     route: '/${perMissionModels[i].perm!.trim()}',
//                     icon: IconData(
//                       int.parse(
//                         '${perMissionModels[i].icon}',
//                       ),
//                       fontFamily: 'MaterialIcons',
//                     ),
//                   ),
//             ],
//           ),
//         ],
//         selectedRoute: '/',
//         onSelected: (item) async {
//           SharedPreferences preferences = await SharedPreferences.getInstance();
//           if (preferences.getString('zonesName').toString() == 'null') {
//             // ✅ แยก preferences I/O ออกนอก setState
//             await preferences.setString('zoneSer', '0');
//             await preferences.setString('zonesName', 'ทั้งหมด');
//           }
//           for (int i = 0; i < perMissionModels.length; i++) {
//             if (item.route == '/${perMissionModels[i].perm!.trim()}') {
//               if (renTal_user != null) {
//                 SharedPreferences preferences =
//                     await SharedPreferences.getInstance();
//                 preferences.setString(
//                     'route', perMissionModels[i].perm!.trim().toString());
//                 setState(() {
//                   preferences.setString('Ser_Typepay', '0');
//                   Value_Route = perMissionModels[i].perm!.trim();
//                   // print(Value_Route);
//                   Navigator.pop(context);
//                 });
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Translate.TranslateAndSetText(
//                         'กรุณาเลือกสถานที่ของท่านเพื่อเรียกดูข้อมูล',
//                         Colors.black,
//                         TextAlign.center,
//                         FontWeight.bold,
//                         FontWeight_.Fonts_T,
//                         14,
//                         1),
//                   ),
//                 );
//               }
//               read_GC_rentalColor();
//             }
//           }
//           // print(Value_Route);
//         },
//         header: Container(
//           color: AppBarColors.ABar_Colors_tab,
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4.0),
//                 decoration: BoxDecoration(
//                   color: AppBarColors.ABar_Colors_tab,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(0),
//                       topRight: Radius.circular(0),
//                       bottomLeft: Radius.circular(0),
//                       bottomRight: Radius.circular(0)),
//                 ),
//                 child: const Image(
//                   image: AssetImage('images/chaoperty_dark.png'),
//                 ),
//               ),
//               InkWell(
//                 onTap: () async {
//                   setState(() {
//                     Value_Route = 'หน้าหลัก';
//                     Navigator.pop(context);
//                   });
//                   SharedPreferences preferences =
//                       await SharedPreferences.getInstance();
//                   preferences.setString('route', 'หน้าหลัก');
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     height: 50,
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                           bottomLeft: Radius.circular(20),
//                           bottomRight: Radius.circular(20)),
//                     ),
//                     child: Center(
//                       child: Translate.TranslateAndSetText(
//                           'เมนูหลัก',
//                           Colors.black,
//                           TextAlign.center,
//                           FontWeight.bold,
//                           FontWeight_.Fonts_T,
//                           14,
//                           1),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         footer: Container(
//           // height: 50,
//           width: double.infinity,
//           color: AppBarColors.ABar_Colors_tab,
//           child: Container(
//             // height: 40,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(5),
//                   topRight: Radius.circular(5),
//                   bottomLeft: Radius.circular(0),
//                   bottomRight: Radius.circular(0)),
//             ),
//             child: Column(
//               children: [
//                 // (ren_ser.toString() == '114')
//                 //     ? Padding(
//                 //         padding: EdgeInsets.all(4.0),
//                 //         child: InkWell(
//                 //           onTap: () async {
//                 //             Navigator.push(
//                 //               context,
//                 //               MaterialPageRoute(
//                 //                 builder: (context) => WebView_NainaSetting(),
//                 //               ),
//                 //             );
//                 //           },
//                 //           child: Container(
//                 //             decoration: BoxDecoration(
//                 //               color: AppBarColors.hexColor.withOpacity(0.9),
//                 //               borderRadius: BorderRadius.only(
//                 //                   topLeft: Radius.circular(10),
//                 //                   topRight: Radius.circular(10),
//                 //                   bottomLeft: Radius.circular(10),
//                 //                   bottomRight: Radius.circular(10)),
//                 //             ),
//                 //             padding: EdgeInsets.all(4.0),
//                 //             child: Row(
//                 //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 //               children: const [
//                 //                 Icon(
//                 //                   Icons.hotel,
//                 //                   color: Colors.white,
//                 //                 ),
//                 //                 Text(
//                 //                   'Nainaservice',
//                 //                   maxLines: 1,
//                 //                   overflow: TextOverflow.ellipsis,
//                 //                   softWrap: false,
//                 //                   textAlign: TextAlign.center,
//                 //                   style: TextStyle(
//                 //                       color: Colors.white,
//                 //                       fontWeight: FontWeight.bold,
//                 //                       fontFamily: Font_.Fonts_T,
//                 //                       fontSize: 16.0),
//                 //                 ),
//                 //                 Text(
//                 //                   '> >',
//                 //                   maxLines: 1,
//                 //                   overflow: TextOverflow.ellipsis,
//                 //                   softWrap: false,
//                 //                   textAlign: TextAlign.center,
//                 //                   style: TextStyle(
//                 //                       color: Colors.white,
//                 //                       fontWeight: FontWeight.bold,
//                 //                       fontFamily: Font_.Fonts_T,
//                 //                       fontSize: 16.0),
//                 //                 ),
//                 //               ],
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       )
//                 //     :
//                 renTal_lavel! <= 3
//                     ? SizedBox()
//                     : passcode == null
//                         ? SizedBox()
//                         : Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Text(
//                                 '$passcode',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 softWrap: false,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: Colors.orange.shade900,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                     fontSize: 20.0),
//                               ),
//                             ),
//                           ),
//                 // renTal_lavel! <= 1
//                 //     ? SizedBox()
//                 //     : passcode == null
//                 //         ? SizedBox()
//                 //         : Center(
//                 //             child: Padding(
//                 //               padding: EdgeInsets.all(8.0),
//                 //               child: Text(
//                 //                 '$passcode',
//                 //                 maxLines: 1,
//                 //                 overflow: TextOverflow.ellipsis,
//                 //                 softWrap: false,
//                 //                 textAlign: TextAlign.center,
//                 //                 style: TextStyle(
//                 //                     color: Colors.orange.shade900,
//                 //                     fontWeight: FontWeight.bold,
//                 //                     fontFamily: Font_.Fonts_T,
//                 //                     fontSize: 20.0),
//                 //               ),
//                 //             ),
//                 //           ),
//                 Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       '© 2023  Dzentric Co.,Ltd. All Rights Reserved',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       softWrap: false,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: AdminScafScreen_Color.Colors_Text2_,
//                           // fontWeight: FontWeight.bold,
//                           fontFamily: Font_.Fonts_T,
//                           fontSize: 10.0),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: (Value_Route == 'หน้าหลัก')
//           ? const HomeScreen()
//           : (Value_Route == 'พื้นที่เช่า')
//               ? const ChaoAreaScreen()
//               : (Value_Route == 'ผู้เช่า')
//                   ? const PeopleChaoScreen()
//                   : (Value_Route == 'บัญชี')
//                       ? const AccountScreen()
//                       : (Value_Route == 'จัดการ')
//                           ? const ManageScreen()
//                           : (Value_Route == 'รายงาน')
//                               ? ReportScreen()
//                               : (Value_Route == 'ทะเบียน')
//                                   ? const BureauScreen()
//                                   : (Value_Route == 'ตั้งค่า')
//                                       ? const SettingScreen()
//                                       : (Value_Route == 'จัดการข้อมูลส่วนตัว')
//                                           ? const SettingUserScreen()
//                                           : const SettingUserScreen(),
//       // body: (Value_Route == 'หน้าหลัก')
//       //     ? const HomeScreen()
//       //     : (Value_Route == 'พื้นที่เช่า')
//       //         ? const ChaoAreaScreen()
//       //         : (Value_Route == 'ผู้เช่า')
//       //             ? const PeopleChaoScreen()
//       //             : (Value_Route == 'บัญชี')
//       //                 ? const AccountScreen()
//       //                 : (Value_Route == 'จัดการ')
//       //                     ? const ManageScreen()
//       //                     : (Value_Route == 'รายงาน' &&
//       //                             (renTal_user.toString() == '72' ||
//       //                                 renTal_user.toString() == '92' ||
//       //                                 renTal_user.toString() == '93' ||
//       //                                 renTal_user.toString() == '94'))
//       //                         ? const Report_Ortor_Screen()
//       //                         : (Value_Route == 'รายงาน' &&
//       //                                 renTal_user.toString() == '65')
//       //                             ? const Report_cm_Screen()
//       //                             : (Value_Route == 'รายงาน' &&
//       //                                     renTal_user.toString() != '65')
//       //                                 ? ReportScreen()
//       //                                 : (Value_Route == 'ทะเบียน')
//       //                                     ? const BureauScreen()
//       //                                     : (Value_Route == 'ตั้งค่า')
//       //                                         ? const SettingScreen()
//       //                                         : (Value_Route ==
//       //                                                 'จัดการข้อมูลส่วนตัว')
//       //                                             ? const Accessrights()
//       //                                             : const Accessrights(),
//     );
//   }

//   void routToService(Widget myWidget) {
//     MaterialPageRoute route = MaterialPageRoute(
//       builder: (context) => myWidget,
//     );
//     Navigator.pushAndRemoveUntil(context, route, (route) {
//       return false;
//     });
//   }

//   /////////------------------------------------------->

//   Future<Null> read_GC_rentalColor() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');

//     String url =
//         '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

//     try {
//       var response = await httpClient.get(Uri.parse(url));

//       var result = json.decode(response.body);

//       if (result != null) {
//         for (var map in result) {
//           RenTalModel renTalModels = RenTalModel.fromJson(map);
//           dynamic colorsren = renTalModels.colors_ren;
//           dynamic colorsren_sub = renTalModels.colors_subren;
//           New_Appbar_color(colorsren, colorsren_sub);
//         }
//       } else {}
//     } catch (e) {}
//   }

// /////////------------------------------------------->
//   Future<Null> New_Appbar_color(colors_ren, colorsren_sub) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     dynamic colorsren = colors_ren;
//     var Check_New_color = preferences.getString('Check_New_color');
//     var Check_New_colorsub = preferences.getString('Check_New_colorsub');

//     if (Check_New_color.toString() == colorsren.toString() &&
//         Check_New_colorsub.toString() == colorsren_sub.toString()) {
//       // print(Check_New_color.toString());
//       // print(colorsren.toString());
//     } else {
//       if (renTalModels.isNotEmpty) {
//         if (colorsren is String) {
//           // ✅ รวม setState 2 ครั้งเป็น 1 ครั้ง + ย้าย preferences I/O ออกนอก setState
//           Color? newHex;
//           Color? newTab;

//           if (colorsren != null &&
//               colorsren.toString() != '' &&
//               colorsren.toString() != 'null') {
//             newHex = Color(int.parse(colorsren));
//             await preferences.setString('Check_New_color', '$colorsren');
//           }
//           if (colorsren_sub != null &&
//               colorsren_sub.toString() != '' &&
//               colorsren_sub.toString() != 'null') {
//             newTab = Color(int.parse(colorsren_sub));
//             await preferences.setString('Check_New_colorsub', '$colorsren_sub');
//           }
//           if (!mounted) return;
//           setState(() {
//             if (newHex != null) AppBarColors.hexColor = newHex;
//             if (newTab != null) AppBarColors.ABar_Colors_tab = newTab;
//           });
//         }
//       }
//       if (!mounted) return;
//       String? _route = preferences.getString('route');
//       MaterialPageRoute materialPageRoute = MaterialPageRoute(
//           builder: (BuildContext context) => AdminScafScreen(route: _route));
//       Navigator.pushAndRemoveUntil(
//           context, materialPageRoute, (route) => false);
//     }
//   }

// /////////------------------------------------------->

//   // List<ConnecAminModel> ConnecAmins = [];
//   final Formbecause_ = TextEditingController();

//   Widget _UserPickerDialog({
//     required BuildContext context,
//     required String namemake,
//     required List<ConnecAminModel> userModels,
//     required Function(ConnecAminModel picked) onPicked,
//   }) {
//     bool _isDeleting = false; // ไว้ประกาศบน state ที่ครอบปุ่ม (กันกดรัว)
//     // ===== helpers (local) =====
//     DateTime? safeParse(String s) {
//       s = s.trim();
//       if (s.isEmpty || s.startsWith('0000')) return null;
//       final t = s.contains('T') ? s : s.replaceFirst(' ', 'T');
//       return DateTime.tryParse(t);
//     }

//     int? minutesSince(DateTime? dt) {
//       if (dt == null) return null;
//       return DateTime.now().difference(dt).inMinutes;
//     }

//     Map<String, dynamic> statusOf(int? minutes, String raw) {
//       if (minutes == null)
//         return {'text': 'ไม่พบข้อมูลเวลา', 'color': Colors.grey};
//       if (minutes <= 1)
//         return {'text': 'ออนไลน์ภายใน 1 นาที', 'color': Colors.green};
//       if (minutes <= 15)
//         return {
//           'text': 'ใช้งานเมื่อ $minutes นาทีที่แล้ว',
//           'color': Colors.orange
//         };
//       return {'text': raw, 'color': Colors.grey};
//     }

//     String _initials(String? f, String? l) {
//       final a = (f ?? '').trim();
//       final b = (l ?? '').trim();
//       final aa = a.isNotEmpty ? a.characters.first : '';
//       final bb = b.isNotEmpty ? b.characters.first : '';
//       return (aa + bb).toUpperCase();
//     }

//     // ===== state ภายใน dialog =====
//     final TextEditingController _searchCtrl = TextEditingController();
//     List<ConnecAminModel> filtered = List.of(userModels);

//     void _applyFilter(String q) {
//       final key = q.trim().toLowerCase();
//       if (key.isEmpty) {
//         filtered = List.of(userModels);
//         return;
//       }
//       filtered = userModels.where((u) {
//         final full =
//             ('${u.fname ?? ''} ${u.lname ?? ''} ${u.nameUser ?? ''} ${u.email ?? ''}')
//                 .toLowerCase();
//         return full.contains(key);
//       }).toList();
//     }

//     // เริ่มแรกไม่มีตัวกรอง
//     _applyFilter('');

//     return StatefulBuilder(
//       builder: (ctx, setState) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           backgroundColor: Colors.white,
//           titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//           contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
//           actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//           title: Row(
//             children: [
//               Container(
//                 height: 36,
//                 width: 36,
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.people_alt_rounded, color: Colors.blue),
//               ),
//               const SizedBox(width: 10),
//               const Expanded(
//                 child: Text(
//                   'Admin',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.black87,
//                     fontFamily: Font_.Fonts_T,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () => Navigator.pop(context),
//                 borderRadius: BorderRadius.circular(20),
//                 child: const Padding(
//                   padding: EdgeInsets.all(6.0),
//                   child: Icon(Icons.close, color: Colors.red),
//                 ),
//               ),
//             ],
//           ),
//           content: SizedBox(
//             width: 440,
//             height: MediaQuery.of(ctx).size.height * 0.75,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Legend
//                 Row(
//                   children: [
//                     Row(children: [
//                       Container(
//                           width: 10,
//                           height: 10,
//                           decoration: const BoxDecoration(
//                               color: Colors.green, shape: BoxShape.circle)),
//                       const SizedBox(width: 6),
//                       const Text('ภายใน 1 นาที',
//                           style: TextStyle(fontSize: 12)),
//                     ]),
//                     const SizedBox(width: 12),
//                     Row(children: [
//                       Container(
//                           width: 10,
//                           height: 10,
//                           decoration: const BoxDecoration(
//                               color: Colors.orange, shape: BoxShape.circle)),
//                       const SizedBox(width: 6),
//                       const Text('ภายใน 15 นาที',
//                           style: TextStyle(fontSize: 12)),
//                     ]),
//                     const SizedBox(width: 12),
//                     Row(children: [
//                       Container(
//                           width: 10,
//                           height: 10,
//                           decoration: const BoxDecoration(
//                               color: Colors.grey, shape: BoxShape.circle)),
//                       const SizedBox(width: 6),
//                       const Text('ออฟไลน์', style: TextStyle(fontSize: 12)),
//                     ]),
//                   ],
//                 ),
//                 const SizedBox(height: 12),

//                 // Search
//                 TextField(
//                   controller: _searchCtrl,
//                   onChanged: (text) => setState(() {
//                     _applyFilter(text);
//                   }),
//                   decoration: InputDecoration(
//                     hintText: 'ค้นหา: ชื่อ/นามสกุล/อีเมล…',
//                     prefixIcon: const Icon(Icons.search, color: Colors.black54),
//                     isDense: true,
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 10),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Colors.black12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Colors.black12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Colors.black54),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // Result info
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'ผลลัพธ์ ${filtered.length} รายการ',
//                     style: const TextStyle(
//                       fontSize: 12.5,
//                       color: Colors.black54,
//                       fontFamily: Font_.Fonts_T,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // List
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                       maxHeight: MediaQuery.of(ctx).size.height * 0.6),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: const Color(0xFFEFEFEF)),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: filtered.isEmpty
//                           ? Container(
//                               height: 120,
//                               alignment: Alignment.center,
//                               child: const Text(
//                                 'ไม่พบรายชื่อที่ค้นหา',
//                                 style: TextStyle(
//                                   color: Colors.black45,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             )
//                           : ListView.separated(
//                               shrinkWrap: true,
//                               itemCount: filtered.length,
//                               separatorBuilder: (_, __) => const Divider(
//                                   height: 1, color: Color(0xFFF2F2F2)),
//                               itemBuilder: (context, index) {
//                                 final u = filtered[index];
//                                 final full =
//                                     ('${u.fname ?? ''} ${u.lname ?? ''}')
//                                         .trim();
//                                 final isCurrent =
//                                     full.isNotEmpty && full == namemake;

//                                 final email = u.email ?? '-';
//                                 final name = (u.nameUser ?? full).trim();
//                                 final lastStr = (u.connected ?? '').trim();
//                                 final lastAt = safeParse(lastStr);
//                                 final minutes = minutesSince(lastAt);
//                                 final st = statusOf(minutes, lastStr);

//                                 return InkWell(
//                                   onTap: _isDeleting
//                                       ? null
//                                       : (u.data!.length < 1)
//                                           ? null
//                                           : () async {
//                                               // 1) ยืนยันก่อน
//                                               final ok = await showDialog<bool>(
//                                                     context: context,
//                                                     builder: (context) =>
//                                                         AlertDialog(
//                                                       shape:
//                                                           const RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius.all(
//                                                                 Radius.circular(
//                                                                     8)),
//                                                       ),
//                                                       title: const Text(
//                                                           'ลบข้อมูลที่เลือกไว้'),
//                                                       content: SizedBox(
//                                                         height: 70,
//                                                         child: Column(
//                                                           children: [
//                                                             Row(
//                                                               children: [
//                                                                 CircleAvatar(
//                                                                   radius: 18,
//                                                                   backgroundColor: (isCurrent
//                                                                           ? Colors
//                                                                               .green
//                                                                           : Colors
//                                                                               .blue)
//                                                                       .withOpacity(
//                                                                           0.12),
//                                                                   child: Text(
//                                                                     _initials(
//                                                                         u.fname,
//                                                                         u.lname),
//                                                                     style:
//                                                                         TextStyle(
//                                                                       color: isCurrent
//                                                                           ? Colors
//                                                                               .green
//                                                                           : Colors
//                                                                               .blue,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w800,
//                                                                       fontSize:
//                                                                           12,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     width: 12),
//                                                                 Expanded(
//                                                                   child: Column(
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       Row(
//                                                                         children: [
//                                                                           Expanded(
//                                                                             child:
//                                                                                 Text(
//                                                                               name.isEmpty ? '-' : name,
//                                                                               maxLines: 1,
//                                                                               overflow: TextOverflow.ellipsis,
//                                                                               style: const TextStyle(
//                                                                                 fontSize: 15,
//                                                                                 color: Colors.black87,
//                                                                                 fontWeight: FontWeight.w700,
//                                                                                 fontFamily: Font_.Fonts_T,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       ),
//                                                                       if (email
//                                                                           .isNotEmpty)
//                                                                         Padding(
//                                                                           padding:
//                                                                               const EdgeInsets.only(top: 2.5),
//                                                                           child:
//                                                                               Row(
//                                                                             children: [
//                                                                               const Icon(Icons.mail_outline, size: 14, color: Colors.black38),
//                                                                               const SizedBox(width: 4),
//                                                                               Expanded(
//                                                                                 child: Text(
//                                                                                   email,
//                                                                                   maxLines: 1,
//                                                                                   overflow: TextOverflow.ellipsis,
//                                                                                   style: const TextStyle(
//                                                                                     fontSize: 12,
//                                                                                     color: Colors.black54,
//                                                                                     fontFamily: Font_.Fonts_T,
//                                                                                   ),
//                                                                                 ),
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                       actions: [
//                                                         TextButton(
//                                                           onPressed: () =>
//                                                               Navigator.pop(
//                                                                   context,
//                                                                   false),
//                                                           child: const Text(
//                                                               'ยกเลิก'),
//                                                         ),
//                                                         ElevatedButton(
//                                                           onPressed: () =>
//                                                               Navigator.pop(
//                                                                   context,
//                                                                   true),
//                                                           child:
//                                                               const Text('ลบ'),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ) ??
//                                                   false;

//                                               if (!ok) return;

//                                               // 2) เริ่มลบ (กันกดรัว)
//                                               setState(
//                                                   () => _isDeleting = true);

//                                               try {
//                                                 final prefs =
//                                                     await SharedPreferences
//                                                         .getInstance();
//                                                 final ren = prefs
//                                                     .getString('renTalSer');

//                                                 if (ren == null ||
//                                                     ren.isEmpty) {
//                                                   if (!context.mounted) return;
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(
//                                                     const SnackBar(
//                                                         content: Text(
//                                                             'ไม่พบค่าเช่า (renTalSer)')),
//                                                   );
//                                                   return;
//                                                 }

//                                                 // ✅ เรียก DELETE ที่ถูกต้อง: isAdd=delete + ใส่ user
//                                                 final uri = Uri.parse(
//                                                         '${MyConstant().domain}/Connected_AminSelect.php')
//                                                     .replace(queryParameters: {
//                                                   'isAdd': 'delete',
//                                                   'ren': ren,
//                                                   'user': u.user ??
//                                                       '', // ค่าว่าง "" ก็ได้ ตามที่ PHP รองรับ
//                                                 });
//                                                 // print('DELETE $uri');

//                                                 final resp = await httpClient
//                                                     .delete(uri)
//                                                     .timeout(const Duration(
//                                                         seconds: 15));

//                                                 if (resp.statusCode == 200) {
//                                                   // ✅ แกะ JSON: {"ok":true,"action":"delete","ren":"...","user":"...","deleted_rows":N,...}
//                                                   Map<String, dynamic> data;
//                                                   try {
//                                                     data = jsonDecode(resp.body)
//                                                         as Map<String, dynamic>;
//                                                   } catch (_) {
//                                                     // เผื่อฝั่ง server ส่งอย่างอื่นมา ไม่ใช่ JSON
//                                                     if (!context.mounted)
//                                                       return;
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       SnackBar(
//                                                           content: Text(
//                                                               'รูปแบบผลลัพธ์ไม่ถูกต้อง: ${resp.body}'),
//                                                           backgroundColor:
//                                                               Colors.red),
//                                                     );
//                                                     return;
//                                                   }

//                                                   final ok = data['ok'] == true;
//                                                   final deleted =
//                                                       (data['deleted_rows'] ??
//                                                               0)
//                                                           .toString();

//                                                   if (ok) {
//                                                     // สำเร็จ
//                                                     onPicked(u);
//                                                     if (!context.mounted)
//                                                       return;
//                                                     Navigator.pop(
//                                                         context); // ปิด dialog รายชื่อ
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       SnackBar(
//                                                           content: Text(
//                                                               'ลบ ${u.email ?? 'ผู้ใช้'} สำเร็จ ($deleted แถว)')),
//                                                     );
//                                                   } else {
//                                                     final err = (data[
//                                                                 'error'] ??
//                                                             data['message'] ??
//                                                             'ไม่ทราบสาเหตุ')
//                                                         .toString();
//                                                     if (!context.mounted)
//                                                       return;
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       SnackBar(
//                                                           content: Text(
//                                                               'ลบไม่สำเร็จ: $err'),
//                                                           backgroundColor:
//                                                               Colors.red),
//                                                     );
//                                                     print('ลบไม่สำเร็จ: $err');
//                                                   }
//                                                 } else {
//                                                   if (!context.mounted) return;
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(
//                                                     SnackBar(
//                                                       content: Text(
//                                                           'ลบไม่สำเร็จ [HTTP ${resp.statusCode}]'),
//                                                       backgroundColor:
//                                                           Colors.red,
//                                                     ),
//                                                   );
//                                                   print(
//                                                       'ลบไม่สำเร็จ: HTTP ${resp.statusCode} ${resp.body}');
//                                                 }
//                                               } catch (e) {
//                                                 if (!context.mounted) return;
//                                                 ScaffoldMessenger.of(context)
//                                                     .showSnackBar(
//                                                   SnackBar(
//                                                       content: Text(
//                                                           'เกิดข้อผิดพลาด: $e'),
//                                                       backgroundColor:
//                                                           Colors.red),
//                                                 );
//                                                 print('เกิดข้อผิดพลาด: $e');
//                                               } finally {
//                                                 SharedPreferences preferences =
//                                                     await SharedPreferences
//                                                         .getInstance();
//                                                 if (mounted)
//                                                   setState(() =>
//                                                       _isDeleting = false);
//                                                 String? _route = preferences
//                                                     .getString('route');
//                                                 MaterialPageRoute
//                                                     materialPageRoute =
//                                                     MaterialPageRoute(
//                                                         builder: (BuildContext
//                                                                 context) =>
//                                                             AdminScafScreen(
//                                                                 route: _route));
//                                                 Navigator.pushAndRemoveUntil(
//                                                     context,
//                                                     materialPageRoute,
//                                                     (route) => false);
//                                               }
//                                             },
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 10),
//                                     child: Row(
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 18,
//                                           backgroundColor: (isCurrent
//                                                   ? Colors.green
//                                                   : Colors.blue)
//                                               .withOpacity(0.12),
//                                           child: Text(
//                                             _initials(u.fname, u.lname),
//                                             style: TextStyle(
//                                               color: isCurrent
//                                                   ? Colors.green
//                                                   : Colors.blue,
//                                               fontWeight: FontWeight.w800,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Container(
//                                                     width: 10,
//                                                     height: 10,
//                                                     decoration: BoxDecoration(
//                                                       color: (st['color']
//                                                           as Color),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 8),
//                                                   Expanded(
//                                                     child: Text(
//                                                       name.isEmpty ? '-' : name,
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                       style: const TextStyle(
//                                                         fontSize: 15,
//                                                         color: Colors.black87,
//                                                         fontWeight:
//                                                             FontWeight.w700,
//                                                         fontFamily:
//                                                             Font_.Fonts_T,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   if (isCurrent)
//                                                     Container(
//                                                       margin:
//                                                           const EdgeInsets.only(
//                                                               left: 8),
//                                                       padding: const EdgeInsets
//                                                               .symmetric(
//                                                           horizontal: 8,
//                                                           vertical: 4),
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.green
//                                                             .withOpacity(0.08),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(999),
//                                                         border: Border.all(
//                                                             color: Colors.green
//                                                                 .withOpacity(
//                                                                     0.28)),
//                                                       ),
//                                                       child: const Text(
//                                                         'ปัจจุบัน',
//                                                         style: TextStyle(
//                                                           color: Colors.green,
//                                                           fontSize: 11.5,
//                                                           fontWeight:
//                                                               FontWeight.w700,
//                                                           fontFamily:
//                                                               Font_.Fonts_T,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                 ],
//                                               ),
//                                               if (email.isNotEmpty)
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           top: 2.5),
//                                                   child: Row(
//                                                     children: [
//                                                       const Icon(
//                                                           Icons.mail_outline,
//                                                           size: 14,
//                                                           color:
//                                                               Colors.black38),
//                                                       const SizedBox(width: 4),
//                                                       Expanded(
//                                                         child: Text(
//                                                           email,
//                                                           maxLines: 1,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 12,
//                                                             color:
//                                                                 Colors.black54,
//                                                             fontFamily:
//                                                                 Font_.Fonts_T,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       const SizedBox(width: 12),
//                                                       const Icon(Icons.list_alt,
//                                                           size: 14,
//                                                           color:
//                                                               Colors.black38),
//                                                       const SizedBox(width: 4),
//                                                       Text(
//                                                         'เลือก : ${u.data!.length}',
//                                                         style: TextStyle(
//                                                           fontSize: 12,
//                                                           color: (u.data!
//                                                                       .length >
//                                                                   0)
//                                                               ? Colors
//                                                                   .deepPurple
//                                                                   .shade700
//                                                               : Colors.black54,
//                                                           fontFamily:
//                                                               Font_.Fonts_T,
//                                                           fontWeight:
//                                                               FontWeight.w500,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         if (u.data!.length > 0)
//                                           const Icon(
//                                               Icons.chevron_right_rounded,
//                                               color: Colors.blue),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
