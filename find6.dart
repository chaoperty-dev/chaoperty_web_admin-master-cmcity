import 'dart:io';

void main() {
  final file = File('lib/AdminScaffold/AdminScaffold.dart');
  final lines = file.readAsLinesSync();
  int inBuild = 0;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.contains('Widget build(BuildContext context)')) {
      inBuild = i;
    }
  }
  print('Build starts at: ' + inBuild.toString());
}
