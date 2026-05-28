import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/Myconstant.dart';
import 'Translate.dart';
import 'colors.dart';

Future<void> Dialog_Download_Foder(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        // title: const Text('Download_Foder'),
        content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: InkWell(
                  onTap: () async {
                    Deleted_foder(context);
                    Navigator.of(context).pop();
                    // setState(() {
                    //   innerloop = false;
                    // });
                  },
                  child: Icon(Icons.cancel_outlined, color: Colors.red))),
          Center(
              child: SizedBox(
            height: 80,
            width: 200,
            child: Image.asset(
              "images/chaoperty_dark.png",
              fit: BoxFit.fill,
              height: 80,
              width: 200,
            ),
            // CircularProgressIndicator()
          )),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Center(
          //     child: Text(
          //       ' Download ??',
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(
          //         fontSize: 14,
          //         color: Colors.black,
          //         fontWeight: FontWeight.bold,
          //         fontFamily: FontWeight_.Fonts_T,
          //       ),
          //     ),
          //   ),
          // ),
        ])),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                // width: 100,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () async {
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    // DateTime datex = DateTime.now();
                    var ren = preferences.getString('renTalSer');
                    var user = preferences.getString('ser');
                    var Select_UP_Success =
                        preferences.getString('Select_UP_Success');
                    if (Select_UP_Success == 'OK') {
                      download_foder('$ren$user', '$ren$user');
                      await Future.delayed(const Duration(milliseconds: 300));
                      Navigator.of(context).pop();
                    }
                  },
                  child: Translate.TranslateAndSetText(
                      'ยืนยัน Download',
                      Colors.white,
                      TextAlign.center,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> uploadFile(Uint8List data, name_1) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // DateTime datex = DateTime.now();
  var ren = preferences.getString('renTalSer');
  var user = preferences.getString('ser');
  var selectUpSuccess = preferences.getString('Select_UP_Success');
  // Convert ByteData to Uint8List
  // final Uint8List data = byteData.buffer.asUint8List();

  // Create a Blob from the Uint8List
  final blob = html.Blob([data], 'application/pdf'); // Specify PDF MIME type

  // Create FormData and append the file (Blob)
  final formData = html.FormData();
  formData.appendBlob('file', blob, '$name_1.pdf'); // You can set any file name

  // Create and send the request
  final request = html.HttpRequest();
  request
    ..open(
        'POST', '${MyConstant().domain}/File_uploadPDF.php?ren=$ren&user=$user')
    ..send(formData);

  // Wait for the request to finish
  await request.onLoad.first;

  // Check the response
  if (request.status == 200) {
    // //print('File **************!');
    // //print('$name_1 successfully! $Select_UP_Success');
    // await Future.delayed(const Duration(milliseconds: 300));
    // if (Select_UP_Success == 'OK') {
    //   download_foder('$ren$user', '$ren$user');
    // }
  } else {
    // //print('File upload failed with status code: ${request.status}');
  }
}

Future<void> download_foder(String folderName, String name) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  var ren = preferences.getString('renTalSer');
  var namePage = preferences.getString('name_page');
  var selectUpSuccess = preferences.getString('Select_UP_Success');
  DateTime datex = DateTime.now();
  // List<String> All_file = [
  //   'ใบเสร็จรับเงิน RM67-09-000513.pdf',
  //   'ใบเสร็จรับเงิน RM67-09-000514.pdf',
  //   'ใบเสร็จรับเงิน RM67-09-000515.pdf',
  // ];

  // // URL encode the file list to pass as a query parameter
  // String fileList = All_file.map((file) => Uri.encodeComponent(file)).join(',');
  if (selectUpSuccess.toString() == 'OK') {
    try {
      // Make an HTTP request to download the zipped folder from the server
      // final http.Response r = await http.get(
      //   Uri.parse(
      //       '${MyConstant().domain}/download_file_list.php?folder=$folderName&ren=$ren&files=$fileList'),
      // );
      final http.Response r = await http.get(
        Uri.parse(
            '${MyConstant().domain}/download_file.php?folder=$folderName&ren=$ren'),
      );

      // Get the response bytes (the zip file)
      final data = r.bodyBytes;

      // Create a Blob from the response data
      final blob = html.Blob([data], 'application/zip');

      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element to trigger the download
      final a = html.AnchorElement(href: url)
        ..download = '$namePage.zip' // Set the download name for the zip file
        ..click(); // Trigger the download

      // Revoke the object URL after download to free up resources
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      //print('Error downloading folder: $e');
    }
  }
}

Future<void> Deleted_foder(context) async {
  for (int index = 0; index < 2; index++) {
    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    var user = preferences.getString('ser');
    var folderName = '$ren$user';
// https://chaoperties.com/Choice/chao_api/Deleted_Folder.php?folder=092024(106268)&ren=106
    String url =
        '${MyConstant().domain}/Deleted_Folder.php?folder=$folderName&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      if (result.toString() != 'null') {
        //print('Deleted_foder');
        // await Future.delayed(const Duration(seconds: 1));
        // Navigator.pop(context, 'OK');
      }
    } catch (e) {}
  }
}

// https://chaoperties.com/Choice/chao_api/download_file.php?folder=092024&ren=
// Future<void> download_foder(String folderName, String name) async {
//   List All_file = [
//     'ใบเสร็จรับเงิน RM67-09-000513.pdf',
//     'ใบเสร็จรับเงิน RM67-09-000514.pdf',
//     'ใบเสร็จรับเงิน RM67-09-000515.pdf',
//   ];
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   var ren = preferences.getString('renTalSer');
//   String fileList = All_file.map((file) => Uri.encodeComponent(file)).join(',');
//   try {
//     // Make an HTTP request to download the zipped folder from the server
//     final http.Response r = await http.get(
//       Uri.parse(
//           '${MyConstant().domain}/download_file_list.php?folder=$folderName&ren=$ren&files=$fileList'),
//     );

//     // Get the response bytes (the zip file)
//     final data = r.bodyBytes;

//     // Create a Blob from the response data
//     final blob = html.Blob([data], 'application/zip');

//     // Create a URL for the Blob
//     final url = html.Url.createObjectUrlFromBlob(blob);

//     // Create an anchor element to trigger the download
//     final a = html.AnchorElement(href: url)
//       ..download = '$folderName.zip' // Set the download name for the zip file
//       ..click(); // Trigger the download

//     // Revoke the object URL after download to free up resources
//     html.Url.revokeObjectUrl(url);
//   } catch (e) {
//     //print('Error downloading folder: $e');
//   }
// }
