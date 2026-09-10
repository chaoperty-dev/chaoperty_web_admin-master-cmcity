class InvoiceCNModel {
  String? cid;
  String? inv;
  String? date;
  String? daterec;
  String? docno;
  String? expname;
  String? refno;
  String? dtype;
  String? amt;
  String? pvat;
  String? vat;
  String? wht;
  String? total;
  String? nameCn;
  String? docnoCn;
  String? dtypeCn;
  String? amtCn;
  String? vatCn;
  String? pvatCn;
  String? whtCn;
  String? mrp;

  InvoiceCNModel(
      {this.cid,
      this.inv,
      this.date,
      this.daterec,
      this.docno,
      this.expname,
      this.refno,
      this.dtype,
      this.amt,
      this.pvat,
      this.vat,
      this.wht,
      this.total,
      this.nameCn,
      this.docnoCn,
      this.dtypeCn,
      this.amtCn,
      this.vatCn,
      this.pvatCn,
      this.whtCn,
      this.mrp});

  InvoiceCNModel.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    inv = json['inv'];
    date = json['date'];
    daterec = json['daterec'];
    docno = json['docno'];
    expname = json['expname'];
    refno = json['refno'];
    dtype = json['dtype'];
    amt = json['amt'];
    pvat = json['pvat'];
    vat = json['vat'];
    wht = json['wht'];
    total = json['total'];
    nameCn = json['name_cn'];
    docnoCn = json['docno_cn'];
    dtypeCn = json['dtype_cn'];
    amtCn = json['amt_cn'];
    vatCn = json['vat_cn'];
    pvatCn = json['pvat_cn'];
    whtCn = json['wht_cn'];
    mrp = json['mrp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cid'] = this.cid;
    data['inv'] = this.inv;
    data['date'] = this.date;
    data['daterec'] = this.daterec;
    data['docno'] = this.docno;
    data['expname'] = this.expname;
    data['refno'] = this.refno;
    data['dtype'] = this.dtype;
    data['amt'] = this.amt;
    data['pvat'] = this.pvat;
    data['vat'] = this.vat;
    data['wht'] = this.wht;
    data['total'] = this.total;
    data['name_cn'] = this.nameCn;
    data['docno_cn'] = this.docnoCn;
    data['dtype_cn'] = this.dtypeCn;
    data['amt_cn'] = this.amtCn;
    data['vat_cn'] = this.vatCn;
    data['pvat_cn'] = this.pvatCn;
    data['wht_cn'] = this.whtCn;
    data['mrp'] = this.mrp;
    return data;
  }
}
