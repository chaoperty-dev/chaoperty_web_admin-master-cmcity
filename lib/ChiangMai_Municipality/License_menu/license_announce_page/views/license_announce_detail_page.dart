// ============================================================================
// license_announce_detail_page.dart
// ============================================================================
// Full-page detail route — เปิดแบบเต็มจอเหมือน "ดูรายละเอียดประกาศ"
// Step 1 เดียว — มีปุ่ม "แก้ไข" / "ลบ" ใน footer
// โครงสร้างเลียนแบบ license_request_detail_page
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/license_announce_item.dart';
import '../viewmodels/license_announce_view_model.dart';
import 'license_announce_edit_page.dart';
import 'theme/license_announce_theme.dart';
import 'widgets/announce_detail_footer.dart';
import 'widgets/announce_detail_header.dart';
import 'widgets/announce_detail_step1.dart';

class LicenseAnnounceDetailPage extends StatefulWidget {
  const LicenseAnnounceDetailPage({super.key});

  @override
  State<LicenseAnnounceDetailPage> createState() =>
      _LicenseAnnounceDetailPageState();
}

class _LicenseAnnounceDetailPageState extends State<LicenseAnnounceDetailPage> {
  String? _uuid;
  bool _isDeleting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // อ่าน route arguments ใน didChangeDependencies (ห้าม initState)
    _uuid ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  LicenseAnnounceItem? _findItem(BuildContext context) {
    if (_uuid == null || _uuid!.isEmpty) return null;
    final vm = context.read<LicenseAnnounceViewModel>();
    try {
      return vm.items.firstWhere((e) => e.announcementUuid == _uuid);
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirmAndDelete() async {
    final item = _findItem(context);
    if (item == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content:
            Text('ลบประกาศ "${item.title}" ?\nการกระทำนี้ไม่สามารถยกเลิกได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _isDeleting = true);
    final messenger = ScaffoldMessenger.of(context);
    final listVm = context.read<LicenseAnnounceViewModel>();
    final success = await listVm.deleteAnnouncement(item.announcementUuid);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (success) {
      messenger.showSnackBar(const SnackBar(
        content: Text('ลบประกาศสำเร็จ'),
        behavior: SnackBarBehavior.floating,
      ));
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    } else {
      messenger.showSnackBar(const SnackBar(
        content: Text('ลบประกาศล้มเหลว'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _openEditPage() async {
    final item = _findItem(context);
    if (item == null) return;
    final vm = context.read<LicenseAnnounceViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<LicenseAnnounceViewModel>.value(value: vm),
          ],
          child: LicenseAnnounceEditPage(item: item),
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      messenger.showSnackBar(const SnackBar(
        content: Text('แก้ไขประกาศสำเร็จ'),
        behavior: SnackBarBehavior.floating,
      ));
      // กลับหน้า list (refresh อัตโนมัติเพราะ VM ตัวเดียวกัน)
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LrColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnnounceDetailHeader(
              title: 'รายละเอียดประกาศ',
              subtitle: 'ตรวจสอบ / แก้ไข / ลบ',
              currentStep: 1,
              totalSteps: 1,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: AnnounceDetailStep1(
                announcementUuid: _uuid,
              ),
            ),
            AnnounceDetailFooter(
              isDeleting: _isDeleting,
              statusText: _isDeleting ? 'กำลังลบประกาศ...' : 'โหมดดูอย่างเดียว',
              statusIcon: _isDeleting
                  ? Icons.hourglass_top_rounded
                  : Icons.visibility_outlined,
              onDelete: _confirmAndDelete,
              onEdit: _openEditPage,
            ),
          ],
        ),
      ),
    );
  }
}
