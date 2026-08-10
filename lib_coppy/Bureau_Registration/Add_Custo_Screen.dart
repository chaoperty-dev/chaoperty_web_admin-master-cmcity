// ignore_for_file: unnecessary_null_comparison
import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:group_radio_button/group_radio_button.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Model/GetCustomer_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetType_Model.dart';
import '../Style/colors.dart';
import 'Add_Custo_Exc_Screen.dart';

class Add_Custo_Screen extends StatefulWidget {
  final dynamic updateMessage;
  final dynamic addForForm;
  final FutureOr<void> Function(String)? onSaveSuccess;

  const Add_Custo_Screen({
    super.key,
    this.updateMessage,
    this.addForForm,
    this.onSaveSuccess,
  });

  @override
  State<Add_Custo_Screen> createState() => _Add_Custo_ScreenState();
}

class _Add_Custo_ScreenState extends State<Add_Custo_Screen> {
  final List<TypeModel> typeModels = [];
  List<TransModel> transModels = [];
  final _formKey = GlobalKey<FormState>();

  final Status4Form_nameshop = TextEditingController();
  final Status4Form_typeshop = TextEditingController();
  final Status4Form_bussshop = TextEditingController();
  final Status4Form_bussscontact = TextEditingController();
  final Status4Form_address = TextEditingController();
  final Status4Form_tel = TextEditingController();
  final Status4Form_email = TextEditingController();
  final Status4Form_tax = TextEditingController();
  final Status5Form_NoArea_ = TextEditingController();
  final Status5Form_NoArea_ren = TextEditingController();
  final Status4Form_birth = TextEditingController();
  final Status4Form_religion = TextEditingController();
  final Status4Form_national = TextEditingController();

  String? renTal_user,
      renTal_name,
      zone_ser,
      zone_name,
      Value_cid,
      fname_,
      pdate,
      number_custno;
  String? ser_user,
      foder,
      position_user,
      fname_user,
      lname_user,
      email_user,
      utype_user,
      permission_user,
      tel_user,
      img_,
      img_logo;

  String _verticalGroupValue = '';
  int Value_AreaSer_ = 0;
  String? fileName_Slip;
  String? base64_Image;
  String? cust_no_;
  int ser_tap = 0;
  bool _saving = false;

  bool get _isPersonalType {
    final selectedType = typeModels.isEmpty
        ? _verticalGroupValue.trim()
        : typeModels[Value_AreaSer_.clamp(0, typeModels.length - 1)]
            .type
            .toString()
            .trim();
    const keys = ['ส่วนตัว/บุคคลธรรมดา', 'บุคคลธรรมดา', 'ส่วนตัว', 'personal'];
    return keys.contains(selectedType) ||
        _verticalGroupValue.trim() == 'ส่วนตัว/บุคคลธรรมดา';
  }

  @override
  void initState() {
    super.initState();
    checkPreferance();
    read_GC_type();
    read_GC_rental();
  }

  @override
  void dispose() {
    Status4Form_nameshop.dispose();
    Status4Form_typeshop.dispose();
    Status4Form_bussshop.dispose();
    Status4Form_bussscontact.dispose();
    Status4Form_address.dispose();
    Status4Form_tel.dispose();
    Status4Form_email.dispose();
    Status4Form_tax.dispose();
    Status5Form_NoArea_.dispose();
    Status5Form_NoArea_ren.dispose();
    Status4Form_birth.dispose();
    Status4Form_religion.dispose();
    Status4Form_national.dispose();
    super.dispose();
  }

  Future<void> checkPreferance() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      fname_ = preferences.getString('fname');
      Status4Form_religion.text = 'พุทธ';
      Status4Form_national.text = 'ไทย';
    });
  }

  Future<void> read_GC_rental() async {
    final preferences = await SharedPreferences.getInstance();
    final utype = preferences.getString('utype');
    final seruser = preferences.getString('ser');
    final url =
        '${MyConstant().domain}/GC_rental.php?isAdd=true&ser=$seruser&type=$utype';

    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result != null) {
        for (final map in result) {
          final renTalModel = RenTalModel.fromJson(map);
          if (!mounted) return;
          setState(() {
            foder = renTalModel.dbn;
            img_ = renTalModel.img;
            img_logo = renTalModel.imglogo;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> read_GC_type() async {
    typeModels.clear();
    final url = '${MyConstant().domain}/GC_type.php?isAdd=true';

    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result != null) {
        for (final map in result) {
          typeModels.add(TypeModel.fromJson(map));
        }
        if (typeModels.isNotEmpty) {
          _verticalGroupValue = typeModels.first.type ?? '';
          Value_AreaSer_ = 0;
        }
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  Future<void> Save_FormText() async {
    final preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final serUser = preferences.getString('ser');

    final nameshop = Status4Form_nameshop.text;
    final typeshop = Status4Form_typeshop.text;
    final bussshop = Status4Form_bussshop.text;
    final bussscontact = _isPersonalType
        ? Status4Form_bussshop.text
        : Status4Form_bussscontact.text;
    final address = Status4Form_address.text;
    final tel = Status4Form_tel.text;
    final email = Status4Form_email.text;
    final tax = Status4Form_tax.text;

    final url =
        '${MyConstant().domain}/Inc_customer_Bureau.php?isAdd=true&ren=$ren&nameshop=$nameshop&typeshop=$typeshop&bussshop=$bussshop&bussscontact=$bussscontact&address=$address&tel=$tel&email=$email&tax=$tax&type=$_verticalGroupValue&user=$serUser';

    try {
      final response = await http.get(Uri.parse(url));
      final result = json.decode(response.body);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs('ทะเบียน', 'เพิ่มข้อมูลลูกค้า>>($nameshop)');
      }
    } catch (_) {}
  }

  Future<void> convert_base64(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile == null) return;
    final imageBytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    if (!mounted) return;
    setState(() {
      base64_Image = base64Image;
    });
  }

  Future<void> uploadImage() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    fileName_Slip = 'pic_${cust_no_}_$timestamp.jpg';

    try {
      final url =
          '${MyConstant().domain}/File_photo.php?name=$fileName_Slip&Foder=$foder';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'image': base64_Image,
          'Foder': foder,
          'name': fileName_Slip,
        },
      );

      if (response.statusCode == 200) {
        await Future.delayed(const Duration(milliseconds: 100));
        await up_photo_string();
      }
    } catch (_) {}
  }

  Future<void> up_photo_string() async {
    final preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final custno_ = cust_no_.toString();

    await Future.delayed(const Duration(milliseconds: 500));

    final url =
        '${MyConstant().domain}/Test_UP_img_Custo.php?isAdd=true&ren=$ren&custno=$custno_&img=$fileName_Slip';

    try {
      await http.get(Uri.parse(url));
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          ' ทำรายการสำเร็จ... !',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: Font_.Fonts_T,
          ),
        ),
      ),
    );

    widget.updateMessage?.call(0);
  }

  Future<String?> _selectDate(BuildContext context,
      {String? currentDate}) async {
    DateTime initialDate;
    if (currentDate != null && currentDate.trim().isNotEmpty) {
      initialDate = DateTime.tryParse(currentDate.trim()) ?? DateTime.now();
    } else {
      initialDate = DateTime.now();
    }

    if (initialDate.isBefore(DateTime(1900))) {
      initialDate = DateTime(1900);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF102456),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      return DateFormat('yyyy-MM-dd').format(picked);
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (typeModels.isEmpty) {
      Dialog_error(context, 'ไม่พบประเภทลูกค้า');
      return;
    }

    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');
      final user = prefs.getString('ser');

      if (ren == null || ren.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบค่าเช่า (renTalSer)')),
        );
        return;
      }

      final typeText =
          typeModels[Value_AreaSer_.clamp(0, typeModels.length - 1)]
              .type
              .toString()
              .trim();
      final isPersonal = _isPersonalType;
      final bussscontact = isPersonal
          ? Status4Form_bussshop.text.trim()
          : Status4Form_bussscontact.text.trim();

      final endpoint = '${MyConstant().domain}/InC_CustoAdd_Bureau.php';
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        'isAdd': 'true',
        'ren': ren,
      });

      final body = <String, String>{
        'ciddoc': '',
        'qutser': '',
        'user': user ?? '',
        'sumdis': '',
        'sumdisp': '',
        'dateY': '',
        'dateY1': '',
        'time': '',
        'payment1': '',
        'payment2': '',
        'pSer1': '',
        'pSer2': '',
        'sum_whta': '',
        'bill': '',
        'fileNameSlip': '',
        'areaSer': isPersonal ? '1' : '2',
        'typeModels': typeText,
        'typeshop': Status4Form_typeshop.text.trim(),
        'nameshop': Status4Form_nameshop.text.trim(),
        'bussshop': Status4Form_bussshop.text.trim(),
        'bussscontact': bussscontact,
        'address': Status4Form_address.text.trim(),
        'tel': Status4Form_tel.text.trim(),
        'tax': Status4Form_tax.text.trim(),
        'email': Status4Form_email.text.trim(),
        'Serbool': '',
        'area_rent_sum': '',
        'comment': '',
        'zser': '',
        'birth': Status4Form_birth.text.trim(),
        'national': Status4Form_national.text.trim(),
        'religion': Status4Form_religion.text.trim(),
      };

      final resp =
          await http.post(uri, body: body).timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        if (!mounted) return;
        Dialog_error(
            context, 'บันทึกลูกค้าไม่สำเร็จ [HTTP ${resp.statusCode}]');
        return;
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(resp.body);
      } catch (_) {
        final b = resp.body.trim();
        if (b.startsWith('"') && b.endsWith('"')) {
          decoded = jsonDecode(jsonDecode(b));
        } else {
          rethrow;
        }
      }

      List<dynamic> list = const [];
      if (decoded == null) {
        list = const [];
      } else if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded is Map) {
        list = [decoded];
      }

      String? newCustNo;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          newCustNo ??= CustomerModel.fromJson(item).custno;
        } else if (item is Map) {
          newCustNo ??=
              CustomerModel.fromJson(Map<String, dynamic>.from(item)).custno;
        }
        if (newCustNo == null && item is Map && item['custno'] is String) {
          newCustNo = item['custno'] as String;
        }
      }

      if (newCustNo == null && decoded is Map && decoded['custno'] is String) {
        newCustNo = decoded['custno'] as String;
      }

      final savedName = Status4Form_nameshop.text.trim();

      if (!mounted) return;
      setState(() {
        cust_no_ = newCustNo ?? cust_no_;
        Status4Form_nameshop.clear();
        Status4Form_typeshop.clear();
        Status4Form_bussshop.clear();
        Status4Form_bussscontact.clear();
        Status4Form_address.clear();
        Status4Form_tel.clear();
        Status4Form_email.clear();
        Status4Form_tax.clear();
        Status4Form_birth.clear();
        Status4Form_religion.text = 'พุทธ';
        Status4Form_national.text = 'ไทย';
      });

      if (base64_Image != null) {
        await uploadImage();
      }

      if (!mounted) return;
      Dialog_success(context, 'บันทึกลูกค้าสำเร็จ');
      if (widget.onSaveSuccess != null) {
        await widget.onSaveSuccess!(savedName);
      }
    } catch (e) {
      debugPrint('Save Error: $e');
      if (!mounted) return;
      Dialog_error(context, 'เกิดข้อผิดพลาด');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isDesktop(double width) => width >= 1200;
  bool _isTablet(double width) => width >= 700 && width < 1200;

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF102456), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: const TextStyle(
        color: PeopleChaoScreen_Color.Colors_Text2_,
        fontFamily: Font_.Fonts_T,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFF102456), size: 18),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PeopleChaoScreen_Color.Colors_Text1_,
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
          const Divider(height: 10, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      onChanged: onChanged,
      cursorColor: Colors.green,
      validator: validator,
      style: const TextStyle(fontFamily: Font_.Fonts_T),
      decoration: _inputDecoration(label, hint: hint),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final value =
            await _selectDate(context, currentDate: Status4Form_birth.text);
        if (value != null) {
          setState(() {
            Status4Form_birth.text = value;
          });
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration('วันเกิด'),
        child: Row(
          children: [
            const Icon(Icons.calendar_month,
                color: Color(0xFF102456), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                Status4Form_birth.text.isNotEmpty
                    ? DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(Status4Form_birth.text))
                    : 'ระบุวันเกิด',
                style: TextStyle(
                  color: Status4Form_birth.text.isNotEmpty
                      ? Colors.blue
                      : Colors.grey.shade700,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldGrid(List<Widget> children, double width) {
    final bool twoCol = _isDesktop(width) || _isTablet(width);

    if (!twoCol) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 15),
          ],
        ],
      );
    }

    final List<Widget> rows = [];
    for (int i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 10),
            Expanded(child: children[i + 1]),
          ],
        ));
      } else {
        rows.add(Row(
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 10),
            const Expanded(child: SizedBox.shrink()),
          ],
        ));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 15),
        ],
      ],
    );
  }

  Widget _buildTypeSelector(double width) {
    if (typeModels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (width < 700) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(typeModels.length, (index) {
          final item = typeModels[index];
          final selected = index == Value_AreaSer_;
          return ChoiceChip(
            label: Text(
              item.type ?? '',
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            selectedColor: const Color(0xFF102456),
            backgroundColor: Colors.grey.shade100,
            side: BorderSide(
              color: selected ? const Color(0xFF102456) : Colors.grey.shade300,
            ),
            onSelected: (_) {
              Status4Form_nameshop.clear();
              Status4Form_bussshop.clear();
              Status4Form_bussscontact.clear();
              setState(() {
                Value_AreaSer_ = index;
                _verticalGroupValue = item.type ?? '';
                transModels = [];
              });
            },
          );
        }),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceAround,
        children: List.generate(typeModels.length, (index) {
          final item = typeModels[index];
          return GestureDetector(
            onTap: () {
              Status4Form_nameshop.clear();
              Status4Form_bussshop.clear();
              Status4Form_bussscontact.clear();
              setState(() {
                Value_AreaSer_ = int.tryParse(item.ser ?? '1') != null
                    ? int.parse(item.ser!) - 1
                    : 0;
                if (Value_AreaSer_ < 0) Value_AreaSer_ = 0;
                _verticalGroupValue = item.type ?? '';
                transModels = [];
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<TypeModel>(
                  value: item,
                  groupValue: typeModels[
                      Value_AreaSer_.clamp(0, typeModels.length - 1)],
                  onChanged: (value) {
                    if (value == null) return;
                    Status4Form_nameshop.clear();
                    Status4Form_bussshop.clear();
                    Status4Form_bussscontact.clear();
                    setState(() {
                      Value_AreaSer_ = int.tryParse(value.ser ?? '1') != null
                          ? int.parse(value.ser!) - 1
                          : 0;
                      if (Value_AreaSer_ < 0) Value_AreaSer_ = 0;
                      _verticalGroupValue = value.type ?? '';
                      transModels = [];
                    });
                  },
                  activeColor: const Color(0xFF102456),
                ),
                Text(
                  item.type ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(double width) {
    final isCompact = width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.addForForm == null)
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => widget.updateMessage?.call(0),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.red),
              label: const Text(
                'ย้อนกลับ',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        if (widget.addForForm == null) const SizedBox(height: 8),
        if (widget.addForForm == null)
          Row(
            children: [
              Expanded(
                child: Text(
                  'เพิ่มข้อมูลทะเบียนลูกค้า',
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: PeopleChaoScreen_Color.Colors_Text1_,
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
              ),
            ],
          ),
        if (widget.addForForm == null) const SizedBox(height: 8),
        if (widget.addForForm == null)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildModeChip(
                  title: 'แบบปกติ',
                  active: ser_tap == 0,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey,
                  onTap: () => setState(() => ser_tap = 0),
                ),
                _buildModeChip(
                  title: 'แบบExcel',
                  active: ser_tap == 1,
                  activeColor: Colors.orange.shade700,
                  inactiveColor: Colors.orange.shade100,
                  onTap: () => setState(() => ser_tap = 1),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModeChip({
    required String title,
    required bool active,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: AutoSizeText(
            title,
            minFontSize: 10,
            maxFontSize: 14,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: FontWeight_.Fonts_T,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalForm(double width) {
    final businessLabel =
        _isPersonalType ? 'ชื่อ-นามสกุล' : 'ชื่อผู้เช่า/บริษัท';

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildSectionCard(
            title: 'ประเภทข้อมูลลูกค้า',
            icon: Icons.badge_outlined,
            child: _buildTypeSelector(width),
          ),
          _buildSectionCard(
            title: 'ข้อมูลร้านค้าและผู้ติดต่อ',
            icon: Icons.storefront_outlined,
            child: _buildFieldGrid([
              _buildTextField(
                controller: Status4Form_nameshop,
                label: 'ชื่อร้านค้า',
                hint: 'ระบุชื่อร้านค้า',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรอกข้อมูลให้ครบถ้วน';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: Status4Form_typeshop,
                label: 'ประเภทร้านค้า',
                hint: 'ระบุประเภทร้านค้า',
              ),
              _buildTextField(
                controller:
                    //  _isPersonalType
                    //     ? Status4Form_bussshop
                    //     :
                    Status4Form_bussscontact,
                label: businessLabel,
                hint: 'ระบุ$businessLabel',
              ),
              _buildTextField(
                controller: Status4Form_bussshop,
                label: 'ชื่อบุคคลติดต่อ',
                hint: 'ระบุชื่อบุคคลติดต่อ',
                onChanged: (value) {
                  // if (_isPersonalType) {
                  //   Status4Form_nameshop.text = value.trim();
                  // }
                },
              ),
              _buildTextField(
                controller: Status4Form_tel,
                label: 'เบอร์โทร',
                hint: 'ระบุเบอร์โทร',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              _buildTextField(
                controller: Status4Form_email,
                label: 'อีเมล',
                hint: 'ระบุอีเมล',
                keyboardType: TextInputType.emailAddress,
              ),
            ], width),
          ),
          _buildSectionCard(
            title: 'ข้อมูลส่วนบุคคล',
            icon: Icons.person_outline,
            child: _buildFieldGrid([
              _buildTextField(
                controller: Status4Form_tax,
                label: 'ID/TAX ID',
                hint: 'ระบุ ID/TAX ID',
                keyboardType: TextInputType.number,
                maxLength: 13,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'กรอกข้อมูลให้ครบถ้วน';
                  if (text.length < 13) return 'กรอกอย่างน้อย 13 หลัก';
                  return null;
                },
              ),
              _buildDateField(),
              _buildTextField(
                controller: Status4Form_religion,
                label: 'ศาสนา',
                hint: 'ระบุศาสนา',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรอกข้อมูลให้ครบถ้วน';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: Status4Form_national,
                label: 'สัญชาติ',
                hint: 'ระบุสัญชาติ',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรอกข้อมูลให้ครบถ้วน';
                  }
                  return null;
                },
              ),
            ], width),
          ),
          _buildSectionCard(
            title: 'ที่อยู่',
            icon: Icons.location_on_outlined,
            child: _buildTextField(
              controller: Status4Form_address,
              label: 'ที่อยู่',
              hint: 'ระบุที่อยู่',
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: width < 700 ? double.infinity : 180,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'กำลังบันทึก...' : 'บันทึก'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final contentMaxWidth = _isDesktop(width) ? 1320.0 : 1000.0;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(width < 700 ? 6 : 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppbackgroundColor.Sub_Abg_Colors,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(width < 700 ? 8 : 14),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(width),
                          const SizedBox(height: 10),
                          ser_tap == 1
                              ? const Add_Custo_EXC_Screen()
                              : _buildNormalForm(width),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
