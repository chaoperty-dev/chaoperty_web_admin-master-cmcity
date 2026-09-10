// ============================================================================
// registration_add_step1.dart
// ============================================================================
// Step 1 — ข้อมูลหลัก (ชื่อร้าน/ประเภท/ผู้ติดต่อ/เบอร์โทร/อีเมล)
// Design: card section + label-with-icon + modern TextField
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../Constant/Myconstant.dart';
import '../../../../../Model/GetType_Model.dart';
import '../theme/registration_theme.dart';

class RegistrationAddStep1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameshop;
  final TextEditingController typeshop;
  final TextEditingController bussshop;
  final TextEditingController bussscontact;
  final TextEditingController tel;
  final TextEditingController email;
  final ValueChanged<String?> onTypeChanged;
  final bool isPersonalType;

  const RegistrationAddStep1({
    super.key,
    required this.formKey,
    required this.nameshop,
    required this.typeshop,
    required this.bussshop,
    required this.bussscontact,
    required this.tel,
    required this.email,
    required this.onTypeChanged,
    required this.isPersonalType,
  });

  @override
  State<RegistrationAddStep1> createState() => _RegistrationAddStep1State();
}

class _RegistrationAddStep1State extends State<RegistrationAddStep1> {
  List<TypeModel> _types = [];
  String _selectedType = '';
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    final url = '${MyConstant().domain}/GC_type.php?isAdd=true';
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final result = jsonDecode(resp.body);
        if (result is List) {
          if (!mounted) return;
          setState(() {
            _types = result
                .map((e) => TypeModel.fromJson(e as Map<String, dynamic>))
                .toList();
            if (_types.isNotEmpty) {
              _selectedType = _types.first.type ?? '';
            }
            _loading = false;
          });
          widget.onTypeChanged(_selectedType);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoCol = width >= 700;
    final businessLabel =
        widget.isPersonalType ? 'ชื่อ-นามสกุล' : 'ชื่อผู้เช่า/บริษัท';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LaSpace.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  icon: Icons.badge_outlined,
                  title: 'ประเภทข้อมูลลูกค้า',
                  subtitle: 'เลือกประเภทเพื่อกำหนดรูปแบบฟอร์ม',
                  child: _buildTypeSelector(),
                ),
                const SizedBox(height: LaSpace.lg),
                _sectionCard(
                  icon: Icons.storefront_outlined,
                  title: 'ข้อมูลร้านค้าและผู้ติดต่อ',
                  subtitle: 'กรอกข้อมูลหลักของลูกค้า',
                  child: _grid(twoCol, [
                    _fieldRow(
                      icon: Icons.store_mall_directory_outlined,
                      label: 'ชื่อร้านค้า',
                      required: true,
                      child: _field(
                        controller: widget.nameshop,
                        hint: 'ระบุชื่อร้านค้า',
                        required: true,
                      ),
                    ),
                    _fieldRow(
                      icon: Icons.category_outlined,
                      label: 'ประเภทร้านค้า',
                      child: _field(
                        controller: widget.typeshop,
                        hint: 'ระบุประเภทร้านค้า',
                      ),
                    ),
                    _fieldRow(
                      icon: Icons.person_outline,
                      label: businessLabel,
                      child: _field(
                        controller: widget.bussscontact,
                        hint: 'ระบุ$businessLabel',
                      ),
                    ),
                    _fieldRow(
                      icon: Icons.support_agent_outlined,
                      label: 'ชื่อบุคคลติดต่อ',
                      child: _field(
                        controller: widget.bussshop,
                        hint: 'ระบุชื่อบุคคลติดต่อ',
                      ),
                    ),
                    _fieldRow(
                      icon: Icons.phone_outlined,
                      label: 'เบอร์โทร',
                      child: _field(
                        controller: widget.tel,
                        hint: 'ระบุเบอร์โทร',
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    _fieldRow(
                      icon: Icons.alternate_email,
                      label: 'อีเมล',
                      child: _field(
                        controller: widget.email,
                        hint: 'ระบุอีเมล',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section card ───
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: LaDecor.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header bar ───
          Container(
            padding: const EdgeInsets.fromLTRB(
                LaSpace.md, LaSpace.md, LaSpace.md, LaSpace.sm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: LaColors.border.withOpacity(.5), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LaColors.primary.withOpacity(.25),
                        LaColors.primary.withOpacity(.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(LaRadius.sm),
                    border: Border.all(
                        color: LaColors.primary.withOpacity(.30), width: 1),
                  ),
                  child: Icon(icon, size: 18, color: LaColors.primaryDark),
                ),
                const SizedBox(width: LaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: LaText.h2),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: LaText.bodyMuted.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ─── Body ───
          Padding(
            padding: const EdgeInsets.all(LaSpace.md),
            child: child,
          ),
        ],
      ),
    );
  }

  // ─── Type selector (pill chips) ───
  Widget _buildTypeSelector() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_types.isEmpty) {
      return Text('ไม่พบประเภทลูกค้า',
          style: LaText.bodyMuted.copyWith(color: LaColors.textMuted));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_types.length, (i) {
        final item = _types[i];
        final selected = i == _selectedIndex;
        return _TypeChip(
          label: item.type ?? '',
          selected: selected,
          onTap: () {
            setState(() {
              _selectedIndex = i;
              _selectedType = item.type ?? '';
            });
            widget.onTypeChanged(_selectedType);
          },
        );
      }),
    );
  }

  // ─── Grid ───
  Widget _grid(bool twoCol, List<Widget> children) {
    if (!twoCol) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 6),
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      if (i + 1 < children.length) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 16),
            Expanded(child: children[i + 1]),
          ],
        ));
      } else {
        rows.add(Row(children: [Expanded(child: children[i])]));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }

  // ─── Field row: Icon + Label + required dot + Input ───
  Widget _fieldRow({
    required IconData icon,
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: LaColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                required ? '$label *' : label,
                style: LaText.body.copyWith(
                  fontSize: 13,
                  color: LaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  // ─── TextField wrapper ───
  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      cursorColor: LaColors.primary,
      validator: validator ??
          (required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรอกข้อมูลให้ครบถ้วน';
                  }
                  return null;
                }
              : null),
      decoration: _inputDecor(hint),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: LaColors.surfaceMuted.withOpacity(.6),
      hintText: hint,
      hintStyle: LaText.caption,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide: BorderSide(color: LaColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide: BorderSide(color: LaColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide: const BorderSide(color: LaColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide:
            const BorderSide(color: LaColors.statusRejectedFg, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LaRadius.sm),
        borderSide:
            const BorderSide(color: LaColors.statusRejectedFg, width: 1.6),
      ),
    );
  }
}

// ============================================================================
// Type Chip — pill button (selected = gradient, unselected = outlined)
// ============================================================================
class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LaRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [LaColors.primaryAccent, LaColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(LaRadius.pill),
            border: Border.all(
              color: selected ? LaColors.primary : LaColors.border,
              width: selected ? 0 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: LaColors.primary.withOpacity(.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 14,
                color: selected ? Colors.white : LaColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : LaColors.textPrimary,
                  fontFamily: LaText.fontBold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
