// ============================================================================
// request_detail_shop_section.dart
// ============================================================================
// Section "ข้อมูลร้านค้า" — แบบ read-only
// - Row เดี่ยว: label + read-only TextField
// - Row พิเศษ (ser=1): แสดง sub fields (2 row x N col)
// คัดลอกมาจาก license_request_page/views/widgets/request_detail_shop_section.dart
// ✅ ใช้ LicenseRequestDetailStep1ViewModel จาก license_request_page (import ข้าม module)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../license_request_page/viewmodels/license_request_detail_step1_view_model.dart';