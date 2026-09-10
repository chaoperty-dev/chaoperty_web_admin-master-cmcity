import '../Model/GetNote_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/GetTeNant_Model.dart';

/// Specialized models for Home2 Dashboard to handle inconsistent API types (int/String)
/// without affecting the rest of the application.

class DashNoteModel {
  String? ser;
  String? user;
  String? note;
  String? datex;

  DashNoteModel({this.ser, this.user, this.note, this.datex});

  DashNoteModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    user = json['user']?.toString();
    note = json['note']?.toString();
    datex = json['datex']?.toString();
  }

  // Helper to convert to existing NoteModel if needed
  NoteModel toNoteModel() {
    return NoteModel(
      ser: ser,
      user: user,
      descr: note, // Map 'note' to 'descr'
      datex: datex,
    );
  }
}

class DashZoneModel {
  String? ser;
  String? zn;
  String? qty;
  String? subZone;
  String? status;
  String? total; // For contract results

  DashZoneModel(
      {this.ser, this.zn, this.qty, this.subZone, this.status, this.total});

  DashZoneModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    zn = json['zn']?.toString();
    qty = json['qty']?.toString();
    subZone = json['sub_zone']?.toString();
    status = json['status']?.toString();
    total = json['total']?.toString();
  }

  ZoneModel toZoneModel() {
    return ZoneModel(
      ser: ser,
      zn: zn,
      qty: qty ?? total, // Map total to qty if qty is null
      sub_zone: subZone,
      status: status,
    );
  }
}

class DashTeNantModel {
  String? ccDate;
  String? total;
  String? st;
  String? sname;
  String? cname;
  String? zn;
  String? ln_c;
  String? ln_q;
  String? docno;
  String? cid;

  DashTeNantModel({
    this.ccDate,
    this.total,
    this.st,
    this.sname,
    this.cname,
    this.zn,
    this.ln_c,
    this.ln_q,
    this.docno,
    this.cid,
  });

  DashTeNantModel.fromJson(Map<String, dynamic> json) {
    ccDate = json['cc_date']?.toString();
    total = json['total']?.toString();
    st = json['st']?.toString();
    sname = json['sname']?.toString();
    cname = json['cname']?.toString();
    zn = json['zn']?.toString();
    ln_c = json['ln_c']?.toString();
    ln_q = json['ln_q']?.toString();
    docno = json['docno']?.toString();
    cid = json['cid']?.toString();
  }

  TeNantModel toTeNantModel() {
    final model = TeNantModel(
      st: st,
    );
    model.cc_date = ccDate;
    model.total = total;
    model.sname = sname;
    model.cname = cname;
    model.zn = zn;
    model.ln_c = ln_c;
    model.ln_q = ln_q;
    model.docno = docno;
    model.cid = cid;
    return model;
  }
}

class NearExpiredModel {
  final String cid;
  final String cname;
  final String ldate;
  final int daysLeft;

  NearExpiredModel({
    required this.cid,
    required this.cname,
    required this.ldate,
    required this.daysLeft,
  });

  factory NearExpiredModel.fromJson(Map<String, dynamic> json) {
    return NearExpiredModel(
      cid: json['cid'] ?? '',
      cname: json['cname'] ?? '',
      ldate: json['ldate'] ?? '',
      daysLeft: int.tryParse("${json['days_left']}") ?? 0,
    );
  }
}

class DashAreaModel {
  String? totalArea;
  String? areaEmpty;
  String? areaActive;
  String? sqmTotal;
  String? sqmEmpty;
  String? sqmActive;

  DashAreaModel(
      {this.totalArea,
      this.areaEmpty,
      this.areaActive,
      this.sqmTotal,
      this.sqmEmpty,
      this.sqmActive});

  DashAreaModel.fromJson(Map<String, dynamic> json) {
    totalArea = json['total_area']?.toString();
    areaEmpty = json['area_empty']?.toString();
    areaActive = json['area_active']?.toString();
    sqmTotal = json['sqm_total']?.toString();
    sqmEmpty = json['sqm_empty']?.toString();
    sqmActive = json['sqm_active']?.toString();
  }
}
