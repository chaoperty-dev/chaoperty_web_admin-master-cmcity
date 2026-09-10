import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../../Style/colors.dart';

Widget_Loading(context) {
  return SizedBox(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        StreamBuilder(
          stream: Stream.periodic(const Duration(milliseconds: 25), (i) => i),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('');
            double elapsed = double.parse(snapshot.data.toString()) * 0.05;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.', // ตัวบ่งชี้กำลังโหลด
                // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                style: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T
                    //fontSize: 10.0
                    ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

typedef VoidCallback = void Function();

VoidCallback showLoader(BuildContext context) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Material(
      color: Colors.black38,
      child: const Center(child: CircularProgressIndicator()),
    ),
  );
  overlay.insert(entry);
  return () => entry.remove();
}

Future<void> showBlockingLoader(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    transitionDuration: Duration.zero, // ไม่มีอนิเมชัน
    pageBuilder: (_, __, ___) =>
        const Center(child: CircularProgressIndicator()),
  );
}

Dia_log1(context) {
  return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext builderContext) {
        Timer(Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });

        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
}

Dia_log2(context) {
  return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext builderContext) {
        // Timer(Duration(milliseconds: 150), () {
        //   Navigator.of(context).pop();
        // });

        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
}

Dia_log3(context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return Dialog(
          child: SizedBox(
            height: 20,
            width: 80,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset(
                "images/gif-LOGOchao.gif",
                fit: BoxFit.cover,
                height: 20,
                width: 80,
              ),
            ),
          ),
        );
      });
}

/// =======================
/// Dia_log4 (ของเดิมคุณ) — ถ้าอยากเก็บไว้
/// =======================
Future<void> Dia_log4(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error,
                  size: 45,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'สำเร็จ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "ยกเลิกการรับชำระ เสร็จสิ้น ...!!",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: Font_.Fonts_T,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'รับทราบ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

/// =======================
/// ตัวแปรกัน Dialog ซ้ำ (ระดับไฟล์)
/// =======================
bool _isSuccessDialogShowing = false;
bool _isErrorDialogShowing = false;

/// =======================
/// Success Dialog: ปิดเอง 3 วิ + กันซ้ำ + กันปิดซ้ำ
/// =======================

Future<void> Dialog_success(BuildContext context, String datatex) async {
  if (_isSuccessDialogShowing) return;
  _isSuccessDialogShowing = true;

  int countdown = 3;
  Timer? timer;
  bool closed = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (contextSB, setStateSB) {
          void closeOnce() {
            if (closed) return;
            closed = true;

            timer?.cancel();

            // ใช้ rootNavigator ลดปัญหา ancestor lookup
            final nav = Navigator.of(dialogContext, rootNavigator: true);
            if (nav.canPop()) nav.pop();
          }

          // start timer "ครั้งเดียว"
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (closed) {
              t.cancel();
              return;
            }

            if (countdown <= 1) {
              closeOnce();
            } else {
              setStateSB(() => countdown--);
            }
          });

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 45,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'สำเร็จ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    datatex,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: Font_.Fonts_T,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // ✅ แสดงเลขนับถอยหลังตรง ๆ (ไม่ใช้ StreamBuilder)
                  Text(
                    'ปิดอัตโนมัติใน $countdown วินาที',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: closeOnce,
                      child: const Text(
                        'รับทราบ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  // กันเคส dialog ถูกปิดจาก route อื่น
  timer?.cancel();
  _isSuccessDialogShowing = false;
}

/// =======================
/// Success Dialog with Action: แสดง popup สำเร็จพร้อมปุ่มเลือก 2 ทาง
/// - ปุ่ม "ปิด" = ปิด dialog (ย้อนกลับ)
/// - ปุ่ม "ไปหน้าใบอนุญาต" = ปิด dialog แล้วเรียก onAction callback
/// =======================
Future<void> Dialog_success_with_action(
  BuildContext context,
  String datatex, {
  String actionLabel = 'ไปหน้าใบอนุญาต',
  VoidCallback? onAction,
}) async {
  if (_isSuccessDialogShowing) return;
  _isSuccessDialogShowing = true;

  int countdown = 5;
  Timer? timer;
  bool closed = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (contextSB, setStateSB) {
          void closeOnce() {
            if (closed) return;
            closed = true;
            timer?.cancel();
            final nav = Navigator.of(dialogContext, rootNavigator: true);
            if (nav.canPop()) nav.pop();
          }

          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (closed) {
              t.cancel();
              return;
            }
            if (countdown <= 1) {
              closeOnce();
            } else {
              setStateSB(() => countdown--);
            }
          });

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 45,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'สำเร็จ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    datatex,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: Font_.Fonts_T,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ปิดอัตโนมัติใน $countdown วินาที',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ปุ่ม "ไปหน้าใบอนุญาต"
                  if (onAction != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          closed = true;
                          timer?.cancel();
                          Navigator.of(dialogContext, rootNavigator: true)
                              .pop();
                          onAction();
                        },
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: Font_.Fonts_T,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (onAction != null) const SizedBox(height: 10),
                  // ปุ่ม "ปิด"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: closeOnce,
                      child: const Text(
                        'ปิด',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  timer?.cancel();
  _isSuccessDialogShowing = false;
}

// Future<void> Dialog_success(BuildContext context, String datatex) async {
//   if (_isSuccessDialogShowing) return;
//   _isSuccessDialogShowing = true;

//   await showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (dialogContext) {
//       int countdown = 3;
//       bool _closed = false;
//       Timer? _timer;

//       void closeOnce() {
//         if (_closed) return;
//         _closed = true;

//         _timer?.cancel();
//         if (Navigator.of(dialogContext).canPop()) {
//           Navigator.of(dialogContext).pop();
//         }
//       }

//       // เริ่มนับถอยหลัง
//       _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//         countdown--;
//         if (countdown <= 0) {
//           closeOnce();
//         } else {
//           // บังคับ rebuild dialog
//           (dialogContext as Element).markNeedsBuild();
//         }
//       });

//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Container(
//           width: 280,
//           padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ไอคอน
//               Container(
//                 width: 70,
//                 height: 70,
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade100,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.check,
//                   size: 45,
//                   color: Colors.green.shade600,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               const Text(
//                 'สำเร็จ',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: Font_.Fonts_T,
//                 ),
//               ),
//               const SizedBox(height: 5),

//               Text(
//                 datatex,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontFamily: Font_.Fonts_T,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 12),

//               // 🔢 เลขนับถอยหลัง
//               StreamBuilder(
//                   stream: Stream.periodic(const Duration(seconds: 1)),
//                   builder: (context, snapshot) {
//                     return Text(
//                       'ปิดอัตโนมัติใน $countdown วินาที',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                         fontFamily: Font_.Fonts_T,
//                       ),
//                     );
//                   }),

//               const SizedBox(height: 20),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: closeOnce,
//                   child: const Text(
//                     'รับทราบ',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontFamily: Font_.Fonts_T,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );

//   // reset flag หลัง dialog ปิด
//   _isSuccessDialogShowing = false;
// }

/// =======================
/// Error Dialog: กันซ้ำ + กันปิดซ้ำ
/// =======================
Future<void> Dialog_error(BuildContext context, String datatex) async {
  if (_isErrorDialogShowing) return;
  _isErrorDialogShowing = true;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      bool _closed = false;

      void closeOnce() {
        if (_closed) return;
        _closed = true;

        if (Navigator.of(dialogContext).canPop()) {
          Navigator.of(dialogContext).pop();
        }
      }

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error,
                  size: 45,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ขออภัย',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                datatex,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: Font_.Fonts_T,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: closeOnce,
                  child: const Text(
                    'รับทราบ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  _isErrorDialogShowing = false;
}

/// =======================

Future<bool?> Dialog_confirm(
    BuildContext context, String title, String datatex) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 45,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                datatex,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: Font_.Fonts_T,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: const Text(
                        'ปิด',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppBarColors.ABar_Colors,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
