import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui; // for ImageByteFormat
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:flutter/rendering.dart';
import 'dart:html' as html; // <-- ใช้เฉพาะบน Web

import 'package:auto_size_text/auto_size_text.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// import 'package:html_editor_enhanced/utils/shims/dart_ui_real.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ChiangMai_Municipality/unity/API_customersRegis.dart';
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetArea_Model.dart';
import '../Model/GetC_regis_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTeNantnew_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetZone_Model.dart';
import 'package:http/http.dart' as http;

import '../PeopleChao/PeopleChao_Screen2.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Details_Rental_customer.dart';

class Rental_customers extends StatefulWidget {
  final updateMessage;
  final updatesearch;

  const Rental_customers({super.key, this.updateMessage, this.updatesearch});

  @override
  State<Rental_customers> createState() => _Rental_customersState();
}

class _Rental_customersState extends State<Rental_customers> {
  final GlobalKey qrBlockKey = GlobalKey();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  /////--------------------------->
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  /////--------------------------->
  DateTime datex = DateTime.now();
  String tappedIndex_ = '';
  ScrollController _scrollController2 = ScrollController();
  List<TransBillModel> _TransBillModels = [];
  List<ZoneModel> zoneModels = [];
  int Count_OFF_SET = 0;
  List<TeNantModel> limitedList_teNantModels = [];
  List<TeNantModel> teNantModels = [];
  List<TeNantModel> teNantModels_Sum = [];
  List<TeNantModel> _teNantModels = <TeNantModel>[];
  List<AreaModel> areaModels = [];
  List<c_regis_Model> regisModels = [];
  String? renTal_user, renTal_name, Value_cid, custno_;

  List<TeNantnewModels> teNantnewModels = [];
  List<TeNantnewModels> _teNantnewModels = <TeNantnewModels>[];
  List<TeNantnewModels> limitedList_teNantnewModels = [];

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
      expbill_name,
      bill_default,
      bill_tser,
      foder,
      bills_name_,
      imglogo_,
      imgl;
  List<RenTalModel> renTalModels = [];
  String text_data = '';
  @override
  void initState() {
    checkPreferance();
    read_GC_rental();

    read_GC_tenant();
    read_GC_Regis();

    read_GC_tenantnew();

    super.initState();
  }

  // @override
  // void didUpdateWidget(Rental_customers oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.updatesearch != oldWidget.updatesearch) {
  //     // Call _searchBar when widget.updatesearch changes
  //     _searchBar();
  //   }
  // }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
    });
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname!.trim();
          var typexs = renTalModel.type!.trim();
          var typexx = renTalModel.typex!.trim();
          var billNamex = renTalModel.bill_name!.trim();
          var billAddrx = renTalModel.bill_addr!.trim();
          var billTaxx = renTalModel.bill_tax!.trim();
          var billTelx = renTalModel.bill_tel!.trim();
          var billEmailx = renTalModel.bill_email!.trim();
          var billDefaultx = renTalModel.bill_default;
          var billTserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            bill_name = billNamex;
            bill_addr = billAddrx;
            bill_tax = billTaxx;
            bill_tel = billTelx;
            bill_email = billEmailx;
            bill_default = billDefaultx;
            bill_tser = billTserx;
            // tem_page_ser = renTalModel.tem_page!.trim();
            renTalModels.add(renTalModel);
            if (billDefaultx == 'P') {
              bills_name_ = 'บิลธรรมดา';
            } else {
              bills_name_ = 'ใบกำกับภาษี';
            }
          });
        }
      } else {}
    } catch (e) {}
    print('name>>>>>  $renname');
  }

  Future<Null> read_GC_tenantnew() async {
    setState(() {
      limitedList_teNantnewModels.clear();
      _teNantnewModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/customer_register_V2.php?isAdd=true&ren=$ren';
    // print('url regisnew >>>>>> $url');

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result != null) {
        for (var map in result) {
          TeNantnewModels teNantnewModel = TeNantnewModels.fromJson(map);
          limitedList_teNantnewModels.add(teNantnewModel);
        }

        // 👉 เรียง userTModels ตาม ser จากน้อยไปมาก
        // limitedList_teNantnewModels.sort(
        //   (a, b) => int.parse(a.ser ?? '0').compareTo(int.parse(b.ser ?? '0')),
        // );

        // 👉 เซ็ตเข้า _userTModels
        setState(() {
          _teNantnewModels = limitedList_teNantnewModels;
        });
        read_tenant_limit();
      } else {
        print('No data found');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> showResultDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // setState(() {
              //   read_GC_tenantnew();
              // });
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> downloadWidgetAsPng(GlobalKey key,
      {String fileName = 'line_register_qr.png'}) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    // เพิ่มความคมชัดหน่อย
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // สร้าง Blob แล้วสั่งให้เบราว์เซอร์ดาวน์โหลด
    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  // --- ฟังก์ชันสำหรับปุ่มลงทะเบียน ---

  Future<void> _showRegisterlineDialog(
    BuildContext context,
    String tax,
    String regis,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer');

    // เก็บวันแบบ local (ดีฟอลต์ = พรุ่งนี้)
    DateTime expireDateLocal = DateTime.now().add(const Duration(days: 0));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            // คำนวณสิ้นวัน (local) -> แปลงเป็น UTC -> ISO -> Base64URL
            final endOfDayLocal = DateTime(
              expireDateLocal.year,
              expireDateLocal.month,
              expireDateLocal.day,
              23,
              59,
              59,
            );
            final expireIsoUtc = endOfDayLocal.toUtc().toIso8601String();
            final expireB64 = base64UrlEncode(utf8.encode(expireIsoUtc));

            // ประกอบ URL (ถ้าจะส่ง ren/tax เพิ่ม ให้ต่อพารามฯ ตรงนี้)
            final lineregisurl = '$regis&expire=$expireB64';
            // final lineregisurl = '$regis&ren=$ren&username=$tax&expire=$expireB64';

            // ข้อความวันสำหรับแสดงผล
            final expireIsoText =
                '${expireDateLocal.day.toString().padLeft(2, '0')}-${expireDateLocal.month.toString().padLeft(2, '0')}-${expireDateLocal.year}';

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(Icons.qr_code_2,
                              color: Colors.green, size: 24),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'ลงทะเบียนไลน์',
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'ปิด',
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 16),

                      // QR + caption (สำหรับบันทึก PNG)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Center(
                          child: RepaintBoundary(
                            key: qrBlockKey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    QrImageView(
                                      data: lineregisurl,
                                      version: QrVersions.auto,
                                      size: 230,
                                      embeddedImage: const AssetImage(
                                          'images/Icon-chao.png'),
                                      embeddedImageStyle:
                                          const QrEmbeddedImageStyle(
                                              size: Size(48, 48)),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'สแกนเพื่อเชื่อมต่อบัญชี LINE\nเลขที่บัตรประชาชน: $tax',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 14,
                                        color: Colors.black87,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 0),

                                    // กดเลือกวันแบบอินไลน์ (ไม่แยกฟังก์ชัน)
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: ctx,
                                          initialDate: expireDateLocal,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 120)),
                                          locale: const Locale('th', 'TH'),
                                        );
                                        if (picked != null) {
                                          setState(
                                              () => expireDateLocal = picked);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //   // color: AppbackgroundColor
                                          //   //     .TiTile_Colors,
                                          //   borderRadius:
                                          //       const BorderRadius.only(
                                          //           topLeft: Radius.circular(6),
                                          //           topRight:
                                          //               Radius.circular(6),
                                          //           bottomLeft:
                                          //               Radius.circular(6),
                                          //           bottomRight:
                                          //               Radius.circular(6)),
                                          //   border: Border.all(
                                          //       color: Colors.grey, width: 1),
                                          // ),
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: 'วันหมดอายุ: ',
                                                  style: TextStyle(
                                                    fontFamily: Font_.Fonts_T,
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    height: 1.25,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      expireIsoText, // <-- ส่วนวันที่
                                                  style: const TextStyle(
                                                    fontFamily: Font_.Fonts_T,
                                                    fontSize: 14,
                                                    color: Colors
                                                        .blue, // ✅ สีน้ำเงิน
                                                    height: 1.25,
                                                    fontWeight: FontWeight
                                                        .bold, // เพิ่มถ้าต้องการเน้น
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Link + Actions
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // เปิดลิงก์
                          // OutlinedButton.icon(
                          //   icon: const Icon(Icons.open_in_new, size: 18),
                          //   label: const Text('เปิดลิงก์',
                          //       style: TextStyle(fontFamily: Font_.Fonts_T)),
                          //   onPressed: () async {
                          //     final uri = Uri.parse(lineregisurl);
                          //     if (await canLaunchUrl(uri)) {
                          //       await launchUrl(uri,
                          //           mode: LaunchMode.externalApplication);
                          //     } else {
                          //       ScaffoldMessenger.of(dialogContext)
                          //           .showSnackBar(
                          //         const SnackBar(
                          //             content: Text('ไม่สามารถเปิดลิงก์ได้')),
                          //       );
                          //     }
                          //   },
                          // ),

                          // คัดลอกลิงก์
                          OutlinedButton.icon(
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('คัดลอกลิงก์',
                                style: TextStyle(fontFamily: Font_.Fonts_T)),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: lineregisurl));
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content: Text('คัดลอกลิงก์แล้ว')),
                              );
                            },
                          ),

                          const SizedBox(height: 10),
                          // ดาวน์โหลด PNG (ต้องมีฟังก์ชัน downloadWidgetAsPng)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('ดาวน์โหลด QR Code',
                                style: TextStyle(fontFamily: Font_.Fonts_T)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () async {
                              await downloadWidgetAsPng(
                                qrBlockKey,
                                fileName: 'line_register_${tax}.png',
                              );
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                    content: Text('ดาวน์โหลด PNG แล้ว')),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'สแกน QR หรือกด “เปิดลิงก์” เพื่อเชื่อมต่อบัญชีไลน์',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> Edit_Tenantnew(BuildContext context, int index) async {
    // ----- local states/refs -----
    final formKey = GlobalKey<FormState>();
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    bool busy = false;

    // ----- model/guards -----
    final model = teNantnewModels[index];
    final hasReg = model.regis_data?.isNotEmpty == true;
    final reg = hasReg ? model.regis_data![0] : null;

    final displayLine = (hasReg && (reg!.reg_displayname?.isNotEmpty ?? false))
        ? reg.reg_displayname!
        : 'รอลงทะเบียน';

    final bool canEdit = hasReg &&
        (reg!.reg_id_card != null && reg.reg_id_card!.trim().isNotEmpty);

    int allowDoc = hasReg && reg!.reg_allow_doc.toString() == '1' ? 1 : 0;
    int allowAgeement =
        hasReg && reg!.reg_allow_ageement.toString() == '1' ? 1 : 0;
    /////===============>
    final responseTuser = await readCustomersTuser(cusUuid: model.custno ?? "");
    final responseJsonTuser = jsonDecode(responseTuser!.body);
    String remember_t_ser = responseJsonTuser['t_user'];
    /////===============>
    final response = await readCustomersRemember(cusUuid: remember_t_ser ?? "");
    final responseJson = jsonDecode(response!.body);
    String remember_token = responseJson['remember_token'];
    /////===============>
    // ----- small reusable widgets -----
    Widget _ReadOnlyField({
      required BuildContext ctx,
      required String label,
      required String value,
    }) {
      final w = (Responsive.isDesktop(ctx))
          ? (MediaQuery.of(ctx).size.width * 0.47 - 16) / 2
          : double.infinity;

      return SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              width: w,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                value.isNotEmpty ? value : '-',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    Widget _ActionButton({
      required String label,
      required IconData icon,
      required Color color,
      VoidCallback? onTap,
    }) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.7)),
          minimumSize: const Size(130, 44),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            // ---------- actions inside dialog (use ctx + setStateDialog) ----------

            Future<void> _delete({required bool onlyLine}) async {
              if (busy) return;
              setStateDialog(() => busy = true);
              try {
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;

                final ren = prefs.getString('renTalSer');
                final idCard = model.user_name ?? '';
                final uri =
                    Uri.parse('${MyConstant().domain}/customer_register_V2.php')
                        .replace(queryParameters: {
                  'isAdd': 'true',
                  'ren': ren ?? ''
                });
                final payload = {
                  'type': onlyLine ? 'line_data' : 'all_data',
                  'id_card': idCard,
                };

                final res = await httpClient.delete(
                  uri,
                  headers: {"Content-Type": "application/json; charset=utf-8"},
                  body: jsonEncode(payload),
                );
                if (!ctx.mounted) return;

                final ok = res.statusCode == 200;

                await showResultDialog(
                  ctx,
                  title: ok ? 'สำเร็จ' : 'ผิดพลาด',
                  message: ok
                      ? (onlyLine
                          ? 'ลบข้อมูลไลน์สำเร็จ'
                          : 'ลบข้อมูลผู้ใช้สำเร็จ')
                      : (onlyLine
                          ? 'ไม่สามารถลบข้อมูลไลน์ได้'
                          : 'ไม่สามารถลบข้อมูลผู้ใช้ได้'),
                  icon: ok ? Icons.check_circle : Icons.error,
                  color: ok ? Colors.green : Colors.red,
                );
                if (!ctx.mounted) return;

                if (ok) {
                  await read_GC_tenantnew();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final n = Navigator.of(ctx);
                    if (n.canPop()) n.pop();
                  });
                }
              } catch (e) {
                if (!ctx.mounted) return;
                await showResultDialog(
                  ctx,
                  title: 'ข้อผิดพลาด',
                  message: 'เกิดปัญหาในการเชื่อมต่อ',
                  icon: Icons.error_outline,
                  color: Colors.red,
                );
              } finally {
                if (ctx.mounted) setStateDialog(() => busy = false);
              }
            }

            Future<void> _savePassword() async {
              final f = formKey.currentState;
              if (f == null || !f.validate()) return;
              if (busy) return;
              setStateDialog(() => busy = true);
              try {
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;

                final ren = prefs.getString('renTalSer') ?? '';
                final idCard = model.user_name;
                final raw = passwordCtrl.text.trim();
                if (raw.isEmpty) {
                  await showResultDialog(
                    ctx,
                    title: 'แจ้งเตือน',
                    message: 'กรุณากรอกรหัสผ่าน',
                    icon: Icons.info,
                    color: Colors.orange,
                  );
                  return;
                }
                final password = md5.convert(utf8.encode(raw)).toString();

                final uri =
                    Uri.parse('${MyConstant().domain}/customer_register_V2.php')
                        .replace(
                            queryParameters: {'isAdd': 'true', 'ren': ren});

                final resp = await httpClient.put(
                  uri,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'passwd': password,
                    'id_card': idCard,
                    'allowDoc': allowDoc,
                    'allowAgeement': allowAgeement,
                  }),
                );
                if (!ctx.mounted) return;

                final ok = resp.statusCode == 200;

                await showResultDialog(
                  ctx,
                  title: ok ? 'แก้ไขสำเร็จ' : 'ผิดพลาด',
                  message:
                      ok ? 'อัปเดตรหัสผ่านเรียบร้อย' : 'แก้ไขรหัสผ่านไม่สำเร็จ',
                  icon: ok ? Icons.check_circle : Icons.cancel,
                  color: ok ? Colors.green : Colors.red,
                );
                if (!ctx.mounted) return;

                if (ok) {
                  final response = await postCustomersRemember(
                      cusUuid: remember_t_ser,
                      newPassword: raw,
                      newPasswordConfirmation: raw,
                      rememberToken: remember_token);
                  final responseJson = jsonDecode(response!.body);
                  await read_GC_tenantnew();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final n = Navigator.of(ctx);
                    if (n.canPop()) n.pop();
                  });
                }
              } catch (e) {
                if (!ctx.mounted) return;
                await showResultDialog(
                  ctx,
                  title: 'ผิดพลาด',
                  message: 'เกิดข้อผิดพลาดในการแก้ไขข้อมูล',
                  icon: Icons.cancel,
                  color: Colors.red,
                );
              } finally {
                if (ctx.mounted) setStateDialog(() => busy = false);
              }
            }

            Future<void> _saveAllowDocAgee() async {
              if (busy) return;
              setStateDialog(() => busy = true);
              try {
                final prefs = await SharedPreferences.getInstance();
                if (!ctx.mounted) return;

                final ren = prefs.getString('renTalSer') ?? '';
                final idCard = model.user_name;
                final raw = passwordCtrl.text.trim();
                final password = md5.convert(utf8.encode(raw)).toString();

                final uri =
                    Uri.parse('${MyConstant().domain}/customer_register_V2.php')
                        .replace(
                            queryParameters: {'isAdd': 'true', 'ren': ren});

                final resp = await httpClient.put(
                  uri,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'passwd': password,
                    'id_card': idCard,
                    'allowDoc': allowDoc,
                    'allowAgeement': allowAgeement,
                  }),
                );
                if (!ctx.mounted) return;

                final ok = resp.statusCode == 200;

                await showResultDialog(
                  ctx,
                  title: ok ? 'แก้ไขสำเร็จ' : 'ผิดพลาด',
                  message: ok ? 'อัปเดตสิทธิเรียบร้อย' : 'แก้ไขสิทธิไม่สำเร็จ',
                  icon: ok ? Icons.check_circle : Icons.cancel,
                  color: ok ? Colors.green : Colors.red,
                );
                if (!ctx.mounted) return;

                if (ok) {
                  await read_GC_tenantnew();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final n = Navigator.of(ctx);
                    if (n.canPop()) n.pop();
                  });
                }
              } catch (e) {
                if (!ctx.mounted) return;
                await showResultDialog(
                  ctx,
                  title: 'ผิดพลาด',
                  message: 'เกิดข้อผิดพลาดในการแก้ไขข้อมูล',
                  icon: Icons.cancel,
                  color: Colors.red,
                );
              } finally {
                if (ctx.mounted) setStateDialog(() => busy = false);
              }
            }

            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
              titlePadding: const EdgeInsets.all(0.0),
              contentPadding: const EdgeInsets.all(10.0),
              actionsPadding: const EdgeInsets.all(6.0),
              title: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isDesktop(ctx)
                      ? MediaQuery.of(ctx).size.width * 0.5
                      : MediaQuery.of(ctx).size.width,
                  maxHeight: 100,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: busy
                              ? null
                              : () {
                                  final n = Navigator.of(ctx);
                                  if (n.canPop()) n.pop();
                                },
                          icon: const Icon(
                            Icons.highlight_off,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.manage_accounts, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          'แก้ไขผู้ใช้งาน',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              content: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Theme.of(ctx).cardColor,
                  child: Form(
                    key: formKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.isDesktop(ctx)
                            ? MediaQuery.of(ctx).size.width * 0.5
                            : MediaQuery.of(ctx).size.width,
                        maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                              child: Column(
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _ReadOnlyField(
                                        ctx: ctx,
                                        label: 'ชื่อผู้เช่า',
                                        value: model.cname ?? '',
                                      ),
                                      _ReadOnlyField(
                                        ctx: ctx,
                                        label: 'ชื่อร้านค้า',
                                        value: model.sname ?? '',
                                      ),
                                      _ReadOnlyField(
                                        ctx: ctx,
                                        label: 'User Name',
                                        value: model.user_name ?? '',
                                      ),
                                      _ReadOnlyField(
                                        ctx: ctx,
                                        label: 'ไลน์',
                                        value: displayLine,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'ตั้งรหัสผ่านใหม่',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(ctx).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: passwordCtrl,
                                    enabled: canEdit,
                                    obscureText: obscure,
                                    textInputAction: TextInputAction.done,
                                    maxLength: 32,
                                    buildCounter: (_,
                                            {required currentLength,
                                            maxLength,
                                            required isFocused}) =>
                                        const SizedBox.shrink(),
                                    decoration: InputDecoration(
                                      hintText: canEdit
                                          ? 'อย่างน้อย 6 ตัวอักษร (ไม่เว้นวรรค/เครื่องหมาย ‘ )'
                                          : 'กรุณาเปิดใช้งาน User ก่อน',
                                      helperText: canEdit
                                          ? null
                                          : 'ต้องเปิดใช้งานก่อนจึงจะตั้งรหัสผ่านได้',
                                      filled: true,
                                      suffixIcon: IconButton(
                                        onPressed: () => setStateDialog(
                                            () => obscure = !obscure),
                                        icon: Icon(
                                          obscure
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        tooltip: obscure
                                            ? 'แสดงรหัสผ่าน'
                                            : 'ซ่อนรหัสผ่าน',
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r"['\s]"),
                                      ),
                                    ],
                                    validator: (v) {
                                      if (!canEdit) return null;
                                      final t = v?.trim() ?? '';
                                      if (t.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                                      if (t.length < 6) {
                                        return 'รหัสผ่านต้องอย่างน้อย 6 ตัว';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ----- Toggles -----
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.contact_emergency,
                                      color: Colors.black54, size: 35),
                                  const SizedBox(width: 2),
                                  const Text(
                                    'เอกสารเกี่ยวกับสัญญา',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          if (busy) return;
                                          setStateDialog(() {
                                            allowAgeement =
                                                (allowAgeement == 0) ? 1 : 0;
                                          });
                                          _saveAllowDocAgee();
                                        },
                                        child: Icon(
                                          (allowAgeement == 0)
                                              ? Icons.toggle_off
                                              : Icons.toggle_on,
                                          color: (allowAgeement == 0)
                                              ? Colors.grey
                                              : Colors.green,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.receipt,
                                      color: Colors.black54, size: 35),
                                  const SizedBox(width: 2),
                                  const Text(
                                    'เอกสารอื่นๆ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 100,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          if (busy) return;
                                          setStateDialog(() {
                                            allowDoc = (allowDoc == 0) ? 1 : 0;
                                          });
                                          _saveAllowDocAgee();
                                        },
                                        child: Icon(
                                          (allowDoc == 0)
                                              ? Icons.toggle_off
                                              : Icons.toggle_on,
                                          color: (allowDoc == 0)
                                              ? Colors.grey
                                              : Colors.green,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      (hasReg && (reg!.reg_id_card?.isNotEmpty ?? false))
                          ? _ActionButton(
                              label: 'ลบผู้ใช้งาน User',
                              icon: Icons.person,
                              color: Colors.red,
                              onTap:
                                  busy ? null : () => _delete(onlyLine: false),
                            )
                          : _ActionButton(
                              label: 'ลบผู้ใช้งาน User',
                              icon: Icons.person,
                              color: Colors.grey,
                              onTap: null,
                            ),
                      const SizedBox(width: 8),
                      (hasReg && (reg!.reg_displayname?.isNotEmpty ?? false))
                          ? _ActionButton(
                              label: 'ลบข้อมูลไลน์',
                              icon: Icons.chat_bubble_outline,
                              color: Colors.orange,
                              onTap:
                                  busy ? null : () => _delete(onlyLine: true),
                            )
                          : _ActionButton(
                              label: 'ลบข้อมูลไลน์',
                              icon: Icons.chat_bubble_outline,
                              color: Colors.grey,
                              onTap: null,
                            ),
                      const Spacer(),
                      SizedBox(
                        height: 44,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: passwordCtrl,
                          builder: (vbCtx, value, _) {
                            final canSubmit = value.text.trim().length >= 6;
                            return ElevatedButton.icon(
                              onPressed:
                                  (busy || !canSubmit) ? null : _savePassword,
                              icon: busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: const Text('บันทึก'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(110, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // dispose controller after dialog closes
    passwordCtrl.dispose();
  }

  Future<Null> read_GC_tenant() async {
    if (limitedList_teNantModels.isNotEmpty) {
      limitedList_teNantModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    String url =
        '${MyConstant().domain}/peploe_chaoAll_GrupBy.php?isAdd=true&ren=$ren&zone=$zone';
    // zone == null
    //     ? '${MyConstant().domain}/peploe_chaoAll_GrupBy.php?isAdd=true&ren=$ren&zone=$zone'
    //     : zone == '0'
    //         ? '${MyConstant().domain}/peploe_chaoAll_GrupBy.php?isAdd=true&ren=$ren&zone=$zone'
    //         : '${MyConstant().domain}/peploe_chao_GrupBy.php.php?isAdd=true&ren=$ren&zone=$zone';
    print('url chaoall >>>>>> $url');
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (teNantModel.quantity == '1') {
            var daterx = teNantModel.ldate == null
                ? teNantModel.ldate_q
                : teNantModel.ldate;

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

              print('difference == $difference');

              var daterx_now = DateTime.now();

              var daterx_ldate = DateTime.parse('$daterx 00:00:00.000');

              final now = DateTime.now();
              final earlier = daterx_ldate.subtract(const Duration(days: 0));
              var daterx_A = now.isAfter(earlier);
              print(now.isAfter(earlier)); // true
              print(now.isBefore(earlier)); // true

              // if (daterx_A != true) {
              setState(() {
                limitedList_teNantModels.add(teNantModel);
              });
              // }
            }

            setState(() {
              _teNantModels = limitedList_teNantModels;
            });
          }
          // setState(() {
          //   teNantModels.add(teNantModel);
          // });
        }
      } else {}

      // read_tenant_limit();
      read_GC_tenant_SUM();
    } catch (e) {}
  }

  /////////////////--------------------------->
  Future<Null> read_tenant_limit() async {
    setState(() {
      endIndex = offset + limit;
      teNantnewModels = limitedList_teNantnewModels.sublist(
          offset, // Start index
          (endIndex <= limitedList_teNantnewModels.length)
              ? endIndex
              : limitedList_teNantnewModels.length // End index
          );
    });
  }

  /////////////////--------------------------->
  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

///////////-----regisModels------GC_regis.php
  int Status_cuspang = 0;
  String? cust_no;
  String? ser_ren;

  Future<Null> read_GC_Regis() async {
    if (regisModels.isNotEmpty) {
      regisModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_regis.php?isAdd=true&ren=$ren';
    print('url regis >>>>>> $url');
    setState(() {
      ser_ren = ren;
    });
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          c_regis_Model regisModel = c_regis_Model.fromJson(map);
          setState(() {
            regisModels.add(regisModel);
          });
        }
      } else {}
      // red_Trans_bill();
    } catch (e) {}
  }

  Future<Null> read_GC_tenant_SUM() async {
    if (teNantModels_Sum.isNotEmpty) {
      teNantModels_Sum.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_tenantAll_Sumcust.php?isAdd=true&ren=$ren';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          if (teNantModel.cid == null ||
              teNantModel.cid.toString() == '' ||
              teNantModel.cid.toString() == 'null') {
          } else {
            teNantModels_Sum.add(teNantModel);
            // sum_teNantModel++;
          }
        }
      } else {}
      // red_Trans_bill();
    } catch (e) {}
  }

  Future<int> read_GC_tenant_where(index) async {
    String targetCustNo = teNantModels[index].custno!; // Get the target custno
    ///print(" custno: $targetCustNo");

    int sum_teNantModel = teNantModels_Sum
        .where((element) => element.custno == targetCustNo)
        .length;

    //print("Total $targetCustNo: $sum_teNantModel");
    return sum_teNantModel;
  }

  Future<String> read_GC_tenant_wherecids(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    double total = 0.00;
    String targetCustNo = teNantModels[index].custno!;

    await Future.forEach(
        teNantModels_Sum.where((element) => element.custno == targetCustNo),
        (element) async {
      try {
        String url =
            '${MyConstant().domain}/GC_tran_paysCustomer.php?isAdd=true&ren=$ren&ciddoc=${element.cid}';

        var response = await httpClient.get(Uri.parse(url));
        var result = json.decode(response.body);

        if (result != null) {
          for (var map in result) {
            TransBillModel _TransBillModel = TransBillModel.fromJson(map);
            total += (_TransBillModel.total == null)
                ? 0.00
                : double.parse(_TransBillModel.total!);
            // if (_TransBillModel.invoice == null) {
            //   if (_TransBillModel.total != null) {
            //     total += (_TransBillModel.total == null)
            //         ? 0.00
            //         : double.parse(_TransBillModel.total!);
            //   }
            // }
          }
        }
      } catch (e) {
        // Handle or log the error here
      }
      // await Future.delayed(Duration(milliseconds: 600));
    });
    //print(" custno: $targetCustNo");
    return '${nFormat.format(double.parse(total.toString()))}';
  }

  String? _message, Valuecid;

  void updateMessage1(PeopleChaoScreen2, ValueNameShop_index, Valuecid) {
    setState(() {
      // _message = newMessage;
      widget.updateMessage(PeopleChaoScreen2, ValueNameShop_index, Valuecid);
      // Status_cuspang = int.parse(newMessage);
      Valuecid = Value_cid;
    });
  }

  ///----------------------->
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
          print(text);
          text = text.toLowerCase();
          setState(
            () {
              teNantnewModels = _teNantnewModels.where((teNantModels) {
                var notTitle = teNantModels.custno.toString().toLowerCase();
                var notTitle2 = teNantModels.tax.toString().toLowerCase();
                var notTitle3 = teNantModels.cname.toString().toLowerCase();

                var notTitle8 = teNantModels.custno.toString().toLowerCase();
                return notTitle.contains(text) ||
                    notTitle2.contains(text) ||
                    notTitle3.contains(text);
              }).toList();
            },
          );
          if (text.isEmpty) {
            read_tenant_limit();
          } else {}
        });
  }

  ///----------------------->
  Widget Next_page() {
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
                                  _scrollController2.animateTo(
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
                        /// '*//$endIndex /${limitedList_teNantnewModels.length} ///${(endIndex ~/ limit)}/${(limitedList_teNantnewModels.length / limit).ceil()}',
                        '${(endIndex ~/ limit)}/${(limitedList_teNantnewModels.length / limit).ceil()}',
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
                        onTap: (endIndex >= limitedList_teNantnewModels.length)
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  tappedIndex_ = '';
                                  read_tenant_limit();
                                });
                                _scrollController2.animateTo(
                                  0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: (endIndex >= limitedList_teNantnewModels.length)
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

  @override
  Widget build(BuildContext context) {
    return (Status_cuspang == 1)
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          // widget.updateMessage('6');
                          Status_cuspang = 0;
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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                'ย้อนกลับ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AccountScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                  //fontSize: 10.0
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
              Details_Rental_customer(
                  updateMessage2: updateMessage1, name_custno: cust_no)
              // PeopleChaoScreen2(
              //   Get_Value_cid: resultqr,
              //   Get_Value_NameShop_index: '1',
              //   Get_Value_status: '1',
              //   Get_Value_indexpage: '3',
              //   updateMessage: updateMessage,
              // ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  // width: MediaQuery.of(context).size.width,
                  width: (Responsive.isDesktop(context))
                      ? MediaQuery.of(context).size.width * 0.85
                      : 1200,
                  decoration: const BoxDecoration(
                    color: AppbackgroundColor.Sub_Abg_Colors,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    // border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                          // width: MediaQuery.of(context).size.width,
                          width: (Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width * 0.85
                              : 1200,
                          child: Column(
                            children: [
                              ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                }),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  dragStartBehavior: DragStartBehavior.start,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: (Responsive.isDesktop(
                                                      context))
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85
                                                  : 1200,
                                              decoration: BoxDecoration(
                                                color: AppbackgroundColor
                                                    .TiTile_Colors,
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0)),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Row(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: Text(
                                                            'ค้นหา :',
                                                            style: TextStyle(
                                                              color: ReportScreen_Color
                                                                  .Colors_Text2_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
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
                                                            child: _searchBar(),
                                                          ),
                                                        ),
                                                        Container(
                                                            width: 150,
                                                            child: Next_page())
                                                      ],
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'รหัสลูกค้า',
                                                                  SettingScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  2),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ชื่อผู้เช่า',
                                                                  SettingScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  2),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ชื่อร้านค้า',
                                                                  SettingScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  2),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate.TranslateAndSetText(
                                                              'เลขที่บัตรประชาชน',
                                                              SettingScreen_Color
                                                                  .Colors_Text1_,
                                                              TextAlign.start,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              2),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ลงทะเบียน User',
                                                                  SettingScreen_Color
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
                                                      Expanded(
                                                        flex: 2,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ไลน์',
                                                                  SettingScreen_Color
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
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'ลงทะเบียนไลน์',
                                                                  SettingScreen_Color
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
                                                      Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'จัดการ',
                                                                  SettingScreen_Color
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
                                                      // Expanded(
                                                      //   flex: 1,
                                                      //   child: Padding(
                                                      //     padding:
                                                      //         EdgeInsets.all(
                                                      //             8.0),
                                                      //     child: Text(
                                                      //       'Reset Password',
                                                      //       textAlign: TextAlign
                                                      //           .center,
                                                      //       style: TextStyle(
                                                      //         color: AccountScreen_Color
                                                      //             .Colors_Text1_,
                                                      //         fontWeight:
                                                      //             FontWeight
                                                      //                 .bold,
                                                      //         fontFamily:
                                                      //             FontWeight_
                                                      //                 .Fonts_T,
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      // Expanded(
                                                      //   flex: 1,
                                                      //   child: Padding(
                                                      //     padding:
                                                      //         EdgeInsets.all(
                                                      //             8.0),
                                                      //     child: Text(
                                                      //       'Delete Line User',
                                                      //       textAlign: TextAlign
                                                      //           .center,
                                                      //       style: TextStyle(
                                                      //         color: AccountScreen_Color
                                                      //             .Colors_Text1_,
                                                      //         fontWeight:
                                                      //             FontWeight
                                                      //                 .bold,
                                                      //         fontFamily:
                                                      //             FontWeight_
                                                      //                 .Fonts_T,
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      // Expanded(
                                                      //   flex: 1,
                                                      //   child: Padding(
                                                      //     padding:
                                                      //         EdgeInsets.all(
                                                      //             8.0),
                                                      //     child: Translate
                                                      //         .TranslateAndSetText(
                                                      //             'สัญญาที่พบ',
                                                      //             SettingScreen_Color
                                                      //                 .Colors_Text1_,
                                                      //             TextAlign.end,
                                                      //             FontWeight
                                                      //                 .bold,
                                                      //             FontWeight_
                                                      //                 .Fonts_T,
                                                      //             14,
                                                      //             2),
                                                      //   ),
                                                      // ),
                                                      // Expanded(
                                                      //   flex: 1,
                                                      //   child: Padding(
                                                      //     padding:
                                                      //         EdgeInsets.all(
                                                      //             8.0),
                                                      //     child: Translate
                                                      //         .TranslateAndSetText(
                                                      //             'จำนวนเงิน',
                                                      //             SettingScreen_Color
                                                      //                 .Colors_Text1_,
                                                      //             TextAlign.end,
                                                      //             FontWeight
                                                      //                 .bold,
                                                      //             FontWeight_
                                                      //                 .Fonts_T,
                                                      //             14,
                                                      //             2),
                                                      //   ),
                                                      // ),
                                                      // Expanded(
                                                      //   flex: 1,
                                                      //   child: Padding(
                                                      //     padding:
                                                      //         EdgeInsets.all(
                                                      //             8.0),
                                                      //     child: Text(
                                                      //       '...',
                                                      //       textAlign: TextAlign
                                                      //           .center,
                                                      //       style: TextStyle(
                                                      //         color: AccountScreen_Color
                                                      //             .Colors_Text1_,
                                                      //         fontWeight:
                                                      //             FontWeight
                                                      //                 .bold,
                                                      //         fontFamily:
                                                      //             FontWeight_
                                                      //                 .Fonts_T,
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.58,
                                                width: Responsive.isDesktop(
                                                        context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.85
                                                    : 1200,
                                                decoration: const BoxDecoration(
                                                  color: AppbackgroundColor
                                                      .Sub_Abg_Colors,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(0),
                                                          topRight:
                                                              Radius.circular(
                                                                  0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  0)),
                                                  // border: Border.all(color: Colors.grey, width: 1),
                                                ),
                                                child: teNantnewModels.isEmpty
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
                                                                double elapsed =
                                                                    double.parse(snapshot
                                                                            .data
                                                                            .toString()) *
                                                                        0.05;
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: (elapsed >
                                                                          8.00)
                                                                      ? Translate.TranslateAndSetText(
                                                                          'ไม่พบข้อมูล',
                                                                          SettingScreen_Color
                                                                              .Colors_Text1_,
                                                                          TextAlign
                                                                              .end,
                                                                          FontWeight
                                                                              .bold,
                                                                          FontWeight_
                                                                              .Fonts_T,
                                                                          14,
                                                                          1)
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
                                                            _scrollController2,
                                                        // itemExtent: 50,
                                                        physics:
                                                            const AlwaysScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            teNantnewModels
                                                                .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Material(
                                                            color: tappedIndex_ ==
                                                                    index
                                                                        .toString()
                                                                ? tappedIndex_Color
                                                                    .tappedIndex_Colors
                                                                : AppbackgroundColor
                                                                    .Sub_Abg_Colors,
                                                            child: Container(
                                                              // color: tappedIndex_ ==
                                                              //         index.toString()
                                                              //     ? tappedIndex_Color
                                                              //         .tappedIndex_Colors
                                                              //         .withOpacity(0.5)
                                                              //     : null,
                                                              child: Column(
                                                                children: [
                                                                  ListTile(
                                                                      onTap:
                                                                          () async {
                                                                        // generateRandomString();
                                                                        // setState(() {
                                                                        //   red_Trans_select(
                                                                        //       index);
                                                                        //   red_Invoice(
                                                                        //       index);
                                                                        // });
                                                                        // Future.delayed(
                                                                        //     const Duration(
                                                                        //         milliseconds:
                                                                        //             300),
                                                                        //     () async {
                                                                        //   checkshowDialog(
                                                                        //     index,
                                                                        //   );
                                                                        // });
                                                                      },
                                                                      title:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          // color: Colors.green[100]!
                                                                          //     .withOpacity(0.5),
                                                                          border:
                                                                              Border(
                                                                            bottom:
                                                                                BorderSide(
                                                                              color: Colors.black12,
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Row(
                                                                                children: [
                                                                                  Copy_Text(context, '${teNantnewModels[index].custno}'),
                                                                                  Expanded(
                                                                                    child: AutoSizeText(
                                                                                      minFontSize: 12,
                                                                                      maxFontSize: 16,
                                                                                      maxLines: 1,
                                                                                      (teNantnewModels[index].custno == null) ? '' : '${teNantnewModels[index].custno}',
                                                                                      textAlign: TextAlign.start,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Tooltip(
                                                                                richMessage: TextSpan(
                                                                                  text:
                                                                                      // '${teNantnewModels[index].cname}',
                                                                                      (teNantnewModels[index].cname == null || teNantnewModels[index].cname == '') ? '' : '${teNantnewModels[index].cname}',
                                                                                  style: const TextStyle(
                                                                                    color: HomeScreen_Color.Colors_Text1_,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: FontWeight_.Fonts_T,
                                                                                    //fontSize: 10.0
                                                                                  ),
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                  color: Colors.grey[200],
                                                                                ),
                                                                                child: AutoSizeText(
                                                                                  minFontSize: 12,
                                                                                  maxFontSize: 16,
                                                                                  maxLines: 1,
                                                                                  (teNantnewModels[index].cname == null || teNantnewModels[index].cname == '') ? '' : '${teNantnewModels[index].cname}',
                                                                                  textAlign: TextAlign.start,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Tooltip(
                                                                                richMessage: TextSpan(
                                                                                  text:
                                                                                      // '${teNantnewModels[index].sname}',
                                                                                      (teNantnewModels[index].sname == null || teNantnewModels[index].sname.toString() == '') ? '' : '${teNantnewModels[index].sname}',
                                                                                  style: const TextStyle(
                                                                                    color: HomeScreen_Color.Colors_Text1_,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: FontWeight_.Fonts_T,
                                                                                    //fontSize: 10.0
                                                                                  ),
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(5),
                                                                                  color: Colors.grey[200],
                                                                                ),
                                                                                child: AutoSizeText(
                                                                                  minFontSize: 12,
                                                                                  maxFontSize: 16,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  (teNantnewModels[index].sname == null || teNantnewModels[index].sname.toString() == '') ? '' : '${teNantnewModels[index].sname}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(2.0),
                                                                                  child: Builder(
                                                                                    builder: (_) {
                                                                                      /// แปลงเลข (หรือข้อความที่มีเลข) ให้เป็นรูปแบบบัตรประชาชน: X-XXXX-XXXXX-XX-X
                                                                                      String formatThaiId(String input) {
                                                                                        final digits = input.replaceAll(RegExp(r'\D'), '');
                                                                                        if (digits.isEmpty) return '';
                                                                                        final capped = digits.length > 13 ? digits.substring(0, 13) : digits;

                                                                                        final buf = StringBuffer();
                                                                                        for (int i = 0; i < capped.length; i++) {
                                                                                          buf.write(capped[i]);
                                                                                          // ใส่ขีดหลังตำแหน่ง 1, 5, 10, 12 (index 0,4,9,11)
                                                                                          if ((i == 0 || i == 4 || i == 9 || i == 11) && i < capped.length - 1) {
                                                                                            buf.write('-');
                                                                                          }
                                                                                        }
                                                                                        return buf.toString();
                                                                                      }

                                                                                      final tax = teNantnewModels[index].tax?.trim() ?? '';

                                                                                      // 1) ว่าง "" "-"-> ไม่โชว์อะไรเลย
                                                                                      if (tax.isEmpty || tax == '-') return const SizedBox();

                                                                                      // 2) ต้องเป็นตัวเลข 13 หลักเท่านั้น
                                                                                      final isValid = RegExp(r'^\d{13}$').hasMatch(tax);

                                                                                      return Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          // ❗ เปลี่ยนจาก if (isValid) -> if (tax.isNotEmpty)
                                                                                          if (tax.isNotEmpty) Copy_Text(context, tax),

                                                                                          Expanded(
                                                                                            child: Align(
                                                                                              alignment: Alignment.centerLeft,
                                                                                              child: AutoSizeText(
                                                                                                formatThaiId(tax).toString(),
                                                                                                minFontSize: 12,
                                                                                                maxFontSize: 16,
                                                                                                maxLines: 1,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.start,
                                                                                                style: TextStyle(
                                                                                                  color: isValid ? PeopleChaoScreen_Color.Colors_Text2_ : Colors.red,
                                                                                                  fontFamily: Font_.Fonts_T,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Center(
                                                                                child: (teNantnewModels[index].regis_data![0].reg_id_card != null && teNantnewModels[index].regis_data![0].reg_id_card != '')
                                                                                    ? SizedBox(
                                                                                        width: 150,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: null,
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.grey[500], // สีเทาแบบ disabled
                                                                                            foregroundColor: Colors.white,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Text(
                                                                                            'เปิดใช้งานแล้ว',
                                                                                            // 'ลงทะเบียนแล้ว',
                                                                                            textAlign: TextAlign.center,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox(
                                                                                        width: 150,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: () async {
                                                                                            final confirm = await showDialog<bool>(
                                                                                              context: context,
                                                                                              barrierDismissible: false, // ต้องเลือกปุ่มเท่านั้น
                                                                                              builder: (ctx) {
                                                                                                return AlertDialog(
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(16),
                                                                                                  ),
                                                                                                  title: Row(
                                                                                                    children: const [
                                                                                                      Icon(Icons.help_outline, color: Colors.amber, size: 28),
                                                                                                      SizedBox(width: 8),
                                                                                                      Text(
                                                                                                        'ยืนยันการเปิดใช้งาน',
                                                                                                        style: TextStyle(
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                          fontSize: 18,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  content: const Text(
                                                                                                    'คุณแน่ใจหรือไม่ว่าต้องการเปิดใช้งานผู้ใช้นี้?',
                                                                                                    style: TextStyle(fontSize: 15),
                                                                                                  ),
                                                                                                  actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                                                  actions: [
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        OutlinedButton(
                                                                                                          style: OutlinedButton.styleFrom(
                                                                                                            minimumSize: const Size(90, 40),
                                                                                                            side: BorderSide(color: Colors.grey.shade400),
                                                                                                            shape: RoundedRectangleBorder(
                                                                                                              borderRadius: BorderRadius.circular(8),
                                                                                                            ),
                                                                                                          ),
                                                                                                          onPressed: () => Navigator.of(ctx).pop(false),
                                                                                                          child: const Text('ยกเลิก'),
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          width: 10,
                                                                                                        ),
                                                                                                        ElevatedButton.icon(
                                                                                                          style: ElevatedButton.styleFrom(
                                                                                                            backgroundColor: Colors.green,
                                                                                                            foregroundColor: Colors.white,
                                                                                                            minimumSize: const Size(100, 40),
                                                                                                            shape: RoundedRectangleBorder(
                                                                                                              borderRadius: BorderRadius.circular(8),
                                                                                                            ),
                                                                                                          ),
                                                                                                          onPressed: () => Navigator.of(ctx).pop(true),
                                                                                                          icon: const Icon(Icons.check_circle_outline),
                                                                                                          label: const Text('ยืนยัน'),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                            );

                                                                                            // ถ้ากด "ยืนยัน" เท่านั้นถึงจะไปทำงานต่อ
                                                                                            if (confirm != true) return;

                                                                                            final prefs = await SharedPreferences.getInstance();
                                                                                            final ren = prefs.getString('renTalSer'); // อาจเป็น null ได้

                                                                                            // --- MD5 ของรหัสผ่าน ---
                                                                                            final rawPass = '111111';
                                                                                            final passwdMd5 = md5.convert(utf8.encode(rawPass)).toString();

                                                                                            // --- ดึงค่า Tax ---
                                                                                            final tax = teNantnewModels[index].tax?.trim() ?? '';

                                                                                            // --- เช็ค Tax ID ---
                                                                                            if (tax.isEmpty) {
                                                                                              await Dialog_error(context, 'ไม่มี Tax ID ไม่สามารถเปิดใช้งาน ได้ !!!');
                                                                                              // await showResultDialog(
                                                                                              //   context,
                                                                                              //   title: 'ไม่มี Tax ID',
                                                                                              //   message: 'ไม่สามารถเปิดใช้งาน ได้ !!!',
                                                                                              //   icon: Icons.error_outline,
                                                                                              //   color: Colors.red,
                                                                                              // );
                                                                                              return;
                                                                                            }

                                                                                            // regex: ตัวเลข 0–9 ความยาว 13 หลักเป๊ะ
                                                                                            final isValidTax = RegExp(r'^[0-9]{13}$').hasMatch(tax);

                                                                                            if (!isValidTax) {
                                                                                              await Dialog_error(context, 'กรุณาตรวจสอบ Tax ID ต้องเป็นตัวเลข 13 หลัก');
                                                                                              // await showResultDialog(
                                                                                              //   context,
                                                                                              //   title: 'Tax ID ไม่ถูกต้อง',
                                                                                              //   message: 'กรุณาตรวจสอบ Tax ID ต้องเป็นตัวเลข 13 หลัก',
                                                                                              //   icon: Icons.error,
                                                                                              //   color: Colors.red,
                                                                                              // );
                                                                                              return;
                                                                                            }

                                                                                            try {
                                                                                              final uri = Uri.parse(
                                                                                                '${MyConstant().domain}/customer_register_V2.php?isAdd=true&ren=$ren',
                                                                                              );
                                                                                              // print('uri regisv2 >>>>>> $uri');

                                                                                              final payload = {
                                                                                                "rser": teNantnewModels[index].rser ?? '',
                                                                                                "custno": teNantnewModels[index].custno ?? '',
                                                                                                "pn": renname ?? '',
                                                                                                "id_card": tax,
                                                                                                "username": tax,
                                                                                                "passwd": passwdMd5,
                                                                                                "language": 'TH',
                                                                                                "cname": teNantnewModels[index].cname ?? '',
                                                                                              };

                                                                                              final res = await httpClient
                                                                                                  .post(
                                                                                                    uri,
                                                                                                    headers: {
                                                                                                      "Content-Type": "application/json; charset=utf-8"
                                                                                                    },
                                                                                                    body: jsonEncode(payload),
                                                                                                  )
                                                                                                  .timeout(const Duration(seconds: 15));

                                                                                              if (res.statusCode == 200) {
                                                                                                final resR = await postCustomersRegister(
                                                                                                  cusUuid: teNantnewModels[index].custno ?? '',
                                                                                                );
                                                                                                if (resR!.statusCode != 200) {
                                                                                                  await Dialog_error(context, 'เกิดข้อผิดพลาด (HTTP ${resR.statusCode})');
                                                                                                } else {
                                                                                                  setState(() {
                                                                                                    read_GC_tenantnew();
                                                                                                  });
                                                                                                  await Dialog_success(context, 'ลงทะเบียนเปิดใช้งาน User สำเร็จ');
                                                                                                }

                                                                                                // await showResultDialog(
                                                                                                //   context,
                                                                                                //   title: 'สำเร็จ',
                                                                                                //   message: 'ลงทะเบียนเปิดใช้งาน User เรียบร้อย',
                                                                                                //   icon: Icons.check_circle,
                                                                                                //   color: Colors.green,
                                                                                                // );
                                                                                              } else {
                                                                                                await Dialog_error(context, 'เกิดข้อผิดพลาด (HTTP ${res.statusCode})');

                                                                                                // showResultDialog(
                                                                                                //   context,
                                                                                                //   title: 'ผิดพลาด',
                                                                                                //   message: 'เกิดข้อผิดพลาด (HTTP ${res.statusCode})',
                                                                                                //   icon: Icons.error,
                                                                                                //   color: Colors.red,
                                                                                                // );
                                                                                              }
                                                                                            } catch (e) {
                                                                                              await Dialog_error(context, 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาลองใหม่');
                                                                                              // await showResultDialog(
                                                                                              //   context,
                                                                                              //   title: 'ข้อผิดพลาด',
                                                                                              //   message: 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาลองใหม่',
                                                                                              //   icon: Icons.error_outline,
                                                                                              //   color: Colors.red,
                                                                                              // );
                                                                                            }
                                                                                          },
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.blue[700],
                                                                                            foregroundColor: Colors.white,
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                                                          ),
                                                                                          child: const Text(
                                                                                            'เปิดใช้งาน User',
                                                                                            textAlign: TextAlign.center,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                              ),
                                                                            ),

                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: (teNantnewModels[index].regis_data![0].reg_userid == null || teNantnewModels[index].regis_data![0].reg_userid?.isEmpty == true)
                                                                                  ? Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Icon(
                                                                                          Icons.warning_amber,
                                                                                          color: Colors.orange,
                                                                                          size: 16,
                                                                                        ),
                                                                                        const SizedBox(width: 4),
                                                                                        Text(
                                                                                          'รอลงทะเบียน',
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          textAlign: TextAlign.start,
                                                                                          style: TextStyle(
                                                                                            color: Colors.orange,
                                                                                            fontFamily: Font_.Fonts_T,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : Text(
                                                                                      '${teNantnewModels[index].regis_data![0].reg_displayname}', // <<< ดึงจาก index [0]
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: const TextStyle(
                                                                                        color: SettingScreen_Color.Colors_Text2_,
                                                                                        fontFamily: Font_.Fonts_T,
                                                                                      ),
                                                                                    ),
                                                                            ),

                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Center(
                                                                                child: (teNantnewModels[index].regis_data![0].reg_userid != null && teNantnewModels[index].regis_data![0].reg_userid != '')
                                                                                    ? SizedBox(
                                                                                        width: 150,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: null,
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.grey[500], // สีเทาแบบ disabled
                                                                                            foregroundColor: Colors.white,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                            ),
                                                                                          ),
                                                                                          child: const Text(
                                                                                            'ลงทะเบียนแล้ว',
                                                                                            textAlign: TextAlign.center,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox(
                                                                                        width: 150,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: (teNantnewModels[index].regis_data![0].reg_id_card != null && teNantnewModels[index].regis_data![0].reg_id_card != '')
                                                                                              ? () => _showRegisterlineDialog(
                                                                                                    context,
                                                                                                    teNantnewModels[index].tax!,
                                                                                                    teNantnewModels[index].regis_data![0].line_regis_url!,
                                                                                                  )
                                                                                              : () => Dialog_error(context, 'กรุณาเปิดใช้งาน User ก่อน'),
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.green,
                                                                                            foregroundColor: Colors.white,
                                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                                                          ),
                                                                                          child: const Text(
                                                                                            'ลงทะเบียนไลน์',
                                                                                            textAlign: TextAlign.center,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                          ),
                                                                                        )),
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Align(
                                                                                alignment: Alignment.center,
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    Edit_Tenantnew(context, index);
                                                                                  },
                                                                                  child: Container(
                                                                                      width: 100,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.red,
                                                                                        borderRadius: BorderRadius.circular(6),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(1.0),
                                                                                      child: SizedBox(
                                                                                        width: 100,
                                                                                        child: ElevatedButton(
                                                                                          onPressed: () => Edit_Tenantnew(context, index),
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.red,
                                                                                            foregroundColor: Colors.white,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(6),
                                                                                            ),
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                                                          ),
                                                                                          child: const Text(
                                                                                            'แก้ไข',
                                                                                            textAlign: TextAlign.center,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                          ),
                                                                                        ),
                                                                                      )),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            // Expanded(
                                                                            //   flex: 1,
                                                                            //   child: Align(
                                                                            //     alignment: Alignment.centerLeft,
                                                                            //     child: Padding(
                                                                            //       padding: const EdgeInsets.all(2.0),
                                                                            //       child: (regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.username).join(', ').toString() != '')
                                                                            //           ? InkWell(
                                                                            //               child: Container(
                                                                            //                 // width: 100,
                                                                            //                 decoration: const BoxDecoration(
                                                                            //                   color: Colors.blue,
                                                                            //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                                                            //                 ),
                                                                            //                 padding: const EdgeInsets.all(4.0),
                                                                            //                 child: const Center(
                                                                            //                   child: Text(
                                                                            //                     'Reset',
                                                                            //                     style: TextStyle(
                                                                            //                       color: Colors.white,
                                                                            //                       fontWeight: FontWeight.bold,
                                                                            //                       fontFamily: Font_.Fonts_T,
                                                                            //                     ),
                                                                            //                   ),
                                                                            //                 ),
                                                                            //               ),
                                                                            //               onTap: () async {
                                                                            //                 String password = md5.convert(utf8.encode('111111')).toString();

                                                                            //                 SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                            //                 String? ren = preferences.getString('renTalSer');
                                                                            //                 String? renTalname_s = preferences.getString('renTalName');

                                                                            //                 var Cust_n = '${teNantModels[index].custno}';
                                                                            //                 var User_U = '${regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.ser.toString()).first}';
                                                                            //                 print('Cust_n>>$Cust_n>>>User_U>>>$User_U');
                                                                            //                 String url = '${MyConstant().domain}/UpC_custno_reset_pass.php?isAdd=true&ren=$ren&Pn=$renTalname_s&cust_no=$Cust_n&user_U=$User_U&Pass_U=$password';
                                                                            //                 print('url:resetpass $url');

                                                                            //                 try {
                                                                            //                   var response = await httpClient.get(Uri.parse(url));

                                                                            //                   var result = json.decode(response.body);
                                                                            //                   print(result);
                                                                            //                   print(result);
                                                                            //                   if (result.toString() == 'true') {
                                                                            //                     Insert_log.Insert_logs('บัญชี', 'บัญชี>>บัญชีผู้เช่า>>Passwd>>111111(${teNantModels[index].custno})');

                                                                            //                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขข้อมูลเสร็จสิ้น !!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))));
                                                                            //                   } else {
                                                                            //                     ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                       const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //                     );
                                                                            //                   }
                                                                            //                 } catch (e) {
                                                                            //                   ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                     const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //                   );
                                                                            //                 }

                                                                            //                 return showDialog(
                                                                            //                     barrierDismissible: true,
                                                                            //                     context: context,
                                                                            //                     builder: (_) {
                                                                            //                       Timer(const Duration(milliseconds: 3600), () {
                                                                            //                         Navigator.of(context).pop();
                                                                            //                       });
                                                                            //                       return Dialog(
                                                                            //                         child: Expanded(
                                                                            //                           child: SizedBox(
                                                                            //                             height: 70,
                                                                            //                             child: Column(
                                                                            //                               children: [
                                                                            //                                 SizedBox(
                                                                            //                                   height: 20,
                                                                            //                                   // width: 100,
                                                                            //                                   child: Text(
                                                                            //                                     'Password : 111111',
                                                                            //                                     style: TextStyle(
                                                                            //                                       color: Colors.black,
                                                                            //                                       // fontWeight: FontWeight.bold,
                                                                            //                                       fontFamily: Font_.Fonts_T,
                                                                            //                                     ),
                                                                            //                                   ),
                                                                            //                                 ),
                                                                            //                                 SizedBox(
                                                                            //                                   height: 50,
                                                                            //                                   width: 100,
                                                                            //                                   child: FittedBox(
                                                                            //                                     fit: BoxFit.cover,
                                                                            //                                     child: Image.asset(
                                                                            //                                       "images/gif-LOGOchao.gif",
                                                                            //                                       fit: BoxFit.fitWidth,
                                                                            //                                       height: 20,
                                                                            //                                       width: 100,
                                                                            //                                     ),
                                                                            //                                   ),
                                                                            //                                 ),
                                                                            //                               ],
                                                                            //                             ),
                                                                            //                           ),
                                                                            //                         ),
                                                                            //                       );
                                                                            //                     });
                                                                            //               },
                                                                            //             )
                                                                            //           : SizedBox(),
                                                                            // (regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.username).join(', ').toString() == '')
                                                                            //     ? Text('')
                                                                            //     : TextFormField(
                                                                            //         readOnly: true,
                                                                            //         style: TextStyle(fontFamily: Font_.Fonts_T, fontSize: 12),
                                                                            //         textAlign: TextAlign.start,
                                                                            //         // controller:
                                                                            //         //     Add_Number_area_,
                                                                            //         validator: (value) {
                                                                            //           if (value == null || value.isEmpty) {
                                                                            //             return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                                            //           }
                                                                            //           // if (int.parse(value.toString()) < 13) {
                                                                            //           //   return '< 13';
                                                                            //           // }
                                                                            //           return null;
                                                                            //         },

                                                                            //         initialValue: (regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.passwd).join(', ').toString() != '') ? 'XXXXXX' : '',
                                                                            //         onFieldSubmitted: (value) async {
                                                                            //           String password = md5.convert(utf8.encode(value)).toString();

                                                                            //           SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                            //           String? ren = preferences.getString('renTalSer');
                                                                            //           String? renTalname_s = preferences.getString('renTalName');

                                                                            //           var Cust_n = '${teNantModels[index].custno}';
                                                                            //           var Cid = '';
                                                                            //           var User_U = '${regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.username.toString()).first}';

                                                                            //           var Pass_U = '$password';
                                                                            //           var Accesstoken = '';
                                                                            //           var Idtoken = '';
                                                                            //           var Userid = '';
                                                                            //           var Displayname = '';
                                                                            //           var C_name = '${teNantModels[index].cname}';

                                                                            //           String url = '${MyConstant().domain}/UpC_custno_cid_Informa.php?isAdd=true&ren=$ren&Pn=$renTalname_s&cust_no=$Cust_n&Cid=$Cid&user_U=$User_U&pass_U=$Pass_U&Accesstoken=$Accesstoken&Idtoken=$Idtoken&Userid=$Userid&Displayname=$Displayname&c_name=$C_name';

                                                                            //           try {
                                                                            //             var response = await httpClient.get(Uri.parse(url));

                                                                            //             var result = json.decode(response.body);
                                                                            //             print(result);
                                                                            //             print(result);
                                                                            //             if (result.toString() == 'true') {
                                                                            //               Insert_log.Insert_logs('บัญชี', 'บัญชี>>บัญชีผู้เช่า>>Passwd>>$value(${teNantModels[index].custno})');

                                                                            //               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขข้อมูลเสร็จสิ้น !!', style: TextStyle(color: Colors.black, fontFamily: Font_.Fonts_T))));
                                                                            //             } else {
                                                                            //               ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                 const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //               );
                                                                            //             }
                                                                            //           } catch (e) {
                                                                            //             ScaffoldMessenger.of(context).showSnackBar(
                                                                            //               const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //             );
                                                                            //           }
                                                                            //           setState(() {
                                                                            //             checkPreferance();
                                                                            //             read_GC_rental();

                                                                            //             read_GC_tenant();
                                                                            //             read_GC_Regis();
                                                                            //           });
                                                                            //         },
                                                                            //         // maxLength: 4,
                                                                            //         cursorColor: Colors.green,
                                                                            //         decoration: InputDecoration(
                                                                            //             labelText: 'ใส่ได้เฉพาะ A-Z a-z 0-9 _ @ .',
                                                                            //             // hintText: 'ใส่ได้เฉพาะ A-Z a-z 0-9 _ @ .',
                                                                            //             fillColor: Colors.white.withOpacity(0.3),
                                                                            //             filled: true,
                                                                            //             // prefixIcon:
                                                                            //             //     const Icon(Icons.person_pin, color: Colors.black),
                                                                            //             // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                            //             focusedBorder: const OutlineInputBorder(
                                                                            //               borderRadius: BorderRadius.only(
                                                                            //                 topRight: Radius.circular(15),
                                                                            //                 topLeft: Radius.circular(15),
                                                                            //                 bottomRight: Radius.circular(15),
                                                                            //                 bottomLeft: Radius.circular(15),
                                                                            //               ),
                                                                            //               borderSide: BorderSide(
                                                                            //                 width: 1,
                                                                            //                 color: Colors.black,
                                                                            //               ),
                                                                            //             ),
                                                                            //             enabledBorder: const OutlineInputBorder(
                                                                            //               borderRadius: BorderRadius.only(
                                                                            //                 topRight: Radius.circular(15),
                                                                            //                 topLeft: Radius.circular(15),
                                                                            //                 bottomRight: Radius.circular(15),
                                                                            //                 bottomLeft: Radius.circular(15),
                                                                            //               ),
                                                                            //               borderSide: BorderSide(
                                                                            //                 width: 1,
                                                                            //                 color: Colors.grey,
                                                                            //               ),
                                                                            //             ),
                                                                            //             // labelText:
                                                                            //             //     'เลขเรื่มต้น 1-xxx',
                                                                            //             labelStyle: TextStyle(
                                                                            //               fontSize: 11,
                                                                            //               color: Colors.red[700],
                                                                            //               fontFamily: Font_.Fonts_T,
                                                                            //             )),
                                                                            //         inputFormatters: <TextInputFormatter>[
                                                                            //           FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_.@]')),
                                                                            //         ],
                                                                            //       ),
                                                                            // ),
                                                                            // ),
                                                                            //     AutoSizeText(
                                                                            //   minFontSize:
                                                                            //       10,
                                                                            //   maxFontSize:
                                                                            //       25,
                                                                            //   maxLines:
                                                                            //       1,
                                                                            //   (teNantModels[index].passw == null)
                                                                            //       ? ''
                                                                            //       : '******',
                                                                            //   textAlign:
                                                                            //       TextAlign.start,
                                                                            //   style: const TextStyle(
                                                                            //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //       fontFamily: Font_.Fonts_T),
                                                                            // ),
                                                                            // ),
                                                                            // Expanded(
                                                                            //   flex: 1,
                                                                            //   child: Align(
                                                                            //     alignment: Alignment.centerLeft,
                                                                            //     child: Padding(
                                                                            //       padding: const EdgeInsets.all(2.0),
                                                                            //       child: (regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.username).join(', ').toString() != '')
                                                                            //           ? InkWell(
                                                                            //               child: Container(
                                                                            //                 // width: 100,
                                                                            //                 decoration: const BoxDecoration(
                                                                            //                   color: Colors.red,
                                                                            //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                                                            //                 ),
                                                                            //                 padding: const EdgeInsets.all(4.0),
                                                                            //                 child: const Center(
                                                                            //                   child: Text(
                                                                            //                     'Delete',
                                                                            //                     style: TextStyle(
                                                                            //                       color: Colors.white,
                                                                            //                       fontWeight: FontWeight.bold,
                                                                            //                       fontFamily: Font_.Fonts_T,
                                                                            //                     ),
                                                                            //                   ),
                                                                            //                 ),
                                                                            //               ),
                                                                            //               onTap: () async {
                                                                            //                 PanaraConfirmDialog.showAnimatedGrow(
                                                                            //                   context,
                                                                            //                   title: "คำเตือน",
                                                                            //                   message: "คุณต้องการยกเลิกการลงทะเบียน Line กับระบบ",
                                                                            //                   confirmButtonText: "ยืนยัน",
                                                                            //                   cancelButtonText: "ยกเลิก",
                                                                            //                   onTapConfirm: () async {
                                                                            //                     String password = md5.convert(utf8.encode('111111')).toString();

                                                                            //                     SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                            //                     String? ren = preferences.getString('renTalSer');
                                                                            //                     String? renTalname_s = preferences.getString('renTalName');

                                                                            //                     var Cust_n = '${teNantModels[index].custno}';
                                                                            //                     var tax_n = '${regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.username).join(', ').toString()}';
                                                                            //                     var User_U = '${regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.ser.toString()).first}';
                                                                            //                     print('Cust_n>>$Cust_n>>>User_U>>>$User_U >>>> $tax_n');
                                                                            //                     String url = '${MyConstant().domain}/De_custno_Line.php?isAdd=true&ren=$ren&Pn=$renTalname_s&cust_no=$Cust_n&user_U=$User_U&Pass_U=$password';

                                                                            //                     try {
                                                                            //                       var response = await httpClient.get(Uri.parse(url));

                                                                            //                       var result = json.decode(response.body);
                                                                            //                       print(result);
                                                                            //                       print(result);
                                                                            //                       if (result.toString() == 'true') {
                                                                            //                         read_GC_tenant();
                                                                            //                         read_GC_Regis();
                                                                            //                         Insert_log.Insert_logs('ผู้เช่า', 'บัญชีผู้เช่า>>ลบ Line User');

                                                                            //                         // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขข้อมูลเสร็จสิ้น !!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))));
                                                                            //                       } else {
                                                                            //                         ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                           const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //                         );
                                                                            //                       }
                                                                            //                     } catch (e) {
                                                                            //                       ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                         const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //                       );
                                                                            //                     }

                                                                            //                     // Insert_log.Insert_logs('บัญชีผู้เช่า', 'ลบ Line User ');
                                                                            //                     Navigator.pop(context);
                                                                            //                   },
                                                                            //                   onTapCancel: () {
                                                                            //                     Navigator.pop(context);
                                                                            //                   },
                                                                            //                   panaraDialogType: PanaraDialogType.warning,
                                                                            //                 );

                                                                            //                 // String password = md5.convert(utf8.encode('111111')).toString();

                                                                            //                 // SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                            //                 // String? ren = preferences.getString('renTalSer');
                                                                            //                 // String? renTalname_s = preferences.getString('renTalName');

                                                                            //                 // var Cust_n = '${teNantModels[index].custno}';
                                                                            //                 // var User_U = '${regisModels.where((model) => model.rser == '$ser_ren' && model.custno == '${teNantModels[index].custno}').map((model) => model.ser.toString()).first}';
                                                                            //                 // print('Cust_n>>$Cust_n>>>User_U>>>$User_U');
                                                                            //                 // String url = '${MyConstant().domain}/UpC_custno_reset_pass.php?isAdd=true&ren=$ren&Pn=$renTalname_s&cust_no=$Cust_n&user_U=$User_U&Pass_U=$password';

                                                                            //                 // try {
                                                                            //                 //   var response = await httpClient.get(Uri.parse(url));

                                                                            //                 //   var result = json.decode(response.body);
                                                                            //                 //   print(result);
                                                                            //                 //   print(result);
                                                                            //                 //   if (result.toString() == 'true') {
                                                                            //                 //     Insert_log.Insert_logs('บัญชี', 'บัญชี>>บัญชีผู้เช่า>>Passwd>>111111(${teNantModels[index].custno})');

                                                                            //                 //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขข้อมูลเสร็จสิ้น !!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))));
                                                                            //                 //   } else {
                                                                            //                 //     ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                 //       const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //                 //     );
                                                                            //                 //   }
                                                                            //                 // } catch (e) {
                                                                            //                 //   ScaffoldMessenger.of(context).showSnackBar(
                                                                            //                 //     const SnackBar(content: Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T))),
                                                                            //                 //   );
                                                                            //                 // }

                                                                            //                 // return showDialog(
                                                                            //                 //     barrierDismissible: true,
                                                                            //                 //     context: context,
                                                                            //                 //     builder: (_) {
                                                                            //                 //       Timer(const Duration(milliseconds: 3600), () {
                                                                            //                 //         Navigator.of(context).pop();
                                                                            //                 //       });
                                                                            //                 //       return Dialog(
                                                                            //                 //         child: Expanded(
                                                                            //                 //           child: SizedBox(
                                                                            //                 //             height: 70,
                                                                            //                 //             child: Column(
                                                                            //                 //               children: [
                                                                            //                 //                 SizedBox(
                                                                            //                 //                   height: 20,
                                                                            //                 //                   // width: 100,
                                                                            //                 //                   child: Text(
                                                                            //                 //                     'Password : 111111',
                                                                            //                 //                     style: TextStyle(
                                                                            //                 //                       color: Colors.black,
                                                                            //                 //                       // fontWeight: FontWeight.bold,
                                                                            //                 //                       fontFamily: Font_.Fonts_T,
                                                                            //                 //                     ),
                                                                            //                 //                   ),
                                                                            //                 //                 ),
                                                                            //                 //                 SizedBox(
                                                                            //                 //                   height: 50,
                                                                            //                 //                   width: 100,
                                                                            //                 //                   child: FittedBox(
                                                                            //                 //                     fit: BoxFit.cover,
                                                                            //                 //                     child: Image.asset(
                                                                            //                 //                       "images/gif-LOGOchao.gif",
                                                                            //                 //                       fit: BoxFit.fitWidth,
                                                                            //                 //                       height: 20,
                                                                            //                 //                       width: 100,
                                                                            //                 //                     ),
                                                                            //                 //                   ),
                                                                            //                 //                 ),
                                                                            //                 //               ],
                                                                            //                 //             ),
                                                                            //                 //           ),
                                                                            //                 //         ),
                                                                            //                 //       );
                                                                            //                 //     });
                                                                            //               },
                                                                            //             )
                                                                            //           : SizedBox(),
                                                                            //     ),
                                                                            //   ),
                                                                            // ),
                                                                            // Expanded(
                                                                            //     flex: 1,
                                                                            //     child: StreamBuilder(
                                                                            //         stream: Stream<void>.periodic(const Duration(seconds: 1), (i) => i).take(1),
                                                                            //         // stream: Stream<void>.periodic(const Duration(seconds: 0)).take(1),
                                                                            //         builder: (context, snapshot) {
                                                                            //           return FutureBuilder<int>(
                                                                            //             future: read_GC_tenant_where(index),
                                                                            //             initialData: 0, // Set an initial value
                                                                            //             builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                                                            //               if (snapshot.connectionState == ConnectionState.waiting) {
                                                                            //                 return Text(
                                                                            //                   '0',
                                                                            //                   maxLines: 1,
                                                                            //                   textAlign: TextAlign.end,
                                                                            //                   style: const TextStyle(
                                                                            //                     color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //                     fontFamily: Font_.Fonts_T,
                                                                            //                   ),
                                                                            //                 );
                                                                            //               } else if (snapshot.hasError) {
                                                                            //                 return Text(
                                                                            //                   '0',
                                                                            //                   maxLines: 1,
                                                                            //                   textAlign: TextAlign.end,
                                                                            //                   style: const TextStyle(
                                                                            //                     color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //                     fontFamily: Font_.Fonts_T,
                                                                            //                   ),
                                                                            //                 );
                                                                            //               } else {
                                                                            //                 return Text(
                                                                            //                   snapshot.data.toString(),
                                                                            //                   maxLines: 1,
                                                                            //                   textAlign: TextAlign.end,
                                                                            //                   style: const TextStyle(
                                                                            //                     color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //                     fontFamily: Font_.Fonts_T,
                                                                            //                   ),
                                                                            //                 );
                                                                            //               }
                                                                            //             },
                                                                            //           );
                                                                            //         })),
                                                                            // Expanded(
                                                                            //     flex: 1,
                                                                            //     child: StreamBuilder(
                                                                            //         stream: Stream<void>.periodic(const Duration(seconds: 1), (i) => i).take(1),
                                                                            //         builder: (context, snapshot) {
                                                                            //           return FutureBuilder<String>(
                                                                            //             future: read_GC_tenant_wherecids(index),
                                                                            //             builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                                                            //               if (snapshot.connectionState == ConnectionState.waiting) {
                                                                            //                 return Text(
                                                                            //                   '0.00',
                                                                            //                   maxLines: 1,
                                                                            //                   textAlign: TextAlign.end,
                                                                            //                   style: const TextStyle(
                                                                            //                     color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //                     fontFamily: Font_.Fonts_T,
                                                                            //                   ),
                                                                            //                 );
                                                                            //               } else if (snapshot.hasError) {
                                                                            //                 return Text(
                                                                            //                   '0.00',
                                                                            //                   maxLines: 1,
                                                                            //                   textAlign: TextAlign.end,
                                                                            //                   style: const TextStyle(
                                                                            //                     color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //                     fontFamily: Font_.Fonts_T,
                                                                            //                   ),
                                                                            //                 );
                                                                            //               } else {
                                                                            //                 return Text(
                                                                            //                   snapshot.data.toString(),
                                                                            //                   maxLines: 1,
                                                                            //                   textAlign: TextAlign.end,
                                                                            //                   style: const TextStyle(
                                                                            //                     color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            //                     fontFamily: Font_.Fonts_T,
                                                                            //                   ),
                                                                            //                 );
                                                                            //               }
                                                                            //             },
                                                                            //           );
                                                                            //         })),
                                                                            // Expanded(
                                                                            //   flex: 1,
                                                                            //   child: Row(
                                                                            //     mainAxisAlignment: MainAxisAlignment.end,
                                                                            //     children: [
                                                                            //       Padding(
                                                                            //         padding: const EdgeInsets.all(0.0),
                                                                            //         child: InkWell(
                                                                            //           onTap: () {
                                                                            //             print(teNantModels[index].custno);
                                                                            //             setState(() {
                                                                            //               // widget.updateMessage('0');
                                                                            //               Status_cuspang = 1;

                                                                            //               cust_no = teNantModels[index].custno!;
                                                                            //             });
                                                                            //             // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                                                                            //             //   return Details_Rental_customer(
                                                                            //             //     name_custno: cust_no,
                                                                            //             //   );
                                                                            //             // }));
                                                                            //           },
                                                                            //           child: Container(
                                                                            //               width: 130,
                                                                            //               decoration: BoxDecoration(
                                                                            //                 color: Colors.indigo.shade100,
                                                                            //                 borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                            //                 border: Border.all(color: Colors.white, width: 1),
                                                                            //               ),
                                                                            //               padding: const EdgeInsets.all(2.0),
                                                                            //               child: Translate.TranslateAndSetText('เรียกดู', SettingScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 2)

                                                                            //               //  AutoSizeText(
                                                                            //               //   minFontSize: 10,
                                                                            //               //   maxFontSize: 25,
                                                                            //               //   maxLines: 1,
                                                                            //               //   'เรียกดู',
                                                                            //               //   textAlign: TextAlign.center,
                                                                            //               //   style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                            //               // ),
                                                                            //               ),
                                                                            //         ),
                                                                            //       ),
                                                                            //     ],
                                                                            //   ),
                                                                            // ),
                                                                          ],
                                                                        ),
                                                                      )),
                                                                  // if (index +
                                                                  //         1 ==
                                                                  //     teNantModels
                                                                  //         .length)
                                                                  //   ListTile(
                                                                  //       title: Row(
                                                                  //           mainAxisAlignment:
                                                                  //               MainAxisAlignment.center,
                                                                  //           children: [
                                                                  //         Padding(
                                                                  //           padding:
                                                                  //               const EdgeInsets.all(4.0),
                                                                  //           child:
                                                                  //               Container(
                                                                  //             width: 100,
                                                                  //             decoration: BoxDecoration(
                                                                  //               color: Colors.red[100]!.withOpacity(0.5),
                                                                  //               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                  //             ),
                                                                  //             padding: const EdgeInsets.all(2.0),
                                                                  //             child: AutoSizeText(
                                                                  //               minFontSize: 10,
                                                                  //               maxFontSize: 25,
                                                                  //               maxLines: 1,
                                                                  //               'สิ้นสุด',
                                                                  //               textAlign: TextAlign.center,
                                                                  //               overflow: TextOverflow.ellipsis,
                                                                  //               style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                  //             ),
                                                                  //           ),
                                                                  //         ),
                                                                  //       ])),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        })),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                  width: (Responsive.isDesktop(context))
                                      ? MediaQuery.of(context).size.width * 0.85
                                      : MediaQuery.of(context).size.width,
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
                                                  _scrollController2.animateTo(
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (_scrollController2
                                                    .hasClients) {
                                                  final position =
                                                      _scrollController2
                                                          .position
                                                          .maxScrollExtent;
                                                  _scrollController2.animateTo(
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
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
                                              onTap: _moveUp2,
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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                            InkWell(
                                              onTap: _moveDown2,
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
                            ],
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          );
  }

  Future<void> updated_Customer(scname, stype, typeser, type, cname, attn,
      addr_1, tel, tax, email, indexToEdit) async {}
}
