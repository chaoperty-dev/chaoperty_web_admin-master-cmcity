import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

Future<Map<String, String>?> pickSlipImageAsBase64() async {
  final imagePicker = ImagePicker();

  try {
    final pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );

    if (pickedFile == null) {
      //print('⚠️ ผู้ใช้ยกเลิกการเลือกรูปภาพ');
      return null;
    }

    //print('📄 เลือกรูปได้จาก path: ${pickedFile.path}');

    final imageBytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final ext = pickedFile.path.split('.').last;
    //print(
    //  '✅ แปลงรูปภาพเป็น base64 สำเร็จ ขนาด: ${imageBytes.length} bytes, นามสกุล: .$ext');

    return {
      'base64': base64Image,
      'extension': ext,
    };
  } on PlatformException catch (e) {
    //print('🚫 PlatformException: ${e.code} - ${e.message}');
    return null;
  } catch (e, stackTrace) {
    //print('❌ เกิดข้อผิดพลาดไม่ทราบสาเหตุ: $e');
    //print('🪵 StackTrace:\n$stackTrace');
    return null;
  }
}
