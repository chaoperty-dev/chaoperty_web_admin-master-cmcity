class PermissionModelCMM {
  List<PositionsAll>? positionsAll;
  List<RolesAll>? rolesAll;

  PermissionModelCMM({this.positionsAll, this.rolesAll});

  PermissionModelCMM.fromJson(Map<String, dynamic> json) {
    if (json['positions_all'] != null) {
      positionsAll = <PositionsAll>[];
      json['positions_all'].forEach((v) {
        positionsAll!.add(new PositionsAll.fromJson(v));
      });
    }
    if (json['roles_all'] != null) {
      rolesAll = <RolesAll>[];
      json['roles_all'].forEach((v) {
        rolesAll!.add(new RolesAll.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.positionsAll != null) {
      data['positions_all'] =
          this.positionsAll!.map((v) => v.toJson()).toList();
    }
    if (this.rolesAll != null) {
      data['roles_all'] = this.rolesAll!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PositionsAll {
  final int? id;
  final String? code;
  final String? nameTh;
  final List<Roles>? roles;

  PositionsAll({
    this.id,
    this.code,
    this.nameTh,
    this.roles,
  });

  factory PositionsAll.fromJson(Map<String, dynamic> json) {
    return PositionsAll(
      id: json['id'],
      code: json['code'],
      nameTh: json['name_th'],
      roles: (json['roles'] as List<dynamic>?)
          ?.map((v) => Roles.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name_th': nameTh,
        'roles': roles?.map((r) => r.toJson()).toList(),
      };
}

class Roles {
  int? id;
  String? code;
  String? nameTh;
  bool? enabled;

  Roles({this.id, this.code, this.nameTh, this.enabled});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    nameTh = json['name_th'];
    enabled = json['enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name_th'] = this.nameTh;
    data['enabled'] = this.enabled;
    return data;
  }
}

class RolesAll {
  int? id;
  String? code;
  String? nameTh;
  String? description;
  int? level;
  int? st;

  RolesAll(
      {this.id, this.code, this.nameTh, this.description, this.level, this.st});

  RolesAll.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    nameTh = json['name_th'];
    description = json['description'];
    level = json['level'];
    st = json['st'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name_th'] = this.nameTh;
    data['description'] = this.description;
    data['level'] = this.level;
    data['st'] = this.st;
    return data;
  }
}
