// ============================================================================
// general_data_sections.dart
// ============================================================================
// Library file สำหรับ section widgets + page widgets ทั้งหมด
// ใช้ part/part of pattern เพื่อให้ private classes (_SectionCard ฯลฯ)
// ใช้ร่วมกันระหว่าง step1 และ step2 ได้
//
// Parts:
//   - general_data_sections_part1.dart : Step 1 classes (Hero + Section 1 + Section 5 + ContractImage)
//   - general_data_sections_part2.dart : Step 2 classes (Section 6, 7, 8 + ZoneImageCard)
//   - general_data_section_views.dart  : Public wrapper classes (GeneralDataStep1, GeneralDataStep2)
// ============================================================================

library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodels/rental_general_view_model.dart';
import 'rental_general_section_row.dart';
import 'package:chaoperty/ChiangMai_Municipality/License_menu/license_fact_check_page/views/theme/license_fact_check_theme.dart';

part 'general_data_sections_part1.dart';
part 'general_data_sections_part2.dart';
part 'general_data_section_views.dart';
