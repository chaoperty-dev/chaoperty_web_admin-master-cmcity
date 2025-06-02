class PropertiesModel {
  NewRequest? newRequest;
  Client? client;

  PropertiesModel({this.newRequest, this.client});

  PropertiesModel.fromJson(Map<String, dynamic> json) {
    newRequest = json['new_request'] != null
        ? new NewRequest.fromJson(json['new_request'])
        : null;
    client =
        json['client'] != null ? new Client.fromJson(json['client']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.newRequest != null) {
      data['new_request'] = this.newRequest!.toJson();
    }
    if (this.client != null) {
      data['client'] = this.client!.toJson();
    }
    return data;
  }
}

class NewRequest {
  int? id;
  String? uuid;
  String? requestUuid;
  int? propertyId;
  int? leaseTermMonths;
  String? desiredStartDate;
  int? subzoneser;
  int? zser;
  String? zn;
  int? aser;
  String? ln;
  String? sdate;
  String? ldate;
  int? sertype;
  String? type;
  int? qty;
  String? comment;
  String? createdAt;
  String? updatedAt;
  String? requestStatus;
  String? requestStep;
  String? paymentUuid;
  String? paymentStatus;
  String? paymentAmount;
  String? payment_json;
  NewRequest(
      {this.id,
      this.uuid,
      this.requestUuid,
      this.propertyId,
      this.leaseTermMonths,
      this.desiredStartDate,
      this.subzoneser,
      this.zser,
      this.zn,
      this.aser,
      this.ln,
      this.sdate,
      this.ldate,
      this.sertype,
      this.type,
      this.qty,
      this.comment,
      this.createdAt,
      this.updatedAt,
      this.requestStatus,
      this.requestStep,
      this.paymentUuid,
      this.paymentStatus,
      this.paymentAmount,
      this.payment_json});

  NewRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    requestUuid = json['request_uuid'];
    propertyId = json['property_id'];
    leaseTermMonths = json['lease_term_months'];
    desiredStartDate = json['desired_start_date'];
    subzoneser = json['subzoneser'];
    zser = json['zser'];
    zn = json['zn'];
    aser = json['aser'];
    ln = json['ln'];
    sdate = json['sdate'];
    ldate = json['ldate'];
    sertype = json['sertype'];
    type = json['type'];
    qty = json['qty'];
    comment = json['comment'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    requestStatus = json['request_status'];
    requestStep = json['request_step'];
    paymentUuid = json['payment_uuid'];
    paymentStatus = json['payment_status'];
    paymentAmount = json['payment_amount'];
    payment_json = json['payment_json'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['request_uuid'] = this.requestUuid;
    data['property_id'] = this.propertyId;
    data['lease_term_months'] = this.leaseTermMonths;
    data['desired_start_date'] = this.desiredStartDate;
    data['subzoneser'] = this.subzoneser;
    data['zser'] = this.zser;
    data['zn'] = this.zn;
    data['aser'] = this.aser;
    data['ln'] = this.ln;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['sertype'] = this.sertype;
    data['type'] = this.type;
    data['qty'] = this.qty;
    data['comment'] = this.comment;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['request_status'] = this.requestStatus;
    data['request_step'] = this.requestStep;
    data['payment_uuid'] = this.paymentUuid;
    data['payment_status'] = this.paymentStatus;
    data['payment_amount'] = this.paymentAmount;
    data['payment_json'] = this.payment_json;
    return data;
  }
}

class Client {
  String? uuid;
  String? scname;

  Client({this.uuid, this.scname});

  Client.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    scname = json['scname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['scname'] = this.scname;
    return data;
  }
}
