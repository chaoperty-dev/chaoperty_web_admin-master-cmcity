import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

import '../Style/colors.dart';

class ReportUi2_Screen extends StatefulWidget {
  const ReportUi2_Screen({super.key});

  @override
  State<ReportUi2_Screen> createState() => _ReportUi2_ScreenState();
}

class _ReportUi2_ScreenState extends State<ReportUi2_Screen> {
  String rtser = '';
  int ser_pang_test = -7;
  int ser_pang = 0;
  ////////--------------------------->
  int ser_pang_CM = -2;
  int ser_pang_Ortor = -1;
  int ser_pang_Choice = -4;
  double Text_Size = 12.00;
  double Text_Size2 = 11.00;
  ////////--------------------------->

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.95,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              // border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    // color: Colors.black.withOpacity(0.58),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    // border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'รายงาน : ',
                          style: TextStyle(
                            fontSize: Text_Size,
                            color: ReportScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          }),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: (rtser.toString() == '65')
                                ? Row(
                                    children: [
                                      for (int index = 0; index < 3; index++)
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (index == 0) {
                                                  ser_pang_CM = -2;
                                                } else if (index == 1) {
                                                  ser_pang_CM = -1;
                                                } else {
                                                  ser_pang_CM = 0;
                                                }
                                              });
                                            },
                                            child: Container(
                                              width: 125,
                                              decoration: BoxDecoration(
                                                color: (ser_pang_CM == -2 &&
                                                        index == 0)
                                                    ? Colors.blueGrey
                                                    : (ser_pang_CM == -1 &&
                                                            index == 1)
                                                        ? Colors.blueGrey
                                                        : (ser_pang_CM == 0 &&
                                                                index == 2)
                                                            ? Colors.blueGrey
                                                            : Colors
                                                                .blueGrey[200],
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 20,
                                                  (index == 0)
                                                      ? 'Exclusive - A'
                                                      : (index == 1)
                                                          ? 'Exclusive - B'
                                                          : 'Exclusive - C',
                                                  style: TextStyle(
                                                    fontSize: Text_Size,
                                                    color: Colors.white,
                                                    // fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      for (int index = 1; index < 9; index++)
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                ser_pang_CM = index;
                                              });
                                            },
                                            child: Container(
                                              width: 100,
                                              decoration: BoxDecoration(
                                                // color: (ser_pang == index + 1 ||
                                                //         ser_pang + index == 0)
                                                //     ? Colors.black54
                                                //     : Colors.black26,
                                                color: (ser_pang_CM == index)
                                                    ? Colors.deepPurple
                                                    : Colors.deepPurple[200],
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: AutoSizeText(
                                                  minFontSize: 8,
                                                  maxFontSize: Text_Size,
                                                  'หน้า ${index}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    // fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  )
                                : (rtser.toString() == '72' ||
                                        rtser.toString() == '92' ||
                                        rtser.toString() == '93' ||
                                        rtser.toString() == '94')
                                    ? Row(
                                        children: [
                                          for (int index = 1;
                                              index < 3;
                                              index++)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (index == 0) {
                                                      ser_pang_Ortor = -2;
                                                    } else if (index == 1) {
                                                      ser_pang_Ortor = -1;
                                                    } else {
                                                      ser_pang_Ortor = 0;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  width: 125,
                                                  decoration: BoxDecoration(
                                                    color: (ser_pang_Ortor ==
                                                                -2 &&
                                                            index == 0)
                                                        ? Colors.blueGrey
                                                        : (ser_pang_Ortor ==
                                                                    -1 &&
                                                                index == 1)
                                                            ? Colors.blueGrey
                                                            : (ser_pang_Ortor ==
                                                                        0 &&
                                                                    index == 2)
                                                                ? Colors
                                                                    .blueGrey
                                                                : Colors.blueGrey[
                                                                    200],
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 2),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: Text_Size,
                                                      // 'Exclusive - A',
                                                      // (index == 0)
                                                      //     ? 'Exclusive - A'
                                                      //     :
                                                      (index == 1)
                                                          ? 'Exclusive - A'
                                                          : 'Exclusive - B',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          for (int index = 1;
                                              index < 9;
                                              index++)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    ser_pang_Ortor = index;
                                                  });
                                                },
                                                child: Container(
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    // color: (ser_pang == index + 1 ||
                                                    //         ser_pang + index == 0)
                                                    //     ? Colors.black54
                                                    //     : Colors.black26,
                                                    color: (ser_pang_Ortor ==
                                                            index)
                                                        ? Colors.deepPurple
                                                        : Colors
                                                            .deepPurple[200],
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 2),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Center(
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: Text_Size,
                                                      'หน้า ${index}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      )
                                    : (rtser.toString() == '106')
                                        ? Row(
                                            children: [
                                              for (int index = -4;
                                                  index < 1;
                                                  index++)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        ser_pang_Choice = index;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 125,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (ser_pang_Choice ==
                                                                    index)
                                                                ? Colors
                                                                    .teal[600]
                                                                : Colors
                                                                    .teal[200],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
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
                                                                  10),
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize:
                                                              Text_Size,
                                                          (index == -4)
                                                              ? 'Exclusive - A'
                                                              : (index == -3)
                                                                  ? 'Exclusive - B'
                                                                  : (index ==
                                                                          -2)
                                                                      ? 'Exclusive - C'
                                                                      : (index ==
                                                                              -1)
                                                                          ? 'Exclusive - D'
                                                                          : 'Exclusive - E',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              for (int index = 1;
                                                  index < 9;
                                                  index++)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        ser_pang_Choice = index;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                        // color: (ser_pang == index + 1 ||
                                                        //         ser_pang + index == 0)
                                                        //     ? Colors.black54
                                                        //     : Colors.black26,
                                                        color: (ser_pang_Choice ==
                                                                index)
                                                            ? Colors.deepPurple
                                                            : Colors.deepPurple[
                                                                200],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
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
                                                                  10),
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize:
                                                              Text_Size,
                                                          'หน้า ${index}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              // for (int index = 0;
                                              //     index < 10;
                                              //     index++)
                                              for (int index = 0;
                                                  index < 8;
                                                  index++)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        ser_pang = index + 1;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                        // color: (ser_pang == index + 1 ||
                                                        //         ser_pang + index == 0)
                                                        //     ? Colors.black54
                                                        //     : Colors.black26,
                                                        color: (ser_pang ==
                                                                    index + 1 ||
                                                                ser_pang +
                                                                        index ==
                                                                    0)
                                                            ? Colors.deepPurple
                                                            : Colors.deepPurple[
                                                                200],
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
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
                                                                  10),
                                                        ),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize:
                                                              Text_Size,
                                                          'หน้า ${index + 1}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.95,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[200],
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        // border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          for (int index = 0; index < 2; index++)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    ser_pang = index + 1;
                                  });
                                },
                                child: Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: AutoSizeText(
                                      minFontSize: 8,
                                      maxFontSize: Text_Size,
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                              child: Container(
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[200],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  // border: Border.all(color: Colors.grey, width: 1),
                                ),
                              )),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[200],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  // border: Border.all(color: Colors.grey, width: 1),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        for (int index = 0; index < 2; index++)
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  ser_pang = index + 1;
                                                });
                                              },
                                              child: Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    minFontSize: 8,
                                                    maxFontSize: Text_Size,
                                                    '${index + 1}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.grey, width: 1),
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
              ],
            )));
  }
}
