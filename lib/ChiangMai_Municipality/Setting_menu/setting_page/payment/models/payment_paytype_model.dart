// ============================================================================
// payment_paytype_model.dart
// ============================================================================
// Model: ประเภทการรับชำระ (PayType) เช่น "เงินสด", "เงินโอน"
// เขียนใหม่ทั้งหมด ไม่ reuse PayTypeModel เดิม
// ============================================================================

class PaymentPayTypeModel {
  final String ser;
  final String tn;
  final String? desc;

  const PaymentPayTypeModel({
    required this.ser,
    required this.tn,
    this.desc,
  });

  factory PaymentPayTypeModel.fromJson(Map<String, dynamic> json) {
    return PaymentPayTypeModel(
      ser: (json['ser'] ?? '0').toString(),
      tn: (json['tn'] ?? '').toString(),
      desc: json['desc']?.toString(),
    );
  }
}
