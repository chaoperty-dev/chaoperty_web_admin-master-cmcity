class InvoiceReModel {
  String? ser;
  String? daterec;
  String? date;
  String? dateacc;
  String? dtype;
  String? mrp;
  String? docno;
  String? showdate;
  String? billno;
  String? custno;
  String? supno;
  String? refno;
  String? descr;
  String? billdate;
  String? ovalue;
  String? nvalue;
  String? qty;
  String? pri;
  String? pvat;
  String? vat;
  String? nvat;
  String? wht;
  String? nwht;
  String? camt;
  String? wtax;
  String? wamt;
  String? dis;
  String? disendbillper;
  String? disendbill;
  String? deposit;
  String? cn;
  String? amt;
  String? remark;
  String? note;
  String? meter;
  String? ptser;
  String? ptname;
  String? bno;
  String? bank;
  String? img;
  String? btype;
  String? scname;
  String? cname;
  String? ln;
  String? zser;
  String? expser;
  String? expname;
  String? amt_expname;
  String? total_dis;
  String? total_bill;
  String? exp_array;
  String? cid;
  String? zn;
  String? total_vat;
  String? total_wht;
  String? amt_dis;
  String? payment_ser;
  String? qty_exp;
  String? pay_fine;
  String? pay_dis;
  String? paytotal_dis;
  String? inv;
  String? refapi;
  String? name_user;
  String? pdate;
  String? doctax;
  String? ser_noti;
  String? shopno;
  String? pos;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? stype;
  String? tel;
  String? zn_code;
  String? payser;
  String? total_docs;

  InvoiceReModel({
    this.ser,
    this.daterec,
    this.date,
    this.dateacc,
    this.dtype,
    this.mrp,
    this.docno,
    this.showdate,
    this.billno,
    this.custno,
    this.supno,
    this.refno,
    this.descr,
    this.billdate,
    this.ovalue,
    this.nvalue,
    this.qty,
    this.pri,
    this.pvat,
    this.vat,
    this.nvat,
    this.wht,
    this.nwht,
    this.camt,
    this.wtax,
    this.wamt,
    this.dis,
    this.disendbillper,
    this.disendbill,
    this.deposit,
    this.cn,
    this.amt,
    this.remark,
    this.note,
    this.meter,
    this.ptser,
    this.ptname,
    this.bno,
    this.bank,
    this.img,
    this.btype,
    this.scname,
    this.cname,
    this.ln,
    this.zser,
    this.expser,
    this.expname,
    this.amt_expname,
    this.total_dis,
    this.total_bill,
    this.exp_array,
    this.cid,
    this.zn,
    this.total_vat,
    this.total_wht,
    this.amt_dis,
    this.payment_ser,
    this.qty_exp,
    this.pay_fine,
    this.pay_dis,
    this.paytotal_dis,
    this.inv,
    this.refapi,
    this.name_user,
    this.pdate,
    this.doctax,
    this.ser_noti,
    this.shopno,
    this.pos,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.stype,
    this.tel,
    this.zn_code,
    this.payser,
    this.total_docs,
  });

  InvoiceReModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    daterec = json['daterec']?.toString();
    date = json['date']?.toString();
    dateacc = json['dateacc']?.toString();
    dtype = json['dtype']?.toString();
    mrp = json['mrp']?.toString();
    docno = json['docno']?.toString();
    showdate = json['showdate']?.toString();
    billno = json['billno']?.toString();
    custno = json['custno']?.toString();
    supno = json['supno']?.toString();
    refno = json['refno']?.toString();
    descr = json['descr']?.toString();
    billdate = json['billdate']?.toString();
    ovalue = json['ovalue']?.toString();
    nvalue = json['nvalue']?.toString();
    qty = json['qty']?.toString();
    pri = json['pri']?.toString();
    pvat = json['pvat']?.toString();
    vat = json['vat']?.toString();
    nvat = json['nvat']?.toString();
    wht = json['wht']?.toString();
    nwht = json['nwht']?.toString();
    camt = json['camt']?.toString();
    wtax = json['wtax']?.toString();
    wamt = json['wamt']?.toString();
    dis = json['dis']?.toString();
    disendbillper = json['disendbillper']?.toString();
    disendbill = json['disendbill']?.toString();
    deposit = json['deposit']?.toString();
    cn = json['cn']?.toString();
    amt = json['amt']?.toString();
    remark = json['remark']?.toString();
    note = json['note']?.toString();
    meter = json['meter']?.toString();
    ptser = json['ptser']?.toString();
    ptname = json['ptname']?.toString();
    bno = json['bno']?.toString();
    bank = json['bank']?.toString();
    img = json['img']?.toString();
    btype = json['btype']?.toString();
    scname = json['scname']?.toString();
    cname = json['cname']?.toString();
    ln = json['ln']?.toString();
    zser = json['zser']?.toString();
    expser = json['expser']?.toString();
    expname = json['expname']?.toString();
    amt_expname = json['amt_expname']?.toString();
    total_dis = json['total_dis']?.toString();
    total_bill = json['total_bill']?.toString();
    exp_array = json['exp_array']?.toString();
    cid = json['cid']?.toString();
    zn = json['zn']?.toString();
    total_vat = json['total_vat']?.toString();
    total_wht = json['total_wht']?.toString();
    amt_dis = json['amt_dis']?.toString();
    payment_ser = json['payment_ser']?.toString();
    qty_exp = json['qty_exp']?.toString();
    pay_fine = json['pay_fine']?.toString();
    pay_dis = json['pay_dis']?.toString();
    paytotal_dis = json['paytotal_dis']?.toString();
    inv = json['inv']?.toString();
    refapi = json['refapi']?.toString();
    name_user = json['name_user']?.toString();
    pdate = json['pdate']?.toString();
    doctax = json['doctax']?.toString();
    ser_noti = json['ser_noti']?.toString();
    shopno = json['shopno']?.toString();
    pos = json['pos']?.toString();
    ref1 = json['ref1']?.toString();
    ref2 = json['ref2']?.toString();
    ref3 = json['ref3']?.toString();
    ref4 = json['ref4']?.toString();
    stype = json['stype']?.toString();
    tel = json['tel']?.toString();
    zn_code = json['zn_code']?.toString();
    payser = json['payser']?.toString();
    total_docs = json['total_docs']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['daterec'] = this.daterec;
    data['date'] = this.date;
    data['dateacc'] = this.dateacc;
    data['dtype'] = this.dtype;
    data['mrp'] = this.mrp;
    data['docno'] = this.docno;
    data['showdate'] = this.showdate;
    data['billno'] = this.billno;
    data['custno'] = this.custno;
    data['supno'] = this.supno;
    data['refno'] = this.refno;
    data['descr'] = this.descr;
    data['billdate'] = this.billdate;
    data['ovalue'] = this.ovalue;
    data['nvalue'] = this.nvalue;
    data['qty'] = this.qty;
    data['pri'] = this.pri;
    data['pvat'] = this.pvat;
    data['vat'] = this.vat;
    data['nvat'] = this.nvat;
    data['wht'] = this.wht;
    data['nwht'] = this.nwht;
    data['camt'] = this.camt;
    data['wtax'] = this.wtax;
    data['wamt'] = this.wamt;
    data['dis'] = this.dis;
    data['disendbillper'] = this.disendbillper;
    data['disendbill'] = this.disendbill;
    data['deposit'] = this.deposit;
    data['cn'] = this.cn;
    data['amt'] = this.amt;
    data['remark'] = this.remark;
    data['note'] = this.note;
    data['meter'] = this.meter;
    data['ptser'] = this.ptser;
    data['ptname'] = this.ptname;
    data['bno'] = this.bno;
    data['bank'] = this.bank;
    data['img'] = this.img;
    data['btype'] = this.btype;
    data['scname'] = this.scname;
    data['cname'] = this.cname;
    data['ln'] = this.ln;
    data['zser'] = this.zser;

    data['expser'] = this.expser;
    data['expname'] = this.expname;
    data['amt_expname'] = this.amt_expname;
    data['total_dis'] = this.total_dis;
    data['total_bill'] = this.total_bill;
    data['exp_array'] = this.exp_array;
    data['cid'] = this.cid;
    data['zn'] = this.zn;
    data['total_vat'] = this.total_vat;
    data['total_wht'] = this.total_wht;
    data['amt_dis'] = this.amt_dis;
    data['payment_ser'] = this.payment_ser;
    data['qty_exp'] = this.qty_exp;
    data['pay_fine'] = this.pay_fine;
    data['pay_dis'] = this.pay_dis;
    data['paytotal_dis'] = this.paytotal_dis;
    data['inv'] = this.inv;
    data['refapi'] = this.refapi;
    data['name_user'] = this.name_user;
    data['pdate'] = this.pdate;
    data['doctax'] = this.doctax;
    data['ser_noti'] = this.ser_noti;
    data['shopno'] = this.shopno;
    data['pos'] = this.pos;
    data['ref1'] = this.ref1;
    data['ref2'] = this.ref2;
    data['ref3'] = this.ref3;
    data['ref4'] = this.ref4;

    data['stype'] = this.stype;
    data['tel'] = this.tel;
    data['zn_code'] = this.zn_code;
    data['payser'] = this.payser;
    data['total_docs'] = this.total_docs;
    return data;
  }
}
