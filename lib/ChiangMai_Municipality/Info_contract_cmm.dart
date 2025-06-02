import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetContract_Photo_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/electricity_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Model/Dataconfig_Model.dart';
import 'Model/Document_Model.dart';
import 'Model/Person&Shop_Model.dart';
import 'PDF_CMM/application_form1_cmm.dart';
import 'PDF_CMM/application_form2_cmm.dart';
import 'PDF_CMM/application_form3_cmm.dart';
import 'PDF_CMM/license_form_cmm.dart';
import 'PDF_CMM/receipt_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import 'unity/Enum.dart';
import 'unity/FormatDate.dart';

class Infocontract_CMM extends StatefulWidget {
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  final Get_Value_statu;
  const Infocontract_CMM(
      {super.key,
      this.Get_Value_NameShop_index,
      this.Get_Value_cid,
      this.Get_Value_statu});

  @override
  State<Infocontract_CMM> createState() => _Infocontract_CMMState();
}

class _Infocontract_CMMState extends State<Infocontract_CMM> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  DateTime datex = DateTime.now();
  /////////------------------------>
  String? _verticalGroupValue,
      foder,
      renTal_bill,
      renTal_name,
      renTal_user,
      fname_,
      Cust_no_,
      paper,
      paper_run;
  String ser_data_tap = '1';
  String? pic_tenant, pic_shop, pic_plan, fiew;
  List<RenTalModel> renTalModels = [];
  List<ContractPhotoModel> contractPhotoModels = [];
  List<TransModel> _TransModels = [];
  List<QuotxSelectModel> quotxSelectModels = [];
  List<ElectricityModel> electricityModels = [];
  List<TeNantModel> teNantModels = [];
  List<Map<String, String>> data_picperson = [
    {"ser": "1", "title": "รูปผู้เช่า", "detail": "pic_tenant", "url": ""},
    {"ser": "2", "title": "รูปร้านค้า", "detail": "pic_shop", "url": ""},
    {"ser": "3", "title": "รูปแผนผัง", "detail": "pic_plan", "url": ""},
  ];
  List<Map<String, String>> data_tap = [
    {"ser": "1", "title": "ใบคำร้องและใบอนุญาต", "detail": ""},
    {"ser": "2", "title": "หลักฐานเอกสารแนบ", "detail": ""},
    {"ser": "3", "title": "ภาพการตรวจสอบข้อเท็จจริง", "detail": ""},
  ];
  List data_doccid = [
    {
      "ser": "1",
      "title":
          "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ",
      "detail": "GeneratePDF_1"
    },
    {
      "ser": "2",
      "title":
          "ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ",
      "detail": "GeneratePDF_2"
    },
    {
      "ser": "3",
      "title": "ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ",
      "detail": "GeneratePDF_3"
    },
  ];
  List data_title_receipt = [
    {
      "ser": "1",
      "title": "เลขที่ใบเสร็จ ",
      "data": "title",
    },
    {
      "ser": "2",
      "title": "วันที่รับชำระ",
      "data": "datex",
    },
    {
      "ser": "3",
      "title": "สถานะ",
      "data": "status",
    },
    {
      "ser": "4",
      "title": "วันที่ตรวจสอบ",
      "data": "verify",
    },
  ];
  List data_receipt = [
    {
      "ser": "1",
      "title": "R68-04-000001",
      "datex": "21-04-2025",
      "status": "รอตรวจสอบ",
      "verify": "-",
    },
  ];
  List data_title_doc = [
    {
      "ser": "1",
      "title": "ชื่อเอกสาร ",
      "data": "title",
    },
    {
      "ser": "2",
      "title": "วันที่ทำรายการ",
      "data": "datex",
    },
    {
      "ser": "3",
      "title": "ไฟล์เอกสาร",
      "data": "file",
    },
    {
      "ser": "4",
      "title": "สถานะ",
      "data": "status",
    },
    {
      "ser": "5",
      "title": "วันที่ตรวจสอบ",
      "data": "verify",
    },
  ];
  List data_doc = [
    {
      "ser": "1",
      "title": "รูปถ่าย ",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "เอกสารถูกต้อง",
      "verify": "-",
    },
    {
      "ser": "2",
      "title": "รูปถ่ายคู่กับร้านค้าและสิ้นค้า",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "รอตรวจสอบ",
      "verify": "-",
    },
    {
      "ser": "3",
      "title": "ใบรับรองแพทย์",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "เอกสารถูกต้อง",
      "verify": "-",
    },
    {
      "ser": "4",
      "title": "ใบอนุญาติจำหน่ายสินค้า",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "รอแก้ไข",
      "verify": "-",
    },
    {
      "ser": "5",
      "title": "บัตรประจำตัวผู้ค้า",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "รอแก้ไข",
      "verify": "-",
    },
    {
      "ser": "6",
      "title": "ใบรับรองการผ่านการอบรม",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "รอตรวจสอบ",
      "verify": "-",
    },
    {
      "ser": "7",
      "title": "เอกสารแนบอื่นๆ",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "รอตรวจสอบ",
      "verify": "-",
    },
    {
      "ser": "8",
      "title": "หลักฐานการชำระ",
      "datex": "21-04-2025",
      "file": "xxxx.png",
      "status": "ไม่ผ่านเกณฑ์",
      "verify": "-",
    },
  ];
  List data_img_people = [
    {
      "ser": "1",
      "title": "รูปถ่ายผู้เช่า ",
      "img": "images/LOGO.png",
    },
    {
      "ser": "2",
      "title": "รูปถ่ายคู่กับร้านค้าและสินค้า",
      "img": "images/LOGO.png",
    },
  ];
  List data_admin_img_people = [
    {
      "ser": "1",
      "title": "รูปถ่ายผู้เช่า ",
      "img": "images/LOGO.png",
    },
    {
      "ser": "2",
      "title": "รูปถ่ายคู่กับร้านค้าและสินค้า",
      "img": "images/LOGO.png",
    },
    {
      "ser": "3",
      "title": "รูปถ่ายสินค้า",
      "img": "",
    },
  ];

  List<PersonFieldModel> data_person = data_persons;
  List<ShopFieldModel> data_shop = data_shops;
  List<ClientModel> clientModels = [];
  final _formKey_person = GlobalKey<FormState>();
  List<TextEditingController> _controllers_person = [];
  List<TextEditingController> _controllers_shop = [];
  List<TextEditingController> _controllers_shop_sub = [];
  List<TextEditingController> _controllers_cid = [];
  List data_cid = [];
  @override
  void initState() {
    super.initState();
    Loading_Data_config();
    read_GC_rental();
    red_reporttrans();
    red_report();
    _controllers_person = List.generate(
      data_person.length,
      (i) => TextEditingController(text: data_person[i].detail ?? ''),
    );
    _controllers_shop = List.generate(
      data_shop.length,
      (i) => TextEditingController(text: data_shop[i].detail ?? ''),
    );
    _controllers_shop_sub = List.generate(
      data_shop[0].detailsub.length,
      (i) =>
          TextEditingController(text: data_shop[0].detailsub[i].detail ?? ''),
    );
    _controllers_cid = List.generate(
      data_cid.length,
      (i) => TextEditingController(text: data_cid[i]['detail'] ?? ''),
    );
  }

  ////////////--------------------->
  @override
  void dispose() {
    for (var c in _controllers_person) {
      c.dispose();
    }
    for (var c in _controllers_shop) {
      c.dispose();
    }
    for (var c in _controllers_shop_sub) {
      c.dispose();
    }
    super.dispose();
  }

  ///////////------------------------------------>
  Loading_Data_config() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();

    setState(() {
      data_cid = cid;
      // data_title_doc = doc;
      // data_title_receipt = receipt;
    });
  }

  ///------------------------------------------------------>
  Future<Null> red_report() async {
    setState(() {
      quotxSelectModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_quot_conx.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    // print('GC_quot_conx>>>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        if (quotxSelectModels.isNotEmpty) {
          setState(() {
            quotxSelectModels.clear();
          });
        }
        for (var map in result) {
          QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
          setState(() {
            quotxSelectModels.add(quotxSelectModel);
          });
        }
      } else {
        setState(() {
          quotxSelectModels.clear();
        });
      }
    } catch (e) {}
  }

  ///////////------------------------------------>
  Future<Null> red_reporttrans() async {
    if (_TransModels.length != 0) {
      setState(() {
        _TransModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_trans_x.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);
          setState(() {
            _TransModels.add(_TransModel);
          });
        }
      } else {
        setState(() {
          _TransModels.clear();
        });
      }
    } catch (e) {}
  }

  ///////////------------------------------------>
  Future<dynamic> showcountmiter(int index) async {
    var ser = quotxSelectModels[index].ele_ty;
    if (electricityModels.isNotEmpty) {
      electricityModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_electricity.php?isAdd=true&ren=$ren';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          ElectricityModel electricityModel = ElectricityModel.fromJson(map);

          if (electricityModel.ser == ser) {
            setState(() {
              electricityModels.add(electricityModel);
            });
          }
        }
      } else {}
    } catch (e) {}
  }

  ///////////------------------------------------>
  Future<void> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    final serUser = preferences.getString('ser');
    final rentalSer = preferences.getString('renTalSer');

    if (rentalSer == null) {
      print('⚠️ ไม่พบค่า renTalSer ใน SharedPreferences');
      return;
    }

    final url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$rentalSer';

    try {
      final response = await http.get(Uri.parse(url));

      final result = json.decode(response.body);

      if (result != null && result is List) {
        final tempModels = <RenTalModel>[];

        for (var map in result) {
          final renTalModel = RenTalModel.fromJson(map);
          final folderName = renTalModel.dbn;

          tempModels.add(renTalModel);

          setState(() {
            foder = folderName;
            renTal_bill = renTalModel.bill_name?.trim() ?? '';
          });
        }

        setState(() {
          renTalModels.clear();
          renTalModels.addAll(tempModels);
        });
      } else {
        print('⚠️ ไม่พบข้อมูล rental หรือรูปแบบข้อมูลไม่ถูกต้อง');
      }
    } catch (e, stackTrace) {
      print('❌ เกิดข้อผิดพลาดใน read_GC_rental: $e');
      print('🪵 StackTrace: $stackTrace');
    }

    await read_GC_photo();
    await read_data();
  }

  Future<Null> read_data() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    print('Get_Value_NameShop_index >>>>>> $qutser');

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);
            Cust_no_ = teNantModel.custno_1.toString();
            _verticalGroupValue = teNantModel.ctype;
            // Form_nameshop.text = teNantModel.sname.toString();
            // Form_typeshop.text = teNantModel.stype.toString();
            // Form_bussshop.text = teNantModel.cname.toString();
            // Form_bussscontact.text = teNantModel.attn.toString();
            // Form_address.text = teNantModel.addr.toString();
            // Form_tel.text = teNantModel.tel.toString();
            // Form_email.text = teNantModel.email.toString();
            // Form_Remark.text = teNantModel.remark.toString();
            // Form_tax.text =
            //     teNantModel.tax == null ? "-" : teNantModel.tax.toString();
            // Form_area.text = teNantModel.area.toString();
            // Form_ln.text = teNantModel.area_c.toString();
            // Form_wnote.text = teNantModel.wnote.toString();
            // Form_sdate.text = DateFormat('dd-MM-yyyy')
            //     .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
            //     .toString();
            // Form_ldate.text = DateFormat('dd-MM-yyyy')
            //     .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
            //     .toString();
            // Form_period.text = teNantModel.period.toString();
            // Form_rtname.text = teNantModel.rtname.toString();
            // Form_docno.text = teNantModel.docno.toString();
            // Form_zn.text = teNantModel.zn.toString();
            // Form_aser.text = teNantModel.aser.toString();
            // Form_qty.text = teNantModel.qty.toString();
            // Form_cdate.text = DateFormat('dd-MM-yyyy')
            //     .format(DateTime.parse('${teNantModel.cdate} 00:00:00'))
            //     .toString();
            // Form_fid.text = teNantModel.fid.toString();
            // Form_renew_cid.text = teNantModel.renew_cid.toString();
            // cid_typePaper_ser = teNantModel.ser_paper.toString();
            // Form_addmin.text = teNantModel.name_user.toString();
            // paper = teNantModel.paper.toString();
            // paper_run = teNantModel.paper_run.toString();
            // Form_renew_datex.text = teNantModel.renew_datex.toString();
            // Form_renew_sdate.text = teNantModel.renew_sdate.toString();
            // Form_renew_ldate.text = teNantModel.renew_ldate.toString();
            // Form_fid_sdate.text = teNantModel.renew_ldate.toString();
            // Form_fid_ldate.text = teNantModel.renew_ldate.toString();
          });
        }
        // read_GC_TypePaper();
        // red_coutumer();
        // read_PakanDocno();
        print('AddForm_requests_uuid');
        AddForm_requests_uuid(0);
      }
    } catch (e) {}
  }

  Future<void> read_GC_photo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final user = preferences.getString('ser');
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;

    if (ren == null || user == null || foder == null) {
      print('⚠️ ข้อมูลที่จำเป็นไม่ครบ: ren/user/foder');
      return;
    }

    final url =
        '${MyConstant().domain}/GC_photo_cont.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser';

    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);

      if (result != null && result is List) {
        final tempPhotoModels = <ContractPhotoModel>[];

        for (var map in result) {
          final model = ContractPhotoModel.fromJson(map);

          final tenantPic = model.pic_tenant?.trim() ?? '';
          final shopPic = model.pic_shop?.trim() ?? '';
          final planPic = model.pic_plan?.trim() ?? '';

          setState(() {
            pic_tenant = tenantPic;
            pic_shop = shopPic;
            pic_plan = planPic;

            data_picperson = [
              {
                "ser": "1",
                "title": "รูปผู้เช่า",
                "detail": "pic_tenant",
                "url":
                    '${MyConstant().domain}/files/$foder/contract/$tenantPic',
              },
              {
                "ser": "2",
                "title": "รูปร้านค้า",
                "detail": "pic_shop",
                "url": '${MyConstant().domain}/files/$foder/contract/$shopPic',
              },
              {
                "ser": "3",
                "title": "รูปแผนผัง",
                "detail": "pic_plan",
                "url": '${MyConstant().domain}/files/$foder/contract/$planPic',
              },
            ];

            contractPhotoModels.clear();
            contractPhotoModels.add(model);
          });

          tempPhotoModels.add(model);
        }
      } else {
        print('⚠️ ไม่พบข้อมูลรูปภาพสัญญา หรือข้อมูลไม่ถูกต้อง');
      }
    } catch (e, stackTrace) {
      print('❌ เกิดข้อผิดพลาดใน read_GC_photo: $e');
      print('🪵 StackTrace: $stackTrace');
    }
  }

  ////---------------->
  String? base64_Slip, fileName_Slip;
  var extension_;
  var file_;
  File? _file;
  Future<void> uploadImage(ImageSource source) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      fileName_Slip = '${fiew}_${widget.Get_Value_cid}_$timestamp.jpg';
    });

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: source,
      maxWidth: 1200, // จำกัดขนาด
      maxHeight: 1200,
      imageQuality: 75, // บีบอัดคุณภาพเล็กน้อย
    );

    if (pickedFile == null) {
      print('❌ User canceled image selection');
      return;
    }

    try {
      print('📷 Picked image path: ${pickedFile.path}');

      final imageBytes = await pickedFile.readAsBytes();
      print('📏 Image size in bytes: ${imageBytes.length}');

      final base64Image = base64Encode(imageBytes);
      final url =
          '${MyConstant().domain}/File_photo.php?name=$fileName_Slip&Foder=$foder';

      print('📡 Uploading to: File_photo');

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64Image,
          'Foder': foder,
          'name': fileName_Slip,
        },
      );

      print('📥 Upload response: ${response.statusCode}');
      print('📨 Server says: ${response.body}');

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        if (jsonRes['message'] == 'Image uploaded successfully') {
          print('✅ Image uploaded successfully');
          await up_photo_string();
        } else {
          print(
              '⚠️ Server responded but message was unexpected: ${jsonRes['message']}');
        }
      } else {
        print('❌ Image upload failed with status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error during image processing: $e');
      print('🪵 StackTrace:\n$stackTrace');
    }
  }

  Future<void> up_photo_string() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final ren = preferences.getString('renTalSer');
      final user = preferences.getString('ser');
      final ciddoc = widget.Get_Value_cid;
      final qutser = widget.Get_Value_NameShop_index;
      final fiewx = fiew;
      final fileNameSafe = fileName_Slip?.trim() ?? '';

      // ✅ ตรวจสอบข้อมูลให้ครบก่อน
      if ([ren, user, ciddoc, qutser, fiewx, fileNameSafe]
          .any((e) => e == null || e.isEmpty)) {
        print('❌ ข้อมูลไม่ครบ ไม่สามารถส่งคำขอได้');
        print(
            '🔸 ren: $ren, user: $user, ciddoc: $ciddoc, qutser: $qutser, fiewx: $fiewx, fileName: $fileNameSafe');
        return;
      }

      final url = '${MyConstant().domain}/GC_tran_Kon_photo.php?isAdd=true'
          '&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser'
          '&fiewx=$fiewx&fileName_Slip=$fileNameSafe';

      print('📡 เรียก URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('📥 Response: $result');

        if (result.toString() == 'true') {
          print('✅ อัปเดตรูปภาพในระบบสำเร็จ');

          // ✅ ล้างตัวแปร
          setState(() {
            fileName_Slip = null;
            base64_Slip = null;
            extension_ = null;
            file_ = null;
            _file = null;
            fiew = null;
          });

          // ✅ โหลดรูปใหม่
          await read_GC_photo();
        } else {
          print('⚠️ ไม่สามารถอัปเดตได้: *โหลดรูปใหม่');
        }
      } else {
        print('❌ HTTP ERROR: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Exception ใน up_photo_string: $e');
      print('🪵 StackTrace:\n$stackTrace');
    }
  }

  void AddForm_requests_uuid(index) {
    // แปลง CustomerModel ให้เป็น JSON string เพื่อแสดง
    // String jsonString = jsonEncode(clientModels[index].toJson());
    TeNantModel model = teNantModels[index]; // ดึง object ออกมาก่อน
    // print(jsonString);

    List<String> data_person_add = [
      "${model.cname}",
      "${model.tax}",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "-",
      "${model.tel}",
      "${model.addr}",
    ];
    List<String> data_shop_add = [
      "-",
      "${model.area}",
      "${model.stype}",
      "${model.sname}",
    ];
    List<String> data_cid_add = [
      formatDate(model.sdate!, type: DateFormatType.thaiShort).toString(),
      formatDate(model.ldate!, type: DateFormatType.thaiShort).toString(),
    ];
    // print('data_person_add');
    // print(data_cid_add.length);
    List<String> data_shopsub_add = ['-', '${model.zn}', '${model.area_c}'];
    // อัปเดตข้อมูลทั้งหมด
    _updateCustomerData(
        data_person_add, data_shop_add, data_shopsub_add, data_cid_add);
    // Dia_log1(context);
    // Timer(Duration(milliseconds: 300), () {
    //   Navigator.of(context).pop();
    // });
  }

  ///////////----------------------->
  void _updateCustomerData(personData, shopData, shopSubData, cidData) {
    setState(() {
      // อัปเดต person
      for (int i = 0; i < personData.length; i++) {
        data_person[i].detail = personData[i].toString();
      }

      // อัปเดต shop
      for (int i = 0; i < shopData.length; i++) {
        data_shop[i].detail = shopData[i].toString();
      }

      // อัปเดต shop.sub เฉพาะ data_shop[0]
      for (int i = 0; i < shopSubData.length; i++) {
        data_shop[0].detailsub[i].detail = shopSubData[i].toString();
      }
      // อัปเดต data cid
      for (int i = 0; i < cidData.length; i++) {
        // print(cidData[i].toString());
        data_cid[i]['detail'] = cidData[i].toString();
      }
      // รีสร้าง controller ทั้งหมด
      _controllers_person = List.generate(
        data_person.length,
        (i) => TextEditingController(text: data_person[i].detail),
      );

      _controllers_shop = List.generate(
        data_shop.length,
        (i) => TextEditingController(text: data_shop[i].detail),
      );

      _controllers_shop_sub = List.generate(
        data_shop[0].detailsub.length,
        (i) => TextEditingController(
          text: data_shop[0].detailsub[i].detail,
        ),
      );
      _controllers_cid = List.generate(
        data_cid.length,
        (i) => TextEditingController(text: data_cid[i]['detail']),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height + 300,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(data_picperson.length, (index_pic) {
                      final url = data_picperson[index_pic]['url'];
                      final title = data_picperson[index_pic]['title'];
                      final detailKey = data_picperson[index_pic]['detail'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  fiew = detailKey;
                                });
                                uploadImage(ImageSource.gallery);
                              },
                              // onTap: (url != null && url.isNotEmpty)
                              //     ? () {
                              //         showDialog(
                              //           context: context,
                              //           builder: (_) => AlertDialog(
                              //             shape: RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(
                              //                         16)),
                              //             contentPadding: EdgeInsets.zero,
                              //             content: ClipRRect(
                              //               borderRadius:
                              //                   BorderRadius.circular(16),
                              //               child: Image.network(
                              //                 url,
                              //                 fit: BoxFit.contain,
                              //                 errorBuilder: (_, __, ___) =>
                              //                     const Icon(
                              //                   Icons.broken_image,
                              //                   size: 80,
                              //                   color: Colors.grey,
                              //                 ),
                              //               ),
                              //             ),
                              //             actions: [
                              //               Center(
                              //                 child: TextButton.icon(
                              //                   icon: const Icon(
                              //                       Icons.close,
                              //                       color: Colors.white),
                              //                   label: const Text(
                              //                     'ปิด',
                              //                     style: TextStyle(
                              //                       color: Colors.white,
                              //                       fontWeight:
                              //                           FontWeight.bold,
                              //                       fontFamily:
                              //                           FontWeight_.Fonts_T,
                              //                     ),
                              //                   ),
                              //                   style: TextButton.styleFrom(
                              //                     backgroundColor:
                              //                         Colors.redAccent,
                              //                     shape:
                              //                         RoundedRectangleBorder(
                              //                             borderRadius:
                              //                                 BorderRadius
                              //                                     .circular(
                              //                                         10)),
                              //                     padding: const EdgeInsets
                              //                             .symmetric(
                              //                         horizontal: 20,
                              //                         vertical: 12),
                              //                   ),
                              //                   onPressed: () =>
                              //                       Navigator.pop(context),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         );
                              //       }
                              //     : null,
                              child: Container(
                                width: 300,
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[100],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  image: (url != null && url.isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(url),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image:
                                              AssetImage("images/pngegg2.png"),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                child: (url == null || url.isEmpty)
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.upload_file,
                                              size: 50, color: Colors.grey),
                                          const SizedBox(height: 6),
                                          const Text(
                                            "ยังไม่ได้เลือกรูป",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: Font_.Fonts_T,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            "รองรับ JPG / PNG\nขนาดไม่เกิน 10MB",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontFamily: Font_.Fonts_T,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                fontFamily: FontWeight_.Fonts_T,
                                color: Colors.black87,
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     Text(
                            //       title ?? '',
                            //       style: const TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 13,
                            //         fontFamily: FontWeight_.Fonts_T,
                            //         color: Colors.black87,
                            //       ),
                            //     ),
                            //     const SizedBox(width: 6),
                            //     IconButton(
                            //       onPressed: () {
                            //         setState(() {
                            //           fiew = detailKey;
                            //         });
                            //         // uploadImage(ImageSource.gallery);
                            //       },
                            //       icon: const Icon(Icons.edit,
                            //           color: Colors.blueGrey),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(
                child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            // height: MediaQuery.of(context).size.height * 0.8,
                            decoration: const BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: Form(
                                        key: _formKey_person,
                                        child: Column(children: [
                                          Form_Person(context),
                                          SizedBox(
                                            height: 20,
                                          ), // for (var shop in data_shop)
                                          Form_Shop(context),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Form_Cid(context),

                                          SizedBox(
                                            height: 60,
                                          ),
                                          // Form_Cid(context),
                                        ]),
                                      ),
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  children: List.generate(
                                                      data_tap.length, (index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: SizedBox(
                                                    // width: 200,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Colors.grey,
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          ser_data_tap =
                                                              '${data_tap[index]['ser']}';
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Translate
                                                            .TranslateAndSet_TextAutoSize(
                                                                '${data_tap[index]['title']}',
                                                                ChaoAreaScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                12,
                                                                14,
                                                                1),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              })))),
                                      (ser_data_tap == '1')
                                          ? Doc_Data_1(context)
                                          : (ser_data_tap == '2')
                                              ? Doc_Data_2(context)
                                              : Doc_Data_3(context),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Exp_Data(context)
                                      // Form_Cid(context),
                                      // SizedBox(
                                      //   height: 50,
                                      // ),
                                      // Doc_Data(context),
                                      // SizedBox(
                                      //   height: 50,
                                      // ),
                                      // ActiveStep_Stepper(context)
                                    ]),
                                  ),
                                ),
                              ],
                            )))),
              )
            ]),
          ),
        ));
  }

  Form_Person(context) {
    return SizedBox(
        child: Column(children: [
      // for (var person
      //     in data_person)
      for (int index = 0; index < data_person.length; index++)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: (index + 1 == data_person.length) ? null : 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      '${data_person[index].title}',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      showCursor: false,
                      readOnly: true,
                      controller: _controllers_person[index],
                      maxLines: (index + 1 == data_person.length) ? 3 : 1,
                      // validator:
                      //     (value) {
                      //   if (value ==
                      //           null ||
                      //       value
                      //           .isEmpty) {
                      //     return '';
                      //   }
                      //   return null;
                      // },
                      // initialValue:
                      //     '${person["detail"]}',
                      onFieldSubmitted: (value) async {},

                      decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.3),
                          filled: true,
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                              // color: (_controllers_person[index].text == null || _controllers_person[index].text.toString() == '')
                              //     ? Colors.red
                              //     : Colors.grey,
                            ),
                          ),
                          // labelText: 'ระบุชื่อร้านค้า',
                          labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontFamily: Font_.Fonts_T)),
                      // inputFormatters: <TextInputFormatter>[
                      //   // for below version 2 use this
                      //   FilteringTextInputFormatter
                      //       .allow(RegExp(r'[0-9]')),
                      //   // for version 2 and greater youcan also use this
                      //   FilteringTextInputFormatter
                      //       .digitsOnly
                      // ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    ]));
  }

  Form_Shop(context) {
    return SizedBox(
        child: Column(children: [
      // for (var shop in data_shop)
      for (int shop = 0; shop < data_shop.length; shop++)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      '${data_shop[shop].title}*',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                (data_shop[shop].ser.toString() == '1')
                    ? Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            for (int shop_sub = 0;
                                shop_sub < data_shop[shop].detailsub.length;
                                shop_sub++)
                              // for (var shop_sub
                              //     in data_shop[shop]
                              //         [
                              //         "detailsub"])
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  child: TextFormField(
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.number,
                                    showCursor: false,
                                    readOnly: true,
                                    controller: _controllers_shop_sub[shop_sub],
                                    // initialValue:
                                    //     '${shop_sub["detail"]}',
                                    onFieldSubmitted: (value) async {},

                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
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
                                        labelText:
                                            '${data_shop[shop].detailsub[shop_sub].titlesub}',
                                        labelStyle: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: Font_.Fonts_T)),
                                    // inputFormatters: <TextInputFormatter>[
                                    //   // for below version 2 use this
                                    //   FilteringTextInputFormatter
                                    //       .allow(RegExp(r'[0-9]')),
                                    //   // for version 2 and greater youcan also use this
                                    //   FilteringTextInputFormatter
                                    //       .digitsOnly
                                    // ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          child: TextFormField(
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.number,
                            showCursor: false,
                            readOnly: true,
                            controller: _controllers_shop[shop],
                            //   initialValue:

                            // '${shop["detail"]}',
                            onFieldSubmitted: (value) async {},

                            decoration: InputDecoration(
                                fillColor: Colors.white.withOpacity(0.3),
                                filled: true,
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                // labelText: 'ระบุชื่อร้านค้า',
                                labelStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontFamily: Font_.Fonts_T)),
                            // inputFormatters: <TextInputFormatter>[
                            //   // for below version 2 use this
                            //   FilteringTextInputFormatter
                            //       .allow(RegExp(r'[0-9]')),
                            //   // for version 2 and greater youcan also use this
                            //   FilteringTextInputFormatter
                            //       .digitsOnly
                            // ],
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
    ]));
  }

  Form_Cid(context) {
    return SizedBox(
        child: Column(children: [
      // for (var cid in data_cid)
      for (int cid = 0; cid < data_cid.length; cid++)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      '${data_cid[cid]["title"]}*',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      showCursor: false,
                      readOnly: true,
                      controller: (_controllers_cid.length < 1)
                          ? null
                          : _controllers_cid[cid],
                      // initialValue: '${cid["detail"]}',
                      onFieldSubmitted: (value) async {},

                      decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.3),
                          filled: true,
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          // labelText: 'ระบุชื่อร้านค้า',
                          labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontFamily: Font_.Fonts_T)),
                      // inputFormatters: <TextInputFormatter>[
                      //   // for below version 2 use this
                      //   FilteringTextInputFormatter
                      //       .allow(RegExp(r'[0-9]')),
                      //   // for version 2 and greater youcan also use this
                      //   FilteringTextInputFormatter
                      //       .digitsOnly
                      // ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    ]));
  }

  Doc_Data_1(context) {
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(
            color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0)),
            // border: Border.all(color: Colors.grey, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          // padding:
          //     const EdgeInsets.symmetric(
          //         vertical: 5,
          //         horizontal: 16),
          child: Column(
            children: [
              // AutoSizeText(
              //   minFontSize: 12,
              //   maxFontSize: 16,
              //   maxLines: 1,
              //   'เอกสารแนบ (${attachments.length}เอกสาร) ${isLoading}',
              //   textAlign: TextAlign.center,
              //   overflow: TextOverflow.ellipsis,
              //   style: TextStyle(
              //       color: PeopleChaoScreen_Color.Colors_Text2_,
              //       fontFamily: Font_.Fonts_T),
              // ),
              Container(
                color: Colors.brown[200],
                child: Row(children: [
                  for (var datatap in data_tap)
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        child: AutoSizeText(
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          '${datatap["title"]}',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text2_,
                              fontFamily: Font_.Fonts_T),
                        ),
                      ),
                    ),
                ]),
              ),
            ],
          ),
        ),
      ])),
      SizedBox(
        child: Column(
          children: [
            AutoSizeText(
              minFontSize: 12,
              maxFontSize: 16,
              maxLines: 1,
              'เอกสารคำร้องขอต่อสัญญา/ใบอนุญาต)',
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: PeopleChaoScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T),
            ),
            for (var doc in data_doccid)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        padding: const EdgeInsets.all(0.0),
                        child: AutoSizeText(
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          '${doc["ser"]}.${doc["title"]}',
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text2_,
                              fontFamily: Font_.Fonts_T),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 35,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 155, 170, 72),
                        ),
                      ),
                      onPressed: () async {
                        var functionName = doc['detail']!;
                        final pdfGenerators = {
                          "GeneratePDF_1": () =>
                              GeneratePDF_ApplicationForm1_CMM(context, 1),
                          "GeneratePDF_2": () =>
                              GeneratePDF_ApplicationForm3_CMM(context, 1),
                          // "GeneratePDF_2": () =>
                          //     GeneratePDF_ApplicationForm2_CMM(context, 1),
                          "GeneratePDF_3": () =>
                              GeneratePDF_License_CMM(context, 1),
                          // GeneratePDF_Receipt_CMM(context, 1),
                        };
                        final fn = pdfGenerators[functionName];
                        if (fn != null) await fn();
                      },
                      // onPressed: () async {
                      //   setState(() {
                      //     pdfx = null;
                      //   });
                      //   Future.delayed(const Duration(milliseconds: 400),
                      //       () async {
                      //     setState(() {
                      //       pdfName = doc["title"]!;
                      //       functionName = doc['detail']!;
                      //     });
                      //     final pdfGenerators = {
                      //       "GeneratePDF_1":
                      //           GeneratePDF_ApplicationForm1_CMM(context, 0),
                      //       "GeneratePDF_2":
                      //           GeneratePDF_ApplicationForm2_CMM(context, 0),
                      //       "GeneratePDF_3":
                      //           GeneratePDF_License_CMM(context, 0),
                      //     };

                      //     final generate = await pdfGenerators[doc['detail']];

                      //     setState(() {
                      //       pdfx = generate;
                      //     });
                      //   });
                      // },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Translate.TranslateAndSet_TextAutoSize(
                            'แสดง',
                            ChaoAreaScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            null,
                            FontWeight_.Fonts_T,
                            12,
                            18,
                            1),
                      ),
                    ),
                  ),
                ]),
              )
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
                minFontSize: 12,
                maxFontSize: 16,
                maxLines: 1,
                'หมายเหตุ',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: TextFormField(
                readOnly: false,
                keyboardType: TextInputType.number,
                // controller: Formbecause_,
                initialValue: '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ใส่ข้อมูลให้ครบถ้วน ';
                  }
                  // if (int.parse(value.toString()) < 13) {
                  //   return '< 13';
                  // }
                  return null;
                },
                onChanged: (value) {
                  // setState(() {
                  //   Formbecause_.text =
                  //       value.toString();
                  // });
                },
                maxLines: 3,
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
                    // labelText: 'คำอธิบาย',
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
          ],
        ),
      ),
    ]));
  }

  Doc_Data_2(context) {
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              // padding:
              //     const EdgeInsets.symmetric(
              //         vertical: 5,
              //         horizontal: 16),
              child: Column(
                children: [
                  AutoSizeText(
                    minFontSize: 12,
                    maxFontSize: 16,
                    maxLines: 1,
                    'เอกสารแนบ (8เอกสาร)',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T),
                  ),
                  Container(
                    color: Colors.brown[200],
                    child: Row(children: [
                      for (var title_doc in data_title_doc)
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_doc["title"]}',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
            for (var doc in data_doc)
              Row(children: [
                for (var title_doc in data_title_doc)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ('${title_doc["title"]}' == 'ไฟล์เอกสาร')
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        (doc["status"]! != 'รอตรวจสอบ')
                                            ? Colors.lime.shade800
                                            : Colors.black,
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PreviewPdf_ordit_CMM(
                                                    title: '${doc["title"]}'),
                                          ));
                                    },
                                    child:
                                        Translate.TranslateAndSet_TextAutoSize(
                                            'เรียกดู',
                                            (doc["status"]! != 'รอตรวจสอบ')
                                                ? CustomerScreen_Color
                                                    .Colors_Text2_
                                                : CustomerScreen_Color
                                                    .Colors_Text3_,
                                            TextAlign.center,
                                            null,
                                            Font_.Fonts_T,
                                            10,
                                            14,
                                            1),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              padding: const EdgeInsets.all(0.0),
                              child: AutoSizeText(
                                minFontSize: 12,
                                maxFontSize: 16,
                                maxLines: 1,
                                '${doc["${title_doc["data"]}"]}',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: ('${title_doc["title"]}' == 'สถานะ')
                                        ? (doc["status"]! == 'เอกสารถูกต้อง')
                                            ? Colors.green
                                            : (doc["status"]! == 'รอแก้ไข')
                                                ? Colors.orange
                                                : (doc["status"]! ==
                                                        'ไม่ผ่านเกณฑ์')
                                                    ? Colors.red
                                                    : CustomerScreen_Color
                                                        .Colors_Text2_
                                        : CustomerScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                )
              ])
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              // padding:
              //     const EdgeInsets.symmetric(
              //         vertical: 5,
              //         horizontal: 16),
              child: Column(
                children: [
                  AutoSizeText(
                    minFontSize: 12,
                    maxFontSize: 16,
                    maxLines: 1,
                    'รายการชำระ',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T),
                  ),
                  Container(
                    color: Colors.brown[200],
                    child: Row(children: [
                      for (var title_receipt in data_title_receipt)
                        Expanded(
                          flex: '${title_receipt["title"]}' == 'สถานะ' ? 2 : 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_receipt["title"]}',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
            for (var receipt in data_receipt)
              Row(children: [
                for (var title_receipt in data_title_receipt)
                  Expanded(
                    flex: '${title_receipt["title"]}' == 'สถานะ' ? 2 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      child: AutoSizeText(
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        '${receipt["${title_receipt["data"]}"]}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ),
              ]),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.info,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ]));
  }

  Doc_Data_3(context) {
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'รูปภาพหลักฐานจากผู้เช่า/ผู้ค้า',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              // color:
              //     Colors.brown[200],
              child: Row(children: [
                for (var imgpeople in data_img_people)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 16,
                            maxLines: 1,
                            '${imgpeople["title"]}',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Container(
                          height: 150,
                          width: 270,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: Image.asset(
                                  '${imgpeople["img"]}',
                                  height: 180,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.brown[200],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'รูปภาพหลักฐานการตรวจสอบข้อเท็จจริง',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              // color:
              //     Colors.brown[200],
              child: Row(children: [
                for (var admin_imgpeople in data_admin_img_people)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 16,
                            maxLines: 1,
                            '${admin_imgpeople["title"]}',
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Container(
                          height: 150,
                          width: 270,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(2.0),
                          child: (admin_imgpeople["img"]! == '')
                              ? const SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Icon(
                                            Icons.system_update_alt_outlined,
                                            size: 30,
                                            color: Colors.grey,
                                          ))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "คลิกหรือกด เพื่อเลือกไฟล์",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "รองรับไฟล์ภาพ JPG หรือ PNG",
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "ขนาดไฟล์สูงสุด: 10MB",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Colors.grey,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    topRight: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Image.asset(
                                        '${admin_imgpeople["img"]}',
                                        height: 180,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.info,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'โปรดแนบรูปเอกสารหลักฐานการตรวจสอบข้อเท็จจริงก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ]));
  }

  ///--------------------------------------------->
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  ///--------------------------------------------->
  Exp_Data(context) {
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: AutoSizeText(
              minFontSize: 10,
              maxFontSize: 15,
              'ตารางสรุปค่าบริการ',
              style: TextStyle(
                  color: PeopleChaoScreen_Color.Colors_Text1_,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T
                  //fontSize: 10.0
                  ),
            ),
          ),
          SizedBox(
            // width: 200,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.grey,
                ),
              ),
              onPressed: () async {
                await Dia_log1();
                Future.delayed(const Duration(milliseconds: 500), () {
                  checkshowDialog();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Translate.TranslateAndSet_TextAutoSize(
                    'ดูรายละเอียด',
                    ChaoAreaScreen_Color.Colors_Text2_,
                    TextAlign.center,
                    null,
                    FontWeight_.Fonts_T,
                    12,
                    14,
                    1),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        child: Column(
          children: [
            Container(
                width: (Responsive.isDesktop(context))
                    ? MediaQuery.of(context).size.width * 0.84
                    : 800,
                decoration: BoxDecoration(
                  color: AppbackgroundColor.TiTile_Colors,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'งวด',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T
                              //fontSize: 10.0
                              //fontSize: 10.0
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'วันที่',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T
                              //fontSize: 10.0
                              //fontSize: 10.0
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'รายการ',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T
                              //fontSize: 10.0
                              //fontSize: 10.0
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ยอด/งวด',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T
                              //fontSize: 10.0
                              //fontSize: 10.0
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ยอด',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text1_,
                              fontWeight: FontWeight.bold,
                              fontFamily: FontWeight_.Fonts_T
                              //fontSize: 10.0
                              //fontSize: 10.0
                              ),
                        ),
                      ),
                    ),
                  ],
                )),
            Container(
              height: (Responsive.isDesktop(context))
                  ? MediaQuery.of(context).size.width * 0.2
                  : 300,
              width: (Responsive.isDesktop(context))
                  ? MediaQuery.of(context).size.width * 0.84
                  : 800,
              decoration: BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                border: Border.all(color: Colors.grey, width: 0.1),
              ),
              child: ListView.builder(
                controller: _scrollController1,
                // itemExtent: 50,
                physics:
                    const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: quotxSelectModels.length,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    color: AppbackgroundColor.Sub_Abg_Colors,
                    child: Container(
                      // color:
                      //     tappedIndex_1 == index.toString()
                      //         ? tappedIndex_Color
                      //             .tappedIndex_Colors
                      //             .withOpacity(0.5)
                      //         : null,
                      child: quotxSelectModels[index].etype == 'F'
                          ? ListTile(
                              onTap: () {
                                // setState(() {
                                //   tappedIndex_1 = index.toString();
                                // });
                              },
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.grey.shade300,
                                          //   borderRadius:
                                          //       const BorderRadius.only(
                                          //           topLeft:
                                          //               Radius.circular(10),
                                          //           topRight:
                                          //               Radius.circular(10),
                                          //           bottomLeft:
                                          //               Radius.circular(10),
                                          //           bottomRight:
                                          //               Radius.circular(10)),
                                          //   // border: Border.all(color: Colors.grey, width: 1),
                                          // ),
                                          padding: const EdgeInsets.all(8.0),
                                          child: AutoSizeText(
                                            maxLines: 2,
                                            minFontSize: 13,
                                            maxFontSize: 15,
                                            (quotxSelectModels[index]
                                                            .etype
                                                            .toString() ==
                                                        'D' &&
                                                    quotxSelectModels[index]
                                                            .pay_pakan
                                                            .toString() ==
                                                        '1')
                                                ? '${quotxSelectModels[index].expname}(เดิม-ยกมา)'
                                                : '${quotxSelectModels[index].expname}',
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              // fontWeight:
                                              //     FontWeight
                                              //         .bold,
                                              fontFamily: Font_.Fonts_T,

                                              //fontSize: 10.0
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Expanded(
                                  //   flex: 1,
                                  //   child: Padding(
                                  //     padding:
                                  //         const EdgeInsets
                                  //             .all(8.0),
                                  //     child: AutoSizeText(
                                  //       maxLines: 2,
                                  //       minFontSize: 8,
                                  //       // maxFontSize: 15,
                                  //       '', //'${double.parse(quotxSelectModels[index].qty!).toStringAsFixed(0)} วัน',
                                  //       textAlign: TextAlign
                                  //           .center,
                                  //       style:
                                  //           const TextStyle(
                                  //         color: PeopleChaoScreen_Color
                                  //             .Colors_Text2_,
                                  //         // fontWeight: FontWeight.bold,
                                  //         fontFamily:
                                  //             Font_.Fonts_T,

                                  //         //fontSize: 10.0
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: AutoSizeText(
                                        maxLines: 2,
                                        minFontSize: 13,
                                        maxFontSize: 15,
                                        widget.Get_Value_NameShop_index == '1'
                                            ? double.parse(
                                                        quotxSelectModels[index]
                                                            .nvat!) ==
                                                    0
                                                ? '${double.parse(quotxSelectModels[index].qty!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].amt!))} บาท'
                                                : '${double.parse(quotxSelectModels[index].qty!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].nvat!))} %'
                                            : double.parse(
                                                        quotxSelectModels[index]
                                                            .fineCal!) ==
                                                    0
                                                ? '${double.parse(quotxSelectModels[index].qty!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].finePri!))} บาท'
                                                : '${double.parse(quotxSelectModels[index].qty!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fineCal!))} %',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T,

                                          //fontSize: 10.0
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Expanded(
                                  //   flex: 1,
                                  //   child: AutoSizeText(
                                  //     maxLines: 2,
                                  //     minFontSize: 8,
                                  //     // maxFontSize: 15,
                                  //     double.parse(quotxSelectModels[
                                  //                         index]
                                  //                     .fine!)
                                  //                 .toStringAsFixed(
                                  //                     0) ==
                                  //             '0'
                                  //         ? ''
                                  //         : 'เกิน ${double.parse(quotxSelectModels[index].fine!).toStringAsFixed(0)} วัน',
                                  //     textAlign:
                                  //         TextAlign.right,
                                  //     style:
                                  //         const TextStyle(
                                  //       color: PeopleChaoScreen_Color
                                  //           .Colors_Text2_,
                                  //       // fontWeight: FontWeight.bold,
                                  //       fontFamily:
                                  //           Font_.Fonts_T,

                                  //       //fontSize: 10.0
                                  //     ),
                                  //   ),
                                  // ),
                                  Expanded(
                                    flex: 1,
                                    child: AutoSizeText(
                                      maxLines: 2,
                                      minFontSize: 13,
                                      maxFontSize: 15,
                                      widget.Get_Value_NameShop_index == '1'
                                          ? double.parse(
                                                      quotxSelectModels[index]
                                                          .vat!) ==
                                                  0
                                              ? ''
                                              : double.parse(quotxSelectModels[
                                                              index]
                                                          .pvat!) ==
                                                      0
                                                  ? 'เกิน ${double.parse(quotxSelectModels[index].vat!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].total!))} บาท'
                                                  : 'เกิน ${double.parse(quotxSelectModels[index].vat!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].pvat!))} %'
                                          : double.parse(
                                                      quotxSelectModels[index]
                                                          .fine!) ==
                                                  0
                                              ? ''
                                              : double.parse(quotxSelectModels[
                                                              index]
                                                          .fineUnit!) ==
                                                      0
                                                  ? 'เกิน ${double.parse(quotxSelectModels[index].fine!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fineLate!))} บาท'
                                                  : 'เกิน ${double.parse(quotxSelectModels[index].fine!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fineUnit!))} %',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,

                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 1,
                                    child: AutoSizeText(
                                      maxLines: 2,
                                      minFontSize: 13,
                                      maxFontSize: 15,
                                      widget.Get_Value_NameShop_index == '1'
                                          ? double.parse(
                                                      quotxSelectModels[index]
                                                          .fine_three!) ==
                                                  0
                                              ? ''
                                              : double.parse(quotxSelectModels[
                                                              index]
                                                          .fine_cal_three!) !=
                                                      0
                                                  ? 'เกิน ${double.parse(quotxSelectModels[index].fine_three!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fine_cal_three!))} บาท'
                                                  : 'เกิน ${double.parse(quotxSelectModels[index].fine_three!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fine_late_three!))} %'
                                          : double.parse(
                                                      quotxSelectModels[index]
                                                          .fine_three!) ==
                                                  0
                                              ? ''
                                              : double.parse(quotxSelectModels[
                                                              index]
                                                          .fine_cal_three!) !=
                                                      0
                                                  ? 'เกิน ${double.parse(quotxSelectModels[index].fine_three!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fine_cal_three!))} บาท'
                                                  : 'เกิน ${double.parse(quotxSelectModels[index].fine_three!).toStringAsFixed(0)} วัน / ${nFormat.format(double.parse(quotxSelectModels[index].fine_late_three!))} %',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,

                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: AutoSizeText(
                                      maxLines: 2,
                                      minFontSize: 13,
                                      maxFontSize: 15,
                                      double.parse(quotxSelectModels[index]
                                                  .fine_max!) ==
                                              0
                                          ? ''
                                          : 'ไม่เกิน ${nFormat.format(double.parse(quotxSelectModels[index].fine_max!))} บาท',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T,

                                        //fontSize: 10.0
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          : ListTile(
                              onTap: () {
                                // setState(() {
                                //   tappedIndex_1 = index.toString();
                                // });
                              },
                              title: Container(
                                decoration: BoxDecoration(
                                  // color: Colors.green[100]!
                                  //     .withOpacity(0.5),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black12,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        maxLines: 2,
                                        minFontSize: 13,
                                        maxFontSize: 15,
                                        '${quotxSelectModels[index].unit} / ${quotxSelectModels[index].term} (งวด)',
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            //fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        maxLines: 2,
                                        minFontSize: 13,
                                        maxFontSize: 15,
                                        '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            //fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Tooltip(
                                        richMessage: TextSpan(
                                          text:
                                              '${quotxSelectModels[index].expname}',
                                          style: const TextStyle(
                                            color:
                                                HomeScreen_Color.Colors_Text1_,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey[200],
                                        ),
                                        child: AutoSizeText(
                                          maxLines: 2,
                                          minFontSize: 13,
                                          maxFontSize: 15,
                                          (quotxSelectModels[index]
                                                          .etype
                                                          .toString() ==
                                                      'D' &&
                                                  quotxSelectModels[index]
                                                          .pay_pakan
                                                          .toString() ==
                                                      '1')
                                              ? '${quotxSelectModels[index].expname}(เดิม-ยกมา)'
                                              : '${quotxSelectModels[index].expname}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              //fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                    quotxSelectModels[index].ele_ty == '0'
                                        ? Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              maxLines: 2,
                                              minFontSize: 13,
                                              maxFontSize: 15,
                                              quotxSelectModels[index].qty ==
                                                      '0.00'
                                                  ? '${nFormat.format(double.parse(quotxSelectModels[index].total!))} / งวด'
                                                  : '${nFormat.format(double.parse(quotxSelectModels[index].qty!))} / หน่วย',
                                              // '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          )
                                        : Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              maxLines: 2,
                                              minFontSize: 13,
                                              maxFontSize: 15,
                                              'อัตราพิเศษ',
                                              // '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                    quotxSelectModels[index].ele_ty == '0'
                                        ? Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              maxLines: 2,
                                              minFontSize: 13,
                                              maxFontSize: 15,
                                              '${nFormat.format(int.parse(quotxSelectModels[index].term!) * double.parse(quotxSelectModels[index].total!))}',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          )
                                        : Expanded(
                                            flex: 1,
                                            child: GestureDetector(
                                              onTap: () {
                                                showcountmiter(index)
                                                    .then((value) => showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return Dialog(
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.2,
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(15.0),
                                                                            child:
                                                                                Text(
                                                                              // ignore: unnecessary_string_interpolations
                                                                              'อัตราการคำนวณปัจจุบัน',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Divider(),
                                                                    (double.parse(electricityModels[0].eleMitOne!) +
                                                                                double.parse(electricityModels[0].eleGobOne!)) ==
                                                                            0.00
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              Expanded(flex: 1, child: Text('')),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  'หน่วยที่ 0 - ${electricityModels[0].eleOne}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitOne!) == 0.00 ? 'เหมาจ่าย' : 'หน่วยละ',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitOne!) == 0.00 ? '${electricityModels[0].eleGobOne}' : '${electricityModels[0].eleMitOne}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  'บาท',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    (double.parse(electricityModels[0].eleMitTwo!) +
                                                                                double.parse(electricityModels[0].eleGobTwo!)) ==
                                                                            0.00
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              Expanded(flex: 1, child: Text('')),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  'หน่วยที่ ${int.parse(electricityModels[0].eleOne!) + 1} - ${electricityModels[0].eleTwo}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitTwo!) == 0.00 ? 'เหมาจ่าย' : 'หน่วยละ',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitTwo!) == 0.00 ? '${electricityModels[0].eleGobTwo}' : '${electricityModels[0].eleMitTwo}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  'บาท',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    (double.parse(electricityModels[0].eleMitThree!) +
                                                                                double.parse(electricityModels[0].eleGobThree!)) ==
                                                                            0.00
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              Expanded(flex: 1, child: Text('')),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  'หน่วยที่ ${int.parse(electricityModels[0].eleTwo!) + 1} - ${electricityModels[0].eleThree}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitThree!) == 0.00 ? 'เหมาจ่าย' : 'หน่วยละ',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitThree!) == 0.00 ? '${electricityModels[0].eleGobThree}' : '${electricityModels[0].eleMitThree}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  'บาท',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    (double.parse(electricityModels[0].eleMitTour!) +
                                                                                double.parse(electricityModels[0].eleGobTour!)) ==
                                                                            0.00
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              Expanded(flex: 1, child: Text('')),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  'หน่วยที่ ${int.parse(electricityModels[0].eleThree!) + 1} - ${electricityModels[0].eleTour}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitTour!) == 0.00 ? 'เหมาจ่าย' : 'หน่วยละ',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitTour!) == 0.00 ? '${electricityModels[0].eleGobTour}' : '${electricityModels[0].eleMitTour}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  'บาท',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    (double.parse(electricityModels[0].eleMitFive!) +
                                                                                double.parse(electricityModels[0].eleGobFive!)) ==
                                                                            0.00
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              Expanded(flex: 1, child: Text('')),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  'หน่วยที่ ${int.parse(electricityModels[0].eleTour!) + 1} - ${electricityModels[0].eleFive}',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitFive!) == 0.00 ? 'เหมาจ่าย' : 'หน่วยละ',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitFive!) == 0.00 ? '${electricityModels[0].eleGobFive}' : '${electricityModels[0].eleMitFive}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  'บาท',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    (double.parse(electricityModels[0].eleMitSix!) +
                                                                                double.parse(electricityModels[0].eleGobSix!)) ==
                                                                            0.00
                                                                        ? SizedBox()
                                                                        : Row(
                                                                            children: [
                                                                              Expanded(flex: 1, child: Text('')),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  'หน่วยที่ ${electricityModels[0].eleSix} ขึ้นไป',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitSix!) == 0.00 ? 'เหมาจ่าย' : 'หน่วยละ',
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  double.parse(electricityModels[0].eleMitSix!) == 0.00 ? '${electricityModels[0].eleGobSix}' : '${electricityModels[0].eleMitSix}',
                                                                                  textAlign: TextAlign.end,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  'บาท',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                    Divider(),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(15.0),
                                                                            child:
                                                                                Text(
                                                                              // ignore: unnecessary_string_interpolations
                                                                              '* อัตราคำนวณปัจจุบันอาจไม่ตรงกับยอดชำระ ณ วันที่บันทึก',
                                                                              textAlign: TextAlign.end,
                                                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          50,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }));
                                              },
                                              child: AutoSizeText(
                                                maxLines: 2,
                                                minFontSize: 13,
                                                maxFontSize: 15,
                                                'ดูอัตราคำนวณ',
                                                // '${nFormat.format(double.parse(quotxSelectModels[index].total!))}',
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              )),
                    ),
                  );
                },
              ),
            ),
            Container(
                width: (Responsive.isDesktop(context))
                    ? MediaQuery.of(context).size.width * 0.84
                    : MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  border: Border.all(color: Colors.grey, width: 0.1),
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
                                _scrollController1.animateTo(
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
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(3.0),
                                  child: const Text(
                                    'Top',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontFamily: FontWeight_.Fonts_T),
                                  )),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (_scrollController1.hasClients) {
                                final position =
                                    _scrollController1.position.maxScrollExtent;
                                _scrollController1.animateTo(
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
                                      fontFamily: FontWeight_.Fonts_T),
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
                            onTap: _moveUp1,
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
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(3.0),
                              child: const Text(
                                'Scroll',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
                                    fontFamily: FontWeight_.Fonts_T),
                              )),
                          InkWell(
                            onTap: _moveDown1,
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
          ],
        ),
      ),
    ]));
  }

  ///---------------------------------------------------------------------->

  Future<Null> checkshowDialog() async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                titlePadding: const EdgeInsets.all(0.0),
                contentPadding: const EdgeInsets.all(10.0),
                actionsPadding: const EdgeInsets.all(6.0),
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
                  ],
                ),
                content: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      dragStartBehavior: DragStartBehavior.start,
                      child: Row(
                        children: [
                          SizedBox(
                            width: (Responsive.isDesktop(context))
                                ? MediaQuery.of(context).size.width * 0.84
                                : 800,
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              children: [
                                Container(
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width *
                                            0.84
                                        : 800,
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
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'ประเภทค่าบริการ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                      fontSize: 14.0
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            widget.Get_Value_NameShop_index ==
                                                    '1'
                                                ? const SizedBox()
                                                : const Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      maxLines: 1,
                                                      minFontSize: 8,
                                                      maxFontSize: 20,
                                                      'งวด',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                          fontSize: 14.0),
                                                    ),
                                                  ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'วันที่ชำระ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'ประเภทค่าบริการ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'VAT',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'VAT(%)',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'VAT(฿)',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'ยอด',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'WHT (%)',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'WHT (฿)',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: AutoSizeText(
                                                maxLines: 1,
                                                minFontSize: 8,
                                                maxFontSize: 20,
                                                'ยอดสุทธิ',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                                Expanded(
                                  child: Container(
                                      // height:
                                      //     MediaQuery.of(context).size.height,
                                      // (Responsive.isDesktop(context))
                                      //     ? MediaQuery.of(context)
                                      //             .size
                                      //             .height *
                                      //         0.2
                                      //     : 300,
                                      width: (Responsive.isDesktop(context))
                                          ? MediaQuery.of(context).size.width *
                                              0.84
                                          : 800,
                                      decoration: const BoxDecoration(
                                        color:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0)),
                                        // border: Border.all(color: Colors.grey, width: 1),
                                      ),
                                      child: ListView.builder(
                                        controller: _scrollController2,
                                        // itemExtent: 50,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(), // const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: _TransModels.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Material(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            child: Container(
                                              // color: tappedIndex_2 ==
                                              //         index.toString()
                                              //     ? tappedIndex_Color
                                              //         .tappedIndex_Colors
                                              //         .withOpacity(0.5)
                                              //     : null,
                                              child: ListTile(
                                                  onTap: () {
                                                    // setState(() {
                                                    //   tappedIndex_2 = index.toString();
                                                    // });
                                                  },
                                                  title: Container(
                                                    decoration: BoxDecoration(
                                                      // color: Colors.green[100]!
                                                      //     .withOpacity(0.5),
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.black12,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        // Expanded(
                                                        //   flex: 1,
                                                        //   child: AutoSizeText(
                                                        //     maxLines: 1,
                                                        //     minFontSize: 8,
                                                        //     maxFontSize: 20,
                                                        //     '${(index + 1)}',
                                                        //     textAlign:
                                                        //         TextAlign.center,
                                                        //     style: const TextStyle(
                                                        //       color: TextHome_Color
                                                        //           .TextHome_Colors,
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${_TransModels[index].duedate != null && _TransModels[index].duedate!.isNotEmpty ? DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].duedate!} 00:00:00')) : '-'}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Tooltip(
                                                            richMessage:
                                                                TextSpan(
                                                              text:
                                                                  '${_TransModels[index].name!}',
                                                              style:
                                                                  const TextStyle(
                                                                color: HomeScreen_Color
                                                                    .Colors_Text1_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                //fontSize: 10.0
                                                              ),
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Colors
                                                                  .grey[200],
                                                            ),
                                                            child: AutoSizeText(
                                                              maxLines: 1,
                                                              minFontSize: 12,
                                                              maxFontSize: 14,
                                                              '${_TransModels[index].name!}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${_TransModels[index].vtype!}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${_TransModels[index].nvat!} %',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${_TransModels[index].vat!}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${_TransModels[index].pvat!}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${nFormat.format(double.tryParse(_TransModels[index].nwht ?? '') ?? 0.0)}',

                                                            //'${_TransModels[index].nwht!}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${nFormat.format(double.tryParse(_TransModels[index].wht ?? '') ?? 0.0)}',

                                                            //  '${_TransModels[index].wht!}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: AutoSizeText(
                                                            maxLines: 1,
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            '${nFormat.format(double.tryParse(_TransModels[index].total ?? '') ?? 0.0)}',
                                                            textAlign:
                                                                TextAlign.right,
                                                            style:
                                                                const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          );
                                        },
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }

  /////////////---------------------------------------------------->
  Dia_log1() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext builderContext) {
          Timer(Duration(milliseconds: 230), () {
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
}
