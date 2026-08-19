// ============================================================================
// license_payment_detail_model.dart
// ============================================================================
// Model — แมประรายการรับชำระ + ใบเสร็จ
// map ตาม JSON จาก Postman "Payment v2 Receipts"
// ============================================================================

import 'package:intl/intl.dart';

/// แถวค่าใช้จ่าย (addons / debt lines) ในรายการรับชำระ
class PaymentAddon {
  final String label;
  final String value;
  final double? amount;

  const PaymentAddon({
    required this.label,
    required this.value,
    this.amount,
  });

  factory PaymentAddon.fromJson(Map<String, dynamic> json) {
    final amount = double.tryParse((json['amount'] ?? json['total'] ?? '0').toString());
    return PaymentAddon(
      label: (json['expname'] ?? json['label'] ?? json['name'] ?? '').toString(),
      value: (json['value'] ?? json['note'] ?? '').toString(),
      amount: amount,
    );
  }
}

/// รายละเอียดการรับชำระ (Step 1 — ตรวจสอบ)
class PaymentDetail {
  final String uuid;
  final String paymentNo;
  final String paymentSystem; // internal / external
  final String payType; // fee / fine
  final String status; // draft / paid
  final String methodName;
  final String payerName;
  final String clientTel;
  final String clientTax;
  final String clientAddr;
  final double amount;
  final double? amountReceived;
  final String? paidAt;
  final String? createdAt;
  final String debtLineUuid; // จาก debt_line_uuid (รายการชำระ)
  final String debtUuid; // จาก debt_uuid
  final String? paymentMethodId; // จาก payment_method_id
  final List<PaymentAddon> addons;

  const PaymentDetail({
    this.uuid = '',
    this.paymentNo = '',
    this.paymentSystem = '',
    this.payType = '',
    this.status = '',
    this.methodName = '',
    this.payerName = '',
    this.clientTel = '',
    this.clientTax = '',
    this.clientAddr = '',
    this.amount = 0,
    this.amountReceived,
    this.paidAt,
    this.createdAt,
    this.debtLineUuid = '',
    this.debtUuid = '',
    this.paymentMethodId,
    this.addons = const [],
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    final addonsRaw = json['addons'];
    final addons = addonsRaw is List
        ? addonsRaw
            .whereType<Map<String, dynamic>>()
            .map(PaymentAddon.fromJson)
            .toList()
        : <PaymentAddon>[];

    return PaymentDetail(
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
      payerName: (json['payer_name'] ?? json['customer_name'] ?? json['name'] ?? '')
          .toString(),
      clientTel: (json['client_tel'] ?? json['tel'] ?? '').toString(),
      clientTax: (json['client_tax'] ?? json['tax'] ?? '').toString(),
      clientAddr: (json['client_addr'] ?? json['addr'] ?? json['addr1'] ?? '')
          .toString(),
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      amountReceived:
          double.tryParse((json['amount_received'] ?? '').toString()),
      paidAt: (json['paid_at'] ?? json['paidAt'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      debtLineUuid: (json['debt_line_uuid'] ?? '').toString(),
      debtUuid: (json['debt_uuid'] ?? '').toString(),
      paymentMethodId: (json['payment_method_id'] ?? '').toString(),
      addons: addons,
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';

  /// UI compatibility: แสดง status เป็น label (TH/EN)
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'ชำระแล้ว';
      case 'draft':
        return 'รอชำระ';
      case 'documents_submitted':
        return 'ยื่นเอกสารแล้ว';
      case 'under_review':
        return 'กำลังตรวจสอบ';
      case 'in_progress':
        return 'กำลังดำเนินการ';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'pending':
        return 'รอดำเนินการ';
      case 'waiting_payment_info':
        return 'รอข้อมูลการชำระ';
      case 'payment_submitted':
        return 'ส่งหลักฐานชำระแล้ว';
      case 'cancelled':
      case 'canceled':
        return 'ยกเลิก';
      case 'rejected':
        return 'ปฏิเสธ';
      default:
        return status.isEmpty ? '-' : status;
    }
  }

  /// UI compatibility: ข้อมูล contract ที่ UI คาดหวัง
  NewRequest? get newRequest => NewRequest(
    leaseNumber: paymentNo,
    subzone: paymentSystem,
    zn: payType,
    ln: methodName,
    ldate: paidAt,
  );

  /// UI compatibility: ข้อมูลลูกค้า/ผู้ชำระ
  Client? get client => Client(cname: payerName, tel: clientTel, tax: clientTax);
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
  const Client({this.cname = '-', this.tel = '', this.tax = ''});
}

/// ใบเสร็จ / สรุปการรับชำระ (Step 2)
class PaymentReceipt {
  final String receiptNo;
  final String bookNo;
  final String bookDate;
  final String officerName;
  final String signatureUuid;
  final PaymentDetail payment;

  const PaymentReceipt({
    this.receiptNo = '',
    this.bookNo = '',
    this.bookDate = '',
    this.officerName = '',
    this.signatureUuid = '',
    this.payment = const PaymentDetail(),
  });

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
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
        ? PaymentDetail.fromJson(paymentRaw as Map<String, dynamic>)
        : const PaymentDetail();

    return PaymentReceipt(
      receiptNo: (json['receipt_no'] ?? json['receiptNo'] ?? '').toString(),
      bookNo: (json['book_no'] ?? json['bookNo'] ?? '').toString(),
      bookDate: (json['book_date'] ?? json['bookDate'] ?? '').toString(),
      officerName: officerName,
      signatureUuid: signatureUuid,
      payment: payment,
    );
  }

  factory PaymentReceipt.empty() => const PaymentReceipt();
}

/// รายการชำระทั้งหมดของคำขอ (GET /api/v2/requests/{uuid}/payments)
/// ตอบกลับเป็น paginated list: { "data": [...], "links": {...}, "meta": {...} }
class RequestPaymentsResponse {
  final List<PaymentDetail> data;
  final int total;
  final int currentPage;
  final int lastPage;

  const RequestPaymentsResponse({
    this.data = const [],
    this.total = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  factory RequestPaymentsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    final data = list is List
        ? list
            .whereType<Map<String, dynamic>>()
            .map(PaymentDetail.fromJson)
            .toList()
        : <PaymentDetail>[];

    int toInt(dynamic v, [int d = 0]) =>
        v is int ? v : int.tryParse('$v') ?? d;

    final meta = json['meta'];
    final total = meta is Map ? toInt(meta['total']) : data.length;
    final currentPage = meta is Map ? toInt(meta['current_page'], 1) : 1;
    final lastPage = meta is Map ? toInt(meta['last_page'], 1) : 1;

    return RequestPaymentsResponse(
      data: data,
      total: total,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  bool get isEmpty => data.isEmpty;
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
