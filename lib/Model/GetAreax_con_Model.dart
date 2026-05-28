class AreaxConModel {
  String? ser;
  String? datex;
  String? timex;
  String? cser;
  String? zser;
  String? aser;
  String? aserQout;
  String? type;
  String? sdate;
  String? ldate;
  String? data_update;
  String? cname;
  String? mainten;
  String? fid;
  String? st;
  String? cc_date;

  AreaxConModel(
      {this.ser,
      this.zser,
      this.data_update,
      this.ldate,
      this.datex,
      this.timex,
      this.cser,
      this.aser,
      this.aserQout,
      this.type,
      this.sdate,
      this.cname,
      this.mainten,
      this.fid,
      this.st,
      this.cc_date});

  AreaxConModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    zser = json['zser'];
    data_update = json['data_update'];
    ldate = json['ldate'];
    datex = json['datex'];
    timex = json['timex'];
    cser = json['cser'];
    aser = json['aser'];
    aserQout = json['aser_qout'];
    type = json['type'];
    sdate = json['sdate'];
    cname = json['cname'];
    mainten = json['mainten'];
    fid = json['fid'];
    st = json['st'];
    cc_date = json['cc_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['zser'] = this.zser;
    data['data_update'] = this.data_update;
    data['ldate'] = this.ldate;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['cser'] = this.cser;
    data['aser'] = this.aser;
    data['aser_qout'] = this.aserQout;
    data['type'] = this.type;
    data['sdate'] = this.sdate;
    data['cname'] = this.cname;
    data['mainten'] = this.mainten;
    data['fid'] = this.fid;
    data['st'] = this.st;
    data['cc_date'] = this.cc_date;
    return data;
  }
}
