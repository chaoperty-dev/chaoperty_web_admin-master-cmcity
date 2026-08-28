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
const double _kHeaderH = 46;
const double _kRowH = 34;
const double _kNumW = 44;
const double _kViewH = 460;
const Color _kHeadFill = Color(0xFFF1F3F4);
const Color _kGrid = Color(0xFFD0D7DE);
const Color _kGridStrong = Color(0xFFB6BEC8);
const Color _kZebra = Color(0xFFF8F9FA);
const Color _kHeadText = Color(0xFF5F6368);
const Color _kHeadLabel = Color(0xFF202124);
const Color _kBodyText = Color(0xFF202124);

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
                          : '${visible.length} คอลัมน์ · 10 แถว (จำลอง)',
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
                  'ข้อมูลนี้เป็นการจำลอง (mock) เพื่อดูรูปแบบก่อนส่งออก '
                  'เมื่อกดดาวน์โหลดจะใช้ข้อมูลจริงจากระบบ',
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
/// ข้อมูลจำลอง 10 แถว (ลูกค้า)
/// ============================================================
const List<CustomerReportItem> _mockRows = [
  CustomerReportItem(
    uuid: 'c-uuid-001',
    custno: 'K-2001',
    taxno: '0-1234-56789-01',
    scname: 'ชัยวัฒน์',
    sname: 'ชัยวัฒน์',
    cname: 'บริษัท ชัยวัฒน์ จำกัด (มหาชน)',
    branch: 'สาขาเชียงใหม่',
    attn: 'นายสมชาย ใจดี',
    addr1: '123 ถนนเจ็ดยอด',
    addr2: 'ต.สุเทพ อ.เมือง',
    zip: '50200',
    tel: '053-222-333',
    tax: '0-1234-56789-01',
    fax: '053-222-334',
    email: 'contact@chaiwat.co.th',
    lineid: '@chaiwat',
    status: 'active',
    st: 1,
    birth: '1980-05-12',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-002',
    custno: 'K-2002',
    taxno: '0-2345-67890-02',
    scname: 'สมหญิง',
    sname: 'สมหญิง',
    cname: 'นางสาวสมหญิง รักเรียน',
    branch: 'สำนักงานใหญ่',
    attn: 'นางสาวสมหญิง รักเรียน',
    addr1: '45 ถนนนิมมาน',
    addr2: 'ต.สุเทพ อ.เมือง',
    zip: '50200',
    tel: '053-333-444',
    tax: '0-2345-67890-02',
    fax: '053-333-445',
    email: 'somying@mail.com',
    lineid: '@somying',
    status: 'active',
    st: 1,
    birth: '1985-09-23',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-003',
    custno: 'K-2003',
    taxno: '0-3456-78901-03',
    scname: 'วิชัย',
    sname: 'วิชัย',
    cname: 'นายวิชัย สุขสบาย',
    branch: 'สาขาเชียงราย',
    attn: 'นายวิชัย สุขสบาย',
    addr1: '9 ถนนพหลโยธิน',
    addr2: 'ต.เวียง อ.เมือง',
    zip: '57000',
    tel: '053-444-555',
    tax: '0-3456-78901-03',
    fax: '053-444-556',
    email: 'wichai@mail.com',
    lineid: '@wichai',
    status: 'pending',
    st: 0,
    birth: '1978-12-01',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-004',
    custno: 'K-2004',
    taxno: '0-4567-89012-04',
    scname: 'สุดา',
    sname: 'สุดา',
    cname: 'นางสุดา ภู่วงศ์',
    branch: 'สาขาลำปาง',
    attn: 'นางสุดา ภู่วงศ์',
    addr1: '78 ถนนพหลโยธิน',
    addr2: 'ต.สวนดอก อ.เมือง',
    zip: '52000',
    tel: '054-555-666',
    tax: '0-4567-89012-04',
    fax: '054-555-667',
    email: 'suda@mail.com',
    lineid: '@suda',
    status: 'active',
    st: 1,
    birth: '1990-03-15',
    national: 'ไทย',
    religion: 'อิสลาม',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-005',
    custno: 'K-2005',
    taxno: '0-5678-90123-05',
    scname: 'อนันต์',
    sname: 'อนันต์',
    cname: 'นายอนันต์ คงทน',
    branch: 'สาขาแพร่',
    attn: 'นายอนันต์ คงทน',
    addr1: '12 ถนนยันตรกิจ',
    addr2: 'ต.อารยา อ.เมือง',
    zip: '54000',
    tel: '054-666-777',
    tax: '0-5678-90123-05',
    fax: '054-666-778',
    email: 'anan@mail.com',
    lineid: '@anan',
    status: 'expired',
    st: 0,
    birth: '1975-07-30',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-006',
    custno: 'K-2006',
    taxno: '0-6789-01234-06',
    scname: 'ปิยะ',
    sname: 'ปิยะ',
    cname: 'นางสาวปิยะ มานะ',
    branch: 'สาขาเชียงใหม่',
    attn: 'นางสาวปิยะ มานะ',
    addr1: '234 ถนนห้วยแก้ว',
    addr2: 'ต.ช้างเผือก อ.เมือง',
    zip: '50300',
    tel: '053-777-888',
    tax: '0-6789-01234-06',
    fax: '053-777-889',
    email: 'piya@mail.com',
    lineid: '@piya',
    status: 'active',
    st: 1,
    birth: '1992-11-05',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-007',
    custno: 'K-2007',
    taxno: '0-7890-12345-07',
    scname: 'เกียรติ',
    sname: 'เกียรติ',
    cname: 'นายเกียรติ ชื่นชม',
    branch: 'สำนักงานใหญ่',
    attn: 'นายเกียรติ ชื่นชม',
    addr1: '56 ถนนมหิดล',
    addr2: 'ต.ป่าตัน อ.เมือง',
    zip: '50100',
    tel: '053-888-999',
    tax: '0-7890-12345-07',
    fax: '053-888-990',
    email: 'kiat@mail.com',
    lineid: '@kiat',
    status: 'pending',
    st: 0,
    birth: '1983-02-18',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-008',
    custno: 'K-2008',
    taxno: '0-8901-23456-08',
    scname: 'รัตนา',
    sname: 'รัตนา',
    cname: 'นางรัตนา แสงทอง',
    branch: 'สาขาลำพูน',
    attn: 'นางรัตนา แสงทอง',
    addr1: '321 ถนนรอบเมือง',
    addr2: 'ต.ในเมือง อ.เมือง',
    zip: '51000',
    tel: '054-999-000',
    tax: '0-8901-23456-08',
    fax: '054-999-001',
    email: 'rattana@mail.com',
    lineid: '@rattana',
    status: 'active',
    st: 1,
    birth: '1988-06-25',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-009',
    custno: 'K-2009',
    taxno: '0-9012-34567-09',
    scname: 'ธนู',
    sname: 'ธนู',
    cname: 'นายธนู พลธนู',
    branch: 'สาขาเชียงราย',
    attn: 'นายธนู พลธนู',
    addr1: '88 ถนนเจ็ดยอด',
    addr2: 'ต.เวียง อ.เมือง',
    zip: '57000',
    tel: '053-111-222',
    tax: '0-9012-34567-09',
    fax: '053-111-223',
    email: 'thanu@mail.com',
    lineid: '@thanu',
    status: 'active',
    st: 1,
    birth: '1995-01-09',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
  CustomerReportItem(
    uuid: 'c-uuid-010',
    custno: 'K-2010',
    taxno: '0-0123-45678-10',
    scname: 'เอื้อมพร',
    sname: 'เอื้อมพร',
    cname: 'นางสาวเอื้อมพร ทองคำ',
    branch: 'สำนักงานใหญ่',
    attn: 'นางสาวเอื้อมพร ทองคำ',
    addr1: '10 ถนนนิมมานเหมินท์',
    addr2: 'ต.สุเทพ อ.เมือง',
    zip: '50200',
    tel: '053-222-111',
    tax: '0-0123-45678-10',
    fax: '053-222-112',
    email: 'uemporn@mail.com',
    lineid: '@uemporn',
    status: 'expired',
    st: 0,
    birth: '1986-08-14',
    national: 'ไทย',
    religion: 'พุทธ',
  ),
];

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
                      for (int i = 0; i < _mockRows.length; i++)
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
                          for (int i = 0; i < _mockRows.length; i++)
                            _DataRow(
                              index: i,
                              item: _mockRows[i],
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
  final CustomerReportItem item;
  final List<CustomerReportColumn> columns;
  final Map<String, double> widths;
  const _DataRow({
    required this.index,
    required this.item,
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
              color: zebra ? Colors.white : _kZebra,
              border: const Border(
                right: BorderSide(color: _kGrid, width: 1),
                bottom: BorderSide(color: _kGrid, width: 1),
              ),
            ),
            child: Text(
              item.getBy(c.field) ?? '-',
              style: const TextStyle(
                fontSize: 12.5,
                fontFamily: 'monospace',
                color: _kBodyText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
