class ReceiptModel {
  String? message;
  Data? data;

  ReceiptModel({this.message, this.data});

  ReceiptModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Document? document;
  Meta? meta;

  Data({this.document, this.meta});

  Data.fromJson(Map<String, dynamic> json) {
    document = json['document'] != null
        ? new Document.fromJson(json['document'])
        : null;
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.document != null) {
      data['document'] = this.document!.toJson();
    }
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Document {
  String? uuid;
  int? documentTypeId;
  String? documentNo;
  String? createdBy;
  String? publishedAt;
  bool? active;

  Document(
      {this.uuid,
      this.documentTypeId,
      this.documentNo,
      this.createdBy,
      this.publishedAt,
      this.active});

  Document.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    documentTypeId = json['document_type_id'];
    documentNo = json['document_no'];
    createdBy = json['created_by'];
    publishedAt = json['published_at'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['document_type_id'] = this.documentTypeId;
    data['document_no'] = this.documentNo;
    data['created_by'] = this.createdBy;
    data['published_at'] = this.publishedAt;
    data['active'] = this.active;
    return data;
  }
}

class Meta {
  String? requestUuid;
  String? documentUuid;
  String? status;
  Payment? payment;
  Client? client;
  NewRequest? newRequest;

  Meta(
      {this.requestUuid,
      this.documentUuid,
      this.status,
      this.payment,
      this.client,
      this.newRequest});

  Meta.fromJson(Map<String, dynamic> json) {
    requestUuid = json['request_uuid'];
    documentUuid = json['document_uuid'];
    status = json['status'];
    payment =
        json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
    client =
        json['client'] != null ? new Client.fromJson(json['client']) : null;
    newRequest = json['new_request'] != null
        ? new NewRequest.fromJson(json['new_request'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_uuid'] = this.requestUuid;
    data['document_uuid'] = this.documentUuid;
    data['status'] = this.status;
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    if (this.client != null) {
      data['client'] = this.client!.toJson();
    }
    if (this.newRequest != null) {
      data['new_request'] = this.newRequest!.toJson();
    }
    return data;
  }
}

class Payment {
  int? amount;
  int? amountReceived;
  String? status;
  List<Json>? json;

  Payment({this.amount, this.amountReceived, this.status, this.json});

  Payment.fromJson(Map<String, dynamic> jsonMap) {
    amount = jsonMap['amount'];
    amountReceived = jsonMap['amount_received'];
    status = jsonMap['status'];
    if (jsonMap['json'] != null) {
      json = List<Json>.from(jsonMap['json'].map((v) => Json.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['amount_received'] = amountReceived;
    data['status'] = status;
    if (json != null) {
      data['json'] = json!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Json {
  String? ser;
  String? expname;
  String? sunit;
  String? unit;
  String? qty;
  String? amt;
  String? total;

  Json(
      {this.ser,
      this.expname,
      this.sunit,
      this.unit,
      this.qty,
      this.amt,
      this.total});

  Json.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    expname = json['expname'];
    sunit = json['sunit'];
    unit = json['unit'];
    qty = json['qty'];
    amt = json['amt'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['expname'] = this.expname;
    data['sunit'] = this.sunit;
    data['unit'] = this.unit;
    data['qty'] = this.qty;
    data['amt'] = this.amt;
    data['total'] = this.total;
    return data;
  }
}

class Client {
  String? name;
  String? type;
  String? business;
  String? address;
  String? phone;
  String? taxId;

  Client(
      {this.name,
      this.type,
      this.business,
      this.address,
      this.phone,
      this.taxId});

  Client.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    business = json['business'];
    address = json['address'];
    phone = json['phone'];
    taxId = json['tax_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['business'] = this.business;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['tax_id'] = this.taxId;
    return data;
  }
}

class NewRequest {
  String? leaseNumber;
  int? propertyId;
  int? leaseTermMonths;
  String? sdate;
  String? ldate;
  int? qty;
  String? type;

  NewRequest(
      {this.leaseNumber,
      this.propertyId,
      this.leaseTermMonths,
      this.sdate,
      this.ldate,
      this.qty,
      this.type});

  NewRequest.fromJson(Map<String, dynamic> json) {
    leaseNumber = json['lease_number'];
    propertyId = json['property_id'];
    leaseTermMonths = json['lease_term_months'];
    sdate = json['sdate'];
    ldate = json['ldate'];
    qty = json['qty'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lease_number'] = this.leaseNumber;
    data['property_id'] = this.propertyId;
    data['lease_term_months'] = this.leaseTermMonths;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['qty'] = this.qty;
    data['type'] = this.type;
    return data;
  }
}
