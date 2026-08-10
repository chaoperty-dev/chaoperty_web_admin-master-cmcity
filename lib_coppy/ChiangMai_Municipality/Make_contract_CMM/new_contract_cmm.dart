import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:html' as html;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/Model/Get_easyslip_Model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons_ns/grouped_buttons_ns.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../List_CMM/Register_CMM/AuthService.dart';
import '../../AdminScaffold/AdminScaffold.dart';
import '../../Bureau_Registration/Add_Custo_Screen.dart';
import '../../Constant/Myconstant.dart';
import '../../Model/GetArea_Model.dart';
import '../../Model/GetC_Quot_Model.dart';
import '../../Model/GetC_Quot_Select_Model.dart';
import '../../Model/GetCustomer_Model.dart';
import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetTeNant_Model.dart';
import '../../Model/GetZone_Model.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';

import '../Model/AnnouncementZone_Model.dart';
import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/Dataconfig_Model.dart';
import '../Model/Document_Model.dart';
import '../Model/Person&Shop_Model.dart';
import '../PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import '../cignaturepad_cmm.dart';
import '../unity/API_Deletelfile.dart';
import '../unity/API_addfile.dart';
import '../unity/API_admin_reject.dart';
import '../unity/API_admin_requests.dart';
import '../unity/API_admin_signature.dart';
import '../unity/API_announcement.dart';
import '../unity/API_expauto.dart';
import '../unity/API_payment.dart';
import '../unity/API_requests_reviewsflow.dart';
import '../unity/API-Admin-Request-Snapshots/API-List-Snapshots.dart';
import '../unity/API-Admin-Request-Snapshots/API-Snapshot-Attachments.dart';
import '../unity/API-Admin-Request-Snapshots/Models/snapshot_list_model.dart'
    hide ClientModel;
import '../unity/API-Admin-Request-Snapshots/Models/snapshot_attachment_model.dart';
import '../unity/API_request_properties.dart';
import 'snapshot_file_picker_dialog.dart';
import '../unity/Enum.dart';
import '../unity/FormatDate.dart';
import '../unity/ReusableSignaturePad.dart';
import '../unity/SecurePrefs_helper.dart';
import '../unity/show_dialog_cmm.dart';
import 'payment_contract_cmm.dart';
import 'quotxSelect_cmm.dart';
import 'dart:math' as math;

class Newcontract_cmm extends StatefulWidget {
  final Get_Value_area_index;
  final Get_Value_area_ln;
  final Get_Value_area_sum;
  final Get_Value_rent_sum;
  final Get_Value_page;
  String Get_Value_uuid;
  String Get_Value_step;
  String Get_Value_payment_uuid;
  String Get_Value_payment_amount;
  List<Map<String, dynamic>> paymentjsonx;
  final Get_ReContact;
  List<TeNantModel> Get_TeNantModels;
  String status_uuid;

  Newcontract_cmm(
      {super.key,
      this.Get_Value_area_index,
      this.Get_Value_area_ln,
      this.Get_Value_area_sum,
      this.Get_Value_rent_sum,
      this.Get_Value_page,
      required this.Get_Value_uuid,
      required this.Get_Value_step,
      required this.Get_Value_payment_uuid,
      required this.Get_Value_payment_amount,
      required this.paymentjsonx,
      this.Get_ReContact,
      required this.Get_TeNantModels,
      required this.status_uuid});

  @override
  State<Newcontract_cmm> createState() => _Newcontract_cmmState();
}

class _Newcontract_cmmState extends State<Newcontract_cmm> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  final GlobalKey<SfSignaturePadState> signatureKey1 = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureKey2 = GlobalKey();
  DateTime _dateTime = DateTime.now();
  int ser_tap = 1;
  bool isLoading = false;
  bool isLoading_main = false;
  bool isLoadingCusto = false;
  final _searchCustoController = TextEditingController();
  ////////////--------------------->
  List _selecteSer = [];
  List<String> _selecteSerbool = [];
  List<TextEditingController> _controllers_person = [];
  List<TextEditingController> _controllers_shop = [];
  List<TextEditingController> _controllers_shop_sub = [];
  final _formKey_person = GlobalKey<FormState>();
  ////////////--------------------->
  List<CQuotModel> cQuotModels = [];
  List<AreaModel> areaModels = [];
  List<AreaModel> _areaModels = <AreaModel>[];
  List<CustomerModel> customerModels = [];
  List<CustomerModel> _customerModels = <CustomerModel>[];
  List<QuotxSelectModel> quotxSelectModels = [];
  // List<ExpAutoModel> expAutoModels = [];
  List<AutoExpTransModelCMM> expAutoModels = [];

  ///------------------------------------------------------------>
  List<PersonFieldModel> data_person = data_persons;
  List<ShopFieldModel> data_shop = data_shops;
  List<ClientModel> clientModels = [];
  List<DocumentModel> documentModels = [];
  List<AttachmentsModel> attachments = [];
  List<DetailsModel> detailsModel = [];
  List<AnnouncementZone> announcementZone = [];
  Map<String, dynamic> fullData = {};
  List data_cid = [];
  List data_title_doc = [];
  List data_title_receipt = [];

  ///------------------------------------------------------------>(stepper)
  int activeStep = 0; // stepper
  ////////////--------------------->
  double _area_sum = 0, _area_rent_sum = 0;
  ////////////--------------------->

  String? Value_D_read;
  String? cxname_card,
      cxname_lease,
      cxname_other,
      cxname_card_ser,
      cxname_lease_ser,
      cxname_other_ser,
      Get_Value_cid,
      foder;
  ////////////--------------------->
  String Value_rental_type_3 = '';
  String Value_rental_count_ = '';
  String Value_rental_type_ = '';
  var uuid_user;
  String? uuid_Request;
  dynamic data_response_Post_GC_payment = {};
  bool read_Only = false;
  final TextEditingController Formbecause_ = TextEditingController();
  ////////////--------------------->
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Data_clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.Get_ReContact.toString() == 'YES') {
        Loading_Data_cid(); // ใช้ context ได้แล้ว
      } else {
        select_customer();
      }
    });
    Value_D_read = DateFormat('yyyy-MM-dd').format(_dateTime);
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
    Loading_Data_Step3();
    Loading_Data_config();
    loadAnnounceMentGetzone();
  }

  void Loading_Data_cid() async {
    Dia_log1(context);
    try {
      final teNantModels = widget.Get_TeNantModels;

      if (teNantModels.isEmpty) {
        _showSnack('ไม่พบข้อมูลผู้เช่า');
        return;
      }

      final cusnoCid = (teNantModels.first.custno ?? '').toString();
      final tenantCid = (teNantModels.first.cid ?? '').toString();
      await select_customer(query: cusnoCid.toString().trim());

      final index = customerModels.indexWhere(
        (x) => (x.custno ?? '').toString() == cusnoCid,
      );
      if (index < 0) {
        _showSnack('${widget.Get_Value_uuid} ไม่พบลูกค้า custno=$cusnoCid');
        return;
      }

      final model = customerModels[index];

      String s(v) => (v ?? '').toString();
      setState(() {
        Get_Value_cid = tenantCid;
        uuid_Request = s(model.uuid);
      });
      final addr = model.address;

      final data_person_add = <String>[
        s(model.cname),
        s(model.tax),
        s(model.age),
        s(model.national),
        s(addr?.number),
        s(addr?.moo),
        s(addr?.soi),
        s(addr?.road),
        s(addr?.tambon),
        s(addr?.amphoe),
        s(addr?.province),
        s(model.tel),
        s(model.addr1),
      ];

      final data_shop_add = <String>[
        '',
        s(widget.Get_Value_area_sum),
        s(model.stype),
        s(model.scname),
      ];

      final data_shopsub_add = <String>[
        s(zone_Subname) ?? '',
        s(Form_zone_name.text),
        s(widget.Get_Value_area_ln),
      ];

      _updateCustomerData(
          data_person_add, data_shop_add, data_shopsub_add, '', '');

      if (!mounted) return;
      Dia_log1(context); // OK เพราะเราเรียกหลังเฟรมแรกแล้ว
    } catch (e, st) {
      //   debugPrint('Loading_Data_cid error: $e\n$st');
      _showSnack('เกิดข้อผิดพลาดในการโหลดข้อมูลลูกค้า');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    final sm = ScaffoldMessenger.maybeOf(context);
    sm?.showSnackBar(SnackBar(content: Text(msg)));
  }

  Data_clear() async {
    setState(() {
      clientModels.clear();
      documentModels.clear();
      attachments.clear();
      detailsModel.clear();
      _controllers_person = List.generate(
        data_person.length,
        (i) => TextEditingController(text: ''),
      );
      _controllers_shop = List.generate(
        data_shop.length,
        (i) => TextEditingController(text: ''),
      );
      _controllers_shop_sub = List.generate(
        data_shop[0].detailsub.length,
        (i) => TextEditingController(text: ''),
      );
    });
  }

  ////////////--------------------->
  @override
  void dispose() {
    _debounce?.cancel();
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
  String? zone_Subser, zone_Subname, zone_ser, zone_name;
  final Form_zone_name = TextEditingController();
  final Form_ln_name = TextEditingController();
  Future<void> read_GC_zone({required String serZone}) async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';

    final url = '${MyConstant().domain}/GC_zone.php?isAdd=true&ren=$ren';

    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);

      for (final map in result) {
        final zoneModel = ZoneModel.fromJson(map);

        if (zoneModel.ser?.toString() == serZone.toString()) {
          final subSer = zoneModel.sub_zone?.toString() ??
              ''; // ✅ เปลี่ยนชื่อ field ให้ตรง model คุณ
          final subName = zoneModel.subpn?.toString() ??
              ''; // ✅ เปลี่ยนชื่อ field ให้ตรง model คุณ

          if (!mounted) return;
          setState(() {
            zone_Subser = subSer;
            zone_Subname = subName;
          });

          // await prefs.setString('zoneSubSer', subSer);
          // await prefs.setString('zonesSubName', subName);
          break;
        }
      }
    } catch (e) {
      // print(e);
    }
  }

  Loading_Data_config() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      uuid_Request = widget.Get_Value_uuid.toString();
      zone_ser = preferences.getString('zoneSer');
      zone_name = preferences.getString('zonesName');
      // zone_Subser = preferences.getString('zoneSubSer');
      // zone_Subname = preferences.getString('zonesSubName');
      // Form_zone_name.text = preferences.getString('zonesName')!;
      // Form_ln_name.text = widget.Get_Value_area_ln!;
      Form_zone_name.text = preferences.getString('zonesName') ?? '';
      Form_ln_name.text = widget.Get_Value_area_ln ?? '';
    });
    await read_GC_zone(serZone: zone_ser!);
    setState(() {
      data_cid = cid;
      data_title_doc = doc;
      data_title_receipt = receipt;
    });
    if (widget.Get_Value_uuid != null &&
        widget.Get_Value_uuid.toString() != '' &&
        widget.Get_Value_uuid.toString() != 'null') {
      setState(() {
        // uuid_user = widget.Get_Value_uuid.toString();
        activeStep = (int.tryParse(widget.Get_Value_step ?? '0') ?? 0);
        read_Only = true;
      });
      Loading_Data_Step2();
    }
    //  print('uuid_Request');
    //  print(uuid_Request);
  }

  Loading_Data_config2() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      uuid_Request = widget.Get_Value_uuid.toString();
      zone_ser = preferences.getString('zoneSer');
      zone_name = preferences.getString('zonesName');
      zone_Subser = preferences.getString('zoneSubSer');
      zone_Subname = preferences.getString('zonesSubName');
      Form_zone_name.text = preferences.getString('zonesName')!;
      Form_ln_name.text = widget.Get_Value_area_ln!;
    });
    setState(() {
      data_cid = cid;
      data_title_doc = doc;
      data_title_receipt = receipt;
    });
    if (widget.Get_Value_uuid != null &&
        widget.Get_Value_uuid.toString() != '' &&
        widget.Get_Value_uuid.toString() != 'null') {
      setState(() {
        // uuid_user = widget.Get_Value_uuid.toString();
        // activeStep = activeStep;
        read_Only = true;
      });
      Loading_Data_Step2();
    }
    //  print('uuid_Request');
    //  print(uuid_Request);
  }

  ///////////------------------------------------>
  Future<void> Loading_Data_Step2() async {
    //  print('Loading_Data_Step2');
    setState(() {
      isLoading = true;
      isLoading_main = true;
      clientModels.clear();
      documentModels.clear();
      attachments.clear();
      detailsModel.clear();
    });
    print('uuid_Request: $uuid_Request');
    try {
      await Set_data(uuid_Request!, OutputType.full);
      // await Set_data(uuid_user, OutputType.documents);
      // await Set_data(uuid_user, OutputType.attachments);
    } catch (e) {
      //   print('❌ Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
        isLoading_main = false;
      });
    }
  }

  List<Map<String, dynamic>> jsonx =
      []; // คืนจำนวนที่โหลดได้ จะได้ await แล้วรู้ผลแน่ ๆ
  // Future<int> Loading_Data_Step3() async {
  //   try {
  //     if (!mounted) return 0;

  //     // ล้างของเก่า
  //     setState(() => expAutoModels.clear());

  //     final uuid = widget.Get_Value_uuid?.toString();
  //     if (uuid == null || uuid.isEmpty || uuid == 'null') return 0;

  //     final response = await readPrepayment(requestUuid: uuid);
  //     if (response == null || response.statusCode != 200) {
  //       print('❌ Prepayment failed or null response');
  //       return 0;
  //     }

  //     final body = jsonDecode(response.body);
  //     final details = body['data']?['details'];
  //     if (details is! List) {
  //       print('⚠️ ไม่มีข้อมูลใน field "data->details"');
  //       return 0;
  //     }

  //     final models = details
  //         .map<AutoExpTransModelCMM>((e) => AutoExpTransModelCMM.fromJson(e))
  //         .toList();

  //     if (!mounted) return models.length;
  //     setState(() => expAutoModels.addAll(models));

  //     return models.length;
  //   } catch (e) {
  //     print('⚠️ Loading_Data_Step3 error: $e');
  //     return 0;
  //   }
  // }

  Future<void> Loading_Data_Step3() async {
    setState(() {
      expAutoModels.clear();
      if (uuid_Request != null) {
        widget.Get_Value_uuid = uuid_Request.toString();
      }
    });
    if (widget.Get_Value_uuid != null &&
        widget.Get_Value_uuid.toString() != '' &&
        widget.Get_Value_uuid.toString() != 'null') {
      final response =
          await readPrepayment(requestUuid: widget.Get_Value_uuid.toString());

      if (response != null && response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['data']['details'] != null &&
            body['data']['details'] is List) {
          final List<dynamic> list = body['data']['details'];
          final models =
              list.map((e) => AutoExpTransModelCMM.fromJson(e)).toList();

          setState(() {
            expAutoModels.addAll(models);
          });
        } else {
          //    print('⚠️ ไม่มีข้อมูลใน field "data->details"');
        }
      } else {
        //    print('❌ Prepayment failed or null response');
      }
    }
  }

  // Loading_Data_Step3() async {
  //   // var uuid_user = 'd87fec79-6020-449f-8b8b-724e4d6a0d4c';

  //   final result = await read_GC_ExpAuto();
  //   print('Loading_Data_Step3');

  //   setState(() {
  //     expAutoModels = result;

  //     jsonx = result.map((e) => e.toJson()).toList();
  //   });
  // }

//////////////------------------------------------------------------>
  String headerText() {
    switch (activeStep) {
      case 0:
        return 'ผู้เช่า ';
      case 1:
        return 'ข้อมูลการเช่า';
      case 2:
        return 'ค่าบริการ';

      case 3:
        return 'การชำระ';

      // case 4:
      //   return 'สัญญาเช่า';

      default:
        return '';
    }
  }

  void _goToNextStep() {
    setState(() {
      activeStep += 1;
      clientModels.clear();
      documentModels.clear();
      fullData.clear();
      attachments.clear();
    });
  }

//////////////------------------------------------------------------>
  String? linksFirst, linksLast, linksPrev, linksNext;
  int? currentPage, lastPage, perPage, totalPage;
  Future<void> select_customer(
      {String? urlCustom, String query = '', StateSetter? setStateSB}) async {
    if (mounted) {
      setState(() => isLoadingCusto = true);
      setStateSB?.call(() {});
    }

    String baseUrl = urlCustom ??
        '${MyConstant().domain_v2}/lookup/customers' +
            (query.isNotEmpty
                ? Uri(queryParameters: {'q': query}).toString()
                : '');

    // 1. URL Protocol Fix (HTTPS Enforcement) เพื่อป้องกัน Authorization header หาย
    if (MyConstant().domain_v2.startsWith('https://') &&
        baseUrl.startsWith('http://')) {
      baseUrl = baseUrl.replaceFirst('http://', 'https://');
    }

    final Uri url = Uri.parse(baseUrl);

    try {
      final headers = await MyHeaders.build();
      final res = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        if (mounted) {
          setState(() => isLoadingCusto = false);
          setStateSB?.call(() {});
        }
        return;
      }

      final result = json.decode(res.body);
      if (result is! Map) {
        if (mounted) {
          setState(() => isLoadingCusto = false);
          setStateSB?.call(() {});
        }
        return;
      }

      // 2. Metadata Parsing (Robust)
      final meta = result['meta'];
      if (meta is Map) {
        if (mounted) {
          setState(() {
            currentPage =
                int.tryParse(meta['current_page']?.toString() ?? '') ??
                    currentPage;
            lastPage =
                int.tryParse(meta['last_page']?.toString() ?? '') ?? lastPage;
            perPage =
                int.tryParse(meta['per_page']?.toString() ?? '') ?? perPage;
            totalPage =
                int.tryParse(meta['total']?.toString() ?? '') ?? totalPage;
          });
        } else {
          currentPage = int.tryParse(meta['current_page']?.toString() ?? '') ??
              currentPage;
          lastPage =
              int.tryParse(meta['last_page']?.toString() ?? '') ?? lastPage;
          perPage = int.tryParse(meta['per_page']?.toString() ?? '') ?? perPage;
          totalPage =
              int.tryParse(meta['total']?.toString() ?? '') ?? totalPage;
        }
      }

      // 3. Links Parsing (Robust)
      final links = result['links'];
      if (links is Map) {
        if (mounted) {
          setState(() {
            linksFirst = links['first']?.toString();
            linksLast = links['last']?.toString();
            linksPrev = links['prev']?.toString();
            linksNext = links['next']?.toString();
          });
        } else {
          linksFirst = links['first']?.toString();
          linksLast = links['last']?.toString();
          linksPrev = links['prev']?.toString();
          linksNext = links['next']?.toString();
        }
      }

      // 4. Data Parsing (Existing robust logic)
      final List<CustomerModel> parsed = [];
      if (result['data'] is List) {
        final list = result['data'] as List;
        for (final item in list) {
          try {
            final map = Map<String, dynamic>.from(item as Map);
            _coerceStringFields(map, const [
              'datex',
              'timex',
              'custno',
              'taxno',
              'scname',
              'stype',
              'tser',
              'type',
              'cname',
              'branch',
              'attn',
              'addr_1',
              'addr_2',
              'zip',
              'tel',
              'tax',
              'fax',
              'email',
              'lineid',
              'lastday',
              'status',
              'data_update',
              'cid',
              'docno',
              'sdate',
              'ldate',
              'period',
              'nday',
              'ctype',
              'zser',
              'zn',
              'aser',
              'ln',
              'qty',
              'area',
              'rtser',
              'rtname',
              'user_name',
              'passw',
              'sname',
              'wnote',
              'uuid',
              'birth',
              'religion',
              'national'
            ]);

            if (map['json'] is List && (map['json'] as List).isNotEmpty) {
              final first = (map['json'] as List).first;
              if (first is Map || first is String) {
                map['json'] = first;
              } else {
                map['json'] = null;
              }
            }
            parsed.add(CustomerModel.fromJson(map));
          } catch (e) {}
        }
      }

      // 5. Apply Results
      if (mounted) {
        setState(() {
          isLoadingCusto = false;
          customerModels.clear();
          _customerModels.clear();
          customerModels.addAll(parsed);
          _customerModels.addAll(parsed);
        });
        setStateSB?.call(() {});
      } else {
        isLoadingCusto = false;
        customerModels.clear();
        _customerModels.clear();
        customerModels.addAll(parsed);
        _customerModels.addAll(parsed);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingCusto = false);
        setStateSB?.call(() {});
      }
    }
  }

  /// ช่วยบังคับให้คีย์ที่ควรเป็น String แปลงจาก List/num/bool/Map -> String
  void _coerceStringFields(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      if (v is String) continue;
      if (v is num || v is bool) {
        map[k] = v.toString();
        continue;
      }
      if (v is List) {
        // ถ้าเป็นลิสต์ของสตริง/ตัวเลข -> join ด้วย ','
        final allSimple = v.every((e) => e is String || e is num || e is bool);
        map[k] =
            allSimple ? v.map((e) => e.toString()).join(',') : jsonEncode(v);
        continue;
      }
      if (v is Map) {
        // แปลงเป็น JSON string
        try {
          map[k] = jsonEncode(v);
        } catch (_) {
          map[k] = v.toString();
        }
        continue;
      }
      map[k] = v.toString();
    }
  }

  // Future<void> select_customer({String? urlCustom, String query = ''}) async {
  //   if (customerModels.isNotEmpty) {
  //     setState(() {
  //       customerModels.clear();
  //       _customerModels.clear();
  //     });
  //   }

  //   Uri url;
  //   if (urlCustom != null) {
  //     url = Uri.parse(urlCustom);
  //   } else {
  //     final baseUrl = '${MyConstant().domain_v2}/lookup/customers';
  //     final queryParams = query.isNotEmpty ? '?q=$query' : '';
  //     url = Uri.parse('$baseUrl$queryParams');
  //   }

  //   final request = http.Request('GET', url);

  //   try {
  //     final response = await request.send();
  //     if (response.statusCode == 200) {
  //       final jsonString = await response.stream.bytesToString();
  //       final result = json.decode(jsonString);

  //       if (result['meta'] != null) {
  //         setState(() {
  //           currentPage = result['meta']['current_page'] ?? 0;
  //           lastPage = result['meta']['last_page'] ?? 0;
  //           perPage = result['meta']['per_page'] ?? 0;
  //           totalPage = result['meta']['total'] ?? 0;
  //         });
  //       }

  //       if (result['links'] != null) {
  //         setState(() {
  //           linksFirst = result['links']['first'];
  //           linksLast = result['links']['last'];
  //           linksPrev = result['links']['prev'];
  //           linksNext = result['links']['next'];
  //         });
  //       }

  //       if (result['data'] is List) {
  //         for (var map in result['data']) {
  //           CustomerModel customerModel = CustomerModel.fromJson(map);
  //           setState(() {
  //             customerModels.add(customerModel);
  //           });
  //         }
  //       }
  //     } else {
  //       print('Error: ${response.statusCode} ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //   }
  // }

  Future<void> Set_data(String uuid, OutputType type) async {
    //  print('🔄 เริ่มโหลดข้อมูล: uuid = xx, type = $type');

    try {
      await setDataHandler(
        uuid: uuid,
        type: type,
        clientModels: clientModels,
        documentModels: documentModels,
        attachments: attachments,
        fullDataTarget: fullData,
        detailsModel: detailsModel,
        onComplete: () {
          setState(() {
            isLoading = false;
          });
          //      print('✅ โหลดข้อมูลเสร็จสิ้น: type = $type');
          AddForm_requests_uuid(0);
        },
      );
    } catch (e, stack) {
      //    print('❌ เกิดข้อผิดพลาดขณะโหลดข้อมูล [type: $type]');
      //   print('🧾 ข้อความ: $e');
      //   print('📍 StackTrace:\n$stack');
      setState(() {
        isLoading = false;
      });
    }
  }

  void AddForm_requests_uuid(index) {
    // แปลง CustomerModel ให้เป็น JSON string เพื่อแสดง
    String jsonString = jsonEncode(clientModels[index].toJson());
    ClientModel model = clientModels[index]; // ดึง object ออกมาก่อน
    DetailsModel details = detailsModel[index];
    // print(jsonString);
    //  final model = ClientModel.fromJson(jsonData);
    // print(model.json?['province']); // → เชียงใหม่

    List<String> data_person_add = [
      model.cname ?? "",
      model.tax ?? "",
      model.age.toString(),
      model.national ?? "",
      model.json?['number'] ?? "",
      model.json?['moo'] ?? "",
      model.json?['soi'] ?? "",
      model.json?['road'] ?? "",
      model.json?['tambon'] ?? "",
      model.json?['amphoe'] ?? "",
      model.json?['province'] ?? "",
      model.tel ?? "",
      model.addr_1 ?? ""
    ];

    List<String> data_shop_add = [
      "-",
      widget.Get_Value_area_sum ?? "",
      model.stype ?? "",
      model.scname ?? ""
    ];
    List<String> data_shopsub_add = [
      details.subzone ?? "",
      details.zn ?? "",
      details.ln ?? "-",
    ];
    List<String> data_details_add = [
      details.sdate!,
      details.ldate!,
      details.type!,
      '1',
    ];
    List<String> data_cid_add = [
      details.sdate!,
      details.ldate!,
      details.type!,
      details.leaseTermMonths.toString(),
    ];

    // อัปเดตข้อมูลทั้งหมด
    _updateCustomerData(data_person_add, data_shop_add, data_shopsub_add,
        data_details_add, data_cid_add);
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
      // อัปเดต cid
      for (int i = 0; i < cidData.length; i++) {
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
    });
  }

  Future<void> createRequestUuid() async {
    // zone_Subser = preferences.getString('zoneSubSer');
    // zone_Subname = preferences.getString('zonesSubName');
    if (uuid_Request == null || uuid_Request!.trim().isEmpty) {
      //    print('⚠️ UUID ไม่ถูกต้อง หรือไม่มีข้อมูล [ UUID : $uuid_Request]');
      return;
    }

    // ข้อมูลที่ต้องส่งไปยัง API
    final uuidcreate = uuid_Request;
    // final uuidannouncemen = announcement_uuid;
    int moduleId = (widget.Get_ReContact == 'YES') ? 2 : 1;
    //  print('✅ UUID : $uuidcreate');
    final data_expjson =
        await SecurePrefs.getDecrypted(SecurePrefsType.expjson);

    final headers = await MyHeaders.build(); // ✅ ต้อง await

    if (data_expjson == null || data_expjson.isEmpty) {
      return await Dialog_error(context, 'ไม่พบข้อมูลค่าธรรมเนียม');
    }

    final parsed = jsonDecode(data_expjson); // แปลง String -> dynamic
    if (parsed is! List) {
      return await Dialog_error(context, 'รูปแบบข้อมูลค่าธรรมเนียมไม่ถูกต้อง');
    }

    final List<dynamic> dataExpJson = parsed;

// จากนั้น filter ตาม ser
    final found = dataExpJson.where((e) {
      // ถ้า e เป็น Map<String,dynamic>
      final ser = (e is Map && e['ser'] != null) ? e['ser'].toString() : '';
      return ser == '1';
    }).toList();

    if (found.isEmpty) {
      return await Dialog_error(context, 'กรุณาเพิ่มค่าธรรมเนียมใบอนุญาต');
    }

    // ✅ ใช้ Uri พร้อม http:// เสมอ
    final url = Uri.parse('${MyConstant().domain_v1}/admin/requests');

    if (zone_ser == null ||
        zone_ser!.trim().isEmpty ||
        zone_name == null ||
        zone_name!.trim().isEmpty ||
        widget.Get_Value_area_index == null ||
        Form_ln_name.text.trim().isEmpty ||
        widget.Get_Value_area_sum == null) {
      //   print('❌ ข้อมูลไม่ครบ กรุณาตรวจสอบ');
      return;
    }
    // zone_Subser = preferences.getString('zoneSubSer');
    //   zone_Subname = preferences.getString('zonesSubName');
    // กำหนดข้อมูลลงใน Map ก่อน เพื่อความชัดเจน
    final requestData = {
      "module_id": moduleId,
      "clients_uuid": uuidcreate,
      "announcement_uuid": announcement_uuid ?? "",
      "subzoneser": (zone_Subser == null || zone_Subser.toString() == '')
          ? '0'
          : zone_Subser!.trim(),
      "subzone": (zone_Subname == null || zone_Subname.toString() == '')
          ? '-'
          : zone_Subname!.trim(),
      "lease_number":
          (widget.Get_ReContact.toString() == 'YES') ? "$Get_Value_cid" : '',
      "zser": zone_ser!.trim(),
      "zn": zone_name!.trim(),
      "aser": widget.Get_Value_area_index,
      "ln": Form_ln_name.text.trim(),
      "sdate": "${data_cid[0]["detail"].toString()}", // ควรดึงจากตัวแปร ถ้ามี
      "ldate": "${data_cid[1]["detail"].toString()}", // เช่นเดียวกัน
      "sertype": "4",
      "type": "รายปี",
      "qty": widget.Get_Value_area_sum ?? '1',
      "json": {
        "number": _controllers_person[4].text.trim() ?? "",
        "moo": _controllers_person[5].text.trim() ?? "",
        "soi": _controllers_person[6].text.trim() ?? "",
        "road": _controllers_person[7].text.trim() ?? "",
        "tambon": _controllers_person[8].text.trim() ?? "",
        "amphoe": _controllers_person[9].text.trim() ?? "",
        "province": _controllers_person[10].text.trim() ?? "",
        "raw": '',
      },
      "debt_details":
          jsonDecode(data_expjson!), // ✅ แปลงเป็น List, // ✅ ถูกต้อง
    };
// แสดงข้อมูลก่อนยิง API เพื่อ debug
    print('📤 Sending data: ${jsonEncode(requestData)}');

// แปลงเป็น JSON
    final body = jsonEncode(requestData);
    try {
      // 🔁 ส่ง POST request
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // ✅ ตรวจสอบ response
      if (response.statusCode == 201) {
        var result = json.decode(response.body);

        int nextStep = activeStep + 1;
        setState(() {
          uuid_Request = result["data"]["uuid"].toString();
        });

        // ตรวจสอบ step เพื่อแสดง popup ที่แตกต่างกัน
        final requestStepx = widget.Get_Value_step;
        if (requestStepx == '2' || requestStepx == '3') {
          // step 2,3 → แสดง popup พร้อมปุ่ม "ไปหน้าใบอนุญาต"
          Dialog_success_with_action(
            context,
            'ดำเนินการสำเร็จ',
            onAction: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              String? _route = preferences.getString('route');
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                  builder: (BuildContext context) => AdminScafScreen(
                        route: 'ใบอนุญาต',
                        route_getdata: uuid_Request.toString(),
                        ser_title: -1,
                      ));
              Navigator.pushAndRemoveUntil(
                  context, materialPageRoute, (route) => false);
            },
          );
        } else if (requestStepx == '4' || requestStepx == '5') {
          // step 4,5 → ไปหน้าใบอนุญาต โดยไม่มี ser_title
          Dialog_success_with_action(
            context,
            'ดำเนินการสำเร็จ',
            onAction: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              String? _route = preferences.getString('route');
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                  builder: (BuildContext context) => AdminScafScreen(
                        route: 'ใบอนุญาต',
                        route_getdata: uuid_Request.toString(),
                      ));
              Navigator.pushAndRemoveUntil(
                  context, materialPageRoute, (route) => false);
            },
          );
        } else {
          // step อื่น → แสดง popup ธรรมดา แล้วไป step ถัดไป
          Dialog_success(context, 'ดำเนินการสำเร็จ');

          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              activeStep = nextStep;
            });
            setState(() {
              widget.Get_Value_uuid = uuid_Request.toString();
            });

            Loading_Data_config2();
          });
        }
        // _goToNextStep();
      } else {
        try {
          var result = json.decode(response.body);
          await Dialog_error(context, '${result['message']}');
          // print('❌ Failed [${response.statusCode}]: ${result['message']}');
        } catch (e) {
          //    print('❌ Failed [${response.statusCode}]: ไม่สามารถแปลง JSON ได้');
          // print('📦 Raw body: ${response.body}');
        }
      }
    } catch (e) {
      //   print('❌ Error sending request: $e');
    }
  }

  // List<AnnouncementZone> announcementZone = [];
  String? announcement_message, computed_status, announcement_uuid;
  Future<void> loadAnnounceMentGetzone() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var zoneser_check = await preferences.getString('zoneSer');
    // print('zoneser_check');
    // print(zoneser_check);
    // print('zoneser_check');
    setState(() {
      announcementZone.clear();
    });

    try {
      final response =
          await read_AnnounceMent_Getzone(zoneid: '$zoneser_check');

      if (response == null) {
        //  print('❌ No response received.');
        return;
      }

      if (response.statusCode != 200) {
        //  print('❌ Server error: ${response.statusCode}');
        return;
      }

      final result = json.decode(response.body);
      final data = result['data'];

      // print('📦 Raw data: $data');
      // print('📦 Data type: ${data.runtimeType}');

      if (data == null) {
        await Dialog_error(context, 'ไม่พบประกาศโซนนี้');
        return;
      } else {
        setState(() {
          announcement_message = result['message'];
          computed_status = data['computed_status'];
          announcement_uuid = data['uuid'];
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
        //  print('❌ Unexpected data format: ${data.runtimeType}');
      }

      if (announcementZone.isNotEmpty) {
        final zone = announcementZone.first;
        setState(() {
          if (zone.cDateStart != null) {
            data_cid[0]["detail"] = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(zone.cDateStart.toString()));
          }
          if (zone.cDateEnd != null) {
            data_cid[1]["detail"] = DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(zone.cDateEnd.toString()));
          }
        });
      }
    } catch (e) {
      //   print('❌ Exception: $e');
    }
  }

/////////////---------------------------------------->
  Future<void> _handleUpload(String uuid, int docId,
      {bool useCamera = false}) async {
    final response = await pickAndUpload(uuid, docId, useCamera: useCamera);

    if (response != null &&
        (response.statusCode == 200 || response.statusCode == 201)) {
      final Map<String, dynamic> result = json.decode(response.body);
      final data = result['data'];
      final updatedAttachment = AttachmentsModel.fromJson(data);

      setState(() {
        final index = documentModels.indexWhere(
          (element) => element.id == data['client_document_id'],
        );
        if (index != -1) {
          documentModels[index].attachments = [updatedAttachment];
        }
      });

      Dialog_success(context, 'อัปโหลดสำเร็จ');
    } else {
      //  print('❌ การอัปโหลดล้มเหลว: ${response?.statusCode}');
      Dialog_error(context, 'ไม่มีไฟล์ถูกอัปโหลด');
    }
  }

///////----------------------------------------->
// ===== Theme (ม่วงดำหรู) =====

  Color _kBg = Color(0xFFF7F9FC);
  Color _kSurface = Color(0xFFFFFFFF);
  Color _kCard = Color.fromARGB(255, 127, 130, 134);
  Color _kBorder = Color(0xFFE3E8EF);
  Color _kPrimary = Color(0xFF2563EB); // blue600
  Color _kPrimaryMd = Color(0xFF60A5FA); // blue300
  Future<T?> showSideSheetRight<T>({
    required BuildContext context,
    required Widget child, // เนื้อหาในแผง (ใส่ Column เดิมของคุณได้)
    bool dismissible = true, // แตะพื้นหลังเพื่อปิดได้ไหม
    bool blockBack = false, // กันปุ่ม Back/system gesture ไหม
    Duration duration = const Duration(milliseconds: 260),
    Color barrierColor = const Color(0x99000000),
    Color? surfaceColor, // สีพื้นหลังของแผง (เช่น _kSurface)
    double? maxWidth, // กว้างสุดของแผง
    double? heightFactor = 0.85, // สูงเท่าไรของหน้าจอ
    BorderRadiusGeometry radius =
        const BorderRadius.horizontal(left: Radius.circular(18)),
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierLabel: 'SideSheetRight',
      barrierDismissible: dismissible,
      barrierColor: barrierColor,
      transitionDuration: duration,
      pageBuilder: (_, __, ___) {
        final mq = MediaQuery.of(context);
        final w = mq.size.width;
        final h = mq.size.height;

        // กำหนดความกว้างตามขนาดจอ
        final sheetWidth =
            maxWidth ?? (w < 600 ? w * 0.95 : (w < 1024 ? 480.0 : 560.0));

        Widget body = SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: sheetWidth,
                maxHeight: h,
              ),
              child: FractionallySizedBox(
                heightFactor: heightFactor?.clamp(0.0, 1.0),
                child: Material(
                  color: surfaceColor ?? Colors.white,
                  elevation: 16,
                  borderRadius: radius,
                  clipBehavior: Clip.antiAlias,
                  child: child,
                ),
              ),
            ),
          ),
        );

        if (blockBack) {
          body = WillPopScope(onWillPop: () async => false, child: body);
        }
        return body;
      },
      transitionBuilder: (_, anim, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0), // จากขวา
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void showAnnouncementDetails(BuildContext context, Map<String, dynamic> ann) {
    // ===== เตรียมข้อมูล =====
    final now = DateTime.now();
    final pub = _parseDt(ann['published_at']);
    final exp = _parseDt(ann['expired_at']);
    final regS = _parseDt(ann['c_date_start']);
    final regE = _parseDt(ann['c_date_end']);
    final zone = ann['zone_property'] as Map<String, dynamic>?;

    final computed = (ann['computed_status'] ?? '').toString();
    final payPn = (ann['pay_status_pn'] ?? '').toString();
    final statusChip = _statusChip(computed);
    final payChip = _pill(
      payPn.isEmpty ? 'สถานะชำระ' : payPn,
      bg: const Color(0xFF43325E),
      border: const Color(0xFF6E4BB8),
    );

    // ===== แสดงเป็น Side Sheet ด้านขวา =====
    showSideSheetRight<Map<String, dynamic>>(
      context: context,
      dismissible: true, // แตะพื้นหลังเพื่อปิด (ถ้าไม่ต้องการให้ปิด -> false)
      blockBack: true, // กันปุ่ม Back
      surfaceColor: _kSurface,
      heightFactor: 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                colors: [_kBg, const Color(0xFF1B1530), _kPrimary],
                stops: const [0.0, 0.55, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.campaign, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'รายละเอียดประกาศ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'ปิด',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Body (ต้องใช้ Expanded ครอบ ListView เสมอ)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                // Wrap(spacing: 8, runSpacing: 8, children: [
                //   statusChip,
                //   payChip,
                //   if (ann['status'] != null)
                //     _pill('สถานะ: ${ann['status']}',
                //         bg: _kCard, border: _kBorder),
                // ]),
                const SizedBox(height: 12),
                _section('เปิดรับคำร้อง', [
                  _rowIconText(Icons.upload_rounded, 'ตั้งแต่', _fmt(pub)),
                  _rowIconText(Icons.event_busy, 'จนถึง', _fmt(exp),
                      trailing: _dueBadge(now, exp)),
                ]),
                _section('รอบอายุใบอนุญาตฯฉบับใหม่', [
                  _rowIconText(Icons.event_available, 'วันที่ออก', _fmt(regS)),
                  _rowIconText(Icons.event, 'วันที่สิ้นสุด', _fmt(regE),
                      trailing: _windowBadge(now, regS, regE)),
                ]),
                if (zone != null)
                  _section('โซน/พื้นที่', [
                    _rowIconText(
                        Icons.map_outlined, 'โซน', '${zone['zone_pn'] ?? '-'}'),
                    // _rowIconText(Icons.fingerprint, 'UUID โซน',
                    //     '${zone['uuid'] ?? '-'}'),
                    _rowIconText(
                      Icons.verified_user,
                      'สถานะโซน',
                      (zone['active'] == 1) ? 'เปิดใช้งาน' : 'ปิดใช้งาน',
                    ),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ===== UI helpers =====
  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _rowIconText(IconData icon, String label, String value,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _pill(String text, {required Color bg, required Color border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _statusChip(String computed) {
    const _kCard = Color(0xFF1A1628);
    const _kBorder = Color(0xFF2A2341);
    // โทน: ยังลงทะเบียนได้ → เขียว / อย่างอื่น → ม่วง
    final ok = computed.contains('ยังลงทะเบียนได้');
    return _pill(
      'สถานะ: $computed',
      bg: ok ? const Color(0xFF064E3B) : _kCard,
      border: ok ? const Color(0xFF10B981) : _kBorder,
    );
  }

  Widget _dueBadge(DateTime now, DateTime? exp) {
    if (exp == null) return const SizedBox();
    final days = exp.difference(now).inDays;
    if (days >= 0) {
      return _pill('เหลืออีก ~${days} วัน',
          bg: const Color(0xFF1E3A8A), border: const Color(0xFF60A5FA));
    } else {
      return _pill('เลยกำหนดมา ~${days.abs()} วัน',
          bg: const Color(0xFF7F1D1D), border: const Color(0xFFFCA5A5));
    }
  }

  Widget _windowBadge(DateTime now, DateTime? s, DateTime? e) {
    if (s == null || e == null) return const SizedBox();
    if (now.isBefore(s)) {
      final d = s.difference(now).inDays;
      return _pill('จะเริ่มใน ~${d} วัน',
          bg: const Color(0xFF1E3A8A), border: const Color(0xFF60A5FA));
    } else if (now.isAfter(e)) {
      final d = now.difference(e).inDays;
      return _pill('สิ้นสุดมา ~${d} วัน',
          bg: const Color(0xFF7F1D1D), border: const Color(0xFFFCA5A5));
    } else {
      final d = e.difference(now).inDays;
      return _pill('เปิดอยู่ (เหลือ ~${d} วัน)',
          bg: const Color(0xFF064E3B), border: const Color(0xFF10B981));
    }
  }

// ===== Date helpers =====
  DateTime? _parseDt(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    // รองรับทั้ง "YYYY-MM-DD" และ "YYYY-MM-DD HH:mm:ss"
    final iso = s.contains(' ') ? s.replaceFirst(' ', 'T') : s;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '-';
    // 27 Aug 2025, 00:00
    const mons = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final m = mons[dt.month - 1];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}-${dt.month}-${dt.year}';
  }

  /////////////---------------------------------------->
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

  /////////////---------------------------------------->
  @override
  Widget build(BuildContext context) {
    final bool hasAnnouncement =
        activeStep == 0 && (announcement_message?.trim().isNotEmpty ?? false);
    return (ser_tap == 2)
        ? SignaturePad_CMM()
        : (activeStep == 1)
            ? Stepper_2(context)
            : (activeStep == 2)
                ? Stepper_3(context)
                : (activeStep == 3)
                    ? Stepper_4(context)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width < 1200)
                                ? 1400
                                : (Responsive.isDesktop(context))
                                    ? MediaQuery.of(context).size.width * 0.85
                                    : 1400,
                            // width: (Responsive.isDesktop(context))
                            //     ? MediaQuery.of(context).size.width * 0.85
                            //     : 1200,
                            // width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height + 300,
                            child: Column(children: [
                              Header_Stepper(context),
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
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1200)
                                                ? 1400
                                                : (Responsive.isDesktop(
                                                        context))
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.85
                                                    : 1400,
                                            // width:
                                            //     (Responsive.isDesktop(context))
                                            //         ? MediaQuery.of(context)
                                            //                 .size
                                            //                 .width *
                                            //             0.85
                                            //         : 1200,
                                            // width: MediaQuery.of(context)
                                            //         .size
                                            //         .width *
                                            //     0.85,
                                            // height: MediaQuery.of(context).size.height * 0.8,
                                            decoration: const BoxDecoration(
                                              color: AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
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
                                                        child:
                                                            Column(children: [
                                                          _buildSidebarSectionTitle(
                                                              Icons.person,
                                                              'ข้อมูลผู้เช่า'),
                                                          Form_Person(context),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                        ]),
                                                      ),
                                                    )),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child:
                                                            AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      220),
                                                          curve: Curves.easeOut,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient: hasAnnouncement
                                                                // โทนหรู: ม่วงดำ (มีประกาศ) / เทาเข้ม (ไม่มี)
                                                                ? LinearGradient(
                                                                    colors: [
                                                                      Color(0xFF2E1D59)
                                                                          .withOpacity(
                                                                              0.5),
                                                                      Color(0xFF7B5CE6)
                                                                          .withOpacity(
                                                                              0.5)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                  )
                                                                : LinearGradient(
                                                                    colors: [
                                                                      Color(0xFF1F2937)
                                                                          .withOpacity(
                                                                              0.5),
                                                                      Color(0xFF0F172A)
                                                                          .withOpacity(
                                                                              0.5)
                                                                    ],
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end: Alignment
                                                                        .bottomRight,
                                                                  ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        14),
                                                            // boxShadow: const [
                                                            //   BoxShadow(
                                                            //       color: Color(
                                                            //           0x33000000),
                                                            //       blurRadius:
                                                            //           12,
                                                            //       offset:
                                                            //           Offset(0,
                                                            //               6)),
                                                            // ],
                                                            border: Border.all(
                                                              color: hasAnnouncement
                                                                  ? const Color(
                                                                          0xFF8B5CF6)
                                                                      .withOpacity(
                                                                          0.5)
                                                                  : const Color(
                                                                          0xFF334155)
                                                                      .withOpacity(
                                                                          0.5),
                                                              width: 1.2,
                                                            ),
                                                          ),
                                                          child: ListTile(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                            leading:
                                                                CircleAvatar(
                                                              radius: 18,
                                                              backgroundColor:
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          .15),
                                                              child: Icon(
                                                                hasAnnouncement
                                                                    ? Icons
                                                                        .campaign
                                                                    : Icons
                                                                        .info_outline,
                                                                color: Colors
                                                                    .white,
                                                                size: 18,
                                                              ),
                                                            ),
                                                            // //                    "subzoneser": (zone_Subser == null || zone_Subser.toString() == '')
                                                            //     ? '0'
                                                            //     : zone_Subser!.trim(),
                                                            // "subzone": (zone_Subname == null || zone_Subname.toString() == '')
                                                            //     ? '-'
                                                            //     : zone_Subname!.trim(),
                                                            // "lease_number":
                                                            //     (widget.Get_ReContact.toString() == 'YES') ? "$Get_Value_cid" : '',
                                                            // "zser": zone_ser!.trim(),
                                                            // "zn": zone_name!.trim(),) == 'YES') ? "$Get_Value_cid" : '',
                                                            // // "zser": zone_ser!.trim(),
                                                            title: Text(
                                                              'ประกาศ',
                                                              // 'ประกาศ  zone_Subser: ${zone_Subser}  // subzone:$zone_Subname  //zser:$zone_ser // zn:$zone_name',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            subtitle: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4),
                                                              child: Text(
                                                                hasAnnouncement
                                                                    ? announcement_message!
                                                                    : 'ไม่พบประกาศในขณะนี้',
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          .92),
                                                                  fontSize:
                                                                      12.5,
                                                                ),
                                                              ),
                                                            ),
                                                            trailing:
                                                                hasAnnouncement
                                                                    ? TextButton
                                                                        .icon(
                                                                        onPressed:
                                                                            () {
                                                                          // ตัวอย่าง: ประกาศจากแบ็คเอนด์ (Map<String, dynamic>)
                                                                          final ann =
                                                                              {
                                                                            "uuid":
                                                                                "${announcementZone.first.uuid}",
                                                                            "status":
                                                                                "${announcementZone.first.status}",
                                                                            "computed_status":
                                                                                "${announcementZone.first.computedStatus}",
                                                                            "pay_status":
                                                                                "${announcementZone.first.payStatus}",
                                                                            "pay_status_pn":
                                                                                "${announcementZone.first.payStatus}",
                                                                            "published_at":
                                                                                "${announcementZone.first.publishedAt}",
                                                                            "expired_at":
                                                                                "${announcementZone.first.expiredAt}",
                                                                            "c_date_start":
                                                                                "${announcementZone.first.cDateStart}",
                                                                            "c_date_end":
                                                                                "${announcementZone.first.cDateEnd}",
                                                                            "zone_property":
                                                                                {
                                                                              "id": '${announcementZone.first.zoneProperty!.id}',
                                                                              "uuid": "${announcementZone.first.zoneProperty!.uuid}",
                                                                              "announcement_uuid": "${announcementZone.first.zoneProperty!.announcementUuid}",
                                                                              "zone_id": '${announcementZone.first.zoneProperty!.zoneId}',
                                                                              "zone_pn": "${announcementZone.first.zoneProperty!.zonePn}",
                                                                              "active": "${announcementZone.first.zoneProperty!.active}",
                                                                              "created_at": "${announcementZone.first.zoneProperty!.createdAt}",
                                                                              "updated_at": "${announcementZone.first.zoneProperty!.updatedAt}",
                                                                            }
                                                                          };

                                                                          showAnnouncementDetails(
                                                                              context,
                                                                              ann);
                                                                          // TODO: ทำอย่างอื่น เช่น เปิดรายละเอียดทั้งหมด/คัดลอกข้อความ
                                                                          // Clipboard.setData(ClipboardData(text: announcement_message!));
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .open_in_new,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                Colors.white),
                                                                        label: const Text(
                                                                            'ดูทั้งหมด',
                                                                            style:
                                                                                TextStyle(color: Colors.white)),
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                        ),
                                                                      )
                                                                    : null,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      _buildSidebarSectionTitle(
                                                          Icons.store,
                                                          'ข้อมูลร้านค้า'),
                                                      Form_Shop(context),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      _buildSidebarSectionTitle(
                                                          Icons.receipt_long,
                                                          'ข้อมูลสัญญา'),
                                                      Form_Cid(context),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      if (activeStep == 0 &&
                                                          announcement_message !=
                                                              null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Translate.TranslateAndSet_TextAutoSize(
                                                              (activeStep == 0)
                                                                  ? 'ค่าบริการ'
                                                                  : '',
                                                              ChaoAreaScreen_Color
                                                                  .Colors_Text2_,
                                                              TextAlign.center,
                                                              null,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              12,
                                                              18,
                                                              1),
                                                        ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      if (activeStep == 0 &&
                                                          announcement_message !=
                                                              null)
                                                        BillingTable(
                                                          cid_sdate:
                                                              '${data_cid[0]["detail"]}',
                                                          cid_ldate:
                                                              '${data_cid[1]["detail"]}',
                                                          cid_zser: (announcementZone
                                                                      .length ==
                                                                  0)
                                                              ? '0'
                                                              : announcementZone
                                                                  .first
                                                                  .payStatus
                                                                  .toString(),
                                                          onRowsChanged:
                                                              (rows) {
                                                            // print(
                                                            //     'ข้อมูลล่าสุด: ${rows} แถว');
                                                            // หรือ setState(() => _rows = rows);
                                                          },
                                                        ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      hasAnnouncement
                                                          ? ActiveStep_Stepper(
                                                              context,
                                                              Stepper: 1)
                                                          : SizedBox()
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

//////////--------------------------------------------------->
  String comment = '';

  bool _busy = false;
  String randomString = '';
  final Pincontroller = TextEditingController();
  generateRandomString() {
    setState(() {
      randomString = '';
    });
    final random = Random();
    const characters = '0123456789';
    final length = 2; // Change this to the desired length

    for (int i = 0; i < length; i++) {
      final index = random.nextInt(characters.length);
      randomString += characters[index];
    }

    // return randomString;
  }

  Future<void> onRejectTap() async {
    if (_busy) return; // กันกดซ้ำ
    _busy = true;
    Dia_log1(context);
    try {
      // 1) โหลดลายเซ็นผู้อนุมัติ
      final respSig = await read_AdminSignature();
      if (respSig == null || respSig.statusCode != 200) {
        _toast('โหลดข้อมูลลายเซ็นไม่สำเร็จ');
        return;
      }

      final sigJson = jsonDecode(respSig.body);
      if (sigJson is! Map || sigJson['data'] is! Map) {
        _toast('รูปแบบข้อมูลลายเซ็นไม่ถูกต้อง');
        return;
      }
      final sigData = sigJson['data'] as Map;
      final profileId = sigData['profile_uuid']?.toString();
      final profileName = sigData['profile']?.toString();
      final sigUuid = sigData['signature_uuid']?.toString();
      final positionName = sigData['position_name']?.toString();
      //print(profileId);
      //print(sigUuid);

      if (profileId == null || sigUuid == null) {
        _toast('ข้อมูลผู้ลงนามไม่ครบ');
        return;
      }
      Future.delayed(const Duration(seconds: 1), () async {
        // 2) โหลด Reviews Flow
        final respFlow =
            await read_GC_ReviewsFlowUuid(UuidRequest: '$uuid_Request');
        if (respFlow == null || respFlow.statusCode != 200) {
          _toast('โหลดข้อมูลการอนุมัติไม่สำเร็จ');
          return;
        }

        final flowJson = jsonDecode(respFlow.body);
        if (flowJson is! Map || flowJson['data'] is! Map) {
          _toast('รูปแบบข้อมูลการอนุมัติไม่ถูกต้อง');
          return;
        }
        final data = flowJson['data'] as Map;
        final requests =
            (data['request'] is Map) ? data['request'] as Map : const {};
        final triggeredUuid = data['triggered_approval_uuid']?.toString();
        final reqUuid = requests['uuid']?.toString();

        if (triggeredUuid == null || reqUuid == null) {
          _toast('ข้อมูลคำขอไม่ครบ');
          return;
        }

        // 3) เรียก API Reject
        final ok = await POST_Reject(
          requestUuid: reqUuid,
          flowUid: triggeredUuid,
          profileUuid: profileId,
          signUuid: sigUuid,
          comMent: '$comment',
        );

        // ถ้า POST_Reject ไม่มี bool ให้เช็ก ให้ดูจาก status/throw ของมันแทน
        if (ok == false) {
          _toast('ยกเลิกคำขอไม่สำเร็จ');
          return;
        }

        if (ok!.statusCode == 200 || ok.statusCode == 201) {
          // 4) นำทางกลับหน้าหลัก (เช็ค mounted ให้ครบ)
          if (!mounted) return;

          final prefs = await SharedPreferences.getInstance();
          final routePref = prefs.getString('route'); // ถ้าจะใช้จริง

          // ใช้ post-frame เพื่อลดโอกาสชน build ขณะ pop/push
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AdminScafScreen(route: 'พื้นที่เช่า'),
              ),
              (r) => false,
            );
          });
        } else {
          final okJson = jsonDecode(ok.body);
          Dialog_error(context, '${okJson['message']}');
          return;
        }
      });
    } catch (e, st) {
      //debug//print('ReviewsFlowUuid error: $e\n$st');
      _toast('พบข้อผิดพลาด โปรดลองอีกครั้ง');
    } finally {
      _busy = false;
    }
  }

  void _showQRUploadDialog(BuildContext context, String? requestUuid) async {
    if (requestUuid == null || requestUuid.isEmpty) {
      _toast('ไม่พบ Request UUID');
      return;
    }

    // Get current auth token to share with mobile
    final String? token = await AuthService.getToken();
    if (token == null) {
      _toast('กรุณาเข้าสู่ระบบใหม่เพื่อใช้งานฟีเจอร์นี้');
      return;
    }

    // Generate expiry timestamp (10 minutes from now)
    final int expiry =
        DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;

    // Get base URL logic
    final String currentUrl = html.window.location.href;
    final int hashIndex = currentUrl.indexOf('#');
    String baseUrl =
        hashIndex != -1 ? currentUrl.substring(0, hashIndex) : currentUrl;

    // Ensure baseUrl ends with /
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }

    // Obfuscate parameters to prevent tampering
    final String dataParams = json.encode({
      'request_uuid': requestUuid,
      'expiry': expiry,
      'token': token,
    });
    final String encodedData = base64Url.encode(utf8.encode(dataParams));

    final String uploadUrl = '${baseUrl}#/mobile_upload?d=$encodedData';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text(
            'สแกนเพื่ออัปโหลดเอกสารผ่านมือถือ',
            style: TextStyle(
                fontFamily: Font_.Fonts_T, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 250,
              child: QrImageView(
                data: uploadUrl,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'คิวอาร์โค้ดจะหมดอายุใน 10 นาที',
              style: TextStyle(color: Colors.red, fontFamily: Font_.Fonts_T),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(uploadUrl))) {
                      await launchUrl(Uri.parse(uploadUrl));
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('เปิดลิงก์',
                      style: TextStyle(fontFamily: Font_.Fonts_T)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: uploadUrl));
                    _toast('คัดลอกลิงก์แล้ว');
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('คัดลอกลิงก์',
                      style: TextStyle(fontFamily: Font_.Fonts_T)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('ปิด', style: TextStyle(fontFamily: Font_.Fonts_T)),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    final sm = ScaffoldMessenger.maybeOf(context);
    sm?.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<Null> Cancel_showDialog() async {
    List<Map<String, dynamic>> data_user_cancel = [
      // {
      //   "ser": "1",
      //   "title": "วันที่ตรวจสอบ",
      //   "detail": "04-05-2025",
      // },
      {
        "ser": "1",
        "title": "เหตุผลที่ปฏิเสธ",
        "detail": "",
      },
      // {
      //   "ser": "3",
      //   "title": "ชื่อผู้ตรวจสอบ",
      //   "detail": "นางสาวเชียงราย พะเยา",
      // },
    ];
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                // stream: Stream.periodic(const Duration(seconds: 0)),
                builder: (context, snapshot) {
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
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      for (int index = 0;
                          index < data_user_cancel.length;
                          index++)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            width: 300,
                            // height: 80,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Translate.TranslateAndSet_TextAutoSize(
                                      '${data_user_cancel[index]["title"]}',
                                      ChaoAreaScreen_Color.Colors_Text2_,
                                      TextAlign.center,
                                      null,
                                      FontWeight_.Fonts_T,
                                      12,
                                      18,
                                      1),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                  child: Container(
                                    height: 60,
                                    child: TextFormField(
                                      // scrollPadding: const EdgeInsets.all(1.0),
                                      autofocus: true,
                                      readOnly: false,
                                      // focusNode: myFocusNode,
                                      textAlign: TextAlign.left,
                                      keyboardType: TextInputType.number,
                                      maxLines: 3,
                                      // controller: FormMeter_text,
                                      // validator: (value) {
                                      //   try {
                                      //     if (value == null || value.isEmpty) {
                                      //       return 'กรุณากรอกค่า';
                                      //     }

                                      //     final input = int.parse(value);
                                      //     final indexx = int.parse(row['index'].toString());
                                      //     final oldValue = int.parse(
                                      //         transMeterModels[indexx].ovalue.toString());

                                      //     if (input < oldValue) {
                                      //       return 'ค่าต้องไม่น้อยกว่า $oldValue';
                                      //     }
                                      //   } catch (e) {
                                      //     return 'รูปแบบไม่ถูกต้อง';
                                      //   }

                                      //   return null;
                                      // },
                                      // maxLength: 13,
                                      initialValue:
                                          '${data_user_cancel[index]["detail"]}',
                                      onChanged: (value) {
                                        setState(() {
                                          comment = value.toString().trim();
                                        });
                                      },

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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          // labelText: 'เลขมิเตอร์',
                                          labelStyle: const TextStyle(
                                            color: ManageScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight:
                                            //     FontWeight.bold,
                                            fontFamily: Font_.Fonts_T,
                                          )),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                        // for below version 2 use this
                                        // FilteringTextInputFormatter.allow(
                                        //     RegExp(r'[0-9 .]')),
                                        // for version 2 and greater youcan also use this
                                        // FilteringTextInputFormatter
                                        //     .digitsOnly
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'CODE : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10)),
                                            color: Color.fromARGB(
                                                255, 179, 177, 170),
                                            // image:
                                            //     const DecorationImage(
                                            //   image: AssetImage(
                                            //       "assets/pngegg2.png"),
                                            //   fit: BoxFit
                                            //       .cover,
                                            // ),
                                          ),
                                          width: 65,
                                          // color: Colors.black,
                                          padding: const EdgeInsets.all(2.0),
                                          child: Center(
                                            child: Text(
                                              '${randomString}',
                                              style: TextStyle(
                                                  color: Colors.red[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: Container(
                                    height: 40,
                                    width: 90,
                                    child: PinCode(
                                      keyboardType: TextInputType.number,
                                      numberOfFields: 2,
                                      fieldWidth: 40.0,
                                      style: const TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        color: Colors.black,
                                      ),
                                      fieldStyle: PinCodeStyle.box,
                                      onChanged: (value) {
                                        setState(() {
                                          Pincontroller.text = value.trim();
                                        });
                                      },
                                      onCompleted: (text) {
                                        setState(() {
                                          Pincontroller.text = text.trim();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        (comment == '' ||
                                                Pincontroller.text !=
                                                    randomString.toString())
                                            ? Colors.grey
                                            : Colors.black,
                                        // Colors.black,
                                      ),
                                    ),
                                    onPressed: (comment == '')
                                        ? null
                                        : () async {
                                            onRejectTap();
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
                                              'ยืนยัน',
                                              ChaoAreaScreen_Color
                                                  .Colors_Text3_,
                                              TextAlign.center,
                                              null,
                                              FontWeight_.Fonts_T,
                                              12,
                                              18,
                                              1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                ],
              );
            }));
  }

  ///---------------------->
  ActiveStep_Stepper(context, {required int Stepper}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (activeStep != 3)
            if (activeStep >= 1)
              (widget.status_uuid.toString() == 'ขอปรับปรุง' ||
                      widget.status_uuid.toString() == 'รอแก้ไข' &&
                          documentModels.first.attachments!.isNotEmpty)
                  ? SizedBox()
                  : (Stepper == 3)
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  (activeStep == 1)
                                      ? const Color.fromARGB(255, 243, 131, 130)
                                      : Colors.grey,
                                ),
                              ),
                              onPressed: (activeStep == 0)
                                  ? null
                                  : () async {
                                      if (Stepper == 2) {
                                        generateRandomString();
                                        Cancel_showDialog();
                                      } else {
                                        setState(() {
                                          activeStep = activeStep - 1;
                                        });
                                        setState(() {
                                          clientModels.clear();
                                          documentModels.clear();
                                          fullData.clear();
                                          attachments.clear();
                                        });

                                        if (activeStep == 1) {
                                          Loading_Data_Step2();
                                        }
                                      }

                                      //     SharedPreferences preferences =
                                      //     await SharedPreferences
                                      //         .getInstance();
                                      // String? _route = preferences
                                      //     .getString('route');
                                      // MaterialPageRoute
                                      //     materialPageRoute =
                                      //     MaterialPageRoute(
                                      //         builder: (BuildContext
                                      //                 context) =>
                                      //             AdminScafScreen(
                                      //                 route:
                                      //                     'RequestDetails_CMM'));
                                      // Navigator
                                      //     .pushAndRemoveUntil(
                                      //         context,
                                      //         materialPageRoute,
                                      //         (route) => false);

                                      // setState(() {
                                      //   ser_tap = 2;
                                      // });
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Translate.TranslateAndSet_TextAutoSize(
                                    (activeStep == 1)
                                        ? 'ปฏิเสธคำร้อง'
                                        : 'กลับ $activeStep',
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
                        ),
          if (activeStep != 3)
            (widget.status_uuid.toString() == 'ขอปรับปรุง' ||
                    widget.status_uuid.toString() == 'รอแก้ไข' &&
                        documentModels.first.attachments!.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey,
                          ),
                        ),
                        onPressed: () async {
                          Future.delayed(const Duration(milliseconds: 400),
                              () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            String? _route = preferences.getString('route');
                            MaterialPageRoute materialPageRoute =
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AdminScafScreen(
                                            route: 'ใบอนุญาต',
                                            route_getdata: uuid_Request ?? ""));
                            Navigator.pushAndRemoveUntil(
                                context, materialPageRoute, (route) => false);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSet_TextAutoSize(
                              'ปรับปรุงเสร็จสิ้น',
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
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.grey,
                          ),
                        ),
                        onPressed: (activeStep == 3)
                            ? null
                            : (_controllers_person[0].text.isEmpty &&
                                    activeStep == 0)
                                ? () async {
                                    await Dialog_error(
                                        context, 'กรุณาระบุข้อมูลผู้เช่า');
                                  }
                                : (announcementZone.isEmpty ||
                                        announcementZone.length == 0)
                                    ? () async {
                                        await Dialog_error(context,
                                            'ไม่พบ! ประกาศทำสัญญา/ต่อสัญญาในโซนนี้');
                                        // final response_di = await Dialog_error(
                                        //     context,
                                        //     'ไม่พบ! ประกาศทำสัญญา/ต่อสัญญาในโซนนี้');
                                        // if (response_di != null) {
                                        //   Navigator.pop(context);
                                        // }
                                      }
                                    : () async {
                                        switch (activeStep) {
                                          case 0:
                                            if (data_person[0].detail == '') {
                                              await Dialog_error(context,
                                                  'เกิดข้อผิดพลาดในการตรวจสอบข้อมูล');
                                            } else {
                                              // ตรวจสอบวันที่เริ่มต้นสิ้นสุด
                                              if (announcementZone.isNotEmpty) {
                                                final announce =
                                                    announcementZone.first;
                                                final selectedSDate =
                                                    data_cid[0]["detail"]
                                                        .toString();
                                                final selectedLDate =
                                                    data_cid[1]["detail"]
                                                        .toString();

                                                final announceSDate =
                                                    announce.cDateStart ?? '';
                                                final announceLDate =
                                                    announce.cDateEnd ?? '';

                                                if (selectedSDate !=
                                                        announceSDate ||
                                                    selectedLDate !=
                                                        announceLDate) {
                                                  final confirm =
                                                      await Dialog_confirm(
                                                    context,
                                                    'แจ้งเตือน',
                                                    'วันที่เริ่มต้นสิ้นสุด ไม่ตรงกับรอบอายุในใบอนุญาตฉบับบใหม่(รอบในใบอนุญาต: ${formatDate(announceSDate, type: DateFormatType.dmy)} - ${formatDate(announceLDate, type: DateFormatType.dmy)})คุณต้องการดำเนินการต่อหรือไม่?',
                                                  );

                                                  if (confirm == true) {
                                                    await createRequestUuid();
                                                  }
                                                } else {
                                                  await createRequestUuid();
                                                }
                                              } else {
                                                await createRequestUuid();
                                              }
                                            }
                                            break;

                                          case 1:
                                            final response =
                                                await readSubmitError(
                                              requests_uuid: '$uuid_Request',
                                              Comment: Formbecause_.text,
                                            );
                                            if (response == null) {
                                              Dialog_error(context,
                                                  'เกิดข้อผิดพลาดในการตรวจสอบข้อมูล');
                                              return;
                                            }
                                            if (response.statusCode != 200) {
                                              Dialog_error(context,
                                                  'ดำเนินการไม่สำเร็จ[${response.statusCode}]');
                                              return;
                                            }

                                            await Loading_Data_Step3(); // ✅ รอจนจบและรู้ผล
                                            if (expAutoModels.length == 0) {
                                              Dialog_error(context,
                                                  'ดำเนินการไม่สำเร็จ ไม่มีข้อมูลที่โหลดได้');
                                              return;
                                            }

                                            _goToNextStep(); // ถ้าเป็น Future ใส่ await
                                            break;

                                          case 2:
                                            if (expAutoModels.length == 0) {
                                              PanaraInfoDialog.showAnimatedGrow(
                                                context,
                                                title: "Oops",
                                                message:
                                                    "ดำเนินการไม่สำเร็จ ไม่มีข้อมูลที่โหลดได้",
                                                buttonText: "รับทราบ",
                                                onTapDismiss: () async {
                                                  await Loading_Data_Step3(); // ✅ รอจนจบและรู้ผล
                                                  Navigator.pop(context);
                                                },
                                                panaraDialogType:
                                                    PanaraDialogType.error,
                                                barrierDismissible: false,
                                              );
                                              // Dialog_error(context,
                                              //     'ดำเนินการไม่สำเร็จ ไม่มีข้อมูลที่โหลดได้');
                                              return;
                                            }

                                            final response =
                                                await Post_GC_payment(
                                                    requestUuid:
                                                        '$uuid_Request',
                                                    paymentMethodId: 0,
                                                    paymentMethodCode: 0,
                                                    bankaccountId: 0,
                                                    paidat: '-',
                                                    referencecode: '-',
                                                    reference1: '-',
                                                    reference2: '-',
                                                    paymentAmount: expAutoModels
                                                        .fold<double>(
                                                      0,
                                                      (sum, e) =>
                                                          sum +
                                                          (double.tryParse(
                                                                  "${e.total}") ??
                                                              0),
                                                    ),
                                                    // paymentAmount: 500.00,
                                                    paymentReceived: 0,
                                                    jsonx: expAutoModels);

                                            if (response != null &&
                                                (response.statusCode == 201 ||
                                                    response.statusCode ==
                                                        409)) {
                                              final jsonRes =
                                                  json.decode(response.body);
                                              setState(() {
                                                data_response_Post_GC_payment =
                                                    jsonRes;
                                                widget.Get_Value_payment_uuid =
                                                    jsonRes['data']['uuid'];
                                                // widget.Get_Value_payment_uuid
                                              });

                                              _goToNextStep();
                                            } else {
                                              Dialog_error(context,
                                                  'ไม่สามารถดำเนินการได้: การรับชำระซ้ำซ้อนหรือผิดพลาด');
                                            }

                                            break;

                                          default:
                                          // _goToNextStep();
                                        }
                                      },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSet_TextAutoSize(
                              (activeStep == 3) ? 'รับชำระ' : 'ยืนยัน/ถัดไป',
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
                  ),
        ],
      ),
    );
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
            height: (index + 1 == data_person.length || index == 0) ? null : 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      '${data_person[index].title}',
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
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.multiline,
                      showCursor: !read_Only,
                      readOnly: read_Only,
                      controller: _controllers_person[index],
                      minLines: (index == 0)
                          ? 1
                          : (index + 1 == data_person.length)
                              ? 3
                              : 1,
                      maxLines: (index == 0)
                          ? 2
                          : (index + 1 == data_person.length)
                              ? 3
                              : 1,
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
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
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
            height: (data_shop[shop].ser.toString() == '1') ? 150 : 50,
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
                                        showCursor: !read_Only,
                                        readOnly: read_Only,
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
                                        showCursor: !read_Only,
                                        readOnly: read_Only,
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
                            showCursor: !read_Only,
                            readOnly: read_Only,
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

  Form_Cid(context) {
    return SizedBox(
        child: Column(children: [
      for (var cid in data_cid)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 50,
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
                      '${cid["title"]}*',
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
                  child: InkWell(
                    onTap: (activeStep != 0)
                        ? null
                        : (cid['ser'].toString() == '3' ||
                                cid['ser'].toString() == '4')
                            ? null
                            : () async {
                                DateTime? newDate = await showDatePicker(
                                  // locale: const Locale('th', 'TH'),
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now()
                                      .add(const Duration(days: -100)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 400)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: AppBarColors
                                              .ABar_Colors, // header background color
                                          onPrimary:
                                              Colors.white, // header text color
                                          onSurface:
                                              Colors.black, // body text color
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            primary: Colors
                                                .black, // button text color
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                // Dialog_error(context,
                                //     'กรุณาเลือกวันที่สิ้นสุดให้มากกว่า 1 ปี');

                                if (newDate == null) {
                                  return;
                                } else {
                                  final index = data_cid.indexWhere(
                                    (element) => element['ser'] == cid['ser'],
                                  );

                                  if (cid['ser'].toString() == '1') {
                                    // เลือกวันที่เริ่มต้น
                                    setState(() {
                                      data_cid[index]["detail"] =
                                          DateFormat('yyyy-MM-dd')
                                              .format(newDate);
                                    });
                                  } else if (cid['ser'].toString() == '2') {
                                    // เลือกวันที่สิ้นสุด
                                    final startDateStr =
                                        data_cid[index - 1]["detail"];

                                    if (startDateStr != null &&
                                        startDateStr.toString().isNotEmpty) {
                                      final startDate =
                                          DateTime.parse(startDateStr);
                                      final endDate = newDate;

                                      final difference =
                                          endDate.difference(startDate).inDays;
                                      //  print(difference);
                                      if (difference < 365) {
                                        Dialog_error(context,
                                            'กรุณาเลือกวันที่สิ้นสุดให้มากกว่า 1 ปี');
                                        return;
                                      } else {
                                        setState(() {
                                          data_cid[index]['detail'] =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(newDate);
                                        });
                                      }
                                    } else {
                                      Dialog_error(context,
                                          'กรุณาเลือกวันที่เริ่มต้นก่อน');
                                    }
                                  }
                                }
                              },
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.green,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: AutoSizeText(
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        (cid["ser"].toString() == '3' ||
                                cid["ser"].toString() == '4')
                            ? '${cid["detail"]}'
                            : '${formatDate('${cid["detail"]}', type: DateFormatType.dmy)}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    ]));
  }

  Doc_Data(context) {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        return '${DateFormat('dd-MM').format(date)}-${date.year}';
      } catch (e) {
        // print('❌ Invalid date format: $dateStr');
        return '';
      }
    }

    String getDisplayText(doc, Map<String, dynamic> titleDoc) {
      String displayText = '';

      switch (titleDoc["ser"].toString()) {
        case '1':
          displayText = (doc.required == false)
              ? doc.nameTh ?? ''
              : doc.nameTh + ' (*)' ?? '';
          break;

        case '2':
          if (doc.attachments != null && doc.attachments!.isNotEmpty) {
            displayText = formatDate(doc.attachments!.first.uploadedAt);
          }
          break;

        case '3':
          displayText = doc.uuid ?? '';
          break;

        case '4':
          if (doc.attachments != null && doc.attachments!.isNotEmpty) {
            displayText = doc.attachments!.first.status_label ?? '';
          }
          break;

        default:
          if (doc.attachments != null && doc.attachments!.isNotEmpty) {
            displayText = formatDate(doc.attachments!.first.reviewAt);
          }
          break;
      }

      return displayText; // ✅ อย่าลืม return
    }

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
                    'เอกสารแนบ',
                    // 'เอกสารแนบ (${documentModels.length}เอกสาร)',
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
                          flex: title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_doc["title"]}',
                              textAlign: (title_doc["title"] == 'ชื่อเอกสาร')
                                  ? TextAlign.left
                                  : TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                      (widget.status_uuid.toString() == 'ขอปรับปรุง' ||
                              widget.status_uuid.toString() == 'รอแก้ไข' &&
                                  documentModels.first.attachments!.isNotEmpty)
                          ? const SizedBox(
                              width: 110,
                            )
                          : Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.blue),
                                  onPressed: () => Loading_Data_Step2(),
                                  tooltip: 'รีเฟรชข้อมูล',
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 140,
                                  child: Column(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.library_add,
                                          size: 15,
                                        ),
                                        label: const Text(
                                          'อัปหลายรายการ',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                        onPressed: () => _showBatchUploadSheet(
                                            context, documentModels),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blueGrey.shade800),
                                      ),
                                      const SizedBox(height: 3),
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.qr_code_scanner,
                                          size: 15,
                                        ),
                                        label: const Text(
                                          'อัปแบบโทรศัพท์',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                        onPressed: () => _showQRUploadDialog(
                                            context, uuid_Request.toString()),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blueGrey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ]),
                  ),
                ],
              ),
            ),
            (isLoading || documentModels.isEmpty)
                ? SizedBox(height: 100, child: Widget_Loading(context))
                : Container(
                    // color: Colors.brown[200],
                    child: Column(
                      children: documentModels.asMap().entries.map((row) {
                        final i = row.key; // row index (0-based)
                        final doc = row.value;
                        // bool _needsUpdateForDoc(DocumentModel doc) {
                        //   if (doc.attachments != null &&
                        //       doc.attachments!.isNotEmpty) {
                        //     if (doc.attachments!.first.status.toString() ==
                        //         'needs_update') {
                        //       return true;
                        //     } else {
                        //       return false;
                        //     }
                        //   }
                        //   return false;
                        // }

                        // helper แนบไฟล์
                        // final hasFile = (doc.attachments != null &&
                        //     doc.attachments!.isNotEmpty);
                        // มีไฟล์แนบไหม
                        final hasFile = (doc.attachments != null &&
                            doc.attachments!.isNotEmpty);

                        // ใช้ helper เช็คว่าต้องให้อัปโหลดเมื่อสถานะ "ขอปรับปรุง/รอแก้ไข" ไหม
                        // final needsUpdate = _needsUpdateForDoc(doc);

                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            children: [
                              // วนคอลัมน์ตาม data_title_doc
                              ...data_title_doc.map<Widget>((titleDoc) {
                                final title =
                                    (titleDoc["title"] ?? '').toString();
                                final isNameCol = title == 'ชื่อเอกสาร';
                                final isFileCol = title == 'ไฟล์เอกสาร';
                                final flex = isNameCol ? 2 : 1;

                                if (isFileCol) {
                                  return Expanded(
                                    flex: flex,
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: hasFile
                                              ? Colors.lime.shade800
                                              : Colors.grey.withOpacity(0.5),
                                        ),
                                        onPressed: hasFile
                                            ? () async {
                                                final matched =
                                                    findAttachmentByDocId(
                                                  doc.attachments ?? [],
                                                  doc.id,
                                                );
                                                final fileUuid =
                                                    matched?.uuid ?? '';
                                                final filePath =
                                                    matched?.filePath ?? '';
                                                final fileType =
                                                    matched?.fileType ?? '';
                                                final requestUuid =
                                                    matched?.requestUuid ?? '';

                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        PreviewPdf_ordit_CMM(
                                                      id: doc.id.toString(),
                                                      uuid: fileUuid,
                                                      Request_Uuid: requestUuid,
                                                      code: doc.code.toString(),
                                                      file_path: filePath,
                                                      file_type: fileType,
                                                      title: doc.nameTh ?? '',
                                                      file_typeOpen: 'UPFile',
                                                      uploaded_At: doc.updatedAt
                                                          .toString(),
                                                      data_title_doc:
                                                          data_title_doc,
                                                      docs: documentModels,
                                                      payment: [],
                                                      viewver: true,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Translate
                                            .TranslateAndSet_TextAutoSize(
                                          'เรียกดู',
                                          CustomerScreen_Color.Colors_Text3_,
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

                                // คอลัมน์ข้อความทั่วไป
                                final rawText = getDisplayText(doc, titleDoc);
                                final displayText =
                                    isNameCol ? '${i + 1}. $rawText' : rawText;

                                return Expanded(
                                  flex: flex,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: AutoSizeText(
                                      displayText, // ✅ ข้อความมาก่อน
                                      minFontSize: 12,
                                      maxFontSize: 16,
                                      maxLines: 1,
                                      textAlign: isNameCol
                                          ? TextAlign.left
                                          : TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),

                              // ปุ่มอัปโหลดท้ายแถว
                              SizedBox(
                                width: 110,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: InkWell(
                                        onTap: (getDisplayText(doc, {
                                                  "ser": "4",
                                                  "title": "สถานะ",
                                                  "data": "status"
                                                }) ==
                                                'ขอปรับปรุง')
                                            ? () async {
                                                final ok = await _handleUpload(
                                                  uuid_Request.toString(),
                                                  doc.id,
                                                  useCamera: false,
                                                );
                                                // TODO: ถ้าอยาก refresh state ใส่ setState ตรงนี้ได้
                                              }
                                            : (hasFile)
                                                ? null
                                                : () async {
                                                    final ok =
                                                        await _handleUpload(
                                                      uuid_Request.toString(),
                                                      doc.id,
                                                      useCamera: false,
                                                    );
                                                    // TODO: ถ้าอยาก refresh state ใส่ setState ตรงนี้ได้
                                                  },
                                        child: Tooltip(
                                          message: 'อัปโหลดเอกสาร',
                                          child: Icon(
                                            Icons.upload_file,
                                            color: (getDisplayText(doc, {
                                                      "ser": "4",
                                                      "title": "สถานะ",
                                                      "data": "status"
                                                    }) ==
                                                    'ขอปรับปรุง')
                                                ? Colors.blue
                                                : (hasFile)
                                                    ? Colors.grey
                                                        .withOpacity(0.5)
                                                    : Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (hasFile)
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final matched =
                                                findAttachmentByDocId(
                                              doc.attachments ?? [],
                                              doc.id,
                                            );
                                            final attachmentUuid =
                                                matched?.uuid?.toString() ??
                                                    doc.attachments!.first.uuid
                                                        ?.toString() ??
                                                    '';
                                            if (attachmentUuid.isEmpty) {
                                              _toast(
                                                  'à¹„à¸¡à¹ˆà¸žà¸šà¸£à¸«à¸±à¸ªà¹„à¸Ÿà¸¥à¹Œ à¸à¸£à¸¸à¸“à¸²à¸¥à¸­à¸‡à¸£à¸µà¹€à¸Ÿà¸£à¸Š');
                                              return;
                                            }

                                            final ok =
                                                await Deletelfile_Document(
                                              uuid_Request.toString(),
                                              attachmentUuid,
                                            );
                                            if (ok) {
                                              setState(() {
                                                doc.attachments = [];
                                              });
                                              Loading_Data_Step2();
                                            } else {
                                              _toast(
                                                  'à¸¥à¸šà¹„à¸Ÿà¸¥à¹Œà¹„à¸¡à¹ˆà¸ªà¸³à¹€à¸£à¹‡à¸ˆ à¸à¸£à¸¸à¸“à¸²à¸¥à¸­à¸‡à¸­à¸µà¸à¸„à¸£à¸±à¹‰à¸‡');
                                            }
                                            if (mounted) return;
                                            final status = getDisplayText(doc, {
                                              "ser": "4",
                                              "title": "สถานะ",
                                              "data": "status"
                                            });
                                            if (status == 'ขอปรับปรุง' ||
                                                status == 'รอตรวจสอบ') {
                                              Deletelfile_Document(
                                                uuid_Request.toString(),
                                                doc.attachments!.first.uuid,
                                              ).then((ok) {
                                                if (ok) {
                                                  Loading_Data_Step2();
                                                } else {
                                                  _toast(
                                                      'ลบไฟล์ไม่สำเร็จ กรุณาลองอีกครั้ง');
                                                }
                                              });
                                            }
                                          },
                                          child: Tooltip(
                                            message: 'ลบไฟล์',
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: () {
                                                final status = getDisplayText(
                                                    doc, {
                                                  "ser": "4",
                                                  "title": "สถานะ",
                                                  "data": "status"
                                                });
                                                return (status ==
                                                            'ขอปรับปรุง' ||
                                                        status == 'รอตรวจสอบ')
                                                    ? Colors.red
                                                    : (hasFile)
                                                        ? Colors.red
                                                        : Colors.grey
                                                            .withOpacity(0.5);
                                              }(),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
//             SizedBox(
//               child: Column(children: [
//                 for (var doc in documentModels)
//                   Row(children: [
//                     for (var title_doc in data_title_doc)
//                       Expanded(
//                         flex: title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
//                         child: Padding(
//                           padding: const EdgeInsets.all(2.0),
//                           child: ('${title_doc["title"]}' == 'ไฟล์เอกสาร')
//                               ? Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 100,
//                                       child:
// ElevatedButton(
//                                         style: ButtonStyle(
//                                           backgroundColor:
//                                               MaterialStateProperty.all<Color>(
//                                             (doc.attachments != null &&
//                                                     doc.attachments!.isNotEmpty)
//                                                 ? Colors.lime.shade800
//                                                 : Colors.grey.withOpacity(0.5),
//                                           ),
//                                         ),
//                                         onPressed: (doc.attachments != null &&
//                                                 doc.attachments!.isNotEmpty)
//                                             ? () async {
//                                                 final matched =
//                                                     findAttachmentByDocId(
//                                                         doc.attachments ?? [],
//                                                         doc.id);
//                                                 final file_Uuid =
//                                                     matched?.uuid ?? '';
//                                                 final file_Path =
//                                                     matched?.filePath ?? '';
//                                                 final file_Type =
//                                                     matched?.fileType ?? '';
//                                                 final RequestUuid =
//                                                     matched?.requestUuid ?? '';
//                                                 // print(
//                                                 //     'doc.id : ${doc.id}');
//                                                 // print(matched);
//                                                 print('file_Uuid : $file_Uuid');
//                                                 print('file_Path : $file_Path');
//                                                 print('file_Type : $file_Type');
//                                                 Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           PreviewPdf_ordit_CMM(
//                                                         id: doc.id.toString(),
//                                                         uuid: file_Uuid
//                                                             .toString(),
//                                                         Request_Uuid:
//                                                             RequestUuid
//                                                                 .toString(),
//                                                         code:
//                                                             doc.code.toString(),
//                                                         file_path: file_Path
//                                                             .toString(),
//                                                         file_type: file_Type
//                                                             .toString(),
//                                                         title: '${doc.nameTh}',
//                                                         file_typeOpen: 'UPFile',
//                                                         uploaded_At: doc
//                                                             .updatedAt
//                                                             .toString(),
//                                                         data_title_doc:
//                                                             data_title_doc,
//                                                         docs: documentModels,
//                                                       ),
//                                                     ));
//                                                 // final matched =
//                                                 //     findAttachmentByDocId(
//                                                 //         attachments,
//                                                 //         doc.id);
//                                                 // final filePath = matched
//                                                 //         ?.filePath
//                                                 //         ?.toString() ??
//                                                 //     '';

//                                                 // if (filePath.isEmpty) {
//                                                 //   final response =
//                                                 //       await pickAndUpload(
//                                                 //           uuid_Request
//                                                 //               .toString(),
//                                                 //           doc.id);

//                                                 //   if (response.body !=
//                                                 //       null) {
//                                                 //     print(
//                                                 //         '✅ อัปโหลดสำเร็จ');
//                                                 //     print(response.body);
//                                                 //     Dialog_success(
//                                                 //         context,
//                                                 //         'อัปโหลดสำเร็จ');
//                                                 //   } else {
//                                                 //     print(
//                                                 //         '⚠️ ไม่มีไฟล์ถูกอัปโหลด ${response.body}');
//                                                 //     Dialog_error(context,
//                                                 //         'ไม่มีไฟล์ถูกอัปโหลด');
//                                                 //   }
//                                                 // } else {
//                                                 //   final matched =
//                                                 //       findAttachmentByDocId(
//                                                 //           doc.attachments ??
//                                                 //               [],
//                                                 //           doc.id);
//                                                 //   final file_Uuid =
//                                                 //       matched?.uuid ?? '';
//                                                 //   final file_Path =
//                                                 //       matched?.filePath ??
//                                                 //           '';
//                                                 //   final file_Type =
//                                                 //       matched?.fileType ??
//                                                 //           '';
//                                                 //   Navigator.push(
//                                                 //       context,
//                                                 //       MaterialPageRoute(
//                                                 //         builder: (context) => PreviewPdf_ordit_CMM(
//                                                 //             id: doc.id,
//                                                 //             uuid:
//                                                 //                 file_Uuid,
//                                                 //             code:
//                                                 //                 doc.code,
//                                                 //             file_path:
//                                                 //                 file_Path,
//                                                 //             file_type:
//                                                 //                 file_Type,
//                                                 //             title:
//                                                 //                 '${doc.nameTh}'),
//                                                 //       ));
//                                                 // }
//                                               }
//                                             : null,
//                                         child: Translate
//                                             .TranslateAndSet_TextAutoSize(
//                                                 'เรียกดู',
//                                                 CustomerScreen_Color
//                                                     .Colors_Text3_,
//                                                 TextAlign.center,
//                                                 null,
//                                                 Font_.Fonts_T,
//                                                 10,
//                                                 14,
//                                                 1),
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Container(
//                                   padding: const EdgeInsets.all(0.0),
//                                   child: AutoSizeText(
//                                     getDisplayText(doc, title_doc),
//                                     minFontSize: 12,
//                                     maxFontSize: 16,
//                                     maxLines: 1,
//                                     textAlign:
//                                         (title_doc["title"] == 'ชื่อเอกสาร')
//                                             ? TextAlign.left
//                                             : TextAlign.center,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       color: CustomerScreen_Color.Colors_Text2_,
//                                       fontFamily: Font_.Fonts_T,
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     // ... ใน widget tree เดิมของคุณ แทนที่ InkWell ด้วย PopupMenuButton
//                     SizedBox(
//                       width: 110,
//                       child: Padding(
//                         padding: const EdgeInsets.all(2.0),
//                         child: PopupMenuButton<UploadAction>(
//                           tooltip: 'อัปโหลดเอกสาร',
//                           // ถ้าอยาก “ปิดการใช้งาน” เมื่อมีไฟล์แล้ว ให้เช็คที่ onSelected ด้านล่าง หรือห่อด้วย IgnorePointer
//                           onSelected: (action) async {
//                             // ถ้ามีไฟล์อยู่แล้ว จะไม่ให้กดอัปโหลดซ้ำ (ทางเลือก)
//                             final hasAttachment = (doc.attachments != null &&
//                                 doc.attachments!.isNotEmpty);
//                             if (hasAttachment) {
//                               Dialog_error(context, 'มีไฟล์แนบแล้ว');
//                               return;
//                             }

//                             switch (action) {
//                               case UploadAction.file:
//                                 await _handleUpload(
//                                   uuid_Request.toString(),
//                                   doc.id,
//                                   useCamera: false,
//                                 );
//                                 break;

//                               case UploadAction.camera:
//                                 final ok = await ensureCameraPermission();
//                                 if (!ok) {
//                                   Dialog_error(
//                                       context, 'ไม่ได้รับสิทธิ์การใช้กล้อง');
//                                   return;
//                                 }
//                                 await _handleUpload(
//                                   uuid_Request.toString(),
//                                   doc.id,
//                                   useCamera: true,
//                                 );
//                                 break;
//                             }
//                           },
//                           itemBuilder: (ctx) => [
//                             const PopupMenuItem(
//                               value: UploadAction.file,
//                               child: ListTile(
//                                 leading: Icon(Icons.insert_drive_file),
//                                 title: Text('เลือกไฟล์จากเครื่อง'),
//                                 contentPadding: EdgeInsets.zero,
//                                 dense: true,
//                               ),
//                             ),
//                             const PopupMenuItem(
//                               value: UploadAction.camera,
//                               child: ListTile(
//                                 leading: Icon(Icons.camera_alt),
//                                 title: Text('ถ่ายรูปด้วยกล้อง'),
//                                 contentPadding: EdgeInsets.zero,
//                                 dense: true,
//                               ),
//                             ),
//                           ],
//                           child: Icon(
//                             Icons.upload_file,
//                             color: (doc.attachments != null &&
//                                     doc.attachments!.isNotEmpty)
//                                 ? Colors.grey.withOpacity(0.5)
//                                 : Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ),

// //                           Padding(
// //                               padding: const EdgeInsets.all(2.0),
// //                               child: InkWell(
// //                                 onTap: () async {
// //                                   showModalBottomSheet(
// //                                     context: context,
// //                                     shape: const RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.vertical(
// //                                           top: Radius.circular(16)),
// //                                     ),
// //                                     builder: (BuildContext ctx) {
// //                                       return SafeArea(
// //                                         child: Column(
// //                                           mainAxisSize: MainAxisSize.min,
// //                                           children: [
// //                                             ListTile(
// //                                               leading: const Icon(
// //                                                   Icons.insert_drive_file),
// //                                               title: const Text(
// //                                                   'เลือกไฟล์จากเครื่อง'),
// //                                               onTap: () async {
// //                                                 Navigator.pop(
// //                                                     ctx); // ปิด bottom sheet
// //                                                 await _handleUpload(
// //                                                     uuid_Request.toString(),
// //                                                     doc.id,
// //                                                     useCamera: false);
// //                                               },
// //                                             ),
// //                                             ListTile(
// //                                                 leading: const Icon(
// //                                                     Icons.camera_alt),
// //                                                 title: const Text(
// //                                                     'ถ่ายรูปด้วยกล้อง'),
// //                                                 onTap: () async {
// //                                                   try {
// //                                                     // ขอกล้องก่อน (web จะคืน true อยู่แล้ว)
// //                                                     final ok =
// //                                                         await ensureCameraPermission();
// //                                                     if (!ok) {
// //                                                       Dialog_error(context,
// //                                                           'ไม่ได้รับสิทธิ์การใช้กล้อง');
// //                                                       return;
// //                                                     }

// //                                                     // ปิด bottom sheet ก่อนเริ่มอัปโหลด (ใช้ ctx ของ bottom sheet)
// //                                                     Navigator.pop(ctx);

// //                                                     // อัปโหลดจากกล้องเพียงครั้งเดียว ผ่าน _handleUpload
// //                                                     await _handleUpload(
// //                                                       uuid_Request.toString(),
// //                                                       doc.id,
// //                                                       useCamera: true,
// //                                                     );
// //                                                   } finally {
// //                                                     // _uploading = false;
// //                                                   }
// //                                                 }),
// //                                           ],
// //                                         ),
// //                                       );
// //                                     },
// //                                   );
// //                                 },

// // //                                 onTap: () async {

// // //                                   final matched = findAttachmentByDocId(
// // //                                       attachments, doc.id);
// // //                                   int filePath = matched?.id ?? 0;

// // //                                   final response = await pickAndUpload(
// // //                                       uuid_Request.toString(), doc.id);

// // //                                   if (response.statusCode == 200 ||
// // //                                       response.statusCode == 201) {
// // //                                     final Map<String, dynamic> result =
// // //                                         json.decode(response.body);
// // //                                     final data = result['data'];
// // //                                     final updatedAttachment =
// // //                                         AttachmentsModel.fromJson(data);

// // //                                     setState(() {
// // //                                       final index = documentModels.indexWhere(
// // //                                         (element) =>
// // //                                             element.id ==
// // //                                             data['client_document_id'],
// // //                                       );

// // //                                       if (index != -1) {
// // //                                         final old = documentModels[
// // //                                             index]; // ลบของเก่า (โดยการ assign ใหม่)
// // //                                         documentModels[index].attachments = [];

// // // // เพิ่มใหม่
// // //                                         documentModels[index]
// // //                                             .attachments!
// // //                                             .add(updatedAttachment);
// // //                                       }
// // //                                       print(
// // //                                           '📌 attachments ใหม่: ${documentModels[index].attachments!.first.filePath}');
// // //                                     });
// // //                                     Dialog_success(context, 'อัปโหลดสำเร็จ');
// // //                                   } else {
// // //                                     print(
// // //                                         '❌ การอัปโหลดล้มเหลว: ${response.statusCode}');
// // //                                     Dialog_error(
// // //                                         context, 'ไม่มีไฟล์ถูกอัปโหลด');
// // //                                   }
// // //                                 },
// //                                 child: Icon(
// //                                   Icons.upload_file,
// //                                   color: (doc.attachments != null &&
// //                                           doc.attachments!.isNotEmpty)
// //                                       ? Colors.grey.withOpacity(0.5)
// //                                       : Colors.blue,
// //                                 ),
// //                               )

// //                               )
//                   ])
//               ]),
//             ),
          ],
        ),
      ),
      // SizedBox(
      //   height: 40,
      // ),
      // SizedBox(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       Container(
      //         decoration: BoxDecoration(
      //           color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
      //           borderRadius: BorderRadius.only(
      //               topLeft: Radius.circular(10),
      //               topRight: Radius.circular(15),
      //               bottomLeft: Radius.circular(0),
      //               bottomRight: Radius.circular(0)),
      //           // border: Border.all(color: Colors.grey, width: 1),
      //         ),
      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      //         // padding:
      //         //     const EdgeInsets.symmetric(
      //         //         vertical: 5,
      //         //         horizontal: 16),
      //         child: Column(
      //           children: [
      //             AutoSizeText(
      //               minFontSize: 12,
      //               maxFontSize: 16,
      //               maxLines: 1,
      //               'รายการชำระ( ${attachments.length})',
      //               textAlign: TextAlign.center,
      //               overflow: TextOverflow.ellipsis,
      //               style: TextStyle(
      //                   color: PeopleChaoScreen_Color.Colors_Text2_,
      //                   fontFamily: Font_.Fonts_T),
      //             ),
      //             Container(
      //               color: Colors.brown[200],
      //               child: Row(children: [
      //                 for (var title_receipt in data_title_receipt)
      //                   Expanded(
      //                     flex: '${title_receipt["title"]}' == 'สถานะ' ? 2 : 1,
      //                     child: Container(
      //                       padding: const EdgeInsets.all(2.0),
      //                       child: AutoSizeText(
      //                         minFontSize: 12,
      //                         maxFontSize: 16,
      //                         maxLines: 1,
      //                         '${title_receipt["title"]}',
      //                         textAlign: TextAlign.left,
      //                         overflow: TextOverflow.ellipsis,
      //                         style: TextStyle(
      //                             color: PeopleChaoScreen_Color.Colors_Text2_,
      //                             fontFamily: Font_.Fonts_T),
      //                       ),
      //                     ),
      //                   ),
      //               ]),
      //             ),
      //           ],
      //         ),
      //       ),
      //       (isLoading || attachments.isEmpty)
      //           ? Widget_Loading(context)
      //           : SizedBox(
      //               child: Column(children: [
      //                 for (var receipt in attachments)
      //                   Row(children: [
      //                     for (var title_receipt in data_title_receipt)
      //                       Expanded(
      //                         flex: '${title_receipt["title"]}' == 'สถานะ'
      //                             ? 2
      //                             : 1,
      //                         child: Container(
      //                           padding: const EdgeInsets.all(2.0),
      //                           child: AutoSizeText(
      //                             minFontSize: 12,
      //                             maxFontSize: 16,
      //                             maxLines: 1,
      //                             //  '-',
      //                             ('${title_receipt["ser"]}' == '1')
      //                                 ? '${receipt.id}'
      //                                 : ('${title_receipt["ser"]}' == '2')
      //                                     ? (receipt.createdAt == null)
      //                                         ? ''
      //                                         : DateFormat('dd-MM')
      //                                                 .format(DateTime.parse(
      //                                                     receipt.createdAt))
      //                                                 .toString() +
      //                                             '-${DateTime.parse(receipt.createdAt).year}'
      //                                     : ('${title_receipt["ser"]}' == '3')
      //                                         ? '${receipt.uuid}'
      //                                         : '${receipt.active}',
      //                             textAlign: TextAlign.left,
      //                             overflow: TextOverflow.ellipsis,
      //                             style: TextStyle(
      //                                 color:
      //                                     PeopleChaoScreen_Color.Colors_Text2_,
      //                                 fontFamily: Font_.Fonts_T),
      //                           ),
      //                         ),
      //                       ),
      //                   ]),
      //               ]),
      //             ),
      //       Padding(
      //         padding: const EdgeInsets.all(0.0),
      //         child: Row(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Icon(
      //                 Icons.info,
      //                 size: 18,
      //               ),
      //             ),
      //             Expanded(
      //               child: AutoSizeText(
      //                 minFontSize: 12,
      //                 maxFontSize: 16,
      //                 maxLines: 1,
      //                 'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
      //                 textAlign: TextAlign.left,
      //                 overflow: TextOverflow.ellipsis,
      //                 style: TextStyle(
      //                     color: PeopleChaoScreen_Color.Colors_Text2_,
      //                     fontFamily: Font_.Fonts_T),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
                // controller: ,
                initialValue: '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ใส่ข้อมูลให้ครบถ้วน';
                  }
                  // if (int.parse(value.toString()) < 13) {
                  //   return '< 13';
                  // }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    Formbecause_.text = value.toString();
                  });
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

  Header_Stepper(context) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Center(
            child: Text(headerText(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 25,
                  color: PeopleChaoScreen_Color.Colors_Text1_,
                  // fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          IconStepper(
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            icons: const [
              Icon(Icons.filter_1),
              Icon(Icons.filter_2),
              Icon(Icons.filter_3),
              Icon(Icons.filter_4),
              // Icon(Icons.filter_5),
            ],

            // activeStep property set to activeStep variable defined above.
            activeStep: activeStep,

            // This ensures step-tapping updates the activeStep.
            onStepReached: (index) {
              setState(() {
                activeStep = index;
              });
            },
          ),
          if (activeStep == 0)
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  // width: MediaQuery.of(context).size.width,
                  width: (Responsive.isDesktop(context))
                      ? MediaQuery.of(context).size.width * 0.85
                      : MediaQuery.of(context).size.width + 100,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              'โซน : ',
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                            Container(
                              width: 200,
                              height: 35,
                              decoration: const BoxDecoration(
                                // color: Colors.green,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                                // border: Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(2.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                showCursor: !read_Only, //add this line
                                readOnly: read_Only,
                                controller: Form_zone_name,
                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                    fillColor: Colors.white.withOpacity(0.3),
                                    filled: true,
                                    // prefixIcon:
                                    //     const Icon(Icons.person, color: Colors.black),
                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(6),
                                        topLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(6),
                                        topLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    labelStyle: const TextStyle(
                                        color: Colors.black54,

                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T
                                        //fontSize: 10.0
                                        )),
                              ),
                            ),
                            const AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              'รหัสพื้นที่ ',
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text1_,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T),
                            ),
                            Container(
                              width: 200,
                              height: 35,
                              decoration: const BoxDecoration(
                                // color: Colors.green,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                                // border: Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(2.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                showCursor: !read_Only, //add this line
                                readOnly: read_Only,
                                controller: Form_ln_name,
                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                    fillColor: Colors.white.withOpacity(0.3),
                                    filled: true,
                                    // prefixIcon:
                                    //     const Icon(Icons.person, color: Colors.black),
                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(6),
                                        topLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(6),
                                        topLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    labelStyle: const TextStyle(
                                        color: Colors.black54,

                                        // fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T
                                        //fontSize: 10.0
                                        )),
                              ),
                            ),
                            // InkWell(
                            //   child: Container(
                            //     width: 100,
                            //     decoration: BoxDecoration(
                            //       color: AppbackgroundColor.TiTile_Colors,
                            //       borderRadius: const BorderRadius.only(
                            //           topLeft: Radius.circular(10),
                            //           topRight: Radius.circular(10),
                            //           bottomLeft: Radius.circular(10),
                            //           bottomRight: Radius.circular(10)),
                            //       border: Border.all(color: Colors.black, width: 1),
                            //     ),
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: AutoSizeText(
                            //       minFontSize: 10,
                            //       maxFontSize: 15,
                            //       maxLines: 3,
                            //       _selecteSer.length == 0
                            //           ? 'เลือก'
                            //           : '${_selecteSerbool.map((e) => e).toString().substring(1, _selecteSerbool.map((e) => e).toString().length - 1)}',
                            //       style: const TextStyle(
                            //           color: PeopleChaoScreen_Color.Colors_Text1_,
                            //           fontWeight: FontWeight.bold,
                            //           fontFamily: FontWeight_.Fonts_T),
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     showDialog<String>(
                            //       barrierDismissible: false,
                            //       context: context,
                            //       builder: (BuildContext context) => AlertDialog(
                            //         shape: const RoundedRectangleBorder(
                            //             borderRadius:
                            //                 BorderRadius.all(Radius.circular(20.0))),
                            //         title: const Center(
                            //             child: Text(
                            //           'เลือกพื้นที่',
                            //           style: TextStyle(
                            //               color: PeopleChaoScreen_Color.Colors_Text1_,
                            //               fontWeight: FontWeight.bold,
                            //               fontFamily: FontWeight_.Fonts_T),
                            //         )),
                            //         content: SingleChildScrollView(
                            //           child: ListBody(
                            //             children: <Widget>[
                            //               StreamBuilder(
                            //                   stream: Stream.periodic(
                            //                       const Duration(seconds: 0)),
                            //                   builder: (context, snapshot) {
                            //                     return CheckboxGroup(
                            //                         checked: _selecteSerbool,
                            //                         activeColor: Colors.red,
                            //                         checkColor: Colors.white,
                            //                         labels: <String>[
                            //                           for (var i = 0;
                            //                               i < areaModels.length;
                            //                               i++)
                            //                             '${areaModels[i].lncode}',
                            //                         ],
                            //                         labelStyle: const TextStyle(
                            //                           color: PeopleChaoScreen_Color
                            //                               .Colors_Text2_,
                            //                           // fontWeight: FontWeight.bold,
                            //                           fontFamily: Font_.Fonts_T,
                            //                         ),
                            //                         onChange:
                            //                             (isChecked, label, index) {
                            //                           if (isChecked == false) {
                            //                             _selecteSer.remove(
                            //                                 areaModels[index].ser);

                            //                             double areax = double.parse(
                            //                                 areaModels[index].area!);
                            //                             double rentx = double.parse(
                            //                                 areaModels[index].rent!);
                            //                             _area_sum = _area_sum - areax;
                            //                             _area_rent_sum =
                            //                                 _area_rent_sum - rentx;

                            //                             if (isChecked == true) {
                            //                               setState(() {
                            //                                 _area_sum =
                            //                                     _area_sum + areax;
                            //                                 _area_rent_sum =
                            //                                     _area_rent_sum +
                            //                                         rentx;
                            //                                 _selecteSer.add(
                            //                                     areaModels[index]
                            //                                         .ser);
                            //                               });
                            //                             }
                            //                           } else {
                            //                             double areax = double.parse(
                            //                                 areaModels[index].area!);
                            //                             double rentx = double.parse(
                            //                                 areaModels[index].rent!);
                            //                             if (isChecked == true) {
                            //                               setState(() {
                            //                                 _area_sum =
                            //                                     _area_sum + areax;
                            //                                 _area_rent_sum =
                            //                                     _area_rent_sum +
                            //                                         rentx;
                            //                                 _selecteSer.add(
                            //                                     areaModels[index]
                            //                                         .ser);
                            //                               });
                            //                             }
                            //                           }
                            //                           print(
                            //                               'เลือกพื้นที่ :  ${_selecteSer.map((e) => e)}  : _area_sum = $_area_sum _area_rent_sum = $_area_rent_sum ');
                            //                         },
                            //                         onSelected:
                            //                             (List<String> selected) {
                            //                           setState(() {
                            //                             _selecteSerbool = selected;
                            //                           });
                            //                           print(
                            //                               'SerGetBankModels_ : ${_selecteSerbool}');
                            //                         });
                            //                   })
                            //             ],
                            //           ),
                            //         ),
                            //         actions: <Widget>[
                            //           Padding(
                            //             padding: const EdgeInsets.all(8.0),
                            //             child: Row(
                            //               mainAxisAlignment: MainAxisAlignment.end,
                            //               children: [
                            //                 Padding(
                            //                   padding: const EdgeInsets.all(8.0),
                            //                   child: Row(
                            //                     mainAxisAlignment:
                            //                         MainAxisAlignment.center,
                            //                     children: [
                            //                       Container(
                            //                         width: 100,
                            //                         decoration: const BoxDecoration(
                            //                           color: Colors.green,
                            //                           borderRadius: BorderRadius.only(
                            //                               topLeft:
                            //                                   Radius.circular(10),
                            //                               topRight:
                            //                                   Radius.circular(10),
                            //                               bottomLeft:
                            //                                   Radius.circular(10),
                            //                               bottomRight:
                            //                                   Radius.circular(10)),
                            //                         ),
                            //                         padding:
                            //                             const EdgeInsets.all(8.0),
                            //                         child: TextButton(
                            //                           onPressed: () {
                            //                             setState(() {
                            //                               // read_GC_areaSelectSer();
                            //                             });
                            //                             Navigator.pop(context, 'OK');
                            //                           },
                            //                           child: const Text(
                            //                             'บันทึก',
                            //                             style: TextStyle(
                            //                               color: Colors.white,
                            //                               fontWeight: FontWeight.bold,
                            //                               fontFamily:
                            //                                   FontWeight_.Fonts_T,
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ],
                            //                   ),
                            //                 ),
                            //                 Container(
                            //                   width: 100,
                            //                   decoration: const BoxDecoration(
                            //                     color: Colors.black,
                            //                     borderRadius: BorderRadius.only(
                            //                         topLeft: Radius.circular(10),
                            //                         topRight: Radius.circular(10),
                            //                         bottomLeft: Radius.circular(10),
                            //                         bottomRight: Radius.circular(10)),
                            //                   ),
                            //                   padding: const EdgeInsets.all(8.0),
                            //                   child: TextButton(
                            //                     onPressed: () {
                            //                       Navigator.pop(context);
                            //                       setState(() {
                            //                         cQuotModels.clear();
                            //                         _selecteSer.clear();
                            //                         _selecteSerbool.clear();
                            //                       });
                            //                     },
                            //                     child: const Text(
                            //                       'ยกเลิก',
                            //                       style: TextStyle(
                            //                         color: Colors.white,
                            //                         fontWeight: FontWeight.bold,
                            //                         fontFamily: FontWeight_.Fonts_T,
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     );
                            //   },
                            // ),
                            // if (Responsive.isDesktop(context))
                            //   Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: InkWell(
                            //       onTap: () {
                            //         Set_data('d87fec79-6020-449f-8b8b-724e4d6a0d4c',
                            //             OutputType.client);
                            //         // Dia_log1(context);
                            //         // Timer(Duration(milliseconds: 300), () {
                            //         //   Dialog_Customer(context);
                            //         // });
                            //         // Dia_log3(context);
                            //         // select_customer().then((value) {
                            //         //   Navigator.of(context).pop();
                            //         //   Timer(Duration(milliseconds: 150), () {
                            //         //     Dialog_Customer(context);
                            //         //   });
                            //         // });
                            //       },
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //           color: Colors.grey,
                            //           borderRadius: const BorderRadius.only(
                            //             topLeft: Radius.circular(10),
                            //             topRight: Radius.circular(10),
                            //             bottomLeft: Radius.circular(10),
                            //             bottomRight: Radius.circular(10),
                            //           ),
                            //           border:
                            //               Border.all(color: Colors.black, width: 1),
                            //         ),
                            //         padding: const EdgeInsets.all(8.0),
                            //         child: const Text(
                            //           'ค้นจากใบเสนอราคา',
                            //           maxLines: 5,
                            //           textAlign: TextAlign.center,
                            //           style: TextStyle(
                            //             color: Colors.white,
                            //             // PeopleChaoScreen_Color
                            //             //     .Colors_Text1_
                            //             // fontWeight: FontWeight.bold,
                            //             fontFamily: FontWeight_.Fonts_T,
                            //             fontWeight: FontWeight.bold,
                            //             //fontSize: 10.0
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      ),
                      (Responsive.isDesktop(context))
                          ? const Spacer()
                          : SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            (widget.Get_ReContact == 'YES')
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        Dia_log1(context);
                                        Timer(Duration(milliseconds: 300), () {
                                          Dialog_Customer(context);
                                        });
                                        // Dia_log3(context);
                                        // select_customer().then((value) {
                                        //   Navigator.of(context).pop();
                                        //   Timer(Duration(milliseconds: 150), () {
                                        //     Dialog_Customer(context);
                                        //   });
                                        // });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          border: Border.all(
                                              color: Colors.black, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'ค้นจากทะเบียน',
                                          maxLines: 5,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            // PeopleChaoScreen_Color
                                            //     .Colors_Text1_
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            fontWeight: FontWeight.bold,
                                            //fontSize: 10.0
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: InkWell(
                            //     onTap: () {
                            //       // red_card().then((value) {
                            //       //   if (read_card != null) {
                            //       //     ScaffoldMessenger.of(context)
                            //       //         .showSnackBar(
                            //       //       SnackBar(
                            //       //           content: Text('$read_card',
                            //       //               style: TextStyle(
                            //       //                   color: Colors.white,
                            //       //                   fontFamily:
                            //       //                       Font_.Fonts_T))),
                            //       //     );
                            //       //   }
                            //       // });
                            //     },
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: Colors.grey,
                            //         borderRadius: const BorderRadius.only(
                            //           topLeft: Radius.circular(10),
                            //           topRight: Radius.circular(10),
                            //           bottomLeft: Radius.circular(10),
                            //           bottomRight: Radius.circular(10),
                            //         ),
                            //         border: Border.all(color: Colors.black, width: 1),
                            //       ),
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: const Text(
                            //         'ค้นจากบัตรประชาชน',
                            //         maxLines: 5,
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(
                            //           color: PeopleChaoScreen_Color.Colors_Text1_,
                            //           // fontWeight: FontWeight.bold,
                            //           fontFamily: FontWeight_.Fonts_T,
                            //           fontWeight: FontWeight.bold,
                            //           //fontSize: 10.0
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // ช่องค้นหา
          Container(
              width: MediaQuery.of(context).size.width,
              // height: 50,
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Box,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              // padding: const EdgeInsets.all(5.0),
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Translate.TranslateAndSetText(
                        (activeStep == 0)
                            ? 'ข้อมูลผู้เช่า '
                            : (activeStep == 1)
                                ? 'ข้อมูลสำหรับทำสัญญา'
                                : (activeStep == 2)
                                    ? 'รายละเอียดค่าบริการ'
                                    : 'ชำระค่าบริการ',
                        ChaoAreaScreen_Color.Colors_Text1_,
                        TextAlign.left,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        2),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Translate.TranslateAndSetText(
                        (activeStep == 0)
                            ? 'ข้อมูลร้านค้า '
                            : (activeStep == 1)
                                ? 'รายละเอียดเอกสารสำหรับทำสัญญา'
                                : (activeStep == 2)
                                    ? ''
                                    : '',
                        // (activeStep == 0)
                        //     ? 'ข้อมูลร้านค้า '
                        //     : (activeStep == 0)
                        //         ? 'รายละเอียดเอกสารสำหรับทำสัญญา'
                        //         : 'ชำระค่าบริการ ',
                        ChaoAreaScreen_Color.Colors_Text1_,
                        TextAlign.left,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        2),
                  ),
                ),
              ])),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void openSignatureDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Signature",
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.3),
          body: SafeArea(
            child: Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    /// 🔹 Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ลายเซ็น',
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 Signature Pad (Responsive)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Center(
                            child: ReusableSignaturePad(
                              height: constraints.maxHeight * 0.9,
                              width: constraints.maxWidth * 0.95,
                              signatureKey: signatureKey2,
                              onUp: () async {
                                final matched = finddocumentByDocCode(
                                    documentModels, 'users_signature');

                                int filePath = matched?.id ?? 0;

                                final response = await handleSave(
                                  uuid_Request.toString(),
                                  filePath,
                                  signatureKey2,
                                  SignatureActionType.upload_user,
                                );

                                final result = json.decode(response.body);

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  final data = result['data'];

                                  final updatedAttachment =
                                      AttachmentsModel.fromJson(data);

                                  setState(() {
                                    final index = documentModels.indexWhere(
                                      (element) =>
                                          element.id ==
                                          data['client_document_id'],
                                    );

                                    if (index != -1) {
                                      documentModels[index].attachments = [];
                                      documentModels[index]
                                          .attachments!
                                          .add(updatedAttachment);
                                    }
                                  });

                                  Navigator.pop(context);
                                  Dialog_success(context, 'อัปโหลดสำเร็จ');
                                } else {
                                  Dialog_error(context, 'ไม่มีไฟล์ถูกอัปโหลด');
                                }
                              },
                              onSave: () async {
                                handleSave(
                                  uuid_Request.toString(),
                                  0,
                                  signatureKey2,
                                  SignatureActionType.saveToFile,
                                );
                              },
                              onClear: () =>
                                  signatureKey2.currentState?.clear(),
                            ),
                          );
                        },
                      ),
                    ),

                    /// 🔹 Bottom Buttons
                    // Container(
                    //   padding: const EdgeInsets.all(10),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: ElevatedButton(
                    //           onPressed: () =>
                    //               signatureKey1.currentState?.clear(),
                    //           child: const Text('ล้าง'),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 10),
                    //       Expanded(
                    //         child: ElevatedButton(
                    //           onPressed: () async {
                    //             final matched = finddocumentByDocCode(
                    //                 documentModels, 'users_signature');

                    //             int filePath = matched?.id ?? 0;

                    //             await handleSave(
                    //               uuid_Request.toString(),
                    //               filePath,
                    //               signatureKey1,
                    //               SignatureActionType.upload_user,
                    //             );

                    //             Navigator.pop(context);
                    //           },
                    //           child: const Text('บันทึก'),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Stepper_2(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width < 1200)
                ? 1400
                : (Responsive.isDesktop(context))
                    ? MediaQuery.of(context).size.width * 0.85
                    : 1400,
            // height: MediaQuery.of(context).size.height + 300,
            child: Column(children: [
              Header_Stepper(context),
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
                            width: (MediaQuery.of(context).size.width < 1200)
                                ? 1400
                                : (Responsive.isDesktop(context))
                                    ? MediaQuery.of(context).size.width * 0.85
                                    : 1400,
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
                                          Row(
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: InkWell(
                                                      onTap: () async {
                                                        openSignatureDialog(
                                                            context);
                                                      },
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        child: Icon(
                                                          Icons.fullscreen,
                                                          color: Colors.white,
                                                        ),
                                                      ))),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ลายมือชื่อ*',
                                                          ChaoAreaScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.left,
                                                          null,
                                                          // FontWeight.bold,
                                                          Font_.Fonts_T,
                                                          14,
                                                          2),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ReusableSignaturePad(
                                            height: 120,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            signatureKey: signatureKey1,
                                            onUp: () async {
                                              final matched =
                                                  finddocumentByDocCode(
                                                      documentModels,
                                                      'users_signature');
                                              int filePath = matched?.id ?? 0;

                                              final response = await handleSave(
                                                  uuid_Request.toString(),
                                                  filePath,
                                                  signatureKey1,
                                                  SignatureActionType
                                                      .upload_user);
                                              final Map<String, dynamic>
                                                  result =
                                                  json.decode(response.body);
                                              print(result);
                                              if (response.statusCode == 200 ||
                                                  response.statusCode == 201) {
                                                final data = result['data'];
                                                final updatedAttachment =
                                                    AttachmentsModel.fromJson(
                                                        data);

                                                setState(() {
                                                  final index =
                                                      documentModels.indexWhere(
                                                    (element) =>
                                                        element.id ==
                                                        data[
                                                            'client_document_id'],
                                                  );

                                                  if (index != -1) {
                                                    final old = documentModels[
                                                        index]; // ลบของเก่า (โดยการ assign ใหม่)
                                                    documentModels[index]
                                                        .attachments = [];

// เพิ่มใหม่
                                                    documentModels[index]
                                                        .attachments!
                                                        .add(updatedAttachment);
                                                  }
                                                  // print(
                                                  //     '📌 attachments ใหม่: ${documentModels[index].attachments!.first.filePath}');
                                                  Dialog_success(
                                                      context, 'อัปโหลดสำเร็จ');
                                                });
                                              } else {
                                                print(
                                                    '❌ การอัปโหลดล้มเหลว: ${response.statusCode}');
                                                Dialog_error(context,
                                                    'ไม่มีไฟล์ถูกอัปโหลด');
                                              }
                                            },
                                            onSave: () async {
                                              handleSave(
                                                  uuid_Request.toString(),
                                                  0,
                                                  signatureKey1,
                                                  SignatureActionType
                                                      .saveToFile);
                                            },
                                            onClear: () => signatureKey1
                                                .currentState
                                                ?.clear(),
                                          ),
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
                                      Form_Cid(context),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      Doc_Data(context),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      ActiveStep_Stepper(context, Stepper: 2)
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

  ScrollController _scrollController_Stepper_3 = ScrollController();
  _moveUp_Stepper3() {
    // ตารางสรุปค่าบริการ
    _scrollController_Stepper_3.animateTo(
        _scrollController_Stepper_3.offset - 220,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 500));
  }

  _moveDown_Stepper3() {
    // ตารางสรุปค่าบริการ
    _scrollController_Stepper_3.animateTo(
        _scrollController_Stepper_3.offset + 220,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 500));
  }

  Stepper_3(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height + 300,
            child: Column(children: [
              Header_Stepper(context),
              Container(
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
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                    child: Container(
                                        width: (!Responsive.isDesktop(context))
                                            ? 1200
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.825,
                                        decoration: BoxDecoration(
                                          color:
                                              AppbackgroundColor.TiTile_Colors,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0)),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'งวด',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
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
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
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
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
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
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
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
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 250,
                                          width:
                                              (!Responsive.isDesktop(context))
                                                  ? 1200
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.825,
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(0)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          child: ListView.builder(
                                            controller:
                                                _scrollController_Stepper_3,
                                            // itemExtent: 50,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: expAutoModels.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Material(
                                                color: AppbackgroundColor
                                                    .Sub_Abg_Colors,
                                                child: Container(
                                                    // color: Strp3_tappedIndex6 ==
                                                    //         index.toString()
                                                    //     ? tappedIndex_Color
                                                    //         .tappedIndex_Colors
                                                    //         .withOpacity(0.5)
                                                    //     : null,
                                                    child: ListTile(
                                                        onTap: () {
                                                          // setState(() {
                                                          //   Strp3_tappedIndex6 =
                                                          //       index
                                                          //           .toString();
                                                          // });
                                                        },
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      maxLines:
                                                                          2,
                                                                      minFontSize:
                                                                          8,
                                                                      // maxFontSize: 15,
                                                                      '${expAutoModels[index].unit}/${expAutoModels[index].term}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight
                                                                        //         .bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,

                                                                        //fontSize: 10.0
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  maxLines: 2,
                                                                  minFontSize:
                                                                      8,
                                                                  // '${expAutoModels[index].sdate} - ${expAutoModels[index].ldate}',
                                                                  // maxFontSize: 15,
                                                                  (expAutoModels[index].sdate ==
                                                                              '' ||
                                                                          expAutoModels[index].sdate ==
                                                                              '')
                                                                      ? '${expAutoModels[index].sdate} - ${expAutoModels[index].ldate}'
                                                                      : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${expAutoModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${expAutoModels[index].ldate!} 00:00:00'))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,

                                                                    //fontSize: 10.0
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  maxLines: 2,
                                                                  minFontSize:
                                                                      8,
                                                                  // maxFontSize: 15,
                                                                  '${expAutoModels[index].expname} ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,

                                                                    //fontSize: 10.0
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 1,
                                                                child:
                                                                    AutoSizeText(
                                                                  maxLines: 2,
                                                                  minFontSize:
                                                                      8,
                                                                  // maxFontSize: 15,
                                                                  '${expAutoModels[index].total} / งวด',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,

                                                                    //fontSize: 10.0
                                                                  ),
                                                                )),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                maxLines: 2,
                                                                minFontSize: 8,
                                                                // maxFontSize: 15,

                                                                '${nFormat.format(int.parse(expAutoModels[index].term ?? '0') * double.parse(expAutoModels[index].total ?? '0'))}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,

                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ))),
                                              );
                                            },
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
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Container(
                          width: (!Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.83,
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
                                          _scrollController_Stepper_3.animateTo(
                                            0,
                                            duration:
                                                const Duration(seconds: 1),
                                            curve: Curves.easeOut,
                                          );
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              // color: AppbackgroundColor
                                              //     .TiTile_Colors,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(6),
                                                      topRight:
                                                          Radius.circular(6),
                                                      bottomLeft:
                                                          Radius.circular(6),
                                                      bottomRight:
                                                          Radius.circular(8)),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
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
                                        if (_scrollController_Stepper_3
                                            .hasClients) {
                                          final position =
                                              _scrollController_Stepper_3
                                                  .position.maxScrollExtent;
                                          _scrollController_Stepper_3.animateTo(
                                            position,
                                            duration:
                                                const Duration(seconds: 1),
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
                                                    topLeft: Radius.circular(6),
                                                    topRight:
                                                        Radius.circular(6),
                                                    bottomLeft:
                                                        Radius.circular(6),
                                                    bottomRight:
                                                        Radius.circular(6)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
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
                                      onTap: _moveUp_Stepper3,
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
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
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
                                      onTap: _moveDown_Stepper3,
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ActiveStep_Stepper(context, Stepper: 3)
            ]),
          ),
        ));
  }

//////////////////////-------->
  Widget Stepper_4(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

// // ปรับขนาดตามจอ
//     final double baseMinWidth =
//         screenWidth > 1800 ? 1800.0 : screenWidth * 0.98;
    final double maxAllowedWidth = screenWidth * 0.85;
    // final double safeMinWidth =
    //     baseMinWidth.clamp(300.0, maxAllowedWidth); // ป้องกันจอเล็กเกินไป

    double maxH = screenHeight * 0.75;
    double minH = 700;
    if (minH > maxH) minH = maxH;
    // print('Stepper_4');
    // // print(widget.Get_Value_payment_uuid);
    // print("Stepper_4 widget.payment_jsonx");
    // print(widget.paymentjsonx);
    // print("Stepper_4 widget.payment_jsonx");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Text('$maxAllowedWidth'),
            Header_Stepper(context),

            // ใส่ ScrollConfiguration สำหรับแนวนอน
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (maxAllowedWidth < 1300) ? 1400 : maxAllowedWidth,

                    maxHeight: (maxH < 560) ? 640 : maxH + 20,

                    // minWidth: safeMinWidth,
                    // maxWidth: maxAllowedWidth,
                    // minHeight: minH,
                    // maxHeight: maxH,
                  ),

                  child: BillPaymentScreen(
                      uuid_Request: uuid_Request,
                      response_Post_payment: data_response_Post_GC_payment,
                      payment_uuid: widget.Get_Value_payment_uuid,
                      payment_amount: widget.Get_Value_payment_amount,
                      payment_jsonx: widget.paymentjsonx.isNotEmpty
                          ? widget.paymentjsonx
                          : jsonx),

                  // widget.paymentjsonx
                ),
              ),
            ),
            // SizedBox(
            //   height: 30,
            // ),
            // ActiveStep_Stepper(context),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  //-------------------------------------->

  Widget Next_page_Customer({StateSetter? setStateSB}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Container(
        height: 30,
        width: 180,
        decoration: const BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.all(4.0),
        child: isLoadingCusto
            ? const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.green),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: (linksPrev != null && linksPrev != '')
                        ? () async {
                            await select_customer(
                                urlCustom: linksPrev, setStateSB: setStateSB);
                          }
                        : null,
                    child: Icon(Icons.arrow_left,
                        size: 25,
                        color: (linksPrev != null && linksPrev != '')
                            ? Colors.black
                            : Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'หน้า ${currentPage ?? '?'} / ${lastPage ?? '?'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: (linksNext != null && linksNext != '')
                        ? () async {
                            await select_customer(
                                urlCustom: linksNext, setStateSB: setStateSB);
                          }
                        : null,
                    child: Icon(Icons.arrow_right,
                        size: 25,
                        color: (linksNext != null && linksNext != '')
                            ? Colors.black
                            : Colors.grey.shade400),
                  ),
                ],
              ),
      ),
    );
  }

  Timer? _debounce;
  int currentPageCustomer = 1;
  Dialog_Customer(context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setStateSB) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final isDesktop = Responsive.isDesktop(context);

          return AlertDialog(
            backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(10),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            currentPageCustomer == 2
                                ? 'เพิ่มข้อมูลทะเบียนลูกค้า'
                                : 'เลือกรายชื่อจากทะเบียน',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          select_customer();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.grey),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () async {
                            setStateSB(() => currentPageCustomer = 1);
                            await select_customer(setStateSB: setStateSB);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentPageCustomer == 1
                                ? Colors.black87
                                : Colors.grey.shade200,
                            foregroundColor: currentPageCustomer == 1
                                ? Colors.white
                                : Colors.black87,
                            elevation: currentPageCustomer == 1 ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'ค้นจากทะเบียน',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () =>
                              setStateSB(() => currentPageCustomer = 2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentPageCustomer == 2
                                ? Colors.black87
                                : Colors.grey.shade200,
                            foregroundColor: currentPageCustomer == 2
                                ? Colors.white
                                : Colors.black87,
                            elevation: currentPageCustomer == 2 ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'เพิ่มทะเบียนใหม่',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   child: Row(
                //     children: [
                //       // Tab ค้นหา
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: () async {
                //             setStateSB(() => currentPageCustomer = 1);
                //             await select_customer();
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: currentPageCustomer == 1
                //                 ? Colors.black87
                //                 : Colors.grey.shade200,
                //             foregroundColor: currentPageCustomer == 1
                //                 ? Colors.white
                //                 : Colors.black87,
                //             elevation: currentPageCustomer == 1 ? 2 : 0,
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(10)),
                //             padding: const EdgeInsets.symmetric(vertical: 12),
                //           ),
                //           child: const Text('ค้นจากทะเบียน',
                //               style: TextStyle(
                //                   fontSize: 13, fontWeight: FontWeight.w600)),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       // Tab เพิ่มใหม่
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: () =>
                //               setStateSB(() => currentPageCustomer = 2),
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: currentPageCustomer == 2
                //                 ? Colors.black87
                //                 : Colors.grey.shade200,
                //             foregroundColor: currentPageCustomer == 2
                //                 ? Colors.white
                //                 : Colors.black87,
                //             elevation: currentPageCustomer == 2 ? 2 : 0,
                //             shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(10)),
                //             padding: const EdgeInsets.symmetric(vertical: 12),
                //           ),
                //           child: const Text('เพิ่มทะเบียนใหม่',
                //               style: TextStyle(
                //                   fontSize: 13, fontWeight: FontWeight.w600)),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                if (currentPageCustomer == 1)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppbackgroundColor.TiTile_Colors.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _searchCustoController,
                              onChanged: (value) {
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();
                                _debounce =
                                    Timer(const Duration(milliseconds: 600),
                                        () async {
                                  await select_customer(
                                      query: value.trim(),
                                      setStateSB: setStateSB);
                                });
                              },
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'ค้นหาชื่อ, รหัส, หรือเลขบัตร...',
                                prefixIcon: Icon(Icons.search, size: 20),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Next_page_Customer(setStateSB: setStateSB),
                      ],
                    ),
                  ),
                const Divider(height: 20),
              ],
            ),
            content: SizedBox(
              width: isDesktop ? screenWidth * 0.85 : screenWidth * 0.95,
              height: screenHeight * 0.75,
              child: currentPageCustomer == 2
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Add_Custo_Screen(
                        addForForm: 'new_contract_cmm.dart',
                        onSaveSuccess: (newName) async {
                          if (!mounted) return;
                          setStateSB(() {
                            _searchCustoController.text = newName;
                            currentPageCustomer = 1;
                          });
                          await select_customer(
                              query: newName, setStateSB: setStateSB);
                        },
                      ),
                    )
                  : ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      }),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: isDesktop ? screenWidth * 0.85 : 1000,
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                        flex: 1,
                                        child: Text('#',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 2,
                                        child: Text('รูปภาพ',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 2,
                                        child: Text('รหัส',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 4,
                                        child: Text('ชื่อร้าน / ผู้เช่า',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 3,
                                        child: Text('ประเภท',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                    Expanded(
                                        flex: 1,
                                        child: Text('เลือก',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
                              ),
                              // Table Body
                              Expanded(
                                child: ListView.builder(
                                  itemCount: customerModels.length,
                                  itemBuilder: (context, index) {
                                    final model = customerModels[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200)),
                                        color: index.isEven
                                            ? Colors.white
                                            : Colors.grey.shade50,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            uuid_Request =
                                                model.uuid.toString();
                                          });

                                          List<String> data_person_add = [
                                            model.cname ?? "",
                                            model.tax ?? "",
                                            model.age?.toString() ?? "",
                                            model.national ?? "",
                                            model.address?.number ?? "",
                                            model.address?.moo ?? "",
                                            model.address?.soi ?? "",
                                            model.address?.road ?? "",
                                            model.address?.tambon ?? "",
                                            model.address?.amphoe ?? "",
                                            model.address?.province ?? "",
                                            model.tel ?? "",
                                            model.addr1 ?? ""
                                          ];

                                          List<String> data_shop_add = [
                                            "",
                                            widget.Get_Value_area_sum ?? "",
                                            model.stype ?? "",
                                            model.scname ?? "",
                                          ];

                                          List<String> data_shopsub_add = [
                                            zone_Subname ?? "",
                                            Form_zone_name.text,
                                            widget.Get_Value_area_ln ?? ""
                                          ];

                                          _updateCustomerData(
                                              data_person_add,
                                              data_shop_add,
                                              data_shopsub_add,
                                              '',
                                              '');
                                          Dia_log1(context);
                                          Timer(
                                              const Duration(milliseconds: 300),
                                              () {
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Text('${index + 1}',
                                                      textAlign:
                                                          TextAlign.center)),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: InkWell(
                                                    onTap:
                                                        (model.addr2 != null &&
                                                                model.addr2!
                                                                    .isNotEmpty)
                                                            ? () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          AlertDialog(
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Image
                                                                            .network(
                                                                          '${MyConstant().domain}/files/$foder/contract/${model.addr2}',
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                            child:
                                                                                const Text('ปิด'),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            : null,
                                                    child: model.addr2 ==
                                                                null ||
                                                            model.addr2!.isEmpty
                                                        ? const Icon(
                                                            Icons
                                                                .account_circle,
                                                            size: 40,
                                                            color: Colors.grey)
                                                        : CircleAvatar(
                                                            radius: 20,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    '${MyConstant().domain}/files/$foder/contract/${model.addr2}'),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                      model.custno ?? '-',
                                                      textAlign:
                                                          TextAlign.center)),
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(model.scname ?? '-',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    Text(model.cname ?? '-',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(model.type ?? '-',
                                                      textAlign:
                                                          TextAlign.center)),
                                              const Expanded(
                                                  flex: 1,
                                                  child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 14,
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            // actions: [
            //   TextButton(
            //     onPressed: () => Navigator.pop(context),
            //     child: Text('ยกเลิก',
            //         style: TextStyle(color: Colors.grey.shade600)),
            //   ),
            // ],
          );
        },
      ),
    );
  }

//////////----------------------------------------->

  Future<void> _showBatchUploadSheet(
    BuildContext context,
    List<dynamic> documentModels,
  ) async {
    // เตรียมรายการงาน (เฉพาะแถวที่ยังไม่มีไฟล์แนบ)
    final items = <BatchItem>[
      for (final d in documentModels)
        if (d.attachments == null || (d.attachments?.isEmpty ?? true))
          BatchItem(doc: d),
    ];

    if (items.isEmpty) {
      Dialog_error(context, 'ทุกหัวข้อมีไฟล์แนบแล้ว');
      return;
    }

    // รับค่าที่ sheet ส่งกลับ (generic ให้ชัด ช่วยลด cast ผิด)
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: BatchUploadSheet(
          documentModels: documentModels,
          uuid_Request: uuid_Request,
        ),
      ),
    );

    // ถ้าผู้ใช้ปิด sheet ด้วยการปัดลง จะได้ null → ข้าม
    if (result == null) return;

    // คาดหวังโครงสร้าง: {'updated': Map<int, AttachmentsModel>, 'failed': List<int>}
    final updated = result['updated'];
    if (updated is Map<int, AttachmentsModel>) {
      setState(() {
        updated.forEach((docId, attachment) {
          final idx = documentModels.indexWhere((e) {
            try {
              return e.id == docId; // โมเดล
            } catch (_) {
              return (e is Map) && e['id'] == docId; // Map
            }
          });
          if (idx != -1) {
            try {
              documentModels[idx].attachments = [attachment]; // โมเดล
            } catch (_) {
              if (documentModels[idx] is Map) {
                (documentModels[idx] as Map)['attachments'] = [
                  attachment
                ]; // Map
              }
            }
          }
        });
      });
      Dialog_success(context, 'อัปเดตสำเร็จ ${updated.length} รายการ');
    }
  }

  // Future<void> _showBatchUploadSheet(
  //     BuildContext context, List<dynamic> documentModels) async {
  //   // เตรียมรายการงาน (เฉพาะแถวที่ยังไม่มีไฟล์แนบ)
  //   final items = <BatchItem>[
  //     for (final d in documentModels)
  //       if (d.attachments == null || (d.attachments?.isEmpty ?? true))
  //         BatchItem(doc: d),
  //   ];

  //   if (items.isEmpty) {
  //     Dialog_error(context, 'ทุกหัวข้อมีไฟล์แนบแล้ว');
  //     return;
  //   }

  //   // เก็บไฟล์ที่ผู้ใช้เลือกทั้งหมด
  //   List<PlatformFile> pickedFiles = [];

  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (ctx) => SizedBox(
  //       height: MediaQuery.of(context).size.height * 0.8,
  //       child: BatchUploadSheet(
  //           documentModels: documentModels, uuid_Request: uuid_Request),
  //     ),
  //   );
  // }
}

class BatchUploadSheet extends StatefulWidget {
  final List<dynamic> documentModels;
  final String? uuid_Request;
  const BatchUploadSheet(
      {super.key, required this.documentModels, required this.uuid_Request});

  @override
  State<BatchUploadSheet> createState() => _BatchUploadSheetState();
}

class _BatchUploadSheetState extends State<BatchUploadSheet> {
  List<PlatformFile> pickedFiles = [];
  Map<int, PlatformFile?> assignments = {}; // key = docId, value = file
  Map<String, String> _fileSources =
      {}; // key = '${name}:${size}', value = 'system' or 'local'
  bool _uploading = false;
  double _progress = 0.0;
  bool _isLoadingFiles = false;

  void _showSnack(String msg) {
    if (!mounted) return;
    final sm = ScaffoldMessenger.maybeOf(context);
    sm?.showSnackBar(SnackBar(content: Text(msg)));
  }

// เพดานขนาดต่อไฟล์ (10 MB)
  static const int kMaxFileBytes = 10 * 1024 * 1024;
  int get _assignedCount => assignments.values.where((f) => f != null).length;
  int _maxBytesFor(PlatformFile f) {
    final ext = (f.extension ?? '').toLowerCase();
    if (ext == 'pdf') return 20 * 1024 * 1024;
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') return 8 * 1024 * 1024;

    //  print(10 * 1024 * 1024);
    return 10 * 1024 * 1024; // default
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // สำคัญบน Web เพื่อมี bytes/size
      type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      // allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null) return;

    final rejected = <PlatformFile>[];

    setState(() {
      final existing = pickedFiles.map((f) => '${f.name}:${f.size}').toSet();
      for (final f in result.files) {
        // **เช็คเพดานต่อไฟล์**
        if (f.size > kMaxFileBytes) {
          rejected.add(f);
          continue;
        }

        final key = '${f.name}:${f.size}';
        if (!existing.contains(key)) {
          pickedFiles.add(f); // รับเข้า list
          existing.add(key);
          _fileSources[key] = 'local'; // เพิ่มแท็กแหล่งที่มา
        }
      }
    });

    // แจ้งไฟล์ที่โดนปฏิเสธ
    if (rejected.isNotEmpty) {
      final lines = rejected
          .map((f) => '• ${f.name} (${_formatBytes(f.size)})')
          .join('\n');
      Dialog_error(
        context,
        'ไฟล์ใหญ่เกินกำหนด (${_formatBytes(kMaxFileBytes)})\n$lines',
      );
    }
  }

  // Future<void> _pickFiles() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     withData: true, // สำคัญบน Web
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  //   );
  //   if (result == null) return;

  //   setState(() {
  //     final existing = pickedFiles.map((f) => '${f.name}:${f.size}').toSet();
  //     for (final f in result.files) {
  //       final key = '${f.name}:${f.size}';
  //       if (!existing.contains(key)) {
  //         pickedFiles.add(f);
  //         existing.add(key);
  //       }
  //     }
  //   });
  // }

  // Future<void> _pickFiles() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     withData: true,
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'jpg', 'png'],
  //   );
  //   if (result == null) return;
  //   setState(() {
  //     pickedFiles = result.files;
  //   });
  // }

  /// เลือกไฟล์จากระบบ (Snapshot Attachments)
  ///
  /// Flow:
  /// 1. ใช้ uuid_Request → ดึงข้อมูล request → ได้ clients_uuid
  /// 2. ใช้ clients_uuid → ดึง snapshots → ได้ snapshot_uuid
  /// 3. ใช้ snapshot_uuid → ดึง attachments → ได้รายการไฟล์
  /// 4. แสดง dialog เลือกไฟล์ → เพิ่มเข้า pickedFiles
  Future<void> _pickFilesFromSystem() async {
    // ตรวจสอบว่ามี uuid_Request หรือไม่ (จาก widget.uuid_Request)
    final requestUuid = widget.uuid_Request;
    if (requestUuid == null || requestUuid.isEmpty) {
      if (mounted) {
        Dialog_error(context, 'ไม่พบข้อมูล Request UUID');
      }
      return;
    }

    try {
      // Step 1: ดึง clients_uuid จาก request
      final clientsUuid =
          await APIRequestProperties.getClientsUuid(requestUuid);
      if (clientsUuid == null || clientsUuid.isEmpty) {
        if (mounted) {
          Dialog_error(context, 'ไม่พบข้อมูล Client สำหรับ Request นี้');
        }
        return;
      }

      // Step 2-4: แสดง Dialog เลือกไฟล์จาก snapshots
      if (!mounted) return;

      final selectedAttachments =
          await showDialog<List<SnapshotAttachmentModel>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => SnapshotFilePickerDialog(
          clientsUuid: clientsUuid,
          title: 'เลือกไฟล์จากระบบ',
        ),
      );

      if (selectedAttachments == null || selectedAttachments.isEmpty) return;

      // ดาวน์โหลดไฟล์ที่เลือกและเพิ่มเข้า pickedFiles
      if (mounted) {
        setState(() {
          _isLoadingFiles = true;
        });
      }

      int successCount = 0;
      int failCount = 0;
      final List<PlatformFile> newFiles = [];

      for (final attachment in selectedAttachments) {
        try {
          // ใช้ preview endpoint พร้อม Basic Auth
          final attachmentUuid = attachment.uuid;
          if (attachmentUuid == null || attachmentUuid.isEmpty) {
            failCount++;
            continue;
          }

          final fileUrl =
              'https://cmr.chaoperties.com/api/request-snapshot-attachments/$attachmentUuid/preview';
          final response = await http.get(
            Uri.parse(fileUrl),
            headers: {
              'accept': 'application/json',
              'authorization':
                  'Basic Y2hpYW5nbWFpbXVuaWNpcGFsaXR5OmNoYW9wZXJ0eTEyMzQ=',
            },
          );

          if (response.statusCode == 200) {
            // สร้าง PlatformFile จาก bytes
            // หมายเหตุ: PlatformFile ไม่มีพารามิเตอร์ extension ใน constructor
            // extension เป็น getter ที่คำนวณจาก name อัตโนมัติ
            final platformFile = PlatformFile(
              name: attachment.fileName ?? 'unnamed_file',
              size: attachment.fileSize ?? response.bodyBytes.length,
              bytes: response.bodyBytes,
            );

            // เช็ค duplicate
            final existing =
                pickedFiles.map((f) => '${f.name}:${f.size}').toSet();
            final key = '${platformFile.name}:${platformFile.size}';

            if (!existing.contains(key)) {
              newFiles.add(platformFile);
              _fileSources[key] = 'system'; // เพิ่มแท็กแหล่งที่มา
              successCount++;
            }
          } else {
            failCount++;
          }
        } catch (e) {
          print('Error downloading file ${attachment.fileName}: $e');
          failCount++;
        }
      }

      // อัปเดต state ทีเดียว
      if (mounted && newFiles.isNotEmpty) {
        setState(() {
          pickedFiles.addAll(newFiles);
          _isLoadingFiles = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingFiles = false;
        });
      }

      if (mounted) {
        if (successCount > 0) {
          _showSnack('เพิ่มไฟล์จากระบบสำเร็จ $successCount ไฟล์');
        }
        if (failCount > 0) {
          Dialog_error(context, 'ดาวน์โหลดไฟล์ไม่สำเร็จ $failCount ไฟล์');
        }
      }
    } catch (e, stackTrace) {
      print('Error in _pickFilesFromSystem: $e');
      print('StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingFiles = false;
        });
        Dialog_error(context, 'เกิดข้อผิดพลาด: $e');
      }
    }
  }

// ==== Helpers: อ่านค่าจาก object หรือ Map ได้ยืดหยุ่น ====
  int _docId(dynamic d) {
    // รองรับ: d.id, d['id'], d.toJson()['id']
    try {
      final v = (d as dynamic).id;
      if (v != null) return int.tryParse(v.toString()) ?? -1;
    } catch (_) {}
    if (d is Map && d['id'] != null) {
      return int.tryParse(d['id'].toString()) ?? -1;
    }
    try {
      final m = (d as dynamic).toJson?.call();
      if (m is Map && m['id'] != null) {
        return int.tryParse(m['id'].toString()) ?? -1;
      }
    } catch (_) {}
    return -1; // ไม่พบ id
  }

  String _docName(dynamic d) {
    // รองรับ: nameTh, name_th, name, หรือใน Map/toJson
    try {
      final v = (d as dynamic).nameTh ??
          (d as dynamic).name_th ??
          (d as dynamic).name;
      if (v != null) return v.toString();
    } catch (_) {}
    if (d is Map) {
      return (d['nameTh'] ?? d['name_th'] ?? d['name'] ?? '-').toString();
    }
    try {
      final m = (d as dynamic).toJson?.call();
      if (m is Map) {
        return (m['nameTh'] ?? m['name_th'] ?? m['name'] ?? '-').toString();
      }
    } catch (_) {}
    return '-';
  }

  Future<dynamic> _uploadAssignedFile({
    required String uuid,
    required int docId,
    required PlatformFile file,
  }) async {
    if (kIsWeb) {
      // ✅ เว็บ: ห้ามใช้ file.path — ต้องใช้ bytes เท่านั้น
      if (file.bytes == null) {
        // เวลาเลือกไฟล์ต้องตั้ง withData:true
        // FilePicker.platform.pickFiles(withData: true, ...)
        //  print('🚫 [Web] ไม่มี bytes — ตรวจสอบว่า withData: true');
        return null;
      }
      return await Addfile_Document_Web(uuid, file.bytes!, file.name, docId);
    } else {
      // ✅ มือถือ/เดสก์ท็อป: ถ้ามี path ใช้ path ได้เลย
      if (file.path != null) {
        return await Addfile_Document_Mobile(uuid, File(file.path!), docId);
      }

      // (ทางเลือก) กรณีไม่มี path แต่มี bytes → เขียน temp file แล้วค่อยส่ง
      if (file.bytes != null) {
        // uncomment ถ้าต้องการใช้ temp-file
        // final dir = await getTemporaryDirectory();
        // final tmp = File('${dir.path}/${file.name}');
        // await tmp.writeAsBytes(file.bytes!, flush: true);
        // final resp = await Addfile_Document_Mobile(uuid, tmp, docId);
        // try { await tmp.delete(); } catch (_) {}
        // return resp;

        // หรือถ้ามีฟังก์ชัน Mobile ที่รองรับ bytes โดยตรง สร้าง Addfile_Document_MobileBytes(...) แล้วเรียกแทน
        // print(
        //      '⚠️ Mobile: ไม่มี path แต่มี bytes — โปรดรองรับ upload-from-bytes หรือใช้ temp file');
        return null;
      }

      //   print('🚫 Mobile/Desktop: ไม่พบ path หรือ bytes');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // เตรียม map assignments ด้วย docId ของทุกรายการ (เป็น null ก่อน)
    for (final d in widget.documentModels) {
      final id = _docId(d);
      if (id != -1) assignments[id] = null;
    }
  }

// Thumbnail สำหรับหัวข้อ (รองรับ PlatformFile? และ null)
  Widget _buildLeadingPreview(PlatformFile? file) {
    if (file == null) {
      return _placeholderThumb(
        icon: Icons.upload_file,
        color: Colors.grey,
        label: 'ยังไม่เลือก',
      );
    }

    final ext = (file.extension ?? '').toLowerCase();

    // รูปภาพ
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            file.bytes!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _placeholderThumb(
              icon: Icons.broken_image,
              color: Colors.orange,
              label: 'แสดงไม่ได้',
            ),
          ),
        );
      }
      return _placeholderThumb(
        icon: Icons.image,
        color: Colors.blue,
        label: 'ไม่มี bytes',
      );
    }

    // PDF
    if (ext == 'pdf') {
      return _placeholderThumb(
        icon: Icons.picture_as_pdf,
        color: Colors.red,
        label: 'PDF',
      );
    }

    // อื่นๆ
    return _placeholderThumb(
      icon: Icons.insert_drive_file,
      color: Colors.grey,
      label: ext.toUpperCase(),
    );
  }

  Widget _placeholderThumb({
    required IconData icon,
    required Color color,
    String? label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 10, color: color, fontFamily: Font_.Fonts_T),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Purple–Black Luxe
    const kBg = Color(0xFF0F0F10); // ดำเข้ม
    const kSurface = Color(0xFF14141A); // พื้นหลังการ์ด/แผง
    const kCard = Color(0xFF1A1628); // การ์ดอมม่วงเข้ม
    const kBorder = Color(0xFF2A2341); // เส้นขอบอมม่วง
    const kPrimary = Color(0xFF2E1D59); // Royal Purple ลึก
    const kPrimaryMd = Color(0xFF7B5CE6); // ไฮไลต์ม่วง
    const kAccent = Color(0xFFC084FC); // ลาเวนเดอร์เรือง

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        toolbarHeight: 64,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kBg, Color(0xFF1B1530), kPrimary], // ดำ→ม่วงเข้ม
              stops: [0.0, 0.55, 1.0], // ไล่เฉดหรู ๆ
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // gradient: LinearGradient(
            //   colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
            //   // colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)], // sky→indigo
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
          ),
        ),
        title: Text(
          "Drag & Drop Upload",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontFamily: Font_.Fonts_T,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        // actions: [
        //   // ชิปแสดงจำนวนไฟล์ที่เลือกแล้ว
        //   if (pickedFiles.isNotEmpty)
        //     Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 10),
        //       child: Chip(
        //         avatar: const Icon(Icons.insert_drive_file,
        //             size: 16, color: Colors.blue),
        //         label: Text(
        //           '${pickedFiles.length} ไฟล์',
        //           style:
        //               TextStyle(color: Colors.black, fontFamily: Font_.Fonts_T),
        //         ),
        //         backgroundColor: Colors.white.withOpacity(0.15),
        //         shape: StadiumBorder(side: BorderSide(color: Colors.white24)),
        //       ),
        //     ),
        //   const SizedBox(width: 8),

        //   // // ปุ่มเลือกไฟล์แบบเม็ดยา
        //   // Padding(
        //   //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //   //   child: ElevatedButton.icon(
        //   //     onPressed: _pickFiles,
        //   //     icon: const Icon(Icons.attach_file, size: 18),
        //   //     label: Text(
        //   //       'เลือกไฟล์',
        //   //       overflow: TextOverflow.ellipsis,
        //   //       style:
        //   //           TextStyle(color: Colors.black, fontFamily: Font_.Fonts_T),
        //   //     ),
        //   //     style: ElevatedButton.styleFrom(
        //   //       elevation: 0,
        //   //       backgroundColor: Colors.white,
        //   //       foregroundColor: Colors.black,
        //   //       padding:
        //   //           const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        //   //       shape: const StadiumBorder(),
        //   //     ),
        //   //   ),
        //   // ),
        // ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                // ปุ่มเลือกไฟล์แบบเม็ดยา
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: Text(
                      'เลือกไฟล์จากเครื่อง',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black, fontFamily: Font_.Fonts_T),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //   child: ElevatedButton.icon(
                //     onPressed: _pickFilesFromSystem,
                //     icon: const Icon(Icons.cloud_download, size: 18),
                //     label: Text(
                //       'เลือกไฟล์จากระบบ',
                //       overflow: TextOverflow.ellipsis,
                //       style: TextStyle(
                //           color: Colors.white, fontFamily: Font_.Fonts_T),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       elevation: 0,
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 14, vertical: 10),
                //       shape: const StadiumBorder(),
                //     ),
                //   ),
                // ),
                Expanded(
                    child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ลากไฟล์จากแถบซ้ายไปวางบนหัวข้อ หรือแตะไฟล์แล้วแตะหัวข้อเพื่อจับคู่',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportW = constraints.maxWidth;
          double leftMin = (Responsive.isDesktop(context))
              ? 400.0
              : (Responsive.isTablet(context))
                  ? constraints.maxWidth / 1.7
                  : 320; // ความกว้างพาเนลไฟล์
          double leftW = leftMin;
          // ให้พาเนลขวากว้างพอ และอย่างน้อย 560
          final rightW = (viewportW - leftW).clamp(560.0, double.infinity);

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              dragStartBehavior: DragStartBehavior.start,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: leftW + rightW),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ------------------- ฝั่งไฟล์ -------------------
                    SizedBox(
                      width: leftW,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Header แสดงจำนวนไฟล์ + ปุ่มล้างรายการ (optional)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'ไฟล์ที่เลือก (${pickedFiles.length})',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  if (pickedFiles.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          // ล้าง assignments ที่อ้างถึงไฟล์เหล่านี้ด้วย
                                          for (final id
                                              in assignments.keys.toList()) {
                                            final f = assignments[id];
                                            if (f != null &&
                                                pickedFiles.contains(f)) {
                                              assignments[id] = null;
                                            }
                                          }
                                          pickedFiles.clear();
                                          _fileSources
                                              .clear(); // ล้างแท็กแหล่งที่มาด้วย
                                        });
                                      },
                                      icon:
                                          const Icon(Icons.clear_all, size: 18),
                                      label: const Text(
                                        'ล้างทั้งหมด',
                                        maxLines: 1,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Empty state
                            if (pickedFiles.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.upload_file,
                                          size: 36,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text(
                                        'ยังไม่มีไฟล์ที่เลือก',
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'กด “เลือกไฟล์” ที่มุมขวาบน',
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              // รายการไฟล์ที่เลือก (สวย ๆ + ลากได้)
                              Expanded(
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 6, 8, 8),
                                  itemCount: pickedFiles.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (ctx, i) {
                                    final file = pickedFiles[i];

                                    //  LongPressDraggable<PlatformFile>(
                                    //   data: file,
                                    return Draggable<PlatformFile>(
                                      data: file,
                                      feedback: _dragFeedbackTile(file),
                                      childWhenDragging: Opacity(
                                        opacity: 0.45,
                                        child: _fileTile(
                                          file: file,
                                          onRemove: () => _removePickedAt(i),
                                        ),
                                      ),
                                      child: _fileTile(
                                        file: file,
                                        onRemove: () => _removePickedAt(i),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const VerticalDivider(width: 1),

                    // ------------------- ฝั่งหัวข้อเอกสาร -------------------
                    SizedBox(
                      width: rightW,
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth < 600 ? 1 : 2;

                          const itemHeight = 110.0;
                          final itemWidth =
                              constraints.maxWidth / crossAxisCount;
                          final childAspectRatio = itemWidth / itemHeight;

                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: widget.documentModels.length,
                            itemBuilder: (ctx, i) {
                              final doc = widget.documentModels[i];
                              final id = _docId(doc);
                              final baseName = _docName(doc);
                              final isRequired = (() {
                                try {
                                  final v = (doc as dynamic).required;
                                  if (v is bool) return v;
                                } catch (_) {}
                                if (doc is Map && doc['required'] is bool)
                                  return doc['required'] as bool;
                                return false;
                              })();
                              final title =
                                  isRequired ? '$baseName (*)' : baseName;
                              final assignedFile = assignments[id];
                              return DragTarget<PlatformFile>(
                                onAccept: (file) =>
                                    setState(() => assignments[id] = file),
                                builder: (ctx, candidate, rejected) {
                                  final isHovering = candidate.isNotEmpty;

                                  // ✅ คำนวณค่าที่ต้องใช้ใน subtitle (มีไฟล์เท่านั้นถึงจะมีค่า)

                                  final hasFile = assignedFile != null;
                                  final ext = hasFile
                                      ? (assignedFile!.extension ?? '')
                                          .toUpperCase()
                                      : '';
                                  if (id == 9 &&
                                      (ext == 'PDF' || ext == 'pdf')) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      Dialog_error(context,
                                          '$title ไม่สามารถอัปโหลดไฟล์ PDF ได้');
                                      setState(() {
                                        assignments[id] = null;
                                      });
                                    });
                                  }
                                  final color = _extColor(
                                      ext.toLowerCase()); // ต้องมีฟังก์ชันนี้
                                  final sizeLabel = hasFile
                                      ? _formatBytes(assignedFile!.size)
                                      : ''; // และฟังก์ชันนี้

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: isHovering
                                              ? Colors.blue
                                              : Colors.grey.shade300),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(8),
                                      leading: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: _buildLeadingPreview(
                                            assignedFile), // รองรับ null
                                      ),
                                      title: Text(title,
                                          overflow: TextOverflow.ellipsis),
                                      subtitle: hasFile
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start, // ✅ ชิดซ้าย
                                              children: [
                                                Text(
                                                  'เลือกแล้ว: ${assignedFile!.name}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.green),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    _extBadge(
                                                        ext.isEmpty
                                                            ? 'FILE'
                                                            : ext,
                                                        color), // ✅ กันเคสไม่มีนามสกุล
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      sizeLabel,
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 12,
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Text(
                                              (doc.attachments != null &&
                                                      doc.attachments!
                                                          .isNotEmpty)
                                                  ? 'พบการอัพโหลดไฟล์แล้ว'
                                                  : 'ลากไฟล์มาวางที่นี่',
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                      trailing: isHovering
                                          ? const Icon(Icons.arrow_downward,
                                              color: Colors.blue)
                                          : (hasFile
                                              ? IconButton(
                                                  icon: const Icon(Icons.close,
                                                      color: Colors.red),
                                                  tooltip: 'เอาไฟล์ออก',
                                                  onPressed: () => setState(
                                                      () => assignments[id] =
                                                          null),
                                                )
                                              : null),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // body: Container(
      //   width: (Responsive.isDesktop(context))
      //       ? MediaQuery.of(context).size.width
      //       : MediaQuery.of(context).size.width + 200,
      //   child: ScrollConfiguration(
      //     behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
      //       PointerDeviceKind.touch,
      //       PointerDeviceKind.mouse,
      //     }),
      //     child: SingleChildScrollView(
      //       scrollDirection: Axis.horizontal,
      //       dragStartBehavior: DragStartBehavior.start,
      //       child: Row(
      //         children: [
      //           // ------------------- ฝั่งไฟล์ -------------------
      //           Expanded(
      //             flex: 1,
      //             child: Container(
      //               decoration: BoxDecoration(
      //                 color: Colors.grey.shade50,
      //                 border: Border(
      //                   right: BorderSide(color: Colors.grey.shade200),
      //                 ),
      //               ),
      //               child: Column(
      //                 children: [
      //                   // Header แสดงจำนวนไฟล์ + ปุ่มล้างรายการ (optional)
      //                   Padding(
      //                     padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      //                     child: Row(
      //                       children: [
      //                         Expanded(
      //                           child: Text(
      //                             'ไฟล์ที่เลือก (${pickedFiles.length})',
      //                             maxLines: 1,
      //                             style: TextStyle(
      //                               fontWeight: FontWeight.w600,
      //                               fontFamily: Font_.Fonts_T,
      //                             ),
      //                           ),
      //                         ),
      //                         if (pickedFiles.isNotEmpty)
      //                           TextButton.icon(
      //                             onPressed: () {
      //                               setState(() {
      //                                 // ล้าง assignments ที่อ้างถึงไฟล์เหล่านี้ด้วย
      //                                 for (final id
      //                                     in assignments.keys.toList()) {
      //                                   final f = assignments[id];
      //                                   if (f != null &&
      //                                       pickedFiles.contains(f)) {
      //                                     assignments[id] = null;
      //                                   }
      //                                 }
      //                                 pickedFiles.clear();
      //                               });
      //                             },
      //                             icon: const Icon(Icons.clear_all, size: 18),
      //                             label: const Text(
      //                               'ล้างทั้งหมด',
      //                               maxLines: 1,
      //                             ),
      //                           ),
      //                       ],
      //                     ),
      //                   ),

      //                   // Empty state
      //                   if (pickedFiles.isEmpty)
      //                     Expanded(
      //                       child: Center(
      //                         child: Column(
      //                           mainAxisSize: MainAxisSize.min,
      //                           children: [
      //                             Icon(Icons.upload_file,
      //                                 size: 36, color: Colors.grey.shade400),
      //                             const SizedBox(height: 8),
      //                             Text(
      //                               'ยังไม่มีไฟล์ที่เลือก',
      //                               maxLines: 1,
      //                               style: TextStyle(
      //                                   color: Colors.grey.shade600,
      //                                   fontFamily: Font_.Fonts_T),
      //                             ),
      //                             const SizedBox(height: 6),
      //                             Text(
      //                               'กด “เลือกไฟล์” ที่มุมขวาบน',
      //                               maxLines: 1,
      //                               style: TextStyle(
      //                                   color: Colors.grey.shade500,
      //                                   fontSize: 12,
      //                                   fontFamily: Font_.Fonts_T),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     )
      //                   else
      //                     // รายการไฟล์ที่เลือก (สวย ๆ + ลากได้)
      //                     Expanded(
      //                       child: ListView.separated(
      //                         padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      //                         itemCount: pickedFiles.length,
      //                         separatorBuilder: (_, __) =>
      //                             const SizedBox(height: 8),
      //                         itemBuilder: (ctx, i) {
      //                           final file = pickedFiles[i];

      //                           //  LongPressDraggable<PlatformFile>(
      //                           //   data: file,
      //                           return Draggable<PlatformFile>(
      //                             data: file,
      //                             feedback: _dragFeedbackTile(file),
      //                             childWhenDragging: Opacity(
      //                               opacity: 0.45,
      //                               child: _fileTile(
      //                                 file: file,
      //                                 onRemove: () => _removePickedAt(i),
      //                               ),
      //                             ),
      //                             child: _fileTile(
      //                               file: file,
      //                               onRemove: () => _removePickedAt(i),
      //                             ),
      //                           );
      //                         },
      //                       ),
      //                     ),
      //                 ],
      //               ),
      //             ),
      //           ),

      //           const VerticalDivider(width: 1),

      //           // ------------------- ฝั่งหัวข้อเอกสาร -------------------
      //           Expanded(
      //             flex: 2,
      //             child: LayoutBuilder(
      //               builder: (ctx, constraints) {
      //                 // จอแคบ (<600) = 1 คอลัมน์, จอกว้าง = 2 คอลัมน์
      //                 final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;

      //                 // คุมสัดส่วนให้หน้าตาเหมือน ListTile
      //                 const itemHeight = 110.0;
      //                 final itemWidth = constraints.maxWidth / crossAxisCount;
      //                 final childAspectRatio = itemWidth / itemHeight;

      //                 return GridView.builder(
      //                   padding: const EdgeInsets.all(8),
      //                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //                     crossAxisCount: crossAxisCount,
      //                     crossAxisSpacing: 8,
      //                     mainAxisSpacing: 8,
      //                     childAspectRatio: childAspectRatio,
      //                   ),
      //                   itemCount: widget.documentModels.length,
      //                   itemBuilder: (ctx, i) {
      //                     final doc = widget.documentModels[i];
      //                     final id = _docId(doc);
      //                     final baseName = _docName(doc);
      //                     final isRequired = (() {
      //                       try {
      //                         final v = (doc as dynamic).required;
      //                         if (v is bool) return v;
      //                       } catch (_) {}
      //                       if (doc is Map && doc['required'] is bool)
      //                         return doc['required'] as bool;
      //                       return false;
      //                     })();
      //                     final title = isRequired ? '$baseName (*)' : baseName;
      //                     final assignedFile = assignments[id];
      //                     return DragTarget<PlatformFile>(
      //                       onAccept: (file) =>
      //                           setState(() => assignments[id] = file),
      //                       builder: (ctx, candidate, rejected) {
      //                         final isHovering = candidate.isNotEmpty;
      //                         final assignedFile = assignments[id];

      //                         // ✅ คำนวณค่าที่ต้องใช้ใน subtitle (มีไฟล์เท่านั้นถึงจะมีค่า)
      //                         final hasFile = assignedFile != null;
      //                         final ext = hasFile
      //                             ? (assignedFile!.extension ?? '')
      //                                 .toUpperCase()
      //                             : '';
      //                         final color = _extColor(
      //                             ext.toLowerCase()); // ต้องมีฟังก์ชันนี้
      //                         final sizeLabel = hasFile
      //                             ? _formatBytes(assignedFile!.size)
      //                             : ''; // และฟังก์ชันนี้

      //                         return Card(
      //                           shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(12),
      //                             side: BorderSide(
      //                                 color: isHovering
      //                                     ? Colors.blue
      //                                     : Colors.grey.shade300),
      //                           ),
      //                           child: ListTile(
      //                             contentPadding: const EdgeInsets.all(8),
      //                             leading: SizedBox(
      //                               width: 60,
      //                               height: 60,
      //                               child: _buildLeadingPreview(
      //                                   assignedFile), // รองรับ null
      //                             ),
      //                             title: Text(title,
      //                                 overflow: TextOverflow.ellipsis),
      //                             subtitle: hasFile
      //                                 ? Column(
      //                                     mainAxisSize: MainAxisSize.min,
      //                                     crossAxisAlignment: CrossAxisAlignment
      //                                         .start, // ✅ ชิดซ้าย
      //                                     children: [
      //                                       Text(
      //                                         'เลือกแล้ว: ${assignedFile!.name}',
      //                                         overflow: TextOverflow.ellipsis,
      //                                         style: const TextStyle(
      //                                             color: Colors.green),
      //                                       ),
      //                                       const SizedBox(height: 4),
      //                                       Row(
      //                                         mainAxisSize: MainAxisSize.min,
      //                                         children: [
      //                                           _extBadge(
      //                                               ext.isEmpty ? 'FILE' : ext,
      //                                               color), // ✅ กันเคสไม่มีนามสกุล
      //                                           const SizedBox(width: 8),
      //                                           Text(
      //                                             sizeLabel,
      //                                             style: TextStyle(
      //                                               color: Colors.grey.shade600,
      //                                               fontSize: 12,
      //                                               fontFamily: Font_.Fonts_T,
      //                                             ),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                     ],
      //                                   )
      //                                 : Text(
      //                                     (doc.attachments != null &&
      //                                             doc.attachments!.isNotEmpty)
      //                                         ? 'พบการอัพโหลดไฟล์แล้ว'
      //                                         : 'ลากไฟล์มาวางที่นี่',
      //                                     overflow: TextOverflow.ellipsis,
      //                                     style: TextStyle(color: Colors.grey),
      //                                   ),
      //                             trailing: isHovering
      //                                 ? const Icon(Icons.arrow_downward,
      //                                     color: Colors.blue)
      //                                 : (hasFile
      //                                     ? IconButton(
      //                                         icon: const Icon(Icons.close,
      //                                             color: Colors.red),
      //                                         tooltip: 'เอาไฟล์ออก',
      //                                         onPressed: () => setState(
      //                                             () => assignments[id] = null),
      //                                       )
      //                                     : null),
      //                           ),
      //                         );
      //                       },
      //                     );
      //                   },
      //                 );
      //               },
      //             ),
      //           )
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // แถวสถานะด้านบน: ชิปสรุปหรือ progress bar
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: !_uploading
                    ? Row(
                        key: const ValueKey('summary'),
                        children: [
                          Chip(
                            avatar: const Icon(Icons.link,
                                size: 16, color: Colors.white),
                            label: Text(
                              'จับคู่แล้ว ${_assignedCount} รายการ',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFF6366F1),
                            shape: const StadiumBorder(),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _assignedCount == 0
                                  ? 'ลากไฟล์ไปวางบนหัวข้อเพื่อเริ่มอัปโหลด'
                                  : 'พร้อมอัปโหลดไฟล์ที่จับคู่แล้วทั้งหมด',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('progress'),
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress <= 0.0 ? null : _progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${(_progress * 100).toStringAsFixed(0)}%'),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              // ปุ่มอัปโหลดใหญ่ สวย ๆ
              Container(
                height: 52,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton.icon(
                  icon: _uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(
                          Icons.cloud_upload,
                          color: Colors.white,
                        ),
                  label: Text(
                    _uploading
                        ? 'กำลังอัปโหลด... ${(_progress * 100).toStringAsFixed(0)}%'
                        : (_assignedCount == 0
                            ? 'อัปโหลดทั้งหมด'
                            : 'อัปโหลดทั้งหมด ($_assignedCount รายการ)'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _assignedCount == 0 || _uploading
                        ? Colors.grey.shade300
                        : Colors.purple[800],

                    //  const Color(0xFFFFD54F), // amber อบอุ่น
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: (_assignedCount == 0 || _uploading)
                      ? null
                      : () async {
                          setState(() {
                            _uploading = true;
                            _progress = 0.0;
                          });

                          final Map<int, AttachmentsModel> updatedByDocId = {};
                          final List<int> failedDocIds = [];

                          // เอาเฉพาะรายการที่จับคู่จริง ๆ
                          final selected = assignments.entries
                              .where((e) => e.value != null)
                              .toList();
                          final total = selected.length;

                          // for (var idx = 0; idx < selected.length; idx++) {

                          //   final docId = selected[idx].key;
                          //   final file = selected[idx].value!;

                          //   final resp = await _uploadAssignedFile(
                          //     uuid: widget.uuid_Request.toString(),
                          //     docId: docId,
                          //     file: file, // web=bytes / mobile=path
                          //   );

                          //   if (resp != null &&
                          //       (resp.statusCode == 200 ||
                          //           resp.statusCode == 201)) {
                          //     final Map<String, dynamic> result =
                          //         json.decode(resp.body);
                          //     final data = result['data'];
                          //     final updatedAttachment =
                          //         AttachmentsModel.fromJson(data);
                          //     updatedByDocId[docId] = updatedAttachment;
                          //   } else {
                          //     failedDocIds.add(docId);
                          //   }

                          //   if (mounted) {
                          //     setState(() {
                          //       _progress = (idx + 1) / total;
                          //     });
                          //   }
                          // }

                          // if (!mounted) return;
                          for (var i = 0; i < selected.length; i++) {
                            final docId = selected[i].key;
                            final file = selected[i].value!;
                            // ถ้าอยากหน่วงเล็กน้อยให้ API หายใจ ก็ใส่บรรทัดนี้ได้ (ไม่ใส่ก็ได้)
                            // await Future.delayed(const Duration(milliseconds: 300));

                            try {
                              final resp = await _uploadAssignedFile(
                                uuid: widget.uuid_Request.toString(),
                                docId: docId,
                                file: file,
                              );

                              if (resp != null &&
                                  (resp.statusCode == 200 ||
                                      resp.statusCode == 201)) {
                                final Map<String, dynamic> result =
                                    json.decode(resp.body);
                                final data = result['data'];
                                final updatedAttachment =
                                    AttachmentsModel.fromJson(data);
                                updatedByDocId[docId] = updatedAttachment;
                              } else {
                                failedDocIds.add(docId);
                              }
                            } catch (_) {
                              failedDocIds.add(docId);
                            } finally {
                              if (mounted) {
                                setState(() => _progress = (i + 1) / total);
                              }
                            }
                          }

                          // ส่งผลลัพธ์กลับให้หน้าพ่อแม่
                          Navigator.of(context).pop({
                            'updated': updatedByDocId,
                            'failed': failedDocIds,
                          });
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removePickedAt(int index) {
    setState(() {
      final removed = pickedFiles[index];
      final key = '${removed.name}:${removed.size}';
      // ถ้าไฟล์นี้ถูกจับคู่ไว้กับหัวข้อใด ให้ปลดออก
      for (final id in assignments.keys.toList()) {
        if (assignments[id] == removed) assignments[id] = null;
      }
      pickedFiles.removeAt(index);
      _fileSources.remove(key); // ลบแท็กแหล่งที่มาด้วย
    });
  }

  Widget _fileTile({
    required PlatformFile file,
    required VoidCallback onRemove,
  }) {
    final ext = (file.extension ?? '').toUpperCase();
    final color = _extColor(ext.toLowerCase());
    final sizeLabel = _formatBytes(file.size);
    final fileKey = '${file.name}:${file.size}';
    final source = _fileSources[fileKey] ?? 'local';
    final isFromSystem = source == 'system';

    return Material(
      elevation: 0.5,
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: _buildLeadingPreview(file),
              ),
            ),
            const SizedBox(width: 10),

            // ชื่อไฟล์ + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อไฟล์ + แท็กแหล่งที่มา
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // แท็กแหล่งที่มา
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFromSystem
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isFromSystem
                                ? Colors.blue.shade200
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          isFromSystem ? 'ระบบ' : 'เครื่อง',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: Font_.Fonts_T,
                            color: isFromSystem
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // meta: ext badge + size
                  Row(
                    children: [
                      _extBadge(ext, color),
                      const SizedBox(width: 8),
                      Text(
                        sizeLabel,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ปุ่มลบ + ไอคอนลาก (เป็น hint)
            IconButton(
              tooltip: 'นำออก',
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
            const SizedBox(width: 4),
            Icon(Icons.drag_indicator, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _dragFeedbackTile(PlatformFile file) {
    // feedback ตอนลาก (ลอยตามนิ้ว)
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        width: 260,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 40, height: 40, child: _buildLeadingPreview(file)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _extBadge(String ext, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ext,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          fontFamily: Font_.Fonts_T,
        ),
      ),
    );
  }

  Color _extColor(String ext) {
    switch (ext) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const k = 1024;
    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

    final i = (log(bytes) / log(k)).floor();
    final idx = i.clamp(0, units.length - 1).toInt();

    final value = bytes / pow(k, idx);
    final text =
        (value is double) ? value.toStringAsFixed(decimals) : value.toString();

    return '$text ${units[idx]}';
  } // ===== Theme (ม่วงดำหรู) =====
}
