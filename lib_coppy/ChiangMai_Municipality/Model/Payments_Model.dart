class PaymentsModelCMM {
  int? id;
  String? uuid;
  String? code;
  String? name_th;
  List<Meta>? meta; // รองรับหลาย meta ได้

  PaymentsModelCMM({
    this.id,
    this.uuid,
    this.code,
    this.name_th,
    this.meta,
  });

  PaymentsModelCMM.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    code = json['code'];
    name_th = json['name_th'];

    final rawMeta = json['meta'];
    if (rawMeta != null) {
      if (rawMeta is List) {
        meta = rawMeta
            .whereType<Map<String, dynamic>>()
            .map((e) => Meta.fromJson(e))
            .toList();
      } else if (rawMeta is Map<String, dynamic>) {
        meta = [Meta.fromJson(rawMeta)];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['code'] = code;
    data['name_th'] = name_th;
    if (meta != null) {
      data['meta'] = meta!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Meta {
  int? bank_id;
  String? bcode;
  String? bank_account;
  String? bank_names;
  String? branch;
  String? note;
  String? image_path;

  Meta({
    this.bank_id,
    this.bcode,
    this.bank_account,
    this.bank_names,
    this.branch,
    this.note,
    this.image_path,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    bank_id = json['bank_id'];
    bcode = json['bcode'];
    bank_account = json['bank_account'];
    bank_names = json['bank_names'];
    branch = json['branch'];
    note = json['note'];
    image_path = json['image_path'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bank_id'] = bank_id;
    data['bcode'] = bcode;
    data['bank_account'] = bank_account;
    data['bank_names'] = bank_names;
    data['branch'] = branch;
    data['note'] = note;
    data['image_path'] = image_path;
    return data;
  }
}
