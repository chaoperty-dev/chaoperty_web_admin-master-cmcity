import 'dart:convert';

/// Permit item returned by GET /api/v1/admin/permits.
class TenantPermitListItem {
  final Map<String, dynamic> raw;

  const TenantPermitListItem(this.raw);

  String get uuid => _string(raw['uuid']);
  String get permitNo => _string(raw['permit_no']);
  String get requestUuid => _string(raw['request_uuid']);
  String get customerUuid => _string(raw['customer_uuid']);
  String get customerName => _string(raw['customer_name']);
  String get status => _string(raw['status']);
  String get areaId => _string(raw['aser']);
  String get zoneId => _string(raw['zser']);
  String get lockCode => _string(raw['ln']);
  String get validFrom => _string(raw['valid_from']);
  String get validUntil => _string(raw['valid_until']);
  String get issuedAt => _string(raw['issued_at']);
  String get issuedBy => _string(raw['issued_by_name'] ?? raw['issued_by']);
  String get failureMessage => _string(raw['failure_message']);
  Map<String, dynamic> get document => _map(raw['document']);

  factory TenantPermitListItem.fromJson(Map<String, dynamic> json) =>
      TenantPermitListItem(Map<String, dynamic>.from(json));
}

/// Full permit detail returned by GET /api/v1/admin/permits/{uuid}.
class TenantPermitDetail extends TenantPermitListItem {
  const TenantPermitDetail(super.raw);

  Map<String, dynamic> get request => _map(raw['request']);
  Map<String, dynamic> get customer => _map(request['customer']);
  Map<String, dynamic> get details => _map(request['details']);
  Map<String, dynamic> get announcement => _map(request['announcement']);
  List<Map<String, dynamic>> get attachments => _maps(request['attachments']);
  List<Map<String, dynamic>> get payments => _maps(request['payments']);
  List<Map<String, dynamic>> get approvals => _maps(request['approvals']);
  List<Map<String, dynamic>> get documents => _maps(request['documents']);
  Map<String, dynamic> get inspectionReview =>
      _map(request['inspection_review']);
  Map<String, dynamic> get checklist => _map(request['checklist']);

  String customerField(String key) => _string(customer[key]);
  String detailField(String key) => _string(details[key]);

  String addressField(String key) {
    final address = _decodeMap(customer['addr_2']);
    final fallback = address.isNotEmpty ? address : _decodeMap(customer['json']);
    return _string(fallback[key]);
  }

  factory TenantPermitDetail.fromJson(Map<String, dynamic> json) =>
      TenantPermitDetail(Map<String, dynamic>.from(json));
}

class TenantPermitListResult {
  final List<TenantPermitListItem> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const TenantPermitListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory TenantPermitListResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = _map(json['meta']);
    final items = data is List
        ? data
            .whereType<Map>()
            .map((item) => TenantPermitListItem.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList()
        : <TenantPermitListItem>[];

    int asInt(dynamic value, int fallback) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

    return TenantPermitListResult(
      items: items,
      currentPage: asInt(meta['current_page'], 1),
      lastPage: asInt(meta['last_page'], 1),
      total: asInt(meta['total'], items.length),
    );
  }
}

String _string(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  return text == 'null' ? '' : text;
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> _decodeMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String && value.trim().isNotEmpty) {
    try {
      dynamic decoded = jsonDecode(value);
      // Some responses encode addr_2 twice; decode the inner JSON too.
      if (decoded is String && decoded.trim().isNotEmpty) {
        decoded = jsonDecode(decoded);
      }
      return _map(decoded);
    } catch (_) {}
  }
  return <String, dynamic>{};
}
