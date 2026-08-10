import 'dart:convert';

class PaymentIntentsResponse {
  final String? message;
  final List<PaymentIntent> data;
  final Meta? meta;

  PaymentIntentsResponse({
    this.message,
    required this.data,
    this.meta,
  });

  factory PaymentIntentsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentsResponse(
      message: json['message'] as String?,
      data: (json['data'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => PaymentIntent.fromJson(e))
          .toList(),
      meta: json['meta'] is Map<String, dynamic>
          ? Meta.fromJson(json['meta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        if (meta != null) 'meta': meta!.toJson(),
      };

  static PaymentIntentsResponse parse(String body) =>
      PaymentIntentsResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
}

class PaymentIntent {
  final Connected? connected;
  // final String? intentUuid;
  final String? uuid;
  final String? intentNo;
  final int? customerId;
  final int? bankmerchantid;
  final String? customerNo;
  final String? channel;
  final String? payedtype;
  final double? requestedAmount;
  final double? amount;
  final double? discountAmount;
  final String? currency;
  final String? status;
  final String? description;

  final String? attache_slip_no;

  final StatusExtended? statusExtended;
  final DateTime? softExpireAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Invoice> invoices;
  final dynamic latestSlip; // unknown schema (null in sample)
  final List<dynamic> payments; // unknown schema (empty list in sample)

  PaymentIntent({
    this.connected,
    this.uuid,
    this.intentNo,
    this.customerId,
    this.bankmerchantid,
    this.customerNo,
    this.channel,
    this.payedtype,
    this.requestedAmount,
    this.amount,
    this.discountAmount,
    this.currency,
    this.status,
    this.description,
    this.attache_slip_no,
    this.statusExtended,
    this.softExpireAt,
    this.createdAt,
    this.updatedAt,
    this.invoices = const [],
    this.latestSlip,
    this.payments = const [],
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      connected: json['connected'] is Map<String, dynamic>
          ? Connected.fromJson(json['connected'])
          : null,
      uuid: json['uuid'] as String?,
      intentNo: json['payment_intent_no'] as String?,
      customerId: _toInt(json['customer_id']),
      bankmerchantid: _toInt(json['bank_merchant_id']),
      customerNo: json['customer_no'] as String?,
      channel: json['channel'] as String?,
      payedtype: json['payed_type'] as String?,
      requestedAmount: _toDouble(json['requested_amount']),
      amount: _toDouble(json['amount']),
      discountAmount: _toDouble(json['discount_amount']),
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      attache_slip_no: json['attache_slip_no'] as String?,
      statusExtended: json['status_extended'] is Map<String, dynamic>
          ? StatusExtended.fromJson(json['status_extended'])
          : null,
      softExpireAt: _toDate(json['soft_expire_at']),
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      invoices: (json['invoices'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => Invoice.fromJson(e))
          .toList(),
      latestSlip: json['latest_slip'],
      payments: (json['payments'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toJson() => {
        if (connected != null) 'connected': connected!.toJson(),
        'uuid': uuid,
        'payment_intent_no': intentNo,
        'customer_id': customerId,
        'bank_merchant_id': bankmerchantid,
        'customer_no': customerNo,
        'channel': channel,
        'payedtype': payedtype,
        // ส่งเป็น string 2 ตำแหน่ง เพื่อให้สอดคล้อง API response
        'requested_amount': _money2(requestedAmount),
        'amount': _money2(amount),
        'discount_amount': _money2(discountAmount),
        'currency': currency,
        'status': status,
        'description': description,
        'attache_slip_no': attache_slip_no,
        if (statusExtended != null) 'status_extended': statusExtended!.toJson(),
        'soft_expire_at': softExpireAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'invoices': invoices.map((e) => e.toJson()).toList(),
        'latest_slip': latestSlip,
        'payments': payments,
      };
}

class Connected {
  final int? id;
  final String? code;
  final String? name;

  Connected({this.id, this.code, this.name});

  factory Connected.fromJson(Map<String, dynamic> json) => Connected(
        id: _toInt(json['id']),
        code: json['code'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
      };
}

class StatusExtended {
  final String? statusVerbose;
  final String? statusThai;
  final bool? isActive;
  final bool? isExpired;

  StatusExtended(
      {this.statusVerbose, this.statusThai, this.isActive, this.isExpired});

  factory StatusExtended.fromJson(Map<String, dynamic> json) => StatusExtended(
        statusVerbose: json['status_verbose'] as String?,
        statusThai: json['status_thai'] as String?,
        isActive: json['is_active'] as bool?,
        isExpired: json['is_expired'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'status_verbose': statusVerbose,
        'status_thai': statusThai,
        'is_active': isActive,
        'is_expired': isExpired,
      };
}

class Invoice {
  final int? invoiceId;
  final String? billReference;
  final double? originalAmount;
  final double? amount;
  final double? lateFee;
  final double? vatAmount;

  final double? discountAmount;
  final double? depositAmount;
  final double? insuranceAmount;
  final double? withholdingAmount;
  final double? total;
  final List<Listfee> listfee;
  final List<Metadata> metadata;
  final double? desiredAmount;
  final int? orderIndex;

  Invoice({
    this.invoiceId,
    this.billReference,
    this.originalAmount,
    this.amount,
    this.lateFee,
    this.vatAmount,
    this.discountAmount,
    this.depositAmount,
    this.insuranceAmount,
    this.withholdingAmount,
    this.total,
    this.listfee = const [],
    this.metadata = const [],
    this.desiredAmount,
    this.orderIndex,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceId: _toInt(json['invoice_id']),
        billReference: json['bill_reference'] as String?,
        originalAmount: _toDouble(json['original_amount']),
        amount: _toDouble(json['amount']),
        lateFee: _toDouble(json['late_fee']),
        vatAmount: _toDouble(json['vat_amount']),
        discountAmount: _toDouble(json['discount_amount']),
        depositAmount: _toDouble(json['deposit_amount']),
        insuranceAmount: _toDouble(json['insurance_amount']),
        withholdingAmount: _toDouble(json['withholding_amount']),
        total: _toDouble(json['total']),
        listfee: (json['list_fee'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => Listfee.fromJson(e))
            .toList(),
        metadata: (json['metadata'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => Metadata.fromJson(e))
            .toList(),
        desiredAmount: _toDouble(json['desired_amount']),
        orderIndex: _toInt(json['order_index']),
      );

  Map<String, dynamic> toJson() => {
        'invoice_id': invoiceId,
        'bill_reference': billReference,
        'original_amount': _money2(originalAmount),
        'amount': _money2(amount),
        'late_fee': _money2(lateFee),
        'vat_amount': _money2(vatAmount),
        'discount_amount': _money2(discountAmount),
        'deposit_amount': _money2(depositAmount),
        'insurance_amount': _money2(insuranceAmount),
        'withholding_amount': _money2(withholdingAmount),
        'total': _money2(total),
        'listfee': listfee.map((e) => e.toJson()).toList(),
        'metadata': metadata.map((e) => e.toJson()).toList(),
        'desired_amount': _money2(desiredAmount),
        'order_index': orderIndex,
      };
}

class Metadata {
  final String? expname;
  final String? docno;
  final String? date; // ถ้าต้อง DateTime ให้เปลี่ยน type แล้วใช้ _toDate
  final String? cid;
  final String? custno;
  final String? st;
  final String? status; // sample เป็น "1" (string)
  final int? payser;
  final int? docnoAll;
  final double? priBill;
  final double? pvatBill;
  final double? vatBill;
  final double? whtBill;
  final double? vatDislis;
  final double? dislis;
  final double? totalBill;
  final List<Listfee> listfee;

  Metadata({
    this.expname,
    this.docno,
    this.date,
    this.cid,
    this.custno,
    this.st,
    this.status,
    this.payser,
    this.docnoAll,
    this.priBill,
    this.pvatBill,
    this.vatBill,
    this.whtBill,
    this.vatDislis,
    this.dislis,
    this.totalBill,
    this.listfee = const [],
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        expname: json['expname'] as String?,
        docno: json['docno'] as String?,
        date: json['date'] as String?,
        cid: json['cid'] as String?,
        custno: json['custno'] as String?,
        st: json['st'] as String?,
        status: json['status']?.toString(),
        payser: _toInt(json['payser']),
        docnoAll: _toInt(json['docno_all']),
        priBill: _toDouble(json['pri_bill']),
        pvatBill: _toDouble(json['pvat_bill']),
        vatBill: _toDouble(json['vat_bill']),
        whtBill: _toDouble(json['wht_bill']),
        vatDislis: _toDouble(json['vat_dis_lis']),
        dislis: _toDouble(json['dis_lis']),
        totalBill: _toDouble(json['total_bill']),
        listfee: (json['list_fee'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((e) => Listfee.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'expname': expname,
        'docno': docno,
        'date': date,
        'cid': cid,
        'custno': custno,
        'st': st,
        'status': status,
        'payser': payser,
        'docno_all': docnoAll,
        'pri_bill': priBill,
        'pvat_bill': pvatBill,
        'vat_bill': vatBill,
        'wht_bill': whtBill,
        'vat_dis_lis': vatDislis,
        'dis_lis': dislis,
        'total_bill': totalBill,
        'listfee': listfee.map((e) => e.toJson()).toList(),
      };
}

class Listfee {
  final String? docno;
  final String? expname;
  final double? pvat;
  final double? vat;
  final double? wht;
  final double? total;

  Listfee({
    this.docno,
    this.expname,
    this.pvat,
    this.vat,
    this.wht,
    this.total,
  });

  factory Listfee.fromJson(Map<String, dynamic> json) => Listfee(
        docno: json['docno'] as String?,
        expname: json['expname'] as String?,
        pvat: _toDouble(json['pvat']),
        vat: _toDouble(json['vat']),
        wht: _toDouble(json['wht']),
        total: _toDouble(json['total']),
      );

  Map<String, dynamic> toJson() => {
        'docno': docno,
        'expname': expname,
        'pvat': _money2(pvat),
        'vat': _money2(vat),
        'wht': _money2(wht),
        'total': _money2(total),
      };
}

class Meta {
  final int? currentPage;
  final int? perPage;
  final int? total;
  final int? lastPage;

  Meta({this.currentPage, this.perPage, this.total, this.lastPage});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: _toInt(json['current_page']),
        perPage: _toInt(json['per_page']),
        total: _toInt(json['total']),
        lastPage: _toInt(json['last_page']),
      );

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'per_page': perPage,
        'total': total,
        'last_page': lastPage,
      };
}

/// ---------- helpers ----------
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// ส่งเงินเป็น string 2 ตำแหน่ง (หรือ null ถ้าไม่มีค่า)
String? _money2(double? v) => (v == null) ? null : v.toStringAsFixed(2);
