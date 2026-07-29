import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Model/electricity_model.dart';
import '../PDF/PDF_Billing/pdf_BillingNote_IV.dart';

import '../PDF_TP10/PDF_Billing_TP10/pdf_BillingNote_IV_TP10.dart';
import '../PDF_TP2/PDF_Billing_TP2/pdf_BillingNote_IV_TP2.dart';
import '../PDF_TP3/PDF_Billing_TP3/pdf_BillingNote_IV_TP3.dart';
import '../PDF_TP3/PDF_Billing_TP3/pdf_BillingNote_IV_TP3_V2.dart';
import '../PDF_TP4/PDF_Billing_TP4/pdf_BillingNote_IV_TP4.dart';
import '../PDF_TP5/PDF_Billing_TP5/pdf_BillingNote_IV_TP5.dart';
import '../PDF_TP6/PDF_Billing_TP6/pdf_BillingNote_IV_TP6.dart';
import '../PDF_TP7/PDF_Billing_TP7/pdf_BillingNote_IV_TP7.dart';
import '../PDF/LAMPHUN/PDF_Billing_TP7_LAMPHUN/pdf_BillingNote_IV_TP7_LAMPHUN.dart';
import '../PDF_TP7_Ama1000/PDF_Billing_TP7/pdf_BillingNote_IV_TP7.dart';
import '../PDF_TP8/PDF_Billing_TP8/pdf_BillingNote_IV_TP8.dart';
import '../PDF_TP8_Choice/PDF_Billing_TP8_Choice/pdf_BillingNote_IV_TP8_Choice.dart';
import '../PDF_TP8_Ortorkor/PDF_Billing_TP8_Ortorkor/pdf_BillingNote_IV_TP8.dart';
import '../PDF_TP9/PDF_Billing_TP9/pdf_BillingNote_IV_TP9.dart';
import '../PDF_TP9_Lao/PDF_Billing_TP9/pdf_BillingNote_IV_TP9.dart';

class Man_BillingNoteInvlice_PDF {
  static void ManBillingNoteInvlice_PDF(
      TitleType_Default_Receipt_Name,
      foder,
      qutser,
      tem_page_ser,
      // ser,
      // tableData003,
      context,
      // _TransModels,
      Get_Value_cid,
      namenew,
      // sum_pvat,
      // sum_vat,
      // sum_wht,
      // sum_amt,
      // sum_dis,
      // sum_total,
      // '${sum_amt - double.parse(sum_disamt.text)}',
      // renTal_name,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      cFinn,
      Preview_ser
      // Date_Time,
      // paymentName1,
      // paymentName2,
      // selectedValue_bank_bno
      ) async {
    List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
    List<ElectricityModel> Water_electricity = [];
    List<ElectricityModel> electricityModels = [];
    List<String> Water_elec = [];
    String? numinvoice;
    String? Form_nameshop;
    String? Form_typeshop;
    String? Form_bussshop;
    String? Form_bussscontact;
    String? Form_address;
    String? Form_tel;
    String? Form_email;
    String? Form_tax;
    String? rental_count_text;
    String? Form_area;
    String? Form_ln;
    String? Form_lncode;
    String? Form_sdate;
    String? Form_ldate;
    String? Form_period;
    String? Form_rtname;
    String? Form_docno;
    String? Form_zn;
    String? Form_aser;
    String? Form_qty;
    String? customer_name;

    String? payment_Ptser1,
        payment_Ptname1,
        payment_Bno1,
        bank1,
        img1,
        btype1,
        ptname1,
        ptser1;
    String? payment_Ptser2,
        payment_Ptname2,
        payment_Bno2,
        bank2,
        img2,
        btype2,
        ptname2,
        ptser2;
    String? Datex_invoice;
    String? End_Bill_Paydate;
    double sum_pvat = 0.00,
        sum_vat = 0.00,
        sum_wht = 0.00,
        sum_amt = 0.00,
        sum_dis = 0.00,
        sum_disamt = 0.00,
        sum_disp = 0.00,
        sum_net_amount_pvat = 0.00,
        sum_net_non_pvat = 0.00;

    String? Cust_no, Ln_s, Zone_s, cid_;
    String? ser_user;
    String Con_remark = '';
    /////////////////////------------------------->
    var round_p, paper, paper_run;

//--------------------->
    if (_InvoiceHistoryModels.length != 0) {
      _InvoiceHistoryModels.clear();
      Water_electricity.clear();
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_disamt = 0;
      sum_disp = 0;
      sum_net_amount_pvat = 0;
      sum_net_non_pvat = 0;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var fname;
    var rtser = preferences.getString('renTalSer');
    var ren = preferences.getString('renTalSer');
    var rt_Language = preferences.getString('renTal_Language');
    var renTal_name = preferences.getString('renTalName');
    var docnoin = cFinn;
    var ciddoc = Get_Value_cid;
    var fonts_pdf = (rt_Language.toString().trim() == 'LA')
        ? await 'fonts/NotoSansLao-Regular.ttf'
        : await 'fonts/THSarabunNew.ttf';
    var nFormat = (rt_Language.toString().trim() == 'LA')
        ? NumberFormat("#,##0", "en_US")
        : NumberFormat("#,##0.00", "en_US");
////////////--------------------------->

    String url_1 =
        '${MyConstant().domain}/GC_bill_invoice_WhereDocno_PDF.php?isAdd=true&ren=$ren&doc_no=$docnoin';
    try {
      var response = await http.get(Uri.parse(url_1));
      // print(url_1);
      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
          payment_Ptser1 = _InvoiceModel.ptser;
          payment_Ptname1 = _InvoiceModel.ptname;
          payment_Bno1 = _InvoiceModel.bno;
          numinvoice = _InvoiceModel.docno;
          Datex_invoice = _InvoiceModel.daterec;
          End_Bill_Paydate = _InvoiceModel.date;
          bank1 = _InvoiceModel.bank;
          img1 = _InvoiceModel.img;
          btype1 = _InvoiceModel.btype;
          Cust_no = _InvoiceModel.custno;
          Zone_s = _InvoiceModel.c_zn;
          Ln_s = _InvoiceModel.c_ln.toString();
          cid_ = _InvoiceModel.cid;
          ciddoc = _InvoiceModel.cid;
          ser_user = _InvoiceModel.user;
          ptname1 = _InvoiceModel.ptname;
          ptser1 = _InvoiceModel.ptser;
          Con_remark = (_InvoiceModel.con_remark == null)
              ? ''
              : _InvoiceModel.con_remark!;

          round_p = _InvoiceModel.round_p;
          paper = _InvoiceModel.paper;
          paper_run = _InvoiceModel.paper_run;
        }
      }
    } catch (e) {}
    /////////////////////------------------------->
    String url_paper_run =
        '${MyConstant().domain}/UP_Paper_Run.php?isAdd=true&ren=$ren&ciddoc=$docnoin&paper_run=${int.parse('$paper_run') + 1}&type=inv';
    try {
      var response = await http.get(Uri.parse(url_paper_run));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {}
    } catch (e) {}
/////////////////////------------------------->

    String url_usersell =
        '${MyConstant().domain}/GC_User_PDF.php?isAdd=true&serUser=$ser_user';
    try {
      var response = await http.get(Uri.parse(url_usersell));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        // print('GC_Data_OnBill_PDF>>>> $result');
        for (var map in result) {
          UserModel userModel = UserModel.fromJson(map);

          fname = '[${userModel.ser}] ${userModel.fname} ${userModel.lname}';
        }
      }
    } catch (e) {}
////////////------------------------------------------------------>

    String url_2 =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    // print(url_2);
    try {
      var response = await http.get(Uri.parse(url_2));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          // teNantModels.add(teNantModel);
          Form_nameshop = (teNantModel.ctype.toString() == 'องค์กร/นิติบุคคล')
              ? teNantModel.cname.toString()
              : teNantModel.sname.toString();
          Form_typeshop = teNantModel.stype.toString();
          Form_bussshop = teNantModel.cname.toString();
          Form_bussscontact = teNantModel.attn.toString();
          Form_address = teNantModel.addr.toString();
          Form_tel = teNantModel.tel.toString();
          Form_email = teNantModel.email.toString();
          Form_tax = teNantModel.tax == null ? "-" : teNantModel.tax.toString();
          Form_area = teNantModel.area.toString();
          Form_ln = teNantModel.area_c.toString();
          Form_lncode = teNantModel.ln.toString();
          Form_sdate = DateFormat('dd-MM-yyyy')
              .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
              .toString();
          Form_ldate = DateFormat('dd-MM-yyyy')
              .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
              .toString();
          Form_period = teNantModel.period.toString();
          Form_rtname = teNantModel.rtname.toString();
          Form_docno = teNantModel.docno.toString();
          Form_zn = teNantModel.zn.toString();
          Form_aser = teNantModel.aser.toString();
          Form_qty = teNantModel.qty.toString();
          customer_name = teNantModel.customer_name.toString();
          if (ren.toString() == '106') {
            fname = teNantModel.name_user.toString();
          }
        }
      }
    } catch (e) {}

///////////////////----------------------------------------->
    // String url_3 =
    //     '${MyConstant().domain}/GC_bill_invoice_historyPDF.php?isAdd=true&ren=$ren&docnoin=$docnoin';
    String url_3 = (ren == '148')
        ? '${MyConstant().domain}/LP_JATUJAK_API/GC_bill_INVLPJATUJAK_historyPDF.php?isAdd=true&ren=$ren&docnoin=$docnoin'
        : '${MyConstant().domain}/GC_bill_invoice_historyPDF.php?isAdd=true&ren=$ren&docnoin=$docnoin';
    // '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url_3));

      var result = json.decode(response.body);
    //   print(url_3);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = (_InvoiceHistoryModel.pvat_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = (_InvoiceHistoryModel.vat_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = (_InvoiceHistoryModel.wht == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = (_InvoiceHistoryModel.total_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = (_InvoiceHistoryModel.disendbill == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = (_InvoiceHistoryModel.disendbillper == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.disendbillper!);
          var sum_net_amount_pvatx =
              (_InvoiceHistoryModel.net_amount_pvat == null)
                  ? 0.00
                  : double.parse(_InvoiceHistoryModel.net_amount_pvat!);
          var sum_net_non_pvatx = (_InvoiceHistoryModel.net_non_pvat == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.net_non_pvat!);
          sum_pvat = sum_pvat + sum_pvatx;
          sum_vat = sum_vat + sum_vatx;
          sum_wht = sum_wht + sum_whtx;
          sum_amt = sum_amt + sum_amtx;
          sum_disamt = sum_disamtx;
          sum_disp = sum_dispx;
          sum_net_amount_pvat = sum_net_amount_pvat + sum_net_amount_pvatx;
          sum_net_non_pvat = sum_net_non_pvat + sum_net_non_pvatx;

          _InvoiceHistoryModels.add(_InvoiceHistoryModel);
        }
      }
    } catch (e) {}

///////////////////----------------------------------------->
    String url_4 =
        '${MyConstant().domain}/GC_countmiter_PDF.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin&type_doc=INV';
    // print('bbbbb$url_4');
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
      // print('Water_electricity.length');
      // print(Water_electricity.length);
    } catch (e) {}
///////////////////----------------------------------------->
    double sum_total = (sum_amt - sum_disamt);

    final tableData003 = [
      // for (int index = 0; index < _InvoiceHistoryModels.length; index++)
      //   [
      //     '${_InvoiceHistoryModels[index].unitser}',

      //     ///---0
      //     '${_InvoiceHistoryModels[index].date}',

      //     ///---1
      //     '${_InvoiceHistoryModels[index].descr.toString().trim()}',

      //     ///---2
      //     '${nFormat.format((_InvoiceHistoryModels[index].nvat == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].vat!))}',

      //     ///---3
      //     '${nFormat.format((_InvoiceHistoryModels[index].wht == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].wht!))}',

      //     ///---4
      //     '${nFormat.format((_InvoiceHistoryModels[index].amt == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].amt!))}',

      //     ///---5
      //     '${nFormat.format((_InvoiceHistoryModels[index].total_t == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].total_t!))}',

      //     ///---6
      //     '${nFormat.format((_InvoiceHistoryModels[index].pri == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].pri!))}',

      //     ///---7
      //     '${_InvoiceHistoryModels[index].ovalue}',

      //     ///---8
      //     '${_InvoiceHistoryModels[index].nvalue}',

      //     ///---9
      //     '${nFormat.format((_InvoiceHistoryModels[index].qty == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].qty!))}',

      //     ///---10
      //     '${_InvoiceHistoryModels[index].refno}',

      //     ///---11
      //     double.parse(_InvoiceHistoryModels[index].tf!) == 0.00
      //         ? '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}'
      //         : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}',
      //     //'(${int.parse(_InvoiceHistoryModels[index].ovalue!)} - ${int.parse(_InvoiceHistoryModels[index].nvalue!)}) ${double.parse(_InvoiceHistoryModels[index].qty!)}',

      //     ///---12
      //     double.parse(_InvoiceHistoryModels[index].tf!) != 0.00
      //         ? '${nFormat.format(double.parse((_InvoiceHistoryModels[index].pri == null) ? '0.00' : _InvoiceHistoryModels[index].pri!))} (tf ${nFormat.format((double.parse((_InvoiceHistoryModels[index].amt == null) ? '0.00' : _InvoiceHistoryModels[index].amt!) - (double.parse((_InvoiceHistoryModels[index].vat == null) ? '0.00' : _InvoiceHistoryModels[index].vat!) + double.parse((_InvoiceHistoryModels[index].pvat == null) ? '0.00' : _InvoiceHistoryModels[index].pvat!))))})'
      //         : '${nFormat.format(double.parse((_InvoiceHistoryModels[index].nvat == null) ? '0.00' : _InvoiceHistoryModels[index].nvat!))}',
      //     //'${nFormat.format(double.parse((_InvoiceHistoryModels[index].nvat == null) ? '0.00' : _InvoiceHistoryModels[index].nvat!))}',

      //     ///---13

      //     '${_InvoiceHistoryModels[index].ele_ty}',

      //     ///---14
      //     '${nFormat.format((_InvoiceHistoryModels[index].pvat == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].pvat!))}',

      //     ///---15
      //     (_InvoiceHistoryModels[index].zn != null)
      //         ? (_InvoiceHistoryModels[index].zn!.split('_')[0].length <= 4)
      //             ? '${_InvoiceHistoryModels[index].refno}/0${_InvoiceHistoryModels[index].zn!.split('_')[0]}'
      //             : '${_InvoiceHistoryModels[index].refno}/${_InvoiceHistoryModels[index].zn!.split('_')[0]}'
      //         : (_InvoiceHistoryModels[index].zn!.split('_')[0].length <= 4)
      //             ? '-/0${_InvoiceHistoryModels[index].zn!.split('_')[0]}'
      //             : '-/${_InvoiceHistoryModels[index].zn!.split('_')[0]}',

      //     ///---16
      //     '${_InvoiceHistoryModels[index].vat_dis}',

      //     ///---17
      //     (_InvoiceHistoryModels[index].dis == null)
      //         ? '0.00'
      //         : '${nFormat.format((_InvoiceHistoryModels[index].dis == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].dis!))}',
      //     // '${_InvoiceHistoryModels[index].dis}',

      //     ///---18
      //     (_InvoiceHistoryModels[index].dis == null)
      //         ? '0.00'
      //         : (_InvoiceHistoryModels[index].pri.toString() == '0.00' ||
      //                 _InvoiceHistoryModels[index].pri.toString() == '0')
      //             ? '${nFormat.format((_InvoiceHistoryModels[index].amt == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].dis!) : double.parse(_InvoiceHistoryModels[index].amt!) - double.parse(_InvoiceHistoryModels[index].dis!))}'
      //             : '${nFormat.format((_InvoiceHistoryModels[index].pri == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].dis!) : double.parse(_InvoiceHistoryModels[index].pri!) - double.parse(_InvoiceHistoryModels[index].dis!))}',

      //     ///---19 (AMT Dis)
      //     (_InvoiceHistoryModels[index].dis == null)
      //         ? '0.00'
      //         : '${nFormat.format((_InvoiceHistoryModels[index].pvat == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].dis!) : double.parse(_InvoiceHistoryModels[index].pvat!) - double.parse(_InvoiceHistoryModels[index].dis!))}',

      //     ///---20 (PVAT Dis)
      //     (_InvoiceHistoryModels[index].vat_dis == null ||
      //             _InvoiceHistoryModels[index].vat_dis.toString() == '0')
      //         ? '0.00'
      //         : '${nFormat.format((_InvoiceHistoryModels[index].nvat == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].vat_dis!) : double.parse(_InvoiceHistoryModels[index].vat!) - double.parse(_InvoiceHistoryModels[index].vat_dis!))}',

      //     ///---21 (VAT Dis)
      //     (_InvoiceHistoryModels[index].dis == null ||
      //             _InvoiceHistoryModels[index].dis.toString() == '0')
      //         ? '0.00'
      //         : '${nFormat.format((_InvoiceHistoryModels[index].total_t == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].dis!) : double.parse(_InvoiceHistoryModels[index].total_t!) - double.parse(_InvoiceHistoryModels[index].dis!))}',

      //     ///---22 (Total Dis)
      //     '${nFormat.format((_InvoiceHistoryModels[index].pvat == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].pvat!) + ((_InvoiceHistoryModels[index].vat == null) ? 0.00 : double.parse(_InvoiceHistoryModels[index].vat!)))}',

      //     ///---23 (Total pvat+vat)
      //     '${nFormat.format(((_InvoiceHistoryModels[index].pvat == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].dis!) : double.parse(_InvoiceHistoryModels[index].pvat!) - double.parse(_InvoiceHistoryModels[index].dis!)) + ((_InvoiceHistoryModels[index].nvat == null) ? 0.00 - double.parse(_InvoiceHistoryModels[index].vat_dis!) : double.parse(_InvoiceHistoryModels[index].vat!) - double.parse(_InvoiceHistoryModels[index].vat_dis!)))}',

      //     ///---24 (Total pvat Dis +vat Dis )
      //   ],
    ];

///////////////--------------------------------------------------->
    Future.delayed(Duration(milliseconds: 500), () async {
      if (tem_page_ser.toString() == '0' || tem_page_ser == null) {
        Pdfgen_BillingNoteInvlice_TP3.exportPDF_BillingNoteInvlice_TP3(
            _InvoiceHistoryModels,
            foder,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            tableData003,
            context,
            Get_Value_cid,
            namenew,
            sum_pvat,
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disamt,
            sum_total,
            renTal_name,
            Form_bussshop,
            Form_address,
            Form_tel,
            Form_email,
            Form_tax,
            Form_nameshop,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            Datex_invoice,
            payment_Ptname1,
            payment_Ptname2,
            payment_Bno1,
            bank1,
            ptser1,
            ptname1,
            img1,
            Preview_ser,
            End_Bill_Paydate,
            TitleType_Default_Receipt_Name,
            fonts_pdf,
            Con_remark,
            customer_name);
        // Pdfgen_BillingNoteInvlice_TP3_V2.exportPDF_BillingNoteInvlice_TP3_V2(
        //     _InvoiceHistoryModels,
        //     foder,
        //     Cust_no,
        //     cid_,
        //     Zone_s,
        //     Ln_s,
        //     fname,
        //     tableData003,
        //     context,
        //     Get_Value_cid,
        //     namenew,
        //     sum_pvat,
        //     sum_vat,
        //     sum_wht,
        //     sum_amt,
        //     sum_disamt,
        //     sum_total,
        //     renTal_name,
        //     Form_bussshop,
        //     Form_address,
        //     Form_tel,
        //     Form_email,
        //     Form_tax,
        //     Form_nameshop,
        //     bill_addr,
        //     bill_email,
        //     bill_tel,
        //     bill_tax,
        //     bill_name,
        //     newValuePDFimg,
        //     numinvoice,
        //     Datex_invoice,
        //     payment_Ptname1,
        //     payment_Ptname2,
        //     payment_Bno1,
        //     bank1,
        //     ptser1,
        //     ptname1,
        //     img1,
        //     Preview_ser,
        //     End_Bill_Paydate,
        //     TitleType_Default_Receipt_Name,
        //     fonts_pdf,
        //     Con_remark,
        //     customer_name);
      } else if (tem_page_ser.toString() == '1') {
        Pdfgen_BillingNoteInvlice_TP4.exportPDF_BillingNoteInvlice_TP4(
            _InvoiceHistoryModels,
            foder,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            tableData003,
            context,
            Get_Value_cid,
            namenew,
            sum_pvat,
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disamt,
            sum_total,
            renTal_name,
            Form_bussshop,
            Form_address,
            Form_tel,
            Form_email,
            Form_tax,
            Form_nameshop,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            Datex_invoice,
            payment_Ptname1,
            payment_Ptname2,
            payment_Bno1,
            bank1,
            ptser1,
            ptname1,
            img1,
            Preview_ser,
            End_Bill_Paydate,
            TitleType_Default_Receipt_Name,
            fonts_pdf,
            Con_remark,
            customer_name);
      } else if (tem_page_ser.toString() == '2') {
        if (rtser.toString() == '102') {
          Pdfgen_BillingNoteInvlice_TP7_Ama
              .exportPDF_BillingNoteInvlice_TP7_Ama(
                  _InvoiceHistoryModels,
                  foder,
                  Cust_no,
                  cid_,
                  Zone_s,
                  Ln_s,
                  fname,
                  // ser,
                  tableData003,
                  context,
                  Get_Value_cid,
                  namenew,
                  sum_pvat,
                  sum_vat,
                  sum_wht,
                  sum_amt,
                  sum_disamt,
                  sum_total,
                  renTal_name,
                  Form_bussshop,
                  Form_address,
                  Form_tel,
                  Form_email,
                  Form_tax,
                  Form_nameshop,
                  bill_addr,
                  bill_email,
                  bill_tel,
                  bill_tax,
                  bill_name,
                  newValuePDFimg,
                  numinvoice,
                  Datex_invoice,
                  payment_Ptname1,
                  payment_Ptname2,
                  payment_Bno1,
                  payment_Ptser1,
                  bank1,
                  img1,
                  btype1,
                  ptser1,
                  ptname1,
                  Preview_ser,
                  End_Bill_Paydate,
                  fonts_pdf,
                  Con_remark,
                  customer_name);
        }
        if (rtser.toString() == '148') {
          Pdfgen_BillingNoteInvlice_TP7_LAMPHUN
              .exportPDF_BillingNoteInvlice_TP7_LAMPHUN(
                  _InvoiceHistoryModels,
                  foder,
                  Cust_no,
                  cid_,
                  Zone_s,
                  Ln_s,
                  fname,
                  // ser,
                  tableData003,
                  context,
                  Get_Value_cid,
                  namenew,
                  sum_pvat,
                  sum_vat,
                  sum_wht,
                  sum_amt,
                  sum_disamt,
                  sum_total,
                  renTal_name,
                  Form_bussshop,
                  Form_address,
                  Form_tel,
                  Form_email,
                  Form_tax,
                  Form_nameshop,
                  bill_addr,
                  bill_email,
                  bill_tel,
                  bill_tax,
                  bill_name,
                  newValuePDFimg,
                  numinvoice,
                  Datex_invoice,
                  payment_Ptname1,
                  payment_Ptname2,
                  payment_Bno1,
                  payment_Ptser1,
                  bank1,
                  img1,
                  btype1,
                  ptser1,
                  ptname1,
                  Preview_ser,
                  End_Bill_Paydate,
                  fonts_pdf,
                  Con_remark,
                  customer_name);
        } else {
          Pdfgen_BillingNoteInvlice_TP7.exportPDF_BillingNoteInvlice_TP7(
              _InvoiceHistoryModels,
              foder,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              // ser,
              tableData003,
              context,
              Get_Value_cid,
              namenew,
              sum_pvat,
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disamt,
              sum_total,
              renTal_name,
              Form_bussshop,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_nameshop,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              Datex_invoice,
              payment_Ptname1,
              payment_Ptname2,
              payment_Bno1,
              payment_Ptser1,
              bank1,
              img1,
              btype1,
              ptser1,
              ptname1,
              Preview_ser,
              End_Bill_Paydate,
              fonts_pdf,
              Con_remark,
              customer_name);
        }
      } else if (tem_page_ser.toString() == '3') {
        if (rtser.toString() == '72' ||
            rtser.toString() == '92' ||
            rtser.toString() == '93' ||
            rtser.toString() == '94') {
          Pdfgen_BillingNoteInvlice_TP8_Ortorkor
              .exportPDF_BillingNoteInvlice_TP8_Ortorkor(
                  _InvoiceHistoryModels,
                  foder,
                  Cust_no,
                  cid_,
                  Zone_s,
                  Ln_s,
                  fname,
                  // ser,
                  tableData003,
                  context,
                  Get_Value_cid,
                  namenew,
                  sum_pvat,
                  sum_vat,
                  sum_wht,
                  sum_amt,
                  sum_disamt,
                  sum_total,
                  renTal_name,
                  Form_bussshop,
                  Form_address,
                  Form_tel,
                  Form_email,
                  Form_tax,
                  Form_nameshop,
                  bill_addr,
                  bill_email,
                  bill_tel,
                  bill_tax,
                  bill_name,
                  newValuePDFimg,
                  numinvoice,
                  Datex_invoice,
                  payment_Ptname1,
                  payment_Ptname2,
                  payment_Bno1,
                  TitleType_Default_Receipt_Name,
                  payment_Ptser1,
                  bank1,
                  ptser1,
                  ptname1,
                  img1,
                  Preview_ser,
                  End_Bill_Paydate,
                  fonts_pdf,
                  Con_remark,
                  customer_name);
        } else if (rtser.toString() == '106') {
          Pdfgen_BillingNoteInvlice_TP8_Choice
              .exportPDF_BillingNoteInvlice_TP8_Choice(
                  _InvoiceHistoryModels,
                  foder,
                  Cust_no,
                  cid_,
                  Zone_s,
                  Ln_s,
                  fname,
                  // ser,
                  tableData003,
                  context,
                  Get_Value_cid,
                  namenew,
                  sum_pvat,
                  sum_vat,
                  sum_wht,
                  sum_amt,
                  sum_disamt,
                  sum_total,
                  renTal_name,
                  Form_bussshop,
                  Form_address,
                  Form_tel,
                  Form_email,
                  Form_tax,
                  Form_nameshop,
                  bill_addr,
                  bill_email,
                  bill_tel,
                  bill_tax,
                  bill_name,
                  newValuePDFimg,
                  numinvoice,
                  Datex_invoice,
                  payment_Ptname1,
                  payment_Ptname2,
                  payment_Bno1,
                  TitleType_Default_Receipt_Name,
                  payment_Ptser1,
                  bank1,
                  ptser1,
                  ptname1,
                  img1,
                  Preview_ser,
                  End_Bill_Paydate,
                  fonts_pdf,
                  Con_remark,
                  paper,
                  '${int.parse('$paper_run') + 1}',
                  sum_net_amount_pvat,
                  sum_net_non_pvat,
                  customer_name);
        } else {
          Pdfgen_BillingNoteInvlice_TP9.exportPDF_BillingNoteInvlice_TP9(
              // _InvoiceHistoryModels,
              // foder,
              // Cust_no,
              // cid_,
              // Zone_s,
              // Ln_s,
              // fname,
              // // ser,
              // tableData003,
              // context,
              // Get_Value_cid,
              // namenew,
              // sum_pvat,
              // sum_vat,
              // sum_wht,
              // sum_amt,
              // sum_disamt,
              // sum_total,
              // renTal_name,
              // Form_bussshop,
              // Form_address,
              // Form_tel,
              // Form_email,
              // Form_tax,
              // Form_nameshop,
              // bill_addr,
              // bill_email,
              // bill_tel,
              // bill_tax,
              // bill_name,
              // newValuePDFimg,
              // numinvoice,
              // Datex_invoice,
              // payment_Ptname1,
              // payment_Ptname2,
              // payment_Bno1,
              // TitleType_Default_Receipt_Name,
              // payment_Ptser1,
              // bank1,
              // ptser1,
              // ptname1,
              // img1,
              // Preview_ser,
              // End_Bill_Paydate,
              // fonts_pdf,
              // Water_electricity,
              // Con_remark,
              // customer_name);
              _InvoiceHistoryModels,
              foder,
              Cust_no,
              cid_,
              Zone_s,
              Ln_s,
              fname,
              // ser,
              tableData003,
              context,
              Get_Value_cid,
              namenew,
              sum_pvat,
              sum_vat,
              sum_wht,
              sum_amt,
              sum_disamt,
              sum_total,
              renTal_name,
              Form_bussshop,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_nameshop,
              bill_addr,
              bill_email,
              bill_tel,
              bill_tax,
              bill_name,
              newValuePDFimg,
              numinvoice,
              Datex_invoice,
              payment_Ptname1,
              payment_Ptname2,
              payment_Bno1,
              TitleType_Default_Receipt_Name,
              payment_Ptser1,
              bank1,
              ptser1,
              ptname1,
              img1,
              Preview_ser,
              End_Bill_Paydate,
              fonts_pdf,
              Water_electricity,
              Con_remark,
              paper,
              '${int.parse('$paper_run') + 1}',
              sum_net_amount_pvat,
              sum_net_non_pvat,
              customer_name);
        }
      } else if (tem_page_ser.toString() == '4') {
        Pdfgen_BillingNoteInvlice_TP9_Lao.exportPDF_BillingNoteInvlice_TP9_Lao(
            _InvoiceHistoryModels,
            foder,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            // ser,
            tableData003,
            context,
            Get_Value_cid,
            namenew,
            sum_pvat,
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disamt,
            sum_total,
            renTal_name,
            Form_bussshop,
            Form_address,
            Form_tel,
            Form_email,
            Form_tax,
            Form_nameshop,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            Datex_invoice,
            payment_Ptname1,
            payment_Ptname2,
            payment_Bno1,
            TitleType_Default_Receipt_Name,
            payment_Ptser1,
            bank1,
            ptser1,
            ptname1,
            img1,
            Preview_ser,
            End_Bill_Paydate,
            fonts_pdf,
            Con_remark,
            customer_name);
      } else if (tem_page_ser.toString() == '5') {
        Pdfgen_BillingNoteInvlice_TP9.exportPDF_BillingNoteInvlice_TP9(
            // _InvoiceHistoryModels,
            // foder,
            // Cust_no,
            // cid_,
            // Zone_s,
            // Ln_s,
            // fname,
            // // ser,
            // tableData003,
            // context,
            // Get_Value_cid,
            // namenew,
            // sum_pvat,
            // sum_vat,
            // sum_wht,
            // sum_amt,
            // sum_disamt,
            // sum_total,
            // renTal_name,
            // Form_bussshop,
            // Form_address,
            // Form_tel,
            // Form_email,
            // Form_tax,
            // Form_nameshop,
            // bill_addr,
            // bill_email,
            // bill_tel,
            // bill_tax,
            // bill_name,
            // newValuePDFimg,
            // numinvoice,
            // Datex_invoice,
            // payment_Ptname1,
            // payment_Ptname2,
            // payment_Bno1,
            // TitleType_Default_Receipt_Name,
            // payment_Ptser1,
            // bank1,
            // ptser1,
            // ptname1,
            // img1,
            // Preview_ser,
            // End_Bill_Paydate,
            // fonts_pdf,
            // Water_electricity,
            // Con_remark,
            // customer_name);
            _InvoiceHistoryModels,
            foder,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            fname,
            // ser,
            tableData003,
            context,
            Get_Value_cid,
            namenew,
            sum_pvat,
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disamt,
            sum_total,
            renTal_name,
            Form_bussshop,
            Form_address,
            Form_tel,
            Form_email,
            Form_tax,
            Form_nameshop,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            Datex_invoice,
            payment_Ptname1,
            payment_Ptname2,
            payment_Bno1,
            TitleType_Default_Receipt_Name,
            payment_Ptser1,
            bank1,
            ptser1,
            ptname1,
            img1,
            Preview_ser,
            End_Bill_Paydate,
            fonts_pdf,
            Water_electricity,
            Con_remark,
            paper,
            '${int.parse('$paper_run') + 1}',
            sum_net_amount_pvat,
            sum_net_non_pvat,
            customer_name);
      } else if (tem_page_ser.toString() == '6') {
        Pdfgen_BillingNoteInvlice_TP10.exportPDF_BillingNoteInvlice_TP10(
            _InvoiceHistoryModels,
            foder,
            Cust_no,
            cid_,
            Zone_s,
            Ln_s,
            Form_lncode,
            fname,
            // ser, ส่วนตัว/บุคคลธรรมดา
            tableData003,
            context,
            Get_Value_cid,
            namenew,
            sum_pvat,
            sum_vat,
            sum_wht,
            sum_amt,
            sum_disamt,
            sum_total,
            renTal_name,
            Form_bussshop,
            Form_address,
            Form_tel,
            Form_email,
            Form_tax,
            Form_nameshop,
            bill_addr,
            bill_email,
            bill_tel,
            bill_tax,
            bill_name,
            newValuePDFimg,
            numinvoice,
            Datex_invoice,
            payment_Ptname1,
            payment_Ptname2,
            payment_Bno1,
            TitleType_Default_Receipt_Name,
            payment_Ptser1,
            bank1,
            ptser1,
            ptname1,
            img1,
            Preview_ser,
            End_Bill_Paydate,
            fonts_pdf,
            Con_remark,
            paper,
            '${int.parse('$paper_run') + 1}',
            sum_net_amount_pvat,
            sum_net_non_pvat,
            customer_name);
      }
    });
  }
}
