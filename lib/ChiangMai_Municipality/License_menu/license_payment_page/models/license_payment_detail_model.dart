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
  final double amount;
  final double? amountReceived;
  final String? paidAt;
  final String? createdAt;
  final List<PaymentAddon> addons;

  const PaymentDetail({
    this.uuid = '',
    this.paymentNo = '',
    this.paymentSystem = '',
    this.payType = '',
    this.status = '',
    this.methodName = '',
    this.payerName = '',
    this.amount = 0,
    this.amountReceived,
    this.paidAt,
    this.createdAt,
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
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      amountReceived:
          double.tryParse((json['amount_received'] ?? '').toString()),
      paidAt: (json['paid_at'] ?? json['paidAt'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
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
      case 'cancelled':
      case 'canceled':
        return 'ยกเลิก';
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
  Client? get client => Client(cname: payerName, tel: '');
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
  const Client({this.cname = '-', this.tel = ''});
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
