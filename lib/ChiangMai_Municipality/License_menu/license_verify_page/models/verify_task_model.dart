// ============================================================================
// verify_task_model.dart
// ============================================================================
// Model — แมปรายการ "คำขอต่อสัญญา" (ตรวจสอบ) จาก v2 endpoint
// GET /api/v2/admin/requests/tasks/inspections
//
// Laravel paginated response shape:
//   data[]: { uuid, module{}, customer{}, details{}, status, created_at,
//             submitted_at, inspection_passed, inspection_review }
//   meta{ current_page, last_page, per_page, total }
//   links{ first, last, prev, next }
//
// Fields are the same nested shape as AttachTask but the inspection-specific
// counters differ:
//   - ไม่มี review_attachments_all_done / attachments_*
//   - มี inspection_passed + inspection_review
// ============================================================================

import '../../../unity/license_status_labels.dart';

class VerifyTaskModule {
  final String code;
  final String nameTh;
  const VerifyTaskModule({this.code = '', this.nameTh = ''});
  factory VerifyTaskModule.fromJson(Map<String, dynamic> json) =>
      VerifyTaskModule(
        code: (json['code'] ?? '').toString(),
        nameTh: (json['name_th'] ?? '').toString(),
      );
}

class VerifyTaskCustomer {
  final String uuid;
  final String custno;
  final String scname;
  final String cname;
  final String tel;
  final String tax;
  final String addr1;
  const VerifyTaskCustomer({
    this.uuid = '',
    this.custno = '',
    this.scname = '',
    this.cname = '',
    this.tel = '',
    this.tax = '',
    this.addr1 = '',
  });
  factory VerifyTaskCustomer.fromJson(Map<String, dynamic> json) =>
      VerifyTaskCustomer(
        uuid: (json['uuid'] ?? '').toString(),
        custno: (json['custno'] ?? '').toString(),
        scname: (json['scname'] ?? '').toString(),
        cname: (json['cname'] ?? json['attn'] ?? '').toString(),
        tel: (json['tel'] ?? '').toString(),
        tax: (json['tax'] ?? '').toString(),
        addr1: (json['addr_1'] ?? json['addr1'] ?? '').toString(),
      );
}

class VerifyTaskDetails {
  final String subzone;
  final String zn;
  final String ln;
  const VerifyTaskDetails({this.subzone = '', this.zn = '', this.ln = ''});
  factory VerifyTaskDetails.fromJson(Map<String, dynamic> json) =>
      VerifyTaskDetails(
        subzone: (json['subzone'] ?? '').toString(),
        zn: (json['zn'] ?? '').toString(),
        ln: (json['ln'] ?? '').toString(),
      );
}

class VerifyTask {
  final String uuid;
  final VerifyTaskModule module;
  final VerifyTaskCustomer? customer;
  final VerifyTaskDetails details;
  final String status;
  final String createdAt;
  final String submittedAt;
  final bool inspectionPassed;
  final dynamic inspectionReview;

  const VerifyTask({
    this.uuid = '',
    this.module = const VerifyTaskModule(),
    this.customer,
    this.details = const VerifyTaskDetails(),
    this.status = '',
    this.createdAt = '',
    this.submittedAt = '',
    this.inspectionPassed = false,
    this.inspectionReview,
  });

  factory VerifyTask.fromJson(Map<String, dynamic> json) {
    VerifyTaskModule m = const VerifyTaskModule();
    if (json['module'] is Map) {
      m = VerifyTaskModule.fromJson(
          Map<String, dynamic>.from(json['module'] as Map));
    }
    VerifyTaskCustomer? c;
    if (json['customer'] is Map) {
      c = VerifyTaskCustomer.fromJson(
          Map<String, dynamic>.from(json['customer'] as Map));
    }
    VerifyTaskDetails d = const VerifyTaskDetails();
    if (json['details'] is Map) {
      d = VerifyTaskDetails.fromJson(
          Map<String, dynamic>.from(json['details'] as Map));
    }
    return VerifyTask(
      uuid: (json['uuid'] ?? '').toString(),
      module: m,
      customer: c,
      details: d,
      status: (json['status'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      submittedAt: (json['submitted_at'] ?? '').toString(),
      inspectionPassed: json['inspection_passed'] == true,
      inspectionReview: json['inspection_review'],
    );
  }

  /// Thai label per status — ดึงจาก central mapper
  String get statusLabel => LicenseStatusLabels.th(status);
}

class VerifyTasksResponse {
  final List<VerifyTask> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksFirst, linksLast, linksPrev, linksNext;

  const VerifyTasksResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.linksFirst,
    this.linksLast,
    this.linksPrev,
    this.linksNext,
  });
}
