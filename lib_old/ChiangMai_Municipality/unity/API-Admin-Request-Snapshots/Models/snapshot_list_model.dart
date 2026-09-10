// Model สำหรับ Client JSON (nested object)
class ClientJsonModel {
  String? number;
  String? moo;
  String? soi;
  String? road;
  String? tambon;
  String? amphoe;
  String? province;
  String? raw;

  ClientJsonModel({
    this.number,
    this.moo,
    this.soi,
    this.road,
    this.tambon,
    this.amphoe,
    this.province,
    this.raw,
  });

  ClientJsonModel.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    moo = json['moo'];
    soi = json['soi'];
    road = json['road'];
    tambon = json['tambon'];
    amphoe = json['amphoe'];
    province = json['province'];
    raw = json['raw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['moo'] = moo;
    data['soi'] = soi;
    data['road'] = road;
    data['tambon'] = tambon;
    data['amphoe'] = amphoe;
    data['province'] = province;
    data['raw'] = raw;
    return data;
  }
}

// Model สำหรับ Client
class ClientModel {
  int? ser;
  int? user;
  int? rser;
  String? datex;
  String? timex;
  String? custno;
  String? taxno;
  String? scname;
  String? sname;
  String? stype;
  int? typeser;
  String? type;
  String? cname;
  String? branch;
  String? attn;
  String? addr1;
  String? addr2;
  String? zip;
  String? tel;
  String? tax;
  String? fax;
  String? email;
  String? lineid;
  String? lastday;
  String? status;
  int? st;
  String? userName;
  String? passw;
  String? dataUpdate;
  String? uuid;
  ClientJsonModel? json;
  String? birth;
  String? religion;
  String? national;
  dynamic tUser;
  int? age;
  String? nationality;

  ClientModel({
    this.ser,
    this.user,
    this.rser,
    this.datex,
    this.timex,
    this.custno,
    this.taxno,
    this.scname,
    this.sname,
    this.stype,
    this.typeser,
    this.type,
    this.cname,
    this.branch,
    this.attn,
    this.addr1,
    this.addr2,
    this.zip,
    this.tel,
    this.tax,
    this.fax,
    this.email,
    this.lineid,
    this.lastday,
    this.status,
    this.st,
    this.userName,
    this.passw,
    this.dataUpdate,
    this.uuid,
    this.json,
    this.birth,
    this.religion,
    this.national,
    this.tUser,
    this.age,
    this.nationality,
  });

  ClientModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    user = json['user'];
    rser = json['rser'];
    datex = json['datex'];
    timex = json['timex'];
    custno = json['custno'];
    taxno = json['taxno'];
    scname = json['scname'];
    sname = json['sname'];
    stype = json['stype'];
    typeser = json['typeser'];
    type = json['type'];
    cname = json['cname'];
    branch = json['branch'];
    attn = json['attn'];
    addr1 = json['addr_1'];
    addr2 = json['addr_2'];
    zip = json['zip'];
    tel = json['tel'];
    tax = json['tax'];
    fax = json['fax'];
    email = json['email'];
    lineid = json['lineid'];
    lastday = json['lastday'];
    status = json['status'];
    st = json['st'];
    userName = json['user_name'];
    passw = json['passw'];
    dataUpdate = json['data_update'];
    uuid = json['uuid'];
    this.json =
        json['json'] != null ? ClientJsonModel.fromJson(json['json']) : null;
    birth = json['birth'];
    religion = json['religion'];
    national = json['national'];
    tUser = json['t_user'];
    age = json['age'];
    nationality = json['nationality'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ser'] = ser;
    data['user'] = user;
    data['rser'] = rser;
    data['datex'] = datex;
    data['timex'] = timex;
    data['custno'] = custno;
    data['taxno'] = taxno;
    data['scname'] = scname;
    data['sname'] = sname;
    data['stype'] = stype;
    data['typeser'] = typeser;
    data['type'] = type;
    data['cname'] = cname;
    data['branch'] = branch;
    data['attn'] = attn;
    data['addr_1'] = addr1;
    data['addr_2'] = addr2;
    data['zip'] = zip;
    data['tel'] = tel;
    data['tax'] = tax;
    data['fax'] = fax;
    data['email'] = email;
    data['lineid'] = lineid;
    data['lastday'] = lastday;
    data['status'] = status;
    data['st'] = st;
    data['user_name'] = userName;
    data['passw'] = passw;
    data['data_update'] = dataUpdate;
    data['uuid'] = uuid;
    if (json != null) {
      data['json'] = json!.toJson();
    }
    data['birth'] = birth;
    data['religion'] = religion;
    data['national'] = national;
    data['t_user'] = tUser;
    data['age'] = age;
    data['nationality'] = nationality;
    return data;
  }
}

// Model สำหรับ Module
class ModuleModel {
  int? id;
  String? code;
  String? nameTh;

  ModuleModel({this.id, this.code, this.nameTh});

  ModuleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    nameTh = json['name_th'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name_th'] = nameTh;
    return data;
  }
}

// Model สำหรับ Snapshot (List item)
class SnapshotListItemModel {
  String? uuid;
  String? sourceRequestUuid;
  int? snapshotVersion;
  bool? active;
  String? clientsUuid;
  String? sourceClientsUuid;
  String? referencedRequestUuid;
  String? referencedAt;
  ModuleModel? module;
  ClientModel? client;
  String? sourceAnnouncementUuid;
  String? sourceParentUuid;
  String? sourceStatus;
  String? sourceSubmittedAt;
  String? sourceSubmittedBy;
  dynamic sourceSubmittedProfile;
  dynamic sourceSubmittedSignature;
  String? sourceCompletedAt;
  String? sourceFeeAmount;
  bool? sourceCreatedByAdmin;
  String? sourceCreatedBy;
  String? sourceUpdatedBy;
  String? sourceCreatedAt;
  String? sourceUpdatedAt;
  String? snapshottedAt;
  int? attachmentsCount;
  String? createdAt;
  String? updatedAt;

  SnapshotListItemModel({
    this.uuid,
    this.sourceRequestUuid,
    this.snapshotVersion,
    this.active,
    this.clientsUuid,
    this.sourceClientsUuid,
    this.referencedRequestUuid,
    this.referencedAt,
    this.module,
    this.client,
    this.sourceAnnouncementUuid,
    this.sourceParentUuid,
    this.sourceStatus,
    this.sourceSubmittedAt,
    this.sourceSubmittedBy,
    this.sourceSubmittedProfile,
    this.sourceSubmittedSignature,
    this.sourceCompletedAt,
    this.sourceFeeAmount,
    this.sourceCreatedByAdmin,
    this.sourceCreatedBy,
    this.sourceUpdatedBy,
    this.sourceCreatedAt,
    this.sourceUpdatedAt,
    this.snapshottedAt,
    this.attachmentsCount,
    this.createdAt,
    this.updatedAt,
  });

  SnapshotListItemModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    sourceRequestUuid = json['source_request_uuid'];
    snapshotVersion = json['snapshot_version'];
    active = json['active'];
    clientsUuid = json['clients_uuid'];
    sourceClientsUuid = json['source_clients_uuid'];
    referencedRequestUuid = json['referenced_request_uuid'];
    referencedAt = json['referenced_at'];
    module =
        json['module'] != null ? ModuleModel.fromJson(json['module']) : null;
    client =
        json['client'] != null ? ClientModel.fromJson(json['client']) : null;
    sourceAnnouncementUuid = json['source_announcement_uuid'];
    sourceParentUuid = json['source_parent_uuid'];
    sourceStatus = json['source_status'];
    sourceSubmittedAt = json['source_submitted_at'];
    sourceSubmittedBy = json['source_submitted_by'];
    sourceSubmittedProfile = json['source_submitted_profile'];
    sourceSubmittedSignature = json['source_submitted_signature'];
    sourceCompletedAt = json['source_completed_at'];
    sourceFeeAmount = json['source_fee_amount'];
    sourceCreatedByAdmin = json['source_created_by_admin'];
    sourceCreatedBy = json['source_created_by'];
    sourceUpdatedBy = json['source_updated_by'];
    sourceCreatedAt = json['source_created_at'];
    sourceUpdatedAt = json['source_updated_at'];
    snapshottedAt = json['snapshotted_at'];
    attachmentsCount = json['attachments_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['source_request_uuid'] = sourceRequestUuid;
    data['snapshot_version'] = snapshotVersion;
    data['active'] = active;
    data['clients_uuid'] = clientsUuid;
    data['source_clients_uuid'] = sourceClientsUuid;
    data['referenced_request_uuid'] = referencedRequestUuid;
    data['referenced_at'] = referencedAt;
    if (module != null) {
      data['module'] = module!.toJson();
    }
    if (client != null) {
      data['client'] = client!.toJson();
    }
    data['source_announcement_uuid'] = sourceAnnouncementUuid;
    data['source_parent_uuid'] = sourceParentUuid;
    data['source_status'] = sourceStatus;
    data['source_submitted_at'] = sourceSubmittedAt;
    data['source_submitted_by'] = sourceSubmittedBy;
    data['source_submitted_profile'] = sourceSubmittedProfile;
    data['source_submitted_signature'] = sourceSubmittedSignature;
    data['source_completed_at'] = sourceCompletedAt;
    data['source_fee_amount'] = sourceFeeAmount;
    data['source_created_by_admin'] = sourceCreatedByAdmin;
    data['source_created_by'] = sourceCreatedBy;
    data['source_updated_by'] = sourceUpdatedBy;
    data['source_created_at'] = sourceCreatedAt;
    data['source_updated_at'] = sourceUpdatedAt;
    data['snapshotted_at'] = snapshottedAt;
    data['attachments_count'] = attachmentsCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

// Model สำหรับ Pagination Links
class PaginationLinksModel {
  String? first;
  String? last;
  String? prev;
  String? next;

  PaginationLinksModel({this.first, this.last, this.prev, this.next});

  PaginationLinksModel.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['last'] = last;
    data['prev'] = prev;
    data['next'] = next;
    return data;
  }
}

// Model สำหรับ Pagination Meta Links
class MetaLinkModel {
  String? url;
  String? label;
  bool? active;

  MetaLinkModel({this.url, this.label, this.active});

  MetaLinkModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}

// Model สำหรับ Pagination Meta
class PaginationMetaModel {
  int? currentPage;
  int? from;
  int? lastPage;
  List<MetaLinkModel>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  PaginationMetaModel({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    if (json['links'] != null) {
      links = <MetaLinkModel>[];
      json['links'].forEach((v) {
        links!.add(MetaLinkModel.fromJson(v));
      });
    }
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

// Model สำหรับ Response List Snapshots
class SnapshotListResponse {
  List<SnapshotListItemModel>? data;
  PaginationLinksModel? links;
  PaginationMetaModel? meta;

  SnapshotListResponse({this.data, this.links, this.meta});

  SnapshotListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SnapshotListItemModel>[];
      json['data'].forEach((v) {
        data!.add(SnapshotListItemModel.fromJson(v));
      });
    }
    links = json['links'] != null
        ? PaginationLinksModel.fromJson(json['links'])
        : null;
    meta = json['meta'] != null
        ? PaginationMetaModel.fromJson(json['meta'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      data['links'] = links!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}
