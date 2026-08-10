import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../Constant/Myconstant.dart';
import '../Model/Review_Model.dart';
import 'API_approvals_lastaction.dart';
import 'SecurePrefs_helper.dart';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:http_parser/http_parser.dart';

Future<ReviewResponse> read_GC_Reviews({
  String? urlCustom,
  String query = '',
  int perPage = 50,
  String? zser,
  String? orderBy,
  String sortDir = 'asc',
  String? zn,
  required List<Map<String, String>> fild,
}) async {
  final headers = await MyHeaders.build();
  print(
      '[read_GC_Reviews][start] urlCustom=$urlCustom query="$query" perPage=$perPage zser=$zser orderBy=$orderBy sortDir=$sortDir zn=$zn');
  print('[read_GC_Reviews][fild] $fild');
  print('[read_GC_Reviews][headers] $headers');
  final selectedFields = fild
      .where((e) => e['st'] == '1')
      .map((e) => e['value'])
      .whereType<String>()
      .where((v) => v.trim().isNotEmpty)
      .toList();
  print('[read_GC_Reviews][selectedFields] $selectedFields');

  Uri _buildUri() {
    final baseDomain = Uri.parse('${MyConstant().domain_v1}/admin/approvals');
    print('[read_GC_Reviews][baseDomain] $baseDomain');

    void applySelectedFields(Map<String, String> qp) {
      final q = query.trim();
      print('[read_GC_Reviews][applySelectedFields][before] q="$q" qp=$qp');
      if (q.isEmpty) {
        print(
            '[read_GC_Reviews][applySelectedFields] skip because query is empty');
        return;
      }
      if (selectedFields.isEmpty) {
        qp['q'] = q;
        print('[read_GC_Reviews][applySelectedFields] use q=$q');
        return;
      }
      qp.remove('q');
      for (final field in selectedFields) {
        qp[field] = q;
      }
      print('[read_GC_Reviews][applySelectedFields][after] qp=$qp');
    }

    void applyZone(Map<String, String> qp) {
      if (zn != null && zn.isNotEmpty && zn != '0' && zn != 'ทั้งหมด') {
        qp['zn'] = zn!;
        print('[read_GC_Reviews][applyZone] zn=$zn');
      } else {
        print('[read_GC_Reviews][applyZone] skip zn=$zn');
      }
    }

    void applySort(Map<String, String> qp) {
      if (orderBy != null && orderBy.isNotEmpty) {
        qp['order_by'] = orderBy!;
        qp['sort_dir'] = sortDir;
        print(
            '[read_GC_Reviews][applySort] order_by=$orderBy sort_dir=$sortDir');
      } else {
        print('[read_GC_Reviews][applySort] skip orderBy=$orderBy');
      }
    }

    if (urlCustom != null && urlCustom.isNotEmpty) {
      final sourceUri = Uri.parse(urlCustom);
      final qp = Map<String, String>.from(sourceUri.queryParameters);
      print('[read_GC_Reviews][customUrl][source] $sourceUri');
      print('[read_GC_Reviews][customUrl][queryParameters-before] $qp');
      qp['per_page'] = '50';
      applySelectedFields(qp);
      applyZone(qp);
      applySort(qp);
      print('[read_GC_Reviews][customUrl][queryParameters-after] $qp');
      final finalUri = baseDomain.replace(
        queryParameters: {...baseDomain.queryParameters, ...qp},
      );
      print('[read_GC_Reviews][customUrl][finalUri] $finalUri');
      return finalUri;
    }

    final qp = <String, String>{'per_page': '50'};
    print('[read_GC_Reviews][firstLoad][queryParameters-before] $qp');
    applySelectedFields(qp);
    applyZone(qp);
    applySort(qp);
    print('[read_GC_Reviews][firstLoad][queryParameters-after] $qp');
    final finalUri = baseDomain.replace(
      queryParameters: {...baseDomain.queryParameters, ...qp},
    );
    print('[read_GC_Reviews][firstLoad][finalUri] $finalUri');
    return finalUri;
  }

  try {
    final uri = _buildUri();
    print('[GET] $uri');

    final resp = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 25));
    print(
        '[read_GC_Reviews][response] status=${resp.statusCode} reason=${resp.reasonPhrase}');

    if (resp.statusCode == 204 || resp.body.trim().isEmpty) {
      print('[read_GC_Reviews][response] empty body or 204');
      return ReviewResponse(
        data: [],
        currentPage: 0,
        lastPage: 0,
        perPage: 0,
        total: 0,
        linksFirst: null,
        linksLast: null,
        linksPrev: null,
        linksNext: null,
      );
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      print('[ERR] ${resp.statusCode} ${resp.reasonPhrase}');
      print('[BODY] ${resp.body}');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }

    final decoded = json.decode(resp.body);
    print('[decoded] $decoded');
    if (decoded is! Map) {
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }
    final map = decoded as Map;

    int toInt(dynamic value) => int.tryParse('$value') ?? 0;

    int currentPage = 0, lastPage = 0, perPageVal = 0, total = 0;
    String? linksFirst, linksLast, linksPrev, linksNext;

    if (map['meta'] is Map) {
      final meta = map['meta'] as Map;
      currentPage = toInt(meta['current_page']);
      lastPage = toInt(meta['last_page']);
      perPageVal = toInt(meta['per_page']);
      total = toInt(meta['total']);
    } else {
      currentPage = toInt(map['current_page']);
      lastPage = toInt(map['last_page']);
      perPageVal = toInt(map['per_page']);
      total = toInt(map['total']);
    }

    if (map['links'] is Map) {
      final linkMap = map['links'] as Map;
      linksFirst = linkMap['first']?.toString();
      linksLast = linkMap['last']?.toString();
      linksPrev = linkMap['prev']?.toString();
      linksNext = linkMap['next']?.toString();
    } else {
      linksFirst = map['first_page_url']?.toString();
      linksLast = map['last_page_url']?.toString();
      linksPrev = map['prev_page_url']?.toString();
      linksNext = map['next_page_url']?.toString();
    }

    List<ReviewModel> list = [];
    final data = map['data'];
    if (data is List) {
      list = data
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
      print(
          '[read_GC_Reviews][result] currentPage=$currentPage lastPage=$lastPage perPage=$perPageVal total=$total dataCount=${list.length} prev=$linksPrev next=$linksNext');
    } else {
      print('[read_GC_Reviews][result] data is not List: ${data.runtimeType}');
    }

    return ReviewResponse(
      data: list,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPageVal,
      total: total,
      linksFirst: linksFirst,
      linksLast: linksLast,
      linksPrev: linksPrev,
      linksNext: linksNext,
    );
  } catch (e, st) {
    print('[read_GC_Reviews][exception] $e');
    print('[read_GC_Reviews][stacktrace] $st');
    return ReviewResponse(
        data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
  }
}

// Future<ReviewResponse> read_GC_Reviews({
//   String? urlCustom,
//   String query = '',
//   int perPage = 1, // <- à¹ƒà¸Šà¹‰à¸„à¹ˆà¸²à¸—à¸µà¹ˆà¸„à¸¸à¸“à¸•à¸±à¹‰à¸‡à¹„à¸§à¹‰/à¸„à¹ˆà¸²à¸ˆà¸²à¸ state à¸ªà¹ˆà¸‡à¹€à¸‚à¹‰à¸²à¸¡à¸²
//   required List<Map<String, String>> fild,
// }) async {
//   final headers = await MyHeaders.build();

//   try {
//     Uri uri;
//     if (urlCustom != null && urlCustom.isNotEmpty) {
//       // à¹ƒà¸Šà¹‰à¸¥à¸´à¸‡à¸à¹Œ next/prev à¹à¸•à¹ˆà¹ƒà¸«à¹‰à¹€à¸•à¸´à¸¡ per_page / q à¸–à¹‰à¸²à¸«à¸²à¸¢à¹„à¸›
//       final u = Uri.parse(urlCustom);
//       final qp = Map<String, String>.from(u.queryParameters);
//       if (!qp.containsKey('per_page')) qp['per_page'] = '$perPage';
//       if (query.isNotEmpty && !qp.containsKey('q')) qp['q'] = query;
//       uri = u.replace(queryParameters: qp);
//     } else {
//       // à¸„à¸£à¸±à¹‰à¸‡à¹à¸£à¸: à¹€à¸£à¸²à¸ªà¸£à¹‰à¸²à¸‡ URL à¹€à¸­à¸‡
//       final base = Uri.parse('${MyConstant().domain_v1}/admin/approvals');
//       final params = <String, String>{
//         'per_page': '$perPage',
//         for (int index = 0; index < fild.length; index++)
//           '${fild[index]['value']}': query,
//         // if (query.isNotEmpty) 'q': query,
//       };
//       uri = base.replace(queryParameters: {...base.queryParameters, ...params});
//     }

//     //print('?q=$query || [GET] $uri');
//     final resp = await http.get(uri, headers: headers);

//     if (resp.statusCode < 200 || resp.statusCode >= 300) {
//       //print('[ERR] ${resp.statusCode} ${resp.reasonPhrase}');
//       //print('[BODY] ${resp.body}');
//       return ReviewResponse(
//           data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
//     }

//     final decoded = json.decode(resp.body);
//     if (decoded is! Map) {
//       //print('âŒ unexpected JSON shape (not a Map)');
//       return ReviewResponse(
//           data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
//     }
//     final map = decoded as Map;

//     // meta
//     final int currentPage = int.tryParse('${map['current_page']}') ?? 0;
//     final int lastPage = int.tryParse('${map['last_page']}') ?? 0;
//     final int perPageVal = int.tryParse('${map['per_page']}') ?? 0;
//     final int total = int.tryParse('${map['total']}') ?? 0;

//     // links
//     final String? linksFirst = map['first_page_url']?.toString();
//     final String? linksLast = map['last_page_url']?.toString();
//     final String? linksPrev = map['prev_page_url']?.toString();
//     final String? linksNext = map['next_page_url']?.toString();

//     // data
//     List<ReviewModel> list = [];
//     final data = map['data'];
//     if (data is List) {
//       list = data
//           .whereType<Map<String, dynamic>>()
//           .map(ReviewModel.fromJson)
//           .toList();
//       //print(
//           'âœ… à¹„à¸”à¹‰à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸—à¸±à¹‰à¸‡à¸«à¸¡à¸” ${list.length} à¸£à¸²à¸¢à¸à¸²à¸£ | prev=$linksPrev next=$linksNext');
//     } else {
//       //print('âŒ "data" à¹„à¸¡à¹ˆà¹ƒà¸Šà¹ˆ List');
//     }

//     return ReviewResponse(
//       data: list,
//       currentPage: currentPage,
//       lastPage: lastPage,
//       perPage: perPageVal,
//       total: total,
//       linksFirst: linksFirst,
//       linksLast: linksLast,
//       linksPrev: linksPrev,
//       linksNext: linksNext,
//     );
//   } catch (e) {
//     //print('Exception: $e');
//     return ReviewResponse(
//         data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
//   }
// }
// Future<http.Response?> read_GC_Reviews() async {
//   final headers = await MyHeaders.build(); // âœ… à¸•à¹‰à¸­à¸‡ await

//   final url = Uri.parse('${MyConstant().domain_v1}/admin/approvals');
//   //print('GET Reviews : $url');
//   //print('GET headers : $headers');
//   try {
//     final response = await http.get(url, headers: headers);
//     //print('[${response.statusCode}]');

//     if (response.statusCode == 200) {
//       //print('âœ… Get Reviews Success');
//       // //print(response.body);
//     } else {
//       //print('âŒ Get Reviews Failed [${response.statusCode}]: ${response.body}');
//     }

//     return response;
//   } catch (e, stack) {
//     //print('âŒ Exception during Reviews request: $e');
//     //print('ðŸ§­ StackTrace:\n$stack');
//     return null;
//   }
// }
//  approvals/roles
// API_approvals_roles

Future<http.Response?> read_GC_ReviewsUuid(String? UuidRequest) async {
  if (UuidRequest == null || UuidRequest.isEmpty) {
    //print(' UuidRequest is null or empty');
    return null;
  }

  final headers = await MyHeaders.build(); // await

  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$UuidRequest/review');
  print(' GET Reviews by Uuid: $url');

  try {
    final response = await http.get(url, headers: headers);
    //print('ðŸ“¥ Status: [${response.statusCode}]');

    if (response.statusCode == 200) {
      //print('ðŸ”“âœ… Get Reviews Uuid Success');
    } else {
      //print(
      // 'âŒ Get Reviews Uuid Failed [${response.statusCode}]: ${response.body}');
    }

    return response;
  } catch (e, stack) {
    //print('Exception during Reviews Uuid request: $e');
    //print('­ StackTrace:\n$stack');
    return null;
  }
}

//////////////------------------------------------>
enum ReviewsApprovalRoleType {
  doc_reviewer,
  finance_approver,
}

// enum ReviewsStatusType {
//   needs_update,
//   rejected,
//   approved,
// }

Future<http.Response?> Post_ReviewsAttachMents({
  required String requestUuid,
  required String attachmentsUuid,
  required String staTus,
  required String descripTion,
  // required ReviewsApprovalRoleType role,
}) async {
  final headers = await MyHeaders.build(); // âœ… à¸•à¹‰à¸­à¸‡ await
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$requestUuid/review');
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
      //print('âœ… Post Reviews Success: ${result}');
    } else {
      //print('âŒ Post Reviews Failed [${response.statusCode}]: ${result}');
    }
    return response;
  } catch (e, stack) {
    //print('âŒ Exception during Reviews request: $e');
    //print('ðŸ§­ StackTrace:\n$stack');
    return null;
  }
}

// Future<http.Response?> Post_ReviewsCheckListCommit(
//  required String requestUuid,
//   required String attachmentsUuid,
//   required String description,
//   required String staTus,
//   File file,
// ) async {

Future<http.Response?> Post_ReviewsCheckListCommit({
  required String requestUuid,
  required String profileUuid,
  required String signatureUuid,
  required String staTus,
  required String documentId,
  required Uint8List file,
}) async {
  final url = Uri.parse(
      '${MyConstant().domain_v1}/admin/approvals/$requestUuid/checklist');
  //print(url);
  //print('uuid_request: $requestUuid');

  final headers = await MyHeaders.build();

  var request = http.MultipartRequest('POST', url)
    ..headers.addAll(headers)
    ..fields['signature_uuid'] = signatureUuid.toString()
    ..fields['profile_uuid'] = profileUuid.toString()
    ..fields['status'] = staTus.toString()
    ..fields['document_id'] = documentId.toString()
    ..files.add(
      http.MultipartFile.fromBytes(
        'file',
        file,
        filename: 'review.pdf',
        contentType: MediaType('application', 'pdf'),
      ),
    );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200 || response.statusCode == 201) {
    //print('âœ… Upload à¸ªà¸³à¹€à¸£à¹‡à¸ˆ');
  } else {
    //print('âŒ Upload à¸¥à¹‰à¸¡à¹€à¸«à¸¥à¸§: ${response.statusCode}');
    //print('ðŸ“„ à¸•à¸­à¸šà¸à¸¥à¸±à¸š: ${response.body}');
  }

  return response;
}

// Future<http.Response?> Post_ReviewsAttachMentsCommit({
//   required File file,
//   required String requestUuid,
//   required String attachmentsUuid,
//   required String staTus,
//   required String descripTion,
//   // required ReviewsApprovalRoleType role,
// }) async {
//   Future<http.Response> Post_ReviewsAttachMentsCommit(
//     String uuid,
//     File file,
//     String uuid_request,
//   ) async {
//     final uri =
//         Uri.parse('${MyConstant().domain_v1}/payments/$uuid/attachments');
//     //print(uri);
//     //print('uuid_request');
//     //print(uuid_request);
//     final headers = await MyHeaders.build(); // âœ… à¸•à¹‰à¸­à¸‡ await
//     var request = http.MultipartRequest('POST', uri)

//       /// 0ddc7ea6-9636-4e2a-ba44-0e86d211f7cd
//       ..headers.addAll(headers
//           //   {
//           //   'Accept': 'application/json',
//           //   'Authorization':
//           //       'Bearer 7|Xm7Hdf184i16Y45avEiYkalUofL6XstNlUQJDDiLe79fc995',
//           // }
//           )
//       ..fields['document_id'] = '8'
//       ..fields['request_uuid'] = uuid_request.toString()
//       ..files.add(
//         await http.MultipartFile.fromPath('file', file.path,
//             filename: path.basename(file.path)),
//       );

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       //print('âœ… Mobile/Desktop à¸­à¸±à¸›à¹‚à¸«à¸¥à¸”à¸ªà¸³à¹€à¸£à¹‡à¸ˆ');
//     } else {
//       //print('âŒ Mobile/Desktop à¸­à¸±à¸›à¹‚à¸«à¸¥à¸”à¸¥à¹‰à¸¡à¹€à¸«à¸¥à¸§: ${response.statusCode}');
//       //print('ðŸ“„ à¸•à¸­à¸šà¸à¸¥à¸±à¸š: ${response.body}');
//     }

//     return response;
//   }
// }

// Future<http.Response?> Post_ReviewsAttachMentsCommit({
//  File file,
//   required String requestUuid,
//   required String attachmentsUuid,
//   required String staTus,
//   required String descripTion,
//   // required ReviewsApprovalRoleType role,
// }) async {
//   final headers = await MyHeaders.build(); // âœ… à¸•à¹‰à¸­à¸‡ await
//   final url =
//       Uri.parse('${MyConstant().domain_v1}/admin/reviews/$requestUuid/commit');
//   final body = json.encode({
//     "signature_uuid": attachmentsUuid,
//     "profile_uuid": staTus,
//     "file": descripTion, "document_id": descripTion, "status": descripTion,
//     // "approval_role": role.toString(),
//   });
//   //print('Post_ReviewsAttachMents : $url');

//   //print(body);
//   try {
//     final response = await http.post(
//       url,
//       headers: headers,
//       body: body,
//     );
//     //print('[${response.statusCode}]');
//     final result = json.decode(response.body);
//     if (response.statusCode == 201 || response.statusCode == 409) {
//       //print('âœ… Post Reviews Success: ${result}');
//     } else {
//       //print('âŒ Post Reviews Failed [${response.statusCode}]: ${result}');
//     }
//     return response;
//   } catch (e, stack) {
//     //print('âŒ Exception during Reviews request: $e');
//     //print('ðŸ§­ StackTrace:\n$stack');
//     return null;
//   }
// }

Future<http.Response?> Post_ReviewsAddon({
  required String requestUuid,
  required String bookNo,
  required String bookDate,
}) async {
  final headers = await MyHeaders.build();
  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$requestUuid/addon');
  final body = json.encode({
    "book_no": bookNo,
    "book_date": bookDate,
  });
  print('ðŸ”Ž POST Reviews Addon: $url');
  print('ðŸ“¦ Body: $body');

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return response;
  } catch (e, stack) {
    print('âŒ Exception during Reviews Addon request: $e');
    print('ðŸ§­ StackTrace:\n$stack');
    return null;
  }
}

Future<http.Response?> get_ReviewsAddon({required String requestUuid}) async {
  final headers = await MyHeaders.build();
  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$requestUuid/addon');
  print('ðŸ”Ž GET Reviews Addon: $url');

  try {
    final response = await http.get(url, headers: headers);
    return response;
  } catch (e, stack) {
    print('âŒ Exception during Reviews Addon GET request: $e');
    print('ðŸ§­ StackTrace:\n$stack');
    return null;
  }
}
