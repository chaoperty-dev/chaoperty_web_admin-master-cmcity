// ============================================================================
// thai_address.dart
// ============================================================================
// ข้อมูลจังหวัด/อำเภอ/ตำบล ของประเทศไทย (subset สำหรับ autocomplete)
// - ใช้สำหรับช่วยกรอกที่อยู่ใน Registration menu เท่านั้น
// - สามารถพิมพ์เองได้ถ้าไม่มีใน list (TypeAhead fallback)
// ============================================================================

class ThaiProvince {
  final String name;
  final List<ThaiDistrict> districts;

  const ThaiProvince({required this.name, required this.districts});
}

class ThaiDistrict {
  final String name;
  final List<String> subDistricts;

  const ThaiDistrict({required this.name, required this.subDistricts});
}

/// ข้อมูลจังหวัดหลักๆ ของไทย (subset)
final List<ThaiProvince> kThaiProvinces = [
  ThaiProvince(name: 'กรุงเทพมหานคร', districts: [
    ThaiDistrict(name: 'เขตพระนคร', subDistricts: [
      'พระบรมมหาราชวัง',
      'วังบูรพาภิรมย์',
      'วัดราชบพิธ',
      'สำราญราษฎร์',
      'ศาลเจ้าพ่อเสือ',
      'เสาชิงช้า',
      'บวรมงคล',
      'ตลาดยอด',
    ]),
    ThaiDistrict(name: 'เขตดุสิต', subDistricts: [
      'ดุสิต',
      'วชิรพยาบาล',
      'สวนจิตรลดา',
      'สี่แยกมหานาค',
      'บางซื่อ',
    ]),
    ThaiDistrict(name: 'เขตบางรัก', subDistricts: [
      'มหาพฤฒาราม',
      'สีลม',
      'บางรัก',
      'ราชดำริ',
    ]),
  ]),
  ThaiProvince(name: 'เชียงใหม่', districts: [
    ThaiDistrict(name: 'เมืองเชียงใหม่', subDistricts: [
      'ศรีภูมิ',
      'พระสิงห์',
      'หายยา',
      'ช้างม่อย',
      'ช้างคลาน',
      'วัดเกต',
      'วัดสะต๋อย',
      'หนองหอย',
      'ท่าศาลา',
      'ป่าตัน',
      'สันผีเสื้อ',
      'สบตุ๋ย',
      'แม่เหียะ',
      'ป่าแดด',
      'หนองควาย',
      'ฟ้าฮ่าม',
    ]),
    ThaiDistrict(name: 'เชียงดาว', subDistricts: [
      'เชียงดาว',
      'เมืองนะ',
      'เมืองงาย',
      'แม่นะ',
      'ปิงโค้ง',
      'ทุ่งข้าวพวง',
    ]),
    ThaiDistrict(name: 'แม่ริม', subDistricts: [
      'ริมใต้',
      'ริมเหนือ',
      'สันโป่ง',
      'ขี้เหล็ก',
      'สะลวง',
      'ห้วยทราย',
      'แม่แรม',
      'โป่งแยง',
      'ดอยแก้ว',
    ]),
    ThaiDistrict(name: 'สันทราย', subDistricts: [
      'สันทราย',
      'สันพระเนตร',
      'สันนาเม็ง',
      'สันป่าเปา',
      'หนองแหย่ง',
      'หนองจ๊อม',
      'หนองหาร',
      'ท่าวังพร้าว',
      'ป่าไผ่',
    ]),
    ThaiDistrict(name: 'หางดง', subDistricts: [
      'หางดง',
      'หนองแก๋ว',
      'หารแก้ว',
      'บ้านแหวน',
      'สันผักหวาน',
      'หนองตอง',
      'ขุนคง',
      'บ้านปง',
      'น้ำแพร่',
    ]),
    ThaiDistrict(name: 'แม่อาย', subDistricts: [
      'แม่อาย',
      'แม่สาว',
      'แม่นาวาง',
      'ท่าตอน',
      'บ้านหลวง',
      'มะลิกา',
      'ท่าปุย',
    ]),
    ThaiDistrict(name: 'เวียงแหง', subDistricts: [
      'เวียงแหง',
      'เปียงหลวง',
      'แสนไห',
      'ปงตำ',
      'ป่าแป๋',
    ]),
  ]),
  ThaiProvince(name: 'เชียงราย', districts: [
    ThaiDistrict(name: 'เมืองเชียงราย', subDistricts: [
      'เวียง',
      'รอบเวียง',
      'บ้านดู่',
      'นางแล',
      'แม่ข้าวต้ม',
      'แม่ยาว',
      'สันทราย',
      'ท่าสาย',
      'ดอยลาน',
      'ป่าอ้อดอนชี',
    ]),
    ThaiDistrict(name: 'เวียงชัย', subDistricts: [
      'เวียงชัย',
      'ผางาม',
      'ดงบัง',
      'ดอนศิลา',
      'หลวงใต้',
    ]),
  ]),
  ThaiProvince(name: 'ลำปาง', districts: [
    ThaiDistrict(name: 'เมืองลำปาง', subDistricts: [
      'สบตุ๋ย',
      'ต้นธงชัย',
      'นิคมพัฒนา',
      'บุญนาคพัฒนา',
      'พระบาท',
      'หัวเวียง',
      'ทุ่งฝาย',
      'บ้านเป้า',
    ]),
    ThaiDistrict(name: 'แม่เมาะ', subDistricts: [
      'แม่เมาะ',
      'บ้านดง',
      'สบป้าด',
    ]),
  ]),
  ThaiProvince(name: 'ลำพูน', districts: [
    ThaiDistrict(name: 'เมืองลำพูน', subDistricts: [
      'ในเมือง',
      'หนองช้างคืน',
      'ป่าสัก',
      'บ้านกลาง',
      'มะเขืนผ่อม',
      'ศรีบัวบาน',
      'อุโมงค์',
    ]),
    ThaiDistrict(name: 'แม่ทา', subDistricts: [
      'ทาปลาดุก',
      'ทาสบเส้า',
      'ทากาศ',
      'ทาขุมเงิน',
      'ทาทุ่งหลวง',
      'ทาแม่ลอบ',
    ]),
  ]),
  ThaiProvince(name: 'แพร่', districts: [
    ThaiDistrict(name: 'เมืองแพร่', subDistricts: [
      'ในเวียง',
      'นาจักร',
      'น้ำชา',
      'บ้านถิ่น',
      'ทุ่งโฮ้ง',
      'แม่หล่าย',
      'ห้วยข้าวก่ำ',
      'วังหงษ์',
    ]),
  ]),
  ThaiProvince(name: 'น่าน', districts: [
    ThaiDistrict(name: 'เมืองน่าน', subDistricts: [
      'ในเวียง',
      'ไชยสถาน',
      'ถืมตอง',
      'ดู่ใต้',
      'กองควาย',
      'สะเนียน',
      'บ่อ',
      'ผาสิงห์',
    ]),
  ]),
  ThaiProvince(name: 'พะเยา', districts: [
    ThaiDistrict(name: 'เมืองพะเยา', subDistricts: [
      'เวียง',
      'แม่ต๋ำ',
      'แม่กา',
      'บ้านต๋ำ',
      'บ้านตุ่น',
    ]),
  ]),
  ThaiProvince(name: 'ขอนแก่น', districts: [
    ThaiDistrict(name: 'เมืองขอนแก่น', subDistricts: [
      'ในเมือง',
      'สำราญ',
      'โคกสี',
      'ท่าพระ',
      'บ้านทุ่ม',
      'เมืองเก่า',
      'บ้านหว้า',
    ]),
  ]),
  ThaiProvince(name: 'นครราชสีมา', districts: [
    ThaiDistrict(name: 'เมืองนครราชสีมา', subDistricts: [
      'ในเมือง',
      'ตลาด',
      'พะเนา',
      'หนองกะทิง',
      'หนองไข่น้ำ',
      'ไชยมงคล',
      'บ้านโพธิ์',
    ]),
  ]),
  ThaiProvince(name: 'อุดรธานี', districts: [
    ThaiDistrict(name: 'เมืองอุดรธานี', subDistricts: [
      'หมากแข้ง',
      'นิคมสงเคราะห์',
      'บ้านขาว',
      'หนองบัว',
      'โนนสูง',
      'กุดสระ',
    ]),
  ]),
  ThaiProvince(name: 'อุบลราชธานี', districts: [
    ThaiDistrict(name: 'เมืองอุบลราชธานี', subDistricts: [
      'ในเมือง',
      'หนองบอน',
      'แจระแม',
      'คำน้ำแซบ',
    ]),
  ]),
  ThaiProvince(name: 'ชลบุรี', districts: [
    ThaiDistrict(name: 'เมืองชลบุรี', subDistricts: [
      'บางปลาสร้อย',
      'มะขามหย่ง',
      'บ้านโขด',
      'แสนสุข',
    ]),
    ThaiDistrict(name: 'ศรีราชา', subDistricts: [
      'ศรีราชา',
      'สุรศักดิ์',
      'ทุ่งสุขลา',
      'บางพระ',
    ]),
    ThaiDistrict(name: 'พัทยา', subDistricts: [
      'หนองปรือ',
      'นาเกลือ',
    ]),
  ]),
  ThaiProvince(name: 'ภูเก็ต', districts: [
    ThaiDistrict(name: 'เมืองภูเก็ต', subDistricts: [
      'ตลาดใหญ่',
      'ตลาดเหนือ',
      'เกาะแก้ว',
      'รัษฎา',
    ]),
  ]),
  ThaiProvince(name: 'สุราษฎร์ธานี', districts: [
    ThaiDistrict(name: 'เมืองสุราษฎร์ธานี', subDistricts: [
      'ตลาด',
      'มะขามเตี้ย',
      'บางใบไม้',
    ]),
  ]),
  ThaiProvince(name: 'นครศรีธรรมราช', districts: [
    ThaiDistrict(name: 'เมืองนครศรีธรรมราช', subDistricts: [
      'ในเมือง',
      'ท่าวัง',
      'นาทราย',
      'ปากนคร',
    ]),
  ]),
  ThaiProvince(name: 'สงขลา', districts: [
    ThaiDistrict(name: 'เมืองสงขลา', subDistricts: [
      'บ่อยาง',
      'เขารูปช้าง',
      'เกาะแต้ว',
    ]),
  ]),
  ThaiProvince(name: 'หาดใหญ่', districts: [
    ThaiDistrict(name: 'หาดใหญ่', subDistricts: [
      'หาดใหญ่',
      'ควนลัง',
      'คอหงส์',
      'สะเดา',
    ]),
  ]),
  ThaiProvince(name: 'นนทบุรี', districts: [
    ThaiDistrict(name: 'เมืองนนทบุรี', subDistricts: [
      'สวนใหญ่',
      'ตลาดขวัญ',
      'บางเขน',
    ]),
  ]),
  ThaiProvince(name: 'ปทุมธานี', districts: [
    ThaiDistrict(name: 'เมืองปทุมธานี', subDistricts: [
      'บางปรอก',
      'บ้านใหม่',
      'บ้านกลาง',
    ]),
  ]),
  ThaiProvince(name: 'สมุทรปราการ', districts: [
    ThaiDistrict(name: 'เมืองสมุทรปราการ', subDistricts: [
      'ปากน้ำ',
      'บางเมือง',
      'บางพูด',
    ]),
  ]),
  ThaiProvince(name: 'นครปฐม', districts: [
    ThaiDistrict(name: 'เมืองนครปฐม', subDistricts: [
      'พระปฐมเจดีย์',
      'บ่อพลับ',
      'ห้วยจรเข้',
    ]),
  ]),
  ThaiProvince(name: 'ราชบุรี', districts: [
    ThaiDistrict(name: 'เมืองราชบุรี', subDistricts: [
      'หน้าเมือง',
      'เจดีย์หัก',
      'ดอนตะโก',
    ]),
  ]),
  ThaiProvince(name: 'สุพรรณบุรี', districts: [
    ThaiDistrict(name: 'เมืองสุพรรณบุรี', subDistricts: [
      'สนามชัย',
      'บ้านโพธิ์',
      'ดอนกำยาน',
    ]),
  ]),
  ThaiProvince(name: 'อ่างทอง', districts: [
    ThaiDistrict(name: 'เมืองอ่างทอง', subDistricts: [
      'บ้านอิฐ',
      'หัวไผ่',
      'โพสะ',
    ]),
  ]),
  ThaiProvince(name: 'อยุธยา', districts: [
    ThaiDistrict(name: 'พระนครศรีอยุธยา', subDistricts: [
      'ประตูชัย',
      'หอรัตนไชย',
      'บ้านใหม่',
    ]),
  ]),
  ThaiProvince(name: 'นครสวรรค์', districts: [
    ThaiDistrict(name: 'เมืองนครสวรรค์', subDistricts: [
      'ในเมือง',
      'นครสวรรค์ออก',
      'พระนอน',
    ]),
  ]),
  ThaiProvince(name: 'กำแพงเพชร', districts: [
    ThaiDistrict(name: 'เมืองกำแพงเพชร', subDistricts: [
      'ในเมือง',
      'เทพสถิต',
      'หนองปลิง',
    ]),
  ]),
  ThaiProvince(name: 'ตาก', districts: [
    ThaiDistrict(name: 'เมืองตาก', subDistricts: [
      'ระแหง',
      'หนองหลวง',
      'ป่ามะม่วง',
    ]),
  ]),
  ThaiProvince(name: 'สุโขทัย', districts: [
    ThaiDistrict(name: 'เมืองสุโขทัย', subDistricts: [
      'ธานี',
      'บ้านสวน',
      'ยางซ้าย',
    ]),
  ]),
  ThaiProvince(name: 'พิษณุโลก', districts: [
    ThaiDistrict(name: 'เมืองพิษณุโลก', subDistricts: [
      'ในเมือง',
      'อรัญญิก',
      'บึงพระ',
    ]),
  ]),
  ThaiProvince(name: 'เพชรบูรณ์', districts: [
    ThaiDistrict(name: 'เมืองเพชรบูรณ์', subDistricts: [
      'ในเมือง',
      'ตะเบาะ',
      'บ้านโคก',
    ]),
  ]),
  ThaiProvince(name: 'ระยอง', districts: [
    ThaiDistrict(name: 'เมืองระยอง', subDistricts: [
      'ท่าประดู่',
      'เชิงเนิน',
      'ตลาด',
    ]),
  ]),
  ThaiProvince(name: 'จันทบุรี', districts: [
    ThaiDistrict(name: 'เมืองจันทบุรี', subDistricts: [
      'วัดใหม่',
      'ตลาด',
      'คมบาง',
    ]),
  ]),
  ThaiProvince(name: 'ตราด', districts: [
    ThaiDistrict(name: 'เมืองตราด', subDistricts: [
      'วังกะจะ',
      'บางพระ',
      'หนองเสม็ด',
    ]),
  ]),
  ThaiProvince(name: 'ปราจีนบุรี', districts: [
    ThaiDistrict(name: 'เมืองปราจีนบุรี', subDistricts: [
      'หน้าเมือง',
      'บางบริบูรณ์',
      'เมืองใหม่',
    ]),
  ]),
  ThaiProvince(name: 'สระแก้ว', districts: [
    ThaiDistrict(name: 'เมืองสระแก้ว', subDistricts: [
      'สระแก้ว',
      'บ้านแดง',
      'โคกสูง',
    ]),
  ]),
  ThaiProvince(name: 'ประจวบคีรีขันธ์', districts: [
    ThaiDistrict(name: 'เมืองประจวบคีรีขันธ์', subDistricts: [
      'ประจวบคีรีขันธ์',
      'เกาะหลัว',
      'อ่าวน้อย',
    ]),
  ]),
  ThaiProvince(name: 'เพชรบุรี', districts: [
    ThaiDistrict(name: 'เมืองเพชรบุรี', subDistricts: [
      'ชะอำ',
      'บ้านหม้อ',
      'นาวังหิน',
    ]),
  ]),
  ThaiProvince(name: 'ชุมพร', districts: [
    ThaiDistrict(name: 'เมืองชุมพร', subDistricts: [
      'ท่าตะเภา',
      'นาชะอัง',
      'ขุนกระทิง',
    ]),
  ]),
  ThaiProvince(name: 'ระนอง', districts: [
    ThaiDistrict(name: 'เมืองระนอง', subDistricts: [
      'เขานิเวศน์',
      'ราชกรูด',
      'บางริ้น',
    ]),
  ]),
  ThaiProvince(name: 'กระบี่', districts: [
    ThaiDistrict(name: 'เมืองกระบี่', subDistricts: [
      'ปากน้ำ',
      'กระบี่น้อย',
      'ไสไทย',
    ]),
  ]),
  ThaiProvince(name: 'พังงา', districts: [
    ThaiDistrict(name: 'เมืองพังงา', subDistricts: [
      'ท้ายช้าง',
      'นบปริง',
      'ทุ่งคาโตน',
    ]),
  ]),
  ThaiProvince(name: 'ตรัง', districts: [
    ThaiDistrict(name: 'เมืองตรัง', subDistricts: [
      'ทับเที่ยง',
      'นาท่ามเหนือ',
      'นาท่ามใต้',
    ]),
  ]),
  ThaiProvince(name: 'พัทลุง', districts: [
    ThaiDistrict(name: 'เมืองพัทลุง', subDistricts: [
      'คูหาสวรรค์',
      'ท่ามะเดื่อ',
      'ลำปำ',
    ]),
  ]),
  ThaiProvince(name: 'สตูล', districts: [
    ThaiDistrict(name: 'เมืองสตูล', subDistricts: [
      'พิชัย',
      'บุดี',
      'คลองขุด',
    ]),
  ]),
  ThaiProvince(name: 'ยะลา', districts: [
    ThaiDistrict(name: 'เมืองยะลา', subDistricts: [
      'สะเตง',
      'บุดี',
      'ยุโป',
    ]),
  ]),
  ThaiProvince(name: 'ปัตตานี', districts: [
    ThaiDistrict(name: 'เมืองปัตตานี', subDistricts: [
      'สะบารัง',
      'บานา',
      'รูสะมิแล',
    ]),
  ]),
  ThaiProvince(name: 'นราธิวาส', districts: [
    ThaiDistrict(name: 'เมืองนราธิวาส', subDistricts: [
      'บางนาค',
      'มะนังตายอ',
      'ลำภู',
    ]),
  ]),
];

// ============================================================================
// Helper functions
// ============================================================================

/// หา district list ตามชื่อจังหวัด (case-insensitive)
List<ThaiDistrict> districtsOf(String provinceName) {
  for (final p in kThaiProvinces) {
    if (p.name == provinceName) return p.districts;
  }
  return const [];
}

/// หา sub-districts ตามจังหวัด + อำเภอ
List<String> subDistrictsOf(String provinceName, String districtName) {
  for (final d in districtsOf(provinceName)) {
    if (d.name == districtName) return d.subDistricts;
  }
  return const [];
}

/// ตรวจสอบว่า query เป็น Latin หรือไม่ (ใช้ fallback ดูทั้งหมด)
bool _isLatin(String s) {
  return RegExp(r'^[a-zA-Z\s]+$').hasMatch(s.trim());
}

/// ค้นหาจังหวัดที่ตรง/ขึ้นต้นด้วย prefix (autocomplete)
List<String> filterProvinces(String query, {int limit = 20}) {
  final q = query.trim();
  // ถ้าว่างหรือเป็น Latin → คืนทั้งหมด
  if (q.isEmpty || _isLatin(q)) {
    return kThaiProvinces.take(limit).map((p) => p.name).toList();
  }
  final out = <String>[];
  for (final p in kThaiProvinces) {
    if (p.name.contains(q) || p.name.startsWith(q)) {
      out.add(p.name);
      if (out.length >= limit) break;
    }
  }
  return out;
}

/// ค้นหาอำเภอในจังหวัด
List<String> filterDistricts(String provinceName, String query,
    {int limit = 20}) {
  final list = districtsOf(provinceName);
  if (list.isEmpty) return const [];
  final q = query.trim();
  // ถ้าว่างหรือเป็น Latin → คืนทั้งหมด
  if (q.isEmpty || _isLatin(q)) {
    return list.take(limit).map((d) => d.name).toList();
  }
  final out = <String>[];
  for (final d in list) {
    if (d.name.contains(q) || d.name.startsWith(q)) {
      out.add(d.name);
      if (out.length >= limit) break;
    }
  }
  return out;
}

/// ค้นหาตำบลในอำเภอ+จังหวัด
List<String> filterSubDistricts(
    String provinceName, String districtName, String query,
    {int limit = 20}) {
  final list = subDistrictsOf(provinceName, districtName);
  if (list.isEmpty) return const [];
  final q = query.trim();
  // ถ้าว่างหรือเป็น Latin → คืนทั้งหมด
  if (q.isEmpty || _isLatin(q)) {
    return list.take(limit).toList();
  }
  final out = <String>[];
  for (final s in list) {
    if (s.contains(q) || s.startsWith(q)) {
      out.add(s);
      if (out.length >= limit) break;
    }
  }
  return out;
}

/// ค้นหารหัสไปรษณีย์
/// - ถ้ามี zipcodeMap สำหรับจังหวัด+อำเภอ+ตำบล → ใช้ข้อมูลนั้น
/// - ถ้าไม่มี → ใช้ zipcodeMap ของจังหวัดแรกที่ match
List<String> filterZipcodes(
  String provinceName,
  String districtName,
  String subDistrictName,
  String query, {
  int limit = 20,
}) {
  final prov = (provinceName ?? '').isEmpty
      ? (kThaiProvinces.isNotEmpty ? kThaiProvinces.first.name : '')
      : provinceName;
  final ds = districtsOf(prov);
  final dist = (districtName ?? '').isEmpty
      ? (ds.isNotEmpty ? ds.first.name : '')
      : districtName;

  // zipcodeMap: province → district → zipcodes
  final byProv = kZipcodeMap[prov] ?? const <String, List<String>>{};
  final zips = byProv[dist] ?? const <String>[];

  // fallback: ถ้าไม่เจอ zipcode สำหรับอำเภอนั้น → ใช้ zipcode ของอำเภอแรกของจังหวัด
  final pool = zips.isNotEmpty
      ? zips
      : (ds.isNotEmpty
          ? (byProv[ds.first.name] ?? const <String>[])
          : const <String>[]);

  if (pool.isEmpty) {
    // fallback สุดท้าย: zipcode เริ่มต้นของจังหวัด
    if (prov == 'เชียงใหม่') return const ['50000', '50100', '50200', '50300'];
    if (prov == 'กรุงเทพมหานคร')
      return const [
        '10110',
        '10120',
        '10130',
        '10140',
        '10150',
        '10160',
        '10170',
        '10210'
      ];
    return const [];
  }

  final q = query.trim();
  // ถ้าว่างหรือเป็น Latin → คืนทั้งหมด
  if (q.isEmpty || _isLatin(q)) {
    return pool.take(limit).toList();
  }
  final out = <String>[];
  for (final z in pool) {
    if (z.contains(q) || z.startsWith(q)) {
      out.add(z);
      if (out.length >= limit) break;
    }
  }
  return out;
}

// ============================================================================
// ZIPCODE MAP (subset)
// province → district → [zipcode, ...]
// ============================================================================

const Map<String, Map<String, List<String>>> kZipcodeMap = {
  'เชียงใหม่': {
    'เมืองเชียงใหม่': ['50000', '50100', '50200', '50300'],
    'เชียงดาว': ['50170'],
    'แม่ริม': ['50180'],
    'สันทราย': ['50210'],
    'หางดง': ['50230'],
    'แม่อาย': ['50290'],
    'เวียงแหง': ['50350'],
  },
  'กรุงเทพมหานคร': {
    'เขตพระนคร': ['10200'],
    'เขตดุสิต': ['10300'],
    'เขตบางรัก': ['10500'],
  },
  'เชียงราย': {
    'เมืองเชียงราย': ['57000'],
    'เวียงชัย': ['57210']
  },
  'ลำปาง': {
    'เมืองลำปาง': ['52000', '52100'],
    'แม่เมาะ': ['52220']
  },
  'ลำพูน': {
    'เมืองลำพูน': ['51000'],
    'แม่ทา': ['51140']
  },
  'แพร่': {
    'เมืองแพร่': ['54000']
  },
  'น่าน': {
    'เมืองน่าน': ['55000']
  },
  'พะเยา': {
    'เมืองพะเยา': ['56000']
  },
  'ขอนแก่น': {
    'เมืองขอนแก่น': ['40000']
  },
  'นครราชสีมา': {
    'เมืองนครราชสีมา': ['30000']
  },
  'อุดรธานี': {
    'เมืองอุดรธานี': ['41000']
  },
  'อุบลราชธานี': {
    'เมืองอุบลราชธานี': ['34000']
  },
  'ชลบุรี': {
    'เมืองชลบุรี': ['20000'],
    'ศรีราชา': ['20110'],
    'พัทยา': ['20150']
  },
  'ภูเก็ต': {
    'เมืองภูเก็ต': ['83000']
  },
  'สุราษฎร์ธานี': {
    'เมืองสุราษฎร์ธานี': ['84000']
  },
  'นครศรีธรรมราช': {
    'เมืองนครศรีธรรมราช': ['80000']
  },
  'สงขลา': {
    'เมืองสงขลา': ['90000']
  },
  'หาดใหญ่': {
    'หาดใหญ่': ['90110']
  },
  'นนทบุรี': {
    'เมืองนนทบุรี': ['11000']
  },
  'ปทุมธานี': {
    'เมืองปทุมธานี': ['12000']
  },
  'สมุทรปราการ': {
    'เมืองสมุทรปราการ': ['10270']
  },
  'นครปฐม': {
    'เมืองนครปฐม': ['73000']
  },
  'ราชบุรี': {
    'เมืองราชบุรี': ['70000']
  },
  'สุพรรณบุรี': {
    'เมืองสุพรรณบุรี': ['72000']
  },
  'อ่างทอง': {
    'เมืองอ่างทอง': ['14000']
  },
  'อยุธยา': {
    'พระนครศรีอยุธยา': ['13000']
  },
  'นครสวรรค์': {
    'เมืองนครสวรรค์': ['60000']
  },
  'กำแพงเพชร': {
    'เมืองกำแพงเพชร': ['62000']
  },
  'ตาก': {
    'เมืองตาก': ['63000']
  },
  'สุโขทัย': {
    'เมืองสุโขทัย': ['64000']
  },
  'พิษณุโลก': {
    'เมืองพิษณุโลก': ['65000']
  },
  'เพชรบูรณ์': {
    'เมืองเพชรบูรณ์': ['67000']
  },
  'ระยอง': {
    'เมืองระยอง': ['21000']
  },
  'จันทบุรี': {
    'เมืองจันทบุรี': ['22000']
  },
  'ตราด': {
    'เมืองตราด': ['23000']
  },
  'ปราจีนบุรี': {
    'เมืองปราจีนบุรี': ['25000']
  },
  'สระแก้ว': {
    'เมืองสระแก้ว': ['27000']
  },
  'ประจวบคีรีขันธ์': {
    'เมืองประจวบคีรีขันธ์': ['77000']
  },
  'เพชรบุรี': {
    'เมืองเพชรบุรี': ['76000']
  },
  'ชุมพร': {
    'เมืองชุมพร': ['86000']
  },
  'ระนอง': {
    'เมืองระนอง': ['85000']
  },
  'กระบี่': {
    'เมืองกระบี่': ['81000']
  },
  'พังงา': {
    'เมืองพังงา': ['82000']
  },
  'ตรัง': {
    'เมืองตรัง': ['92000']
  },
  'พัทลุง': {
    'เมืองพัทลุง': ['93000']
  },
  'สตูล': {
    'เมืองสตูล': ['91000']
  },
  'ยะลา': {
    'เมืองยะลา': ['95000']
  },
  'ปัตตานี': {
    'เมืองปัตตานี': ['94000']
  },
  'นราธิวาส': {
    'เมืองนราธิวาส': ['96000']
  },
};
