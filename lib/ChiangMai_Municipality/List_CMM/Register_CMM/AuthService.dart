import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Constant/Myconstant.dart';
import '../../unity/auth_token_store.dart';

class AuthService {
  // ✅ API v2 — /admin/auth/*
  static final String _loginUrl =
      '${MyConstant().domain_v2}/admin/auth/login';
  static final String _rolesTreeUrl =
      '${MyConstant().domain_v2}/admin/roles/tree';
  static final String _logoutTokenUrl =
      '${MyConstant().domain_v2}/admin/auth/logout';

  static Future<bool> login(String email, String password) async {
    try {
      print('🌐 [AuthService.login] URL = $_loginUrl');
      print('   body = {email: $email, password: ***}');

      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        final data = jsonRes is Map ? jsonRes['data'] : null;
        final token = data is Map ? data['access_token'] : null;
        final user = data is Map ? data['user'] : null;

        print('📝 [AuthService.login] /admin/auth/login response:');
        print('   statusCode = ${response.statusCode}');

        if (token != null && user is Map) {
          // 🔐 auth data → sessionStorage (web) / SecurePrefs (native)
          await AuthTokenStore.save(token);
          await AuthEmailStore.save(email);
          await AuthUuidStore.save(user['uuid']?.toString() ?? '');
          await AuthUserStore.save(jsonEncode(user));

          // ✅ legacy SharedPreferences ให้ shell/AdminScaffold ใช้ต่อ
          try {
            await _persistLegacyPrefs(
                Map<String, dynamic>.from(user));
          } catch (e) {
            print('❌ [AuthService.login] _persistLegacyPrefs error: $e');
          }

          // 🌳 เมนู — ยิง roles/tree หลัง login สำเร็จ
          final tree = await fetchRolesTree();
          print('✅ [AuthService.login] saved. roles/tree roles = '
              '${tree?.length}');

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

  /// 🌳 โหลด role tree (GET /admin/roles/tree) — เอาเมนูที่ user มีสิทธิ์
  /// - assigned == true → user มี role นี้ (ใช้ filter เมนู)
  /// - cache ทั้ง tree ไว้ใน SecurePrefs (authRolesTree)
  /// - สรุป code ที่ assigned เป็น string เก็บใน prefs 'menuPermission'
  static Future<List<Map<String, dynamic>>?> fetchRolesTree() async {
    final token = await AuthTokenStore.read();
    if (token == null) return null;
    try {
      print('🌐 [AuthService.fetchRolesTree] URL = $_rolesTreeUrl');
      final response = await http.get(
        Uri.parse(_rolesTreeUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('   status = ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        final data = jsonRes is Map ? jsonRes['data'] : null;
        if (data is List) {
          await AuthRolesTreeStore.save(jsonEncode(data));

          final assigned = <String>[];
          _collectAssigned(data, assigned);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('menuPermission', assigned.join(','));
          print('   assigned menus = $assigned');
          return data.cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      print('❌ [AuthService.fetchRolesTree] exception: $e');
      return null;
    }
  }

  /// ไล่ tree (รวม children) เก็บ code ของ role ที่ assigned == true
  static void _collectAssigned(List data, List<String> out) {
    for (final item in data) {
      if (item is! Map) continue;
      if (item['assigned'] == true) {
        final code = item['code']?.toString() ?? '';
        if (code.isNotEmpty) out.add(code);
      }
      final children = item['children'];
      if (children is List) _collectAssigned(children, out);
    }
  }

  /// 🌳 อ่าน menuPermission (code คั่นด้วย ,) ที่ cache ไว้
  static Future<List<String>> getMenuPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('menuPermission') ?? '';
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// 🔄 Try auto login using saved token
  /// — v2 ไม่มี /admin/me แล้ว ใช้ roles/tree เป็น token check แทน
  /// (200 = token valid, 401 = หมดอายุ → logout)
  static Future<bool> tryAutoLogin() async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      print('🔒 [AuthService.tryAutoLogin] No stored token found');
      return false;
    }
    try {
      // 🌳 ได้ทั้ง validate token + refresh เมนูในครั้งเดียว
      final tree = await fetchRolesTree();
      if (tree != null) {
        return true;
      }
      await logout();
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 🚪 Logout and clear token/user
  static Future<void> logout() async {
    try {
      // 🔐 เตรียม Header
      final headers = await MyHeaders.build();

      // 🌐 ส่งคำขอ logout ไปยัง server (revoke token)
      try {
        await http.post(Uri.parse(_logoutTokenUrl), headers: headers);
      } catch (_) {
        // server ไปไม่ได้ก็ต้อง clear local ต่อ
      }

      // 📦 ลบ Token + user + เมนู ออกจาก local ให้หมด
      await clearAllAuthStores();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('menuPermission');
      await prefs.remove('permission');
    } catch (e) {
      // print('❌ Exception during logout: $e');
    }
  }

  /// 👤 Get user info from storage
  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await AuthUserStore.read();
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// 🔑 Get decrypted token
  static Future<String?> getToken() async {
    return await AuthTokenStore.read();
  }

  /// 🆔 Get decrypted user UUID
  static Future<String?> getUserUuid() async {
    return await AuthUuidStore.read();
  }

  /// 🟢 Check if it's the first login (v2: bool / เดิม: int 0)
  static Future<bool> isFirstLogin() async {
    final user = await getUser();
    if (user == null) return true; // ✅ default ให้เป็น first login
    final v = user['first_login_completed'];
    return v == false || v == 0 || v == null;
  }

  /// 🧾 Check if user is active (v2: bool / เดิม: int 1)
  static Future<bool> isActiveUser() async {
    final user = await getUser();
    if (user == null) return false;
    final v = user['active'];
    return v == true || v == 1;
  }

  /// 🧾 แสดงค่าทุกอย่างที่เก็บไว้ในระบบ auth (ใช้สำหรับ debug)
  static Future<void> printStoredAuthData() async {
    // Logic for printing was removed to maintain security.
  }

  /// 💾 บันทึก SharedPreferences (legacy keys) ให้หน้าอื่นใช้
  /// — map จาก user object ของ v2 (/admin/auth/login → data.user)
  static Future<void> _persistLegacyPrefs(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    final profile =
        (user['profile'] as Map?)?.cast<String, dynamic>() ?? const {};
    final position =
        (user['position'] as Map?)?.cast<String, dynamic>() ?? const {};

    // v2 มีแค่ full_name — แยกเป็น fname/lname ให้ legacy
    final fullName = profile['full_name']?.toString() ?? '';
    final nameParts =
        fullName.trim().split(RegExp(r'\s+'))..removeWhere((e) => e.isEmpty);
    final fname = nameParts.isNotEmpty ? nameParts.first : '';
    final lname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // v2 permissions เป็น List<String> ของ code
    final permissions = (user['permissions'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .join(',') ??
        '';

    await Future.wait([
      prefs.setString('ser', user['uuid']?.toString() ?? ''),
      prefs.setString('position', position['name_th']?.toString() ?? ''),
      prefs.setString('fname', fname),
      prefs.setString('lname', lname),
      prefs.setString('email', user['email']?.toString() ?? ''),
      prefs.setString('permission', permissions),
      prefs.setString('rser', '195'), // legacy default เดิม
      prefs.setString(
          'lavel', position['level']?.toString() ?? '5'),
      prefs.setString('ren', '195'),
      prefs.setString('renTalSer', '195'),
      prefs.setString('renTalName', ''),
    ]);

    print('💾 [AuthService.login] legacy prefs saved '
        '(permission codes = ${permissions.split(',').length})');
  }
}
