// ============================================================================
// payment_service.dart
// ============================================================================
// Service — เรียก API ทั้งหมดที่หน้า "การรับชำระ" ต้องใช้
// - เขียนใหม่ทั้งหมด ไม่ reuse service เดิม
// - ไม่ใช้ dart:html (รองรับ mobile/desktop)
// - ใช้ MyConstant().domain (PHP API เดิม)
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../../Constant/Myconstant.dart';
import '../models/payment_bank_model.dart';
import '../models/payment_banktype_model.dart';
import '../models/payment_paytype_model.dart';
import '../models/payment_payment_model.dart';
import '../models/payment_rental_model.dart';

class PaymentService {
  PaymentService();

  String get _base => MyConstant().domain;

  // ===============================================================
  // Payment
  // ===============================================================
  Future<List<PaymentPaymentModel>> fetchPayments(String rser) async {
    final url = '$_base/GC_payMent.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <PaymentPaymentModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <PaymentPaymentModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(PaymentPaymentModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('PaymentService.fetchPayments error: $e');
      return <PaymentPaymentModel>[];
    }
  }

  Future<bool> addPayment({
    required String rser,
    required String ln,
    required String sn,
    required String sname,
    required String sw,
    required String zone,
    required String typeId,
    required String bankId,
    required String bankTypeId,
  }) async {
    final url = '$_base/Edit_payMent.php?isAdd=true&ren=$rser';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ln': ln,
          'sn': sn,
          'sname': sname,
          'sw': sw,
          'zone': zone,
          'type_id': typeId,
          'bank_id': bankId,
          'bank_type_id': bankTypeId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.addPayment error: $e');
      return false;
    }
  }

  Future<bool> updatePayment({
    required String rser,
    required String ser,
    required String ln,
    required String sn,
    required String sname,
    required String sw,
    required String zone,
    required String typeId,
    required String bankId,
    required String bankTypeId,
  }) async {
    final url = '$_base/Edit_payMent.php?isAdd=true&ren=$rser&ser=$ser';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'ln': ln,
          'sn': sn,
          'sname': sname,
          'sw': sw,
          'zone': zone,
          'type_id': typeId,
          'bank_id': bankId,
          'bank_type_id': bankTypeId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.updatePayment error: $e');
      return false;
    }
  }

  Future<bool> deletePayment({
    required String rser,
    required String ser,
  }) async {
    final url = '$_base/Edit_payMent.php?isAdd=true&ren=$rser&ser=$ser&delete=1';
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.deletePayment error: $e');
      return false;
    }
  }

  // ===============================================================
  // PayType
  // ===============================================================
  Future<List<PaymentPayTypeModel>> fetchPayTypes(String rser) async {
    final url = '$_base/GC_paytype.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <PaymentPayTypeModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <PaymentPayTypeModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(PaymentPayTypeModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('PaymentService.fetchPayTypes error: $e');
      return <PaymentPayTypeModel>[];
    }
  }

  Future<bool> addPayType({
    required String rser,
    required String tn,
    String? desc,
  }) async {
    final url = '$_base/add_paytype.php?isAdd=true&ren=$rser';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'tn': tn,
          if (desc != null && desc.isNotEmpty) 'desc': desc,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.addPayType error: $e');
      return false;
    }
  }

  // ===============================================================
  // Bank
  // ===============================================================
  Future<List<PaymentBankModel>> fetchBanks(String rser) async {
    final url = '$_base/GC_bank.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <PaymentBankModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <PaymentBankModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(PaymentBankModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('PaymentService.fetchBanks error: $e');
      return <PaymentBankModel>[];
    }
  }

  Future<bool> addBank({
    required String rser,
    required String bcode,
    required String bname,
    required String btype,
  }) async {
    final url = '$_base/add_bank.php?isAdd=true&ren=$rser';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'bcode': bcode,
          'bname': bname,
          'btype': btype,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.addBank error: $e');
      return false;
    }
  }

  // ===============================================================
  // BankType
  // ===============================================================
  Future<List<PaymentBankTypeModel>> fetchBankTypes(String rser) async {
    final url = '$_base/GC_bank_type.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <PaymentBankTypeModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <PaymentBankTypeModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(PaymentBankTypeModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('PaymentService.fetchBankTypes error: $e');
      return <PaymentBankTypeModel>[];
    }
  }

  Future<bool> addBankType({
    required String rser,
    required String btype,
  }) async {
    final url = '$_base/add_bank_type.php?isAdd=true&ren=$rser';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'btype': btype},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.addBankType error: $e');
      return false;
    }
  }

  // ===============================================================
  // Rental
  // ===============================================================
  Future<List<PaymentRentalModel>> fetchRentals(String rser) async {
    final url = '$_base/GC_rental_setring.php?isAdd=true&ren=$rser';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return <PaymentRentalModel>[];
      final result = json.decode(response.body);
      if (result is! List) return <PaymentRentalModel>[];
      return result
          .whereType<Map<String, dynamic>>()
          .map(PaymentRentalModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('PaymentService.fetchRentals error: $e');
      return <PaymentRentalModel>[];
    }
  }

  // ===============================================================
  // Slip (อัปโหลด/ลบ)
  // ===============================================================
  Future<bool> uploadSlip({
    required String rser,
    required String ser,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final url = '$_base/upload_payment_slip.php?isAdd=true&ren=$rser&ser=$ser';
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(
          http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
        );
      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.uploadSlip error: $e');
      return false;
    }
  }

  Future<bool> deleteSlip({
    required String rser,
    required String ser,
    required String fileName,
    required String foder,
    required String pathFoder,
  }) async {
    final url = '$_base/File_Deleted_QR.php'
        '?Foder=$foder'
        '&Pathfoder=$pathFoder'
        '&name=$fileName'
        '&ren=$rser'
        '&ser=$ser';
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PaymentService.deleteSlip error: $e');
      return false;
    }
  }
}
