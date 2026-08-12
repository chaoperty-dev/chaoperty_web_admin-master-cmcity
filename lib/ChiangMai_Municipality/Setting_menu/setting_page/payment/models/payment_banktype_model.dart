// ============================================================================
// payment_banktype_model.dart
// ============================================================================
// Model: ประเภทบัญชี (BankType) เช่น "ออมทรัพย์", "กระแสรายวัน"
// เขียนใหม่ทั้งหมด ไม่ reuse BanktypeModel เดิม
// ============================================================================

class PaymentBankTypeModel {
  final String ser;
  final String btype;
  final String st;
  final String dataUpdate;

  const PaymentBankTypeModel({
    required this.ser,
    required this.btype,
    this.st = '1',
    this.dataUpdate = '',
  });

  factory PaymentBankTypeModel.fromJson(Map<String, dynamic> json) {
    return PaymentBankTypeModel(
      ser: (json['ser'] ?? '0').toString(),
      btype: (json['btype'] ?? '').toString(),
      st: (json['st'] ?? '1').toString(),
      dataUpdate: (json['data_update'] ?? '').toString(),
    );
  }
}
