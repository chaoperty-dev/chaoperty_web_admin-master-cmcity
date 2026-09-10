import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiRequestSnapshotsShow {
  static const String baseUrl = 'https://cmr.chaoperties.com';
  static const String authHeader =
      'Basic Y2hpYW5nbWFpbXVuaWNpcGFsaXR5OmNoYW9wZXJ0eTEyMzQ=';

  static Future<http.Response> showRequestSnapshot(
    String sourceClientsUuid,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/request-snapshots'),
      headers: {
        'accept': 'application/json',
        'authorization': authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode({'source_clients_uuid': sourceClientsUuid}),
    );

    return response;
  }
}
