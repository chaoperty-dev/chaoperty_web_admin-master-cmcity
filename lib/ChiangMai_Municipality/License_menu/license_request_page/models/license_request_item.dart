// ============================================================================
// license_request_item.dart
// ============================================================================
// Model — แถวรายการ "คำขอ" จาก v2 endpoint
//
//   GET /api/v2/admin/requests?per_page=15&sort_by=created_at&sort_dir=desc
//
// Query params ที่ใช้: per_page, sort_by, sort_dir, q, announcement_uuid,
//                    status[], module_id, customer, created_from/to,
//                    submitted_from/to, review_attachments_all_done,
//                    inspection_passed, payment_all_done, zser, subzoneser
//
// ตัว model นี้เป็น "ของตัวเอง" ของ license_request_page
// (ไม่แชร์กับ attach_page / fact_check / submit_approval / verify_attachment)
//
// หมายเหตุ: response มี `details.zser` (int) — backend ใส่ zone serial
// กลับมาในแต่ละแถวด้วย ส่วน query filter ใช้ `zser=<int>` ที่ root level
// ============================================================================

import 'package:intl/intl.dart';

/// module — ดึงจาก json['module']
class LicenseRequestModule {
  final String code;
  final String nameTh;
  const LicenseRequestModule({this.code = '', this.nameTh = ''});

  factory LicenseRequestModule.fromJson(Map<String, dynamic> json) =>
      LicenseRequestModule(
        code: (json['code'] ?? '').toString(),
        nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      );
}

/// customer — ดึงจาก json['customer'] (nullable ใน v2)
class LicenseRequestCustomer {
  final int? id;
  final String uuid;
  final String requestUuid;
  final String active;
  final String custno;
  final String taxno;
  final String tax;
  final String type;
  final String stype;
  final String scname;
  final String sname;
  final String cname;
  final String branch;
  final String attn;
  final String addr1;
  final String addr2;
  final String zip;
  final String tel;
  final String email;
  final String? createdAt;
  final String? updatedAt;

  const LicenseRequestCustomer({
    this.id,
    this.uuid = '',
    this.requestUuid = '',
    this.active = '',
    this.custno = '',
    this.taxno = '',
    this.tax = '',
    this.type = '',
    this.stype = '',
    this.scname = '',
    this.sname = '',
    this.cname = '',
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

  factory LicenseRequestCustomer.fromJson(Map<String, dynamic> json) =>
      LicenseRequestCustomer(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse('${json['id'] ?? ''}'),
        uuid: (json['uuid'] ?? '').toString(),
        requestUuid: (json['request_uuid'] ?? '').toString(),
        active: (json['active'] ?? '').toString(),
        custno: (json['custno'] ?? '').toString(),
        taxno: (json['taxno'] ?? '').toString(),
        tax: (json['tax'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        stype: (json['stype'] ?? '').toString(),
        scname: (json['scname'] ?? '').toString(),
        sname: (json['sname'] ?? '').toString(),
        cname: (json['cname'] ?? json['attn'] ?? '').toString(),
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

  /// Format เบอร์โทร 09X-XXX-XXXX (ถ้ามี)
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
class LicenseRequestDetails {
  final String subzone;
  final int? zser; // zone serial (int ใน response v2)
  final String zn;
  final String ln;
  final String sdate; // start date (YYYY-MM-DD)
  final String type; // รายปี / รายเดือน / etc.
  final String qty; // จำนวน

  const LicenseRequestDetails({
    this.subzone = '',
    this.zser,
    this.zn = '',
    this.ln = '',
    this.sdate = '',
    this.type = '',
    this.qty = '',
  });

  factory LicenseRequestDetails.fromJson(Map<String, dynamic> json) =>
      LicenseRequestDetails(
        subzone: (json['subzone'] ?? '').toString(),
        zser: json['zser'] is int
            ? json['zser'] as int
            : int.tryParse('${json['zser'] ?? ''}'),
        zn: (json['zn'] ?? '').toString(),
        ln: (json['ln'] ?? '').toString(),
        sdate: (json['sdate'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        qty: (json['qty'] ?? '').toString(),
      );
}

/// 1 แถวรายการ — list v2
class LicenseRequestItem {
  final String uuid;
  final LicenseRequestModule module;
  final LicenseRequestCustomer? customer; // nullable ใน v2
  final LicenseRequestDetails details;
  final String status;
  final String feeAmount;
  final bool createdByAdmin;
  final String? createdAt;
  final String? submittedAt;
  final String? completedAt;
  final bool reviewAttachmentsAllDone;
  final bool inspectionPassed;
  final bool paymentAllDone;
  final bool approvalPending;

  const LicenseRequestItem({
    this.uuid = '',
    this.module = const LicenseRequestModule(),
    this.customer,
    this.details = const LicenseRequestDetails(),
    this.status = '',
    this.feeAmount = '',
    this.createdByAdmin = false,
    this.createdAt,
    this.submittedAt,
    this.completedAt,
    this.reviewAttachmentsAllDone = false,
    this.inspectionPassed = false,
    this.paymentAllDone = false,
    this.approvalPending = false,
  });

  factory LicenseRequestItem.fromJson(Map<String, dynamic> json) {
    final moduleJson = json['module'];
    final customerJson = json['customer'];
    final detailsJson = json['details'];

    return LicenseRequestItem(
      uuid: (json['uuid'] ?? '').toString(),
      module: moduleJson is Map
          ? LicenseRequestModule.fromJson(
              Map<String, dynamic>.from(moduleJson))
          : const LicenseRequestModule(),
      customer: customerJson is Map
          ? LicenseRequestCustomer.fromJson(
              Map<String, dynamic>.from(customerJson))
          : null,
      details: detailsJson is Map
          ? LicenseRequestDetails.fromJson(
              Map<String, dynamic>.from(detailsJson))
          : const LicenseRequestDetails(),
      status: (json['status'] ?? '').toString(),
      feeAmount: (json['fee_amount'] ?? '0.00').toString(),
      createdByAdmin: json['created_by_admin'] == true,
      createdAt: json['created_at']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      reviewAttachmentsAllDone: json['review_attachments_all_done'] == true,
      inspectionPassed: json['inspection_passed'] == true,
      paymentAllDone: json['payment_all_done'] == true,
      approvalPending: json['approval_pending'] == true,
    );
  }

  // ─── UI compat helpers ───
  String get customerName => customer?.cname ?? customer?.scname ?? '';
  String get customerTel => customer?.telFormatted ?? '';
  String get moduleNameTh => module.nameTh;
  String get moduleCode => module.code;
  String get subzone => details.subzone;
  String get zn => details.zn;
  String get ln => details.ln;
  int? get zoneSer => details.zser;

  /// Status label (TH) — map จาก status string
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'ร่าง';
      case 'pending':
        return 'รอดำเนินการ';
      case 'under_review':
        return 'กำลังตรวจสอบ';
      case 'in_progress':
        return 'กำลังดำเนินการ';
      case 'documents_submitted':
        return 'ยื่นเอกสารแล้ว';
      case 'waiting_payment_info':
        return 'รอข้อมูลการชำระ';
      case 'payment_submitted':
        return 'ส่งหลักฐานชำระแล้ว';
      case 'completed':
      case 'approved':
        return 'เสร็จสิ้น';
      case 'rejected':
        return 'ปฏิเสธ';
      case 'cancelled':
      case 'canceled':
        return 'ยกเลิก';
      default:
        return status.isEmpty ? '-' : status;
    }
  }
}

/// Wrapper สำหรับ list endpoint — items + meta + links
class LicenseRequestsListResult {
  final List<LicenseRequestItem> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksFirst;
  final String? linksLast;
  final String? linksPrev;
  final String? linksNext;
  const LicenseRequestsListResult({
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

  static const empty = LicenseRequestsListResult(
    items: [],
    currentPage: 0,
    lastPage: 0,
    perPage: 0,
    total: 0,
  );
}

/// Format helpers
String formatLicenseRequestDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('dd-MM-yyyy HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}