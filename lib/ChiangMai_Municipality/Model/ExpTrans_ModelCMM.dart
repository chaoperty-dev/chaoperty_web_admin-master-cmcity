class ExpTransModelCMM {
  String? ser;
  String? datex;
  String? timex;
  String? qser;
  String? docno;
  String? expser;
  String? expname;
  String? exptser;
  String? sunit;
  String? unitser;
  String? unit;
  String? day;
  String? term;
  String? sdate;
  String? ldate;
  String? meter;
  String? qty;
  String? amt;
  String? servat;
  String? vser;
  String? vtype;
  String? nvat;
  String? vat;
  String? pvat;
  String? wser;
  String? nwht;
  String? wht;
  String? wtype;
  String? fine;
  String? fine_unit;
  String? fine_late;
  String? fine_cal;
  String? fine_pri;
  String? st;
  String? total;
  String? data_update;
  String? etype;
  String? dtype;
  String? ele_ty;
  String? amt_ty;
  String? fine_three;
  String? fine_late_three;
  String? fine_cal_three;
  String? fine_max;
  String? fine_max_cal;
  String? pay_pakan;
  String? pri_auto;

  ExpTransModelCMM({
    this.ser,
    this.datex,
    this.timex,
    this.qser,
    this.docno,
    this.expser,
    this.expname,
    this.exptser,
    this.sunit,
    this.unitser,
    this.unit,
    this.day,
    this.term,
    this.sdate,
    this.ldate,
    this.meter,
    this.qty,
    this.amt,
    this.servat,
    this.vser,
    this.vtype,
    this.nvat,
    this.vat,
    this.pvat,
    this.wser,
    this.nwht,
    this.wht,
    this.wtype,
    this.fine,
    this.fine_unit,
    this.fine_late,
    this.fine_cal,
    this.fine_pri,
    this.st,
    this.total,
    this.data_update,
    this.etype,
    this.dtype,
    this.ele_ty,
    this.amt_ty,
    this.fine_three,
    this.fine_late_three,
    this.fine_cal_three,
    this.fine_max,
    this.fine_max_cal,
    this.pay_pakan,
    this.pri_auto,
  });

  factory ExpTransModelCMM.fromJson(Map<String, dynamic> json) {
    return ExpTransModelCMM(
      ser: json['ser']?.toString(),
      datex: json['datex']?.toString(),
      timex: json['timex']?.toString(),
      qser: json['qser']?.toString(),
      docno: json['docno']?.toString(),
      expser: json['expser']?.toString(),
      expname: json['expname']?.toString(),
      exptser: json['exptser']?.toString(),
      sunit: json['sunit']?.toString(),
      unitser: json['unitser']?.toString(),
      unit: json['unit']?.toString(),
      day: json['day']?.toString(),
      term: json['term']?.toString(),
      sdate: json['sdate']?.toString(),
      ldate: json['ldate']?.toString(),
      meter: json['meter']?.toString(),
      qty: json['qty']?.toString(),
      amt: json['amt']?.toString(),
      servat: json['servat']?.toString(),
      vser: json['vser']?.toString(),
      vtype: json['vtype']?.toString(),
      nvat: json['nvat']?.toString(),
      vat: json['vat']?.toString(),
      pvat: json['pvat']?.toString(),
      wser: json['wser']?.toString(),
      nwht: json['nwht']?.toString(),
      wht: json['wht']?.toString(),
      wtype: json['wtype']?.toString(),
      fine: json['fine']?.toString(),
      fine_unit: json['fine_unit']?.toString(),
      fine_late: json['fine_late']?.toString(),
      fine_cal: json['fine_cal']?.toString(),
      fine_pri: json['fine_pri']?.toString(),
      st: json['st']?.toString(),
      total: json['total']?.toString(),
      data_update: json['data_update']?.toString(),
      etype: json['etype']?.toString(),
      dtype: json['dtype']?.toString(),
      ele_ty: json['ele_ty']?.toString(),
      amt_ty: json['amt_ty']?.toString(),
      fine_three: json['fine_three']?.toString(),
      fine_late_three: json['fine_late_three']?.toString(),
      fine_cal_three: json['fine_cal_three']?.toString(),
      fine_max: json['fine_max']?.toString(),
      fine_max_cal: json['fine_max_cal']?.toString(),
      pay_pakan: json['pay_pakan']?.toString(),
      pri_auto: json['pri_auto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ser': ser,
      'datex': datex,
      'timex': timex,
      'qser': qser,
      'docno': docno,
      'expser': expser,
      'expname': expname,
      'exptser': exptser,
      'sunit': sunit,
      'unitser': unitser,
      'unit': unit,
      'day': day,
      'term': term,
      'sdate': sdate,
      'ldate': ldate,
      'meter': meter,
      'qty': qty,
      'amt': amt,
      'servat': servat,
      'vser': vser,
      'vtype': vtype,
      'nvat': nvat,
      'vat': vat,
      'pvat': pvat,
      'wtype': wtype,
      'nwht': nwht,
      'wht': wht,
      'wtype': wtype,
      'fine': fine,
      'fine_unit': fine_unit,
      'fine_late': fine_late,
      'fine_cal': fine_cal,
      'fine_pri': fine_pri,
      'st': st,
      'total': total,
      'data_update': data_update,
      'etype': etype,
      'dtype': dtype,
      'ele_ty': ele_ty,
      'amt_ty': amt_ty,
      'fine_three': fine_three,
      'fine_late_three': fine_late_three,
      'fine_cal_three': fine_cal_three,
      'fine_max': fine_max,
      'fine_max_cal': fine_max_cal,
      'pay_pakan': pay_pakan,
      'pri_auto': pri_auto,
    };
  }
}
