import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

// httpClient

class Security {
  static const String secret = "YOUR_SECRET_KEY_HERE"; // ต้องตรงกับ PHP

  static Map<String, String> generateAuthHeaders() {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final hmac = Hmac(sha256, utf8.encode(secret));
    final clientHash = hmac.convert(utf8.encode(timestamp)).toString();

    return {
      'X-TIMESTAMP': timestamp,
      'X-TIMESTAMP': clientHash,
    };
  }
}

/////------------------------------------------------>
class GlobalHttp extends http.BaseClient {
  final http.Client _inner = http.Client();

  // ต้องตรงกับ PHP: define("API_KEY", "YOUR_SECRET_KEY_HERE");
  static const String _secretKey = "YOUR_SECRET_KEY_HERE";

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // 1) สร้าง timestamp ใหม่ทุกครั้ง
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    // 2) สร้าง HMAC SHA256
    final hmacSha256 = Hmac(sha256, utf8.encode(_secretKey));
    final clientHash = hmacSha256.convert(utf8.encode(timestamp)).toString();

    // 3) ใส่ header ลงใน request (ชื่อให้ตรงกับ PHP)
    request.headers['X-TIMESTAMP'] = timestamp;
    request.headers['X-API-KEY'] = clientHash;

    request.headers['Content-Type'] =
        request.headers['Content-Type'] ?? 'application/json';
    // print({
    //   'TIMESTAMP': timestamp,
    //   'X-API-KEY': clientHash,
    // });
    return _inner.send(request);
  }
}

final http.Client httpClient = GlobalHttp();
/////------------------------------------------------>
///
///
// class GlobalHttp extends http.BaseClient {
//   final http.Client _inner = http.Client();

//   // secret ต้องตรงกับ PHP: define("API_KEY", "YOUR_SECRET_KEY_HERE");
//   static const String _secretKey = "YOUR_SECRET_KEY_HERE";

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) async {
//     // 1) สร้าง timestamp ใหม่ทุกครั้ง (วินาที)
//     final timestamp =
//         (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

//     // 2) สร้าง HMAC SHA256 ด้วย secret เดียวกัน
//     final hmacSha256 = Hmac(sha256, utf8.encode(_secretKey));
//     final clientHash = hmacSha256.convert(utf8.encode(timestamp)).toString();

//     // 3) ใส่ headers ให้ตรงกับฝั่ง PHP
//     request.headers['Content-Type'] ??= 'application/json';
//     request.headers['TIMESTAMP'] = timestamp;
//     request.headers['API_KEY'] = clientHash;

//     // ถ้ามี header อื่นที่ user ใส่มาก่อน ก็ยังอยู่เหมือนเดิม
//     return _inner.send(request);
//   }
// }

  // String apiSecret = 'YOUR_SECRET_KEY_HERE'; // ต้องตรงกับ PHP API_KEY

  // Future<void> securePost() async {
  //   // 1) สร้าง timestamp (วินาที)
  //   final timestamp =
  //       (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  //   // 2) สร้าง HMAC SHA256 ด้วย secret เดียวกัน
  //   final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
  //   final clientHash = hmacSha256.convert(utf8.encode(timestamp)).toString();

  //   // 3) สร้าง headers ที่ถูกต้อง
  //   final headers = {
  //     "Content-Type": "application/json",
  //     "TIMESTAMP": timestamp,
  //     "API_KEY": clientHash,
  //   };

  //   print('headers = $headers');

  //   final url = Uri.parse(
  //     'http://192.168.1.227/chao_api/GC_user.php?isAdd=true&email=T_T@gmail.com',
  //   );

  //   // 4) ใช้ headers ตัวนี้จริง ๆ
  //   final response = await http.get(
  //     url,
  //     headers: headers,
  //   );

  //   print('statusCode = ${response.statusCode}');
  //   print('body = ${response.body}');
  // }
