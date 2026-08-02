// ============================================================================
// personal_information_page.dart
// ============================================================================
// Main View — "จัดการข้อมูลส่วนตัว"
//
// MVVM:
//   • Factory create()  → wrap ChangeNotifierProvider
//   • Body              → read/watch ViewModel
//   • Widgets           → pure UI (จาก widgets/)
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../unity/show_dialog_cmm.dart';
import '../models/personal_information_models.dart';
import '../viewmodels/personal_information_view_model.dart';
import 'theme/personal_information_theme.dart';
import 'widgets/personal_information_app_bar.dart';
import 'widgets/personal_information_avatar.dart';
import 'widgets/personal_information_info_grid.dart';
import 'widgets/personal_information_signature_dialog.dart';
import 'widgets/personal_information_signature_section.dart';

class ManagePersonalInformationPage extends StatefulWidget {
  const ManagePersonalInformationPage._();

  /// Factory สำหรับใช้ใน AdminScaffold / Navigator
  static Widget create({Key? key}) {
    return ChangeNotifierProvider<PersonalInformationViewModel>(
      create: (_) => PersonalInformationViewModel()..load(),
      child: const ManagePersonalInformationPage._(),
    );
  }

  @override
  State<ManagePersonalInformationPage> createState() =>
      _ManagePersonalInformationPageState();
}

class _ManagePersonalInformationPageState
    extends State<ManagePersonalInformationPage> {
  StreamSubscription<PersonalInformationEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    // ฟัง event จาก ViewModel (snackbar / error dialog)
    final vm = context.read<PersonalInformationViewModel>();
    _eventSub = vm.events.listen(_onEvent);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _onEvent(PersonalInformationEvent e) {
    if (!mounted) return;
    switch (e) {
      case PersonalInformationError(:final message):
        // ใช้ Dialog_error เพื่อความ consistent กับหน้าอื่นในโปรเจค
        Dialog_error(context, message);
      case PersonalInformationSaved():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกลายเซ็นสำเร็จ'),
            backgroundColor: PiColors.statusApprovedFg,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PersonalInformationViewModel>();
    final isMobile = PiSpace.isMobile(context);
    return Container(
      color: PiColors.surface,
      child: Padding(
        padding: PiSpace.pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (headerCtx) => PersonalInformationAppBar(
                title: 'ข้อมูลผู้ใช้',
                subtitle: isMobile
                    ? 'ข้อมูลส่วนตัวและลายเซ็น'
                    : 'จัดการข้อมูลส่วนตัวและลายเซ็นของคุณ',
                trailing: _HeaderEditButton(vm: vm, ctx: headerCtx),
              ),
            ),
            SizedBox(height: isMobile ? PiSpace.md : PiSpace.lg),
            Expanded(
              child: SingleChildScrollView(
                child: _Body(vm: vm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Body — switch loading / error / data
// ============================================================================

class _Body extends StatelessWidget {
  final PersonalInformationViewModel vm;
  const _Body({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.profile == null) return _loadingBlock();
    if (vm.profile == null) {
      return _errorBlock(context, vm.error ?? 'ไม่พบข้อมูล');
    }
    return _ProfileCard(vm: vm, profile: vm.profile!);
  }

  Widget _loadingBlock() {
    return Container(
      height: 280,
      alignment: Alignment.center,
      decoration: PiDecor.card(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: PiSpace.md),
          Text('กำลังโหลดข้อมูล...'),
        ],
      ),
    );
  }

  Widget _errorBlock(BuildContext context, String message) {
    final isMobile = PiSpace.isMobile(context);
    return Container(
      padding: EdgeInsets.all(isMobile ? PiSpace.md : PiSpace.xl),
      decoration: PiDecor.card(borderColor: const Color(0xFFFCA5A5)),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: PiColors.statusRejectedFg),
                    const SizedBox(width: PiSpace.md),
                    Expanded(
                      child: Text(
                        'เกิดข้อผิดพลาด: $message',
                        style:
                            const TextStyle(color: PiColors.statusRejectedFg),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PiSpace.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: vm.refresh,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('ลองอีกครั้ง'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: PiColors.statusRejectedFg),
                const SizedBox(width: PiSpace.md),
                Expanded(
                  child: Text(
                    'เกิดข้อผิดพลาด: $message',
                    style: const TextStyle(color: PiColors.statusRejectedFg),
                  ),
                ),
                TextButton.icon(
                  onPressed: vm.refresh,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('ลองอีกครั้ง'),
                ),
              ],
            ),
    );
  }
}

// ============================================================================
// Profile card
// ============================================================================

/// ปุ่ม "แก้ไขลายเซ็น" ที่ header (มุมขวา) — ใช้สีขาวบนพื้น header เข้ม
class _HeaderEditButton extends StatelessWidget {
  final PersonalInformationViewModel vm;
  final BuildContext ctx;
  const _HeaderEditButton({required this.vm, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final isMobile = PiSpace.isMobile(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: vm.isSaving
            ? null
            : () async {
                await PersonalInformationSignatureDialog.show(
                  context: ctx,
                  onSave: (key) => vm.saveSignature(key),
                );
              },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color:
                vm.isSaving ? Colors.white.withOpacity(.08) : PiColors.primary,
            borderRadius: BorderRadius.circular(PiRadius.pill),
            border: Border.all(
              color: Colors.white.withOpacity(.25),
              width: 1,
            ),
            boxShadow: vm.isSaving
                ? null
                : [
                    BoxShadow(
                      color: PiColors.primary.withOpacity(.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (vm.isSaving)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: isMobile ? 16 : 14,
                ),
              if (!isMobile) ...[
                const SizedBox(width: 6),
                Text(
                  vm.isSaving ? 'กำลังบันทึก...' : 'แก้ไขลายเซ็น',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final PersonalInformationViewModel vm;
  final AdminProfile profile;
  const _ProfileCard({required this.vm, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isMobile = PiSpace.isMobile(context);
    return Container(
      decoration: PiDecor.card(),
      padding: EdgeInsets.all(isMobile ? PiSpace.md : PiSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonalInformationAvatar(profile: profile),
          SizedBox(height: isMobile ? PiSpace.lg : PiSpace.xxl),
          const Divider(height: 1, color: PiColors.border),
          const SizedBox(height: PiSpace.xl),
          PersonalInformationInfoGrid(
            fields: [
              InfoFieldData(
                label: 'รหัสผู้ใช้ (User UUID)',
                value: profile.userUuid.isEmpty ? '-' : profile.userUuid,
                mono: true,
                icon: Icons.fingerprint_rounded,
              ),
              InfoFieldData(
                label: 'Profile UUID',
                value: profile.profileUuid.isEmpty ? '-' : profile.profileUuid,
                mono: true,
                icon: Icons.tag_rounded,
              ),
              InfoFieldData(
                label: 'Signature UUID',
                value:
                    profile.signatureUuid.isEmpty ? '-' : profile.signatureUuid,
                mono: true,
                icon: Icons.draw_rounded,
              ),
              InfoFieldData(
                label: 'ลายเซ็นปัจจุบัน',
                value: profile.hasSignature ? 'พร้อมใช้งาน' : 'ยังไม่มีลายเซ็น',
                icon: Icons.verified_rounded,
                tone: profile.hasSignature
                    ? PiColors.statusApprovedFg
                    : PiColors.statusPendingFg,
              ),
            ],
          ),
          SizedBox(height: isMobile ? PiSpace.lg : PiSpace.xxl),
          PersonalInformationSignatureSection(profile: profile),
        ],
      ),
    );
  }
}
