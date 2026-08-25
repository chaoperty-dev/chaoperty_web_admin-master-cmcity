// ============================================================================
// license_payment_detail_model.dart
// ============================================================================
// Model — แมประรายการรับชำระ + ใบเสร็จ
// map ตาม JSON จาก Postman "Payment v2 Receipts"
//
// status mapping: ใช้ LicenseStatusLabels (central) — ดู
//   lib/ChiangMai_Municipality/unity/license_status_labels.dart
// ============================================================================

import 'package:intl/intl.dart';

import '../../../unity/license_status_labels.dart';
import 'license_payment_attachment.dart';

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
    final amount =
        double.tryParse((json['amount'] ?? json['total'] ?? '0').toString());
    return PaymentAddon(
      label:
          (json['expname'] ?? json['label'] ?? json['name'] ?? '').toString(),
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
  final PaymentAttachment?
      latestAttachment; // จาก latest_attachment (ใน response)

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
    this.latestAttachment,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    final addonsRaw = json['addons'];
    final addons = addonsRaw is List
        ? addonsRaw
            .whereType<Map<String, dynamic>>()
            .map(PaymentAddon.fromJson)
            .toList()
        : <PaymentAddon>[];

    final latestRaw = json['latest_attachment'];
    final hasLatest = latestRaw is Map && latestRaw.isNotEmpty;
    final latestAttachment = hasLatest
        ? PaymentAttachment.fromJson(
            Map<String, dynamic>.from(latestRaw as Map))
        : null;

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
      payerName:
          (json['payer_name'] ?? json['customer_name'] ?? json['name'] ?? '')
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
      latestAttachment: latestAttachment,
    );
  }

  bool get isPaid => status.toLowerCase() == 'paid';

  /// UI compatibility: แสดง status เป็น label (TH/EN)
  /// — ใช้ central mapper เพื่อให้ทุกเมนูตรงกัน
  String get statusLabel {
    return LicenseStatusLabels.th(status);
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
  Client? get client =>
      Client(cname: payerName, tel: clientTel, tax: clientTax);
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
/// Nested: { data: { receipt, payment, method, entries, totals, vendor, location, officer, signature } }
class PaymentReceipt {
  final ReceiptInfo receipt;
  final PaymentDetail payment;
  final ReceiptMethod? method;
  final ReceiptEntries entries;
  final ReceiptVendor? vendor;
  final ReceiptLocation? location;
  final ReceiptOfficer? officer;

  const PaymentReceipt({
    this.receipt = const ReceiptInfo(),
    this.payment = const PaymentDetail(),
    this.method,
    this.entries = const ReceiptEntries(),
    this.vendor,
    this.location,
    this.officer,
  });

  // legacy convenience getters (UI เก่าอาจเรียกใช้)
  String get receiptNo => receipt.receiptNo;
  String get bookNo => receipt.bookNo;
  String get bookDate => receipt.date;
  String get officerName => officer?.fullName ?? '';
  String get signatureUuid => officer?.signature?.uuid ?? '';

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    final src = (json['data'] is Map) ? json['data'] as Map : json;

    final receiptRaw = src['receipt'];
    final receipt = receiptRaw is Map
        ? ReceiptInfo.fromJson(Map<String, dynamic>.from(receiptRaw as Map))
        : const ReceiptInfo();

    final paymentRaw = src['payment'];
    final payment = paymentRaw is Map
        ? PaymentDetail.fromJson(paymentRaw as Map<String, dynamic>)
        : const PaymentDetail();

    final methodRaw = src['method'];
    final method = methodRaw is Map
        ? ReceiptMethod.fromJson(Map<String, dynamic>.from(methodRaw as Map))
        : null;

    final entriesRaw = src['entries'];
    final entries = entriesRaw is Map
        ? ReceiptEntries.fromJson(Map<String, dynamic>.from(entriesRaw as Map))
        : const ReceiptEntries();

    final vendorRaw = src['vendor'];
    final vendor = vendorRaw is Map
        ? ReceiptVendor.fromJson(Map<String, dynamic>.from(vendorRaw as Map))
        : null;

    final locationRaw = src['location'];
    final location = locationRaw is Map
        ? ReceiptLocation.fromJson(
            Map<String, dynamic>.from(locationRaw as Map))
        : null;

    final officerRaw = src['officer'];
    final officer = officerRaw is Map
        ? ReceiptOfficer.fromJson(Map<String, dynamic>.from(officerRaw as Map))
        : null;

    return PaymentReceipt(
      receipt: receipt,
      payment: payment,
      method: method,
      entries: entries,
      vendor: vendor,
      location: location,
      officer: officer,
    );
  }

  factory PaymentReceipt.empty() => const PaymentReceipt();
}

/// ข้อมูลใบเสร็จ (block "receipt")
class ReceiptInfo {
  final String receiptNo;
  final String bookNo;
  final String date;
  final String payType;
  final String payTypeLabel;
  final String paymentSystem;

  const ReceiptInfo({
    this.receiptNo = '',
    this.bookNo = '',
    this.date = '',
    this.payType = '',
    this.payTypeLabel = '',
    this.paymentSystem = '',
  });

  factory ReceiptInfo.fromJson(Map<String, dynamic> json) {
    return ReceiptInfo(
      receiptNo: (json['receipt_no'] ?? json['receiptNo'] ?? '').toString(),
      bookNo: (json['book_no'] ?? json['bookNo'] ?? '').toString(),
      date: (json['date'] ?? json['book_date'] ?? '').toString(),
      payType: (json['pay_type'] ?? json['payType'] ?? '').toString(),
      payTypeLabel:
          (json['pay_type_label'] ?? json['payTypeLabel'] ?? '').toString(),
      paymentSystem:
          (json['payment_system'] ?? json['paymentSystem'] ?? '').toString(),
    );
  }
}

/// ช่องทางชำระเงิน (block "method")
class ReceiptMethod {
  final int id;
  final String code;
  final String nameTh;

  const ReceiptMethod({
    this.id = 0,
    this.code = '',
    this.nameTh = '',
  });

  factory ReceiptMethod.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    return ReceiptMethod(
      id: toInt(json['id']),
      code: (json['code'] ?? '').toString(),
      nameTh:
          (json['name_th'] ?? json['nameTh'] ?? json['name'] ?? '').toString(),
    );
  }
}

/// รายการรายได้ (entries.fee + entries.fine + totals)
class ReceiptEntries {
  final List<ReceiptEntryItem> fee;
  final List<ReceiptEntryItem> fine;
  final ReceiptTotals totals;

  const ReceiptEntries({
    this.fee = const [],
    this.fine = const [],
    this.totals = const ReceiptTotals(),
  });

  factory ReceiptEntries.fromJson(Map<String, dynamic> json) {
    List<ReceiptEntryItem> parseList(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) =>
              ReceiptEntryItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    final totalsRaw = json['totals'];
    final totals = totalsRaw is Map
        ? ReceiptTotals.fromJson(Map<String, dynamic>.from(totalsRaw as Map))
        : const ReceiptTotals();

    return ReceiptEntries(
      fee: parseList(json['fee']),
      fine: parseList(json['fine']),
      totals: totals,
    );
  }
}

class ReceiptEntryItem {
  final String uuid;
  final String ser;
  final String name;
  final String qty;
  final String unit;
  final String amt;
  final String vat;
  final String amountInclVat;
  final String sdate;
  final String ldate;
  final double amount;
  final String? etype;
  final String? dtype;

  const ReceiptEntryItem({
    this.uuid = '',
    this.ser = '',
    this.name = '',
    this.qty = '',
    this.unit = '',
    this.amt = '',
    this.vat = '',
    this.amountInclVat = '',
    this.sdate = '',
    this.ldate = '',
    this.amount = 0,
    this.etype,
    this.dtype,
  });

  factory ReceiptEntryItem.fromJson(Map<String, dynamic> json) {
    return ReceiptEntryItem(
      uuid: (json['uuid'] ?? '').toString(),
      ser: (json['ser'] ?? '').toString(),
      name: (json['name'] ?? json['expname'] ?? '').toString(),
      qty: (json['qty'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      amt: (json['amt'] ?? '').toString(),
      vat: (json['vat'] ?? '').toString(),
      amountInclVat: (json['amount_incl_vat'] ?? '').toString(),
      sdate: (json['sdate'] ?? '').toString(),
      ldate: (json['ldate'] ?? '').toString(),
      amount: double.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      etype: json['etype']?.toString(),
      dtype: json['dtype']?.toString(),
    );
  }
}

class ReceiptTotals {
  final double fee;
  final double fine;
  final double grand;

  const ReceiptTotals({this.fee = 0, this.fine = 0, this.grand = 0});

  factory ReceiptTotals.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return ReceiptTotals(
      fee: toD(json['fee']),
      fine: toD(json['fine']),
      grand: toD(json['grand']),
    );
  }
}

/// ข้อมูลผู้ชำระ (vendor)
class ReceiptVendor {
  final String custno;
  final String taxno;
  final String tax;
  final String scname;
  final String cname;
  final String branch;
  final String addr1;
  final String addr2;
  final String zip;
  final String tel;
  final String email;
  final String snapshotAt;

  const ReceiptVendor({
    this.custno = '',
    this.taxno = '',
    this.tax = '',
    this.scname = '',
    this.cname = '',
    this.branch = '',
    this.addr1 = '',
    this.addr2 = '',
    this.zip = '',
    this.tel = '',
    this.email = '',
    this.snapshotAt = '',
  });

  factory ReceiptVendor.fromJson(Map<String, dynamic> json) {
    return ReceiptVendor(
      custno: (json['custno'] ?? '').toString(),
      taxno: (json['taxno'] ?? '').toString(),
      tax: (json['tax'] ?? '').toString(),
      scname: (json['scname'] ?? '').toString(),
      cname: (json['cname'] ?? '').toString(),
      branch: (json['branch'] ?? '').toString(),
      addr1: (json['addr_1'] ?? json['addr1'] ?? '').toString(),
      addr2: (json['addr_2'] ?? json['addr2'] ?? '').toString(),
      zip: (json['zip'] ?? '').toString(),
      tel: (json['tel'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      snapshotAt:
          (json['snapshot_at'] ?? json['snapshotAt'] ?? '').toString(),
    );
  }
}

/// ข้อมูลสถานที่ (location)
class ReceiptLocation {
  final int zser;
  final String zn;
  final int subzoneser;
  final String subzone;
  final int aser;
  final String ln;
  final int propertyId;
  final String qty;
  final String leaseNumber;
  final String sdate;
  final String ldate;

  const ReceiptLocation({
    this.zser = 0,
    this.zn = '',
    this.subzoneser = 0,
    this.subzone = '',
    this.aser = 0,
    this.ln = '',
    this.propertyId = 0,
    this.qty = '',
    this.leaseNumber = '',
    this.sdate = '',
    this.ldate = '',
  });

  factory ReceiptLocation.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    return ReceiptLocation(
      zser: toInt(json['zser']),
      zn: (json['zn'] ?? '').toString(),
      subzoneser: toInt(json['subzoneser']),
      subzone: (json['subzone'] ?? '').toString(),
      aser: toInt(json['aser']),
      ln: (json['ln'] ?? '').toString(),
      propertyId: toInt(json['property_id']),
      qty: (json['qty'] ?? '').toString(),
      leaseNumber:
          (json['lease_number'] ?? json['leaseNumber'] ?? '').toString(),
      sdate: (json['sdate'] ?? '').toString(),
      ldate: (json['ldate'] ?? '').toString(),
    );
  }
}

/// เจ้าหน้าที่ผู้รับเงิน (officer + position + signature)
class ReceiptOfficer {
  final String userUuid;
  final String fullName;
  final ReceiptPosition? position;
  final ReceiptSignature? signature;

  const ReceiptOfficer({
    this.userUuid = '',
    this.fullName = '',
    this.position,
    this.signature,
  });

  factory ReceiptOfficer.fromJson(Map<String, dynamic> json) {
    final pos = json['position'];
    final sig = json['signature'];
    return ReceiptOfficer(
      userUuid: (json['user_uuid'] ?? json['userUuid'] ?? '').toString(),
      fullName:
          (json['full_name'] ?? json['fullName'] ?? json['name'] ?? '')
              .toString(),
      position: pos is Map
          ? ReceiptPosition.fromJson(Map<String, dynamic>.from(pos as Map))
          : null,
      signature: sig is Map
          ? ReceiptSignature.fromJson(Map<String, dynamic>.from(sig as Map))
          : null,
    );
  }
}

class ReceiptPosition {
  final String uuid;
  final String code;
  final String nameTh;
  final String? level;

  const ReceiptPosition({
    this.uuid = '',
    this.code = '',
    this.nameTh = '',
    this.level,
  });

  factory ReceiptPosition.fromJson(Map<String, dynamic> json) {
    return ReceiptPosition(
      uuid: (json['uuid'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      nameTh: (json['name_th'] ?? json['nameTh'] ?? '').toString(),
      level: json['level']?.toString(),
    );
  }
}

class ReceiptSignature {
  final String uuid;
  final String previewUrl;
  final int version;

  const ReceiptSignature({
    this.uuid = '',
    this.previewUrl = '',
    this.version = 0,
  });

  factory ReceiptSignature.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    return ReceiptSignature(
      uuid: (json['uuid'] ?? '').toString(),
      previewUrl: (json['preview_url'] ?? json['previewUrl'] ?? '').toString(),
      version: toInt(json['version']),
    );
  }
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

    int toInt(dynamic v, [int d = 0]) => v is int ? v : int.tryParse('$v') ?? d;

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
String formatMoney(double v) => NumberFormat('#,##0.00', 'en_US').format(v);

String formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('dd-MM-yyyy HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}
