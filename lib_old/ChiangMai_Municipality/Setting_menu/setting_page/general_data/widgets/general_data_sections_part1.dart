// ============================================================================
// general_data_sections_part1.dart
// ============================================================================
// Part 1: Step 1 classes — Hero + Section 1 + Section 5 + ContractImage
// ============================================================================

part of 'general_data_sections.dart';

/// ─── Section widget: _HeroStatsCard ───
class _HeroStatsCard extends StatelessWidget {
  final RentalGeneralViewModel vm;
  final bool isMobile;
  const _HeroStatsCard({required this.vm, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final nFormat = NumberFormat("#,##0", "en_US");
    final total = vm.data.pkqty ?? 0;
    final used = vm.data.countArea ?? 0;
    final remaining = vm.data.remainingArea;
    final usedPct = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? LaSpace.md : LaSpace.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LaColors.primary, LaColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LaRadius.lg),
        boxShadow: [
          BoxShadow(
            color: LaColors.primary.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Row 1: Place name + Package pill ───
          Row(
            children: [
              const Icon(Icons.storefront_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vm.data.pn?.trim().isNotEmpty == true
                      ? vm.data.pn!.trim()
                      : 'ยังไม่ได้ตั้งชื่อสถานที่',
                  style: LaText.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 16 : 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (vm.data.pk != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Pkg ${vm.data.pk}',
                    style: LaText.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : LaSpace.md),
          // ─── Row 2: Stats inline (compact on mobile) ───
          if (isMobile)
            // Mobile: 1 horizontal row 4 stats, text-only
            Row(
              children: [
                _HeroStat(
                  icon: Icons.grid_view_rounded,
                  label: 'ทั้งหมด',
                  value: nFormat.format(total),
                  compact: true,
                ),
                const SizedBox(width: 6),
                _HeroStat(
                  icon: Icons.check_circle_outline,
                  label: 'ใช้แล้ว',
                  value: nFormat.format(used),
                  compact: true,
                ),
                const SizedBox(width: 6),
                _HeroStat(
                  icon: Icons.layers_outlined,
                  label: 'คงเหลือ',
                  value: nFormat.format(remaining),
                  compact: true,
                  tone: remaining > 0 ? Colors.white : Colors.amber.shade200,
                ),
                const SizedBox(width: 6),
                _HeroStat(
                  icon: Icons.people_alt_outlined,
                  label: 'สิทธิ์',
                  value: '${vm.data.pkuser ?? 0}',
                  compact: true,
                ),
              ],
            )
          else
            // Desktop: Wrap 2x2
            Wrap(
              spacing: LaSpace.md,
              runSpacing: LaSpace.sm,
              children: [
                _HeroStat(
                  icon: Icons.grid_view_rounded,
                  label: 'พื้นที่ทั้งหมด',
                  value: nFormat.format(total),
                ),
                _HeroStat(
                  icon: Icons.check_circle_outline,
                  label: 'ใช้งานแล้ว',
                  value: nFormat.format(used),
                  tone: Colors.white,
                ),
                _HeroStat(
                  icon: Icons.layers_outlined,
                  label: 'คงเหลือ',
                  value: nFormat.format(remaining),
                  tone: remaining > 0 ? Colors.white : Colors.amber.shade200,
                ),
                _HeroStat(
                  icon: Icons.people_alt_outlined,
                  label: 'สิทธิ์ผู้ใช้',
                  value: '${vm.data.pkuser ?? 0}',
                ),
              ],
            ),
          SizedBox(height: isMobile ? 8 : LaSpace.md),
          // ─── Progress bar ───
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usedPct,
              minHeight: isMobile ? 6 : 8,
              backgroundColor: Colors.white.withOpacity(.18),
              valueColor: AlwaysStoppedAnimation<Color>(
                usedPct >= 1.0
                    ? Colors.amber.shade300
                    : Colors.white.withOpacity(.95),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ใช้งาน ${(usedPct * 100).toStringAsFixed(1)}% ของพื้นที่ทั้งหมด',
            style: LaText.caption.copyWith(
              color: Colors.white.withOpacity(.75),
              fontSize: isMobile ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Section widget: _HeroStat ───
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? tone;
  final bool compact;
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
    this.tone,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: tone ?? Colors.white, size: 14),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: tone ?? Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: LaText.caption.copyWith(
                  color: Colors.white.withOpacity(.75),
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: tone ?? Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: LaText.caption.copyWith(
                  color: Colors.white.withOpacity(.75),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: LaText.body.copyWith(
                  color: tone ?? Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
// Section card wrapper — ใช้ครอบแต่ละ section ให้ดูเป็น card แยก
// ────────────────────────────────────────────────────────────

/// ─── Section widget: _SectionCard ───
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? accent;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? LaColors.primary;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: LaColors.cardBg,
        borderRadius: BorderRadius.circular(LaRadius.lg),
        border: Border.all(color: LaColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : LaSpace.lg,
                vertical: isMobile ? 6 : 10),
            decoration: BoxDecoration(
              color: tone.withOpacity(.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(LaRadius.lg),
                topRight: Radius.circular(LaRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isMobile ? 22 : 26,
                  height: isMobile ? 22 : 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone.withOpacity(.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: tone, size: isMobile ? 14 : 16),
                ),
                SizedBox(width: isMobile ? 8 : 10),
                Text(
                  title,
                  style: LaText.label.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
          // Bottom border (unified style to avoid borderRadius issue)
          Container(
            height: 1,
            color: LaColors.border,
          ),
          // Section body
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : LaSpace.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 1. ลักษณะ/ประเภทพื้นที่เช่า
// ────────────────────────────────────────────────────────────

/// ─── Section widget: _Section1AreaType ───
class _Section1AreaType extends StatelessWidget {
  const _Section1AreaType();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentalGeneralViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final rows = [
      (label: '1.ลักษณะ/ประเภทพื้นที่เช่า', value: vm.data.typex ?? '-'),
      (label: '2.การคิดค่าเช่า', value: vm.data.rtname ?? '-'),
      (label: '3.ลักษณะการใช้งาน', value: vm.data.type ?? '-'),
    ];

    return _SectionCard(
      title: 'ลักษณะและประเภทการเช่า',
      icon: Icons.category_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                color: LaColors.border,
                margin: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
              ),
            RentalGeneralSectionRow(
              label: rows[i].label,
              value: rows[i].value,
            ),
          ],
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// 5. ชื่อสถานที่ (TextField + Upload popup menu)
// ────────────────────────────────────────────────────────────

/// ─── Section widget: _Section5PlaceName ───
class _Section5PlaceName extends StatefulWidget {
  const _Section5PlaceName();
  @override
  State<_Section5PlaceName> createState() => _Section5PlaceNameState();
}

/// ─── Section widget: _Section5PlaceNameState ───
class _Section5PlaceNameState extends State<_Section5PlaceName> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final vm = context.read<RentalGeneralViewModel>();
    final ok = await vm.updateName(_controller.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'บันทึกชื่อสถานที่แล้ว' : 'บันทึกไม่สำเร็จ'),
      backgroundColor: ok ? LaColors.primary : LaColors.statusRejectedFg,
    ));
  }

  Future<void> _uploadImage(String path) async {
    final vm = context.read<RentalGeneralViewModel>();
    final bytes = await vm.pickImageBytes();
    if (bytes == null) return;
    final ok = await vm.uploadImage(
      path: path,
      zoneName: vm.data.pn ?? '',
      zoneSer: null,
      imageBytes: bytes,
      extension: 'png',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'อัปโหลด $path สำเร็จ' : 'อัปโหลดไม่สำเร็จ'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RentalGeneralViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    if (!_initialized && vm.data.pn != null) {
      _controller.text = vm.data.pn!.trim();
      _initialized = true;
    }
    return _SectionCard(
      title: 'ชื่อสถานที่',
      icon: Icons.storefront_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: TextField + Save button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                      controller: _controller,
                      style: LaText.body,
                      cursorColor: LaColors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'กรอกชื่อสถานที่',
                        hintStyle: LaText.bodyMuted,
                        prefixIcon: const Icon(Icons.edit_outlined,
                            size: 18, color: LaColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: LaSpace.sm),
              FilledButton.icon(
                onPressed: vm.loading ? null : _save,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('บันทึก'),
                style: FilledButton.styleFrom(
                  backgroundColor: LaColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : LaSpace.md),
          // Row: Upload menu + Package info
          Wrap(
            spacing: LaSpace.sm,
            runSpacing: LaSpace.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<String>(
                tooltip: 'อัปโหลดรูปภาพ',
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: _uploadImage,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'logo',
                    child: Row(
                      children: [
                        Icon(
                          vm.data.imglogo == null || vm.data.imglogo!.isEmpty
                              ? Icons.cancel_outlined
                              : Icons.check_circle_outline,
                          color: vm.data.imglogo == null ||
                                  vm.data.imglogo!.isEmpty
                              ? LaColors.statusRejectedFg
                              : LaColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('รูปโลโก้'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'contract',
                    child: Row(
                      children: [
                        Icon(
                          vm.data.img == null || vm.data.img!.isEmpty
                              ? Icons.cancel_outlined
                              : Icons.check_circle_outline,
                          color: vm.data.img == null || vm.data.img!.isEmpty
                              ? LaColors.statusRejectedFg
                              : LaColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('รูปแผนผัง'),
                      ],
                    ),
                  ),
                  for (int i = 1; i < vm.zones.length; i++)
                    PopupMenuItem(
                      value: 'zone',
                      child: Row(
                        children: [
                          Icon(
                            vm.zones[i].img == null || vm.zones[i].img!.isEmpty
                                ? Icons.cancel_outlined
                                : Icons.check_circle_outline,
                            color: vm.zones[i].img == null ||
                                    vm.zones[i].img!.isEmpty
                                ? LaColors.statusRejectedFg
                                : LaColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(vm.zones[i].zn ?? '-'),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: LaColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LaColors.primary.withOpacity(.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_rounded,
                          color: LaColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'เพิ่มรูปภาพ',
                        style: LaText.label.copyWith(
                          color: LaColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Package info card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade50,
                      Colors.deepPurple.shade100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: Colors.deepPurple.shade400, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Package ${vm.data.pk ?? '-'} : ${vm.data.pkqty ?? 0} ล็อค/แผง',
                      style: LaText.body.copyWith(
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: LaColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LaColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        size: 18, color: LaColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'สิทธิ์ผู้ใช้งาน ${vm.data.pkuser ?? 0} คน',
                      style: LaText.body.copyWith(
                        color: LaColors.textSecondary,
                      ),
                    ),
                  ],
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
// 6. ระยะเวลาแจ้งใกล้หมดสัญญา
// ────────────────────────────────────────────────────────────

