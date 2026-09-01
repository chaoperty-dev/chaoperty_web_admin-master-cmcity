// ============================================================================
// areas_report_preview.dart
// ============================================================================
// ตัวอย่างตาราง (Preview) แบบคล้าย Excel
// - อิงจากคอลัมน์ที่ผู้ใช้เลือก (ติ๊ก) + ลำดับที่เรียงใน ColumnPicker
// - จำลองข้อมูล 10 แถว (mock) เพื่อดูหน้าตาข้อมูลก่อนส่งออกไฟล์
// - คอลัมน์จะเปลี่ยนลำดับ/แสดง-ซ่อน ทันทีตามที่เลือกใน picker ด้านบน
// - สไตล์ Excel: หัวตารางแช่แข็ง (frozen) + คอลัมน์เลขแถวค้าง + ตัวอักษร A/B/C
//   + เส้นกริด + แถวสลับสี (zebra)
//
// ✅ ใช้ Selector — rebuild เฉพาะตอน columns / selected เปลี่ยน
//    ไม่ rebuild ตอน isExporting / totalArea / phase เปลี่ยน
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/areas_report_view_model.dart';
import '../../services/areas_report_service.dart';
import '../../../customers/views/theme/customers_report_theme.dart';

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

/// Snapshot ของ state ที่ preview ต้องใช้
class _PreviewData {
  final List<AreasReportColumn> columns;
  // ✅ เก็บเป็น copy — ป้องกันปัญหา Set เดียวกันถูก mutate แล้วเทียบเท่ากัน
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

class AreasReportPreview extends StatelessWidget {
  const AreasReportPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AreasReportViewModel, _PreviewData>(
      selector: (_, vm) => _PreviewData(
        // columns เรียงตามลำดับที่ผู้ใช้ drag เรียงใน picker แล้ว
        columns: vm.columns,
        // copy เพื่อให้ equality เทียบได้ถูกต้องแม้ VM จะ mutate Set เดิม
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
              // ─── Header bar ───
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
            Icon(Icons.checklist_outlined,
                size: 32, color: CrColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'เลือกคอลัมน์ด้านบนเพื่อดูตัวอย่างตาราง',
              style: CrText.bodyMuted,
            ),
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

/// ============================================================
/// _PreviewTable — Excel sheet
/// - คอลัมน์เลขแถว (1..N) ด้านซ้าย แช่แข็งตอนเลื่อนแนวนอน
/// - หัวตาราง (A/B/C + label) แช่แข็งตอนเลื่อนแนวตั้ง + เลื่อนตามแนวนอน
///   ด้วย ScrollController ที่ sync กัน
/// ============================================================
class _PreviewTable extends StatefulWidget {
  final List<AreasReportColumn> columns;
  const _PreviewTable({required this.columns});

  @override
  State<_PreviewTable> createState() => _PreviewTableState();
}

class _PreviewTableState extends State<_PreviewTable> {
  late final ScrollController _vBody; // body vertical
  late final ScrollController _hBody; // body horizontal
  late final ScrollController _hHead; // header horizontal (sync)
  late final ScrollController _vNum; // row-number vertical (sync)
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
        // ✅ stretch ให้คอลัมน์ทั้งสองได้ความสูงคงที่ (460)
        //    ไม่งั้น data column จะ unbounded → SingleChildScrollView วินาทีนี้พัง
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── คอลัมน์เลขแถว (แช่แข็งแนวนอน) ───
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

          // ─── ตารางข้อมูล ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // หัวตาราง (A/B/C) — sync แนวนอนกับ body
                SingleChildScrollView(
                  controller: _hHead,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: _HeaderRow(columns: widget.columns, widths: widths),
                ),
                // เนื้อหา — scroll ได้ทั้ง 2 แกน
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
      child: const Icon(Icons.grid_view_rounded,
          size: 16, color: _kHeadText),
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
  final List<AreasReportColumn> columns;
  final Map<String, double> widths;
  const _HeaderRow({required this.columns, required this.widths});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < columns.length; i++)
          _HeaderCell(label: columns[i].label, width: widths[columns[i].field]!, letter: _colLetter(i)),
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
  final List<AreasReportColumn> columns;
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
            width: widths[c.field]!,
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
