import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/Model/GetUser_Model.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';

class AdminSet_User extends StatefulWidget {
  const AdminSet_User({super.key});

  @override
  State<AdminSet_User> createState() => _AdminSet_UserState();
}

class _AdminSet_UserState extends State<AdminSet_User> {
  List<UserModel> userModels = [];
  List<UserModel> _userModels = <UserModel>[];
  int? ser_key, ser_index;
  int ser_tap = 0;
//////------------------------------>
  @override
  void initState() {
    super.initState();
    read_GC_User('0');
  }

  //////------------------------------>
  Future<Null> read_GC_User(tap) async {
    setState(() {
      userModels.clear();
      _userModels.clear();
    });
    String url = '${MyConstant().domain}/GC_set_user.php?isAdd=true&tap=$tap';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('read_GC_rental///// $result');
      for (var map in result) {
        UserModel userModelss = UserModel.fromJson(map);

        setState(() {
          userModels.add(userModelss);
        });
      }
      setState(() {
        _userModels = userModels;
      });
    } catch (e) {}
  }

/////////////------------------------------------------>
  _searchBarBody_1() {
    return TextField(
      textAlign: TextAlign.start,
      // controller: Text_searchBar_Main_Overdue,
      autofocus: false,
      cursorHeight: 20,
      keyboardType: TextInputType.text,
      style: const TextStyle(
          color: PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100]!.withOpacity(0.5),
        hintText: ' Search...',
        hintStyle: const TextStyle(
            // fontSize: 12,
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontFamily: Font_.Fonts_T),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (text) {
        var Text_searchBar2_ = text;
        // var Text_searchBar2_ = Text_searchBar_Main_Overdue.text.toLowerCase();
        setState(() {
          userModels = _userModels.where((Text_searchBar2_) {
            var notTitle1 = Text_searchBar2_.pn.toString();
            var notTitle2 = Text_searchBar2_.fname.toString();
            var notTitle3 = Text_searchBar2_.email.toString();

            return notTitle1.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text);
          }).toList();
        });
      },
    );
  }

/////////////------------------------------------------>
  _searchBarBody_2() {
    return TextField(
      textAlign: TextAlign.start,
      // controller: Text_searchBar_Main_Overdue,
      autofocus: false,
      cursorHeight: 20,
      keyboardType: TextInputType.text,
      style: const TextStyle(
          color: PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100]!.withOpacity(0.5),
        hintText: ' Search...',
        hintStyle: const TextStyle(
            // fontSize: 12,
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontFamily: Font_.Fonts_T),
        contentPadding:
            const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (text) {
        String searchText = text.toLowerCase().trim();
        // var Text_searchBar2_ = Text_searchBar_Main_Overdue.text.toLowerCase();
        setState(() {
          userModels = _userModels.where((Text_searchBar2_) {
            // Convert properties to lower case and trim them
            var notTitle1 =
                Text_searchBar2_.type.toString().toLowerCase().trim();
            var notTitle2 =
                Text_searchBar2_.fname.toString().toLowerCase().trim();
            var notTitle3 =
                Text_searchBar2_.lname.toString().toLowerCase().trim();

            // Check if any of the properties contain the search text
            return notTitle1.contains(searchText) ||
                notTitle2.contains(searchText) ||
                notTitle3.contains(searchText);
          }).toList();
        });
      },
    );
  }

  ///------------------------>
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'User',
              maxLines: 1,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: FontWeight_.Fonts_T,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '[ All ${userModels.length} ]',
              maxLines: 1,
              style: TextStyle(
                color: Colors.green,
                // fontWeight: FontWeight.bold,
                fontFamily: Font_.Fonts_T,
              ),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: InkWell(
              onTap: () {
                setState(() {
                  ser_tap = 0;
                  ser_key = null;
                  ser_index = null;
                });
                read_GC_User('0');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: (ser_tap != 0)
                      ? Colors.deepPurple.withOpacity(0.5)
                      : Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                  // border: Border.all(color: Colors.white, width: 1),
                ),
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Web-หลัก',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: InkWell(
              onTap: () {
                setState(() {
                  ser_tap = 1;
                  ser_key = null;
                  ser_index = null;
                });
                read_GC_User('1');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: (ser_tap == 0)
                      ? Colors.deepOrange.withOpacity(0.5)
                      : Colors.deepOrange,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                  // border: Border.all(color: Colors.white, width: 1),
                ),
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  'Web-Market',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Container(
        decoration: BoxDecoration(
          color: AppbackgroundColor.TiTile_Colors,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        padding: const EdgeInsets.all(8.0),
        child: (ser_tap == 1)
            ? Column(
                children: [
                  // Padding(
                  //     padding: const EdgeInsets.all(2.0),
                  //     child: Row(children: [
                  //       Padding(
                  //         padding: EdgeInsets.all(2.0),
                  //         child: Translate.TranslateAndSetText(
                  //             'ค้นหา :',
                  //             AccountScreen_Color.Colors_Text1_,
                  //             TextAlign.center,
                  //             FontWeight.bold,
                  //             FontWeight_.Fonts_T,
                  //             14,
                  //             1),
                  //       ),
                  //       Expanded(
                  //         // flex: 1,
                  //         child: Container(
                  //           height: 35, //Date_ser
                  //           // width: 150,
                  //           decoration: BoxDecoration(
                  //             color: AppbackgroundColor.Sub_Abg_Colors,
                  //             borderRadius: const BorderRadius.only(
                  //                 topLeft: Radius.circular(8),
                  //                 topRight: Radius.circular(8),
                  //                 bottomLeft: Radius.circular(8),
                  //                 bottomRight: Radius.circular(8)),
                  //             border: Border.all(color: Colors.grey, width: 1),
                  //           ),
                  //           child: _searchBarBody_2(),
                  //         ),
                  //       ),
                  //     ])),
                  Row(children: [
                    Container(
                      width: 50,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ลำดับ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ชื่อ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    // Expanded(
                    //   flex: 1,
                    //   child: AutoSizeText(
                    //     minFontSize: 8,
                    //     maxFontSize: 12,
                    //     maxLines: 1,
                    //     'Email',
                    //     textAlign: TextAlign.start,
                    //     style: TextStyle(
                    //         color: PeopleChaoScreen_Color.Colors_Text1_,
                    //         fontWeight: FontWeight.bold,
                    //         fontFamily: FontWeight_.Fonts_T
                    //         //fontSize: 10.0
                    //         //fontSize: 10.0
                    //         ),
                    //   ),
                    // ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'เบอร์ติดต่อ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ประเภท',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'Tax-ID',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'แก้ไขรหัสผ่าน',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ]),
                ],
              )
            : Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(children: [
                        Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Translate.TranslateAndSetText(
                              'ค้นหา :',
                              AccountScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              FontWeight.bold,
                              FontWeight_.Fonts_T,
                              14,
                              1),
                        ),
                        Expanded(
                          // flex: 1,
                          child: Container(
                            height: 35, //Date_ser
                            // width: 150,
                            decoration: BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: _searchBarBody_1(),
                          ),
                        ),
                      ])),
                  Row(children: [
                    Container(
                      width: 50,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ลำดับ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ตลาด',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ชื่อ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'ตำแหน่ง',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'สถานะ',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'Email',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 12,
                        maxLines: 1,
                        'แก้ไขรหัสผ่าน',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ]),
                ],
              ),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          height: Responsive.isDesktop(context)
              ? MediaQuery.of(context).size.height -
                  (MediaQuery.of(context).size.width * 0.1) -
                  80
              : MediaQuery.of(context).size.height * 0.95 -
                  (MediaQuery.of(context).size.width * 0.2) -
                  80,
          child: (ser_tap == 1)
              ? ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: userModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    var ttax = '${userModels[index].lname}';
                    return ListTile(
                        title: Container(
                            decoration: BoxDecoration(
                              color: (ser_index != index)
                                  ? null
                                  : Colors.orange[100]!.withOpacity(0.5),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(children: [
                              Container(
                                width: 50,
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  '${index + 1}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  '${userModels[index].fname}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: AutoSizeText(
                              //     minFontSize: 8,
                              //     maxFontSize: 12,
                              //     maxLines: 1,
                              //     '${userModels[index].email}',
                              //     textAlign: TextAlign.start,
                              //     style: TextStyle(
                              //         color:
                              //             PeopleChaoScreen_Color.Colors_Text2_,
                              //         //fontWeight: FontWeight.bold,
                              //         fontFamily: Font_.Fonts_T),
                              //   ),
                              // ),
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  '${userModels[index].tel}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  '${userModels[index].type}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Copy_Text(context, '${ttax}'),
                                    Expanded(
                                      child: Container(
                                        height: 50,
                                        child: TextFormField(
                                          initialValue: '${ttax}',
                                          //keyboardType: TextInputType.none,
                                          // obscureText: true,

                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.length < 12) {
                                              //   return 'ใส่ข้อมูลให้ครบถ้วน ';

                                              return 'Tax-Id!!';
                                            }
                                            // if (int.parse(value.toString()) < 13) {
                                            //   return '< 13';
                                            // }
                                            return null;
                                          },

                                          onFieldSubmitted: (value) async {
                                            setState(() {
                                              ser_index = index;
                                            });
                                            // var password = value.toString() == ''
                                            //     ? userModels[index].passwd
                                            //     : md5
                                            //         .convert(utf8
                                            //             .encode(value.toString()))
                                            //         .toString();
                                            if (value.toString() != '' &&
                                                value.length == 13) {
                                              try {
                                                final url =
                                                    '${MyConstant().domain}/UP_set_user.php?isAdd=true';

                                                final response =
                                                    await http.post(
                                                  Uri.parse(url),
                                                  body: {
                                                    'ser_id':
                                                        '${userModels[index].ser}',
                                                    'email_id': '',
                                                    'passw': '',
                                                    'tax_id':
                                                        '${userModels[index].lname}',
                                                    'tx':
                                                        '${value.toString().trim()}',
                                                    'tap': '2',
                                                  },
                                                );
                                                var result =
                                                    json.decode(response.body);
                                                if (result.toString() ==
                                                    'true') {
                                                  setState(() {
                                                    ser_key = null;
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        backgroundColor:
                                                            Colors.green,
                                                        content: Text(
                                                            '${index + 1}). ${userModels[index].fname} แก้ไขTax-Id เสร็จสิ้น !',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: Font_
                                                                    .Fonts_T))),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          (value.length < 12)
                                                              ? 'แก้ไขTax-Id ผิดพลาด รหัส < 13 กรุณาลองใหม่!'
                                                              : 'แก้ไขTax-Id ผิดพลาด กรุณาลองใหม่!',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: Font_
                                                                  .Fonts_T))),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                        (value.length < 12)
                                                            ? 'แก้ไขTax-Id ผิดพลาด รหัส < 13 กรุณาลองใหม่!'
                                                            : 'แก้ไขTax-Id ผิดพลาด กรุณาลองใหม่!',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: Font_
                                                                .Fonts_T))),
                                              );
                                            }
                                          },
                                          // maxLength: 13,
                                          cursorColor: Colors.green,
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Colors.white.withOpacity(0.3),
                                              filled: true,
                                              // prefixIcon:
                                              //     const Icon(Icons.key, color: Colors.black),
                                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              errorStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: Font_.Fonts_T),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              // labelText: 'PASSWORD',
                                              labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontFamily: Font_.Fonts_T)),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[800],
                                              fontFamily: Font_.Fonts_T),
                                          inputFormatters: <TextInputFormatter>[
                                            // for below version 2 use this
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                            // for version 2 and greater youcan also use this
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),

                                      //  Tooltip(
                                      //   richMessage: TextSpan(
                                      //     text: '${userModels[index].lname}',
                                      //     style: const TextStyle(
                                      //       color:
                                      //           HomeScreen_Color.Colors_Text1_,
                                      //       fontWeight: FontWeight.bold,
                                      //       fontFamily: FontWeight_.Fonts_T,
                                      //       //fontSize: 10.0
                                      //     ),
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     borderRadius:
                                      //         BorderRadius.circular(5),
                                      //     color: Colors.grey[200],
                                      //   ),
                                      //   child: Text(
                                      //     // minFontSize: 8,
                                      //     // maxFontSize: 14,
                                      //     maxLines: 1,
                                      //     '${userModels[index].lname}',
                                      //     textAlign: TextAlign.start,
                                      //     style: TextStyle(
                                      //         fontSize: 13,
                                      //         color: Colors.blue[800],
                                      //         // fontWeight: FontWeight.bold,
                                      //         fontFamily: FontWeight_.Fonts_T),
                                      //   ),
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: (ser_key != index)
                                    ? Center(
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                ser_key = index;
                                                ser_index = index;
                                              });
                                            },
                                            child: Icon(Icons.key,
                                                color: Colors.red[900])))
                                    : Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade200,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8)),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: TextFormField(
                                                //keyboardType: TextInputType.none,
                                                // obscureText: true,

                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      value.length < 6) {
                                                    //   return 'ใส่ข้อมูลให้ครบถ้วน ';

                                                    return ' Password!!';
                                                  }
                                                  // if (int.parse(value.toString()) < 13) {
                                                  //   return '< 13';
                                                  // }
                                                  return null;
                                                },

                                                onFieldSubmitted:
                                                    (value) async {
                                                  var password = value
                                                              .toString() ==
                                                          ''
                                                      ? userModels[index].passwd
                                                      : md5
                                                          .convert(utf8.encode(
                                                              value.toString()))
                                                          .toString();
                                                  if (value.toString() != '' &&
                                                      value.length > 5) {
                                                    try {
                                                      final url =
                                                          '${MyConstant().domain}/UP_set_user.php?isAdd=true';

                                                      final response =
                                                          await http.post(
                                                        Uri.parse(url),
                                                        body: {
                                                          'ser_id':
                                                              '${userModels[index].ser}',
                                                          'email_id': '',
                                                          'passw': '$password',
                                                          'tax_id':
                                                              '${userModels[index].lname}',
                                                          'tap': '1',
                                                        },
                                                      );
                                                      var result = json.decode(
                                                          response.body);
                                                      if (result.toString() ==
                                                          'true') {
                                                        setState(() {
                                                          ser_key = null;
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              content: Text(
                                                                  '${index + 1}). ${userModels[index].fname} แก้ไขรหัสเสร็จสิ้น !',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T))),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            content: Text(
                                                                (value.length <
                                                                        6)
                                                                    ? 'แก้ไขรหัส ผิดพลาด รหัส < 6 กรุณาลองใหม่!'
                                                                    : 'แก้ไขรหัส ผิดพลาด กรุณาลองใหม่!',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T))),
                                                      );
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          content: Text(
                                                              (value.length < 6)
                                                                  ? 'แก้ไขรหัส ผิดพลาด รหัส < 6 กรุณาลองใหม่!'
                                                                  : 'แก้ไขรหัส ผิดพลาด กรุณาลองใหม่!',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily: Font_
                                                                      .Fonts_T))),
                                                    );
                                                  }
                                                },
                                                // maxLength: 13,
                                                cursorColor: Colors.green,
                                                decoration: InputDecoration(
                                                    fillColor: Colors.white
                                                        .withOpacity(0.3),
                                                    filled: true,
                                                    // prefixIcon:
                                                    //     const Icon(Icons.key, color: Colors.black),
                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(8),
                                                        topLeft:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                      ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    errorStyle: TextStyle(
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(8),
                                                        topLeft:
                                                            Radius.circular(8),
                                                        bottomRight:
                                                            Radius.circular(8),
                                                        bottomLeft:
                                                            Radius.circular(8),
                                                      ),
                                                      borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    // labelText: 'PASSWORD',
                                                    labelStyle: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black54,
                                                        fontFamily:
                                                            Font_.Fonts_T)),
                                                // inputFormatters: <TextInputFormatter>[
                                                //   // for below version 2 use this
                                                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                //   // for version 2 and greater youcan also use this
                                                //   FilteringTextInputFormatter.digitsOnly
                                                // ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -1,
                                            right: 0,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  ser_key = null;
                                                  ser_index = null;
                                                });
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 10,
                                                child: Icon(
                                                  Icons.highlight_off,
                                                  color: Colors.red[900],
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                              ),
                              if (ser_index != index)
                                Center(
                                    child: InkWell(
                                        onTap: () async {
                                          try {
                                            final url =
                                                '${MyConstant().domain}/UP_set_user.php?isAdd=true';

                                            final response = await http.post(
                                              Uri.parse(url),
                                              body: {
                                                'ser_id':
                                                    '${userModels[index].ser}',
                                                'email_id': '',
                                                'passw': '',
                                                'tax_id':
                                                    '${userModels[index].lname}',
                                                'tap': '1',
                                                'logout': 'OK',
                                              },
                                            );
                                            var result =
                                                json.decode(response.body);
                                            if (result.toString() == 'true') {
                                              setState(() {
                                                ser_key = null;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    content: Text(
                                                        '${index + 1}). ${userModels[index].fname} Log out เสร็จสิ้น !',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: Font_
                                                                .Fonts_T))),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      'Log out ผิดพลาด กรุณาลองใหม่!',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              Font_.Fonts_T))),
                                            );
                                          }
                                        },
                                        child: Icon(Icons.logout,
                                            color: Colors.grey[600])))
                            ])));
                  })
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: userModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    String connected_ = '${userModels[index].connected}';

                    DateTime connectedTime = DateTime.parse(connected_);

                    DateTime currentTime = DateTime.now();

                    Duration difference = currentTime.difference(connectedTime);

                    int minutesPassed = difference.inMinutes;
                    return ListTile(
                        title: Container(
                      decoration: BoxDecoration(
                        color: (ser_index != index)
                            ? null
                            : Colors.deepPurple[100]!.withOpacity(0.5),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(children: [
                        Container(
                          width: 50,
                          child: (userModels[index].rser.toString() == '0')
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.purple,
                                  ),
                                )
                              : AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  '${index + 1}',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color:
                                          (userModels[index].type.toString() ==
                                                  '@min')
                                              ? Colors.green[800]
                                              : PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                        ),
                        Expanded(
                          flex: 1,
                          child:
                              // (userModels[index].type.toString() =='@min')?
                              // :
                              AutoSizeText(
                            minFontSize: 8,
                            maxFontSize: 12,
                            maxLines: 1,
                            (userModels[index].type.toString() == '@min')
                                ? '@Min_Chaoperty'
                                : '${userModels[index].pn} ',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: (userModels[index].type.toString() ==
                                        '@min')
                                    ? Colors.green[800]
                                    : PeopleChaoScreen_Color.Colors_Text2_,
                                // fontWeight:
                                //     (userModels[index].type.toString() == '@min')
                                //         ? FontWeight.bold
                                //         : null,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: AutoSizeText(
                            minFontSize: 8,
                            maxFontSize: 12,
                            maxLines: 1,
                            '${userModels[index].fname} ${userModels[index].lname}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: (userModels[index].type.toString() ==
                                        '@min')
                                    ? Colors.green[800]
                                    : PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: AutoSizeText(
                            minFontSize: 8,
                            maxFontSize: 12,
                            maxLines: 1,
                            '${userModels[index].position}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: (userModels[index].type.toString() ==
                                        '@min')
                                    ? Colors.green[800]
                                    : PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Icon(
                                  (minutesPassed > 1)
                                      ? Icons.motion_photos_off_rounded
                                      : Icons.motion_photos_on_rounded,
                                  color: (minutesPassed > 1)
                                      ? Colors.grey
                                      : Colors.blue[400]),
                              Expanded(
                                flex: 2,
                                child: AutoSizeText(
                                  minFontSize: 8,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  (minutesPassed > 1)
                                      ? (minutesPassed > 60)
                                          ? 'ออกจากระบบ'
                                          : 'ใช้งานเมื่อ $minutesPassed นาทีที่แล้ว'
                                      : ' ${userModels[index].connected}',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child: AutoSizeText(
                        //     minFontSize: 8,
                        //     maxFontSize: 12,
                        //     maxLines: 1,
                        //     '${userModels[index].position} ',
                        //     textAlign: TextAlign.start,
                        //     style: const TextStyle(
                        //         color: PeopleChaoScreen_Color.Colors_Text2_,
                        //         //fontWeight: FontWeight.bold,
                        //         fontFamily: Font_.Fonts_T),
                        //   ),
                        // ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Copy_Text(context, '${userModels[index].email}'),
                              Expanded(
                                child: Tooltip(
                                  richMessage: TextSpan(
                                    text: '${userModels[index].email}',
                                    style: const TextStyle(
                                      color: HomeScreen_Color.Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T,
                                      //fontSize: 10.0
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey[200],
                                  ),
                                  child: Text(
                                    // minFontSize: 8,
                                    // maxFontSize: 14,
                                    maxLines: 1,
                                    '${userModels[index].email}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: (userModels[index]
                                                    .type
                                                    .toString() ==
                                                '@min')
                                            ? Colors.green[800]
                                            : Colors.deepOrange[800],
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: FontWeight_.Fonts_T),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: (ser_key != index)
                              ? Center(
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          ser_key = index;
                                          ser_index = index;
                                        });
                                      },
                                      child: Icon(Icons.key,
                                          color: Colors.deepPurple[900])))
                              : Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade200,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(2.0),
                                        child: TextFormField(
                                          //keyboardType: TextInputType.none,
                                          // obscureText: true,

                                          validator: (value) {
                                            if (value == null || value.isEmpty
                                                // || value.length < 13
                                                ) {
                                              //   return 'ใส่ข้อมูลให้ครบถ้วน ';

                                              return ' Password!!';
                                            }
                                            // if (int.parse(value.toString()) < 13) {
                                            //   return '< 13';
                                            // }
                                            return null;
                                          },

                                          onFieldSubmitted: (value) async {
                                            var password =
                                                value.toString() == ''
                                                    ? userModels[index].passwd
                                                    : md5
                                                        .convert(utf8.encode(
                                                            value.toString()))
                                                        .toString();
                                            if (value.toString() != '') {
                                              try {
                                                final url =
                                                    '${MyConstant().domain}/UP_set_user.php?isAdd=true';

                                                final response =
                                                    await http.post(
                                                  Uri.parse(url),
                                                  body: {
                                                    'ser_id':
                                                        '${userModels[index].ser}',
                                                    'email_id':
                                                        '${userModels[index].email}',
                                                    'passw': '$password',
                                                    'tax_id': '',
                                                    'tap': '0',
                                                  },
                                                );
                                                var result =
                                                    json.decode(response.body);
                                                if (result.toString() ==
                                                    'true') {
                                                  setState(() {
                                                    ser_key = null;
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        backgroundColor:
                                                            Colors.green,
                                                        content: Text(
                                                            '${index + 1}). ${userModels[index].email} แก้ไขรหัสเสร็จสิ้น !',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily: Font_
                                                                    .Fonts_T))),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          'แก้ไขรหัส ผิดพลาด กรุณาลองใหม่!',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily: Font_
                                                                  .Fonts_T))),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                        'แก้ไขรหัส ผิดพลาด กรุณาลองใหม่!',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: Font_
                                                                .Fonts_T))),
                                              );
                                            }
                                          },
                                          // maxLength: 13,
                                          cursorColor: Colors.green,
                                          decoration: InputDecoration(
                                              fillColor:
                                                  Colors.white.withOpacity(0.3),
                                              filled: true,
                                              // prefixIcon:
                                              //     const Icon(Icons.key, color: Colors.black),
                                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              errorStyle: TextStyle(
                                                  fontFamily: Font_.Fonts_T),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              // labelText: 'PASSWORD',
                                              labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontFamily: Font_.Fonts_T)),
                                          // inputFormatters: <TextInputFormatter>[
                                          //   // for below version 2 use this
                                          //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                          //   // for version 2 and greater youcan also use this
                                          //   FilteringTextInputFormatter.digitsOnly
                                          // ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -1,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            ser_key = null;
                                            ser_index = null;
                                          });
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 10,
                                          child: Icon(
                                            Icons.highlight_off,
                                            color: Colors.red[900],
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        if (ser_index != index)
                          Center(
                              child: InkWell(
                                  onTap: () async {
                                    try {
                                      final url =
                                          '${MyConstant().domain}/UP_set_user.php?isAdd=true';

                                      final response = await http.post(
                                        Uri.parse(url),
                                        body: {
                                          'ser_id': '${userModels[index].ser}',
                                          'email_id':
                                              '${userModels[index].email}',
                                          'passw': '',
                                          'tax_id': '',
                                          'tap': '0',
                                          'logout': 'OK',
                                        },
                                      );
                                      var result = json.decode(response.body);
                                      if (result.toString() == 'true') {
                                        setState(() {
                                          ser_key = null;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                  '${index + 1}). ${userModels[index].email} Log out เสร็จสิ้น !',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                          Font_.Fonts_T))),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'Log out ผิดพลาด กรุณาลองใหม่!',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        Font_.Fonts_T))),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.logout,
                                      color: Colors.grey[600])))
                      ]),
                    ));
                  }))
    ]));
  }
}
