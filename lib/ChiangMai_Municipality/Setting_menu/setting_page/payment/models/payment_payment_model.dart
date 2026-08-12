// ============================================================================
// payment_payment_model.dart
// ============================================================================
// Model: Payment (การรับชำระ) สำหรับหน้า "การรับชำระ"
// เขียนใหม่ทั้งหมด ไม่ reuse PayMentModel เดิม
// ============================================================================

class PaymentPaymentModel {
  final String ser;
  final String ln;
  final String sn;
  final String sname;
  final String sw;
  final String zone;
  final String typeId;
  final String typeName;
  final String bankId;
  final String bankCode;
  final String bankName;
  final String bankTypeId;
  final String bankTypeName;
  final String rser;
  final String slipName;

  const PaymentPaymentModel({
    required this.ser,
    required this.ln,
    required this.sn,
    required this.sname,
    required this.sw,
    required this.zone,
    this.typeId = '',
    this.typeName = '',
    this.bankId = '',
    this.bankCode = '',
    this.bankName = '',
    this.bankTypeId = '',
    this.bankTypeName = '',
    this.rser = '0',
    this.slipName = '',
  });

  factory PaymentPaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentPaymentModel(
      ser: (json['ser'] ?? '0').toString(),
      ln: (json['ln'] ?? '').toString(),
      sn: (json['sn'] ?? '').toString(),
      sname: (json['sname'] ?? '').toString(),
      sw: (json['sw'] ?? '0').toString(),
      zone: (json['zone'] ?? '0').toString(),
      typeId: (json['type_id'] ?? json['typeId'] ?? '').toString(),
      typeName:
          (json['type_name'] ?? json['typeName'] ?? json['tn'] ?? '').toString(),
      bankId: (json['bank_id'] ?? json['bankId'] ?? '').toString(),
      bankCode: (json['bank_code'] ?? json['bankCode'] ?? json['bcode'] ?? '')
          .toString(),
      bankName:
          (json['bank_name'] ?? json['bankName'] ?? json['bname'] ?? '').toString(),
      bankTypeId:
          (json['bank_type_id'] ?? json['bankTypeId'] ?? '').toString(),
      bankTypeName: (json['bank_type_name'] ??
              json['bankTypeName'] ??
              json['btype'] ??
              '')
          .toString(),
      rser: (json['rser'] ?? '0').toString(),
      slipName: (json['slip_name'] ?? json['slipName'] ?? json['payment_IMG'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'ser': ser,
        'ln': ln,
        'sn': sn,
        'sname': sname,
        'sw': sw,
        'zone': zone,
        'type_id': typeId,
        'bank_id': bankId,
        'bank_type_id': bankTypeId,
        'rser': rser,
        'slip_name': slipName,
      };
}
