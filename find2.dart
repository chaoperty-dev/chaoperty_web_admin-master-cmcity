import 'dart:io';

void main() {
  final file = File('lib/AdminScaffold/AdminScaffold.dart');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('signInThreadMain') ||
        line.contains('signInThreadCMM') ||
        line.contains('signInThread') ||
        line.contains('read_GC_permission')) {
      print('Line \${i + 1}: \${line.trim()}');
    }
  }
}
