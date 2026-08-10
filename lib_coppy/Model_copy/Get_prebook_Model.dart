class PrebookModel {
  String? ser;
  String? ren;
  String? zone;
  String? pdate;
  String? ts_padte;
  String? ldate;
  String? tl_ldate;
  String? bdate;
  String? bldate;
  String? unit_pdate;
  String? unit_ldate;

  PrebookModel(
      {this.ser,
      this.ren,
      this.zone,
      this.pdate,
      this.ts_padte,
      this.ldate,
      this.tl_ldate,
      this.bdate,
      this.bldate,
      this.unit_pdate,
      this.unit_ldate});

  PrebookModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    ren = json['ren'];
    zone = json['zone'];
    pdate = json['pdate'];
    ts_padte = json['ts_padte'];
    ldate = json['ldate'];
    tl_ldate = json['tl_ldate'];
    bdate = json['bdate'];
    bldate = json['bldate'];
    unit_pdate = json['unit_pdate'];
    unit_ldate = json['unit_ldate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['ren'] = this.ren;
    data['zone'] = this.zone;
    data['pdate'] = this.pdate;
    data['ts_padte'] = this.ts_padte;
    data['ldate'] = this.ldate;
    data['tl_ldate'] = this.tl_ldate;
    data['bdate'] = this.bdate;
    data['bldate'] = this.bldate;
    data['unit_pdate'] = this.unit_pdate;
    data['unit_ldate'] = this.unit_ldate;
    return data;
  }
}
