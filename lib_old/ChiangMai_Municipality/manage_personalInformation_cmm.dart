import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:http/http.dart' as http;

// --------- Project imports (ของคุณ) ----------
import '../Constant/Myconstant.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'unity/API_admin_signature.dart';
import 'unity/API_permission.dart';
import 'unity/Enum.dart';
import 'unity/ReusableSignaturePad.dart';
import 'unity/SecurePrefs_helper.dart';
import 'unity/show_dialog_cmm.dart';

class ManagePersonalInformation_CMM extends StatefulWidget {
  const ManagePersonalInformation_CMM({super.key});

  @override
  State<ManagePersonalInformation_CMM> createState() =>
      _ManagePersonalInformation_CMMState();
}

class _ManagePersonalInformation_CMMState
    extends State<ManagePersonalInformation_CMM> {
  // ---------- State ----------
  String fullNameAdmin = '';
  String positionAdmin = '';
  String proFileUuid = '';
  String sigNatureUuid = '';
  String emailAdmin = '';
  String? userUuid;
  Uint8List? signaturesUrl;
  // String signaturesUrl = '';

  bool _loading = true;
  String? _error;

  // ---------- Controllers ----------
  final TextEditingController controllerFullName = TextEditingController();
  final TextEditingController controllerPosition = TextEditingController();

  // ---------- Signature Keys ----------
  final GlobalKey<SfSignaturePadState> signatureKey1 = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureKey2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    _storedAuthData();
  }

  @override
  void dispose() {
    controllerFullName.dispose();
    controllerPosition.dispose();
    super.dispose();
  }

  // ================================================================
  // Load profile + signature meta
  // ================================================================
  Future<void> _storedAuthData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await read_AdminSignature();
      if (response == null) throw Exception('No response from server');

      final dynamic result = json.decode(response.body);
      final data = (result is Map<String, dynamic>) ? result['data'] : null;

      final profileUuid = data?['profile_uuid'] as String?;
      final profile = data?['profile'] as String?;
      final signatureUuid = data?['signature_uuid'] as String?;
      final positionName = data?['position_name'] as String?;

      // secure storage
      final accessToken =
          await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
      final _userUuid =
          await SecurePrefs.getDecrypted(SecurePrefsType.authUserUuid);
      final userJson =
          await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

      Uint8List? sigBytes;
      if (signatureUuid != null && signatureUuid.isNotEmpty) {
        final sigResp = await img_signatureUuid(signatureUuid: signatureUuid);
        if (sigResp != null && sigResp.statusCode == 200) {
          sigBytes = sigResp.bodyBytes;
        } else {
          //  debugprint('❌ Failed to load signature image');
        }
      }
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        if (!mounted) return;
        setState(() {
          signaturesUrl = sigBytes;
          proFileUuid = profileUuid ?? '';
          sigNatureUuid = signatureUuid ?? '';
          fullNameAdmin = profile ?? '';
          positionAdmin = positionName ?? '';
          controllerFullName.text = fullNameAdmin;
          controllerPosition.text = positionAdmin;
          emailAdmin = (userMap['email'] as String?) ?? '';
          userUuid = _userUuid;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          signaturesUrl = sigBytes;
          proFileUuid = profileUuid ?? '';
          sigNatureUuid = signatureUuid ?? '';
          fullNameAdmin = profile ?? '';
          positionAdmin = positionName ?? '';
          controllerFullName.text = fullNameAdmin;
          controllerPosition.text = positionAdmin;
          userUuid = _userUuid;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ================================================================
  // UI
  // ================================================================
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final innerWidth = (!Responsive.isDesktop(context))
        ? 1400.00
        : MediaQuery.of(context).size.width * 0.85;
    // isDesktop ? MediaQuery.of(context).size.width * 0.85 : 1000.0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Translate.TranslateAndSetText(
                  'ข้อมูลผู้ใช้',
                  SettingScreen_Color.Colors_Text1_,
                  TextAlign.center,
                  FontWeight.bold,
                  FontWeight_.Fonts_T,
                  14,
                  1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ========== Card content with horizontal scroll (bounded) ==========
          _boundedHScroll(
            width: innerWidth,
            child: Container(
              decoration: const BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  _buildHeaderRow(),
                  _buildValueRow(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ========== Actions ==========
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 180,
                  height: 36,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Colors.green.shade400,
                      ),
                    ),
                    onPressed: (_loading)
                        ? null
                        : () async {
                            // เปิด dialog แก้ไขลายเซ็น
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            _editUserSignatures(
                              'แก้ไขลายเซ็นผู้ใช้',
                              1,
                              (userUuid ?? '').toString(),
                            );
                          },
                    child: Translate.TranslateAndSet_TextAutoSize(
                      'แก้ไขลายเซ็น',
                      Colors.black,
                      TextAlign.center,
                      null,
                      Font_.Fonts_T,
                      10,
                      14,
                      1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppbackgroundColor.TiTile_Colors,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            _headerCell('ชื่อผู้ใช้งาน'),
            _headerCell('อีเมล'),
            _headerCell('ตำแหน่ง'),
            _headerCell('ลายเซ็น'),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Translate.TranslateAndSetText(
          text,
          SettingScreen_Color.Colors_Text1_,
          TextAlign.center,
          FontWeight.bold,
          FontWeight_.Fonts_T,
          14,
          1,
        ),
      ),
    );
  }

  // ---------- Values ----------
  Widget _buildValueRow() {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 32, 8, 32),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('กำลังโหลดข้อมูล...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Center(
          child: Text(
            'เกิดข้อผิดพลาด: $_error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Container(
        height: 110,
        decoration: const BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            _valueCell(fullNameAdmin),
            _valueCell(emailAdmin),
            _valueCell(positionAdmin),
            Expanded(
              flex: 2,
              child: Center(
                child: (sigNatureUuid!.isEmpty ||
                        sigNatureUuid == '' ||
                        sigNatureUuid == null)
                    ? SizedBox(
                        child: Icon(Icons.image_not_supported),
                      )
                    : _buildSignaturePreview(signaturesUrl!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueCell(String text) {
    return Expanded(
      flex: 2,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: SettingScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T,
        ),
      ),
    );
  }

  Widget _buildSignaturePreview(Uint8List sigBytes) {
    // ป้องกัน layout shift ด้วยขนาดตายตัว + คลิปโค้งเล็กน้อย
    return SizedBox(
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: (sigBytes == null)
            ? const SizedBox(
                child: Icon(Icons.image_not_supported),
              )
            : FittedBox(
                fit: BoxFit.cover,
                child: Image.memory(
                  sigBytes!,
                  height: 180,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined, size: 28),
                ),
              ),
        // Image.network(
        //   url,
        //   fit: BoxFit.contain,
        //   errorBuilder: (_, __, ___) =>
        //       const Icon(Icons.broken_image_outlined, size: 28),
        //   // cacheHeight/Width จะช่วยลด memory (ปรับได้)
        // ),
      ),
    );
  }

  // ================================================================
  // Dialog: Edit signature
  // ================================================================
  Future<void> _editUserSignatures(
      String title, int type, String usersUuid) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.highlight_off,
                          size: 30, color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
              Center(
                child: Translate.TranslateAndSetText(
                  title,
                  SettingScreen_Color.Colors_Text1_,
                  TextAlign.center,
                  FontWeight.bold,
                  FontWeight_.Fonts_T,
                  16,
                  1,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _boundedHScroll(
                  width: 600,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Translate.TranslateAndSetText(
                              'ลายมือชื่อ',
                              PeopleChaoScreen_Color.Colors_Text2_,
                              TextAlign.left,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              16,
                              1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ReusableSignaturePad(
                              height: 150,
                              width: 500,
                              signatureKey: signatureKey1,
                              onSave: () => handleSave(
                                'uuid_Request',
                                8,
                                signatureKey1,
                                SignatureActionType.saveToFile,
                              ),
                              onClear: () =>
                                  signatureKey1.currentState?.clear(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _primaryButton(
                  text: 'ตกลง',
                  onPressed: () async {
                    if (usersUuid.isEmpty) {
                      Dialog_error(context, 'ไม่พบ UUID : $usersUuid');
                      return;
                    }

                    final Uint8List? signedData = await handleSave(
                      '',
                      0,
                      signatureKey1,
                      SignatureActionType.upload_admin,
                    ) as Uint8List?;

                    if (signedData == null) {
                      Dialog_error(context, 'ไม่สามารถแปลงลายเซ็นเป็นไฟล์ได้');
                      return;
                    }

                    final response = await Post_Signatures_Permission(
                      fileData: signedData,
                      userUuid: usersUuid,
                    );

                    await Future.delayed(const Duration(milliseconds: 200));
                    if (!mounted) return;

                    if (response != null &&
                        (response.statusCode == 200 ||
                            response.statusCode == 201)) {
                      Navigator.of(context).pop(); // ปิด dialog
                      _storedAuthData(); // รีเฟรชข้อมูล
                    } else {
                      Dialog_error(context, 'แก้ไขลายเซ็นล้มเหลว');
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // Small UI helpers
  // ================================================================
  Widget _primaryButton(
      {required String text, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 120,
        height: 40,
        child: ElevatedButton(
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green),
          ),
          onPressed: onPressed,
          child: Translate.TranslateAndSet_TextAutoSize(
            text,
            Colors.white,
            TextAlign.center,
            null,
            Font_.Fonts_T,
            10,
            14,
            1,
          ),
        ),
      ),
    );
  }

  /// ใช้ห่อคอนเทนต์ที่อยู่ใน SingleChildScrollView แนวนอน
  /// เพื่อให้ child ด้านใน "bounded" และสามารถใช้ Expanded/Flexible ได้อย่างปลอดภัย
  Widget _boundedHScroll({required double width, required Widget child}) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        dragStartBehavior: DragStartBehavior.start,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width),
          child: SizedBox(width: width, child: child),
        ),
      ),
    );
  }
}
