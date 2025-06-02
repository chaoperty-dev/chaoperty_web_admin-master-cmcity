import 'package:shared_preferences/shared_preferences.dart';

import 'EncryptText.dart';

enum SecurePrefsType {
  UuidRequest,
  UuidUser,
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
