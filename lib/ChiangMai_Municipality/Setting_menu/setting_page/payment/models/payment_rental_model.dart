// ============================================================================
// payment_rental_model.dart
// ============================================================================
// Model: Rental (ข้อมูลร้าน/ผู้เช่า) ใช้แสดงบริบท + ตั้งค่า slip folder
// เขียนใหม่ทั้งหมด ไม่ reuse RenTalModel เดิม
// ============================================================================

class PaymentRentalModel {
  final String ser;
  final String rtname;
  final String pn;
  final String dbn;
  final String foder;
  final String? temPage;
  final String? timeCheck;
  final String? type;
  final String? typex;

  const PaymentRentalModel({
    required this.ser,
    required this.rtname,
    required this.pn,
    required this.dbn,
    this.foder = '',
    this.temPage,
    this.timeCheck,
    this.type,
    this.typex,
  });

  factory PaymentRentalModel.fromJson(Map<String, dynamic> json) {
    return PaymentRentalModel(
      ser: (json['ser'] ?? '0').toString(),
      rtname: (json['rtname'] ?? '').toString(),
      pn: (json['pn'] ?? '').toString(),
      dbn: (json['dbn'] ?? '').toString(),
      foder: (json['foder'] ?? '').toString(),
      temPage: json['tem_page']?.toString() ?? json['temPage']?.toString(),
      timeCheck:
          json['time_check']?.toString() ?? json['timeCheck']?.toString(),
      type: json['type']?.toString(),
      typex: json['typex']?.toString(),
    );
  }
}
