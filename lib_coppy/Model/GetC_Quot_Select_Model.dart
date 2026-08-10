class QuotxSelectModel {
  String? ser;
  String? datex;
  String? qser;
  String? docno;
  String? expser;
  String? expname;
  String? exptser;
  String? sunit;
  String? unit;
  String? unitser;
  String? day;
  String? sday;
  String? term;
  String? sdate;
  String? meter;
  String? qty;
  String? ldate;
  String? amt;
  String? vtype;
  String? wtype;
  String? nvat;
  String? vat;
  String? pvat;
  String? nwht;
  String? wht;
  String? fine;
  String? fineUnit;
  String? fineLate;
  String? fineCal;
  String? finePri;
  String? st;
  String? total;
  String? dataUpdate;
  String? dtype;
  String? etype;
  String? ele_ty;
  String? amt_ty;
  String? fine_three;
  String? fine_late_three;
  String? fine_cal_three;
  String? fine_max;
  String? fine_max_cal;
  String? pay_pakan;
  String? first_total;
  String? cfid;
  String? pdate;
  String? exp_array;
  String? pri;
  String? total_prev;

  String? is_mon;
  String? is_tue;
  String? is_wed;
  String? is_thu;
  String? is_fri;
  String? is_sat;
  String? is_sun;
  String? price_type;
  String? trans_array;
  String? totals;

  QuotxSelectModel({
    this.ser,
    this.datex,
    this.qser,
    this.docno,
    this.expser,
    this.expname,
    this.exptser,
    this.sunit,
    this.unit,
    this.unitser,
    this.day,
    this.sday,
    this.term,
    this.sdate,
    this.meter,
    this.qty,
    this.ldate,
    this.amt,
    this.vtype,
    this.wtype,
    this.nvat,
    this.vat,
    this.pvat,
    this.nwht,
    this.wht,
    this.fine,
    this.fineUnit,
    this.fineLate,
    this.fineCal,
    this.finePri,
    this.st,
    this.total,
    this.dataUpdate,
    this.dtype,
    this.etype,
    this.ele_ty,
    this.amt_ty,
    this.fine_three,
    this.fine_late_three,
    this.fine_cal_three,
    this.fine_max,
    this.fine_max_cal,
    this.pay_pakan,
    this.first_total,
    this.cfid,
    this.pdate,
    this.exp_array,
    this.pri,
    this.total_prev,
    this.is_mon,
    this.is_tue,
    this.is_wed,
    this.is_thu,
    this.is_fri,
    this.is_sat,
    this.is_sun,
    this.price_type,
    this.trans_array,
    this.totals,
  });

  QuotxSelectModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    datex = json['datex'];
    qser = json['qser'];
    docno = json['docno'];
    expser = json['expser'];
    expname = json['expname'];
    exptser = json['exptser'];
    sunit = json['sunit'];
    unit = json['unit'];
    unitser = json['unitser'];
    day = json['day'];
    sday = json['sday'];
    term = json['term'];
    sdate = json['sdate'];
    meter = json['meter'];
    qty = json['qty'];
    ldate = json['ldate'];
    amt = json['amt'];
    vtype = json['vtype'];
    wtype = json['wtype'];
    nvat = json['nvat'];
    vat = json['vat'];
    pvat = json['pvat'];
    nwht = json['nwht'];
    wht = json['wht'];
    fine = json['fine'];
    fineUnit = json['fine_unit'];
    fineLate = json['fine_late'];
    fineCal = json['fine_cal'];
    finePri = json['fine_pri'];
    st = json['st'];
    total = json['total'];
    dataUpdate = json['data_update'];
    dtype = json['dtype'];
    etype = json['etype'];
    ele_ty = json['ele_ty'];
    amt_ty = json['amt_ty'];
    fine_three = json['fine_three'];
    fine_late_three = json['fine_late_three'];
    fine_cal_three = json['fine_cal_three'];
    fine_max = json['fine_max'];
    fine_max_cal = json['fine_max_cal'];
    pay_pakan = json['pay_pakan'];
    first_total = json['first_total'];
    cfid = json['cfid'];
    pdate = json['pdate'];
    exp_array = json['exp_array'];
    pri = json['pri'];
    total_prev = json['total_prev'];

    is_mon = json['is_mon'];
    is_tue = json['is_tue'];
    is_wed = json['is_wed'];
    is_thu = json['is_thu'];
    is_fri = json['is_fri'];
    is_sat = json['is_sat'];
    is_sun = json['is_sun'];
    price_type = json['price_type'];
    trans_array = json['trans_array'];
    totals = json['totals'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['qser'] = this.qser;
    data['docno'] = this.docno;
    data['expser'] = this.expser;
    data['expname'] = this.expname;
    data['exptser'] = this.exptser;
    data['sunit'] = this.sunit;
    data['unit'] = this.unit;
    data['unitser'] = this.unitser;
    data['day'] = this.day;
    data['sday'] = this.sday;
    data['term'] = this.term;
    data['sdate'] = this.sdate;
    data['meter'] = this.meter;
    data['qty'] = this.qty;
    data['ldate'] = this.ldate;
    data['amt'] = this.amt;
    data['vtype'] = this.vtype;
    data['wtype'] = this.wtype;
    data['nvat'] = this.nvat;
    data['vat'] = this.vat;
    data['pvat'] = this.pvat;
    data['nwht'] = this.nwht;
    data['wht'] = this.wht;
    data['fine'] = this.fine;
    data['fine_unit'] = this.fineUnit;
    data['fine_late'] = this.fineLate;
    data['fine_cal'] = this.fineCal;
    data['fine_pri'] = this.finePri;
    data['st'] = this.st;
    data['total'] = this.total;
    data['data_update'] = this.dataUpdate;
    data['dtype'] = this.dtype;
    data['etype'] = this.etype;
    data['ele_ty'] = this.ele_ty;
    data['amt_ty'] = this.amt_ty;
    data['fine_three'] = this.fine_three;
    data['fine_late_three'] = this.fine_late_three;
    data['fine_cal_three'] = this.fine_cal_three;
    data['fine_max'] = this.fine_max;
    data['fine_max_cal'] = this.fine_max_cal;
    data['pay_pakan'] = this.pay_pakan;
    data['first_total'] = this.first_total;
    data['cfid'] = this.cfid;
    data['pdate'] = this.pdate;
    data['exp_array'] = this.exp_array;
    data['pri'] = this.pri;
    data['total_prev'] = this.total_prev;

    data['is_mon'] = this.is_mon;
    data['is_tue'] = this.is_tue;
    data['is_wed'] = this.is_wed;
    data['is_thu'] = this.is_thu;
    data['is_fri'] = this.is_fri;
    data['is_sat'] = this.is_sat;
    data['is_sun'] = this.is_sun;
    data['price_type'] = this.price_type;
    data['trans_array'] = this.trans_array;
    data['totals'] = this.totals;

    return data;
  }
}
