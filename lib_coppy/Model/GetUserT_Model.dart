class UserTModel {
  String? ser;
  String? name;
  String? position;
  String? username;
  String? password;
  String? notify_status;
  String? line_user_id;
  String? line_display_name;
  String? line_picture_url;
  String? line_email;
  String? line_access_token;
  String? line_id_token;
  String? created_at;
  String? updated_at;

  UserTModel({
    this.ser,
    this.name,
    this.position,
    this.username,
    this.password,
    this.notify_status,
    this.line_user_id,
    this.line_display_name,
    this.line_picture_url,
    this.line_email,
    this.line_access_token,
    this.line_id_token,
    this.created_at,
    this.updated_at,
  });

  UserTModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    name = json['name'];
    position = json['position'];
    username = json['username'];
    password = json['password'];
    notify_status = json['notify_status'];
    line_user_id = json['line_user_id'];
    line_display_name = json['line_display_name'];
    line_picture_url = json['line_picture_url'];
    line_email = json['line_email'];
    line_access_token = json['line_access_token'];
    line_id_token = json['line_id_token'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['name'] = this.name;
    data['position'] = this.position;
    data['username'] = this.username;
    data['password'] = this.password;
    data['notify_status'] = this.notify_status;
    data['line_user_id'] = this.line_user_id;
    data['line_display_name'] = this.line_display_name;
    data['line_picture_url'] = this.line_picture_url;
    data['line_email'] = this.line_email;
    data['line_access_token'] = this.line_access_token;
    data['line_id_token'] = this.line_id_token;
    data['created_at'] = this.created_at;
    data['updated_at'] = this.updated_at;
    return data;
  }
}
