import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Style/colors.dart';

/////////----------------------------------------------------------->

// ignore: depend_on_referenced_packages
import 'package:image/image.dart'
    as img; // Add this import for image manipulation
import 'dart:typed_data';

dynamic uploadFile_Slip_Again(context, docno, datex, type, slip, foder) async {
  if (datex == null ||
      datex.toString() == '' ||
      datex.toString() == '0000-00-00') {
    Navigator.pop(context, 'OK');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.red[700],
          content: Text('Upload slip : ${docno} failed !!',
              style:
                  TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    );
  } else {
    var extension;
    // var file;

    String? base64_Slip;
    final imagePicker = ImagePicker();
    // Allow picking multiple images
    final List<XFile>? pickedFiles = await imagePicker.pickMultiImage(
      imageQuality: 80, // Optional: adjust quality
      maxWidth: 1024, // Resize large images to avoid OOM
    );

    if (pickedFiles == null || pickedFiles.isEmpty) {
      // print('User canceled image selection');
      return;
    } else {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("กำลังประมวลผลรูปภาพ..."),
                ],
              ),
            ),
          );
        },
      );

      extension = 'png'; // We will encode the merged result as PNG (or JPG)

      if (pickedFiles.length == 1) {
        // Single image case
        final imageBytes = await pickedFiles[0].readAsBytes();
        base64_Slip = base64Encode(imageBytes);
      } else {
        // Multiple images case: Merge them
        try {
          List<img.Image> images = [];
          int totalHeight = 0;
          int maxWidth = 0;

          for (var file in pickedFiles) {
            final bytes = await file.readAsBytes();
            final decodedImage = img.decodeImage(bytes);
            if (decodedImage != null) {
              images.add(decodedImage);
              totalHeight += decodedImage.height;
              if (decodedImage.width > maxWidth) {
                maxWidth = decodedImage.width;
              }
            }
          }

          if (images.isEmpty) {
            Navigator.pop(context); // Close loading if no images
            return;
          }

          // Create a merged image canvas
          final mergedImage = img.Image(width: maxWidth, height: totalHeight);

          int currentY = 0;
          for (var image in images) {
            // Draw each image onto the merged canvas
            // If image width is smaller than maxWidth, we might want to center it or just draw at 0
            // For simplicity, drawing at 0,0 relative to currentY
            img.compositeImage(mergedImage, image, dstX: 0, dstY: currentY);
            currentY += image.height;
          }

          // Encode the merged image to PNG
          final mergedBytes = img.encodePng(mergedImage);
          base64_Slip = base64Encode(mergedBytes);
        } catch (e) {
          Navigator.pop(context); // Close loading on error
          print('Error merging images: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error merging images: $e')),
          );
          return;
        }
      }
    }
    OKuploadFile_Slip(
        context, extension, null, base64_Slip, docno, datex, type, slip, foder);
  }
}

///------------->
Future<void> OKuploadFile_Slip(context, extension, file, base64_Slip, docno,
    datex, type, slip, foder) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var ren = preferences.getString('renTalSer');
  var user = preferences.getString('ser');
  String? fileName_Slip;
  if (base64_Slip != null) {
    String dateTimeNow = DateTime.now().toString();
    String date_MM =
        DateFormat('MM').format(DateTime.parse('${datex}')).toString();
    String date_YY =
        DateFormat('yyyy').format(DateTime.parse('${datex}')).toString();
    String date = DateFormat('ddMMyyyy')
        .format(DateTime.parse('${dateTimeNow}'))
        .toString();
    final dateTimeNow2 = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formatter2 = DateFormat('HHmmss');
    final formattedTime2 = formatter2.format(dateTimeNow2);
    String Time_ = formattedTime2.toString();
    String sanitizedInput = docno.replaceAll('-', '');
    fileName_Slip =
        'slip_${sanitizedInput}_$Time_${dateTimeNow2.millisecond}.$extension';
    // print(fileName_Slip);
    if (datex == null ||
        datex.toString() == '' ||
        datex.toString() == '0000-00-00') {
      Navigator.pop(context, 'OK');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red[700],
            content: Text('Upload slip : ${docno} failed !!',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
      );
    } else {
      try {
        final url =
            '${MyConstant().domain}/File_uploadSlip_Again.php?name=$fileName_Slip&Foder=$foder&extension=$extension';

        final response = await httpClient.post(
          Uri.parse(url),
          body: {
            'ren': '$ren',
            'image': base64_Slip,
            'Foder': foder,
            'name': fileName_Slip,
            'ex': extension.toString(),
            'month': date_MM.toString(),
            'year': date_YY.toString(),
            'docno': docno.toString(),
            'slip_del': slip.toString()
          }, // Send the image as a form field named 'image'
        );

        if (response.statusCode == 200) {
          if (type.toString() == 'รอตรวจสอบ') {
            if (slip == null ||
                slip.toString() == '' ||
                slip.toString() == 'null') {
              Insert_log.Insert_logs(
                  'บัญชี', 'รอตรวจสอบ>>(เพิ่ม${fileName_Slip})');
            } else {
              Insert_log.Insert_logs(
                  'บัญชี', 'รอตรวจสอบ>>(${slip}=>${fileName_Slip})');
            }
          } else if (type.toString() == 'ประวัติชำระ') {
            if (slip == null ||
                slip.toString() == '' ||
                slip.toString() == 'null') {
              Insert_log.Insert_logs(
                  'บัญชี', 'ประวัติชำระ>>(เพิ่ม${fileName_Slip})');
            } else {
              Insert_log.Insert_logs(
                  'บัญชี', 'ประวัติชำระ>>(${slip}=>${fileName_Slip})');
            }
          }

          // print('Image uploaded successfully');
          Navigator.pop(context, 'OK');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green[700],
                content: Text('Upload slip : ${docno} successfully !!',
                    style: TextStyle(
                        color: Colors.white, fontFamily: Font_.Fonts_T))),
          );
        } else {
          // print('Image upload failed');
          Navigator.pop(context, 'OK');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red[700],
                content: Text('Upload slip : ${docno} failed !!',
                    style: TextStyle(
                        color: Colors.white, fontFamily: Font_.Fonts_T))),
          );
        }
      } catch (e) {
        // print('Error during image processing: $e');
        Navigator.pop(context, 'OK');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red[700],
              content: Text('Upload slip : ${docno} failed !!',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
        Navigator.pop(context, 'OK');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red[700],
              content: Text('Upload slip : ${docno} failed !!',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
      }
    }
  } else {
    // print('ยังไม่ได้เลือกรูปภาพ');
    Navigator.pop(context, 'OK');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.red[700],
          content: Text('Upload slip : ${docno} failed !!',
              style:
                  TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    );
  }
}
