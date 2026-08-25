// ============================================================================
// payment_task_model.dart
// ============================================================================
// Model — แมปรายการ "คำขอต่อสัญญา" จาก v2 endpoint
//   GET /api/v2/admin/requests/tasks/payments
//
// Response shape: Laravel paginated envelope {data[], meta{}, links{}}.
// Each row has nested `module` / `customer` / `details` objects.
//
// status mapping: ใช้ LicenseStatusLabels (central) — ดู
//   lib/ChiangMai_Municipality/unity/license_status_labels.dart
// ============================================================================

import '../../../unity/license_status_labels.dart';

class PaymentTaskModule {
  final String code;
  final String nameTh;
  const PaymentTaskModule({this.code = '', this.nameTh = ''});
  factory PaymentTaskModule.fromJson(Map<String, dynamic> json) =>
      PaymentTaskModule(
        code: (json['code'] ?? '').toString(),
        nameTh: (json['name_th'] ?? '').toString(),
      );
}

class PaymentTaskCustomer {
  final String uuid;
  final String custno;
  final String scname;
  final String cname;
  final String tel;
  final String tax;
  const PaymentTaskCustomer({
    this.uuid = '',
    this.custno = '',
    this.scname = '',
    this.cname = '',
    this.tel = '',
    this.tax = '',
  });
  factory PaymentTaskCustomer.fromJson(Map<String, dynamic> json) =>
      PaymentTaskCustomer(
        uuid: (json['uuid'] ?? '').toString(),
        custno: (json['custno'] ?? '').toString(),
        scname: (json['scname'] ?? '').toString(),
        cname: (json['cname'] ?? json['attn'] ?? '').toString(),
        tel: (json['tel'] ?? '').toString(),
        tax: (json['tax'] ?? '').toString(),
      );
}

class PaymentTaskDetails {
  final String subzone;
  final String zn;
  final String ln;
  const PaymentTaskDetails({this.subzone = '', this.zn = '', this.ln = ''});
  factory PaymentTaskDetails.fromJson(Map<String, dynamic> json) =>
      PaymentTaskDetails(
        subzone: (json['subzone'] ?? '').toString(),
        zn: (json['zn'] ?? '').toString(),
        ln: (json['ln'] ?? '').toString(),
      );
}

class PaymentTask {
  final String uuid;
  final PaymentTaskModule module;
  final PaymentTaskCustomer customer;
  final PaymentTaskDetails details;
  final String status;
  final String feeAmount;
  final String createdAt;
  final String submittedAt;
  final bool paymentAllDone;
  final bool feeRequired;
  final int paymentsTotal;
  final int paymentsPaid;
  final int paymentsPending;

  const PaymentTask({
    this.uuid = '',
    this.module = const PaymentTaskModule(),
    this.customer = const PaymentTaskCustomer(),
    this.details = const PaymentTaskDetails(),
    this.status = '',
    this.feeAmount = '0.00',
    this.createdAt = '',
    this.submittedAt = '',
    this.paymentAllDone = false,
    this.feeRequired = false,
    this.paymentsTotal = 0,
    this.paymentsPaid = 0,
    this.paymentsPending = 0,
  });

  factory PaymentTask.fromJson(Map<String, dynamic> json) {
    PaymentTaskModule m = const PaymentTaskModule();
    if (json['module'] is Map) {
      m = PaymentTaskModule.fromJson(
          Map<String, dynamic>.from(json['module'] as Map));
    }
    PaymentTaskCustomer c = const PaymentTaskCustomer();
    if (json['customer'] is Map) {
      c = PaymentTaskCustomer.fromJson(
          Map<String, dynamic>.from(json['customer'] as Map));
    }
    PaymentTaskDetails d = const PaymentTaskDetails();
    if (json['details'] is Map) {
      d = PaymentTaskDetails.fromJson(
          Map<String, dynamic>.from(json['details'] as Map));
    }
    return PaymentTask(
      uuid: (json['uuid'] ?? '').toString(),
      module: m,
      customer: c,
      details: d,
      status: (json['status'] ?? '').toString(),
      feeAmount: (json['fee_amount'] ?? '0.00').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      submittedAt: (json['submitted_at'] ?? '').toString(),
      paymentAllDone: json['payment_all_done'] == true,
      feeRequired: json['fee_required'] == true,
      paymentsTotal: int.tryParse('${json['payments_total'] ?? 0}') ?? 0,
      paymentsPaid: int.tryParse('${json['payments_paid'] ?? 0}') ?? 0,
      paymentsPending: int.tryParse('${json['payments_pending'] ?? 0}') ?? 0,
    );
  }

  /// แปล status (API) เป็นภาษาไทยสำหรับแสดงใน UI
  /// — ใช้ central mapper (LicenseStatusLabels.th) เพื่อให้ทุกเมนูตรงกัน
  String get statusLabel {
    return LicenseStatusLabels.th(status);
  }
}

/// Laravel paginated envelope (data + meta + links)
class PaymentTasksResponse {
  final List<PaymentTask> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? linksFirst;
  final String? linksLast;
  final String? linksPrev;
  final String? linksNext;

  const PaymentTasksResponse({
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