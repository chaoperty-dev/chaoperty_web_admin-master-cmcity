import 'package:intl/intl.dart';

Future<List<Map<String, String>>> getContractInfo() async {
  return [
    {
      "ser": "1",
      "title": "วันที่เริ่มต้น",
      "detail": "${DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}"
    },
    {
      "ser": "2",
      "title": "วันที่สิ้นสุด",
      "detail":
          "${DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 365))).toString()}"
    },
    {"ser": "3", "title": "ประเภทการเช่า", "detail": "รายปี"},
    {"ser": "4", "title": "อายุสัญญา(เดือน/ปี)", "detail": "1"},
  ];
}

List<Map<String, String>> getDocumentDisplayFields() {
  return [
    {"ser": "1", "title": "ชื่อเอกสาร", "data": "title"},
    {"ser": "2", "title": "วันที่ทำรายการ", "data": "datex"},
    {"ser": "3", "title": "ไฟล์เอกสาร", "data": "file"},
    {"ser": "4", "title": "สถานะ", "data": "status"},
    {"ser": "5", "title": "วันที่ตรวจสอบ", "data": "verify"},
  ];
}

List<Map<String, String>> getSubmittedDocumentsDisplayFields() {
  return [
    {"ser": "1", "title": "ชื่อเอกสาร", "data": "title"},
    {"ser": "2", "title": "วันที่ทำรายการ", "data": "datex"},
    {"ser": "3", "title": "ไฟล์เอกสาร", "data": "file"},
    {"ser": "4", "title": "สถานะ", "data": "status"},
    {"ser": "5", "title": "วันที่ตรวจสอบ", "data": "verify"},
  ];
}

List<Map<String, String>> getReceiptDisplayFields() {
  return [
    {"ser": "1", "title": "ชื่อเอกสาร", "data": "title"},
    {"ser": "2", "title": "วันที่รับชำระ", "data": "datex"},
    {"ser": "3", "title": "ไฟล์เอกสาร", "data": "file"},
    {"ser": "4", "title": "สถานะ", "data": "status"},
    {"ser": "5", "title": "วันที่ตรวจสอบ", "data": "verify"},
  ];
}
