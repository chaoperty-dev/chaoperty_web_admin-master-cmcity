import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Style/colors.dart';
import '../unity/API_payment.dart';
import '../unity/show_dialog_cmm.dart';
import 'payment_contract_cmm.dart';

class RegencreceiptView_CMM extends StatefulWidget {
  final String uuid_Request;
  const RegencreceiptView_CMM({super.key, required this.uuid_Request});

  @override
  State<RegencreceiptView_CMM> createState() => _RegencreceiptView_CMMState();
}

class _RegencreceiptView_CMMState extends State<RegencreceiptView_CMM> {
  String? documentUuidReceipt;
  Map<String, dynamic> jsonDataReceipt = const {
    "documentUuid": "",
    "clientsName": "",
    "receiptDocno": "",
    "receiptDate": "",
    "name_th": "",
    "zn": "",
    "ln": "",
  };

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocNo();
  }

  Future<void> _loadDocNo() async {
    try {
      final resp =
          await POST_docno_paymentonly(requestUuid: widget.uuid_Request);
      if (!mounted) return;

      if (resp?.statusCode == 200) {
        final body = jsonDecode(resp!.body);
        // print('_loadDocNo1234');
        // print(body);
        final document = body['data']?['document'] as Map? ?? {};
        final meta = body['data']?['meta']['meta'] as Map? ?? {};
        final client = meta['client'] as Map? ?? {};

        final documentUuid = (document['uuid'] ?? '').toString();
        final receiptDocno = (document['document_no'] ?? '').toString();
        final receiptDate = (meta['payment']?['slip_pdate'] ?? '').toString();
        final clientsName = (client['cname'] ?? '').toString();
        final znName = meta?['new_request']?['zn']?.toString() ?? '';
        final subzoneName = meta?['new_request']?['subzone']?.toString() ?? '';
        final lnName = meta?['new_request']?['ln']?.toString() ?? '';
        final methodPayTh =
            meta?['payment']?['method']?['name_th']?.toString() ?? '';
        setState(() {
          jsonDataReceipt = {
            "documentUuid": documentUuid,
            "clientsName": clientsName,
            "receiptDocno": receiptDocno,
            "receiptDate": receiptDate,
            "methodpay_th": methodPayTh,
            "subzone": subzoneName,
            "zn": znName,
            "ln": lnName,
          };
          documentUuidReceipt = documentUuid.isNotEmpty ? documentUuid : null;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'โหลดข้อมูลไม่สำเร็จ (${resp?.statusCode})';
          _loading = false;
        });
      }
    } catch (e, st) {
      debugPrint('docno_payment error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'เกิดข้อผิดพลาดขณะโหลดข้อมูล';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppBarColors.hexColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, {}),
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'เอกสารรับชำระ',
          style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null || documentUuidReceipt == null)
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : BillPaymentScreen(
                  uuid_Request: widget.uuid_Request,
                  payment_amount: '',
                  payment_jsonx: [],
                  payment_uuid: documentUuidReceipt ?? '',
                  Repay_jsonDataReceipt: jsonDataReceipt ?? '',
                  Repay_document_uuid_receipt: documentUuidReceipt ?? '',
                  popOnSuccess: true,
                ),
    );
  }
}
