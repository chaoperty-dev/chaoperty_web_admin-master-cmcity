String formatPhoneNumber(String? phone) {
  if (phone == null || phone.isEmpty) return '';
  if (phone.length == 10) {
    return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
  }
  return phone;
}
