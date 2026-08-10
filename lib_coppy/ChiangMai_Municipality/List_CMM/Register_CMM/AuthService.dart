import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../unity/SecurePrefs_helper.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;

class AuthService {
  static final String _loginUrl = '${MyConstant().domain_v1}/admin/login';
  static final String _checkTokenUrl = '${MyConstant().domain_v1}/admin/me';
  static final String _logoutTokenUrl =
      '${MyConstant().domain_v1}/admin/logout';

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {
          // 'credentials': 'include',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
          // 'Access-Control-Allow-Origin': '*',
          // 'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          // 'Access-Control-Allow-Headers': 'Content-Type, Accept',
        },
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];

        if (token != null && user != null) {
          await SecurePrefs.setEncrypted(
            SecurePrefsType.authUserObject,
            jsonEncode(data),
          );
          await SecurePrefs.setEncrypted(SecurePrefsType.authUserEmail, email);

          await SecurePrefs.setEncrypted(
              SecurePrefsType.authAccessToken, token);
          await SecurePrefs.setEncrypted(
              SecurePrefsType.authUserUuid, user['uuid']);

          await SecurePrefs.setEncrypted(
              SecurePrefsType.authUserObject, jsonEncode(user));

          //   print('✅ Login success: token, uuid, and user saved securely');
          return true;
        } else {
          // print('⚠️ Missing token or user in response');
          return false;
        }
      } else {
        //print('❌ Login failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // print('❌ Exception during login: $e');
      return false;
    }
  }

  /// 🔄 Try auto login using saved token
  static Future<bool> tryAutoLogin() async {
    final token =
        await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
    final headers = await MyHeaders.build(); // ✅ ต้อง await
    if (token == null) {
      //   print('🔒 No stored token found');
      return false;
    }
    // printStoredAuthData(); // ❌ ปิด print log
    try {
      final response =
          await http.get(Uri.parse(_checkTokenUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // print('✅ Token valid, auto-login success');

        //  print(data);
        return true;
      } else {
        // print('⚠️ Token invalid or expired: ${response.statusCode}');
        await logout();
        return false;
      }
    } catch (e) {
      // print('❌ Token check error: $e');
      return false;
    }
  }

  /// 🚪 Logout and clear token/user
  /// 🚪 Logout and clear token/user
  static Future<void> logout() async {
    try {
      // 🔐 เตรียม Header
      final headers = await MyHeaders.build();
      // 📦 ลบ Token และข้อมูลผู้ใช้ใน Secure Storage

      // 🌐 ส่งคำขอ logout ไปยัง server
      final response =
          await http.post(Uri.parse(_logoutTokenUrl), headers: headers);
      final data = jsonDecode(response.body);
      // final jsonRes = json.decode(response.body);
      //   print('🧾 Raw JSON: $data');
      //  print(' Logout statusCode: [${response.statusCode}] ${response.body}');
      // if (response.statusCode == 200) {
      // } else {
      //   print(' Logout statusCode: [${response.statusCode}] ${response.body}');
      // }
      await Future.wait([
        SecurePrefs.removeEncrypted(SecurePrefsType.authAccessToken),
        SecurePrefs.removeEncrypted(SecurePrefsType.authUserUuid),
        SecurePrefs.removeEncrypted(SecurePrefsType.authUserObject),
      ]);
    } catch (e, stack) {
      //  print('❌ Exception during logout: $e');
      // print('📌 Stacktrace:\n$stack');
    }
    //  print('🚪 Logged out and local data cleared.');
  }

  /// 👤 Get user info from storage
  static Future<Map<String, dynamic>?> getUser() async {
    final userJson =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// 🔑 Get decrypted token
  static Future<String?> getToken() async {
    return await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
  }

  /// 🆔 Get decrypted user UUID
  static Future<String?> getUserUuid() async {
    return await SecurePrefs.getDecrypted(SecurePrefsType.authUserUuid);
  }

  /// 🟢 Check if it's the first login
  static Future<bool> isFirstLogin() async {
    final user = await getUser();
    if (user == null) return true; // ✅ default ให้เป็น first login
    return user['first_login_completed'] == 0;
  }

  /// 🧾 Check if user is active
  static Future<bool> isActiveUser() async {
    final user = await getUser();
    return user?['active'] == 1;
  }

  /// 🧾 แสดงค่าทุกอย่างที่เก็บไว้ในระบบ auth (ใช้สำหรับ debug)
  static Future<void> printStoredAuthData() async {
    // Logic for printing was removed to maintain security.
  }
}
