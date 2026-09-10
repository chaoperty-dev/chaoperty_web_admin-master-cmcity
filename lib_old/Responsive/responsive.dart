import 'package:flutter/material.dart';

//https://github.com/ShubhranshuArya/Responsive-web-ui?ref=flutterawesome.com
class Responsive extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? smallMobile;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.smallMobile,
  }) : super(key: key);

  // ✅ Mobile / Tablet / Desktop
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 500;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 500 &&
      MediaQuery.of(context).size.width < 1100;

  // ✅ Desktop: width >= 1100 เท่านั้น
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // ✅ Desktop เฉพาะเมื่อ width >= 1370
    if (size.width >= 1370 && size.height >= 50) {
      return desktop!;
    }
    // ✅ Tablet
    else if (size.width >= 768 && tablet != null) {
      return tablet!;
    }
    // ✅ Mobile
    else if (size.width >= 376 && size.width <= 400 && mobile != null) {
      return mobile!;
    }
    // ✅ Small mobile
    else {
      return smallMobile ?? mobile ?? desktop!;
    }
  }
}
