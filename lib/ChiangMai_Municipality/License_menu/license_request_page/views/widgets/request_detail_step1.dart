// ============================================================================
// request_detail_step1.dart
// ============================================================================
// Step 1 — ตรวจสอบคำขอ (Read-Only / View-Only)
//
// โครงสร้าง UI เป็นของตัวเอง (ไม่แชร์/ดึงจาก license_contract_page)
// ✅ ใช้ LicenseRequestDetailStep1ViewModel ของตัวเอง
// ✅ ใช้ LicenseRequestDetailService ของตัวเอง
// ✅ ใช้ Form widgets ของตัวเอง (RequestDetail*Section, RequestDetail*Row)
//
// ★ Data Source (คัดลอก logic จาก request_examiner1_cmm.dart):
//   - API: GET /admin/approvals/{uuid}/review   (read_GC_ReviewsUuid)
//   - UUID: รับจาก LicenseRequestDetailPage.routeData
//           (มาจาก ReviewModel.newRequest.requestUuid ตอนกด "เรียกดู")
//   - Parse: ReviewDetail.fromJson(result['data'])
//   - นำไป set ใน ViewModel ผ่าน _applyReviewData() (ภายใน VM)
// ============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../Constant/Myconstant.dart';
import '../../viewmodels/license_request_detail_step1_view_model.dart';
import '../../viewmodels/license_request_detail_view_model.dart';
import 'cancel_request_button.dart';
import 'request_detail_contract_section.dart';
import 'request_detail_person_section.dart';
import 'request_detail_section_title.dart';
import 'request_detail_shop_section.dart';
import 'request_detail_zone_row.dart';

class RequestDetailStep1 extends StatefulWidget {
  /// UUID ของ Request (มาจาก ReviewModel.newRequest.requestUuid)
  final String? requestUuid;

  const RequestDetailStep1({super.key, this.requestUuid});

  @override
  State<RequestDetailStep1> createState() => _RequestDetailStep1State();
}

class _RequestDetailStep1State extends State<RequestDetailStep1> {
  // ★ ViewModel ของตัวเอง (ไม่แชร์กับ license_contract_page)
  late final LicenseRequestDetailStep1ViewModel _vm;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _vm = LicenseRequestDetailStep1ViewModel().init();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    final uuid = widget.requestUuid?.trim();
    if (uuid == null || uuid.isEmpty) {
      _setError('ไม่พบ UUID ของคำขอ (routeData ว่าง)');
      return;
    }
    try {
      await _vm.loadFromUuid(uuid);
      // ✅ sync status ไปยัง shared VM (ใช้ใน step1 badge + step2 lock)
      if (mounted) {
        context.read<LicenseRequestDetailViewModel>().setStatus(_vm.status);
      }
      if (mounted) {
        setState(() {
          _isLoading = _vm.isLoading;
          _errorMessage = _vm.errorMessage;
        });
      }
    } catch (e, st) {
      debugPrint('❌ _loadReviewData error: $e\n$st');
      _setError('เกิดข้อผิดพลาด: $e');
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = msg;
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Touch step VM so it rebuilds when step changes
    context.watch<LicenseRequestDetailViewModel>();

    return ChangeNotifierProvider<LicenseRequestDetailStep1ViewModel>.value(
      value: _vm,
      child: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลดข้อมูลคำขอ...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            );
          }

          if (_errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 56, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadReviewData();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _Step1Body(requestUuid: widget.requestUuid);
        },
      ),
    );
  }
}

/// ───────────────────────────────────────────────────────────────────────────
/// Internal body — ต้องอยู่ใต้ Provider<LicenseRequestDetailStep1ViewModel>
/// ───────────────────────────────────────────────────────────────────────────
class _Step1Body extends StatelessWidget {
  final String? requestUuid;
  const _Step1Body({this.requestUuid});

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Title bar ───
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7).withOpacity(.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_rounded,
                        size: 18, color: Color(0xFF15803D)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ตรวจสอบคำขอ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    // ✅ ถ้า rejected → แสดง badge สถานะแทนปุ่มยกเลิก (กันกดซ้ำ)
                    if (context.watch<LicenseRequestDetailViewModel>().isRejected)
                      _RejectedStatusBadge()
                    else if (requestUuid != null &&
                        requestUuid!.trim().isNotEmpty)
                      CancelRequestButton(
                        requestUuid: requestUuid!.trim(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── แบบฟอร์มคำขอ (PDF preview) ───
              if (requestUuid != null && requestUuid!.trim().isNotEmpty) ...[
                RequestFormPdfCard(requestUuid: requestUuid!.trim()),
                const SizedBox(height: 16),
              ],

              // ─── Zone row (read-only) ───
              const RequestDetailZoneRow(),
              const SizedBox(height: 16),

              // ─── Form card (ไม่รวมประกาศ) ───
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: mediaWidth < 1100
                    // ── Mobile/tablet: stack vertically ──
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RequestDetailSectionTitle(
                              icon: Icons.person, title: 'ข้อมูลผู้เช่า'),
                          RequestDetailPersonSection(),
                          SizedBox(height: 16),
                          RequestDetailSectionTitle(
                              icon: Icons.store, title: 'ข้อมูลร้านค้า'),
                          RequestDetailShopSection(),
                          SizedBox(height: 16),
                          RequestDetailSectionTitle(
                              icon: Icons.receipt_long, title: 'ข้อมูลสัญญา'),
                          RequestDetailContractSection(),
                        ],
                      )
                    // ── Desktop: 2 columns (ข้อมูลผู้เช่า | ข้อมูลร้านค้า + สัญญา) ──
                    : const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RequestDetailSectionTitle(
                                    icon: Icons.person, title: 'ข้อมูลผู้เช่า'),
                                RequestDetailPersonSection(),
                              ],
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RequestDetailSectionTitle(
                                    icon: Icons.store, title: 'ข้อมูลร้านค้า'),
                                RequestDetailShopSection(),
                                SizedBox(height: 16),
                                RequestDetailSectionTitle(
                                    icon: Icons.receipt_long,
                                    title: 'ข้อมูลสัญญา'),
                                RequestDetailContractSection(),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              // ─── Info row ───
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'โหมดดูข้อมูลอย่างเดียว ไม่สามารถแก้ไขได้',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
              // ✅ ปุ่ม "ยกเลิกคำขอ" ย้ายไปไว้ใน header (ด้านบน) — ไม่อยู่ใน body
            ],
          ),
        ),
      ),
    );
  }
}

/// ───────────────────────────────────────────────────────────────────────────
/// Status badge — แสดงเมื่อ status = rejected (แทนปุ่มยกเลิก กันกดซ้ำ)
/// ───────────────────────────────────────────────────────────────────────────
class _RejectedStatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2), // red-100
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFCA5A5)), // red-300
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel_rounded, size: 14, color: Color(0xFF991B1B)),
          SizedBox(width: 6),
          Text(
            'ถูกปฏิเสธ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF991B1B), // red-800
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================================
// RequestFormPdfCard — การ์ดเรียกดูแบบฟอร์มคำขอ (PDF) ในแอป
// URL: {domain_v3}/api/preview/req-vendor-license-2/{uuid}/pdf (Bearer auth)
// กด "เรียกดู" → โหลด bytes → เปิด dialog SfPdfViewer (ดูอย่างเดียว ไม่พิมพ์/บันทึก)
// ============================================================================
class RequestFormPdfCard extends StatefulWidget {
  final String requestUuid;
  const RequestFormPdfCard({super.key, required this.requestUuid});

  @override
  State<RequestFormPdfCard> createState() => _RequestFormPdfCardState();
}

class _RequestFormPdfCardState extends State<RequestFormPdfCard> {
  bool _loading = false;
  String? _error;

  String get _pdfUrl =>
      '${MyConstant().domain_v3}/api/preview/req-vendor-license-2/${widget.requestUuid}/pdf';

  Future<void> _openViewer() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    Uint8List? bytes;
    try {
      final headers = await MyHeaders.build();
      final resp = await http.get(Uri.parse(_pdfUrl), headers: headers);
      if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
        _error = 'โหลดแบบฟอร์มไม่สำเร็จ (HTTP ${resp.statusCode})';
      } else {
        bytes = resp.bodyBytes;
      }
    } catch (e) {
      _error = 'โหลดแบบฟอร์มไม่สำเร็จ: $e';
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error ?? 'โหลดแบบฟอร์มไม่สำเร็จ'),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // เปิด dialog ดู PDF (read-only)
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          // ✅ จำกัดความกว้าง ~กระดาษ A4 แนวตั้ง (สัดส่วนตรงจริงตอนอ่าน)
          constraints: const BoxConstraints(maxWidth: 794),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // ─── Header: title + ปุ่มปิด ───
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded,
                        size: 18, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'แบบฟอร์มคำขอ — คำร้องขอรับใบอนุญาต',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'ปิด',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              // ─── PDF viewer ───
              Expanded(
                child: SfPdfViewer.memory(
                  bytes!,
                  canShowPaginationDialog: false,
                  canShowScrollStatus: false,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              size: 22,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'แบบฟอร์มคำขอ (PDF)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'คำร้องขอรับใบอนุญาต — กดเรียกดูเพื่อเปิดอ่านในแอป',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _loading ? null : _openViewer,
            icon: _loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.visibility_rounded, size: 16),
            label: const Text('เรียกดู'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}