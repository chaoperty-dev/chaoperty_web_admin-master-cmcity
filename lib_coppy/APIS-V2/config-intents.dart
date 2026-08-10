import 'package:uuid/uuid.dart';

import '../Constant/global_http.dart'; // ใช้ gen uuid v4

class MyHeadersIntents {
  MyHeadersIntents._(); // private constructor

  static Future<Map<String, String>> build() async {
    final uuid = const Uuid().v4();
    final token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhYzQ0OS04OTNjLTcxZWYtOGYwMS1lYzdkOTBmYjkxYmIiLCJqdGkiOiJjZGI3Y2EzNTU3ZTQ2YjNhMWQzMGRhNDE0YTYyMDZmMWIyNzZjMmY2MTYwMTZhZDZjNzVlMTA3N2VlZTczZDk2N2YwZGRhZDkwOWQzNTIzZSIsImlhdCI6MTc2NDM4MDU1MS42MjA1ODYsIm5iZiI6MTc2NDM4MDU1MS42MjA1ODgsImV4cCI6MTc2NDM5ODU1MS40MjYzODQsInN1YiI6IjAxOWFjNDQ5LTg5M2MtNzFlZi04ZjAxLWVjN2Q5MGZiOTFiYiIsInNjb3BlcyI6W119.PPVDDKTjokedgdMJRU0t6yeJvPApTCbYdOWx3V0xnxOY7pV_mjh7m3R1vCo1F87A6u9_PtLZE_N0wSqz-db56RIJlUESEP0fsHGeOHSBSMTwX7DBMnHaNM6groSzlOQJe7vGMKb2-Qs01NJTwk-ab1Zf7fvdgDaZKixXUaKRYab9SbrFGzbIEvsctUKlcRGQ3cm_Yu04aq50VvvF7EXqSLsvp-iJwKREmkga0DiN_P1ltKII_2KkwMZJ3psAhzUBWDs3Q6Nii5mPY3Qg7lGk4JUMU1NmbtlwPCrem1gZ0w8qLwxqBKfSPkeOFQXNOVzZ0q4ZIVzT-vQhg0OsOdOaD7ZBsHQ6gLG0waDq-1GIktQfzMPI5oAav5uAsJX0VjwJF5YvqOu3KpDDkuFABXBAdSVKa2wlMJXGikuV2i8mrPQq44T4lqTJEMlYD_oiHwJLDoa0whaZLm63s563CWq_FQAW8Y5J_etRHV_-DIifEYTDgQ448W1BweHUY2L_KMk_c9zrc3dTRtdZ60TbtAw0wcQR-bxUnDNArgvD4KibtOjKN9GXs3q8dsqB680hhO1b_H0iwGKUSnl65Vhlv-opqpA1Qxur4AQWNUDQtzw2g1WwiNf98X9Chh9HiCLAtRQYwbXo-nWgOzD0uTOhE5a6UZvMTeoOWYWqeTSdH9e6p2c";
    return {
      'X-Tenant': 'rser-0',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-NONCE-ID': uuid,
      ...Security.generateAuthHeaders(),
      'Authorization': 'Bearer $token',
    };
  }
}

// class MyHeadersIntents {
//   static Future<Map<String, String>> build() async {
//     // final token = await MyToken.accessToken;

//     // gen uuid v4 ใหม่ทุกครั้งที่เรียก build()
//     final uuid = const Uuid().v4();

//     return {
//       'X-Tenant': 'rser-0',
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'uuid': uuid,
//       ...Security.generateAuthHeaders(),
//       // 'Authorization': 'Bearer $token',
//     };
//   }
// }

class MyconfigIntents {
  var domainIntents = 'https://apisuser.chaoperties.com/api';
}
