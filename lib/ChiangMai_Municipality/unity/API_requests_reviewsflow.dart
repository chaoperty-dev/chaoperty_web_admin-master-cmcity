import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../Constant/Myconstant.dart';
import 'SecurePrefs_helper.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<http.Response?> read_GC_ReviewsFlow() async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url = Uri.parse('${MyConstant().domain_v1}/admin/approvals');
  //print('GET Reviews Flow: $url');

  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ Get Reviews Flow Success');
    } else {
      //print(
      //  '❌ Get Reviews Flow Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during Reviews Flow request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> read_GC_ReviewsFlowUuid(
    {required String? UuidRequest}) async {
  if (UuidRequest == null || UuidRequest.isEmpty) {
    //print('⚠️ UuidRequest is null or empty');
    return null;
  }

  final headers = await MyHeaders.build(); // ✅ ต้อง await

  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/approvals/$UuidRequest/flow');
  //print('🔎 GET Reviews Flow by Uuid: $url');

  try {
    final response = await http.get(url, headers: headers);
    //print('📥 Status: [${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('🔓✅ Get Reviews Flow Uuid Success');
    } else {
      //print(
      //   '❌ Get Reviews Flow Uuid Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('❌ Exception during Reviews Flow Uuid request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

//////////////------------------------------------>
// enum ReviewsApprovalRoleType {
//   doc_reviewer,
//   finance_approver,
// }

// enum ReviewsStatusType {
//   needs_update,
//   rejected,
//   approved,
// }

Future<http.Response?> Post_ReviewsFlowAttachMents({
  required String requestUuid,
  required String attachmentsUuid,
  required String staTus,
  required String descripTion,
  // required ReviewsApprovalRoleType role,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  // ✨ NEW endpoint: POST /admin/requests/{requestUuid}/admin-reviewer
  // body: { attachment_uuid, status: "approved|rejected|needs_update", description }
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/requests/$requestUuid/admin-reviewer');
  final body = json.encode({
    "attachment_uuid": attachmentsUuid,
    "status": staTus,
    "description": descripTion,
    // "approval_role": role.toString(),
  });
  //print('Post_ReviewsAttachMents : $url');

  //print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    //print('[${response.statusCode}]');
    final result = json.decode(response.body);
    if (response.statusCode == 201 || response.statusCode == 409) {
      //print('✅ Post Reviews Success: ${result}');
    } else {
      //print('❌ Post Reviews Failed [${response.statusCode}]: ${result}');
    }
    return response;
  } catch (e, stack) {
    //print('❌ Exception during Reviews request: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> Post_ReviewsFlowApprove({
  required String requestUuid,
  required String flowUuid,
  required String profileUuid,
  required String signUuid,
  required String comment,
}) async {
  final headers = await MyHeaders.build(); // ✅ ต้อง await
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$requestUuid/flow/$flowUuid/approve');
  final body = json.encode({
    "profile_uuid": profileUuid,
    "sign_uuid": signUuid,
    "comment": comment,
  });
  //print('Post_ReviewsFlowApprove : $url');

  //print(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    //print('[${response.statusCode}]');
    final result = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      //print('✅ Post Reviews Flow Approve Success: ${result}');
    } else {
      //print('❌ Post Reviews Flow Approve [${response.statusCode}]: ${result}');
    }
    return result;
  } catch (e, stack) {
    //print('❌ Exception during Reviews Flow Approve: $e');
    //print('🧭 StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> pdfimg_ReviewsFlow(
    {required String? attachmentUuid}) async {
  final headers = await MyHeaders.build(); // 🔐 สร้าง headers พร้อม token

  final url = Uri.parse(
    '${MyConstant().domain_v1}/admin/requests/attachments/$attachmentUuid/preview',
  );

  //print('📤 GET Image ApprovalsCheckUp: $url');
  // //print('🧾 Headers: $headers');

  try {
    final response = await http.get(url, headers: headers);
    //print('[${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('✅ ApprovalsCheckUp image loaded successfully');
    } else {
      //print(
      //   '❌ Failed to load image [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stackTrace) {
    //print('❌ Exception occurred: $e');
    // //print('🧭 Stack trace:\n$stackTrace');
    return null;
  }
}
