import 'dart:io';

void main() {
  final file = File('lib/AdminScaffold/AdminScaffold.dart');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('read_GC_permission') ||
        line.contains('signInThread') ||
        line.contains('read_GC_rentalColor')) {
      print('Line \${i + 1}: \${line.trim()}');
    }
  }
}
