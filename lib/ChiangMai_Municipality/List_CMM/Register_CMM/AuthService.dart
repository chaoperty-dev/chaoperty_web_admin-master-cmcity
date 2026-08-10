import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Constant/Myconstant.dart';
import '../../unity/SecurePrefs_helper.dart';

class AuthService {
  static final String _loginUrl = '${MyConstant().domain_v1}/admin/login';
  static final String _checkTokenUrl = '${MyConstant().domain_v1}/admin/me';
  static final String _logoutTokenUrl =
      '${MyConstant().domain_v1}/admin/logout';

  static Future<bool> login(String email, String password) async {
    try {
      print('🌐 [AuthService.login] URL = $_loginUrl');
      print('   body = {email: $email, password: ***}');

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

        print('📝 [AuthService.login] /admin/login response:');
        print('   statusCode = ${response.statusCode}');
        print('   access_token = $token');
        print('   user = $user');

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

          // ✅ บันทึก SharedPreferences ทันที เพื่อให้ shell page ใช้ renTalSer ได้
          // ไม่ต้องรอ routeToService() ที่อยู่ใน HomePage อีกต่อไป
          String? savedRen;
          String? savedRenTalSer;
          String? savedRenTalName;
          try {
            final prefs = await SharedPreferences.getInstance();
            await _persistLegacyPrefs(user);
            savedRen = prefs.getString('ren');
            savedRenTalSer = prefs.getString('renTalSer');
            savedRenTalName = prefs.getString('renTalName');
          } catch (e) {
            print('❌ [AuthService.login] _persistLegacyPrefs error: $e');
          }

          // ✅ แสดงค่าที่บันทึกจริง (หลัง fallback) — rser/ren/renTalSer คือค่าเดียวกัน
          print('✅ [AuthService.login] saved (after fallback):');
          print('   rser       = ${user['rser']}');
          print('   ren        = $savedRen');
          print('   renTalSer  = $savedRenTalSer');
          print('   renTalName = $savedRenTalName');
          return true;
        } else {
          print('⚠️ [AuthService.login] Missing token or user in response');
          return false;
        }
      } else {
        print('❌ [AuthService.login] failed: ${response.statusCode}');
        print('   body = ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ [AuthService.login] exception: $e');
      return false;
    }
  }

  /// 🔄 Try auto login using saved token
  static Future<bool> tryAutoLogin() async {
    final token =
        await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
    final headers = await MyHeaders.build(); // ✅ ต้อง await
    if (token == null) {
      print('🔒 [AuthService.tryAutoLogin] No stored token found');
      return false;
    }
    // printStoredAuthData(); // ❌ ปิด print log
    try {
      print('🌐 [AuthService.tryAutoLogin] URL = $_checkTokenUrl');
      print('   headers = $headers');

      final response =
          await http.get(Uri.parse(_checkTokenUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // print('✅ Token valid, auto-login success');

        // ⚠️ /admin/me บางทีไม่ส่ง rser/ren กลับมา ต้อง merge กับ user ที่ login ไว้ก่อน
        // ไม่งั้นจะทับ user object เดิมและ rser หาย
        final existingUserJson =
            await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);
        Map<String, dynamic> existing = {};
        if (existingUserJson != null) {
          try {
            existing = jsonDecode(existingUserJson) as Map<String, dynamic>;
          } catch (_) {}
        }

        final meUser = data['user'] ?? data;
        if (meUser is Map) {
          final merged = Map<String, dynamic>.from(existing);
          merged.addAll(Map<String, dynamic>.from(meUser));
          await SecurePrefs.setEncrypted(
            SecurePrefsType.authUserObject,
            jsonEncode(merged),
          );
          print('🔄 [tryAutoLogin] /admin/me merged user saved');
          print('   rser = ${merged['rser']}');
          print('   ren  = ${merged['ren']}');
          print('   renTalSer = ${merged['renTalSer']}');
          print('   renTalName = ${merged['renTalName']}');
          print('   rname = ${merged['rname']}');
          print('   ren_name = ${merged['ren_name']}');
        }

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
      await http.post(Uri.parse(_logoutTokenUrl), headers: headers);
      // final response = await http.post(Uri.parse(_logoutTokenUrl), headers: headers);
      // final data = jsonDecode(response.body);
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
    } catch (e) {
      //  print('❌ Exception during logout: $e');
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

  /// 💾 บันทึก SharedPreferences (legacy keys) ให้หน้าอื่นใช้
  /// เพื่อให้ shell page ใช้ renTalSer / rser / etc ได้ทันทีหลัง login
  static Future<void> _persistLegacyPrefs(dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    final rser = user['rser']?.toString() ?? '195';
    final ren = user['ren']?.toString();
    final renTalSer = user['renTalSer']?.toString();
    final renTalName = user['renTalName']?.toString();
    final rname = user['rname']?.toString();
    final renName = user['ren_name']?.toString();

    // ลำดับ fallback: renTalSer → ren → rser → '195'
    final fallbackRenTalSer = renTalSer ?? ren ?? rser ?? '195';
    final fallbackRen = ren ?? rser ?? '195';
    final fallbackRenTalName = renTalName ?? rname ?? renName ?? '';

    await Future.wait([
      prefs.setString('ser', '${user['ser'] ?? ''}'),
      prefs.setString('position', '${user['position'] ?? ''}'),
      prefs.setString('fname', '${user['fname'] ?? ''}'),
      prefs.setString('lname', '${user['lname'] ?? ''}'),
      prefs.setString('email', '${user['email'] ?? ''}'),
      prefs.setString('permission', '${user['permission'] ?? ''}'),
      prefs.setString('rser', rser),
      prefs.setString('lavel', '${user['level'] ?? user['lavel'] ?? '5'}'),
      prefs.setString('ren', fallbackRen),
      prefs.setString('renTalSer', fallbackRenTalSer),
      prefs.setString('renTalName', fallbackRenTalName),
    ]);

    print('💾 [AuthService.login] SharedPreferences saved:');
    print('   rser = $rser');
    print('   ren = $fallbackRen');
    print('   renTalSer = $fallbackRenTalSer');
    print('   renTalName = $fallbackRenTalName');
  }
}
