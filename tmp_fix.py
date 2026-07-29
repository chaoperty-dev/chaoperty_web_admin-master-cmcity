lines = open(r'd:\NEW\CMM\chaoperty\lib\ChiangMai_Municipality\License_menu\license_contract_page\views\widgets\billing_table.dart', 'r', encoding='utf-8').read().split('\n')
# Line 334 (1-indexed) is index 333
lines[333] = '                          const Text(\'ยอดรวมทั้งหมด\', style: LcText.label),'
lines[584] = '          const Text(\'ยังไม่มีรายการค่าบริการ\', style: LcText.h2),'
lines[586] = '          const Text(\'กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น\', style: LcText.bodyMuted),'
open(r'd:\NEW\CMM\chaoperty\lib\ChiangMai_Municipality\License_menu\license_contract_page\views\widgets\billing_table.dart', 'w', encoding='utf-8').write('\n'.join(lines))
