// ============================================================================
// license_contract_result.dart
// ============================================================================
// Data class สำหรับส่งค่าผลลัพธ์กลับเมื่อผู้ใช้กดบันทึก Step 1 (ข้อมูลผู้เช่า)
// ============================================================================

class LicenseContractResult {
  final List<String> personValues;
  final List<String> shopValues;
  final List<String> shopSubValues;
  final List<Map<String, dynamic>> cidValues;
  final String? zn; // โซน
  final String? ln; // รหัสพื้นที่
  final String? zser; // zone serial
  final String? aser; // area serial
  final String? scname; // ชื่อร้าน
  final String? uuid; // uuid ที่ได้จาก API POST /admin/requests

  const LicenseContractResult({
    required this.personValues,
    required this.shopValues,
    required this.shopSubValues,
    required this.cidValues,
    this.zn,
    this.ln,
    this.zser,
    this.aser,
    this.scname,
    this.uuid,
  });
}
