// ============================================================================
// request_detail_contract_section.dart
// ============================================================================
// Section "ข้อมูลสัญญา" — แบบ read-only
// - ser 1 / 2 → แสดงวันที่ (dd-MM-yyyy)
// - ser 3 / 4 → แสดงเป็น text ธรรมดา
// คัดลอกมาจาก license_request_page/views/widgets/request_detail_contract_section.dart
// ✅ ใช้ LicenseRequestDetailStep1ViewModel จาก license_request_page (import ข้าม module)
// ✅ formatDate จาก lib/unity/FormatDate.dart (path คำนวณจาก license_attach_page)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../unity/Enum.dart';
import '../../../../unity/FormatDate.dart';
import '../../../license_request_page/viewmodels/license_request_detail_step1_view_model.dart';