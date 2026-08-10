class UserSubModel {
  int? ser;
  String? datex;
  String? timex;
  int? rser;
  int? rserUser;
  String? pn;
  int? user;
  String? email;
  int? st;
  String? dataUpdate;

  UserSubModel(
      {this.ser,
      this.datex,
      this.timex,
      this.rser,
      this.rserUser,
      this.pn,
      this.user,
      this.email,
      this.st,
      this.dataUpdate});

  UserSubModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    datex = json['datex'];
    timex = json['timex'];
    rser = json['rser'];
    rserUser = json['rser_user'];
    pn = json['pn'];
    user = json['user'];
    email = json['email'];
    st = json['st'];
    dataUpdate = json['data_update'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['datex'] = this.datex;
    data['timex'] = this.timex;
    data['rser'] = this.rser;
    data['rser_user'] = this.rserUser;
    data['pn'] = this.pn;
    data['user'] = this.user;
    data['email'] = this.email;
    data['st'] = this.st;
    data['data_update'] = this.dataUpdate;
    return data;
  }
}
