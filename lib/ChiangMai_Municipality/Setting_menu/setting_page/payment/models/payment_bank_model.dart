// ============================================================================
// payment_bank_model.dart
// ============================================================================
// Model: ธนาคาร (Bank)
// เขียนใหม่ทั้งหมด ไม่ reuse GetBankModel เดิม
// ============================================================================

class PaymentBankModel {
  final String ser;
  final String bcode;
  final String bname;
  final String btype;
  final String st;
  final String dataUpdate;

  const PaymentBankModel({
    required this.ser,
    required this.bcode,
    required this.bname,
    required this.btype,
    this.st = '1',
    this.dataUpdate = '',
  });

  factory PaymentBankModel.fromJson(Map<String, dynamic> json) {
    return PaymentBankModel(
      ser: (json['ser'] ?? '0').toString(),
      bcode: (json['bcode'] ?? '').toString(),
      bname: (json['bname'] ?? '').toString(),
      btype: (json['btype'] ?? '').toString(),
      st: (json['st'] ?? '1').toString(),
      dataUpdate: (json['data_update'] ?? '').toString(),
    );
  }
}
