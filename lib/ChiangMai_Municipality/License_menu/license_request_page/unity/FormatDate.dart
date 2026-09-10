import 'package:intl/intl.dart';

import 'Enum.dart';

String formatThaiDate(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '-';
  try {
    final date = DateTime.parse(dateStr).toLocal();
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year + 543}';
  } catch (_) {
    return '-';
  }
}

String formatThaiDateTime(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '-';
  try {
    final date = DateTime.parse(dateStr).toLocal();
    return '${formatThaiDate(dateStr)} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '-';
  }
}

String formatDate(String? dateStr,
    {DateFormatType type = DateFormatType.isoStandard}) {
  if (dateStr == null || dateStr.trim().isEmpty) return '-';

  try {
    final date = DateTime.parse('$dateStr');

    switch (type) {
      case DateFormatType.thaiShort:
        final thaiYear = date.year + 543;
        return '${date.day.toString().padLeft(2, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '$thaiYear';

      case DateFormatType.englishShort:
        return DateFormat('dd MMM yyyy', 'en_US').format(date);

      case DateFormatType.dmy:
        final thaiYear = date.year + 543;
        return '${date.day.toString().padLeft(2, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '$thaiYear';

      case DateFormatType.isoStandard:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  } catch (e) {
    //print('❌ FormatDate : $e');
    return '-';
  }
}
