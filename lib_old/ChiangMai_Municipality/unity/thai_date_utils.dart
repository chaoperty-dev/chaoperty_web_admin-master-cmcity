////////------------------------------------------------------->
// DateTime date = DateTime.now(); // หรือ date ที่ต้องการ
// String day = toThaiNumber(DateFormat('dd').format(date));
// String monthName = getThaiMonthName(date.month, short: false);
// String year = toThaiNumber((date.year + 543).toString()); // แปลงเป็น พ.ศ.

// String fullDate = '$day $monthName พ.ศ. $year';
// //print(fullDate); // เช่น: ๒๙ พฤษภาคม พ.ศ. ๒๕๖๗
////////------------------------------------------------------->
String getThaiMonthName(int month, {bool short = false}) {
  const fullMonths = [
    '', // index 0 ไม่ใช้
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
    'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
    'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];
  const shortMonths = [
    '', // index 0 ไม่ใช้
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
    'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
    'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];
  if (month < 1 || month > 12) return '';
  return short ? shortMonths[month] : fullMonths[month];
}

String toThaiNumber(String input) {
  const arabicToThai = {
    '0': '๐',
    '1': '๑',
    '2': '๒',
    '3': '๓',
    '4': '๔',
    '5': '๕',
    '6': '๖',
    '7': '๗',
    '8': '๘',
    '9': '๙',
  };

  return input.split('').map((char) => arabicToThai[char] ?? char).join();
}
