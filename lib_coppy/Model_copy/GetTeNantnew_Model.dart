class RegisData {
  String? allowed_regis;
  String? line_regis_url;
  String? total_tax;
  String? reg_rser;
  String? reg_pn;
  String? reg_id_card;
  String? reg_userid;
  String? reg_displayname;
  String? reg_username;
  String? reg_passwd;
  String? reg_data_update;
  String? reg_allow_doc;
  String? reg_allow_ageement;

  RegisData.fromJson(Map<String, dynamic> json) {
    allowed_regis = json['allowed_regis']?.toString();
    line_regis_url = json['line_regis_url']?.toString();
    total_tax = json['total_tax']?.toString();
    reg_rser = json['reg_rser']?.toString();
    reg_pn = json['reg_pn']?.toString();
    reg_id_card = json['reg_id_card']?.toString();
    reg_userid = json['reg_userid']?.toString();
    reg_displayname = json['reg_displayname']?.toString();
    reg_username = json['reg_username']?.toString();
    reg_passwd = json['reg_passwd']?.toString();
    reg_data_update = json['reg_data_update']?.toString();
    reg_allow_doc = json['reg_allow_doc']?.toString();
    reg_allow_ageement = json['reg_allow_ageement']?.toString();
  }

  Map<String, dynamic> toJson() => {
        'allowed_regis': allowed_regis,
        'line_regis_url': line_regis_url,
        'total_tax': total_tax,
        'reg_rser': reg_rser,
        'reg_pn': reg_pn,
        'reg_id_card': reg_id_card,
        'reg_userid': reg_userid,
        'reg_displayname': reg_displayname,
        'reg_username': reg_username,
        'reg_passwd': reg_passwd,
        'reg_data_update': reg_data_update,
        'reg_allow_doc': reg_allow_doc,
        'reg_allow_ageement': reg_allow_ageement,
      };
}

class ContractData {
  String? total_cid;
  String? tax;

  ContractData.fromJson(Map<String, dynamic> json) {
    total_cid = json['total_cid']?.toString();
    tax = json['tax']?.toString();
  }

  Map<String, dynamic> toJson() => {
        'total_cid': total_cid,
        'tax': tax,
      };
}

class TeNantnewModels {
  String? ser;
  String? rser;
  String? custno;
  String? cname;
  String? sname;
  String? tax;
  String? user_name;
  String? passw;
  List<RegisData>? regis_data; // <<< เปลี่ยนชนิดให้ถูก
  List<ContractData>? contract_data; // <<< เปลี่ยนชนิดให้ถูก

  TeNantnewModels({
    this.ser,
    this.rser,
    this.custno,
    this.cname,
    this.sname,
    this.tax,
    this.user_name,
    this.passw,
    this.regis_data,
    this.contract_data,
  });

  TeNantnewModels.fromJson(Map<String, dynamic> json) {
    ser = json['ser']?.toString();
    rser = json['rser']?.toString();
    custno = json['custno']?.toString();
    cname = json['cname']?.toString();
    sname = json['sname']?.toString();
    tax = json['tax']?.toString();
    user_name = json['user_name']?.toString();
    passw = json['passw']?.toString();

    regis_data = (json['regis_data'] as List?)
        ?.map((e) => RegisData.fromJson(e as Map<String, dynamic>))
        .toList();

    contract_data = (json['contract_data'] as List?)
        ?.map((e) => ContractData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'ser': ser,
        'rser': rser,
        'custno': custno,
        'cname': cname,
        'sname': sname,
        'tax': tax,
        'user_name': user_name,
        'passw': passw,
        'regis_data': regis_data?.map((e) => e.toJson()).toList(),
        'contract_data': contract_data?.map((e) => e.toJson()).toList(),
      };
}
