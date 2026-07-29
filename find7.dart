import 'dart:io';

void main() {
  final file = File('lib/AdminScaffold/AdminScaffold.dart');
  final lines = file.readAsLinesSync();
  int start = -1;
  int end = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('signInThreadMain()')) start = i;
    if (start != -1 && lines[i].contains('Future<Null> read_GC_permission')) {
      end = i;
      break;
    }
  }
  if (start != -1 && end != -1) {
    for (int i = start; i < end; i++) {
      print(lines[i]);
    }
  } else {
    print('Not found: $start to $end');
  }
}
