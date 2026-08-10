class ChackpayinvoiceModel {
  String? ref_id;
  String? transDate;
  String? transTime;
  String? amount;
  String? fromName;
  String? reference1;
  String? reference2;

  ChackpayinvoiceModel({
    this.ref_id,
    this.transDate,
    this.transTime,
    this.amount,
    this.fromName,
    this.reference1,
    this.reference2,
  });

  ChackpayinvoiceModel.fromJson(Map<String, dynamic> json) {
    ref_id = json['ref_id'];
    transDate = json['transDate'];
    transTime = json['transTime'];
    amount = json['amount'];
    fromName = json['fromName'];
    reference1 = json['reference1'];
    reference2 = json['reference2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ref_id'] = this.ref_id;
    data['transDate'] = this.transDate;
    data['transTime'] = this.transTime;
    data['amount'] = this.amount;
    data['fromName'] = this.fromName;
    data['reference1'] = this.reference1;
    data['reference2'] = this.reference2;

    return data;
  }
}
