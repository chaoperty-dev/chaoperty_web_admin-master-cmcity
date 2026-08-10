// ============================================================================
// general_data_section_views.dart
// ============================================================================
// Public wrapper classes สำหรับ Step 1 และ Step 2
// ใช้ part of 'general_data_sections.dart' เพื่อให้ private classes
// (_SectionCard, _HeroStatsCard, etc.) ใช้ร่วมกันได้
// ============================================================================

part of 'general_data_sections.dart';

// ═══════════════════════════════════════════════════════════════════════
// Step 1 — ข้อมูลพื้นฐาน + การตั้งค่า
//   - Hero Stats Card
//   - Section 1-3: ลักษณะ/ประเภทพื้นที่เช่า / การคิดค่าเช่า / ลักษณะการใช้งาน
//   - Section 5: ชื่อสถานที่ + Upload (logo/contract/zone)
//   - Section 6: ระยะเวลาแจ้งใกล้หมดสัญญา
//   - Section 7: แจ้งเตือนผ่าน LINE (toggle + QR)
// ═══════════════════════════════════════════════════════════════════════
class GeneralDataStep1 extends StatelessWidget {
  const GeneralDataStep1({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentalGeneralViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 6 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero / Loading
          if (vm.loading && vm.data.ser == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _HeroStatsCard(vm: vm, isMobile: isMobile),

          SizedBox(height: isMobile ? 8 : 16),

          // Section 1-3
          const _Section1AreaType(),

          const _Section5PlaceName(),

          const _Section6ExpiringDays(),

          const _Section7MassOn(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Step 2 — รูปภาพโซนพื้นที่
//   - Section 8: รูปภาพโซนพื้นที่ (search + horizontal ListView + upload/delete)
// ═══════════════════════════════════════════════════════════════════════
class GeneralDataStep2 extends StatelessWidget {
  const GeneralDataStep2({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Section8ZoneImages(),
        ],
      ),
    );
  }
}
