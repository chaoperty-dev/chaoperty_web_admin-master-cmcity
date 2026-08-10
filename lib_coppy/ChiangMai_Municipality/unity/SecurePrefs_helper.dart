import 'package:shared_preferences/shared_preferences.dart';

import 'EncryptText.dart';

// enum SecurePrefsType {
//   UuidRequest,
//   UuidUser,
//   AuthService_token,
//   AuthService_Uuid,
//   AuthService_tokentype
// }
enum SecurePrefsType {
  UuidRequest,
  UuidUser,
  // ✅ Auth related (ใช้ prefix สั้นลงเป็น "auth")
  authAccessToken, // 🔐 access token สำหรับ API
  authRefreshToken, // 🔄 token สำหรับ refresh (ถ้ามี)
  authTokenType, // 🔖 Bearer, JWT, etc.
  authUserUuid, // 🆔 UUID ของ user
  authUserEmail, // 📧 email
  authUserTel, // 📧 tel
  authUserTax, // 📧 tax
  authUserId, // 🔢 ID ของ user
  authUserObject, // 👤 เก็บ JSON user object ที่เข้ารหัสไว้
  flowUuid, // 👤 เก็บ JSON user object ที่เข้ารหัสไว้
  expjson, // 👤 เก็บ JSON exp object ที่เข้ารหัสไว้
  approverAll,
  lastCheckTime,
  lastCheckResult,
}

extension SecurePrefsKey on SecurePrefsType {
  String get name => toString().split('.').last;
}

class SecurePrefs {
  /// บันทึกข้อมูลแบบเข้ารหัส โดยใช้ enum
  static Future<void> setEncrypted(SecurePrefsType type, String value) async {
    final preferences = await SharedPreferences.getInstance();
    final encKey = encryptTextMainkey(type.name);
    final encValue = encryptText(value);
    await preferences.setString(encKey, encValue);
  }

  /// ดึงข้อมูลแบบถอดรหัส
  static Future<String?> getDecrypted(SecurePrefsType type) async {
    final preferences = await SharedPreferences.getInstance();
    final encKey = encryptTextMainkey(type.name);
    final encValue = preferences.getString(encKey);
    if (encValue != null) {
      return decryptText(encValue);
    }
    return null;
  }

  /// ลบข้อมูลที่เข้ารหัส
  static Future<void> removeEncrypted(SecurePrefsType type) async {
    final preferences = await SharedPreferences.getInstance();
    final encKey = encryptTextMainkey(type.name);
    await preferences.remove(encKey);
  }
}
