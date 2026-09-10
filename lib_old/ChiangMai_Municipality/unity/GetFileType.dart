String getFileType(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();
  return ext;
  // switch (ext) {
  //   case 'pdf':
  //     return 'ไฟล์ PDF';
  //   case 'png':
  //   case 'jpg':
  //   case 'jpeg':
  //   case 'gif':
  //     return 'ไฟล์รูปภาพ';
  //   case 'doc':
  //   case 'docx':
  //     return 'ไฟล์ Word';
  //   case 'xls':
  //   case 'xlsx':
  //     return 'ไฟล์ Excel';
  //   case 'txt':
  //     return 'ไฟล์ข้อความ';
  //   default:
  //     return 'ไฟล์อื่น ๆ';
  // }
}
