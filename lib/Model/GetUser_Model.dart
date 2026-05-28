class UserModel {
  String? ser;
  String? fname;
  String? lname;
  String? tel;
  String? email;
  String? passwd;
  String? position;
  String? st;
  String? user_id;
  String? permission;
  String? user;
  String? rser;
  String? utype;
  String? verify;
  String? otp;
  String? modeclor;
  String? data_update;
  String? connected;
  String? onoff;
  String? showst_update;
  String? system_datex;
  String? dev_text;
  String? type;
  String? syslog;
  String? pn;

  UserModel({
    this.ser,
    this.fname,
    this.lname,
    this.tel,
    this.email,
    this.passwd,
    this.position,
    this.st,
    this.user_id,
    this.permission,
    this.user,
    this.rser,
    this.utype,
    this.verify,
    this.otp,
    this.modeclor,
    this.connected,
    this.data_update,
    this.showst_update,
    this.system_datex,
    this.dev_text,
    this.onoff,
    this.type,
    this.syslog,
    this.pn,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    fname = json['fname']?.toString();
    lname = json['lname']?.toString();
    tel = json['tel']?.toString();
    email = json['email']?.toString();
    passwd = json['passwd']?.toString();
    position = json['position']?.toString();
    st = json['st']?.toString();
    user_id = json['user_id']?.toString();
    permission = json['permission']?.toString();
    user = json['user']?.toString();
    rser = json['rser']?.toString();
    utype = json['utype']?.toString();
    verify = json['verify']?.toString();
    otp = json['otp']?.toString();
    modeclor = json['modeclor']?.toString();
    connected = json['connected']?.toString();
    data_update = json['data_update']?.toString();
    onoff = json['onoff']?.toString();
    showst_update = json['showst_update']?.toString();
    system_datex = json['system_datex']?.toString();
    dev_text = json['dev_text']?.toString();
    type = json['type']?.toString();
    syslog = json['syslog']?.toString();
    pn = json['pn']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['fname'] = this.fname;
    data['lname'] = this.lname;
    data['tel'] = this.tel;
    data['email'] = this.email;
    data['passwd'] = this.passwd;
    data['position'] = this.position;
    data['st'] = this.st;
    data['user_id'] = this.user_id;
    data['permission'] = this.permission;
    data['user'] = this.user;
    data['rser'] = this.rser;
    data['utype'] = this.utype;
    data['verify'] = this.verify;
    data['otp'] = this.otp;
    data['modeclor'] = this.modeclor;
    data['data_update'] = this.data_update;
    data['connected'] = this.connected;
    data['onoff'] = this.onoff;
    data['showst_update'] = this.showst_update;
    data['system_datex'] = this.system_datex;
    data['dev_text'] = this.dev_text;
    data['type'] = this.type;
    data['syslog'] = this.syslog;
    data['pn'] = this.pn;
    return data;
  }
}
