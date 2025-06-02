import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyString = 'my32lengthdzentricchaoperty2023s'; //
const _keyStringMain = 'my16lengthdzentricchaoperty2023s';
// final String _keyString = dotenv.env['SECRET_KEY_STRING_SPERFER'] ?? '';

final _key = encrypt.Key.fromUtf8(_keyString); // สำหรับ value
final _keyMain = encrypt.Key.fromUtf8(_keyStringMain); // สำหรับ key
final _iv = encrypt.IV.fromLength(16);

String encryptText(String plainText) {
  final encrypter = encrypt.Encrypter(encrypt.AES(_key));
  final encrypted = encrypter.encrypt(plainText, iv: _iv);
  return encrypted.base64;
}

String decryptText(String encryptedText) {
  final encrypter = encrypt.Encrypter(encrypt.AES(_key));
  final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
  return decrypted;
}

String encryptTextMainkey(String plainText) {
  final encrypter = encrypt.Encrypter(encrypt.AES(_keyMain));
  final encrypted = encrypter.encrypt(plainText, iv: _iv);
  return encrypted.base64;
}


