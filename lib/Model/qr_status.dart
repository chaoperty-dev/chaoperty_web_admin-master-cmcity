class QRStatusModel {
  String? result;
  String? message;
  String? payment_data;

  QRStatusModel({
    this.result,
    this.message,
    this.payment_data,
  });

  QRStatusModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    message = json['message'];
    payment_data = json['payment_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['message'] = this.message;
    data['payment_data'] = this.payment_data;

    return data;
  }
}
