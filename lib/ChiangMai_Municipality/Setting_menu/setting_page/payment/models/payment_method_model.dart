class PaymentMethodModel {
  final String uuid;
  final String code;
  final String nameTh;
  final String description;
  final String paymentSystem;
  final List<String> payTypes;
  final int sortOrder;
  final bool active;
  final Map<String, dynamic>? config;

  const PaymentMethodModel({
    required this.uuid,
    required this.code,
    required this.nameTh,
    required this.description,
    required this.paymentSystem,
    required this.payTypes,
    required this.sortOrder,
    required this.active,
    required this.config,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final rawPayTypes = json['pay_types'];
    final rawConfig = json['config'];
    return PaymentMethodModel(
      uuid: '${json['uuid'] ?? ''}',
      code: '${json['code'] ?? ''}',
      nameTh: '${json['name_th'] ?? ''}',
      description: '${json['description'] ?? ''}',
      paymentSystem: json['payment_system']?.toString() ?? '',
      payTypes: rawPayTypes is List
          ? rawPayTypes.map((e) => '$e').toList()
          : const <String>[],
      sortOrder: int.tryParse('${json['sort_order'] ?? 0}') ?? 0,
      active: json['active'] == true || json['active'] == 1,
      config: rawConfig is Map ? Map<String, dynamic>.from(rawConfig) : null,
    );
  }
}
