// --------------------> API_admin_requests
enum OutputType { client, documents, attachments, full, count, details }

// --------------------> formatDate
enum DateFormatType {
  thaiShort, // ➜ 17-05-2567
  englishShort, // ➜ 17 May 2024
  isoStandard, // ➜ 2024-05-17 (มาตรฐาน ISO / SQL)
  dmy // ➜ 17-05-2024 (ทั่วไป)
}

// -------------------->ReusableSignaturePad
enum SignatureActionType {
  preview,
  saveToFile,
  upload_user,
  upload_admin,
}

// -------------------->PermissionModel
enum PermissionType {
  positions_all,
  roles_all,
}
