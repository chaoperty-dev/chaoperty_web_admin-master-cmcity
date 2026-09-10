import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Constant/Myconstant.dart';

/// Admin Support — แสดงเว็บไซต์ของผู้ดูแลระบบ
/// - เมนู static (hardcode) ใน AdminScaffold SideBar หมวด "อื่นๆ"
/// - Route key: 'AdminSupport' (URL '/AdminSupport')
/// - URL: https://chaoperties.com/cmm_test?token=<renTalSer>
///
/// หมายเหตุ:
/// - บน mobile/desktop ใช้ [InAppWebView]
/// - บน Flutter Web ใช้ fallback เปิด browser ภายนอก เพราะเว็บเป้าหมายตั้ง
///   X-Frame-Options: SAMEORIGIN ไว้ ทำให้ embed iframe ไม่ได้
class AdminSupport extends StatefulWidget {
  const AdminSupport({super.key});

  @override
  State<AdminSupport> createState() => _AdminSupportState();
}

class _AdminSupportState extends State<AdminSupport> {
  static const String _baseUrl = 'https://chaoperties.com/chao-cmcity-support/';

  InAppWebViewController? _webViewController;
  String? _fullUrl;

  final ValueNotifier<bool> _loadingNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0);

  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _loadingNotifier.dispose();
    _errorNotifier.dispose();
    _progressNotifier.dispose();
    super.dispose();
  }

  /// โหลด token (= renTalSer) จาก SharedPreferences
  Future<void> _loadToken() async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('renTalSer');
      final token = await MyToken.accessToken;
      if (!mounted) return;

      setState(() {
        _fullUrl = (token == null || token.isEmpty)
            ? '$_baseUrl?token='
            : '$_baseUrl?token=$token';
      });

      debugPrint('[AdminSupport] full URL: $_fullUrl');
    } catch (e) {
      debugPrint('load token error: $e');
      _errorNotifier.value = 'ไม่สามารถโหลด token ได้: $e';
      _loadingNotifier.value = false;
    }
  }

  void _startLoadingTimeout() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (_loadingNotifier.value) {
        debugPrint('[AdminSupport] loading timeout — hiding overlay');
        _loadingNotifier.value = false;
      }
    });
  }

  Future<void> _refresh() async {
    _errorNotifier.value = null;
    _loadingNotifier.value = true;
    _progressNotifier.value = 0;
    await _loadToken();
    final controller = _webViewController;
    final url = _fullUrl;
    if (controller != null && url != null) {
      await controller.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(url)),
      );
      _startLoadingTimeout();
    }
  }

  Future<void> _openInBrowser() async {
    final url = _fullUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      debugPrint('[AdminSupport] open browser: $uri');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _errorNotifier.value = 'ไม่สามารถเปิด browser ได้';
    }
  }

  Future<void> _copyUrl() async {
    final url = _fullUrl;
    if (url == null) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คัดลอก URL แล้ว')),
      );
    }
  }

  Widget _buildWebFallback() {
    final url = _fullUrl;
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E8FF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.support_agent,
                        size: 48,
                        color: Colors.deepPurple.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Admin Support',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ระบบสนับสนุนผู้ดูแลระบบ',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'บนเวอร์ชัน Web ต้องเปิดเว็บไซต์นี้ในเบราว์เซอร์ภายนอก '
                              'เนื่องจากเว็บไซต์ไม่อนุญาตให้แสดง',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 24),
                    // if (url != null)
                    //   Container(
                    //     width: double.infinity,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 12,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey.shade100,
                    //       borderRadius: BorderRadius.circular(12),
                    //       border: Border.all(color: Colors.grey.shade300),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text(
                    //           'URL',
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             color: Colors.grey.shade600,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //         const SizedBox(height: 4),
                    //         SelectableText(
                    //           url,
                    //           style: const TextStyle(
                    //             fontSize: 13,
                    //             color: Colors.black87,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Expanded(
                        //   child: OutlinedButton.icon(
                        //     onPressed: url == null ? null : _copyUrl,
                        //     icon: const Icon(Icons.copy),
                        //     label: const Text('คัดลอก URL'),
                        //     style: OutlinedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(vertical: 14),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: url == null ? null : _openInBrowser,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('เปิดเว็บไซต์'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('ลองโหลดในแอปอีกครั้ง'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    final url = _fullUrl;
    if (url == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ),
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
        debugPrint('[AdminSupport] InAppWebView created');
      },
      onLoadStart: (controller, uri) {
        debugPrint('[AdminSupport] onLoadStart: $uri');
        _loadingNotifier.value = true;
        _errorNotifier.value = null;
      },
      onProgressChanged: (controller, progress) {
        _progressNotifier.value = progress / 100;
      },
      onLoadStop: (controller, uri) {
        debugPrint('[AdminSupport] onLoadStop: $uri');
        _loadingNotifier.value = false;
        _loadingTimer?.cancel();
      },
      onLoadError: (controller, uri, code, message) {
        debugPrint('[AdminSupport] onLoadError: $message');
        _errorNotifier.value = 'โหลดเว็บล้มเหลว: $message';
        _loadingNotifier.value = false;
        _loadingTimer?.cancel();
      },
      onLoadHttpError: (controller, uri, statusCode, description) {
        debugPrint('[AdminSupport] onLoadHttpError: $statusCode');
        _errorNotifier.value = 'HTTP error: $statusCode';
        _loadingNotifier.value = false;
        _loadingTimer?.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const isWeb = kIsWeb;
    final url = _fullUrl;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (isWeb)
              _buildWebFallback()
            else
              Positioned.fill(child: _buildWebView()),

            // ----- Loading overlay -----
            ValueListenableBuilder<bool>(
              valueListenable: _loadingNotifier,
              builder: (context, isLoading, _) {
                if (!isLoading || isWeb) return const SizedBox.shrink();
                return PointerInterceptor(
                  child: Container(
                    color: Colors.white.withOpacity(0.85),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          const Text('กำลังโหลด Admin Support...'),
                          const SizedBox(height: 8),
                          ValueListenableBuilder<double>(
                            valueListenable: _progressNotifier,
                            builder: (context, progress, _) {
                              if (progress <= 0 || progress >= 1) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(value: progress),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ----- Error overlay -----
            ValueListenableBuilder<String?>(
              valueListenable: _errorNotifier,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return PointerInterceptor(
                  child: Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: Colors.red.shade50,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ----- Refresh button (mobile/desktop only) -----
            if (!isWeb && url != null)
              Positioned(
                top: 16,
                right: 16,
                child: PointerInterceptor(
                  child: FloatingActionButton.small(
                    heroTag: 'admin_support_refresh',
                    onPressed: _refresh,
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
