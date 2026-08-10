class TransReBillModel {
  String? ser;
  String? datex;
  String? timex;
  String? user;
  String? rser;
  String? daterec;
  String? timerec;
  String? date;
  String? dateacc;
  String? duedate;
  String? dateCheckin;
  String? dateCheckout;
  String? shopno;
  String? pos;
  String? shifts;
  String? st;
  String? dochtax;
  String? doctax;
  String? cid;
  String? meter;
  String? docno;
  String? custno;
  String? supno;
  String? supnox;
  String? refno;
  String? refnox;
  String? po;
  String? inv;
  String? accode;
  String? accodeAccrued;
  String? service;
  String? expense;
  String? xxxno;
  String? xxxdate;
  String? barcode;
  String? stcode;
  String? name;
  String? namex;
  String? unit;
  String? no;
  String? tqty;
  String? qty1;
  String? qty2;
  String? qty3;
  String? qty4;
  String? qty5;
  String? agqty;
  String? emp;
  String? distype;
  String? dis;
  String? discount;
  String? deposit;
  String? other;
  String? fine;
  String? expser;
  String? expname;
  String? term;
  String? sdate;
  String? ldate;
  String? amt;
  String? amtx;
  String? vtype;
  String? nvat;
  String? tax;
  String? vat;
  String? pvat;
  String? xpvat;
  String? xvat;
  String? wtax;
  String? wamt;
  String? nwht;
  String? wht;
  String? total;
  String? disendbill;
  String? diffx;
  String? dtype;
  String? dtypex;
  String? paid;
  String? refund;
  String? returnSt;
  String? asset;
  String? pass;
  String? datepass;
  String? remark;

  String? ovalue;
  String? nvalue;
  String? qty;
  String? pri;
  String? c_pvat;
  String? c_nvat;
  String? c_vat;
  String? c_amt;
  String? c_refno;
  String? c_note;

  String? ser_in;
  String? docno_in;

  String? unit_con;
  String? qty_con;
  String? amt_con;
  String? total_bill;
  String? sname;
  String? ln;
  String? ln2;
  String? pdate;
  String? total_dis;
  String? room_number;

  String? cname;
  String? addr;
  String? type;
  String? ramt;
  String? ramtd;
  String? bno;
  String? bank;
  String? remark1;
  String? zn;
  String? zn2;
  String? area;
  String? zser;
  String? zser1;
  String? znn;
  String? descr;
  String? descr1;
  String? slip;
  String? ptser;
  String? ptname;
  String? total_duesbill;
  String? sum_items;
  String? pay_by;
  String? pri_book;
  String? inv_end_date;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? date_book;
  String? fname_user;
  String? lname_user;
  String? round_p;
  String? paper;
  String? paper_run;
  String? amt_up;
  String? vat_up;
  String? inv2;
  String? sum_pvat;
  String? sum_vat;
  String? sum_wht;
  String? reduce_debt;
  String? reduce_status;
  String? reduce_bill;
  String? date_cid;
  String? status_cid;
  String? name_user;
  String? dis_list;
  String? receipt_ser;
  String? zn_code;

  TransReBillModel({
    this.ser,
    this.datex,
    this.timex,
    this.user,
    this.rser,
    this.daterec,
    this.timerec,
    this.date,
    this.dateacc,
    this.duedate,
    this.dateCheckin,
    this.dateCheckout,
    this.shopno,
    this.pos,
    this.shifts,
    this.st,
    this.dochtax,
    this.doctax,
    this.cid,
    this.meter,
    this.docno,
    this.custno,
    this.supno,
    this.supnox,
    this.refno,
    this.refnox,
    this.po,
    this.inv,
    this.accode,
    this.accodeAccrued,
    this.service,
    this.expense,
    this.xxxno,
    this.xxxdate,
    this.barcode,
    this.stcode,
    this.name,
    this.namex,
    this.unit,
    this.no,
    this.tqty,
    this.qty1,
    this.qty2,
    this.qty3,
    this.qty4,
    this.qty5,
    this.agqty,
    this.emp,
    this.distype,
    this.dis,
    this.discount,
    this.deposit,
    this.other,
    this.fine,
    this.expser,
    this.expname,
    this.term,
    this.sdate,
    this.ldate,
    this.amt,
    this.amtx,
    this.vtype,
    this.nvat,
    this.tax,
    this.vat,
    this.pvat,
    this.xpvat,
    this.xvat,
    this.wtax,
    this.wamt,
    this.nwht,
    this.wht,
    this.total,
    this.disendbill,
    this.diffx,
    this.dtype,
    this.dtypex,
    this.paid,
    this.refund,
    this.returnSt,
    this.asset,
    this.pass,
    this.datepass,
    this.remark,
    this.ovalue,
    this.nvalue,
    this.qty,
    this.pri,
    this.c_pvat,
    this.c_nvat,
    this.c_vat,
    this.c_amt,
    this.c_refno,
    this.c_note,
    this.ser_in,
    this.docno_in,
    this.unit_con,
    this.qty_con,
    this.amt_con,
    this.total_bill,
    this.sname,
    this.ln,
    this.ln2,
    this.pdate,
    this.total_dis,
    this.room_number,
    this.cname,
    this.addr,
    this.type,
    this.ramt,
    this.ramtd,
    this.bno,
    this.bank,
    this.remark1,
    this.zn,
    this.zn2,
    this.area,
    this.zser,
    this.zser1,
    this.znn,
    this.descr,
    this.descr1,
    this.slip,
    this.ptser,
    this.ptname,
    this.total_duesbill,
    this.sum_items,
    this.pay_by,
    this.pri_book,
    this.inv_end_date,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.date_book,
    this.fname_user,
    this.lname_user,
    this.round_p,
    this.paper,
    this.paper_run,
    this.amt_up,
    this.vat_up,
    this.inv2,
    this.sum_pvat,
    this.sum_vat,
    this.sum_wht,
    this.reduce_debt,
    this.reduce_status,
    this.reduce_bill,
    this.date_cid,
    this.status_cid,
    this.name_user,
    this.dis_list,
    this.receipt_ser,
    this.zn_code,
  });

  TransReBillModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    datex = json['datex']?.toString();
    timex = json['timex']?.toString();
    user = json['user']?.toString();
    rser = json['rser']?.toString();
    daterec = json['daterec']?.toString();
    timerec = json['timerec']?.toString();
    date = json['date']?.toString();
    dateacc = json['dateacc']?.toString();
    duedate = json['duedate']?.toString();
    dateCheckin = json['date_checkin']?.toString();
    dateCheckout = json['date_checkout']?.toString();
    shopno = json['shopno']?.toString();
    pos = json['pos']?.toString();
    shifts = json['shifts']?.toString();
    st = json['st']?.toString();
    dochtax = json['dochtax']?.toString();
    doctax = json['doctax']?.toString();
    cid = json['cid']?.toString();
    meter = json['meter']?.toString();
    docno = json['docno']?.toString();
    custno = json['custno']?.toString();
    supno = json['supno']?.toString();
    supnox = json['supnox']?.toString();
    refno = json['refno']?.toString();
    refnox = json['refnox']?.toString();
    po = json['po']?.toString();
    inv = json['inv']?.toString();
    accode = json['accode']?.toString();
    accodeAccrued = json['accode_accrued']?.toString();
    service = json['service']?.toString();
    expense = json['expense']?.toString();
    xxxno = json['xxxno']?.toString();
    xxxdate = json['xxxdate']?.toString();
    barcode = json['barcode']?.toString();
    stcode = json['stcode']?.toString();
    name = json['name']?.toString();
    namex = json['namex']?.toString();
    unit = json['unit']?.toString();
    no = json['no']?.toString();
    tqty = json['tqty']?.toString();
    qty1 = json['qty1']?.toString();
    qty2 = json['qty2']?.toString();
    qty3 = json['qty3']?.toString();
    qty4 = json['qty4']?.toString();
    qty5 = json['qty5']?.toString();
    agqty = json['agqty']?.toString();
    emp = json['emp']?.toString();
    distype = json['distype']?.toString();
    dis = json['dis']?.toString();
    discount = json['discount']?.toString();
    deposit = json['deposit']?.toString();
    other = json['other']?.toString();
    fine = json['fine']?.toString();
    expser = json['expser']?.toString();
    expname = json['expname']?.toString();
    term = json['term']?.toString();
    sdate = json['sdate']?.toString();
    ldate = json['ldate']?.toString();
    amt = json['amt']?.toString();
    amtx = json['amtx']?.toString();
    vtype = json['vtype']?.toString();
    nvat = json['nvat']?.toString();
    tax = json['tax']?.toString();
    vat = json['vat']?.toString();
    pvat = json['pvat']?.toString();
    xpvat = json['xpvat']?.toString();
    xvat = json['xvat']?.toString();
    wtax = json['wtax']?.toString();
    wamt = json['wamt']?.toString();
    nwht = json['nwht']?.toString();
    wht = json['wht']?.toString();
    total = json['total']?.toString();
    disendbill = json['disendbill']?.toString();
    diffx = json['diffx']?.toString();
    dtype = json['dtype']?.toString();
    dtypex = json['dtypex']?.toString();
    paid = json['paid']?.toString();
    refund = json['refund']?.toString();
    returnSt = json['return_st']?.toString();
    asset = json['asset']?.toString();
    pass = json['pass']?.toString();
    datepass = json['datepass']?.toString();
    remark = json['remark']?.toString();

    ovalue = json['ovalue']?.toString();
    nvalue = json['nvalue']?.toString();
    qty = json['qty']?.toString();
    pri = json['pri']?.toString();
    c_pvat = json['c_pvat']?.toString();
    c_nvat = json['c_nvat']?.toString();
    c_vat = json['c_vat']?.toString();
    c_amt = json['c_amt']?.toString();
    c_refno = json['c_refno']?.toString();
    c_note = json['c_note']?.toString();
    ser_in = json['ser_in']?.toString();
    docno_in = json['docno_in']?.toString();
    unit_con = json['unit_con']?.toString();
    qty_con = json['qty_con']?.toString();
    amt_con = json['amt_con']?.toString();
    total_bill = json['total_bill']?.toString();
    sname = json['sname']?.toString();
    ln = json['ln']?.toString();
    ln2 = json['ln2']?.toString();
    pdate = json['pdate']?.toString();
    total_dis = json['total_dis']?.toString();
    room_number = json['room_number']?.toString();
    cname = json['cname']?.toString();
    addr = json['addr']?.toString();
    type = json['type']?.toString();
    ramt = json['ramt']?.toString();
    ramtd = json['ramtd']?.toString();
    bno = json['bno']?.toString();
    bank = json['bank']?.toString();
    remark1 = json['remark1']?.toString();
    zn = json['zn']?.toString();
    zn2 = json['zn2']?.toString();
    area = json['area']?.toString();
    zser = json['zser']?.toString();
    zser1 = json['zser1']?.toString();
    znn = json['znn']?.toString();
    descr = json['descr']?.toString();
    descr1 = json['descr1']?.toString();
    slip = json['slip']?.toString();
    ptser = json['ptser']?.toString();
    ptname = json['ptname']?.toString();
    total_duesbill = json['total_duesbill']?.toString();
    sum_items = json['sum_items']?.toString();
    pay_by = json['pay_by']?.toString();
    pri_book = json['pri_book']?.toString();
    inv_end_date = json['inv_end_date']?.toString();

    ref1 = json['ref1']?.toString();
    ref2 = json['ref2']?.toString();
    ref3 = json['ref3']?.toString();
    ref4 = json['ref4']?.toString();
    date_book = json['date_book']?.toString();
    fname_user = json['fname_user']?.toString();
    lname_user = json['lname_user']?.toString();

    round_p = json['round_p']?.toString();
    paper = json['paper']?.toString();
    paper_run = json['paper_run']?.toString();
    amt_up = json['amt_up']?.toString();
    vat_up = json['vat_up']?.toString();
    inv2 = json['inv2']?.toString();
    sum_pvat = json['sum_pvat']?.toString();
    sum_vat = json['sum_vat']?.toString();
    sum_wht = json['sum_wht']?.toString();

    reduce_debt = json['reduce_debt']?.toString();
    reduce_status = json['reduce_status']?.toString();
    reduce_bill = json['reduce_bill']?.toString();
    date_cid = json['date_cid']?.toString();
    status_cid = json['status_cid']?.toString();
    name_user = json['name_user']?.toString();
    dis_list = json['dis_list']?.toString();
    receipt_ser = json['receipt_ser']?.toString();
    zn_code = json['zn_code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['user'] = this.user;
    data['rser'] = this.rser;
    data['daterec'] = this.daterec;
    data['timerec'] = this.timerec;
    data['date'] = this.date;
    data['dateacc'] = this.dateacc;
    data['duedate'] = this.duedate;
    data['date_checkin'] = this.dateCheckin;
    data['date_checkout'] = this.dateCheckout;
    data['shopno'] = this.shopno;
    data['pos'] = this.pos;
    data['shifts'] = this.shifts;
    data['st'] = this.st;
    data['dochtax'] = this.dochtax;
    data['doctax'] = this.doctax;
    data['cid'] = this.cid;
    data['meter'] = this.meter;
    data['docno'] = this.docno;
    data['custno'] = this.custno;
    data['supno'] = this.supno;
    data['supnox'] = this.supnox;
    data['refno'] = this.refno;
    data['refnox'] = this.refnox;
    data['po'] = this.po;
    data['inv'] = this.inv;
    data['accode'] = this.accode;
    data['accode_accrued'] = this.accodeAccrued;
    data['service'] = this.service;
    data['expense'] = this.expense;
    data['xxxno'] = this.xxxno;
    data['xxxdate'] = this.xxxdate;
    data['barcode'] = this.barcode;
    data['stcode'] = this.stcode;
    data['name'] = this.name;
    data['namex'] = this.namex;
    data['unit'] = this.unit;
    data['no'] = this.no;
    data['tqty'] = this.tqty;
    data['qty1'] = this.qty1;
    data['qty2'] = this.qty2;
    data['qty3'] = this.qty3;
    data['qty4'] = this.qty4;
    data['qty5'] = this.qty5;
    data['agqty'] = this.agqty;
    data['emp'] = this.emp;
    data['distype'] = this.distype;
    data['dis'] = this.dis;
    data['discount'] = this.discount;
    data['deposit'] = this.deposit;
    data['other'] = this.other;
    data['fine'] = this.fine;
    data['expser'] = this.expser;
    data['expname'] = this.expname;
    data['term'] = this.term;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['amt'] = this.amt;
    data['amtx'] = this.amtx;
    data['vtype'] = this.vtype;
    data['nvat'] = this.nvat;
    data['tax'] = this.tax;
    data['vat'] = this.vat;
    data['pvat'] = this.pvat;
    data['xpvat'] = this.xpvat;
    data['xvat'] = this.xvat;
    data['wtax'] = this.wtax;
    data['wamt'] = this.wamt;
    data['nwht'] = this.nwht;
    data['wht'] = this.wht;
    data['total'] = this.total;
    data['disendbill'] = this.disendbill;
    data['diffx'] = this.diffx;
    data['dtype'] = this.dtype;
    data['dtypex'] = this.dtypex;
    data['paid'] = this.paid;
    data['refund'] = this.refund;
    data['return_st'] = this.returnSt;
    data['asset'] = this.asset;
    data['pass'] = this.pass;
    data['datepass'] = this.datepass;
    data['remark'] = this.remark;

    data['ovalue'] = this.ovalue;
    data['nvalue'] = this.nvalue;
    data['qty'] = this.qty;
    data['pri'] = this.pri;
    data['c_pvat'] = this.c_pvat;
    data['c_nvat'] = this.c_nvat;
    data['c_vat'] = this.c_vat;
    data['c_amt'] = this.c_amt;
    data['c_refno'] = this.c_refno;
    data['c_note'] = this.c_note;
    data['ser_in'] = this.ser_in;
    data['docno_in'] = this.docno_in;
    data['unit_con'] = this.unit_con;
    data['qty_con'] = this.qty_con;
    data['amt_con'] = this.amt_con;
    data['total_bill'] = this.total_bill;
    data['sname'] = this.sname;
    data['ln'] = this.ln;
    data['ln2'] = this.ln2;
    data['pdate'] = this.pdate;
    data['total_dis'] = this.total_dis;
    data['room_number'] = this.room_number;
    data['cname'] = this.cname;
    data['addr'] = this.addr;
    data['type'] = this.type;
    data['ramt'] = this.ramt;
    data['ramtd'] = this.ramtd;
    data['bno'] = this.bno;
    data['bank'] = this.bank;
    data['remark1'] = this.remark1;
    data['zn'] = this.zn;
    data['zn2'] = this.zn2;
    data['area'] = this.area;
    data['zser'] = this.zser;
    data['zser1'] = this.zser1;
    data['znn'] = this.znn;
    data['descr'] = this.descr;
    data['descr1'] = this.descr1;
    data['slip'] = this.slip;
    data['ptser'] = this.ptser;
    data['ptname'] = this.ptname;
    data['total_duesbill'] = this.total_duesbill;
    data['sum_items'] = this.sum_items;
    data['pay_by'] = this.pay_by;
    data['pri_book'] = this.pri_book;
    data['inv_end_date'] = this.inv_end_date;

    data['ref1'] = this.ref1;
    data['ref2'] = this.ref2;
    data['ref3'] = this.ref3;
    data['ref4'] = this.ref4;
    data['date_book'] = this.date_book;
    data['fname_user'] = this.fname_user;
    data['lname_user'] = this.lname_user;

    data['round_p'] = this.round_p;
    data['paper'] = this.paper;
    data['paper_run'] = this.paper_run;
    data['amt_up'] = this.amt_up;
    data['vat_up'] = this.vat_up;
    data['inv2'] = this.inv2;
    data['sum_pvat'] = this.sum_pvat;
    data['sum_vat'] = this.sum_vat;
    data['sum_wht'] = this.sum_wht;

    data['reduce_debt'] = this.reduce_debt;
    data['reduce_status'] = this.reduce_status;
    data['reduce_bill'] = this.reduce_bill;
    data['date_cid'] = this.date_cid;
    data['status_cid'] = this.status_cid;
    data['name_user'] = this.name_user;
    data['dis_list'] = this.dis_list;
    data['receipt_ser'] = this.receipt_ser;
    data['zn_code'] = this.zn_code;

    return data;
  }
}
