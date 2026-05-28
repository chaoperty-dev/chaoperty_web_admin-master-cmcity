import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../../Constant/Myconstant.dart';
import '../Model/Review_Model.dart';
import 'SecurePrefs_helper.dart';
import 'dart:convert';
import 'dart:io';

class ReviewResponse {
  final List<ReviewModel> data;

  // meta
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  // links
  final String? linksFirst;
  final String? linksLast;
  final String? linksPrev;
  final String? linksNext;

  ReviewResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.linksFirst,
    this.linksLast,
    this.linksPrev,
    this.linksNext,
  });
}

////////----------------------->
Future<ReviewResponse> read_GC_ApprovalsLastaction({
  String? urlCustom,
  String query = '',
  int perPage = 1,
  String? orderBy,
  String? sortDir,
}) async {
  final headers = await MyHeaders.build();

  try {
    final baseDomain =
        Uri.parse('${MyConstant().domain_v1}/admin/approvals/lastaction');
    Uri uri;
    if (urlCustom != null && urlCustom.isNotEmpty) {
      // à¹ƒà¸Šà¹‰ params à¸ˆà¸²à¸à¸¥à¸´à¸‡à¸à¹Œ next/prev à¹à¸•à¹ˆà¸šà¸±à¸‡à¸„à¸±à¸š Domain/Protocol à¹à¸¥à¸° Search State à¸‚à¸­à¸‡à¹€à¸£à¸²
      final u = Uri.parse(urlCustom);
      final qp = Map<String, String>.from(u.queryParameters);
      qp['per_page'] = '50';
      qp['q'] = query; // keep current UI search state
      if (orderBy != null && orderBy.isNotEmpty) qp['order_by'] = orderBy;
      if (sortDir != null && sortDir.isNotEmpty) qp['sort_dir'] = sortDir;

      // à¸šà¸±à¸‡à¸„à¸±à¸šà¹ƒà¸Šà¹‰ scheme/host à¸ˆà¸²à¸ MyConstant à¹€à¸ªà¸¡à¸­
      uri = baseDomain
          .replace(queryParameters: {...baseDomain.queryParameters, ...qp});
    } else {
      // à¸„à¸£à¸±à¹‰à¸‡à¹à¸£à¸: à¹€à¸£à¸²à¸ªà¸£à¹‰à¸²à¸‡ URL à¹€à¸­à¸‡
      final params = <String, String>{
        'per_page': '$perPage',
        'q': query,
      };
      uri = baseDomain
          .replace(queryParameters: {...baseDomain.queryParameters, ...params});
    }

    //print('[GET] $uri');
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      //print('[ERR] ${resp.statusCode} ${resp.reasonPhrase}');
      //print('[BODY] ${resp.body}');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }

    final decoded = json.decode(resp.body);
    if (decoded is! Map) {
      //print('âŒ unexpected JSON shape (not a Map)');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }
    final map = decoded as Map;

    // meta
    final int currentPage = int.tryParse('${map['current_page']}') ?? 0;
    final int lastPage = int.tryParse('${map['last_page']}') ?? 0;
    final int perPageVal = int.tryParse('${map['per_page']}') ?? 0;
    final int total = int.tryParse('${map['total']}') ?? 0;

    // links
    final String? linksFirst = map['first_page_url']?.toString();
    final String? linksLast = map['last_page_url']?.toString();
    final String? linksPrev = map['prev_page_url']?.toString();
    final String? linksNext = map['next_page_url']?.toString();

    // data
    List<ReviewModel> list = [];
    final data = map['data'];
    if (data is List) {
      list = data
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
      //print(
      //'âœ… à¹„à¸”à¹‰à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸—à¸±à¹‰à¸‡à¸«à¸¡à¸” ${list.length} à¸£à¸²à¸¢à¸à¸²à¸£ | prev=$linksPrev next=$linksNext');
    } else {
      //print('âŒ "data" à¹„à¸¡à¹ˆà¹ƒà¸Šà¹ˆ List');
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
  } catch (e) {
    //print('Exception: $e');
    return ReviewResponse(
        data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
  }
}

////////----------------------->
///
Future<ReviewResponse> read_GC_ApprovalsLastcompleted({
  String? urlCustom,
  String query = '',
  int perPage = 1,
  String? orderBy,
  String? sortDir,
}) async {
  final headers = await MyHeaders.build();

  try {
    final baseDomain =
        Uri.parse('${MyConstant().domain_v1}/admin/approvals/lastcompleted');
    Uri uri;
    if (urlCustom != null && urlCustom.isNotEmpty) {
      // à¹ƒà¸Šà¹‰ params à¸ˆà¸²à¸à¸¥à¸´à¸‡à¸à¹Œ next/prev à¹à¸•à¹ˆà¸šà¸±à¸‡à¸„à¸±à¸š Domain/Protocol à¹à¸¥à¸° Search State à¸‚à¸­à¸‡à¹€à¸£à¸²
      final u = Uri.parse(urlCustom);
      final qp = Map<String, String>.from(u.queryParameters);
      qp['per_page'] = '50';
      qp['q'] = query; // keep current UI search state
      if (orderBy != null && orderBy.isNotEmpty) qp['order_by'] = orderBy;
      if (sortDir != null && sortDir.isNotEmpty) qp['sort_dir'] = sortDir;

      // à¸šà¸±à¸‡à¸„à¸±à¸šà¹ƒà¸Šà¹‰ scheme/host à¸ˆà¸²à¸ MyConstant à¹€à¸ªà¸¡à¸­
      uri = baseDomain
          .replace(queryParameters: {...baseDomain.queryParameters, ...qp});
    } else {
      // à¸„à¸£à¸±à¹‰à¸‡à¹à¸£à¸: à¹€à¸£à¸²à¸ªà¸£à¹‰à¸²à¸‡ URL à¹€à¸­à¸‡
      final params = <String, String>{
        'per_page': '$perPage',
        'q': query,
      };
      uri = baseDomain
          .replace(queryParameters: {...baseDomain.queryParameters, ...params});
    }

    //print('[GET] $uri');
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      //print('[ERR] ${resp.statusCode} ${resp.reasonPhrase}');
      //print('[BODY] ${resp.body}');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }

    final decoded = json.decode(resp.body);
    if (decoded is! Map) {
      //print('âŒ unexpected JSON shape (not a Map)');
      return ReviewResponse(
          data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
    }
    final map = decoded as Map;

    // meta
    final int currentPage = int.tryParse('${map['current_page']}') ?? 0;
    final int lastPage = int.tryParse('${map['last_page']}') ?? 0;
    final int perPageVal = int.tryParse('${map['per_page']}') ?? 0;
    final int total = int.tryParse('${map['total']}') ?? 0;

    // links
    final String? linksFirst = map['first_page_url']?.toString();
    final String? linksLast = map['last_page_url']?.toString();
    final String? linksPrev = map['prev_page_url']?.toString();
    final String? linksNext = map['next_page_url']?.toString();

    // data
    List<ReviewModel> list = [];
    final data = map['data'];
    if (data is List) {
      list = data
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
      //print(
      //    'âœ… à¹„à¸”à¹‰à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸—à¸±à¹‰à¸‡à¸«à¸¡à¸” ${list.length} à¸£à¸²à¸¢à¸à¸²à¸£ | prev=$linksPrev next=$linksNext');
    } else {
      //print('âŒ "data" à¹„à¸¡à¹ˆà¹ƒà¸Šà¹ˆ List');
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
  } catch (e) {
    //print('Exception: $e');
    return ReviewResponse(
        data: [], currentPage: 0, lastPage: 0, perPage: 0, total: 0);
  }
}

////////---------------------------------------------------------------->
// Future<http.Response?> read_GC_ApprovalsLastaction() async {
//   final headers = await MyHeaders.build(); // âœ… à¸•à¹‰à¸­à¸‡ await

//   final url = Uri.parse('${MyConstant().domain_v1}/admin/approvals/lastaction');
//   //print('GET ApprovalsLastaction : $url');
//   //print('GET headers : $headers');
//   try {
//     final response = await http.get(url, headers: headers);
//     //print('[${response.statusCode}]');

//     if (response.statusCode == 200) {
//       //print('âœ… Get ApprovalsLastaction Success');
//       // //print(response.body);
//     } else {
//       //print(
//           'âŒ Get ApprovalsLastaction Failed [${response.statusCode}]: ${response.body}');
//     }

//     return response;
//   } catch (e, stack) {
//     //print('âŒ Exception during ApprovalsLastaction request: $e');
//     //print('ðŸ§­ StackTrace:\n$stack');
//     return null;
//   }
// }

// Future<http.Response?> read_GC_ApprovalsLastcompleted(
//     {required String? nextPageUrl}) async {
//   final headers = await MyHeaders.build();

//   // à¸–à¹‰à¸² nextPageUrl à¹€à¸›à¹‡à¸™ relative à¹ƒà¸«à¹‰ resolve à¸à¸±à¸šà¹‚à¸”à¹€à¸¡à¸™
//   Uri _resolveUrl() {
//     final base =
//         Uri.parse('${MyConstant().domain_v1}/admin/approvals/lastcompleted');
//     if (nextPageUrl == null || nextPageUrl.trim().isEmpty) return base;

//     final u = Uri.parse(nextPageUrl);
//     return u.hasScheme ? u : base.resolveUri(u);
//   }

//   final url = _resolveUrl();
//   //print('GET ApprovalsLastcompleted : $url');
//   //print('GET headers : $headers');

//   try {
//     final response = await http.get(url, headers: headers);
//     //print('[${response.statusCode}]');
//     return response;
//   } catch (e, stack) {
//     //print('âŒ Exception during ApprovalsLastcompleted request: $e');
//     //print('ðŸ§­ StackTrace:\n$stack');
//     return null;
//   }
// }

