class Read_DataONBill_PDFModel {
  String? ser;
  String? rser;
  String? docno;
  String? doctax;
  String? cid;
  String? datex;
  String? znn;
  String? daterec;
  String? dateacc;
  String? expname;
  String? room_number;
  String? scname;
  String? cname;
  String? addr1;
  String? tax;
  String? tel;
  String? email;
  String? stype;
  String? type;
  String? zn;
  String? ln;
  String? lncode;
  String? ln_c;
  String? custno;
  String? remark;
  String? user;
  String? scname1;
  String? cname1;
  String? pdate;
  String? con_remark;
  String? round_p;
  String? paper;
  String? paper_run;
  String? amt_up;
  String? vat_up;
  String? user_updata;

  Read_DataONBill_PDFModel({
    this.ser,
    this.rser,
    this.docno,
    this.doctax,
    this.cid,
    this.datex,
    this.znn,
    this.daterec,
    this.dateacc,
    this.expname,
    this.room_number,
    this.scname,
    this.cname,
    this.addr1,
    this.tax,
    this.tel,
    this.email,
    this.stype,
    this.type,
    this.zn,
    this.ln,
    this.lncode,
    this.ln_c,
    this.custno,
    this.remark,
    this.user,
    this.scname1,
    this.cname1,
    this.pdate,
    this.con_remark,
    this.round_p,
    this.paper,
    this.paper_run,
    this.amt_up,
    this.vat_up,
    this.user_updata,
  });

  Read_DataONBill_PDFModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    rser = json['rser'];
    docno = json['docno'];
    doctax = json['doctax'];
    cid = json['cid'];
    datex = json['datex'];
    znn = json['znn'];
    daterec = json['daterec'];
    dateacc = json['dateacc'];
    expname = json['expname'];
    room_number = json['room_number'];
    scname = json['scname'];
    cname = json['cname'];
    addr1 = json['addr_1'];
    tax = json['tax'];
    tel = json['tel'];
    email = json['email'];
    stype = json['stype'];
    type = json['type'];
    zn = json['zn'];
    ln = json['ln'];
    lncode = json['lncode'];
    ln_c = json['ln_c'];
    custno = json['custno'];
    remark = json['remark'];
    user = json['user'];
    scname1 = json['scname1'];
    cname1 = json['cname1'];
    pdate = json['pdate'];
    con_remark = json['con_remark'];

    round_p = json['round_p'];
    paper = json['paper'];
    paper_run = json['paper_run'];
    amt_up = json['amt_up'];
    vat_up = json['vat_up'];
    user_updata = json['user_updata'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['rser'] = this.rser;
    data['docno'] = this.docno;
    data['doctax'] = this.doctax;
    data['cid'] = this.cid;
    data['datex'] = this.datex;
    data['znn'] = this.znn;
    data['daterec'] = this.daterec;
    data['dateacc'] = this.dateacc;
    data['expname'] = this.expname;
    data['room_number'] = this.room_number;
    data['scname'] = this.scname;
    data['cname'] = this.cname;
    data['addr_1'] = this.addr1;
    data['tax'] = this.tax;
    data['tel'] = this.tel;
    data['email'] = this.email;
    data['stype'] = this.stype;
    data['type'] = this.type;
    data['zn'] = this.zn;
    data['ln'] = this.ln;
    data['lncode'] = this.lncode;
    data['ln_c'] = this.ln_c;
    data['custno'] = this.custno;
    data['remark'] = this.remark;
    data['user'] = this.user;
    data['scname1'] = this.scname1;
    data['cname1'] = this.cname1;
    data['pdate'] = this.pdate;
    data['con_remark'] = this.con_remark;

    data['round_p'] = this.round_p;
    data['paper'] = this.paper;
    data['paper_run'] = this.paper_run;
    data['amt_up'] = this.amt_up;
    data['vat_up'] = this.vat_up;
    data['user_updata'] = this.user_updata;
    return data;
  }
}
