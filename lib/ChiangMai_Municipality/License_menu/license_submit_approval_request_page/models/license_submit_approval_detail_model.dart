// ============================================================================
// license_submit_approval_detail_model.dart
// ============================================================================
// Model — แมปรายการ "ส่งคำร้องขออนุมัติ" + หลักฐาน
// map ตาม JSON จาก v2 endpoint:
//   - GET /api/v2/admin/requests/tasks/approvals   (list — ใหม่)
//   - POST {domain_v1}/v2/payments                (create draft)
// ============================================================================

import 'package:intl/intl.dart';

/// แถวค่าใช้จ่าย (addons / debt lines) ในรายส่งคำร้องขออนุมัติ
class SubmitApprovalAddon {
  final String label;
  final String value;
  final double? amount;

  const SubmitApprovalAddon({
    required this.label,
    required this.value,
    this.amount,
  });

  factory SubmitApprovalAddon.fromJson(Map<String, dynamic> json) {
    final amount = double.tryParse((json['amount'] ?? json['total'] ?? '0').toString());
    return SubmitApprovalAddon(
      label: (json['expname'] ?? json['label'] ?? json['name'] ?? '').toString(),
      value: (json['value'] ?? json['note'] ?? '').toString(),
      amount: amount,
    );
  }
}

/// รายละเอียดส่งคำร้องขออนุมัติ (Step 1 — ตรวจสอบ)
/// รองรับทั้ง legacy POST /v2/payments shape และ list /v2/admin/requests/tasks/approvals
class SubmitApprovalDetail {
  final String uuid;
  final String paymentNo;
  final String paymentSystem; // internal / external
  final String payType; // fee / fine
  final String status; // draft / paid / completed / waiting_payment_info
  final String methodName;
  final String payerName;
  final String clientTel;
  final String clientTax;
  final String clientAddr1;
  final double amount;
  final double? amountReceived;
  final String? paidAt;
  final String? createdAt;
  final List<SubmitApprovalAddon> addons;

  // ─── list endpoint extras ───
  final String moduleName; // module.name_th
  final String moduleCode; // module.code
  final String subzone; // details.subzone
  final String zn; // details.zn
  final String ln; // details.ln
  final bool approvalPending;
  final int pendingStepCount;
  final String? oldestPendingStepAt;

  const SubmitApprovalDetail({
    this.uuid = '',
    this.paymentNo = '',
    this.paymentSystem = '',
    this.payType = '',
    this.status = '',
    this.methodName = '',
    this.payerName = '',
    this.clientTel = '',
    this.clientTax = '',
    this.clientAddr1 = '',
    this.amount = 0,
    this.amountReceived,
    this.paidAt,
    this.createdAt,
    this.addons = const [],
    this.moduleName = '',
    this.moduleCode = '',
    this.subzone = '',
    this.zn = '',
    this.ln = '',
    this.approvalPending = false,
    this.pendingStepCount = 0,
    this.oldestPendingStepAt,
  });

  factory SubmitApprovalDetail.fromJson(Map<String, dynamic> json) {
    final addonsRaw = json['addons'];
    final addons = addonsRaw is List
        ? addonsRaw
            .whereType<Map<String, dynamic>>()
            .map(SubmitApprovalAddon.fromJson)
            .toList()
        : <SubmitApprovalAddon>[];

    // module
    final module = json['module'];
    String moduleName = '';
    String moduleCode = '';
    if (module is Map) {
      moduleName = (module['name_th'] ?? module['nameTh'] ?? '').toString();
      moduleCode = (module['code'] ?? '').toString();
    }

    // customer (v2 list endpoint) — nullable
    final customer = json['customer'];
    String payerName = '';
    String clientTel = '';
    String clientTax = '';
    String clientAddr1 = '';
    if (customer is Map) {
      payerName = (customer['cname'] ??
              customer['scname'] ??
              customer['payer_name'] ??
              customer['customer_name'] ??
              json['payer_name'] ??
              '')
          .toString();
      clientTel = (customer['tel'] ??
              customer['client_tel'] ??
              json['client_tel'] ??
              json['tel'] ??
              '')
          .toString();
      clientTax = (customer['tax'] ??
              customer['taxno'] ??
              customer['client_tax'] ??
              json['client_tax'] ??
              json['tax'] ??
              '')
          .toString();
      clientAddr1 = (customer['addr_1'] ??
              customer['addr1'] ??
              customer['client_addr1'] ??
              json['client_addr1'] ??
              json['addr1'] ??
              '')
          .toString();
    } else {
      // legacy POST /v2/payments shape (root-level)
      payerName =
          (json['payer_name'] ?? json['customer_name'] ?? json['name'] ?? '')
              .toString();
      clientTel = (json['client_tel'] ?? json['tel'] ?? '').toString();
      clientTax = (json['client_tax'] ?? json['tax'] ?? '').toString();
      clientAddr1 = (json['client_addr1'] ?? json['addr1'] ?? '').toString();
    }

    // details (v2 list endpoint)
    final details = json['details'];
    String subzone = '';
    String zn = '';
    String ln = '';
    if (details is Map) {
      subzone = (details['subzone'] ?? '').toString();
      zn = (details['zn'] ?? '').toString();
      ln = (details['ln'] ?? '').toString();
    }

    return SubmitApprovalDetail(
      uuid: (json['uuid'] ?? json['payment_uuid'] ?? '').toString(),
      paymentNo: (json['payment_no'] ?? json['paymentNo'] ?? '').toString(),
      paymentSystem:
          (json['payment_system'] ?? json['paymentSystem'] ?? '').toString(),
      payType: (json['pay_type'] ?? json['payType'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      methodName: (json['payment_method_name'] ??
              json['method_name'] ??
              json['method'] ??
              '')
          .toString(),
      payerName: payerName,
      clientTel: clientTel,
      clientTax: clientTax,
      clientAddr1: clientAddr1,
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      amountReceived:
          double.tryParse((json['amount_received'] ?? '').toString()),
      paidAt: (json['paid_at'] ?? json['paidAt'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      addons: addons,
      moduleName: moduleName,
      moduleCode: moduleCode,
      subzone: subzone,
      zn: zn,
      ln: ln,
      approvalPending: json['approval_pending'] == true,
      pendingStepCount: json['pending_step_count'] is int
          ? json['pending_step_count'] as int
          : int.tryParse((json['pending_step_count'] ?? '0').toString()) ?? 0,
      oldestPendingStepAt:
          (json['oldest_pending_step_at'] ?? json['oldestPendingStepAt'])
              ?.toString(),
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';

  /// UI compatibility: แสดง status เป็น label (TH/EN)
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return 'ส่งคำร้องแล้ว';
      case 'draft':
        return 'รอส่งคำร้อง';
      case 'waiting_payment_info':
      case 'waiting_payment':
        return 'รอข้อมูลการชำระ';
      case 'cancelled':
      case 'canceled':
        return 'ยกเลิก';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  /// UI compatibility: ข้อมูล contract ที่ UI คาดหวัง
  /// list endpoint → ใช้ details (subzone/zn/ln)
  /// legacy POST → ใช้ paymentSystem/payType/methodName
  NewRequest get newRequest => NewRequest(
        leaseNumber: paymentNo.isEmpty ? '-' : paymentNo,
        subzone: subzone.isNotEmpty ? subzone : paymentSystem,
        zn: zn.isNotEmpty ? zn : payType,
        ln: ln.isNotEmpty ? ln : methodName,
        ldate: paidAt,
      );

  /// UI compatibility: ข้อมูลลูกค้า/ผู้ส่งคำร้อง
  Client get client => Client(
        cname: payerName,
        tel: clientTel,
        tax: clientTax,
        addr1: clientAddr1,
      );
}

/// Wrapper for UI compatibility — fields ที่ table เก่าเรียกใช้
class NewRequest {
  final String leaseNumber;
  final String subzone;
  final String zn;
  final String ln;
  final String? ldate;

  const NewRequest({
    this.leaseNumber = '-',
    this.subzone = '-',
    this.zn = '-',
    this.ln = '-',
    this.ldate,
  });
}

/// Wrapper for UI compatibility — client info
class Client {
  final String cname;
  final String tel;
  final String tax;
  final String addr1;
  const Client({
    this.cname = '-',
    this.tel = '',
    this.tax = '',
    this.addr1 = '',
  });
}

/// หลักฐาน / สรุปส่งคำร้องขออนุมัติ (Step 2)
class SubmitApprovalReceipt {
  final String receiptNo;
  final String bookNo;
  final String bookDate;
  final String officerName;
  final String signatureUuid;
  final SubmitApprovalDetail payment;

  const SubmitApprovalReceipt({
    this.receiptNo = '',
    this.bookNo = '',
    this.bookDate = '',
    this.officerName = '',
    this.signatureUuid = '',
    this.payment = const SubmitApprovalDetail(),
  });

  factory SubmitApprovalReceipt.fromJson(Map<String, dynamic> json) {
    final officer = json['officer'];
    String officerName = '';
    String signatureUuid = '';
    if (officer is Map) {
      officerName = (officer['name'] ?? officer['fullname'] ?? '').toString();
      final sig = officer['signature'];
      if (sig is Map) {
        signatureUuid = (sig['uuid'] ?? '').toString();
      }
    }

    final paymentRaw = json['payment'];
    final payment = paymentRaw is Map
        ? SubmitApprovalDetail.fromJson(paymentRaw as Map<String, dynamic>)
        : const SubmitApprovalDetail();

    return SubmitApprovalReceipt(
      receiptNo: (json['receipt_no'] ?? json['receiptNo'] ?? '').toString(),
      bookNo: (json['book_no'] ?? json['bookNo'] ?? '').toString(),
      bookDate: (json['book_date'] ?? json['bookDate'] ?? '').toString(),
      officerName: officerName,
      signatureUuid: signatureUuid,
      payment: payment,
    );
  }

  factory SubmitApprovalReceipt.empty() => const SubmitApprovalReceipt();
}

/// Helper format
String formatMoney(double v) =>
    NumberFormat('#,##0.00', 'en_US').format(v);

String formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('dd-MM-yyyy HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}