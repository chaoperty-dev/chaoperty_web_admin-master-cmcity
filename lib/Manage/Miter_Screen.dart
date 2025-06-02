import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/Get_tran_meter_model.dart';
import '../Model/Getexp_sz_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';

class MiterScreen extends StatefulWidget {
  const MiterScreen({super.key});

  @override
  State<MiterScreen> createState() => _MiterScreenState();
}

class _MiterScreenState extends State<MiterScreen> {
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  var nFormat3 = NumberFormat("#,##0", "en_US");
  DateTime datex = DateTime.now();
  //-------------------------------------->
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  final FormMeter_text = TextEditingController();
  ///////////--------------------------------------------->
  List<TransMeterModel> transMeterModels = <TransMeterModel>[];
  List<TransMeterModel> _transMeterModels = [];
  List<ExpSZModel> expSZModels = [];
  List<PayMentModel> _PayMentModels = [];
  ///////////--------------------------------------------->
  // ข้อมูลที่ผ่านการกรอง (สำหรับแสดงผล)
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> data = [];
  List<Map<String, String>> ac7 = [];

  List<int> Fix_data = [4, 5, 6];
  //-------------------------------------->

  // ตัวแปรสำหรับการค้นหา
  String searchQuery = "";
  //-------------------------------------->
  // Pagination
  int currentPage_1 = 0;
  bool firstRound = true;
  bool showDuplicatesOnly = false;
  bool showDubiousOnly = false;
  static const int rowsPerPage_1 = 50;
  //-------------------------------------->
  // ตัวแปรสำหรับการจัดเรียง
  bool sortAscending = true;
  String sortColumn = "รหัสพื้นที่";
  //-------------------------------------->
  // ตัวแปร debounce
  Timer? _debounce;
  // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
  int sortColumnIndex = 0;
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool isLoading_main = false;
  //-------------------------------------->
  int Ser_BodySta1 = 0;
  int renTal_lavel = 0;
  int edit_lock = 0;
  String tappedIndex_ = '';
  int tappedIndex_s = -1;
  String? serarea,
      lncodearea,
      lnarea,
      Value_D_start,
      snamearea,
      custnoarea,
      zone_ser,
      zone_name,
      zone_Subser,
      zone_Subname;
  String? rtname, type, typex, renname, expbill, cFinn, foder, api_key;
  String? paymentSer1, paymentName1, selectedValue;
  var End_Bill_Paydate;
  //-------------------------------------->
  void initState() {
    super.initState();
    checkPreferance();
    read_GC_rental();
    red_payMent();

    red_exp_sz();
    Loading_Trans_bill();
    End_Bill_Paydate = DateFormat('yyyy-MM-dd').format(datex);
  }

  Future<Null> checkPreferance() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      zone_ser = preferences.getString('zonePSer');
      zone_name = preferences.getString('zonesPName');
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });
  }

  /////////--------------------------------------------->
  Future<Null> red_payMent() async {
    if (_PayMentModels.length != 0) {
      setState(() {
        _PayMentModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        Map<String, dynamic> map = Map();
        map['ser'] = '0';
        map['datex'] = '';
        map['timex'] = '';
        map['ptser'] = '';
        map['ptname'] = 'เลือก';
        map['bser'] = '';
        map['bank'] = '';
        map['bno'] = '';
        map['bname'] = '';
        map['bsaka'] = '';
        map['btser'] = '';
        map['btype'] = '';
        map['st'] = '1';
        map['rser'] = '';
        map['accode'] = '';
        map['co'] = '';
        map['data_update'] = '';
        map['auto'] = '0';

        PayMentModel _PayMentModel = PayMentModel.fromJson(map);
        setState(() {
          _PayMentModels.add(_PayMentModel);
        });

        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          setState(() {
            _PayMentModels.add(_PayMentModel);
            if (autox == '1') {
              paymentSer1 = serx.toString();
              paymentName1 = ptnamex.toString();
            }
          });
          if (_PayMentModel.btser.toString() == '1') {
          } else {}
        }

        if (paymentSer1 == null) {
          paymentSer1 = 0.toString();
          paymentName1 = 'เลือก'.toString();
        }
      }
    } catch (e) {}
  }

  /////////--------------------------------------------->
  Future<Null> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    var ser_user = preferences.getString('ser');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname!.trim();
          var typexs = renTalModel.type!.trim();
          var typexx = renTalModel.typex!.trim();
          var bill_namex = renTalModel.bill_name!.trim();
          var bill_addrx = renTalModel.bill_addr!.trim();
          var bill_taxx = renTalModel.bill_tax!.trim();
          var bill_telx = renTalModel.bill_tel!.trim();
          var bill_emailx = renTalModel.bill_email!.trim();
          var bill_defaultx = renTalModel.bill_default;
          var bill_tserx = renTalModel.tser;
          var name = renTalModel.pn!.trim();
          var foderx = renTalModel.dbn;
          var serx = renTalModel.ser;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }

  /////////--------------------------------------------->
  Future<Null> red_exp_sz() async {
    if (expSZModels.length != 0) {
      setState(() {
        expSZModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    String url = '${MyConstant().domain}/GC_exp_sz.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        Map<String, dynamic> map = Map();
        map['ser'] = '0';
        map['user'] = '0';
        map['etype'] = '0';
        map['exptser'] = '0';
        map['expname'] = 'ทั้งหมด';
        map['st'] = '0';
        map['unit'] = '0';
        map['sdate'] = '0';
        map['vat'] = '0';
        map['wht'] = '0';
        map['cal'] = '0';
        map['pri'] = '0';
        map['rser'] = '0';
        map['fine'] = '0';
        map['fine_unit'] = '0';
        map['fine_late'] = '0';
        map['fine_cal'] = '0';
        map['fine_pri'] = '0';
        map['data_update'] = '0';

        ExpSZModel expSZModel = ExpSZModel.fromJson(map);

        setState(() {
          expSZModels.add(expSZModel);
        });

        for (var map in result) {
          ExpSZModel expSZModel = ExpSZModel.fromJson(map);
          setState(() {
            expSZModels.add(expSZModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }
    } catch (e) {}
  }

/////////--------------------------------------------->
  Loading_Trans_bill() {
    red_Trans_Mitter().then((_) {
      setState(() {
        currentPage_1 = 0;

        isLoading = false;
        isLoading_main = false;
      });
    });
  }

  ////////-------------------------------------------------------->
  Future<Null> red_Trans_Mitter() async {
    setState(() {
      isLoading_main = true;
      isLoading = true;
      _transMeterModels.clear();
      transMeterModels.clear();
      data.clear();
      filteredData.clear();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone_Sub = preferences.getString('zoneSubSer');
    // print('Ser_BodySta1 >>>>  $Ser_BodySta1');
    String url = (zone_ser.toString() == 'null')
        ? '${MyConstant().domain}/GC_trans_mitterManage.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0&serzonesub=$zone_Sub'
        : '${MyConstant().domain}/GC_trans_mitterManage.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=$zone_ser&serzonesub=$zone_Sub';
    print('GC_trans_mitterManage $url');

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransMeterModel transMeterModel = TransMeterModel.fromJson(map);
          setState(() {
            transMeterModels.add(transMeterModel);
          });
        }
      }
      setState(() {
        _transMeterModels = transMeterModels;
      });
      AddDaTa();
    } catch (e) {}
  }

  //-------------------------------------->
  Future<Null> AddDaTa() async {
    // Clear data list before adding new data
    data.clear();
    print('transMeterModels.length');
    print(transMeterModels.length);
    // Check if contractxPakanModels is not empty
    if (transMeterModels.isNotEmpty) {
      setState(() {
        data = List.generate(transMeterModels.length, (index) {
          final model = transMeterModels[index];

          final ln = model.ln ?? "";
          final refno = model.refno ?? "";
          final zn = model.zn ?? "";
          final expname = "${model.expname ?? ""} ${model.date ?? ""}";

          final num_meter = model.num_meter ?? "";
          final ovalue = (model.ovalue ?? "").padLeft(8, '0');
          final nvalue = (model.nvalue ?? "").padLeft(8, '0');

          final qty = _safeParseFormat(model.qty, nFormat3, fractionDigits: 0);
          final c_qty = (model.ele_ty == '0')
              ? _safeParseFormat(model.c_qty, nFormat)
              : "อัตราพิเศษ";
          final c_amt = _safeParseFormat(model.c_amt, nFormat);

          final prevMonthDate = DateTime(
            datex.year,
            datex.month - 1,
            datex.day,
          );

          final prevMonthLabel = DateFormat.MMM('th_TH').format(prevMonthDate);
          final currMonthLabel = DateFormat.MMM('th_TH').format(datex);

          return {
            "index": "$index",
            // "โซนพื้นที่": zn,
            "รหัสพื้นที่": ln,
            "เลขที่สัญญา": refno,
            "รายการ": expname,
            "เลขเครื่อง": num_meter,
            "มิเตอร์เดือน $prevMonthLabel": ovalue,
            "มิเตอร์เดือน $currMonthLabel": nvalue,
            "หน่วยที่ใช้": qty,
            "ราคาต่อหน่วย": c_qty,
            "รวม Vat": c_amt,
          };
        });

        filteredData = data;
      });
    } else {
      setState(() {
        final prevMonthDate = DateTime(
          datex.year,
          datex.month - 1,
          datex.day,
        );

        final prevMonthLabel = DateFormat.MMM('th_TH').format(prevMonthDate);
        final currMonthLabel = DateFormat.MMM('th_TH').format(datex);
        data = List.generate(1, (index) {
          return {
            "index": "",
            // "โซนพื้นที่": zn,
            "รหัสพื้นที่": "",
            "เลขที่สัญญา": "",
            "รายการ": "",
            "เลขเครื่อง": "",
            "มิเตอร์เดือน $prevMonthLabel": "",
            "มิเตอร์เดือน $currMonthLabel": "",
            "หน่วยที่ใช้": "",
            "ราคาต่อหน่วย": "",
            "รวม Vat": "",
          };
        });

        filteredData = data;
      });
    }
    // print('data.length');
    // print(data.length);
    // print("Data added: $data");
  }

  //-------------------------------------->
  String _safeParseFormat(String? value, NumberFormat formatter,
      {int? fractionDigits}) {
    try {
      double val = double.parse(value ?? '0');
      if (fractionDigits != null) {
        val = double.parse(val.toStringAsFixed(fractionDigits));
      }
      return formatter.format(val);
    } catch (e) {
      return '0';
    }
  }

  //-------------------------------------->
  // ฟังก์ชันค้นหา
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    setState(() {
      isLoading = true; // กำหนดให้กำลังโหลด
    });
    _debounce = Timer(Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = query;
        currentPage_1 = 0; // รีเซ็ตหน้า
        filteredData = data.where((row) {
          return row.entries.any((entry) {
            return entry.value
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
          });
        }).toList();
        isLoading = false; // กำหนดให้โหลดเสร็จแล้ว
      });
    });
  }

  ////////--------------------------------------------------------------->
// ฟังก์ชันตรวจสอบข้อมูลซ้ำ
  bool hasDuplicate(Map<String, dynamic> row) {
    // ตรวจสอบว่ามีข้อมูลซ้ำใน _TransReBillModels หรือไม่
    return transMeterModels
            .where((e) => e.ln.toString() == row['รหัสพื้นที่'].toString())
            .length >
        2;
  }

  bool hasMain(Map<String, dynamic> row) {
    return showDuplicatesOnly == true
        ? hasDuplicate(row)
        : showDubiousOnly == true
            ? hasDubious(row)
            : false;
  }

  bool hasDubious(Map<String, dynamic> row) {
    // ตรวจสอบว่า 'หน่วยที่ใช้' หรือ 'รวม Vat' มีค่าน้อยกว่า 1 หรือไม่
    double qty = double.tryParse(row['หน่วยที่ใช้']?.toString() ?? '0') ?? 0;
    double vat = double.tryParse(row['รวม Vat']?.toString() ?? '0') ?? 0;

    return qty < 1 || vat < 1;
  }

// ฟังก์ชันกรองข้อมูลซ้ำ
  void filterDuplicates() {
    setState(() {
      tappedIndex_ = '';
      if (showDuplicatesOnly) {
        // แสดงข้อมูลทั้งหมด
        filteredData = List.from(data);
      } else {
        // ใช้ Map เพื่อตรวจสอบความถี่ของค่าใน เลขที่ใบวางบิล
        final seen = <String, int>{};
        for (var row in data) {
          final key = row["รหัสพื้นที่"]?.toString() ??
              ''; // ใช้ เลขที่ใบวางบิล เป็น key

          // ตรวจสอบว่า key ไม่เป็นค่าว่างก่อนที่จะนับ
          if (key != '') {
            seen[key] = (seen[key] ?? 0) + 1; // นับจำนวนครั้งที่พบ
          }
        }

        // กรองเฉพาะข้อมูลที่ซ้ำ
        filteredData = data.where((row) {
          final key = row["รหัสพื้นที่"]?.toString() ??
              ''; // ใช้ เลขที่ใบวางบิล เป็น key
          return key != '' &&
              seen[key]! >
                  2; // เงื่อนไข: key ไม่เป็นค่าว่างและมีมากกว่า 1 ครั้ง
        }).toList();

        // แจ้งเตือนหากไม่มีข้อมูลซ้ำ
        if (filteredData.isEmpty) {
          Dialog_duplicates(1);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('No duplicates found')),
          // );
          filteredData = List.from(data); // คืนค่าข้อมูลทั้งหมด
        }
      }
      currentPage_1 = 0; // รีเซ็ตหน้า
      // สลับสถานะการแสดงผล
      showDuplicatesOnly = !showDuplicatesOnly;
      if (showDubiousOnly == true) {
        setState(() {
          showDubiousOnly = !showDubiousOnly;
        });
      }
    });
  }

  ////////--------------------------------------------------------------->
  void filterDubious() {
    setState(() {
      tappedIndex_ = '';
      if (showDubiousOnly) {
        // แสดงข้อมูลทั้งหมด
        filteredData = List.from(data);
      } else {
        // กรองเฉพาะข้อมูลที่หน่วยที่ใช้ < 1 หรือ รวม Vat < 1
        filteredData = data.where((row) {
          final usageStr =
              row["หน่วยที่ใช้"]?.toString().replaceAll(',', '') ?? '0';
          final vatStr = row["รวม Vat"]?.toString().replaceAll(',', '') ?? '0';

          double usage = double.tryParse(usageStr) ?? 0;
          double vat = double.tryParse(vatStr) ?? 0;

          return usage < 1 || vat < 1;
        }).toList();

        // แจ้งเตือนหากไม่มีข้อมูลที่เข้าเงื่อนไข
        if (filteredData.isEmpty) {
          Dialog_duplicates(2);
          filteredData = List.from(data); // คืนค่าทั้งหมด
        }
      }
      currentPage_1 = 0; // รีเซ็ตหน้า
      showDubiousOnly = !showDubiousOnly;
      if (showDuplicatesOnly == true) {
        setState(() {
          showDuplicatesOnly = !showDuplicatesOnly;
        });
      }
    });
  }

  ////////--------------------------------------------------------------->
  Widget Next_page_Miter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Container(
          height: 30,
          width: 140,
          child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: currentPage_1 > 0
                                  ? () async {
                                      setState(() {
                                        currentPage_1--;
                                      });
                                      _scrollController1.animateTo(
                                        0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  : null,
                              child: Icon(
                                Icons.arrow_left,
                                color: Colors.black,
                                size: 25,
                              )),
                          Text(
                            '${currentPage_1 + 1} / ${(filteredData.length / rowsPerPage_1).ceil()}',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T,
                              //fontSize: 10.0 Account_BillPayVerifi
                            ),
                          ),
                          InkWell(
                              onTap: (currentPage_1 + 1) * rowsPerPage_1 <
                                      filteredData.length
                                  ? () async {
                                      setState(() {
                                        currentPage_1++;
                                      });
                                      _scrollController1.animateTo(
                                        0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  : null,
                              child: Icon(
                                Icons.arrow_right,
                                color: Colors.black,
                                size: 25,
                              )),
                        ],
                      ),
                    )
                  ]))),
    );
  }

  ////////-------------------------->
  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }


/////////////----------------------------------------------------------->
  var extension_;
  var file_;
  String? base64_Slip, fileName_Slip;
  Future<void> uploadFile_Slip(docno, Cid, ser) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      print('User canceled image selection');
      return;
    } else {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      setState(() {
        base64_Slip = base64Image;
      });

      setState(() {
        extension_ = 'png';
        // file_ = file;
      });
      // print(extension_);
      // print(extension_);
      Future.delayed(Duration(milliseconds: 200), () {
        OKuploadFile_Slip(docno, Cid, ser);
      });
    }
    // print(base64_Slip);
    //
  }

/////////////----------------------------------------------------------->
  Future<void> OKuploadFile_Slip(docno, Cid, ser) async {
    if (base64_Slip != null) {
      String Path_foder = 'Meter';
      String dateTimeNow = DateTime.now().toString();
      String date = DateFormat('ddMMyyyy')
          .format(DateTime.parse('${dateTimeNow}'))
          .toString();
      final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
      final formatter2 = DateFormat('HHmmss');
      final formattedTime2 = formatter2.format(dateTimeNow2);
      String Time_ = formattedTime2.toString();

      setState(() {
        fileName_Slip = 'Meter_${Cid}_${date}_$Time_.$extension_';
      });

      try {
        // 2. Read the image as bytes
        // final imageBytes = await pickedFile.readAsBytes();

        // 3. Encode the image as a base64 string
        // final base64Image = base64Encode(imageBytes);

        // 4. Make an HTTP POST request to your server
        final url =
            '${MyConstant().domain}/File_uploadMeter.php?name=$fileName_Slip&Foder=$foder&extension=$extension_';

        final response = await http.post(
          Uri.parse(url),
          body: {
            'image': base64_Slip,
            'Foder': foder,
            'name': fileName_Slip,
            'ex': extension_.toString()
          }, // Send the image as a form field named 'image'
        );

        if (response.statusCode == 200) {
          print('File uploaded successfully!*** : $fileName_Slip');
          OK_up_insert_img(docno, Cid, ser);
        } else {
          print('Image upload failed');
        }
      } catch (e) {
        print('Error during image processing: $e');
        print('Error : $base64_Slip');
        print('Error : $foder');
      }
    } else {
      print('ยังไม่ได้เลือกรูปภาพ');
    }
  }

/////////////----------------------------------------------------------->
  Future<void> OK_up_insert_img(docno, Cid, ser) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');

    var docno_ = docno;
    String url =
        '${MyConstant().domain}/UPC_Invoice_img.php?isAdd=true&ren=$ren&fileName=$fileName_Slip&transer=$ser';
    print('$docno_ /// $ren /// $user /// $fileName_Slip ');
    print('$url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() == 'true') {
        //print(result);
        // Navigator.pop(context);
        setState(() {
          checkPreferance();
        });
      }
    } catch (e) {}
  }

  ////////-------------------------->
  @override
  Widget build(BuildContext context) {
    double calculatedWidth = (Responsive.isDesktop(context))
        ? MediaQuery.of(context).size.width * 0.85
        : 1200;

    // For the first round, use the extracted data as is, no need to sort.
    List<Map<String, dynamic>> displayedData;

    if (firstRound) {
      displayedData = filteredData; // Use the extracted data without sorting
      displayedData = filteredData
          .skip(currentPage_1 * rowsPerPage_1)
          .take(rowsPerPage_1)
          .toList();
    } else {
      // For subsequent rounds, apply sorting
      filteredData.sort((a, b) {
        if (sortAscending) {
          return a[sortColumn].toString().compareTo(b[sortColumn].toString());
        } else {
          return b[sortColumn].toString().compareTo(a[sortColumn].toString());
        }
      });

      // Apply pagination
      displayedData = filteredData
          .skip(currentPage_1 * rowsPerPage_1)
          .take(rowsPerPage_1)
          .toList();
    }

    // ดึงคีย์จากแถวแรกเพื่อใช้เป็นคอลัมน์
    final columnHeaders =
        filteredData.isNotEmpty ? filteredData[0].keys.toList() : [];
    // final Expan = columnHeaders.skip(1).map().toList();
//////////---------------------------->
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(23, 8, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int index = 0; index < expSZModels.length; index++)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          Ser_BodySta1 = int.parse(expSZModels[index].ser!);
                        });
                        Loading_Trans_bill();
                      },
                      child: Container(
                        // width: 130,
                        decoration: BoxDecoration(
                          color: (Ser_BodySta1 ==
                                  int.parse(expSZModels[index].ser!))
                              ? Colors.green[600]
                              : Colors.green[200],
                          // (index == 0)
                          //     ? (Ser_BodySta1 ==
                          //             int.parse(expSZModels[index].ser!))
                          //         ? Colors.brown[600]
                          //         : Colors.brown[200]
                          //     : (index == 1)
                          //         ? (Ser_BodySta1 ==
                          //                 int.parse(
                          //                     expSZModels[index].ser!))
                          //             ? Colors.blue[600]
                          //             : Colors.blue[200]
                          //         : (index == 2)
                          //             ? (Ser_BodySta1 ==
                          //                     int.parse(
                          //                         expSZModels[index].ser!))
                          //                 ? Colors.red[600]
                          //                 : Colors.red[200]
                          //             : (Ser_BodySta1 ==
                          //                     int.parse(
                          //                         expSZModels[index].ser!))
                          //                 ? Colors.purple[600]
                          //                 : Colors.purple[200],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0)),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              '${expSZModels[index].expname}',
                              (Ser_BodySta1 ==
                                      int.parse(expSZModels[index].ser!))
                                  ? Colors.white
                                  : Colors.grey[800],
                              TextAlign.start,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              12,
                              1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ช่องค้นหา
          Container(
            width: calculatedWidth,
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
                  children: [
                    Expanded(
                      child: Container(
                        height: 30, //Date_ser
                        // width: 150,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.Sub_Abg_Colors,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: (isLoading_main)
                            ? const Center(
                                child: Text(
                                  'ดาวน์โหลดข้อมูล',
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T
                                      //fontSize: 10.0
                                      ),
                                ),
                              )
                            : (transMeterModels.isEmpty)
                                ? const Center(
                                    child: Text(
                                      'ไม่พบข้อมูล',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  )
                                : TextField(
                                    onChanged: onSearchChanged,
                                    decoration: const InputDecoration(
                                      // labelText:
                                      //     (isLoading_main) ? 'ดาวน์โหลดข้อมูล...' : null,
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                        ),
                                      ),
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                  ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                    //   child: Container(
                    //     height: 30,
                    //     decoration: BoxDecoration(
                    //       color: AppbackgroundColor.Sub_Abg_Colors,
                    //       // .withOpacity(0.5),
                    //       borderRadius: BorderRadius.only(
                    //           topLeft: Radius.circular(0),
                    //           topRight: Radius.circular(6),
                    //           bottomLeft: Radius.circular(0),
                    //           bottomRight: Radius.circular(6)),
                    //       // border: Border.all(
                    //       //     color:
                    //       //         Colors.grey,
                    //       //     width: 1),
                    //     ),
                    //     width: 130,
                    //     // height: 30,
                    //     padding: const EdgeInsets.all(2.0),
                    //     child: DropdownButtonHideUnderline(
                    //       child: DropdownButton2<String>(
                    //         isExpanded: true,
                    //         hint: Center(
                    //           child: Text(
                    //             'หัวข้อ',
                    //             style: const TextStyle(
                    //               fontSize: 14,
                    //               color: AccountScreen_Color.Colors_Text1_,
                    //               fontWeight: FontWeight.bold,
                    //               fontFamily: Font_.Fonts_T,
                    //             ),
                    //           ),
                    //         ),

                    //         items: ac7.asMap().entries.map((entry) {
                    //           int index = entry.key; // Get the index
                    //           var item = entry.value;
                    //           return DropdownMenuItem<String>(
                    //             value: item["ser"], // Use "ser" as the value
                    //             enabled:
                    //                 false, // Set to true to allow selection
                    //             child: StatefulBuilder(
                    //               builder: (context, menuSetState) {
                    //                 // final isSelected = selectedItems.contains(item);
                    //                 return InkWell(
                    //                   onTap: () {
                    //                     int selectedIndex = ac7.indexWhere(
                    //                         (items) =>
                    //                             items["ser"] == item["ser"]);
                    //                     // print(ac1[selectedIndex]
                    //                     //     [
                    //                     //     "pn"]);
                    //                     // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                    //                     //This rebuilds the StatefulWidget to update the button's text
                    //                     setState(() {
                    //                       if (item["st"]! == '1') {
                    //                         ac7[selectedIndex]["st"] = '0';
                    //                       } else {
                    //                         ac7[selectedIndex]["st"] = '1';
                    //                       }
                    //                     });
                    //                     AddDaTa();
                    //                     //This rebuilds the dropdownMenu Widget to update the check mark
                    //                     menuSetState(() {});
                    //                   },
                    //                   child: Container(
                    //                     height: double.infinity,
                    //                     padding: const EdgeInsets.symmetric(
                    //                         horizontal: 4.0),
                    //                     child: Row(
                    //                       children: [
                    //                         if (item["st"]! == '1')
                    //                           Icon(
                    //                             Icons.check_box_outlined,
                    //                             color: Colors.green[400],
                    //                           )
                    //                         else
                    //                           const Icon(Icons
                    //                               .check_box_outline_blank),
                    //                         Expanded(
                    //                           child: Text(
                    //                             item["pn"]!,
                    //                             maxLines: 2,
                    //                             style: const TextStyle(
                    //                               fontSize: 12,
                    //                               color: AccountScreen_Color
                    //                                   .Colors_Text1_,
                    //                               fontWeight: FontWeight.w600,
                    //                               fontFamily: Font_.Fonts_T,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 );
                    //               },
                    //             ),
                    //           );
                    //         }).toList(),
                    //         //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
                    //         // value: selectedItems.isEmpty ? null : selectedItems.last,
                    //         onChanged: (value) {},
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Container(
                        height: 30,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.Sub_Abg_Colors.withOpacity(
                              0.5),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          // border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: InkWell(
                          onTap: filterDuplicates,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  AppbackgroundColor.Sub_Abg_Colors.withOpacity(
                                      0.5),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Translate.TranslateAndSetText(
                                      showDuplicatesOnly
                                          ? 'ข้อมูลทั้งหมด'
                                          : 'กรองข้อมูลซ้ำ',
                                      Colors.grey,
                                      TextAlign.center,
                                      null,
                                      Font_.Fonts_T,
                                      12,
                                      1),
                                ),
                                Center(
                                  child: Icon(
                                    showDuplicatesOnly
                                        ? Icons.list
                                        : Icons.filter_alt_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  // IconButton(
                                  //   icon: Icon(
                                  //     showDuplicatesOnly
                                  //         ? Icons.list
                                  //         : Icons.filter_alt,
                                  //     size: 16,
                                  //   ),
                                  //   onPressed: filterDuplicates,
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Container(
                        height: 30,
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppbackgroundColor.Sub_Abg_Colors.withOpacity(
                              0.5),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          // border: Border.all(color: Colors.white, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: InkWell(
                          onTap: filterDubious,
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  AppbackgroundColor.Sub_Abg_Colors.withOpacity(
                                      0.5),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Translate.TranslateAndSetText(
                                      showDubiousOnly
                                          ? 'ข้อมูลทั้งหมด'
                                          : 'กรองข้อมูลน่าสงสัย',
                                      Colors.grey[600],
                                      TextAlign.center,
                                      null,
                                      Font_.Fonts_T,
                                      12,
                                      1),
                                ),
                                Center(
                                  child: Icon(
                                    showDubiousOnly
                                        ? Icons.list
                                        : Icons.filter_alt_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  // IconButton(
                                  //   icon: Icon(
                                  //     showDuplicatesOnly
                                  //         ? Icons.list
                                  //         : Icons.filter_alt,
                                  //     size: 16,
                                  //   ),
                                  //   onPressed: filterDuplicates,
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: Dialog_InvoiceAll,
                          style: ButtonStyle(
                            //  backgroundColor:
                            // MaterialStateProperty.all<
                            //     Color>(Colors.green),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 37, 118, 184)),
                          ),
                          child: Center(
                            child: Translate.TranslateAndSetText(
                                '📄 Invoice',
                                Colors.white,
                                TextAlign.start,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                          ),
                        ),
                      ),
                    ),
                    Container(child: Next_page_Miter())
                  ],
                ),
                const Divider(),
                //${MONTH_Now}//${YEAR_Now}
                // SizedBox(
                //   width: (Responsive.isDesktop(context))
                //       ? MediaQuery.of(context).size.width * 0.83
                //       : MediaQuery.of(context).size.width,
                //   child: ScrollConfiguration(
                //       behavior: ScrollConfiguration.of(context)
                //           .copyWith(dragDevices: {
                //         PointerDeviceKind.touch,
                //         PointerDeviceKind.mouse,
                //       }),
                //       child: SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Row(children: [
                //             Container(
                //               decoration: BoxDecoration(
                //                 color: AppbackgroundColor.Sub_Abg_Colors
                //                     .withOpacity(0.5),
                //                 borderRadius: BorderRadius.only(
                //                     topLeft: Radius.circular(10),
                //                     topRight: Radius.circular(10),
                //                     bottomLeft: Radius.circular(10),
                //                     bottomRight: Radius.circular(10)),
                //                 // border: Border.all(color: Colors.white, width: 1),
                //               ),
                //               child: Row(
                //                 children: [],
                //               ),
                //             ),
                //           ]))),
                // ),

                // const Divider(),
              ],
            ),
          ),

          // ตารางข้อมูล
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                  width: calculatedWidth,
                  height: MediaQuery.of(context).size.height / 1.63,
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
                      // Fixed Topic Row (Header)
                      Container(
                        color: AppbackgroundColor.TiTile_Colors,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 16),
                        child: Row(children: [
                          ...columnHeaders
                              .skip(1)
                              .map((column) => Expanded(
                                    flex: (column.toString() == 'รายละเอียด')
                                        ? 1
                                        : 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          firstRound = false;
                                          // Toggle sort order
                                          if (sortColumn == column) {
                                            sortAscending = !sortAscending;
                                          } else {
                                            sortColumn = column;
                                            sortAscending = true;
                                          }

                                          // Sort the displayed data
                                          displayedData.sort((a, b) {
                                            final aValue = a[column];
                                            final bValue = b[column];

                                            // Handle null values gracefully
                                            if (aValue == null &&
                                                bValue == null) return 0;
                                            if (aValue == null)
                                              return sortAscending ? -1 : 1;
                                            if (bValue == null)
                                              return sortAscending ? 1 : -1;

                                            // Compare values
                                            return sortAscending
                                                ? aValue.compareTo(bValue)
                                                : bValue.compareTo(aValue);
                                          });
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: ([9].contains(
                                                columnHeaders.indexWhere(
                                                    (item) => item == column)))
                                            ? MainAxisAlignment.center
                                            : MainAxisAlignment.start,
                                        children: [
                                          if (sortColumn ==
                                              column) // Show sorting indicator
                                            Icon(
                                              sortAscending
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              size: 20,
                                              color: Colors.red[600],
                                            ),
                                          Expanded(
                                            child: ([
                                              5,
                                              6
                                            ].contains(columnHeaders.indexWhere(
                                                    (item) => item == column)))
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            2, 0, 0, 0),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              4, 1, 4, 1),
                                                      decoration: ([
                                                        5,
                                                        6
                                                      ].contains(columnHeaders
                                                              .indexWhere(
                                                                  (item) =>
                                                                      item ==
                                                                      column)))
                                                          ? BoxDecoration(
                                                              color: [
                                                                5
                                                              ].contains(columnHeaders
                                                                      .indexWhere((item) =>
                                                                          item ==
                                                                          column))
                                                                  ? Colors
                                                                      .green[
                                                                          300]!
                                                                      .withOpacity(
                                                                          0.5)
                                                                  : Colors
                                                                      .orange[
                                                                          300]!
                                                                      .withOpacity(
                                                                          0.5),
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0)),
                                                              // border: Border.all(
                                                              //     color: Colors.grey, width: 1),
                                                            )
                                                          : null,
                                                      child: Translate.TranslateAndSetText(
                                                          column,
                                                          AccountScreen_Color
                                                              .Colors_Text1_,
                                                          (column.toString() ==
                                                                      'หน่วยที่ใช้' ||
                                                                  column.toString() ==
                                                                      'ราคาต่อหน่วย' ||
                                                                  column.toString() ==
                                                                      'รวม Vat')
                                                              ? TextAlign.right
                                                              : TextAlign.left,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          13.8,
                                                          1),
                                                    ),
                                                  )
                                                : Translate.TranslateAndSetText(
                                                    column,
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    (column.toString() ==
                                                                'หน่วยที่ใช้' ||
                                                            column.toString() ==
                                                                'ราคาต่อหน่วย' ||
                                                            column.toString() ==
                                                                'รวม Vat')
                                                        ? TextAlign.right
                                                        : TextAlign.left,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    13.8,
                                                    1),
                                          ),
                                          if ([6].contains(
                                              columnHeaders.indexWhere((item) =>
                                                  item ==
                                                  column))) // Show sorting indicator
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 2, 0),
                                              child: InkWell(
                                                onDoubleTap: () {
                                                  setState(() {
                                                    edit_lock = (edit_lock == 0)
                                                        ? 1
                                                        : 0;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      4, 1, 4, 1),
                                                  decoration: BoxDecoration(
                                                    color: (edit_lock == 1)
                                                        ? Colors.green[100]
                                                        : Colors.orange[100],
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    0),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0)),
                                                    // border: Border.all(
                                                    //     color: Colors.grey, width: 1),
                                                  ),
                                                  // radius: 12,
                                                  // backgroundColor:
                                                  //     (edit_lock == 1)
                                                  //         ? Colors.green[100]
                                                  //         : Colors.orange[100],
                                                  child: Icon(
                                                    size: 18,
                                                    Icons.border_color,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                          Container(
                            width: 120,
                            child: Translate.TranslateAndSetText(
                                '...',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                1),
                          ),
                        ]),
                      ),

                      // Scrollable ListView.builder for Data Rows
                      Expanded(
                        child: (isLoading)
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
                                          child: Text(
                                            'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.', // ตัวบ่งชี้กำลังโหลด
                                            // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
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
                            : (displayedData.isEmpty)
                                ? Center(
                                    child: const Text(
                                      'ไม่พบข้อมูล',
                                      style: TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T
                                          //fontSize: 10.0
                                          ),
                                    ),
                                  )
                                : (transMeterModels.isEmpty)
                                    ? Center(
                                        child: const Text(
                                          'ไม่พบข้อมูล',
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontFamily: Font_.Fonts_T
                                              //fontSize: 10.0
                                              ),
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: _scrollController2,
                                        itemCount: displayedData.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final row = displayedData[index];
                                          final columnToCheck = 'รายการ';
                                          return (hasMain(row) &&
                                                  row[columnToCheck]
                                                          ?.toString() !=
                                                      '')
                                              ? SizedBox(
                                                  width: calculatedWidth,
                                                  child: Column(
                                                    children: [
                                                      List_Material(
                                                          index,
                                                          columnHeaders,
                                                          row,
                                                          columnToCheck),
                                                      Container(
                                                        width: calculatedWidth,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8,
                                                                horizontal: 16),
                                                        decoration:
                                                            BoxDecoration(
                                                          // color: tappedIndex_ ==
                                                          //         index.toString()
                                                          //     ? tappedIndex_Color
                                                          //         .tappedIndex_Colors
                                                          //     : (hasMain(row) &&
                                                          //             row[columnToCheck]
                                                          //                     ?.toString() !=
                                                          //                 '')
                                                          //         ? Colors.red[200]!
                                                          //             .withOpacity(
                                                          //                 0.6)
                                                          //         : AppbackgroundColor
                                                          //             .Sub_Abg_Colors,
                                                          border: const Border(
                                                            bottom: BorderSide(
                                                              color: Colors
                                                                  .black12,
                                                              width: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .warning_sharp,
                                                              size: 15,
                                                              color: Colors
                                                                  .amber[800],
                                                            ),
                                                            Text(
                                                              'ตรวจพบข้อมูลที่อาจซ้ำ/น่าสงสัย..!! ( ${row[columnToCheck]} )',
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontFamily:
                                                                      Font_
                                                                          .Fonts_T
                                                                  //fontSize: 10.0
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : List_Material(
                                                  index,
                                                  columnHeaders,
                                                  row,
                                                  columnToCheck);
                                        },
                                      ),
                      ),
                    ],
                  )),
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
                              _scrollController2.animateTo(
                                0,
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  // color: AppbackgroundColor
                                  //     .TiTile_Colors,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(8)),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: const EdgeInsets.all(3.0),
                                child: const Text(
                                  'Top',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                    fontFamily: FontWeight_.Fonts_T,
                                  ),
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (_scrollController2.hasClients) {
                              final position =
                                  _scrollController2.position.maxScrollExtent;
                              _scrollController2.animateTo(
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
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                'Down',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                  fontFamily: FontWeight_.Fonts_T,
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
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(3.0),
                            child: const Text(
                              'Scroll',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            )),
                        InkWell(
                          onTap: _moveDown2,
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
          // Pagination Controls
        ],
      ),
    );
  }

  /////////////----------------------------->
  Widget List_Material(index, columnHeaders, row, columnToCheck) {
    return Material(
      // surfaceTintColor: tappedIndex_Color
      //     .tappedIndex_Colors,
      color: tappedIndex_ == index.toString()
          ? tappedIndex_Color.tappedIndex_Colors
          : AppbackgroundColor.Sub_Abg_Colors,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          // color: Colors.green[100]!
          //     .withOpacity(0.5),
          border: (showDuplicatesOnly == true || showDubiousOnly == true)
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
        ),
        child: Row(children: [
          ...columnHeaders
              .skip(1)
              .map((column) => (columnHeaders.any((columnx) {
                    return column.toString() == 'เลขที่สัญญา';
                  }))
                      ? Expanded(
                          flex: 1,
                          child: Row(children: [
                            (row[column]?.toString() == '' ||
                                    row[column] == null)
                                ? SizedBox()
                                : Copy_Text(
                                    context, row[column]?.toString() ?? ''),
                            Expanded(
                              child: Tooltip(
                                richMessage: TextSpan(
                                  text: row[column]?.toString() ?? '',
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
                                  minFontSize: 11,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                  row[column]?.toString() ?? '',
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            )
                          ]))
                      : (edit_lock == 1 &&
                              [6].contains(columnHeaders
                                  .indexWhere((item) => item == column)))
                          ? Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
                                child: Container(
                                  height: 33,
                                  child: TextFormField(
                                    // scrollPadding: const EdgeInsets.all(1.0),
                                    autofocus: renTal_lavel <= 1
                                        ? false
                                        : tappedIndex_s + 1 == index
                                            ? true
                                            : false,
                                    readOnly: renTal_lavel <= 1 ? true : false,
                                    // focusNode: myFocusNode,
                                    textAlign: TextAlign.right,
                                    keyboardType: TextInputType.number,
                                    // controller: FormMeter_text,
                                    validator: (value) {
                                      try {
                                        if (value == null || value.isEmpty) {
                                          return 'กรุณากรอกค่า';
                                        }

                                        final input = int.parse(value);
                                        final indexx =
                                            int.parse(row['index'].toString());
                                        final oldValue = int.parse(
                                            transMeterModels[indexx]
                                                .ovalue
                                                .toString());

                                        if (input < oldValue) {
                                          return 'ค่าต้องไม่น้อยกว่า $oldValue';
                                        }
                                      } catch (e) {
                                        return 'รูปแบบไม่ถูกต้อง';
                                      }

                                      return null;
                                    },
                                    // maxLength: 13,
                                    initialValue:
                                        transMeterModels[index].nvalue,
                                    onChanged: (value) {
                                      setState(() {
                                        tappedIndex_ = index;
                                      });
                                    },
                                    onFieldSubmitted: (valuem) async {
                                      int index_x =
                                          int.parse('${row['index']}');
                                      // Dia_log2();
                                      try {
                                        final value = int.parse(
                                            valuem); // ตรวจสอบว่าเป็นตัวเลข

                                        final ovalue = int.parse(
                                            transMeterModels[index_x].ovalue ??
                                                '0');

                                        if (value < ovalue) {
                                          Dialog_Error(
                                              'ค่าที่กรอกต้องมากกว่าหรือเท่ากับค่าเริ่มต้น (${ovalue})');
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   SnackBar(
                                          //     backgroundColor: Colors.orange,
                                          //     content: Text(
                                          //         'ค่าที่กรอกต้องมากกว่าหรือเท่ากับค่าเริ่มต้น (${ovalue})'),
                                          //   ),
                                          // );
                                          return;
                                        }

                                        SharedPreferences preferences =
                                            await SharedPreferences
                                                .getInstance();

                                        String? ren =
                                            preferences.getString('renTalSer');
                                        String? ser_user =
                                            preferences.getString('ser');
                                        var qser_in =
                                            transMeterModels[index_x].ser_in;
                                        var tran_ser =
                                            transMeterModels[index_x].ser;
                                        var nvalue =
                                            transMeterModels[index_x].nvalue;
                                        var tran_expser =
                                            transMeterModels[index_x].expser;
                                        var _celvat =
                                            transMeterModels[index_x].nvat;
                                        var _cser =
                                            transMeterModels[index_x].ser;
                                        var _cqty_vat =
                                            transMeterModels[index_x].c_qty;

                                        String url =
                                            '${MyConstant().domain}/UPC_Invoice_n.php?isAdd=true&ren=$ren&qser_in=$qser_in&qty=$value&ser_user=$ser_user&ovalue=$ovalue&nvalue=$nvalue&_celvat=$_celvat&_cqty_vat=$_cqty_vat&con_ser=$_cser&tran_ser=$tran_ser&tran_expser=$tran_expser';

                                        print(url);

                                        var response =
                                            await http.get(Uri.parse(url));
                                        var result = json.decode(response.body);

                                        if (result.toString() != 'null') {
                                          setState(() {
                                            FormMeter_text.clear();
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration:
                                                  Duration(milliseconds: 500),
                                              backgroundColor: Colors.green,
                                              content: Text('บันทึกสำเร็จ...!'),
                                            ),
                                          );
                                          Dia_log2();
                                          Insert_log.Insert_logs(
                                            'จัดการ',
                                            'มิเตอร์น้ำไฟฟ้า>>แก้ไขเลขมิเตอร์เดือนนี้(${transMeterModels[index_x].ln}, ${transMeterModels[index_x].expname})',
                                          );
                                        }
                                      } catch (e) {
                                        print('ERROR: $e');
                                        Dialog_Error(
                                            'เกิดข้อผิดพลาดหรือตัวเลขไม่ถูกต้อง!');
                                        // Navigator.pop(context);
                                        // ScaffoldMessenger.of(context)
                                        //     .showSnackBar(
                                        //   SnackBar(
                                        //     backgroundColor: Colors.red,
                                        //     content: Text(
                                        //         'เกิดข้อผิดพลาดหรือตัวเลขไม่ถูกต้อง!'),
                                        //   ),
                                        // );
                                      }

                                      // Insert_log.Insert_logs(
                                      //   'จัดการ',
                                      //   'มิเตอร์น้ำไฟฟ้า>>แก้ไขเลขมิเตอร์เดือนนี้(${transMeterModels[index_x].ln}, ${transMeterModels[index_x].expname})',
                                      // );

                                      setState(() {
                                        tappedIndex_ = index_x.toString();
                                      });

                                      // int index_x =
                                      //     int.parse('${row['index']}');
                                      // SharedPreferences preferences =
                                      //     await SharedPreferences.getInstance();
                                      // Dia_log2();
                                      // String? ren =
                                      //     preferences.getString('renTalSer');
                                      // String? ser_user =
                                      //     preferences.getString('ser');

                                      // var qser_in =
                                      //     transMeterModels[index_x].ser_in;

                                      // var tran_ser =
                                      //     transMeterModels[index_x].ser;
                                      // var ovalue = transMeterModels[index_x]
                                      //     .ovalue; // ก่อน
                                      // var nvalue = transMeterModels[index_x]
                                      //     .nvalue; // หลัง
                                      // // _celvat; //vat
                                      // // _cqty_vat; // หน่วย
                                      // // var qser_inn =
                                      // //     transMeterModels[
                                      // //             index + 1]
                                      // //         .ser_in;

                                      // var tran_expser =
                                      //     transMeterModels[index_x].expser;
                                      // var _celvat =
                                      //     transMeterModels[index_x].nvat;
                                      // var _cser = transMeterModels[index_x].ser;
                                      // var _cqty_vat =
                                      //     transMeterModels[index_x].c_qty;

                                      // // print(
                                      // //     'ovalue>>>. $ovalue  ---- nvalue>>>>>> $nvalue');
                                      // // var value =
                                      // //     FormMeter_text.text;
                                      // var value = valuem;
                                      // String url =
                                      //     '${MyConstant().domain}/UPC_Invoice_n.php?isAdd=true&ren=$ren&qser_in=$qser_in&qty=$value&ser_user=$ser_user&ovalue=$ovalue&nvalue=$nvalue&_celvat=$_celvat&_cqty_vat=$_cqty_vat&con_ser=$_cser&tran_ser=$tran_ser&tran_expser=$tran_expser';
                                      // print(url);
                                      // try {
                                      //   var response =
                                      //       await http.get(Uri.parse(url));

                                      //   var result = json.decode(response.body);
                                      //   // print(result);

                                      //   if (result.toString() != 'null') {
                                      //     setState(() {
                                      //       // red_Trans_bill();
                                      //       FormMeter_text.clear();
                                      //     });
                                      //     // Navigator.pop(
                                      //     //     context, 'OK');
                                      //   }
                                      //   ScaffoldMessenger.of(context)
                                      //       .showSnackBar(
                                      //     SnackBar(
                                      //         backgroundColor: Colors.green,
                                      //         content:
                                      //             Text('บันทึกสำเร็จ...!')),
                                      //   );
                                      // } catch (e) {
                                      //   ScaffoldMessenger.of(context)
                                      //       .showSnackBar(
                                      //     SnackBar(
                                      //         backgroundColor: Colors.red,
                                      //         content:
                                      //             Text('เกิดข้อผิดพลาด...!')),
                                      //   );
                                      // }
                                      // Insert_log.Insert_logs('จัดการ',
                                      //     'มิเตอร์น้ำไฟฟ้า>>แก้ไขเลขมิเตอร์เดือนนี้(${transMeterModels[index_x].ln},${transMeterModels[index_x].expname})');
                                      // setState(() {
                                      //   tappedIndex_ = index_x.toString();
                                      //   // red_Trans_Mitter().then((value) => {
                                      //   //       _scrollController2.animateTo(
                                      //   //         0,
                                      //   //         duration:
                                      //   //             const Duration(seconds: 1),
                                      //   //         curve: Curves.easeOut,
                                      //   //       )
                                      //   //     });
                                      //   // FormMeter_text.clear();
                                      // });
                                    },
                                    // onFieldSubmitted: (value) {
                                    //   Insert_log.Insert_logs(
                                    //       'จัดการ',
                                    //       'มิเตอร์น้ำไฟฟ้า>>แก้ไขเลขมิเตอร์เดือนนี้(${transMeterModels[index].ln},${transMeterModels[index].expname})');
                                    //   setState(() {
                                    //     red_Trans_bill();
                                    //     // FormMeter_text.clear();
                                    //   });
                                    // },
                                    cursorColor: Colors.green,
                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        // prefixIcon: const Icon(
                                        //     Icons
                                        //         .electrical_services,
                                        //     color: Colors.red),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // labelText: 'เลขมิเตอร์',
                                        labelStyle: const TextStyle(
                                          color:
                                              ManageScreen_Color.Colors_Text2_,
                                          // fontWeight:
                                          //     FontWeight.bold,
                                          fontFamily: Font_.Fonts_T,
                                        )),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp("[' ']")),
                                      // for below version 2 use this
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9 .]')),
                                      // for version 2 and greater youcan also use this
                                      // FilteringTextInputFormatter
                                      //     .digitsOnly
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              flex: ([6, 7].contains(columnHeaders
                                      .indexWhere((item) => item == column)))
                                  ? 1
                                  : 1,
                              child: AutoSizeText(
                                minFontSize: 11,
                                maxFontSize: 15,
                                maxLines: 1,
                                row[column]?.toString() ?? '',
                                textAlign: (columnHeaders.any((columnx) {
                                  return column.toString() == 'หน่วยที่ใช้' ||
                                      column.toString() == 'ราคาต่อหน่วย' ||
                                      column.toString() == 'รวม Vat';
                                }))
                                    ? TextAlign.right
                                    : TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: (columnHeaders.any((columnx) {
                                              double vat = double.tryParse(
                                                      row['รวม Vat']
                                                          .toString()
                                                          .replaceAll(
                                                              ',', '')) ??
                                                  0;
                                              String nvaluex =
                                                  row[columnHeaders[6]]
                                                          ?.toString() ??
                                                      '';
                                              double usage = double.tryParse(
                                                      row['หน่วยที่ใช้']
                                                          .toString()
                                                          .replaceAll(
                                                              ',', '')) ??
                                                  0;
                                              return vat < 1 ||
                                                  // amt < 1 ||
                                                  usage < 1 ||
                                                  nvaluex == '00000';
                                            }) &&
                                            [6, 7, 9].contains(
                                                columnHeaders.indexWhere(
                                                    (item) => item == column)))
                                        ?
                                        // PeopleChaoScreen_Color.Colors_Text2_
                                        Colors.red[600]
                                        : PeopleChaoScreen_Color.Colors_Text2_,
                                    fontWeight: ([6].contains(
                                            columnHeaders.indexWhere(
                                                (item) => item == column)))
                                        ? FontWeight.bold
                                        : null,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ))
              .toList(),
          Container(
            width: 120,
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      // (maintenanceModels[int.parse('${row['index']}')]
                      //             .mst
                      //             .toString() ==
                      //         '3')
                      //     ? MaterialStateProperty.all<Color>(Colors.green)
                      //     :
                      MaterialStateProperty.all<Color>(
                    (transMeterModels[int.parse('${row['index']}')].img != '')
                        ? Colors.grey
                        : Colors.green,
                  ),
                ),
                onPressed: () async {
                  await Dia_log1();
                  int index_x = int.parse('${row['index']}');
                  String Ser_ = transMeterModels[index_x].ser.toString();

                  var formatter = DateFormat('y-MM-d');

                  Future.delayed(const Duration(milliseconds: 300), () async {
                    if (renTal_lavel <= 1) {
                      infomation();
                    } else {
                      var doc = transMeterModels[index_x].docno;
                      var cid = transMeterModels[index_x].refno;
                      var ser = transMeterModels[index_x].ser;
                      // print(
                      //     '$ser /// $doc // $cid   //   ');

                      if (transMeterModels[index_x].img != '') {
                        Dialog_img_Meter(doc, cid, ser, index_x);
                      } else {
                        uploadFile_Slip(doc, cid, ser);
                      }
                    }
                  });
                },
                child: Translate.TranslateAndSet_TextAutoSize(
                    (transMeterModels[int.parse('${row['index']}')].img != '')
                        ? 'ดู/แก้ไข'
                        : 'เพิ่ม',
                    CustomerScreen_Color.Colors_Text3_,
                    TextAlign.center,
                    null,
                    Font_.Fonts_T,
                    10,
                    14,
                    1),
              ),
            ),
          ),
        ]),
      ),
    );
  }
  /////////////---------------------------------------------------->

  Dia_log1() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext builderContext) {
          Timer(Duration(milliseconds: 150), () {
            Navigator.of(context).pop();
          });

          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
  }

  Dia_log2() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          Timer(Duration(seconds: 1), () {
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

  ///////////--------------------------------->
  Dialog_duplicates(type) async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: (type == 1)
          ? "ไม่พบรายการที่พื้นที่ซ้ำกัน (No duplicates found) !!"
          : "ไม่พบรายการที่น่าสงสัย (No suspicious items found) !!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        setState(() {
          // สลับสถานะการแสดงผล
          showDuplicatesOnly = !showDuplicatesOnly;
        });
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

  ///////////--------------------------------->
  Dialog_Error(data) async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "$data",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
        Dia_log2();
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

////////-------------------------------------->
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

  ////------------------------------------------------->
  Future<void> Dialog_img_Meter(docno, Cid, ser, index) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Text(
            '$Cid',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T),
          ),
        ),
        content: SizedBox(
          width: 350,
          // width: MediaQuery.of(context)
          //     .size
          //     .width,
          child: (transMeterModels.isEmpty ||
                  transMeterModels[index].img.toString() == '' ||
                  transMeterModels[index].img == null)
              ? Center(child: Icon(Icons.image_not_supported))
              : Image.network(
                  // '${MyConstant().domain}/files/kad_taii/logo/${Img_logo_}',
                  '${MyConstant().domain}/files/$foder/Meter/${transMeterModels[index].img}',
                  // fit: BoxFit.cover,
                ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
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
                            uploadFile_Slip(docno, Cid, ser);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'แก้ไข',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
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

  /////////--------------------------------->
  Future<void> Dialog_InvoiceAll() async {
    if (renTal_lavel <= 1) {
      infomation();
    } else {
      showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
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
                        'วางบิล น้ำ-ไฟ เดือน ${DateFormat.MMM('th_TH').format(datex)}',
                        ManageScreen_Color.Colors_Text1_,
                        TextAlign.center,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        2),
                  ),
                  Container(
                    // color: Colors.indigo.shade100,
                    decoration: BoxDecoration(
                      color: AppbackgroundColor.TiTile_Colors,
                      // color: AppbackgroundColor.Sub_Abg_Colors,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      // border: Border.all(
                      //     color: Colors.grey, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'โซน',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'รหัสพื้นที่',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            //  Text(
                            //   'รหัสพื้นที่',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'เลขที่สัญญา',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            // Text(
                            //   'เลขที่สัญญา',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ชื่อร้านค้า',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            // Text(
                            //   'ชื่อร้านค้า',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'รายการ',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            // Text(
                            //   'รายการ',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'เลขเครื่อง',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            // Text(
                            //   'เลขเครื่อง',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'เลขครั้งก่อน',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            //  Text(
                            //   'เลขครั้งก่อน',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'เลขปัจจุบัน',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.start,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),

                            // Text(
                            //   'เลขปัจจุบัน',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'หน่วยที่ใช้',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.end,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            //  Text(
                            //   'หน่วยที่ใช้',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Translate.TranslateAndSetText(
                                'ยอดชำระ',
                                ManageScreen_Color.Colors_Text1_,
                                TextAlign.end,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                            //  Text(
                            //   'ยอดชำระ',
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: SettingScreen_Color.Colors_Text1_,
                            //     fontFamily: Font_.Fonts_T,
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.5,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        for (int index = 0;
                            index < transMeterModels.length;
                            index++)
                          if (transMeterModels[index].nvalue != '0')
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${transMeterModels[index].zn}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${transMeterModels[index].ln}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${transMeterModels[index].refno}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${transMeterModels[index].sname}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${transMeterModels[index].expname}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${transMeterModels[index].num_meter}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${(transMeterModels[index].ovalue ?? "").padLeft(5, '0')}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${(transMeterModels[index].nvalue ?? "").padLeft(5, '0')}',
                                      // '${transMeterModels[index].nvalue}',
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${_safeParseFormat(transMeterModels[index].qty, nFormat3, fractionDigits: 0)}',

                                      // '${transMeterModels[index].qty}',
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${_safeParseFormat(transMeterModels[index].c_amt, nFormat)}',
                                      // '${transMeterModels[index].c_amt}',
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color:
                                            SettingScreen_Color.Colors_Text1_,
                                        fontFamily: Font_.Fonts_T,
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
              actions: <Widget>[
                Divider(),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Translate.TranslateAndSetText(
                            'รูปแบบชำระ',
                            ManageScreen_Color.Colors_Text1_,
                            TextAlign.center,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            2),
                        StreamBuilder(
                            stream: Stream.periodic(
                                const Duration(milliseconds: 0)),
                            builder: (
                              context,
                              snapshot,
                            ) {
                              return Container(
                                height: 50,
                                width: 350,
                                // color:
                                //     AppbackgroundColor
                                //         .Sub_Abg_Colors,
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    // border: Border.all(
                                    //     color: Colors.grey, width: 1),
                                  ),
                                  width: 120,
                                  child: DropdownButtonFormField2(
                                    decoration: InputDecoration(
                                      //Add isDense true and zero Padding.
                                      //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      //Add more decoration as you want here
                                      //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
                                    ),
                                    isExpanded: true,
                                    // disabledHint: Icon(Icons.time_to_leave, color: Colors.black),
                                    hint: Row(
                                      children: [
                                        Text(
                                          '$paymentName1',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              // fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ],
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black45,
                                    ),
                                    iconSize: 25,
                                    buttonHeight: 42,
                                    // buttonPadding:
                                    //     const EdgeInsets
                                    //         .only(
                                    //         left:
                                    //             10,
                                    //         right:
                                    //             10),
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    items: _PayMentModels.map((item) =>
                                        DropdownMenuItem<String>(
                                          onTap: () {
                                            setState(() {
                                              selectedValue = item.bno!;
                                            });
                                            // print('**/*/*   --- ${selectedValue}');
                                          },
                                          value: '${item.ser}:${item.ptname}',
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.ptname!}',
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${item.bno!}',
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          Font_.Fonts_T),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                    onChanged: (value) async {
                                      // print(value);
                                      // Do something when changing the item if you want.

                                      var zones = value!.indexOf(':');
                                      var rtnameSer = value.substring(0, zones);
                                      var rtnameName =
                                          value.substring(zones + 1);
                                      // print(
                                      //     'mmmmm ${rtnameSer.toString()} $rtnameName');
                                      setState(() {
                                        paymentSer1 = rtnameSer.toString();

                                        if (rtnameSer.toString() == '0') {
                                          paymentName1 = null;
                                        } else {
                                          paymentName1 = rtnameName.toString();
                                        }
                                        // paymentSer1 =
                                        //     rtnameSer;
                                      });
                                      // print('mmmmm ${rtnameSer.toString()} $rtnameName');
                                      // print(
                                      //     'pppppp $paymentSer1 $paymentName1');
                                      // print('Form_payment1.text');
                                      // print(Form_payment1.text);
                                      // print(Form_payment2.text);
                                      // print('Form_payment1.text');
                                    },
                                    // onSaved: (value) {

                                    // },
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 40,
                          child: StreamBuilder(
                              stream: Stream.periodic(
                                  const Duration(milliseconds: 0)),
                              builder: (
                                context,
                                snapshot,
                              ) {
                                return InkWell(
                                  onTap: () async {
                                    select_Date_Inv(context);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'วันที่ครบกำหนดชำระ : ',
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            //fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            6, 6, 0, 6),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: const BorderRadius
                                                    .only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(0)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          // width: 120,
                                          padding: const EdgeInsets.all(2.0),
                                          child: Center(
                                            child: Text(
                                              (End_Bill_Paydate == null)
                                                  ? ''
                                                  : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${End_Bill_Paydate}'))}',
                                              // '${End_Bill_Paydate}',
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          // width: 120,
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black,
                                          )),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Translate.TranslateAndSetText(
                                '***หมายเหตุ เลขที่สัญญาเดียวกันจะรวมบิลอัตโนมัติ  ',
                                Colors.red,
                                TextAlign.center,
                                FontWeight.bold,
                                FontWeight_.Fonts_T,
                                14,
                                2),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: Container(
                                  width: 200,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    // border: Border.all(color: Colors.white, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'บันทึกวางบิล',
                                        Colors.white,
                                        TextAlign.center,
                                        FontWeight.bold,
                                        FontWeight_.Fonts_T,
                                        14,
                                        2),
                                  )),
                              onTap: () {
                                in_Trans_invoice().then(
                                    (value) => Navigator.of(context).pop());
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
    }
  }

  ///////-------------------------------->
  Future<Null> in_Trans_invoice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var zone_Sub = preferences.getString('zoneSubSer') == null
        ? '0'
        : preferences.getString('zoneSubSer');
    var zone_ser = preferences.getString('zonePSer') == null
        ? '0'
        : preferences.getString('zonePSer');
    // print(
    //     'zzzzasaaa123454>>>>  &sertype=$Ser_BodySta1&serzone=$zone_ser&serzonesub=$zone_Sub');
    // String? cFinn;

    String url =
        '${MyConstant().domain}/In_tran_invoice_all.php?isAdd=true&ren=$ren&user=$user&sertype=$Ser_BodySta1&serzone=$zone_ser&serzonesub=$zone_Sub&pSer=$paymentSer1&Paydate=$End_Bill_Paydate';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        // for (var map in result) {
        //   // TransBillModel transBillModel = TransBillModel.fromJson(map);
        //   // setState(() {
        //   //   cFinn = transBillModel.docno;
        //   // });
        //   // print('zzzzasaaa123454>>>>  $cFinn');
        //   // print('docnodocnodocnodocnodocno123456>>>>  ${transBillModel.docno}');
        // }

        Insert_log.Insert_logs(
            'ผู้เช่า', 'วางบิลทั้งหมด>>บันทึก(${user.toString()})');
        setState(() {
          red_Trans_bill();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('บันทึกรายการวางบิลสำเร็จ',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_bill() async {
    setState(() {
      _transMeterModels.clear();
      transMeterModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var zone_Sub = preferences.getString('zoneSubSer');
    // print('Ser_BodySta1 >>>>  $Ser_BodySta1');
    String url = (zone_ser.toString() == 'null')
        ? '${MyConstant().domain}/GC_trans_mitterManage.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0&serzonesub=$zone_Sub'
        : '${MyConstant().domain}/GC_trans_mitterManage.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=$zone_ser&serzonesub=$zone_Sub';
    print('GC_trans_mitterManage $url');
    // String url = zone_Sub == null || zone_Sub == '0'
    //     ? (zone_ser.toString() == 'null')
    //         ? '${MyConstant().domain}/GC_trans_mitterManage.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0'
    //         : '${MyConstant().domain}/GC_trans_mitter.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=$zone_ser'
    //     : (zone_ser.toString() == 'null')
    //         ? '${MyConstant().domain}/GC_trans_mitter_sub.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=0&serzonesub=$zone_Sub'
    //         : '${MyConstant().domain}/GC_trans_mitter_sub.php?isAdd=true&ren=$ren&sertype=$Ser_BodySta1&serzone=$zone_ser&serzonesub=$zone_Sub';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransMeterModel transMeterModel = TransMeterModel.fromJson(map);
          setState(() {
            _transMeterModels.add(transMeterModel);

            // _TransBillModels.add(_TransBillModel);
          });
        }
      }
      setState(() {
        transMeterModels = _transMeterModels;
      });
    } catch (e) {}
  }

  Future<Null> select_Date_Inv(BuildContext context) async {
    final Future<DateTime?> picked = showDatePicker(
      // locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่ครบกำหนด', confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      context: context,
      initialDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month + 6, DateTime.now().day),
      // selectableDayPredicate: _decideWhichDayToEnable,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppBarColors.ABar_Colors, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    picked.then((result) {
      // ignore: unnecessary_null_comparison
      if (picked != null) {
        var formatter = DateFormat('yyyy-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          End_Bill_Paydate = "${formatter.format(result)}";
        });
      }
    });
  }
}
