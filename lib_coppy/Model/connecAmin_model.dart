class ConnecAminModel {
  String? user;
  int? selectAll;
  String? email;
  String? fname;
  String? lname;
  String? nameUser;
  String? connected;
  List<ConnecAminData>? data;

  ConnecAminModel({
    this.user,
    this.selectAll,
    this.email,
    this.fname,
    this.lname,
    this.nameUser,
    this.connected,
    this.data,
  });

  ConnecAminModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    selectAll = json['selectAll'];
    email = json['email'];
    fname = json['fname'];
    lname = json['lname'];
    nameUser = json['name_user'];
    connected = json['connected'];
    if (json['data'] != null) {
      data = <ConnecAminData>[];
      for (var v in json['data']) {
        data!.add(ConnecAminData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['user'] = user;
    data['selectAll'] = selectAll;
    data['email'] = email;
    data['fname'] = fname;
    data['lname'] = lname;
    data['name_user'] = nameUser;
    data['connected'] = connected;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ConnecAminData {
  String? cid;
  String? refno;
  String? status;

  ConnecAminData({this.cid, this.refno, this.status});

  ConnecAminData.fromJson(Map<String, dynamic> json) {
    cid = json['cid'];
    refno = json['refno'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['cid'] = cid;
    data['refno'] = refno;
    data['status'] = status;
    return data;
  }
}



