import 'payment_method_model.dart';

sealed class PaymentMethodEvent {
  const PaymentMethodEvent();
}

class PaymentMethodErrorEvent extends PaymentMethodEvent {
  final String message;
  const PaymentMethodErrorEvent(this.message);
}

class PaymentMethodSuccessEvent extends PaymentMethodEvent {
  final String message;
  const PaymentMethodSuccessEvent(this.message);
}

class PaymentMethodOpenCreateEvent extends PaymentMethodEvent {
  const PaymentMethodOpenCreateEvent();
}

class PaymentMethodOpenEditEvent extends PaymentMethodEvent {
  final PaymentMethodModel item;
  const PaymentMethodOpenEditEvent(this.item);
}
