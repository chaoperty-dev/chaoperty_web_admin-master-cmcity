import 'dart:io';

void searchFile(File file) {
  try {
    final lines = file.readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('AdminScafScreen(')) {
        if (lines[i].contains('Navigator') ||
            (i > 0 && lines[i - 1].contains('Navigator'))) {
          print('FOUND PUSH in ' +
              file.path +
              ' - Line ' +
              i.toString() +
              ': ' +
              lines[i].trim());
        }
      }
    }
  } catch (e) {}
}

void main() {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);
  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      searchFile(entity);
    }
  }
}
