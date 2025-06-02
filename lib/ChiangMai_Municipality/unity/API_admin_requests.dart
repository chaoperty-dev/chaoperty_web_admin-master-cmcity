import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../../Model/GetCustomer_Model.dart';
import '../../Model/GetUser_Model.dart';
import '../Model/Document_Model.dart';
import '../Model/Requests_SubmitError_Model.dart';
import 'Enum.dart';

dynamic findKeyAnywhere(dynamic json, String key) {
  if (json is Map<String, dynamic>) {
    if (json.containsKey(key)) return json[key];
    for (var value in json.values) {
      final result = findKeyAnywhere(value, key);
      if (result != null) return result;
    }
  } else if (json is List) {
    for (var item in json) {
      final result = findKeyAnywhere(item, key);
      if (result != null) return result;
    }
  }
  return null;
}

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

final Map<String, JsonFactory> modelRegistry = {
  'client': (json) => ClientModel.fromJson(json),
  'documents': (json) => DocumentModel.fromJson(json),
  'attachments': (json) => AttachmentsModel.fromJson(json),
  'user': (json) => UserModel.fromJson(json),
  'details': (json) => DetailsModel.fromJson(json),
  // 'items': (json) => ItemModel.fromJson(json),
};
dynamic extractAndMapByKey(String key, dynamic json) {
  final target = findKeyAnywhere(json, key);
  final factory = modelRegistry[key];

  if (factory == null) {
    print('⚠️ No model registered for key: $key');
    return null;
  }

  if (target is Map<String, dynamic>) {
    return factory(target);
  } else if (target is List) {
    return target
        .whereType<Map<String, dynamic>>()
        .map((e) => factory(e))
        .toList();
  }

  return null;
}

Future<Map<String, dynamic>> fetchAny(String uuid) async {
  final Map<String, dynamic> results = {};

  final url = Uri.parse('${MyConstant().domain_v1}/admin/requests/$uuid');
  final request = http.Request('GET', url);
  print(url);
  try {
    final response = await request.send();
    final statusCode = response.statusCode;
    final reason = response.reasonPhrase ?? '';

    if (statusCode != 200) {
      print('❌ HTTP Error: $statusCode $reason');
      return results;
    }

    final body = await response.stream.bytesToString();

    try {
      final result = json.decode(body);

      if (result is Map<String, dynamic>) {
        for (var key in [
          'client',
          'documents',
          'attachments',
          'user',
          'details'
        ]) {
          final data = extractAndMapByKey(key, result);

          if (data != null) {
            results[key] = data;
            print('✅ $key extracted: ${data.runtimeType}');
          } else {
            print('⚠️ $key not found or mapping failed');
          }
        }
      } else {
        print('⚠️ Unexpected JSON root type: ${result.runtimeType}');
      }
    } catch (jsonErr, stack) {
      print('❌ JSON Decode Error: $jsonErr');
      print('📦 Raw response body:\n$body');
      print('🧭 Stack trace:\n$stack');
    }
  } catch (e, s) {
    print('❌ Network/Request Error: $e');
    print('🧭 Stack trace:\n$s');
  }

  return results;
}

Future<dynamic> Getdata(String uuid, OutputType type) async {
  final result = await fetchAny(uuid);
  final client = result['client'];
  final documents = result['documents'];
  final attachments = result['attachments'];
  final details = result['details'];

  switch (type) {
    case OutputType.client:
      return client?.toJson(); // ✅ always Map<String, dynamic>
    case OutputType.documents:
      return documents is List ? documents.map((e) => e.toJson()).toList() : [];
    // case OutputType.attachments:
    //   return attachments is List
    //       ? attachments.map((e) => e.toJson()).toList()
    //       : [];
    case OutputType.attachments:
      if (documents is List) {
        final allAttachments = <Map<String, dynamic>>[];
        final documentsList = documents.whereType<DocumentModel>().toList();

        for (var doc in documentsList) {
          final docAttachments = doc.attachments ?? [];
          allAttachments.addAll(
            docAttachments.map((e) => e.toJson()).toList(),
          );
        }

        return allAttachments;
      }
      return [];
    case OutputType.details:
      return details?.toJson(); // ✅ always Map<String, dynamic>
    // case OutputType.full:
    //   return {
    //     'client': client?.toJson(),
    //     'documents':
    //         documents is List ? documents.map((e) => e.toJson()).toList() : [],
    //     'attachments': attachments is List
    //         ? attachments.map((e) => e.toJson()).toList()
    //         : [],
    //   };
    case OutputType.full:
      return {
        'client': client?.toJson(),
        'documents': documents is List
            ? documents.whereType<DocumentModel>().map((doc) {
                final map = doc.toJson();
                final attachments = doc.attachments ?? [];
                map['attachments'] =
                    attachments.map((e) => e.toJson()).toList();
                return map;
              }).toList()
            : [],
        'details': details?.toJson(),
      };

    case OutputType.count:
      return (documents is List) ? documents.length : 0;
    default:
      return null;
  }
}

Future<void> setDataHandler({
  required String uuid,
  required OutputType type,
  required List<ClientModel> clientModels,
  required List<DocumentModel> documentModels,
  required List<AttachmentsModel> attachments,
  required List<DetailsModel> detailsModel,
  Map<String, dynamic>? fullDataTarget, // optional
  VoidCallback? onComplete,
}) async {
  final result = await Getdata(uuid, type);
  print('⚠️ result : $result');
  switch (type) {
    case OutputType.client:
      clientModels.add(ClientModel.fromJson(result));
      break;

    case OutputType.documents:
      final docs =
          (result as List).map((e) => DocumentModel.fromJson(e)).toList();
      documentModels.addAll(docs);
      break;

    case OutputType.attachments:
      final attac =
          (result as List).map((e) => AttachmentsModel.fromJson(e)).toList();
      attachments.addAll(attac);
      break;

    case OutputType.full:
      if (fullDataTarget != null) {
        fullDataTarget.clear();
        fullDataTarget.addAll(result);
      }

      // clientModels.add(ClientModel.fromJson(result['client']));
      if (result['client'] != null) {
        clientModels.add(ClientModel.fromJson(result['client']));
      } else {
        print('⚠️ client ไม่พบใน result');
      }
      final docs = (result['documents'] as List)
          .map((e) => DocumentModel.fromJson(e))
          .toList();
      documentModels.addAll(docs);

      final List<AttachmentsModel> attac = [];
      for (var doc in result['documents']) {
        if (doc['attachments'] != null && doc['attachments'] is List) {
          attac.addAll(
            (doc['attachments'] as List)
                .map((e) => AttachmentsModel.fromJson(e))
                .toList(),
          );
        }
      }
      attachments.addAll(attac);

      if (result['details'] != null) {
        detailsModel.add(DetailsModel.fromJson(result['details']));
      } else {
        print('⚠️ details ไม่พบใน result');
      }
      break;

    default:
      break;
  }

  onComplete?.call();
}

AttachmentsModel? findAttachmentByDocId(
    List<AttachmentsModel> attachments, int? docId) {
  try {
    return attachments.firstWhere(
      (element) => element.clientDocumentId == docId,
    );
  } catch (_) {
    return null;
  }
}

// AttachmentsModel? findAttachmentByDocId(
//     List<AttachmentsModel> attachments, int? docId) {
//   try {
//     return attachments.firstWhere(
//       (element) => element.clientDocumentId == docId,
//     );
//   } catch (_) {
//     return null;
//   }
// }

DocumentModel? finddocumentByDocCode(
    List<DocumentModel> documentModel, String? docCode) {
  try {
    return documentModel.firstWhere(
      (element) => element.code == docCode,
    );
  } catch (_) {
    return null;
  }
}

Future<http.Response?> readSubmitError({required String requests_uuid}) async {
  final url =
      Uri.parse('${MyConstant().domain_v1}/admin/requests/$requests_uuid');
  final headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    "status": "documents_submitted",
  });
  try {
    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );
    // final response = await http.put(url); // ใช้ http.put ตรง

    // print('response : ${response.body}');
    return response;
  } catch (e) {
    print('❌ HTTP Error: $e');
    return null;
  }
}
