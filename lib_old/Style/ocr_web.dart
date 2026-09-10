// lib/ocr_web.dart
import 'dart:js_util' as js_util;
import 'dart:html' as html;

/// Call the global JS function we exposed in index.html: window._extractText(imagePath, mapData)
Future<String> webExtractText({
  required String imagePath,
  required String languages, // e.g. "eng+tha"
  Map<String, dynamic>? args,
}) async {
  final mapData = {
    'language': languages,
    if (args != null) 'args': args,
  };
  final jsMap = js_util.jsify(mapData);
  final promise =
      js_util.callMethod(html.window, '_extractText', [imagePath, jsMap]);
  final result = await js_util.promiseToFuture(promise);
  return (result ?? '').toString();
}
