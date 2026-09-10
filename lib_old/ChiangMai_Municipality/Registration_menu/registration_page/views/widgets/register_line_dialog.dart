// ============================================================================
// register_line_dialog.dart
// ============================================================================
// Dialog ลงทะเบียนไลน์ — แสดง QR Code จาก line_regis_url
// (Copy จาก PeopleChao/Rental_customer.dart → _showRegisterlineDialog)
// ============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// เปิด Dialog ลงทะเบียนไลน์
/// - [lineRegisUrl]: URL จาก regis_data[0].line_regis_url
/// - [tax]: เลขบัตรประชาชน/TAX สำหรับแสดงใน caption
Future<void> showRegisterLineDialog(
  BuildContext context, {
  required String lineRegisUrl,
  required String tax,
}) async {
  // เก็บวันแบบ local (ดีฟอลต์ = วันนี้)
  DateTime expireDateLocal = DateTime.now();

  await showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          // คำนวณสิ้นวัน (local) -> UTC -> ISO -> Base64URL
          final endOfDayLocal = DateTime(
            expireDateLocal.year,
            expireDateLocal.month,
            expireDateLocal.day,
            23,
            59,
            59,
          );
          final expireIsoUtc = endOfDayLocal.toUtc().toIso8601String();
          final expireB64 = base64UrlEncode(utf8.encode(expireIsoUtc));
          final lineregisurl = '$lineRegisUrl&expire=$expireB64';

          final expireText =
              '${expireDateLocal.day.toString().padLeft(2, '0')}-${expireDateLocal.month.toString().padLeft(2, '0')}-${expireDateLocal.year}';

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.qr_code_2,
                            color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'ลงทะเบียนไลน์',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'ปิด',
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // QR + caption
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                QrImageView(
                                  data: lineregisurl,
                                  version: QrVersions.auto,
                                  size: 230,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'สแกนเพื่อเชื่อมต่อบัญชี LINE\nเลขที่บัตรประชาชน: $tax',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // เลือกวันหมดอายุ
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: ctx,
                                      initialDate: expireDateLocal,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 120)),
                                      locale: const Locale('th', 'TH'),
                                    );
                                    if (picked != null) {
                                      setState(() => expireDateLocal = picked);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.event,
                                            size: 16, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          'หมดอายุ: $expireText',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 18, color: Colors.black54),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('ปิด'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
