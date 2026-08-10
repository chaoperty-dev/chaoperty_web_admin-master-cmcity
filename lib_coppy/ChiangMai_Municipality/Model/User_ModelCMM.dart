class UserModelCMM {
  String? uuid;
  String? username;
  String? email;
  int? active;
  Profile? profile;
  List<Roles>? roles;
  List<Positions>? positions;

  UserModelCMM(
      {this.uuid,
      this.username,
      this.email,
      this.active,
      this.profile,
      this.roles,
      this.positions});

  UserModelCMM.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    username = json['username'];
    email = json['email'];
    active = json['active'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(new Roles.fromJson(v));
      });
    }
    if (json['positions'] != null) {
      positions = <Positions>[];
      json['positions'].forEach((v) {
        positions!.add(new Positions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['username'] = this.username;
    data['email'] = this.email;
    data['active'] = this.active;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    if (this.roles != null) {
      data['roles'] = this.roles!.map((v) => v.toJson()).toList();
    }
    if (this.positions != null) {
      data['positions'] = this.positions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Profile {
  int? id;
  String? uuid;
  String? usersUuid;
  String? prefix;
  String? firstName;
  String? lastName;
  String? citizenId;
  Null? officerId;
  String? birthDate;
  String? appointedDate;
  int? active;
  String? createdAt;
  String? updatedAt;
  String? phone;
  int? version;

  Profile(
      {this.id,
      this.uuid,
      this.usersUuid,
      this.prefix,
      this.firstName,
      this.lastName,
      this.citizenId,
      this.officerId,
      this.birthDate,
      this.appointedDate,
      this.active,
      this.createdAt,
      this.updatedAt,
      this.phone,
      this.version});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    usersUuid = json['users_uuid'];
    prefix = json['prefix'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    citizenId = json['citizen_id'];
    officerId = json['officer_id'];
    birthDate = json['birth_date'];
    appointedDate = json['appointed_date'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    phone = json['phone'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['users_uuid'] = this.usersUuid;
    data['prefix'] = this.prefix;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['citizen_id'] = this.citizenId;
    data['officer_id'] = this.officerId;
    data['birth_date'] = this.birthDate;
    data['appointed_date'] = this.appointedDate;
    data['active'] = this.active;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['phone'] = this.phone;
    data['version'] = this.version;
    return data;
  }
}

class Roles {
  String? uuid;
  String? code;
  String? nameTh;
  int? level;

  Roles({this.uuid, this.code, this.nameTh, this.level});

  Roles.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    code = json['code'];
    nameTh = json['name_th'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uuid'] = this.uuid;
    data['code'] = this.code;
    data['name_th'] = this.nameTh;
    data['level'] = this.level;
    return data;
  }
}

class Positions {
  String? uuid;
  String? code;
  String? nameTh;
  int? level;

  Positions({this.uuid, this.code, this.nameTh, this.level});

  Positions.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    code = json['code'];
    nameTh = json['name_th'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['uuid'] = uuid;
    data['code'] = code;
    data['name_th'] = nameTh;
    data['level'] = level;
    return data;
  }
}

// class Links {
//   String? first;
//   String? last;
//   Null? prev;
//   Null? next;

//   Links({this.first, this.last, this.prev, this.next});

//   Links.fromJson(Map<String, dynamic> json) {
//     first = json['first'];
//     last = json['last'];
//     prev = json['prev'];
//     next = json['next'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['first'] = this.first;
//     data['last'] = this.last;
//     data['prev'] = this.prev;
//     data['next'] = this.next;
//     return data;
//   }
// }

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<Links>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta(
      {this.currentPage,
      this.from,
      this.lastPage,
      this.links,
      this.path,
      this.perPage,
      this.to,
      this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}

class SignaturesAdminModel {
  int? id;
  String? uuid;
  String? usersUuid;
  String? fileName;
  String? filePath;
  String? fileType;
  int? fileSize;
  int? version;
  int? active;
  String? createdAt;
  String? updatedAt;

  SignaturesAdminModel(
      {this.id,
      this.uuid,
      this.usersUuid,
      this.fileName,
      this.filePath,
      this.fileType,
      this.fileSize,
      this.version,
      this.active,
      this.createdAt,
      this.updatedAt});

  SignaturesAdminModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    usersUuid = json['users_uuid'];
    fileName = json['file_name'];
    filePath = json['file_path'];
    fileType = json['file_type'];
    fileSize = json['file_size'];
    version = json['version'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['users_uuid'] = this.usersUuid;
    data['file_name'] = this.fileName;
    data['file_path'] = this.filePath;
    data['file_type'] = this.fileType;
    data['file_size'] = this.fileSize;
    data['version'] = this.version;
    data['active'] = this.active;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class SignaturesUsersAdminModel {
  int? id;
  String? uuid;
  String? usersUuid;
  String? fileName;
  String? filePath;
  String? fileType;
  int? fileSize;
  int? version;
  int? active;
  String? createdAt;
  String? updatedAt;

  SignaturesUsersAdminModel(
      {this.id,
      this.uuid,
      this.usersUuid,
      this.fileName,
      this.filePath,
      this.fileType,
      this.fileSize,
      this.version,
      this.active,
      this.createdAt,
      this.updatedAt});

  SignaturesUsersAdminModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    usersUuid = json['users_uuid'];
    fileName = json['file_name'];
    filePath = json['file_path'];
    fileType = json['file_type'];
    fileSize = json['file_size'];
    version = json['version'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['users_uuid'] = this.usersUuid;
    data['file_name'] = this.fileName;
    data['file_path'] = this.filePath;
    data['file_type'] = this.fileType;
    data['file_size'] = this.fileSize;
    data['version'] = this.version;
    data['active'] = this.active;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
