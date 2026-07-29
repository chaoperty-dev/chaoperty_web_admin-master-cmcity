import 'dart:io';

void main() {
  final file = File('lib/AdminScaffold/AdminScaffold.dart');
  final lines = file.readAsLinesSync();
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('StreamBuilder') ||
        line.contains('FutureBuilder') ||
        line.contains('Timer.periodic') ||
        line.contains('Stream.periodic')) {
      print('Line ' + i.toString() + ': ' + line.trim());
    }
  }
}
