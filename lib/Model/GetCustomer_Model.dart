import 'dart:convert';
import '../ChiangMai_Municipality/Model/Address_Model.dart';

class CustomerModel {
  dynamic ser;
  dynamic user;
  dynamic rser;
  String? datex;
  String? timex;
  String? custno;
  String? taxno;
  String? scname;
  String? stype;
  String? tser;
  dynamic typeser;
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
  String? lineRegisUrl; // line_regis_url จาก regis_data[0]
  String? lastday;
  String? status;
  dynamic st;
  String? dataUpdate;
  String? cid;
  String? docno;
  String? sdate;
  String? ldate;
  String? period;
  String? nday;
  String? ctype;
  String? zser;
  String? zn;
  String? aser;
  String? ln;
  String? qty;
  String? area;
  String? rtser;
  String? rtname;
  String? user_name;
  String? passw;
  String? sname;
  String? wnote;
  String? uuid;

  AddressModel? address;
  dynamic age;
  String? birth;
  String? religion;
  String? national;

  CustomerModel({
    this.ser,
    this.user,
    this.rser,
    this.datex,
    this.timex,
    this.custno,
    this.taxno,
    this.scname,
    this.stype,
    this.tser,
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
    this.lineRegisUrl,
    this.lastday,
    this.status,
    this.st,
    this.dataUpdate,
    this.cid,
    this.docno,
    this.sdate,
    this.ldate,
    this.period,
    this.nday,
    this.ctype,
    this.zser,
    this.zn,
    this.aser,
    this.ln,
    this.qty,
    this.area,
    this.rtser,
    this.rtname,
    this.user_name,
    this.passw,
    this.sname,
    this.wnote,
    this.uuid,
    this.address,
    this.age,
    this.birth,
    this.religion,
    this.national,
  });

  /// แปลง dynamic -> String? อย่างปลอดภัย
  /// - String: คืนเดิม
  /// - num/bool: toString()
  /// - List: ถ้าเป็นลิสต์ของสตริง/นัมเบอร์ -> join ด้วย ','
  ///         ถ้ามีชนิดปนกัน -> jsonEncode
  /// - Map อื่นๆ -> jsonEncode
  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    if (v is List) {
      // ลอง map เป็นสตริง (กรอง null) แล้ว join
      final list = v
          .where((e) => e != null)
          .map((e) {
            if (e is String) return e;
            if (e is num || e is bool) return e.toString();
            return null;
          })
          .whereType<String>()
          .toList();

      if (list.length == v.length) {
        return list.join(','); // ได้ลิสต์สตริงล้วน
      }
      // มีชนิดซับซ้อน ปล่อยเป็น JSON
      try {
        return jsonEncode(v);
      } catch (_) {
        return v.toString();
      }
    }
    if (v is Map) {
      try {
        return jsonEncode(v);
      } catch (_) {
        return v.toString();
      }
    }
    return v.toString();
  }

  /// แปลง address จากทั้ง Map/String/null -> AddressModel?
  static AddressModel? _parseAddress(dynamic v) {
    if (v == null) return null;
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return null;
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          return AddressModel.fromJson(decoded);
        }
        return null;
      } catch (_) {
        return null;
      }
    }
    if (v is Map<String, dynamic>) return AddressModel.fromJson(v);
    if (v is Map) return AddressModel.fromJson(Map<String, dynamic>.from(v));
    return null;
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      ser: json['ser'],
      user: json['user'],
      rser: json['rser'],
      datex: _asString(json['datex']),
      timex: _asString(json['timex']),
      custno: _asString(json['custno']),
      taxno: _asString(json['taxno']),
      scname: _asString(json['scname']),
      stype: _asString(json['stype']),
      tser: _asString(json['tser']),
      typeser: json['typeser'],
      type: _asString(json['type']),
      cname: _asString(json['cname']),
      branch: _asString(json['branch']),
      attn: _asString(json['attn']),
      addr1: _asString(json['addr1'] ?? json['addr_1']),
      addr2: _asString(json['addr2'] ?? json['addr_2']),
      zip: _asString(json['zip']),
      tel: _asString(json['tel']),
      tax: _asString(json['tax']),
      fax: _asString(json['fax']),
      email: _asString(json['email']),
      lineid: _asString(json['lineid']),
      lineRegisUrl: _asString(json['line_regis_url']),
      lastday: _asString(json['lastday']),
      status: _asString(json['status']),
      st: json['st'],
      dataUpdate: _asString(json['data_update']),
      cid: _asString(json['cid']),
      docno: _asString(json['docno']),
      sdate: _asString(json['sdate']),
      ldate: _asString(json['ldate']),
      period: _asString(json['period']),
      nday: _asString(json['nday']),
      ctype: _asString(json['ctype']),
      zser: _asString(json['zser']),
      zn: _asString(json['zn']),
      aser: _asString(json['aser']),
      ln: _asString(json['ln']),
      qty: _asString(json['qty']),
      area: _asString(json['area']),
      rtser: _asString(json['rtser']),
      rtname: _asString(json['rtname']),
      user_name: _asString(json['user_name']),
      passw: _asString(json['passw']),
      sname: _asString(json['sname']),
      wnote: _asString(json['wnote']),
      uuid: _asString(json['uuid']),
      address: _parseAddress(json['json']),
      age: json['age'],
      birth: _asString(json['birth']),
      religion: _asString(json['religion']),
      national: _asString(json['national']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['ser'] = ser;
    data['user'] = user;
    data['rser'] = rser;
    data['datex'] = datex;
    data['timex'] = timex;
    data['custno'] = custno;
    data['taxno'] = taxno;
    data['scname'] = scname;
    data['stype'] = stype;
    data['tser'] = tser;
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
    data['data_update'] = dataUpdate;
    data['cid'] = cid;
    data['docno'] = docno;
    data['sdate'] = sdate;
    data['ldate'] = ldate;
    data['period'] = period;
    data['nday'] = nday;
    data['ctype'] = ctype;
    data['zser'] = zser;
    data['zn'] = zn;
    data['aser'] = aser;
    data['ln'] = ln;
    data['qty'] = qty;
    data['area'] = area;
    data['rtser'] = rtser;
    data['rtname'] = rtname;
    data['user_name'] = user_name;
    data['passw'] = passw;
    data['sname'] = sname;
    data['wnote'] = wnote;
    data['uuid'] = uuid;
    data['json'] = address?.toJson();
    data['age'] = age;
    data['birth'] = birth;
    data['religion'] = religion;
    data['national'] = national;
    return data;
  }
}
