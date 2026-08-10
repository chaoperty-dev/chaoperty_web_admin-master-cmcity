import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Constant/Myconstant.dart';
import '../Model/Permission_Model.dart';
import 'Enum.dart';

Future<List<PermissionModelCMM>> read_GC_Permission(
    PermissionType permission) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = '${MyConstant().domain_v1}/lookup/permission';
  //print('🧾 Permission url: $url');

  try {
    final response = await http.get(Uri.parse(url))
      ..headers.addAll(headers); // ✅ ต้องใส่ headers ด้วย
    final jsonRes = json.decode(response.body);
    //print('🧾 Raw JSON: $jsonRes');

    final List<PermissionModelCMM> allPermissions = [];

    switch (permission) {
      case PermissionType.positions_all:
        final List<dynamic> positions = jsonRes['positions_all'];
        for (var pos in positions) {
          final roles = pos['roles'] as List<dynamic>;
          for (var role in roles) {
            if (role['enabled'] == true) {
              allPermissions.add(PermissionModelCMM.fromJson(role));
            }
          }
        }
        break;

      case PermissionType.roles_all:
        final List<dynamic> roles = jsonRes['roles_all'];
        for (var role in roles) {
          allPermissions.add(PermissionModelCMM.fromJson(role));
        }
        break;
    }

    return allPermissions;
  } catch (e, stack) {
    //print('❌ Error: $e');
    //print('🪵 Stack: $stack');
    return [];
  }
}

Future<List<PositionsAll>> readPositions(PermissionType permission) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = '${MyConstant().domain_v1}/lookup/permission';
  //print('🧾 Permission url: $url');

  try {
    final response = await http.get(Uri.parse(url))
      ..headers.addAll(headers); // ✅ ต้องใส่ headers ด้วย
    final jsonRes = json.decode(response.body);
    //print('🧾 Raw JSON: $jsonRes');

    final List<PositionsAll> allPermissions = [];

    if (permission == PermissionType.positions_all) {
      final List<dynamic> positions = jsonRes['positions_all'];
      for (var pos in positions) {
        allPermissions.add(PositionsAll.fromJson(pos));
      }
    }

    return allPermissions;
  } catch (e, stack) {
    //print('❌ Error: $e');
    //print('🪵 Stack: $stack');
    return [];
  }
}

Future<List<RolesAll>> readRoles(PermissionType permission) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = '${MyConstant().domain_v1}/lookup/permission';
  //print('🧾 Permission url: $url');

  try {
    final response = await http.get(Uri.parse(url))
      ..headers.addAll(headers); // ✅ ต้องใส่ headers ด้วย
    final jsonRes = json.decode(response.body);
    //print('🧾 Raw JSON: $jsonRes');

    final List<RolesAll> allPermissions = [];

    switch (permission) {
      case PermissionType.positions_all:
        final List<dynamic> positions = jsonRes['positions_all'];
        for (var pos in positions) {
          final roles = pos['roles'] as List<dynamic>;
          for (var role in roles) {
            if (role['enabled'] == true) {
              allPermissions.add(RolesAll.fromJson(role));
            }
          }
        }
        break;

      case PermissionType.roles_all:
        final List<dynamic> roles = jsonRes['roles_all'];
        for (var role in roles) {
          allPermissions.add(RolesAll.fromJson(role));
        }
        break;
    }

    return allPermissions;
  } catch (e, stack) {
    //print('❌ Error: $e');
    //print('🪵 Stack: $stack');
    return [];
  }
}

Future<http.StreamedResponse?> Post_Permission({
  required Uint8List fileData,
  required String userName,
  required String eMail,
  required String passWord,
  // required List<Map<String, dynamic>> proFile,
  required List<int> roleId,
  required int positionId,
  required String preFix,
  required String firstName,
  required String lastName,
  required String citizenId,
  required String phone,
  required String prepostion,
}) async {
  // var headers = {
  //   'Accept': 'application/json',
  //   'Authorization':
  //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
  // };
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${MyConstant().domain_v1}/admin/users'),
  );

  // ✅ เพิ่มไฟล์
  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      fileData,
      filename: 'signature.png',
    ),
  );

  // ✅ เพิ่มฟิลด์ข้อมูล (อย่าใช้ Content-Type: application/json กับ Multipart)
  request.fields['username'] = userName;
  request.fields['email'] = eMail;
  request.fields['password'] = passWord.toString();
  request.fields['password_confirmation'] = passWord.toString();
  request.fields['position_id'] = positionId.toString();

  request.fields['profile[prefix]'] = "$preFix";
  request.fields['profile[first_name]'] = "$firstName";
  request.fields['profile[last_name]'] = "$lastName";
  request.fields['profile[citizen_id]'] = "$citizenId";
  request.fields['profile[phone]'] = "$phone";
  request.fields['profile[prepostion]'] = "$prepostion";

  final roleIds = roleId;
  for (int i = 0; i < roleIds.length; i++) {
    request.fields['role_ids[$i]'] = roleIds[i].toString();
  }

  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      //print('✅ Success:\n$responseBody');
    } else {
      //print('❌ Failed [${response.statusCode}]:\n$responseBody');
    }

    return response;
  } catch (e) {
    //print('❌ Exception: $e');
    return null;
  }
}

Future<http.StreamedResponse?> Post_Signatures_Permission({
  required Uint8List fileData,
  required String userUuid,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  // var headers = {
  //   'Accept': 'application/json',
  //   'Authorization':
  //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
  // };

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('${MyConstant().domain_v1}/admin/users/$userUuid/signatures'),
  );
  //print('POST signatures');
  // ✅ เพิ่มไฟล์
  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      fileData,
      filename: 'signature.png',
    ),
  );

  // // ✅ เพิ่มฟิลด์ข้อมูล (อย่าใช้ Content-Type: application/json กับ Multipart)
  // request.fields['username'] = userName;
  // request.fields['email'] = eMail;
  // request.fields['password'] = passWord.toString();
  // request.fields['password_confirmation'] = passWord.toString();
  // request.fields['position_id'] = positionId.toString();

  // request.fields['profile[prefix]'] = "$preFix";
  // request.fields['profile[first_name]'] = "$firstName";
  // request.fields['profile[last_name]'] = "$lastName";
  // request.fields['profile[citizen_id]'] = "$citizenId";
  // request.fields['profile[phone]'] = "$phone";

  // final roleIds = roleId;
  // for (int i = 0; i < roleIds.length; i++) {
  //   request.fields['role_ids[$i]'] = roleIds[i].toString();
  // }

  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      //print('✅ Success:\n$responseBody');
    } else {
      //print('❌ Failed [${response.statusCode}]:\n$responseBody');
    }

    return response;
  } catch (e) {
    //print('❌ Exception: $e');
    return null;
  }
}

Future<http.StreamedResponse?> Put_Permission({
  required Uint8List fileData,
  required String userName,
  required String eMail,
  required String passWord,
  required List<int> roleId,
  required int positionId,
  required String preFix,
  required String firstName,
  required String lastName,
  required String citizenId,
  required String phone,
  required String userUuid,
  required String prepostion,
}) async {
  //print('Put_Permission');
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  // var headers = {
  //   'Accept': 'application/json',
  //   'Content-Type': 'application/json',
  //   'Authorization':
  //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
  // };

  var request = http.Request(
    'PUT',
    Uri.parse('${MyConstant().domain_v1}/admin/users/$userUuid'),
  );

  request.body = json.encode({
    "username": userName,
    "email": eMail,
    "password": passWord,
    "password_confirmation": passWord,
    "position_id": positionId,
    "profile": {
      "prefix": preFix,
      "first_name": firstName,
      "last_name": lastName,
      "citizen_id": citizenId,
      "phone": phone,
      "prepostion": prepostion
    },
    "role_ids": roleId,
  });

  // //print({
  //   "username": userName,
  //   "email": eMail,
  //   "password": passWord,
  //   "password_confirmation": passWord,
  //   "position_id": positionId,
  //   "profile": {
  //     "prefix": preFix,
  //     "first_name": firstName,
  //     "last_name": lastName,
  //     "citizen_id": citizenId,
  //     "phone": phone,
  //     "prepostion": prepostion
  //   },
  //   "role_ids": roleId,
  // });

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = await response.stream.bytesToString(); // ✅ อ่านได้ครั้งเดียว
    final jsonResponse = json.decode(body);
    //print('✅ Response JSON: $jsonResponse');
    // //print('🧾 Raw JSON: $jsonRes');
    return response;
  } else {
    //print('❌ Failed: ${response.statusCode}');
    //print(await response.stream.bytesToString());
    return null;
  }
}

// Future<http.StreamedResponse?> Post_Permission({
//   required Uint8List fileData,
//   required String userName,
//   required String eMail,
//   required String passWord,
//   required List<Map<String, dynamic>> proFile,
//   required List<int> roleIds,
//   required int positionId,
// }) async {
//   final url = Uri.parse('${MyConstant().domain_v1}/admin/users');

//   try {
//     final request = http.MultipartRequest('POST', url);

//     // ✅ ใช้ Uint8List ตรง ๆ ไม่ต้องอ่านซ้ำ
//     request.files.add(http.MultipartFile.fromBytes(
//       'file',
//       fileData,
//       filename: 'signature.png', // หรือกำหนดชื่ออื่นตามต้องการ
//     ));

//     // ✅ Add fields
//     request.fields['username'] = userName;
//     request.fields['email'] = eMail;
//     request.fields['password'] = passWord.toString();
//     request.fields['password_confirmation'] = passWord.toString();
//     request.fields['position_id'] = positionId.toString();
//     request.fields['profile'] = json.encode(proFile);
//     request.fields['role_ids'] = json.encode(roleIds);

//     request.headers.addAll({
//       'Accept': 'application/json',
//     });

//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//     if (response.statusCode == 201 || response.statusCode == 409) {
//       //print('✅ Post Permission Success');
//       //print('📦 Response Body: $responseBody');
//     } else {
//       //print('❌ Post Permission Failed [${response.statusCode}]');
//       //print('📄 Body: $responseBody');
//     }

//     return response;
//   } catch (e, stack) {
//     //print('❌ Exception during Post_Permission: $e');
//     //print('🧭 StackTrace:\n$stack');
//     return null;
//   }
// }
