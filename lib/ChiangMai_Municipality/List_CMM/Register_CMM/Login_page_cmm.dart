import 'dart:convert';

import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../AdminScaffold/AdminScaffold.dart';
import '../../../Responsive/responsive.dart';
import '../../../Setting/Bill_Document_Template.dart';
import '../../../Style/Translate.dart';
import '../../../Style/colors.dart';
import '../../../router/auth_state_notifier.dart';
import '../../unity/SecurePrefs_helper.dart';
import 'AuthService.dart';
import 'SetupPage.dart';

import 'privacyIcon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String singleDeviceName = "Unknown";
  String singleDeviceNameFromModel = "Unknown";
  String deviceNames = "Unknown";
  String deviceNamesFromModel = "Unknown";

  @override
  void initState() {
    super.initState();
    initPlugin();
    // _loadSavedUsername();
  }

  // Future<void> _loadSavedUsername() async {
  //   final prefs_username = await SharedPreferences.getInstance();
  //   final saved = prefs_username.getString('saved_username') ?? '';
  //   setState(() {
  //     emailCtrl.text = saved;
  //   });
  // }

  // Future<void> _saveUsername(String username) async {
  //   final prefs_username = await SharedPreferences.getInstance();
  //   await prefs_username.setString('saved_username', username);
  // }

  Future<void> initPlugin() async {
    try {
      const model = "Device : ";
      final deviceMarketingNames = DeviceMarketingNames();
      final currentSingleDeviceName =
          await deviceMarketingNames.getSingleName();
      final currentDeviceNames = await deviceMarketingNames.getNames();
      if (!mounted) return;
      setState(() {
        singleDeviceName = currentSingleDeviceName ?? "Unknown";
        deviceNames = currentDeviceNames ?? "Unknown";
        singleDeviceNameFromModel = deviceMarketingNames.getSingleNameFromModel(
                DeviceType.android, model) ??
            "Unknown";
        deviceNamesFromModel =
            deviceMarketingNames.getNamesFromModel(DeviceType.android, model) ??
                "Unknown";
      });
    } catch (e) {
      print('initPlugin error: $e');
    }
  }

  Future<void> handleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('accepted_privacy') ?? false;

    if (!accepted) {
      final agree = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Center(
            child: const Text(
                'กรุณาอ่านและยอมรับนโยบายความเป็นส่วนตัวก่อนเข้าสู่ระบบ'),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.55,
            child: PreviewScreen_doc3(
                Url:
                    'https://chaoperties.com/privacy/Privacy_Policy_OCT20_CMM.pdf',
                title: 'Chaoperty-เช่าเพอร์ตี้'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ปฏิเสธ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ยอมรับ'),
            ),
          ],
        ),
      );

      if (agree == true) {
        await prefs.setBool('accepted_privacy', true);
      } else {
        // ❌ ไม่ยอมรับ → ห้ามเข้าสู่ระบบ
        return;
      }
    }

    // ✅ มาถึงตรงนี้คือเคยยอมรับแล้ว → ดำเนินการ login ตามปกติ
    setState(() => loading = true);
    final success = await AuthService.login(emailCtrl.text, passCtrl.text);
    setState(() => loading = false);

    if (success && mounted) {
      // ✅ GoRouter จะตรวจจับ auth state เปลี่ยน แล้ว redirect ไป /setup อัตโนมัติ
      // trigger markLoggedIn() ทันที ไม่ต้องรอ polling 1 นาที
      try {
        final notifier = Provider.of<AuthStateNotifier>(context, listen: false);
        notifier.markLoggedIn();
      } catch (_) {}
    } else {
      Dialog_error(context, 'เข้าสู่ระบบไม่สำเร็จ');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ')),
      // );
    }
  }

  Color BG_cl = Color(0xfff3f3ee);
  Color Fool_cl = Color.fromARGB(255, 141, 185, 90);
  Color Fool_cm = Color.fromARGB(255, 174, 90, 185);
  final _formKey = GlobalKey<FormState>();

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      fillColor: Colors.white.withOpacity(0.3),
      filled: true,
      prefixIcon: Icon(icon, color: Colors.black),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(width: 1, color: Colors.black),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        borderSide: BorderSide(width: 1, color: Colors.black),
      ),
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
      errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
    );
  }

// ใช้ร่วมกับ TextFormField ในฟอร์มของคุณ
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: obscure
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        validator: (value) {
          final text = (value ?? '').trim();
          if (obscure) {
            if (text.isEmpty) return 'กรุณากรอกรหัสผ่าน';
            return null;
          } else {
            // ตรวจรูปแบบอีเมลแบบง่าย
            final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(text);
            if (!isEmail) return 'รูปแบบอีเมลไม่ถูกต้อง เช่น: you@email.com';
            return null;
          }
        },
        onFieldSubmitted: !obscure
            ? null
            : (value) {
                if (_formKey.currentState!.validate()) {
                  handleLogin();
                }
              },
        cursorColor: Colors.purple[700],
        decoration: _inputDecoration(label: label, icon: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _SetupBackground(), // 👈 พื้นหลังแบบ “พาสเทลเฉียง + เส้นโค้ง” (ต่างจากหน้า Login นิดหน่อย)
          // Positioned.fill(
          //     child: ChiangMaiBackground2()), // 👈 พื้นหลังวาดด้วย Canvas
          // ---------- เนื้อหาเดิมของคุณ ----------
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // color: BG_cl, // แนะนำเอาออก/โปร่งใส เพื่อเห็นพื้นหลัง
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ===== Header Icon =====
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreviewScreen_doc3(
                                  Url:
                                      'https://chaoperties.com/privacy/Privacy_Policy_OCT20_CMM.pdf',
                                  title: 'Chaoperty-เช่าเพอร์ตี้')),
                        );
                      },
                      child: PrivacyIcon(), // 👈 แทน Icon เดิม
                    ),
                  ),
                ),

                // ===== Logo =====
                Center(
                  child: Image.asset(
                    'images/LOGO-Photoroom.webp',
                    // 'images/LOGOchao.png',
                    width: 250,
                  ),
                ),

                // ===== Form =====
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(blurRadius: 8, color: Colors.black26)
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 300,
                    maxWidth: 450,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          // "เข้าสู่ระบบ(ทดสอบ)",
                          "เข้าสู่ระบบ",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                            fontFamily: "Sarabun",
                          ),
                        ),
                        SizedBox(height: 20),
                        // Email & Password
                        _buildTextField(emailCtrl, "ชื่อผู้ใช้", Icons.person),
                        _buildTextField(passCtrl, "รหัสผ่าน", Icons.key,
                            obscure: true),
                        // _buildTextField(emailCtrl, "USERNAME", Icons.person),
                        // _buildTextField(passCtrl, "PASSWORD", Icons.key,
                        //     obscure: true),

                        SizedBox(height: 25),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 200,
                            maxWidth: 450,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 40),
                            ),
                            onPressed: handleLogin,
                            child: Center(
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Translate.TranslateAndSetText(
                                      'ยืนยัน',
                                      Colors.white,
                                      TextAlign.center,
                                      FontWeight.bold,
                                      FontWeight_.Fonts_T,
                                      (Responsive.isDesktop(context)) ? 20 : 15,
                                      1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Footer =====
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8E44AD), Color(0xFFF5B041)],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      // Center(
                      //   child: Text(
                      //       "Chaoperty ร่วมเป็นพันธมิตรกับเทศบาลนครเชียงใหม่ — สร้างสรรค์จากเชียงใหม่",
                      //       style:
                      //           TextStyle(color: Colors.white, fontSize: 12)),
                      // ),
                      Center(
                        child: Text(
                            "Chaoperty ร่วมเป็นพันธมิตรกับเทศบาลนครเชียงใหม่ — สร้างสรรค์จากเชียงใหม่ || Chaoperty works in partnership with Chiang Mai Municipality — Powered from Chiang Mai",
                            maxLines: 2,
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
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

    // Scaffold(
    //   body: Container(
    //     width: double.infinity,
    //     height: double.infinity,
    //     decoration: BoxDecoration(
    //       image: DecorationImage(
    //         image: AssetImage("images/chiangmai_bg.png"),
    //         fit: BoxFit.cover,
    //         colorFilter: ColorFilter.mode(
    //           Colors.black.withOpacity(0.15),
    //           BlendMode.darken,
    //         ),
    //       ),
    //     ),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         // ===== Header Icon =====
    //         Align(
    //           alignment: Alignment.topRight,
    //           child: Padding(
    //             padding: const EdgeInsets.all(16),
    //             child: Icon(Icons.temple_buddhist,
    //                 color: Colors.amber[700], size: 40),
    //           ),
    //         ),

    //         // ===== Logo =====
    //         Center(
    //           child: Image.asset(
    //             'images/LOGO.png',
    //             width: 250,
    //           ),
    //         ),

    //         // ===== Form =====
    //         Container(
    //           padding: EdgeInsets.all(16),
    //           margin: EdgeInsets.symmetric(vertical: 20),
    //           decoration: BoxDecoration(
    //             color: Colors.white.withOpacity(0.9),
    //             borderRadius: BorderRadius.circular(16),
    //             boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
    //           ),
    //           child: Form(
    //             key: _formKey,
    //             child: Column(
    //               children: [
    //                 Text(
    //                   "เข้าสู่ระบบ",
    //                   style: TextStyle(
    //                     fontSize: 28,
    //                     fontWeight: FontWeight.bold,
    //                     color: Colors.purple[800],
    //                     fontFamily: "Sarabun",
    //                   ),
    //                 ),
    //                 SizedBox(height: 20),
    //                 // Email & Password
    //                 _buildTextField(emailCtrl, "USERNAME", Icons.person),
    //                 _buildTextField(passCtrl, "PASSWORD", Icons.key,
    //                     obscure: true),

    //                 SizedBox(height: 25),
    //                 ElevatedButton(
    //                   style: ElevatedButton.styleFrom(
    //                     backgroundColor: Colors.purple[700],
    //                     shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(20),
    //                     ),
    //                     padding:
    //                         EdgeInsets.symmetric(vertical: 14, horizontal: 40),
    //                   ),
    //                   onPressed: handleLogin,
    //                   child: Text("เข้าสู่ระบบ",
    //                       style: TextStyle(fontSize: 18, color: Colors.white)),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),

    //         // ===== Footer =====
    //         Container(
    //           padding: EdgeInsets.all(6),
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //               colors: [Color(0xFF8E44AD), Color(0xFFF5B041)],
    //             ),
    //           ),
    //           child: Text("Chaoperty — Powered from Chiang Mai",
    //               style: TextStyle(color: Colors.white, fontSize: 12)),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    // Scaffold(
    //   // appBar: AppBar(title: const Text('เข้าสู่ระบบ')),

    //   body: Container(
    //     color: BG_cl,
    //     width: MediaQuery.of(context).size.width,
    //     height: MediaQuery.of(context).size.height,
    //     child: Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Padding(
    //                 padding: EdgeInsets.fromLTRB(4, 1, 30, 1),
    //                 child: Container(
    //                   width: 130,
    //                   height: 40,
    //                   child: Row(
    //                     children: [
    //                       Icon(
    //                         Icons.cookie,
    //                         // Icons.translate,
    //                         color: Colors.indigo[600],
    //                         size: 30,
    //                       ),
    //                       Expanded(
    //                         child: Center(
    //                           child: InkWell(
    //                             onTap: () {
    //                               Navigator.push(
    //                                 context,
    //                                 MaterialPageRoute(
    //                                     builder: (context) => PreviewScreen_doc3(
    //                                         Url:
    //                                             'https://chaoperties.com/chao_api/Awaitdownload/Privacy_Policy.pdf',
    //                                         title:
    //                                             ' เช่าเพอร์ตี้ Privacy Policy')),
    //                               );
    //                               // PreviewScreen_doc2(
    //                               // Url:
    //                               //     'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
    //                               // //'images/TP6/B1_TP60.pdf',
    //                               // title:
    //                               //     'Privacy Policy');
    //                             },
    //                             child: Translate.TranslateAndSet_TextAutoSize(
    //                               'Privacy Policy',
    //                               Colors.grey[600],
    //                               TextAlign.center,
    //                               null,
    //                               FontWeight_.Fonts_T,
    //                               10,
    //                               14,
    //                               2,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ],
    //           ),
    //           Center(
    //             child: Image(
    //               image: AssetImage('images/LOGO.png'),
    //               width: 400,
    //             ),
    //           ),
    //           Align(
    //             alignment: Alignment.center,
    //             child: Container(
    //               constraints: const BoxConstraints(
    //                 minWidth: 300,
    //                 maxWidth: 320,
    //               ),
    //               child: Form(
    //                 key: _formKey,
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     Padding(
    //                       padding: EdgeInsets.all(4.0),
    //                       child: Translate.TranslateAndSet_TextAutoSize(
    //                         'เข้าสู่ระบบ',
    //                         SinginScreen_Color.Colors_Text1_,
    //                         TextAlign.center,
    //                         FontWeight.bold,
    //                         FontWeight_.Fonts_T,
    //                         30,
    //                         60,
    //                         1,
    //                       ),
    //                       // AutoSizeText(
    //                       //     minFontSize:
    //                       //         (Responsive.isDesktop(
    //                       //                 context))
    //                       //             ? 30
    //                       //             : 20,
    //                       //     maxFontSize: 50,
    //                       //     maxLines: 1,
    //                       //     'เข้าสู่ระบบ',
    //                       //     overflow:
    //                       //         TextOverflow.ellipsis,
    //                       //     softWrap: false,
    //                       //     style: TextStyle(
    //                       //         // fontSize: 20,
    //                       //         color: SinginScreen_Color
    //                       //             .Colors_Text1_,
    //                       //         fontWeight:
    //                       //             FontWeight.bold,
    //                       //         fontFamily:
    //                       //             FontWeight_.Fonts_T)),
    //                     ),
    //                     SizedBox(
    //                       height: (Responsive.isDesktop(context)) ? 20 : 10,
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.all(8.0),
    //                       child: // Email field
    //                           TextFormField(
    //                         controller: emailCtrl,
    //                         keyboardType: TextInputType.emailAddress,
    //                         validator: (value) {
    //                           final email = value?.trim() ?? '';
    //                           if (!email.contains('@') ||
    //                               !email.contains('.')) {
    //                             return 'รูปแบบอีเมลไม่ถูกต้อง เช่น: you@email.com';
    //                           }
    //                           return null;
    //                         },
    //                         cursorColor: Colors.green,
    //                         decoration: _inputDecoration(
    //                           label: 'USERNAME',
    //                           icon: Icons.person,
    //                         ),
    //                       ),
    //                     ),
    //                     Padding(
    //                       padding: const EdgeInsets.all(8.0),
    //                       child: // Password field
    //                           TextFormField(
    //                         controller: passCtrl,
    //                         obscureText: true,
    //                         validator: (value) {
    //                           if ((value?.trim().isEmpty ?? true)) {
    //                             return 'กรุณากรอกรหัสผ่าน';
    //                           }
    //                           return null;
    //                         },
    //                         onFieldSubmitted: (value) {
    //                           if (_formKey.currentState!.validate()) {
    //                             handleLogin();
    //                           }
    //                         },
    //                         cursorColor: Colors.green,
    //                         decoration: _inputDecoration(
    //                           label: 'PASSWORD',
    //                           icon: Icons.key,
    //                         ),
    //                       ),
    //                     ),
    //                     SizedBox(
    //                       height: (Responsive.isDesktop(context)) ? 30 : 15,
    //                     ),
    //                     InkWell(
    //                       onTap: loading
    //                           ? null
    //                           : () async {

    //                               //////////----------------------------->
    //                               if (_formKey.currentState!.validate()) {
    //                                 handleLogin();
    //                               }
    //                             },
    //                       child: Container(
    //                         width: 150,
    //                         height: (Responsive.isDesktop(context)) ? 60 : 40,
    //                         decoration: BoxDecoration(
    //                           color: Fool_cl,
    //                           borderRadius: const BorderRadius.only(
    //                               topLeft: Radius.circular(20),
    //                               topRight: Radius.circular(20),
    //                               bottomLeft: Radius.circular(20),
    //                               bottomRight: Radius.circular(20)),
    //                         ),
    //                         child:
    // Center(
    //                           child: loading
    //                               ? const CircularProgressIndicator()
    //                               : Translate.TranslateAndSetText(
    //                                   'เข้าสู่ระบบ',
    //                                   Colors.white,
    //                                   TextAlign.center,
    //                                   FontWeight.bold,
    //                                   FontWeight_.Fonts_T,
    //                                   (Responsive.isDesktop(context)) ? 20 : 15,
    //                                   1),

    //                         ),
    //                       ),
    //                     ),
    //                     SizedBox(
    //                       height: (Responsive.isDesktop(context)) ? 20 : 10,
    //                     ),

    //                     SizedBox(
    //                       height: (Responsive.isDesktop(context)) ? 20 : 10,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //           Container(
    //             //   constraints: BoxConstraints(
    //             //   maxWidth: MediaQuery.of(context).size.width / 1.05,
    //             // ),
    //             width: MediaQuery.of(context).size.width,
    //             height: (Responsive.isDesktop(context)) ? 30 : 20,
    //             decoration: BoxDecoration(
    //               gradient: LinearGradient(
    //                 begin: Alignment.bottomCenter, // เริ่มจากมุมซ้ายบน
    //                 end: Alignment.bottomCenter, // สิ้นสุดที่มุมขวาล่าง
    //                 colors: [
    //                   Color.fromARGB(255, 215, 168, 221),
    //                   Color.fromARGB(255, 212, 128, 223),
    //                   Color.fromARGB(255, 174, 90, 185),
    //                 ],
    //               ),
    //               // color: Color.fromARGB(255, 174, 90, 185),
    //               borderRadius: const BorderRadius.only(
    //                   topLeft: Radius.circular(8),
    //                   topRight: Radius.circular(8),
    //                   bottomLeft: Radius.circular(0),
    //                   bottomRight: Radius.circular(0)),
    //             ),
    //           )
    //         ]),
    //   ),

    // );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    routeToService();
  }

  // final userStr =
  //       await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

  //   if (userStr != null) {
  //     try {
  //       final userJson = jsonDecode(userStr);
  //       print('📦 Raw userJson: ${jsonEncode(userJson)}');

  //       // ถ้า user อยู่ชั้นบนสุด
  //       final userJsonx = userJson;

  //       final prefs = await SharedPreferences.getInstance();
  //       prefs.setString('ser', '${userJsonx['ser'] ?? ''}');
  //       prefs.setString('position', '${userJsonx['position'] ?? ''}');
  //       prefs.setString('fname', '${userJsonx['fname'] ?? ''}');
  //       prefs.setString('lname', '${userJsonx['lname'] ?? ''}');
  //       prefs.setString('email', '${userJsonx['email'] ?? ''}');
  //       prefs.setString('permission', '1,2,3');
  //       prefs.setString('rser', '${userJsonx['rser'] ?? '50'}');
  //       prefs.setString('lavel', '5');

  //       print('✅ Preferences saved successfully');
  //       print('ser: ${userJsonx['ser']}');
  //       print('position: ${userJsonx['position']}');
  //       print('fname: ${userJsonx['fname']}');
  //       print('lname: ${userJsonx['lname']}');
  //       print('email: ${userJsonx['email']}');
  //       print('permission: ${userJsonx['permission']}');
  //       print('rser: ${userJsonx['rser']}');
  //       print('lavel: ${userJsonx['lavel']}');
  //       // AuthService.printStoredAuthData();
  //     } catch (e) {
  //       print('❌ Failed to decode user JSON: $e');
  //     }
  //   } else {
  //     print('⚠️ No user data found in SecurePrefs');
  //     AuthService.printStoredAuthData();
  //   }
  Future<void> routeToService() async {
    final userStr =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

    if (userStr != null) {
      try {
        final userJson = jsonDecode(userStr);
        // print('📦 Raw userJson: ${jsonEncode(userJson)}');

        final preferences = await SharedPreferences.getInstance();

        final fields = {
          'ser': '240',
          'position': '${userJson['position'] ?? ''}',
          'fname': '${userJson['fname'] ?? ''}',
          'lname': '${userJson['lname'] ?? ''}',
          'email': '${userJson['email'] ?? ''}',
          'permission': '${userJson['permission'] ?? ''}',
          'rser': '${userJson['rser'] ?? '165'}',
          'lavel': '${userJson['lavel'] ?? '5'}',
          // บันทึก ren / renTalSer / renTalName ให้หน้าอื่นๆ ใช้งานได้
          // ลำดับ fallback: renTalSer → ren → rser → '195'
          'ren': '${userJson['ren'] ?? userJson['rser'] ?? '195'}',
          'renTalSer':
              '${userJson['renTalSer'] ?? userJson['ren'] ?? userJson['rser'] ?? '195'}',
          'renTalName':
              '${userJson['renTalName'] ?? userJson['rname'] ?? userJson['ren_name'] ?? ''}',
        };

        fields.forEach((k, v) => preferences.setString(k, v));

        print('✅ [routeToService] Preferences saved:');
        fields.forEach((k, v) => print('   $k: $v'));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AdminScafScreen(route: 'หน้าหลัก')),
          (route) => false,
        );
      } catch (e) {
        //  print('❌ Failed to decode user JSON: $e');
      }
    } else {
      //  print('⚠️ No user data found in SecurePrefs');
      await AuthService.printStoredAuthData();
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SizedBox()
        // Center(
        //     child: InkWell(
        //         onTap: () async {
        //           await AuthService.printStoredAuthData();
        //           routeToService();
        //         },
        //         child: Text('🎉 ยินดีต้อนรับเข้าสู่ระบบ'))
        //         ),
        );
  }
}

/// ===== พื้นหลัง “เข้าชุดกับหน้า Login แต่ไม่ซ้ำ” =====
/// - ใช้ gradient สีเดียวกัน
/// - เพิ่มลายเฉียงด้านล่าง + เส้นโค้งนุ่ม ๆ (แทนภูเขา)
class _SetupBackground extends StatelessWidget {
  const _SetupBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SetupPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class _SetupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradient พาสเทลเดียวกับหน้า Login
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: kBgGradient,
        stops: [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // แถบเฉียงนุ่ม ๆ ด้านล่าง (ให้ความรู้สึกคล้าย login footer)
    final layer1 = Paint()..color = const Color(0xFFFFFFFF).withOpacity(.35);
    final p1 = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
          size.width * .35, size.height * .80, size.width, size.height * .86)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, layer1);

    // เส้นโค้งบาง ๆ ซ้อนอีกชั้นให้มีมิติ
    final layer2 = Paint()..color = const Color(0xFFFFFFFF).withOpacity(.22);
    final p2 = Path()
      ..moveTo(0, size.height * 0.94)
      ..quadraticBezierTo(
          size.width * .55, size.height * .86, size.width, size.height * .92)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p2, layer2);

    // จุด pattern โปร่งบาง ๆ (ต่างจากหน้า Login เล็กน้อย)
    final dot = Paint()..color = const Color(0xFF000000).withOpacity(.04);
    const spacing = 42.0;
    for (double y = 24; y < size.height * 0.75; y += spacing) {
      for (double x = 24; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
