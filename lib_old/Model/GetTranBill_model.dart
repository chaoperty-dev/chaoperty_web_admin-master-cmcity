class TransBillModel {
  String? ser;
  String? docno;
  String? tno;
  String? dtype;
  String? date;
  String? total;
  String? expname;
  String? invoice;
  String? descr;
  String? duedate;
  String? nvat;
  String? pvat;
  String? vat;
  String? nwht;
  String? wht;
  String? vtype;
  String? wtype;
  String? vser;
  String? meter;
  String? refno;
  String? ser_con;
  String? refnox;
  String? namex;
  String? befor_duedate;
  String? befor_date;
  String? befor_total;

  TransBillModel({
    this.ser,
    this.docno,
    this.tno,
    this.dtype,
    this.date,
    this.total,
    this.expname,
    this.invoice,
    this.descr,
    this.duedate,
    this.nvat,
    this.pvat,
    this.vat,
    this.nwht,
    this.wht,
    this.vtype,
    this.wtype,
    this.vser,
    this.meter,
    this.refno,
    this.ser_con,
    this.refnox,
    this.namex,
    this.befor_duedate,
    this.befor_date,
    this.befor_total,
  });

  TransBillModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    docno = json['docno'];
    tno = json['tno'];
    dtype = json['dtype'];
    date = json['date'];
    total = json['total'];
    expname = json['expname'];
    invoice = json['invoice'];
    descr = json['descr'];
    duedate = json['duedate'];
    nvat = json['nvat'];
    pvat = json['pvat'];
    vat = json['vat'];
    nwht = json['nwht'];
    wht = json['wht'];
    vtype = json['vtype'];
    wtype = json['wtype'];
    vser = json['vser'];
    meter = json['meter'];
    refno = json['refno'];
    ser_con = json['ser_con'];
    refnox = json['refnox'];
    namex = json['namex'];
    befor_duedate = json['befor_duedate'];
    befor_date = json['befor_date'];
    befor_total = json['befor_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['docno'] = this.docno;
    data['tno'] = this.tno;
    data['dtype'] = this.dtype;
    data['date'] = this.date;
    data['total'] = this.total;
    data['expname'] = this.expname;
    data['invoice'] = this.invoice;
    data['descr'] = this.descr;
    data['duedate'] = this.duedate;
    data['nvat'] = this.nvat;
    data['pvat'] = this.pvat;
    data['vat'] = this.vat;
    data['nwht'] = this.nwht;
    data['wht'] = this.wht;
    data['vtype'] = this.vtype;
    data['wtype'] = this.wtype;
    data['vser'] = this.vser;
    data['meter'] = this.meter;
    data['refno'] = this.refno;
    data['ser_con'] = this.ser_con;
    data['refnox'] = this.refnox;
    data['namex'] = this.namex;
    data['befor_duedate'] = this.befor_duedate;
    data['befor_date'] = this.befor_date;
    data['befor_total'] = this.befor_total;

    return data;
  }
}
