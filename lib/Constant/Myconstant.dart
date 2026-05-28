import '../ChiangMai_Municipality/unity/SecurePrefs_helper.dart';

class MyToken {
  static Future<String?> get accessToken async =>
      await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
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

// superadmin@example.com
// password123

class MyConstant {
// final ren = SharedPreferences.getInstance().getString('renTalSer');
// https://mbstar.co.th
  // String domain =
  //     '${Uri.base.toString().substring(0, Uri.base.toString().length - 3)}/chao_api';
  // String domain = 'https://chaoperties.com/Choice/chao_api';
  // String domain = 'https://chaoperties.com/CMM/chao_api';
  String domain = 'https://chaoperties.com/cmcity/chao_api';
  // String domain = 'https://chaoperties.com/Admin_Test/chao_api';
  // String domain_test = 'https://chaoperties.com/Admin_Test/chao_api';
  // String domain = 'http://goodviewcmu.cnxsolution.net:94/APIQ';
  // http://tananuwat.dynns.com:7080/webQR/#?1658194561/18,T01
  // // String domain = 'http://localhost/chao_api';
  // String domain = 'http://192.168.1.227/chao_api';

  // String domain_v1 = 'https://newtest.chaoperties.com//api/v1';
  // String domain_v2 = 'https://newtest.chaoperties.com//api/v2';

  // String domain_v1 = 'http://192.168.1.89:8080/api/v1';
  // String domain_v2 = 'http://192.168.1.89:8080/api/v2';
  // String domain_v3 = 'http://192.168.1.89:8080';

  // String domain_v1 = 'https://upload.rimpinglao.com/api/v1';
  // String domain_v2 = 'https://upload.rimpinglao.com/api/v2';
  // String domain_v3 = 'https://upload.rimpinglao.com';

  // String domain_v1 = 'https://apis.chaoperties.com/api/v1';
  // String domain_v2 = 'https://apis.chaoperties.com/api/v2';R
  // String domain_v3 = 'https://apis.chaoperties.com';

  String domain_v1 = 'https://cmcity-api.chaoperties.com/api/v1';
  String domain_v2 = 'https://cmcity-api.chaoperties.com/api/v2';
  String domain_v3 = 'https://cmcity-api.chaoperties.com';

  // List<String> Authorizations = [
  //   'Bearer 3|7HeaY2A8EqAveID7fpx5i4nevJfzmZrAnb2QxDyX1a724c5a',
  //   'Bearer 2|cwoWiBqMSaTaX7DH0cgJ2Z0Z9NrqDGAQjhULhTyu89b57898',
  //   'Bearer 4|ji2BVh8CC0xrPweO2NWn1XWBdD4LGds230Azqs98b96884b5', //role การเงิน
  // ];
  // '3|7HeaY2A8EqAveID7fpx5i4nevJfzmZrAnb2QxDyX1a724c5a';
  // 'Bearer 2|cwoWiBqMSaTaX7DH0cgJ2Z0Z9NrqDGAQjhULhTyu89b57898';
}

// class MyImage {
//   String domainActivity = 'https://mbstar.co.th/admin/files/activity/';
//   String domainCar = 'https://mbstar.co.th/admin/files/car/';
//   String domainCard = 'https://mbstar.co.th/admin/files/card/';
//   String domainCover = 'https://mbstar.co.th/admin/files/cover/';
//   String domainPromotion = 'https://mbstar.co.th/admin/files/promotion/';
//   String domainSalary = 'https://mbstar.co.th/admin/files/salary/';
//   String domainheaderweb_img =
//       'https://mbstar.co.th/admin/files/headerweb_img/'; 010555908541209
// }tys 099400016565010  pdf_Agreement_Nichada
// https://chaoperties.com/chao_api_test/LAMP_DEV.php?isAdd=true
// จริง : https://chaoperties.com/cmcity
// ทดสอบ : https://chaoperties.com/cmcity_test