// Page entry
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/license_announce_config.dart';
import '../models/license_announce_event.dart';
import '../services/license_announce_service.dart';
import '../viewmodels/license_announce_view_model.dart';
import 'theme/license_announce_theme.dart';
import 'widgets/license_announce_header.dart';
import 'widgets/license_announce_pagination.dart';
import 'widgets/license_announce_search_bar.dart';
import 'widgets/license_announce_table.dart';
import 'widgets/license_announce_zone_filter.dart';
import 'license_announce_add_page.dart';
import 'license_announce_detail_page.dart';

class LicenseAnnouncePage extends StatefulWidget {
  const LicenseAnnouncePage._({super.key});
  static Widget create(
      {String? routeData,
      String title = 'ประกาศ',
      LicenseAnnounceConfig? config}) {
    final cfg =
        config ?? LicenseAnnounceConfig(title: title, routeData: routeData);
    return ChangeNotifierProvider<LicenseAnnounceViewModel>(
      create: (_) => LicenseAnnounceViewModel(
          config: cfg, service: LicenseAnnounceService()),
      child: const _Body(),
    );
  }

  @override
  State<LicenseAnnouncePage> createState() => _PS();
}

class _PS extends State<LicenseAnnouncePage> {
  @override
  Widget build(BuildContext context) => const _Body();
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BS();
}

class _BS extends State<_Body> {
  StreamSubscription<LicenseAnnounceEvent>? _sub;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub != null) return; // ป้องกัน subscribe ซ้ำ
    final vm = context.read<LicenseAnnounceViewModel>();
    _sub = vm.events.listen(_onEvent);
  }

  void _onEvent(LicenseAnnounceEvent e) {
    if (!mounted) return;
    if (e is LicenseAnnounceErrorEvent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: LrColors.statusRejectedFg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LrRadius.md),
        ),
      ));
    } else if (e is LicenseAnnounceSuccessEvent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        backgroundColor: LrColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LrRadius.md),
        ),
      ));
    } else if (e is LicenseAnnounceOpenAddEvent) {
      _openAddPage();
    } else if (e is LicenseAnnounceOpenEditEvent) {
      _openEditDialog(e.announcementSer);
    } else if (e is LicenseAnnounceOpenViewEvent) {
      _openDetailPage(e.announcementUuid);
    } else if (e is LicenseAnnounceOpenAddZoneEvent) {
      _openAddZoneDialog();
    }
  }

  Future<void> _openDetailPage(String uuid) async {
    final vm = context.read<LicenseAnnounceViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<LicenseAnnounceViewModel>.value(value: vm),
          ],
          child: const LicenseAnnounceDetailPage(),
        ),
        settings: RouteSettings(arguments: uuid),
      ),
    );
    // refresh list หลังกลับมา (เผื่อมีการแก้ไข/ลบ)
    vm.refresh();
  }

  Future<void> _openAddPage() async {
    final vm = context.read<LicenseAnnounceViewModel>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<LicenseAnnounceViewModel>.value(value: vm),
          ],
          child: const LicenseAnnounceAddPage(),
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      vm.refresh();
    }
  }

  Future<void> _openEditDialog(String ser) async {
    final vm = context.read<LicenseAnnounceViewModel>();
    final item = vm.items.where((e) => e.announcementUuid == ser).firstOrNull;
    if (item == null) return;
    await showDialog(
        context: context,
        builder: (_) => LicenseAnnounceFormDialog(
            mode: LicenseAnnounceDialogMode.edit,
            initial: item,
            viewModel: vm));
  }

  Future<void> _openAddZoneDialog() async {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เพิ่มโซน'),
        content: TextField(
            controller: controller,
            decoration: const InputDecoration(
                labelText: 'ชื่อโซน',
                border: OutlineInputBorder(),
                isDense: true)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('เพิ่ม')),
        ],
      ),
    );
    if (ok == true) {
      messenger.showSnackBar(const SnackBar(content: Text('เพิ่มโซน (mock)')));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseAnnounceViewModel>();
    return Container(
      color: LrColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(LrSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LicenseAnnounceHeader(
              title: vm.title,
              subtitle: 'จัดการประกาศและแจ้งเตือนผู้เช่า',
              totalCount: vm.filtered.length,
              onCreate: vm.onAdd,
            ),
            const SizedBox(height: LrSpace.lg),
            // ─────────────────────────────────────────────────────
            // Filter zone (Card ครอบเอง — คัดลอก 100% จาก license_request_zone_filter)
            // ─────────────────────────────────────────────────────
            const LicenseAnnounceZoneFilter(),
            const SizedBox(height: LrSpace.md),

            // Search + Pagination row (ไม่มี Card ครอบ เหมือน license_request_page)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: LicenseAnnounceSearchBar()),
                const SizedBox(width: LrSpace.md),
                LicenseAnnouncePagination(
                  current: 1,
                  last: 1,
                  onPrev: () {},
                  onNext: () {},
                ),
              ],
            ),
            const SizedBox(height: LrSpace.lg),
            const Expanded(child: LicenseAnnounceTable()),
          ],
        ),
      ),
    );
  }
}
