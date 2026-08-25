// ============================================================================
// attach_task_model.dart
// ============================================================================
// Model — แมปรายการ "คำขอต่อสัญญา" (แนบหลักฐาน) จาก v2 endpoint
// GET /api/v2/admin/requests/tasks/attachments
//
// Laravel paginated response shape:
//   data[]: { uuid, module{}, customer{}, details{}, status, created_at,
//             submitted_at, review_attachments_all_done,
//             attachments_total, attachments_pending, attachments_approved,
//             oldest_pending_at }
//   meta{ current_page, last_page, per_page, total }
//   links{ first, last, prev, next }
//
// Fields are the same nested shape as PaymentTask but the counters differ:
//   - ไม่มี fee_amount / payments_*
//   - มี review_attachments_all_done + attachments_total/pending/approved
// ============================================================================

import '../../../unity/license_status_labels.dart';

class AttachTaskModule {
  final String code;
  final String nameTh;
  const AttachTaskModule({this.code = '', this.nameTh = ''});
  factory AttachTaskModule.fromJson(Map<String, dynamic> json) =>
      AttachTaskModule(
        code: (json['code'] ?? '').toString(),
        nameTh: (json['name_th'] ?? '').toString(),
      );
}

class AttachTaskCustomer {
  final String uuid;
  final String custno;
  final String scname;
  final String cname;
  final String tel;
  final String tax;
  final String addr1;
  const AttachTaskCustomer({
    this.uuid = '',
    this.custno = '',
    this.scname = '',
    this.cname = '',
    this.tel = '',
    this.tax = '',
    this.addr1 = '',
  });
  factory AttachTaskCustomer.fromJson(Map<String, dynamic> json) =>
      AttachTaskCustomer(
        uuid: (json['uuid'] ?? '').toString(),
        custno: (json['custno'] ?? '').toString(),
        scname: (json['scname'] ?? '').toString(),
        cname: (json['cname'] ?? json['attn'] ?? '').toString(),
        tel: (json['tel'] ?? '').toString(),
        tax: (json['tax'] ?? '').toString(),
        addr1: (json['addr_1'] ?? json['addr1'] ?? '').toString(),
      );
}

class AttachTaskDetails {
  final String subzone;
  final String zn;
  final String ln;
  const AttachTaskDetails({this.subzone = '', this.zn = '', this.ln = ''});
  factory AttachTaskDetails.fromJson(Map<String, dynamic> json) =>
      AttachTaskDetails(
        subzone: (json['subzone'] ?? '').toString(),
        zn: (json['zn'] ?? '').toString(),
        ln: (json['ln'] ?? '').toString(),
      );
}

class AttachTask {
  final String uuid;
  final AttachTaskModule module;
  final AttachTaskCustomer customer;
  final AttachTaskDetails details;
  final String status;
  final String createdAt;
  final String submittedAt;
  final bool reviewAttachmentsAllDone;
  final int attachmentsTotal;
  final int attachmentsPending;
  final int attachmentsApproved;
  final String? oldestPendingAt;

  const AttachTask({
    this.uuid = '',
    this.module = const AttachTaskModule(),
    this.customer = const AttachTaskCustomer(),
    this.details = const AttachTaskDetails(),
    this.status = '',
    this.createdAt = '',
    this.submittedAt = '',
    this.reviewAttachmentsAllDone = false,
    this.attachmentsTotal = 0,
    this.attachmentsPending = 0,
    this.attachmentsApproved = 0,
    this.oldestPendingAt,
  });

  factory AttachTask.fromJson(Map<String, dynamic> json) {
    AttachTaskModule m = const AttachTaskModule();
    if (json['module'] is Map) {
      m = AttachTaskModule.fromJson(
          Map<String, dynamic>.from(json['module'] as Map));
    }
    AttachTaskCustomer c = const AttachTaskCustomer();
    if (json['customer'] is Map) {
      c = AttachTaskCustomer.fromJson(
          Map<String, dynamic>.from(json['customer'] as Map));
    }
    AttachTaskDetails d = const AttachTaskDetails();
    if (json['details'] is Map) {
      d = AttachTaskDetails.fromJson(
          Map<String, dynamic>.from(json['details'] as Map));
    }
    return AttachTask(
      uuid: (json['uuid'] ?? '').toString(),
      module: m,
      customer: c,
      details: d,
      status: (json['status'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      submittedAt: (json['submitted_at'] ?? '').toString(),
      reviewAttachmentsAllDone: json['review_attachments_all_done'] == true,
      attachmentsTotal:
          int.tryParse('${json['attachments_total'] ?? 0}') ?? 0,
      attachmentsPending:
          int.tryParse('${json['attachments_pending'] ?? 0}') ?? 0,
      attachmentsApproved:
          int.tryParse('${json['attachments_approved'] ?? 0}') ?? 0,
      oldestPendingAt: (json['oldest_pending_at'] ?? '').toString().isEmpty
          ? null
          : (json['oldest_pending_at'] ?? '').toString(),
    );
  }

  /// Thai label per English status — delegate to central mapper
  String get statusLabel => LicenseStatusLabels.th(status);
}

class AttachTasksResponse {
  final List<AttachTask> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksFirst, linksLast, linksPrev, linksNext;

  const AttachTasksResponse({
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
