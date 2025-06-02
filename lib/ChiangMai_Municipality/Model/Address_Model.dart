

class AddressModel {
  String? number;
  String? moo;
  String? road;
    String? soi;
  String? tambon;
  String? amphoe;
  String? province;
  String? raw;

  AddressModel({
    this.number,
    this.moo,
    this.road,
     this.soi,
    this.tambon,
    this.amphoe,
    this.province,
    this.raw,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        number: json['number'],
        moo: json['moo'],
        road: json['road'],
           soi: json['soi'],
        tambon: json['tambon'],
        amphoe: json['amphoe'],
        province: json['province'],
        raw: json['raw'],
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'moo': moo,
        'road': road,
             'soi': soi,
        'tambon': tambon,
        'amphoe': amphoe,
        'province': province,
        'raw': raw,
      };
}
