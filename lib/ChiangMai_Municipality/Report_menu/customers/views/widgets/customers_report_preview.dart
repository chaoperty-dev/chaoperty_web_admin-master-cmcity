// ============================================================================
// customers_report_preview.dart
// ============================================================================
// ตัวอย่างตาราง (Preview) แบบคล้าย Excel — สำหรับเมนูรายงานลูกค้า
// (เหมือน areas_report_preview แต่ใช้ CustomerReport* model + ข้อมูลลูกค้า)
// - อิงจากคอลัมน์ที่ผู้ใช้เลือก (ติ๊ก) + ลำดับที่เรียงใน ColumnPicker
// - จำลองข้อมูล 10 แถว (mock) เพื่อดูหน้าตาข้อมูลก่อนส่งออกไฟล์
// - Excel: หัวตารางแช่แข็ง + คอลัมน์เลขแถวค้าง + ตัวอักษร A/B/C + เส้นกริด + zebra
//
// ✅ ใช้ Selector — rebuild เฉพาะตอน columns / selected เปลี่ยน
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/customers_report_view_model.dart';
import '../../services/customers_report_service.dart';
import '../theme/customers_report_theme.dart';

// ─── Excel-like constants ───
const double _kHeaderH = 48;
const double _kRowH = 36;
const double _kNumW = 48;
const double _kViewH = 360;
const Color _kHeadFill = Color(0xFFF6F8FB);
const Color _kGrid = Color(0xFFE3E8EE);
const Color _kGridStrong = Color(0xFFCBD2DA);
const Color _kZebra = Color(0xFFFAFBFC);
const Color _kEmptyFill = Color(0xFFF9FAFB);
const Color _kHeadText = Color(0xFF5F6368);
const Color _kHeadLabel = Color(0xFF1F2937);
const Color _kMutedText = Color(0xFFB8C0CC);

class _PreviewData {
  final List<CustomerReportColumn> columns;
  final Set<String> selected;

  const _PreviewData({required this.columns, required this.selected});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _PreviewData) return false;
    if (!_setEq(other.selected, selected)) return false;
    if (other.columns.length != columns.length) return false;
    for (int i = 0; i < columns.length; i++) {
      if (other.columns[i].field != columns[i].field) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        identityHashCode(columns),
        identityHashCode(selected),
      );

  static bool _setEq(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    for (final e in a) {
      if (!b.contains(e)) return false;
    }
    return true;
  }
}

class CustomersReportPreview extends StatelessWidget {
  const CustomersReportPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CustomersReportViewModel, _PreviewData>(
      selector: (_, vm) => _PreviewData(
        columns: vm.columns,
        selected: {...vm.selectedFields},
      ),
      shouldRebuild: (a, b) => a != b,
      builder: (context, data, _) {
        final visible = data.columns
            .where((c) => data.selected.contains(c.field))
            .toList(growable: false);

        return Container(
          decoration: CrDecor.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    CrSpace.lg, CrSpace.md, CrSpace.md, CrSpace.sm),
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_rounded,
                        size: 18, color: CrColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'ตัวอย่างตาราง (Preview)',
                      style: CrText.h2.copyWith(color: CrColors.textPrimary),
                    ),
                    const Spacer(),
                    Text(
                      visible.isEmpty
                          ? 'ยังไม่เลือกคอลัมน์'
                          : '${visible.length} คอลัมน์ · โครงสร้างตัวอย่าง',
                      style: CrText.bodyMuted.copyWith(
                        color: CrColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: CrColors.border),
              const SizedBox(height: CrSpace.sm),
              if (visible.isEmpty)
                _EmptyPreview()
              else
                _PreviewTable(columns: visible),
              const SizedBox(height: CrSpace.sm),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    CrSpace.md, 0, CrSpace.md, CrSpace.md),
                child: Text(
                  'โครงสร้างตารางตัวอย่างเท่านั้น — '
                  'ข้อมูลจริงจะถูกส่งออกเมื่อกดดาวน์โหลด',
                  style: CrText.caption.copyWith(color: CrColors.textMuted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_outlined, size: 32, color: CrColors.textMuted),
            const SizedBox(height: 12),
            Text('เลือกคอลัมน์ด้านบนเพื่อดูตัวอย่างตาราง',
                style: CrText.bodyMuted),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// โครงสร้างตารางตัวอย่าง — ไม่แสดงข้อมูลจริง (empty placeholder)
/// ============================================================
const int _kPreviewRows = 6;

String _colLetter(int index) {
  String s = '';
  int n = index + 1;
  while (n > 0) {
    final r = (n - 1) % 26;
    s = String.fromCharCode(65 + r) + s;
    n = (n - 1) ~/ 26;
  }
  return s;
}

double _colWidth(String label) =>
    (label.length * 9.0).clamp(96.0, 200.0);

class _PreviewTable extends StatefulWidget {
  final List<CustomerReportColumn> columns;
  const _PreviewTable({required this.columns});

  @override
  State<_PreviewTable> createState() => _PreviewTableState();
}

class _PreviewTableState extends State<_PreviewTable> {
  late final ScrollController _vBody;
  late final ScrollController _hBody;
  late final ScrollController _hHead;
  late final ScrollController _vNum;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _vBody = ScrollController();
    _hBody = ScrollController();
    _hHead = ScrollController();
    _vNum = ScrollController();
    _hBody.addListener(_syncH);
    _vBody.addListener(_syncV);
  }

  void _syncH() {
    if (_syncing) return;
    _syncing = true;
    if (_hHead.hasClients) _hHead.jumpTo(_hBody.offset);
    _syncing = false;
  }

  void _syncV() {
    if (_syncing) return;
    _syncing = true;
    if (_vNum.hasClients) _vNum.jumpTo(_vBody.offset);
    _syncing = false;
  }

  @override
  void dispose() {
    _vBody.dispose();
    _hBody.dispose();
    _hHead.dispose();
    _vNum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widths = {
      for (final c in widget.columns) c.field: _colWidth(c.label),
    };
    final bodyH = _kViewH - _kHeaderH;

    return SizedBox(
      height: _kViewH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _Corner(),
              SizedBox(
                height: bodyH,
                child: SingleChildScrollView(
                  controller: _vNum,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      for (int i = 0; i < _kPreviewRows; i++)
                        _RowNumberCell(i),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  controller: _hHead,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: _HeaderRow(columns: widget.columns, widths: widths),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _vBody,
                    child: SingleChildScrollView(
                      controller: _hBody,
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < _kPreviewRows; i++)
                            _DataRow(
                              index: i,
                              columns: widget.columns,
                              widths: widths,
                            ),
                        ],
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
  }
}

class _Corner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kNumW,
      height: _kHeaderH,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _kHeadFill,
        border: Border(
          right: BorderSide(color: _kGridStrong, width: 1),
          bottom: BorderSide(color: _kGridStrong, width: 1.5),
        ),
      ),
      child: const Icon(Icons.grid_view_rounded, size: 16, color: _kHeadText),
    );
  }
}

class _RowNumberCell extends StatelessWidget {
  final int index;
  const _RowNumberCell(this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kNumW,
      height: _kRowH,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _kHeadFill,
        border: Border(
          right: BorderSide(color: _kGridStrong, width: 1),
          bottom: BorderSide(color: _kGrid, width: 1),
        ),
      ),
      child: Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 12,
          color: _kHeadText,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<CustomerReportColumn> columns;
  final Map<String, double> widths;
  const _HeaderRow({required this.columns, required this.widths});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < columns.length; i++)
          _HeaderCell(
            label: columns[i].label,
            width: widths[columns[i].field]!,
            letter: _colLetter(i),
          ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final String letter;
  const _HeaderCell({
    required this.label,
    required this.width,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _kHeaderH,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: _kHeadFill,
        border: Border(
          right: BorderSide(color: _kGrid, width: 1),
          bottom: BorderSide(color: _kGridStrong, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letter,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kHeadText,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kHeadLabel,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final int index;
  final List<CustomerReportColumn> columns;
  final Map<String, double> widths;
  const _DataRow({
    required this.index,
    required this.columns,
    required this.widths,
  });

  @override
  Widget build(BuildContext context) {
    final zebra = index.isEven;
    return Row(
      children: [
        for (final c in columns)
          Container(
            width: widths[c.field],
            height: _kRowH,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: zebra ? _kEmptyFill : _kZebra,
              border: const Border(
                right: BorderSide(color: _kGrid, width: 1),
                bottom: BorderSide(color: _kGrid, width: 1),
              ),
            ),
            child: Center(
              child: Container(
                width: widths[c.field]! * 0.55,
                height: 6,
                decoration: BoxDecoration(
                  color: _kMutedText.withOpacity(.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
