// ============================================================================
// fact_check_item.dart
// ============================================================================
// Model — แถวรายการ "ตรวจสอบข้อเท็จจริง" (fact check / inspection task)
//
// map ตาม JSON จาก v2 endpoint:
//   GET /api/v2/admin/requests/tasks/inspections
//
// โมเดลนี้เป็น "ของตัวเอง" ของ fact_check_page — ไม่แชร์กับหน้าอื่น
// (ไม่ใช้ ReviewModel / SubmitApprovalDetail)
// ============================================================================

import 'package:intl/intl.dart';

/// module — ดึงจาก json['module']
class FactCheckModule {
  final String code;
  final String nameTh;
  const FactCheckModule({this.code = '', this.nameTh = ''});

  factory FactCheckModule.fromJson(Map<String, dynamic> json) =>
      FactCheckModule(
        code: (json['code'] ?? '').toString(),
        nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      );
}

/// customer — ดึงจาก json['customer'] (nullable ใน v2)
class FactCheckCustomer {
  final String uuid;
  final String requestUuid;
  final String custno;
  final String taxno;
  final String tax;
  final String type;
  final String stype;
  final String cname;
  final String sname;
  final String branch;
  final String attn;
  final String addr1;
  final String addr2;
  final String zip;
  final String tel;
  final String email;
  final String? createdAt;
  final String? updatedAt;

  const FactCheckCustomer({
    this.uuid = '',
    this.requestUuid = '',
    this.custno = '',
    this.taxno = '',
    this.tax = '',
    this.type = '',
    this.stype = '',
    this.cname = '',
    this.sname = '',
    this.branch = '',
    this.attn = '',
    this.addr1 = '',
    this.addr2 = '',
    this.zip = '',
    this.tel = '',
    this.email = '',
    this.createdAt,
    this.updatedAt,
  });

  factory FactCheckCustomer.fromJson(Map<String, dynamic> json) =>
      FactCheckCustomer(
        uuid: (json['uuid'] ?? '').toString(),
        requestUuid: (json['request_uuid'] ?? '').toString(),
        custno: (json['custno'] ?? '').toString(),
        taxno: (json['taxno'] ?? '').toString(),
        tax: (json['tax'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        stype: (json['stype'] ?? '').toString(),
        cname: (json['cname'] ?? '').toString(),
        sname: (json['sname'] ?? '').toString(),
        branch: (json['branch'] ?? '').toString(),
        attn: (json['attn'] ?? '').toString(),
        addr1: (json['addr_1'] ?? json['addr1'] ?? '').toString(),
        addr2: (json['addr_2'] ?? json['addr2'] ?? '').toString(),
        zip: (json['zip'] ?? '').toString(),
        tel: (json['tel'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  /// ดึงเบอร์โทรแบบ format 09X-XXX-XXXX (ถ้ามี)
  String get telFormatted {
    final digits = tel.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 9) {
      return '${digits.substring(0, 2)}-${digits.substring(2, 5)}-${digits.substring(5)}';
    }
    return tel;
  }
}

/// details — ดึงจาก json['details']
class FactCheckDetails {
  final String subzone;
  final String zn;
  final String ln;
  const FactCheckDetails({
    this.subzone = '',
    this.zn = '',
    this.ln = '',
  });
  factory FactCheckDetails.fromJson(Map<String, dynamic> json) =>
      FactCheckDetails(
        subzone: (json['subzone'] ?? '').toString(),
        zn: (json['zn'] ?? '').toString(),
        ln: (json['ln'] ?? '').toString(),
      );
}

/// inspection_review (ฝั่ง inspection state) — nullable
class FactCheckReview {
  final String? uuid;
  final String? state;
  final String? comment;
  final String? createdAt;
  const FactCheckReview({
    this.uuid,
    this.state,
    this.comment,
    this.createdAt,
  });
  factory FactCheckReview.fromJson(Map<String, dynamic> json) =>
      FactCheckReview(
        uuid: json['uuid']?.toString(),
        state: json['state']?.toString(),
        comment: json['comment']?.toString(),
        createdAt: json['created_at']?.toString(),
      );
}

/// 1 แถวรายการตรวจสอบข้อเท็จจริง — list v2
class FactCheckItem {
  final String uuid;
  final FactCheckModule module;
  final FactCheckCustomer? customer; // nullable ใน v2
  final FactCheckDetails details;
  final String status;
  final String? createdAt;
  final String? submittedAt;
  final bool inspectionPassed;
  final FactCheckReview? inspectionReview;

  const FactCheckItem({
    this.uuid = '',
    this.module = const FactCheckModule(),
    this.customer,
    this.details = const FactCheckDetails(),
    this.status = '',
    this.createdAt,
    this.submittedAt,
    this.inspectionPassed = false,
    this.inspectionReview,
  });

  factory FactCheckItem.fromJson(Map<String, dynamic> json) {
    final moduleJson = json['module'];
    final customerJson = json['customer'];
    final detailsJson = json['details'];
    final reviewJson = json['inspection_review'];

    return FactCheckItem(
      uuid: (json['uuid'] ?? '').toString(),
      module: moduleJson is Map
          ? FactCheckModule.fromJson(Map<String, dynamic>.from(moduleJson))
          : const FactCheckModule(),
      customer: customerJson is Map
          ? FactCheckCustomer.fromJson(Map<String, dynamic>.from(customerJson))
          : null,
      details: detailsJson is Map
          ? FactCheckDetails.fromJson(Map<String, dynamic>.from(detailsJson))
          : const FactCheckDetails(),
      status: (json['status'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      inspectionPassed: json['inspection_passed'] == true,
      inspectionReview: reviewJson is Map
          ? FactCheckReview.fromJson(Map<String, dynamic>.from(reviewJson))
          : null,
    );
  }

  // ─── UI compat helpers ───
  String get customerName => customer?.cname ?? customer?.sname ?? '';
  String get customerTel => customer?.telFormatted ?? '';
  String get moduleNameTh => module.nameTh;
  String get moduleCode => module.code;
  String get subzone => details.subzone;
  String get zn => details.zn;
  String get ln => details.ln;

  /// Status label (TH) — map จาก status string
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'ร่าง';
      case 'pending':
        return 'รอตรวจ';
      case 'under_review':
        return 'กำลังตรวจสอบ';
      case 'in_progress':
        return 'ดำเนินการ';
      case 'documents_submitted':
        return 'ส่งเอกสารแล้ว';
      case 'waiting_payment_info':
        return 'รอข้อมูลชำระ';
      case 'payment_submitted':
        return 'ส่งชำระแล้ว';
      case 'completed':
      case 'approved':
        return 'เสร็จสิ้น';
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return 'ยกเลิก';
      default:
        return status.isEmpty ? '-' : status;
    }
  }
}

/// Wrapper สำหรับ list endpoint — items + meta + links
class FactCheckListResult {
  final List<FactCheckItem> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksFirst;
  final String? linksLast;
  final String? linksPrev;
  final String? linksNext;
  const FactCheckListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.linksFirst,
    this.linksLast,
    this.linksPrev,
    this.linksNext,
  });

  static const empty = FactCheckListResult(
    items: [],
    currentPage: 0,
    lastPage: 0,
    perPage: 0,
    total: 0,
  );
}

/// Format helpers
String formatFactCheckDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('dd-MM-yyyy HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}