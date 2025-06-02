import 'dart:html';
import 'dart:js_interop';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../AdminScaffold/AdminScaffold.dart';
import '../PeopleChao/Pays_.dart';
import '../Setting/Bill_Document_Template.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'PDF_CMM/application_form1_cmm.dart';
import 'PDF_CMM/application_form2_cmm.dart';
import 'PDF_CMM/license_form_cmm.dart';
import 'package:pdf/widgets.dart' as pw;

import 'PDF_CMM/receipt_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf2_cmm.dart';

class SignaturePad_CMM extends StatefulWidget {
  const SignaturePad_CMM({super.key});

  @override
  State<SignaturePad_CMM> createState() => _SignaturePad_CMMState();
}

class _SignaturePad_CMMState extends State<SignaturePad_CMM> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  String? Signature_user;
  String functionName = "GeneratePDF_1",
      pdfName =
          "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ";
  ////////////--------------------->
  File? pdfFile;
  dynamic pdfx = pw.Document();
  ////////////--------------------->
  @override
  void initState() {
    Preview_PDF();
    super.initState();
  }

  Future<Null> Preview_PDF() async {
    final generate = await GeneratePDF_ApplicationForm1_CMM(context, 0);

    setState(() {
      pdfx = generate;
    });
  }

  ////////////--------------------->
  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
  }

  void _handleSaveButtonPressed() async {
    final data = await signatureGlobalKey.currentState!.toImage(
      pixelRatio: 3.0,
    );
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Container(
                color: Colors.grey[300],
                child: Image.memory(bytes!.buffer.asUint8List()),
              ),
            ),
          );
        },
      ),
    );
  }

  ////////////--------------------->
  // final Map<String, Future<void> Function()> pdfGenerators = {
  //   "GeneratePDF_1": GeneratePDF_ApplicationForm1_CMM,
  //   "GeneratePDF_2": GeneratePDF_ApplicationForm2_CMM,
  //   "GeneratePDF_3": GeneratePDF_License_CMM,
  // };
  // final Map<String, Future<void> Function()> pdfGenerators = {
  //   "GeneratePDF_1": GeneratePDF_ApplicationForm1_CMM,
  //   "GeneratePDF_2": GeneratePDF_ApplicationForm2_CMM,
  //   "GeneratePDF_3": () => GeneratePDF_License_CMM,
  // };

  List data_doccid = [
    {
      "ser": "1",
      "title":
          "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ",
      "detail": "GeneratePDF_1"
    },
    {
      "ser": "2",
      "title":
          "ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ",
      "detail": "GeneratePDF_2"
    },
    {
      "ser": "3",
      "title": "ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ_นายเชียงใหม่สุเทพ",
      "detail": "GeneratePDF_3"
    },
  ];
  ////////////--------------------->
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height + 300,
            child: Column(children: [
              // ช่องค้นหา
              Container(
                  width: MediaQuery.of(context).size.width,
                  // height: 50,
                  decoration: BoxDecoration(
                    color: AppbackgroundColor.TiTile_Box,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  // padding: const EdgeInsets.all(5.0),
                  child: Row(children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'คำขอต่อสัญญา ',
                            ChaoAreaScreen_Color.Colors_Text1_,
                            TextAlign.left,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            2),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Translate.TranslateAndSetText(
                            'รายละเอียดเอกสารสำหรับต่อสัญญา ',
                            ChaoAreaScreen_Color.Colors_Text1_,
                            TextAlign.left,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            2),
                      ),
                    ),
                  ])),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            // height: MediaQuery.of(context).size.height * 0.8,
                            decoration: const BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      AutoSizeText(
                                        minFontSize: 12,
                                        maxFontSize: 16,
                                        maxLines: 1,
                                        'Preview $pdfName',
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      Container(
                                        width: 400,
                                        height: 550,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        child: pdfx != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: PreviewPdfgen2_CMM(
                                                    doc: pdfx,
                                                    title: '$pdfName'),
                                              )
                                            : Center(
                                                child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                        Icons.picture_as_pdf),
                                                  ),
                                                  Text(
                                                    "PDF Download ...",
                                                    style: TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ],
                                              )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                            onPressed: () async {
                                              final pdfGenerators = {
                                                "GeneratePDF_1": () =>
                                                    GeneratePDF_ApplicationForm1_CMM(
                                                        context, 1),
                                                "GeneratePDF_2": () =>
                                                    GeneratePDF_ApplicationForm2_CMM(
                                                        context, 1),
                                                "GeneratePDF_3": () =>
                                                    GeneratePDF_Receipt_CMM(
                                                        context, 1),
                                              };
                                              final fn =
                                                  pdfGenerators[functionName];
                                              if (fn != null) await fn();
                                            },
                                            icon: Icon(Icons.print)),
                                      ),
                                      // IconButton(
                                      //     onPressed: () {},
                                      //     icon: Icon(Icons.print)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: [
                                      SizedBox(
                                        child: Column(
                                          children: [
                                            AutoSizeText(
                                              minFontSize: 12,
                                              maxFontSize: 16,
                                              maxLines: 1,
                                              'เอกสารคำร้องขอต่อสัญญา/ใบอนุญาต)',
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                            for (var doc in data_doccid)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Row(children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 16,
                                                          maxLines: 1,
                                                          '${doc["ser"]}.${doc["title"]}',
                                                          textAlign:
                                                              TextAlign.left,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 150,
                                                    height: 35,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Color.fromARGB(255,
                                                              155, 170, 72),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          pdfx = null;
                                                        });
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    400),
                                                            () async {
                                                          setState(() {
                                                            pdfName =
                                                                doc["title"]!;
                                                            functionName =
                                                                doc['detail']!;
                                                          });
                                                          final pdfGenerators =
                                                              {
                                                            "GeneratePDF_1":
                                                                GeneratePDF_ApplicationForm1_CMM(
                                                                    context, 0),
                                                            "GeneratePDF_2":
                                                                GeneratePDF_ApplicationForm2_CMM(
                                                                    context, 0),
                                                            "GeneratePDF_3":
                                                                GeneratePDF_License_CMM(
                                                                    context, 0),
                                                          };

                                                          final generate =
                                                              await pdfGenerators[
                                                                  doc['detail']];

                                                          setState(() {
                                                            pdfx = generate;
                                                          });
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Translate
                                                            .TranslateAndSet_TextAutoSize(
                                                                'แสดง',
                                                                ChaoAreaScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                12,
                                                                18,
                                                                1),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                              )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: AutoSizeText(
                                                minFontSize: 12,
                                                maxFontSize: 16,
                                                maxLines: 1,
                                                'หมายเหตุ',
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: TextFormField(
                                                readOnly: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                // controller: Formbecause_,
                                                initialValue: '',
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                  }
                                                  // if (int.parse(value.toString()) < 13) {
                                                  //   return '< 13';
                                                  // }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  // setState(() {
                                                  //   Formbecause_.text =
                                                  //       value.toString();
                                                  // });
                                                },
                                                maxLines: 3,
                                                cursorColor: Colors.green,
                                                decoration: InputDecoration(
                                                    fillColor: Colors.white
                                                        .withOpacity(0.3),
                                                    filled: true,
                                                    // prefixIcon: const Icon(Icons.water,
                                                    //     color: Colors.blue),
                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(15),
                                                        topLeft:
                                                            Radius.circular(15),
                                                        bottomRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            Radius.circular(15),
                                                      ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(15),
                                                        topLeft:
                                                            Radius.circular(15),
                                                        bottomRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            Radius.circular(15),
                                                      ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    // labelText: 'คำอธิบาย',
                                                    labelStyle: const TextStyle(
                                                      color: ManageScreen_Color
                                                          .Colors_Text2_,
                                                      // fontWeight:
                                                      //     FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T,
                                                    )),
                                                // inputFormatters: <TextInputFormatter>[
                                                //   // for below version 2 use this
                                                //   FilteringTextInputFormatter.allow(
                                                //       RegExp(r'[0-9]')),
                                                //   // for version 2 and greater youcan also use this
                                                //   FilteringTextInputFormatter.digitsOnly
                                                // ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10)),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 150,
                                                        width: 200,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8.0),
                                                          ),
                                                          child: (Signature_user ==
                                                                      null ||
                                                                  Signature_user ==
                                                                      '')
                                                              ? null
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    child: Image
                                                                        .network(
                                                                      '$Signature_user',
                                                                      height:
                                                                          180,
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(0),
                                                              topRight: Radius
                                                                  .circular(0),
                                                              bottomLeft: Radius
                                                                  .circular(0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          0)),
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color:
                                                              AppbackgroundColor
                                                                  .Abg_Colors,
                                                          borderRadius: BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(0),
                                                              topRight: Radius
                                                                  .circular(0),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          // border: Border.all(color: Colors.grey, width: 1),
                                                        ),
                                                        child: Row(
                                                          children: <Widget>[
                                                            TextButton(
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 12,
                                                                maxFontSize: 16,
                                                                maxLines: 1,
                                                                'ประทับลายเซ็นต์',
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blueGrey,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T),
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  Signature_user =
                                                                      'https://i0.wp.com/www.iurban.in.th/wp-content/uploads/2010/06/signature2.jpg?w=770&ssl=1';
                                                                });
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      12,
                                                                  maxFontSize:
                                                                      16,
                                                                  maxLines: 1,
                                                                  'ยกเลิกลายเซ็นต์',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blueGrey,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                setState(() {
                                                                  Signature_user =
                                                                      null;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Expanded(
                                            //   flex: 1,
                                            //   child:
                                            // Padding(
                                            //     padding:
                                            //         const EdgeInsets.all(8.0),
                                            //     child: Container(
                                            //       decoration: BoxDecoration(
                                            //         color: AppbackgroundColor
                                            //             .Abg_Colors,
                                            //         borderRadius:
                                            //             BorderRadius.only(
                                            //                 topLeft:
                                            //                     Radius.circular(
                                            //                         10),
                                            //                 topRight:
                                            //                     Radius.circular(
                                            //                         10),
                                            //                 bottomLeft:
                                            //                     Radius.circular(
                                            //                         10),
                                            //                 bottomRight:
                                            //                     Radius.circular(
                                            //                         10)),
                                            //         border: Border.all(
                                            //             color: Colors.grey,
                                            //             width: 1),
                                            //       ),
                                            //       child: Column(
                                            //         children: [
                                            //           Container(
                                            //             height: 150,
                                            //             padding:
                                            //                 const EdgeInsets
                                            //                     .all(2.0),
                                            //             child: SfSignaturePad(
                                            //               key:
                                            //                   signatureGlobalKey,
                                            //               backgroundColor:
                                            //                   Colors.white,
                                            //               strokeColor:
                                            //                   Colors.black,
                                            //               minimumStrokeWidth:
                                            //                   1.0,
                                            //               maximumStrokeWidth:
                                            //                   4.0,
                                            //             ),
                                            //             decoration:
                                            //                 BoxDecoration(
                                            //               borderRadius: BorderRadius.only(
                                            //                   topLeft: Radius
                                            //                       .circular(0),
                                            //                   topRight: Radius
                                            //                       .circular(0),
                                            //                   bottomLeft: Radius
                                            //                       .circular(0),
                                            //                   bottomRight:
                                            //                       Radius
                                            //                           .circular(
                                            //                               0)),
                                            //             ),
                                            //           ),
                                            //           Container(
                                            //             decoration:
                                            //                 const BoxDecoration(
                                            //               color:
                                            //                   AppbackgroundColor
                                            //                       .Abg_Colors,
                                            //               borderRadius: BorderRadius.only(
                                            //                   topLeft: Radius
                                            //                       .circular(0),
                                            //                   topRight: Radius
                                            //                       .circular(0),
                                            //                   bottomLeft: Radius
                                            //                       .circular(10),
                                            //                   bottomRight:
                                            //                       Radius
                                            //                           .circular(
                                            //                               10)),
                                            //               // border: Border.all(color: Colors.grey, width: 1),
                                            //             ),
                                            //             child: Row(
                                            //               children: <Widget>[
                                            //                 TextButton(
                                            //                   child:
                                            //                       AutoSizeText(
                                            //                     minFontSize: 12,
                                            //                     maxFontSize: 16,
                                            //                     maxLines: 1,
                                            //                     'ToImage',
                                            //                     textAlign:
                                            //                         TextAlign
                                            //                             .left,
                                            //                     overflow:
                                            //                         TextOverflow
                                            //                             .ellipsis,
                                            //                     style: TextStyle(
                                            //                         color: Colors
                                            //                             .blueGrey,
                                            //                         fontFamily:
                                            //                             Font_
                                            //                                 .Fonts_T),
                                            //                   ),
                                            //                   onPressed:
                                            //                       _handleSaveButtonPressed,
                                            //                 ),
                                            //                 TextButton(
                                            //                   child: Padding(
                                            //                     padding:
                                            //                         const EdgeInsets
                                            //                                 .all(
                                            //                             8.0),
                                            //                     child:
                                            //                         AutoSizeText(
                                            //                       minFontSize:
                                            //                           12,
                                            //                       maxFontSize:
                                            //                           16,
                                            //                       maxLines: 1,
                                            //                       'Clear',
                                            //                       textAlign:
                                            //                           TextAlign
                                            //                               .left,
                                            //                       overflow:
                                            //                           TextOverflow
                                            //                               .ellipsis,
                                            //                       style: TextStyle(
                                            //                           color: Colors
                                            //                               .blueGrey,
                                            //                           fontFamily:
                                            //                               Font_
                                            //                                   .Fonts_T),
                                            //                     ),
                                            //                   ),
                                            //                   onPressed:
                                            //                       _handleClearButtonPressed,
                                            //                 ),
                                            //               ],
                                            //               mainAxisAlignment:
                                            //                   MainAxisAlignment
                                            //                       .spaceEvenly,
                                            //             ),
                                            //           ),
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                            Expanded(
                                                flex: 1,
                                                child: SizedBox(
                                                  child: Column(
                                                    children: [
                                                      for (int index = 0;
                                                          index < 2;
                                                          index++)
                                                        SizedBox(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      12,
                                                                  maxFontSize:
                                                                      16,
                                                                  maxLines: 1,
                                                                  (index == 0)
                                                                      ? 'ชื่อผู้ตรวจสอบเอกสาร'
                                                                      : 'ชื่อตำแหน่ง',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                child:
                                                                    TextFormField(
                                                                  readOnly:
                                                                      false,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  // controller: Formbecause_,
                                                                  initialValue:
                                                                      '',
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                                    }
                                                                    // if (int.parse(value.toString()) < 13) {
                                                                    //   return '< 13';
                                                                    // }
                                                                    return null;
                                                                  },
                                                                  onChanged:
                                                                      (value) {
                                                                    // setState(() {
                                                                    //   Formbecause_.text =
                                                                    //       value.toString();
                                                                    // });
                                                                  },
                                                                  maxLines: 1,
                                                                  cursorColor:
                                                                      Colors
                                                                          .green,
                                                                  decoration: InputDecoration(
                                                                      fillColor: Colors.white.withOpacity(0.3),
                                                                      filled: true,
                                                                      // prefixIcon: const Icon(Icons.water,
                                                                      //     color: Colors.blue),
                                                                      // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                      focusedBorder: const OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(8)),
                                                                        borderSide:
                                                                            BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      enabledBorder: const OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(8)),
                                                                        borderSide:
                                                                            BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                      // labelText: 'คำอธิบาย',
                                                                      labelStyle: const TextStyle(
                                                                        color: ManageScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                      )),
                                                                  // inputFormatters: <TextInputFormatter>[
                                                                  //   // for below version 2 use this
                                                                  //   FilteringTextInputFormatter.allow(
                                                                  //       RegExp(r'[0-9]')),
                                                                  //   // for version 2 and greater youcan also use this
                                                                  //   FilteringTextInputFormatter.digitsOnly
                                                                  // ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Colors.grey,
                                                ),
                                              ),
                                              onPressed: () async {
                                                SharedPreferences preferences =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String? _route = preferences
                                                    .getString('route');
                                                MaterialPageRoute
                                                    materialPageRoute =
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            AdminScafScreen(
                                                                route:
                                                                    'ใบอนุญาต'));
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    materialPageRoute,
                                                    (route) => false);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Translate
                                                    .TranslateAndSet_TextAutoSize(
                                                        'กลับ',
                                                        ChaoAreaScreen_Color
                                                            .Colors_Text2_,
                                                        TextAlign.center,
                                                        null,
                                                        FontWeight_.Fonts_T,
                                                        12,
                                                        18,
                                                        1),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 200,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  (Signature_user == null ||
                                                          Signature_user == '')
                                                      ? Colors.grey
                                                      : Colors.green,
                                                ),
                                              ),
                                              onPressed: () async {},
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Translate
                                                    .TranslateAndSet_TextAutoSize(
                                                        'ยืนยัน/สำเร็จ',
                                                        ChaoAreaScreen_Color
                                                            .Colors_Text2_,
                                                        TextAlign.center,
                                                        null,
                                                        FontWeight_.Fonts_T,
                                                        12,
                                                        18,
                                                        1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ]),
                                  ),
                                ),
                              ],
                            )))),
              )
            ]),
          ),
        ));
  }
}
