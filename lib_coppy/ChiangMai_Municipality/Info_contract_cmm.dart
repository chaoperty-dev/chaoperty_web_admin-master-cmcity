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
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../ChaoArea/ChaoRe_contact_add.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetContract_Photo_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/electricity_model.dart';
import '../PeopleChao/Seteing_listmenu.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Make_contract_CMM/repayment_contract_cmm.dart';
import 'Model/ContractsCid_Model.dart';
import 'Model/Dataconfig_Model.dart';
import 'Model/Document_Model.dart';
import 'Model/Person&Shop_Model.dart';
import 'Model/ReviewUuid_Model.dart';
import 'PDF_CMM/application_form1_cmm.dart';
import 'PDF_CMM/application_form2_cmm.dart';
import 'PDF_CMM/application_form3_cmm.dart';
import 'PDF_CMM/license_form_cmm.dart';
import 'PDF_CMM/receipt_cmm.dart';
import 'PDF_CMM/receipt_view_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import 'unity/API_approvals_roles&checkup.dart';
import 'unity/API_contracts_cid.dart';
import 'unity/API_documents_preview.dart';
import 'unity/Enum.dart';
import 'unity/FormatDate.dart';
import 'unity/FullScreenDocViewer.dart';
import 'unity/show_dialog_cmm.dart';

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
  List data_cid = [];
  List data_title_doc = [];
  List data_title_receipt = [];
  List submitteddoc_checklist = [];

  // List<Map<String, String>> data_picperson = [
  //   {"ser": "1", "title": "รูปผู้เช่า", "detail": "pic_tenant", "url": ""},
  //   {"ser": "2", "title": "รูปร้านค้า", "detail": "pic_shop", "url": ""},
  //   {"ser": "3", "title": "รูปแผนผัง", "detail": "pic_plan", "url": ""},
  // ];
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

  List data_receipt = [
    {
      "ser": "1",
      "title": "R68-04-000001",
      "datex": "21-04-2025",
      "status": "รอตรวจสอบ",
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
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool contractsCidData = true;
  @override
  void initState() {
    super.initState();
    Loading_Data_config();
    // read_GC_rental();
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
    red_contractsCid();
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
  List<ContractsCidModel> contractsCidModels = [];
  List<ContractDocuments> contractsDocuments = [];
  List<ClientsModel> clientx = [];

  String? age,
      national,
      json_number,
      json_moo,
      json_soi,
      json_road,
      json_tambon,
      json_amphoe,
      json_province;

  Future<void> red_contractsCid() async {
    debugPrint('--- red_contractsCid START ---');
    debugPrint('cid: ${widget.Get_Value_cid}');

    setState(() {
      // data_person.clear();
      // data_shop.clear();
      // data_cid.clear();
      // shopSubData.clear();
      contractsCidModels.clear();
      contractsDocuments.clear();
      clientx.clear();
    });

    final response = await readContractsCid(cid: '${widget.Get_Value_cid}');
    if (response == null) {
      debugPrint('❌ response == null');
      return;
    }

    debugPrint('✅ statusCode: ${response.statusCode}');
    if (response.statusCode != 200) {
      setState(() {
        contractsCidData = false;
        List<String> data_person_add = [
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
        ];

        List<String> data_shop_add = [
          "-",
          '',
          '',
          '',
        ];
        List<String> data_cid_add = [
          '',
          '',
        ];

        List<String> data_details_add = [
          '',
          '',
          '',
          '',
        ];

        List<String> data_shopsub_add = ['', '', ''];
        // อัปเดตข้อมูลทั้งหมด
        _updateCustomerData(data_person_add, data_shop_add, data_shopsub_add,
            data_details_add, data_cid_add);
      });
      Dialog_error(context, 'ขออภัยไม่พบข้อมูลผู้เช่า');
      // debugPrint('❌ body: ${response.body}');
      return;
    }
    if (response.statusCode != 200) {
      debugPrint('❌ body: ${response.body}');
      return;
    }

    dynamic jsonMap;
    try {
      jsonMap = json.decode(response.body);
    } catch (e) {
      debugPrint('❌ json decode error: $e');
      return;
    }

    debugPrint('✅ jsonMap type: ${jsonMap.runtimeType}');
    if (jsonMap is! Map) {
      debugPrint('❌ jsonMap is not Map');
      return;
    }

    final data = jsonMap['data'];
    debugPrint('✅ data type: ${data.runtimeType}');
    if (data is! Map<String, dynamic>) {
      debugPrint('❌ data is not Map<String,dynamic>');
      debugPrint('data = $data');
      return;
    }

    debugPrint('✅ data keys: ${data.keys.toList()}');
    debugPrint(
        'id: ${data['id']} | uuid: ${data['uuid']} | status: ${data['status']}');

    // ---------- contractDocuments ----------
    final docsRaw = data['contractDocuments'] ?? data['contract_documents'];
    debugPrint('contractDocuments raw type: ${docsRaw.runtimeType}');
    if (docsRaw is List) {
      debugPrint('contractDocuments count: ${docsRaw.length}');
      if (docsRaw.isNotEmpty) {
        debugPrint(
            'contractDocuments[0] keys: ${(docsRaw.first as Map).keys.toList()}');
      }
    } else {
      debugPrint('contractDocuments = null or not List');
    }

    // ---------- clients ----------
    final clientRaw = data['clients'];
    debugPrint('clients raw type: ${clientRaw.runtimeType}');
    if (clientRaw is Map) {
      final Map<String, dynamic> c = Map<String, dynamic>.from(clientRaw);

      final Map<String, dynamic> addrJson = (c['json'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(c['json'])
          : {};

      setState(() {
        age = c['age']?.toString() ?? '';
        national = c['national']?.toString() ?? '';

        json_number = addrJson['number']?.toString() ?? '';
        json_moo = addrJson['moo']?.toString() ?? '';
        json_soi = addrJson['soi']?.toString() ?? '';
        json_road = addrJson['road']?.toString() ?? '';
        json_tambon = addrJson['tambon']?.toString() ?? '';
        json_amphoe = addrJson['amphoe']?.toString() ?? '';
        json_province = addrJson['province']?.toString() ?? '';
      });
    } else {
      debugPrint('clients = null or not Map');
    }

    // ---------- parse models ----------
    try {
      final model = ContractsCidModel.fromJson(data);

      final modelDocuments = (docsRaw is List)
          ? docsRaw
              .whereType<Map>()
              .map((e) =>
                  ContractDocuments.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ContractDocuments>[];

      final modelClient = (clientRaw is Map<String, dynamic>)
          ? ClientsModel.fromJson(clientRaw)
          : null;

      print('✅ parsed model.uuid: ${model.uuid}');
      print('✅ parsed documents: ${modelDocuments.length}');
      // debugPrint(
      //     '✅ parsed client: ${modelClient?.uuid} / age=${modelClient?.age}');
      setState(() {
        contractsCidModels = [model];
        contractsDocuments = modelDocuments;
        // age = '123';
        if (modelClient != null) {
          clientx = [modelClient];
        }
      });

      // setState(() {
      //   contractsCidModels = [model];
      //   contractsDocuments = modelDocuments;
      //   if (modelClient != null) clientx = [modelClient];
      // });
      print('--- red_contractsCid END --- client ${clientx.length}');
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (response.statusCode == 200) {
          await read_data();
        }
      });
    } catch (e, st) {
      print('❌ parse model error: $e');
      print('$st');
    }
  }

  // Future<void> red_contractsCid() async {
  //   //print('loadContractsCid');

  //   setState(() {
  //     // requestUuid = value;
  //     // FlowUuid = valueFlowUuid;
  //     // isLoading_main = true;
  //     // isLoading = true;
  //     contractsCidModels.clear();
  //     contractsDocuments.clear();
  //   });

  //   final response = await readContractsCid(cid: '${widget.Get_Value_cid}');
  //   if (response != null && response.statusCode == 200) {
  //     final jsonMap = json.decode(response.body);
  //     if (jsonMap['data'] is Map<String, dynamic>) {
  //       final model = ContractsCidModel.fromJson(jsonMap['data']);

  //       // ✅ contractDocuments เป็น List
  //       final docsJson = jsonMap['data']['contractDocuments'] as List<dynamic>;
  //       final modelDocuments =
  //           docsJson.map((e) => ContractDocuments.fromJson(e)).toList();

  //       setState(() {
  //         contractsCidModels = [model];
  //         contractsDocuments = modelDocuments; // 👈 ไม่ใช่แค่ 1
  //       });

  //       //print('✅ โหลด ${contractsCidModels.length} รายการเสร็จสมบูรณ์');
  //       //print('📄 เอกสารที่โหลดได้: ${contractsDocuments.length}');
  //     } else {
  //       //print('❌ "data" ไม่ใช่ Map');
  //     }

  //     // if (jsonMap['data'] is Map<String, dynamic>) {
  //     //   final model = ContractsCidModel.fromJson(jsonMap['data']);
  //     //   final modelDocuments =
  //     //       ContractDocuments.fromJson(jsonMap['data']['contractDocuments']);
  //     //   setState(() {
  //     //     contractsCidModels = [model];
  //     //     contractsDocuments = [modelDocuments];
  //     //     // isLoading_main = false;
  //     //     // isLoading = false;
  //     //   });
  //     //   //print('✅ โหลด 1 รายการเสร็จสมบูรณ์');
  //     //   //print(contractsDocuments.length);
  //     //   //print('✅ โหลด 1 รายการเสร็จสมบูรณ์**');
  //     // }
  //     //else {
  //     //   //print('❌ "data" ไม่ใช่ Map');
  //     // }
  //     //print('length red_contractsCid: ${contractsCidModels.length}');
  //   } else {
  //     //print('❌ ไม่สามารถโหลดข้อมูลได้');
  //   }
  // }

  // Future<void> red_contractsCid() async {
  //   setState(() {
  //     contractsCidModels.clear();
  //   });

  //   //print('loadcontractsCid');
  //   final response = await readContractsCid(cid: '100010082025');

  //   // ถ้า readContractsCid คืนเป็น http.Response
  //   final Map<String, dynamic> result = json.decode(response!.body);

  //   //print('📦 red_contractsCid: $result');

  //   if (result['data'] is List) {
  //     final List<dynamic> list = result['data'];

  //     setState(() {
  //       contractsCidModels = list
  //           .map((e) => ContractsCidModel.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     });
  //   }

  //   //print('length red_contractsCid: ${contractsCidModels.length}');
  // }

  ///////////------------------------------------>
  Loading_Data_config() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();
    final checklist = await getSubmittedDocumentsDisplayFields();
    setState(() {
      data_cid = cid;
      data_title_doc = doc;
      data_title_receipt = receipt;
      submitteddoc_checklist = checklist;
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
    // //print('GC_quot_conx>>>> $url');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
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
      // //print(result);
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
      // //print(result);
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
      //print('⚠️ ไม่พบค่า renTalSer ใน SharedPreferences');
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
        //print('⚠️ ไม่พบข้อมูล rental หรือรูปแบบข้อมูลไม่ถูกต้อง');
      }
    } catch (e, stackTrace) {
      //print('❌ เกิดข้อผิดพลาดใน read_GC_rental: $e');
      //print('🪵 StackTrace: $stackTrace');
    }

    await read_GC_photo();
    // await read_data();
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
    //print('Get_Value_NameShop_index >>>>>> $qutser');

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
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
        //print('AddForm_requests_uuid');

        AddForm_requests_uuid(0);
      }
    } catch (e, stackTrace) {
      print('❌ Error in read_data: $e');
      print('🪵 StackTrace: $stackTrace');
    }
  }

  Future<void> read_GC_photo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final user = preferences.getString('ser');
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;

    if (ren == null || user == null || foder == null) {
      //print('⚠️ ข้อมูลที่จำเป็นไม่ครบ: ren/user/foder');
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

            // data_picperson = [
            //   {
            //     "ser": "1",
            //     "title": "รูปผู้เช่า",
            //     "detail": "pic_tenant",
            //     "url":
            //         '${MyConstant().domain}/files/$foder/contract/$tenantPic',
            //   },
            //   {
            //     "ser": "2",
            //     "title": "รูปร้านค้า",
            //     "detail": "pic_shop",
            //     "url": '${MyConstant().domain}/files/$foder/contract/$shopPic',
            //   },
            //   {
            //     "ser": "3",
            //     "title": "รูปแผนผัง",
            //     "detail": "pic_plan",
            //     "url": '${MyConstant().domain}/files/$foder/contract/$planPic',
            //   },
            // ];

            contractPhotoModels.clear();
            contractPhotoModels.add(model);
          });

          tempPhotoModels.add(model);
        }
      } else {
        //print('⚠️ ไม่พบข้อมูลรูปภาพสัญญา หรือข้อมูลไม่ถูกต้อง');
      }
    } catch (e, stackTrace) {
      //print('❌ เกิดข้อผิดพลาดใน read_GC_photo: $e');
      //print('🪵 StackTrace: $stackTrace');
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
      //print('❌ User canceled image selection');
      return;
    }

    try {
      //print('📷 Picked image path: ${pickedFile.path}');

      final imageBytes = await pickedFile.readAsBytes();
      //print('📏 Image size in bytes: ${imageBytes.length}');

      final base64Image = base64Encode(imageBytes);
      final url =
          '${MyConstant().domain}/File_photo.php?name=$fileName_Slip&Foder=$foder';

      //print('📡 Uploading to: File_photo');

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64Image,
          'Foder': foder,
          'name': fileName_Slip,
        },
      );

      //print('📥 Upload response: ${response.statusCode}');
      //print('📨 Server says: ${response.body}');

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        if (jsonRes['message'] == 'Image uploaded successfully') {
          //print('✅ Image uploaded successfully');
          await up_photo_string();
        } else {
          //print(
          //  '⚠️ Server responded but message was unexpected: ${jsonRes['message']}');
        }
      } else {
        //print('❌ Image upload failed with status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      //print('❌ Error during image processing: $e');
      //print('🪵 StackTrace:\n$stackTrace');
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
        //print('❌ ข้อมูลไม่ครบ ไม่สามารถส่งคำขอได้');
        //print(
        //  '🔸 ren: $ren, user: $user, ciddoc: $ciddoc, qutser: $qutser, fiewx: $fiewx, fileName: $fileNameSafe');
        return;
      }

      final url = '${MyConstant().domain}/GC_tran_Kon_photo.php?isAdd=true'
          '&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser'
          '&fiewx=$fiewx&fileName_Slip=$fileNameSafe';

      //print('📡 เรียก URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        //print('📥 Response: $result');

        if (result.toString() == 'true') {
          //print('✅ อัปเดตรูปภาพในระบบสำเร็จ');

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
          //print('⚠️ ไม่สามารถอัปเดตได้: *โหลดรูปใหม่');
        }
      } else {
        //print('❌ HTTP ERROR: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      //print('❌ Exception ใน up_photo_string: $e');
      //print('🪵 StackTrace:\n$stackTrace');
    }
  }

  void AddForm_requests_uuid(index) {
    TeNantModel model = teNantModels[index]; // ดึง object ออกมาก่อน
    print("AddForm_requests_uuid");
    print({
      "${model.cname}",
      "${model.tax}",
      age.toString(),
      national ?? "",
      json_number ?? "",
      json_moo ?? "",
      json_soi ?? "",
      json_road ?? "",
      json_tambon ?? "",
      json_amphoe ?? "",
      json_province ?? "",
      "${model.tel}",
      "${model.addr}",
    });
    if (contractsCidData == false || contractsCidModels.isEmpty) {
      print("======= contractsCidModels.isEmpty");
      List<String> data_person_add = [
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ];

      List<String> data_shop_add = [
        "-",
        '',
        '',
        '',
      ];
      List<String> data_cid_add = [
        '',
        '',
      ];
      List<String> data_details_add = [
        '',
        '',
        '',
        '',
      ];

      List<String> data_shopsub_add = ['', '', ''];
      // อัปเดตข้อมูลทั้งหมด
      _updateCustomerData(data_person_add, data_shop_add, data_shopsub_add,
          data_details_add, data_cid_add);
    } else {
      print("======= contractsCidData ${contractsCidData}");
      List<String> data_person_add = [
        "${model.cname}",
        "${model.tax}",
        age.toString(),
        national ?? "",
        json_number ?? "",
        json_moo ?? "",
        json_soi ?? "",
        json_road ?? "",
        json_tambon ?? "",
        json_amphoe ?? "",
        json_province ?? "",
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
      List<String> data_details_add = [
        model.sdate ?? '',
        model.ldate ?? '',
        model.stype ?? '',
        '1',
      ];
      // //print('data_person_add');
      // //print(data_cid_add.length);
      List<String> data_shopsub_add = [
        '${model.subzone ?? "-"}',
        '${model.zn}',
        '${model.area_c}'
      ];
      // อัปเดตข้อมูลทั้งหมด
      _updateCustomerData(data_person_add, data_shop_add, data_shopsub_add,
          data_details_add, data_cid_add);
      // _updateCustomerData(
      //     data_person_add, data_shop_add, data_shopsub_add, data_cid_add);
    }

    // Dia_log1(context);
    // Timer(Duration(milliseconds: 300), () {
    //   Navigator.of(context).pop();
    // });
  }

  ///////////----------------------->
  void _updateCustomerData(
      personData, shopData, shopSubData, detailsData, cidData) {
    setState(() {
      // อัปเดต person
      for (int i = 0; i < personData.length && i < data_person.length; i++) {
        data_person[i].detail = personData[i].toString();
      }

      // อัปเดต shop
      for (int i = 0; i < shopData.length && i < data_shop.length; i++) {
        data_shop[i].detail = shopData[i].toString();
      }

      // อัปเดต shop.sub เฉพาะ data_shop[0]
      if (data_shop.isNotEmpty) {
        for (int i = 0;
            i < shopSubData.length && i < data_shop[0].detailsub.length;
            i++) {
          data_shop[0].detailsub[i].detail = shopSubData[i].toString();
        }
      }
      // อัปเดต cid
      for (int i = 0; i < cidData.length && i < data_cid.length; i++) {
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
      _controllers_cid = List.generate(
        data_cid.length,
        (i) => TextEditingController(text: data_cid[i]['detail']),
      );
      _controllers_shop_sub = List.generate(
        data_shop[0].detailsub.length,
        (i) => TextEditingController(
          text: data_shop[0].detailsub[i].detail,
        ),
      );
    });
  }

  // void _updateCustomerData(
  //   List personData,
  //   List shopData,
  //   List shopSubData,
  //   List cidData,
  // ) {
  //   setState(() {
  //     // ===== person =====
  //     final pLen = personData.length < data_person.length
  //         ? personData.length
  //         : data_person.length;

  //     for (int i = 0; i < pLen; i++) {
  //       data_person[i].detail = (personData[i] ?? '').toString();
  //     }

  //     // ===== shop =====
  //     final sLen = shopData.length < data_shop.length
  //         ? shopData.length
  //         : data_shop.length;

  //     for (int i = 0; i < sLen; i++) {
  //       data_shop[i].detail = (shopData[i] ?? '').toString();
  //     }

  //     // ===== shopSub (เฉพาะ data_shop[0]) =====
  //     final subLen = shopSubData.length < data_shop[0].detailsub.length
  //         ? shopSubData.length
  //         : data_shop[0].detailsub.length;

  //     for (int i = 0; i < subLen; i++) {
  //       data_shop[0].detailsub[i].detail = (shopSubData[i] ?? '').toString();
  //     }

  //     // ===== cid =====
  //     final cLen =
  //         cidData.length < data_cid.length ? cidData.length : data_cid.length;

  //     for (int i = 0; i < cLen; i++) {
  //       data_cid[i]['detail'] = (cidData[i] ?? '').toString();
  //     }

  //     // ===== rebuild controllers (กัน null) =====
  //     _controllers_person = List.generate(
  //       data_person.length,
  //       (i) => TextEditingController(
  //           text: (data_person[i].detail ?? '').toString()),
  //     );

  //     _controllers_shop = List.generate(
  //       data_shop.length,
  //       (i) =>
  //           TextEditingController(text: (data_shop[i].detail ?? '').toString()),
  //     );

  //     _controllers_shop_sub = List.generate(
  //       data_shop[0].detailsub.length,
  //       (i) => TextEditingController(
  //         text: (data_shop[0].detailsub[i].detail ?? '').toString(),
  //       ),
  //     );

  //     _controllers_cid = List.generate(
  //       data_cid.length,
  //       (i) => TextEditingController(
  //         text: (data_cid[i]['detail'] ?? '').toString(),
  //       ),
  //     );
  //   });
  // }

  // void _updateCustomerData(personData, shopData, shopSubData, cidData) {
  //   setState(() {
  //     // อัปเดต person
  //     for (int i = 0; i < personData.length; i++) {
  //       data_person[i].detail = personData[i].toString();
  //     }

  //     // อัปเดต shop
  //     for (int i = 0; i < shopData.length; i++) {
  //       data_shop[i].detail = shopData[i].toString();
  //     }

  //     // อัปเดต shop.sub เฉพาะ data_shop[0]
  //     for (int i = 0; i < shopSubData.length; i++) {
  //       data_shop[0].detailsub[i].detail = shopSubData[i].toString();
  //     }
  //     // อัปเดต data cid
  //     for (int i = 0; i < cidData.length; i++) {
  //       // //print(cidData[i].toString());
  //       data_cid[i]['detail'] = cidData[i].toString();
  //     }
  //     // รีสร้าง controller ทั้งหมด
  //     _controllers_person = List.generate(
  //       data_person.length,
  //       (i) => TextEditingController(text: data_person[i].detail),
  //     );

  //     _controllers_shop = List.generate(
  //       data_shop.length,
  //       (i) => TextEditingController(text: data_shop[i].detail),
  //     );

  //     _controllers_shop_sub = List.generate(
  //       data_shop[0].detailsub.length,
  //       (i) => TextEditingController(
  //         text: data_shop[0].detailsub[i].detail,
  //       ),
  //     );
  //     _controllers_cid = List.generate(
  //       data_cid.length,
  //       (i) => TextEditingController(text: data_cid[i]['detail']),
  //     );
  //   });
  // }

  String getDisplayText(
      ContractAttachments doc, Map<String, dynamic> titleDoc) {
    String displayText = '';

    switch (titleDoc["ser"].toString()) {
      case '1':
        displayText = doc.document!.nameTh ?? '';
        break;
      case '2':
        displayText =
            formatDate(doc.attachment?.uploadedAt, type: DateFormatType.dmy);
        break;
      case '3':
        displayText = doc.attachment?.uuid ?? '';
        break;
      case '4':
        displayText = doc.attachment?.statusLabel ?? '';
        break;
      default:
        displayText =
            formatDate(doc.attachment?.reviewedAt, type: DateFormatType.dmy);
        break;
    }

    return displayText;
  }

  String getDisplayTextReceipt(
      ReceiptDocuments receipt, Map<String, dynamic> titleDoc) {
    String displayText = '';

    switch (titleDoc["ser"].toString()) {
      case '1':
        displayText = receipt.document!.nameTh ?? '';
        break;
      case '2':
        displayText = formatDate(receipt.attachment?.uploadedAt,
            type: DateFormatType.dmy);
        break;
      case '3':
        displayText = receipt.attachment?.uuid ?? '';
        break;
      case '4':
        displayText = 'ผ่าน'; // receipt.attachment?.statusLabel ?? '';
        break;
      default:
        displayText = formatDate(receipt.attachment?.reviewedAt,
            type: DateFormatType.dmy);
        break;
    }

    return displayText;
  }

  Widget _buildSidebarSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: CustomerScreen_Color.Colors_Text1_),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: CustomerScreen_Color.Colors_Text1_,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: ser_tabbarview_2 == 0
            ? SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height + 300,
                  child: Column(children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     child: Row(
                    //       children:
                    //           List.generate(data_picperson.length, (index_pic) {
                    //         final url = data_picperson[index_pic]['url'];
                    //         final title = data_picperson[index_pic]['title'];
                    //         final detailKey =
                    //             data_picperson[index_pic]['detail'];
                    //         final img = data_picperson[index_pic]['img'];

                    //         return Padding(
                    //           padding:
                    //               const EdgeInsets.symmetric(horizontal: 8.0),
                    //           child: InkWell(
                    //             borderRadius: BorderRadius.circular(16),
                    //             onTap: () {
                    //               setState(() {
                    //                 fiew = detailKey;
                    //               });
                    //               uploadImage(ImageSource.gallery);
                    //             },
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 Container(
                    //                   width: 280,
                    //                   height: 170,
                    //                   decoration: BoxDecoration(
                    //                     borderRadius: BorderRadius.circular(16),
                    //                     color: Colors.grey[200],
                    //                     boxShadow: [
                    //                       BoxShadow(
                    //                         color:
                    //                             Colors.black12.withOpacity(0.1),
                    //                         blurRadius: 8,
                    //                         spreadRadius: 1,
                    //                         offset: const Offset(0, 4),
                    //                       ),
                    //                     ],
                    //                     image: (img != null && img.isNotEmpty)
                    //                         ? DecorationImage(
                    //                             image: NetworkImage(url!),
                    //                             // fit: BoxFit.fitHeight,
                    //                           )
                    //                         : null,
                    //                   ),
                    //                   child: (img == null || img.isEmpty)
                    //                       ? Container(
                    //                           decoration: BoxDecoration(
                    //                             image: DecorationImage(
                    //                               colorFilter:
                    //                                   new ColorFilter.mode(
                    //                                       Colors.white
                    //                                           .withOpacity(
                    //                                               0.05),
                    //                                       BlendMode.dstATop),
                    //                               image: AssetImage(
                    //                                   "images/BG_im.png"),
                    //                               fit: BoxFit.cover,
                    //                             ),
                    //                           ),
                    //                           child: Center(
                    //                             child: Column(
                    //                               mainAxisSize:
                    //                                   MainAxisSize.min,
                    //                               children: const [
                    //                                 Icon(Icons.upload_rounded,
                    //                                     size: 48,
                    //                                     color: Colors.grey),
                    //                                 SizedBox(height: 8),
                    //                                 Text(
                    //                                   "ยังไม่ได้เลือกรูป",
                    //                                   style: TextStyle(
                    //                                     color: Colors.grey,
                    //                                     fontFamily:
                    //                                         Font_.Fonts_T,
                    //                                     fontWeight:
                    //                                         FontWeight.bold,
                    //                                   ),
                    //                                 ),
                    //                                 SizedBox(height: 4),
                    //                                 Text(
                    //                                   "รองรับ JPG / PNG\nขนาดไม่เกิน 10MB\n280X180",
                    //                                   textAlign:
                    //                                       TextAlign.center,
                    //                                   style: TextStyle(
                    //                                     fontSize: 11,
                    //                                     color: Colors.grey,
                    //                                     fontFamily:
                    //                                         Font_.Fonts_T,
                    //                                   ),
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ),
                    //                         )
                    //                       : Container(
                    //                           decoration: BoxDecoration(
                    //                             borderRadius:
                    //                                 BorderRadius.circular(16),
                    //                             gradient: LinearGradient(
                    //                               colors: [
                    //                                 Colors.black
                    //                                     .withOpacity(0.1),
                    //                                 Colors.black
                    //                                     .withOpacity(0.3),
                    //                               ],
                    //                               begin: Alignment.topCenter,
                    //                               end: Alignment.bottomCenter,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                 ),
                    //                 const SizedBox(height: 10),
                    //                 Text(
                    //                   title ?? '',
                    //                   style: const TextStyle(
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 14,
                    //                     fontFamily: FontWeight_.Fonts_T,
                    //                     color: Colors.black87,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         );
                    //       }),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          }),
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                  width: (MediaQuery.of(context).size.width <
                                          1370)
                                      ? 1400
                                      : (Responsive.isDesktop(context))
                                          ? MediaQuery.of(context).size.width *
                                              0.85
                                          : 1400.00,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Form(
                                              key: _formKey_person,
                                              child: Column(children: [
                                                _buildSidebarSectionTitle(
                                                    Icons.person,
                                                    'ข้อมูลบุคคล'),
                                                Form_Person(context),
                                                const SizedBox(height: 20),
                                                _buildSidebarSectionTitle(
                                                    Icons.store,
                                                    'ข้อมูลร้านค้า'),
                                                Form_Shop(context),
                                                const SizedBox(height: 20),
                                                _buildSidebarSectionTitle(
                                                    Icons.receipt_long,
                                                    'ข้อมูลสัญญา'),
                                                Form_Cid(context),
                                                const SizedBox(height: 30),
                                                // Form_Person(context),
                                                // SizedBox(
                                                //   height: 20,
                                                // ), // for (var shop in data_shop)
                                                // Form_Shop(context),
                                                // SizedBox(
                                                //   height: 10,
                                                // ),
                                                // Form_Cid(context),

                                                // SizedBox(
                                                //   height: 60,
                                                // ),
                                                // // Form_Cid(context),
                                              ]),
                                            ),
                                          )),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                        children: List.generate(
                                                            data_tap.length,
                                                            (index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: SizedBox(
                                                          // width: 200,
                                                          child: ElevatedButton(
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                          Color>(
                                                                Colors.grey,
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                ser_data_tap =
                                                                    '${data_tap[index]['ser']}';
                                                              });
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Translate.TranslateAndSet_TextAutoSize(
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
              )
            : ser_tabbarview_2 == 1
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                if (ser_tabbarview_2 == 2) {
                                  ser_tabbarview_2 = 0;
                                } else {
                                  ser_tabbarview_2 = 2;
                                }
                              });

                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              String? ren = preferences.getString('renTalSer');
                              String? ser_user = preferences.getString('ser');
                              var name = preferences.getString('fname');
                              Insert_log.Insert_logs('สัญญาเช่า',
                                  '$name>สัญญา${widget.Get_Value_cid}>เพิ่มค่าบริการ');
                              String url2 =
                                  '${MyConstant().domain}/D_quotx.php?isAdd=true&ren=$ren&ser_user=$ser_user';

                              try {
                                var response2 = await http.get(Uri.parse(url2));

                                var result2 = json.decode(response2.body);
                                //print(result2);
                                if (result2.toString() == 'true') {}
                              } catch (e) {}
                            },
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                ser_tabbarview_2 == 2
                                    ? 'ยกเลิกเพิ่มค่าบริการ'
                                    : 'เพิ่มค่าบริการ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T
                                    // fontSize: 15.0,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                if (ser_tabbarview_2 == 1) {
                                  ser_tabbarview_2 = 0;
                                } else {
                                  ser_tabbarview_2 = 1;
                                }
                              });

                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var name = preferences.getString('fname');
                              Insert_log.Insert_logs('สัญญาเช่า',
                                  '$name>สัญญา${widget.Get_Value_cid}>ปรับตั้งหนี้');
                            },
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.orange[900],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                ser_tabbarview_2 == 1
                                    ? 'ยกเลิกปรับตั้งหนี้'
                                    : 'ปรับตั้งหนี้',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontSize: 15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SettringListMenu(
                          Get_Value_cid: widget.Get_Value_cid,
                          Get_Value_NameShop_index:
                              widget.Get_Value_NameShop_index),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                if (ser_tabbarview_2 == 2) {
                                  ser_tabbarview_2 = 0;
                                } else {
                                  ser_tabbarview_2 = 2;
                                }
                              });

                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              String? ren = preferences.getString('renTalSer');
                              String? ser_user = preferences.getString('ser');
                              var name = preferences.getString('fname');
                              Insert_log.Insert_logs('สัญญาเช่า',
                                  '$name>สัญญา${widget.Get_Value_cid}>เพิ่มค่าบริการ');
                              String url2 =
                                  '${MyConstant().domain}/D_quotx.php?isAdd=true&ren=$ren&ser_user=$ser_user';

                              try {
                                var response2 = await http.get(Uri.parse(url2));

                                var result2 = json.decode(response2.body);
                                //print(result2);
                                if (result2.toString() == 'true') {}
                              } catch (e) {}
                            },
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                ser_tabbarview_2 == 2
                                    ? 'ยกเลิกเพิ่มค่าบริการ'
                                    : 'เพิ่มค่าบริการ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T
                                    // fontSize: 15.0,
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                if (ser_tabbarview_2 == 1) {
                                  ser_tabbarview_2 = 0;
                                } else {
                                  ser_tabbarview_2 = 1;
                                }
                              });

                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var name = preferences.getString('fname');
                              Insert_log.Insert_logs('สัญญาเช่า',
                                  '$name>สัญญา${widget.Get_Value_cid}>ปรับตั้งหนี้');
                            },
                            child: Container(
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.orange[900],
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                ser_tabbarview_2 == 1
                                    ? 'ยกเลิกปรับตั้งหนี้'
                                    : 'ปรับตั้งหนี้',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T,
                                    fontSize: 15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ChaoReContactAdd(
                        Value_cid: widget.Get_Value_cid,
                      ),
                    ],
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
            height: (index == 0 || index + 1 == data_person.length) ? null : 40,
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
                      data_person[index].title.replaceAll('*', '') ?? '',
                      // '${data_person[index].title}',
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
                      maxLines: (index + 1 == data_person.length)
                          ? 3
                          : (index == 0)
                              ? 2
                              : 1,
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
            height: (data_shop[shop].ser.toString() == '1') ? 150 : 40,
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
                      '${data_shop[shop].title}',
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                for (int shop_sub = 0;
                                    shop_sub <
                                        data_shop[shop].detailsub.length - 1;
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
                                        controller:
                                            _controllers_shop_sub[shop_sub],
                                        maxLines: 1,
                                        // style: TextStyle(
                                        //     overflow: TextOverflow.ellipsis),
                                        // initialValue:
                                        //     '${shop_sub["detail"]}',
                                        onFieldSubmitted: (value) async {},

                                        decoration: InputDecoration(
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
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
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                for (int shop_sub = 2;
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
                                        controller:
                                            _controllers_shop_sub[shop_sub],
                                        maxLines: 1,
                                        // style: TextStyle(
                                        //     overflow: TextOverflow.ellipsis),
                                        // initialValue:
                                        //     '${shop_sub["detail"]}',
                                        onFieldSubmitted: (value) async {},

                                        decoration: InputDecoration(
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
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
                            style: TextStyle(overflow: TextOverflow.ellipsis),
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
  // Form_Shop(context) {
  //   return SizedBox(
  //       child: Column(children: [
  //     // for (var shop in data_shop)
  //     for (int shop = 0; shop < data_shop.length; shop++)
  //       Padding(
  //         padding: const EdgeInsets.all(2.0),
  //         child: SizedBox(
  //           height: 40,
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 flex: 1,
  //                 child: Container(
  //                   padding: const EdgeInsets.all(2.0),
  //                   child: AutoSizeText(
  //                     minFontSize: 12,
  //                     maxFontSize: 16,
  //                     maxLines: 1,
  //                     '${data_shop[shop].title}*',
  //                     textAlign: TextAlign.left,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                         color: PeopleChaoScreen_Color.Colors_Text2_,
  //                         fontFamily: Font_.Fonts_T),
  //                   ),
  //                 ),
  //               ),
  //               (data_shop[shop].ser.toString() == '1')
  //                   ? Expanded(
  //                       flex: 2,
  //                       child: Row(
  //                         children: [
  //                           for (int shop_sub = 0;
  //                               shop_sub < data_shop[shop].detailsub.length;
  //                               shop_sub++)
  //                             // for (var shop_sub
  //                             //     in data_shop[shop]
  //                             //         [
  //                             //         "detailsub"])
  //                             Expanded(
  //                               flex: 1,
  //                               child: Container(
  //                                 padding: const EdgeInsets.all(2.0),
  //                                 child: TextFormField(
  //                                   textAlign: TextAlign.left,
  //                                   keyboardType: TextInputType.number,
  //                                   showCursor: false,
  //                                   readOnly: true,
  //                                   controller: _controllers_shop_sub[shop_sub],
  //                                   // initialValue:
  //                                   //     '${shop_sub["detail"]}',
  //                                   onFieldSubmitted: (value) async {},

  //                                   decoration: InputDecoration(
  //                                       fillColor:
  //                                           Colors.white.withOpacity(0.3),
  //                                       filled: true,
  //                                       focusedBorder: const OutlineInputBorder(
  //                                         borderRadius: BorderRadius.all(
  //                                             Radius.circular(6)),
  //                                         borderSide: BorderSide(
  //                                           width: 1,
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                       enabledBorder: const OutlineInputBorder(
  //                                         borderRadius: BorderRadius.all(
  //                                             Radius.circular(6)),
  //                                         borderSide: BorderSide(
  //                                           width: 1,
  //                                           color: Colors.grey,
  //                                         ),
  //                                       ),
  //                                       labelText:
  //                                           '${data_shop[shop].detailsub[shop_sub].titlesub}',
  //                                       labelStyle: const TextStyle(
  //                                           fontSize: 16,
  //                                           color: Colors.black,
  //                                           fontFamily: Font_.Fonts_T)),
  //                                   // inputFormatters: <TextInputFormatter>[
  //                                   //   // for below version 2 use this
  //                                   //   FilteringTextInputFormatter
  //                                   //       .allow(RegExp(r'[0-9]')),
  //                                   //   // for version 2 and greater youcan also use this
  //                                   //   FilteringTextInputFormatter
  //                                   //       .digitsOnly
  //                                   // ],
  //                                 ),
  //                               ),
  //                             )
  //                         ],
  //                       ),
  //                     )
  //                   : Expanded(
  //                       flex: 2,
  //                       child: Container(
  //                         padding: const EdgeInsets.all(2.0),
  //                         child: TextFormField(
  //                           textAlign: TextAlign.left,
  //                           keyboardType: TextInputType.number,
  //                           showCursor: false,
  //                           readOnly: true,
  //                           controller: _controllers_shop[shop],
  //                           //   initialValue:

  //                           // '${shop["detail"]}',
  //                           onFieldSubmitted: (value) async {},

  //                           decoration: InputDecoration(
  //                               fillColor: Colors.white.withOpacity(0.3),
  //                               filled: true,
  //                               focusedBorder: const OutlineInputBorder(
  //                                 borderRadius:
  //                                     BorderRadius.all(Radius.circular(6)),
  //                                 borderSide: BorderSide(
  //                                   width: 1,
  //                                   color: Colors.black,
  //                                 ),
  //                               ),
  //                               enabledBorder: const OutlineInputBorder(
  //                                 borderRadius:
  //                                     BorderRadius.all(Radius.circular(6)),
  //                                 borderSide: BorderSide(
  //                                   width: 1,
  //                                   color: Colors.grey,
  //                                 ),
  //                               ),
  //                               // labelText: 'ระบุชื่อร้านค้า',
  //                               labelStyle: const TextStyle(
  //                                   fontSize: 14,
  //                                   color: Colors.black54,
  //                                   fontFamily: Font_.Fonts_T)),
  //                           // inputFormatters: <TextInputFormatter>[
  //                           //   // for below version 2 use this
  //                           //   FilteringTextInputFormatter
  //                           //       .allow(RegExp(r'[0-9]')),
  //                           //   // for version 2 and greater youcan also use this
  //                           //   FilteringTextInputFormatter
  //                           //       .digitsOnly
  //                           // ],
  //                         ),
  //                       ),
  //                     )
  //             ],
  //           ),
  //         ),
  //       ),
  //   ]));
  // }

  Form_Cid(context) {
    // Helper: overlay ลายน้ำ (สมมุติว่ามีฟังก์ชันนี้อยู่แล้วในไฟล์เดียวกัน)
    Widget _watermark() => IgnorePointer(child: _buildWatermarkOverlay());
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
    // Helper: overlay ลายน้ำ (สมมุติว่ามีฟังก์ชันนี้อยู่แล้วในไฟล์เดียวกัน)
    Widget _watermark() => IgnorePointer(child: _buildWatermarkOverlay());
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Center(
                child: AutoSizeText(
                  minFontSize: 12,
                  maxFontSize: 16,
                  maxLines: 1,
                  'เอกสารคำร้องขอต่อสัญญา/ใบอนุญาต',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                      fontFamily: Font_.Fonts_T),
                ),
              ),
            ),
            // for (var doc in contractsDocuments)
            if (contractsDocuments.length == 0) ...[
              SizedBox(
                height: 100,
                child: Center(child: Text('ไม่พบเอกสารแนบ')),
              )
            ],

            for (var doc in contractsDocuments.asMap().entries)
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
                          '${doc.key + 1}. ${doc.value.documentname ?? ''}',
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
                        // final atts =   contractsCidModels.first.contractDocuments!.first.attachments.;
                        final atts = doc.value.attachments ?? [];
                        // //print(atts);
                        if (atts.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                                content: Text('ไม่พบไฟล์แนบ')),
                          );
                          return;
                        }

                        final first = atts.first;
                        final String? uuid = doc.value.uuid;
                        final String? requestUuidDocs = doc.value.requestUuid;

                        if (uuid == null || requestUuidDocs == null) {
                          showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                                content: Text('ข้อมูลไฟล์แนบไม่ครบ')),
                          );
                          return;
                        }

                        // สร้าง future หลังจากเช็ค null ครบ
                        final Future<http.Response?> future =
                            documentsPreview(requestUuidDocs, uuid);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          useSafeArea: false, // ✅ อนุญาตให้ชิดขอบจอ
                          builder: (context) {
                            final future =
                                documentsPreview(requestUuidDocs, uuid);

                            return Stack(
                              children: [
                                // พื้นหลัง (ถ้าอยากให้จาง)
                                Positioned.fill(
                                  child: Container(
                                      color: Colors.black.withOpacity(0.85)),
                                ),
                                // เนื้อหาเต็มจอ
                                Positioned.fill(
                                  child: Material(
                                    // ให้มี Material สำหรับ Ink/Theme
                                    color: Colors.transparent,
                                    child: FullScreenDocViewer(
                                      title: '${doc.value.documentname ?? ''}',
                                      subTitle: (doc.value.uuid == null)
                                          ? '(error)'
                                          : '(${doc.value.uuid})',
                                      future: future,
                                      fileTypeHint: first.fileType ?? '',
                                      watermark: _watermark(),
                                      appBarColor: AppBarColors.hexColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
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

  Widget Doc_Data_2(BuildContext context) {
    // 1) เตรียมข้อมูลแบบ local ไม่ setState ตรงนี้
    final hasContract = contractsCidModels.isNotEmpty;
    final List<ContractAttachments> docs = hasContract
        ? (contractsCidModels.first.contractAttachments?.toList() ?? [])
        : [];

    final List<ReceiptDocuments> receiptDocs = hasContract
        ? (contractsCidModels.first.receiptDocuments?.toList() ?? [])
        : [];

    // สำหรับหัวข้อคอลัมน์ (สมมติว่ามีตัวแปรนี้อยู่แล้ว)
    final List<dynamic> titlesDoc = data_title_doc; // ชื่อคอลัมน์เอกสารแนบ
    final List<dynamic> titlesReceipt =
        data_title_receipt; // ชื่อคอลัมน์ใบเสร็จ

    // สำหรับหัวข้อ “รายการชำระ (x เอกสาร)”
    final receiptHasAttachment =
        receiptDocs.isNotEmpty && receiptDocs.first.attachment != null;
    final receiptCountText = 'รายการชำระ';

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ===== เอกสารแนบ =====
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    children: [
                      AutoSizeText(
                        'เอกสารแนบ',
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                      Container(
                        color: Colors.brown[200],
                        child: Row(
                          children: [
                            for (var titleDoc in titlesDoc)
                              Expanded(
                                flex: titleDoc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  child: AutoSizeText(
                                    '${titleDoc["title"]}',
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    textAlign: titleDoc["title"] == 'สถานะ' ||
                                            titleDoc["title"] == 'ไฟล์เอกสาร'
                                        ? TextAlign.center
                                        : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (!hasContract)
                  SizedBox(height: 100, child: Widget_Loading(context))
                else if (docs.isEmpty)
                  const SizedBox(
                    height: 100,
                    child: Center(child: Text('ไม่พบเอกสารแนบ')),
                  )
                else
                  Column(
                    children: docs.asMap().entries.map((row) {
                      final i = row.key; // index ของแถว (0-based)
                      final doc = row.value; // ข้อมูล doc ของแถวนั้น

                      return Row(
                        children:
                            data_title_doc.asMap().entries.map<Widget>((col) {
                          final titleDoc = col.value;
                          final title = (titleDoc["title"] ?? '').toString();
                          final isNameCol = title == 'ชื่อเอกสาร';
                          final isFileCol = title == 'ไฟล์เอกสาร';
                          final flex = isNameCol ? 2 : 1;

                          if (isFileCol) {
                            final hasFile =
                                doc.attachment?.fileName?.isNotEmpty ?? false;
                            return Expanded(
                              flex: flex,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasFile
                                        ? Colors.lime.shade800
                                        : Colors.black,
                                  ),
                                  onPressed: hasFile
                                      ? () async {
                                          final att = doc.attachment!;
                                          final doccu = doc.document;
                                          final resultx = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewPdf_ordit_CMM(
                                                id: att.id?.toString(),
                                                uuid: att.uuid?.toString(),
                                                Request_Uuid:
                                                    att.requestUuid?.toString(),
                                                code: att.clientDocumentId
                                                    ?.toString(),
                                                file_path:
                                                    att.filePath?.toString(),
                                                file_type:
                                                    att.fileType?.toString(),
                                                title: doccu?.nameTh ?? '',
                                                file_typeOpen: 'pending',
                                                uploaded_At:
                                                    att.uploadedAt?.toString(),
                                                statusReviewer:
                                                    att.status?.toString(),
                                                data_title_doc: titlesDoc,
                                                docs: docs,
                                                payment: [],
                                                viewver: true,
                                              ),
                                            ),
                                          );
                                          if (resultx is Map &&
                                              resultx['message'] != null) {
                                            // TODO: refresh ถ้าต้องการ
                                          }
                                        }
                                      : null,
                                  child: const Text(
                                    'เรียกดู',
                                    style: TextStyle(
                                      color: CustomerScreen_Color.Colors_Text3_,
                                      fontSize: 12,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final rawText = getDisplayText(doc, titleDoc);
                            final displayText =
                                isNameCol ? '${i + 1}. $rawText' : rawText;

                            return Expanded(
                              flex: flex,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  displayText,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: isNameCol
                                      ? TextAlign.left
                                      : TextAlign.center,
                                  style: const TextStyle(
                                    color: CustomerScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      );
                    }).toList(),
                  )
                // Column(
                //   children: docs.map((doc) {
                //     return Row(
                //       children: titlesDoc.map<Widget>((titleDoc) {
                //         if (titleDoc["title"] == 'ไฟล์เอกสาร') {
                //           final hasFile =
                //               doc.attachment?.fileName?.isNotEmpty ?? false;
                //           return Expanded(
                //             flex: titleDoc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                //             child: Padding(
                //               padding: const EdgeInsets.all(2.0),
                //               child: ElevatedButton(
                //                 style: ElevatedButton.styleFrom(
                //                   backgroundColor: hasFile
                //                       ? Colors.lime.shade800
                //                       : Colors.black,
                //                 ),
                //                 onPressed: hasFile
                //                     ? () async {
                //                         final att = doc.attachment!;
                //                         final doccu = doc.document;
                //                         final resultx = await Navigator.push(
                //                           context,
                //                           MaterialPageRoute(
                //                             builder: (context) =>
                //                                 PreviewPdf_ordit_CMM(
                //                               id: att.id?.toString(),
                //                               uuid: att.uuid?.toString(),
                //                               Request_Uuid:
                //                                   att.requestUuid?.toString(),
                //                               code: att.clientDocumentId
                //                                   ?.toString(),
                //                               file_path:
                //                                   att.filePath?.toString(),
                //                               file_type:
                //                                   att.fileType?.toString(),
                //                               title: doccu?.nameTh ?? '',
                //                               file_typeOpen: 'pending',
                //                               uploaded_At:
                //                                   att.uploadedAt?.toString(),
                //                               statusReviewer:
                //                                   att.status?.toString(),
                //                               data_title_doc: titlesDoc,
                //                               docs: docs,
                //                               payment: [],
                //                               viewver: true,
                //                             ),
                //                           ),
                //                         );
                //                         if (resultx is Map &&
                //                             resultx['message'] != null) {
                //                           // TODO: refresh ถ้าต้องการ
                //                         }
                //                       }
                //                     : null,
                //                 child: Text(
                //                   'เรียกดู',
                //                   style: TextStyle(
                //                     color: CustomerScreen_Color.Colors_Text3_,
                //                     fontSize: 12,
                //                     fontFamily: Font_.Fonts_T,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           );
                //         } else {
                //           return Expanded(
                //             flex: titleDoc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                //             child: Padding(
                //               padding: const EdgeInsets.all(2.0),
                //               child: Text(
                //                 getDisplayText(doc, titleDoc),
                //                 overflow: TextOverflow.ellipsis,
                //                 textAlign: titleDoc["title"] == 'สถานะ'
                //                     ? TextAlign.center
                //                     : TextAlign.left,
                //                 style: TextStyle(
                //                   color: CustomerScreen_Color.Colors_Text2_,
                //                   fontFamily: Font_.Fonts_T,
                //                 ),
                //               ),
                //             ),
                //           );
                //         }
                //       }).toList(),
                //     );
                //   }).toList(),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===== รายการชำระ =====
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                    children: [
                      AutoSizeText(
                        receiptCountText,
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                      Container(
                        color: Colors.brown[200],
                        child: Row(
                          children: [
                            for (var titleReceipt in titlesReceipt)
                              Expanded(
                                flex: '${titleReceipt["title"]}' ==
                                        'เลขที่ใบเสร็จ'
                                    ? 2
                                    : 1,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  child: AutoSizeText(
                                    '${titleReceipt["title"]}',
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    textAlign:
                                        titleReceipt["title"] == 'สถานะ' ||
                                                titleReceipt["title"] ==
                                                    'ไฟล์เอกสาร'
                                            ? TextAlign.center
                                            : TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (receiptDocs.isEmpty || receiptDocs.first.attachment == null)
                  const SizedBox(
                    height: 80,
                    child: Center(
                      child: Text(
                        'ไม่พบข้อมูล',
                        style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: receiptDocs.map((doc) {
                      final hasFile =
                          doc.attachment?.fileName?.isNotEmpty ?? false;
                      return Row(
                        children: titlesReceipt.map<Widget>((titleReceipt) {
                          if (titleReceipt["title"] == 'ไฟล์เอกสาร') {
                            return Expanded(
                              flex:
                                  '${titleReceipt["title"]}' == 'เลขที่ใบเสร็จ'
                                      ? 2
                                      : 1,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasFile
                                        ? Colors.lime.shade800
                                        : Colors.blue.shade800,
                                  ),
                                  onPressed: () async {
                                    final attachment = doc.attachment;
                                    final attUuid = attachment?.uuid;
                                    // final doccu = doc.document; // ถ้าต้องใช้

                                    final resultx = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PreviewPdfgencreceiptView_CMM(
                                          title: 'แบบฟอร์มรายการชำระ',
                                          reviewDetail: [],
                                          uuid: attUuid,
                                        ),
                                      ),
                                    );

                                    if (resultx is Map &&
                                        resultx['message'] != null) {
                                      // TODO: refresh ถ้าต้องการ
                                    }
                                  },
                                  child: Text(
                                    hasFile ? 'เรียกดู' : 'สร้างเอกสาร',
                                    textAlign: titleReceipt["title"] == 'สถานะ'
                                        ? TextAlign.center
                                        : TextAlign.left,
                                    style: TextStyle(
                                      color: CustomerScreen_Color.Colors_Text3_,
                                      fontSize: 12,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Expanded(
                              flex:
                                  '${titleReceipt["title"]}' == 'เลขที่ใบเสร็จ'
                                      ? 2
                                      : 1,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  getDisplayTextReceipt(doc, titleReceipt),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: titleReceipt["title"] == 'สถานะ'
                                      ? TextAlign.center
                                      : TextAlign.left,
                                  style: TextStyle(
                                    color: CustomerScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      );
                    }).toList(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info, size: 18),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // List<ContractAttachments> docs = [];
  // List<ReceiptDocuments> receipt_docs = [];
  // Doc_Data_2(context) {
  //   setState(() {
  //     docs = contractsCidModels.first.contractAttachments!.toList();
  //     receipt_docs = contractsCidModels.first.receiptDocuments!.toList();
  //   });

  //   return SizedBox(
  //       child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
  //     SizedBox(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Container(
  //             decoration: BoxDecoration(
  //               color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(10),
  //                   topRight: Radius.circular(15),
  //                   bottomLeft: Radius.circular(0),
  //                   bottomRight: Radius.circular(0)),
  //               // border: Border.all(color: Colors.grey, width: 1),
  //             ),
  //             padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //             // padding:
  //             //     const EdgeInsets.symmetric(
  //             //         vertical: 5,
  //             //         horizontal: 16),
  //             child: Column(
  //               children: [
  //                 AutoSizeText(
  //                   minFontSize: 12,
  //                   maxFontSize: 16,
  //                   maxLines: 1,
  //                   'เอกสารแนบ (${docs.length} เอกสาร)',
  //                   // 'เอกสารแนบ (${data_doc.length} เอกสาร)',
  //                   textAlign: TextAlign.center,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                       color: PeopleChaoScreen_Color.Colors_Text2_,
  //                       fontFamily: Font_.Fonts_T),
  //                 ),
  //                 Container(
  //                   color: Colors.brown[200],
  //                   child: Row(children: [
  //                     for (var title_doc in data_title_doc)
  //                       Expanded(
  //                         flex: title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
  //                         child: Container(
  //                           padding: const EdgeInsets.all(2.0),
  //                           child: AutoSizeText(
  //                             minFontSize: 12,
  //                             maxFontSize: 16,
  //                             maxLines: 1,
  //                             '${title_doc["title"]}',
  //                             textAlign: TextAlign.left,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                                 color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                 fontFamily: Font_.Fonts_T),
  //                           ),
  //                         ),
  //                       ),
  //                   ]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Divider(),

  //           if (docs.isEmpty)
  //             SizedBox(height: 100, child: Widget_Loading(context))
  //           else
  //             Column(
  //               children: docs.map((doc) {
  //                 return Row(
  //                   children: data_title_doc.map<Widget>((title_doc) {
  //                     if (title_doc["title"] == 'ไฟล์เอกสาร') {
  //                       final hasFile =
  //                           doc.attachment?.fileName?.isNotEmpty ?? false;

  //                       return Expanded(
  //                         flex: title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(2.0),
  //                           child: ElevatedButton(
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: hasFile
  //                                   ? Colors.lime.shade800
  //                                   : Colors.black,
  //                             ),
  //                             onPressed: hasFile
  //                                 ? () async {
  //                                     final att = doc.attachment!;
  //                                     final doccu = doc.document!;
  //                                     final resultx = await Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (context) =>
  //                                             PreviewPdf_ordit_CMM(
  //                                           id: att.id.toString(),
  //                                           uuid: att.uuid.toString(),
  //                                           Request_Uuid:
  //                                               att.requestUuid.toString(),
  //                                           code:
  //                                               att.clientDocumentId.toString(),
  //                                           file_path: att.filePath.toString(),
  //                                           file_type: att.fileType.toString(),
  //                                           title: doccu.nameTh ?? '',
  //                                           file_typeOpen: 'pending',
  //                                           uploaded_At:
  //                                               att.uploadedAt.toString(),
  //                                           statusReviewer:
  //                                               att.status.toString(),
  //                                           data_title_doc: data_title_doc,
  //                                           docs: docs,
  //                                         ),
  //                                       ),
  //                                     );

  //                                     if (resultx['message'] != null) {

  //                                     }
  //                                   }
  //                                 : null,
  //                             child: Text(
  //                               'เรียกดู',
  //                               style: TextStyle(
  //                                 color: CustomerScreen_Color.Colors_Text3_,
  //                                 fontSize: 12,
  //                                 fontFamily: Font_.Fonts_T,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     } else {
  //                       return Expanded(
  //                         flex: title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(2.0),
  //                           child: Text(
  //                             getDisplayText(doc, title_doc),
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                               color: CustomerScreen_Color.Colors_Text2_,
  //                               fontFamily: Font_.Fonts_T,
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     }
  //                   }).toList(),
  //                 );
  //               }).toList(),
  //             ),

  //         ],
  //       ),
  //     ),
  //     SizedBox(
  //       height: 20,
  //     ),
  //     SizedBox(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Container(
  //             decoration: BoxDecoration(
  //               color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(10),
  //                   topRight: Radius.circular(15),
  //                   bottomLeft: Radius.circular(0),
  //                   bottomRight: Radius.circular(0)),
  //               // border: Border.all(color: Colors.grey, width: 1),
  //             ),
  //             padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //             // padding:
  //             //     const EdgeInsets.symmetric(
  //             //         vertical: 5,
  //             //         horizontal: 16),
  //             child: Column(
  //               children: [
  //                 AutoSizeText(
  //                   minFontSize: 12,
  //                   maxFontSize: 16,
  //                   maxLines: 1,
  //                   (receipt_docs.first.attachment == null)
  //                       ? 'รายการชำระ( 0 เอกสาร)'
  //                       : 'รายการชำระ( 1 เอกสาร)',
  //                   textAlign: TextAlign.center,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                       color: PeopleChaoScreen_Color.Colors_Text2_,
  //                       fontFamily: Font_.Fonts_T),
  //                 ),

  //                 Container(
  //                   color: Colors.brown[200],
  //                   child: Row(children: [
  //                     for (var title_receipt in data_title_receipt)
  //                       Expanded(
  //                         flex: '${title_receipt["title"]}' == 'เลขที่ใบเสร็จ'
  //                             ? 2
  //                             : 1,
  //                         child: Container(
  //                           padding: const EdgeInsets.all(2.0),
  //                           child: AutoSizeText(
  //                             minFontSize: 12,
  //                             maxFontSize: 16,
  //                             maxLines: 1,
  //                             '${title_receipt["title"]}',
  //                             textAlign: TextAlign.left,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                                 color: PeopleChaoScreen_Color.Colors_Text2_,
  //                                 fontFamily: Font_.Fonts_T),
  //                           ),
  //                         ),
  //                       ),
  //                   ]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           (receipt_docs.first.attachment == null)
  //               ? const Center(
  //                   child: Text(
  //                     'ไม่พบข้อมูล',
  //                     style: TextStyle(
  //                       color: PeopleChaoScreen_Color.Colors_Text2_,
  //                       fontFamily: Font_.Fonts_T,
  //                     ),
  //                   ),
  //                 )
  //               : SizedBox(
  //                   child: Column(
  //                     children: receipt_docs.map((doc) {
  //                       return Row(
  //                         children:
  //                             data_title_receipt.map<Widget>((title_receipt) {
  //                           final hasFile =
  //                               doc.attachment?.fileName?.isNotEmpty ?? false;
  //                           if (title_receipt["title"] == 'ไฟล์เอกสาร') {
  //                             return Expanded(
  //                               flex: title_receipt["title"] == 'เลขที่ใบเสร็จ'
  //                                   ? 2
  //                                   : 1,
  //                               child: Padding(
  //                                 padding: const EdgeInsets.all(2.0),
  //                                 child: ElevatedButton(
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: hasFile
  //                                         ? Colors.lime.shade800
  //                                         : Colors.blue.shade800,
  //                                   ),
  //                                   onPressed: () async {
  //                                     final attachment =
  //                                         receipt_docs.first.attachment;

  //                                     final attUuid = attachment?.uuid ?? null;
  //                                     final doccu = receipt_docs.first.document;
  //                                     final resultx = await Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               PreviewPdfgencreceiptView_CMM(
  //                                                   // doc: 'pdf',
  //                                                   title: 'แบบฟอร์มรายการชำระ',
  //                                                   // docs: docs,
  //                                                   // zn: _controllers_shop_sub[
  //                                                   //         1]
  //                                                   //     .text,
  //                                                   // ln: _controllers_shop_sub[
  //                                                   //         2]
  //                                                   //     .text,
  //                                                   reviewDetail: [],
  //                                                   //         .receiptDocuments,
  //                                                   // code: doccu
  //                                                   //     .code,
  //                                                   // id: doccu
  //                                                   //     .id,
  //                                                   uuid: attUuid),
  //                                         ));

  //                                     // ตรวจสอบค่าที่กลับมา
  //                                     if (resultx['message'] != null) {
  //                                       //print(
  //                                           'ตรวจสอบค่าที่กลับมา ${resultx['message']}');
  //                                       // Loading_Data_config();
  //                                       // loadClientReviewsUuid();
  //                                     }
  //                                   },
  //                                   child: Text(
  //                                     hasFile ? 'เรียกดู' : 'สร้างเอกสาร',
  //                                     style: TextStyle(
  //                                       color:
  //                                           CustomerScreen_Color.Colors_Text3_,
  //                                       fontSize: 12,
  //                                       fontFamily: Font_.Fonts_T,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             );
  //                           } else {
  //                             return Expanded(
  //                               flex: title_receipt["title"] == 'เลขที่ใบเสร็จ'
  //                                   ? 2
  //                                   : 1,
  //                               child: Padding(
  //                                 padding: const EdgeInsets.all(2.0),
  //                                 child: Text(
  //                                   getDisplayTextReceipt(
  //                                       receipt_docs.first, title_receipt),
  //                                   overflow: TextOverflow.ellipsis,
  //                                   style: TextStyle(
  //                                     color: CustomerScreen_Color.Colors_Text2_,
  //                                     fontFamily: Font_.Fonts_T,
  //                                   ),
  //                                 ),
  //                               ),
  //                             );
  //                           }
  //                         }).toList(),
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ),

  //           Padding(
  //             padding: const EdgeInsets.all(0.0),
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Icon(
  //                     Icons.info,
  //                     size: 18,
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: AutoSizeText(
  //                     minFontSize: 12,
  //                     maxFontSize: 16,
  //                     maxLines: 1,
  //                     'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
  //                     textAlign: TextAlign.left,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(
  //                         color: PeopleChaoScreen_Color.Colors_Text2_,
  //                         fontFamily: Font_.Fonts_T),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     SizedBox(
  //       height: 20,
  //     ),
  //   ]));
  // }
  String? getRequestUuidSafe({
    required List<ContractDocuments>? contractDocs,
  }) {
    // 1) มีเอกสารไหม
    if (contractDocs == null || contractDocs.isEmpty) return null;

    // 2) หาตัวแรกที่มีค่า requestUuid
    final withReq = contractDocs.firstWhere(
      (e) => (e.requestUuid != null && e.requestUuid!.isNotEmpty),
      orElse: () => contractDocs.first, // มีแน่เพราะเช็ค isEmpty ไปแล้ว
    );
    if (withReq.requestUuid != null && withReq.requestUuid!.isNotEmpty) {
      return withReq.requestUuid;
    }

    // 3) ถ้ายังไม่มี ลองหาจาก attachments (บาง API ใส่ไว้ใน attachment)
    for (final doc in contractDocs) {
      final atts = doc.attachments ?? const [];
      for (final a in atts) {
        if (a.requestUuid != null && a.requestUuid!.isNotEmpty) {
          return a.requestUuid;
        }
      }
    }

    // 4) หาไม่เจอจริง ๆ
    return null;
  }

  Widget Doc_Data_3(BuildContext context) {
    // -------- เตรียมข้อมูลแบบ local (ไม่ setState ตรงนี้) --------
    final bool hasContract = contractsCidModels.isNotEmpty;

    final List<ContractAttachments> docs =
        hasContract ? (contractsCidModels.first.contractAttachments ?? []) : [];

    final List<ReceiptDocuments> receiptDocs =
        hasContract ? (contractsCidModels.first.receiptDocuments ?? []) : [];

    final List<CheckupDocuments> checkupDocs =
        hasContract ? (contractsCidModels.first.checkupDocuments ?? []) : [];

    final List<ApproveDocuments> approveDocs =
        hasContract ? (contractsCidModels.first.approveDocuments ?? []) : [];

    final List<ContractDocuments> contractDocs =
        hasContract ? (contractsCidModels.first.contractDocuments ?? []) : [];

    // requestUuidDocs ใช้กับ API ของรูป/ไฟล์ตรวจสอบข้อเท็จจริง
    // final String? requestUuidDocs =
    //     contractDocs.isNotEmpty ? contractDocs.first.requestUuid : null;
    // final String? requestUuidDocs = docs.first.attachment!.requestUuid;
    final String? requestUuidDocs =
        docs.isNotEmpty ? docs.first.attachment?.requestUuid : null;

// เวลาใช้ใน UI ต้องเผื่อ null
    if (requestUuidDocs == null) {
      // แสดงข้อความ/ซ่อนปุ่ม/รอโหลด ฯลฯ
    } else {
      // ใช้งาน requestUuidDocs ได้
    }

    // //print('uuid: ${contractDocs.first.uuid}');
    // //print('requestUuid: ${contractDocs.first.requestUuid}');
    // หัวข้อคอลัมน์ (ถือว่ามีตัวแปรพวกนี้ใน scope แล้ว)
    final List<dynamic> titlesDoc = data_title_doc;
    final List<dynamic> titlesReceipt = data_title_receipt;

    // สำหรับหัวข้อ “รายการชำระ (x เอกสาร)”
    final bool receiptHasAttachment =
        receiptDocs.isNotEmpty && (receiptDocs.first.attachment != null);
    final String receiptCountText = 'รายการชำระ';

    // Helper: thumbnail สำหรับ PDF (หลีกเลี่ยงการโหลด SfPdfViewer ในกรอบเล็ก)
    Widget _pdfThumbPlaceholder() {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.picture_as_pdf, size: 30),
      );
    }

    // Helper: overlay ลายน้ำ (สมมุติว่ามีฟังก์ชันนี้อยู่แล้วในไฟล์เดียวกัน)
    Widget _watermark() => IgnorePointer(child: _buildWatermarkOverlay());

    // Helper: บล็อก “ไม่พบข้อมูล”
    Widget _noData([String msg = 'ไม่พบข้อมูล']) => SizedBox(
          height: 80,
          child: Center(
            child: Text(
              msg,
              style: const TextStyle(
                color: PeopleChaoScreen_Color.Colors_Text2_,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ),
        );

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ===================== รูปภาพหลักฐานจากผู้เช่า/ผู้ค้า =====================
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: const Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          'รูปภาพหลักฐานจากผู้เช่า/ผู้ค้า',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        StreamBuilder(
                          stream: Stream.periodic(
                              const Duration(milliseconds: 25), (i) => i),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final double elapsed =
                                double.parse(snapshot.data.toString()) * 0.05;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                                style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else if (checkupDocs.isEmpty ||
                    checkupDocs.first.attachment == null)
                  _noData()
                else
                  SizedBox(
                    child: Row(
                      children: [
                        for (final adminCheck in checkupDocs)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ชื่อเอกสาร
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: AutoSizeText(
                                    adminCheck.document?.nameTh ?? "-",
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                                // กรอบภาพ
                                Container(
                                  height: 150,
                                  width: 270,
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Builder(
                                          builder: (context) {
                                            final att = adminCheck.attachment;
                                            final String? uuid = att?.uuid;
                                            final String ft =
                                                (att?.fileType ?? '')
                                                    .toLowerCase();
                                            if (uuid == null) {
                                              return const Center(
                                                  child: Text('ไม่พบไฟล์แนบ',
                                                      style: TextStyle(
                                                          color: Colors.grey)));
                                            }
                                            // แสดง preview
                                            if (ft == 'pdf' ||
                                                ft.contains(
                                                    'application/pdf')) {
                                              return FutureBuilder<
                                                  http.Response?>(
                                                future:
                                                    img_ApprovalsRequests(uuid),
                                                builder: (context, snap) {
                                                  if (snap.connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }
                                                  if (snap.hasData &&
                                                      snap.data?.statusCode ==
                                                          200) {
                                                    // Thumbnail: ใช้ placeholder สำหรับ PDF
                                                    return _pdfThumbPlaceholder();
                                                  }
                                                  return const Icon(
                                                      Icons.broken_image);
                                                },
                                              );
                                            } else {
                                              return Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: FittedBox(
                                                    fit: BoxFit.cover,
                                                    child: FutureBuilder<
                                                        http.Response?>(
                                                      future:
                                                          img_ApprovalsRequests(
                                                              uuid),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const CircularProgressIndicator();
                                                        }
                                                        if (snapshot.hasData &&
                                                            snapshot.data
                                                                    ?.statusCode ==
                                                                200) {
                                                          return Image.memory(
                                                            snapshot.data!
                                                                .bodyBytes,
                                                            fit: BoxFit.contain,
                                                          );
                                                        } else {
                                                          return const Icon(Icons
                                                              .broken_image);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: 130,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.blueGrey
                                                          .withOpacity(0.5)),
                                            ),
                                            onPressed: () async {
                                              final att = adminCheck.attachment;
                                              final String? uuid = att?.uuid;
                                              final String fileType =
                                                  (att?.fileType ?? '')
                                                      .toLowerCase();

                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) {
                                                  // สร้าง future เดียว แล้วส่งซ้ำให้ทั้งตัวเต็มและ thumb ด้านล่าง
                                                  final Future<http.Response?>
                                                      previewFuture =
                                                      img_ApprovalsRequests(
                                                          uuid ?? '');

                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    backgroundColor:
                                                        AppbackgroundColor
                                                            .Sub_Abg_Colors,
                                                    titlePadding:
                                                        const EdgeInsets.all(0),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    actionsPadding:
                                                        const EdgeInsets.all(6),
                                                    title: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            InkWell(
                                                              onTap: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            4.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .highlight_off,
                                                                  size: 30,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Text(
                                                            adminCheck.document
                                                                    ?.nameTh ??
                                                                'ไม่พบชื่อเอกสาร',
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.9,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.55,
                                                      child: FutureBuilder<
                                                          http.Response?>(
                                                        future: previewFuture,
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return const Center(
                                                                child:
                                                                    CircularProgressIndicator());
                                                          }

                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data
                                                                      ?.statusCode ==
                                                                  200) {
                                                            final headers =
                                                                snapshot.data!
                                                                        .headers ??
                                                                    {};
                                                            final ct = (headers[
                                                                        'content-type'] ??
                                                                    headers[
                                                                        'Content-Type'] ??
                                                                    '')
                                                                .toLowerCase();
                                                            final isPdf =
                                                                fileType ==
                                                                        'pdf' ||
                                                                    ct.contains(
                                                                        'application/pdf');

                                                            if (isPdf) {
                                                              return Stack(
                                                                children: [
                                                                  SfPdfViewer
                                                                      .memory(
                                                                    snapshot
                                                                        .data!
                                                                        .bodyBytes,
                                                                    enableDocumentLinkAnnotation:
                                                                        false,
                                                                    canShowScrollHead:
                                                                        false,
                                                                    canShowScrollStatus:
                                                                        false,
                                                                    pageLayoutMode:
                                                                        PdfPageLayoutMode
                                                                            .continuous,
                                                                    enableDoubleTapZooming:
                                                                        false,
                                                                  ),
                                                                  _watermark(),
                                                                ],
                                                              );
                                                            } else {
                                                              return Stack(
                                                                children: [
                                                                  Center(
                                                                    child:
                                                                        InteractiveViewer(
                                                                      child: Image
                                                                          .memory(
                                                                        snapshot
                                                                            .data!
                                                                            .bodyBytes,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  _watermark(),
                                                                ],
                                                              );
                                                            }
                                                          }

                                                          return const Center(
                                                              child: Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  size: 48));
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Translate
                                                  .TranslateAndSet_TextAutoSize(
                                                ((adminCheck.attachment
                                                                ?.fileType
                                                                ?.toLowerCase() ??
                                                            '') ==
                                                        'pdf')
                                                    ? 'Preview PDF'
                                                    : 'Preview Image',
                                                ChaoAreaScreen_Color
                                                    .Colors_Text3_,
                                                TextAlign.center,
                                                null,
                                                FontWeight_.Fonts_T,
                                                10,
                                                12,
                                                1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // วันที่
                                Align(
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    (adminCheck.attachment?.uploadedAt == null)
                                        ? ''
                                        : '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse('${adminCheck.attachment?.uploadedAt!}'))}',
                                    // adminCheck.attachment?.uploadedAt ?? '',
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===================== รูปภาพหลักฐานการตรวจสอบข้อเท็จจริง (History) =====================
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.brown[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: AutoSizeText(
                          'รูปภาพหลักฐานการตรวจสอบข้อเท็จจริง',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: InkWell(
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: const EdgeInsets.all(0),
                                      contentPadding: const EdgeInsets.all(10),
                                      actionsPadding: const EdgeInsets.all(6),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () =>
                                                    Navigator.pop(context),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.highlight_off,
                                                    size: 30,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Text(
                                              'ประวัติการอัปโหลดภาพ',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                (MediaQuery.of(context)
                                                            .size
                                                            .height <
                                                        800
                                                    ? 0.7
                                                    : 0.9),
                                        width: 350,
                                        child: ListView(
                                          children: [
                                            const SizedBox(height: 20),
                                            if (isLoading)
                                              Widget_Loading(context)
                                            else if (approveDocs.isEmpty)
                                              _noData()
                                            else
                                              ...approveDocs.map((type) {
                                                final hasHist = (type
                                                        .approveAttachments
                                                        ?.isNotEmpty ??
                                                    false);
                                                if (!hasHist)
                                                  return const SizedBox
                                                      .shrink();
                                                return Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 4.0),
                                                        child: Text(
                                                          type.nameTh ?? '-',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ...type
                                                          .approveAttachments!
                                                          .map((history) {
                                                        final String? hUuid =
                                                            history.uuid;
                                                        final Future<
                                                                http.Response?>
                                                            previewFuture =
                                                            (requestUuidDocs !=
                                                                        null &&
                                                                    hUuid !=
                                                                        null)
                                                                ? img_ApprovalsCheckUp(
                                                                    requestUuidDocs,
                                                                    hUuid)
                                                                : Future.value(
                                                                    null);

                                                        return ListTile(
                                                          title: Text(
                                                            history.caption ??
                                                                '-',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            (history.createdAt ==
                                                                    null)
                                                                ? ''
                                                                : '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse('${history.createdAt!}'))}',
                                                            // history.createdAt ??
                                                            //     '-',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                          trailing: InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    backgroundColor:
                                                                        AppbackgroundColor
                                                                            .Sub_Abg_Colors,
                                                                    titlePadding:
                                                                        const EdgeInsets
                                                                            .all(0),
                                                                    contentPadding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    actionsPadding:
                                                                        const EdgeInsets
                                                                            .all(6),
                                                                    title: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        InkWell(
                                                                          onTap: () =>
                                                                              Navigator.pop(context),
                                                                          child:
                                                                              const Padding(
                                                                            padding:
                                                                                EdgeInsets.all(4),
                                                                            child:
                                                                                Icon(
                                                                              Icons.highlight_off,
                                                                              size: 30,
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    content:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      child:
                                                                          SizedBox(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.9,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.55,
                                                                        child: FutureBuilder<
                                                                            http.Response?>(
                                                                          future:
                                                                              previewFuture,
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            if (snapshot.connectionState ==
                                                                                ConnectionState.waiting) {
                                                                              return const Center(child: CircularProgressIndicator());
                                                                            }
                                                                            if (snapshot.hasData &&
                                                                                snapshot.data?.statusCode == 200) {
                                                                              final ct = (snapshot.data!.headers['content-type'] ?? '').toLowerCase();
                                                                              final bytes = snapshot.data!.bodyBytes;
                                                                              if (ct.contains('pdf')) {
                                                                                return SfPdfViewer.memory(bytes);
                                                                              } else {
                                                                                return InteractiveViewer(
                                                                                  child: Image.memory(
                                                                                    bytes,
                                                                                    fit: BoxFit.contain,
                                                                                  ),
                                                                                );
                                                                              }
                                                                            }
                                                                            return const Icon(Icons.broken_image,
                                                                                size: 48);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: SizedBox(
                                                              height: 120,
                                                              width: 120,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: FutureBuilder<
                                                                    http.Response?>(
                                                                  future:
                                                                      previewFuture,
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return const Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    }
                                                                    if (snapshot
                                                                            .hasData &&
                                                                        snapshot.data?.statusCode ==
                                                                            200) {
                                                                      final ct =
                                                                          (snapshot.data!.headers['content-type'] ?? '')
                                                                              .toLowerCase();
                                                                      final bytes = snapshot
                                                                          .data!
                                                                          .bodyBytes;

                                                                      // Thumbnail: PDF ใช้ placeholder
                                                                      if (ct.contains(
                                                                          'pdf')) {
                                                                        return _pdfThumbPlaceholder();
                                                                      } else {
                                                                        return Image
                                                                            .memory(
                                                                          bytes,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        );
                                                                      }
                                                                    }
                                                                    return const Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        size:
                                                                            48);
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                );
                                              }),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.history),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (isLoading)
                  Widget_Loading(context)
                else if (approveDocs.isEmpty)
                  _noData()
                else
                  SizedBox(
                    child: Row(
                      children: [
                        for (final adminImg in approveDocs)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ชื่อเอกสาร
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: AutoSizeText(
                                    // '$requestUuidDocs',
                                    adminImg.nameTh ?? "-",
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                                // กรอบภาพ
                                Container(
                                  height: 150,
                                  width: 270,
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Builder(
                                            builder: (context) {
                                              final att =
                                                  adminImg.approveAttachment;
                                              final String? uuid = att?.uuid;
                                              final String ft =
                                                  (att?.fileType ?? '')
                                                      .toLowerCase();

                                              if (uuid == null ||
                                                  requestUuidDocs == null) {
                                                return const Center(
                                                  child: Text(
                                                    'ไม่พบไฟล์แนบ',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                );
                                              }

                                              if (ft == 'pdf' ||
                                                  ft.contains(
                                                      'application/pdf')) {
                                                // Thumbnail PDF => placeholder
                                                return FutureBuilder<
                                                    http.Response?>(
                                                  future: img_ApprovalsCheckUp(
                                                      requestUuidDocs, uuid),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    }
                                                    if (snapshot.hasData &&
                                                        snapshot.data
                                                                ?.statusCode ==
                                                            200) {
                                                      return _pdfThumbPlaceholder();
                                                    }
                                                    return const Icon(
                                                        Icons.broken_image);
                                                  },
                                                );
                                              } else {
                                                return FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: FutureBuilder<
                                                      http.Response?>(
                                                    future:
                                                        img_ApprovalsCheckUp(
                                                            requestUuidDocs,
                                                            uuid),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const SizedBox(
                                                          width: 100,
                                                          height: 100,
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      }
                                                      if (snapshot.hasData &&
                                                          snapshot.data
                                                                  ?.statusCode ==
                                                              200) {
                                                        return Image.memory(
                                                          snapshot
                                                              .data!.bodyBytes,
                                                          fit: BoxFit.contain,
                                                        );
                                                      } else {
                                                        return const Icon(
                                                            Icons.broken_image);
                                                      }
                                                    },
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 130,
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.blueGrey
                                                              .withOpacity(
                                                                  0.5)),
                                                ),
                                                onPressed: () async {
                                                  final att = adminImg
                                                      .approveAttachment;
                                                  final String? uuid =
                                                      att?.uuid;
                                                  final String fileType =
                                                      (att?.fileType ?? '')
                                                          .toLowerCase();

                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      final Future<
                                                              http.Response?>?
                                                          future =
                                                          (requestUuidDocs !=
                                                                      null &&
                                                                  uuid != null)
                                                              ? img_ApprovalsCheckUp(
                                                                  requestUuidDocs!,
                                                                  uuid)
                                                              : null;

                                                      final size =
                                                          MediaQuery.of(context)
                                                              .size;

                                                      return AlertDialog(
                                                        // กัน padding ที่ทำให้ layout แปลก ๆ
                                                        // contentPadding:
                                                        //     EdgeInsets.zero,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        backgroundColor:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        title: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            4.0),
                                                                    child: Icon(
                                                                      Icons
                                                                          .highlight_off,
                                                                      size: 30,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                adminImg.nameTh ??
                                                                    'ไม่พบชื่อเอกสาร',
                                                                maxLines: 2,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        content: SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.9,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.55,
                                                          //  ConstrainedBox(
                                                          //   // ✅ บังคับให้ content มี “ขนาดจริง” (กันศูนย์) และไม่เกินจอ
                                                          //   constraints:
                                                          //       BoxConstraints(
                                                          //     minWidth: 320,
                                                          //     minHeight: 240,
                                                          //     maxWidth: (size
                                                          //                 .width *
                                                          //             0.55)
                                                          //         .clamp(
                                                          //             320, 1200),
                                                          //     maxHeight:
                                                          //         (size.height *
                                                          //                 0.90)
                                                          //             .clamp(240,
                                                          //                 1000),
                                                          //   ),
                                                          child: Stack(
                                                            children: [
                                                              // ✅ เนื้อหาหลักให้ “กินพื้นที่ทั้งหมด” เสมอ
                                                              Positioned.fill(
                                                                child: (future ==
                                                                        null)
                                                                    ? const Center(
                                                                        child: Text(
                                                                            'ไม่พบไฟล์แนบ'))
                                                                    : FutureBuilder<
                                                                        http.Response?>(
                                                                        future:
                                                                            future,
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          if (snapshot.connectionState ==
                                                                              ConnectionState.waiting) {
                                                                            return const Center(child: CircularProgressIndicator());
                                                                          }
                                                                          if (snapshot.hasData &&
                                                                              snapshot.data?.statusCode == 200) {
                                                                            final res =
                                                                                snapshot.data!;
                                                                            final headers =
                                                                                res.headers;
                                                                            final ct =
                                                                                (headers['content-type'] ?? headers['Content-Type'] ?? '').toLowerCase();
                                                                            final isPdf =
                                                                                fileType.contains('pdf') || ct.contains('application/pdf');

                                                                            return isPdf
                                                                                ? SfPdfViewer.memory(res.bodyBytes)
                                                                                : InteractiveViewer(
                                                                                    // 👈 ซูม/แพนได้ และรักษา hit test
                                                                                    child: Image.memory(
                                                                                      res.bodyBytes,
                                                                                      fit: BoxFit.contain,
                                                                                    ),
                                                                                  );
                                                                          }
                                                                          return const Center(
                                                                            child:
                                                                                Icon(Icons.broken_image, size: 48),
                                                                          );
                                                                        },
                                                                      ),
                                                              ),

                                                              // ✅ watermark ให้มีขนาดด้วย Positioned.fill และไม่กิน pointer
                                                              Positioned.fill(
                                                                child: IgnorePointer(
                                                                    child:
                                                                        _watermark()),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Translate
                                                      .TranslateAndSet_TextAutoSize(
                                                    ((adminImg.approveAttachment
                                                                    ?.fileType
                                                                    ?.toLowerCase() ??
                                                                '') ==
                                                            'pdf')
                                                        ? 'Preview PDF'
                                                        : 'Preview Image',
                                                    ChaoAreaScreen_Color
                                                        .Colors_Text3_,
                                                    TextAlign.center,
                                                    null,
                                                    FontWeight_.Fonts_T,
                                                    10,
                                                    12,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // วันที่
                                Align(
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    (adminImg.approveAttachment?.createdAt ==
                                            null)
                                        ? ''
                                        : '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse('${adminImg.approveAttachment?.createdAt!}'))}',
                                    // adminImg.approveAttachment?.createdAt ?? '',
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
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

                // Info
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info, size: 18),
                      ),
                      Expanded(
                        child: AutoSizeText(
                          'โปรดแนบรูปเอกสารหลักฐานการตรวจสอบข้อเท็จจริงก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
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

          const SizedBox(height: 20),
        ],
      ),
    );
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
  int renTal_lavel = 0, ser_tabbarview_2 = 0, Ser_Tap = 0;
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
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blue.shade600),
            ),
            onPressed: () async {
              setState(() {
                if (ser_tabbarview_2 == 2) {
                  ser_tabbarview_2 = 0;
                } else {
                  ser_tabbarview_2 = 2;
                }
              });

              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              String? ren = preferences.getString('renTalSer');
              String? ser_user = preferences.getString('ser');
              var name = preferences.getString('fname');
              Insert_log.Insert_logs('สัญญาเช่า',
                  '$name>สัญญา${widget.Get_Value_cid}>เพิ่มค่าบริการ');
              String url2 =
                  '${MyConstant().domain}/D_quotx.php?isAdd=true&ren=$ren&ser_user=$ser_user';

              try {
                var response2 = await http.get(Uri.parse(url2));

                var result2 = json.decode(response2.body);
                //print(result2);
                if (result2.toString() == 'true') {}
              } catch (e) {}
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Translate.TranslateAndSet_TextAutoSize(
                  ser_tabbarview_2 == 2
                      ? 'ยกเลิกเพิ่มค่าบริการ'
                      : 'เพิ่มค่าบริการ',
                  ChaoAreaScreen_Color.Colors_Text2_,
                  TextAlign.center,
                  null,
                  FontWeight_.Fonts_T,
                  12,
                  14,
                  1),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.orange.shade900),
            ),
            onPressed: () async {
              setState(() {
                if (ser_tabbarview_2 == 1) {
                  ser_tabbarview_2 = 0;
                } else {
                  ser_tabbarview_2 = 1;
                }
              });

              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              var name = preferences.getString('fname');
              Insert_log.Insert_logs('สัญญาเช่า',
                  '$name>สัญญา${widget.Get_Value_cid}>ปรับตั้งหนี้');
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Translate.TranslateAndSet_TextAutoSize(
                  ser_tabbarview_2 == 1 ? 'ยกเลิกปรับตั้งหนี้' : 'ปรับตั้งหนี้',
                  ChaoAreaScreen_Color.Colors_Text2_,
                  TextAlign.center,
                  null,
                  FontWeight_.Fonts_T,
                  12,
                  14,
                  1),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
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

  Widget _buildWatermarkOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        List<Widget> watermarks = [];

        for (double y = 0; y < height; y += 200) {
          for (double x = 0; x < width; x += 300) {
            watermarks.add(Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: -0.4,
                child: Opacity(
                  opacity: 0.08,
                  child: Text(
                    'Chaoperty',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ));
          }
        }

        return Stack(children: watermarks);
      },
    );
  }
}
