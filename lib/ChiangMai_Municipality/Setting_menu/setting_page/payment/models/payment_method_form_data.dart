import 'payment_method_model.dart';

/// Input data submitted by the payment method form.
class PaymentMethodFormData {
  final String code;
  final String nameTh;
  final String description;
  final String paymentSystem;
  final List<String> payTypes;
  final int sortOrder;
  final bool active;

  const PaymentMethodFormData({
    required this.code,
    required this.nameTh,
    required this.description,
    required this.paymentSystem,
    required this.payTypes,
    required this.sortOrder,
    required this.active,
  });

  factory PaymentMethodFormData.fromModel(PaymentMethodModel model) {
    return PaymentMethodFormData(
      code: model.code,
      nameTh: model.nameTh,
      description: model.description,
      paymentSystem: model.paymentSystem,
      payTypes: List<String>.of(model.payTypes),
      sortOrder: model.sortOrder,
      active: model.active,
    );
  }
}
