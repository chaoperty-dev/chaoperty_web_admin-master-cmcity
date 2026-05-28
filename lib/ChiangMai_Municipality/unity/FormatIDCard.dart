String formatThaiIdCard(String? id) {
  if (id == null || id.trim().isEmpty) return '';
  final digits = id.replaceAll(RegExp(r'\D'), ''); // ลบอักขระที่ไม่ใช่ตัวเลข

  if (digits.length != 13) return id; // ถ้าไม่ครบ 13 หลัก ให้คืนค่าเดิม

  return '${digits.substring(0, 1)}-${digits.substring(1, 5)}-${digits.substring(5, 10)}-${digits.substring(10, 12)}-${digits.substring(12)}';
}
