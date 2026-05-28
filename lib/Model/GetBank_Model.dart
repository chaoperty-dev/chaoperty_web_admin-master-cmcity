class GetBankModel {
  String? ser;
  String? bcode;
  String? bname;
  String? btype;
  String? bname_en;
  String? currency;
  String? st;
  String? data_Update;

  GetBankModel(
      {this.ser,
      this.bcode,
      this.bname,
      this.btype,
      this.st,
      this.data_Update});

  GetBankModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    bcode = json['bcode'];
    bname = json['bname'];
    btype = json['btype'];
    bname_en = json['bname_en'];
    currency = json['currency'];
    st = json['st'];
    data_Update = json['data_update'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['bcode'] = this.bcode;
    data['bname'] = this.bname;
    data['btype'] = this.btype;
    data['bname_en'] = this.bname_en;
    data['currency'] = this.currency;
    data['st'] = this.st;
    data['data_update'] = this.data_Update;
    return data;
  }
}
