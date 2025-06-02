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
  });

  factory CustomerModel.fromJson(Map<dynamic, dynamic> json) {
    return CustomerModel(
      ser: json['ser'],
      user: json['user'],
      rser: json['rser'],
      datex: json['datex'],
      timex: json['timex'],
      custno: json['custno'],
      taxno: json['taxno'],
      scname: json['scname'],
      stype: json['stype'],
      tser: json['tser'],
      typeser: json['typeser'],
      type: json['type'],
      cname: json['cname'],
      branch: json['branch'],
      attn: json['attn'],
      addr1: json['addr_1'],
      addr2: json['addr_2'],
      zip: json['zip'],
      tel: json['tel'],
      tax: json['tax'],
      fax: json['fax'],
      email: json['email'],
      lineid: json['lineid'],
      lastday: json['lastday'],
      status: json['status'],
      st: json['st'],
      dataUpdate: json['data_update'],
      cid: json['cid'],
      docno: json['docno'],
      sdate: json['sdate'],
      ldate: json['ldate'],
      period: json['period'],
      nday: json['nday'],
      ctype: json['ctype'],
      zser: json['zser'],
      zn: json['zn'],
      aser: json['aser'],
      ln: json['ln'],
      qty: json['qty'],
      area: json['area'],
      rtser: json['rtser'],
      rtname: json['rtname'],
      user_name: json['user_name'],
      passw: json['passw'],
      sname: json['sname'],
      wnote: json['wnote'],
      uuid: json['uuid'],
      address:
          json['json'] != null ? AddressModel.fromJson(json['json']) : null,
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
    return data;
  }
}
