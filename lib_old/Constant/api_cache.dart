/// แคช API response แบบ in-memory พร้อม TTL
/// ป้องกันการดึง API ซ้ำตอนรีเฟรชหรือ rebuild
///
/// Usage:
/// ```dart
/// final _cache = ApiCache(ttl: Duration(seconds: 15));
///
/// Future<void> fetchData() async {
///   if (_cache.isValid('myKey')) return; // ยังไม่หมดอายุ ข้าม
///   // ... ดึง API ...
///   _cache.set('myKey'); // บันทึกว่าดึงแล้ว
/// }
/// ```
class ApiCache {
  final Duration ttl;
  final Map<String, DateTime> _timestamps = {};
  final Map<String, dynamic> _data = {};

  ApiCache({this.ttl = const Duration(seconds: 15)});

  /// ตรวจว่าข้อมูล key นี้ยังใหม่อยู่ (ยังไม่หมด TTL)
  bool isValid(String key) {
    final lastFetch = _timestamps[key];
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < ttl;
  }

  /// ดึงข้อมูลที่เก็บไว้
  dynamic get(String key) {
    return _data[key];
  }

  /// บันทึกข้อมูลและเวลาที่ดึง
  void set(String key, dynamic data) {
    _timestamps[key] = DateTime.now();
    _data[key] = data;
  }

  /// ล้างแคชทั้งหมด
  void clear() {
    _timestamps.clear();
    _data.clear();
  }

  /// ล้างแคชเฉพาะ key
  void invalidate(String key) {
    _timestamps.remove(key);
    _data.remove(key);
  }
}
