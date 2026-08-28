// ============================================================================
// export_phase.dart
// ============================================================================
// Export phase enum — shared between customers + areas report view models.
//
// ✅ UX: แสดง progress message ที่ตรงกับ phase จริง
//    - loadingData: "กำลังโหลดข้อมูล..."
//    - buildingFile: "กำลังสร้างไฟล์..."
//    - done: "เสร็จ"
//    - error: error message
// ============================================================================

enum ExportPhase {
  idle,
  loadingData,
  buildingFile,
  done,
  error,
}

extension ExportPhaseLabel on ExportPhase {
  /// ข้อความสำหรับ UI (ปุ่ม download)
  String get label {
    switch (this) {
      case ExportPhase.idle:
        return '';
      case ExportPhase.loadingData:
        return 'กำลังโหลดข้อมูล...';
      case ExportPhase.buildingFile:
        return 'กำลังสร้างไฟล์...';
      case ExportPhase.done:
        return 'เสร็จ';
      case ExportPhase.error:
        return 'ผิดพลาด';
    }
  }

  /// ✅ กำลัง export อยู่หรือไม่ (true ระหว่าง loadingData / buildingFile)
  bool get isBusy =>
      this == ExportPhase.loadingData || this == ExportPhase.buildingFile;
}
