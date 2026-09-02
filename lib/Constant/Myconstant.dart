import '../ChiangMai_Municipality/unity/auth_token_store.dart';

class MyToken {
  static Future<String?> get accessToken async => await AuthTokenStore.read();
}

class MyHeaders {
  static Future<Map<String, String>> build() async {
    final token = await MyToken.accessToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class MyConstant {
  String domain = 'https://chaoperties.com/cmcity/chao_api';

  String domain_v1 = 'https://cmcity-test-api.chaoperties.com/api/v1';
  String domain_v2 = 'https://cmcity-test-api.chaoperties.com/api/v2';
  String domain_v3 = 'https://cmcity-test-api.chaoperties.com';
}
