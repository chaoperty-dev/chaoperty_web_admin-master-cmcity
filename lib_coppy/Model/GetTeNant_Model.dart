class TeNantModel {
  String? ser;
  String? datex;
  String? timex;
  String? rser;
  String? zser;
  String? lncode;
  String? ln;
  String? area;
  String? rent;
  String? st;
  String? img;
  String? tser;
  String? tname;
  String? cid;
  String? dataUpdate;
  String? total;
  String? sdate;
  String? ldate;
  String? cdate;
  String? cname;
  String? sname;
  String? ln_c;
  String? area_c;
  String? docno;
  String? date;
  String? cname_q;
  String? sname_q;
  String? ln_q;
  String? ldate_q;
  String? sdate_q;
  String? area_q;
  String? quantity;
  String? period;
  String? period_q;
  String? rtname;
  String? rtname_q;
  String? stype;
  String? attn;
  String? addr;
  String? tax;
  String? tel;
  String? email;
  String? ctype;
  String? zn;
  String? znn;
  String? aser;
  String? qty;
  String? count_bill;
  String? invoice;
  String? expname;
  String? ser_tran;
  String? custno_1;
  String? custno_2;
  String? duedate;
  String? amt;
  String? amt_expser1;
  String? amt_expser9;
  String? amt_expser10;
  String? amt_expser11;
  String? amt_expser12;
  String? cc_remark;
  String? custno;
  String? user_name;
  String? passw;
  String? fid;
  String? renew_cid;
  String? cc_date;
  String? wnote;
  String? daterec;
  String? name_user;
  String? min_sdate;
  String? ser_paper;
  String? remark;
  String? note;
  String? paper;
  String? paper_run;
  String? renew_datex;
  String? renew_sdate;
  String? renew_ldate;
  String? exp_array;
  String? unit;
  String? type_cid;
  String? w1;
  String? customer_name;
  String? addrx;
  String? pgroup;
  String? is_mon;
  String? is_tue;
  String? is_wed;
  String? is_thu;
  String? is_fri;
  String? is_sat;
  String? is_sun;

  String? stime;
  String? ltime;
  String? zn_code;
  String? areatype;
  String? subzone;

  TeNantModel({
    this.ser,
    this.datex,
    this.timex,
    this.rser,
    this.zser,
    this.lncode,
    this.ln,
    this.area,
    this.rent,
    this.st,
    this.img,
    this.tser,
    this.tname,
    this.cid,
    this.dataUpdate,
    this.total,
    this.sdate,
    this.ldate,
    this.cdate,
    this.cname,
    this.sname,
    this.ln_c,
    this.area_c,
    this.docno,
    this.date,
    this.cname_q,
    this.sname_q,
    this.ln_q,
    this.ldate_q,
    this.sdate_q,
    this.area_q,
    this.quantity,
    this.period,
    this.period_q,
    this.rtname,
    this.rtname_q,
    this.stype,
    this.attn,
    this.addr,
    this.tax,
    this.tel,
    this.email,
    this.ctype,
    this.zn,
    this.znn,
    this.aser,
    this.qty,
    this.count_bill,
    this.invoice,
    this.expname,
    this.ser_tran,
    this.custno_1,
    this.custno_2,
    this.duedate,
    this.amt,
    this.amt_expser1,
    this.amt_expser9,
    this.amt_expser10,
    this.amt_expser11,
    this.amt_expser12,
    this.cc_remark,
    this.custno,
    this.user_name,
    this.passw,
    this.fid,
    this.renew_cid,
    this.cc_date,
    this.wnote,
    this.daterec,
    this.name_user,
    this.min_sdate,
    this.ser_paper,
    this.remark,
    this.note,
    this.paper,
    this.paper_run,
    this.renew_datex,
    this.renew_sdate,
    this.renew_ldate,
    this.exp_array,
    this.unit,
    this.type_cid,
    this.w1,
    this.customer_name,
    this.addrx,
    this.pgroup,
    this.is_mon,
    this.is_tue,
    this.is_wed,
    this.is_thu,
    this.is_fri,
    this.is_sat,
    this.is_sun,
    this.stime,
    this.ltime,
    this.zn_code,
    this.areatype,
    this.subzone,
  });
  TeNantModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    datex = json['datex']?.toString();
    timex = json['timex']?.toString();
    rser = json['rser']?.toString();
    zser = json['zser']?.toString();
    lncode = json['lncode']?.toString();
    ln = json['ln']?.toString();
    area = json['area']?.toString();
    rent = json['rent']?.toString();
    st = json['st']?.toString();
    img = json['img']?.toString();
    tser = json['tser']?.toString();
    tname = json['tname']?.toString();
    cid = json['cid']?.toString();
    dataUpdate = json['data_update']?.toString();
    total = json['total']?.toString();
    sdate = json['sdate']?.toString();
    cdate = json['cdate']?.toString();
    ldate = json['ldate']?.toString();
    cname = json['cname']?.toString();
    sname = json['sname']?.toString();
    ln_c = json['ln_c']?.toString();
    area_c = json['area_c']?.toString();
    docno = json['docno']?.toString();
    date = json['date']?.toString();

    cname_q = json['cname_q']?.toString();
    sname_q = json['sname_q']?.toString();
    ln_q = json['ln_q']?.toString();
    ldate_q = json['ldate_q']?.toString();
    sdate_q = json['sdate_q']?.toString();
    area_q = json['area_q']?.toString();
    quantity = json['quantity']?.toString();
    period = json['period']?.toString();
    period_q = json['period_q']?.toString();
    rtname = json['rtname']?.toString();
    rtname_q = json['rtname_q']?.toString();
    stype = json['stype']?.toString();
    attn = json['attn']?.toString();
    addr = json['addr']?.toString();
    tax = json['tax']?.toString();
    tel = json['tel']?.toString();
    email = json['email']?.toString();
    ctype = json['ctype']?.toString();
    zn = json['zn']?.toString();
    znn = json['znn']?.toString();
    aser = json['aser']?.toString();
    qty = json['qty']?.toString();
    count_bill = json['count_bill']?.toString();
    invoice = json['invoice']?.toString();
    expname = json['expname']?.toString();
    ser_tran = json['ser_tran']?.toString();

    custno_1 = json['custno_1']?.toString();
    custno_2 = json['custno_2']?.toString();
    duedate = json['duedate']?.toString();
    amt = json['amt']?.toString();

    amt_expser1 = json['amt_expser1']?.toString();
    amt_expser9 = json['amt_expser9']?.toString();
    amt_expser10 = json['amt_expser10']?.toString();
    amt_expser11 = json['amt_expser11']?.toString();
    amt_expser12 = json['amt_expser12']?.toString();
    cc_remark = json['cc_remark']?.toString();
    custno = json['custno']?.toString();
    user_name = json['user_name']?.toString();
    passw = json['passw']?.toString();
    fid = json['fid']?.toString();
    renew_cid = json['renew_cid']?.toString();
    cc_date = json['cc_date']?.toString();
    wnote = json['wnote']?.toString();
    daterec = json['daterec']?.toString();
    name_user = json['name_user']?.toString();
    min_sdate = json['min_sdate']?.toString();
    ser_paper = json['ser_paper']?.toString();
    remark = json['remark']?.toString();
    note = json['note']?.toString();
    paper = json['paper']?.toString();
    paper_run = json['paper_run']?.toString();

    renew_datex = json['renew_datex']?.toString();
    renew_sdate = json['renew_sdate']?.toString();
    renew_ldate = json['renew_ldate']?.toString();
    exp_array = json['exp_array']?.toString();
    unit = json['unit']?.toString();
    type_cid = json['type_cid']?.toString();
    w1 = json['w1']?.toString();
    customer_name = json['customer_name']?.toString();
    addrx = json['addrx']?.toString();
    pgroup = json['pgroup']?.toString();

    is_mon = json['is_mon']?.toString();
    is_tue = json['is_tue']?.toString();
    is_wed = json['is_wed']?.toString();
    is_thu = json['is_thu']?.toString();
    is_fri = json['is_fri']?.toString();
    is_sat = json['is_sat']?.toString();
    is_sun = json['is_sun']?.toString();
    stime = json['stime']?.toString();
    ltime = json['ltime']?.toString();
    zn_code = json['zn_code']?.toString();
    areatype = json['areatype']?.toString();
    subzone = json['subzone']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['rser'] = this.rser;
    data['zser'] = this.zser;
    data['lncode'] = this.lncode;
    data['ln'] = this.ln;
    data['area'] = this.area;
    data['rent'] = this.rent;
    data['st'] = this.st;
    data['img'] = this.img;
    data['tser'] = this.tser;
    data['tname'] = this.tname;
    data['cid'] = this.cid;
    data['data_update'] = this.dataUpdate;
    data['total'] = this.total;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['cdate'] = this.cdate;
    data['cname'] = this.cname;
    data['sname'] = this.sname;
    data['ln_c'] = this.ln_c;
    data['area_c'] = this.area_c;
    data['docno'] = this.docno;
    data['date'] = this.date;
    data['cname_q'] = this.cname_q;
    data['sname_q'] = this.sname_q;
    data['ln_q'] = this.ln_q;
    data['ldate_q'] = this.ldate_q;
    data['sdate_q'] = this.sdate_q;
    data['area_q'] = this.area_q;
    data['quantity'] = this.quantity;
    data['period'] = this.period;
    data['period_q'] = this.period_q;
    data['rtname'] = this.rtname;
    data['rtname_q'] = this.rtname_q;
    data['stype'] = this.stype;
    data['attn'] = this.attn;
    data['addr'] = this.addr;
    data['tax'] = this.tax;
    data['tel'] = this.tel;
    data['email'] = this.email;
    data['ctype'] = this.ctype;
    data['zn'] = this.zn;
    data['znn'] = this.znn;
    data['aser'] = this.aser;
    data['qty'] = this.qty;
    data['count_bill'] = this.count_bill;
    data['invoice'] = this.invoice;
    data['expname'] = this.expname;
    data['ser_tran'] = this.ser_tran;

    data['custno_1'] = this.custno_1;
    data['custno_2'] = this.custno_2;
    data['duedate'] = this.duedate;
    data['amt'] = this.amt;

    data['amt_expser1'] = this.amt_expser1;
    data['amt_expser9'] = this.amt_expser9;
    data['amt_expser10'] = this.amt_expser10;
    data['amt_expser11'] = this.amt_expser11;
    data['amt_expser12'] = this.amt_expser12;
    data['cc_remark'] = this.cc_remark;
    data['custno'] = this.custno;
    data['user_name'] = this.user_name;
    data['passw'] = this.passw;
    data['fid'] = this.fid;
    data['renew_cid'] = this.renew_cid;
    data['cc_date'] = this.cc_date;
    data['wnote'] = this.wnote;
    data['daterec'] = this.daterec;
    data['name_user'] = this.name_user;
    data['min_sdate'] = this.min_sdate;
    data['ser_paper'] = this.ser_paper;
    data['remark'] = this.remark;
    data['note'] = this.note;
    data['paper'] = this.paper;
    data['paper_run'] = this.paper_run;
    data['renew_datex'] = this.renew_datex;
    data['renew_sdate'] = this.renew_sdate;
    data['renew_ldate'] = this.renew_ldate;
    data['exp_array'] = this.exp_array;
    data['unit'] = this.unit;
    data['type_cid'] = this.type_cid;
    data['w1'] = this.w1;
    data['customer_name'] = this.customer_name;
    data['addrx'] = this.addrx;
    data['pgroup'] = this.pgroup;
    data['is_mon'] = this.is_mon;
    data['is_tue'] = this.is_tue;
    data['is_wed'] = this.is_wed;
    data['is_thu'] = this.is_thu;
    data['is_fri'] = this.is_fri;
    data['is_sat'] = this.is_sat;
    data['is_sun'] = this.is_sun;
    data['stime'] = this.stime;
    data['ltime'] = this.ltime;
    data['zn_code'] = this.zn_code;
    data['areatype'] = this.areatype;
    data['subzone'] = this.subzone;
    return data;
  }
}
