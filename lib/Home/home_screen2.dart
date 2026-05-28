// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Constant/Myconstant.dart';
// import '../Style/colors.dart';
// import '../Responsive/responsive.dart';
// import '../Model/GetNote_Model.dart';
// import '../ChiangMai_Municipality/unity/API_announcement.dart';
// import '../ChiangMai_Municipality/Model/AnnounceMentActive_Model.dart';
// import '../ChiangMai_Municipality/unity/API_approvals_roles&checkup.dart';
// import '../ChiangMai_Municipality/unity/API_approvals_lastaction.dart';
// import '../ChiangMai_Municipality/Model/Review_Model.dart';
// import 'package:intl/intl.dart';
// import '../AdminScaffold/AdminScaffold.dart';
// import '../Model/GetCustomer_Model.dart';

// class HomeScreen2 extends StatefulWidget {
//   final bool hasLicensePermission;
//   const HomeScreen2({Key? key, this.hasLicensePermission = true})
//       : super(key: key);

//   @override
//   _HomeScreen2State createState() => _HomeScreen2State();
// }

// class _HomeScreen2State extends State<HomeScreen2> {
//   // Announcements
//   List<AnnounceMentActiveModel> announcements = [];
//   bool isLoadingAnnouncements = true;

//   // Licenses: Action Required & Rejected
//   List<ReviewModel> pendingLicenses = [];
//   bool isLoadingLicenses = true;

//   List<ReviewModel> rejectedLicenses = [];
//   bool isLoadingRejected = true;

//   // Notes
//   final TextEditingController noteController = TextEditingController();
//   String? sernote;
//   bool isSavingNote = false;
//   bool isLoadingNote = true;

//   // Zone Area Data (Fallback)
//   List<CustomerModel> areaCustomers = [];
//   bool isLoadingArea = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDashboardData();
//   }

//   Future<void> _fetchDashboardData() async {
//     List<Future> futures = [
//       _fetchAnnouncements(),
//       _fetchNotes(),
//     ];

//     if (widget.hasLicensePermission) {
//       futures.add(_fetchLicenses());
//       futures.add(_fetchRejectedLicenses());
//     } else {
//       futures.add(_fetchAreaCustomers());
//     }

//     await Future.wait(futures);
//   }

//   Future<void> _fetchAnnouncements() async {
//     try {
//       final response = await read_AnnounceMent_Active();
//       if (response != null && response.statusCode == 200) {
//         final result = json.decode(response.body);
//         final data = result['data'];
//         if (data is List) {
//           setState(() {
//             announcements =
//                 data.map((e) => AnnounceMentActiveModel.fromJson(e)).toList();
//           });
//         }
//       }
//     } catch (e) {
//       // Error logged silently
//     } finally {
//       if (mounted) setState(() => isLoadingAnnouncements = false);
//     }
//   }

//   Future<void> _fetchLicenses() async {
//     try {
//       final res = await read_GC_ApprovalsRoles(perPage: 50);
//       setState(() {
//         pendingLicenses = res.data;
//       });
//     } catch (e) {
//       // Error logged silently
//     } finally {
//       if (mounted) setState(() => isLoadingLicenses = false);
//     }
//   }

//   Future<void> _fetchRejectedLicenses() async {
//     try {
//       final res = await read_GC_ApprovalsLastaction(perPage: 50);
//       setState(() {
//         rejectedLicenses = res.data;
//       });
//     } catch (e) {
//       // Error logged silently
//     } finally {
//       if (mounted) setState(() => isLoadingRejected = false);
//     }
//   }

//   Future<void> _fetchAreaCustomers() async {
//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       String? ren = preferences.getString('renTalSer');
//       String? serzone = preferences.getString('zoneSer') ?? '0';

//       final url =
//           '${MyConstant().domain}/GC_custo_home.php?isAdd=true&ren=$ren&ser_zone$serzone';
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         if (result is List) {
//           setState(() {
//             areaCustomers =
//                 result.map((e) => CustomerModel.fromJson(e)).toList();
//           });
//         }
//       }
//     } catch (e) {
//       // Error logged silently
//     } finally {
//       if (mounted) setState(() => isLoadingArea = false);
//     }
//   }

//   Future<void> _fetchNotes() async {
//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       var ren = preferences.getString('renTalSer');
//       var ser_user = preferences.getString('ser');

//       String url =
//           '${MyConstant().domain}/GC_Note.php?isAdd=true&ren=$ren&ser_user=$ser_user';
//       var response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         var result = json.decode(response.body);
//         if (result != null && result is List && result.isNotEmpty) {
//           NoteModel noteModel = NoteModel.fromJson(result.first);
//           setState(() {
//             noteController.text = noteModel.descr ?? '';
//             sernote = noteModel.ser?.toString();
//           });
//         }
//       }
//     } catch (e) {
//       // Error logged silently
//     } finally {
//       if (mounted) setState(() => isLoadingNote = false);
//     }
//   }

//   Future<void> _saveNote() async {
//     if (noteController.text.isEmpty) return;
//     setState(() => isSavingNote = true);

//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       var ren = preferences.getString('renTalSer');
//       var ser_user = preferences.getString('ser');

//       String url =
//           '${MyConstant().domain}/UDC_Note.php?isAdd=true&ren=$ren&ser_user=$ser_user&sernote=$sernote';
//       var response = await http.post(
//         Uri.parse(url),
//         body: {'note': noteController.text},
//       );

//       var result = json.decode(response.body);
//       if (result.toString() == 'true') {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('บันทึกโน๊ตสำเร็จ 🎉',
//               style: TextStyle(fontFamily: FontWeight_.Fonts_T)),
//           backgroundColor: Colors.green,
//         ));
//       }
//     } catch (e) {
//       // Error logged silently
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('เกิดข้อผิดพลาดในการบันทึกโน๊ต',
//             style: TextStyle(fontFamily: FontWeight_.Fonts_T)),
//         backgroundColor: Colors.red,
//       ));
//     } finally {
//       if (mounted) setState(() => isSavingNote = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDesktop = Responsive.isDesktop(context);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC), // Modern slate background
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: isDesktop
//               ? buildDesktopLayout()
//               : SingleChildScrollView(child: buildMobileLayout()),
//         ),
//       ),
//     );
//   }

//   Widget buildDesktopLayout() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left Column (Main Actions)
//         Expanded(
//           flex: 1,
//           child: Column(
//             children: [
//               Expanded(flex: 4, child: buildAnnouncementsSection()),
//               const SizedBox(height: 16),
//               if (widget.hasLicensePermission)
//                 Expanded(flex: 6, child: buildLicensesSection())
//               else
//                 Expanded(flex: 6, child: buildAreaSection()),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         // Right Column (Follow-up & Tools)
//         Expanded(
//           flex: 1,
//           child: Column(
//             children: [
//               if (widget.hasLicensePermission) ...[
//                 Expanded(flex: 6, child: buildRejectedSection()),
//                 const SizedBox(height: 16),
//               ],
//               Expanded(
//                 flex: widget.hasLicensePermission ? 4 : 10,
//                 child: buildNotesSection(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildMobileLayout() {
//     return Column(
//       children: [
//         buildAnnouncementsSection(),
//         const SizedBox(height: 16),
//         if (widget.hasLicensePermission) ...[
//           buildLicensesSection(),
//           const SizedBox(height: 16),
//           buildRejectedSection(),
//           const SizedBox(height: 16),
//         ] else ...[
//           buildAreaSection(),
//           const SizedBox(height: 16),
//         ],
//         buildNotesSection(),
//       ],
//     );
//   }

//   Widget _buildSectionCard({
//     required Widget icon,
//     required String title,
//     required Color color,
//     required Widget content,
//     List<Widget>? actions,
//     List<Color>? gradient,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppbackgroundColor.Sub_Abg_Colors,
//         // color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: AppbackgroundColor.TiTile_Box,
//               // gradient: LinearGradient(
//               //   colors: gradient ??
//               //       [color.withOpacity(0.1), color.withOpacity(0.05)],
//               //   begin: Alignment.topLeft,
//               //   end: Alignment.bottomRight,
//               // ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     icon,
//                     const SizedBox(width: 8),
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: FontWeight_.Fonts_T,
//                         color: color.darken(0.2),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (actions != null) ...actions,
//               ],
//             ),
//           ),
//           Expanded(child: content),
//         ],
//       ),
//     );
//   }

//   Widget buildAreaSection() {
//     return _buildSectionCard(
//       title: 'รายการรอทำสัญญา (โซนพื้นที่)',
//       icon: const Icon(Icons.handshake_rounded,
//           color: Color(0xFF334155), size: 24),
//       color: const Color(0xFF334155),
//       gradient: [const Color(0xFFF1F5F9), const Color(0xFFF8FAFC)],
//       content: isLoadingArea
//           ? const Center(child: CircularProgressIndicator())
//           : areaCustomers.isEmpty
//               ? const Center(
//                   child: Text('ไม่มีรายการรอทำสัญญา',
//                       style: TextStyle(fontFamily: FontWeight_.Fonts_T)))
//               : ListView.builder(
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                   itemCount: areaCustomers.length,
//                   itemBuilder: (context, index) {
//                     final customer = areaCustomers[index];
//                     return _buildAreaTile(customer);
//                   },
//                 ),
//     );
//   }

//   Widget _buildAreaTile(CustomerModel customer) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE2E8F0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF1F5F9),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.location_on_rounded,
//                 size: 20, color: Color(0xFF334155)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   customer.scname ?? 'ไม่ทราบชื่อร้าน',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontFamily: FontWeight_.Fonts_T,
//                     color: Color(0xFF334155),
//                   ),
//                 ),
//                 Text(
//                   '${customer.zn ?? "-"} / ${customer.ln ?? "-"}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                     fontFamily: FontWeight_.Fonts_T,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${customer.area ?? "0"} ตร.ม.',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 13,
//                   color: Color(0xFF334155),
//                 ),
//               ),
//               if (customer.datex != null)
//                 Text(
//                   customer.datex!,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey,
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildAnnouncementsSection() {
//     return _buildSectionCard(
//       title: 'กำหนดการประกาศ',
//       icon: const Icon(Icons.campaign_rounded,
//           color: Color(0xFF334155), size: 24),
//       color: const Color(0xFF334155),
//       gradient: [const Color(0xFFF1F5F9), const Color(0xFFF8FAFC)],
//       content: isLoadingAnnouncements
//           ? const Center(child: CircularProgressIndicator())
//           : announcements.isEmpty
//               ? const Center(
//                   child: Text('ไม่มีประกาศในขณะนี้',
//                       style: TextStyle(
//                           fontFamily: FontWeight_.Fonts_T, color: Colors.grey)))
//               : ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: announcements.length,
//                   separatorBuilder: (context, index) => const Divider(),
//                   itemBuilder: (context, index) {
//                     final ann = announcements[index];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 ann.announcement?.content?.title ??
//                                     'ไม่มีหัวข้อ',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: FontWeight_.Fonts_T,
//                                     fontSize: 16),
//                               ),
//                             ),
//                             Text(
//                               ann.effectiveAt != null
//                                   ? DateFormat('dd/MM/yyyy')
//                                       .format(DateTime.parse(ann.effectiveAt!))
//                                   : '',
//                               style: const TextStyle(
//                                   color: Colors.grey, fontSize: 12),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           ann.announcement?.content?.content ?? '',
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               fontFamily: FontWeight_.Fonts_T,
//                               color: Colors.grey[700]),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//     );
//   }

//   Widget buildLicensesSection() {
//     return _buildSectionCard(
//       title: 'รายการที่รอตรวจสอบ/อนุมัติ',
//       icon: const Icon(Icons.assignment_turned_in_rounded,
//           color: Color(0xFF334155), size: 24),
//       color: const Color(0xFF334155),
//       gradient: [const Color(0xFFF1F5F9), const Color(0xFFF8FAFC)],
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => AdminScafScreen(route: 'ใบอนุญาต'))),
//           child: const Text('ดูทั้งหมด',
//               style: TextStyle(fontFamily: FontWeight_.Fonts_T)),
//         ),
//       ],
//       content: isLoadingLicenses
//           ? const Center(child: CircularProgressIndicator())
//           : pendingLicenses.isEmpty
//               ? const Center(
//                   child: Text('ไม่มีรายการรอตรวจสอบ',
//                       style: TextStyle(
//                           fontFamily: FontWeight_.Fonts_T, color: Colors.grey)))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: pendingLicenses.length,
//                   itemBuilder: (context, index) {
//                     final license = pendingLicenses[index];
//                     return _buildLicenseTile(license, const Color(0xFF334155));
//                   },
//                 ),
//     );
//   }

//   Widget _buildLicenseTile(ReviewModel license, Color color) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       elevation: 0,
//       color: color.withOpacity(0.05),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: CircleAvatar(
//           backgroundColor: color.withOpacity(0.1),
//           child: Icon(Icons.description, color: color, size: 20),
//         ),
//         title: Text(
//           license.newRequest?.leaseNumber ?? 'ไม่ระบุเลขที่',
//           style: const TextStyle(
//               fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
//         ),
//         subtitle: Text(
//           'ผู้ติดต่อ: ${license.client?.scname ?? '-'}',
//           style: const TextStyle(fontFamily: FontWeight_.Fonts_T, fontSize: 13),
//         ),
//         trailing: const Icon(Icons.arrow_forward_ios_rounded,
//             size: 14, color: Colors.grey),
//         onTap: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => AdminScafScreen(
//                     route: 'ใบอนุญาต',
//                     route_getdata: license.newRequest?.leaseNumber)),
//           );
//         },
//       ),
//     );
//   }

//   Widget buildRejectedSection() {
//     return _buildSectionCard(
//       title: 'รายการใบอนุญาตที่ถูกปฏิเสธ/ยกเลิก',
//       icon:
//           const Icon(Icons.cancel_rounded, color: Color(0xFF334155), size: 24),
//       color: const Color(0xFF334155),
//       gradient: [const Color(0xFFF1F5F9), const Color(0xFFF8FAFC)],
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => AdminScafScreen(route: 'ใบอนุญาต'))),
//           child: const Text('ดูทั้งหมด',
//               style: TextStyle(fontFamily: FontWeight_.Fonts_T)),
//         ),
//       ],
//       content: isLoadingRejected
//           ? const Center(child: CircularProgressIndicator())
//           : rejectedLicenses.isEmpty
//               ? const Center(
//                   child: Text('ไม่มีรายการที่ถูกปฏิเสธ/ยกเลิก',
//                       style: TextStyle(
//                           fontFamily: FontWeight_.Fonts_T, color: Colors.grey)))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: rejectedLicenses.length,
//                   itemBuilder: (context, index) {
//                     final license = rejectedLicenses[index];
//                     return _buildLicenseTile(license, const Color(0xFF334155));
//                   },
//                 ),
//     );
//   }

//   Widget buildNotesSection() {
//     return _buildSectionCard(
//       title: 'โน๊ตส่วนตัว',
//       icon: const Icon(Icons.note_alt_rounded,
//           color: Color(0xFF334155), size: 24),
//       color: const Color(0xFF334155),
//       gradient: [const Color(0xFFF1F5F9), const Color(0xFFF8FAFC)],
//       actions: [
//         IconButton(
//           onPressed: isSavingNote ? null : _saveNote,
//           icon: isSavingNote
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2))
//               : const Icon(Icons.save_rounded, color: Color(0xFF334155)),
//         ),
//       ],
//       content: isLoadingNote
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFE2E8F0)),
//                 ),
//                 child: TextField(
//                   controller: noteController,
//                   maxLines: null,
//                   expands: true,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.all(12),
//                     hintText: 'พิมพ์โน๊ตส่วนตัวของคุณที่นี่...',
//                     hintStyle: TextStyle(
//                         fontFamily: FontWeight_.Fonts_T, fontSize: 14),
//                   ),
//                   style: const TextStyle(
//                       fontFamily: FontWeight_.Fonts_T, fontSize: 14),
//                 ),
//               ),
//             ),
//     );
//   }
// }

// extension ColorExtension on Color {
//   Color darken([double amount = .1]) {
//     assert(amount >= 0 && amount <= 1);
//     final hsv = HSVColor.fromColor(this);
//     final darkenedHsv = hsv.withValue((hsv.value - amount).clamp(0.0, 1.0));
//     return darkenedHsv.toColor();
//   }
// }
