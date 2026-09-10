// ============================================================================
// general_data_sections_part2.dart
// ============================================================================
// Part 2: Step 2 classes — Section 6, 7, 8 + ZoneImageCard
// ============================================================================

part of 'general_data_sections.dart';

/// ─── Section widget: _Section6ExpiringDays ───
class _Section6ExpiringDays extends StatefulWidget {
  const _Section6ExpiringDays();
  @override
  State<_Section6ExpiringDays> createState() => _Section6ExpiringDaysState();
}

/// ─── Section widget: _Section6ExpiringDaysState ───
class _Section6ExpiringDaysState extends State<_Section6ExpiringDays> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = context.read<RentalGeneralViewModel>();
    final days = int.tryParse(_controller.text) ?? 0;
    final ok = await vm.updateOpenSetDate(days);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'บันทึกระยะเวลาแล้ว' : 'บันทึกไม่สำเร็จ'),
      backgroundColor: ok ? LaColors.primary : LaColors.statusRejectedFg,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentalGeneralViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    if (!_initialized && vm.data.openSetDate != null) {
      _controller.text = vm.data.openSetDate!.toString();
      _initialized = true;
    }
    return _SectionCard(
      title: 'ระยะเวลาแจ้งใกล้หมดสัญญา',
      icon: Icons.notifications_active_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            Text(
              'แจ้งเตือนลูกค้าล่วงหน้าก่อนสัญญาหมด',
              style: LaText.bodyMuted,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isMobile ? 36 : 44,
                height: isMobile ? 36 : 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.statusPendingBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: LaColors.statusPendingFg.withOpacity(.3)),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: LaColors.statusPendingFg,
                  size: isMobile ? 18 : 22,
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              // Number input
              Container(
                width: 80,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LaColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: LaText.body
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                    cursorColor: LaColors.primary,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: '30',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('วัน', style: LaText.body),
              const Spacer(),
              FilledButton.icon(
                onPressed: vm.loading ? null : _save,
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('บันทึก'),
                style: FilledButton.styleFrom(
                  backgroundColor: LaColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 7. เปิดแจ้งผ่านไลน์ + LINE QR
// ────────────────────────────────────────────────────────────

/// ─── Section widget: _Section7MassOn ───
class _Section7MassOn extends StatelessWidget {
  const _Section7MassOn();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentalGeneralViewModel>();
    final isOn = vm.data.isMassOn;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    return _SectionCard(
      title: 'การแจ้งเตือนผ่าน LINE',
      icon: Icons.notifications_rounded,
      accent: const Color(0xFF06C755), // LINE green
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Toggle + Switch + QR
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Toggle button area
              Expanded(
                child: Row(
                  children: [
                    Switch(
                      value: isOn,
                      activeColor: const Color(0xFF06C755),
                      onChanged: vm.loading
                          ? null
                          : (val) async {
                              final ok = await vm.toggleMassOn();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      ok ? 'อัปเดตแล้ว' : 'อัปเดตไม่สำเร็จ'),
                                  backgroundColor: ok
                                      ? const Color(0xFF06C755)
                                      : LaColors.statusRejectedFg,
                                ),
                              );
                            },
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOn
                            ? const Color(0xFF06C755).withOpacity(.12)
                            : LaColors.statusRejectedBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOn ? Icons.check_circle : Icons.cancel,
                            size: 12,
                            color: isOn
                                ? const Color(0xFF06C755)
                                : LaColors.statusRejectedFg,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isOn ? 'เปิด' : 'ปิด',
                            style: LaText.caption.copyWith(
                              color: isOn
                                  ? const Color(0xFF06C755)
                                  : LaColors.statusRejectedFg,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // QR
              if (vm.data.lineQrImageUrl != null &&
                  vm.data.lineQrImageUrl!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: LaColors.border),
                  ),
                  child: Image.network(
                    vm.data.lineQrImageUrl!,
                    width: isMobile ? 72 : 88,
                    height: isMobile ? 72 : 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                    ),
                  ),
                ),
            ],
          ),
          // Hint
          if (!isMobile) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber.shade800, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'อาจมีค่าใช้จ่ายเพิ่มเติม',
                    style: LaText.caption.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 8. รูปภาพโซนพื้นที่ (search + horizontal ListView + upload/delete)
// ────────────────────────────────────────────────────────────

/// ─── Section widget: _Section8ZoneImages ───
class _Section8ZoneImages extends StatefulWidget {
  const _Section8ZoneImages();
  @override
  State<_Section8ZoneImages> createState() => _Section8ZoneImagesState();
}

/// ─── Section widget: _Section8ZoneImagesState ───
class _Section8ZoneImagesState extends State<_Section8ZoneImages> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentalGeneralViewModel>();
    final filtered = _query.isEmpty ? vm.zones : vm.searchZones(_query);
    final width = MediaQuery.of(context).size.width;

    return _SectionCard(
      title: 'รูปภาพโซนพื้นที่',
      icon: Icons.collections_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Row(
            children: [
              const Icon(Icons.search_rounded,
                  size: 20, color: LaColors.textMuted),
              const SizedBox(width: 8),
              Text('ค้นหาโซน :', style: LaText.body),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: LaColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'พิมพ์ชื่อโซน...',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: LaColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${filtered.length} / ${vm.zones.length} โซน',
                  style: LaText.caption.copyWith(
                    color: LaColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LaSpace.md),
          // Horizontal list of zones
          SizedBox(
            height: 220,
            width: width < 700 ? width * 0.95 : width * 0.85,
            child: vm.loadingZones
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 48, color: LaColors.textMuted),
                            const SizedBox(height: 8),
                            Text('ไม่พบโซนที่ค้นหา', style: LaText.bodyMuted),
                          ],
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: LaSpace.sm),
                        itemBuilder: (context, index) {
                          final z = filtered[index];
                          return _ZoneImageCard(zone: z);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// ─── Section widget: _ZoneImageCard ───
class _ZoneImageCard extends StatelessWidget {
  final dynamic zone; // ZoneImageModel
  const _ZoneImageCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RentalGeneralViewModel>();
    final isLogo = zone.zn == 'โลโก้';
    final isContract = zone.zn == 'แผนผัง';
    final imgUrl = zone.imageUrl;
    final hasImg = imgUrl != null && imgUrl.isNotEmpty;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        border: Border.all(color: LaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final bytes = await vm.pickImageBytes();
                if (bytes == null) return;
                final path = isLogo
                    ? 'logo'
                    : isContract
                        ? 'contract'
                        : 'zone';
                final ok = await vm.uploadImage(
                  path: path,
                  zoneName: isLogo
                      ? 'logo'
                      : (isContract ? 'contract' : (zone.zn ?? '')),
                  zoneSer: isLogo || isContract ? null : zone.ser,
                  imageBytes: bytes,
                  extension: 'png',
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'อัปโหลดแล้ว' : 'อัปโหลดไม่สำเร็จ'),
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: LaColors.surfaceMuted,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(LaRadius.lg),
                    topRight: Radius.circular(LaRadius.lg),
                  ),
                ),
                child: hasImg
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(LaRadius.lg),
                          topRight: Radius.circular(LaRadius.lg),
                        ),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                size: 64, color: LaColors.textMuted),
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 36, color: LaColors.textMuted),
                            const SizedBox(height: 4),
                            Text('คลิกเพื่ออัปโหลด', style: LaText.caption),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          // Footer label + delete
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(LaRadius.lg),
                bottomRight: Radius.circular(LaRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    zone.zn ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LaText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: LaColors.textPrimary,
                    ),
                  ),
                ),
                if (hasImg)
                  Material(
                    color: LaColors.statusRejectedBg,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        final path = isLogo
                            ? 'logo'
                            : isContract
                                ? 'contract'
                                : 'zone';
                        final ok = await vm.deleteImage(
                          path: path,
                          fileName: zone.img,
                          zoneSer: zone.ser,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'ลบรูปแล้ว' : 'ลบรูปไม่สำเร็จ'),
                        ));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: LaColors.statusRejectedFg),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
