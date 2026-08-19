// ============================================================================
// verify_attachment_item.dart
// ============================================================================
// Model — แถวรายการ "ตรวจสอบหลักฐาน" (attachment review task) — v2 endpoint
//
//   GET /api/v2/admin/requests/tasks/attachments
//
// Query params ที่ใช้: include_done, sort_by, sort_dir, q, status[],
//                    customer, created_from/to, submitted_from/to,
//                    zser, subzoneser, per_page, page
//
// ตัว model นี้เป็น "ของตัวเอง" ของ license_verify_page
// (ไม่แชร์กับ fact_check_item / submit_approval_item)
// ============================================================================

import 'package:intl/intl.dart';

/// module — ดึงจาก json['module']
class VerifyAttachmentModule {
  final String code;
  final String nameTh;
  const VerifyAttachmentModule({this.code = '', this.nameTh = ''});

  factory VerifyAttachmentModule.fromJson(Map<String, dynamic> json) =>
      VerifyAttachmentModule(
        code: (json['code'] ?? '').toString(),
        nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      );
}

/// customer — ดึงจาก json['customer'] (nullable ใน v2)
class VerifyAttachmentCustomer {
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

  const VerifyAttachmentCustomer({
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

  factory VerifyAttachmentCustomer.fromJson(Map<String, dynamic> json) =>
      VerifyAttachmentCustomer(
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
class VerifyAttachmentDetails {
  final String subzone;
  final String zn;
  final String ln;
  const VerifyAttachmentDetails({
    this.subzone = '',
    this.zn = '',
    this.ln = '',
  });
  factory VerifyAttachmentDetails.fromJson(Map<String, dynamic> json) =>
      VerifyAttachmentDetails(
        subzone: (json['subzone'] ?? '').toString(),
        zn: (json['zn'] ?? '').toString(),
        ln: (json['ln'] ?? '').toString(),
      );
}

/// 1 แถวรายการ "ตรวจสอบหลักฐาน" — list v2
class VerifyAttachmentItem {
  final String uuid;
  final VerifyAttachmentModule module;
  final VerifyAttachmentCustomer? customer; // nullable ใน v2
  final VerifyAttachmentDetails details;
  final String status;
  final String? createdAt;
  final String? submittedAt;
  final bool reviewAttachmentsAllDone;
  final int attachmentsTotal;
  final int attachmentsPending;
  final int attachmentsApproved;
  final String? oldestPendingAt;

  const VerifyAttachmentItem({
    this.uuid = '',
    this.module = const VerifyAttachmentModule(),
    this.customer,
    this.details = const VerifyAttachmentDetails(),
    this.status = '',
    this.createdAt,
    this.submittedAt,
    this.reviewAttachmentsAllDone = false,
    this.attachmentsTotal = 0,
    this.attachmentsPending = 0,
    this.attachmentsApproved = 0,
    this.oldestPendingAt,
  });

  factory VerifyAttachmentItem.fromJson(Map<String, dynamic> json) {
    final moduleJson = json['module'];
    final customerJson = json['customer'];
    final detailsJson = json['details'];

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return VerifyAttachmentItem(
      uuid: (json['uuid'] ?? '').toString(),
      module: moduleJson is Map
          ? VerifyAttachmentModule.fromJson(
              Map<String, dynamic>.from(moduleJson))
          : const VerifyAttachmentModule(),
      customer: customerJson is Map
          ? VerifyAttachmentCustomer.fromJson(
              Map<String, dynamic>.from(customerJson))
          : null,
      details: detailsJson is Map
          ? VerifyAttachmentDetails.fromJson(
              Map<String, dynamic>.from(detailsJson))
          : const VerifyAttachmentDetails(),
      status: (json['status'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
      submittedAt: json['submitted_at']?.toString(),
      reviewAttachmentsAllDone: json['review_attachments_all_done'] == true,
      attachmentsTotal: toInt(json['attachments_total']),
      attachmentsPending: toInt(json['attachments_pending']),
      attachmentsApproved: toInt(json['attachments_approved']),
      oldestPendingAt: json['oldest_pending_at']?.toString(),
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
class VerifyAttachmentsListResult {
  final List<VerifyAttachmentItem> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksFirst;
  final String? linksLast;
  final String? linksPrev;
  final String? linksNext;
  const VerifyAttachmentsListResult({
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

  static const empty = VerifyAttachmentsListResult(
    items: [],
    currentPage: 0,
    lastPage: 0,
    perPage: 0,
    total: 0,
  );
}

/// Format helpers
String formatVerifyAttachmentDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('dd-MM-yyyy HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}