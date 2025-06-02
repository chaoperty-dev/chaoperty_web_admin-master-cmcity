class TeNantCanCellChoiceModel {
  String? ser;
  String? datex;
  String? timex;
  String? user;
  String? name_user;
  String? rser;
  String? daterec;
  String? timerec;
  String? date;
  String? dateacc;
  String? duedate;
  String? cid;

  String? st;
  String? cc_remark;
  String? cc_date;
  String? cname;
  String? sname;
  String? stype;
  String? addr;
  String? tax;
  String? zn;
  String? zn1;
  String? zser;
  String? zser1;
  String? ln;
  String? sdate;
  String? ldate;
  String? docno;
  String? doctax;
  String? pdate;
  String? remark;
  String? total_bill;
  String? total_pay;
  String? pakan_pvat;
  String? pakan_vat;
  String? pakan_total;
  String? water_electri;
  String? land_name;
  String? land_amt;
  String? land_pvat;
  String? land_vat;
  String? land_total;

  String? rent_name;
  String? rent_amt;
  String? rent_pvat;
  String? rent_vat;
  String? rent_total;
  String? service_name;
  String? service_amt;
  String? service_pvat;
  String? service_vat;
  String? service_total;
  String? water;
  String? electricity;
  String? fine;
  String? renew_cid;
  String? data_update;
  String? min_docno;
  String? min_doctax;
  String? min_pdate;
  String? ref1;
  String? ref2;
  String? ref3;
  String? ref4;
  String? wnote;
  String? tel;
  String? cdate;
  String? inv;
  String? w1;

  TeNantCanCellChoiceModel({
    this.ser,
    this.datex,
    this.timex,
    this.user,
    this.name_user,
    this.rser,
    this.daterec,
    this.timerec,
    this.date,
    this.dateacc,
    this.duedate,
    this.cid,
    this.st,
    this.cc_remark,
    this.cc_date,
    this.cname,
    this.sname,
    this.stype,
    this.addr,
    this.tax,
    this.zn,
    this.zn1,
    this.zser,
    this.zser1,
    this.ln,
    this.sdate,
    this.ldate,
    this.docno,
    this.doctax,
    this.pdate,
    this.remark,
    this.total_bill,
    this.total_pay,
    this.pakan_pvat,
    this.pakan_vat,
    this.pakan_total,
    this.water_electri,
    this.land_name,
    this.land_amt,
    this.land_pvat,
    this.land_vat,
    this.land_total,
    this.rent_name,
    this.rent_amt,
    this.rent_pvat,
    this.rent_vat,
    this.rent_total,
    this.service_name,
    this.service_amt,
    this.service_pvat,
    this.service_vat,
    this.service_total,
    this.water,
    this.electricity,
    this.fine,
    this.renew_cid,
    this.data_update,
    this.min_docno,
    this.min_doctax,
    this.min_pdate,
    this.ref1,
    this.ref2,
    this.ref3,
    this.ref4,
    this.wnote,
    this.tel,
    this.cdate,
    this.inv,
    this.w1,
  });

  TeNantCanCellChoiceModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    datex = json['datex'];
    timex = json['timex'];
    user = json['user'];
    name_user = json['name_user'];
    rser = json['rser'];
    daterec = json['daterec'];
    timerec = json['timerec'];
    date = json['date'];
    dateacc = json['dateacc'];
    duedate = json['duedate'];
    cid = json['cid'];

    st = json['st'];
    cc_remark = json['cc_remark'];
    cc_date = json['cc_date'];
    cname = json['cname'];
    sname = json['sname'];
    stype = json['stype'];
    addr = json['addr'];
    tax = json['tax'];
    zn = json['zn'];
    zn1 = json['zn1'];
    zser = json['zser'];
    zser1 = json['zser1'];
    ln = json['ln'];
    sdate = json['sdate'];
    ldate = json['ldate'];
    docno = json['docno'];
    doctax = json['doctax'];
    pdate = json['pdate'];
    remark = json['remark'];
    total_bill = json['total_bill'];
    total_pay = json['total_pay'];
    pakan_pvat = json['pakan_pvat'];
    pakan_vat = json['pakan_vat'];
    pakan_total = json['pakan_total'];
    water_electri = json['water_electri'];
    land_name = json['land_name'];
    land_amt = json['land_amt'];
    land_pvat = json['land_pvat'];
    land_vat = json['land_vat'];
    land_total = json['land_total'];

    rent_name = json['rent_name'];
    rent_amt = json['rent_amt'];
    rent_pvat = json['rent_pvat'];
    rent_vat = json['rent_vat'];
    rent_total = json['rent_total'];
    service_name = json['service_name'];
    service_amt = json['service_amt'];
    service_pvat = json['service_pvat'];
    service_vat = json['service_vat'];
    service_total = json['service_total'];
    water = json['water'];
    electricity = json['electricity'];
    fine = json['fine'];
    renew_cid = json['renew_cid'];
    data_update = json['data_update'];
    min_docno = json['min_docno'];
    min_doctax = json['min_doctax'];
    min_pdate = json['min_pdate'];
    ref1 = json['ref1'];
    ref2 = json['ref2'];
    ref3 = json['ref3'];
    ref4 = json['ref4'];
    wnote = json['wnote'];
    tel = json['tel'];
    cdate = json['cdate'];
    inv = json['inv'];
    w1 = json['w1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['user'] = this.user;
    data['name_user'] = this.name_user;
    data['rser'] = this.rser;
    data['daterec'] = this.daterec;
    data['timerec'] = this.timerec;
    data['date'] = this.date;
    data['dateacc'] = this.dateacc;
    data['duedate'] = this.duedate;
    data['cid'] = this.cid;

    data['st'] = this.st;
    data['cc_remark'] = this.cc_remark;
    data['cc_date'] = this.cc_date;
    data['cname'] = this.cname;
    data['sname'] = this.sname;
    data['stype'] = this.stype;
    data['addr'] = this.addr;
    data['tax'] = this.tax;
    data['zn'] = this.zn;
    data['zn1'] = this.zn1;
    data['zser'] = this.zser;
    data['zser1'] = this.zser1;
    data['ln'] = this.ln;
    data['sdate'] = this.sdate;
    data['ldate'] = this.ldate;
    data['docno'] = this.docno;
    data['doctax'] = this.doctax;
    data['pdate'] = this.pdate;
    data['remark'] = this.remark;
    data['total_bill'] = this.total_bill;
    data['total_pay'] = this.total_pay;
    data['pakan_pvat'] = this.pakan_pvat;
    data['pakan_vat'] = this.pakan_vat;
    data['pakan_total'] = this.pakan_total;
    data['water_electri'] = this.water_electri;
    data['land_name'] = this.land_name;
    data['land_amt'] = this.land_amt;
    data['land_pvat'] = this.land_pvat;
    data['land_vat'] = this.land_vat;
    data['land_total'] = this.land_total;

    data['rent_name'] = this.rent_name;
    data['rent_amt'] = this.rent_amt;
    data['rent_pvat'] = this.rent_pvat;
    data['rent_vat'] = this.rent_vat;
    data['rent_total'] = this.rent_total;
    data['service_name'] = this.service_name;
    data['service_amt'] = this.service_amt;
    data['service_pvat'] = this.service_pvat;
    data['service_vat'] = this.service_vat;
    data['service_total'] = this.service_total;
    data['water'] = this.water;
    data['electricity'] = this.electricity;
    data['fine'] = this.fine;
    data['renew_cid'] = this.renew_cid;
    data['data_update'] = this.data_update;
    data['min_docno'] = this.min_docno;
    data['min_doctax'] = this.min_doctax;
    data['min_pdate'] = this.min_pdate;
    data['ref1'] = this.ref1;
    data['ref2'] = this.ref2;
    data['ref3'] = this.ref3;
    data['ref4'] = this.ref4;
    data['wnote'] = this.wnote;
    data['tel'] = this.tel;
    data['cdate'] = this.cdate;
    data['inv'] = this.inv;
    data['w1'] = this.w1;
    return data;
  }
}
