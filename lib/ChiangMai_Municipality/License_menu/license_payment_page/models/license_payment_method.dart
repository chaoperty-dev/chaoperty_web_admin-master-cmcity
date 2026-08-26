// ============================================================================
// license_payment_method.dart
// ============================================================================
// Model — ช่องทาง/วิธีรับชำระ (Lookup) สำหรับ POST /v2/payments
//   GET {api_root}/api/v1/lookup/payments
//   -> { "methods": [ { id, uuid, code, name_th, meta: [...] } ] }
//
// ใช้ร่วมกับ PaymentDetail.payment_method_id �อนสร้างรายการรับชำระ
// ============================================================================

/// บัญชีรับเงิน (1 method อาจมีหลายบัญชี เช่น ธนาคารหลายเจ้า)
class LicensePaymentBank {
  final int? bankId;
  final String? bankCode; // รหัสธนาคาร
  final String? bankAccount; // เลขบัญชี
  final String? bankName; // ชื่อบัญชี
  final String? branch; // สาขา
  final String? note;
  final String? imagePath;

  const LicensePaymentBank({
    this.bankId,
    this.bankCode,
    this.bankAccount,
    this.bankName,
    this.branch,
    this.note,
    this.imagePath,
  });

  factory LicensePaymentBank.fromJson(Map<String, dynamic> json) {
    return LicensePaymentBank(
      bankId: json['bank_id'] is int
          ? json['bank_id'] as int
          : int.tryParse('${json['bank_id'] ?? ''}'),
      bankCode: (json['bcode'] ?? '').toString(),
      bankAccount: (json['bank_account'] ?? '').toString(),
      bankName: (json['bank_names'] ?? json['bank_name'] ?? '').toString(),
      branch: (json['branch'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      imagePath: (json['image_path'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'bank_id': bankId,
        'bcode': bankCode,
        'bank_account': bankAccount,
        'bank_names': bankName,
        'branch': branch,
        'note': note,
        'image_path': imagePath,
      };

  /// ข้อความแสดงผลบน UI
  String get display {
    final parts = <String>[];
    if (bankName != null && bankName!.isNotEmpty) parts.add(bankName!);
    if (bankAccount != null && bankAccount!.isNotEmpty) {
      parts.add(bankAccount!);
    }
    if (branch != null && branch!.isNotEmpty) parts.add('สาขา $branch');
    return parts.isEmpty ? '-' : parts.join(' • ');
  }
}

/// ช่องทางการรับชำระ (เช่น เงินสด / เงินโอน / พร้อมเพย์)
class LicensePaymentMethod {
  final int id;
  final String uuid;
  final String code; // CASH / TRANSFER / PROMPTPAY / ...
  final String nameTh; // ชื่อภาษาไทย
  final List<LicensePaymentBank> banks;

  const LicensePaymentMethod({
    required this.id,
    required this.uuid,
    required this.code,
    required this.nameTh,
    this.banks = const [],
  });

  factory LicensePaymentMethod.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, [int d = 0]) =>
        v is int ? v : int.tryParse('$v') ?? d;

    final rawMeta = json['meta'];
    List<LicensePaymentBank> banks;
    if (rawMeta is List) {
      // กรณี meta = [...] (array ของ banks)
      banks = rawMeta
          .whereType<Map<String, dynamic>>()
          .map(LicensePaymentBank.fromJson)
          .toList();
    } else if (rawMeta is Map) {
      // กรณี meta = {...} (single bank object — BANK_TRANSFER, QR methods)
      banks = [LicensePaymentBank.fromJson(Map<String, dynamic>.from(rawMeta))];
    } else {
      banks = <LicensePaymentBank>[];
    }

    return LicensePaymentMethod(
      id: toInt(json['id']),
      uuid: (json['uuid'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      nameTh: (json['name_th'] ?? json['name'] ?? '').toString(),
      banks: banks,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'code': code,
        'name_th': nameTh,
        'meta': banks.map((e) => e.toJson()).toList(),
      };

  /// label สำหรับ UI (ไอคอน/สี) — จาก code
  bool get isCash => code.toUpperCase() == 'CASH';
  bool get hasBankAccounts => banks.isNotEmpty;
}

/// Wrapper สำหรับ response
class LicensePaymentMethodList {
  final List<LicensePaymentMethod> methods;
  const LicensePaymentMethodList({this.methods = const []});

  factory LicensePaymentMethodList.fromJson(Map<String, dynamic> json) {
    final list = json['methods'];
    final methods = list is List
        ? list
            .whereType<Map<String, dynamic>>()
            .map(LicensePaymentMethod.fromJson)
            .toList()
        : <LicensePaymentMethod>[];
    return LicensePaymentMethodList(methods: methods);
  }
}
