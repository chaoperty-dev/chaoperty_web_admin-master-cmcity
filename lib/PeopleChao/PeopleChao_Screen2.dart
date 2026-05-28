// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, duplicate_import, must_be_immutable, body_might_complete_normally_nullable
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:chaoperty/PeopleChao/Move_Area.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/api_cache.dart';

import '../Account/Ac_Sub/Account_Screen.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../ChaoArea/ChaoArea_Screen.dart';
import '../ChaoArea/ChaoRe_contact.dart';
import '../ChaoArea/ChaoRe_contact_add.dart';
import '../ChaoArea/Chao_Return.dart';
import '../ChaoArea/Chao_Return_madjum.dart';
import '../ChiangMai_Municipality/Info_contract_cmm.dart';
import '../ChiangMai_Municipality/Make_contract_CMM/contractParams.dart';
import '../ChiangMai_Municipality/Make_contract_CMM/new_contract_cmm.dart';
import '../Constant/Myconstant.dart';
import '../Home/Home_Screen.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Manage/Manage_Screen.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Responsive/responsive.dart';
import '../Setting/SettingScreen.dart';
import '../Style/colors.dart';
import 'Bills_.dart';
import 'Bills_history.dart';
import 'History_Bills.dart';
import 'Meter_WaterElectric.dart';
import 'Pays_.dart';
import 'Pays_history.dart';
import 'PeopleChao_Screen.dart';
import 'Rental_Information.dart';
import 'Seteing_listmenu.dart';
import 'discount_bill.dart';

class PeopleChaoScreen2 extends StatefulWidget {
  final dynamic Get_Value_NameShop_index;
  final dynamic Get_Value_cid;
  final dynamic Get_Value_status;
  final dynamic updateMessage;
  final dynamic Get_Value_indexpage;

  const PeopleChaoScreen2({
    super.key,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
    this.Get_Value_status,
    this.updateMessage,
    this.Get_Value_indexpage,
  });

  @override
  State<PeopleChaoScreen2> createState() => _PeopleChaoScreen2State();
}

class _PeopleChaoScreen2State extends State<PeopleChaoScreen2> {
  static final _apiCache = ApiCache(ttl: const Duration(seconds: 60));
  final store = ContractStore();
  // --------------------------- State ---------------------------
  int ser_tabbarview_1 = 0,
      _Pakan = 0,
      renTal_lavel = 0,
      _Madjum = 0,
      open_move_area = 0;
  final Formbecause_ = TextEditingController();

  List<TeNantModel> teNantModels = [];
  List<RenTalModel> renTalModels = [];
  List<UserModel> userModels = [];
  List<UserModel> _userModels = <UserModel>[];
  String? areanew,
      areazone,
      namenew,
      namemake,
      Sercid,
      cc_datecid,
      s_datecid,
      l_datecid;

  List tabbarview_1 = ['เงินประกัน', 'ยกเลิกสัญญา', 'ซ่อมบำรุง'];
  List tabbarview_color_1 = [Colors.orange, Colors.red, Colors.green];

  int ser_tabbarview_2 = 0, contact_new = 0, contact_add = 0;
  List tabbarview_2 = [
    'ข้อมูลการเช่า',
    'มิเตอร์น้ำไฟฟ้า',
    'วางบิล',
    // 'ลดหนี้',
    'รับชำระ',
    'ประวัติบิล'
  ];
  List tabbarview_color_2 = [
    Colors.green,
    Colors.blue,
    Colors.brown,
    // Colors.pink,
    Colors.deepPurple,
    Colors.orange
  ];

  String? rtname,
      renTal_user,
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
      tem_page_ser,
      newValuePDFimg_QR,
      renTal_name,
      open_disinv;

  // Date pickers (cancel contract)
  String Value_DateTime_Step2 = '';
  String Value_D_start = '';

  // --------------------------- Lifecycle ---------------------------
  @override
  void initState() {
    super.initState();
    read_GC_teNant();
    read_GC_pkan();
    read_GC_Madjum();
    read_GC_rental();
    // ปลอดภัยกว่า: เผื่อค่า index เดิม null/ไม่ใช่ตัวเลข
    final parsed = int.tryParse('${widget.Get_Value_indexpage}');
    ser_tabbarview_2 = parsed ?? 0;
  }

  // --------------------------- Utilities ---------------------------
  bool _isValidDateStr(String? s) =>
      s != null &&
      s.isNotEmpty &&
      s != '0000-00-00' &&
      DateTime.tryParse('$s 00:00:00') != null;

  DateTime? _dt(String? s) =>
      _isValidDateStr(s) ? DateTime.parse('$s 00:00:00') : null;

  String _fmt(DateTime d) => DateFormat('dd-MM-yyyy').format(d);

  String _remainText(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff > 0) return 'เหลือ $diff วัน';
    if (diff == 0) return 'ครบกำหนดวันนี้';
    return 'เกินกำหนด ${diff.abs()} วัน';
  }

  Color _remainColor(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff > 0) return Colors.green;
    if (diff == 0) return Colors.orange;
    return Colors.red;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'เสนอราคา':
        return Colors.blue;
      case 'เสนอราคา(รับมัดจำ)':
        return Colors.deepPurple;
      case 'ใกล้หมดสัญญา':
        return Colors.orange;
      case 'หมดสัญญา':
        return Colors.red;
      default:
        return Colors.green.shade800;
    }
  }

  BoxDecoration get _cardWhite => BoxDecoration(
        color: Colors.white,
        // color: Colors.white.withOpacity(0.7),
        // borderRadius: BorderRadius.circular(12),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0)),
        boxShadow: [
          BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(.06),
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: const Color(0xFFEAEAEA)),
      );

  Widget _statusBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontFamily: FontWeight_.Fonts_T),
          ),
        ]),
      );

  Widget _dateChip({
    required IconData icon,
    required Color color,
    required String title,
    required DateTime date,
  }) {
    final badgeColor = _remainColor(date);
    return Container(
      height: 80,
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      // padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(10),
      //   border: Border.all(color: const Color(0xFFEFEFEF)),
      // ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        // CircleAvatar(
        //     radius: 14,
        //     backgroundColor: color.withOpacity(0.10),
        //     child: Icon(icon, color: color, size: 16)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          // Text(title,
          //     style: TextStyle(
          //         color: color,
          //         fontWeight: FontWeight.bold,
          //         fontFamily: FontWeight_.Fonts_T)),
          Text(_fmt(date),
              style: TextStyle(
                  color: Colors.black87,
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: badgeColor.withOpacity(0.4)),
          ),
          child: Text(
            _remainText(date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }

  Widget dateChipFromStr({
    required IconData icon,
    required Color color,
    required String title,
    required String? dateStr,
  }) {
    if (!_isValidDateStr(dateStr)) return const SizedBox.shrink();
    final d = DateTime.parse('$dateStr 00:00:00');
    return _dateChip(icon: icon, color: color, title: title, date: d);
  }

  Widget _InfoTile({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget child,
    VoidCallback? onDoubleTap,
  }) {
    return Material(
      key: key,
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onDoubleTap: onDoubleTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5),
                    ),
                    const SizedBox(height: 6),
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _UserPickerDialog({
    required BuildContext context,
    required String namemake,
    required List<UserModel> userModels,
    required Function(UserModel picked) onPicked,
  }) {
    return StatefulBuilder(
      builder: (ctx, setState) {
        final TextEditingController _searchCtrl = TextEditingController();
        // String _norm(String s) => s.toLowerCase().trim();

        // List<UserModel> _filter(String q) {
        //   if (q.trim().isEmpty) return userModels;
        //   final key = _norm(q);
        //   return userModels.where((u) {
        //     final full = '${u.fname ?? ''} ${u.lname ?? ''}'.trim();
        //     return _norm(full).contains(key);
        //   }).toList();
        // }

        // List<UserModel> filtered = _filter(_searchCtrl.text);

        Widget _currentBadge() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.green.withOpacity(0.28)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_rounded,
                    color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'ผู้ทำสัญญาปัจจุบัน: $namemake',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ]),
            );

        String _initials(String? f, String? l) {
          final a = (f ?? '').isNotEmpty ? f!.trim()[0] : '';
          final b = (l ?? '').isNotEmpty ? l!.trim()[0] : '';
          return (a + b).toUpperCase();
        }

        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

            // ---------- Header ----------
            title: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.people_alt_rounded, color: Colors.blue),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'เลือกผู้ทำสัญญา',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ],
            ),

            // ---------- Content ----------
            content: SizedBox(
              width: 440,
              height: MediaQuery.of(ctx).size.height * 0.75,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current badge
                  Align(
                      alignment: Alignment.centerLeft, child: _currentBadge()),
                  const SizedBox(height: 10),

                  // Search field
                  TextField(
                    controller: _searchCtrl,
                    // onChanged: (_) {},
                    onChanged: (text) {
                      //  print(text);
                      text = text.toLowerCase();
                      setState(
                        () {
                          userModels = _userModels.where((teNantModels) {
                            var notTitle =
                                teNantModels.fname.toString().toLowerCase();
                            var notTitle2 =
                                teNantModels.lname.toString().toLowerCase();
                            var notTitle3 =
                                teNantModels.email.toString().toLowerCase();

                            var notTitle8 =
                                teNantModels.tel.toString().toLowerCase();
                            return notTitle.contains(text) ||
                                notTitle2.contains(text) ||
                                notTitle3.contains(text);
                          }).toList();
                        },
                      );
                      if (text.isEmpty) {
                        userModels = _userModels;
                      } else {}
                    },
                    decoration: InputDecoration(
                      hintText: 'ค้นหาชื่อ/นามสกุล…',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.black54),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black54),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Result info
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ผลลัพธ์ ${userModels.length} รายการ',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // List
                  ValueListenableBuilder<TextEditingValue>(
                      valueListenable:
                          Formbecause_, // ต้องเป็น controller เดียวกับ TextFormField
                      builder: (ctx, value, _) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(ctx).size.height * 0.5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFEFEFEF)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: userModels.isEmpty
                                  ? Container(
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'ไม่พบรายชื่อที่ค้นหา',
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: userModels.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(
                                        height: 1,
                                        color: Color(0xFFF2F2F2),
                                      ),
                                      itemBuilder: (context, index) {
                                        final u = userModels[index];
                                        final full =
                                            '${u.fname ?? ''} ${u.lname ?? ''}'
                                                .trim();
                                        final isCurrent =
                                            full.isNotEmpty && full == namemake;

                                        return InkWell(
                                          onTap: () {
                                            // onPicked(u);
                                            // Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: isCurrent
                                                      ? Colors.green
                                                          .withOpacity(0.12)
                                                      : Colors.blue
                                                          .withOpacity(0.12),
                                                  child: Text(
                                                    _initials(u.fname, u.lname),
                                                    style: TextStyle(
                                                      color: isCurrent
                                                          ? Colors.green
                                                          : Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              full.isEmpty
                                                                  ? '-'
                                                                  : full,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),
                                                          if (isCurrent)
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 8),
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .green
                                                                    .withOpacity(
                                                                        0.08),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            999),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .green
                                                                      .withOpacity(
                                                                          0.28),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'ปัจจุบัน',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize:
                                                                      11.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      if ((u.email ?? '')
                                                              .isNotEmpty ||
                                                          (u.tel ?? '')
                                                              .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 2.5),
                                                          child: Row(
                                                            children: [
                                                              if ((u.email ??
                                                                      '')
                                                                  .isNotEmpty) ...[
                                                                const Icon(
                                                                  Icons
                                                                      .mail_outline,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .black38,
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Expanded(
                                                                  child: Text(
                                                                    u.email!,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black54,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                              if ((u.email ??
                                                                          '')
                                                                      .isNotEmpty &&
                                                                  (u.tel ?? '')
                                                                      .isNotEmpty)
                                                                const SizedBox(
                                                                    width: 12),
                                                              if ((u.tel ?? '')
                                                                  .isNotEmpty) ...[
                                                                const Icon(
                                                                  Icons
                                                                      .call_outlined,
                                                                  size: 14,
                                                                  color: Colors
                                                                      .black38,
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                  u.tel!,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: Colors.black26),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        );
                      })
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // --------------------------- API Reads ---------------------------
  Future<void> read_user_ren() async {
    userModels.clear();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final url = '${MyConstant().domain}/GC_User_ren.php?isAdd=true&ren=$ren';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      for (var map in result) {
        userModels.add(UserModel.fromJson(map));
        _userModels.add(UserModel.fromJson(map));
      }
      // เรียงตามชื่อ
      userModels.sort((a, b) =>
          ('${a.fname} ${a.lname}').compareTo('${b.fname} ${b.lname}'));
      setState(() {});
    } catch (_) {}
  }

  Future<void> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    final cacheKey = 'read_GC_rental_$ren';

    if (_apiCache.isValid(cacheKey)) {
      final cachedData = _apiCache.get(cacheKey);
      if (cachedData != null) {
        setState(() {
          renTalModels.clear();
          for (var map in cachedData) {
            final renTalModel = RenTalModel.fromJson(map);
            renTal_user = renTalModel.ser;
            foder = renTalModel.dbn;
            rtname = renTalModel.rtname?.trim();
            type = renTalModel.type?.trim();
            typex = renTalModel.typex?.trim();
            renname = renTalModel.pn?.trim();
            bill_name = renTalModel.bill_name?.trim();
            bill_addr = renTalModel.bill_addr?.trim();
            bill_tax = renTalModel.bill_tax?.trim();
            bill_tel = renTalModel.bill_tel?.trim();
            bill_email = renTalModel.bill_email?.trim();
            bill_default = renTalModel.bill_default;
            bill_tser = renTalModel.tser;
            tem_page_ser = renTalModel.tem_page?.trim();
            open_disinv = renTalModel.open_disinv;
            open_move_area = int.tryParse(renTalModel.move_area ?? '0') ?? 0;
            renTalModels.add(renTalModel);
          }
        });
        return;
      }
    }

    if (renTalModels.isNotEmpty) {
      setState(() => renTalModels.clear());
    }

    final url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result != null) {
        if (result is List) _apiCache.set(cacheKey, result);
        for (var map in result) {
          final renTalModel = RenTalModel.fromJson(map);
          setState(() {
            renTal_user = renTalModel.ser;
            foder = renTalModel.dbn;
            rtname = renTalModel.rtname?.trim();
            type = renTalModel.type?.trim();
            typex = renTalModel.typex?.trim();
            renname = renTalModel.pn?.trim();
            bill_name = renTalModel.bill_name?.trim();
            bill_addr = renTalModel.bill_addr?.trim();
            bill_tax = renTalModel.bill_tax?.trim();
            bill_tel = renTalModel.bill_tel?.trim();
            bill_email = renTalModel.bill_email?.trim();
            bill_default = renTalModel.bill_default;
            bill_tser = renTalModel.tser;
            tem_page_ser = renTalModel.tem_page?.trim();
            open_disinv = renTalModel.open_disinv;
            open_move_area = int.tryParse(renTalModel.move_area ?? '0') ?? 0;
            renTalModels.add(renTalModel);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> read_GC_pkan() async {
    setState(() => _Pakan = 0);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;
    final url =
        '${MyConstant().domain}/GC_Pakan.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result.toString() == 'true') setState(() => _Pakan = 1);
      setState(() => renTal_lavel =
          int.tryParse(preferences.getString('lavel').toString()) ?? 0);
    } catch (_) {
      setState(() => renTal_lavel =
          int.tryParse(preferences.getString('lavel').toString()) ?? 0);
    }
  }

  Future<void> read_GC_Madjum() async {
    setState(() => _Madjum = 0);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;
    final url =
        '${MyConstant().domain}/GC_Madjum.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result.toString() == 'true') setState(() => _Madjum = 1);
      setState(() => renTal_lavel =
          int.tryParse(preferences.getString('lavel').toString()) ?? 0);
    } catch (_) {
      setState(() => renTal_lavel =
          int.tryParse(preferences.getString('lavel').toString()) ?? 0);
    }
  }

  Future<void> read_GC_teNant() async {
    teNantModels.clear();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;
    final url =
        '${MyConstant().domain}/GC_tenantlook.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result != null) {
        for (var map in result) {
          final teNantModel = TeNantModel.fromJson(map);
          setState(() {
            areanew = teNantModel.area_c;
            areazone = teNantModel.zn;
            namemake = teNantModel.name_user;
            namenew = teNantModel.cname;
            Sercid = teNantModel.ser;
            cc_datecid = teNantModel.cc_date;
            s_datecid = teNantModel.sdate;
            l_datecid = teNantModel.ldate;
            teNantModels.add(teNantModel);
          });
        }
      } else {
        final _route = preferences.getString('route');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => AdminScafScreen(route: _route)),
            (route) => false);
      }
    } catch (_) {}
  }

  // --------------------------- Build ---------------------------
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Status Header =====
        if (contact_new != 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Container(
              decoration: _cardWhite,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หัวข้อสถานะ + ปุ่มการทำงาน
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'สถานะ : ',
                              style: TextStyle(
                                color: AdminScafScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                            '${widget.Get_Value_NameShop_index}' == '1'
                                ? _statusBadge('${widget.Get_Value_status}',
                                    _statusColor('${widget.Get_Value_status}'))
                                : _statusBadge(
                                    'เสนอราคา', _statusColor('เสนอราคา')),
                          ],
                        ),
                      ),
                      // ปุ่ม

                      Wrap(
                        spacing: 8,
                        children: [
                          InkWell(
                            onTap: () async {
                              if ('${widget.Get_Value_NameShop_index}' == '1') {
                                setState(() =>
                                    contact_new = (contact_new == 2 ? 0 : 2));
                              } else {
                                if (_Madjum == 1) {
                                  setState(() =>
                                      contact_new = (contact_new == 4 ? 0 : 4));
                                } else {
                                  cancel(context);
                                }
                              }
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final name = prefs.getString('fname');
                              Insert_log.Insert_logs(
                                  'หน้าหลัก', '$name>ปุ่มยกเลิกสัญญา');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                '${widget.Get_Value_NameShop_index}' == '1'
                                    ? 'ยกเลิกสัญญา'
                                    : 'ยกเลิกใบเสนอราคา',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (widget.Get_Value_status == 'ใกล้หมดสัญญา' ||
                              widget.Get_Value_status == 'หมดสัญญา')
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  if (contact_new == 1) {
                                    contact_new = 0;
                                  } else {
                                    contact_new = 1;
                                  }
                                });
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                var name = preferences.getString('fname');
                                Insert_log.Insert_logs(
                                    'หน้าหลัก', '$name>ปุ่มต่อสัญญา');
                              },
                              // onTap: () async {
                              //   setState(() =>
                              //       contact_new = (contact_new == 1 ? 0 : 1));
                              //   final prefs =
                              //       await SharedPreferences.getInstance();
                              //   final name = prefs.getString('fname');
                              //   Insert_log.Insert_logs(
                              //       'หน้าหลัก', '$name>ปุ่มต่อสัญญา');
                              // },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.green[600],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  contact_new == 1
                                      ? 'ยกเลิกต่อสัญญา'
                                      : 'ต่อสัญญา',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEFEFEF)),
                  const SizedBox(height: 12),

                  // วันที่สำคัญ
                  // Row(
                  //   children: [
                  //     Expanded(child: SizedBox()),
                  //     dateChipFromStr(
                  //         icon: Icons.event_available_rounded,
                  //         color: Colors.blue,
                  //         title: 'วันที่หมดสัญญา',
                  //         dateStr: l_datecid),
                  //     Expanded(child: SizedBox()),
                  //     dateChipFromStr(
                  //         icon: Icons.event_busy_rounded,
                  //         color: Colors.red,
                  //         title: 'กำหนดยกเลิกสัญญา',
                  //         dateStr: cc_datecid),
                  //   ],
                  // ),
                  (!Responsive.isDesktop(context) ||
                          MediaQuery.of(context).size.width < 1370)
                      ? ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // ✅ สำคัญมาก
                            primary: false,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 280,
                                  height: 80,
                                  child: _InfoTile(
                                    icon: Icons.map,
                                    iconColor: Colors.blueGrey,
                                    label: 'โซนพื้นที่',
                                    child: Text(
                                      '${areazone ?? '-'}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                  height: 80,
                                  child: _InfoTile(
                                    icon: Icons.grid_view_rounded,
                                    iconColor: Colors.indigo,
                                    label: 'รหัสพื้นที่',
                                    child: Text(
                                      '${areanew ?? '-'}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 15,
                                // ),
                                if (cc_datecid.toString() == '0000-00-00' ||
                                    cc_datecid == '' ||
                                    cc_datecid == null)
                                  dateChipFromStr(
                                      icon: Icons.event_available_rounded,
                                      color: Colors.blue,
                                      title: 'วันที่หมดสัญญา',
                                      dateStr: l_datecid)
                                else
                                  SizedBox(),
                                // SizedBox(
                                //   width: 15,
                                // ),

                                if (cc_datecid.toString() == '0000-00-00' ||
                                    cc_datecid == '' ||
                                    cc_datecid == null)
                                  InkWell(
                                    onDoubleTap: () =>
                                        cancel_FutureCidCancel(context),
                                    child: dateChipFromStr(
                                        icon: Icons.event_busy_rounded,
                                        color: Colors.red,
                                        title: 'กำหนดยกเลิกสัญญา',
                                        dateStr: cc_datecid),
                                  )
                                else
                                  InkWell(
                                    onDoubleTap: () =>
                                        cancel_FutureCidCancel(context),
                                    child: dateChipFromStr(
                                        icon: Icons.event_busy_rounded,
                                        color: Colors.red,
                                        title: 'กำหนดยกเลิกสัญญา',
                                        dateStr: cc_datecid),
                                  ),

                                // Tiles
                                // Expanded(child: SizedBox()),
                                // SizedBox(
                                //   width: double.infinity,
                                // ),
                                SizedBox(
                                  width: 280,
                                  height: 80,
                                  child: _InfoTile(
                                    icon: Icons.account_circle_rounded,
                                    iconColor: Colors.teal,
                                    label: 'ชื่อผู้ทำรายการ',
                                    onDoubleTap: () async {
                                      await read_user_ren();
                                      showDialog<String>(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (ctx) => _UserPickerDialog(
                                          context: ctx,
                                          namemake: namemake ?? '-',
                                          userModels: userModels,
                                          onPicked: (picked) async {
                                            try {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final ren =
                                                  prefs.getString('renTalSer');
                                              final userSer = picked.ser!;
                                              final userCid =
                                                  '${widget.Get_Value_cid}';
                                              final url =
                                                  '${MyConstant().domain}/UP_user_contrac.php?isAdd=true&ren=$ren&ser_user=$userSer&sercid=$userCid';
                                              final res = await http
                                                  .get(Uri.parse(url));
                                              if (res.statusCode == 200) {
                                                Insert_log.Insert_logs(
                                                  'ผู้เช่า',
                                                  'แอดมินผู้ทำสัญญา${widget.Get_Value_cid} จาก $namemake --> ${picked.fname} ${picked.lname}',
                                                );
                                              }
                                            } catch (e) {
                                              //  debugPrint('Error: $e');
                                            }
                                            if (!mounted) return;
                                            Navigator.pop(ctx);
                                            setState(() => read_GC_teNant());
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      '${namemake ?? '-'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: 15,
                                // ),
                                SizedBox(
                                  width: 280,
                                  height: 80,
                                  child: _InfoTile(
                                    icon: Icons.person_outline_rounded,
                                    iconColor: Colors.deepPurple,
                                    label:
                                        '${widget.Get_Value_NameShop_index}' ==
                                                '1'
                                            ? 'ชื่อผู้เช่าสัญญา: '
                                            : 'ชื่อผู้เสนอราคา: ',

                                    //  'ชื่อผู้เช่า',
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            '${namenew ?? '-'}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        // const SizedBox(width: 4),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              // Text(
                                              //   '${widget.Get_Value_NameShop_index}' ==
                                              //           '1'
                                              //       ? 'เลขที่สัญญา: '
                                              //       : 'เลขที่เสนอราคา: ',
                                              //   maxLines: 1,
                                              //   overflow:
                                              //       TextOverflow
                                              //           .ellipsis,
                                              //   style: const TextStyle(
                                              //       color: Colors
                                              //           .black54,
                                              //       fontWeight:
                                              //           FontWeight
                                              //               .w600),
                                              // ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors.black12,
                                                        width: 1),
                                                  ),
                                                  child: SelectableText(
                                                    '${widget.Get_Value_cid}',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey.shade900,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                    toolbarOptions:
                                                        const ToolbarOptions(
                                                            copy: true,
                                                            selectAll: true,
                                                            cut: false,
                                                            paste: false),
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
                              ],
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 280,
                              height: 80,
                              child: _InfoTile(
                                icon: Icons.map,
                                iconColor: Colors.blueGrey,
                                label: 'โซนพื้นที่',
                                child: Text(
                                  '${areazone ?? '-'}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 280,
                              height: 80,
                              child: _InfoTile(
                                icon: Icons.grid_view_rounded,
                                iconColor: Colors.indigo,
                                label: 'รหัสพื้นที่',
                                child: Text(
                                  '${areanew ?? '-'}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   width: 15,
                            // ),
                            if (cc_datecid.toString() == '0000-00-00' ||
                                cc_datecid == '' ||
                                cc_datecid == null)
                              dateChipFromStr(
                                  icon: Icons.event_available_rounded,
                                  color: Colors.blue,
                                  title: 'วันที่หมดสัญญา',
                                  dateStr: l_datecid)
                            else
                              SizedBox(),
                            // SizedBox(
                            //   width: 15,
                            // ),

                            if (cc_datecid.toString() == '0000-00-00' ||
                                cc_datecid == '' ||
                                cc_datecid == null)
                              InkWell(
                                onDoubleTap: () =>
                                    cancel_FutureCidCancel(context),
                                child: dateChipFromStr(
                                    icon: Icons.event_busy_rounded,
                                    color: Colors.red,
                                    title: 'กำหนดยกเลิกสัญญา',
                                    dateStr: cc_datecid),
                              )
                            else
                              InkWell(
                                onDoubleTap: () =>
                                    cancel_FutureCidCancel(context),
                                child: dateChipFromStr(
                                    icon: Icons.event_busy_rounded,
                                    color: Colors.red,
                                    title: 'กำหนดยกเลิกสัญญา',
                                    dateStr: cc_datecid),
                              ),

                            // Tiles
                            // Expanded(child: SizedBox()),
                            // SizedBox(
                            //   width: double.infinity,
                            // ),
                            SizedBox(
                              width: 280,
                              height: 80,
                              child: _InfoTile(
                                icon: Icons.account_circle_rounded,
                                iconColor: Colors.teal,
                                label: 'ชื่อผู้ทำรายการ',
                                onDoubleTap: () async {
                                  await read_user_ren();
                                  showDialog<String>(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (ctx) => _UserPickerDialog(
                                      context: ctx,
                                      namemake: namemake ?? '-',
                                      userModels: userModels,
                                      onPicked: (picked) async {
                                        try {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          final ren =
                                              prefs.getString('renTalSer');
                                          final userSer = picked.ser!;
                                          final userCid =
                                              '${widget.Get_Value_cid}';
                                          final url =
                                              '${MyConstant().domain}/UP_user_contrac.php?isAdd=true&ren=$ren&ser_user=$userSer&sercid=$userCid';
                                          final res =
                                              await http.get(Uri.parse(url));
                                          if (res.statusCode == 200) {
                                            Insert_log.Insert_logs(
                                              'ผู้เช่า',
                                              'แอดมินผู้ทำสัญญา${widget.Get_Value_cid} จาก $namemake --> ${picked.fname} ${picked.lname}',
                                            );
                                          }
                                        } catch (e) {
                                          //  debugPrint('Error: $e');
                                        }
                                        if (!mounted) return;
                                        Navigator.pop(ctx);
                                        setState(() => read_GC_teNant());
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  '${namemake ?? '-'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   width: 15,
                            // ),
                            SizedBox(
                              width: 280,
                              height: 80,
                              child: _InfoTile(
                                icon: Icons.person_outline_rounded,
                                iconColor: Colors.deepPurple,
                                label:
                                    '${widget.Get_Value_NameShop_index}' == '1'
                                        ? 'ชื่อผู้เช่าสัญญา: '
                                        : 'ชื่อผู้เสนอราคา: ',

                                //  'ชื่อผู้เช่า',
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        '${namenew ?? '-'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    // const SizedBox(width: 4),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          // Text(
                                          //   '${widget.Get_Value_NameShop_index}' ==
                                          //           '1'
                                          //       ? 'เลขที่สัญญา: '
                                          //       : 'เลขที่เสนอราคา: ',
                                          //   maxLines: 1,
                                          //   overflow:
                                          //       TextOverflow
                                          //           .ellipsis,
                                          //   style: const TextStyle(
                                          //       color: Colors
                                          //           .black54,
                                          //       fontWeight:
                                          //           FontWeight
                                          //               .w600),
                                          // ),
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.black12,
                                                    width: 1),
                                              ),
                                              child: SelectableText(
                                                '${widget.Get_Value_cid}',
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade900,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                                toolbarOptions:
                                                    const ToolbarOptions(
                                                        copy: true,
                                                        selectAll: true,
                                                        cut: false,
                                                        paste: false),
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
                          ],
                        ),
                ],
              ),
            ),
          ),

        // ===== เนื้อหาหลัก (tabs) =====
        contact_new == 1
            ? Newcontract_cmm(
                Get_Value_area_index: store.areaIndex,
                Get_Value_area_ln: store.areaLn,
                Get_Value_area_sum: store.areaSum,
                Get_Value_rent_sum: store.rentSum,
                Get_Value_page: store.page,
                Get_Value_uuid: store.uuid,
                Get_Value_step: store.step,
                Get_Value_payment_uuid: store.paymentUuid,
                Get_Value_payment_amount: store.paymentAmount,
                paymentjsonx: store.paymentJson,
                Get_ReContact: 'YES',
                Get_TeNantModels: teNantModels,
                status_uuid: '',
              )
            // ChaoReContact(Value_cid: widget.Get_Value_cid)
            : contact_new == 2
                ? ChaoReturn(
                    Get_Value_NameShop_index: widget.Get_Value_NameShop_index,
                    Value_cid: widget.Get_Value_cid)
                : contact_new == 3
                    ? ChaoReContactAdd(Value_cid: widget.Get_Value_cid)
                    : contact_new == 4
                        ? ChaoReturnMadjum(Value_cid: widget.Get_Value_cid)
                        : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Container(
                                  // elevation: 2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(0),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12)),
                                  ),
                                  // color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        // Wrap(
                                        //   spacing: 12,
                                        //   runSpacing: 12,
                                        //   alignment: WrapAlignment.spaceBetween,
                                        //   children: [
                                        // Row(
                                        //   children: [
                                        //     SizedBox(
                                        //       width: 280,
                                        //       height: 85,
                                        //       child: _InfoTile(
                                        //         icon: Icons.grid_view_rounded,
                                        //         iconColor: Colors.indigo,
                                        //         label: 'รหัสพื้นที่',
                                        //         child: Text(
                                        //           '${areanew ?? '-'}',
                                        //           maxLines: 2,
                                        //           overflow:
                                        //               TextOverflow.ellipsis,
                                        //           style: const TextStyle(
                                        //               color: Colors.black87,
                                        //               fontWeight:
                                        //                   FontWeight.bold),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     // Tiles
                                        //     Expanded(child: SizedBox()),
                                        //     // SizedBox(
                                        //     //   width: double.infinity,
                                        //     // ),
                                        //     SizedBox(
                                        //       width: 280,
                                        //       height: 85,
                                        //       child: _InfoTile(
                                        //         icon: Icons
                                        //             .account_circle_rounded,
                                        //         iconColor: Colors.teal,
                                        //         label: 'ชื่อผู้ทำรายการ',
                                        //         onDoubleTap: () {
                                        //           read_user_ren();
                                        //           showDialog<String>(
                                        //             barrierDismissible: false,
                                        //             context: context,
                                        //             builder: (ctx) =>
                                        //                 _UserPickerDialog(
                                        //               context: ctx,
                                        //               namemake: namemake ?? '-',
                                        //               userModels: userModels,
                                        //               onPicked: (picked) async {
                                        //                 try {
                                        //                   final prefs =
                                        //                       await SharedPreferences
                                        //                           .getInstance();
                                        //                   final ren =
                                        //                       prefs.getString(
                                        //                           'renTalSer');
                                        //                   final userSer =
                                        //                       picked.ser!;
                                        //                   final userCid =
                                        //                       '${widget.Get_Value_cid}';
                                        //                   final url =
                                        //                       '${MyConstant().domain}/UP_user_contrac.php?isAdd=true&ren=$ren&ser_user=$userSer&sercid=$userCid';
                                        //                   final res = await http
                                        //                       .get(Uri.parse(
                                        //                           url));
                                        //                   if (res.statusCode ==
                                        //                       200) {
                                        //                     Insert_log
                                        //                         .Insert_logs(
                                        //                       'ผู้เช่า',
                                        //                       'แอดมินผู้ทำสัญญา${widget.Get_Value_cid} จาก $namemake --> ${picked.fname} ${picked.lname}',
                                        //                     );
                                        //                   }
                                        //                 } catch (e) {
                                        //                   debugPrint(
                                        //                       'Error: $e');
                                        //                 }
                                        //                 if (!mounted) return;
                                        //                 Navigator.pop(ctx);
                                        //                 setState(() =>
                                        //                     read_GC_teNant());
                                        //               },
                                        //             ),
                                        //           );
                                        //         },
                                        //         child: Text(
                                        //           '${namemake ?? '-'}',
                                        //           maxLines: 1,
                                        //           overflow:
                                        //               TextOverflow.ellipsis,
                                        //           style: const TextStyle(
                                        //               color: Colors.black87,
                                        //               fontWeight:
                                        //                   FontWeight.bold),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     SizedBox(
                                        //       width: 20,
                                        //     ),
                                        //     SizedBox(
                                        //       width: 280,
                                        //       height: 85,
                                        //       child: _InfoTile(
                                        //         icon: Icons
                                        //             .person_outline_rounded,
                                        //         iconColor: Colors.deepPurple,
                                        //         label:
                                        //             '${widget.Get_Value_NameShop_index}' ==
                                        //                     '1'
                                        //                 ? 'ชื่อผู้เช่าสัญญา: '
                                        //                 : 'ชื่อผู้เสนอราคา: ',

                                        //         //  'ชื่อผู้เช่า',
                                        //         child: Row(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.center,
                                        //           children: [
                                        //             SizedBox(
                                        //               width: 80,
                                        //               child: Text(
                                        //                 '${namenew ?? '-'}',
                                        //                 maxLines: 1,
                                        //                 overflow: TextOverflow
                                        //                     .ellipsis,
                                        //                 style: const TextStyle(
                                        //                     color:
                                        //                         Colors.black87,
                                        //                     fontWeight:
                                        //                         FontWeight
                                        //                             .bold),
                                        //               ),
                                        //             ),
                                        //             // const SizedBox(width: 4),
                                        //             Expanded(
                                        //               child: Row(
                                        //                 children: [
                                        //                   // Text(
                                        //                   //   '${widget.Get_Value_NameShop_index}' ==
                                        //                   //           '1'
                                        //                   //       ? 'เลขที่สัญญา: '
                                        //                   //       : 'เลขที่เสนอราคา: ',
                                        //                   //   maxLines: 1,
                                        //                   //   overflow:
                                        //                   //       TextOverflow
                                        //                   //           .ellipsis,
                                        //                   //   style: const TextStyle(
                                        //                   //       color: Colors
                                        //                   //           .black54,
                                        //                   //       fontWeight:
                                        //                   //           FontWeight
                                        //                   //               .w600),
                                        //                   // ),
                                        //                   Expanded(
                                        //                     child: Container(
                                        //                       padding: const EdgeInsets
                                        //                               .symmetric(
                                        //                           horizontal: 2,
                                        //                           vertical: 2),
                                        //                       decoration:
                                        //                           BoxDecoration(
                                        //                         color: Colors
                                        //                             .grey[50],
                                        //                         borderRadius:
                                        //                             BorderRadius
                                        //                                 .circular(
                                        //                                     8),
                                        //                         border: Border.all(
                                        //                             color: Colors
                                        //                                 .black12,
                                        //                             width: 1),
                                        //                       ),
                                        //                       child:
                                        //                           SelectableText(
                                        //                         '${widget.Get_Value_cid}',
                                        //                         maxLines: 1,
                                        //                         style: TextStyle(
                                        //                             color: Colors
                                        //                                 .grey
                                        //                                 .shade900,
                                        //                             fontWeight:
                                        //                                 FontWeight
                                        //                                     .bold,
                                        //                             fontFamily:
                                        //                                 Font_
                                        //                                     .Fonts_T),
                                        //                         toolbarOptions:
                                        //                             const ToolbarOptions(
                                        //                                 copy:
                                        //                                     true,
                                        //                                 selectAll:
                                        //                                     true,
                                        //                                 cut:
                                        //                                     false,
                                        //                                 paste:
                                        //                                     false),
                                        //                       ),
                                        //                     ),
                                        //                   ),
                                        //                 ],
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),

                                        //   ],
                                        // ),
                                        // const SizedBox(height: 12),

                                        // Tabs / Warning
                                        // if (ser_tabbarview_2 == 7)
                                        //   Container(
                                        //     width: double.infinity,
                                        //     padding: const EdgeInsets.symmetric(
                                        //         horizontal: 12, vertical: 10),
                                        //     decoration: BoxDecoration(
                                        //       color:
                                        //           Colors.red.withOpacity(0.06),
                                        //       borderRadius:
                                        //           BorderRadius.circular(10),
                                        //       border: Border.all(
                                        //           color: Colors.red
                                        //               .withOpacity(0.2)),
                                        //     ),
                                        //     child: const Text(
                                        //       'คำเตือน : การย้ายพื้นที่อาจมีผลต่อสัญญาเช่า',
                                        //       textAlign: TextAlign.left,
                                        //       style: TextStyle(
                                        //           color: Colors.red,
                                        //           fontWeight: FontWeight.bold),
                                        //     ),
                                        //   )
                                        // else
                                        SizedBox(
                                          height: 20,
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child:
                                              //  SingleChildScrollView(
                                              //   scrollDirection: Axis.horizontal,
                                              //   padding:
                                              //       const EdgeInsets.only(top: 4),
                                              // child:
                                              Align(
                                            // ✅ จัด Row ให้อยู่กึ่งกลาง
                                            alignment: Alignment.center,
                                            child:
                                                (!Responsive.isDesktop(
                                                            context) ||
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width <
                                                            1370)
                                                    ? ScrollConfiguration(
                                                        behavior:
                                                            ScrollConfiguration
                                                                    .of(context)
                                                                .copyWith(
                                                          dragDevices: {
                                                            PointerDeviceKind
                                                                .touch,
                                                            PointerDeviceKind
                                                                .mouse,
                                                          },
                                                        ),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min, // ✅ ไม่ขยาย Row เต็มจอ
                                                            children: [
                                                              for (var index =
                                                                      0;
                                                                  index <
                                                                      tabbarview_2
                                                                          .length;
                                                                  index++)
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          6),
                                                                  child:
                                                                      InkWell(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            999),
                                                                    onTap: () =>
                                                                        setState(() =>
                                                                            ser_tabbarview_2 =
                                                                                index),
                                                                    child:
                                                                        AnimatedContainer(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              160),
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              18,
                                                                          vertical:
                                                                              10),
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        minWidth:
                                                                            170,
                                                                        maxWidth:
                                                                            200,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: (ser_tabbarview_2 ==
                                                                                index)
                                                                            ? (tabbarview_color_2[index][700] ??
                                                                                Colors.blue)
                                                                            : (tabbarview_color_2[index][100] ?? Colors.blue[50]),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12),
                                                                        border: (ser_tabbarview_2 ==
                                                                                index)
                                                                            ? Border.all(
                                                                                color: Colors.white,
                                                                                width: 1)
                                                                            : Border.all(color: Colors.transparent),
                                                                        boxShadow: (ser_tabbarview_2 ==
                                                                                index)
                                                                            ? [
                                                                                BoxShadow(
                                                                                  color: (tabbarview_color_2[index][200] ?? Colors.black12).withOpacity(0.6),
                                                                                  blurRadius: 10,
                                                                                  offset: const Offset(0, 4),
                                                                                ),
                                                                              ]
                                                                            : [],
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          '${tabbarview_2[index]}',
                                                                          style:
                                                                              TextStyle(
                                                                            color: (ser_tabbarview_2 == index)
                                                                                ? Colors.white
                                                                                : Colors.black87,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            fontSize:
                                                                                15,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize: MainAxisSize
                                                            .min, // ✅ ไม่ขยาย Row เต็มจอ
                                                        children: [
                                                          for (var index = 0;
                                                              index <
                                                                  tabbarview_2
                                                                      .length;
                                                              index++)
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      6),
                                                              child: InkWell(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            999),
                                                                onTap: () =>
                                                                    setState(() =>
                                                                        ser_tabbarview_2 =
                                                                            index),
                                                                child:
                                                                    AnimatedContainer(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          160),
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          18,
                                                                      vertical:
                                                                          10),
                                                                  constraints:
                                                                      BoxConstraints(
                                                                    minWidth:
                                                                        170,
                                                                    maxWidth:
                                                                        200,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: (ser_tabbarview_2 ==
                                                                            index)
                                                                        ? (tabbarview_color_2[index][700] ??
                                                                            Colors
                                                                                .blue)
                                                                        : (tabbarview_color_2[index][100] ??
                                                                            Colors.blue[50]),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                    border: (ser_tabbarview_2 ==
                                                                            index)
                                                                        ? Border.all(
                                                                            color: Colors
                                                                                .white,
                                                                            width:
                                                                                1)
                                                                        : Border.all(
                                                                            color:
                                                                                Colors.transparent),
                                                                    boxShadow:
                                                                        (ser_tabbarview_2 ==
                                                                                index)
                                                                            ? [
                                                                                BoxShadow(
                                                                                  color: (tabbarview_color_2[index][200] ?? Colors.black12).withOpacity(0.6),
                                                                                  blurRadius: 10,
                                                                                  offset: const Offset(0, 4),
                                                                                ),
                                                                              ]
                                                                            : [],
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      '${tabbarview_2[index]}',
                                                                      style:
                                                                          TextStyle(
                                                                        color: (ser_tabbarview_2 ==
                                                                                index)
                                                                            ? Colors.white
                                                                            : Colors.black87,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                          ),
                                          // ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              (ser_tabbarview_2 == 0)
                                  ? Infocontract_CMM(
                                      Get_Value_cid: widget.Get_Value_cid,
                                      Get_Value_NameShop_index:
                                          widget.Get_Value_NameShop_index,
                                      Get_Value_statu: widget.Get_Value_status,
                                    )
                                  // (renTal_user.toString() == '50' ||
                                  //         renTal_user.toString() == '139')
                                  //     ? Infocontract_CMM(
                                  //         Get_Value_cid: widget.Get_Value_cid,
                                  //         Get_Value_NameShop_index:
                                  //             widget.Get_Value_NameShop_index,
                                  //         Get_Value_statu:
                                  //             widget.Get_Value_status,
                                  //       )
                                  //     : RentalInformation(
                                  //         Get_Value_cid: widget.Get_Value_cid,
                                  //         Get_Value_NameShop_index:
                                  //             widget.Get_Value_NameShop_index,
                                  //         Get_Value_statu:
                                  //             widget.Get_Value_status,
                                  //       )
                                  : (ser_tabbarview_2 == 1)
                                      ? MeterWaterElectric(
                                          Get_Value_cid: widget.Get_Value_cid,
                                          Get_Value_NameShop_index:
                                              widget.Get_Value_NameShop_index)
                                      : (ser_tabbarview_2 == 2)
                                          ? Bills(
                                              Get_Value_cid:
                                                  widget.Get_Value_cid,
                                              Get_Value_NameShop_index: widget
                                                  .Get_Value_NameShop_index,
                                              namenew: namenew)
                                          :
                                          // (ser_tabbarview_2 == 3)
                                          //     ? (open_disinv == '0'
                                          //         ? const Center(
                                          //             child: Text(
                                          //                 'Coming soon...'))
                                          //         : DiscountBill(
                                          //             Get_Value_cid:
                                          //                 widget.Get_Value_cid))
                                          //     :
                                          (ser_tabbarview_2 == 3)
                                              ? Pays(
                                                  updateMessage2:
                                                      updateMessage2,
                                                  Get_Value_cid:
                                                      widget.Get_Value_cid,
                                                  Get_Value_NameShop_index: widget
                                                      .Get_Value_NameShop_index,
                                                  namenew: namenew,
                                                  Screen_name: 'PeopleChao',
                                                )
                                              : (ser_tabbarview_2 == 4)
                                                  ? HistoryBills(
                                                      Get_Value_cid:
                                                          widget.Get_Value_cid,
                                                      Get_Value_NameShop_index:
                                                          widget
                                                              .Get_Value_NameShop_index)
                                                  : (ser_tabbarview_2 == 5)
                                                      ? SettringListMenu(
                                                          Get_Value_cid: widget
                                                              .Get_Value_cid,
                                                          Get_Value_NameShop_index:
                                                              widget
                                                                  .Get_Value_NameShop_index)
                                                      : Move_Area(
                                                          Get_Value_cid: widget
                                                              .Get_Value_cid,
                                                          Get_Value_NameShop_index:
                                                              widget
                                                                  .Get_Value_NameShop_index),
                            ],
                          ),
      ],
    );
  }

  // --------------------------- Actions ---------------------------
  void updateMessage2(index_s) async {
    setState(() => ser_tabbarview_2 = 3);
    Future.delayed(const Duration(milliseconds: 200),
        () => setState(() => ser_tabbarview_2 = 3));
  }

  // Future<dynamic> calcen_LE(BuildContext context) {
  //   final data_text = TextEditingController();
  //   return showDialog(
  //     barrierDismissible: true,
  //     context: context,
  //     builder: (BuildContext context) => StreamBuilder(
  //       stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
  //       builder: (context, snapshot) {
  //         return AlertDialog(
  //           backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
  //           titlePadding: const EdgeInsets.all(0.0),
  //           contentPadding: const EdgeInsets.all(10.0),
  //           actionsPadding: const EdgeInsets.all(6.0),
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //           title: const Padding(
  //             padding: EdgeInsets.all(8.0),
  //             child: Align(
  //               alignment: Alignment.center,
  //               child: Text('กำหนดวันยกเลิกสัญญา',
  //                   style: TextStyle(
  //                       color: Colors.black, fontWeight: FontWeight.bold)),
  //             ),
  //           ),
  //           content: SingleChildScrollView(
  //             child: ListBody(
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Container(
  //                     height: 50,
  //                     width: 200,
  //                     decoration: BoxDecoration(
  //                       borderRadius: const BorderRadius.only(
  //                         topLeft: Radius.circular(15),
  //                         topRight: Radius.circular(15),
  //                         bottomLeft: Radius.circular(15),
  //                         bottomRight: Radius.circular(15),
  //                       ),
  //                       border: Border.all(color: Colors.grey, width: 1),
  //                     ),
  //                     child: InkWell(
  //                       onTap: () async {
  //                         DateTime? newDate = await showDatePicker(
  //                           locale: const Locale('th', 'TH'),
  //                           context: context,
  //                           initialDate: DateTime.now(),
  //                           firstDate: DateTime.tryParse(
  //                                   '${s_datecid ?? DateTime.now().toString().substring(0, 10)} 00:00:00') ??
  //                               DateTime(2000),
  //                           lastDate: (DateTime.tryParse(
  //                                       '${l_datecid ?? DateTime.now().toString().substring(0, 10)} 00:00:00') ??
  //                                   DateTime.now())
  //                               .add(const Duration(days: 50)),
  //                           builder: (context, child) {
  //                             return Theme(
  //                               data: Theme.of(context).copyWith(
  //                                 colorScheme: const ColorScheme.light(
  //                                   primary: AppBarColors.ABar_Colors,
  //                                   onPrimary: Colors.white,
  //                                   onSurface: Colors.black,
  //                                 ),
  //                                 textButtonTheme: TextButtonThemeData(
  //                                   style: TextButton.styleFrom(
  //                                       foregroundColor: Colors.black),
  //                                 ),
  //                               ),
  //                               child: child!,
  //                             );
  //                           },
  //                         );

  //                         if (newDate == null) return;

  //                         setState(() {
  //                           Value_D_start =
  //                               DateFormat('yyyy-MM-dd').format(newDate);
  //                           Value_DateTime_Step2 =
  //                               DateFormat('dd-MM-yyy').format(newDate);
  //                         });
  //                       },
  //                       child: Container(
  //                         padding: const EdgeInsets.all(15.0),
  //                         child: AutoSizeText(
  //                           Value_DateTime_Step2.isEmpty
  //                               ? 'เลือกวันที่'
  //                               : Value_DateTime_Step2,
  //                           minFontSize: 9,
  //                           maxFontSize: 16,
  //                           textAlign: TextAlign.start,
  //                           style: const TextStyle(
  //                               color: PeopleChaoScreen_Color.Colors_Text2_,
  //                               fontFamily: Font_.Fonts_T),
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: TextFormField(
  //                     controller: data_text,
  //                     decoration: InputDecoration(
  //                       fillColor: Colors.white.withOpacity(0.3),
  //                       filled: true,
  //                       prefixIcon: const Icon(Icons.chat, color: Colors.black),
  //                       focusedBorder: const OutlineInputBorder(
  //                         borderRadius: BorderRadius.only(
  //                           topRight: Radius.circular(15),
  //                           topLeft: Radius.circular(15),
  //                           bottomRight: Radius.circular(15),
  //                           bottomLeft: Radius.circular(15),
  //                         ),
  //                         borderSide: BorderSide(width: 1, color: Colors.black),
  //                       ),
  //                       enabledBorder: const OutlineInputBorder(
  //                         borderRadius: BorderRadius.only(
  //                           topRight: Radius.circular(15),
  //                           topLeft: Radius.circular(15),
  //                           bottomRight: Radius.circular(15),
  //                           bottomLeft: Radius.circular(15),
  //                         ),
  //                         borderSide: BorderSide(width: 1, color: Colors.grey),
  //                       ),
  //                       labelText: 'หมายเหตุ',
  //                       labelStyle: const TextStyle(
  //                           color: ManageScreen_Color.Colors_Text2_,
  //                           fontFamily: Font_.Fonts_T),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             Column(
  //               children: [
  //                 const SizedBox(height: 5.0),
  //                 const Divider(color: Colors.grey, height: 4.0),
  //                 const SizedBox(height: 5.0),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: InkWell(
  //                         onTap: () async =>
  //                             read_ED_tenant(data_text.text.toString()),
  //                         child: Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.green,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: const Text('ยืนยัน',
  //                               textAlign: TextAlign.center,
  //                               style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold)),
  //                         ),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: InkWell(
  //                         onTap: () async => Navigator.pop(context),
  //                         child: Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.black,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: const Text('ยกเลิก',
  //                               textAlign: TextAlign.center,
  //                               style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold)),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  // Future<void> read_ED_tenant(String data_text) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   final ren = preferences.getString('renTalSer');
  //   final ciddoc = widget.Get_Value_cid;
  //   final ccdate = Value_D_start;
  //   final remark = data_text;

  //   final url =
  //       '${MyConstant().domain}/UP_cc_contract.php?isAdd=true&ren=$ren&cid=$ciddoc&ccdate=$ccdate&remark=$remark';
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     final result = json.decode(response.body);
  //     if (result.toString() == 'true') {
  //       setState(() {
  //         Value_D_start = '';
  //         Value_DateTime_Step2 = '';
  //         read_GC_teNant();
  //       });
  //       if (mounted) Navigator.pop(context);
  //     }
  //   } catch (_) {}
  // }
  Future<String?> cancel(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogCtx) {
        final formKey = GlobalKey<FormState>();
        bool isLoading = false;

        return StatefulBuilder(
          builder: (ctx, setState) {
            final isEmpty = (Formbecause_.text.trim().isEmpty);

            Future<void> _submit() async {
              if (isLoading) return;
              if (!formKey.currentState!.validate()) return;

              setState(() => isLoading = true);

              final because_ = Formbecause_.text.trim();
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              final ren = preferences.getString('renTalSer');
              final isContract = '${widget.Get_Value_NameShop_index}' == '1';

              final url = isContract
                  ? '${MyConstant().domain}/DC_Area_ciddocV2.php?isAdd=true&ren=$ren&ciddoc=${widget.Get_Value_cid}&because=$because_'
                  : '${MyConstant().domain}/DC_Area_quot.php?isAdd=true&ren=$ren&ciddoc=${widget.Get_Value_cid}&because=$because_';

              try {
                final response = await http.get(Uri.parse(url));
                final result = json.decode(response.body);
                if (result.toString() == 'true') {
                  // callback ถ้ามี
                  if (widget.updateMessage != null) {
                    widget.updateMessage('PeopleChaoScreen');
                  }
                  Formbecause_.clear();
                  if (Navigator.of(dialogCtx).canPop()) {
                    Navigator.pop(dialogCtx, 'OK');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ไม่สามารถยกเลิกได้ กรุณาลองใหม่')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                );
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

              // ---------- Title ----------
              title: Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.Get_Value_NameShop_index}' == '1'
                          ? 'ยกเลิกสัญญา'
                          : 'ยกเลิกใบเสนอราคา',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: FontWeight_.Fonts_T,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(dialogCtx),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              // ---------- Content ----------
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // CID chip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 28,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.25)),
                              ),
                              child: Text(
                                '${widget.Get_Value_NameShop_index}' == '1'
                                    ? 'เลขที่ใบสัญญา'
                                    : 'เลขที่ใบเสนอราคา',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SelectableText(
                                '${widget.Get_Value_cid}',
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Info text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.18)),
                        ),
                        child: Text(
                          'ระบุเหตุผลการยกเลิกให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Reason field
                      TextFormField(
                        controller: Formbecause_,
                        maxLines: 2,
                        maxLength: 200,
                        cursorColor: Colors.red,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกเหตุผลการยกเลิก';
                          }
                          if (value.trim().length < 3) {
                            return 'เหตุผลสั้นเกินไป';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '${widget.Get_Value_NameShop_index}' == '1'
                              ? 'เช่น ผู้เช่าขอยุติสัญญาก่อนกำหนด'
                              : 'เช่น ผู้เสนอราคาขอยุติใบเสนอราคา',
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.edit_note_rounded,
                              color: Colors.black54),
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black87),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black26),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          labelText: 'หมายเหตุ',
                          labelStyle: const TextStyle(
                            color: ManageScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ---------- Actions ----------
              actions: [
                Row(
                  children: [
                    // Confirm
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable:
                            Formbecause_, // ต้องเป็น controller เดียวกับ TextFormField
                        builder: (ctx, value, _) {
                          final bool isEmptyLocal = value.text.trim().isEmpty;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: Responsive.isDesktop(ctx)
                                  ? MediaQuery.of(ctx).size.width * 0.5
                                  : MediaQuery.of(ctx).size.width,
                              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                            ),
                            child: IgnorePointer(
                              ignoring:
                                  isEmptyLocal || isLoading, // ✅ กันคลิกจริง ๆ
                              child: AnimatedOpacity(
                                duration: const Duration(
                                    milliseconds: 150), // ✅ ลื่นตา
                                opacity: (isEmptyLocal || isLoading) ? 0.6 : 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: _submit, // ✅ ไม่ต้องเช็คซ้ำที่นี่
                                  child: Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.red[600],
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red!.withOpacity(0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'ยืนยัน',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  ///////////////
  Future<String?> cancel_FutureCidCancel(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogCtx) {
        final formKey = GlobalKey<FormState>();
        bool isLoading = false;

        return StatefulBuilder(
          builder: (ctx, setState) {
            final isEmpty = (Formbecause_.text.trim().isEmpty);

            Future<void> _submit() async {
              if (isLoading) return;
              if (!formKey.currentState!.validate()) return;

              setState(() => isLoading = true);

              final because_ = Formbecause_.text.trim();
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              final ren = preferences.getString('renTalSer');
              final isContract = '${widget.Get_Value_NameShop_index}' == '1';
              String ccdate = '0000-00-00';
              String because_can = '';
              String url =
                  '${MyConstant().domain}/UP_cc_contract.php?isAdd=true&ren=$ren&cid=${widget.Get_Value_cid}&ccdate=$ccdate&remark=$because_can';

              try {
                final response = await http.get(Uri.parse(url));
                final result = json.decode(response.body);
                //  print(result);
                if (result.toString() == 'true') {
                  Insert_log.Insert_logs('ผู้เช่า',
                      'ยกเลิกการยกเลิกสัญญาล่วงหน้า:${widget.Get_Value_cid} >> ${because_}');

                  if (Navigator.of(dialogCtx).canPop()) {
                    Navigator.pop(dialogCtx, 'OK');
                  }
                  read_GC_teNant();
                  Dialog_success(context, 'ดำเนินการสำเร็จ');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('ไม่สามารถยกเลิกได้ กรุณาลองใหม่')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                );
              } finally {
                if (mounted) setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

              // ---------- Title ----------
              title: Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ยกเลิกการยกเลิกสัญญาล่วงหน้า',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: FontWeight_.Fonts_T,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(dialogCtx),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              // ---------- Content ----------
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // CID chip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                        ),
                        child: dateChipFromStr(
                            icon: Icons.event_busy_rounded,
                            color: Colors.red,
                            title: 'กำหนดยกเลิกสัญญา',
                            dateStr: cc_datecid),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.25)),
                            ),
                            child: Text(
                              'เลขที่สัญญา',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              '${widget.Get_Value_cid}',
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Info text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.18)),
                        ),
                        child: Text(
                          'ระบุเหตุผลการยกเลิกให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Reason field
                      TextFormField(
                        controller: Formbecause_,
                        maxLines: 2,
                        maxLength: 200,
                        cursorColor: Colors.orange,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกเหตุผลการยกเลิก';
                          }
                          if (value.trim().length < 3) {
                            return 'เหตุผลสั้นเกินไป';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'เช่น ผู้เช่าเปลี่ยนใจไม่ยกเลิก',
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.edit_note_rounded,
                              color: Colors.black54),
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black87),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black26),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          labelText: 'หมายเหตุ',
                          labelStyle: const TextStyle(
                            color: ManageScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ---------- Actions ----------
              actions: [
                Row(
                  children: [
                    // Confirm
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable:
                            Formbecause_, // ต้องเป็น controller เดียวกับ TextFormField
                        builder: (ctx, value, _) {
                          final bool isEmptyLocal = value.text.trim().isEmpty;

                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: Responsive.isDesktop(ctx)
                                  ? MediaQuery.of(ctx).size.width * 0.5
                                  : MediaQuery.of(ctx).size.width,
                              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                            ),
                            child: IgnorePointer(
                              ignoring:
                                  isEmptyLocal || isLoading, // ✅ กันคลิกจริง ๆ
                              child: AnimatedOpacity(
                                duration: const Duration(
                                    milliseconds: 150), // ✅ ลื่นตา
                                opacity: (isEmptyLocal || isLoading) ? 0.6 : 1,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: _submit, // ✅ ไม่ต้องเช็คซ้ำที่นี่
                                  child: Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.orange[600],
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.orange!.withOpacity(0.25),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'ยืนยัน',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: FontWeight_.Fonts_T,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
