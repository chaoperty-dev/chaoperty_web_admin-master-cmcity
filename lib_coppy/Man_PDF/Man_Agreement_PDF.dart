import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../Model/GetC_Quot_Select_Model.dart';
import '../Model/GetContract_Photo_Model.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTrans_Kon_Model.dart';
import '../Model/GetUser_Model.dart';
import '../Model/Read_DataONBill_PDF_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice.dart';
import '../PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice2.dart';
import '../PDF/Choice/Sub_Agreement_Choice/pdf_SubAgreement_Choice3.dart';
import '../PDF/Choice/pdf_Agreement_Choice.dart';
import '../PDF/Choice/pdf_Agreement_Choice2.dart';
import '../PDF/Choice/pdf_Agreement_Choice3.dart';
import '../PDF/Choice/pdf_Agreement_Choice8.dart';
import '../PDF/Choice/pdf_Agreement_Choice9.dart';
import '../PDF/LAMPHUN/pdf_lamphun.dart';
import '../PDF/LAMPHUN/pdf_lamphun1.dart';
import '../PDF/LAMPHUN/pdf_lamphun2.dart';
import '../PDF/NichadaThani/pdf_Agreement_Nichada.dart';
import '../PDF/NichadaThani/pdf_Agreement_Nichada2.dart';
import '../PDF/NichadaThani/pdf_Agreement_Nichada3.dart';
import '../PDF/NichadaThani/pdf_Agreement_Nichada4.dart';
import '../PDF/NichadaThani/pdf_Agreement_Nichada5.dart';
import '../PDF/PDF_Agreement/Ama1000/pdf_Agreement_ama1000.dart';
import '../PDF/PDF_Agreement/Ortor/BangKla/pdf_Agreement_Ortor.dart';
import '../PDF/PDF_Agreement/pdf_Agreement.dart';
import '../PDF/PDF_Agreement/pdf_Agreement_JSpace.dart';
import '../PDF/PDF_Agreement/pdf_Agreement_JSpace2.dart';
import '../PDF/PDF_Receipt/pdf_AC_his_statusbill.dart';
import '../PDF/nim/nim1_pdf.dart';
import '../PDF/nim/nim2_pdf.dart';
import '../PDF/nim/nim3_pdf.dart';
import '../PDF/nim/nim4_pdf.dart';
import '../PDF/nim/nim4place_pdf.dart';
import '../PDF/nim/nim5_pdf.dart';
import '../PDF/nim/nim7_pdf.dart';
import '../PDF/pdf_Cancel_Rental.dart';

import '../PDF/pdf_Cancel_Rental_Choice.dart';
import '../PDF/pdf_Cancel_Rental_Lao.dart';
import '../PDF_TP2/PDF_Receipt_TP2/pdf_AC_his_statusbill_TP2.dart';
import '../PDF_TP3/PDF_Receipt_TP3/pdf_AC_his_statusbill_TP3.dart';
import '../PDF_TP4/PDF_Receipt_TP4/pdf_AC_his_statusbill_TP4.dart';
import '../PDF_TP5/PDF_Receipt_TP5/pdf_AC_his_statusbill_TP5.dart';
import '../PDF_TP6/PDF_Receipt_TP6/pdf_AC_his_statusbill_TP6.dart';
import '../PDF_TP7/PDF_Receipt_TP7/pdf_AC_his_statusbill_TP7.dart';
import '../PDF_TP8/PDF_Receipt_TP8/pdf_AC_his_statusbill_TP8.dart';
import '../PDF_TP8_Ortorkor/PDF_Receipt_TP8_Ortorkor/pdf_AC_his_statusbill_TP8.dart';

class Man_Agreement_PDF {
  static void ManAgreement_PDF(
      context,
      type,
      _ReportValue_type_docOttor,
      Get_Value_NameShop_index,
      Get_Value_cid,
      _verticalGroupValue,
      Form_nameshop,
      Form_typeshop,
      Form_bussshop,
      Form_bussscontact,
      Form_address,
      Form_areaaddrx,
      Form_tel,
      Form_email,
      Form_tax,
      Form_ln,
      Form_zn,
      Form_area,
      Form_qty,
      Form_sdate,
      Form_ldate,
      Form_period,
      Form_rtname,
      // quotxSelectModels,
      _TransModels,
      renTal_name,
      bill_addr,
      bill_email,
      bill_tel,
      bill_tax,
      bill_name,
      newValuePDFimg,
      tableData00,
      TitleType_Default_Receipt_Name,
      Datex_text,
      Form_fid,
      Form_renew_cid,
      Form_PakanSdate,
      Form_PakanLdate,
      Form_PakanSdate_Doc,
      Form_PakanLdate_Doc,
      Form_PakanAll_amt,
      Form_PakanAll_pvat,
      Form_PakanAll_vat,
      Form_PakanAll_Total,
      Form_PakanAll_Total_bill,
      Form_PakanAll_amt_first,
      Form_PakanAll_pvat_first,
      Form_PakanAll_vat_first,
      Form_PakanAll_Total_first,
      Pri1_text,
      Pri2_text,
      Pri3_text,
      FormNameFile_text,
      img,
      imglogo,
      _ReportValue_type_doc,
      cid_typePaper_ser,
      Form_wnote,
      paper_run,
      FormPeriod_choice,
      Form_renew_datex,
      Form_renew_sdate,
      Form_renew_ldate,
      DatexChoice_Sub2_1text, //ประกันภัยอัคคีภัย
      DatexChoice_Sub2_2text, //ภาษีที่ดินสิ่งปลูกสร้าง
      DatexChoice_Sub2_3text, //ให้ผู้เช่าครอบครองวันที่
      Title_text,
      Details_text,
      FormName1_choice,
      FormName2_choice,
      FormName3_choice,
      FormName4_choice,
      Contract_num) async {
    List<QuotxSelectModel> quotxSelectModels = [];
    List<ContractPhotoModel> contractPhotoModels = [];
    List<TeNantModel> teNantModels = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences
        .getString('renTalSer'); /////////////////////------------------------->
    String url_Payment =
        '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    try {
      var response_Payment = await httpClient.get(Uri.parse(url_Payment));
      var result_Payment = json.decode(response_Payment.body);

      if (result_Payment.toString() != 'null') {
        for (var map in result_Payment) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var p_bno = (_PayMentModel.bno == null) ? '-' : _PayMentModel.bno;
          var p_bank = (_PayMentModel.bank == null) ? '-' : _PayMentModel.bank;
          var p_bname =
              (_PayMentModel.bname == null) ? '-' : _PayMentModel.bname;
          if (autox.toString() == '1') {
            preferences.setString('PDF_bno', p_bno.toString());
            preferences.setString('PDF_bank', p_bank.toString());
            preferences.setString('PDF_bname', p_bname.toString());
          }
        }
      }
    } catch (e) {}

    /////////////////////------------------------->
    String url_paper_run =
        '${MyConstant().domain}/UP_Paper_Run.php?isAdd=true&ren=$ren&ciddoc=$Get_Value_cid&paper_run=${int.parse('$paper_run') + 1}&type=agm';
    try {
      var response = await httpClient.get(Uri.parse(url_paper_run));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {}
    } catch (e) {}

    /////////////////////------------------------->
    String url2 =
        '${MyConstant().domain}/GC_quot_conxPDF.php?isAdd=true&ren=$ren&ciddoc=$Get_Value_cid&qutser=$Get_Value_NameShop_index&fiddoc=$Form_fid';
    print(url2);
    try {
      var response2 = await httpClient.get(Uri.parse(url2));
      var result2 = json.decode(response2.body);
      // print(result2);
      if (result2.toString() != 'null') {
        for (var map in result2) {
          QuotxSelectModel quotxSelectModel = QuotxSelectModel.fromJson(map);
          quotxSelectModels.add(quotxSelectModel);
        }
      }
      print(quotxSelectModels.length);
    } catch (e) {}

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // final ren = preferences.getString('renTalSer');
    final user = preferences.getString('ser');
    final ciddoc = Get_Value_cid;
    final qutser = Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_photo_cont.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser';
    print('read_GC_photo aaa///// $url');

    try {
      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          ContractPhotoModel contractPhotoModel =
              ContractPhotoModel.fromJson(map);
          contractPhotoModels.add(contractPhotoModel);
        }
      }
      print('📸 จำนวนรูปที่โหลดได้: ${contractPhotoModels.length}');
    } catch (e) {
      print('❌ read_GC_photo error: $e');
    }

    String url_TeNant =
        '${MyConstant().domain}/GC_tenant.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&qutser=$qutser';
    print('read_GC_tenant $url_TeNant');

    try {
      var response = await httpClient.get(Uri.parse(url_TeNant));
      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          teNantModels.add(teNantModel);
        }
      }
      // print('👤 จำนวนผู้เช่าที่โหลดได้: ${teNantModels.length}');
    } catch (e) {
      print('❌ read_GC_tenant error: $e');
    }

/////////////////////------------------------->
    ///
    Future.delayed(Duration(milliseconds: 500), () async {
      if (type == 2) {
        String _ReportValue_type = cid_typePaper_ser;

        // print(_ReportValue_type);
        if (_ReportValue_type == '2') {
          Pdfgen_SubAgreement_Choice.exportPDF_SubAgreement_Choice(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              (Form_PakanAll_amt_first != null && Form_PakanAll_amt_first != '')
                  ? Form_PakanAll_amt_first
                  : 0.00,
              (Form_PakanAll_pvat_first != null &&
                      Form_PakanAll_pvat_first != '')
                  ? Form_PakanAll_pvat_first
                  : 0.00,
              (Form_PakanAll_vat_first != null && Form_PakanAll_vat_first != '')
                  ? Form_PakanAll_vat_first
                  : 0.00,
              (Form_PakanAll_Total_first != null &&
                      Form_PakanAll_Total_first != '')
                  ? Form_PakanAll_Total_first
                  : 0.00,
              FormPeriod_choice,
              Form_renew_datex,
              Form_renew_sdate,
              Form_renew_ldate,
              DatexChoice_Sub2_1text,
              DatexChoice_Sub2_2text,
              DatexChoice_Sub2_3text);
        } else if (_ReportValue_type == '3') {
          Pdfgen_SubAgreement_Choice2.exportPDF_SubAgreement_Choice2(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              (Form_PakanAll_amt_first != null && Form_PakanAll_amt_first != '')
                  ? Form_PakanAll_amt_first
                  : 0.00,
              (Form_PakanAll_pvat_first != null &&
                      Form_PakanAll_pvat_first != '')
                  ? Form_PakanAll_pvat_first
                  : 0.00,
              (Form_PakanAll_vat_first != null && Form_PakanAll_vat_first != '')
                  ? Form_PakanAll_vat_first
                  : 0.00,
              (Form_PakanAll_Total_first != null &&
                      Form_PakanAll_Total_first != '')
                  ? Form_PakanAll_Total_first
                  : 0.00,
              FormPeriod_choice,
              Form_renew_datex,
              Form_renew_sdate,
              Form_renew_ldate,
              DatexChoice_Sub2_1text,
              DatexChoice_Sub2_2text,
              DatexChoice_Sub2_3text);
        } else if (_ReportValue_type == '4') {
          Pdfgen_SubAgreement_Choice3.exportPDF_SubAgreement_Choice3(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              (Form_PakanAll_amt_first != null && Form_PakanAll_amt_first != '')
                  ? Form_PakanAll_amt_first
                  : 0.00,
              (Form_PakanAll_pvat_first != null &&
                      Form_PakanAll_pvat_first != '')
                  ? Form_PakanAll_pvat_first
                  : 0.00,
              (Form_PakanAll_vat_first != null && Form_PakanAll_vat_first != '')
                  ? Form_PakanAll_vat_first
                  : 0.00,
              (Form_PakanAll_Total_first != null &&
                      Form_PakanAll_Total_first != '')
                  ? Form_PakanAll_Total_first
                  : 0.00,
              FormPeriod_choice,
              Form_renew_datex,
              Form_renew_sdate,
              Form_renew_ldate,
              DatexChoice_Sub2_1text,
              DatexChoice_Sub2_2text);
          // } else if (_ReportValue_type == '6') {
        } else {
          Pdfgen_Agreement_JSpace2.exportPDF_Agreement_JSpace2(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '$bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              Pri1_text,
              Pri2_text,
              Pri3_text,
              Title_text,
              Details_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        }
      } else {
        // print('cid_typePaper_ser');
        // print(cid_typePaper_ser);
        String _ReportValue_type = cid_typePaper_ser;
        // String _ReportValue_type = _ReportValue_type_doc;
        print('_ReportValue_type  $_ReportValue_type');
        if (_ReportValue_type == '0' || _ReportValue_type == '1') {
          Pdfgen_Agreement.exportPDF_Agreement(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_areaaddrx,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        } else if (_ReportValue_type == '6') {
          Pdfgen_Agreement_JSpace.exportPDF_Agreement_JSpace(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              Pri1_text,
              Pri2_text,
              Pri3_text

              // (ser_user == null) ? '' : ser_user
              );
        } else if (_ReportValue_type == '2') {
          Pdfgen_Agreement_Choice.exportPDF_Agreement_Choice(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              Form_wnote,
              FormPeriod_choice,
              DatexChoice_Sub2_3text);
        } else if (_ReportValue_type == '3') {
          Pdfgen_Agreement_Choice2.exportPDF_Agreement_Choice2(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              Form_wnote,
              FormPeriod_choice,
              DatexChoice_Sub2_3text);
        } else if (_ReportValue_type == '4') {
          Pdfgen_Agreement_Choice3.exportPDF_Agreement_Choice3(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              bill_addr,
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              (Form_PakanAll_Total_bill != null &&
                      Form_PakanAll_Total_bill != '')
                  ? Form_PakanAll_Total_bill
                  : 0.00,
              Form_wnote,
              FormPeriod_choice);
        } else if (_ReportValue_type == '8' && ren == '106') {
          Pdfgen_Agreement_Choice8.exportPDF_Agreement_Choice8(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              Form_wnote,
              FormPeriod_choice,
              DatexChoice_Sub2_3text);
        } else if (_ReportValue_type == '9' && ren == '106') {
          Pdfgen_Agreement_Choice9.exportPDF_Agreement_Choice9(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor,
              Form_fid,
              Form_renew_cid,
              Form_PakanSdate,
              Form_PakanLdate,
              Form_PakanSdate_Doc,
              Form_PakanLdate_Doc,
              (Form_PakanAll_amt != null && Form_PakanAll_amt != '')
                  ? Form_PakanAll_amt
                  : 0.00,
              (Form_PakanAll_pvat != null && Form_PakanAll_pvat != '')
                  ? Form_PakanAll_pvat
                  : 0.00,
              (Form_PakanAll_vat != null && Form_PakanAll_vat != '')
                  ? Form_PakanAll_vat
                  : 0.00,
              (Form_PakanAll_Total != null && Form_PakanAll_Total != '')
                  ? Form_PakanAll_Total
                  : 0.00,
              Form_wnote,
              FormPeriod_choice,
              DatexChoice_Sub2_3text);
        } else if (_ReportValue_type == '5') {
          Pdfgen_Agreement_Ama1000.exportPDF_Agreement_Ama1000(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              img,
              imglogo,
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormNameFile_text);
        } else if (_ReportValue_type == 'อาคารพาณิชย์') {
          Pdfgen_Agreement_Ortor.exportPDF_Agreement_Ortor(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '$bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              _ReportValue_type_docOttor);
        } else if (_ReportValue_type == '8' || _ReportValue_type == '11') {
          Pdfgen_Agreement_Nichada.exportPDF_Agreement_Nichada(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        } else if (_ReportValue_type == '9' || _ReportValue_type == '12') {
          Pdfgen_Agreement_Nichada2.exportPDF_Agreement_Nichada2(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        } else if (_ReportValue_type == '10' || _ReportValue_type == '13') {
          Pdfgen_Agreement_Nichada3.exportPDF_Agreement_Nichada3(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        } else if (_ReportValue_type == '14' || _ReportValue_type == '15') {
          Pdfgen_Agreement_Nichada5.exportPDF_Agreement_Nichada5(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        } else if (_ReportValue_type == '16' || _ReportValue_type == '17') {
          Pdfgen_Agreement_Nichada4.exportPDF_Agreement_Nichada4(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice);
        } else if (_ReportValue_type == '18') {
          // nim สัญญาเช่าอาคาร
          Pdfgen_Agreementnim1.exportPDF_Agreementnim1(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              contractPhotoModels,
              Contract_num);
        } else if (_ReportValue_type == '19') {
          // nim สัญญาบริการ
          Pdfgen_Agreementnim2.exportPDF_Agreementnim2(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              contractPhotoModels);
        } else if (_ReportValue_type == '20') {
          // nim เอกสารแนบท้ายสัญญา1
          Pdfgen_Agreementnim3.exportPDF_Agreementnim3(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              contractPhotoModels);
        } else if (_ReportValue_type == '21') {
          // nim เอกสารแนบท้ายสัญญาหมายเลข 2
          Pdfgen_Agreementnim4.exportPDF_Agreementnim4(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              contractPhotoModels);
        } else if (_ReportValue_type == '22') {
          // nim เอกสารแนบท้ายสัญญาหมายเลข 2 ตกแต่งสถานที่
          Pdfgen_Agreementnim4place.exportPDF_Agreementnim4place(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              contractPhotoModels);
        } else if (_ReportValue_type == '23') {
          // nim เอกสารแนบท้ายสัญญาหมายเลข 3.1
          Pdfgen_Agreementnim5.exportPDF_Agreementnim5(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              contractPhotoModels);
        } else if (_ReportValue_type == '24') {
          // nim เอกสารแนบท้ายสัญญาหมายเลข 3.2
          Pdfgen_Agreementnim6.exportPDF_Agreementnim6(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              FormName1_choice,
              FormName2_choice,
              FormName3_choice,
              FormName4_choice,
              teNantModels,
              contractPhotoModels);
        } else if (_ReportValue_type == '25') {
          Pdfgen_Agreementlamphun.exportPDF_Agreementlamphun(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              teNantModels,
              contractPhotoModels);
        } else if (_ReportValue_type == '26') {
          Pdfgen_Agreementlamphun1.exportPDF_Agreementlamphun1(
              context,
              '${Get_Value_NameShop_index}',
              '${Get_Value_cid}',
              _verticalGroupValue,
              Form_nameshop,
              Form_typeshop,
              Form_bussshop,
              Form_bussscontact,
              Form_address,
              Form_tel,
              Form_email,
              Form_tax,
              Form_ln,
              Form_zn,
              Form_area,
              Form_qty,
              Form_sdate,
              Form_ldate,
              Form_period,
              Form_rtname,
              quotxSelectModels,
              _TransModels,
              '$renTal_name',
              '${bill_addr}',
              '${bill_email}',
              '${bill_tel}',
              '${bill_tax}',
              '${bill_name}',
              newValuePDFimg,
              tableData00,
              TitleType_Default_Receipt_Name,
              Datex_text,
              teNantModels,
              contractPhotoModels);
        } else if (_ReportValue_type == '27') {
          Pdfgen_Agreementlamphun2.exportPDF_Agreementlamphun2(
            context,
            '${Get_Value_NameShop_index}',
            '${Get_Value_cid}',
            _verticalGroupValue,
            Form_nameshop,
            Form_typeshop,
            Form_bussshop,
            Form_bussscontact,
            Form_address,
            Form_tel,
            Form_email,
            Form_tax,
            Form_ln,
            Form_zn,
            Form_area,
            Form_qty,
            Form_sdate,
            Form_ldate,
            Form_period,
            Form_rtname,
            quotxSelectModels,
            _TransModels,
            '$renTal_name',
            '${bill_addr}',
            '${bill_email}',
            '${bill_tel}',
            '${bill_tax}',
            '${bill_name}',
            newValuePDFimg,
            tableData00,
            TitleType_Default_Receipt_Name,
            Datex_text,
            teNantModels,
            contractPhotoModels,
            FormName1_choice,
            FormName2_choice,
            FormName3_choice,
            FormName4_choice,
          );
        }
      }
    });
  }
}

// ////////////------------------------------------------------------>(Export file)
// Future<void> _showMyDialog_SAVE(
//     context, tableData00, newValuePDFimg, ren, type) async {
//   String _ReportValue_type_doc = "สัญญาระบบหลัก";
//   String _ReportValue_type_JSpace = "JSpace";
//   String _ReportValue_type_docOttor = "อาคารพาณิชย์";
//   String _ReportValue_type_Choice = "สัญญาเช่าที่ดิน";
//   String _ReportValue_type_Ama = "สัญญาเช่าพื้นที่";
//   String _verticalGroupValue_NameFile = "จากระบบ";
//   String Value_Report = ' ';
//   String NameFile_ = '';
//   String Pre_and_Dow = '';
//   String? TitleType_Default_Receipt_Name;
//   final _formKey = GlobalKey<FormState>();
//   final FormNameFile_text = TextEditingController();
//   final Datex_text = TextEditingController();
//   final Pri1_text = TextEditingController();
//   final Pri2_text = TextEditingController();
//   final Pri3_text = TextEditingController();
//   var date_x = DateTime.now();
//   var formatter = DateFormat('dd-MM-yyyy');
//   setState(() {
//     Datex_text.text = "${formatter.format(date_x)}";
//     Pri1_text.text = '0.00';
//     Pri2_text.text = '0.00';
//     Pri3_text.text = '0.00';
//   });
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return StreamBuilder(
//         stream: Stream.periodic(const Duration(seconds: 0)),
//         builder: (context, snapshot) {
//           return Form(
//             key: _formKey,
//             child: AlertDialog(
//               shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(15.0))),
//               content: SingleChildScrollView(
//                 child: ListBody(
//                   children: <Widget>[
//                     SizedBox(height: 2),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: const Text(
//                         'วันที่ทำสัญญา :',
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           color: ReportScreen_Color.Colors_Text2_,
//                           // fontWeight: FontWeight.bold,
//                           fontFamily: Font_.Fonts_T,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: InkWell(
//                         onTap: () {
//                           Future<DateTime?> picked = showDatePicker(
//                             // locale: const Locale('th', 'TH'),
//                             helpText: 'เลือกวันที่',
//                             confirmText: 'ตกลง',
//                             cancelText: 'ยกเลิก',
//                             context: context,
//                             initialDate: DateTime(DateTime.now().year,
//                                 DateTime.now().month, DateTime.now().day - 1),
//                             initialDatePickerMode: DatePickerMode.day,
//                             firstDate: DateTime(2023, 1, 1),
//                             lastDate: DateTime(
//                                 DateTime.now().year,
//                                 DateTime.now().month,
//                                 DateTime.now().day + 100),
//                             // selectableDayPredicate: _decideWhichDayToEnable,
//                             builder: (context, child) {
//                               return Theme(
//                                 data: Theme.of(context).copyWith(
//                                   colorScheme: const ColorScheme.light(
//                                     primary: AppBarColors
//                                         .ABar_Colors, // header background color
//                                     onPrimary:
//                                         Colors.white, // header text color
//                                     onSurface:
//                                         Colors.black, // body text color
//                                   ),
//                                   textButtonTheme: TextButtonThemeData(
//                                     style: TextButton.styleFrom(
//                                       primary:
//                                           Colors.black, // button text color
//                                     ),
//                                   ),
//                                 ),
//                                 child: child!,
//                               );
//                             },
//                           );
//                           picked.then((result) {
//                             if (picked != null) {
//                               // TransReBillModels = [];

//                               var formatter = DateFormat('dd-MM-yyyy');
//                               print("${formatter.format(result!)}");
//                               setState(() {
//                                 Datex_text.text =
//                                     "${formatter.format(result)}";
//                               });
//                             }
//                           });
//                         },
//                         child: Container(
//                             decoration: BoxDecoration(
//                               color: AppbackgroundColor.Sub_Abg_Colors,
//                               borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(10),
//                                   topRight: Radius.circular(10),
//                                   bottomLeft: Radius.circular(10),
//                                   bottomRight: Radius.circular(10)),
//                               border:
//                                   Border.all(color: Colors.grey, width: 1),
//                             ),
//                             width: 200,
//                             padding: const EdgeInsets.all(8.0),
//                             child: Center(
//                               child: Text(
//                                 (Datex_text.text == null)
//                                     ? 'เลือก'
//                                     : '${Datex_text.text}',
//                                 style: const TextStyle(
//                                   color: ReportScreen_Color.Colors_Text2_,
//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             )),
//                       ),
//                     ),
//                     (ren.toString() == '102' ||
//                             ren.toString() == '106' ||
//                             ren.toString() == '72' ||
//                             ren.toString() == '92' ||
//                             ren.toString() == '93' ||
//                             ren.toString() == '94' ||
//                             ren.toString() == '90')
//                         ? SizedBox()
//                         : Column(
//                             children: [
//                               const Text(
//                                 'รูปแบบปกติ:',
//                                 style: TextStyle(
//                                   color: ReportScreen_Color.Colors_Text2_,
//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.3),
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(15),
//                                     topRight: Radius.circular(15),
//                                     bottomLeft: Radius.circular(15),
//                                     bottomRight: Radius.circular(15),
//                                   ),
//                                   border: Border.all(
//                                       color: Colors.grey, width: 1),
//                                 ),
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: RadioGroup<String>.builder(
//                                   direction: Axis.horizontal,
//                                   groupValue: _ReportValue_type_doc,
//                                   horizontalAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   onChanged: (value) {
//                                     // setState(() {
//                                     //   FormNameFile_text.clear();
//                                     // });
//                                     setState(() {
//                                       _ReportValue_type_doc = value ?? '';
//                                     });

//                                     // if (value == 'ไม่ระบุ') {
//                                     //   setState(() {
//                                     //     TitleType_Default_Receipt_Name = null;
//                                     //   });
//                                     // } else {
//                                     //   setState(() {
//                                     //     TitleType_Default_Receipt_Name = value;
//                                     //   });
//                                     // }
//                                   },
//                                   items: const <String>[
//                                     'สัญญาระบบหลัก',
//                                   ],
//                                   textStyle: const TextStyle(
//                                     fontSize: 15,
//                                     color: ReportScreen_Color.Colors_Text2_,
//                                     // fontWeight: FontWeight.bold,
//                                     fontFamily: Font_.Fonts_T,
//                                   ),
//                                   itemBuilder: (item) => RadioButtonBuilder(
//                                     item,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                     SizedBox(height: 2),

//                     if (ren.toString() == '72' ||
//                         ren.toString() == '92' ||
//                         ren.toString() == '93' ||
//                         ren.toString() == '94')
//                       Container(
//                           child: Column(
//                         children: [
//                           SizedBox(height: 2),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'รูปแบบสัญญา อต. :',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(15),
//                                 topRight: Radius.circular(15),
//                                 bottomLeft: Radius.circular(15),
//                                 bottomRight: Radius.circular(15),
//                               ),
//                               border:
//                                   Border.all(color: Colors.grey, width: 1),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: RadioGroup<String>.builder(
//                               direction: Axis.horizontal,
//                               groupValue: _ReportValue_type_docOttor,
//                               horizontalAlignment:
//                                   MainAxisAlignment.spaceAround,
//                               onChanged: (value) {
//                                 // setState(() {
//                                 //   FormNameFile_text.clear();
//                                 // });
//                                 setState(() {
//                                   _ReportValue_type_docOttor = value ?? '';
//                                 });

//                                 // if (value == 'ไม่ระบุ') {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = null;
//                                 //   });
//                                 // } else {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = value;
//                                 //   });
//                                 // }
//                               },
//                               items: <String>[
//                                 'อาคารพาณิชย์',
//                                 'แผงค้าจำหน่ายสัตว์น้ำ (แพปลา)',
//                                 'แผงค้าดองสัตว์น้ำ (ดองปลา)',
//                                 'แผงค้าแปรรูปสัตว์น้ำ (แปรรูปปลา)',
//                                 // for (int index = 0;
//                                 //     index < Type_Ortor.length;
//                                 //     index)
//                                 //   '${Type_Ortor[index]}',
//                               ],
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                               itemBuilder: (item) => RadioButtonBuilder(
//                                 item,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                         ],
//                       )),

//                     ///Type_Choice
//                     if (ren.toString() == '106')
//                       Container(
//                           child: Column(
//                         children: [
//                           SizedBox(height: 2),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'รูปแบบสัญญา ชอยส์ มินิสโตร์. :',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(15),
//                                 topRight: Radius.circular(15),
//                                 bottomLeft: Radius.circular(15),
//                                 bottomRight: Radius.circular(15),
//                               ),
//                               border:
//                                   Border.all(color: Colors.grey, width: 1),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: RadioGroup<String>.builder(
//                               direction: Axis.horizontal,
//                               groupValue: _ReportValue_type_Choice,
//                               horizontalAlignment:
//                                   MainAxisAlignment.spaceAround,
//                               onChanged: (value) {
//                                 // setState(() {
//                                 //   FormNameFile_text.clear();
//                                 // });
//                                 setState(() {
//                                   _ReportValue_type_Choice = value ?? '';
//                                 });

//                                 // if (value == 'ไม่ระบุ') {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = null;
//                                 //   });
//                                 // } else {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = value;
//                                 //   });
//                                 // }
//                               },
//                               items: <String>[
//                                 'สัญญาเช่าที่ดิน',
//                                 'สัญญาห้องเช่า',
//                                 'สัญญาบริการ',
//                               ],
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                               itemBuilder: (item) => RadioButtonBuilder(
//                                 item,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                         ],
//                       )),

//                     ///Type_Choice
//                     if (ren.toString() == '102')
//                       Container(
//                           child: Column(
//                         children: [
//                           SizedBox(height: 2),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               'รูปแบบสัญญา อาม่า1000สุข. :',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.3),
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(15),
//                                 topRight: Radius.circular(15),
//                                 bottomLeft: Radius.circular(15),
//                                 bottomRight: Radius.circular(15),
//                               ),
//                               border:
//                                   Border.all(color: Colors.grey, width: 1),
//                             ),
//                             padding: const EdgeInsets.all(8.0),
//                             child: RadioGroup<String>.builder(
//                               direction: Axis.horizontal,
//                               groupValue: _ReportValue_type_Ama,
//                               horizontalAlignment:
//                                   MainAxisAlignment.spaceAround,
//                               onChanged: (value) {
//                                 // setState(() {
//                                 //   FormNameFile_text.clear();
//                                 // });
//                                 setState(() {
//                                   _ReportValue_type_Ama = value ?? '';
//                                 });

//                                 // if (value == 'ไม่ระบุ') {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = null;
//                                 //   });
//                                 // } else {
//                                 //   setState(() {
//                                 //     TitleType_Default_Receipt_Name = value;
//                                 //   });
//                                 // }
//                               },
//                               items: <String>[
//                                 'สัญญาเช่าพื้นที่',
//                               ],
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                               itemBuilder: (item) => RadioButtonBuilder(
//                                 item,
//                               ),
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: const Text(
//                               '20.อื่นๆ :',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: ReportScreen_Color.Colors_Text2_,
//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: TextFormField(
//                               keyboardType: TextInputType.text,
//                               controller: FormNameFile_text,

//                               // maxLength: 13,
//                               cursorColor: Colors.green,
//                               decoration: InputDecoration(
//                                   fillColor: Colors.white.withOpacity(0.3),
//                                   filled: true,
//                                   focusedBorder: const OutlineInputBorder(
//                                     borderRadius: BorderRadius.only(
//                                       topRight: Radius.circular(15),
//                                       topLeft: Radius.circular(15),
//                                       bottomRight: Radius.circular(15),
//                                       bottomLeft: Radius.circular(15),
//                                     ),
//                                     borderSide: BorderSide(
//                                       width: 1,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   errorStyle:
//                                       TextStyle(fontFamily: Font_.Fonts_T),
//                                   enabledBorder: const OutlineInputBorder(
//                                     borderRadius: BorderRadius.only(
//                                       topRight: Radius.circular(15),
//                                       topLeft: Radius.circular(15),
//                                       bottomRight: Radius.circular(15),
//                                       bottomLeft: Radius.circular(15),
//                                     ),
//                                     borderSide: BorderSide(
//                                       width: 1,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   // labelText:
//                                   //     'วางเงินประกันตลอดอายุสัญญาเช่า : ',
//                                   labelStyle: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.black54,
//                                       fontFamily: Font_.Fonts_T)),
//                               // inputFormatters: [
//                               //   FilteringTextInputFormatter.deny(
//                               //       RegExp(r'\s')),
//                               //   // FilteringTextInputFormatter.deny(
//                               //   //     RegExp(r'^0')),
//                               //   FilteringTextInputFormatter.allow(
//                               //       RegExp(r'[0-9 .]')),
//                               // ],
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                         ],
//                       )),
//                     if (ren.toString() == '90')
//                       if (type == 1)
//                         Column(
//                           children: [
//                             SizedBox(height: 2),
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: const Text(
//                                 'รูปแบบสัญญา JSpace. :',
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                   color: ReportScreen_Color.Colors_Text2_,
//                                   // fontWeight: FontWeight.bold,
//                                   fontFamily: Font_.Fonts_T,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(15),
//                                   topRight: Radius.circular(15),
//                                   bottomLeft: Radius.circular(15),
//                                   bottomRight: Radius.circular(15),
//                                 ),
//                                 border:
//                                     Border.all(color: Colors.grey, width: 1),
//                               ),
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.3),
//                                       borderRadius: const BorderRadius.only(
//                                         topLeft: Radius.circular(15),
//                                         topRight: Radius.circular(15),
//                                         bottomLeft: Radius.circular(15),
//                                         bottomRight: Radius.circular(15),
//                                       ),
//                                       border: Border.all(
//                                           color: Colors.grey, width: 1),
//                                     ),
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: RadioGroup<String>.builder(
//                                       direction: Axis.horizontal,
//                                       groupValue: _ReportValue_type_JSpace,
//                                       horizontalAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       onChanged: (value) {
//                                         // setState(() {
//                                         //   FormNameFile_text.clear();
//                                         // });
//                                         setState(() {
//                                           _ReportValue_type_JSpace =
//                                               value ?? '';
//                                         });

//                                         // if (value == 'ไม่ระบุ') {
//                                         //   setState(() {
//                                         //     TitleType_Default_Receipt_Name = null;
//                                         //   });
//                                         // } else {
//                                         //   setState(() {
//                                         //     TitleType_Default_Receipt_Name = value;
//                                         //   });
//                                         // }
//                                       },
//                                       items: const <String>[
//                                         'JSpace',
//                                         // 'แนบท้าย',
//                                       ],
//                                       textStyle: const TextStyle(
//                                         fontSize: 15,
//                                         color:
//                                             ReportScreen_Color.Colors_Text2_,
//                                         // fontWeight: FontWeight.bold,
//                                         fontFamily: Font_.Fonts_T,
//                                       ),
//                                       itemBuilder: (item) =>
//                                           RadioButtonBuilder(
//                                         item,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: 2),
//                                   Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: const Text(
//                                       'อัตราค่าเช่าเดือนละ :',
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         color:
//                                             ReportScreen_Color.Colors_Text2_,
//                                         // fontWeight: FontWeight.bold,
//                                         fontFamily: Font_.Fonts_T,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: TextFormField(
//                                       keyboardType: TextInputType.number,
//                                       controller: Pri1_text,

//                                       // maxLength: 13,
//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                         fillColor:
//                                             Colors.white.withOpacity(0.3),
//                                         filled: true,
//                                         focusedBorder:
//                                             const OutlineInputBorder(
//                                           borderRadius: BorderRadius.only(
//                                             topRight: Radius.circular(15),
//                                             topLeft: Radius.circular(15),
//                                             bottomRight: Radius.circular(15),
//                                             bottomLeft: Radius.circular(15),
//                                           ),
//                                           borderSide: BorderSide(
//                                             width: 1,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                         errorStyle: TextStyle(
//                                             fontFamily: Font_.Fonts_T),
//                                         enabledBorder:
//                                             const OutlineInputBorder(
//                                           borderRadius: BorderRadius.only(
//                                             topRight: Radius.circular(15),
//                                             topLeft: Radius.circular(15),
//                                             bottomRight: Radius.circular(15),
//                                             bottomLeft: Radius.circular(15),
//                                           ),
//                                           borderSide: BorderSide(
//                                             width: 1,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                         // labelText: 'อัตราค่าเช่าเดือนละ : ',
//                                         labelStyle: const TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black54,
//                                             fontFamily: Font_.Fonts_T),
//                                       ),
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.deny(
//                                             RegExp(r'\s')),
//                                         // FilteringTextInputFormatter.deny(
//                                         //     RegExp(r'^0')),
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp(r'[0-9 .]')),
//                                       ],
//                                     ),
//                                   ),
//                                   Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: const Text(
//                                       'วางเงินประกันตลอดอายุสัญญาเช่า :',
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         color:
//                                             ReportScreen_Color.Colors_Text2_,
//                                         // fontWeight: FontWeight.bold,
//                                         fontFamily: Font_.Fonts_T,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: TextFormField(
//                                       keyboardType: TextInputType.number,
//                                       controller: Pri2_text,

//                                       // maxLength: 13,
//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                           fillColor:
//                                               Colors.white.withOpacity(0.3),
//                                           filled: true,
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               topLeft: Radius.circular(15),
//                                               bottomRight:
//                                                   Radius.circular(15),
//                                               bottomLeft: Radius.circular(15),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           errorStyle: TextStyle(
//                                               fontFamily: Font_.Fonts_T),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               topLeft: Radius.circular(15),
//                                               bottomRight:
//                                                   Radius.circular(15),
//                                               bottomLeft: Radius.circular(15),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           // labelText:
//                                           //     'วางเงินประกันตลอดอายุสัญญาเช่า : ',
//                                           labelStyle: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.black54,
//                                               fontFamily: Font_.Fonts_T)),
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.deny(
//                                             RegExp(r'\s')),
//                                         // FilteringTextInputFormatter.deny(
//                                         //     RegExp(r'^0')),
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp(r'[0-9 .]')),
//                                       ],
//                                     ),
//                                   ),
//                                   Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: const Text(
//                                       'ผู้เช่าต้องชำระค่าส่วนกลางต่อเดือน :',
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         color:
//                                             ReportScreen_Color.Colors_Text2_,
//                                         // fontWeight: FontWeight.bold,
//                                         fontFamily: Font_.Fonts_T,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: TextFormField(
//                                       keyboardType: TextInputType.number,
//                                       controller: Pri3_text,

//                                       // maxLength: 13,
//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                           fillColor:
//                                               Colors.white.withOpacity(0.3),
//                                           filled: true,
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               topLeft: Radius.circular(15),
//                                               bottomRight:
//                                                   Radius.circular(15),
//                                               bottomLeft: Radius.circular(15),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           errorStyle: TextStyle(
//                                               fontFamily: Font_.Fonts_T),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               topLeft: Radius.circular(15),
//                                               bottomRight:
//                                                   Radius.circular(15),
//                                               bottomLeft: Radius.circular(15),
//                                             ),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.black,
//                                             ),
//                                           ),
//                                           // labelText:
//                                           //     'ผู้เช่าต้องชำระค่าส่วนกลางต่อเดือน : ',
//                                           labelStyle: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.black54,
//                                               fontFamily: Font_.Fonts_T)),
//                                       inputFormatters: [
//                                         FilteringTextInputFormatter.deny(
//                                             RegExp(r'\s')),
//                                         // FilteringTextInputFormatter.deny(
//                                         //     RegExp(r'^0')),
//                                         FilteringTextInputFormatter.allow(
//                                             RegExp(r'[0-9 .]')),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                     const Text(
//                       'หัวบิล :',
//                       style: TextStyle(
//                         color: ReportScreen_Color.Colors_Text2_,
//                         // fontWeight: FontWeight.bold,
//                         fontFamily: Font_.Fonts_T,
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(15),
//                           topRight: Radius.circular(15),
//                           bottomLeft: Radius.circular(15),
//                           bottomRight: Radius.circular(15),
//                         ),
//                         border: Border.all(color: Colors.grey, width: 1),
//                       ),
//                       padding: const EdgeInsets.all(8.0),
//                       child: RadioGroup<String>.builder(
//                         direction: Axis.horizontal,
//                         groupValue: _ReportValue_type,
//                         horizontalAlignment: MainAxisAlignment.spaceAround,
//                         onChanged: (value) {
//                           // setState(() {
//                           //   FormNameFile_text.clear();
//                           // });
//                           setState(() {
//                             _ReportValue_type = value ?? '';
//                           });

//                           if (value == 'ไม่ระบุ') {
//                             setState(() {
//                               TitleType_Default_Receipt_Name = null;
//                             });
//                           } else {
//                             setState(() {
//                               TitleType_Default_Receipt_Name = value;
//                             });
//                           }
//                         },
//                         items: const <String>[
//                           'ไม่ระบุ',
//                           'ต้นฉบับ',
//                           'สำเนา',
//                         ],
//                         textStyle: const TextStyle(
//                           fontSize: 15,
//                           color: ReportScreen_Color.Colors_Text2_,
//                           // fontWeight: FontWeight.bold,
//                           fontFamily: Font_.Fonts_T,
//                         ),
//                         itemBuilder: (item) => RadioButtonBuilder(
//                           item,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: InkWell(
//                         onTap: (type == 2)
//                             ? () {
//                                 String _ReportValue_type =
//                                     (ren.toString() == '90')
//                                         ? _ReportValue_type_JSpace
//                                         : (ren.toString() == '72' ||
//                                                 ren.toString() == '92' ||
//                                                 ren.toString() == '93' ||
//                                                 ren.toString() == '94')
//                                             ? _ReportValue_type_docOttor
//                                             : (ren.toString() == '102')
//                                                 ? _ReportValue_type_Ama
//                                                 : (ren.toString() == '106')
//                                                     ? _ReportValue_type_Choice
//                                                     : _ReportValue_type_doc;
//                                 print(_ReportValue_type);
//                                 if (_ReportValue_type == 'สัญญาเช่าที่ดิน') {
//                                   Pdfgen_SubAgreement_Choice
//                                       .exportPDF_SubAgreement_Choice(
//                                     context,
//                                     '${widget.Get_Value_NameShop_index}',
//                                     '${widget.Get_Value_cid}',
//                                     _verticalGroupValue,
//                                     Form_nameshop.text,
//                                     Form_typeshop.text,
//                                     Form_bussshop.text,
//                                     Form_bussscontact.text,
//                                     Form_address.text,
//                                     Form_tel.text,
//                                     Form_email.text,
//                                     Form_tax.text,
//                                     Form_ln.text,
//                                     Form_zn.text,
//                                     Form_area.text,
//                                     Form_qty.text,
//                                     Form_sdate.text,
//                                     Form_ldate.text,
//                                     Form_period.text,
//                                     Form_rtname.text,
//                                     quotxSelectModels,
//                                     _TransModels,
//                                     '$renTal_name',
//                                     '${renTalModels[0].bill_addr}',
//                                     '${renTalModels[0].bill_email}',
//                                     '${renTalModels[0].bill_tel}',
//                                     '${renTalModels[0].bill_tax}',
//                                     '${renTalModels[0].bill_name}',
//                                     newValuePDFimg,
//                                     tableData00,
//                                     TitleType_Default_Receipt_Name,
//                                     Datex_text,
//                                     _ReportValue_type_docOttor,
//                                     Form_fid.text,
//                                     Form_renew_cid.text,
//                                     Form_PakanSdate.text,
//                                     Form_PakanLdate.text,
//                                     Form_PakanSdate_Doc.text,
//                                     Form_PakanLdate_Doc.text,
//                                     Form_PakanAll_amt.text,
//                                     Form_PakanAll_pvat.text,
//                                     Form_PakanAll_vat.text,
//                                     Form_PakanAll_Total.text,
//                                   );
//                                 } else if (_ReportValue_type ==
//                                     'สัญญาห้องเช่า') {
//                                   Pdfgen_SubAgreement_Choice2
//                                       .exportPDF_SubAgreement_Choice2(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           _ReportValue_type_docOttor,
//                                           Form_fid.text,
//                                           Form_renew_cid.text,
//                                           Form_PakanSdate.text,
//                                           Form_PakanLdate.text,
//                                           Form_PakanSdate_Doc.text,
//                                           Form_PakanLdate_Doc.text,
//                                           Form_PakanAll_amt.text,
//                                           Form_PakanAll_pvat.text,
//                                           Form_PakanAll_vat.text,
//                                           Form_PakanAll_Total.text);
//                                 } else if (_ReportValue_type ==
//                                     'สัญญาบริการ') {
//                                   Pdfgen_SubAgreement_Choice3
//                                       .exportPDF_SubAgreement_Choice3(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           _ReportValue_type_docOttor,
//                                           Form_fid.text,
//                                           Form_renew_cid.text,
//                                           Form_PakanSdate.text,
//                                           Form_PakanLdate.text,
//                                           Form_PakanSdate_Doc.text,
//                                           Form_PakanLdate_Doc.text,
//                                           Form_PakanAll_amt.text,
//                                           Form_PakanAll_pvat.text,
//                                           Form_PakanAll_vat.text,
//                                           Form_PakanAll_Total.text);
//                                 } else if (_ReportValue_type == 'JSpace') {
//                                   Pdfgen_Agreement_JSpace2
//                                       .exportPDF_Agreement_JSpace2(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           Pri1_text,
//                                           Pri2_text,
//                                           Pri3_text);
//                                 }
//                               }
//                             : () {
//                                 String _ReportValue_type =
//                                     (ren.toString() == '90')
//                                         ? _ReportValue_type_JSpace
//                                         : (ren.toString() == '72' ||
//                                                 ren.toString() == '92' ||
//                                                 ren.toString() == '93' ||
//                                                 ren.toString() == '94')
//                                             ? _ReportValue_type_docOttor
//                                             : (ren.toString() == '102')
//                                                 ? _ReportValue_type_Ama
//                                                 : (ren.toString() == '106')
//                                                     ? _ReportValue_type_Choice
//                                                     : _ReportValue_type_doc;

//                                 if (_ReportValue_type == 'ปกติ') {
//                                   Pdfgen_Agreement.exportPDF_Agreement(
//                                       context,
//                                       '${widget.Get_Value_NameShop_index}',
//                                       '${widget.Get_Value_cid}',
//                                       _verticalGroupValue,
//                                       Form_nameshop.text,
//                                       Form_typeshop.text,
//                                       Form_bussshop.text,
//                                       Form_bussscontact.text,
//                                       Form_address.text,
//                                       Form_tel.text,
//                                       Form_email.text,
//                                       Form_tax.text,
//                                       Form_ln.text,
//                                       Form_zn.text,
//                                       Form_area.text,
//                                       Form_qty.text,
//                                       Form_sdate.text,
//                                       Form_ldate.text,
//                                       Form_period.text,
//                                       Form_rtname.text,
//                                       quotxSelectModels,
//                                       _TransModels,
//                                       '$renTal_name',
//                                       '${renTalModels[0].bill_addr}',
//                                       '${renTalModels[0].bill_email}',
//                                       '${renTalModels[0].bill_tel}',
//                                       '${renTalModels[0].bill_tax}',
//                                       '${renTalModels[0].bill_name}',
//                                       newValuePDFimg,
//                                       tableData00,
//                                       TitleType_Default_Receipt_Name,
//                                       Datex_text);
//                                 } else if (_ReportValue_type == 'JSpace') {
//                                   Pdfgen_Agreement_JSpace
//                                       .exportPDF_Agreement_JSpace(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           Pri1_text,
//                                           Pri2_text,
//                                           Pri3_text

//                                           // (ser_user == null) ? '' : ser_user
//                                           );
//                                 } else if (_ReportValue_type ==
//                                     'สัญญาเช่าที่ดิน') {
//                                   Pdfgen_Agreement_Choice
//                                       .exportPDF_Agreement_Choice(
//                                     context,
//                                     '${widget.Get_Value_NameShop_index}',
//                                     '${widget.Get_Value_cid}',
//                                     _verticalGroupValue,
//                                     Form_nameshop.text,
//                                     Form_typeshop.text,
//                                     Form_bussshop.text,
//                                     Form_bussscontact.text,
//                                     Form_address.text,
//                                     Form_tel.text,
//                                     Form_email.text,
//                                     Form_tax.text,
//                                     Form_ln.text,
//                                     Form_zn.text,
//                                     Form_area.text,
//                                     Form_qty.text,
//                                     Form_sdate.text,
//                                     Form_ldate.text,
//                                     Form_period.text,
//                                     Form_rtname.text,
//                                     quotxSelectModels,
//                                     _TransModels,
//                                     '$renTal_name',
//                                     '${renTalModels[0].bill_addr}',
//                                     '${renTalModels[0].bill_email}',
//                                     '${renTalModels[0].bill_tel}',
//                                     '${renTalModels[0].bill_tax}',
//                                     '${renTalModels[0].bill_name}',
//                                     newValuePDFimg,
//                                     tableData00,
//                                     TitleType_Default_Receipt_Name,
//                                     Datex_text,
//                                     _ReportValue_type_docOttor,
//                                     Form_fid.text,
//                                     Form_renew_cid.text,
//                                     Form_PakanSdate.text,
//                                     Form_PakanLdate.text,
//                                     Form_PakanSdate_Doc.text,
//                                     Form_PakanLdate_Doc.text,
//                                     Form_PakanAll_amt.text,
//                                     Form_PakanAll_pvat.text,
//                                     Form_PakanAll_vat.text,
//                                     Form_PakanAll_Total.text,
//                                   );
//                                 } else if (_ReportValue_type ==
//                                     'สัญญาห้องเช่า') {
//                                   Pdfgen_Agreement_Choice2
//                                       .exportPDF_Agreement_Choice2(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           _ReportValue_type_docOttor,
//                                           Form_fid.text,
//                                           Form_renew_cid.text,
//                                           Form_PakanSdate.text,
//                                           Form_PakanLdate.text,
//                                           Form_PakanSdate_Doc.text,
//                                           Form_PakanLdate_Doc.text,
//                                           Form_PakanAll_amt.text,
//                                           Form_PakanAll_pvat.text,
//                                           Form_PakanAll_vat.text,
//                                           Form_PakanAll_Total.text);
//                                 } else if (_ReportValue_type ==
//                                     'สัญญาบริการ') {
//                                   Pdfgen_Agreement_Choice3
//                                       .exportPDF_Agreement_Choice3(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           _ReportValue_type_docOttor,
//                                           Form_fid.text,
//                                           Form_renew_cid.text,
//                                           Form_PakanSdate.text,
//                                           Form_PakanLdate.text,
//                                           Form_PakanSdate_Doc.text,
//                                           Form_PakanLdate_Doc.text,
//                                           Form_PakanAll_amt.text,
//                                           Form_PakanAll_pvat.text,
//                                           Form_PakanAll_vat.text,
//                                           Form_PakanAll_Total.text,
//                                           Form_PakanAll_Total_bill.text);
//                                 } else if (_ReportValue_type ==
//                                     'สัญญาเช่าพื้นที่') {
//                                   Pdfgen_Agreement_Ama1000.exportPDF_Agreement_Ama1000(
//                                       context,
//                                       '${widget.Get_Value_NameShop_index}',
//                                       '${widget.Get_Value_cid}',
//                                       _verticalGroupValue,
//                                       Form_nameshop.text,
//                                       Form_typeshop.text,
//                                       Form_bussshop.text,
//                                       Form_bussscontact.text,
//                                       Form_address.text,
//                                       Form_tel.text,
//                                       Form_email.text,
//                                       Form_tax.text,
//                                       Form_ln.text,
//                                       Form_zn.text,
//                                       Form_area.text,
//                                       Form_qty.text,
//                                       Form_sdate.text,
//                                       Form_ldate.text,
//                                       Form_period.text,
//                                       Form_rtname.text,
//                                       quotxSelectModels,
//                                       _TransModels,
//                                       '$renTal_name',
//                                       '${renTalModels[0].bill_addr}',
//                                       '${renTalModels[0].bill_email}',
//                                       '${renTalModels[0].bill_tel}',
//                                       '${renTalModels[0].bill_tax}',
//                                       '${renTalModels[0].bill_name}',
//                                       'files/$foder/contract/${renTalModels[0].img}',
//                                       'files/$foder/contract/${renTalModels[0].imglogo}',
//                                       newValuePDFimg,
//                                       tableData00,
//                                       TitleType_Default_Receipt_Name,
//                                       Datex_text,
//                                       FormNameFile_text);
//                                 } else if (_ReportValue_type ==
//                                     'อาคารพาณิชย์') {
//                                   Pdfgen_Agreement_Ortor
//                                       .exportPDF_Agreement_Ortor(
//                                           context,
//                                           '${widget.Get_Value_NameShop_index}',
//                                           '${widget.Get_Value_cid}',
//                                           _verticalGroupValue,
//                                           Form_nameshop.text,
//                                           Form_typeshop.text,
//                                           Form_bussshop.text,
//                                           Form_bussscontact.text,
//                                           Form_address.text,
//                                           Form_tel.text,
//                                           Form_email.text,
//                                           Form_tax.text,
//                                           Form_ln.text,
//                                           Form_zn.text,
//                                           Form_area.text,
//                                           Form_qty.text,
//                                           Form_sdate.text,
//                                           Form_ldate.text,
//                                           Form_period.text,
//                                           Form_rtname.text,
//                                           quotxSelectModels,
//                                           _TransModels,
//                                           '$renTal_name',
//                                           '${renTalModels[0].bill_addr}',
//                                           '${renTalModels[0].bill_email}',
//                                           '${renTalModels[0].bill_tel}',
//                                           '${renTalModels[0].bill_tax}',
//                                           '${renTalModels[0].bill_name}',
//                                           newValuePDFimg,
//                                           tableData00,
//                                           TitleType_Default_Receipt_Name,
//                                           Datex_text,
//                                           _ReportValue_type_docOttor);
//                                 } else {}

//                                 // (ren.toString() == '82')
//                                 //     ?
//                                 // Pdfgen_Agreement_Ekkamai
//                                 //         .exportPDF_Agreement_Ekkamai(
//                                 //             context,
//                                 //             '${widget.Get_Value_NameShop_index}',
//                                 //             '${widget.Get_Value_cid}',
//                                 //             _verticalGroupValue,
//                                 //             Form_nameshop.text,
//                                 //             Form_typeshop.text,
//                                 //             Form_bussshop.text,
//                                 //             Form_bussscontact.text,
//                                 //             Form_address.text,
//                                 //             Form_tel.text,
//                                 //             Form_email.text,
//                                 //             Form_tax.text,
//                                 //             Form_ln.text,
//                                 //             Form_zn.text,
//                                 //             Form_area.text,
//                                 //             Form_qty.text,
//                                 //             Form_sdate.text,
//                                 //             Form_ldate.text,
//                                 //             Form_period.text,
//                                 //             Form_rtname.text,
//                                 //             quotxSelectModels,
//                                 //             _TransModels,
//                                 //             '$renTal_name',
//                                 //             '${renTalModels[0].bill_addr}',
//                                 //             '${renTalModels[0].bill_email}',
//                                 //             '${renTalModels[0].bill_tel}',
//                                 //             '${renTalModels[0].bill_tax}',
//                                 //             '${renTalModels[0].bill_name}',
//                                 //             newValuePDFimg,
//                                 //             tableData00)
//                                 //     :
//                                 //(ren.toString() == '90' ||
//                                 //             ren.toString() == '50')
//                                 //         ?
//                                 // Pdfgen_Agreement_JSpace
//                                 //             .exportPDF_Agreement_JSpace(
//                                 //             context,
//                                 //             '${widget.Get_Value_NameShop_index}',
//                                 //             '${widget.Get_Value_cid}',
//                                 //             _verticalGroupValue,
//                                 //             Form_nameshop.text,
//                                 //             Form_typeshop.text,
//                                 //             Form_bussshop.text,
//                                 //             Form_bussscontact.text,
//                                 //             Form_address.text,
//                                 //             Form_tel.text,
//                                 //             Form_email.text,
//                                 //             Form_tax.text,
//                                 //             Form_ln.text,
//                                 //             Form_zn.text,
//                                 //             Form_area.text,
//                                 //             Form_qty.text,
//                                 //             Form_sdate.text,
//                                 //             Form_ldate.text,
//                                 //             Form_period.text,
//                                 //             Form_rtname.text,
//                                 //             quotxSelectModels,
//                                 //             _TransModels,
//                                 //             '$renTal_name',
//                                 //             '${renTalModels[0].bill_addr}',
//                                 //             '${renTalModels[0].bill_email}',
//                                 //             '${renTalModels[0].bill_tel}',
//                                 //             '${renTalModels[0].bill_tax}',
//                                 //             '${renTalModels[0].bill_name}',
//                                 //             newValuePDFimg,
//                                 //             tableData00,

//                                 //             // (ser_user == null) ? '' : ser_user
//                                 //           )
//                                 //         :
//                                 // Pdfgen_Agreement.exportPDF_Agreement(
//                                 //             context,
//                                 //             '${widget.Get_Value_NameShop_index}',
//                                 //             '${widget.Get_Value_cid}',
//                                 //             _verticalGroupValue,
//                                 //             Form_nameshop.text,
//                                 //             Form_typeshop.text,
//                                 //             Form_bussshop.text,
//                                 //             Form_bussscontact.text,
//                                 //             Form_address.text,
//                                 //             Form_tel.text,
//                                 //             Form_email.text,
//                                 //             Form_tax.text,
//                                 //             Form_ln.text,
//                                 //             Form_zn.text,
//                                 //             Form_area.text,
//                                 //             Form_qty.text,
//                                 //             Form_sdate.text,
//                                 //             Form_ldate.text,
//                                 //             Form_period.text,
//                                 //             Form_rtname.text,
//                                 //             quotxSelectModels,
//                                 //             _TransModels,
//                                 //             '$renTal_name',
//                                 //             '${renTalModels[0].bill_addr}',
//                                 //             '${renTalModels[0].bill_email}',
//                                 //             '${renTalModels[0].bill_tel}',
//                                 //             '${renTalModels[0].bill_tax}',
//                                 //             '${renTalModels[0].bill_name}',
//                                 //             newValuePDFimg,
//                                 //             tableData00

//                                 //             // (ser_user == null) ? '' : ser_user
//                                 //             );
//                               },
//                         child: Container(
//                           width: 100,
//                           decoration: const BoxDecoration(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                           ),
//                           padding: const EdgeInsets.all(8.0),
//                           child: Center(
//                             child: Text(
//                               'พิมพ์',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 //fontWeight: FontWeight.bold, color:

//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: InkWell(
//                         onTap: () => Navigator.pop(context, 'OK'),
//                         child: Container(
//                           width: 100,
//                           decoration: const BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10)),
//                           ),
//                           padding: const EdgeInsets.all(8.0),
//                           child: Center(
//                             child: Text(
//                               'ปิด',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 //fontWeight: FontWeight.bold, color:

//                                 // fontWeight: FontWeight.bold,
//                                 fontFamily: Font_.Fonts_T,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
