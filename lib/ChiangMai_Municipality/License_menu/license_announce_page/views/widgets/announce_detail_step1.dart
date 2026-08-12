// ============================================================================
// announce_detail_step1.dart
// ============================================================================
// Step 1 (เดียว) — ดูรายละเอียดประกาศ (Read-only)
// - โหลดข้อมูลจาก API v1: GET /admin/announcement/{uuid}
// - ปุ่ม "แก้ไข" / "ลบ" อยู่ใน footer ของ detail page (AnnounceDetailFooter)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/license_announce_item.dart';
import '../../viewmodels/license_announce_detail_step1_view_model.dart';

class AnnounceDetailStep1 extends StatefulWidget {
  /// UUID ของประกาศ
  final String? announcementUuid;

  const AnnounceDetailStep1({
    super.key,
    this.announcementUuid,
  });

  @override
  State<AnnounceDetailStep1> createState() => _AnnounceDetailStep1State();
}

class _AnnounceDetailStep1State extends State<AnnounceDetailStep1> {
  late final LicenseAnnounceDetailStep1ViewModel _vm;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _vm = LicenseAnnounceDetailStep1ViewModel().init();
    _load();
  }

  Future<void> _load() async {
    final uuid = widget.announcementUuid?.trim();
    if (uuid == null || uuid.isEmpty) {
      _setError('ไม่พบ UUID ของประกาศ');
      return;
    }
    try {
      await _vm.loadFromUuid(uuid);
      if (mounted) {
        setState(() {
          _isLoading = _vm.isLoading;
          _errorMessage = _vm.errorMessage;
        });
      }
    } catch (e) {
      _setError('เกิดข้อผิดพลาด: $e');
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = msg;
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LicenseAnnounceDetailStep1ViewModel>.value(
      value: _vm,
      child: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลดข้อมูลประกาศ...',
                    style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                  ),
                ],
              ),
            )
          : (_errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 56, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: Colors.red.shade700),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _load();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('ลองอีกครั้ง'),
                        ),
                      ],
                    ),
                  ),
                )
              : const _Step1Body()),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Body — Read-only display
// ───────────────────────────────────────────────────────────────────────────
class _Step1Body extends StatelessWidget {
  const _Step1Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseAnnounceDetailStep1ViewModel>();
    final item = vm.item;
    if (item == null) {
      return const Center(child: Text('ไม่พบข้อมูล'));
    }

    // Breakpoints:
  //   mobile  : < 700
  //   tablet  : 700..1099
  //   desktop : >= 1100
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 700;
  final isTablet = screenWidth >= 700 && screenWidth < 1100;
  final isCompact = isMobile || isTablet;  // single-column mode

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7).withOpacity(.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.campaign_rounded,
                        size: 18, color: Color(0xFF15803D)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'รายละเอียดประกาศ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _StatusPill(status: item.computedStatus),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ZoneRow(item: item),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle(
                              icon: Icons.title, title: 'หัวข้อประกาศ'),
                          _TitleField(value: item.title),
                          const SizedBox(height: 16),
                          _SectionTitle(
                              icon: Icons.article, title: 'เนื้อหาประกาศ'),
                          _ContentField(value: item.content),
                          const SizedBox(height: 16),
                          _SectionTitle(icon: Icons.event, title: 'ช่วงวันที่'),
                          _DateGrid(item: item),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(
                                    icon: Icons.title, title: 'หัวข้อประกาศ'),
                                _TitleField(value: item.title),
                                const SizedBox(height: 16),
                                _SectionTitle(
                                    icon: Icons.event, title: 'ช่วงวันที่'),
                                _DateGrid(item: item),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(
                                    icon: Icons.article,
                                    title: 'เนื้อหาประกาศ'),
                                _ContentField(value: item.content),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'โหมดดูข้อมูลอย่างเดียว ไม่สามารถแก้ไขได้',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ───────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF15803D)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final int maxLines;
  const _ReadOnlyField({required this.value, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        value.isEmpty ? '-' : value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  final String value;
  const _TitleField({required this.value});
  @override
  Widget build(BuildContext context) =>
      _ReadOnlyField(value: value, maxLines: 2);
}

class _ContentField extends StatelessWidget {
  final String value;
  const _ContentField({required this.value});
  @override
  Widget build(BuildContext context) =>
      _ReadOnlyField(value: value, maxLines: 12);
}

class _ZoneRow extends StatelessWidget {
  final LicenseAnnounceItem item;
  const _ZoneRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ZoneChip(
            icon: Icons.place_outlined,
            label: 'โซนพื้นที่',
            value: item.zonePn ?? '-',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ZoneChip(
            icon: Icons.fingerprint,
            label: 'UUID',
            value: item.announcementUuid,
          ),
        ),
      ],
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ZoneChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF15803D)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateGrid extends StatelessWidget {
  final LicenseAnnounceItem item;
  const _DateGrid({required this.item});

  static String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DateField(
                icon: Icons.flag_outlined,
                label: 'วันที่ประกาศ',
                value: _fmt(item.announceDate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                icon: Icons.play_arrow_rounded,
                label: 'วันเริ่มรับคำขอ',
                value: _fmt(item.sdate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateField(
                icon: Icons.stop_rounded,
                label: 'วันสิ้นสุด',
                value: _fmt(item.edate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                icon: Icons.verified_outlined,
                label: 'วันออกใบอนุญาต',
                value: _fmt(item.cDateStart),
              ),
            ),
          ],
        ),
        if (item.cDateEnd != null && item.cDateEnd!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DateField(
            icon: Icons.event_busy_outlined,
            label: 'วันหมดอายุใบอนุญาต',
            value: _fmt(item.cDateEnd),
          ),
        ],
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DateField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF15803D)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  Color _bg() {
    final s = status.toLowerCase();
    if (s == 'active' || s == 'published') return const Color(0xFFDCFCE7);
    if (s == 'pending') return const Color(0xFFFEF9C3);
    if (s == 'expired' || s == 'closed') return const Color(0xFFFEE2E2);
    return const Color(0xFFE2E8F0);
  }

  Color _fg() {
    final s = status.toLowerCase();
    if (s == 'active' || s == 'published') return const Color(0xFF15803D);
    if (s == 'pending') return const Color(0xFFA16207);
    if (s == 'expired' || s == 'closed') return const Color(0xFFB91C1C);
    return const Color(0xFF475569);
  }

  @override
  Widget build(BuildContext context) {
    final s = status.isEmpty ? 'unknown' : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _fg(),
          letterSpacing: .5,
        ),
      ),
    );
  }
}
