import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Constant/Myconstant.dart';
import '../../Model/GetExpType_Model.dart';
import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetType_Model.dart';
import '../../Model/GetUnit_Model.dart';
import '../../Model/GetUnitx_Model.dart';
import '../../Model/GetVat_Model.dart';
import '../../Model/GetWht_Model.dart';
import '../../Responsive/responsive.dart';
import '../../Style/colors.dart';
import '../Model/AnnouncementZone_Model.dart';
import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/ExpTrans_ModelCMM.dart';
import '../unity/API_announcement.dart';
import '../unity/SecurePrefs_helper.dart';
import '../unity/show_dialog_cmm.dart';

class BillingTable extends StatefulWidget {
  final cid_sdate;
  final cid_ldate;
  final cid_zser;

  final Function(List<ExpTransModelCMM>)? onRowsChanged;
  BillingTable(
      {this.onRowsChanged, this.cid_sdate, this.cid_ldate, this.cid_zser});
  @override
  _BillingTableState createState() => _BillingTableState();
}

class _BillingTableState extends State<BillingTable> {
  List<TypeModel> typeModels = [];
  List<AutoExpTransModelCMM> expAutoModels = [];
  List<AutoExpTransModelCMM> addExpModels = [];
  List<UnitModel> unitModels = [];
  List<UnitxModel> unitxModels = [];
  List<VatModel> vatModels = [];
  List<WhtModel> whtModels = [];
  List<ExpTypeModel> expTypeModels = [];
  List<AnnouncementZone> announcementZone = [];
  // List<Map<String, dynamic>> rows = [];

  List<ExpTransModelCMM> rows = [];
  final List<String> frequencies = ['รายวัน', 'ครั้งเดียว'];
  final _styles = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: FontWeight_.Fonts_T,
  );
  final data_datex =
      DateFormat('yyyy-MM-dd').format(DateTime.now()) ?? '0000-00-00';
  final data_timex =
      DateFormat('hh:mm:ss').format(DateTime.now()) ?? '00:00:00';
  @override
  void initState() {
    super.initState();
    read_GC_unit();
    read_GC_type();
    read_GC_vat();
    read_GC_wht();
    read_GC_ExpType();
    loadAnnounceMentGetzone();
    // read_GC_ExpAuto();
  }

  Future<Null> read_GC_ExpType() async {
    if (expTypeModels.isNotEmpty) {
      expTypeModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_exptype.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          ExpTypeModel expTypeModel = ExpTypeModel.fromJson(map);
          if (expTypeModel.ser.toString() != '3' &&
                  // expTypeModel.ser.toString() != '5' &&
                  expTypeModel.etype.toString() != 'E'
              // &&
              // expTypeModel.etype.toString() != 'F'
              ) {
            setState(() {
              expTypeModels.add(expTypeModel);
            });
          }
        }
      } else {}
    } catch (e) {}
    // print('expTypeModels.length');
    // print(expTypeModels.length);
    // print('expTypeModels.length');
  }

  // List<AnnouncementZone> announcementZone = [];
  String? announcement_message, computed_status;
  int? pay_status_fine = 0;
  Future<void> loadAnnounceMentGetzone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var zoneser_check = await preferences.getString('zoneSer');
    setState(() {
      announcementZone.clear();
    });

    try {
      final response =
          await read_AnnounceMent_Getzone(zoneid: '$zoneser_check');

      if (response == null) {
        //    print('❌ No response received.');
        return;
      }

      if (response.statusCode != 200) {
        //  print('❌ Server error: ${response.statusCode}');
        return;
      }

      final result = json.decode(response.body);
      final data = result['data'];

      //   print('📦 Raw data: $data');
      //   print('📦 Data type: ${data.runtimeType}');

      if (data == null) {
        //  print('❌ No data found.');
        return;
      } else {
        setState(() {
          announcement_message = result['message'];
          computed_status = data['computed_status'];
          pay_status_fine = data['pay_status'];
        });
      }

      if (data is List) {
        final items = data.map((e) => AnnouncementZone.fromJson(e)).toList();
        setState(() {
          announcementZone.addAll(items);
        });
      } else if (data is Map) {
        final item = AnnouncementZone.fromJson(Map<String, dynamic>.from(data));
        setState(() {
          announcementZone.add(item);
        });
      } else {
        //   print('❌ Unexpected data format: ${data.runtimeType}');
      }
    } catch (e, stack) {
      // print('❌ Exception: $e');
      // print('🧭 StackTrace:\n$stack');
    }
    read_GC_ExpAuto();
  }

  Future<void> read_GC_ExpAuto() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_exp_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        if (pay_status_fine == 0) {
          setState(() {
            expAutoModels = result
                .where((e) => e['etype'] != 'F') // ← ถูกต้อง
                .map<AutoExpTransModelCMM>(
                    (e) => AutoExpTransModelCMM.fromJson(e))
                .toList();
          });
        } else if (pay_status_fine == 1) {
          setState(() {
            expAutoModels = result
                .map<AutoExpTransModelCMM>(
                    (e) => AutoExpTransModelCMM.fromJson(e))
                .toList();
          });
        } else {
          Dialog_error(
              context, 'เกิดข้อผิดพลาดไม่สามารถโหลดข้อมูล ค่าบริการได้');
        }

        Future.delayed(const Duration(seconds: 1), () {
          _addRow(type: 'read');
        });
      }
      //  print('⚠️ pay_status_fine loading data: ${pay_status_fine}');
    } catch (e) {
      //   print('⚠️ Error loading data: $e');
    }
  }

  Future<void> read_GC_wht() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url = '${MyConstant().domain}/GC_wht.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result != null) {
        setState(() {
          whtModels =
              result.map<WhtModel>((e) => WhtModel.fromJson(e)).toList();
        });
      }
    } catch (e) {}
  }

  Future<void> read_GC_vat() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url = '${MyConstant().domain}/GC_vat.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result != null) {
        setState(() {
          vatModels =
              result.map<VatModel>((e) => VatModel.fromJson(e)).toList();
        });
      }
    } catch (e) {}
  }

  Future<void> read_GC_unit() async {
    String url = '${MyConstant().domain}/GC_unit.php?isAdd=true';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        setState(() {
          unitModels =
              result.map<UnitModel>((e) => UnitModel.fromJson(e)).toList();
          unitxModels =
              result.map<UnitxModel>((e) => UnitxModel.fromJson(e)).toList();
        });
      }
    } catch (e) {}
  }

  Future<void> read_GC_type() async {
    String url = '${MyConstant().domain}/GC_type.php?isAdd=true';

    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        setState(() {
          typeModels =
              result.map<TypeModel>((e) => TypeModel.fromJson(e)).toList();
        });
      }
    } catch (e) {}
  }

  bool checkSerexp(index) {
    bool t = expAutoModels[index].ser.toString() == '1' ||
        expAutoModels[index].ser.toString() == '9';
    return t;
  }

  void _selectDate(
    BuildContext context,
    ExpTransModelCMM row,
    void Function(void Function()) dialogSetState,
  ) async {
    DateTime initialDate;

    // ตรวจสอบว่า row.sdate มีค่าที่ parse ได้หรือไม่
    if (row.sdate != null && row.sdate!.trim().isNotEmpty) {
      final parsedDate = DateTime.tryParse(row.sdate!.trim());
      initialDate = parsedDate ?? DateTime.now();
    } else {
      initialDate = DateTime.now();
    }

    // ป้องกันกรณีวันที่ก่อน firstDate
    if (initialDate.isBefore(DateTime(2020))) {
      initialDate = DateTime(2020);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    // row.sunit = selected.ser;
    // row.unitser = selected.ser;
    // row.unit = selected.unit;
    // row.day = selected.day;

    if (picked != null) {
      setState(() {
        row.sdate = DateFormat('yyyy-MM-dd').format(picked);
        // row.ldate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
    printInstallmentsByDays(
      context,
      row,
      dialogSetState,
    );
    // print(row.ser);
    // print(row.unit);
    // print(row.day);
    // print(row.sdate);
    // print(row.ldate);
  }

// ===== helpers =====
  int _monthsBetween(DateTime start, DateTime end, {bool inclusive = true}) {
    if (end.isBefore(start)) return 0;
    int m = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day < start.day) m -= 1;
    if (inclusive) m += 1;
    return m;
  }

  int _yearsBetween(DateTime start, DateTime end, {bool inclusive = true}) {
    if (end.isBefore(start)) return 0;
    int y = end.year - start.year;
    if (end.month < start.month ||
        (end.month == start.month && end.day < start.day)) y -= 1;
    if (inclusive) y += 1;
    return y;
  }

  int _countByFixedDays(DateTime start, DateTime end, int daysPerPeriod) {
    if (end.isBefore(start) || daysPerPeriod <= 0) return 0;
    final daysIncl = end.difference(start).inDays + 1; // inclusive
    return (daysIncl / daysPerPeriod).ceil();
  }

// ===== main =====
  void printInstallmentsByDays(
    BuildContext context,
    ExpTransModelCMM row,
    void Function(void Function()) dialogSetState,
  ) {
    if (row.sdate == null || row.ldate == null) {
      //   print('ยังไม่มีช่วงวันที่ครบสำหรับคำนวณงวด');
      return;
    }

    final start = DateTime.parse(row.sdate!);
    final end = DateTime.parse(row.ldate!);

    if (end.isBefore(start)) {
      // print('วันสิ้นสุดน้อยกว่าวันเริ่มต้น');
      return;
    }

    final unit = (row.unit ?? '').trim(); // เช่น 'รายเดือน', 'รายปี', ...
    final ser = int.tryParse('${row.ser}') ?? 0; // ถ้ามีรหัสหน่วยเป็นตัวเลข
    int n;

    // เลือกสูตรตามหน่วย
    switch (unit) {
      case 'รายปี':
        n = _yearsBetween(start, end, inclusive: true);
        break;
      case 'รายเดือน':
        n = _monthsBetween(start, end, inclusive: true); // แม่นตามปฏิทิน
        break;
      case 'รายสัปดาห์':
        n = _countByFixedDays(start, end, 7);
        break;
      case 'รายวัน':
        n = _countByFixedDays(start, end, 1);
        break;
      case 'ครั้งเดียว':
        n = 1;
        break;
      case 'มิเตอร์':
        n = _monthsBetween(start, end, inclusive: true); // โดยทั่วไปคิดรายเดือน
        break;
      case 'ไม่มี':
        n = 0;
        break;
      case 'เหมาจ่าย':
        n = 1; // ปรับตามกติกาธุรกิจคุณได้
        break;

      default:
        // fallback ถ้า unit เป็นรหัส/ไม่ชัด: ใช้ row.day (365/30/7/1/…)
        final periodDays = int.tryParse('${row.day}') ?? 0;
        n = _countByFixedDays(start, end, periodDays);
    }

    // (ถ้าต้องการอัปเดตค่าใน row แล้วรีเฟรช UI ด้วย dialogSetState)
    // dialogSetState(() {
    //   row.installments = n; // ถ้ามีฟิลด์นี้
    // });

    // print('วันที่: $start ถึง $end');
    // print('ประเภท: ${row.unit} (ser=$ser, day=${row.day})');
    // print('จำนวนงวดทั้งหมด: $n');
    setState(() {
      row.term = '$n';
    });
  }

  // void printInstallmentsByDays(
  //   BuildContext context,
  //   ExpTransModelCMM row,
  //   void Function(void Function()) dialogSetState,
  // ) {
  //   if (row.sdate == null || row.ldate == null) {
  //     print('ยังไม่มีช่วงวันที่ครบสำหรับคำนวณงวด');
  //     return;
  //   }

  //   final start = DateTime.parse(row.sdate!);
  //   final end = DateTime.parse(row.ldate!);

  //   if (end.isBefore(start)) {
  //     print('วันสิ้นสุดน้อยกว่าวันเริ่มต้น');
  //     return;
  //   }

  //   // ระยะวันแบบรวมปลายทาง (inclusive)
  //   final diffDaysInclusive = end.difference(start).inDays + 1;

  //   // ใช้ค่าจำนวนวันต่อ 1 งวด (เช่น 365/30/7/1)
  //   final periodDays = int.tryParse('${row.day}') ?? 1;

  //   // จำนวนงวดที่ "ครอบคลุม" ทั้งช่วงเวลา (ปัดขึ้น)
  //   final installmentsCover = (diffDaysInclusive / periodDays).ceil();

  //   // ถ้าต้องการ "งวดที่เสร็จสมบูรณ์แล้ว" (ปัดลง)
  //   final installmentsFull = diffDaysInclusive ~/ periodDays;
  //   print('วันที่: $start  ถึง  $end');
  //   print('ประเภท: ${row.unit}');
  //   print('จำนวนงวดทั้งหมด (ครอบคลุมช่วง): $installmentsCover');
  //   print('จำนวนงวดทั้งหมด (เสร็จสมบูรณ์): $installmentsFull');
  // }

  double calculateTotal(ExpTransModelCMM row) {
    // 🧮 แปลงข้อมูลจากโมเดล
    double price = double.tryParse(row.amt ?? '0.0') ?? 0.0;
    double qty = double.tryParse(row.qty ?? '1.0') ?? 1.0;
    if (qty <= 0) qty = 1.0;

    String vser = row.vser ?? '1'; // ประเภท VAT: 1=ไม่มี, 2=รวมแล้ว, 3=บวกเพิ่ม
    String wser = row.wser ?? '1'; // ประเภท WHT: 0=ไม่มี, 1/3/5=หัก %

    double vatRate =
        double.tryParse(row.nvat?.toString()?.trim() ?? '0') ?? 0.0;
    double whtRate =
        (double.tryParse(row.nwht?.toString()?.trim() ?? '0') ?? 0.0) / 100;

    double basePrice = price;
    double vat = 0.0;
    double total = 0.0;
    double wht = 0.0;

    // ▶️ คำนวณ VAT
    if (vser == '1') {
      // print('ไม่มี VAT');
      vat = 0.0;
      basePrice = price;
      total = price * qty;
    } else if (vser == '2') {
      //  print('รวมภาษีแล้ว');
      basePrice = price / (1 + vatRate / 100);
      vat = price - basePrice;
      total = price * qty;
    } else if (vser == '3') {
      //   print('บวก VAT เพิ่ม');
      vat = price * (vatRate / 100);
      basePrice = price;
      total = (price + vat) * qty;
    }

    // ▶️ คำนวณ WHT (หัก ณ ที่จ่าย)
    // if (['1', '3', '5'].contains(wser)) {
    //   wht = basePrice * qty * whtRate;
    // }
    wht = basePrice * qty * whtRate;
    // ▶️ คำนวณยอดสุทธิ
    double netTotal = total - wht;

    // ⏺ บันทึกค่ากลับเข้าโมเดล
    row.pvat = basePrice.toStringAsFixed(2);
    row.vat = vat.toStringAsFixed(2);
    row.wht = wht.toStringAsFixed(2);
    row.total = netTotal.toStringAsFixed(2);

    // ✅ Debug log
    // print('🧾 รายการ: ${row.expname}');
    // print('📌 ราคาก่อน VAT: ${basePrice.toStringAsFixed(2)}');
    // print('🧮 ภาษี (VAT) $vatRate %: ${vat.toStringAsFixed(2)}');
    // print(
    //     '💸 หัก ณ ที่จ่าย (WHT) ${whtRate * 100} %: ${wht.toStringAsFixed(2)}');
    // print('✅ ยอดสุทธิ (Total): ${netTotal.toStringAsFixed(2)}');
    // print('---');

    return netTotal;
  }

  // double calculateTotal(ExpTransModelCMM row) {
  //   double price = double.tryParse(row.amt ?? '0.0') ?? 0.0;
  //   double qty = double.tryParse(row.qty ?? '1.0') ?? 1.0;
  //   if (qty <= 0) qty = 1.0;

  //   String vser = row.vser ?? '0'; // ประเภท VAT
  //   String wser = row.wser ?? '0'; // ประเภท WHT

  //   double vatRate =
  //       double.tryParse(row.nvat?.toString()?.trim() ?? '0') ?? 0.0;
  //   double whtRate =
  //       (double.tryParse(row.nwht?.toString()?.trim() ?? '0') ?? 0.0);

  //   double basePrice = price;
  //   double vat = 0.0;
  //   double total = 0.0;
  //   double wht = 0.0;

  //   // ▶️ คำนวณ VAT
  //   if (vser == '1') {
  //     print('ไม่มี VAT');
  //     vat = 0.0;
  //     basePrice = price;
  //     total = price * qty;
  //   } else if (vser == '2') {
  //     print('รวมภาษีแล้ว');
  //     basePrice = price / (1 + vatRate / 100);
  //     vat = price - basePrice;
  //     total = price * qty;
  //   } else if (vser == '3') {
  //     print('บวก VAT เพิ่ม');
  //     vat = price * (vatRate / 100);
  //     basePrice = price;
  //     total = (price + vat) * qty;
  //   }
  //   if (['1', '3', '5'].contains(wser)) {
  //     wht = basePrice * qty * whtRate; // whtRate เป็น 0.01, 0.03, 0.05 แล้ว
  //   }

  //   // ▶️ คำนวณ WHT ตามประเภท
  //   if (['1', '3', '5'].contains(wser)) {
  //     wht = basePrice * qty * whtRate;
  //   }

  //   // ▶️ คำนวณยอดสุทธิ
  //   double netTotal = total - wht;

  //   // ⏺ บันทึกค่ากลับเข้าโมเดล
  //   row.vat = vat.toStringAsFixed(2);
  //   row.wht = wht.toStringAsFixed(2);
  //   row.total = netTotal.toStringAsFixed(2);

  //   // ✅ Debug print
  //   print('🧾 รายการ: ${row.expname}');
  //   print('📌 ราคาก่อน VAT: ${basePrice.toStringAsFixed(2)}');
  //   print('🧮 ภาษี (VAT) $vatRate %: ${vat.toStringAsFixed(2)}');
  //   print('💸 หัก ณ ที่จ่าย (WHT) $whtRate % : ${wht.toStringAsFixed(2)}');
  //   print('✅ ยอดสุทธิ (Total): ${netTotal.toStringAsFixed(2)}');
  //   print('---');

  //   return netTotal;
  // }

  void _printJson() {
    final jsonList = rows.map((e) => e.toJson()).toList();
    // print(jsonEncode(jsonList));
  }

  void _addRow({required String? type}) async {
    switch (type) {
      case 'read':
        if (rows.length == 0) {
          for (var i = 0;
              i <
                  expAutoModels
                      .where((element) => element.auto.toString() == '1')
                      .length;
              i++) {
            final expAuto = expAutoModels[i];
            //  print(expAuto.expname);

            final _day = unitModels
                    .where((element) =>
                        element.ser.toString() == '${expAuto.unitser}')
                    .first
                    .day ??
                '0';

            final _vtype = vatModels
                    .where(
                        (element) => element.ser.toString() == '${expAuto.vat}')
                    .first
                    .vtype ??
                '0';
            final _nvat = vatModels
                    .where(
                        (element) => element.ser.toString() == '${expAuto.vat}')
                    .first
                    .pct ??
                '0';

            final _whtser = whtModels
                    .where(
                        (element) => element.ser.toString() == '${expAuto.wht}')
                    .first
                    .ser ??
                '0';
            final _wtype = whtModels
                    .where(
                        (element) => element.ser.toString() == '${expAuto.wht}')
                    .first
                    .wht ??
                '0';
            final _nwht = whtModels
                    .where(
                        (element) => element.ser.toString() == '${expAuto.wht}')
                    .first
                    .pct ??
                '0';
            setState(() {
              rows.add(ExpTransModelCMM(
                ser: expAuto.ser?.toString(),
                datex: data_datex ?? '0000-00-00',
                timex: data_timex ?? '00:00:00',
                qser: expAuto.qser ?? '',
                docno: expAuto.docno ?? '',
                expser: expAuto.ser?.toString(),
                expname: expAuto.expname ?? '',
                exptser: expAuto.exptser?.toString(),
                sunit: expAuto.unitser ?? '',
                unitser: expAuto.unitser ?? '',
                unit: expAuto.unit ?? '',
                day: _day.toString(),
                term: expAuto.term ?? '1',
                sdate: widget.cid_sdate ?? '0000-00-00',
                ldate: widget.cid_ldate ?? '0000-00-00',
                meter: '',
                qty: expAuto.qty ?? '1',
                amt: (double.tryParse(expAuto.pri_auto ?? '0.0') ?? 0.0)
                    .toString(), //(double.tryParse(expAuto.amt ?? '0.0') ?? 0.0).toString(),
                servat: expAuto.vat ?? '0.0',
                vser: expAuto.vat ?? '0',
                vtype: _vtype ?? '',
                nvat: _nvat ?? '0.0',
                vat: '0.0',
                pvat: expAuto.pvat ?? '0.0',
                wser: _whtser ?? '',
                nwht: _nwht ?? '0.0',
                wht: '0.0',
                wtype: _wtype ?? '',
                fine: expAuto.fine?.toString(),
                fine_unit: expAuto.fine_unit?.toString(),
                fine_late: expAuto.fine_late?.toString(),
                fine_cal: expAuto.fine_cal?.toString(),
                fine_pri: expAuto.fine_pri?.toString(),
                st: expAuto.st?.toString(),
                total: expAuto.total?.toString(),
                data_update: DateTime.now().toString(),
                etype: expAuto.etype ?? '',
                dtype: expAuto.dtype ?? '',
                ele_ty: expAuto.ele_ty ?? '',
                amt_ty: expAuto.amt_ty ?? '',
                fine_three: expAuto.fine_three?.toString(),
                fine_late_three: expAuto.fine_late_three?.toString(),
                fine_cal_three: expAuto.fine_cal_three?.toString(),
                fine_max: expAuto.fine_max?.toString(),
                fine_max_cal: expAuto.fine_max_cal?.toString(),
                pay_pakan: '0.0',
                pri_auto: expAuto.pri_auto?.toString(),
              ));
            });
          }
        }

        SecurePrefs.removeEncrypted(SecurePrefsType.expjson);

        List<ExpTransModelCMM> tempRows = List.from(rows);
        for (final row in tempRows) {
          calculateTotal(row);
        }
        await SecurePrefs.setEncrypted(
          SecurePrefsType.expjson,
          jsonEncode(rows.map((e) => e.toJson()).toList()),
        );
        final data = await SecurePrefs.getDecrypted(SecurePrefsType.expjson);
        // print('SecurePrefs expjson : $data');
        widget.onRowsChanged?.call(rows); // ✅ แจ้งกลับ parent

        break;

      case 'add':
        List<ExpTransModelCMM> tempRows = List.from(rows);
        _dialogAdddata(tempRows, onDone: (updatedList) async {
          setState(() {
            rows = updatedList; // ✅ เขียนค่ากลับเข้า rows
          });
          //  print('updatedList : ${updatedList.length}');
          //  print('rows : ${rows.length}');
          await SecurePrefs.setEncrypted(
            SecurePrefsType.expjson,
            jsonEncode(rows.map((e) => e.toJson()).toList()),
          );
          final data = await SecurePrefs.getDecrypted(SecurePrefsType.expjson);
          //    print('SecurePrefs expjson : $data');
          widget.onRowsChanged?.call(rows); // ✅ แจ้งกลับ parent
        });
        break;
      default:
        break;
    }
  }

  void _addRowData(
    BuildContext context,
    AutoExpTransModelCMM expAuto,
    void Function(void Function()) dialogSetState,
    List<ExpTransModelCMM> rows,
  ) {
    final day = unitModels
            .where((element) => element.ser.toString() == '${expAuto.unitser}')
            .first
            .day ??
        '0';
    // print(expAuto.expname); // ✅ ถูกต้องแล้ว
    dialogSetState(() {
      rows.add(ExpTransModelCMM(
        ser: expAuto.ser?.toString(),
        datex: data_datex ?? '0000-00-00',
        timex: data_timex ?? '00:00:00',
        qser: expAuto.qser ?? '',
        docno: expAuto.docno ?? '',
        expser: expAuto.ser?.toString(),
        expname: expAuto.expname ?? '',
        exptser: expAuto.exptser?.toString(),
        sunit: expAuto.unitser ?? '',
        unitser: expAuto.unitser ?? '',
        unit: expAuto.unit ?? '',
        day: day.toString(),
        term: expAuto.term ?? '1',
        sdate: widget.cid_sdate ?? '0000-00-00',
        ldate: widget.cid_ldate ?? '0000-00-00',
        meter: '',
        qty: expAuto.qty ?? '1',
        amt: (double.tryParse(expAuto.pri_auto ?? '0.0') ?? 0.0)
            .toString(), //(double.tryParse(expAuto.amt ?? '0.0') ?? 0.0).toString(),
        servat: expAuto.servat ?? '0.0',
        vser: expAuto.vser ?? '0',
        vtype: expAuto.vtype ?? '',
        nvat: expAuto.nvat ?? '0.0',
        vat: expAuto.vat ?? '0.0',
        pvat: expAuto.pvat ?? '0.0',
        wser: expAuto.wser ?? '0.0',
        nwht: expAuto.nwht ?? '0.0',
        wht: expAuto.wht ?? '0.0',
        wtype: expAuto.wtype ?? '',
        fine: expAuto.fine?.toString(),
        fine_unit: expAuto.fine_unit?.toString(),
        fine_late: expAuto.fine_late?.toString(),
        fine_cal: expAuto.fine_cal?.toString(),
        fine_pri: expAuto.fine_pri?.toString(),
        st: expAuto.st?.toString(),
        total: '0.0',
        data_update: DateTime.now().toString(),
        etype: expAuto.etype ?? '',
        dtype: expAuto.dtype ?? '',
        ele_ty: expAuto.ele_ty ?? '',
        amt_ty: expAuto.amt_ty ?? '',
        fine_three: expAuto.fine_three?.toString(),
        fine_late_three: expAuto.fine_late_three?.toString(),
        fine_cal_three: expAuto.fine_cal_three?.toString(),
        fine_max: expAuto.fine_max?.toString(),
        fine_max_cal: expAuto.fine_max_cal?.toString(),
        pay_pakan: '0.0',
        pri_auto: expAuto.pri_auto?.toString(),
      ));
    });

    // List<ExpTransModelCMM> rowsx = rows;
    // setState(() {
    //   rows.clear();
    //   rows = rowsx;
    // });
  }

  Future<void> _dialogAdddata(List<ExpTransModelCMM> tempRows,
      {required Function(List<ExpTransModelCMM>) onDone}) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                titlePadding: const EdgeInsets.all(0.0),
                contentPadding: const EdgeInsets.all(10.0),
                actionsPadding: const EdgeInsets.all(6.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        onDone(rows);
                        Navigator.pop(context);
                        // Navigator.pop(context, tempRows); // ✅ ส่งค่ากลับ
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.highlight_off,
                            size: 30, color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                    height: double.infinity * 0.85,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        // Card(
                        //   elevation: 3,
                        //   shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(12)),
                        //   child: Container(
                        //     padding: EdgeInsets.all(8),
                        //     width: double.infinity,
                        //     child: SingleChildScrollView(
                        //       scrollDirection: Axis.horizontal,
                        //     ),
                        //   ),
                        // ),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            // children: expTypeModels.map((type) {
                            //   final currentSer = type.ser;
                            //   final matchedRows = rows
                            //       .asMap()
                            //       .entries
                            //       .where((entry) =>
                            //           entry.value.exptser.toString() ==
                            //           currentSer.toString())
                            //       .toList();

                            //   if (matchedRows.isEmpty)
                            //     return SizedBox.shrink(); // skip empty groups
                            children: expTypeModels.map((type) {
                              final currentSer = type.ser;

                              final matchedRows = rows
                                  .asMap()
                                  .entries
                                  .where((entry) =>
                                      entry.value.exptser?.toString() ==
                                      currentSer?.toString())
                                  .toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: type.ser == '1' ? 10 : 20,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          'ประเภท : ${type.bills ?? 'ไม่ทราบประเภท'}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      if (expAutoModels
                                              .where((element) =>
                                                  element.exptser.toString() ==
                                                  currentSer)
                                              .length !=
                                          0)
                                        DropdownButton<String>(
                                          // value: expAutoModels.any(
                                          //         (e) => e.expname == row.expname)
                                          //     ? row.expname
                                          //     : null,
                                          hint: Center(
                                              child: Text(
                                            ' + เพิ่มข้อมูล',
                                            style: _styles,
                                          )),
                                          items: expAutoModels
                                              .where((element) =>
                                                  element.exptser.toString() ==
                                                  currentSer)
                                              .map((exp) => DropdownMenuItem(
                                                    value: exp.expname,
                                                    child:
                                                        Text(exp.expname ?? ''),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            List<ExpTransModelCMM> tempRows =
                                                [];
                                            final selected =
                                                expAutoModels.firstWhere(
                                                    (e) => e.expname == val,
                                                    orElse: () =>
                                                        AutoExpTransModelCMM());
                                            _addRowData(context, selected,
                                                setState, tempRows);
                                            setState(() {
                                              rows.addAll(
                                                  tempRows); // ✅ เพิ่มทีละ element
                                            });

                                            // setState(() {
                                            //   row.expname = selected.expname;
                                            //   row.expser =
                                            //       selected.ser?.toString();
                                            //   row.unit = selected.unit;
                                            //   row.amt = selected.amt ?? '0.0';
                                            //   calculateTotal(row);
                                            // });
                                          },
                                        )
                                    ],
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 50,
                                      headingRowHeight: 48,
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => Colors.grey[200]!),
                                      headingTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                      dataRowHeight: 56,
                                      columns: matchedRows.isEmpty
                                          ? [
                                              DataColumn(label: Text('')),
                                            ]
                                          : [
                                              DataColumn(
                                                  label: Text(
                                                'ประเภทค่าบริการ',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'ความถี่',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'จำนวนงวด',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'วันเริ่มต้น',
                                                style: _styles,
                                              )),
                                              // DataColumn(
                                              //     label: Text(
                                              //   'วันสิ้นสุด',
                                              //   style: _styles,
                                              // )),
                                              DataColumn(
                                                  label: Text(
                                                'ยอด (บาท)',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'ประเภท VAT',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'VAT',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'ประเภท WHT',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'WHT',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                'ยอดสุทธิ',
                                                style: _styles,
                                              )),
                                              DataColumn(
                                                  label: Text(
                                                '',
                                                style: _styles,
                                              )),
                                            ],
                                      rows: matchedRows.isEmpty
                                          ? [
                                              DataRow(cells: [
                                                DataCell(
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Text(
                                                      'ไม่มีข้อมูล',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ),
                                                ),
                                                // ...List.generate(
                                                //     10,
                                                //     (_) => DataCell(Container(
                                                //           alignment:
                                                //               Alignment.center,
                                                //           width: MediaQuery.of(
                                                //                       context)
                                                //                   .size
                                                //                   .width /
                                                //               14.5,
                                                //         ))),
                                              ])
                                            ]
                                          : matchedRows.map((entry) {
                                              int i = entry.key;
                                              var row = entry.value;

                                              return DataRow(cells: [
                                                // ประเภทค่าบริการ
                                                DataCell(
                                                    Text(row.expname ?? '-')),
                                                // DataCell(DropdownButton<String>(
                                                //   value: expAutoModels.any(
                                                //           (e) =>
                                                //               e.expname ==
                                                //               row.expname)
                                                //       ? row.expname
                                                //       : null,
                                                //   hint: Text('เลือก'),
                                                //   items: expAutoModels
                                                //       .map((exp) =>
                                                //           DropdownMenuItem(
                                                //             value: exp.expname,
                                                //             child: Text(
                                                //                 exp.expname ??
                                                //                     ''),
                                                //           ))
                                                //       .toList(),
                                                //   onChanged: (val) {
                                                //     final selected =
                                                //         expAutoModels.firstWhere(
                                                //             (e) =>
                                                //                 e.expname ==
                                                //                 val,
                                                //             orElse: () =>
                                                //                 AutoExpTransModelCMM());
                                                //     setState(() {
                                                //       row.expname =
                                                //           selected.expname;
                                                //       row.expser = selected.ser
                                                //           ?.toString();
                                                //       row.unit = selected.unit;
                                                //       row.amt =
                                                //           selected.amt ?? '0.0';
                                                //       calculateTotal(row);
                                                //     });
                                                //   },
                                                // )),

                                                // ความถี่
                                                DataCell(
                                                  DropdownButton<String>(
                                                    value: unitModels
                                                            .map((u) => u.ser)
                                                            .contains(
                                                                row.unitser)
                                                        ? row.unitser
                                                        : null,
                                                    hint: Text('เลือก'),
                                                    items: unitModels.map((u) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: u.ser,
                                                        child:
                                                            Text(u.unit ?? ''),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      final selected =
                                                          unitModels.firstWhere(
                                                        (u) => u.ser == val,
                                                        orElse: () =>
                                                            UnitModel(),
                                                      );
                                                      setState(() {
                                                        row.sunit =
                                                            selected.ser;
                                                        row.unitser =
                                                            selected.ser;
                                                        row.unit =
                                                            selected.unit;
                                                        row.day = selected.day;
                                                      });
                                                      printInstallmentsByDays(
                                                          context,
                                                          row,
                                                          setState);
                                                    },
                                                  ),
                                                ),

                                                // จำนวนงวด
                                                DataCell(
                                                    Text(row.term ?? '0.00')),
                                                // DataCell(SizedBox(
                                                //   width: 50,
                                                //   child: TextFormField(
                                                //     readOnly: true,
                                                //     initialValue: row.term,
                                                //     keyboardType:
                                                //         TextInputType.number,
                                                //     onChanged: (val) {
                                                //       setState(() {
                                                //         row.term = val;
                                                //         calculateTotal(row);
                                                //       });
                                                //     },
                                                //   ),
                                                // )),

                                                // วันเริ่มต้น
                                                DataCell(
                                                  SizedBox(
                                                    width: 120,
                                                    child: InkWell(
                                                      onTap: () => _selectDate(
                                                          context,
                                                          row,
                                                          setState),
                                                      child: Text(
                                                        DateFormat('dd-MM-yyyy')
                                                            .format(
                                                          DateTime.tryParse(
                                                                  row.sdate ??
                                                                      '') ??
                                                              DateTime.now(),
                                                        ),
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline), // optional
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // // วันเริ่มสิ้นสุด
                                                // DataCell(
                                                //   Text(
                                                //     DateFormat('dd-MM-yyyy')
                                                //         .format(
                                                //       DateTime.tryParse(
                                                //               row.ldate ??
                                                //                   '') ??
                                                //           DateTime.now(),
                                                //     ),
                                                //   ),
                                                // ),
                                                // ยอด
                                                DataCell(SizedBox(
                                                  width: 120,
                                                  child: TextFormField(
                                                    initialValue: row.amt,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        row.amt = val;
                                                        calculateTotal(row);
                                                      });
                                                    },
                                                  ),
                                                )),

                                                // ประเภท VAT
                                                DataCell(
                                                  DropdownButton<String>(
                                                    value: vatModels.any((v) =>
                                                            v.ser == row.vser)
                                                        ? row.vser
                                                        : null,
                                                    hint: Text('เลือก'),
                                                    items: vatModels.map((v) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: v
                                                            .ser, // ✅ ต้องเป็น String
                                                        child:
                                                            Text(v.vat ?? ''),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      final selected =
                                                          vatModels.firstWhere(
                                                        (v) => v.ser == val,
                                                        orElse: () =>
                                                            VatModel(),
                                                      );
                                                      setState(() {
                                                        row.servat =
                                                            selected.ser;
                                                        row.vser = selected.ser;
                                                        row.vtype =
                                                            selected.vat;
                                                        row.nvat = selected.pct;
                                                        calculateTotal(row);
                                                      });
                                                    },
                                                  ),
                                                ),

                                                // VAT
                                                DataCell(
                                                    Text(row.vat ?? '0.00')),

                                                // ประเภท WHT
                                                DataCell(
                                                  DropdownButton<String>(
                                                    value: whtModels
                                                            .map((w) => w.ser)
                                                            .contains(row.wser)
                                                        ? row.wser
                                                        : null,
                                                    hint: Text('เลือก'),
                                                    items: whtModels.map((w) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: w.ser,
                                                        child:
                                                            Text(w.wht ?? ''),
                                                      );
                                                    }).toList(),
                                                    onChanged: (selectedSer) {
                                                      final selected =
                                                          whtModels.firstWhere(
                                                        (w) =>
                                                            w.ser ==
                                                            selectedSer,
                                                        orElse: () =>
                                                            WhtModel(),
                                                      );
                                                      double pct = double
                                                              .tryParse(selected
                                                                      .pct ??
                                                                  '0') ??
                                                          0.0;
                                                      double price =
                                                          double.tryParse(
                                                                  row.amt ??
                                                                      '0.0') ??
                                                              0.0;
                                                      setState(() {
                                                        row.wser = selected.ser;
                                                        // row.wht = selected.wht;
                                                        row.nwht = selected.pct;
                                                        // row.wht = ((price *
                                                        //             pct) /
                                                        //         100)
                                                        //     .toStringAsFixed(2);
                                                        calculateTotal(row);
                                                      });
                                                    },
                                                  ),
                                                ),

                                                // WHT
                                                DataCell(
                                                    Text(row.wht ?? '0.00')),

                                                // ยอดสุทธิ
                                                DataCell(
                                                    Text(row.total ?? '0.00')),

                                                // ลบแถว
                                                DataCell(IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  onPressed: () => setState(
                                                      () => rows.removeAt(i)),
                                                )),
                                              ]);
                                            }).toList(),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        )
                      ]),
                    )));
          });
        });
  }

  double get grandTotal => rows.fold(
      0.0, (sum, row) => sum + (double.tryParse(row.total ?? '0.0') ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("เพิ่มรายการ"),
                onPressed: () {
                  _addRow(type: 'add');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
        Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(8),
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 48,
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey[200]!),
                  headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                  dataRowHeight: 56,
                  columns: [
                    DataColumn(
                        label: Text(
                      'ประเภทค่าบริการ',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      'ความถี่',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      'จำนวนงวด',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      'วันเริ่มต้น',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      'ราคาก่อน VAT',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      'ภาษี (VAT)',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      ' หัก ณ ที่จ่าย (WHT)',
                      style: _styles,
                    )),
                    DataColumn(
                        label: Text(
                      'ยอดสุทธิ (Total)',
                      style: _styles,
                    )),
                    // DataColumn(
                    //     label: Text(
                    //   'WHT',
                    //   style: _styles,
                    // )),
                    // DataColumn(
                    //     label: Text(
                    //   'ยอดสุทธิ',
                    //   style: _styles,
                    // )),
                    DataColumn(
                        label: Text(
                      '',
                      style: _styles,
                    )),
                  ],
                  rows: rows.asMap().entries.map((entry) {
                    int i = entry.key;
                    var row = entry.value;

                    return DataRow(cells: [
                      // ประเภทค่าบริการ
                      DataCell(
                        Text(row.expname ?? '-'),
                      ),

                      // ความถี่
                      DataCell(
                        Text(row.unit ?? '-'),
                      ),

                      // จำนวนงวด
                      DataCell(
                        SizedBox(
                          width: 50,
                          child: Text(row.term ?? '0'),
                        ),
                      ),

                      // วันเริ่มต้น
                      DataCell(
                        Text((row.sdate == '' || row.sdate == null)
                            ? '-'
                            : DateFormat('dd-MM-yyyy').format(
                                DateTime.tryParse(row.sdate ?? '') ??
                                    DateTime.now(),
                              )),

                        // Text(row.sdate ?? '00-00-0000'),
                      ),

                      // ยอด
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Text(row.pvat ?? '0.00'),
                        ),
                      ),

                      // ประเภท VAT
                      DataCell(Text(row.vat ?? '0.00')),

                      // VAT
                      DataCell(Text(row.wht ?? '0.00')),

                      // ประเภท WHT
                      DataCell(Text(row.total ?? '0.00')),

                      // // WHT
                      // DataCell(Text(row.wht ?? '0.00')),

                      // // ยอดสุทธิ
                      // DataCell(Text(row.total ?? '0.00')),

                      // ลบแถว
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            setState(() => rows.removeAt(i));
                            List<ExpTransModelCMM> tempRows = List.from(rows);
                            for (final row in tempRows) {
                              calculateTotal(row);
                            }
                            await SecurePrefs.setEncrypted(
                              SecurePrefsType.expjson,
                              jsonEncode(rows.map((e) => e.toJson()).toList()),
                            );
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: ElevatedButton.icon(
        //     icon: Icon(Icons.add),
        //     label: Text("printJson"),
        //     onPressed: _printJson,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.green[700],
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, right: 30),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'รวมทั้งหมด: ${grandTotal.toStringAsFixed(2)} บาท',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
