// ============================================================================
// personal_information_models.dart
// ============================================================================
// Data classes สำหรับ "จัดการข้อมูลส่วนตัว" (admin profile + signature)
// ============================================================================

import 'dart:typed_data';

/// ข้อมูลโปรไฟล์และลายเซ็นของ admin
class AdminProfile {
  final String userUuid;
  final String profileUuid;
  final String signatureUuid;
  final String fullName;
  final String positionName;
  final String email;
  final Uint8List? signatureBytes;

  const AdminProfile({
    required this.userUuid,
    required this.profileUuid,
    required this.signatureUuid,
    required this.fullName,
    required this.positionName,
    required this.email,
    required this.signatureBytes,
  });

  bool get hasSignature => signatureUuid.isNotEmpty && signatureBytes != null;

  /// Initials สำหรับ avatar placeholder
  String get initials {
    final name = fullName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

/// Event ที่ ViewModel ส่งให้ View ฟัง (ใช้ sealed class)
sealed class PersonalInformationEvent {
  const PersonalInformationEvent();
}

class PersonalInformationError extends PersonalInformationEvent {
  final String message;
  const PersonalInformationError(this.message);
}

class PersonalInformationSaved extends PersonalInformationEvent {
  const PersonalInformationSaved();
}
