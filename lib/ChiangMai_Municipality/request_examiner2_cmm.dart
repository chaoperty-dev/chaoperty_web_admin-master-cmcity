import 'dart:ui';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'cignaturepad_cmm.dart';

class RequestExaminer2_CMM extends StatefulWidget {
  const RequestExaminer2_CMM({super.key});

  @override
  State<RequestExaminer2_CMM> createState() => _RequestExaminer2_CMMState();
}

class _RequestExaminer2_CMMState extends State<RequestExaminer2_CMM> {
  int ser_tap = 1;
  ////////////--------------------->
  @override
  void initState() {
    super.initState();
  }

  ////////////--------------------->
  List data_person = [
    {"ser": "1", "title": "ชื่อ-นามสกุล", "detail": "นายเชียงใหม่ สุเทพ"},
    {"ser": "2", "title": "เลขบัตรประจำตัวประชาชน", "detail": "0123456789101"},
    {"ser": "3", "title": "อายุ", "detail": "ไทย"},
    {"ser": "4", "title": "บ้านเลขที่", "detail": "123/4 ม.5"},
    {"ser": "5", "title": "หมู่ที่", "detail": "สุเทพ"},
    {"ser": "6", "title": "ตรอก/ซอย", "detail": "-"},
    {"ser": "7", "title": "ถนน", "detail": "-"},
    {"ser": "8", "title": "ตำบล/แขวง", "detail": "สุเทพ"},
    {"ser": "9", "title": "อำเภอ/เขต", "detail": "เมือง"},
    {"ser": "10", "title": "จังหวัด", "detail": "เชียงใหม่"},
  ];
  List<Map<String, dynamic>> data_shop = [
    {
      "ser": "1",
      "title": "พื้นที่เช่า (ตร.ม.)",
      "detail": "",
      "detailsub": [
        {"ser": "1", "titlesub": "บริเวณ", "detail": "A"},
        {"ser": "2", "titlesub": "โซน", "detail": "B"},
        {"ser": "3", "titlesub": "ล็อกที่", "detail": "1"},
      ]
    },
    {
      "ser": "2",
      "title": "ขนาดพื้นที่เช่า (ตร.ม.)",
      "detail": "20",
      "detailsub": []
    },
    {"ser": "3", "title": "ประเภทสินค้า", "detail": "อาหาร", "detailsub": []},
    {"ser": "4", "title": "ชื่อร้าน", "detail": "ไทย", "detailsub": []},
  ];
  List data_cid = [
    {"ser": "1", "title": "วันที่เริ่มต้น", "detail": "01-06-2568"},
    {"ser": "2", "title": "วันที่สิ้นสุด", "detail": "01-06-2569"},
  ];
  List data_img_people = [
    {
      "ser": "1",
      "title": "รูปถ่ายผู้เช่า ",
      "img": "images/LOGO.png",
    },
    {
      "ser": "2",
      "title": "รูปถ่ายคู่กับร้านค้าและสินค้า",
      "img": "images/LOGO.png",
    },
  ];
  List data_admin_img_people = [
    {
      "ser": "1",
      "title": "รูปถ่ายผู้เช่า ",
      "img": "images/LOGO.png",
    },
    {
      "ser": "2",
      "title": "รูปถ่ายคู่กับร้านค้าและสินค้า",
      "img": "images/LOGO.png",
    },
    {
      "ser": "3",
      "title": "รูปถ่ายสินค้า",
      "img": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return (ser_tap == 2)
        ? SignaturePad_CMM()
        : Padding(
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
                        // Expanded(
                        //   flex: 2,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Translate.TranslateAndSetText(
                        //         'รายละเอียดเอกสารสำหรับต่อสัญญา ',
                        //         ChaoAreaScreen_Color.Colors_Text1_,
                        //         TextAlign.left,
                        //         FontWeight.bold,
                        //         FontWeight_.Fonts_T,
                        //         14,
                        //         2),
                        //   ),
                        // ),
                      ])),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
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
                                        child: Container(
                                          child: Column(children: [
                                            for (var person in data_person)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 16,
                                                            maxLines: 1,
                                                            '${person["title"]}*',
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.left,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            showCursor: false,
                                                            readOnly: true,
                                                            initialValue:
                                                                '${person["detail"]}',
                                                            onFieldSubmitted:
                                                                (value) async {},

                                                            decoration:
                                                                InputDecoration(
                                                                    fillColor: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.3),
                                                                    filled:
                                                                        true,
                                                                    focusedBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    // labelText: 'ระบุชื่อร้านค้า',
                                                                    labelStyle: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontFamily:
                                                                            Font_.Fonts_T)),
                                                            // inputFormatters: <TextInputFormatter>[
                                                            //   // for below version 2 use this
                                                            //   FilteringTextInputFormatter
                                                            //       .allow(RegExp(r'[0-9]')),
                                                            //   // for version 2 and greater youcan also use this
                                                            //   FilteringTextInputFormatter
                                                            //       .digitsOnly
                                                            // ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            for (var shop in data_shop)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 16,
                                                            maxLines: 1,
                                                            '${shop["title"]}*',
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ),
                                                      (shop["ser"].toString() ==
                                                              '1')
                                                          ? Expanded(
                                                              flex: 2,
                                                              child: Row(
                                                                children: [
                                                                  for (var shop
                                                                      in shop[
                                                                          "detailsub"])
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.all(2.0),
                                                                        child:
                                                                            TextFormField(
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          showCursor:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          initialValue:
                                                                              '${shop["detail"]}',
                                                                          onFieldSubmitted:
                                                                              (value) async {},

                                                                          decoration: InputDecoration(
                                                                              fillColor: Colors.white.withOpacity(0.3),
                                                                              filled: true,
                                                                              focusedBorder: const OutlineInputBorder(
                                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                borderSide: BorderSide(
                                                                                  width: 1,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                              enabledBorder: const OutlineInputBorder(
                                                                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                                                                borderSide: BorderSide(
                                                                                  width: 1,
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ),
                                                                              labelText: '${shop["titlesub"]}',
                                                                              labelStyle: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: Font_.Fonts_T)),
                                                                          // inputFormatters: <TextInputFormatter>[
                                                                          //   // for below version 2 use this
                                                                          //   FilteringTextInputFormatter
                                                                          //       .allow(RegExp(r'[0-9]')),
                                                                          //   // for version 2 and greater youcan also use this
                                                                          //   FilteringTextInputFormatter
                                                                          //       .digitsOnly
                                                                          // ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                ],
                                                              ),
                                                            )
                                                          : Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        2.0),
                                                                child:
                                                                    TextFormField(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  showCursor:
                                                                      false,
                                                                  readOnly:
                                                                      true,
                                                                  initialValue:
                                                                      '${shop["detail"]}',
                                                                  onFieldSubmitted:
                                                                      (value) async {},

                                                                  decoration:
                                                                      InputDecoration(
                                                                          fillColor: Colors.white.withOpacity(
                                                                              0.3),
                                                                          filled:
                                                                              true,
                                                                          focusedBorder:
                                                                              const OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(6)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              width: 1,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          enabledBorder:
                                                                              const OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(6)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey,
                                                                            ),
                                                                          ),
                                                                          // labelText: 'ระบุชื่อร้านค้า',
                                                                          labelStyle: const TextStyle(
                                                                              fontSize: 14,
                                                                              color: Colors.black54,
                                                                              fontFamily: Font_.Fonts_T)),
                                                                  // inputFormatters: <TextInputFormatter>[
                                                                  //   // for below version 2 use this
                                                                  //   FilteringTextInputFormatter
                                                                  //       .allow(RegExp(r'[0-9]')),
                                                                  //   // for version 2 and greater youcan also use this
                                                                  //   FilteringTextInputFormatter
                                                                  //       .digitsOnly
                                                                  // ],
                                                                ),
                                                              ),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            for (var cid in data_cid)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: SizedBox(
                                                  height: 40,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 16,
                                                            maxLines: 1,
                                                            '${cid["title"]}*',
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: TextFormField(
                                                            textAlign:
                                                                TextAlign.left,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            showCursor: false,
                                                            readOnly: true,
                                                            initialValue:
                                                                '${cid["detail"]}',
                                                            onFieldSubmitted:
                                                                (value) async {},

                                                            decoration:
                                                                InputDecoration(
                                                                    fillColor: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.3),
                                                                    filled:
                                                                        true,
                                                                    focusedBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    enabledBorder:
                                                                        const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(6)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    // labelText: 'ระบุชื่อร้านค้า',
                                                                    labelStyle: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black54,
                                                                        fontFamily:
                                                                            Font_.Fonts_T)),
                                                            // inputFormatters: <TextInputFormatter>[
                                                            //   // for below version 2 use this
                                                            //   FilteringTextInputFormatter
                                                            //       .allow(RegExp(r'[0-9]')),
                                                            //   // for version 2 and greater youcan also use this
                                                            //   FilteringTextInputFormatter
                                                            //       .digitsOnly
                                                            // ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ]),
                                        )),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppbackgroundColor
                                                            .TiTile_Colors
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0)),
                                                    // border: Border.all(color: Colors.grey, width: 1),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 16,
                                                          maxLines: 1,
                                                          'รูปภาพหลักฐานจากผู้เช่า/ผู้ค้า',
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
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                SizedBox(
                                                  // color:
                                                  //     Colors.brown[200],
                                                  child: Row(children: [
                                                    for (var imgpeople
                                                        in data_img_people)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 12,
                                                                maxFontSize: 16,
                                                                maxLines: 1,
                                                                '${imgpeople["title"]}',
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
                                                            Container(
                                                              height: 150,
                                                              width: 270,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppbackgroundColor
                                                                    .Sub_Abg_Colors,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            10),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          8.0),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          8.0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          8.0),
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  child:
                                                                      FittedBox(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    child: Image
                                                                        .asset(
                                                                      '${imgpeople["img"]}',
                                                                      height:
                                                                          180,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.brown[200],
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0)),
                                                    // border: Border.all(color: Colors.grey, width: 1),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 0, 0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 16,
                                                          maxLines: 1,
                                                          'รูปภาพหลักฐานการตรวจสอบข้อเท็จจริง',
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
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                SizedBox(
                                                  // color:
                                                  //     Colors.brown[200],
                                                  child: Row(children: [
                                                    for (var admin_imgpeople
                                                        in data_admin_img_people)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 12,
                                                                maxFontSize: 16,
                                                                maxLines: 1,
                                                                '${admin_imgpeople["title"]}',
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
                                                            Container(
                                                              height: 150,
                                                              width: 270,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppbackgroundColor
                                                                    .Sub_Abg_Colors,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            10),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              child: (admin_imgpeople[
                                                                          "img"]! ==
                                                                      '')
                                                                  ? const SizedBox(
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                  child: Icon(
                                                                                Icons.system_update_alt_outlined,
                                                                                size: 30,
                                                                                color: Colors.grey,
                                                                              ))
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  "คลิกหรือกด เพื่อเลือกไฟล์",
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: Font_.Fonts_T, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  "รองรับไฟล์ภาพ JPG หรือ PNG",
                                                                                  textAlign: TextAlign.center,
                                                                                  maxLines: 2,
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    color: Colors.grey,
                                                                                    fontFamily: Font_.Fonts_T,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  "ขนาดไฟล์สูงสุด: 10MB",
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    fontSize: 8,
                                                                                    color: Colors.grey,
                                                                                    fontFamily: Font_.Fonts_T,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : ClipRRect(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(8.0),
                                                                        topRight:
                                                                            Radius.circular(8.0),
                                                                        bottomLeft:
                                                                            Radius.circular(8.0),
                                                                        bottomRight:
                                                                            Radius.circular(8.0),
                                                                      ),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        child:
                                                                            FittedBox(
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          child:
                                                                              Image.asset(
                                                                            '${admin_imgpeople["img"]}',
                                                                            height:
                                                                                180,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ]),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Icon(
                                                          Icons.info,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 16,
                                                          maxLines: 1,
                                                          'โปรดแนบรูปเอกสารหลักฐานการตรวจสอบข้อเท็จจริงก่อนดำเนินการยืนยันเอกสารถูกต้อง',
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
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 40,
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
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                      const Color.fromARGB(
                                                          255, 243, 131, 130),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    SharedPreferences
                                                        preferences =
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
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            materialPageRoute,
                                                            (route) => false);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Translate
                                                        .TranslateAndSet_TextAutoSize(
                                                            'ปฏิเสธคำร้อง',
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
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                      Colors.black,
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    //     SharedPreferences preferences =
                                                    //     await SharedPreferences
                                                    //         .getInstance();
                                                    // String? _route = preferences
                                                    //     .getString('route');
                                                    // MaterialPageRoute
                                                    //     materialPageRoute =
                                                    //     MaterialPageRoute(
                                                    //         builder: (BuildContext
                                                    //                 context) =>
                                                    //             AdminScafScreen(
                                                    //                 route:
                                                    //                     'RequestDetails_CMM'));
                                                    // Navigator
                                                    //     .pushAndRemoveUntil(
                                                    //         context,
                                                    //         materialPageRoute,
                                                    //         (route) => false);

                                                    setState(() {
                                                      ser_tap = 2;
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Translate
                                                        .TranslateAndSet_TextAutoSize(
                                                            'ยืนยัน/ถัดไป',
                                                            ChaoAreaScreen_Color
                                                                .Colors_Text3_,
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
