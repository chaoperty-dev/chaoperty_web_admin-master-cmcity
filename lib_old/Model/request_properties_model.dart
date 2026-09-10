// Model สำหรับ Client ใน Request Properties Response
class RequestPropertiesClientModel {
  int? ser;
  String? uuid;
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

  RequestPropertiesClientModel({
    this.ser,
    this.uuid,
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
  });

  RequestPropertiesClientModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    uuid = json['uuid'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ser'] = ser;
    data['uuid'] = uuid;
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
    return data;
  }
}

// Model สำหรับ Request Properties Data
class RequestPropertiesDataModel {
  String? uuid;
  RequestPropertiesClientModel? client;

  RequestPropertiesDataModel({this.uuid, this.client});

  RequestPropertiesDataModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    client = json['client'] != null
        ? RequestPropertiesClientModel.fromJson(json['client'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    if (client != null) {
      data['client'] = client!.toJson();
    }
    return data;
  }
}

// Model สำหรับ Request Properties Response
class RequestPropertiesResponseModel {
  RequestPropertiesDataModel? data;

  RequestPropertiesResponseModel({this.data});

  RequestPropertiesResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? RequestPropertiesDataModel.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
