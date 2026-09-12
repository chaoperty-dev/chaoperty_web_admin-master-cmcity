import 'dart:convert';

import 'package:chaoperty/Constant/Myconstant.dart';
import 'package:http/http.dart' as http;

import '../models/payment_method_model.dart';

class PaymentMethodService {
  Uri _uri([String? uuid]) => Uri.parse(
        '${MyConstant().domain_v3}/api/v2/admin/payment-methods'
        '${uuid == null ? '' : '/$uuid'}',
      );

  Future<List<PaymentMethodModel>> fetchAll() async {
    final response = await http.get(_uri(), headers: await MyHeaders.build());
    _check(response);
    final body = jsonDecode(response.body);
    final data = body is Map ? body['data'] : body;
    if (data is! List) return const <PaymentMethodModel>[];
    return data
        .whereType<Map>()
        .map((item) => PaymentMethodModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<void> create({
    required String code,
    required String nameTh,
    required String description,
    required String paymentSystem,
    required List<String> payTypes,
    required int sortOrder,
    required bool active,
  }) async {
    final response = await http.post(
      _uri(),
      headers: await MyHeaders.build(),
      body: jsonEncode(_payload(
        code: code,
        nameTh: nameTh,
        description: description,
        paymentSystem: paymentSystem,
        payTypes: payTypes,
        sortOrder: sortOrder,
        active: active,
      )),
    );
    _check(response);
  }

  Future<void> update({
    required String uuid,
    required String nameTh,
    required String description,
    required String paymentSystem,
    required List<String> payTypes,
    required int sortOrder,
    required bool active,
  }) async {
    final response = await http.put(
      _uri(uuid),
      headers: await MyHeaders.build(),
      body: jsonEncode({
        'name_th': nameTh,
        'description': description,
        'payment_gateway_id': null,
        'payment_system': paymentSystem,
        'pay_types': payTypes,
        'sort_order': sortOrder,
        'active': active,
        'config': {},
      }),
    );
    _check(response);
  }

  Future<void> delete(String uuid) async {
    final response =
        await http.delete(_uri(uuid), headers: await MyHeaders.build());
    _check(response);
  }

  Map<String, dynamic> _payload({
    required String code,
    required String nameTh,
    required String description,
    required String paymentSystem,
    required List<String> payTypes,
    required int sortOrder,
    required bool active,
  }) =>
      {
        'code': code,
        'name_th': nameTh,
        'description': description,
        'payment_gateway_id': null,
        'active': active,
        'payment_system': paymentSystem,
        'pay_types': payTypes,
        'sort_order': sortOrder,
        'config': {},
      };

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'Payment method request failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] is String) {
          message = body['message'] as String;
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
