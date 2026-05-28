// class lastaction {
//   int? id;
//   String? uuid;
//   String? announcementUuid;
//   String? parentUuid;
//   int? moduleId;
//   String? clientsUuid;
//   int? createdByAdmin;
//   String? status;
//   String? submittedAt;
//   String? submittedBy;
//   String? submittedProfile;
//   String? submittedSignature;
//   String? completedAt;
//   String? feeAmount;
//   String? createdBy;
//   String? updatedBy;
//   String? createdAt;
//   String? updatedAt;
//   Module? module;
//   Client? client;
//   NewRequest? newRequest;
//   LatestApproval? latestApproval;

//   lastaction(
//       {this.id,
//       this.uuid,
//       this.announcementUuid,
//       this.parentUuid,
//       this.moduleId,
//       this.clientsUuid,
//       this.createdByAdmin,
//       this.status,
//       this.submittedAt,
//       this.submittedBy,
//       this.submittedProfile,
//       this.submittedSignature,
//       this.completedAt,
//       this.feeAmount,
//       this.createdBy,
//       this.updatedBy,
//       this.createdAt,
//       this.updatedAt,
//       this.module,
//       this.client,
//       this.newRequest,
//       this.latestApproval});

//   lastaction.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     uuid = json['uuid'];
//     announcementUuid = json['announcement_uuid'];
//     parentUuid = json['parent_uuid'];
//     moduleId = json['module_id'];
//     clientsUuid = json['clients_uuid'];
//     createdByAdmin = json['created_by_admin'];
//     status = json['status'];
//     submittedAt = json['submitted_at'];
//     submittedBy = json['submitted_by'];
//     submittedProfile = json['submitted_profile'];
//     submittedSignature = json['submitted_signature'];
//     completedAt = json['completed_at'];
//     feeAmount = json['fee_amount'];
//     createdBy = json['created_by'];
//     updatedBy = json['updated_by'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     module =
//         json['module'] != null ? new Module.fromJson(json['module']) : null;
//     client =
//         json['client'] != null ? new Client.fromJson(json['client']) : null;
//     newRequest = json['new_request'] != null
//         ? new NewRequest.fromJson(json['new_request'])
//         : null;
//     latestApproval = json['latest_approval'] != null
//         ? new LatestApproval.fromJson(json['latest_approval'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['uuid'] = this.uuid;
//     data['announcement_uuid'] = this.announcementUuid;
//     data['parent_uuid'] = this.parentUuid;
//     data['module_id'] = this.moduleId;
//     data['clients_uuid'] = this.clientsUuid;
//     data['created_by_admin'] = this.createdByAdmin;
//     data['status'] = this.status;
//     data['submitted_at'] = this.submittedAt;
//     data['submitted_by'] = this.submittedBy;
//     data['submitted_profile'] = this.submittedProfile;
//     data['submitted_signature'] = this.submittedSignature;
//     data['completed_at'] = this.completedAt;
//     data['fee_amount'] = this.feeAmount;
//     data['created_by'] = this.createdBy;
//     data['updated_by'] = this.updatedBy;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.module != null) {
//       data['module'] = this.module!.toJson();
//     }
//     if (this.client != null) {
//       data['client'] = this.client!.toJson();
//     }
//     if (this.newRequest != null) {
//       data['new_request'] = this.newRequest!.toJson();
//     }
//     if (this.latestApproval != null) {
//       data['latest_approval'] = this.latestApproval!.toJson();
//     }
//     return data;
//   }
// }

// class Module {
//   int? id;
//   String? nameTh;

//   Module({this.id, this.nameTh});

//   Module.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     nameTh = json['name_th'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name_th'] = this.nameTh;
//     return data;
//   }
// }

// class Client {
//   String? uuid;
//   int? ser;
//   String? custno;
//   String? scname;
//   String? addr1;
//   String? addr2;
//   Json? jsonData;
//   String? tel;
//   String? tax;

//   Client({
//     this.uuid,
//     this.ser,
//     this.custno,
//     this.scname,
//     this.addr1,
//     this.addr2,
//     this.jsonData,
//     this.tel,
//     this.tax,
//   });

//   Client.fromJson(Map<String, dynamic> json) {
//     uuid = json['uuid'];
//     ser = json['ser'];
//     custno = json['custno'];
//     scname = json['scname'];
//     addr1 = json['addr_1'];
//     addr2 = json['addr_2'];
//     jsonData = json['json'] != null ? Json.fromJson(json['json']) : null;
//     tel = json['tel'];
//     tax = json['tax'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['uuid'] = uuid;
//     data['ser'] = ser;
//     data['custno'] = custno;
//     data['scname'] = scname;
//     data['addr_1'] = addr1;
//     data['addr_2'] = addr2;
//     if (jsonData != null) {
//       data['json'] = jsonData!.toJson();
//     }
//     data['tel'] = tel;
//     data['tax'] = tax;
//     return data;
//   }
// }

// class Json {
//   String? number;
//   Null? moo;
//   Null? soi;
//   String? road;
//   String? tambon;
//   String? amphoe;
//   String? province;
//   Null? raw;

//   Json(
//       {this.number,
//       this.moo,
//       this.soi,
//       this.road,
//       this.tambon,
//       this.amphoe,
//       this.province,
//       this.raw});

//   Json.fromJson(Map<String, dynamic> json) {
//     number = json['number'];
//     moo = json['moo'];
//     soi = json['soi'];
//     road = json['road'];
//     tambon = json['tambon'];
//     amphoe = json['amphoe'];
//     province = json['province'];
//     raw = json['raw'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['number'] = this.number;
//     data['moo'] = this.moo;
//     data['soi'] = this.soi;
//     data['road'] = this.road;
//     data['tambon'] = this.tambon;
//     data['amphoe'] = this.amphoe;
//     data['province'] = this.province;
//     data['raw'] = this.raw;
//     return data;
//   }
// }

// class NewRequest {
//   String? uuid;
//   String? requestUuid;
//   String? leaseNumber;
//   int? propertyId;
//   int? subzoneser;
//   String? zn;
//   String? ln;
//   String? sdate;
//   String? ldate;

//   NewRequest(
//       {this.uuid,
//       this.requestUuid,
//       this.leaseNumber,
//       this.propertyId,
//       this.subzoneser,
//       this.zn,
//       this.ln,
//       this.sdate,
//       this.ldate});

//   NewRequest.fromJson(Map<String, dynamic> json) {
//     uuid = json['uuid'];
//     requestUuid = json['request_uuid'];
//     leaseNumber = json['lease_number'];
//     propertyId = json['property_id'];
//     subzoneser = json['subzoneser'];
//     zn = json['zn'];
//     ln = json['ln'];
//     sdate = json['sdate'];
//     ldate = json['ldate'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['uuid'] = this.uuid;
//     data['request_uuid'] = this.requestUuid;
//     data['lease_number'] = this.leaseNumber;
//     data['property_id'] = this.propertyId;
//     data['subzoneser'] = this.subzoneser;
//     data['zn'] = this.zn;
//     data['ln'] = this.ln;
//     data['sdate'] = this.sdate;
//     data['ldate'] = this.ldate;
//     return data;
//   }
// }

// class LatestApproval {
//   int? id;
//   String? uuid;
//   String? requestUuid;
//   String? usersUuid;
//   String? profileUuid;
//   String? signUuid;
//   String? positionUuid;
//   Null? createdBy;
//   String? flowsUuid;
//   int? flowsSequence;
//   String? status;
//   String? approvedAt;
//   String? comment;
//   String? createdAt;
//   String? updatedAt;
//   Flow? flow;

//   LatestApproval(
//       {this.id,
//       this.uuid,
//       this.requestUuid,
//       this.usersUuid,
//       this.profileUuid,
//       this.signUuid,
//       this.positionUuid,
//       this.createdBy,
//       this.flowsUuid,
//       this.flowsSequence,
//       this.status,
//       this.approvedAt,
//       this.comment,
//       this.createdAt,
//       this.updatedAt,
//       this.flow});

//   LatestApproval.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     uuid = json['uuid'];
//     requestUuid = json['request_uuid'];
//     usersUuid = json['users_uuid'];
//     profileUuid = json['profile_uuid'];
//     signUuid = json['sign_uuid'];
//     positionUuid = json['position_uuid'];
//     createdBy = json['created_by'];
//     flowsUuid = json['flows_uuid'];
//     flowsSequence = json['flows_sequence'];
//     status = json['status'];
//     approvedAt = json['approved_at'];
//     comment = json['comment'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     flow = json['flow'] != null ? new Flow.fromJson(json['flow']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['uuid'] = this.uuid;
//     data['request_uuid'] = this.requestUuid;
//     data['users_uuid'] = this.usersUuid;
//     data['profile_uuid'] = this.profileUuid;
//     data['sign_uuid'] = this.signUuid;
//     data['position_uuid'] = this.positionUuid;
//     data['created_by'] = this.createdBy;
//     data['flows_uuid'] = this.flowsUuid;
//     data['flows_sequence'] = this.flowsSequence;
//     data['status'] = this.status;
//     data['approved_at'] = this.approvedAt;
//     data['comment'] = this.comment;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.flow != null) {
//       data['flow'] = this.flow!.toJson();
//     }
//     return data;
//   }
// }

// class Flow {
//   String? uuid;
//   String? flowName;
//   int? stepOrder;
//   int? moduleId;

//   Flow({this.uuid, this.flowName, this.stepOrder, this.moduleId});

//   Flow.fromJson(Map<String, dynamic> json) {
//     uuid = json['uuid'];
//     flowName = json['flow_name'];
//     stepOrder = json['step_order'];
//     moduleId = json['module_id'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['uuid'] = this.uuid;
//     data['flow_name'] = this.flowName;
//     data['step_order'] = this.stepOrder;
//     data['module_id'] = this.moduleId;
//     return data;
//   }
// }
