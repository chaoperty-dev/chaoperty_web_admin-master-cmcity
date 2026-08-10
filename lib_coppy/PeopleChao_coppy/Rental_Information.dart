// // ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, duplicate_import, must_be_immutable, body_might_complete_normally_nullable
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:chaoperty/PeopleChao/Seteing_listmenu.dart';
// import 'package:crypto/crypto.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';

// import 'package:file_picker/file_picker.dart';
// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/container.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter_limited_checkbox/flutter_limited_checkbox.dart';
// import 'package:group_radio_button/group_radio_button.dart';
// // import 'package:hand_signature/signature.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';

// import 'package:radio_grouped_buttons/custom_buttons/custom_radio_buttons_group.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:syncfusion_flutter_barcodes/barcodes.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// // import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

// import '../ChaoArea/ChaoRe_contact_add.dart';
// import '../ChiangMai_Municipality/unity/show_dialog_cmm.dart';
// import '../Constant/Myconstant.dart';
// import '../INSERT_Log/Insert_log.dart';
// import '../Man_PDF/Man_Agreement_PDF.dart';
// import '../Man_PDF/Preview_PDF/Preview_IDcard.dart';
// import '../Man_PDF/Preview_PDF/Preview_IDcard.dart';
// import '../Man_PDF/Preview_PDF/Preview_Rental.dart';
// import '../Model/GetC_Quot_Select_Model.dart';
// import '../Model/GetC_Syslog.dart';
// import '../Model/GetContract_Photo_Model.dart';
// import '../Model/GetContractf_Model.dart';
// import '../Model/GetCustomer_Model.dart';
// import '../Model/GetExp_Model.dart';
// import '../Model/GetRenTal_Model.dart';
// import '../Model/GetTeNant_Model.dart';
// import '../Model/GetTrans_Model.dart';
// import '../Model/PakanDocnoModel.dart';
// import '../Model/TypePaper_Model.dart';
// import '../Model/electricity_model.dart';
// import '../PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice.dart';
// import '../PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice2.dart';
// import '../PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice3.dart';
// import '../PDF/Choice/pdf_Agreement_Choice.dart';
// import '../PDF/Choice/pdf_Agreement_Choice2.dart';
// import '../PDF/Choice/pdf_Agreement_Choice3.dart';
// import '../PDF/PDF_Agreement/Ama1000/pdf_Agreement_ama1000.dart';
// import '../PDF/PDF_Agreement/Ortor/BangKla/pdf_Agreement_Ortor.dart';
// import '../PDF/PDF_Agreement/pdf_Agreement.dart';
// import '../PDF/PDF_Agreement/pdf_Agreement2.dart';
// import '../PDF/PDF_Agreement/pdf_Agreement3.dart';
// import '../PDF/PDF_Agreement/pdf_Agreement_JSpace.dart';
// import '../PDF/PDF_Agreement/pdf_Agreement_JSpace2.dart';
// import '../PDF/PDF_Agreement/pdf_Informa_Choice.dart';
// import '../PDF/PDF_Agreement/pdf_RentalInforma.dart';
// import '../PDF/nim/nim_RentalInforma.dart';
// import '../Responsive/responsive.dart';
// import '../Style/Translate.dart';
// import '../Style/colors.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:path/path.dart';
// import 'package:path/path.dart' as path;
// import 'package:pdf/widgets.dart' as pw;
// import 'dart:ui' as ui;
// import 'dart:convert';
// import 'dart:js' as js;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// import 'EditContractFrom.dart';
// import 'PeopleChao_Screen2.dart';
// import 'QR_PDF2.dart';
// import 'package:convert/convert.dart';

// ///////------------------------>
// class RentalInformation extends StatefulWidget {
//   final Get_Value_NameShop_index;
//   final Get_Value_cid;
//   final Get_Value_statu;

//   const RentalInformation({
//     super.key,
//     this.Get_Value_NameShop_index,
//     this.Get_Value_cid,
//     this.Get_Value_statu,
//   });

//   @override
//   State<RentalInformation> createState() => _RentalInformationState();
// }

// class _RentalInformationState extends State<RentalInformation> {
//   var nFormat = NumberFormat("#,##0.00", "en_US");
//   DateTime datex = DateTime.now();
//   List<TeNantModel> teNantModels = [];
//   List<RenTalModel> renTalModels = [];
//   List<ContractfModel> contractfModels = [];
//   List<CustomerModel> customerModels = [];
//   List<CustomerModel> customer_Models = [];
//   List<ElectricityModel> electricityModels = [];
//   List<CustomerModel> _customerModels = <CustomerModel>[];
//   List<PakanDocnoModel> pakanDocnoModels = [];
//   List<SyslogModel> syslogModel = [];
//   List<SyslogModel> _syslogModel = <SyslogModel>[];
//   final _formKey = GlobalKey<FormState>();
//   final Form_nameshop = TextEditingController();
//   final Form_typeshop = TextEditingController();
//   final Form_bussshop = TextEditingController();
//   final Form_bussscontact = TextEditingController();
//   final Form_address = TextEditingController();
//   final Form_tel = TextEditingController();
//   final Form_email = TextEditingController();
//   final Form_tax = TextEditingController();
//   final Form_wnote = TextEditingController();
//   final rental_count_text = TextEditingController();
//   final Form_area = TextEditingController();
//   final Form_ln = TextEditingController();
//   final Form_lncode = TextEditingController();
//   final Form_sdate = TextEditingController();
//   final Form_ldate = TextEditingController();
//   final Form_period = TextEditingController();
//   final Form_rtname = TextEditingController();
//   final Form_docno = TextEditingController();
//   final Form_zn = TextEditingController();
//   final Form_aser = TextEditingController();
//   final Form_qty = TextEditingController();
//   final Form_cdate = TextEditingController();

//   final Form_User = TextEditingController();
//   final Form_UserPass = TextEditingController();
// /////////----------------------------------------->
//   final Form_fid = TextEditingController();
//   final Form_renew_cid = TextEditingController();
//   final Form_PakanSdate = TextEditingController();
//   final Form_PakanLdate = TextEditingController();
//   final Form_PakanSdate_Doc = TextEditingController();

//   final Form_Remark = TextEditingController();
//   final Form_PakanLdate_Doc = TextEditingController();
//   final Form_PakanAll_amt = TextEditingController();
//   final Form_PakanAll_pvat = TextEditingController();
//   final Form_PakanAll_vat = TextEditingController();
//   final Form_PakanAll_Total = TextEditingController();
//   final Form_PakanAll_Total_bill = TextEditingController();

//   final Form_PakanAll_amt_first = TextEditingController();
//   final Form_PakanAll_pvat_first = TextEditingController();
//   final Form_PakanAll_vat_first = TextEditingController();
//   final Form_PakanAll_Total_first = TextEditingController();

//   final Form_pvat_pakan_cid = TextEditingController();
//   final Form_vat_pakan_cid = TextEditingController();
//   final Form_total_pakan_cid = TextEditingController();
//   final Form_addmin = TextEditingController();
//   final Form_renew_datex = TextEditingController();
//   final Form_renew_sdate = TextEditingController();
//   final Form_renew_ldate = TextEditingController();
//   final Form_fid_sdate = TextEditingController();
//   final Form_fid_ldate = TextEditingController();
//   final Title_text = TextEditingController();
//   final Details_text = TextEditingController();
//   bool Form_readOnly = true;
//   String tappedIndex_1 = ''; // รายละเอียดค่าบริการ
//   String tappedIndex_2 = ''; // รายละเอียดค่าบริการ
//   List<QuotxSelectModel> quotxSelectModels = [];
//   List<QuotxSelectModel> quotxSelectModels2 = [];
//   List<TransModel> _TransModels = [];

//   List<ContractPhotoModel> contractPhotoModels = [];

//   String? _verticalGroupValue,
//       foder,
//       foderx,
//       renTal_bill,
//       renTal_name,
//       renTal_user,
//       fname_,
//       Cust_no_,
//       paper,
//       paper_run;
//   String? File_Names = '', Dropdown_expname = 'ทั้งหมด';
//   String? cxname_card,
//       cxname_lease,
//       cxname_other,
//       cxname_card_ser,
//       cxname_lease_ser,
//       cxname_other_ser,
//       _PakanSdate_Doc;
//   int renTal_lavel = 0, ser_tabbarview_2 = 0, ExpTap = 1, TitelTap = 1;
//   List<ContractfModel> Other_file = [];
//   List<TypePaperModel> typePaperModels = [];
//   List<ExpModel> expModels = [];
//   String? pic_tenant, pic_shop, pic_plan, fiew;
//   String _ReportValue_type = "ไม่ระบุ";
//   String? cid_typePaper, cid_typePaper_ser;

//   List<Map<String, String>> data_picperson = [
//     {"ser": "1", "title": "รูปผู้เช่า", "detail": "pic_tenant", "url": ""},
//     {"ser": "2", "title": "รูปร้านค้า", "detail": "pic_shop", "url": ""},
//     {"ser": "3", "title": "รูปแผนผัง", "detail": "pic_plan", "url": ""},
//   ];
//   // ====== ปรับตามโปรเจ็กต์คุณได้ ======
//   double _labelWidth = 120.0; // ความกว้างคอลัมน์ label
//   double _gap = 8.0; // ระยะห่างแนวนอน
//   double _fieldHeight = 45.0; // ความสูงช่องกรอกมาตรฐาน

//   final _pillBorder = OutlineInputBorder(
//     borderRadius: BorderRadius.circular(6),
//     borderSide: const BorderSide(width: 1, color: Colors.grey),
//   );
//   final _pillBorderFocused = OutlineInputBorder(
//     borderRadius: BorderRadius.circular(6),
//     borderSide: const BorderSide(width: 1, color: Colors.black),
//   );

// //////-------------------------->
//   @override
//   void initState() {
//     super.initState();
//     read_GC_rental().then((_) {
//       read_GC_photo();
//     });

//     checkPreferance();
//     read_customer();

//     // read_PakanDocno();
//   }

//   Color cardColor = Colors.green[300]!;
//   int indexcardColor = 0;
//   List<dynamic> colorList = [
//     Colors.green[300],
//     Colors.red[300],
//     Colors.blue[300],
//     Colors.yellow[300],
//     Colors.orange[300],
//     Colors.purple[300],
//     Colors.teal[300],
//     Colors.pink[300],
//     Colors.indigo[300],
//     Colors.cyan[300],
//     Colors.brown[300],
//     Colors.black,
//     Colors.grey[300],
//   ];
//   void changeCardColor(namecolor) {
//     setState(() {
//       // Change the color to a different one
//       cardColor = namecolor; // You can replace this with any color you want
//     });
//   }

//   Future<Null> checkPreferance() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     setState(() {
//       renTal_user = preferences.getString('renTalSer');
//       renTal_name = preferences.getString('renTalName');
//       fname_ = preferences.getString('fname');

//       renTal_lavel = int.parse(preferences.getString('lavel').toString());

//       read_data();
//       red_report();
//       red_report2();

//       GC_contractf();
//       red_reporttrans(expser: '').then((value) => read_GC_Exp());
//     });
//   }

//   ////////--------------------------------------------------------------->

//   Future<void> read_GC_photo() async {
//     if (renTalModels.length > 0) {
//       setState(() {
//         foder = renTalModels[0].dbn.toString();
//         foderx = renTalModels[0].dbn.toString();
//         renTal_bill = renTalModels[0].bill_name!;
//       });
//     }

//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     final ren = preferences.getString('renTalSer');
//     final user = preferences.getString('ser');
//     final ciddoc = widget.Get_Value_cid;
//     final qutser = widget.Get_Value_NameShop_index;

//     if (ren == null || user == null || foderx == null) {
//       //print('⚠️ ข้อมูลที่จำเป็นไม่ครบ: ren: $ren/user: $user /foderx:');
//       return;
//     }

//     final url =
//         '${MyConstant().domain}/GC_photo_cont.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser';

//     try {
//       final response = await http.get(Uri.parse(url));
//       final result = json.decode(response.body);

//       if (result != null && result is List) {
//         final tempPhotoModels = <ContractPhotoModel>[];

//         for (var map in result) {
//           final model = ContractPhotoModel.fromJson(map);

//           final tenantPic = model.pic_tenant?.trim() ?? '';
//           final shopPic = model.pic_shop?.trim() ?? '';
//           final planPic = model.pic_plan?.trim() ?? '';

//           setState(() {
//             pic_tenant = tenantPic;
//             pic_shop = shopPic;
//             pic_plan = planPic;

//             contractPhotoModels.clear();
//             contractPhotoModels.add(model);
//           });

//           tempPhotoModels.add(model);
//         }
//       } else {
//         //print('⚠️ ไม่พบข้อมูลรูปภาพสัญญา หรือข้อมูลไม่ถูกต้อง');
//       }

//       setState(() {
//         data_picperson = [
//           {
//             "ser": "1",
//             "title": "รูปผู้เช่า",
//             "detail": "pic_tenant",
//             "url": '${MyConstant().domain}/files/$foderx/contract/$pic_tenant',
//             "img": "$pic_tenant",
//           },
//           {
//             "ser": "2",
//             "title": "รูปร้านค้า",
//             "detail": "pic_shop",
//             "url": '${MyConstant().domain}/files/$foderx/contract/$pic_shop',
//             "img": "$pic_shop",
//           },
//           {
//             "ser": "3",
//             "title": "รูปแผนผัง",
//             "detail": "pic_plan",
//             "url": '${MyConstant().domain}/files/$foderx/contract/$pic_plan',
//             "img": "$pic_plan",
//           },
//         ];
//       });
//     } catch (e, stackTrace) {
//       //print('❌ เกิดข้อผิดพลาดใน read_GC_photo: $e');
//       //print('🪵 StackTrace: $stackTrace');
//     }
//   }

// ////---------------->
//   Future<void> red_Syslog() async {
//     final prefs = await SharedPreferences.getInstance();
//     final ren = prefs.getString('renTalSer');
//     final user = prefs.getString('ser');
//     final ciddoc = widget.Get_Value_cid;
//     final qutser = widget.Get_Value_NameShop_index;

//     final url = Uri.parse(
//       '${MyConstant().domain}/GC_SyslogCid.php?isAdd=true&ren=$ren&value=$ciddoc',
//     );

//     try {
//       final response = await http.get(url);
//       if (response.statusCode != 200) return;

//       final result = json.decode(response.body);

//       if (result is List) {
//         final List<SyslogModel> loaded = [];
//         for (final item in result) {
//           if (item is Map<String, dynamic>) {
//             loaded.add(SyslogModel.fromJson(item));
//           }
//         }

//         if (!mounted) return;
//         setState(() {
//           syslogModel
//             ..clear()
//             ..addAll(loaded);
//           _syslogModel = syslogModel;
//         });
//       }
//     } catch (e) {
//       // TODO: log error หรือ show dialog/snackbar ตามต้องการ
//     }
//   }

// ////---------------->
//   String? base64_Slip, fileName_Slip;
//   var extension_;
//   var file_;
//   File? _file;
//   Future<void> uploadImage(ImageSource source) async {
//     int timestamp = DateTime.now().millisecondsSinceEpoch;

//     setState(() {
//       fileName_Slip = '${fiew}_${widget.Get_Value_cid}_$timestamp.jpg';
//     });

//     final imagePicker = ImagePicker();
//     final pickedFile = await imagePicker.pickImage(
//       source: source,
//       maxWidth: 1200, // จำกัดขนาด
//       maxHeight: 1200,
//       imageQuality: 75, // บีบอัดคุณภาพเล็กน้อย
//     );

//     if (pickedFile == null) {
//       //print('❌ User canceled image selection');
//       return;
//     }

//     try {
//       //print('📷 Picked image path: ${pickedFile.path}');

//       final imageBytes = await pickedFile.readAsBytes();
//       //print('📏 Image size in bytes: ${imageBytes.length}');

//       final base64Image = base64Encode(imageBytes);
//       final url =
//           '${MyConstant().domain}/File_photo.php?name=$fileName_Slip&Foder=$foder';

//       //print('📡 Uploading to: File_photo');

//       final response = await http.post(
//         Uri.parse(url),
//         body: {
//           'image': base64Image,
//           'Foder': foder,
//           'name': fileName_Slip,
//         },
//       );

//       //print('📥 Upload response: ${response.statusCode}');
//       //print('📨 Server says: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonRes = jsonDecode(response.body);
//         if (jsonRes['message'] == 'Image uploaded successfully') {
//           //print('✅ Image uploaded successfully');
//           await up_photo_string();
//         } else {
//           //print(
//           //   '⚠️ Server responded but message was unexpected: ${jsonRes['message']}');
//         }
//       } else {
//         //print('❌ Image upload failed with status code: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       //print('❌ Error during image processing: $e');
//       //print('🪵 StackTrace:\n$stackTrace');
//     }
//   }

//   Future<void> up_photo_string() async {
//     try {
//       final preferences = await SharedPreferences.getInstance();
//       final ren = preferences.getString('renTalSer');
//       final user = preferences.getString('ser');
//       final ciddoc = widget.Get_Value_cid;
//       final qutser = widget.Get_Value_NameShop_index;
//       final fiewx = fiew;
//       final fileNameSafe = fileName_Slip?.trim() ?? '';

//       // ✅ ตรวจสอบข้อมูลให้ครบก่อน
//       if ([ren, user, ciddoc, qutser, fiewx, fileNameSafe]
//           .any((e) => e == null || e.isEmpty)) {
//         //print('❌ ข้อมูลไม่ครบ ไม่สามารถส่งคำขอได้');
//         //print(
//         // '🔸 ren: $ren, user: $user, ciddoc: $ciddoc, qutser: $qutser, fiewx: $fiewx, fileName: $fileNameSafe');
//         return;
//       }
//       // String type_cid =
//       //     (widget.Get_Value_NameShop_index.toString() == '1') ? 'cid' : 'quotation';

//       final url = '${MyConstant().domain}/GC_tran_Kon_photo.php?isAdd=true'
//           '&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser'
//           '&fiewx=$fiewx&fileName_Slip=$fileNameSafe';

//       //print('📡 เรียก URL: $url');

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         //print('📥 Response: $result');

//         if (result.toString() == 'true') {
//           //print('✅ อัปเดตรูปภาพในระบบสำเร็จ');

//           // ✅ ล้างตัวแปร
//           setState(() {
//             fileName_Slip = null;
//             base64_Slip = null;
//             extension_ = null;
//             file_ = null;
//             _file = null;
//             fiew = null;
//           });

//           // ✅ โหลดรูปใหม่
//           await read_GC_photo();
//         } else {
//           //print('⚠️ ไม่สามารถอัปเดตได้: *โหลดรูปใหม่');
//         }
//       } else {
//         //print('❌ HTTP ERROR: ${response.statusCode}');
//       }
//     } catch (e, stackTrace) {
//       //print('❌ Exception ใน up_photo_string: $e');
//       //print('🪵 StackTrace:\n$stackTrace');
//     }
//   }

//   Future<Null> read_GC_rental() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var seruser = preferences.getString('ser');
//     var utype = preferences.getString('utype');

//     var ren = preferences.getString('renTalSer');
//     String url =
//         '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
//     //print('read_GC_rental///// $url');
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print('read_GC_rental///// $result');
//       for (var map in result) {
//         RenTalModel renTalModel = RenTalModel.fromJson(map);
//         var foderx = renTalModel.dbn;
//         // //print('read_GC_rental///// $foderx');
//         setState(() {
//           foder = renTalModel.dbn.toString();
//           foderx = renTalModel.dbn.toString();
//           renTal_bill = renTalModel.bill_name!;
//           renTalModels.add(renTalModel);
//         });
//       }
//     } catch (e) {}
//   }

//   Future<Null> read_GC_TypePaper() async {
//     if (typePaperModels.length != 0) {
//       setState(() {
//         typePaperModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');
//     String url = '${MyConstant().domain}/GC_Type_paper.php?isAdd=true&ren=$ren';

//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print('read_GC_rental///// $result');
//       for (var map in result) {
//         TypePaperModel typePaperModelss = TypePaperModel.fromJson(map);

//         setState(() {
//           typePaperModels.add(typePaperModelss);
//         });
//       }
//       setState(() {
//         cid_typePaper =
//             '${typePaperModels.where((model) => model.ser.toString() == '${(cid_typePaper_ser.toString() == '0') ? 1 : cid_typePaper_ser}').map((model) => model.p_type).join(',')}';
//       });
//     } catch (e) {}
//   }

//   ///------------------------------------------------------>
//   Future<Null> red_report() async {
//     setState(() {
//       quotxSelectModels.clear();
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var ciddoc = widget.Get_Value_cid;
//     var qutser = widget.Get_Value_NameShop_index;

//     String url =
//         '${MyConstant().domain}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
//     // //print('GC_quot_conx>>>> $url');
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result.toString() != 'null') {
//         if (quotxSelectModels.isNotEmpty) {
//           setState(() {
//             quotxSelectModels.clear();
//           });
//         }
//         for (var map in result) {
//           QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
//           setState(() {
//             quotxSelectModels.add(quotxSelectModel);
//           });
//         }
//       } else {
//         setState(() {
//           quotxSelectModels.clear();
//         });
//       }
//     } catch (e) {}
//   }

//   ///------------------------------------------------------>
//   Future<Null> red_report2() async {
//     setState(() {
//       quotxSelectModels2.clear();
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var ciddoc = widget.Get_Value_cid;
//     var qutser = widget.Get_Value_NameShop_index;

//     String url =
//         '${MyConstant().domain}/GC_quotconx_mont.php?isAdd=true&ren=$ren&ciddoc=$ciddoc';
//     //print('GC_quot_conx>>>>vvv $url');
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       for (var map in result) {
//         QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
//         setState(() {
//           quotxSelectModels2.add(quotxSelectModel);
//         });
//       }
//     } catch (e) {}
//   }

//   Future<Null> red_reporttrans({required String? expser}) async {
//     if (_TransModels.length != 0) {
//       setState(() {
//         _TransModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     var ciddoc = widget.Get_Value_cid;
//     var qutser = widget.Get_Value_NameShop_index;

//     String url =
//         '${MyConstant().domain}/GC_trans_x.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&expser=$expser';
//     // //print(url);
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result.toString() != 'null') {
//         for (var map in result) {
//           TransModel _TransModel = TransModel.fromJson(map);
//           setState(() {
//             _TransModels.add(_TransModel);
//           });
//         }
//       } else {
//         setState(() {
//           _TransModels.clear();
//         });
//       }
//     } catch (e) {}
//   }

//   Future<Null> read_GC_Exp() async {
//     if (expModels.isNotEmpty) {
//       expModels.clear();
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');

//     String url = '${MyConstant().domain}/GC_exp_Report.php?isAdd=true&ren=$ren';
//     // //print(url);

//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);

//       Map<String, dynamic> map = Map();
//       map['ser'] = '0';
//       map['rser'] = '0';
//       map['expser'] = '0';
//       map['expname'] = 'ทั้งหมด';
//       map['data_update'] = '0';

//       ExpModel expModelx = ExpModel.fromJson(map);

//       setState(() {
//         expModels.add(expModelx);
//       });

//       // //print(result);
//       if (result != null) {
//         for (var map in result) {
//           ExpModel expModel = ExpModel.fromJson(map);
//           // if (expModel.exptser! != '2') {
//           int total_exp = _TransModels.where(
//               (e) => e.expser.toString() == expModel.ser.toString()).length;
//           if (total_exp != 0) {
//             setState(() {
//               expModels.add(expModel);
//             });
//           }
//         }
//         expModels.sort((a, b) {
//           if (a.exptser == 'ทั้งหมด') {
//             return -1; // 'all' should come before other elements
//           } else if (b.exptser == 'ทั้งหมด') {
//             return 1; // 'all' should come after other elements
//           } else {
//             return a.exptser!.compareTo(
//                 b.exptser!); // sort other elements in ascending order
//           }
//         });
//       } else {}
//     } catch (e) {}
//   }

//   Future<Null> read_data() async {
//     if (teNantModels.length != 0) {
//       setState(() {
//         teNantModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');
//     var ciddoc = widget.Get_Value_cid;
//     var qutser = widget.Get_Value_NameShop_index;
//     //print('Get_Value_NameShop_index >>>>>> $qutser');

//     String url =
//         '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result != null) {
//         for (var map in result) {
//           TeNantModel teNantModel = TeNantModel.fromJson(map);
//           setState(() {
//             teNantModels.add(teNantModel);
//             Cust_no_ = teNantModel.custno_1.toString();
//             _verticalGroupValue = teNantModel.ctype;
//             Form_nameshop.text = teNantModel.sname.toString();
//             Form_typeshop.text = teNantModel.stype.toString();
//             Form_bussshop.text = teNantModel.cname.toString();
//             Form_bussscontact.text = teNantModel.attn.toString();
//             Form_address.text = teNantModel.addr.toString();
//             Form_tel.text = teNantModel.tel.toString();
//             Form_email.text = teNantModel.email.toString();
//             Form_Remark.text = teNantModel.remark.toString();
//             Form_tax.text =
//                 teNantModel.tax == null ? "-" : teNantModel.tax.toString();
//             Form_area.text = teNantModel.area.toString();
//             Form_ln.text = teNantModel.area_c.toString();
//             Form_lncode.text = teNantModel.ln.toString();
//             Form_wnote.text = teNantModel.wnote.toString();
//             Form_sdate.text = DateFormat('dd-MM-yyyy')
//                 .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
//                 .toString();
//             Form_ldate.text = DateFormat('dd-MM-yyyy')
//                 .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
//                 .toString();
//             Form_period.text = teNantModel.period.toString();
//             Form_rtname.text = teNantModel.rtname.toString();
//             Form_docno.text = teNantModel.docno.toString();
//             Form_zn.text = teNantModel.zn.toString();
//             Form_aser.text = teNantModel.aser.toString();
//             Form_qty.text = teNantModel.qty.toString();
//             Form_cdate.text = DateFormat('dd-MM-yyyy')
//                 .format(DateTime.parse('${teNantModel.cdate} 00:00:00'))
//                 .toString();
//             Form_fid.text = teNantModel.fid.toString();
//             Form_renew_cid.text = teNantModel.renew_cid.toString();
//             cid_typePaper_ser = teNantModel.ser_paper.toString();
//             Form_addmin.text = teNantModel.name_user.toString();
//             paper = teNantModel.paper.toString();
//             paper_run = teNantModel.paper_run.toString();
//             Form_renew_datex.text = teNantModel.renew_datex.toString();
//             Form_renew_sdate.text = teNantModel.renew_sdate.toString();
//             Form_renew_ldate.text = teNantModel.renew_ldate.toString();
//             Form_fid_sdate.text = teNantModel.renew_ldate.toString();
//             Form_fid_ldate.text = teNantModel.renew_ldate.toString();
//           });
//         }
//         read_GC_TypePaper();
//         red_coutumer();
//         read_PakanDocno();
//       }
//     } catch (e) {}
//   }

//   Future<Null> red_coutumer() async {
//     if (customerModels.isNotEmpty) {
//       setState(() {
//         customerModels.clear();
//       });
//     }

//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? ren = preferences.getString('renTalSer');
//     String url =
//         '${MyConstant().domain}/GC_custo_informa.php?isAdd=true&ren=$ren&cusno=$Cust_no_';

//     try {
//       var response = await http.get(Uri.parse(url));
//       var result = json.decode(response.body);
//       ////print(result);
//       List<int> encodedBytes = [];
//       Uint8List decodedBytes;
//       if (result.toString() != 'null') {
//         for (var map in result) {
//           CustomerModel customerModel = CustomerModel.fromJson(map);
//           setState(() {
//             customerModels.add(customerModel);

//             Form_User.text = customerModel.user_name.toString();
//             // encodedBytes = hex.decode(customerModel.passw!);
//             // decodedBytes = Uint8List.fromList(encodedBytes);
//             // const utf8Decoder = Utf8Decoder(allowMalformed: true);
//             // Form_UserPass.text = utf8Decoder.convert(encodedBytes);
//           });
//         }
//       }
//     } catch (e) {}
//   }

//   ///--------------------------------------------->
//   ScrollController _scrollController1 = ScrollController();
//   ScrollController _scrollController2 = ScrollController();

//   _moveUp1() {
//     _scrollController1.animateTo(_scrollController1.offset - 250,
//         curve: Curves.linear, duration: const Duration(milliseconds: 500));
//   }

//   _moveDown1() {
//     _scrollController1.animateTo(_scrollController1.offset + 250,
//         curve: Curves.linear, duration: const Duration(milliseconds: 500));
//   }

//   _moveUp2() {
//     _scrollController2.animateTo(_scrollController2.offset - 250,
//         curve: Curves.linear, duration: const Duration(milliseconds: 500));
//   }

//   _moveDown2() {
//     _scrollController2.animateTo(_scrollController2.offset + 250,
//         curve: Curves.linear, duration: const Duration(milliseconds: 500));
//   }

// ///////------------------------------------------------------------->
//   // String image_base64_IDcard = '';
//   // Future<void> chooseImage_IDcard() async {
//   //   final ImagePicker _picker = ImagePicker();
//   //   // var choosedimage = await ImagePicker.pickImage(source: ImageSource.gallery);
//   //   final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
//   //   //set source: ImageSource.camera to get image from camera
//   //   if (photo == null) return;
//   //   // read picked image byte data.
//   //   Uint8List imagebytes = await photo.readAsBytes();
//   //   // using base64 encoder convert image into base64 string.
//   //   String _base64String1 = base64.encode(imagebytes);

//   //   setState(() {
//   //     image_base64_IDcard = _base64String1;
//   //   });
//   //   //print(image_base64_IDcard);
//   // }

//   // Future<void> _uploadFile_IDcard() async {
//   //   String imageStep4_base64_new = '0';
//   //   Random randomx = Random();
//   //   int ix = randomx.nextInt(1000000);
//   //   String uploadurl = "${MyConstant().domain}/xxxxxxx.php";
//   //   String fileName4 = 'img_4_$ix.jpg';
//   //   try {
//   //     setState(() {
//   //       imageStep4_base64_new = fileName4;
//   //     });
//   //     var response = await http.post(Uri.parse(uploadurl), body: {
//   //       'image': image_base64_IDcard,
//   //       'name': fileName4,
//   //     });

//   //     if (response.statusCode == 200) {
//   //       var jsondata = json.decode(response.body);
//   //       if (jsondata["error"]) {
//   //         //  //print(jsondata["msg"]);
//   //       } else {
//   //         //  //print("Upload successful");
//   //       }
//   //     } else {
//   //       // //print("Error during connection to server");
//   //     }
//   //   } catch (e) {}
//   // }

//   ///------------------------------------------------------------>( รูปBase64 )
//   Widget getImagenBase64(String photo) {
//     String _imageBase64 = photo;

//     const Base64Codec base64 = Base64Codec();
//     var bytes = base64.decode(_imageBase64);
//     if (_imageBase64 == null) {
//       return const Text('Nodata');
//     } else {
//       return Image.memory(
//         bytes,
//         // width: MediaQuery.of(context).size.width * 0.2,
//         // height: MediaQuery.of(context).size.width * 0.2,
//         fit: BoxFit.fill,
//       );
//     }
//   }

//   ///---------------------------------------------------------->
//   // Future<html.File> pickFile() async {
//   //   final completer = Completer<html.File>();
//   //   final input = html.FileUploadInputElement()..accept = '.pdf';
//   //   input.click();

//   //   await input.onChange.first;
//   //   if (input.files!.isNotEmpty) {
//   //     completer.complete(input.files!.first);
//   //   } else {
//   //     completer.complete(null);
//   //   }

//   //   return completer.future;
//   // }
//   // Future<html.File> pickFile_IDcard() async {
//   //   final completer = Completer<html.File>();
//   //   final input = html.FileUploadInputElement()..accept = '.pdf';
//   //   input.click();

//   //   await input.onChange.first;
//   //   if (input.files!.isNotEmpty) {
//   //     completer.complete(input.files!.first);
//   //   } else {
//   //     completer.complete(null);
//   //   }

//   //   return completer.future;
//   // }
//   // Future<FilePickerResult?> pickFile_IDcard() async {
//   //   FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //     type: FileType.custom,
//   //     allowedExtensions: ['pdf'],
//   //   );
//   //   return result;
//   // }

//   // Future<FilePickerResult?> pickFile_agreement() async {
//   //   FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //     type: FileType.custom,
//   //     allowedExtensions: ['pdf'],
//   //   );
//   //   return result;
//   // }

//   // Future<FilePickerResult?> pickFile_documentmore() async {
//   //   FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //     type: FileType.custom,
//   //     allowedExtensions: ['pdf'],
//   //   );
//   //   return result;
//   // }

//   Future<Null> GC_contractf() async {
//     if (contractfModels.length != 0) {
//       contractfModels.clear();
//     }
//     setState(() {
//       Other_file = [];
//       cxname_card = null;
//       cxname_lease = null;
//       cxname_other = null;
//       cxname_card_ser = null;
//       cxname_lease_ser = null;
//       cxname_other_ser = null;
//     });
//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     var ren = preferences.getString('renTalSer');
//     var ser_user = preferences.getString('ser');
//     String Namecid = '${widget.Get_Value_cid}';
//     String url =
//         '${MyConstant().domain}/GC_contractf.php?isAdd=true&ren=$ren&ser_user=$ser_user&namecid=$Namecid';

//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result != null) {
//         for (var map in result) {
//           ContractfModel contractfModelss = ContractfModel.fromJson(map);
//           setState(() {
//             contractfModels.add(contractfModelss);
//           });

//           if (contractfModelss.cxname.toString() == 'contract/card') {
//             setState(() {
//               cxname_card = contractfModelss.filename.toString();
//               cxname_card_ser = contractfModelss.ser.toString();
//             });
//           } else if (contractfModelss.cxname.toString() == 'contract/lease') {
//             setState(() {
//               cxname_lease = contractfModelss.filename.toString();
//               cxname_lease_ser = contractfModelss.ser.toString();
//             });
//           } else if (contractfModelss.cxname.toString() == 'contract/other') {
//             setState(() {
//               cxname_other = contractfModelss.filename.toString();
//               cxname_other_ser = contractfModelss.ser.toString();
//             });

//             //////////----------------------------------

//             setState(() {
//               Other_file.add(contractfModelss);
//             });
//           } else {}
//         }

//         // //print('00000000>>>>>>>>>>>>>>>>> ${contractfModels.length}');
//       } else {}
//     } catch (e) {}
//   }

//   Future<Null> InsertFile_SQL(String FileName, String MixPath) async {
//     String dateTimeNow = DateTime.now().toString();
//     String date_ = DateFormat('yyyy-MM-dd')
//         .format(DateTime.parse('${dateTimeNow}'))
//         .toString();
// ///////////------------------------->
//     final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
//     final formatter = DateFormat(' HH:mm:ss');
//     final formattedTime = formatter.format(dateTimeNow2);
//     String Time_ = formattedTime.toString();
//     ///////////------------------------->
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');

//     String SerUser = '';
//     String Namecid = '${widget.Get_Value_cid}';
//     String Path_foder = MixPath;
//     String fileName = FileName;

//     String url =
//         '${MyConstant().domain}/lnC_contractf.php?isAdd=true&ren=$ren&ser_user=$SerUser&namecid=$Namecid&namecxname=$Path_foder&fileNames=$fileName&dates=$date_&times=$Time_';
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result.toString());
//     } catch (e) {
//       //print(e);
//     }
//   }

//   Future<Null> deletedFile_SQL(ser) async {
//     ///////////------------------------->
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');

//     String Namecid = '${widget.Get_Value_cid}';
//     String Ser = ser;
//     String url =
//         '${MyConstant().domain}/DeC_contractf.php?isAdd=true&ren=$ren&ser_user=$Ser&namecid=$Namecid';
//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print('result deletedFile_SQL $Ser//$Namecid : ${result.toString()}');
//     } catch (e) {
//       //print(e);
//     }
//     GC_contractf();
//   }

//   Future<void> deletedFile_(
//       String fileName, String ser, String PathfoderSub) async {
//     String Path_foder = 'contract';
//     String Path_foderSub = PathfoderSub;
//     String fileName_ = fileName;
//     final deleteRequest = html.HttpRequest();
//     deleteRequest.open('POST',
//         '${MyConstant().domain}/File_Deleted.php?Foder=$foder&Pathfoder=$Path_foder&PathfoderSub=$Path_foderSub&name=$fileName_');
//     deleteRequest.send();

//     // Handle the response
//     await deleteRequest.onLoad.first;
//     if (deleteRequest.status == 200) {
//       final response = deleteRequest.response;
//       if (response == 'File deleted successfully.') {
//         //print('File deleted successfully!');
//       } else {
//         //print('Failed to delete file: $response');
//       }
//     } else {
//       //print('Failed to delete file!');
//     }
//   }

//   Future<void> uploadFile_IDcard(cxname_card, cxname_card_ser) async {
//     String Path_foder = 'contract';
//     String Path_foderSub = 'card';

//     String dateTimeNow = DateTime.now().toString();
//     String date_ = DateFormat('ddMMyyyy')
//         .format(DateTime.parse('${dateTimeNow}'))
//         .toString();
//     // String fileName = 'card_${widget.Get_Value_cid}_$date_.pdf';
//     String MixPath_ = '$Path_foder/$Path_foderSub';

//     // InsertFile_SQL(fileName, MixPath_);
//     // Open the file picker and get the selected file
//     final input = html.FileUploadInputElement();
//     input.accept = 'image/jpeg,image/png,image/jpg';
//     input.click();
//     // deletedFile_('IDcard_LE000001_25-02-2023.pdf');
//     await input.onChange.first;

//     final file = input.files!.first;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     await reader.onLoadEnd.first;
//     String fileName_ = file.name;
//     String extension = fileName_.split('.').last;
//     //print('File name: $fileName_');
//     //print('Extension: $extension');
//     String fileName = 'card_${widget.Get_Value_cid}_$date_.$extension';
//     InsertFile_SQL(fileName, MixPath_);
//     // Create a new FormData object and add the file to it
//     final formData = html.FormData();
//     formData.appendBlob('file', file, fileName);

//     // Send the request
//     final request = html.HttpRequest();
//     request.open('POST',
//         '${MyConstant().domain}/File_uploadTestTOTo.php?file=$base64&name=$fileName&Foder=$foder&Pathfoder=$Path_foder&PathfoderSub=$Path_foderSub');
//     request.send(formData);
//     GC_contractf();
//     // Handle the response
//     await request.onLoad.first;

//     //print(File_Names);
//     if (request.status == 200) {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       var name = preferences.getString('fname');
//       Insert_log.Insert_logs('สัญญาเช่า',
//           '$name>สัญญา${widget.Get_Value_cid}>อัพโหลดสำเนาบัตรประชาชน');
//       //print('File uploaded successfully!');
//     } else {
//       //print('File upload failed with status code: ${request.status}');
//     }
//   }

//   Future<void> uploadFile_Agreement(cxname_lease, cxname_lease_ser) async {
//     String Path_foder = 'contract';
//     String Path_foderSub = 'lease';
//     String dateTimeNow = DateTime.now().toString();
//     String date_ =
//         DateFormat('ddMMyyyy').format(DateTime.parse(dateTimeNow)).toString();
//     String fileName = 'lease_${widget.Get_Value_cid}_$date_.pdf';
//     String MixPath_ = '$Path_foder/$Path_foderSub';
//     InsertFile_SQL(fileName, MixPath_);
//     // Open the file picker and get the selected file
//     final input = html.FileUploadInputElement();
//     input..accept = 'application/pdf';
//     input.click();
//     await input.onChange.first;

//     final file = input.files!.first;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     await reader.onLoadEnd.first;

//     // Create a new FormData object and add the file to it
//     final formData = html.FormData();
//     formData.appendBlob('file', file, fileName);

//     // Send the request
//     final request = html.HttpRequest();
//     request.open('POST',
//         '${MyConstant().domain}/File_uploadTestTOTo.php?file=$base64&name=$fileName&Foder=$foder&Pathfoder=$Path_foder&PathfoderSub=$Path_foderSub');
//     request.send(formData);
//     GC_contractf();
//     // Handle the response
//     await request.onLoad.first;
//     if (request.status == 200) {
//       setState(() {
//         File_Names = fileName.toString();
//       });
//       //print('File uploaded successfully!');
//     } else {
//       //print('File upload failed with status code: ${request.status}');
//     }
//   }

//   Future<void> uploadFile_Documentmore(cxname_other, cxname_other_ser) async {
//     String Path_foder = 'contract';
//     String Path_foderSub = 'other';
//     String dateTimeNow = DateTime.now().toString();
//     String date_ = DateFormat('ddMMyyyy')
//         .format(DateTime.parse('${dateTimeNow}'))
//         .toString();

//     String fileName =
//         'other_${widget.Get_Value_cid}_${date_}_${Other_file.length + 1}.pdf';
//     String MixPath_ = '$Path_foder/$Path_foderSub';

//     InsertFile_SQL(fileName, MixPath_);

//     // Open the file picker and get the selected file
//     final input = html.FileUploadInputElement();
//     input..accept = 'application/pdf';
//     input.click();
//     await input.onChange.first;

//     final file = input.files!.first;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     await reader.onLoadEnd.first;

//     // Create a new FormData object and add the file to it
//     final formData = html.FormData();
//     formData.appendBlob('file', file, fileName);

//     // Send the request
//     final request = html.HttpRequest();
//     request.open('POST',
//         '${MyConstant().domain}/File_uploadTestTOTo.php?file=$base64&name=$fileName&Foder=$foder&Pathfoder=$Path_foder&PathfoderSub=$Path_foderSub');
//     request.send(formData);
//     GC_contractf();
//     // Handle the response
//     await request.onLoad.first;
//     if (request.status == 200) {
//       setState(() {
//         File_Names = fileName.toString();
//       });
//       //print('File uploaded successfully!');
//     } else {
//       //print('File upload failed with status code: ${request.status}');
//     }
//   }

//   // Future<void> uploadFile_IDcard(FilePickerResult result) async {
//   //   // Get the file bytes from the result
//   //   final Uint8List bytes = result.files.first.bytes!;
//   //   String dateTimeNow = DateTime.now().toString();
//   //   String date_ = DateFormat('dd-MM-yyyy')
//   //       .format(DateTime.parse('${dateTimeNow}'))
//   //       .toString();
//   //   String fileName = 'IDcard_${widget.Get_Value_cid}_$date_.pdf';

//   //   // Convert the bytes to base64
//   //   final String base64 = base64Encode(bytes);

//   //   // Make the API request to upload the file to your server
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(
//   //           '${MyConstant().domain}/File_uploadTestTOTo.php?file=$base64&name=$fileName'),
//   //       body: {
//   //         'file': base64,
//   //         'name': fileName,
//   //       },
//   //     );

//   //     if (response.statusCode == 200) {
//   //       //print('File uploaded successfully!');
//   //     } else {
//   //       //print('File upload failed!');
//   //     }
//   //   } catch (e) {
//   //     //print('catch (e)');
//   //     //print(e);
//   //   }
//   // }

//   // Future<void> uploadFile_Agreement(FilePickerResult result) async {
//   //   ///////////////////------------------------------------>
//   //   // Get the file bytes from the result
//   //   final Uint8List bytes = result.files.first.bytes!;
//   //   ///////////////////------------------------------------>

//   //   String dateTimeNow = DateTime.now().toString();
//   //   String date_ = DateFormat('dd-MM-yyyy')
//   //       .format(DateTime.parse('${dateTimeNow}'))
//   //       .toString();
//   //   String fileName = 'Agreement_${widget.Get_Value_cid}_$date_.pdf';
//   //   ///////////////////------------------------------------>
//   //   // Convert the bytes to base64    'https://dzentric.com/chao_perty/chao_api/File_uploadTestTOTo.php?file=$base64&name=$fileName';
//   //   final String base64 = base64Encode(bytes);
//   //   String uploadurl =
//   //       "${MyConstant().domain}/File_upload.php&file=$base64&name=$fileName";
//   //   // String uploadurl =
//   //   //     "${MyConstant().domain}/xxxxxxx.php&file=$base64&name=$fileName";
//   //   //print(base64);
//   //   ///////////////////------------------------------------>
//   //   // Make the API request to upload the file to your server
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(uploadurl),
//   //       body: {
//   //         "file": base64,
//   //         "name": fileName,
//   //       },
//   //     );

//   //     if (response.statusCode == 200) {
//   //       //print('File uploaded successfully!');
//   //     } else {
//   //       //print('File upload failed!');
//   //     }
//   //   } catch (e) {}
//   // }

//   // Future<void> uploadFile_Documentmore(FilePickerResult result) async {
//   //   ///////////////////------------------------------------>
//   //   // Get the file bytes from the result
//   //   final Uint8List bytes = result.files.first.bytes!;
//   //   ///////////////////------------------------------------>
//   //   var path = result.paths;
//   //   String dateTimeNow = DateTime.now().toString();
//   //   String date_ = DateFormat('dd-MM-yyyy')
//   //       .format(DateTime.parse('${dateTimeNow}'))
//   //       .toString();
//   //   String fileName = 'Documentmore_${widget.Get_Value_cid}_$date_.pdf';
//   //   ///////////////////------------------------------------>
//   //   // Convert the bytes to base64
//   //   final String base64 = base64Encode(bytes);
//   //   String uploadurl =
//   //       "${MyConstant().domain}/File_upload.php&file=$base64&name=$fileName";
//   //   // String uploadurl =
//   //   //     "${MyConstant().domain}/xxxxxxx.php&file=$base64&name=$fileName";
//   //   // //print(base64);
//   //   ///////////////////------------------------------------>
//   //   // Make the API request to upload the file to your server
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse(uploadurl),
//   //       body: {
//   //         "path": path,
//   //         "file": base64,
//   //         "name": fileName,
//   //       },
//   //     );

//   //     if (response.statusCode == 200) {
//   //       //print('File uploaded successfully!');
//   //     } else {
//   //       //print('File upload failed!');
//   //     }
//   //   } catch (e) {}
//   // }

//   // String? base64_Slip, fileName_Slip;
//   // var extension_;
//   // var file_;
//   // File? _file;

//   Future<Null> chooseImage(ImageSource source) async {
//     // ignore: deprecated_member_use
//     var object = await ImagePicker()
//         .getImage(source: source, maxWidth: 800.0, maxHeight: 800.0);
//     Uint8List bytes = File(object!.path).readAsBytesSync();
//     int timestamp = DateTime.now().millisecondsSinceEpoch;

//     setState(() {
//       fileName_Slip = '${fiew}_${widget.Get_Value_cid}_$timestamp';
//       base64_Slip = base64Encode(bytes);
//       _file = File(object.path);
//       extension_ = 'jpg';
//     });
//     // try {
//     //   var object = await ImagePicker().pickImage(source: source);
//     //   Uint8List bytes = File(object!.path).readAsBytesSync();
//     //   int timestamp = DateTime.now().millisecondsSinceEpoch;
//     //   setState(() {
//     //     fileName_Slip = '${fiew}_${widget.Get_Value_cid}_$timestamp';
//     //     base64_Slip = base64Encode(bytes);
//     //     _file = File(object.path);
//     //     extension_ = 'jpg';
//     //   });
//     // } catch (e) {}
//     // uploadImage();
//   }

//   // Future<void> uploadImage(ImageSource source) async {
//   //   int timestamp = DateTime.now().millisecondsSinceEpoch;
//   //   setState(() {
//   //     fileName_Slip = '${fiew}_${widget.Get_Value_cid}_$timestamp.jpg';
//   //   });
//   //   // //print(fileName_Slip);
//   //   // var name_ = 'testforweb_$timestamp';
//   //   // var foder_ = 'kad_taii';
//   //   // 1. Capture an image from the device's gallery or camera
//   //   final imagePicker = ImagePicker();
//   //   final pickedFile = await imagePicker.getImage(source: source);

//   //   if (pickedFile == null) {
//   //     //print('User canceled image selection');
//   //     return;
//   //   }

//   //   try {
//   //     // 2. Read the image as bytes
//   //     final imageBytes = await pickedFile.readAsBytes();

//   //     // 3. Encode the image as a base64 string
//   //     final base64Image = base64Encode(imageBytes);

//   //     // 4. Make an HTTP POST request to your server
//   //     final url =
//   //         '${MyConstant().domain}/File_photo.php?name=$fileName_Slip&Foder=$foder';

//   //     final response = await http.post(
//   //       Uri.parse(url),
//   //       body: {
//   //         'image': base64Image,
//   //         'Foder': foder,
//   //         'name': fileName_Slip
//   //       }, // Send the image as a form field named 'image'
//   //     );

//   //     if (response.statusCode == 200) {
//   //       //print('Image uploaded successfully');
//   //       up_photo_string();
//   //     } else {
//   //       //print('Image upload failed');
//   //     }
//   //   } catch (e) {
//   //     //print('Error during image processing: $e');
//   //   }
//   // }

//   Future<void> _getFromGallery2() async {
//     // InsertFile_SQL(fileName, MixPath_);
//     // Open the file picker and get the selected file
//     final input = html.FileUploadInputElement();
//     // input..accept = 'application/pdf';
//     input.accept = 'image/jpeg,image/png,image/jpg';
//     input.click();
//     // deletedFile_('IDcard_LE000001_25-02-2023.pdf');
//     await input.onChange.first;

//     final file = input.files!.first;
//     final reader = html.FileReader();
//     reader.readAsArrayBuffer(file);
//     await reader.onLoadEnd.first;
//     String fileName_ = file.name;
//     String extension = fileName_.split('.').last;
//     //print('File name: $fileName_');
//     //print('Extension: $extension');
//     setState(() {
//       base64_Slip = base64Encode(reader.result as Uint8List);
//     });

//     setState(() {
//       extension_ = extension;
//       file_ = file;
//     });
//     OKuploadFile_Phto();
//   }

//   Future<void> OKuploadFile_Phto() async {
//     if (base64_Slip != null) {
//       String Path_foder = 'contract';
//       String dateTimeNow = DateTime.now().toString();
//       String date = DateFormat('ddMMyyyy')
//           .format(DateTime.parse('${dateTimeNow}'))
//           .toString();
//       final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
//       final formatter2 = DateFormat('HHmmss');
//       final formattedTime2 = formatter2.format(dateTimeNow2);
//       String Time_ = formattedTime2.toString();
//       int timestamp = DateTime.now().millisecondsSinceEpoch;
//       setState(() {
//         fileName_Slip =
//             '${fiew}_${widget.Get_Value_cid}_$timestamp.$extension_';
//       });
//       // String fileName = 'slip_${widget.Get_Value_cid}_${date}_$Time_.$extension_';
//       // InsertFile_SQL(fileName, MixPath_, formattedTime1);
//       // Create a new FormData object and add the file to it
//       final formData = html.FormData();
//       formData.appendBlob('file', file_, fileName_Slip);
//       // Send the request
//       final request = html.HttpRequest();
//       request.open('POST',
//           '${MyConstant().domain}/File_uploadPhoto.php?name=$fileName_Slip&Foder=$foder&Pathfoder=$Path_foder');
//       request.send(formData);
//       //print(formData);

//       // Handle the response
//       await request.onLoad.first;

//       if (request.status == 200) {
//         //print('File uploaded successfully!');
//         up_photo_string();
//       } else {
//         //print('File upload failed with status code: ${request.status}');
//       }
//     } else {
//       //print('ยังไม่ได้เลือกรูปภาพ');
//     }
//   }

//   // Future<Null> up_photo_string() async {
//   //   SharedPreferences preferences = await SharedPreferences.getInstance();
//   //   var ren = preferences.getString('renTalSer');
//   //   var user = preferences.getString('ser');
//   //   var ciddoc = widget.Get_Value_cid;
//   //   var qutser = widget.Get_Value_NameShop_index;
//   //   var fiewx = fiew;
//   //   String? fileName_Slip_ = fileName_Slip.toString().trim();

//   //   String url =
//   //       '${MyConstant().domain}/GC_tran_Kon_photo.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser&fiewx=$fiewx&fileName_Slip=$fileName_Slip_';
//   //   try {
//   //     var response = await http.get(Uri.parse(url));

//   //     var result = json.decode(response.body);
//   //     // //print(result);
//   //     if (result.toString() == 'true') {
//   //       setState(() {
//   //         fileName_Slip_ = null;
//   //         base64_Slip = null;
//   //         extension_ = null;
//   //         file_ = null;
//   //         _file = null;
//   //         fiew = null;
//   //         read_GC_photo();
//   //       });
//   //     }
//   //   } catch (e) {}
//   // }
// ////////---------------------------------->

//   Future<Null> read_customer() async {
//     if (customer_Models.isNotEmpty) {
//       setState(() {
//         customer_Models.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? ren = preferences.getString('renTalSer');
//     String? serzone = preferences.getString('zoneSer');
//     //print('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz>>>>>>>>>>>>>>>>>>>>>>>>> $serzone');
//     String url =
//         '${MyConstant().domain}/GC_custo_Information.php?isAdd=true&ren=$ren';

//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       //print(result);
//       if (result.toString() != 'null') {
//         for (var map in result) {
//           CustomerModel customerModel = CustomerModel.fromJson(map);
//           setState(() {
//             customer_Models.add(customerModel);
//           });
//         }
//       }
//       //print(customer_Models.map((e) => e.scname));
//       setState(() {
//         _customerModels = customer_Models;
//       });
//       //print(_customerModels.map((e) => e.scname));
//     } catch (e) {}
//   }
// ////////---------------------------------->

//   Future<Null> read_PakanDocno() async {
//     if (pakanDocnoModels.isNotEmpty) {
//       setState(() {
//         pakanDocnoModels.clear();
//       });
//     }
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? ren = preferences.getString('renTalSer');
//     String? serzone = preferences.getString('zoneSer');
//     var ciddoc = widget.Get_Value_cid;

//     String url =
//         '${MyConstant().domain}/GC_PakanDocno_Choice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&renew_cid=${Form_renew_cid.text}';

//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       // //print(result);
//       if (result.toString() != 'null') {
//         for (var map in result) {
//           PakanDocnoModel pakanDocnoModel = PakanDocnoModel.fromJson(map);
//           setState(() {
//             Form_PakanSdate.text = pakanDocnoModel.min_date.toString();
//             Form_PakanLdate.text = pakanDocnoModel.max_date.toString();
//             Form_PakanSdate_Doc.text = pakanDocnoModel.min_docno.toString();
//             Form_PakanLdate_Doc.text = pakanDocnoModel.max_docno.toString();
//             _PakanSdate_Doc = pakanDocnoModel.min_docno.toString();
//             Form_PakanAll_amt.text = (pakanDocnoModel.amt_pakan == null ||
//                     pakanDocnoModel.amt_pakan.toString() == '')
//                 ? '0.00'
//                 : pakanDocnoModel.amt_pakan.toString();
//             Form_PakanAll_pvat.text = (pakanDocnoModel.pvat_pakan == null ||
//                     pakanDocnoModel.pvat_pakan.toString() == '')
//                 ? '0.00'
//                 : pakanDocnoModel.pvat_pakan.toString();
//             Form_PakanAll_vat.text = (pakanDocnoModel.vat_pakan == null ||
//                     pakanDocnoModel.vat_pakan.toString() == '')
//                 ? '0.00'
//                 : pakanDocnoModel.vat_pakan.toString();

//             Form_PakanAll_Total.text = (pakanDocnoModel.total_pakan == null ||
//                     pakanDocnoModel.total_pakan.toString() == '')
//                 ? '0.00'
//                 : pakanDocnoModel.total_pakan.toString();

//             ///------------>
//             Form_PakanAll_amt_first.text =
//                 (pakanDocnoModel.amt_pakan_first == null ||
//                         pakanDocnoModel.amt_pakan_first.toString() == '')
//                     ? '0.00'
//                     : pakanDocnoModel.amt_pakan_first.toString();
//             Form_PakanAll_pvat_first.text =
//                 (pakanDocnoModel.pvat_pakan_first == null ||
//                         pakanDocnoModel.pvat_pakan_first.toString() == '')
//                     ? '0.00'
//                     : pakanDocnoModel.pvat_pakan_first.toString();
//             Form_PakanAll_vat_first.text =
//                 (pakanDocnoModel.vat_pakan_first == null ||
//                         pakanDocnoModel.vat_pakan_first.toString() == '')
//                     ? '0.00'
//                     : pakanDocnoModel.vat_pakan_first.toString();

//             Form_PakanAll_Total_first.text =
//                 (pakanDocnoModel.total_pakan_first == null ||
//                         pakanDocnoModel.total_pakan_first.toString() == '')
//                     ? '0.00'
//                     : pakanDocnoModel.total_pakan_first.toString();
//             pakanDocnoModels.add(pakanDocnoModel);
//           });
//         }
//       }
//     } catch (e) {}
//   }

// ////////---------------------------------->
//   _searchBarAll() {
//     return StreamBuilder(
//         stream: Stream.periodic(const Duration(seconds: 0)),
//         builder: (context, snapshot) {
//           return TextField(
//             autofocus: false,
//             keyboardType: TextInputType.text,
//             style: const TextStyle(
//               // fontSize: 22.0,
//               color: Colors.black,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               // fillColor: Colors.white,
//               hintText: ' Search...',
//               hintStyle: const TextStyle(
//                 color: PeopleChaoScreen_Color.Colors_Text1_,
//                 // fontWeight: FontWeight.bold,
//                 fontFamily: Font_.Fonts_T,
//               ),
//               contentPadding:
//                   const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
//               // focusedBorder: OutlineInputBorder(
//               //   borderSide: const BorderSide(color: Colors.white),
//               //   borderRadius: BorderRadius.circular(10),
//               // ),
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.white),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onChanged: (text) {
//               text = text.toLowerCase();
//               // //print(text);

//               setState(() {
//                 customer_Models = _customerModels.where((customer_Model) {
//                   var notTitle = customer_Model.custno.toString().toLowerCase();
//                   var notTitle2 = customer_Model.cname.toString().toLowerCase();
//                   var notTitle3 =
//                       customer_Model.scname.toString().toLowerCase();
//                   var notTitle4 = customer_Model.tax.toString().toLowerCase();

//                   return notTitle.contains(text) ||
//                       notTitle2.contains(text) ||
//                       notTitle3.contains(text) ||
//                       notTitle4.contains(text);
//                 }).toList();
//               });
//             },
//           );
//         });
//   }

//   ///--------------------------------------------->
//   Future<void> select_coutumerAll(BuildContext context) async {
//     final searchCtrl = TextEditingController();
//     final focusNode = FocusNode();
//     Timer? _debounce;
//     String? errorText;
//     int? tappedIndex;
//     bool loading = false;

//     List<dynamic> filtered = List.of(customer_Models); // <- ใช้ลิสต์เดิมของคุณ

//     void _runFilter(String q, void Function(void Function()) setState) {
//       _debounce?.cancel();
//       _debounce = Timer(const Duration(milliseconds: 250), () {
//         setState(() {
//           final query = q.trim().toLowerCase();
//           if (query.isEmpty) {
//             filtered = List.of(customer_Models);
//           } else {
//             filtered = customer_Models.where((e) {
//               final a = (e.custno ?? '').toString().toLowerCase();
//               final b = (e.scname ?? '').toString().toLowerCase();
//               final c = (e.cname ?? '').toString().toLowerCase();
//               final d = (e.type ?? '').toString().toLowerCase();
//               return a.contains(query) ||
//                   b.contains(query) ||
//                   c.contains(query) ||
//                   d.contains(query);
//             }).toList();
//           }
//         });
//       });
//     }

//     await showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (dCtx) => StatefulBuilder(
//         builder: (ctx, setState) {
//           final isDesktop = Responsive.isDesktop(ctx);
//           final dialogW = isDesktop
//               ? MediaQuery.of(ctx).size.width * 0.85
//               : MediaQuery.of(ctx).size.width * 0.95;
//           final dialogH = isDesktop
//               ? MediaQuery.of(ctx).size.height * 0.80
//               : MediaQuery.of(ctx).size.height * 0.85;

//           Widget header() => Container(
//                 padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.amber.withOpacity(.15),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.store_mall_directory_rounded,
//                           color: Colors.amber, size: 24),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('รายชื่อจากทะเบียน',
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.w700)),
//                           const SizedBox(height: 6),
//                           Row(
//                             children: [
//                               // Search box
//                               Expanded(
//                                 child: TextField(
//                                   controller: searchCtrl,
//                                   focusNode: focusNode,
//                                   onChanged: (v) => _runFilter(v, setState),
//                                   decoration: InputDecoration(
//                                     hintText:
//                                         'ค้นหา: รหัส / ชื่อร้าน / ผู้เช่า / ประเภท',
//                                     prefixIcon: const Icon(Icons.search),
//                                     isDense: true,
//                                     filled: true,
//                                     fillColor: Colors.grey.shade100,
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 10),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(14),
//                                       borderSide: BorderSide(
//                                           color: Colors.grey.shade300),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(14),
//                                       borderSide:
//                                           const BorderSide(color: Colors.amber),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 10, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(20),
//                                   border:
//                                       Border.all(color: Colors.grey.shade300),
//                                 ),
//                                 child: Text('ทั้งหมด: ${filtered.length}',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w600)),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       tooltip: 'ปิด',
//                       icon: const Icon(Icons.close_rounded),
//                       splashRadius: 22,
//                       onPressed: () => Navigator.of(dCtx).pop(),
//                     ),
//                   ],
//                 ),
//               );

//           Widget tableHeader() => Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade700,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   children: [
//                     _Hdr(text: '#', flex: 2, center: true),
//                     _Hdr(text: 'Img', flex: 2, center: true),
//                     _Hdr(text: 'รหัสสมาชิก', flex: 2),
//                     _Hdr(text: 'ชื่อร้าน', flex: 3),
//                     _Hdr(text: 'ชื่อผู้เช่า/บริษัท', flex: 3),
//                     _Hdr(text: 'ประเภทร้านค้า', flex: 3),
//                     _Hdr(text: 'TAX', flex: 2),
//                     _Hdr(text: 'ประเภท', flex: 2, center: true),
//                     _Hdr(text: 'Select', flex: 2, center: true),
//                   ],
//                 ),
//               );

//           Widget rowItem(int index) {
//             final e = filtered[index];
//             final isTap = tappedIndex == index;
//             final bg = isTap ? Colors.amber.withOpacity(.08) : Colors.white;

//             ImageProvider? avatar;
//             final img = (e.addr2 ?? '').toString();
//             if (img.isNotEmpty) {
//               avatar = NetworkImage(
//                   '${MyConstant().domain}/files/$foder/contract/$img');
//             }

//             return Material(
//               color: bg,
//               child: InkWell(
//                 onTap: () => setState(() => tappedIndex = index),
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     children: [
//                       _Cell(
//                           child:
//                               Text('${index + 1}', textAlign: TextAlign.center),
//                           flex: 2),
//                       _Cell(
//                         child: Center(
//                           child: CircleAvatar(
//                             radius: 18,
//                             backgroundColor: Colors.grey.shade300,
//                             backgroundImage: avatar,
//                             child: avatar == null
//                                 ? const Icon(Icons.image_not_supported_rounded,
//                                     size: 18)
//                                 : null,
//                           ),
//                         ),
//                         flex: 2,
//                       ),
//                       _Cell(child: Text('${e.custno ?? ''}'), flex: 2),
//                       _Cell(child: Text('${e.scname ?? ''}'), flex: 3),
//                       _Cell(child: Text('${e.cname ?? ''}'), flex: 3),
//                       _Cell(child: Text('${e.stype ?? ''}'), flex: 3),
//                       _Cell(
//                           child: Text((e.tax?.toString() == 'null' ||
//                                   (e.tax ?? '').toString().isEmpty)
//                               ? '-'
//                               : '${e.tax}'),
//                           flex: 2),
//                       _Cell(
//                           child: Text('${e.type ?? ''}',
//                               textAlign: TextAlign.center),
//                           flex: 2),
//                       _Cell(
//                         child: Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey.shade600,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 8),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20)),
//                             ),
//                             onPressed: loading
//                                 ? null
//                                 : () async {
//                                     // ====== ย้าย logic เลือก/ยืนยันของคุณมาไว้ตรงนี้ ======
//                                     setState(() {
//                                       loading = true;
//                                       errorText = null;
//                                       tappedIndex = index;
//                                     });
//                                     try {
//                                       // TODO: call API / อัปเดตค่า / เซ็ตฟอร์ม ฯลฯ
//                                       // ตัวอย่าง: await _applyCustomer(e);
//                                       ScaffoldMessenger.of(ctx).showSnackBar(
//                                         const SnackBar(
//                                             content:
//                                                 Text('เลือกผู้เช่าสำเร็จ')),
//                                       );
//                                       if (Navigator.canPop(dCtx))
//                                         Navigator.pop(dCtx);
//                                     } catch (err) {
//                                       errorText = 'ผิดพลาด: $err';
//                                     } finally {
//                                       if (mounted)
//                                         setState(() => loading = false);
//                                     }
//                                   },
//                             child: loading && tappedIndex == index
//                                 ? const SizedBox(
//                                     width: 18,
//                                     height: 18,
//                                     child: CircularProgressIndicator(
//                                         strokeWidth: 2))
//                                 : const Text('Select',
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.w600)),
//                           ),
//                         ),
//                         flex: 2,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }

//           return Dialog(
//             insetPadding:
//                 const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//             backgroundColor: Colors.transparent,
//             child: ConstrainedBox(
//               constraints:
//                   BoxConstraints.tightFor(width: dialogW, height: dialogH),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Material(
//                   color: Colors.white,
//                   child: Column(
//                     children: [
//                       // Header
//                       header(),
//                       // Content
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(14),
//                               boxShadow: [
//                                 BoxShadow(
//                                     color: Colors.black.withOpacity(.05),
//                                     blurRadius: 18,
//                                     offset: const Offset(0, 4))
//                               ],
//                               border: Border.all(
//                                   color: Colors.grey.shade300, width: .8),
//                             ),
//                             child: Column(
//                               children: [
//                                 // ตารางแนวนอน
//                                 Expanded(
//                                   child: ScrollConfiguration(
//                                     behavior: ScrollConfiguration.of(ctx)
//                                         .copyWith(dragDevices: {
//                                       // ไม่ใส่ PointerDeviceKind.mouse (กัน assert mouse_tracker)
//                                       PointerDeviceKind.touch,
//                                       PointerDeviceKind.trackpad,
//                                       PointerDeviceKind.stylus,
//                                     }),
//                                     child: Scrollbar(
//                                       thumbVisibility: true,
//                                       child: SingleChildScrollView(
//                                         scrollDirection: Axis.horizontal,
//                                         child: ConstrainedBox(
//                                           constraints: BoxConstraints(
//                                               minWidth: isDesktop
//                                                   ? dialogW - 64
//                                                   : 1000),
//                                           child: Column(
//                                             children: [
//                                               tableHeader(),
//                                               Expanded(
//                                                 // ใช้ Expanded ภายใน Column ที่มีความสูงจำกัดแล้ว
//                                                 child: Scrollbar(
//                                                   thumbVisibility: true,
//                                                   child: ListView.separated(
//                                                     itemCount: filtered.length,
//                                                     separatorBuilder: (_, __) =>
//                                                         Divider(
//                                                             height: 1,
//                                                             color: Colors
//                                                                 .grey.shade200),
//                                                     itemBuilder: (c, i) =>
//                                                         rowItem(i),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 if (errorText != null) ...[
//                                   const SizedBox(height: 8),
//                                   Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 10),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red.withOpacity(0.08),
//                                       borderRadius: BorderRadius.circular(12),
//                                       border: Border.all(
//                                           color: Colors.red.withOpacity(.25)),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         const Icon(Icons.error_outline,
//                                             size: 18, color: Colors.redAccent),
//                                         const SizedBox(width: 8),
//                                         Expanded(
//                                             child: Text(errorText!,
//                                                 style: const TextStyle(
//                                                     color: Colors.redAccent))),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                                 const SizedBox(height: 8),
//                                 Align(
//                                   alignment: Alignment.centerRight,
//                                   child: TextButton.icon(
//                                     onPressed: () => Navigator.of(dCtx).pop(),
//                                     icon: const Icon(Icons.close_rounded),
//                                     label: const Text('ปิด'),
//                                     style: TextButton.styleFrom(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 16, vertical: 10),
//                                       foregroundColor: Colors.black87,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(12)),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );

//     _debounce?.cancel();
//     searchCtrl.dispose();
//     focusNode.dispose();
//   }

//   /// เฮดเดอร์ cell
//   Widget _Hdr({
//     required String text,
//     int flex = 1,
//     bool center = false,
//   }) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         text,
//         textAlign: center ? TextAlign.center : TextAlign.left,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontFamily: FontWeight_.Fonts_T,
//         ),
//       ),
//     );
//   }

//   /// เซลล์ข้อมูล
//   Widget _Cell({required Widget child, int flex = 1}) {
//     return Expanded(
//       flex: flex,
//       child: DefaultTextStyle.merge(
//         style: const TextStyle(
//           fontFamily: Font_.Fonts_T,
//           fontSize: 13,
//         ),
//         child: child,
//       ),
//     );
//   }

//   /// เซลล์ข้อมูล
// // class _Cell extends StatelessWidget {
// //   final Widget child;
// //   final int flex;
// //   const _Cell(this.child, {this.flex = 1, Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Expanded(
// //       flex: flex,
// //       child: DefaultTextStyle.merge(
// //         style: const TextStyle(fontFamily: Font_.Fonts_T, fontSize: 13),
// //         child: child,
// //       ),
// //     );
// //   }
// // }

//   // Future<Null> select_coutumerAll(context) async {
//   //   return showDialog(
//   //     barrierDismissible: false,
//   //     context: context,
//   //     builder: (BuildContext context) => StatefulBuilder(
//   //         // stream: Stream.periodic(const Duration(seconds: 0)),
//   //         builder: (context, snapshot) {
//   //       String tappedIndex_ = '';
//   //       return AlertDialog(
//   //         shape: const RoundedRectangleBorder(
//   //             borderRadius: BorderRadius.all(Radius.circular(20.0))),
//   //         title: Column(
//   //           children: [
//   //             Center(
//   //               child: Text(
//   //                 'รายชื่อจากทะเบียน',
//   //                 style: TextStyle(
//   //                   color: Colors.black,
//   //                   fontWeight: FontWeight.bold,
//   //                 ),
//   //               ),
//   //             ),
//   //             Container(
//   //               // padding: EdgeInsets.all(10),
//   //               child: Row(
//   //                 children: [
//   //                   Expanded(
//   //                     child: _searchBarAll(),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //         content: StreamBuilder(
//   //             stream: Stream.periodic(const Duration(seconds: 0)),
//   //             builder: (context, snapshot) {
//   //               return SingleChildScrollView(
//   //                 child: ListBody(
//   //                   children: <Widget>[
//   //                     ScrollConfiguration(
//   //                       behavior: ScrollConfiguration.of(context)
//   //                           .copyWith(dragDevices: {
//   //                         PointerDeviceKind.touch,
//   //                         PointerDeviceKind.mouse,
//   //                       }),
//   //                       child: SingleChildScrollView(
//   //                         scrollDirection: Axis.horizontal,
//   //                         dragStartBehavior: DragStartBehavior.start,
//   //                         child: Row(
//   //                           children: [
//   //                             Container(
//   //                               // height:
//   //                               //     MediaQuery.of(context).size.height /
//   //                               //         1.5,
//   //                               width: (!Responsive.isDesktop(context))
//   //                                   ? 1000
//   //                                   : MediaQuery.of(context).size.width / 1.2,
//   //                               decoration: BoxDecoration(
//   //                                 color: Colors.grey.shade100,
//   //                                 borderRadius: const BorderRadius.only(
//   //                                     topLeft: Radius.circular(10),
//   //                                     topRight: Radius.circular(10),
//   //                                     bottomLeft: Radius.circular(10),
//   //                                     bottomRight: Radius.circular(10)),
//   //                                 // border: Border.all(color: Colors.white, width: 1),
//   //                               ),
//   //                               child: Padding(
//   //                                 padding: const EdgeInsets.all(2.0),
//   //                                 child: Container(
//   //                                     decoration: BoxDecoration(
//   //                                       color: Colors.grey.shade100,
//   //                                       borderRadius: const BorderRadius.only(
//   //                                           topLeft: Radius.circular(15),
//   //                                           topRight: Radius.circular(15),
//   //                                           bottomLeft: Radius.circular(15),
//   //                                           bottomRight: Radius.circular(15)),
//   //                                     ),
//   //                                     padding: const EdgeInsets.all(2.0),
//   //                                     child: Column(
//   //                                       children: [
//   //                                         Container(
//   //                                           padding: const EdgeInsets.all(10),
//   //                                           decoration: BoxDecoration(
//   //                                             color: Colors.grey.shade600,
//   //                                             borderRadius:
//   //                                                 const BorderRadius.only(
//   //                                                     topLeft:
//   //                                                         Radius.circular(10),
//   //                                                     topRight:
//   //                                                         Radius.circular(10),
//   //                                                     bottomLeft:
//   //                                                         Radius.circular(0),
//   //                                                     bottomRight:
//   //                                                         Radius.circular(0)),
//   //                                           ),
//   //                                           child: const Row(
//   //                                             children: [
//   //                                               Expanded(
//   //                                                 flex: 2,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   '...',
//   //                                                   textAlign: TextAlign.center,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 2,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'Img',
//   //                                                   textAlign: TextAlign.center,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 2,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'รหัสสมาชิก',
//   //                                                   textAlign: TextAlign.left,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 3,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'ชื่อร้าน',
//   //                                                   textAlign: TextAlign.left,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 3,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'ชื่อผู่เช่า/บริษัท',
//   //                                                   textAlign: TextAlign.left,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 3,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'ประเภทร้านค้า',
//   //                                                   textAlign: TextAlign.left,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 2,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'TAX',
//   //                                                   textAlign: TextAlign.left,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 2,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'ประเภท',
//   //                                                   textAlign: TextAlign.center,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                               Expanded(
//   //                                                 flex: 2,
//   //                                                 child: AutoSizeText(
//   //                                                   minFontSize: 10,
//   //                                                   maxFontSize: 18,
//   //                                                   'Select',
//   //                                                   textAlign: TextAlign.center,
//   //                                                   style: TextStyle(
//   //                                                     color: Colors.white,
//   //                                                     fontWeight:
//   //                                                         FontWeight.bold,
//   //                                                     fontFamily:
//   //                                                         FontWeight_.Fonts_T,
//   //                                                   ),
//   //                                                 ),
//   //                                               ),
//   //                                             ],
//   //                                           ),
//   //                                         ),
//   //                                         Container(
//   //                                             width: (!Responsive.isDesktop(
//   //                                                     context))
//   //                                                 ? 1000
//   //                                                 : MediaQuery.of(context)
//   //                                                         .size
//   //                                                         .width /
//   //                                                     1.2,
//   //                                             height: MediaQuery.of(context)
//   //                                                     .size
//   //                                                     .height *
//   //                                                 0.4,
//   //                                             child: ListView.builder(
//   //                                                 physics:
//   //                                                     const AlwaysScrollableScrollPhysics(),
//   //                                                 shrinkWrap: true,
//   //                                                 itemCount:
//   //                                                     customer_Models.length,
//   //                                                 itemBuilder:
//   //                                                     (BuildContext context,
//   //                                                         int index) {
//   //                                                   return Material(
//   //                                                     color: tappedIndex_ ==
//   //                                                             index.toString()
//   //                                                         ? tappedIndex_Color
//   //                                                             .tappedIndex_Colors
//   //                                                             .withOpacity(0.5)
//   //                                                         : AppbackgroundColor
//   //                                                             .Sub_Abg_Colors,
//   //                                                     child: Container(
//   //                                                       padding:
//   //                                                           const EdgeInsets
//   //                                                               .all(5),
//   //                                                       child: ListTile(
//   //                                                         onTap: () async {
//   //                                                           var NEW_Form_nameshop =
//   //                                                               '${customer_Models[index].scname}';

//   //                                                           var NEW_Form_sname =
//   //                                                               '${customer_Models[index].sname}';
//   //                                                           var NEW_Form_typeshop =
//   //                                                               '${customer_Models[index].stype}';

//   //                                                           var NEW_Form_bussshop =
//   //                                                               '${customer_Models[index].cname}';
//   //                                                           var NEW_Form_bussscontact =
//   //                                                               '${customer_Models[index].attn}';
//   //                                                           var NEW_Form_address =
//   //                                                               '${customer_Models[index].addr1}';
//   //                                                           var NEW_Form_tel =
//   //                                                               '${customer_Models[index].tel}';
//   //                                                           var NEW_Form_email =
//   //                                                               '${customer_Models[index].email}';
//   //                                                           var NEW_Form_tax =
//   //                                                               customer_Models[index]
//   //                                                                           .tax ==
//   //                                                                       'null'
//   //                                                                   ? "-"
//   //                                                                   : '${customer_Models[index].tax}';
//   //                                                           var ADDRx = '';
//   //                                                           var NEW_Value_AreaSer_ =
//   //                                                               int.parse(customer_Models[
//   //                                                                           index]
//   //                                                                       .typeser!) -
//   //                                                                   1; // ser ประเภท
//   //                                                           var NEW_verticalGroupValue =
//   //                                                               '${customer_Models[index].type}'; // ประเภท

//   //                                                           var NEW_number_custno =
//   //                                                               customer_Models[
//   //                                                                       index]
//   //                                                                   .custno
//   //                                                                   .toString();
//   //                                                           var NEW_img_custno =
//   //                                                               customer_Models[
//   //                                                                       index]
//   //                                                                   .addr2
//   //                                                                   .toString();

//   //                                                           //print(
//   //                                                               NEW_verticalGroupValue);
//   //                                                           setState(() {
//   //                                                             tappedIndex_ = index
//   //                                                                 .toString();
//   //                                                           });

//   //                                                           ///--->UP_LE_Rental_Information

//   //                                                           // Navigator.pop(
//   //                                                           //     context);

//   //                                                           SharedPreferences
//   //                                                               preferences =
//   //                                                               await SharedPreferences
//   //                                                                   .getInstance();
//   //                                                           String? ren =
//   //                                                               preferences
//   //                                                                   .getString(
//   //                                                                       'renTalSer');
//   //                                                           String? ser_user =
//   //                                                               preferences
//   //                                                                   .getString(
//   //                                                                       'ser');

//   //                                                           /// Widget เล็กๆ สำหรับแสดงบรรทัดสรุป
//   //                                                           Widget _PreviewRow(
//   //                                                               {required String
//   //                                                                   label,
//   //                                                               required String?
//   //                                                                   value}) {
//   //                                                             final v =
//   //                                                                 (value ?? '')
//   //                                                                     .trim();
//   //                                                             if (v.isEmpty)
//   //                                                               return const SizedBox
//   //                                                                   .shrink();

//   //                                                             return Padding(
//   //                                                               padding: const EdgeInsets
//   //                                                                       .symmetric(
//   //                                                                   vertical:
//   //                                                                       4),
//   //                                                               child: Row(
//   //                                                                 children: [
//   //                                                                   Expanded(
//   //                                                                     flex: 4,
//   //                                                                     child:
//   //                                                                         Text(
//   //                                                                       label,
//   //                                                                       style:
//   //                                                                           TextStyle(
//   //                                                                         color: Colors
//   //                                                                             .grey
//   //                                                                             .shade600,
//   //                                                                         fontSize:
//   //                                                                             13,
//   //                                                                         fontFamily:
//   //                                                                             FontWeight_.Fonts_T,
//   //                                                                       ),
//   //                                                                     ),
//   //                                                                   ),
//   //                                                                   const SizedBox(
//   //                                                                       width:
//   //                                                                           8),
//   //                                                                   Expanded(
//   //                                                                     flex: 6,
//   //                                                                     child:
//   //                                                                         Text(
//   //                                                                       v,
//   //                                                                       textAlign:
//   //                                                                           TextAlign.end,
//   //                                                                       style:
//   //                                                                           const TextStyle(
//   //                                                                         fontWeight:
//   //                                                                             FontWeight.w600,
//   //                                                                         fontFamily:
//   //                                                                             FontWeight_.Fonts_T,
//   //                                                                       ),
//   //                                                                     ),
//   //                                                                   ),
//   //                                                                 ],
//   //                                                               ),
//   //                                                             );
//   //                                                           }

//   //                                                           showDialog<String>(
//   //                                                             context: context,
//   //                                                             barrierDismissible:
//   //                                                                 true,
//   //                                                             builder:
//   //                                                                 (BuildContext
//   //                                                                     context) {
//   //                                                               bool loading =
//   //                                                                   false;
//   //                                                               String?
//   //                                                                   errorText;

//   //                                                               return StatefulBuilder(
//   //                                                                 builder: (context,
//   //                                                                         setState) =>
//   //                                                                     AlertDialog(
//   //                                                                   elevation:
//   //                                                                       2,
//   //                                                                   insetPadding: const EdgeInsets
//   //                                                                           .symmetric(
//   //                                                                       horizontal:
//   //                                                                           24,
//   //                                                                       vertical:
//   //                                                                           24),
//   //                                                                   shape:
//   //                                                                       RoundedRectangleBorder(
//   //                                                                     borderRadius:
//   //                                                                         BorderRadius.circular(
//   //                                                                             20),
//   //                                                                   ),
//   //                                                                   titlePadding:
//   //                                                                       const EdgeInsets.fromLTRB(
//   //                                                                           24,
//   //                                                                           20,
//   //                                                                           24,
//   //                                                                           0),
//   //                                                                   contentPadding:
//   //                                                                       const EdgeInsets.fromLTRB(
//   //                                                                           24,
//   //                                                                           8,
//   //                                                                           24,
//   //                                                                           16),
//   //                                                                   actionsPadding:
//   //                                                                       const EdgeInsets.fromLTRB(
//   //                                                                           16,
//   //                                                                           0,
//   //                                                                           16,
//   //                                                                           16),
//   //                                                                   title:
//   //                                                                       Column(
//   //                                                                     children: [
//   //                                                                       Container(
//   //                                                                         width:
//   //                                                                             56,
//   //                                                                         height:
//   //                                                                             56,
//   //                                                                         decoration:
//   //                                                                             BoxDecoration(
//   //                                                                           color:
//   //                                                                               Colors.amber.withOpacity(0.15),
//   //                                                                           shape:
//   //                                                                               BoxShape.circle,
//   //                                                                         ),
//   //                                                                         child: const Icon(
//   //                                                                             Icons.edit_note_rounded,
//   //                                                                             size: 30,
//   //                                                                             color: Colors.amber),
//   //                                                                       ),
//   //                                                                       const SizedBox(
//   //                                                                           height:
//   //                                                                               12),
//   //                                                                       const Text(
//   //                                                                         'เปลี่ยนแปลงข้อมูล.. ?',
//   //                                                                         textAlign:
//   //                                                                             TextAlign.center,
//   //                                                                         style:
//   //                                                                             TextStyle(
//   //                                                                           color:
//   //                                                                               AdminScafScreen_Color.Colors_Text1_,
//   //                                                                           fontWeight:
//   //                                                                               FontWeight.bold,
//   //                                                                           fontFamily:
//   //                                                                               FontWeight_.Fonts_T,
//   //                                                                         ),
//   //                                                                       ),
//   //                                                                       const SizedBox(
//   //                                                                           height:
//   //                                                                               6),
//   //                                                                       Text(
//   //                                                                         'ยืนยันการแก้ไขข้อมูลผู้เช่า',
//   //                                                                         style:
//   //                                                                             TextStyle(
//   //                                                                           color:
//   //                                                                               Colors.grey.shade600,
//   //                                                                           fontFamily:
//   //                                                                               FontWeight_.Fonts_T,
//   //                                                                           fontSize:
//   //                                                                               13,
//   //                                                                         ),
//   //                                                                       ),
//   //                                                                       const SizedBox(
//   //                                                                           height:
//   //                                                                               8),
//   //                                                                       Divider(
//   //                                                                           color:
//   //                                                                               Colors.grey.shade300,
//   //                                                                           height: 24),
//   //                                                                     ],
//   //                                                                   ),
//   //                                                                   content:
//   //                                                                       Column(
//   //                                                                     mainAxisSize:
//   //                                                                         MainAxisSize
//   //                                                                             .min,
//   //                                                                     children: [
//   //                                                                       // แถบสรุปสั้น ๆ (ถ้าไม่ต้องการลบออกได้)
//   //                                                                       _PreviewRow(
//   //                                                                           label:
//   //                                                                               'เลขที่ผู้เช่า',
//   //                                                                           value:
//   //                                                                               NEW_number_custno),
//   //                                                                       _PreviewRow(
//   //                                                                           label:
//   //                                                                               'ชื่อร้าน (ใหม่)',
//   //                                                                           value:
//   //                                                                               NEW_Form_nameshop),
//   //                                                                       _PreviewRow(
//   //                                                                           label:
//   //                                                                               'ผู้ติดต่อ (ใหม่)',
//   //                                                                           value:
//   //                                                                               NEW_Form_bussscontact),
//   //                                                                       if (errorText !=
//   //                                                                           null) ...[
//   //                                                                         const SizedBox(
//   //                                                                             height: 8),
//   //                                                                         Container(
//   //                                                                           width:
//   //                                                                               double.infinity,
//   //                                                                           padding:
//   //                                                                               const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//   //                                                                           decoration:
//   //                                                                               BoxDecoration(
//   //                                                                             color: Colors.red.withOpacity(0.08),
//   //                                                                             borderRadius: BorderRadius.circular(12),
//   //                                                                           ),
//   //                                                                           child:
//   //                                                                               Row(
//   //                                                                             crossAxisAlignment: CrossAxisAlignment.start,
//   //                                                                             children: [
//   //                                                                               const Icon(Icons.error_outline, size: 18, color: Colors.redAccent),
//   //                                                                               const SizedBox(width: 8),
//   //                                                                               Expanded(
//   //                                                                                 child: Text(
//   //                                                                                   errorText!,
//   //                                                                                   style: const TextStyle(color: Colors.redAccent, fontSize: 13),
//   //                                                                                 ),
//   //                                                                               ),
//   //                                                                             ],
//   //                                                                           ),
//   //                                                                         ),
//   //                                                                       ],
//   //                                                                     ],
//   //                                                                   ),
//   //                                                                   actions: [
//   //                                                                     Row(
//   //                                                                       mainAxisAlignment:
//   //                                                                           MainAxisAlignment.center,
//   //                                                                       children: [
//   //                                                                         // ปุ่มยกเลิก
//   //                                                                         SizedBox(
//   //                                                                           width:
//   //                                                                               120,
//   //                                                                           child:
//   //                                                                               OutlinedButton(
//   //                                                                             onPressed: loading ? null : () => Navigator.pop(context, 'CANCEL'),
//   //                                                                             style: OutlinedButton.styleFrom(
//   //                                                                               padding: const EdgeInsets.symmetric(vertical: 12),
//   //                                                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //                                                                             ),
//   //                                                                             child: const Text(
//   //                                                                               'ยกเลิก',
//   //                                                                               style: TextStyle(fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
//   //                                                                             ),
//   //                                                                           ),
//   //                                                                         ),
//   //                                                                         const SizedBox(
//   //                                                                             width: 12),
//   //                                                                         // ปุ่มยืนยัน
//   //                                                                         SizedBox(
//   //                                                                           width:
//   //                                                                               140,
//   //                                                                           child:
//   //                                                                               ElevatedButton(
//   //                                                                             onPressed: loading
//   //                                                                                 ? null
//   //                                                                                 : () async {
//   //                                                                                     setState(() {
//   //                                                                                       loading = true;
//   //                                                                                       errorText = null;
//   //                                                                                     });

//   //                                                                                     final uri = Uri.parse('${MyConstant().domain}/UP_LE_Rental_Information.php?isAdd=true');

//   //                                                                                     final body = {
//   //                                                                                       'ren': ren ?? '',
//   //                                                                                       'custno': NEW_number_custno,
//   //                                                                                       'ctype': NEW_verticalGroupValue,
//   //                                                                                       'scname': NEW_Form_nameshop,
//   //                                                                                       'sname': customer_Models[index].scname ?? '',
//   //                                                                                       'stype': NEW_Form_typeshop,
//   //                                                                                       'cname': NEW_Form_bussshop,
//   //                                                                                       'attn': NEW_Form_bussscontact,
//   //                                                                                       'addr': NEW_Form_address,
//   //                                                                                       'addrx': ADDRx,
//   //                                                                                       'tax': NEW_Form_tax,
//   //                                                                                       'tel': NEW_Form_tel,
//   //                                                                                       'email': NEW_Form_email,
//   //                                                                                       'vLE': '${widget.Get_Value_cid}',
//   //                                                                                       'img': NEW_img_custno,
//   //                                                                                     };

//   //                                                                                     try {
//   //                                                                                       final res = await http.post(uri, body: body).timeout(const Duration(seconds: 20));

//   //                                                                                       if (res.statusCode != 200) {
//   //                                                                                         throw 'HTTP ${res.statusCode}: ${res.reasonPhrase}';
//   //                                                                                       }

//   //                                                                                       dynamic decoded;
//   //                                                                                       try {
//   //                                                                                         decoded = json.decode(res.body);
//   //                                                                                       } catch (_) {
//   //                                                                                         decoded = res.body;
//   //                                                                                       }

//   //                                                                                       final ok = (decoded is Map && (decoded['ok'] == true || decoded['ok'] == 'true')) || (decoded is bool && decoded == true) || (decoded is String && decoded.trim().toLowerCase() == 'true');

//   //                                                                                       if (ok) {
//   //                                                                                         // โหลดใหม่
//   //                                                                                         await Future.wait([
//   //                                                                                           checkPreferance(),
//   //                                                                                           read_customer(),
//   //                                                                                         ]);

//   //                                                                                         if (!mounted) return;
//   //                                                                                         Insert_log.Insert_logs(
//   //                                                                                           'ผู้เช่า',
//   //                                                                                           'เรียกดู:${widget.Get_Value_cid} >> แก้ไขข้อมูลผู้เช่า : ${Form_nameshop.text} >> $NEW_Form_nameshop',
//   //                                                                                         );
//   //                                                                                         ScaffoldMessenger.of(context).showSnackBar(
//   //                                                                                           SnackBar(
//   //                                                                                               backgroundColor: Colors.green,
//   //                                                                                               content: Text(
//   //                                                                                                 'แก้ไขข้อมูลผู้เช่าสำเร็จ',
//   //                                                                                                 style: const TextStyle(
//   //                                                                                                     color: PeopleChaoScreen_Color.Colors_Text3_,
//   //                                                                                                     //fontWeight: FontWeight.bold,
//   //                                                                                                     fontFamily: Font_.Fonts_T),
//   //                                                                                               )),
//   //                                                                                         );
//   //                                                                                         // ปิด dialog แล้วแจ้งสำเร็จ
//   //                                                                                         if (Navigator.canPop(context)) Navigator.pop(context);
//   //                                                                                         if (Navigator.canPop(context)) Navigator.pop(context);
//   //                                                                                         // await Dialog_success(context, 'แก้ไขข้อมูลผู้เช่าสำเร็จ');
//   //                                                                                       } else {
//   //                                                                                         final err = (decoded is Map && decoded['error'] != null) ? decoded['error'].toString() : 'อัปเดตไม่สำเร็จ';
//   //                                                                                         throw err;
//   //                                                                                       }
//   //                                                                                     } catch (e) {
//   //                                                                                       if (!mounted) return;
//   //                                                                                       setState(() => errorText = 'ผิดพลาด: $e');
//   //                                                                                       ScaffoldMessenger.of(context).showSnackBar(
//   //                                                                                         SnackBar(content: Text('ผิดพลาด: $e')),
//   //                                                                                       );
//   //                                                                                     } finally {
//   //                                                                                       if (mounted) setState(() => loading = false);
//   //                                                                                     }
//   //                                                                                   },
//   //                                                                             style: ElevatedButton.styleFrom(
//   //                                                                               backgroundColor: Colors.green,
//   //                                                                               foregroundColor: Colors.white,
//   //                                                                               padding: const EdgeInsets.symmetric(vertical: 12),
//   //                                                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //                                                                               elevation: 1.5,
//   //                                                                             ),
//   //                                                                             child: AnimatedSwitcher(
//   //                                                                               duration: const Duration(milliseconds: 200),
//   //                                                                               transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
//   //                                                                               child: loading
//   //                                                                                   ? const SizedBox(
//   //                                                                                       key: ValueKey('loading'),
//   //                                                                                       height: 20,
//   //                                                                                       width: 20,
//   //                                                                                       child: CircularProgressIndicator(strokeWidth: 2),
//   //                                                                                     )
//   //                                                                                   : const Text(
//   //                                                                                       'ยืนยัน',
//   //                                                                                       key: ValueKey('text'),
//   //                                                                                       style: TextStyle(
//   //                                                                                         fontWeight: FontWeight.bold,
//   //                                                                                         fontFamily: FontWeight_.Fonts_T,
//   //                                                                                       ),
//   //                                                                                     ),
//   //                                                                             ),
//   //                                                                           ),
//   //                                                                         ),
//   //                                                                       ],
//   //                                                                     ),
//   //                                                                   ],
//   //                                                                 ),
//   //                                                               );
//   //                                                             },
//   //                                                           );

//   //                                                           /// -----------------
//   //                                                         },
//   //                                                         title: Row(
//   //                                                           children: [
//   //                                                             Expanded(
//   //                                                               flex: 2,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 '${index + 1}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .center,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 2,
//   //                                                               child: (customer_Models[index].addr2 ==
//   //                                                                           null ||
//   //                                                                       customer_Models[index].addr2 ==
//   //                                                                           '')
//   //                                                                   ? Container(
//   //                                                                       // padding:
//   //                                                                       //     const EdgeInsets
//   //                                                                       //             .all(
//   //                                                                       //         2.0),
//   //                                                                       // decoration: BoxDecoration(
//   //                                                                       //     color: Colors
//   //                                                                       //             .grey[
//   //                                                                       //         200],
//   //                                                                       //     borderRadius:
//   //                                                                       //         BorderRadius.all(
//   //                                                                       //             Radius.circular(100))),
//   //                                                                       child:
//   //                                                                           const Center(
//   //                                                                         child:
//   //                                                                             Icon(Icons.image_not_supported_rounded),
//   //                                                                       ),
//   //                                                                     )
//   //                                                                   : InkWell(
//   //                                                                       child:
//   //                                                                           Container(
//   //                                                                         // color: Colors
//   //                                                                         //     .black,
//   //                                                                         child:
//   //                                                                             CircleAvatar(
//   //                                                                           radius:
//   //                                                                               30.0,
//   //                                                                           backgroundImage:
//   //                                                                               NetworkImage(
//   //                                                                             '${MyConstant().domain}/files/$foder/contract/${customer_Models[index].addr2}',
//   //                                                                           ),
//   //                                                                           backgroundColor:
//   //                                                                               Colors.transparent,
//   //                                                                         ),
//   //                                                                       ),
//   //                                                                       onTap:
//   //                                                                           () {
//   //                                                                         setState(
//   //                                                                             () {
//   //                                                                           tappedIndex_ =
//   //                                                                               index.toString();
//   //                                                                         });
//   //                                                                         showDialog<
//   //                                                                             String>(
//   //                                                                           context:
//   //                                                                               context,
//   //                                                                           builder: (BuildContext context) =>
//   //                                                                               AlertDialog(
//   //                                                                             shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
//   //                                                                             // title: Container(
//   //                                                                             //     width: MediaQuery.of(context).size.width * 0.25,
//   //                                                                             //     height: MediaQuery.of(context).size.width * 0.35,
//   //                                                                             //     child: Image.network(
//   //                                                                             //       '${MyConstant().domain}/files/$foder/contract/${customer_Models[index].addr2}',
//   //                                                                             //       fit: BoxFit.contain,
//   //                                                                             //     )),
//   //                                                                             content: Container(
//   //                                                                               // width: MediaQuery.of(context).size.width * 0.25,
//   //                                                                               // height: MediaQuery.of(context).size.width * 0.32,
//   //                                                                               child: SingleChildScrollView(
//   //                                                                                 child: ListBody(
//   //                                                                                   children: <Widget>[
//   //                                                                                     Container(
//   //                                                                                       width: MediaQuery.of(context).size.width * 0.25,
//   //                                                                                       height: MediaQuery.of(context).size.width * 0.32,
//   //                                                                                       child: Image.network(
//   //                                                                                         '${MyConstant().domain}/files/$foder/contract/${customer_Models[index].addr2}',
//   //                                                                                         fit: BoxFit.contain,
//   //                                                                                       ),
//   //                                                                                     ),
//   //                                                                                   ],
//   //                                                                                 ),
//   //                                                                               ),
//   //                                                                             ),
//   //                                                                             actions: <Widget>[
//   //                                                                               Column(
//   //                                                                                 children: [
//   //                                                                                   const SizedBox(
//   //                                                                                     height: 5.0,
//   //                                                                                   ),
//   //                                                                                   const Divider(
//   //                                                                                     color: Colors.grey,
//   //                                                                                     height: 4.0,
//   //                                                                                   ),
//   //                                                                                   const SizedBox(
//   //                                                                                     height: 5.0,
//   //                                                                                   ),
//   //                                                                                   Padding(
//   //                                                                                     padding: const EdgeInsets.all(8.0),
//   //                                                                                     child: Row(
//   //                                                                                       mainAxisAlignment: MainAxisAlignment.center,
//   //                                                                                       children: [
//   //                                                                                         Container(
//   //                                                                                           width: 100,
//   //                                                                                           decoration: const BoxDecoration(
//   //                                                                                             color: Colors.redAccent,
//   //                                                                                             borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
//   //                                                                                           ),
//   //                                                                                           padding: const EdgeInsets.all(8.0),
//   //                                                                                           child: TextButton(
//   //                                                                                             onPressed: () => Navigator.pop(context, 'OK'),
//   //                                                                                             child: const Text(
//   //                                                                                               'ปิด',
//   //                                                                                               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
//   //                                                                                             ),
//   //                                                                                           ),
//   //                                                                                         ),
//   //                                                                                       ],
//   //                                                                                     ),
//   //                                                                                   ),
//   //                                                                                 ],
//   //                                                                               ),
//   //                                                                             ],
//   //                                                                           ),
//   //                                                                         );
//   //                                                                       },
//   //                                                                     ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 2,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 customer_Models[index]
//   //                                                                             .custno ==
//   //                                                                         null
//   //                                                                     ? ''
//   //                                                                     : '${customer_Models[index].custno}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .left,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 3,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 '${customer_Models[index].scname}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .start,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 3,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 '${customer_Models[index].cname}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .start,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 3,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 '${customer_Models[index].stype}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .start,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 2,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 (customer_Models[index]
//   //                                                                             .tax
//   //                                                                             .toString() ==
//   //                                                                         'null')
//   //                                                                     ? '-'
//   //                                                                     : '${customer_Models[index].tax}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .left,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 2,
//   //                                                               child:
//   //                                                                   AutoSizeText(
//   //                                                                 minFontSize:
//   //                                                                     10,
//   //                                                                 maxFontSize:
//   //                                                                     18,
//   //                                                                 '${customer_Models[index].type}',
//   //                                                                 textAlign:
//   //                                                                     TextAlign
//   //                                                                         .center,
//   //                                                                 style:
//   //                                                                     const TextStyle(
//   //                                                                   color: PeopleChaoScreen_Color
//   //                                                                       .Colors_Text2_,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   fontFamily:
//   //                                                                       Font_
//   //                                                                           .Fonts_T,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                   // fontWeight: FontWeight.bold,
//   //                                                                 ),
//   //                                                               ),
//   //                                                             ),
//   //                                                             Expanded(
//   //                                                               flex: 2,
//   //                                                               child: Row(
//   //                                                                 mainAxisAlignment:
//   //                                                                     MainAxisAlignment
//   //                                                                         .end,
//   //                                                                 children: [
//   //                                                                   Container(
//   //                                                                     decoration:
//   //                                                                         BoxDecoration(
//   //                                                                       color: Colors
//   //                                                                           .grey[500],
//   //                                                                       borderRadius: BorderRadius.only(
//   //                                                                           topLeft:
//   //                                                                               Radius.circular(10),
//   //                                                                           topRight: Radius.circular(10),
//   //                                                                           bottomLeft: Radius.circular(10),
//   //                                                                           bottomRight: Radius.circular(10)),
//   //                                                                     ),
//   //                                                                     padding:
//   //                                                                         const EdgeInsets.all(
//   //                                                                             8.0),
//   //                                                                     child:
//   //                                                                         AutoSizeText(
//   //                                                                       minFontSize:
//   //                                                                           10,
//   //                                                                       maxFontSize:
//   //                                                                           18,
//   //                                                                       'Select',
//   //                                                                       textAlign:
//   //                                                                           TextAlign.center,
//   //                                                                       style:
//   //                                                                           TextStyle(
//   //                                                                         color:
//   //                                                                             PeopleChaoScreen_Color.Colors_Text2_,
//   //                                                                         // fontWeight: FontWeight.bold,
//   //                                                                         fontFamily:
//   //                                                                             Font_.Fonts_T,
//   //                                                                         // fontWeight: FontWeight.bold,
//   //                                                                         // fontWeight: FontWeight.bold,
//   //                                                                       ),
//   //                                                                     ),
//   //                                                                   ),
//   //                                                                 ],
//   //                                                               ),
//   //                                                             ),
//   //                                                           ],
//   //                                                         ),
//   //                                                       ),
//   //                                                     ),
//   //                                                   );
//   //                                                 })),
//   //                                       ],
//   //                                     )),
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               );
//   //             }),
//   //         actions: <Widget>[
//   //           Padding(
//   //             padding: const EdgeInsets.all(8.0),
//   //             child: Column(
//   //               children: [
//   //                 const SizedBox(
//   //                   height: 5.0,
//   //                 ),
//   //                 const Divider(
//   //                   color: Colors.grey,
//   //                   height: 4.0,
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 5.0,
//   //                 ),
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.end,
//   //                   children: [
//   //                     Container(
//   //                       width: 100,
//   //                       decoration: const BoxDecoration(
//   //                         color: Colors.black,
//   //                         borderRadius: BorderRadius.only(
//   //                             topLeft: Radius.circular(10),
//   //                             topRight: Radius.circular(10),
//   //                             bottomLeft: Radius.circular(10),
//   //                             bottomRight: Radius.circular(10)),
//   //                       ),
//   //                       padding: const EdgeInsets.all(8.0),
//   //                       child: TextButton(
//   //                         onPressed: () {
//   //                           Navigator.pop(context);
//   //                         },
//   //                         child: const Text(
//   //                           'ยกเลิก',
//   //                           style: TextStyle(
//   //                             color: Colors.white,
//   //                             fontWeight: FontWeight.bold,
//   //                             fontFamily: FontWeight_.Fonts_T,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     }),
//   //   );
//   // }

//   Future<dynamic> showcountmiter(int index) async {
//     var ser = quotxSelectModels[index].ele_ty;
//     if (electricityModels.isNotEmpty) {
//       electricityModels.clear();
//     }

//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var ren = preferences.getString('renTalSer');
//     String url =
//         '${MyConstant().domain}/GC_electricity.php?isAdd=true&ren=$ren';

//     try {
//       var response = await http.get(Uri.parse(url));

//       var result = json.decode(response.body);
//       //print(result);
//       if (result != null) {
//         for (var map in result) {
//           ElectricityModel electricityModel = ElectricityModel.fromJson(map);

//           if (electricityModel.ser == ser) {
//             setState(() {
//               electricityModels.add(electricityModel);
//             });
//           }
//         }
//       } else {}
//     } catch (e) {}
//   }

// ////////////------------------------------------------------------>(Export file)
//   Future<void> _showMyDialog_SAVE(
//       context, tableData00, newValuePDFimg, ren, type) async {
//     String _ReportValue_type_doc = "สัญญาระบบหลัก";
//     setState(() {
//       _ReportValue_type_doc =
//           '${typePaperModels.where((model) => model.ser.toString() == '${(cid_typePaper_ser.toString() == '0') ? 1 : cid_typePaper_ser}').map((model) => model.p_type).join(',')}';
//     });

//     // String _ReportValue_type_JSpace = "JSpace";
//     String _ReportValue_type_docOttor = "อาคารพาณิชย์";
//     // String _ReportValue_type_Choice = "สัญญาเช่าที่ดิน";
//     // String _ReportValue_type_Ama = "สัญญาเช่าพื้นที่";
//     // String _verticalGroupValue_NameFile = "จากระบบ";
//     String Value_Report = ' ';
//     String NameFile_ = '';
//     String Pre_and_Dow = '';
//     String? TitleType_Default_Receipt_Name;
//     final _formKey = GlobalKey<FormState>();
//     final FormNameFile_text = TextEditingController();
//     final Datex_text = TextEditingController();
//     final DatexChoice_Sub2_1text = TextEditingController(); //ประกันภัยอัคคีภัย
//     final DatexChoice_Sub2_2text =
//         TextEditingController(); //ภาษีที่ดินสิ่งปลูกสร้าง
//     final DatexChoice_Sub2_3text =
//         TextEditingController(); //ให้ผู้เช่าครอบครองวันที่
//     final Pri1_text = TextEditingController();
//     final Pri2_text = TextEditingController();
//     final Pri3_text = TextEditingController();

//     var date_x = DateTime.now();
//     var formatter = DateFormat('dd-MM-yyyy');
//     final FormName1_choice = TextEditingController();
//     final FormName2_choice = TextEditingController();
//     final FormName3_choice = TextEditingController();
//     final FormName4_choice = TextEditingController();
//     final FormPeriod_choice = TextEditingController();
//     setState(() {
//       Datex_text.text = "${formatter.format(date_x)}";
//       DatexChoice_Sub2_1text.text = "${formatter.format(date_x)}";
//       DatexChoice_Sub2_2text.text = "${formatter.format(date_x)}";
//       DatexChoice_Sub2_3text.text = "${formatter.format(date_x)}";
//       Pri1_text.text = '0.00';
//       Pri2_text.text = '0.00';
//       Pri3_text.text = '0.00';
//       if (ren.toString() == '106') {
//         FormName1_choice.text =
//             'นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญญู ตันตรานนท์';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = 'นางสาวชนิดาพร ส่งเจริญ';
//         FormName4_choice.text = '';
//       } else if (ren.toString() == '70') {
//         FormName1_choice.text = 'นางรัตนา  ตนานุวัฒน์';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = 'นางสาวชัญกาญจน์  คำฟู';
//         FormName4_choice.text = 'นางสาววารินทร์ สัมมาทิพย์';
//       } else if (ren.toString() == '151' || ren.toString() == '152') {
//         FormName1_choice.text = 'นายอัฐพล โพธิสุข';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = '';
//         FormName4_choice.text = '';
//       } else {
//         FormName1_choice.text = '';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = '';
//         FormName4_choice.text = '';
//       }

//       FormPeriod_choice.text = '${Form_period.text}';
//     });
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return StreamBuilder(
//           stream: Stream.periodic(const Duration(seconds: 0)),
//           builder: (context, snapshot) {
//             return Form(
//               key: _formKey,
//               child: AlertDialog(
//                 shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(15.0))),
//                 content: SingleChildScrollView(
//                   child: ListBody(
//                     children: <Widget>[
//                       SizedBox(height: 2),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: const Text(
//                           'วันที่ทำสัญญา :',
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: ReportScreen_Color.Colors_Text2_,
//                             // fontWeight: FontWeight.bold,
//                             fontFamily: Font_.Fonts_T,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: InkWell(
//                           onTap: () {
//                             Future<DateTime?> picked = showDatePicker(
//                               // locale: const Locale('th', 'TH'),
//                               helpText: 'เลือกวันที่',
//                               confirmText: 'ตกลง',
//                               cancelText: 'ยกเลิก',
//                               context: context,
//                               initialDate: DateTime(DateTime.now().year,
//                                   DateTime.now().month, DateTime.now().day - 1),
//                               initialDatePickerMode: DatePickerMode.day,
//                               firstDate: DateTime(2023, 1, 1),
//                               lastDate: DateTime(
//                                   DateTime.now().year,
//                                   DateTime.now().month,
//                                   DateTime.now().day + 100),
//                               // selectableDayPredicate: _decideWhichDayToEnable,
//                               builder: (context, child) {
//                                 return Theme(
//                                   data: Theme.of(context).copyWith(
//                                     colorScheme: const ColorScheme.light(
//                                       primary: AppBarColors
//                                           .ABar_Colors, // header background color
//                                       onPrimary:
//                                           Colors.white, // header text color
//                                       onSurface:
//                                           Colors.black, // body text color
//                                     ),
//                                     textButtonTheme: TextButtonThemeData(
//                                       style: TextButton.styleFrom(
//                                         primary:
//                                             Colors.black, // button text color
//                                       ),
//                                     ),
//                                   ),
//                                   child: child!,
//                                 );
//                               },
//                             );
//                             picked.then((result) {
//                               if (picked != null) {
//                                 // TransReBillModels = [];

//                                 var formatter = DateFormat('dd-MM-yyyy');
//                                 print("${formatter.format(result!)}");
//                                 setState(() {
//                                   Datex_text.text =
//                                       "${formatter.format(result)}";
//                                 });
//                               }
//                             });
//                           },
//                           child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppbackgroundColor.Sub_Abg_Colors,
//                                 borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(10),
//                                     topRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10)),
//                                 border:
//                                     Border.all(color: Colors.grey, width: 1),
//                               ),
//                               width: 200,
//                               padding: const EdgeInsets.all(8.0),
//                               child: Center(
//                                 child: Text(
//                                   (Datex_text.text == null)
//                                       ? 'เลือก'
//                                       : '${Datex_text.text}',
//                                   style: const TextStyle(
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               )),
//                         ),
//                       ),
//                       if (type.toString() == '1' &&
//                           (cid_typePaper_ser.toString() == '2' ||
//                               cid_typePaper_ser.toString() == '3') &&
//                           ren.toString() == '106')
//                         SizedBox(
//                           width: 320,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: const Text(
//                                   'ให้ผู้เช่าครอบครองวันที่',
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (type.toString() == '2' &&
//                           (cid_typePaper_ser.toString() == '2' ||
//                               cid_typePaper_ser.toString() == '3') &&
//                           ren.toString() == '106')
//                         SizedBox(
//                           width: 320,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: const Text(
//                                   'ประกันภัยอัคคีภัย',
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               ),
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: const Text(
//                                   'ภาษีที่ดินสิ่งปลูกสร้าง',
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (type.toString() == '1' &&
//                           (cid_typePaper_ser.toString() == '2' ||
//                               cid_typePaper_ser.toString() == '3') &&
//                           ren.toString() == '106')
//                         SizedBox(
//                           width: 320,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Future<DateTime?> picked = showDatePicker(
//                                       // locale: const Locale('th', 'TH'),
//                                       helpText: 'เลือกวันที่',
//                                       confirmText: 'ตกลง',
//                                       cancelText: 'ยกเลิก',
//                                       context: context,
//                                       initialDate: DateTime(
//                                           DateTime.now().year,
//                                           DateTime.now().month,
//                                           DateTime.now().day - 1),
//                                       initialDatePickerMode: DatePickerMode.day,
//                                       firstDate: DateTime(2023, 1, 1),
//                                       lastDate: DateTime(
//                                           DateTime.now().year,
//                                           DateTime.now().month,
//                                           DateTime.now().day + 100),
//                                       // selectableDayPredicate: _decideWhichDayToEnable,
//                                       builder: (context, child) {
//                                         return Theme(
//                                           data: Theme.of(context).copyWith(
//                                             colorScheme:
//                                                 const ColorScheme.light(
//                                               primary: AppBarColors
//                                                   .ABar_Colors, // header background color
//                                               onPrimary: Colors
//                                                   .white, // header text color
//                                               onSurface: Colors
//                                                   .black, // body text color
//                                             ),
//                                             textButtonTheme:
//                                                 TextButtonThemeData(
//                                               style: TextButton.styleFrom(
//                                                 primary: Colors
//                                                     .black, // button text color
//                                               ),
//                                             ),
//                                           ),
//                                           child: child!,
//                                         );
//                                       },
//                                     );
//                                     picked.then((result) {
//                                       if (picked != null) {
//                                         // TransReBillModels = [];

//                                         var formatter =
//                                             DateFormat('dd-MM-yyyy');
//                                         print("${formatter.format(result!)}");
//                                         setState(() {
//                                           DatexChoice_Sub2_3text.text =
//                                               "${formatter.format(result)}";
//                                         });
//                                       }
//                                     });
//                                   },
//                                   child: Container(
//                                       decoration: BoxDecoration(
//                                         color:
//                                             AppbackgroundColor.Sub_Abg_Colors,
//                                         borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                             bottomLeft: Radius.circular(10),
//                                             bottomRight: Radius.circular(10)),
//                                         border: Border.all(
//                                             color: Colors.grey, width: 1),
//                                       ),
//                                       width: 120,
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Center(
//                                         child: Text(
//                                           (DatexChoice_Sub2_3text.text == null)
//                                               ? 'เลือก'
//                                               : '${DatexChoice_Sub2_3text.text}',
//                                           style: const TextStyle(
//                                             color: ReportScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight: FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T,
//                                           ),
//                                         ),
//                                       )),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       if (type.toString() == '2' &&
//                           (cid_typePaper_ser.toString() == '2' ||
//                               cid_typePaper_ser.toString() == '3') &&
//                           ren.toString() == '106')
//                         SizedBox(
//                           width: 320,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Future<DateTime?> picked = showDatePicker(
//                                       // locale: const Locale('th', 'TH'),
//                                       helpText: 'เลือกวันที่',
//                                       confirmText: 'ตกลง',
//                                       cancelText: 'ยกเลิก',
//                                       context: context,
//                                       initialDate: DateTime(
//                                           DateTime.now().year,
//                                           DateTime.now().month,
//                                           DateTime.now().day - 1),
//                                       initialDatePickerMode: DatePickerMode.day,
//                                       firstDate: DateTime(2023, 1, 1),
//                                       lastDate: DateTime(
//                                           DateTime.now().year,
//                                           DateTime.now().month,
//                                           DateTime.now().day + 100),
//                                       // selectableDayPredicate: _decideWhichDayToEnable,
//                                       builder: (context, child) {
//                                         return Theme(
//                                           data: Theme.of(context).copyWith(
//                                             colorScheme:
//                                                 const ColorScheme.light(
//                                               primary: AppBarColors
//                                                   .ABar_Colors, // header background color
//                                               onPrimary: Colors
//                                                   .white, // header text color
//                                               onSurface: Colors
//                                                   .black, // body text color
//                                             ),
//                                             textButtonTheme:
//                                                 TextButtonThemeData(
//                                               style: TextButton.styleFrom(
//                                                 primary: Colors
//                                                     .black, // button text color
//                                               ),
//                                             ),
//                                           ),
//                                           child: child!,
//                                         );
//                                       },
//                                     );
//                                     picked.then((result) {
//                                       if (picked != null) {
//                                         // TransReBillModels = [];

//                                         var formatter =
//                                             DateFormat('dd-MM-yyyy');
//                                         print("${formatter.format(result!)}");
//                                         setState(() {
//                                           DatexChoice_Sub2_1text.text =
//                                               "${formatter.format(result)}";
//                                         });
//                                       }
//                                     });
//                                   },
//                                   child: Container(
//                                       decoration: BoxDecoration(
//                                         color:
//                                             AppbackgroundColor.Sub_Abg_Colors,
//                                         borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                             bottomLeft: Radius.circular(10),
//                                             bottomRight: Radius.circular(10)),
//                                         border: Border.all(
//                                             color: Colors.grey, width: 1),
//                                       ),
//                                       width: 120,
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Center(
//                                         child: Text(
//                                           (DatexChoice_Sub2_1text.text == null)
//                                               ? 'เลือก'
//                                               : '${DatexChoice_Sub2_1text.text}',
//                                           style: const TextStyle(
//                                             color: ReportScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight: FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T,
//                                           ),
//                                         ),
//                                       )),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Future<DateTime?> picked = showDatePicker(
//                                       // locale: const Locale('th', 'TH'),
//                                       helpText: 'เลือกวันที่',
//                                       confirmText: 'ตกลง',
//                                       cancelText: 'ยกเลิก',
//                                       context: context,
//                                       initialDate: DateTime(
//                                           DateTime.now().year,
//                                           DateTime.now().month,
//                                           DateTime.now().day - 1),
//                                       initialDatePickerMode: DatePickerMode.day,
//                                       firstDate: DateTime(2023, 1, 1),
//                                       lastDate: DateTime(
//                                           DateTime.now().year,
//                                           DateTime.now().month,
//                                           DateTime.now().day + 100),
//                                       // selectableDayPredicate: _decideWhichDayToEnable,
//                                       builder: (context, child) {
//                                         return Theme(
//                                           data: Theme.of(context).copyWith(
//                                             colorScheme:
//                                                 const ColorScheme.light(
//                                               primary: AppBarColors
//                                                   .ABar_Colors, // header background color
//                                               onPrimary: Colors
//                                                   .white, // header text color
//                                               onSurface: Colors
//                                                   .black, // body text color
//                                             ),
//                                             textButtonTheme:
//                                                 TextButtonThemeData(
//                                               style: TextButton.styleFrom(
//                                                 primary: Colors
//                                                     .black, // button text color
//                                               ),
//                                             ),
//                                           ),
//                                           child: child!,
//                                         );
//                                       },
//                                     );
//                                     picked.then((result) {
//                                       if (picked != null) {
//                                         // TransReBillModels = [];

//                                         var formatter =
//                                             DateFormat('dd-MM-yyyy');
//                                         print("${formatter.format(result!)}");
//                                         setState(() {
//                                           DatexChoice_Sub2_2text.text =
//                                               "${formatter.format(result)}";
//                                         });
//                                       }
//                                     });
//                                   },
//                                   child: Container(
//                                       decoration: BoxDecoration(
//                                         color:
//                                             AppbackgroundColor.Sub_Abg_Colors,
//                                         borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                             bottomLeft: Radius.circular(10),
//                                             bottomRight: Radius.circular(10)),
//                                         border: Border.all(
//                                             color: Colors.grey, width: 1),
//                                       ),
//                                       width: 120,
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Center(
//                                         child: Text(
//                                           (DatexChoice_Sub2_2text.text == null)
//                                               ? 'เลือก'
//                                               : '${DatexChoice_Sub2_2text.text}',
//                                           style: const TextStyle(
//                                             color: ReportScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight: FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T,
//                                           ),
//                                         ),
//                                       )),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       Column(
//                         children: [
//                           const Text(
//                             'รูปแบบ:',
//                             style: TextStyle(
//                               color: ReportScreen_Color.Colors_Text2_,
//                               // fontWeight: FontWeight.bold,
//                               fontFamily: Font_.Fonts_T,
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(15),
//                                 topRight: Radius.circular(15),
//                                 bottomLeft: Radius.circular(15),
//                                 bottomRight: Radius.circular(15),
//                               ),
//                               border: Border.all(color: Colors.grey, width: 1),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: RadioGroup<String>.builder(
//                               direction: Axis.horizontal,
//                               groupValue: _ReportValue_type_doc,
//                               horizontalAlignment:
//                                   MainAxisAlignment.spaceAround,
//                               onChanged: (value) {
//                                 // setState(() {
//                                 //   FormNameFile_text.clear();
//                                 // });
//                                 setState(() {
//                                   _ReportValue_type_doc = value ?? '';
//                                 });

//                                 // if (value == 'ไม่ระบุ') {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = null;
//                                 //   });
//                                 // } else {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = value;
//                                 //   });
//                                 // }
//                               },
//                               items: <String>[
//                                 '${_ReportValue_type_doc}',
//                               ],
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                               itemBuilder: (item) => RadioButtonBuilder(
//                                 item,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 2),

//                       ///Type_Choice
//                       if (ren.toString() == '102')
//                         Container(
//                             child: Column(
//                           children: [
//                             SizedBox(height: 2),
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: const Text(
//                                 'รูปแบบสัญญา อาม่า1000สุข. :',
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                   color: ReportScreen_Color.Colors_Text2_,
//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: const Text(
//                                 '20.อื่นๆ :',
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                   color: ReportScreen_Color.Colors_Text2_,
//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: TextFormField(
//                                 keyboardType: TextInputType.text,
//                                 controller: FormNameFile_text,

//                                 // maxLength: 13,
//                                 cursorColor: Colors.green,
//                                 decoration: InputDecoration(
//                                     fillColor: Colors.white.withOpacity(0.3),
//                                     filled: true,
//                                     focusedBorder: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.only(
//                                         topRight: Radius.circular(15),
//                                         topLeft: Radius.circular(15),
//                                         bottomRight: Radius.circular(15),
//                                         bottomLeft: Radius.circular(15),
//                                       ),
//                                       borderSide: BorderSide(
//                                         width: 1,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                     errorStyle:
//                                         TextStyle(fontFamily: Font_.Fonts_T),
//                                     enabledBorder: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.only(
//                                         topRight: Radius.circular(15),
//                                         topLeft: Radius.circular(15),
//                                         bottomRight: Radius.circular(15),
//                                         bottomLeft: Radius.circular(15),
//                                       ),
//                                       borderSide: BorderSide(
//                                         width: 1,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                     // labelText:
//                                     //     'วางเงินประกันตลอดอายุสัญญาเช่า : ',
//                                     labelStyle: const TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.black54,
//                                         fontFamily: Font_.Fonts_T)),
//                                 // inputFormatters: [
//                                 //   FilteringTextInputFormatter.deny(
//                                 //       RegExp(r'\s')),
//                                 //   // FilteringTextInputFormatter.deny(
//                                 //   //     RegExp(r'^0')),
//                                 //   FilteringTextInputFormatter.allow(
//                                 //       RegExp(r'[0-9 .]')),
//                                 // ],
//                               ),
//                             ),
//                             SizedBox(height: 2),
//                           ],
//                         )),
//                       if (ren.toString() == '90')
//                         if (type == 1)
//                           Column(
//                             children: [
//                               SizedBox(height: 2),
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: const Text(
//                                   'รูปแบบสัญญา JSpace. :',
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(15),
//                                     topRight: Radius.circular(15),
//                                     bottomLeft: Radius.circular(15),
//                                     bottomRight: Radius.circular(15),
//                                   ),
//                                   border:
//                                       Border.all(color: Colors.grey, width: 1),
//                                 ),
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: const Text(
//                                         'อัตราค่าเช่าเดือนละ :',
//                                         textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                           color:
//                                               ReportScreen_Color.Colors_Text2_,
//                                           // fontWeight: FontWeight.bold,
//                                           fontFamily: Font_.Fonts_T,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: TextFormField(
//                                         keyboardType: TextInputType.number,
//                                         controller: Pri1_text,

//                                         // maxLength: 13,
//                                         cursorColor: Colors.green,
//                                         decoration: InputDecoration(
//                                           fillColor:
//                                               Colors.white.withOpacity(0.3),
//                                           filled: true,
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               topLeft: Radius.circular(15),
//                                               bottomRight: Radius.circular(15),
//                                               bottomLeft: Radius.circular(15),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           errorStyle: TextStyle(
//                                               fontFamily: Font_.Fonts_T),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               topLeft: Radius.circular(15),
//                                               bottomRight: Radius.circular(15),
//                                               bottomLeft: Radius.circular(15),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                           labelStyle: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.black54,
//                                               fontFamily: Font_.Fonts_T),
//                                         ),
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.deny(
//                                               RegExp(r'\s')),
//                                           // FilteringTextInputFormatter.deny(
//                                           //     RegExp(r'^0')),
//                                           FilteringTextInputFormatter.allow(
//                                               RegExp(r'[0-9 .]')),
//                                         ],
//                                       ),
//                                     ),
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: const Text(
//                                         'วางเงินประกันตลอดอายุสัญญาเช่า :',
//                                         textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                           color:
//                                               ReportScreen_Color.Colors_Text2_,
//                                           // fontWeight: FontWeight.bold,
//                                           fontFamily: Font_.Fonts_T,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: TextFormField(
//                                         keyboardType: TextInputType.number,
//                                         controller: Pri2_text,

//                                         // maxLength: 13,
//                                         cursorColor: Colors.green,
//                                         decoration: InputDecoration(
//                                             fillColor:
//                                                 Colors.white.withOpacity(0.3),
//                                             filled: true,
//                                             focusedBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.only(
//                                                 topRight: Radius.circular(15),
//                                                 topLeft: Radius.circular(15),
//                                                 bottomRight:
//                                                     Radius.circular(15),
//                                                 bottomLeft: Radius.circular(15),
//                                               ),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             errorStyle: TextStyle(
//                                                 fontFamily: Font_.Fonts_T),
//                                             enabledBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.only(
//                                                 topRight: Radius.circular(15),
//                                                 topLeft: Radius.circular(15),
//                                                 bottomRight:
//                                                     Radius.circular(15),
//                                                 bottomLeft: Radius.circular(15),
//                                               ),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             // labelText:
//                                             //     'วางเงินประกันตลอดอายุสัญญาเช่า : ',
//                                             labelStyle: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.black54,
//                                                 fontFamily: Font_.Fonts_T)),
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.deny(
//                                               RegExp(r'\s')),
//                                           // FilteringTextInputFormatter.deny(
//                                           //     RegExp(r'^0')),
//                                           FilteringTextInputFormatter.allow(
//                                               RegExp(r'[0-9 .]')),
//                                         ],
//                                       ),
//                                     ),
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: const Text(
//                                         'ผู้เช่าต้องชำระค่าส่วนกลางต่อเดือน :',
//                                         textAlign: TextAlign.left,
//                                         style: TextStyle(
//                                           color:
//                                               ReportScreen_Color.Colors_Text2_,
//                                           // fontWeight: FontWeight.bold,
//                                           fontFamily: Font_.Fonts_T,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: TextFormField(
//                                         keyboardType: TextInputType.number,
//                                         controller: Pri3_text,

//                                         // maxLength: 13,
//                                         cursorColor: Colors.green,
//                                         decoration: InputDecoration(
//                                             fillColor:
//                                                 Colors.white.withOpacity(0.3),
//                                             filled: true,
//                                             focusedBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.only(
//                                                 topRight: Radius.circular(15),
//                                                 topLeft: Radius.circular(15),
//                                                 bottomRight:
//                                                     Radius.circular(15),
//                                                 bottomLeft: Radius.circular(15),
//                                               ),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             errorStyle: TextStyle(
//                                                 fontFamily: Font_.Fonts_T),
//                                             enabledBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.only(
//                                                 topRight: Radius.circular(15),
//                                                 topLeft: Radius.circular(15),
//                                                 bottomRight:
//                                                     Radius.circular(15),
//                                                 bottomLeft: Radius.circular(15),
//                                               ),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             // labelText:
//                                             //     'ผู้เช่าต้องชำระค่าส่วนกลางต่อเดือน : ',
//                                             labelStyle: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.black54,
//                                                 fontFamily: Font_.Fonts_T)),
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.deny(
//                                               RegExp(r'\s')),
//                                           // FilteringTextInputFormatter.deny(
//                                           //     RegExp(r'^0')),
//                                           FilteringTextInputFormatter.allow(
//                                               RegExp(r'[0-9 .]')),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                       const Text(
//                         'หัวบิล :',
//                         style: TextStyle(
//                           color: ReportScreen_Color.Colors_Text2_,
//                           // fontWeight: FontWeight.bold,
//                           fontFamily: Font_.Fonts_T,
//                         ),
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.3),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(15),
//                             topRight: Radius.circular(15),
//                             bottomLeft: Radius.circular(15),
//                             bottomRight: Radius.circular(15),
//                           ),
//                           border: Border.all(color: Colors.grey, width: 1),
//                         ),
//                         padding: const EdgeInsets.all(8.0),
//                         child: RadioGroup<String>.builder(
//                           direction: Axis.vertical,
//                           // direction: Axis.horizontal,
//                           groupValue: _ReportValue_type,
//                           horizontalAlignment: MainAxisAlignment.center,
//                           onChanged: (value) {
//                             // setState(() {
//                             //   FormNameFile_text.clear();
//                             // });
//                             setState(() {
//                               _ReportValue_type = value ?? '';
//                             });

//                             if (value == 'ไม่ระบุ') {
//                               setState(() {
//                                 TitleType_Default_Receipt_Name = null;
//                               });
//                             } else {
//                               setState(() {
//                                 TitleType_Default_Receipt_Name = value;
//                               });
//                             }
//                           },
//                           items: const <String>[
//                             'ไม่ระบุ',
//                             'ต้นฉบับ',
//                             'คู่ฉบับ',
//                             'สำเนา',
//                             'สำเนาคู่ฉบับ',
//                           ],
//                           textStyle: const TextStyle(
//                             fontSize: 15,
//                             color: ReportScreen_Color.Colors_Text2_,
//                             // fontWeight: FontWeight.bold,
//                             fontFamily: Font_.Fonts_T,
//                           ),
//                           itemBuilder: (item) => RadioButtonBuilder(
//                             item,
//                           ),
//                         ),
//                       ),
//                       // if (ren.toString() == '106' || ren.toString() == '70')
//                       Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'ระยะเวลาเช่า',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 300,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 2,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(4.0),
//                                     child: Container(
//                                       // width: 150,
//                                       child: TextFormField(
//                                         keyboardType: TextInputType.number,
//                                         controller: FormPeriod_choice,

//                                         // maxLength: 13,
//                                         cursorColor: Colors.green,
//                                         decoration: InputDecoration(
//                                           fillColor:
//                                               Colors.white.withOpacity(0.3),
//                                           filled: true,
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(8),
//                                               topLeft: Radius.circular(8),
//                                               bottomRight: Radius.circular(8),
//                                               bottomLeft: Radius.circular(8),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           errorStyle: TextStyle(
//                                               fontFamily: Font_.Fonts_T),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(8),
//                                               topLeft: Radius.circular(8),
//                                               bottomRight: Radius.circular(8),
//                                               bottomLeft: Radius.circular(8),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                           labelStyle: const TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.black54,
//                                               fontFamily: Font_.Fonts_T),
//                                         ),
//                                         style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.black,
//                                             fontFamily: Font_.Fonts_T),
//                                         // inputFormatters: [
//                                         //   FilteringTextInputFormatter.deny(
//                                         //       RegExp(r'\s')),
//                                         //   // FilteringTextInputFormatter.deny(
//                                         //   //     RegExp(r'^0')),
//                                         //   FilteringTextInputFormatter.allow(
//                                         //       RegExp(r'[0-9 .]')),
//                                         // ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Text(
//                                     '${Form_rtname.text}',
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                         color: PeopleChaoScreen_Color
//                                             .Colors_Text2_,
//                                         //fontWeight: FontWeight.bold,
//                                         fontFamily: Font_.Fonts_T),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'ผู้ใช้เช่า',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Container(
//                                   width: 300,
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: FormName1_choice,

//                                     // maxLength: 13,
//                                     cursorColor: Colors.green,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.white.withOpacity(0.3),
//                                       filled: true,
//                                       focusedBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       errorStyle:
//                                           TextStyle(fontFamily: Font_.Fonts_T),
//                                       enabledBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                       labelStyle: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.black54,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                         fontFamily: Font_.Fonts_T),
//                                     // inputFormatters: [
//                                     //   FilteringTextInputFormatter.deny(
//                                     //       RegExp(r'\s')),
//                                     //   // FilteringTextInputFormatter.deny(
//                                     //   //     RegExp(r'^0')),
//                                     //   FilteringTextInputFormatter.allow(
//                                     //       RegExp(r'[0-9 .]')),
//                                     // ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'พยาน1 / พยาน2',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Container(
//                                   width: 150,
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: FormName3_choice,

//                                     // maxLength: 13,
//                                     cursorColor: Colors.green,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.white.withOpacity(0.3),
//                                       filled: true,
//                                       focusedBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       errorStyle:
//                                           TextStyle(fontFamily: Font_.Fonts_T),
//                                       enabledBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                       labelStyle: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.black54,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                         fontFamily: Font_.Fonts_T),
//                                     // inputFormatters: [
//                                     //   FilteringTextInputFormatter.deny(
//                                     //       RegExp(r'\s')),
//                                     //   // FilteringTextInputFormatter.deny(
//                                     //   //     RegExp(r'^0')),
//                                     //   FilteringTextInputFormatter.allow(
//                                     //       RegExp(r'[0-9 .]')),
//                                     // ],
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Container(
//                                   width: 150,
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: FormName4_choice,

//                                     // maxLength: 13,
//                                     cursorColor: Colors.green,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.white.withOpacity(0.3),
//                                       filled: true,
//                                       focusedBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       errorStyle:
//                                           TextStyle(fontFamily: Font_.Fonts_T),
//                                       enabledBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                       labelStyle: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.black54,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                         fontFamily: Font_.Fonts_T),
//                                     // inputFormatters: [
//                                     //   FilteringTextInputFormatter.deny(
//                                     //       RegExp(r'\s')),
//                                     //   // FilteringTextInputFormatter.deny(
//                                     //   //     RegExp(r'^0')),
//                                     //   FilteringTextInputFormatter.allow(
//                                     //       RegExp(r'[0-9 .]')),
//                                     // ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(8, 3, 2, 2),
//                             child: Text(
//                               '🖨 พิมพ์แล้ว : ${(paper_run == null) ? 0 : paper_run} ครั้ง',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 actions: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: InkWell(
//                           onTap: () async {
//                             SharedPreferences preferences =
//                                 await SharedPreferences.getInstance();
//                             preferences.setString(
//                                 'Name1_choice', '${FormName1_choice.text}');
//                             // preferences.setString(
//                             //     'Name2_choice', '${FormName2_choice.text}');
//                             preferences.setString(
//                                 'Name3_choice', '${FormName3_choice.text}');
//                             preferences.setString(
//                                 'Name4_choice', '${FormName4_choice.text}');
//                             // //print('Man_Agreement_PDF');
//                             Man_Agreement_PDF.ManAgreement_PDF(
//                                 context,
//                                 type,
//                                 _ReportValue_type_docOttor,
//                                 '${widget.Get_Value_NameShop_index}',
//                                 '${widget.Get_Value_cid}',
//                                 _verticalGroupValue,
//                                 Form_nameshop.text,
//                                 Form_typeshop.text,
//                                 Form_bussshop.text,
//                                 Form_bussscontact.text,
//                                 Form_address.text,
//                                 Form_tel.text,
//                                 Form_email.text,
//                                 Form_tax.text,
//                                 Form_ln.text,
//                                 Form_zn.text,
//                                 Form_area.text,
//                                 Form_qty.text,
//                                 Form_sdate.text,
//                                 Form_ldate.text,
//                                 Form_period.text,
//                                 Form_rtname.text,
//                                 // quotxSelectModels,
//                                 _TransModels,
//                                 '$renTal_name',
//                                 '${renTalModels[0].bill_addr}',
//                                 '${renTalModels[0].bill_email}',
//                                 '${renTalModels[0].bill_tel}',
//                                 '${renTalModels[0].bill_tax}',
//                                 '${renTalModels[0].bill_name}',
//                                 newValuePDFimg,
//                                 tableData00,
//                                 TitleType_Default_Receipt_Name,
//                                 Datex_text,
//                                 Form_fid.text,
//                                 Form_renew_cid.text,
//                                 Form_PakanSdate.text,
//                                 Form_PakanLdate.text,
//                                 Form_PakanSdate_Doc.text,
//                                 Form_PakanLdate_Doc.text,
//                                 Form_PakanAll_amt.text,
//                                 Form_PakanAll_pvat.text,
//                                 Form_PakanAll_vat.text,
//                                 Form_PakanAll_Total.text,
//                                 Form_PakanAll_Total_bill.text,
//                                 Form_PakanAll_amt_first.text,
//                                 Form_PakanAll_pvat_first.text,
//                                 Form_PakanAll_vat_first.text,
//                                 Form_PakanAll_Total_first.text,
//                                 Pri1_text,
//                                 Pri2_text,
//                                 Pri3_text,
//                                 FormNameFile_text,
//                                 '${MyConstant().domain}/files/$foder/contract/${renTalModels[0].img}',
//                                 '${MyConstant().domain}/files/$foder/contract/${renTalModels[0].imglogo}',
//                                 _ReportValue_type_doc,
//                                 cid_typePaper_ser,
//                                 Form_wnote.text.toString(),
//                                 '${paper_run}',
//                                 FormPeriod_choice.text,
//                                 Form_renew_datex.text,
//                                 Form_renew_sdate.text,
//                                 Form_renew_ldate.text,
//                                 DatexChoice_Sub2_1text.text,
//                                 DatexChoice_Sub2_2text.text,
//                                 DatexChoice_Sub2_3text.text,
//                                 Title_text.text,
//                                 Details_text.text,
//                                 FormName1_choice.text,
//                                 FormName2_choice.text,
//                                 FormName3_choice.text,
//                                 FormName4_choice.text,
//                                 '');
//                           },
//                           child: Container(
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
//                             child: Center(
//                               child: Text(
//                                 'พิมพ์',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   //fontWeight: FontWeight.bold, color:

//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: InkWell(
//                           onTap: () => Navigator.pop(context, 'OK'),
//                           child: Container(
//                             width: 100,
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Text(
//                                 'ปิด',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   //fontWeight: FontWeight.bold, color:

//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

// ////////////------------------------------------------------------>(Export file)
//   Future<void> _showMyDialog_SAVE3(context, newValuePDFimg, ren) async {
//     String _ReportValue_type_doc = "สัญญาระบบหลัก";
//     setState(() {
//       _ReportValue_type_doc =
//           '${typePaperModels.where((model) => model.ser.toString() == '${(cid_typePaper_ser.toString() == '0') ? 1 : cid_typePaper_ser}').map((model) => model.p_type).join(',')}';
//     });

//     // String _ReportValue_type_JSpace = "JSpace";
//     String _ReportValue_type_docOttor = "อาคารพาณิชย์";
//     // String _ReportValue_type_Choice = "สัญญาเช่าที่ดิน";
//     // String _ReportValue_type_Ama = "สัญญาเช่าพื้นที่";
//     // String _verticalGroupValue_NameFile = "จากระบบ";
//     String Value_Report = ' ';
//     String NameFile_ = '';
//     String Pre_and_Dow = '';
//     String? TitleType_Default_Receipt_Name;
//     final _formKey = GlobalKey<FormState>();
//     final FormNameFile_text = TextEditingController();
//     final Datex_text = TextEditingController();
//     final DatexChoice_Sub2_1text = TextEditingController(); //ประกันภัยอัคคีภัย
//     final DatexChoice_Sub2_2text =
//         TextEditingController(); //ภาษีที่ดินสิ่งปลูกสร้าง
//     final DatexChoice_Sub2_3text =
//         TextEditingController(); //ให้ผู้เช่าครอบครองวันที่
//     final Pri1_text = TextEditingController();
//     final Pri2_text = TextEditingController();
//     final Pri3_text = TextEditingController();

//     var date_x = DateTime.now();
//     var formatter = DateFormat('dd-MM-yyyy');
//     final FormName1_choice = TextEditingController();
//     final FormName2_choice = TextEditingController();
//     final FormName3_choice = TextEditingController();
//     final FormName4_choice = TextEditingController();
//     final FormPeriod_choice = TextEditingController();
//     setState(() {
//       Datex_text.text = "${formatter.format(date_x)}";
//       DatexChoice_Sub2_1text.text = "${formatter.format(date_x)}";
//       DatexChoice_Sub2_2text.text = "${formatter.format(date_x)}";
//       DatexChoice_Sub2_3text.text = "${formatter.format(date_x)}";
//       Pri1_text.text = '0.00';
//       Pri2_text.text = '0.00';
//       Pri3_text.text = '0.00';
//       if (ren.toString() == '106') {
//         FormName1_choice.text =
//             'นางฤทัยรัตน์ วิสิทธิ์ และ นายวธัญญู ตันตรานนท์';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = 'นางสาวชนิดาพร ส่งเจริญ';
//         FormName4_choice.text = '';
//       } else if (ren.toString() == '70') {
//         FormName1_choice.text = 'นางรัตนา  ตนานุวัฒน์';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = 'นางสาวชัญกาญจน์  คำฟู';
//         FormName4_choice.text = 'นางสาววารินทร์ สัมมาทิพย์';
//       } else {
//         FormName1_choice.text = '';
//         FormName2_choice.text = '${Form_bussshop.text}';
//         FormName3_choice.text = '';
//         FormName4_choice.text = '';
//       }

//       FormPeriod_choice.text = '${Form_period.text}';
//     });
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return StreamBuilder(
//           stream: Stream.periodic(const Duration(seconds: 0)),
//           builder: (context, snapshot) {
//             return Form(
//               key: _formKey,
//               child: AlertDialog(
//                 shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(15.0))),
//                 content: SingleChildScrollView(
//                   child: ListBody(
//                     children: <Widget>[
//                       SizedBox(height: 2),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: const Text(
//                           'วันที่ทำสัญญา :',
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: ReportScreen_Color.Colors_Text2_,
//                             // fontWeight: FontWeight.bold,
//                             fontFamily: Font_.Fonts_T,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: InkWell(
//                           onTap: () {
//                             Future<DateTime?> picked = showDatePicker(
//                               // locale: const Locale('th', 'TH'),
//                               helpText: 'เลือกวันที่',
//                               confirmText: 'ตกลง',
//                               cancelText: 'ยกเลิก',
//                               context: context,
//                               initialDate: DateTime(DateTime.now().year,
//                                   DateTime.now().month, DateTime.now().day - 1),
//                               initialDatePickerMode: DatePickerMode.day,
//                               firstDate: DateTime(2023, 1, 1),
//                               lastDate: DateTime(
//                                   DateTime.now().year,
//                                   DateTime.now().month,
//                                   DateTime.now().day + 100),
//                               // selectableDayPredicate: _decideWhichDayToEnable,
//                               builder: (context, child) {
//                                 return Theme(
//                                   data: Theme.of(context).copyWith(
//                                     colorScheme: const ColorScheme.light(
//                                       primary: AppBarColors
//                                           .ABar_Colors, // header background color
//                                       onPrimary:
//                                           Colors.white, // header text color
//                                       onSurface:
//                                           Colors.black, // body text color
//                                     ),
//                                     textButtonTheme: TextButtonThemeData(
//                                       style: TextButton.styleFrom(
//                                         primary:
//                                             Colors.black, // button text color
//                                       ),
//                                     ),
//                                   ),
//                                   child: child!,
//                                 );
//                               },
//                             );
//                             picked.then((result) {
//                               if (picked != null) {
//                                 // TransReBillModels = [];

//                                 var formatter = DateFormat('dd-MM-yyyy');
//                                 print("${formatter.format(result!)}");
//                                 setState(() {
//                                   Datex_text.text =
//                                       "${formatter.format(result)}";
//                                 });
//                               }
//                             });
//                           },
//                           child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppbackgroundColor.Sub_Abg_Colors,
//                                 borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(10),
//                                     topRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10)),
//                                 border:
//                                     Border.all(color: Colors.grey, width: 1),
//                               ),
//                               width: 200,
//                               padding: const EdgeInsets.all(8.0),
//                               child: Center(
//                                 child: Text(
//                                   (Datex_text.text == null)
//                                       ? 'เลือก'
//                                       : '${Datex_text.text}',
//                                   style: const TextStyle(
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                 ),
//                               )),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           const Text(
//                             'รูปแบบ:',
//                             style: TextStyle(
//                               color: ReportScreen_Color.Colors_Text2_,
//                               // fontWeight: FontWeight.bold,
//                               fontFamily: Font_.Fonts_T,
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(15),
//                                 topRight: Radius.circular(15),
//                                 bottomLeft: Radius.circular(15),
//                                 bottomRight: Radius.circular(15),
//                               ),
//                               border: Border.all(color: Colors.grey, width: 1),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: RadioGroup<String>.builder(
//                               direction: Axis.horizontal,
//                               groupValue: _ReportValue_type_doc,
//                               horizontalAlignment:
//                                   MainAxisAlignment.spaceAround,
//                               onChanged: (value) {
//                                 // setState(() {
//                                 //   FormNameFile_text.clear();
//                                 // });
//                                 setState(() {
//                                   _ReportValue_type_doc = value ?? '';
//                                 });

//                                 // if (value == 'ไม่ระบุ') {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = null;
//                                 //   });
//                                 // } else {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = value;
//                                 //   });
//                                 // }
//                               },
//                               items: <String>[
//                                 '${_ReportValue_type_doc}',
//                               ],
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                               itemBuilder: (item) => RadioButtonBuilder(
//                                 item,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 2),
//                       const Text(
//                         'หัวบิล :',
//                         style: TextStyle(
//                           color: ReportScreen_Color.Colors_Text2_,
//                           // fontWeight: FontWeight.bold,
//                           fontFamily: Font_.Fonts_T,
//                         ),
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.3),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(15),
//                             topRight: Radius.circular(15),
//                             bottomLeft: Radius.circular(15),
//                             bottomRight: Radius.circular(15),
//                           ),
//                           border: Border.all(color: Colors.grey, width: 1),
//                         ),
//                         padding: const EdgeInsets.all(8.0),
//                         child: RadioGroup<String>.builder(
//                           direction: Axis.vertical,
//                           // direction: Axis.horizontal,
//                           groupValue: _ReportValue_type,
//                           horizontalAlignment: MainAxisAlignment.center,
//                           onChanged: (value) {
//                             // setState(() {
//                             //   FormNameFile_text.clear();
//                             // });
//                             setState(() {
//                               _ReportValue_type = value ?? '';
//                             });

//                             if (value == 'ไม่ระบุ') {
//                               setState(() {
//                                 TitleType_Default_Receipt_Name = null;
//                               });
//                             } else {
//                               setState(() {
//                                 TitleType_Default_Receipt_Name = value;
//                               });
//                             }
//                           },
//                           items: const <String>[
//                             'ไม่ระบุ',
//                             'ต้นฉบับ',
//                             'คู่ฉบับ',
//                             'สำเนา',
//                             'สำเนาคู่ฉบับ',
//                           ],
//                           textStyle: const TextStyle(
//                             fontSize: 15,
//                             color: ReportScreen_Color.Colors_Text2_,
//                             // fontWeight: FontWeight.bold,
//                             fontFamily: Font_.Fonts_T,
//                           ),
//                           itemBuilder: (item) => RadioButtonBuilder(
//                             item,
//                           ),
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'ผู้ใช้เช่า',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Container(
//                                   width: 300,
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: FormName1_choice,

//                                     // maxLength: 13,
//                                     cursorColor: Colors.green,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.white.withOpacity(0.3),
//                                       filled: true,
//                                       focusedBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       errorStyle:
//                                           TextStyle(fontFamily: Font_.Fonts_T),
//                                       enabledBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                       labelStyle: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.black54,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                         fontFamily: Font_.Fonts_T),
//                                     // inputFormatters: [
//                                     //   FilteringTextInputFormatter.deny(
//                                     //       RegExp(r'\s')),
//                                     //   // FilteringTextInputFormatter.deny(
//                                     //   //     RegExp(r'^0')),
//                                     //   FilteringTextInputFormatter.allow(
//                                     //       RegExp(r'[0-9 .]')),
//                                     // ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'พยาน1 / พยาน2',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Container(
//                                   width: 150,
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: FormName3_choice,

//                                     // maxLength: 13,
//                                     cursorColor: Colors.green,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.white.withOpacity(0.3),
//                                       filled: true,
//                                       focusedBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       errorStyle:
//                                           TextStyle(fontFamily: Font_.Fonts_T),
//                                       enabledBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                       labelStyle: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.black54,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                         fontFamily: Font_.Fonts_T),
//                                     // inputFormatters: [
//                                     //   FilteringTextInputFormatter.deny(
//                                     //       RegExp(r'\s')),
//                                     //   // FilteringTextInputFormatter.deny(
//                                     //   //     RegExp(r'^0')),
//                                     //   FilteringTextInputFormatter.allow(
//                                     //       RegExp(r'[0-9 .]')),
//                                     // ],
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Container(
//                                   width: 150,
//                                   child: TextFormField(
//                                     keyboardType: TextInputType.number,
//                                     controller: FormName4_choice,

//                                     // maxLength: 13,
//                                     cursorColor: Colors.green,
//                                     decoration: InputDecoration(
//                                       fillColor: Colors.white.withOpacity(0.3),
//                                       filled: true,
//                                       focusedBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       errorStyle:
//                                           TextStyle(fontFamily: Font_.Fonts_T),
//                                       enabledBorder: const OutlineInputBorder(
//                                         borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(8),
//                                           topLeft: Radius.circular(8),
//                                           bottomRight: Radius.circular(8),
//                                           bottomLeft: Radius.circular(8),
//                                         ),
//                                         borderSide: BorderSide(
//                                           width: 1,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                       labelStyle: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.black54,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                     style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.black,
//                                         fontFamily: Font_.Fonts_T),
//                                     // inputFormatters: [
//                                     //   FilteringTextInputFormatter.deny(
//                                     //       RegExp(r'\s')),
//                                     //   // FilteringTextInputFormatter.deny(
//                                     //   //     RegExp(r'^0')),
//                                     //   FilteringTextInputFormatter.allow(
//                                     //       RegExp(r'[0-9 .]')),
//                                     // ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // Padding(
//                           //   padding: const EdgeInsets.fromLTRB(8, 3, 2, 2),
//                           //   child: Text(
//                           //     '🖨 พิมพ์แล้ว : ${(paper_run == null) ? 0 : paper_run} ครั้ง',
//                           //     style: TextStyle(
//                           //       fontSize: 14,
//                           //       color: ReportScreen_Color.Colors_Text2_,
//                           //       // fontWeight: FontWeight.bold,
//                           //       fontFamily: Font_.Fonts_T,
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 actions: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: InkWell(
//                           onTap: () async {
//                             Pdfgen_Agreement3.exportPDF_Agreement3(
//                                 context,
//                                 '${widget.Get_Value_NameShop_index}',
//                                 '${widget.Get_Value_cid}',
//                                 _verticalGroupValue,
//                                 Form_nameshop.text,
//                                 Form_typeshop.text,
//                                 Form_bussshop.text,
//                                 Form_bussscontact.text,
//                                 Form_address.text,
//                                 Form_tel.text,
//                                 Form_email.text,
//                                 Form_tax.text,
//                                 Form_ln.text,
//                                 Form_zn.text,
//                                 Form_area.text,
//                                 Form_qty.text,
//                                 Form_sdate.text,
//                                 Form_ldate.text,
//                                 Form_period.text,
//                                 Form_rtname.text,
//                                 Form_cdate.text,
//                                 quotxSelectModels2,
//                                 _TransModels,
//                                 '$renTal_name',
//                                 ' ${renTalModels[0].bill_addr}',
//                                 ' ${renTalModels[0].bill_email}',
//                                 ' ${renTalModels[0].bill_tel}',
//                                 ' ${renTalModels[0].bill_tax}',
//                                 ' ${renTalModels[0].bill_name}',
//                                 newValuePDFimg,
//                                 TitleType_Default_Receipt_Name,
//                                 Datex_text,
//                                 FormName1_choice.text,
//                                 FormName2_choice.text,
//                                 FormName3_choice.text,
//                                 FormName4_choice.text,
//                                 renTal_user);
//                           },
//                           child: Container(
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
//                             child: Center(
//                               child: Text(
//                                 'พิมพ์',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   //fontWeight: FontWeight.bold, color:

//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: InkWell(
//                           onTap: () => Navigator.pop(context, 'OK'),
//                           child: Container(
//                             width: 100,
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Text(
//                                 'ปิด',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   //fontWeight: FontWeight.bold, color:

//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         // color: Colors.red,
//         width: MediaQuery.of(context).size.width,
//         decoration: const BoxDecoration(
//           // color: AppbackgroundColor.Sub_Abg_Colors,
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(10),
//               bottomLeft: Radius.circular(10),
//               bottomRight: Radius.circular(10)),
//         ),
//         padding: const EdgeInsets.all(2.0),
//         child: Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   colorFilter: new ColorFilter.mode(
//                       Colors.white.withOpacity(0.05), BlendMode.dstATop),
//                   image: AssetImage("images/BG_im.png"),
//                   fit: BoxFit.cover,
//                 ),
//                 color: AppbackgroundColor.Sub_Abg_Colors,
//                 borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(6),
//                     topRight: Radius.circular(6),
//                     bottomLeft: Radius.circular(0),
//                     bottomRight: Radius.circular(0)),
//                 // border: Border.all(color: Colors.white, width: 1),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children:
//                             List.generate(data_picperson.length, (index_pic) {
//                           final url = data_picperson[index_pic]['url'];
//                           final title = data_picperson[index_pic]['title'];
//                           final detailKey = data_picperson[index_pic]['detail'];
//                           final img = data_picperson[index_pic]['img'];

//                           return Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(16),
//                               onTap: () {
//                                 setState(() {
//                                   fiew = detailKey;
//                                 });
//                                 uploadImage(ImageSource.gallery);
//                               },
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     width: 280,
//                                     height: 170,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(16),
//                                       color: Colors.grey[200],
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color:
//                                               Colors.black12.withOpacity(0.1),
//                                           blurRadius: 8,
//                                           spreadRadius: 1,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                       image: (img != null && img.isNotEmpty)
//                                           ? DecorationImage(
//                                               image: NetworkImage(url!),
//                                               // fit: BoxFit.fitHeight,
//                                             )
//                                           : null,
//                                     ),
//                                     child: (img == null || img.isEmpty)
//                                         ? Container(
//                                             decoration: BoxDecoration(
//                                               image: DecorationImage(
//                                                 colorFilter:
//                                                     new ColorFilter.mode(
//                                                         Colors.white
//                                                             .withOpacity(0.05),
//                                                         BlendMode.dstATop),
//                                                 image: AssetImage(
//                                                     "images/BG_im.png"),
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                             child: Center(
//                                               child: Column(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: const [
//                                                   Icon(Icons.upload_rounded,
//                                                       size: 48,
//                                                       color: Colors.grey),
//                                                   SizedBox(height: 8),
//                                                   Text(
//                                                     "ยังไม่ได้เลือกรูป",
//                                                     style: TextStyle(
//                                                       color: Colors.grey,
//                                                       fontFamily: Font_.Fonts_T,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 4),
//                                                   Text(
//                                                     "รองรับ JPG / PNG\nขนาดไม่เกิน 10MB\n280X180",
//                                                     textAlign: TextAlign.center,
//                                                     style: TextStyle(
//                                                       fontSize: 11,
//                                                       color: Colors.grey,
//                                                       fontFamily: Font_.Fonts_T,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           )
//                                         : Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(16),
//                                               gradient: LinearGradient(
//                                                 colors: [
//                                                   Colors.black.withOpacity(0.1),
//                                                   Colors.black.withOpacity(0.3),
//                                                 ],
//                                                 begin: Alignment.topCenter,
//                                                 end: Alignment.bottomCenter,
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     title ?? '',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                       fontFamily: FontWeight_.Fonts_T,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: InkWell(
//                           onTap: () {
//                             // _generatePdf();
//                           },
//                           child: const AutoSizeText(
//                             minFontSize: 10,
//                             maxFontSize: 15,
//                             '1.ข้อมูลผู้เช่า',
//                             style: TextStyle(
//                                 color: PeopleChaoScreen_Color.Colors_Text1_,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: FontWeight_.Fonts_T),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'ประเภท',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 2,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.3),
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(6),
//                                   topRight: Radius.circular(6),
//                                   bottomLeft: Radius.circular(6),
//                                   bottomRight: Radius.circular(6),
//                                 ),
//                                 border:
//                                     Border.all(color: Colors.grey, width: 1),
//                               ),
//                               padding: const EdgeInsets.all(6),
//                               child: Text(
//                                 '$_verticalGroupValue',
//                                 textAlign: TextAlign.start,
//                                 style: const TextStyle(
//                                     color: PeopleChaoScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T
//                                     //fontSize: 10.0
//                                     ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Row(
//                             children: [
//                               Text(
//                                 'บัตรผู้เช่า',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: PeopleChaoScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T
//                                     //fontSize: 10.0
//                                     ),
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: AppbackgroundColor.Sub_Abg_Colors,
//                                   borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(10),
//                                       topRight: Radius.circular(10),
//                                       bottomLeft: Radius.circular(10),
//                                       bottomRight: Radius.circular(10)),
//                                   border:
//                                       Border.all(color: Colors.grey, width: 1),
//                                 ),
//                                 width: 70,
//                                 child: DropdownButtonFormField2(
//                                   decoration: InputDecoration(
//                                     isDense: true,
//                                     contentPadding: EdgeInsets.zero,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   isExpanded: true,
//                                   hint: Icon(Icons.circle_rounded,
//                                       color: cardColor, size: 16),
//                                   icon: const Icon(
//                                     Icons.arrow_drop_down,
//                                     color: TextHome_Color.TextHome_Colors,
//                                   ),
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontFamily: Font_.Fonts_T),
//                                   iconSize: 20,
//                                   buttonHeight: 30,
//                                   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
//                                   dropdownDecoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   items: colorList
//                                       .map((item) => DropdownMenuItem<dynamic>(
//                                             value: item,
//                                             child: Icon(Icons.circle_rounded,
//                                                 color: item, size: 16),
//                                           ))
//                                       .toList(),

//                                   onChanged: (value) async {
//                                     final selectedColor = value;
//                                     final index = colorList.indexWhere(
//                                         (color) =>
//                                             color.value == selectedColor.value);
//                                     setState(() {
//                                       indexcardColor = index;
//                                     });

//                                     changeCardColor(colorList[index]);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: ScrollConfiguration(
//                             behavior: ScrollConfiguration.of(context)
//                                 .copyWith(dragDevices: {
//                               PointerDeviceKind.touch,
//                               PointerDeviceKind.mouse,
//                             }),
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Container(
//                                           width: 300,
//                                           // height: 135,
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius: const BorderRadius
//                                                     .only(
//                                                 topLeft: Radius.circular(10),
//                                                 topRight: Radius.circular(0),
//                                                 bottomLeft: Radius.circular(10),
//                                                 bottomRight:
//                                                     Radius.circular(0)),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: Colors.grey
//                                                     .withOpacity(0.5),
//                                                 spreadRadius: 3,
//                                                 blurRadius: 5,
//                                                 offset: const Offset(0,
//                                                     3), // changes position of shadow
//                                               ),
//                                             ],
//                                             image: const DecorationImage(
//                                               image: AssetImage(
//                                                   "images/pngegg2.png"),
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               Container(
//                                                 color: Colors.white,
//                                                 child: Text(
//                                                   '$renTal_name ',
//                                                   maxLines: 1,
//                                                   style: const TextStyle(
//                                                     fontSize: 9.0,
//                                                     color: Colors.black,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontFamily: Font_.Fonts_T,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Container(
//                                                 color: Colors.white,
//                                                 child: Text(
//                                                   '${Form_sdate.text} ถึง ${Form_ldate.text}',
//                                                   maxLines: 1,
//                                                   style: const TextStyle(
//                                                     fontSize: 8.0,
//                                                     color: Colors.black,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontFamily: Font_.Fonts_T,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: [
//                                                   Padding(
//                                                     padding: const EdgeInsets
//                                                         .fromLTRB(4, 0, 0, 0),
//                                                     child: Container(
//                                                       color: Colors.white,
//                                                       child: Column(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Center(
//                                                               child: Container(
//                                                             height: 84,
//                                                             width: 84,
//                                                             child:
//                                                                 SfBarcodeGenerator(
//                                                               value:
//                                                                   '${widget.Get_Value_cid}',
//                                                               symbology:
//                                                                   QRCode(),
//                                                               showValue: false,
//                                                             ),
//                                                           )),
//                                                           Padding(
//                                                             padding: EdgeInsets
//                                                                 .fromLTRB(
//                                                                     0, 4, 0, 0),
//                                                             child: Container(
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: Colors
//                                                                     .grey[100],
//                                                                 borderRadius: const BorderRadius
//                                                                         .only(
//                                                                     topLeft:
//                                                                         Radius.circular(
//                                                                             10),
//                                                                     topRight: Radius
//                                                                         .circular(
//                                                                             10),
//                                                                     bottomLeft:
//                                                                         Radius.circular(
//                                                                             10),
//                                                                     bottomRight:
//                                                                         Radius.circular(
//                                                                             10)),
//                                                                 // border: Border.all(color: Colors.grey, width: 1),
//                                                               ),
//                                                               padding:
//                                                                   EdgeInsets
//                                                                       .fromLTRB(
//                                                                           2,
//                                                                           2,
//                                                                           2,
//                                                                           0),
//                                                               child: Text(
//                                                                 'ลงชื่อ.....................................',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 7.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Stack(
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                     .fromLTRB(
//                                                                 4, 8, 0, 8),
//                                                         child: Container(
//                                                           width: 170,
//                                                           child: Column(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               // const SizedBox(
//                                                               //   height: 5.0,
//                                                               // ),
//                                                               // const Text(
//                                                               //   'เลขสัญญา',
//                                                               //   style: TextStyle(
//                                                               //     fontSize: 10.0,
//                                                               //     color: PeopleChaoScreen_Color.Colors_Text1_,
//                                                               //     // fontWeight: FontWeight.bold,
//                                                               //     fontFamily: Font_.Fonts_T,
//                                                               //   ),
//                                                               // ),
//                                                               Text(
//                                                                 '${widget.Get_Value_cid}',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                   fontSize:
//                                                                       11.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                               const Text(
//                                                                 'ชื่อผู้ติดต่อ',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 9.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   //fontWeight: FontWeight.bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 '${Form_bussscontact.text}',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                   fontSize:
//                                                                       11.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                               const Text(
//                                                                 'ชื่อร้านค้า',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 9.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   // fontWeight: FontWeight.bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 '${Form_nameshop.text}',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                   fontSize:
//                                                                       11.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 'พื้นที่ : ${Form_ln.text} ',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                   fontSize: 9.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   // fontWeight: FontWeight.bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 'โซน : ${Form_zn.text}',
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     const TextStyle(
//                                                                   fontSize: 9.0,
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text1_,
//                                                                   // fontWeight: FontWeight.bold,
//                                                                   fontFamily: Font_
//                                                                       .Fonts_T,
//                                                                 ),
//                                                               ),

//                                                               // Text(
//                                                               //   ' ${teNantModels[index].sdate} ถึง ${teNantModels[index].ldate}',
//                                                               //   maxLines: 2,
//                                                               //   style: const TextStyle(
//                                                               //     fontSize: 8.0,
//                                                               //     color: PeopleChaoScreen_Color.Colors_Text1_,
//                                                               //     // fontWeight: FontWeight.bold,
//                                                               //     fontFamily: Font_.Fonts_T,
//                                                               //   ),
//                                                               // ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Positioned(
//                                                         bottom: 5,
//                                                         right: 5,
//                                                         child: InkWell(
//                                                           child: Container(
//                                                             width: 30.0,
//                                                             height: 30.0,
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               color: Colors
//                                                                   .black
//                                                                   .withOpacity(
//                                                                       0.5),
//                                                               shape: BoxShape
//                                                                   .circle,
//                                                             ),
//                                                             child: const Center(
//                                                                 child: Icon(
//                                                               Icons.print,
//                                                               color:
//                                                                   Colors.white,
//                                                             )),
//                                                           ),
//                                                           onTap: () async {
//                                                             showDialog(
//                                                                 barrierDismissible:
//                                                                     false,
//                                                                 context:
//                                                                     context,
//                                                                 builder: (_) {
//                                                                   // Future.delayed(
//                                                                   //     const Duration(
//                                                                   //         seconds:
//                                                                   //             1),
//                                                                   //     () {
//                                                                   //   Navigator.of(
//                                                                   //           context)
//                                                                   //       .pop();
//                                                                   // });

//                                                                   return Dialog(
//                                                                     child: StreamBuilder(
//                                                                         stream: Stream.periodic(const Duration(seconds: 1)),
//                                                                         builder: (context, snapshot) {
//                                                                           return const SizedBox(
//                                                                               // height: 20,
//                                                                               width: 350,
//                                                                               child: Padding(
//                                                                                 padding: EdgeInsets.all(20.0),
//                                                                                 child: Row(
//                                                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                                                   children: [
//                                                                                     Padding(
//                                                                                       padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
//                                                                                       child: SizedBox(height: 30, child: CircularProgressIndicator()),
//                                                                                     ),
//                                                                                     Text(
//                                                                                       'กำลัง Download และแปลงไฟล์ PDF...  ',
//                                                                                       style: TextStyle(
//                                                                                         color: PeopleChaoScreen_Color.Colors_Text1_,
//                                                                                         fontWeight: FontWeight.bold,
//                                                                                         fontFamily: FontWeight_.Fonts_T,
//                                                                                       ),
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ));
//                                                                         }),
//                                                                   );
//                                                                 });
//                                                             Pdfgen_QR_2.displayPdf_QR2(
//                                                                 context,
//                                                                 renTal_name,
//                                                                 widget
//                                                                     .Get_Value_cid,
//                                                                 '${Form_bussscontact.text}',
//                                                                 '${Form_sdate.text} - ${Form_ldate.text}',
//                                                                 '${Form_nameshop.text}',
//                                                                 '${Form_ln.text}',
//                                                                 '${Form_zn.text}',
//                                                                 indexcardColor);
//                                                           },
//                                                         ),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 150,
//                                           width: 15,
//                                           decoration: BoxDecoration(
//                                             color: cardColor,
//                                             borderRadius:
//                                                 const BorderRadius.only(
//                                                     topLeft: Radius.circular(0),
//                                                     topRight:
//                                                         Radius.circular(10),
//                                                     bottomLeft:
//                                                         Radius.circular(0),
//                                                     bottomRight:
//                                                         Radius.circular(10)),
//                                           ),
//                                           // child: Column(
//                                           //   mainAxisAlignment:
//                                           //       MainAxisAlignment.center,
//                                           //   children: [
//                                           //     RotatedBox(
//                                           //       quarterTurns: 1,
//                                           //       child: Text(
//                                           //         '$renTal_name',
//                                           //         maxLines: 1,
//                                           //         style: const TextStyle(
//                                           //           fontSize: 9.0,
//                                           //           color: Colors.white,
//                                           //           // fontWeight: FontWeight.bold,
//                                           //           fontFamily: Font_.Fonts_T,
//                                           //         ),
//                                           //       ),
//                                           //     ),
//                                           //   ],
//                                           // ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     child: EditContractForm(
//                       cid: '${widget.Get_Value_cid}', // ไอดีจริง
//                       // serren: '',
//                       Form_nameshop: Form_nameshop,
//                       Form_typeshop: Form_typeshop,
//                       Form_bussshop: Form_bussshop,
//                       Form_bussscontact: Form_bussscontact,
//                       Form_address: Form_address,
//                       Form_tel: Form_tel,
//                       Form_email: Form_email,
//                       Form_tax: Form_tax,
//                       Form_wnote: Form_wnote,
//                       readOnlys: Form_readOnly,
//                       onFieldSubmitted: (cid, column, value) async {
//                         // ✅ ได้ค่ากลับมาจาก child แล้ว ทำอะไรก็ได้ เช่น:
//                         // 1) call API อัปเดต
//                         // await _updateFieldInParent(id, column, value);

//                         // 2) เก็บ log/ setState
//                         // setState(() { ... });
//                         //print('updated: $column = $value');
//                       },
//                     ),
//                   ),
//                   renTal_lavel <= 3
//                       ? SizedBox()
//                       : Padding(
//                           padding: const EdgeInsets.only(right: 10, left: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: const [
//                               AutoSizeText(
//                                 maxLines: 1,
//                                 minFontSize: 5,
//                                 maxFontSize: 12,
//                                 '* กด Enter ทุกครั้งที่มีการเปลี่ยนแปลงข้อมูลเพื่อบันทึกข้อมูล',
//                                 textAlign: TextAlign.start,
//                                 style: TextStyle(
//                                   color: Colors.red,

//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                   renTal_lavel <= 3
//                       ? SizedBox()
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(6),
//                                 onTap: () {
//                                   setState(() {
//                                     Form_readOnly =
//                                         Form_readOnly == true ? false : true;
//                                   });
//                                 },
//                                 child: Container(
//                                   width: 150,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.deepPurple.shade400,
//                                         Colors.deepPurple.shade600
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     ),
//                                     borderRadius: BorderRadius.circular(6),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color:
//                                             Colors.deepPurple.withOpacity(0.3),
//                                         blurRadius: 6,
//                                         offset: const Offset(0, 3),
//                                       ),
//                                     ],
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 6, horizontal: 8),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                           Form_readOnly == false
//                                               ? Icons.lock_open_outlined
//                                               : Icons.lock,
//                                           color: Colors.white,
//                                           size: 20),
//                                       SizedBox(width: 8),
//                                       Text(
//                                         Form_readOnly == false
//                                             ? 'ปิดฟอร์มแก้ไข'
//                                             : 'เปิดฟอร์มแก้ไข',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: Font_.Fonts_T,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(6),
//                                 onTap: () => select_coutumerAll(context),
//                                 child: Container(
//                                   width: 150,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.red.shade400,
//                                         Colors.red.shade600
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     ),
//                                     borderRadius: BorderRadius.circular(6),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.red.withOpacity(0.3),
//                                         blurRadius: 6,
//                                         offset: const Offset(0, 3),
//                                       ),
//                                     ],
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 6, horizontal: 8),
//                                   child: const Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(Icons.refresh,
//                                           color: Colors.white, size: 20),
//                                       SizedBox(width: 8),
//                                       Text(
//                                         'เปลี่ยนผู้เช่า',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: Font_.Fonts_T,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                 ],
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 color: AppbackgroundColor.Sub_Abg_Colors,
//                 borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(0),
//                     topRight: Radius.circular(0),
//                     bottomLeft: Radius.circular(6),
//                     bottomRight: Radius.circular(6)),
//                 // border: Border.all(color: Colors.white, width: 1),
//               ),
//               child: Column(
//                 children: [
//                   const Row(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: AutoSizeText(
//                           minFontSize: 10,
//                           maxFontSize: 15,
//                           '2.พื้นที่เช่า',
//                           style: TextStyle(
//                               color: PeopleChaoScreen_Color.Colors_Text1_,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: FontWeight_.Fonts_T),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(right: _gap),
//                               child: Text(
//                                 'รหัสพื้นที่เช่า',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_lncode,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done, minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'ชื่อพื้นที่เช่า',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_ln,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(right: _gap),
//                               child: Text(
//                                 'โซนพื้นที่เช่า',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_zn,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'พื้นที่เช่า(ตร.ม.)',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 2,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_area,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'จำนวน\n(ล็อค/ห้อง)',
//                                 textAlign: TextAlign.center,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         SizedBox(
//                           width: _labelWidth,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_qty,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             //  textAlign: TextAlign.center,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Row(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: AutoSizeText(
//                           minFontSize: 10,
//                           maxFontSize: 15,
//                           '3.ข้อมูลสัญญา/เสนอราคา',
//                           style: TextStyle(
//                               color: PeopleChaoScreen_Color.Colors_Text1_,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: FontWeight_.Fonts_T
//                               //fontSize: 10.0
//                               ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'วันที่ทำ(สัญญา/เสนอราคา)',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_cdate,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'วันเริ่มสัญญา/เสนอราคา',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_sdate,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'วันสิ้นสุดสัญญา/เสนอราคา',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_ldate,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'ระยะเวลาการเช่า',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_period,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 '${Form_rtname.text}',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_Remark,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               hintText: 'หมายเหตุ',
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 (Form_PakanSdate == null ||
//                                         Form_PakanSdate.text.toString() == '' ||
//                                         pakanDocnoModels.length == 0)
//                                     ? 'เงินประกันครั้งแรก'
//                                     : 'เงินประกันครั้งแรก' +
//                                         '/ ${Form_PakanSdate.text} ',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_PakanSdate_Doc,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         // Expanded(
//                         //   flex: 1,
//                         //   child: Text(
//                         //     (Form_PakanSdate == null ||
//                         //             Form_PakanSdate.text.toString() == '' ||
//                         //             pakanDocnoModels.length == 0)
//                         //         ? 'เงินประกันครั้งแรก'
//                         //         : 'เงินประกันครั้งแรก' +
//                         //             '/ ${Form_PakanSdate.text} ',
//                         //     textAlign: TextAlign.start,
//                         //     style: TextStyle(
//                         //         color: PeopleChaoScreen_Color.Colors_Text2_,
//                         //         //fontWeight: FontWeight.bold,
//                         //         fontFamily: Font_.Fonts_T),
//                         //   ),
//                         // ),
//                         // Expanded(
//                         //   flex: 2,
//                         //   child: Container(
//                         //     decoration: const BoxDecoration(
//                         //       // color: Colors.green,
//                         //       borderRadius: BorderRadius.only(
//                         //         topLeft: Radius.circular(6),
//                         //         topRight: Radius.circular(6),
//                         //         bottomLeft: Radius.circular(6),
//                         //         bottomRight: Radius.circular(6),
//                         //       ),
//                         //       // border: Border.all(color: Colors.grey, width: 1),
//                         //     ),
//                         //     padding: const EdgeInsets.all(8.0),
//                         //     child: TextFormField(
//                         //       keyboardType: TextInputType.number,
//                         //       showCursor: true, //add this line
//                         //       readOnly: false,

//                         //       controller: Form_PakanSdate_Doc,
//                         //       onFieldSubmitted: (value) async {
//                         //         SharedPreferences preferences =
//                         //             await SharedPreferences.getInstance();
//                         //         String? ren =
//                         //             preferences.getString('renTalSer');
//                         //         String? ser_user = preferences.getString('ser');

//                         //         var vv = Form_PakanLdate_Doc.text;
//                         //         //print(vv);
//                         //         String url2 =
//                         //             '${MyConstant().domain}/U_docno_pakan.php?isAdd=true&ren=$ren&docno=$vv&value=$value';
//                         //         //print(url2);
//                         //         try {
//                         //           var response2 =
//                         //               await http.get(Uri.parse(url2));

//                         //           var result2 = json.decode(response2.body);
//                         //           //print(result2);
//                         //           if (result2.toString() == 'true') {}
//                         //         } catch (e) {}
//                         //       },
//                         //       cursorColor: Colors.green,
//                         //       decoration: InputDecoration(
//                         //           fillColor: Colors.white.withOpacity(0.3),
//                         //           filled: true,
//                         //           // prefixIcon:
//                         //           //     const Icon(Icons.person, color: Colors.black),
//                         //           // suffixIcon: Icon(Icons.clear, color: Colors.black),
//                         //           focusedBorder: const OutlineInputBorder(
//                         //             borderRadius: BorderRadius.only(
//                         //               topRight: Radius.circular(15),
//                         //               topLeft: Radius.circular(15),
//                         //               bottomRight: Radius.circular(15),
//                         //               bottomLeft: Radius.circular(15),
//                         //             ),
//                         //             borderSide: BorderSide(
//                         //               width: 1,
//                         //               color: Colors.black,
//                         //             ),
//                         //           ),
//                         //           enabledBorder: const OutlineInputBorder(
//                         //             borderRadius: BorderRadius.only(
//                         //               topRight: Radius.circular(15),
//                         //               topLeft: Radius.circular(15),
//                         //               bottomRight: Radius.circular(15),
//                         //               bottomLeft: Radius.circular(15),
//                         //             ),
//                         //             borderSide: BorderSide(
//                         //               width: 1,
//                         //               color: Colors.grey,
//                         //             ),
//                         //           ),
//                         //           labelStyle: const TextStyle(
//                         //               color: Colors.black54,
//                         //               fontFamily: Font_.Fonts_T)),
//                         //     ),
//                         //   ),
//                         // ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 (Form_PakanLdate.text == null ||
//                                         Form_PakanLdate.text.toString() == '' ||
//                                         pakanDocnoModels.length == 0)
//                                     ? 'เงินประกันครั้งล่าสุด'
//                                     : 'เงินประกันครั้งล่าสุด' +
//                                         '/ ${Form_PakanLdate.text} ',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_PakanLdate_Doc,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         // Expanded(
//                         //   flex: 1,
//                         //   child: Text(
//                         //     (Form_PakanLdate.text == null ||
//                         //             Form_PakanLdate.text.toString() == '' ||
//                         //             pakanDocnoModels.length == 0)
//                         //         ? 'เงินประกันครั้งล่าสุด'
//                         //         : 'เงินประกันครั้งล่าสุด' +
//                         //             '/ ${Form_PakanLdate.text} ',
//                         //     textAlign: TextAlign.center,
//                         //     style: TextStyle(
//                         //         color: PeopleChaoScreen_Color.Colors_Text2_,
//                         //         //fontWeight: FontWeight.bold,
//                         //         fontFamily: Font_.Fonts_T),
//                         //   ),
//                         // ),
//                         // Expanded(
//                         //   flex: 2,
//                         //   child: Container(
//                         //     decoration: BoxDecoration(
//                         //       // color: Colors.green,
//                         //       borderRadius: BorderRadius.only(
//                         //         topLeft: Radius.circular(6),
//                         //         topRight: Radius.circular(6),
//                         //         bottomLeft: Radius.circular(6),
//                         //         bottomRight: Radius.circular(6),
//                         //       ),
//                         //       // border: Border.all(color: Colors.grey, width: 1),
//                         //     ),
//                         //     padding: EdgeInsets.all(8.0),
//                         //     child: TextFormField(
//                         //       keyboardType: TextInputType.number,
//                         //       showCursor: false, //add this line
//                         //       readOnly: true, //true

//                         //       controller: Form_PakanLdate_Doc,

//                         //       cursorColor: Colors.green,
//                         //       decoration: InputDecoration(
//                         //           fillColor: Colors.white.withOpacity(0.3),
//                         //           filled: true,
//                         //           // prefixIcon:
//                         //           //     const Icon(Icons.person, color: Colors.black),
//                         //           // suffixIcon: Icon(Icons.clear, color: Colors.black),
//                         //           focusedBorder: const OutlineInputBorder(
//                         //             borderRadius: BorderRadius.only(
//                         //               topRight: Radius.circular(15),
//                         //               topLeft: Radius.circular(15),
//                         //               bottomRight: Radius.circular(15),
//                         //               bottomLeft: Radius.circular(15),
//                         //             ),
//                         //             borderSide: BorderSide(
//                         //               width: 1,
//                         //               color: Colors.black,
//                         //             ),
//                         //           ),
//                         //           enabledBorder: const OutlineInputBorder(
//                         //             borderRadius: BorderRadius.only(
//                         //               topRight: Radius.circular(15),
//                         //               topLeft: Radius.circular(15),
//                         //               bottomRight: Radius.circular(15),
//                         //               bottomLeft: Radius.circular(15),
//                         //             ),
//                         //             borderSide: BorderSide(
//                         //               width: 1,
//                         //               color: Colors.grey,
//                         //             ),
//                         //           ),
//                         //           labelStyle: const TextStyle(
//                         //               color: Colors.black54,
//                         //               fontFamily: Font_.Fonts_T)),
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'เงินประกันทั้งหมด(ก่อนvat)',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_PakanAll_pvat,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'เงินประกันทั้งหมด(vat)',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_PakanAll_vat,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'เงินประกันทั้งหมด(รวมvat)',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller: Form_PakanAll_Total,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                             width: _labelWidth,
//                             child: Padding(
//                               padding: EdgeInsets.only(left: _gap),
//                               child: Text(
//                                 'เลขที่สัญญาเดิม/ครั้งแรก',
//                                 textAlign: TextAlign.start,
//                                 // NOTE: แทนที่ด้วยสไตล์ของคุณเองได้
//                                 style: const TextStyle(
//                                     fontSize: 14, color: Color(0xFF333333)),
//                               ),
//                             )),
//                         Expanded(
//                           flex: 1,
//                           child: TextFormField(
//                             keyboardType: TextInputType.number,
//                             showCursor: false, //add this line
//                             readOnly: true,
//                             controller:
//                                 (widget.Get_Value_cid.toString().trim() ==
//                                         Form_renew_cid.text.toString().trim())
//                                     ? null
//                                     : Form_renew_cid,
//                             cursorColor: Colors.green,
//                             textInputAction: TextInputAction.done,
//                             minLines: 1,
//                             maxLines: 1,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               filled: true,
//                               fillColor: Colors.white.withOpacity(0.3),
//                               enabledBorder: _pillBorder,
//                               focusedBorder: _pillBorderFocused,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 14, vertical: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         InkWell(
//                           child: Container(
//                             width: 160,
//                             // height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.orange[300],
//                               borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(6),
//                                   topRight: Radius.circular(6),
//                                   bottomLeft: Radius.circular(6),
//                                   bottomRight: Radius.circular(6)),
//                             ),

//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.all(4.0),
//                                   child: Icon(
//                                     Icons.print,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.all(4.0),
//                                   child: Text(
//                                     'ใบเสนอราคา',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: PeopleChaoScreen_Color
//                                             .Colors_Text2_,
//                                         fontWeight: FontWeight.w400,
//                                         fontFamily: Font_.Fonts_T),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           onTap: () async {
//                             List newValuePDFimg = [];
//                             for (int index = 0; index < 1; index++) {
//                               if (renTalModels[0].imglogo!.trim() == '') {
//                                 // newValuePDFimg.add(
//                                 //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
//                               } else {
//                                 newValuePDFimg.add(
//                                     '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//                               }
//                             }
//                             SharedPreferences preferences =
//                                 await SharedPreferences.getInstance();
//                             var renTal_name =
//                                 preferences.getString('renTalName');
//                             if (renTal_user.toString() == '106') {
//                               Pdfgen_RentalInforma2.exportPDF_RentalInforma2(
//                                   context,
//                                   '${widget.Get_Value_NameShop_index}',
//                                   '${widget.Get_Value_cid}',
//                                   _verticalGroupValue,
//                                   Form_nameshop.text,
//                                   Form_typeshop.text,
//                                   Form_bussshop.text,
//                                   Form_bussscontact.text,
//                                   Form_address.text,
//                                   Form_tel.text,
//                                   Form_email.text,
//                                   Form_tax.text,
//                                   Form_ln.text,
//                                   Form_zn.text,
//                                   Form_area.text,
//                                   Form_qty.text,
//                                   Form_sdate.text,
//                                   Form_ldate.text,
//                                   Form_period.text,
//                                   Form_rtname.text,
//                                   Form_cdate.text,
//                                   quotxSelectModels,
//                                   _TransModels,
//                                   '$renTal_name',
//                                   ' ${renTalModels[0].bill_addr}',
//                                   ' ${renTalModels[0].bill_email}',
//                                   ' ${renTalModels[0].bill_tel}',
//                                   ' ${renTalModels[0].bill_tax}',
//                                   ' ${renTalModels[0].bill_name}',
//                                   newValuePDFimg,
//                                   Form_addmin.text);
//                             } else if (renTal_user.toString() == '145') {
//                               Pdfgen_RentalInformanim
//                                   .exportPDF_RentalInformanim(
//                                       context,
//                                       '${widget.Get_Value_NameShop_index}',
//                                       '${widget.Get_Value_cid}',
//                                       _verticalGroupValue,
//                                       Form_nameshop.text,
//                                       Form_typeshop.text,
//                                       Form_bussshop.text,
//                                       Form_bussscontact.text,
//                                       Form_address.text,
//                                       Form_tel.text,
//                                       Form_email.text,
//                                       Form_tax.text,
//                                       Form_ln.text,
//                                       Form_zn.text,
//                                       Form_area.text,
//                                       Form_qty.text,
//                                       Form_sdate.text,
//                                       Form_ldate.text,
//                                       Form_period.text,
//                                       Form_rtname.text,
//                                       Form_cdate.text,
//                                       quotxSelectModels,
//                                       _TransModels,
//                                       '$renTal_name',
//                                       ' ${renTalModels[0].bill_addr}',
//                                       ' ${renTalModels[0].bill_email}',
//                                       ' ${renTalModels[0].bill_tel}',
//                                       ' ${renTalModels[0].bill_tax}',
//                                       ' ${renTalModels[0].bill_name}',
//                                       newValuePDFimg);
//                             } else {
//                               Pdfgen_RentalInforma.exportPDF_RentalInforma(
//                                 context,
//                                 '${widget.Get_Value_NameShop_index}',
//                                 '${widget.Get_Value_cid}',
//                                 _verticalGroupValue,
//                                 Form_nameshop.text,
//                                 Form_typeshop.text,
//                                 Form_bussshop.text,
//                                 Form_bussscontact.text,
//                                 Form_address.text,
//                                 Form_tel.text,
//                                 Form_email.text,
//                                 Form_tax.text,
//                                 Form_ln.text,
//                                 Form_zn.text,
//                                 Form_area.text,
//                                 Form_qty.text,
//                                 Form_sdate.text,
//                                 Form_ldate.text,
//                                 Form_period.text,
//                                 Form_rtname.text,
//                                 Form_cdate.text,
//                                 quotxSelectModels,
//                                 _TransModels,
//                                 '$renTal_name',
//                                 ' ${renTalModels[0].bill_addr}',
//                                 ' ${renTalModels[0].bill_email}',
//                                 ' ${renTalModels[0].bill_tel}',
//                                 ' ${renTalModels[0].bill_tax}',
//                                 ' ${renTalModels[0].bill_name}',
//                                 newValuePDFimg,
//                                 ''
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Container(
//               // decoration: BoxDecoration(
//               //   // image: DecorationImage(
//               //   //   colorFilter: new ColorFilter.mode(
//               //   //       Colors.white.withOpacity(0.05), BlendMode.dstATop),
//               //   //   image: AssetImage("images/BG_im2.png"),
//               //   //   fit: BoxFit.cover,
//               //   // ),
//               //   color: AppbackgroundColor.Sub_Abg_Colors,
//               //   borderRadius: BorderRadius.only(
//               //       topLeft: Radius.circular(10),
//               //       topRight: Radius.circular(10),
//               //       bottomLeft: Radius.circular(0),
//               //       bottomRight: Radius.circular(0)
//               // ),
//               //   // border: Border.all(color: Colors.white, width: 1),
//               // ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 20,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(6),
//                       onTap: () {
//                         setState(() {
//                           TitelTap = 1;
//                         });
//                       },
//                       child: Container(
//                         width: 180,
//                         decoration: BoxDecoration(
//                           color: TitelTap == 1
//                               ? Colors.grey.shade800
//                               : Colors.grey.shade500,
//                           // gradient: LinearGradient(
//                           //   colors: [
//                           //     Colors.grey.shade400,
//                           //     Colors.grey.shade600
//                           //   ],
//                           //   begin: Alignment.topLeft,
//                           //   end: Alignment.bottomRight,
//                           // ),
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(6),
//                               topRight: Radius.circular(6),
//                               bottomLeft: Radius.circular(0),
//                               bottomRight: Radius.circular(0)),
//                           // boxShadow: [
//                           //   BoxShadow(
//                           //     color: Colors.grey.withOpacity(0.3),
//                           //     blurRadius: 6,
//                           //     offset: const Offset(0, 3),
//                           //   ),
//                           // ],
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 6, horizontal: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.note,
//                                 color:
//                                     TitelTap == 1 ? Colors.white : Colors.black,
//                                 size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'เอกสาร',
//                               style: TextStyle(
//                                 color:
//                                     TitelTap == 1 ? Colors.white : Colors.black,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(6),
//                       onTap: () {
//                         setState(() {
//                           TitelTap = 2;
//                         });
//                       },
//                       child: Container(
//                         width: 180,
//                         decoration: BoxDecoration(
//                           color: TitelTap == 2
//                               ? Colors.grey.shade800
//                               : Colors.grey.shade500,
//                           // gradient: LinearGradient(
//                           //   colors: [
//                           //     Colors.grey.shade400,
//                           //     Colors.grey.shade600
//                           //   ],
//                           //   begin: Alignment.topLeft,
//                           //   end: Alignment.bottomRight,
//                           // ),
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(6),
//                               topRight: Radius.circular(6),
//                               bottomLeft: Radius.circular(0),
//                               bottomRight: Radius.circular(0)),
//                           // boxShadow: [
//                           //   BoxShadow(
//                           //     color: Colors.grey.withOpacity(0.3),
//                           //     blurRadius: 6,
//                           //     offset: const Offset(0, 3),
//                           //   ),
//                           // ],
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 6, horizontal: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.list_alt,
//                                 color:
//                                     TitelTap == 2 ? Colors.white : Colors.black,
//                                 size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'ค่าเช่า-ค่าบริการต่างๆ',
//                               style: TextStyle(
//                                 color:
//                                     TitelTap == 2 ? Colors.white : Colors.black,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (TitelTap == 1) _doccumentUi(context),
//             if (TitelTap == 2) _expCidUi(context),
//             const SizedBox(
//               height: 20,
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> Idcard_(context, Url) async {
//     final pdf = pw.Document();
//     final netImage = await networkImage('$Url');

//     pdf.addPage(pw.Page(build: (pw.Context context) {
//       return pw.Center(
//         child: pw.Image(netImage),
//       ); // Center
//     }));

//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PreviewScreenIDcard(doc: pdf, netImage_: Url),
//         ));
//   }

// /////////////////////---------->
//   Widget navPill({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//     EdgeInsetsGeometry margin = const EdgeInsets.only(left: 6),
//   }) {
//     return Padding(
//       padding: margin,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(999),
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           curve: Curves.easeOut,
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(999),
//             gradient: active
//                 ? LinearGradient(colors: [
//                     Colors.grey.shade700,
//                     Colors.grey.shade600,
//                   ])
//                 : LinearGradient(colors: [
//                     Colors.grey.shade200,
//                     Colors.grey.shade200,
//                   ]),
//             boxShadow: active
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(.12),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ]
//                 : [],
//             border: Border.all(
//               color: Colors.white,
//               width: 1,
//             ),
//           ),
//           child: DefaultTextStyle(
//             style: TextStyle(
//               color: active ? Colors.white : Colors.black87,
//               fontWeight: FontWeight.bold,
//               fontFamily: FontWeight_.Fonts_T,
//               fontSize: 12,
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // ไอคอน (ถ้าอยากต่างกันต่อแท็บ ค่อยปรับตอนเรียกใช้)
//                 if (active) ...[
//                   const Icon(Icons.check_circle, size: 16, color: Colors.white),
//                   const SizedBox(width: 6),
//                 ],
//                 // ถ้าต้องการใช้ Translate เดิมก็แทนที่ Text ตรงนี้ได้
//                 Text(label, textAlign: TextAlign.start),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// // ===== helper เดิม (แก้ลำดับพารามิเตอร์ text ให้อยู่ตัวแรก) =====
//   Widget buildHeaderCell(
//     String text, {
//     TextAlign align = TextAlign.start,
//     int flex = 1,
//     EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
//   }) {
//     return Expanded(
//       flex: flex,
//       child: Padding(
//         padding: padding,
//         child: Text(
//           text,
//           textAlign: align,
//           style: TextStyle(
//             color: PeopleChaoScreen_Color.Colors_Text1_,
//             fontWeight: FontWeight.bold,
//             fontFamily: FontWeight_.Fonts_T,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget HeaderRow(BuildContext context, {required int expTap}) {
//     // ช่วยเขียนให้สั้น
//     Widget header(String text,
//             {int flex = 1,
//             TextAlign align = TextAlign.start,
//             EdgeInsetsGeometry pad = const EdgeInsets.all(2)}) =>
//         buildHeaderCell(text, flex: flex, align: align, padding: pad);
//     List<Widget> _cells() {
//       switch (expTap) {
//         case 1:
//           return [
//             header('งวด', flex: 1),
//             header('วันที่', flex: 2, pad: const EdgeInsets.all(2)),
//             header('รายการ', flex: 2, pad: const EdgeInsets.all(2)),

//             header(
//               'รูปแบบการคำนวน',
//               flex: 1,
//             ),
//             header('หน่วยละ',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ก่อนVAT',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ประเภทVAT', align: TextAlign.center),
//             header('VAT', align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             // header('ประเภทWHT'),
//             header('WHT', align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ยอดสุทธิ',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             const SizedBox(width: 48),
//           ];
//         case 2:
//           return [
//             // header('...'),
//             header('วันที่', flex: 1, pad: const EdgeInsets.all(2)),
//             header('รายการ', flex: 2, pad: const EdgeInsets.all(2)),
//             header('ประเภท', flex: 1, pad: const EdgeInsets.all(2)),
//             header(
//               'รูปแบบการคำนวน',
//               flex: 2,
//             ),
//             header('หน่วยละ',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ก่อนVAT',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ประเภทVAT', align: TextAlign.center),
//             header('VAT', align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             // header('ประเภทWHT'),
//             header('WHT', align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ยอดสุทธิ',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             // const SizedBox(width: 48),
//           ];
//         case 3:
//           return [
//             header('วันที่', flex: 2, pad: const EdgeInsets.all(2)),
//             header('รายการ', flex: 1, pad: const EdgeInsets.all(2)),
//             header('จำนวนรายการ',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             header('ยอดสุทธิ',
//                 align: TextAlign.end, pad: const EdgeInsets.all(2)),
//             // const SizedBox(width: 48),
//           ];
//         default:
//           return [
//             header('วันที่', flex: 2, pad: const EdgeInsets.all(2)),
//             header('เวลา', flex: 2, pad: const EdgeInsets.all(2)),
//             header('ไอพี'),
//             header('ผู้ใช้'),
//             header('รายละเอียด', flex: 2, pad: const EdgeInsets.all(2)),
//             // const SizedBox(width: 48),
//           ];
//       }
//     }

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: _cells(),
//     );
//   }

//   Widget ValueCellExpType_1(BuildContext context,
//       {required List<QuotxSelectModel> quotxSelectModels, required int index}) {
//     return Container(
//       color: AppbackgroundColor.Sub_Abg_Colors,
//       child: Column(
//         children: [
//           // แถวหลัก
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (ExpTap == 1)
//                 buildValueCell(
//                   flex: 1,
//                   '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
//                 ),
//               buildValueCell(
//                 flex: 2,
//                 '${DateFormat('MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))}'
//                 ' - '
//                 '${DateFormat('MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
//               ),
//               buildValueCell(
//                 flex: 2,
//                 (quotxSelectModels[index].etype.toString() == 'D' &&
//                         quotxSelectModels[index].pay_pakan.toString() == '1')
//                     ? '${quotxSelectModels[index].expname}(เดิม-ยกมา)'
//                     : '${quotxSelectModels[index].expname}',
//               ),

//               Builder(builder: (context) {
//                 final dayall = [
//                   if (quotxSelectModels[index].is_mon == '0') 'จ.',
//                   if (quotxSelectModels[index].is_tue == '0') 'อ.',
//                   if (quotxSelectModels[index].is_wed == '0') 'พ.',
//                   if (quotxSelectModels[index].is_thu == '0') 'พฤ.',
//                   if (quotxSelectModels[index].is_fri == '0') 'ศ.',
//                   if (quotxSelectModels[index].is_sat == '0') 'ส.',
//                   if (quotxSelectModels[index].is_sun == '0') 'อา.',
//                 ].join(' , ');

//                 String? typeS = (quotxSelectModels[index].price_type == '0')
//                     ? '0'
//                     : (quotxSelectModels[index].is_mon == '1')
//                         ? '1'
//                         : (quotxSelectModels[index].price_type == '2')
//                             ? '2'
//                             : '0';
//                 String? typeRent = (quotxSelectModels[index].price_type == '0')
//                     ? 'ปกติ'
//                     : (quotxSelectModels[index].is_mon == '1')
//                         ? 'ก้าวหน้า'
//                         : (quotxSelectModels[index].price_type == '2')
//                             ? 'รายวัน'
//                             : '-';

//                 return buildValueCell(
//                   flex: 1,
//                   (typeS == '0' || typeS == '1')
//                       ? '${typeRent}'
//                       : (typeS == '2')
//                           ? '${dayall}'
//                           : '-',
//                 );
//               }),
//               buildValueCell(
//                 flex: 1,
//                 (quotxSelectModels[index].etype.toString() == 'F')
//                     ? nFormat.format(
//                         double.tryParse(quotxSelectModels[index].amt ?? '0') ??
//                             0)
//                     : quotxSelectModels[index].dtype.toString() == 'KU'
//                         ? nFormat.format(double.tryParse(
//                                 quotxSelectModels[index].qty ?? '0') ??
//                             0)
//                         : '-',
//                 align: TextAlign.end,
//                 padding: const EdgeInsets.all(2),
//               ),
//               buildValueCell(
//                 (quotxSelectModels[index].etype.toString() == 'F')
//                     ? '-'
//                     : nFormat.format(
//                         double.tryParse(quotxSelectModels[index].pvat ?? '0') ??
//                             0),
//                 align: TextAlign.end,
//                 padding: const EdgeInsets.all(2),
//               ),
//               buildValueCell(
//                   align: TextAlign.center,
//                   (quotxSelectModels[index].etype.toString() == 'F')
//                       ? '${quotxSelectModels[index].vtype ?? ''}'
//                       : '${quotxSelectModels[index].vtype ?? ''}'),
//               buildValueCell(
//                 (quotxSelectModels[index].etype.toString() == 'F')
//                     ? '-'
//                     : nFormat.format(
//                         double.tryParse(quotxSelectModels[index].vat ?? '0') ??
//                             0),
//                 align: TextAlign.end,
//                 padding: const EdgeInsets.all(2),
//               ),
//               buildValueCell(
//                 (quotxSelectModels[index].etype.toString() == 'F')
//                     ? '-'
//                     : nFormat.format(
//                         double.tryParse(quotxSelectModels[index].wht ?? '0') ??
//                             0),
//                 align: TextAlign.end,
//                 padding: const EdgeInsets.all(2),
//               ),
//               buildValueCell(
//                 (quotxSelectModels[index].etype.toString() == 'F')
//                     ? 'สูงสุด ${nFormat.format(double.tryParse(quotxSelectModels[index].fine_max ?? '0') ?? 0)}'
//                     : nFormat.format(double.tryParse(
//                             quotxSelectModels[index].total ?? '0') ??
//                         0),
//                 align: TextAlign.end,
//                 padding: const EdgeInsets.all(2),
//               ),

//               // ปุ่ม Show/Hide exp_array
//               SizedBox(
//                 width: 48,
//                 child: (quotxSelectModels[index].etype.toString() == 'F')
//                     ? null
//                     : IconButton(
//                         onPressed: () {
//                           setState(() {
//                             if (_expandedRows.contains(index)) {
//                               _expandedRows.remove(index);
//                             } else {
//                               _expandedRows.add(index);
//                             }
//                           });
//                         },
//                         icon: Icon(
//                           _expandedRows.contains(index)
//                               ? Icons.expand_less
//                               : Icons.expand_more,
//                         ),
//                         tooltip: 'ดูรายละเอียด',
//                       ),
//               ),
//             ],
//           ),

//           // แถวรายละเอียดจาก exp_array (ถ้ามี และกดขยาย)
//           if (_expandedRows.contains(index)) ...[
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.indigo[100]!.withOpacity(0.5),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(6),
//                   topRight: Radius.circular(6),
//                   bottomLeft: Radius.circular(6),
//                   bottomRight: Radius.circular(6),
//                 ),
//                 border: Border.all(color: Colors.grey.shade100, width: 0.5),
//               ),
//               child: Builder(
//                 builder: (context) {
//                   // 1) decode exp_array (string JSON -> List<Map>)
//                   final raw = quotxSelectModels[index].exp_array;
//                   List<Map<String, dynamic>> items = [];
//                   if (raw is String && raw.trim().isNotEmpty) {
//                     try {
//                       final decoded = jsonDecode(raw);
//                       if (decoded is List) {
//                         items = decoded
//                             .where((e) => e is Map)
//                             .map<Map<String, dynamic>>(
//                                 (e) => Map<String, dynamic>.from(e as Map))
//                             .toList();
//                       }
//                     } catch (_) {
//                       // decode ไม่สำเร็จ -> items ว่าง
//                     }
//                   }

//                   // 2) ฟังก์ชันช่วย format
//                   String _fmtDate(String src) {
//                     if (src.isEmpty) return '-';
//                     try {
//                       return DateFormat('dd-MM-yyyy')
//                           .format(DateTime.parse('$src 00:00:00'));
//                     } catch (_) {
//                       return src; // ถ้า parse ไม่ได้ แสดงดิบ
//                     }
//                   }

//                   String _fmtNum(String src) {
//                     final d = double.tryParse(src) ?? 0;
//                     return nFormat.format(d);
//                   }

//                   // 3) ใช้ ListView.separated (ลื่นกว่า Column + ScrollView)
//                   return ListView.separated(
//                     padding: EdgeInsets.zero,
//                     itemCount: items.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 4),
//                     itemBuilder: (_, i) {
//                       final e = items[i];

//                       final serExp = (e['ser_exp'] ?? '').toString();
//                       final nameExp = (e['name_exp'] ?? '').toString();
//                       final dateExpS = (e['date_exp'] ?? '')
//                           .toString(); // อาจไม่มีในข้อมูลจริง
//                       final pvatS = (e['pvat_exp'] ?? '0').toString();
//                       final vtypeS = (e['vtype_exp'] ?? '0').toString();
//                       final vatS = (e['vat_exp'] ?? '0').toString();
//                       final whtS = (e['wht_exp'] ?? '0').toString();
//                       final totalS = (e['total_exp'] ?? '0').toString();

//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (ExpTap == 1)
//                             buildValueCell(
//                                 flex: 1,
//                                 align: TextAlign.center,
//                                 '${i + 1}'), // ลำดับย่อย
//                           buildValueCell(flex: 2, _fmtDate(dateExpS)), // วันที่
//                           buildValueCell(flex: 2, '$nameExp'),
//                           buildValueCell(flex: 1, ''), // รายการ
//                           buildValueCell(flex: 1, ''), // รายการ
//                           buildValueCell(_fmtNum(pvatS),
//                               align: TextAlign.end,
//                               padding: const EdgeInsets.all(2)),
//                           buildValueCell(
//                               align: TextAlign.center,
//                               '$vtypeS'), // vtype ย่อย (ไม่มี -> ขีด)
//                           buildValueCell(_fmtNum(vatS),
//                               align: TextAlign.end,
//                               padding: const EdgeInsets.all(2)),
//                           buildValueCell(_fmtNum(whtS),
//                               align: TextAlign.end,
//                               padding: const EdgeInsets.all(2)),
//                           buildValueCell(_fmtNum(totalS),
//                               align: TextAlign.end,
//                               padding: const EdgeInsets.all(2)),
//                           const SizedBox(
//                               width: 48), // เผื่อพื้นที่ให้ไอคอนของแถวหลัก
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ]
//         ],
//       ),
//     );
//   }

//   Widget ValueCellExpType_2(BuildContext context,
//       {required List<TransModel> transModels, required int index}) {
//     return Container(
//       color: AppbackgroundColor.Sub_Abg_Colors,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // buildValueCell(
//           //   '...',
//           // ),
//           buildValueCell(
//             flex: 1,
//             '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${transModels[index].date!} 00:00:00'))}',
//           ),
//           buildValueCell(
//             flex: 2,
//             '${transModels[index].expname}',
//           ),
//           buildValueCell(
//             flex: 1,
//             '${transModels[index].unit}',
//           ),
//           Builder(builder: (context) {
//             final dayall = [
//               if (transModels[index].is_mon == '0') 'จ.',
//               if (transModels[index].is_tue == '0') 'อ.',
//               if (transModels[index].is_wed == '0') 'พ.',
//               if (transModels[index].is_thu == '0') 'พฤ.',
//               if (transModels[index].is_fri == '0') 'ศ.',
//               if (transModels[index].is_sat == '0') 'ส.',
//               if (transModels[index].is_sun == '0') 'อา.',
//             ].join(' , ');

//             String? typeS = (transModels[index].price_type == '0')
//                 ? '0'
//                 : (transModels[index].is_mon == '1')
//                     ? '1'
//                     : (transModels[index].price_type == '2')
//                         ? '2'
//                         : '0';
//             String? typeRent = (transModels[index].price_type == '0')
//                 ? 'ปกติ'
//                 : (transModels[index].is_mon == '1')
//                     ? 'ก้าวหน้า'
//                     : (transModels[index].price_type == '2')
//                         ? 'รายวัน'
//                         : '-';

//             return buildValueCell(
//               flex: 2,
//               (typeS == '0' || typeS == '1')
//                   ? '${typeRent}'
//                   : (typeS == '2')
//                       ? '${dayall}'
//                       : '-',
//             );
//           }),

//           buildValueCell(
//             transModels[index].dtype.toString() == 'KU'
//                 ? nFormat.format(
//                     double.tryParse(transModels[index].qty_con ?? '0') ?? 0)
//                 : '-',
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//           buildValueCell(
//             nFormat
//                 .format(double.tryParse(transModels[index].pvat ?? '0') ?? 0),
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//           buildValueCell(
//             '${transModels[index].vtype}',
//             align: TextAlign.center,
//           ),
//           buildValueCell(
//             nFormat.format(double.tryParse(transModels[index].vat ?? '0') ?? 0),
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//           buildValueCell(
//             nFormat.format(double.tryParse(transModels[index].wht ?? '0') ?? 0),
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//           buildValueCell(
//             nFormat
//                 .format(double.tryParse(transModels[index].total ?? '0') ?? 0),
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget ValueCellExpType_3(BuildContext context,
//       {required List<QuotxSelectModel> quotxSelectModels2,
//       required int index}) {
//     String _fmtDate(String src) {
//       if (src.isEmpty) return '-';
//       try {
//         return DateFormat('dd-MM-yyyy').format(DateTime.parse('$src 00:00:00'));
//       } catch (_) {
//         return src; // ถ้า parse ไม่ได้ แสดงดิบ
//       }
//     }

//     return Container(
//       color: AppbackgroundColor.Sub_Abg_Colors,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           buildValueCell(
//             flex: 2,
//             '${_fmtDate('${quotxSelectModels2[index].datex!}')}',
//           ),
//           buildValueCell(
//             (quotxSelectModels2[index].etype.toString() == 'D' &&
//                     quotxSelectModels2[index].pay_pakan.toString() == '1')
//                 ? '${quotxSelectModels2[index].expname}(เดิม-ยกมา)'
//                 : '${quotxSelectModels2[index].expname}',
//           ),
//           buildValueCell(
//             nFormat.format(
//                 double.tryParse(quotxSelectModels2[index].qty ?? '0') ?? 0),
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//           buildValueCell(
//             nFormat.format(
//                 double.tryParse(quotxSelectModels2[index].total ?? '0') ?? 0),
//             align: TextAlign.end,
//             padding: const EdgeInsets.all(2),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget ValueCellExpType_4(BuildContext context,
//       {required List<SyslogModel> syslogModel, required int index}) {
//     return Container(
//       color: AppbackgroundColor.Sub_Abg_Colors,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           buildValueCell(
//             flex: 2,
//             '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${syslogModel[index].datex!}'))}',
//           ),
//           buildValueCell(
//             '${syslogModel[index].timex}',
//           ),
//           buildValueCell(
//             '${syslogModel[index].ip}',
//           ),
//           buildValueCell(
//             '${syslogModel[index].username}',
//           ),
//           buildValueCell(
//             '${syslogModel[index].frm}',
//           ),
//           buildValueCell(
//             flex: 2,
//             '${syslogModel[index].fdo}',
//           ),
//         ],
//       ),
//     );
//   }

// ////////////////////////////--------------------------------->
//   final Set<int> _expandedRows = {};

//   Widget buildValueCell(
//     String text, {
//     TextAlign align = TextAlign.start,
//     int flex = 1,
//     EdgeInsetsGeometry padding = const EdgeInsets.all(2.0),
//   }) {
//     return Expanded(
//       flex: flex,
//       child: Padding(
//         padding: padding,
//         child: Text(
//           text,
//           textAlign: align,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             color: PeopleChaoScreen_Color.Colors_Text1_,
//             fontFamily: Font_.Fonts_T,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _doccumentUi(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           colorFilter: new ColorFilter.mode(
//               Colors.white.withOpacity(0.05), BlendMode.dstATop),
//           image: AssetImage("images/BG_im2.png"),
//           fit: BoxFit.cover,
//         ),
//         color: AppbackgroundColor.Sub_Abg_Colors,
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(10),
//             topRight: Radius.circular(10),
//             bottomLeft: Radius.circular(10),
//             bottomRight: Radius.circular(10)),
//         // border: Border.all(color: Colors.white, width: 1),
//       ),
//       child: Column(
//         children: [
//           const Row(
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: AutoSizeText(
//                   minFontSize: 10,
//                   maxFontSize: 15,
//                   '4.เอกสาร/ค่าเช่า-ค่าบริการ',
//                   style: TextStyle(
//                       color: PeopleChaoScreen_Color.Colors_Text1_,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: FontWeight_.Fonts_T
//                       //fontSize: 10.0
//                       ),
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Text(
//                     'ประเภทเอกสารสัญญา',
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                         color: PeopleChaoScreen_Color.Colors_Text2_,
//                         // fontWeight: FontWeight.bold,
//                         fontFamily: Font_.Fonts_T
//                         //fontSize: 10.0
//                         ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: widget.Get_Value_NameShop_index == '2'
//                         ? SizedBox()
//                         : Container(
//                             decoration: BoxDecoration(
//                               color: AppbackgroundColor.Sub_Abg_Colors,
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10),
//                               ),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: DropdownButtonFormField2<String>(
//                               isExpanded: true,
//                               value: (cid_typePaper_ser != null &&
//                                       typePaperModels.any((e) =>
//                                           '${e.ser}' == '$cid_typePaper_ser'))
//                                   ? '$cid_typePaper_ser'
//                                   : null,
//                               items: typePaperModels.map((item) {
//                                 final value = '${item.ser}';
//                                 final label = '${item.p_type ?? ''}';
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(
//                                     label,
//                                     textAlign: TextAlign.center,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(
//                                         fontSize: 14, color: Colors.grey),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (String? value) async {
//                                 if (value == null) return;

//                                 final idx = typePaperModels
//                                     .indexWhere((e) => '${e.ser}' == value);
//                                 if (idx < 0) return;

//                                 setState(() {
//                                   cid_typePaper_ser = value;
//                                   cid_typePaper = typePaperModels[idx].p_type;
//                                 });

//                                 try {
//                                   final prefs =
//                                       await SharedPreferences.getInstance();
//                                   final ren = prefs.getString('renTalSer');

//                                   if (ren == null || ren.isEmpty) {
//                                     //  debug//print('renTalSer is null/empty');
//                                     return;
//                                   }

//                                   final url =
//                                       '${MyConstant().domain}/UP_Type_paper_cid.php?isAdd=true';

//                                   final response = await http.post(
//                                     Uri.parse(url),
//                                     body: {
//                                       'ren': ren,
//                                       'cid': '${widget.Get_Value_cid}',
//                                       'serpaper': '$cid_typePaper_ser',
//                                     },
//                                   );

//                                   if (response.statusCode != 200) {
//                                     //  debug//print(
//                                     //    'POST failed: ${response.statusCode} ${response.reasonPhrase}');
//                                   } else {
//                                     // debug//print(
//                                     //  'POST success: ${response.body}');
//                                   }
//                                 } catch (e) {
//                                   // debug//print('POST exception: $e');
//                                 }
//                               },
//                             )),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: SizedBox(),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: SizedBox(),
//                 ),
//               ],
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Text(
//                   'สำเนาบัตรประชาชนผู้เช่า',
//                   textAlign: TextAlign.start,
//                   style: TextStyle(
//                       color: PeopleChaoScreen_Color.Colors_Text2_,
//                       // fontWeight: FontWeight.bold,
//                       fontFamily: Font_.Fonts_T
//                       //fontSize: 10.0
//                       ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             height: 150,
//             decoration: BoxDecoration(
//               // color: AppbackgroundColor.Sub_Abg_Colors,
//               borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                   bottomLeft: Radius.circular(10),
//                   bottomRight: Radius.circular(10)),
//               border: Border.all(color: Colors.grey, width: 1),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: (cxname_card != null)
//                             ? Stack(
//                                 children: [
//                                   Container(
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                             bottomLeft: Radius.circular(10),
//                                             bottomRight: Radius.circular(10)),
//                                       ),
//                                       child: Image.network(
//                                         '${MyConstant().domain}/files/$foder/contract/card/$cxname_card',
//                                         // width: 200,
//                                         // height: 160,
//                                         fit: BoxFit.cover,
//                                       )
//                                       //  Center(
//                                       //   child: Column(
//                                       //     mainAxisAlignment: MainAxisAlignment.center,
//                                       //     children: [
//                                       //       Text(
//                                       //         'พบเอกสาร',
//                                       //         textAlign: TextAlign.center,
//                                       //         style: TextStyle(
//                                       //             color: PeopleChaoScreen_Color
//                                       //                 .Colors_Text2_,
//                                       //             // fontWeight: FontWeight.bold,
//                                       //             fontFamily: Font_.Fonts_T

//                                       //             //fontSize: 10.0
//                                       //             ),
//                                       //       ),
//                                       //       Text(
//                                       //         '$cxname_card',
//                                       //         textAlign: TextAlign.center,
//                                       //         style: TextStyle(
//                                       //             color: Colors.blue[800],
//                                       //             // fontWeight: FontWeight.bold,
//                                       //             fontFamily: Font_.Fonts_T,
//                                       //             fontSize: 8.0),
//                                       //       ),
//                                       //     ],
//                                       //   ),
//                                       // ),
//                                       ),
//                                   Positioned(
//                                     top: 20,
//                                     right: 10,
//                                     child: InkWell(
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color:
//                                               Colors.red[900]!.withOpacity(0.8),
//                                           borderRadius: const BorderRadius.only(
//                                               topLeft: Radius.circular(10),
//                                               topRight: Radius.circular(10),
//                                               bottomLeft: Radius.circular(10),
//                                               bottomRight: Radius.circular(10)),
//                                         ),
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: const Center(
//                                           child: Text(
//                                             'ดูเอกสาร',
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 // fontWeight: FontWeight.bold,
//                                                 fontFamily: Font_.Fonts_T

//                                                 //fontSize: 10.0
//                                                 ),
//                                           ),
//                                         ),
//                                       ),
//                                       onTap: () {
//                                         showDialog(
//                                           context: context,
//                                           builder: (_) => Dialog(
//                                             child: Stack(
//                                               children: [
//                                                 SizedBox(
//                                                   width: MediaQuery.of(context)
//                                                           .size
//                                                           .width *
//                                                       0.8,
//                                                   child: FittedBox(
//                                                     fit: BoxFit.contain,
//                                                     child: (cxname_card ==
//                                                                 null ||
//                                                             cxname_card
//                                                                     .toString() ==
//                                                                 '')
//                                                         ? const Icon(Icons
//                                                             .image_not_supported)
//                                                         : Image.network(
//                                                             '${MyConstant().domain}/files/$foder/contract/card/$cxname_card'),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                     top: 10,
//                                                     right: 10,
//                                                     child: InkWell(
//                                                       onTap: () {
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                       child: const Icon(
//                                                         Icons.cancel_outlined,
//                                                         size: 40,
//                                                         color: Colors.red,
//                                                       ),
//                                                     ))
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   )
//                                 ],
//                               )
//                             : Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[300],
//                                   borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(10),
//                                       topRight: Radius.circular(10),
//                                       bottomLeft: Radius.circular(10),
//                                       bottomRight: Radius.circular(10)),
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     'ไม่พบเอกสาร',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: PeopleChaoScreen_Color
//                                             .Colors_Text2_,
//                                         // fontWeight: FontWeight.bold,
//                                         fontFamily: Font_.Fonts_T

//                                         //fontSize: 10.0
//                                         ),
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (Responsive.isDesktop(context))
//                   Expanded(
//                     flex: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           // color: Colors.grey,
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(10),
//                               topRight: Radius.circular(10),
//                               bottomLeft: Radius.circular(10),
//                               bottomRight: Radius.circular(10)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   flex: 2,
//                   child: Row(
//                     children: [
//                       // Expanded(
//                       //   flex: 1,
//                       //   child: Padding(
//                       //     padding: const EdgeInsets.all(8.0),
//                       //     child: Container(
//                       //       decoration: const BoxDecoration(
//                       //         color: Colors.red,
//                       //         borderRadius: BorderRadius.only(
//                       //             topLeft: Radius.circular(10),
//                       //             topRight: Radius.circular(10),
//                       //             bottomLeft: Radius.circular(10),
//                       //             bottomRight: Radius.circular(10)),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),

//                       Expanded(
//                         flex: 1,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               // color: Colors.white,
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: InkWell(
//                                     child: Container(
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         color: Colors.blue[300],
//                                         borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                             bottomLeft: Radius.circular(10),
//                                             bottomRight: Radius.circular(10)),
//                                       ),
//                                       child: const Center(
//                                         child: Text(
//                                           'อัพโหลดไฟล์ ( jpeg,png,jpg )',
//                                           textAlign: TextAlign.start,
//                                           style: TextStyle(
//                                               color: PeopleChaoScreen_Color
//                                                   .Colors_Text2_,
//                                               fontWeight: FontWeight.w400,
//                                               fontFamily: Font_.Fonts_T),
//                                         ),
//                                       ),
//                                     ),
//                                     onTap: () async {
//                                       (cxname_card == null)
//                                           ? uploadFile_IDcard(
//                                               '${cxname_card}',
//                                               ' $cxname_card_ser',
//                                             )
//                                           : showDialog<void>(
//                                               context: context,
//                                               barrierDismissible:
//                                                   false, // user must tap button!
//                                               builder: (BuildContext context) {
//                                                 return AlertDialog(
//                                                   shape:
//                                                       const RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.all(
//                                                                   Radius.circular(
//                                                                       10.0))),
//                                                   title: const Center(
//                                                       child: Text(
//                                                     'มีเอกสารสำเนาบัตรประชาชนอยู่แล้ว',
//                                                     style: TextStyle(
//                                                         color:
//                                                             PeopleChaoScreen_Color
//                                                                 .Colors_Text1_,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontFamily: FontWeight_
//                                                             .Fonts_T),
//                                                   )),
//                                                   content:
//                                                       const SingleChildScrollView(
//                                                     child: ListBody(
//                                                       children: <Widget>[
//                                                         Text(
//                                                           'มีเอกสารสำเนาบัตรประชาชนอยู่แล้ว หากต้องการอัพโหลดกรุณาลบเอกสารที่มีอยู่แล้วก่อน',
//                                                           style: TextStyle(
//                                                               color: PeopleChaoScreen_Color
//                                                                   .Colors_Text2_,
//                                                               fontFamily: Font_
//                                                                   .Fonts_T),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   actions: <Widget>[
//                                                     Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: InkWell(
//                                                             child: Container(
//                                                                 width: 100,
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .red[600],
//                                                                   borderRadius: const BorderRadius
//                                                                           .only(
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
//                                                                   // border: Border.all(color: Colors.white, width: 1),
//                                                                 ),
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .all(
//                                                                         8.0),
//                                                                 child:
//                                                                     const Center(
//                                                                         child:
//                                                                             Text(
//                                                                   'ลบเอกสาร',
//                                                                   style: TextStyle(
//                                                                       color: PeopleChaoScreen_Color
//                                                                           .Colors_Text3_,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       fontFamily:
//                                                                           Font_
//                                                                               .Fonts_T),
//                                                                 ))),
//                                                             onTap: () async {
//                                                               //String fileName, String ser, String Pathfoder,    String PathfoderSub

//                                                               deletedFile_(
//                                                                   '${cxname_card}',
//                                                                   ' $cxname_card_ser',
//                                                                   'card');
//                                                               deletedFile_SQL(
//                                                                   '$cxname_card_ser');

//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop();
//                                                             },
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: InkWell(
//                                                             child: Container(
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
//                                                                   // border: Border.all(color: Colors.white, width: 1),
//                                                                 ),
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                             .all(
//                                                                         8.0),
//                                                                 child:
//                                                                     const Center(
//                                                                         child:
//                                                                             Text(
//                                                                   'ปิด',
//                                                                   style: TextStyle(
//                                                                       color: PeopleChaoScreen_Color
//                                                                           .Colors_Text3_,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       fontFamily:
//                                                                           Font_
//                                                                               .Fonts_T),
//                                                                 ))),
//                                                             onTap: () {
//                                                               GC_contractf();
//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop();
//                                                             },
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 );
//                                               },
//                                             );
//                                     },
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     // Expanded(
//                                     //   flex: 1,
//                                     //   child: Padding(
//                                     //     padding: const EdgeInsets.all(8.0),
//                                     //     child: InkWell(
//                                     //       child: Container(
//                                     //         height: 40,
//                                     //         decoration: BoxDecoration(
//                                     //           color: Colors.red[400],
//                                     //           borderRadius:
//                                     //               const BorderRadius.only(
//                                     //                   topLeft:
//                                     //                       Radius.circular(10),
//                                     //                   topRight:
//                                     //                       Radius.circular(10),
//                                     //                   bottomLeft:
//                                     //                       Radius.circular(10),
//                                     //                   bottomRight:
//                                     //                       Radius.circular(
//                                     //                           10)),
//                                     //         ),
//                                     //         child: const Center(
//                                     //           child: Text(
//                                     //             'ลบ(PDF)',
//                                     //             textAlign: TextAlign.start,
//                                     //             style: TextStyle(
//                                     //                 color:
//                                     //                     PeopleChaoScreen_Color
//                                     //                         .Colors_Text2_,
//                                     //                 // fontWeight: FontWeight.bold,
//                                     //                 fontFamily: Font_.Fonts_T
//                                     //                 //fontSize: 10.0
//                                     //                 ),
//                                     //           ),
//                                     //         ),
//                                     //       ),
//                                     //       onTap: () async {
//                                     //         // deletedFile_('${cxname_card}',
//                                     //         //     ' $cxname_card_ser');

//                                     //         // deletedFile_('${cxname_card}',
//                                     //         //     ' $cxname_card_ser', 'card');
//                                     //         // deletedFile_SQL(
//                                     //         //     '$cxname_card_ser');
//                                     //       },
//                                     //     ),
//                                     //   ),
//                                     // ),
//                                     Expanded(
//                                       flex: 1,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: InkWell(
//                                           child: Container(
//                                             height: 40,
//                                             decoration: BoxDecoration(
//                                               color: Colors.orange[300],
//                                               borderRadius:
//                                                   const BorderRadius.only(
//                                                       topLeft:
//                                                           Radius.circular(10),
//                                                       topRight:
//                                                           Radius.circular(10),
//                                                       bottomLeft:
//                                                           Radius.circular(10),
//                                                       bottomRight:
//                                                           Radius.circular(10)),
//                                             ),
//                                             child: const Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Padding(
//                                                   padding: EdgeInsets.all(4.0),
//                                                   child: Icon(
//                                                     Icons.print,
//                                                     color: Colors.black,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   'พิมพ์',
//                                                   textAlign: TextAlign.start,
//                                                   style: TextStyle(
//                                                       color:
//                                                           PeopleChaoScreen_Color
//                                                               .Colors_Text2_,
//                                                       fontWeight:
//                                                           FontWeight.w400,
//                                                       fontFamily:
//                                                           Font_.Fonts_T),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           onTap: () async {
//                                             String Url =
//                                                 await '${MyConstant().domain}/files/$foder/contract/card/$cxname_card';
//                                             //print(Url);
//                                             Idcard_(context, Url);
//                                             // String Url =
//                                             //     'https://www.etda.or.th/getattachment/78750426-4a58-4c36-85d3-d1c11c3db1f3/IUB-65-Final.pdf.aspx';
//                                             // if (Url == '') {
//                                             //   showDialog<void>(
//                                             //     context: context,
//                                             //     barrierDismissible:
//                                             //         false, // user must tap button!
//                                             //     builder:
//                                             //         (BuildContext context) {
//                                             //       return AlertDialog(
//                                             //         shape: const RoundedRectangleBorder(
//                                             //             borderRadius:
//                                             //                 BorderRadius.all(
//                                             //                     Radius.circular(
//                                             //                         10.0))),
//                                             //         title: const Center(
//                                             //             child: Text(
//                                             //           'ไม่พบสำเนาบัตรประชาชน',
//                                             //           style: TextStyle(
//                                             //               color: PeopleChaoScreen_Color
//                                             //                   .Colors_Text1_,
//                                             //               fontWeight:
//                                             //                   FontWeight.bold,
//                                             //               fontFamily:
//                                             //                   FontWeight_
//                                             //                       .Fonts_T),
//                                             //         )),
//                                             //         content:
//                                             //             SingleChildScrollView(
//                                             //           child: ListBody(
//                                             //             children: const <
//                                             //                 Widget>[
//                                             //               Text(
//                                             //                 'ไม่พบเอกสาร หรือ กรุณาอัพโหลดก่อน จึงจะสามารถพิมพ์ได้',
//                                             //                 style: TextStyle(
//                                             //                     color: PeopleChaoScreen_Color
//                                             //                         .Colors_Text2_,
//                                             //                     fontFamily: Font_
//                                             //                         .Fonts_T),
//                                             //               ),
//                                             //             ],
//                                             //           ),
//                                             //         ),
//                                             //         actions: <Widget>[
//                                             //           InkWell(
//                                             //             child: Container(
//                                             //                 width: 100,
//                                             //                 decoration:
//                                             //                     const BoxDecoration(
//                                             //                   color: Colors
//                                             //                       .black,
//                                             //                   borderRadius: BorderRadius.only(
//                                             //                       topLeft: Radius
//                                             //                           .circular(
//                                             //                               10),
//                                             //                       topRight: Radius
//                                             //                           .circular(
//                                             //                               10),
//                                             //                       bottomLeft:
//                                             //                           Radius.circular(
//                                             //                               10),
//                                             //                       bottomRight:
//                                             //                           Radius.circular(
//                                             //                               10)),
//                                             //                   // border: Border.all(color: Colors.white, width: 1),
//                                             //                 ),
//                                             //                 padding:
//                                             //                     const EdgeInsets
//                                             //                         .all(8.0),
//                                             //                 child:
//                                             //                     const Center(
//                                             //                         child:
//                                             //                             Text(
//                                             //                   'ปิด',
//                                             //                   style: TextStyle(
//                                             //                       color: PeopleChaoScreen_Color
//                                             //                           .Colors_Text3_,
//                                             //                       fontWeight:
//                                             //                           FontWeight
//                                             //                               .bold,
//                                             //                       fontFamily:
//                                             //                           Font_
//                                             //                               .Fonts_T),
//                                             //                 ))),
//                                             //             onTap: () {
//                                             //               Navigator.of(
//                                             //                       context)
//                                             //                   .pop();
//                                             //             },
//                                             //           ),
//                                             //           // TextButton(
//                                             //           //   child: const Text('ตกลง'),
//                                             //           //   onPressed: () {
//                                             //           //     Navigator.of(context).pop();
//                                             //           //   },
//                                             //           // ),
//                                             //         ],
//                                             //       );
//                                             //     },
//                                             //   );
//                                             // } else {
//                                             //   Navigator.push(
//                                             //       context,
//                                             //       MaterialPageRoute(
//                                             //         builder: (context) =>
//                                             //             PreviewScreenRental_(
//                                             //                 title:
//                                             //                     'สำเนาบัตรประชาชน',
//                                             //                 Url: Url),
//                                             //       ));
//                                             // }
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Text(
//                   'เอกสารสัญญาเช่า',
//                   textAlign: TextAlign.start,
//                   style: TextStyle(
//                       color: PeopleChaoScreen_Color.Colors_Text2_,
//                       // fontWeight: FontWeight.bold,
//                       fontFamily: Font_.Fonts_T
//                       //fontSize: 10.0
//                       ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             // height: 150,
//             decoration: BoxDecoration(
//               // color: AppbackgroundColor.Sub_Abg_Colors,
//               borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                   bottomLeft: Radius.circular(10),
//                   bottomRight: Radius.circular(10)),
//               border: Border.all(color: Colors.grey, width: 1),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     child: Column(
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(
//                             'เอกสารสัญญาเช่า(ต้นฉบับ)',
//                             maxLines: 2,
//                             textAlign: TextAlign.start,
//                             style: TextStyle(
//                                 color: PeopleChaoScreen_Color.Colors_Text2_,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: FontWeight_.Fonts_T
//                                 //fontSize: 10.0
//                                 ),
//                           ),
//                         ),
//                         (renTal_user.toString() == '90' ||
//                                 renTal_user.toString() == '50')
//                             ? SizedBox()
//                             : SizedBox(
//                                 height: 0,
//                               ),
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: InkWell(
//                                   child: Container(
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.orange[300],
//                                       borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10),
//                                           bottomLeft: Radius.circular(10),
//                                           bottomRight: Radius.circular(10)),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         const Padding(
//                                           padding: EdgeInsets.all(4.0),
//                                           child: Icon(
//                                             Icons.print,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                         Text(
//                                           'พิมพ์',
//                                           textAlign: TextAlign.start,
//                                           style: const TextStyle(
//                                               color: PeopleChaoScreen_Color
//                                                   .Colors_Text2_,
//                                               fontWeight: FontWeight.w400,
//                                               fontFamily: Font_.Fonts_T),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   onTap: () async {
//                                     //print('base64Image');
//                                     // //print(base64Image);
//                                     List newValuePDFimg = [];
//                                     for (int index = 0; index < 1; index++) {
//                                       if (renTalModels[0].imglogo!.trim() ==
//                                           '') {
//                                         // newValuePDFimg.add(
//                                         //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
//                                       } else {
//                                         newValuePDFimg.add(
//                                             '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//                                         newValuePDFimg.add(
//                                             '${MyConstant().domain}/files/$foder/contract/${renTalModels[0].img}');
//                                       }
//                                     }
//                                     SharedPreferences preferences =
//                                         await SharedPreferences.getInstance();
//                                     var ren =
//                                         preferences.getString('renTalSer');
//                                     var renTal_name =
//                                         preferences.getString('renTalName');

//                                     final tableData00 = [
//                                       for (int index = 0;
//                                           index < quotxSelectModels.length;
//                                           index++)
//                                         [
//                                           '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
//                                           '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
//                                           '${quotxSelectModels[index].expname}',
//                                           '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
//                                           '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
//                                           '${nFormat.format(double.parse(quotxSelectModels[index].pvat!))}',
//                                           '${nFormat.format(double.parse(quotxSelectModels[index].vat!))}',
//                                           '${nFormat.format(double.parse(quotxSelectModels[index].qty!))}', // หน่วยละ
//                                           '${nFormat.format(double.parse(quotxSelectModels[index].amt!))}',
//                                         ],
//                                     ];
//                                     _showMyDialog_SAVE(context, tableData00,
//                                         newValuePDFimg, ren, 1);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         // if (renTal_user.toString() == '90' ||
//                         //     renTal_user.toString() == '50' ||
//                         //     renTal_user.toString() == '106')
//                         Container(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
//                                 child: Text(
//                                   (renTal_user.toString() == '106')
//                                       ? 'เอกสารแนบท้ายสัญญา (ชอยส์ มินิสโตร์ จำกัด)'
//                                       : 'เอกสารแนบท้ายสัญญา (ถ้ามี)',
//                                   maxLines: 2,
//                                   textAlign: TextAlign.start,
//                                   style: TextStyle(
//                                       color:
//                                           PeopleChaoScreen_Color.Colors_Text2_,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: FontWeight_.Fonts_T
//                                       //fontSize: 10.0
//                                       ),
//                                 ),
//                               ),
//                               if (renTal_user.toString() != '106')
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(8, 2, 8, 2),
//                                   child: Container(
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[600]!.withOpacity(0.5),
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(6)),
//                                       border: Border.all(
//                                           color: Colors.grey, width: 1),
//                                     ),
//                                     padding: const EdgeInsets.fromLTRB(
//                                         0.5, 0.5, 0.5, 0.5),
//                                     child: TextFormField(
//                                       keyboardType: TextInputType.number,
//                                       controller: Title_text,
//                                       textAlign: TextAlign.start,
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'ระบุข้อมูล..';
//                                         }
//                                         return null;
//                                       },
//                                       maxLines: 1,

//                                       // maxLength: 1,
//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                         fillColor: Colors.white,
//                                         filled: true,
//                                         // prefixIcon:
//                                         //     const Icon(Icons.key, color: Colors.black),
//                                         // suffixIcon: Icon(Icons.clear, color: Colors.black),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(6)),
//                                           borderSide: BorderSide(
//                                             width: 1,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         enabledBorder: const OutlineInputBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(6)),
//                                           borderSide: BorderSide(
//                                             width: 1,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         labelText: 'เพิ่มหัวข้อ',
//                                         labelStyle: const TextStyle(
//                                             color: PeopleChaoScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight: FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T),
//                                       ),
//                                       // inputFormatters: [
//                                       //   FilteringTextInputFormatter
//                                       //       .allow(RegExp(
//                                       //           r'^\d*\.?\d*$')), // Allows digits & one dot
//                                       // ],
//                                     ),
//                                   ),
//                                 ),
//                               if (renTal_user.toString() != '106')
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Container(
//                                     // height: 35,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey[600]!.withOpacity(0.5),
//                                       borderRadius:
//                                           BorderRadius.all(Radius.circular(6)),
//                                       border: Border.all(
//                                           color: Colors.grey, width: 1),
//                                     ),
//                                     padding: const EdgeInsets.fromLTRB(
//                                         0.5, 0.5, 0.5, 0.5),
//                                     child: TextFormField(
//                                       keyboardType: TextInputType.number,
//                                       controller: Details_text,
//                                       textAlign: TextAlign.start,
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'ระบุข้อมูล..';
//                                         }
//                                         return null;
//                                       },

//                                       maxLines: 5,
//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                         fillColor: Colors.white,
//                                         filled: true,
//                                         // prefixIcon:
//                                         //     const Icon(Icons.key, color: Colors.black),
//                                         // suffixIcon: Icon(Icons.clear, color: Colors.black),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(6)),
//                                           borderSide: BorderSide(
//                                             width: 1,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         enabledBorder: const OutlineInputBorder(
//                                           borderRadius: BorderRadius.all(
//                                               Radius.circular(6)),
//                                           borderSide: BorderSide(
//                                             width: 1,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         labelText: 'เพิ่มรายละอียด',
//                                         labelStyle: const TextStyle(
//                                             color: PeopleChaoScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight: FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T),
//                                       ),
//                                       // inputFormatters: [
//                                       //   FilteringTextInputFormatter
//                                       //       .allow(RegExp(
//                                       //           r'^\d*\.?\d*$')), // Allows digits & one dot
//                                       // ],
//                                     ),
//                                   ),
//                                 ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 1,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: InkWell(
//                                         child: Container(
//                                           height: 40,
//                                           decoration: BoxDecoration(
//                                             color: Colors.blueGrey[300],
//                                             borderRadius: const BorderRadius
//                                                     .only(
//                                                 topLeft: Radius.circular(10),
//                                                 topRight: Radius.circular(10),
//                                                 bottomLeft: Radius.circular(10),
//                                                 bottomRight:
//                                                     Radius.circular(10)),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               const Padding(
//                                                 padding: EdgeInsets.all(4.0),
//                                                 child: Icon(
//                                                   Icons.print,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 'พิมพ์',
//                                                 textAlign: TextAlign.start,
//                                                 style: const TextStyle(
//                                                     color:
//                                                         PeopleChaoScreen_Color
//                                                             .Colors_Text2_,
//                                                     fontWeight: FontWeight.w400,
//                                                     fontFamily: Font_.Fonts_T),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         onTap: () async {
//                                           //print('base64Image');
//                                           // //print(base64Image);
//                                           List newValuePDFimg = [];
//                                           for (int index = 0;
//                                               index < 1;
//                                               index++) {
//                                             if (renTalModels[0]
//                                                     .imglogo!
//                                                     .trim() ==
//                                                 '') {
//                                               // newValuePDFimg.add(
//                                               //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
//                                             } else {
//                                               newValuePDFimg.add(
//                                                   '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//                                               newValuePDFimg.add(
//                                                   '${MyConstant().domain}/files/$foder/contract/${renTalModels[0].img}');
//                                             }
//                                           }
//                                           SharedPreferences preferences =
//                                               await SharedPreferences
//                                                   .getInstance();
//                                           var ren = preferences
//                                               .getString('renTalSer');
//                                           var renTal_name = preferences
//                                               .getString('renTalName');

//                                           final tableData00 = [
//                                             for (int index = 0;
//                                                 index <
//                                                     quotxSelectModels.length;
//                                                 index++)
//                                               [
//                                                 '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
//                                                 '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
//                                                 '${quotxSelectModels[index].expname}',
//                                                 '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
//                                                 '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
//                                               ],
//                                           ];
//                                           _showMyDialog_SAVE(
//                                               context,
//                                               tableData00,
//                                               newValuePDFimg,
//                                               ren,
//                                               2);
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     child: Column(
//                       children: [
//                         if (renTal_user.toString() != '106')
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               'เอกสารแนบท้าย รายละเอียดค่าเช่า',
//                               textAlign: TextAlign.start,
//                               style: const TextStyle(
//                                   color: PeopleChaoScreen_Color.Colors_Text2_,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: FontWeight_.Fonts_T
//                                   //fontSize: 10.0
//                                   ),
//                             ),
//                           ),
//                         if (renTal_user.toString() != '106')
//                           InkWell(
//                             child: Container(
//                               width: 200,
//                               // height: 40,
//                               decoration: BoxDecoration(
//                                 color: Colors.blueGrey[300],
//                                 borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(10),
//                                     topRight: Radius.circular(10),
//                                     bottomLeft: Radius.circular(10),
//                                     bottomRight: Radius.circular(10)),
//                               ),

//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.all(4.0),
//                                     child: Icon(
//                                       Icons.print,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'พิมพ์',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           color: PeopleChaoScreen_Color
//                                               .Colors_Text2_,
//                                           fontWeight: FontWeight.w400,
//                                           fontFamily: Font_.Fonts_T),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             onTap: () async {
//                               List newValuePDFimg = [];
//                               for (int index = 0; index < 1; index++) {
//                                 if (renTalModels[0].imglogo!.trim() == '') {
//                                   // newValuePDFimg.add(
//                                   //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
//                                 } else {
//                                   newValuePDFimg.add(
//                                       '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
//                                 }
//                               }
//                               SharedPreferences preferences =
//                                   await SharedPreferences.getInstance();
//                               var renTal_name =
//                                   preferences.getString('renTalName');
//                               String? ren = preferences.getString('renTalSer');
//                               _showMyDialog_SAVE3(context, newValuePDFimg, ren);
//                             },
//                           ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'เอกสารอื่นๆ ${Other_file.length} รายการ',
//                             textAlign: TextAlign.start,
//                             style: const TextStyle(
//                                 color: PeopleChaoScreen_Color.Colors_Text2_,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: FontWeight_.Fonts_T
//                                 //fontSize: 10.0
//                                 ),
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   height: (renTal_user.toString() != '106')
//                                       ? 180
//                                       : 70,
//                                   padding: const EdgeInsets.all(4.0),
//                                   decoration: BoxDecoration(
//                                     // color: Colors.green,
//                                     borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(8),
//                                         topRight: Radius.circular(8),
//                                         bottomLeft: Radius.circular(8),
//                                         bottomRight: Radius.circular(8)),
//                                     border: Border.all(
//                                         color: Colors.grey, width: 2),
//                                   ),
//                                   child: ScrollConfiguration(
//                                     behavior: ScrollConfiguration.of(context)
//                                         .copyWith(dragDevices: {
//                                       PointerDeviceKind.touch,
//                                       PointerDeviceKind.mouse,
//                                     }),
//                                     child: SingleChildScrollView(
//                                       scrollDirection: Axis.horizontal,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           for (int index = 0;
//                                               index < Other_file.length;
//                                               index++)
//                                             Stack(
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: InkWell(
//                                                     onTap: () async {
//                                                       // String Url =
//                                                       //     'https://www.etda.or.th/getattachment/78750426-4a58-4c36-85d3-d1c11c3db1f3/IUB-65-Final.pdf.aspx';
//                                                       String Url =
//                                                           await '${MyConstant().domain}/files/$foder/contract/other/${Other_file[index].filename}';
//                                                       //print(Url);
//                                                       if (Url == '') {
//                                                         showDialog<void>(
//                                                           context: context,
//                                                           barrierDismissible:
//                                                               false, // user must tap button!
//                                                           builder: (BuildContext
//                                                               context) {
//                                                             return AlertDialog(
//                                                               shape: const RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.all(
//                                                                           Radius.circular(
//                                                                               10.0))),
//                                                               title:
//                                                                   const Center(
//                                                                       child:
//                                                                           Text(
//                                                                 'ไม่พบเอกสารอื่นๆ',
//                                                                 style: TextStyle(
//                                                                     color: PeopleChaoScreen_Color
//                                                                         .Colors_Text1_,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                     fontFamily:
//                                                                         FontWeight_
//                                                                             .Fonts_T),
//                                                               )),
//                                                               content:
//                                                                   const SingleChildScrollView(
//                                                                 child: ListBody(
//                                                                   children: <Widget>[
//                                                                     Text(
//                                                                       'ไม่พบเอกสาร หรือ กรุณาอัพโหลดก่อน จึงจะสามารถพิมพ์ได้',
//                                                                       style: TextStyle(
//                                                                           color: PeopleChaoScreen_Color
//                                                                               .Colors_Text2_,
//                                                                           fontFamily:
//                                                                               Font_.Fonts_T),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                               actions: <Widget>[
//                                                                 InkWell(
//                                                                   child: Container(
//                                                                       width: 100,
//                                                                       decoration: const BoxDecoration(
//                                                                         color: Colors
//                                                                             .black,
//                                                                         borderRadius: BorderRadius.only(
//                                                                             topLeft:
//                                                                                 Radius.circular(10),
//                                                                             topRight: Radius.circular(10),
//                                                                             bottomLeft: Radius.circular(10),
//                                                                             bottomRight: Radius.circular(10)),
//                                                                         // border: Border.all(color: Colors.white, width: 1),
//                                                                       ),
//                                                                       padding: const EdgeInsets.all(8.0),
//                                                                       child: const Center(
//                                                                           child: Text(
//                                                                         'ปิด',
//                                                                         style: TextStyle(
//                                                                             color:
//                                                                                 PeopleChaoScreen_Color.Colors_Text3_,
//                                                                             fontWeight: FontWeight.bold,
//                                                                             fontFamily: Font_.Fonts_T),
//                                                                       ))),
//                                                                   onTap: () {
//                                                                     Navigator.of(
//                                                                             context)
//                                                                         .pop();
//                                                                   },
//                                                                 ),
//                                                                 // TextButton(
//                                                                 //   child: const Text('ตกลง'),
//                                                                 //   onPressed: () {
//                                                                 //     Navigator.of(context).pop();
//                                                                 //   },
//                                                                 // ),
//                                                               ],
//                                                             );
//                                                           },
//                                                         );
//                                                       } else {
//                                                         Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   PreviewScreenRental_(
//                                                                       title:
//                                                                           'เอกสารอื่นๆ',
//                                                                       Url: Url),
//                                                             ));
//                                                       }
//                                                     },
//                                                     child: Container(
//                                                         width: 150,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color: Colors.white,
//                                                           borderRadius: const BorderRadius
//                                                                   .only(
//                                                               topLeft: Radius
//                                                                   .circular(8),
//                                                               topRight: Radius
//                                                                   .circular(8),
//                                                               bottomLeft: Radius
//                                                                   .circular(8),
//                                                               bottomRight:
//                                                                   Radius
//                                                                       .circular(
//                                                                           8)),
//                                                           border: Border.all(
//                                                               color:
//                                                                   Colors.grey,
//                                                               width: 2),
//                                                         ),
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8.0),
//                                                         child: Text(
//                                                           '${Other_file[index].filename}',
//                                                           style: TextStyle(
//                                                               color: Colors
//                                                                   .blue[800],
//                                                               // fontWeight: FontWeight.bold,
//                                                               fontFamily:
//                                                                   Font_.Fonts_T,
//                                                               fontSize: 12.0),
//                                                         )),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                     top: 0,
//                                                     right: 2,
//                                                     child: InkWell(
//                                                       child: const Icon(
//                                                         Icons.close_sharp,
//                                                         color: Colors.red,
//                                                       ),
//                                                       onTap: () {
//                                                         showDialog<void>(
//                                                           context: context,
//                                                           barrierDismissible:
//                                                               false, // user must tap button!
//                                                           builder: (BuildContext
//                                                               context) {
//                                                             return AlertDialog(
//                                                               shape: const RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.all(
//                                                                           Radius.circular(
//                                                                               10.0))),
//                                                               title:
//                                                                   const Center(
//                                                                       child:
//                                                                           Text(
//                                                                 'ลบเอกสาร',
//                                                                 style: TextStyle(
//                                                                     color: PeopleChaoScreen_Color
//                                                                         .Colors_Text1_,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                     fontFamily:
//                                                                         FontWeight_
//                                                                             .Fonts_T),
//                                                               )),
//                                                               actions: <Widget>[
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .center,
//                                                                   children: [
//                                                                     Padding(
//                                                                       padding:
//                                                                           const EdgeInsets.all(
//                                                                               8.0),
//                                                                       child:
//                                                                           InkWell(
//                                                                         child: Container(
//                                                                             width: 100,
//                                                                             decoration: BoxDecoration(
//                                                                               color: Colors.red[600],
//                                                                               borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
//                                                                               // border: Border.all(color: Colors.white, width: 1),
//                                                                             ),
//                                                                             padding: const EdgeInsets.all(8.0),
//                                                                             child: const Center(
//                                                                                 child: Text(
//                                                                               'ลบเอกสาร',
//                                                                               style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text3_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
//                                                                             ))),
//                                                                         onTap:
//                                                                             () async {
//                                                                           deletedFile_(
//                                                                               '${Other_file[index].filename}',
//                                                                               ' ${Other_file[index].ser}',
//                                                                               'other');

//                                                                           deletedFile_SQL(
//                                                                               '${Other_file[index].ser}');
//                                                                           GC_contractf();
//                                                                           Navigator.of(context)
//                                                                               .pop();
//                                                                         },
//                                                                       ),
//                                                                     ),
//                                                                     Padding(
//                                                                       padding:
//                                                                           const EdgeInsets.all(
//                                                                               8.0),
//                                                                       child:
//                                                                           InkWell(
//                                                                         child: Container(
//                                                                             width: 100,
//                                                                             decoration: const BoxDecoration(
//                                                                               color: Colors.black,
//                                                                               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
//                                                                               // border: Border.all(color: Colors.white, width: 1),
//                                                                             ),
//                                                                             padding: const EdgeInsets.all(8.0),
//                                                                             child: const Center(
//                                                                                 child: Text(
//                                                                               'ปิด',
//                                                                               style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text3_, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
//                                                                             ))),
//                                                                         onTap:
//                                                                             () {
//                                                                           GC_contractf();
//                                                                           Navigator.of(context)
//                                                                               .pop();
//                                                                         },
//                                                                       ),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             );
//                                                           },
//                                                         );
//                                                       },
//                                                     ))
//                                               ],
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: InkWell(
//                                   child: Container(
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue[300],
//                                       borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10),
//                                           bottomLeft: Radius.circular(10),
//                                           bottomRight: Radius.circular(10)),
//                                     ),
//                                     child: const Center(
//                                       child: Text(
//                                         'อัพโหลดไฟล์(PDF)',
//                                         textAlign: TextAlign.start,
//                                         style: TextStyle(
//                                             color: PeopleChaoScreen_Color
//                                                 .Colors_Text2_,
//                                             fontWeight: FontWeight.w400,
//                                             fontFamily: Font_.Fonts_T
//                                             //fontSize: 10.0
//                                             ),
//                                       ),
//                                     ),
//                                   ),
//                                   onTap: () async {
//                                     uploadFile_Documentmore(
//                                       '${cxname_other}',
//                                       ' $cxname_other_ser',
//                                     );
//                                     SharedPreferences preferences =
//                                         await SharedPreferences.getInstance();
//                                     var name = preferences.getString('fname');
//                                     Insert_log.Insert_logs('สัญญาเช่า',
//                                         '$name>สัญญา${widget.Get_Value_cid}>อัพโหลดเอกสารอื่นๆ');
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _expCidUi(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         // image: DecorationImage(
//         //   colorFilter: new ColorFilter.mode(
//         //       Colors.white.withOpacity(0.05), BlendMode.dstATop),
//         //   image: AssetImage("images/BG_im2.png"),
//         //   fit: BoxFit.cover,
//         // ),
//         color: AppbackgroundColor.Sub_Abg_Colors,
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(10),
//             topRight: Radius.circular(10),
//             bottomLeft: Radius.circular(10),
//             bottomRight: Radius.circular(10)),
//         // border: Border.all(color: Colors.white, width: 1),
//       ),
//       child: Column(
//         children: [
//           renTal_lavel <= 3
//               ? SizedBox()
//               : widget.Get_Value_NameShop_index.toString() != '1'
//                   ? SizedBox()
//                   : Container(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 setState(() {
//                                   if (ser_tabbarview_2 == 2) {
//                                     ser_tabbarview_2 = 0;
//                                   } else {
//                                     ser_tabbarview_2 = 2;
//                                   }
//                                 });

//                                 SharedPreferences preferences =
//                                     await SharedPreferences.getInstance();
//                                 String? ren =
//                                     preferences.getString('renTalSer');
//                                 String? ser_user = preferences.getString('ser');
//                                 var name = preferences.getString('fname');
//                                 Insert_log.Insert_logs('สัญญาเช่า',
//                                     '$name>สัญญา${widget.Get_Value_cid}>เพิ่มค่าบริการ');
//                                 String url2 =
//                                     '${MyConstant().domain}/D_quotx.php?isAdd=true&ren=$ren&ser_user=$ser_user';

//                                 try {
//                                   var response2 =
//                                       await http.get(Uri.parse(url2));

//                                   var result2 = json.decode(response2.body);
//                                   //print(result2);
//                                   if (result2.toString() == 'true') {}
//                                 } catch (e) {}
//                               },
//                               style: ButtonStyle(
//                                 //  backgroundColor:
//                                 // MaterialStateProperty.all<
//                                 //     Color>(Colors.green),
//                                 backgroundColor:
//                                     MaterialStateProperty.all<Color>(
//                                         Color.fromARGB(255, 52, 37, 184)),
//                               ),
//                               child: Center(
//                                 child: Translate.TranslateAndSetText(
//                                     ser_tabbarview_2 == 2
//                                         ? 'ยกเลิกเพิ่มค่าบริการ'
//                                         : 'เพิ่มค่าบริการ',
//                                     Colors.white,
//                                     TextAlign.start,
//                                     null,
//                                     Font_.Fonts_T,
//                                     14,
//                                     1),
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 setState(() {
//                                   if (ser_tabbarview_2 == 1) {
//                                     ser_tabbarview_2 = 0;
//                                   } else {
//                                     ser_tabbarview_2 = 1;
//                                   }
//                                 });

//                                 SharedPreferences preferences =
//                                     await SharedPreferences.getInstance();
//                                 var name = preferences.getString('fname');
//                                 Insert_log.Insert_logs('สัญญาเช่า',
//                                     '$name>สัญญา${widget.Get_Value_cid}>ปรับตั้งหนี้');
//                               },
//                               style: ButtonStyle(
//                                 //  backgroundColor:
//                                 // MaterialStateProperty.all<
//                                 //     Color>(Colors.green),
//                                 backgroundColor:
//                                     MaterialStateProperty.all<Color>(
//                                         Color.fromARGB(255, 184, 79, 37)),
//                               ),
//                               child: Center(
//                                 child: Translate.TranslateAndSetText(
//                                     ser_tabbarview_2 == 1
//                                         ? 'ยกเลิกปรับตั้งหนี้'
//                                         : 'ปรับตั้งหนี้',
//                                     Colors.white,
//                                     TextAlign.start,
//                                     null,
//                                     Font_.Fonts_T,
//                                     14,
//                                     1),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//           ser_tabbarview_2 == 0
//               ? SizedBox(
//                   width: 10,
//                 )
//               : ser_tabbarview_2 == 1
//                   ? SettringListMenu(
//                       Get_Value_cid: widget.Get_Value_cid,
//                       Get_Value_NameShop_index: widget.Get_Value_NameShop_index)
//                   : ChaoReContactAdd(
//                       Value_cid: widget.Get_Value_cid,
//                     ),
//           ser_tabbarview_2 != 0
//               ? SizedBox()
//               : SizedBox(
//                   child: Column(
//                     children: [
//                       const Row(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: AutoSizeText(
//                               minFontSize: 10,
//                               maxFontSize: 15,
//                               'รายละเอียดค่าบริการ',
//                               style: TextStyle(
//                                   color: PeopleChaoScreen_Color.Colors_Text1_,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: FontWeight_.Fonts_T
//                                   //fontSize: 10.0
//                                   ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const SizedBox(width: 25),
//                           // สรุปทั้งหมด
//                           navPill(
//                             label: 'สรุปทั้งหมด',
//                             active: ExpTap == 1,
//                             onTap: () {
//                               setState(() => ExpTap = 1);
//                               red_report();
//                             },
//                             margin: EdgeInsets.zero, // อันแรกชิดซ้าย
//                           ),

//                           // รายละเอียดค่าบริการ
//                           navPill(
//                             label: 'รายละเอียดค่าบริการ',
//                             active: ExpTap == 2,
//                             onTap: () {
//                               setState(() => ExpTap = 2);
//                               red_report();
//                             },
//                           ),

//                           // สรุปรายเดือน (ซ่อนตามเงื่อนไขเดิม)
//                           if (renTal_user.toString() != '106')
//                             navPill(
//                               label: 'สรุปรายเดือน',
//                               active: ExpTap == 3,
//                               onTap: () {
//                                 setState(() => ExpTap = 3);
//                                 red_report2();
//                               },
//                             ),

//                           // ประวัติ
//                           // navPill(
//                           //   label: 'ประวัติ',
//                           //   active: ExpTap == 4,
//                           //   onTap: () {
//                           //     setState(() => ExpTap = 4);
//                           //     red_Syslog();
//                           //   },
//                           // ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//           SizedBox(
//             height: 10,
//           ),
//           ser_tabbarview_2 != 0
//               ? SizedBox()
//               : Container(
//                   child: Column(
//                     children: [
//                       ScrollConfiguration(
//                         behavior: ScrollConfiguration.of(context)
//                             .copyWith(dragDevices: {
//                           PointerDeviceKind.touch,
//                           PointerDeviceKind.mouse,
//                         }),
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           dragStartBehavior: DragStartBehavior.start,
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       width: (Responsive.isDesktop(context))
//                                           ? MediaQuery.of(context).size.width *
//                                               0.84
//                                           : 800,
//                                       decoration: BoxDecoration(
//                                         color: AppbackgroundColor.TiTile_Colors,
//                                         borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10),
//                                         ),
//                                       ),
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         children: [
//                                           if (ExpTap == 2)
//                                             Align(
//                                               alignment: Alignment.topRight,
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         2, 2, 2, 0),
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: AppbackgroundColor
//                                                             .TiTile_Colors
//                                                         .withOpacity(0.5),
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                             topLeft:
//                                                                 Radius.circular(
//                                                                     6),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     6),
//                                                             bottomLeft:
//                                                                 Radius.circular(
//                                                                     6),
//                                                             bottomRight:
//                                                                 Radius.circular(
//                                                                     6)),
//                                                     border: Border.all(
//                                                         color: Colors.grey,
//                                                         width: 1),
//                                                   ),
//                                                   width: 220,
//                                                   height: 35,
//                                                   padding:
//                                                       const EdgeInsets.all(1.0),
//                                                   child:
//                                                       DropdownButtonHideUnderline(
//                                                     child:
//                                                         DropdownButton2<String>(
//                                                       isExpanded: true,
//                                                       hint: Text(
//                                                         '$Dropdown_expname',
//                                                         maxLines: 1,
//                                                         style: const TextStyle(
//                                                           fontSize: 14,
//                                                           color:
//                                                               ReportScreen_Color
//                                                                   .Colors_Text1_,
//                                                           // fontWeight: FontWeight.bold,
//                                                           fontFamily:
//                                                               Font_.Fonts_T,
//                                                         ),
//                                                       ),
//                                                       items:
//                                                           expModels.map((item) {
//                                                         return DropdownMenuItem(
//                                                           value: item.ser,
//                                                           //disable default onTap to avoid closing menu when selecting an item
//                                                           enabled: false,
//                                                           child:
//                                                               StatefulBuilder(
//                                                             builder: (context,
//                                                                 menuSetState) {
//                                                               // final isSelected = selectedItems.contains(item);
//                                                               return InkWell(
//                                                                 onTap: () {
//                                                                   int selectedIndex =
//                                                                       expModels.indexWhere((items) =>
//                                                                           items
//                                                                               .ser ==
//                                                                           item.ser);
//                                                                   // //print(expModels[
//                                                                   //         selectedIndex]
//                                                                   //     .expname);
//                                                                   setState(() {
//                                                                     Dropdown_expname = expModels[
//                                                                             selectedIndex]
//                                                                         .expname
//                                                                         .toString();

//                                                                     red_reporttrans(
//                                                                         expser:
//                                                                             '${expModels[selectedIndex].ser}');
//                                                                   });
//                                                                   Navigator.pop(
//                                                                       context);

//                                                                   menuSetState(
//                                                                       () {});
//                                                                 },
//                                                                 child:
//                                                                     Container(
//                                                                   height: double
//                                                                       .infinity,
//                                                                   padding: const EdgeInsets
//                                                                           .symmetric(
//                                                                       horizontal:
//                                                                           16.0),
//                                                                   child: Row(
//                                                                     children: [
//                                                                       Expanded(
//                                                                         child:
//                                                                             Text(
//                                                                           item.expname!,
//                                                                           maxLines:
//                                                                               1,
//                                                                           style:
//                                                                               const TextStyle(
//                                                                             fontSize:
//                                                                                 14,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               );
//                                                             },
//                                                           ),
//                                                         );
//                                                       }).toList(),
//                                                       //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
//                                                       // value: selectedItems.isEmpty ? null : selectedItems.last,
//                                                       onChanged: (value) {},
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           // if (ExpTap == 2) Divider(),
//                                           HeaderRow(context, expTap: ExpTap),
//                                         ],
//                                       ),
//                                     ),
//                                     Container(
//                                       height: (Responsive.isDesktop(context))
//                                           ? MediaQuery.of(context).size.width *
//                                               0.2
//                                           : 300,
//                                       width: (Responsive.isDesktop(context))
//                                           ? MediaQuery.of(context).size.width *
//                                               0.84
//                                           : 800,
//                                       decoration: const BoxDecoration(
//                                         // color:
//                                         //     AppbackgroundColor.Sub_Abg_Colors,
//                                         borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(0),
//                                             topRight: Radius.circular(0),
//                                             bottomLeft: Radius.circular(0),
//                                             bottomRight: Radius.circular(0)),
//                                         // border: Border.all(color: Colors.grey, width: 1),
//                                       ),
//                                       child: ListView.builder(
//                                         controller: _scrollController1,
//                                         physics:
//                                             const AlwaysScrollableScrollPhysics(), // เหมือนเดิม
//                                         shrinkWrap: true, // เหมือนเดิม
//                                         itemCount: (ExpTap == 1)
//                                             ? quotxSelectModels.length
//                                             : (ExpTap == 2)
//                                                 ? _TransModels.length
//                                                 : (ExpTap == 3)
//                                                     ? quotxSelectModels2.length
//                                                     : syslogModel.length,
//                                         itemBuilder:
//                                             (BuildContext context, int index) {
//                                           return Material(
//                                             child: (ExpTap == 1)
//                                                 ? ValueCellExpType_1(
//                                                     context,
//                                                     quotxSelectModels:
//                                                         quotxSelectModels,
//                                                     index: index,
//                                                   )
//                                                 : (ExpTap == 2)
//                                                     ? ValueCellExpType_2(
//                                                         context,
//                                                         transModels:
//                                                             _TransModels,
//                                                         index: index,
//                                                       )
//                                                     : (ExpTap == 3)
//                                                         ? ValueCellExpType_3(
//                                                             context,
//                                                             quotxSelectModels2:
//                                                                 quotxSelectModels2,
//                                                             index: index,
//                                                           )
//                                                         : ValueCellExpType_4(
//                                                             context,
//                                                             syslogModel:
//                                                                 syslogModel,
//                                                             index: index,
//                                                           ),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Container(
//                           width: (Responsive.isDesktop(context))
//                               ? MediaQuery.of(context).size.width * 0.84
//                               : MediaQuery.of(context).size.width,
//                           decoration: const BoxDecoration(
//                             color: AppbackgroundColor.Sub_Abg_Colors,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(0),
//                                 topRight: Radius.circular(0),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Align(
//                                 alignment: Alignment.centerLeft,
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: InkWell(
//                                         onTap: () {
//                                           _scrollController1.animateTo(
//                                             0,
//                                             duration:
//                                                 const Duration(seconds: 1),
//                                             curve: Curves.easeOut,
//                                           );
//                                         },
//                                         child: Container(
//                                             decoration: BoxDecoration(
//                                               // color: AppbackgroundColor
//                                               //     .TiTile_Colors,
//                                               borderRadius:
//                                                   const BorderRadius.only(
//                                                       topLeft:
//                                                           Radius.circular(6),
//                                                       topRight:
//                                                           Radius.circular(6),
//                                                       bottomLeft:
//                                                           Radius.circular(6),
//                                                       bottomRight:
//                                                           Radius.circular(8)),
//                                               border: Border.all(
//                                                   color: Colors.grey, width: 1),
//                                             ),
//                                             padding: const EdgeInsets.all(3.0),
//                                             child: const Text(
//                                               'Top',
//                                               style: TextStyle(
//                                                   color: Colors.grey,
//                                                   fontSize: 10.0,
//                                                   fontFamily:
//                                                       FontWeight_.Fonts_T),
//                                             )),
//                                       ),
//                                     ),
//                                     InkWell(
//                                       onTap: () {
//                                         if (_scrollController1.hasClients) {
//                                           final position = _scrollController1
//                                               .position.maxScrollExtent;
//                                           _scrollController1.animateTo(
//                                             position,
//                                             duration:
//                                                 const Duration(seconds: 1),
//                                             curve: Curves.easeOut,
//                                           );
//                                         }
//                                       },
//                                       child: Container(
//                                           decoration: BoxDecoration(
//                                             // color: AppbackgroundColor
//                                             //     .TiTile_Colors,
//                                             borderRadius:
//                                                 const BorderRadius.only(
//                                                     topLeft: Radius.circular(6),
//                                                     topRight:
//                                                         Radius.circular(6),
//                                                     bottomLeft:
//                                                         Radius.circular(6),
//                                                     bottomRight:
//                                                         Radius.circular(6)),
//                                             border: Border.all(
//                                                 color: Colors.grey, width: 1),
//                                           ),
//                                           padding: const EdgeInsets.all(3.0),
//                                           child: const Text(
//                                             'Down',
//                                             style: TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 10.0,
//                                                 fontFamily:
//                                                     FontWeight_.Fonts_T),
//                                           )),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Row(
//                                   children: [
//                                     InkWell(
//                                       onTap: _moveUp1,
//                                       child: const Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Align(
//                                             alignment: Alignment.centerLeft,
//                                             child: Icon(
//                                               Icons.arrow_upward,
//                                               color: Colors.grey,
//                                             ),
//                                           )),
//                                     ),
//                                     Container(
//                                         decoration: BoxDecoration(
//                                           // color: AppbackgroundColor
//                                           //     .TiTile_Colors,
//                                           borderRadius: const BorderRadius.only(
//                                               topLeft: Radius.circular(6),
//                                               topRight: Radius.circular(6),
//                                               bottomLeft: Radius.circular(6),
//                                               bottomRight: Radius.circular(6)),
//                                           border: Border.all(
//                                               color: Colors.grey, width: 1),
//                                         ),
//                                         padding: const EdgeInsets.all(3.0),
//                                         child: const Text(
//                                           'Scroll',
//                                           style: TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: 10.0,
//                                               fontFamily: FontWeight_.Fonts_T),
//                                         )),
//                                     InkWell(
//                                       onTap: _moveDown1,
//                                       child: const Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Align(
//                                             alignment: Alignment.centerRight,
//                                             child: Icon(
//                                               Icons.arrow_downward,
//                                               color: Colors.grey,
//                                             ),
//                                           )),
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           )),
//                     ],
//                   ),
//                 ),
//           // ser_tabbarview_2 != 0
//           //     ? SizedBox()
//           //     : const Row(
//           //         children: [
//           //           Padding(
//           //             padding: EdgeInsets.all(8.0),
//           //             child: AutoSizeText(
//           //               minFontSize: 10,
//           //               maxFontSize: 15,
//           //               'ตารางสรุปรายละเอียดค่าบริการ',
//           //               style: TextStyle(
//           //                   color: PeopleChaoScreen_Color.Colors_Text1_,
//           //                   fontWeight: FontWeight.bold,
//           //                   fontFamily: FontWeight_.Fonts_T
//           //                   //fontSize: 10.0
//           //                   ),
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//         ],
//       ),
//     );
//   }
// }
