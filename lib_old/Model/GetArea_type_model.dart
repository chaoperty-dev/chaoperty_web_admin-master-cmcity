class Areatype {
  String? ser;
  String? datex;
  String? timex;
  String? user;
  String? unit;
  String? st;
  String? qty;
  String? rent_add;
  String? data_update;

  Areatype(
      {this.ser,
      this.datex,
      this.timex,
      this.user,
      this.unit,
      this.st,
      this.qty,
      this.data_update});

  Areatype.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    datex = json['datex'];
    timex = json['timex'];
    user = json['user'];
    unit = json['unit'];
    st = json['st'];
    qty = json['qty'];
    rent_add = json['rent_add'];
    data_update = json['data_update'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['user'] = this.user;
    data['unit'] = this.unit;
    data['qty'] = this.qty;
    data['rent_add'] = this.rent_add;
    data['data_update'] = this.data_update;
    return data;
  }
}
