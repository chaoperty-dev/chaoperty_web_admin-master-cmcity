class TypePaperModel {
  String? ser;
  String? datex;
  String? timex;
  String? rser;
  String? p_type;
  String? st;
  String? data_update;

  TypePaperModel(
      {this.ser,
      this.datex,
      this.timex,
      this.rser,
      this.p_type,
      this.st,
      this.data_update});

  TypePaperModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    datex = json['datex'];
    timex = json['timex'];
    rser = json['rser'];
    p_type = json['p_type'];
    st = json['st'];
    data_update = json['data_update'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['rser'] = this.rser;
    data['p_type'] = this.p_type;
    data['st'] = this.st;
    data['data_update'] = this.data_update;
    return data;
  }
}
