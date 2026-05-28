import 'package:intl/intl.dart';

import 'Enum.dart';

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
        return DateFormat('dd-MM-yyyy').format(date);

      case DateFormatType.isoStandard:
      default:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  } catch (e) {
    //print('❌ FormatDate : $e');
    return '-';
  }
}
