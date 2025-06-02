class ReviewModel {
  final int id;
  final String uuid;
  final ModuleModel module;
  final ClientModel client;
  final NewRequestModel newRequest;
  final String status;
  final int needReviewCount;
  final bool needReview;
  final String? statusLabel;

  ReviewModel({
    required this.id,
    required this.uuid,
    required this.module,
    required this.client,
    required this.newRequest,
    required this.status,
    required this.needReviewCount,
    required this.needReview,
    this.statusLabel,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      uuid: json['uuid'],
      module: ModuleModel.fromJson(json['module']),
      client: ClientModel.fromJson(json['client']),
      newRequest: NewRequestModel.fromJson(json['new_request']),
      status: json['status'],
      needReviewCount: json['need_review_count'],
      needReview: json['need_review'],
      statusLabel: json['status_label'],
    );
  }
}

class ModuleModel {
  final int id;
  final String nameTh;

  ModuleModel({required this.id, required this.nameTh});

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      nameTh: json['name_th'],
    );
  }
}

class ClientModel {
  final String uuid;
  final int ser;
  final String custno;
  final String scname;
  final String addr1;
  final String addr2;
  final Map<String, dynamic> jsonDetail;
  final String tel;
  final String tax;

  ClientModel({
    required this.uuid,
    required this.ser,
    required this.custno,
    required this.scname,
    required this.addr1,
    required this.addr2,
    required this.jsonDetail,
    required this.tel,
    required this.tax,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      uuid: json['uuid'],
      ser: json['ser'],
      custno: json['custno'],
      scname: json['scname'],
      addr1: json['addr_1'],
      addr2: json['addr_2'],
      jsonDetail: json['json'] ?? {},
      tel: json['tel'],
      tax: json['tax'],
    );
  }
}

class NewRequestModel {
  final String uuid;
  final String requestUuid;
  final String leaseNumber;
  final int propertyId;
  final int subzoneSer;
  final String zn;
  final String ln;
  final String sdate;
  final String ldate;

  NewRequestModel({
    required this.uuid,
    required this.requestUuid,
    required this.leaseNumber,
    required this.propertyId,
    required this.subzoneSer,
    required this.zn,
    required this.ln,
    required this.sdate,
    required this.ldate,
  });

  factory NewRequestModel.fromJson(Map<String, dynamic> json) {
    return NewRequestModel(
      uuid: json['uuid'],
      requestUuid: json['request_uuid'],
      leaseNumber: json['lease_number'],
      propertyId: json['property_id'],
      subzoneSer: json['subzoneser'],
      zn: json['zn'],
      ln: json['ln'],
      sdate: json['sdate'],
      ldate: json['ldate'],
    );
  }
}
