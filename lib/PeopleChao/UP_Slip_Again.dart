import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Style/colors.dart';

/////////----------------------------------------------------------->

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
    var file;

    String? base64_Slip;
    // ignore: deprecated_member_use
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);

    if (pickedFile == null) {
      // print('User canceled image selection');
      return;
    } else {
      // 2. Read the image as bytes
      final imageBytes = await pickedFile.readAsBytes();

      // 3. Encode the image as a base64 string
      final base64Image = base64Encode(imageBytes);
      base64_Slip = base64Image;

      extension = 'png';
    }
    OKuploadFile_Slip(
        context, extension, file, base64_Slip, docno, datex, type, slip, foder);
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

        final response = await http.post(
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
