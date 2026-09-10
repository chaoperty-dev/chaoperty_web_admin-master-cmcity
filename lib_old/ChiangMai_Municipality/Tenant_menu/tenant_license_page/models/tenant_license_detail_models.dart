// ============================================================================
// tenant_license_detail_models.dart
// ============================================================================
// Models สำหรับหน้า detail 2 step (ผู้เช่า)
// - สร้างเองทั้งหมด ไม่ดึงจาก project อื่น
// - ใช้กับ step1 (ข้อมูล) และ step2 (รูปภาพ)
// ============================================================================

/// ฟิลด์ข้อมูลผู้เช่า (เช่น ชื่อ, เลขบัตร, ที่อยู่, เบอร์โทร)
/// - สามารถดึงค่าจาก TeNantModel ผ่าน `valueResolver` ได้
class TenantPersonField {
  final String ser;
  final String title;
  String detail;
  final IconHint iconHint;
  final String Function(dynamic tenant)? valueResolver;

  TenantPersonField({
    required this.ser,
    required this.title,
    this.detail = '',
    this.iconHint = IconHint.person,
    this.valueResolver,
  });
}

/// ฟิลด์ย่อยของร้านค้า (เช่น บริเวณ, โซน, ล็อก)
class TenantShopSubField {
  final String ser;
  final String titlesub;
  String detail;
  final String Function(dynamic tenant)? valueResolver;

  TenantShopSubField({
    required this.ser,
    required this.titlesub,
    this.detail = '',
    this.valueResolver,
  });
}

/// ฟิลด์ข้อมูลร้านค้า
class TenantShopField {
  final String ser;
  final String title;
  String detail;
  final List<TenantShopSubField> detailsub;
  final IconHint iconHint;
  final String Function(dynamic tenant)? valueResolver;

  TenantShopField({
    required this.ser,
    required this.title,
    this.detail = '',
    this.detailsub = const [],
    this.iconHint = IconHint.shop,
    this.valueResolver,
  });
}

/// เอกสาร (เช่น ใบคำร้อง, ใบอนุญาต)
class TenantDocument {
  final String ser;
  final String title;
  final String detail;

  const TenantDocument({
    required this.ser,
    required this.title,
    required this.detail,
  });
}

/// ใบเสร็จ
class TenantReceipt {
  final String ser;
  final String no;
  final String date;
  final String status;
  final String verify;

  const TenantReceipt({
    required this.ser,
    required this.no,
    required this.date,
    required this.status,
    required this.verify,
  });
}

/// รูปภาพหลักฐาน (step2)
class TenantPhoto {
  final String ser;
  final String title;
  final String? imageUrl;
  final String? remark;

  const TenantPhoto({
    required this.ser,
    required this.title,
    this.imageUrl,
    this.remark,
  });
}

/// Hint สำหรับเลือก icon ตามหัวข้อ
enum IconHint {
  person,
  badge,
  cake,
  flag,
  home,
  phone,
  note,
  shop,
  area,
  zone,
  locker,
  type,
  storeName,
  doc,
  receipt,
  image,
}

// ============================================================================
// Mock datasets — ข้อมูลเริ่มต้นตามแบบ Info_contract_cmm
// ============================================================================

// ============================================================================
// Helper — ดึง string จาก dynamic (กัน NPE)
// ============================================================================
String? _s(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty || s == 'null' ? null : s;
}

String _resolver(dynamic tenant, String? Function(dynamic t) pick) {
  if (tenant == null) return '';
  final v = pick(tenant);
  return v ?? '';
}

final List<TenantPersonField> tenantPersonFields = [
  TenantPersonField(
    ser: '1',
    title: 'ชื่อ-นามสกุล*',
    iconHint: IconHint.person,
    valueResolver: (t) => _resolver(t, (x) => _s(x.cname)),
  ),
  TenantPersonField(
    ser: '2',
    title: 'เลขบัตรประจำตัวประชาชน*',
    iconHint: IconHint.badge,
    valueResolver: (t) => _resolver(t, (x) => _s(x.cid)),
  ),
  TenantPersonField(
    ser: '3',
    title: 'อายุ*',
    iconHint: IconHint.cake,
    valueResolver: (t) => '',
  ),
  TenantPersonField(
    ser: '4',
    title: 'สัญชาติ*',
    iconHint: IconHint.flag,
    valueResolver: (t) => _resolver(t, (x) => _s(x.ctype)),
  ),
  TenantPersonField(
    ser: '5',
    title: 'บ้านเลขที่*',
    iconHint: IconHint.home,
    valueResolver: (t) => _resolver(t, (x) => _s(x.addr)),
  ),
  TenantPersonField(
    ser: '6',
    title: 'เบอร์โทร*',
    iconHint: IconHint.phone,
    valueResolver: (t) => _resolver(t, (x) => _s(x.tel)),
  ),
];

final List<TenantShopField> tenantShopFields = [
  TenantShopField(
    ser: '1',
    title: 'พื้นที่เช่า (ตร.ม.)',
    iconHint: IconHint.area,
    valueResolver: (t) => _resolver(t, (x) => _s(x.area)),
    detailsub: [
      TenantShopSubField(
        ser: '1',
        titlesub: 'บริเวณ',
        valueResolver: (t) => _resolver(t, (x) => _s(x.subzone)),
      ),
      TenantShopSubField(
        ser: '2',
        titlesub: 'โซน',
        valueResolver: (t) => _resolver(t, (x) => _s(x.zn)),
      ),
      TenantShopSubField(
        ser: '3',
        titlesub: 'ล็อกที่',
        valueResolver: (t) => _resolver(t, (x) => _s(x.ln)),
      ),
    ],
  ),
  TenantShopField(
    ser: '2',
    title: 'ขนาดพื้นที่เช่า (ตร.ม.)',
    iconHint: IconHint.area,
    valueResolver: (t) => _resolver(t, (x) => _s(x.area_c)),
  ),
  TenantShopField(
    ser: '3',
    title: 'ประเภทสินค้า',
    iconHint: IconHint.type,
    valueResolver: (t) => _resolver(t, (x) => _s(x.stype)),
  ),
  TenantShopField(
    ser: '4',
    title: 'ชื่อร้าน',
    iconHint: IconHint.storeName,
    valueResolver: (t) => _resolver(t, (x) => _s(x.sname)),
  ),
];

const List<TenantDocument> tenantDocuments = [
  TenantDocument(
    ser: '1',
    title:
        'ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ',
    detail: 'GeneratePDF_1',
  ),
  TenantDocument(
    ser: '2',
    title:
        'ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ',
    detail: 'GeneratePDF_2',
  ),
  TenantDocument(
    ser: '3',
    title: 'ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ',
    detail: 'GeneratePDF_3',
  ),
];

const List<TenantReceipt> tenantReceipts = [
  TenantReceipt(
    ser: '1',
    no: 'R68-04-000001',
    date: '21-04-2025',
    status: 'รอตรวจสอบ',
    verify: '-',
  ),
];

const List<TenantPhoto> tenantPhotos = [
  TenantPhoto(ser: '1', title: 'รูปถ่ายผู้เช่า'),
  TenantPhoto(ser: '2', title: 'รูปถ่ายคู่กับร้านค้าและสินค้า'),
  TenantPhoto(ser: '3', title: 'รูปถ่ายสินค้า'),
  TenantPhoto(ser: '4', title: 'รูปถ่ายสถานที่ตั้งร้าน'),
];
