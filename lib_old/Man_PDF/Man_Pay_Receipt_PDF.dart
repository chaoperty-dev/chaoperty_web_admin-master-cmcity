import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Model/Read_DataONBill_PDF_Model.dart';
import '../Model/electricity_model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../PDF/PDF_Receipt/pdf_AC_his_statusbill.dart';

import '../PDF/nim/PDF_Receipt_TP7_nim/pdf_AC_his_statusbill_TP7_nim.dart';
import '../PDF_TP10/PDF_Receipt_TP10/pdf_AC_his_statusbill_TP10.dart';
import '../PDF_TP2/PDF_Receipt_TP2/pdf_AC_his_statusbill_TP2.dart';
import '../PDF_TP3/PDF_Receipt_TP3/pdf_AC_his_statusbill_TP3.dart';
import '../PDF_TP4/PDF_Receipt_TP4/pdf_AC_his_statusbill_TP4.dart';
import '../PDF_TP5/PDF_Receipt_TP5/pdf_AC_his_statusbill_TP5.dart';
import '../PDF_TP6/PDF_Receipt_TP6/pdf_AC_his_statusbill_TP6.dart';
import '../PDF_TP7/PDF_Receipt_TP7/pdf_AC_his_statusbill_TP7.dart';
import '../PDF/LAMPHUN/PDF_Receipt_TP7_LAMPHUN/pdf_AC_his_statusbill_TP7_LAMPHUN.dart';
import '../PDF_TP7_Ama1000/PDF_Receipt_TP7/pdf_AC_his_statusbill_TP7.dart';
import '../PDF_TP8/PDF_Receipt_TP8/pdf_AC_his_statusbill_TP8.dart';
import '../PDF_TP8_Choice/PDF_Receipt_TP8_Choice/pdf_AC_his_statusbill_TP8_Choice.dart';
import '../PDF_TP9/PDF_Receipt_TP9/pdf_AC_his_statusbill_TP9.dart';
import '../PDF_TP9_Lao/PDF_Receipt_TP9/pdf_AC_his_statusbill_TP9.dart';
import '../PDF_TP8_Ortorkor/PDF_Receipt_TP8_Ortorkor/pdf_AC_his_statusbill_TP8.dart';
import '../Style/loadAndCacheImage.dart';

class ManPay_Receipt_PDF {
  // ─────────────────────────────────────────────────────────────────
  // Dialog เลือกขนาดกระดาษก่อน Export PDF (ใช้ร่วมได้ทุกเทมเพลต PDF)
  // คืนค่า: 'pos80' | 'pos58' | 'a3' | 'a4' | 'a5'
  // คืนค่า null = ผู้ใช้กด ยกเลิก
  // เรียกใช้: await ManTemporary_Receipt_PDF.showPageFormatDialog(context)
  // ─────────────────────────────────────────────────────────────────
  static Future<String?> showPageFormatDialog(BuildContext context) {
    return Future.value('a4');
    // return showDialog<String>(
    //   context: context,
    //   barrierDismissible: true,
    //   builder: (ctx) {
    //     final options = [
    //       // {
    //       //   'mode': 'pos80',
    //       //   'icon': Icons.receipt_long,
    //       //   'label': 'POS 80 mm',
    //       //   'sub': 'กระดาษม้วน 80 mm'
    //       // },
    //       // {
    //       //   'mode': 'pos58',
    //       //   'icon': Icons.receipt,
    //       //   'label': 'POS 58 mm',
    //       //   'sub': 'กระดาษม้วน 58 mm'
    //       // },
    //       // {
    //       //   'mode': 'a3',
    //       //   'icon': Icons.picture_as_pdf,
    //       //   'label': 'A3',
    //       //   'sub': '297 × 420 mm'
    //       // },
    //       {
    //         'mode': 'a4',
    //         'icon': Icons.picture_as_pdf,
    //         'label': 'A4',
    //         'sub': '210 × 297 mm (มาตรฐาน)'
    //       },
    //       // {
    //       //   'mode': 'a5',
    //       //   'icon': Icons.picture_as_pdf,
    //       //   'label': 'A5',
    //       //   'sub': '148 × 210 mm'
    //       // },
    //     ];
    //     return AlertDialog(
    //       shape:
    //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //       title: Row(
    //         children: const [
    //           Icon(Icons.print_outlined, color: Color(0xFF3B82F6)),
    //           SizedBox(width: 8),
    //           Text('เลือกขนาดกระดาษ',
    //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    //         ],
    //       ),
    //       contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
    //       content: SizedBox(
    //         width: 320,
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: options.map((o) {
    //             return Card(
    //               elevation: 0,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(10),
    //                 side: BorderSide(color: Colors.grey.shade200),
    //               ),
    //               child: ListTile(
    //                 leading: Icon(o['icon'] as IconData,
    //                     color: const Color(0xFF3B82F6)),
    //                 title: Text(o['label'] as String,
    //                     style: const TextStyle(fontWeight: FontWeight.w600)),
    //                 subtitle: Text(o['sub'] as String,
    //                     style: const TextStyle(fontSize: 11)),
    //                 onTap: () => Navigator.pop(ctx, o['mode'] as String),
    //               ),
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(ctx, null),
    //           child: const Text('ยกเลิก',
    //               style: TextStyle(color: Colors.redAccent)),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  // --------------------------------> PDF หลังรับชำระ และ ประวัติบิล
  static void ManPayReceipt_PDF(
      docno, ////----->เลขที่รับชำระ
      context, ////----->context
      foder, ////----->foder
      renTal_name,
      // sname, ////----->ชื่อร้าน
      // cname, ////----->ชื่อผู้ติดต่อ
      // addr, ////----->ที่อยู่
      // tax, ////----->เลขประจำตัวผู้เสียภาษี
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      TitleType_Default_Receipt_Name, //->หัวบิล [ต้นฉับับ  สำเนา ไม่ระบุ]

      tem_page_ser,

      ///----->ser เทมเพลต
      bills_name,
      Preview_ser) async {
    print('GC_Data_OnBill_PDF>>>> ManPay_Receipt_PDF');
    List<FinnancetransModel> finnancetransModels = [];
    List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
    List<ElectricityModel> Water_electricity = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var rtser = preferences.getString('renTalSer');
    var rt_Language = preferences.getString('renTal_Language');
    var user = preferences.getString('ser');
    var fname;
    var email = preferences.getString('email');
    var ciddoc = '';
    var qutser = '';
    var docnoin = docno;
    var pdate;

    var fonts_pdf = (rt_Language.toString().trim() == 'LA')
        ? await 'fonts/NotoSansLao.ttf'
        : await 'fonts/THSarabunNew.ttf';
    var nFormat = (rt_Language.toString().trim() == 'LA')
        ? NumberFormat("#,##0", "en_US")
        : NumberFormat("#,##0.00", "en_US");
    String? Cust_no, Ln_s, Lncode, Ln_c, Zone_s, Form_lncode;
    String Con_remark = '';
    double sum_pvat = 0.00,
        sum_vat = 0.00,
        sum_wht = 0.00,
        sum_amt = 0.00,
        sum_dis = 0.00,
        sum_disamt = 0.00,
        sum_addvat_choice = 0.00,
        sum_disp = 0,
        dis_sum_Matjum = 0.00,
        dis_sum_Pakan = 0.00,
        sum_fee = 0.00,
        sum_total = 0.00,
        sum_net_amount_pvat = 0.00,
        sum_net_non_pvat = 0.00;

    // double sum_addvat = 0.00, sum_Nonvat = 0.00;
    String numinvoice = '';
    String numdoctax = '';
    List<String> ref_invoice = [];
    String com_ment = '';
    var scname_,
        cname_,
        addr_,
        tax_,
        tel_,
        email_,
        stype_,
        type_,
        ser_user,
        img_logo;
    var docno_,
        doctax_,
        cid_,
        datex_,
        znn_,
        daterec_,
        dateacc_,
        expname_,
        room_number_,
        date_Transaction,
        date_pay,
        Howto_LockJonPay;
    /////////////////////------------------------->
    var round_p, paper, paper_run, amt_up, vat_up;

    // print('$docno ///  $docnoin docnoindocnoin');
    //  String url = '${MyConstant().domain}/files/$foder/logo/$img_logo';
/////////////////////------------------------->
    String url_1 =
        '${MyConstant().domain}/GC_Data_OnBill_PDF.php?isAdd=true&ren=$ren&ciddoc=$docnoin';
    try {
      var response = await http.get(Uri.parse(url_1));
      var result = json.decode(response.body);

      print(url_1);

      if (result.toString() != 'null') {
        // print('GC_Data_OnBill_PDF>>>> $result');
        for (var map in result) {
          Read_DataONBill_PDFModel readDataONBillPDFModels =
              Read_DataONBill_PDFModel.fromJson(map);

          scname_ = (readDataONBillPDFModels.scname == null ||
                  readDataONBillPDFModels.scname.toString() == '' ||
                  readDataONBillPDFModels.scname == '')
              ? readDataONBillPDFModels.remark
              : readDataONBillPDFModels.scname;
          cname_ = readDataONBillPDFModels.cname;
          addr_ = readDataONBillPDFModels.addr1;
          tax_ = readDataONBillPDFModels.tax;
          tel_ = readDataONBillPDFModels.tel;
          email_ = readDataONBillPDFModels.email;
          stype_ = readDataONBillPDFModels.stype;
          type_ = readDataONBillPDFModels.type;
          Zone_s = (readDataONBillPDFModels.zn == null)
              ? readDataONBillPDFModels.znn
              : readDataONBillPDFModels.zn;
          Ln_s = (readDataONBillPDFModels.ln == null)
              ? readDataONBillPDFModels.room_number
              : readDataONBillPDFModels.ln;
          Lncode = (readDataONBillPDFModels.lncode == null)
              ? ''
              : readDataONBillPDFModels.lncode;
          Ln_c = (readDataONBillPDFModels.ln_c == null)
              ? ''
              : readDataONBillPDFModels.ln_c;
          if (ren.toString() == '106') {
            ser_user = readDataONBillPDFModels.user_updata;
          } else {
            ser_user = readDataONBillPDFModels.user;
          }

          docno_ = readDataONBillPDFModels.docno;
          doctax_ = readDataONBillPDFModels.doctax!;
          cid_ = readDataONBillPDFModels.cid;
          daterec_ = readDataONBillPDFModels.daterec;
          dateacc_ = readDataONBillPDFModels.dateacc;
          room_number_ = readDataONBillPDFModels.room_number;
          date_Transaction = readDataONBillPDFModels.daterec;
          date_pay = readDataONBillPDFModels.pdate;
          Howto_LockJonPay = readDataONBillPDFModels.room_number;
          Cust_no = readDataONBillPDFModels.custno;
          Con_remark = (readDataONBillPDFModels.con_remark == null)
              ? ''
              : readDataONBillPDFModels.con_remark!;

          round_p = readDataONBillPDFModels.round_p;
          paper = readDataONBillPDFModels.paper;
          paper_run = readDataONBillPDFModels.paper_run;
          amt_up = readDataONBillPDFModels.amt_up;
          vat_up = readDataONBillPDFModels.vat_up;

          // print(
          //     'GC_Data_OnBill_PDF //dateaccdateaccdateaccdateacc ::  ${readDataONBillPDFModels.dateacc!}_');
        }
      }
    } catch (e) {}
/////////////////////------------------------->
    String url_paper_run =
        '${MyConstant().domain}/UP_Paper_Run.php?isAdd=true&ren=$ren&ciddoc=$docnoin&paper_run=${int.parse((paper_run == null) ? '0' : '$paper_run') + 1}';
    try {
      var response = await http.get(Uri.parse(url_paper_run));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {}
    } catch (e) {}

/////////////////////------------------------->
    String url_usersell =
        '${MyConstant().domain}/GC_User_PDF.php?isAdd=true&serUser=$ser_user';
    print('url_usersell $url_usersell');
    try {
      var response = await http.get(Uri.parse(url_usersell));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        if (rtser.toString() == '145') {
          for (var map in result) {
            UserModel userModel = UserModel.fromJson(map);
            fname = '${userModel.fname} ${userModel.lname}';
          }
        } else {
          for (var map in result) {
            UserModel userModel = UserModel.fromJson(map);
            fname = '[${userModel.ser}] ${userModel.fname} ${userModel.lname}';
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    // print('$scname_ $cname_ $addr_');
//////////////////////-------------------------------------------->
    String url =
        '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    print('BBBBBBBBBBBBBBBB>>>> $url');
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      ///  print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;
          com_ment = finnancetransModel.descr!;
          if (int.parse(finnancetransModel.receiptSer!) != 0) {
            finnancetransModels.add(finnancetransModel);
            pdate = pdatex;
          } else {
            if (finnancetransModel.type!.trim() == 'DISCOUNT') {
              sum_disamt = sidamt;
              sum_disp = siddisper;
            }
          }
          if (finnancetransModel.dtype! == 'MM') {
            dis_sum_Matjum =
                dis_sum_Matjum + double.parse(finnancetransModel.amt!);
          }
          if (finnancetransModel.dtype! == 'KF') {
            dis_sum_Pakan =
                dis_sum_Pakan + double.parse(finnancetransModel.amt!);
          }
          if (finnancetransModel.dtype! == 'FTA') {
            sum_fee = sum_fee + double.parse(finnancetransModel.amt!);
          }
          // print(
          //     '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
        FinnancetransModel itemToMove =
            finnancetransModels.firstWhere((model) => model.remark != '');

// Remove the item from the list
        finnancetransModels.remove(itemToMove);

// Add the item to the bottom of the list
        finnancetransModels.add(itemToMove);
      }
    } catch (e) {}
//////////////////////-------------------------------------------->
    if (_TransReBillHistoryModels.length != 0) {
      _TransReBillHistoryModels.clear();
      Water_electricity.clear();
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
    }
    String url2 = (ren == '148')
        ? '${MyConstant().domain}/LP_JATUJAK_API/GC_billPay_LPJATUJAK_historyPDF.php?isAdd=true&ren=$ren&user=$user&ciddoc=$cid_&docnoin=$docnoin' // link lamphun
        : '${MyConstant().domain}/GC_billPay_historyPDF_v2.php?isAdd=true&ren=$ren&user=$user&ciddoc=$cid_&docnoin=$docnoin';

    // String url2 =
    //     '${MyConstant().domain}/GC_bill_pay_historyPDF.php?isAdd=true&ren=$ren&user=$user&ciddoc=$cid_&docnoin=$docnoin';
    print(url2);
    try {
      var response = await http.get(Uri.parse(url2));

      var result = json.decode(response.body);

      // print(url2);
      if (result.toString() != 'null') {
        //  print('dtypeinvoiceent /// ');
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);
          var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
          var numinvoiceent = _TransReBillHistoryModel.docno;
          var docnotax = _TransReBillHistoryModel.doctax;
          numinvoice = _TransReBillHistoryModel.docno!;
          numdoctax = _TransReBillHistoryModel.doctax!;
          if (_TransReBillHistoryModel.inv != null &&
              !ref_invoice.contains(_TransReBillHistoryModel.inv!)) {
            ref_invoice.add(_TransReBillHistoryModel.inv!);
          }
          // ref_invoice.add(_TransReBillHistoryModel.inv!);

          var sum_net_amount_pvatx =
              (_TransReBillHistoryModel.net_amount_pvat == null)
                  ? 0.00
                  : double.parse(_TransReBillHistoryModel.net_amount_pvat!);
          var sum_net_non_pvatx =
              (_TransReBillHistoryModel.net_non_pvat == null)
                  ? 0.00
                  : double.parse(_TransReBillHistoryModel.net_non_pvat!);

          sum_net_amount_pvat = sum_net_amount_pvat + sum_net_amount_pvatx;
          sum_net_non_pvat = sum_net_non_pvat + sum_net_non_pvatx;

          _TransReBillHistoryModels.add(_TransReBillHistoryModel);
        }
        ref_invoice.sort();
      }
    } catch (e) {
      print('catch');
    }

    //////////////////////-------------------------------------------->
    // if (_TransReBillHistoryModels.length != 0) {
    //   _TransReBillHistoryModels.clear();
    //   Water_electricity.clear();
    //   sum_pvat = 0;
    //   sum_vat = 0;
    //   sum_wht = 0;
    //   sum_amt = 0;
    // }
    // String url2 =
    //     '${MyConstant().domain}/GC_billPay_historyPDF_v2.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // // String url2 =
    // //     '${MyConstant().domain}/GC_bill_pay_historyPDF.php?isAdd=true&ren=$ren&user=$user&ciddoc=$cid_&docnoin=$docnoin';
    // print(url2);
    // try {
    //   var response = await http.get(Uri.parse(url2));

    //   var result = json.decode(response.body);

    //   // print(url2);
    //   if (result.toString() != 'null') {
    //     //  print('dtypeinvoiceent /// ');
    //     for (var map in result) {
    //       TransReBillHistoryModel _TransReBillHistoryModel =
    //           TransReBillHistoryModel.fromJson(map);
    //       var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
    //       var numinvoiceent = _TransReBillHistoryModel.docno;
    //       // var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
    //       // var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
    //       // var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
    //       // var sumAmtx = double.parse(_TransReBillHistoryModel.total!);

    //       var sum_pvatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
    //           ? double.parse(_TransReBillHistoryModel.dis!) != 0
    //               ? double.parse(_TransReBillHistoryModel.pvat!) -
    //                   double.parse(_TransReBillHistoryModel.dis!)
    //               : double.parse(_TransReBillHistoryModel.pvat!)
    //           : 0.0;
    //       var sum_vatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
    //           ? double.parse(_TransReBillHistoryModel.vat!)
    //           : 0.0;
    //       var sum_whtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
    //           ? double.parse(_TransReBillHistoryModel.wht!)
    //           : 0.0;
    //       var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
    //           ? double.parse(_TransReBillHistoryModel.dis!) != 0
    //               ? double.parse(_TransReBillHistoryModel.pvat!) +
    //                   double.parse(_TransReBillHistoryModel.vat!) -
    //                   double.parse(_TransReBillHistoryModel.wht!) -
    //                   ((_TransReBillHistoryModel.disendbill == null)
    //                       ? 0.00
    //                       : double.parse(_TransReBillHistoryModel.disendbill!))
    //               : double.parse(_TransReBillHistoryModel.total!)
    //           : 0.0;
    //       var sum_dislistx = double.parse(_TransReBillHistoryModel.dis!);
    //       var sum_net_amount_pvat =
    //           dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
    //               ? (_TransReBillHistoryModel.net_amount_pvat == null)
    //                   ? 0.00
    //                   : double.parse(_TransReBillHistoryModel.net_amount_pvat!)
    //               : 0.0;
    //       var sum_net_non_pvat =
    //           dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
    //               ? (_TransReBillHistoryModel.net_non_pvat == null)
    //                   ? 0.00
    //                   : double.parse(_TransReBillHistoryModel.net_non_pvat!)
    //               : 0.0;

    //       print('dtypeinvoiceent /// $dtypeinvoiceent');
    //       if (dtypeinvoiceent == 'KP') {
    //         sum_pvat = sum_pvat + sum_pvatx;

    //         ///---->
    //         sum_addvat = sum_addvat + sum_net_amount_pvat;
    //         sum_Nonvat = sum_Nonvat + sum_net_non_pvat;

    //         ///---->

    //         sum_vat = sum_vat + sum_vatx;
    //         sum_wht = sum_wht + sum_whtx;
    //         sum_amt = sum_amt + sum_amtx;
    //         // sum_disamt = sum_disamtx;
    //         // sum_disp = sum_dispx;
    //         numinvoice = _TransReBillHistoryModel.docno!;
    // numdoctax = _TransReBillHistoryModel.doctax!;
    //         if (_TransReBillHistoryModel.inv != null &&
    //             !ref_invoice.contains(_TransReBillHistoryModel.inv!)) {
    //           ref_invoice.add(_TransReBillHistoryModel.inv!);
    //         }
    //         // ref_invoice.add(_TransReBillHistoryModel.inv!);
    //         _TransReBillHistoryModels.add(_TransReBillHistoryModel);
    //       } else if (dtypeinvoiceent == '!Z') {
    //         sum_pvat = sum_pvat + sum_pvatx;

    //         ///---->
    //         sum_addvat = sum_addvat + sum_net_amount_pvat;
    //         sum_Nonvat = sum_Nonvat + sum_net_non_pvat;

    //         ///---->
    //         sum_vat = sum_vat + sum_vatx;
    //         sum_wht = sum_wht + sum_whtx;
    //         sum_amt = sum_amt + sum_amtx;
    //         // sum_disamt = sum_disamtx;
    //         // sum_disp = sum_dispx;
    //         // numinvoice = _TransReBillHistoryModel.docno;
    //         // numdoctax = _TransReBillHistoryModel.doctax;
    //         _TransReBillHistoryModels.add(_TransReBillHistoryModel);
    //       } else {
    //         // total_amt = total_amt + total_amtx;
    //         _TransReBillHistoryModels.add(_TransReBillHistoryModel);
    //       }
    //     }
    //     ref_invoice.sort();
    //   }
    // } catch (e) {
    //   print('catch');
    // }

///////////////////----------------------------------------->
    String url_4 =
        '${MyConstant().domain}/GC_countmiter_PDF.php?isAdd=true&ren=$ren&ciddoc=$cid_&docnoin=$docnoin&type_doc=Receipt';
    print('aaa $url_4');
    try {
      var response = await http.get(Uri.parse(url_4));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          ElectricityModel quotxSelectModel = ElectricityModel.fromJson(map);
          Water_electricity.add(quotxSelectModel);
        }
      }
      // print('Water_electricity.length $ren $cid_ $docnoin');
      // print( _TransReBillHistoryModels.length);
    } catch (e) {}

    double CalculatePvatandVat(int index) {
      final model = _TransReBillHistoryModels[index];

      // ตรวจสอบและแปลงค่าที่ต้องการใช้งานอย่างปลอดภัย
      double pvat = (model.amt == null)
          ? 0.00
          : (model.pvat == null)
              ? 0.00
              : double.parse(model.pvat!);

      double vat;
      if (model.vat_dis != null ||
          model.vat_dis != '0.00' ||
          model.vat_dis != '0.0000') {
        print('*$index');
        vat = (model.vat == null) ? 0.00 : double.parse(model.vat!);
      } else {
        print('000$index');
        vat = (model.vat_dis == null) ? 0.00 : double.parse(model.vat_dis!);
      }
      print('$index');
      print('$pvat $vat');
      print('---------------------------------');
      // รวมค่า
      double total = pvat + vat;
      return total;
    }
///////////////////----------------------------------------->

    int count_inv = _TransReBillHistoryModels.where((element) =>
        element.count_inv.toString() != '0' ||
        element.count_inv.toString() == '0.00').length;

    int sum_fine = _TransReBillHistoryModels.where((element) =>
            element.fine.toString() == '1' || element.fine.toString() == '1.00')
        .length;
/////////////////------------------------------------------>
    print('$sum_pvat _TransReBillHistoryModels.length  $sum_amt   $sum_total');
    print(_TransReBillHistoryModels.length);
    print('count_inv  $count_inv');
    print(count_inv);
    final tableData00 = [];
    final tableData01 = [];
    // final tableData00 = (count_inv != 0)
    //     ? [
    //         for (int index = 0;
    //             index < _TransReBillHistoryModels.length;
    //             index++)
    //           [
    //             '${_TransReBillHistoryModels[index].unitser}',

    //             ///---0
    //             '${_TransReBillHistoryModels[index].date}',

    //             ///---1
    //             (_TransReBillHistoryModels[index].fine.toString() == '1.00' &&
    //                     _TransReBillHistoryModels[index]
    //                             .expname
    //                             .toString()
    //                             .trim() ==
    //                         'null')
    //                 ? (rt_Language.toString().trim() == 'LA')
    //                     ? 'ປັບໄຫມ [${_TransReBillHistoryModels[index].inv}]'
    //                     : 'ค่าปรับ [${_TransReBillHistoryModels[index].inv}]'
    //                 : '${_TransReBillHistoryModels[index].expname.toString().trim()}',

    //             ///---2
    //             (_TransReBillHistoryModels[index].vat_dis.toString() ==
    //                         '0.00' ||
    //                     _TransReBillHistoryModels[index].vat_dis.toString() ==
    //                         '0.0000' ||
    //                     _TransReBillHistoryModels[index].vat_dis == null)
    //                 ? '${nFormat.format((_TransReBillHistoryModels[index].vat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat!))}'
    //                 : '${nFormat.format((_TransReBillHistoryModels[index].vat_dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat_dis!))}',

    //             ///---3
    //             '${nFormat.format((_TransReBillHistoryModels[index].wht == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].wht!))}',

    //             ///---4
    //             '${nFormat.format((_TransReBillHistoryModels[index].amt == null) ? 0.00 : (_TransReBillHistoryModels[index].pvat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].pvat!))}',

    //             ///---5
    //             '${nFormat.format((_TransReBillHistoryModels[index].total == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].total!))}',

    //             ///---6
    //             '${nFormat.format((_TransReBillHistoryModels[index].pri == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].pri!))}',

    //             ///---7
    //             '${_TransReBillHistoryModels[index].ovalue}',

    //             ///---8
    //             '${_TransReBillHistoryModels[index].nvalue}',

    //             ///---9
    //             '${nFormat.format((_TransReBillHistoryModels[index].qty == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].qty!))}',

    //             ///---10
    //             (_TransReBillHistoryModels[index].fine.toString() == '1.00' &&
    //                     _TransReBillHistoryModels[index]
    //                             .refno
    //                             .toString()
    //                             .trim() ==
    //                         'null')
    //                 ? '-'
    //                 : '${_TransReBillHistoryModels[index].refno}',

    //             ///---11
    //             //'${nFormat.format((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!))}',
    //             (_TransReBillHistoryModels[index].dis2.toString() == '0.00')
    //                 ? '${nFormat.format((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!))}'
    //                 : '${nFormat.format((_TransReBillHistoryModels[index].dis2 == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis2!))}',

    //             ///---12
    //             (_TransReBillHistoryModels[index].dis2.toString() == '0.00')
    //                 ? (_TransReBillHistoryModels[index].total == null)
    //                     ? '${nFormat.format(0.00 - ((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!)))}'
    //                     : (_TransReBillHistoryModels[index]
    //                                 .dtype_tex
    //                                 .toString() ==
    //                             'INV')
    //                         ? '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}'
    //                         : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!) - ((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!)))}'
    //                 : '${nFormat.format((_TransReBillHistoryModels[index].total_t == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].total_t!))}',

    //             ///---13
    //             '${_TransReBillHistoryModels[index].ele_ty}',

    //             ///---14
    //             '${nFormat.format((_TransReBillHistoryModels[index].pvat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].pvat!))}',

    //             ///---15
    //             (_TransReBillHistoryModels[index].zn != null)
    //                 ? (_TransReBillHistoryModels[index]
    //                             .zn!
    //                             .split('_')[0]
    //                             .length <=
    //                         4)
    //                     ? '${(_TransReBillHistoryModels[index].dtype_tex.toString() == 'INV') ? _TransReBillHistoryModels[index].inv : _TransReBillHistoryModels[index].refno}/0${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                     : '${(_TransReBillHistoryModels[index].dtype_tex.toString() == 'INV') ? _TransReBillHistoryModels[index].inv : _TransReBillHistoryModels[index].refno}/${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                 : (_TransReBillHistoryModels[index].fine.toString() ==
    //                             '1.00' &&
    //                         _TransReBillHistoryModels[index]
    //                                 .refno
    //                                 .toString()
    //                                 .trim() ==
    //                             'null')
    //                     ? (_TransReBillHistoryModels[index]
    //                                 .zn!
    //                                 .split('_')[0]
    //                                 .length <=
    //                             4)
    //                         ? '-/0${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                         : '-/${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                     : '${_TransReBillHistoryModels[index].refno}',

    //             ///---16
    //             '${_TransReBillHistoryModels[index].inv}',

    //             ///---17
    //             '${_TransReBillHistoryModels[index].dtype_tex}',

    //             ///---18
    //             '${_TransReBillHistoryModels[index].cid}',

    //             ///---19
    //             '${nFormat.format(CalculatePvatandVat(index))}'
    //             //   '${nFormat.format(
    //             // (_TransReBillHistoryModels[index].amt == null)
    //             // ? 0.00 +( (_TransReBillHistoryModels[index].vat_dis.toString() ==
    //             //             '0.00' ||
    //             //         _TransReBillHistoryModels[index].vat_dis.toString() ==
    //             //             '0.0000')
    //             //     ?(_TransReBillHistoryModels[index].vat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat!)
    //             //     : (_TransReBillHistoryModels[index].vat_dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat_dis!))
    //             // : (_TransReBillHistoryModels[index].pvat == null)
    //             // ? 0.00 +( (_TransReBillHistoryModels[index].vat_dis.toString() ==
    //             //             '0.00' ||
    //             //         _TransReBillHistoryModels[index].vat_dis.toString() ==
    //             //             '0.0000')
    //             //     ?(_TransReBillHistoryModels[index].vat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat!)
    //             //     : (_TransReBillHistoryModels[index].vat_dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat_dis!))
    //             //  :
    //             // double.parse(_TransReBillHistoryModels[index].pvat!)+( (_TransReBillHistoryModels[index].vat_dis.toString() ==
    //             //             '0.00' ||
    //             //         _TransReBillHistoryModels[index].vat_dis.toString() ==
    //             //             '0.0000')
    //             //     ?(_TransReBillHistoryModels[index].vat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat!)
    //             //     : (_TransReBillHistoryModels[index].vat_dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat_dis!)))}',
    //           ]
    //       ]
    //     : [
    //         for (int index = 0;
    //             index < _TransReBillHistoryModels.length;
    //             index++)
    //           if (_TransReBillHistoryModels[index].fine.toString() != '1.00')
    //             // if (_TransReBillHistoryModels[index].fine.toString() != '1.00' &&
    //             //     _TransReBillHistoryModels[index].expser.toString().trim() != '0')
    //             [
    //               '${_TransReBillHistoryModels[index].unitser}',

    //               ///---0
    //               '${_TransReBillHistoryModels[index].date}',

    //               ///---1
    //               '${_TransReBillHistoryModels[index].expname.toString().trim()}',

    //               ///---2
    //               (_TransReBillHistoryModels[index].vat_dis.toString() ==
    //                           '0.00' ||
    //                       _TransReBillHistoryModels[index].vat_dis.toString() ==
    //                           '0.0000' ||
    //                       _TransReBillHistoryModels[index].vat_dis == null)
    //                   ? '${nFormat.format((_TransReBillHistoryModels[index].vat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat!))}'
    //                   : '${nFormat.format((_TransReBillHistoryModels[index].vat_dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].vat_dis!))}',

    //               ///---3
    //               '${nFormat.format((_TransReBillHistoryModels[index].wht == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].wht!))}',

    //               ///---4
    //               '${nFormat.format((_TransReBillHistoryModels[index].amt == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].pvat!))}',

    //               ///---5
    //               '${nFormat.format((_TransReBillHistoryModels[index].total == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].total!))}',

    //               ///---6
    //               '${nFormat.format((_TransReBillHistoryModels[index].pri == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].pri!))}',

    //               ///---7
    //               '${_TransReBillHistoryModels[index].ovalue}',

    //               ///---8
    //               '${_TransReBillHistoryModels[index].nvalue}',

    //               ///---9
    //               '${nFormat.format((_TransReBillHistoryModels[index].qty == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].qty!))}',

    //               ///---10
    //               '${_TransReBillHistoryModels[index].refno}',

    //               ///---11

    //               '${nFormat.format((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!))}',

    //               ///---12
    //               (_TransReBillHistoryModels[index].dis2.toString() == '0.00')
    //                   ? (_TransReBillHistoryModels[index].total == null)
    //                       ? '${nFormat.format(0.00 - ((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!)))}'
    //                       : (_TransReBillHistoryModels[index]
    //                                   .dtype_tex
    //                                   .toString() ==
    //                               'INV')
    //                           ? '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}'
    //                           : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!) - ((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!)))}'
    //                   : '${nFormat.format((_TransReBillHistoryModels[index].total_t == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].total_t!))}',
    //               // (_TransReBillHistoryModels[index].dis2.toString() == '0.00')
    //               //     ? (_TransReBillHistoryModels[index].total == null)
    //               //         ? '${nFormat.format(0.00 - ((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!)))}'
    //               //         : '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!) - ((_TransReBillHistoryModels[index].dis == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].dis!)))}'
    //               //     : '${nFormat.format((_TransReBillHistoryModels[index].total_t == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].total_t!))}',

    //               ///---13

    //               '${_TransReBillHistoryModels[index].ele_ty}',

    //               ///---14
    //               '${nFormat.format((_TransReBillHistoryModels[index].pvat == null) ? 0.00 : double.parse(_TransReBillHistoryModels[index].pvat!))}',

    //               ///---15
    //               (_TransReBillHistoryModels[index].zn != null)
    //                   ? (_TransReBillHistoryModels[index]
    //                               .zn!
    //                               .split('_')[0]
    //                               .length <=
    //                           4)
    //                       ? '${_TransReBillHistoryModels[index].refno}/0${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                       : '${_TransReBillHistoryModels[index].refno}/${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                   : (_TransReBillHistoryModels[index].fine.toString() ==
    //                               '1.00' &&
    //                           _TransReBillHistoryModels[index]
    //                                   .refno
    //                                   .toString()
    //                                   .trim() ==
    //                               'null')
    //                       ? (_TransReBillHistoryModels[index]
    //                                   .zn!
    //                                   .split('_')[0]
    //                                   .length <=
    //                               4)
    //                           ? '-/0${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                           : '-/${_TransReBillHistoryModels[index].zn!.split('_')[0]}'
    //                       : '${_TransReBillHistoryModels[index].refno}',

    //               ///---16
    //               '${_TransReBillHistoryModels[index].inv}',

    //               ///---17
    //               '${_TransReBillHistoryModels[index].dtype_tex}',

    //               ///---18
    //               '${_TransReBillHistoryModels[index].cid}',

    //               ///---19
    //               '${nFormat.format(CalculatePvatandVat(index))}'
    //             ],
    //       ];
    // final tableData01 = [];

    // if (sum_fine != 0 && count_inv == 0) {
    //   tableData01.add(
    //     [
    //       '${_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => model.unitser.toString()).first}',

    //       ///---0
    //       '${_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => model.date.toString()).first}',

    //       ///---1
    //       (rt_Language.toString().trim() == 'LA') ? 'ປັບໄຫມ' : 'ค่าปรับ',

    //       ///---2
    //       '${nFormat.format(_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => double.parse(model.vat ?? '0.00')).fold(0.0, (previousValue, element) => previousValue + element))}',

    //       ///---3
    //       '${nFormat.format(_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => double.parse(model.wht ?? '0.00')).fold(0.0, (previousValue, element) => previousValue + element))}',

    //       ///---4
    //       '${nFormat.format(_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => double.parse(model.wht ?? '0.00')).fold(0.0, (previousValue, element) => previousValue + element))}',

    //       ///---5
    //       '${nFormat.format(_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => double.parse(model.total ?? '0.00')).fold(0.0, (previousValue, element) => previousValue + element))}',

    //       ///---6
    //       '${nFormat.format(_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => double.parse(model.pri ?? '0.00')).fold(0.0, (previousValue, element) => previousValue + element))}',

    //       ///---7
    //       '${_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => model.ovalue.toString()).first}',

    //       ///---8
    //       '${_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => model.nvalue.toString()).first}',

    //       ///---9

    //       '${nFormat.format(_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => double.parse(model.qty ?? '0.00')).fold(0.0, (previousValue, element) => previousValue + element))}',

    //       ///---10
    //       '${_TransReBillHistoryModels.where((model) => model.fine == '1' || model.fine == '1.00').map((model) => model.refno.toString()).first}',

    //       ///---11
    //     ],
    //   );
    // }

    Future.delayed(Duration(milliseconds: 500), () async {
      if (tem_page_ser.toString() == '0' || tem_page_ser == null) {
        Pdfgen_his_statusbill_TP3.exportPDF_statusbill_TP3(
            _TransReBillHistoryModels,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            foder,
            tableData00,
            tableData01,
            context,
            _TransReBillHistoryModels,
            'Num_cid',
            'Namenew',
            '${sum_pvat}',
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disp,
            sum_disamt,
            '${(sum_amt - sum_disamt)}',
            // '${(sum_amt)}',
            renTal_name,
            scname_,
            cname_,
            addr_,
            tax_,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            numdoctax,
            ref_invoice,
            finnancetransModels,
            date_Transaction,
            date_pay,
            Howto_LockJonPay,
            dis_sum_Matjum,
            TitleType_Default_Receipt_Name,
            dis_sum_Pakan,
            sum_fee,
            com_ment,
            fonts_pdf,
            Preview_ser,
            Con_remark);
      } else if (tem_page_ser.toString() == '1') {
        Pdfgen_his_statusbill_TP4.exportPDF_statusbill_TP4(
            _TransReBillHistoryModels,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            foder,
            tableData00,
            tableData01,
            context,
            _TransReBillHistoryModels,
            'Num_cid',
            'Namenew',
            '${sum_pvat}',
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disp,
            sum_disamt,
            '${(sum_amt - sum_disamt)}',
            // '${(sum_amt)}',
            renTal_name,
            scname_,
            cname_,
            addr_,
            tax_,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            numdoctax,
            ref_invoice,
            finnancetransModels,
            date_Transaction,
            date_pay,
            Howto_LockJonPay,
            dis_sum_Matjum,
            TitleType_Default_Receipt_Name,
            dis_sum_Pakan,
            sum_fee,
            com_ment,
            fonts_pdf,
            Preview_ser,
            Con_remark);
      } else if (tem_page_ser.toString() == '2') {
        // if (rtser.toString() == '102') {
        //   // Pdfgen_his_statusbill_TP7_Ama.exportPDF_statusbill_TP7_Ama(
        //   //     Cust_no,
        //   //     cid_,
        //   //     Zone_s,
        //   //     Ln_s,
        //   //     fname,
        //   //     foder,
        //   //     tableData00,
        //   //     tableData01,
        //   //     context,
        //   //     _TransReBillHistoryModels,
        //   //     'Num_cid',
        //   //     'Namenew',
        //   //     '${sum_pvat}',
        //   //     sum_vat,
        //   //     sum_wht,
        //   //     sum_amt,
        //   //     sum_disp,
        //   //     sum_disamt,
        //   //     '${(sum_amt - sum_disamt)}',
        //   //     // '${(sum_amt)}',
        //   //     renTal_name,
        //   //     scname_,
        //   //     cname_,
        //   //     addr_,
        //   //     tax_,
        //   //     bill_addr,
        //   //     bill_email,
        //   //     bill_tel,
        //   //     bill_tax,
        //   //     bill_name,
        //   //     newValuePDFimg,
        //   //     numinvoice,
        //   //     numdoctax,
        //   //     ref_invoice,
        //   //     finnancetransModels,
        //   //     date_Transaction,
        //   //     date_pay,
        //   //     Howto_LockJonPay,
        //   //     dis_sum_Matjum,
        //   //     TitleType_Default_Receipt_Name,
        //   //     dis_sum_Pakan,
        //   //     sum_fee,
        //   //     com_ment,
        //   //     fonts_pdf,
        //   //     Preview_ser,
        //   //     Con_remark);
        // }
        if (rtser.toString() == '148') {
          Pdfgen_his_statusbill_TP7_LAMPHUN.exportPDF_statusbill_TP7_LAMPHun(
              _TransReBillHistoryModels,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              foder,
              tableData00,
              tableData01,
              context,
              _TransReBillHistoryModels,
              'Num_cid',
              'Namenew',
              '${sum_pvat}',
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disp,
              sum_disamt,
              '${(sum_amt - sum_disamt)}',
              // '${(sum_amt)}',
              renTal_name,
              scname_,
              cname_,
              addr_,
              tax_,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              numdoctax,
              ref_invoice,
              finnancetransModels,
              date_Transaction,
              date_pay,
              Howto_LockJonPay,
              dis_sum_Matjum,
              TitleType_Default_Receipt_Name,
              dis_sum_Pakan,
              sum_fee,
              com_ment,
              fonts_pdf,
              Preview_ser,
              Con_remark);
        } else if (rtser.toString() == '145') {
          Pdfgen_his_statusbill_TP7_nim.exportPDF_statusbill_TP7_nim(
              _TransReBillHistoryModels,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              foder,
              tableData00,
              tableData01,
              context,
              _TransReBillHistoryModels,
              'Num_cid',
              'Namenew',
              '${sum_pvat}',
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disp,
              sum_disamt,
              '${(sum_amt - sum_disamt)}',
              // '${(sum_amt)}',
              renTal_name,
              scname_,
              cname_,
              addr_,
              tax_,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              numdoctax,
              ref_invoice,
              finnancetransModels,
              date_Transaction,
              date_pay,
              Howto_LockJonPay,
              dis_sum_Matjum,
              TitleType_Default_Receipt_Name,
              dis_sum_Pakan,
              sum_fee,
              com_ment,
              fonts_pdf,
              Preview_ser,
              Con_remark);
        } else {
          Pdfgen_his_statusbill_TP7.exportPDF_statusbill_TP7(
              _TransReBillHistoryModels,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              foder,
              tableData00,
              tableData01,
              context,
              _TransReBillHistoryModels,
              'Num_cid',
              'Namenew',
              '${sum_pvat}',
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disp,
              sum_disamt,
              '${(sum_amt - sum_disamt)}',
              // '${(sum_amt)}',
              renTal_name,
              scname_,
              cname_,
              addr_,
              tax_,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              numdoctax,
              ref_invoice,
              finnancetransModels,
              date_Transaction,
              date_pay,
              Howto_LockJonPay,
              dis_sum_Matjum,
              TitleType_Default_Receipt_Name,
              dis_sum_Pakan,
              sum_fee,
              com_ment,
              fonts_pdf,
              Preview_ser,
              Con_remark);
        }
      } else if (tem_page_ser.toString() == '3') {
        if (rtser.toString() == '72' ||
            rtser.toString() == '92' ||
            rtser.toString() == '93' ||
            rtser.toString() == '94') {
          // Pdfgen_his_statusbill_TP8_Ortorkor.exportPDF_statusbill_TP8_Ortorkor(
          //     Cust_no,
          //     cid_,
          //     Zone_s,
          //     Ln_s,
          //     fname,
          //     foder,
          //     tableData00,
          //     tableData01,
          //     context,
          //     _TransReBillHistoryModels,
          //     'Num_cid',
          //     'Namenew',
          //     '${sum_pvat}',
          //     sum_vat,
          //     sum_wht,
          //     sum_amt,
          //     sum_disp,
          //     sum_disamt,
          //     '${(sum_amt - sum_disamt)}',
          //     // '${(sum_amt)}',
          //     renTal_name,
          //     scname_,
          //     cname_,
          //     addr_,
          //     tax_,
          //     bill_addr,
          //     bill_email,
          //     bill_tel,
          //     bill_tax,
          //     bill_name,
          //     newValuePDFimg,
          //     numinvoice,
          //     numdoctax,
          //     ref_invoice,
          //     finnancetransModels,
          //     date_Transaction,
          //     date_pay,
          //     Howto_LockJonPay,
          //     dis_sum_Matjum,
          //     TitleType_Default_Receipt_Name,
          //     dis_sum_Pakan,
          //     sum_fee,
          //     com_ment,
          //     fonts_pdf,
          //     Preview_ser,
          //     Con_remark);
        } else if (rtser.toString() == '106') {
          Pdfgen_his_statusbill_TP8_Choice.exportPDF_statusbill_TP8_Choice(
              _TransReBillHistoryModels,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              foder,
              tableData00,
              tableData01,
              context,
              _TransReBillHistoryModels,
              'Num_cid',
              'Namenew',
              '${sum_pvat}',
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disp,
              sum_disamt,
              '${(sum_amt - sum_disamt)}',
              // '${(sum_amt)}',
              renTal_name,
              scname_,
              cname_,
              addr_,
              tax_,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              numdoctax,
              ref_invoice,
              finnancetransModels,
              date_Transaction,
              date_pay,
              Howto_LockJonPay,
              dis_sum_Matjum,
              TitleType_Default_Receipt_Name,
              dis_sum_Pakan,
              sum_fee,
              com_ment,
              fonts_pdf,
              Preview_ser,
              Con_remark,
              round_p,
              paper,
              '${int.parse('$paper_run') + 1}',
              amt_up,
              vat_up,
              sum_net_amount_pvat,
              sum_net_non_pvat);
        } else {
          Pdfgen_his_statusbill_TP8.exportPDF_statusbill_TP8(
              _TransReBillHistoryModels,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              foder,
              tableData00,
              tableData01,
              context,
              _TransReBillHistoryModels,
              'Num_cid',
              'Namenew',
              '${sum_pvat}',
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disp,
              sum_disamt,
              '${(sum_amt - sum_disamt)}',
              // '${(sum_amt)}',
              renTal_name,
              scname_,
              cname_,
              addr_,
              tax_,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              numdoctax,
              ref_invoice,
              finnancetransModels,
              date_Transaction,
              date_pay,
              Howto_LockJonPay,
              dis_sum_Matjum,
              TitleType_Default_Receipt_Name,
              dis_sum_Pakan,
              sum_fee,
              com_ment,
              fonts_pdf,
              Preview_ser,
              Con_remark);
        }
      } else if (tem_page_ser.toString() == '4') {
        Pdfgen_his_statusbill_TP9_Lao.exportPDF_statusbill_TP9_Lao(
            _TransReBillHistoryModels,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            foder,
            tableData00,
            tableData01,
            context,
            _TransReBillHistoryModels,
            'Num_cid',
            'Namenew',
            '${sum_pvat}',
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disp,
            sum_disamt,
            '${(sum_amt - sum_disamt)}',
            // '${(sum_amt)}',
            renTal_name,
            scname_,
            cname_,
            addr_,
            tax_,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            numdoctax,
            ref_invoice,
            finnancetransModels,
            date_Transaction,
            date_pay,
            Howto_LockJonPay,
            dis_sum_Matjum,
            TitleType_Default_Receipt_Name,
            dis_sum_Pakan,
            sum_fee,
            com_ment,
            fonts_pdf,
            Preview_ser,
            Con_remark);
      } else if (tem_page_ser.toString() == '5') {
        print('Pdfgen_his_statusbill_TP9');

        ///แคนนาสสส
        Pdfgen_his_statusbill_TP9.exportPDF_statusbill_TP9(
            // _TransReBillHistoryModels,
            // Cust_no,
            // cid_,
            // Zone_s,
            // Ln_s,
            // fname,
            // foder,
            // tableData00,
            // tableData01,
            // context,
            // _TransReBillHistoryModels,
            // 'Num_cid',
            // 'Namenew',
            // '${sum_pvat}',
            // sum_vat,
            // sum_wht,
            // sum_amt,
            // sum_disp,
            // sum_disamt,
            // '${(sum_amt - sum_disamt)}',
            // // '${(sum_amt)}',
            // renTal_name,
            // scname_,
            // cname_,
            // addr_,
            // tax_,
            // bill_addr,
            // bill_email,
            // bill_tel,
            // bill_tax,
            // bill_name,
            // newValuePDFimg,
            // numinvoice,
            // numdoctax,
            // ref_invoice,
            // finnancetransModels,
            // date_Transaction,
            // date_pay,
            // Howto_LockJonPay,
            // dis_sum_Matjum,
            // TitleType_Default_Receipt_Name,
            // dis_sum_Pakan,
            // sum_fee,
            // com_ment,
            // fonts_pdf,
            // Water_electricity,
            // Preview_ser,
            // Con_remark);
            _TransReBillHistoryModels,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            foder,
            tableData00,
            tableData01,
            context,
            _TransReBillHistoryModels,
            'Num_cid',
            'Namenew',
            '${sum_pvat}',
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disp,
            sum_disamt,
            '${(sum_amt - sum_disamt)}',
            // '${(sum_amt)}',
            renTal_name,
            scname_,
            cname_,
            addr_,
            tax_,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            numdoctax,
            ref_invoice,
            finnancetransModels,
            date_Transaction,
            date_pay,
            Howto_LockJonPay,
            dis_sum_Matjum,
            TitleType_Default_Receipt_Name,
            dis_sum_Pakan,
            sum_fee,
            com_ment,
            fonts_pdf,
            Preview_ser,
            Con_remark,
            round_p,
            paper,
            '${int.parse('$paper_run') + 1}',
            amt_up,
            vat_up,
            sum_net_amount_pvat,
            sum_net_non_pvat);
      } else if (tem_page_ser.toString() == '6') {
        Pdfgen_his_statusbill_TP10.exportPDF_statusbill_TP10(
          _TransReBillHistoryModels,
          Cust_no,
          cid_,
          Zone_s,
          Ln_s,
          Ln_c,
          fname,
          foder,
          tableData00,
          tableData01,
          context,
          _TransReBillHistoryModels,
          'Num_cid',
          'Namenew',
          '${sum_pvat}',
          sum_vat,
          sum_wht,
          sum_amt,
          sum_disp,
          sum_disamt,
          '${(sum_amt - sum_disamt)}',
          // '${(sum_amt)}',
          renTal_name,
          scname_,
          cname_,
          addr_,
          tax_,
          bill_addr,
          bill_email,
          bill_tel,
          bill_tax,
          bill_name,
          newValuePDFimg,
          numinvoice,
          numdoctax,
          ref_invoice,
          finnancetransModels,
          date_Transaction,
          date_pay,
          Howto_LockJonPay,
          dis_sum_Matjum,
          TitleType_Default_Receipt_Name,
          dis_sum_Pakan,
          sum_fee,
          com_ment,
          fonts_pdf,
          Preview_ser,
          Con_remark,
          round_p,
          paper,
          '${int.parse('$paper_run') + 1}',
          amt_up,
          vat_up,
          Lncode,
          sum_net_amount_pvat,
          sum_net_non_pvat,
          // sum_addvat_choice,
        );
        // Pdfgen_his_statusbill_TP10.exportPDF_statusbill_TP10(
        //     Cust_no,
        //     cid_,
        //     Zone_s,
        //     Ln_s,
        //     Ln_c,

        //     fname,
        //     foder,
        //     tableData00,
        //     tableData01,
        //     context,
        //     _TransReBillHistoryModels,
        //     'Num_cid',
        //     'Namenew',
        //     '${sum_pvat}',
        //     sum_vat,
        //     sum_wht,
        //     sum_amt,
        //     sum_disp,
        //     sum_disamt,
        //     '${(sum_amt - sum_disamt)}',
        //     // '${(sum_amt)}',
        //     renTal_name,
        //     scname_,
        //     cname_,
        //     addr_,

        //     Form_lncode,
        //     fname,
        //     foder,
        //     tableData00,
        //     tableData01,
        //     context,
        //     _TransReBillHistoryModels,
        //     'Num_cid',
        //     'Namenew',
        //     '${sum_pvat}',
        //     sum_vat,
        //     sum_wht,
        //     sum_amt,
        //     sum_disp,
        //     sum_disamt,
        //     '${(sum_amt - sum_disamt)}',
        //     // '${(sum_amt)}',
        //     renTal_name,
        //     scname_,
        //     cname_,
        //     addr_,
        //     tax_,
        //     bill_addr,
        //     bill_email,
        //     bill_tel,
        //     bill_tax,
        //     bill_name,
        //     newValuePDFimg,
        //     numinvoice,
        //     numdoctax,
        //     ref_invoice,
        //     finnancetransModels,
        //     date_Transaction,
        //     date_pay,
        //     Howto_LockJonPay,
        //     dis_sum_Matjum,
        //     TitleType_Default_Receipt_Name,
        //     dis_sum_Pakan,
        //     sum_fee,
        //     com_ment,
        //     fonts_pdf,
        //     Preview_ser,
        //     Con_remark,
        //     round_p,
        //     paper,
        //     '${int.parse('$paper_run') + 1}',
        //     amt_up,
        //     vat_up);
      }
    });
    // if (Con_remark.toString() != '' && Con_remark != null)
    //                   pw.Container(
    //                     padding: const pw.EdgeInsets.all(4.0),
    //                     child: pw.Text(
    //                       '# หมายเหตุ : $Con_remark',
    //                       style: pw.TextStyle(
    //                           fontSize: font_Size,
    //                           fontWeight: pw.FontWeight.bold,
    //                           font: ttf,
    //                           color: PdfColors.grey800),
    //                     ),
    //                   ),
    // Future.delayed(Duration(milliseconds: 500), () async {
    //   if (tem_page_ser.toString() == '0' || tem_page_ser == null) {
    //     Pdfgen_his_statusbill.exportPDF_statusbill(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '1') {
    //     Pdfgen_his_statusbill_TP2.exportPDF_statusbill_TP2(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         // numdoctax == '' ? '$numinvoice' : '$numdoctax',
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '2') {
    //     Pdfgen_his_statusbill_TP3.exportPDF_statusbill_TP3(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '3') {
    //     Pdfgen_his_statusbill_TP4.exportPDF_statusbill_TP4(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '4') {
    //     Pdfgen_his_statusbill_TP5.exportPDF_statusbill_TP5(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '5') {
    //     Pdfgen_his_statusbill_TP6.exportPDF_statusbill_TP6(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '6') {
    //     Pdfgen_his_statusbill_TP7.exportPDF_statusbill_TP7(
    //         foder,
    //         tableData00,
    //         tableData01,
    //         context,
    //         _TransReBillHistoryModels,
    //         'Num_cid',
    //         'Namenew',
    //         '${sum_pvat}',
    //         sum_vat,
    //         sum_wht,
    //         sum_amt,
    //         sum_disp,
    //         sum_disamt,
    //         '${(sum_amt - sum_disamt)}',
    //         renTal_name,
    //         scname_,
    //         cname_,
    //         addr_,
    //         tax_,
    //         bill_addr,
    //         bill_email,
    //         bill_tel,
    //         bill_tax,
    //         bill_name,
    //         newValuePDFimg,
    //         numinvoice,
    //         numdoctax,
    //         finnancetransModels,
    //         date_Transaction,
    //         date_pay,
    //         Howto_LockJonPay,
    //         dis_sum_Matjum,
    //         TitleType_Default_Receipt_Name);
    //   } else if (tem_page_ser.toString() == '7') {
    //     if (rtser.toString() == '72' ||
    //         rtser.toString() == '92' ||
    //         rtser.toString() == '93' ||
    //         rtser.toString() == '94') {
    //       Pdfgen_his_statusbill_TP8_Ortorkor.exportPDF_statusbill_TP8_Ortorkor(
    //           Cust_no,
    //           cid_,
    //           Zone_s,
    //           Ln_s,
    //           fname,
    //           foder,
    //           tableData00,
    //           tableData01,
    //           context,
    //           _TransReBillHistoryModels,
    //           'Num_cid',
    //           'Namenew',
    //           '${sum_pvat}',
    //           sum_vat,
    //           sum_wht,
    //           sum_amt,
    //           sum_disp,
    //           sum_disamt,
    //           '${(sum_amt - sum_disamt)}',
    //           renTal_name,
    //           scname_,
    //           cname_,
    //           addr_,
    //           tax_,
    //           bill_addr,
    //           bill_email,
    //           bill_tel,
    //           bill_tax,
    //           bill_name,
    //           newValuePDFimg,
    //           numinvoice,
    //           numdoctax,
    //           finnancetransModels,
    //           date_Transaction,
    //           date_pay,
    //           Howto_LockJonPay,
    //           dis_sum_Matjum,
    //           TitleType_Default_Receipt_Name);
    //     } else {
    //       Pdfgen_his_statusbill_TP8.exportPDF_statusbill_TP8(
    //           Cust_no,
    //           cid_,
    //           Zone_s,
    //           Ln_s,
    //           fname,
    //           foder,
    //           tableData00,
    //           tableData01,
    //           context,
    //           _TransReBillHistoryModels,
    //           'Num_cid',
    //           'Namenew',
    //           '${sum_pvat}',
    //           sum_vat,
    //           sum_wht,
    //           sum_amt,
    //           sum_disp,
    //           sum_disamt,
    //           '${(sum_amt - sum_disamt)}',
    //           renTal_name,
    //           scname_,
    //           cname_,
    //           addr_,
    //           tax_,
    //           bill_addr,
    //           bill_email,
    //           bill_tel,
    //           bill_tax,
    //           bill_name,
    //           newValuePDFimg,
    //           numinvoice,
    //           numdoctax,
    //           finnancetransModels,
    //           date_Transaction,
    //           date_pay,
    //           Howto_LockJonPay,
    //           dis_sum_Matjum,
    //           TitleType_Default_Receipt_Name);
    //     }
    //   }
    // });
  }
}
// context.select((SubjectBloc bloc) => bloc)
// List All_file = [
//   'ใบเสร็จรับเงิน RM67-09-000515.pdf',
//   'ใบเสร็จรับเงิน RM67-09-000516.pdf',
//   'ใบเสร็จรับเงิน RM67-09-000517.pdf',
// ];
