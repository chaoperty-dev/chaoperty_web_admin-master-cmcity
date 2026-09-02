// ============================================================================
// area_view_model_test.dart
// ============================================================================
// Unit tests สำหรับ AreaViewModel — CRUD + filter + cascade + events
// ใช้ FakeAreaService extends AreaService แทน HTTP จริง
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_area_model.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_config.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_event.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/models/area_zone_model.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/services/area_service.dart';
import 'package:chaoperty/ChiangMai_Municipality/Setting_menu/setting_page/area/viewmodels/area_view_model.dart';

/// In-memory stub — extends เพื่อ reuse constructor และ private fields
class FakeAreaService extends AreaService {
  final List<AreaZoneModel> _groups = [];
  final Map<String, List<AreaZoneModel>> _zonesByGroup = {};
  final List<AreaAreaModel> _locks = [];
  final List<String> _mutations = [];

  /// บังคับให้ mutation ครั้งถัดไป fail
  bool failNext = false;

  void seedGroup(String ser, String zn) {
    _groups.add(AreaZoneModel.fromGroup({'ser': ser, 'zn': zn}));
  }

  void seedZone(String ser, String groupSer, String zn) {
    _zonesByGroup.putIfAbsent(groupSer, () => []).add(
          AreaZoneModel.fromZone({
            'ser': ser,
            'group_ser': groupSer,
            'zn': zn,
          }),
        );
  }

  void seedLock(String ser, String zone, {String lncode = '', String ln = ''}) {
    _locks.add(AreaAreaModel(
      ser: ser,
      ln: ln,
      sn: '',
      sname: '',
      sw: '0',
      lncode: lncode,
      zone: zone,
    ));
  }

  List<String> get mutations => List.unmodifiable(_mutations);

  bool _guard() {
    if (failNext) {
      failNext = false;
      return false;
    }
    return true;
  }

  @override
  Future<List<AreaZoneModel>> fetchGroups() async {
    final sentinel = AreaZoneModel.fromGroup(
        {'ser': '0', 'zn': 'ทั้งหมด', 'qty': '0'});
    return [sentinel, ..._groups];
  }

  @override
  Future<List<AreaZoneModel>> fetchZonesOfGroup(String groupSer) async {
    return _zonesByGroup[groupSer] ?? const [];
  }

  @override
  Future<bool> zoneExists({
    required String groupSer,
    required String zn,
  }) async {
    final zones = _zonesByGroup[groupSer] ?? const [];
    return zones.any((z) => z.zn == zn);
  }

  @override
  Future<AreaLocksResult> fetchLocks({
    int perPage = 200,
    int page = 1,
    String zoneSer = '',
    String st = '',
    String q = '',
  }) async {
    var list = _locks;
    if (zoneSer.isNotEmpty && zoneSer != '0') {
      list = list.where((a) => a.zone == zoneSer).toList();
    }
    if (q.isNotEmpty) {
      list = list
          .where((a) =>
              a.ln.toLowerCase().contains(q.toLowerCase()) ||
              a.lncode.toLowerCase().contains(q.toLowerCase()))
          .toList();
    }
    list.sort((a, b) =>
        a.lncode.padLeft(8, '0').compareTo(b.lncode.padLeft(8, '0')));
    return AreaLocksResult(
      data: list,
      currentPage: 1,
      lastPage: 1,
      perPage: perPage,
      total: list.length,
    );
  }

  @override
  Future<bool> addGroup({
    required String zn,
    int qty = 0,
    int pri = 0,
    int renPri = 0,
  }) async {
    _mutations.add('addGroup:$zn');
    if (!_guard()) return false;
    final nextSer = (_groups.length + 100).toString();
    _groups.add(AreaZoneModel.fromGroup(
        {'ser': nextSer, 'zn': zn, 'qty': '$qty'}));
    return true;
  }

  @override
  Future<bool> updateGroup({
    required String ser,
    String? zn,
    int? qty,
  }) async {
    _mutations.add('updateGroup:$ser:$zn');
    if (!_guard()) return false;
    final idx = _groups.indexWhere((g) => g.ser == ser);
    if (idx < 0) return false;
    _groups[idx] = AreaZoneModel.fromGroup({
      'ser': ser,
      'zn': zn ?? _groups[idx].zn,
      'qty': qty?.toString() ?? _groups[idx].qty,
    });
    return true;
  }

  @override
  Future<bool> deleteGroup({required String ser}) async {
    _mutations.add('deleteGroup:$ser');
    if (!_guard()) return false;
    _groups.removeWhere((g) => g.ser == ser);
    _zonesByGroup.remove(ser);
    return true;
  }

  @override
  Future<bool> addZone({
    required String groupSer,
    required String zn,
    int qty = 0,
    int status = 1,
  }) async {
    _mutations.add('addZone:$groupSer:$zn');
    if (!_guard()) return false;
    _zonesByGroup.putIfAbsent(groupSer, () => []).add(
          AreaZoneModel.fromZone({
            'ser': '${groupSer}_${_zonesByGroup[groupSer]!.length}',
            'group_ser': groupSer,
            'zn': zn,
          }),
        );
    return true;
  }

  @override
  Future<bool> updateZone({
    required String ser,
    String? zn,
    int? qty,
  }) async {
    _mutations.add('updateZone:$ser:$zn');
    if (!_guard()) return false;
    for (final list in _zonesByGroup.values) {
      final i = list.indexWhere((z) => z.ser == ser);
      if (i >= 0) {
        list[i] = AreaZoneModel.fromZone({
          'ser': ser,
          'group_ser': list[i].groupSer ?? '0',
          'zn': zn ?? list[i].zn,
        });
        return true;
      }
    }
    return false;
  }

  @override
  Future<bool> deleteZone({required String ser}) async {
    _mutations.add('deleteZone:$ser');
    if (!_guard()) return false;
    for (final list in _zonesByGroup.values) {
      list.removeWhere((z) => z.ser == ser);
    }
    return true;
  }

  @override
  Future<bool> addLock({
    required String zoneSer,
    required String lncode,
    required String ln,
    required String area,
    required String rent,
  }) async {
    _mutations.add('addLock:$zoneSer:$lncode');
    if (!_guard()) return false;
    _locks.add(AreaAreaModel(
      ser: '${_locks.length + 1000}',
      ln: ln,
      sn: '',
      sname: '',
      sw: '0',
      lncode: lncode,
      area: area,
      rent: rent,
      zone: zoneSer,
    ));
    return true;
  }

  @override
  Future<bool> updateLock({
    required String ser,
    String? rent,
    int? st,
  }) async {
    _mutations.add('updateLock:$ser:$rent');
    if (!_guard()) return false;
    final i = _locks.indexWhere((a) => a.ser == ser);
    if (i < 0) return false;
    _locks[i] = AreaAreaModel(
      ser: _locks[i].ser,
      ln: _locks[i].ln,
      sn: _locks[i].sn,
      sname: _locks[i].sname,
      sw: _locks[i].sw,
      lncode: _locks[i].lncode,
      area: _locks[i].area,
      rent: rent ?? _locks[i].rent,
      rentMaket: _locks[i].rentMaket,
      zone: _locks[i].zone,
      zn: _locks[i].zn,
      typeId: _locks[i].typeId,
      typeName: _locks[i].typeName,
      rser: _locks[i].rser,
      cid: _locks[i].cid,
      cname: _locks[i].cname,
      stype: _locks[i].stype,
      quantity: _locks[i].quantity,
    );
    return true;
  }

  @override
  Future<bool> deleteLock({required String ser}) async {
    _mutations.add('deleteLock:$ser');
    if (!_guard()) return false;
    _locks.removeWhere((a) => a.ser == ser);
    return true;
  }
}

AreaViewModel _makeVM(FakeAreaService svc) {
  return AreaViewModel(
    config: AreaConfig(title: 'test', routeData: null),
    service: svc,
  );
}

Future<void> _waitBootstrap(AreaViewModel vm) async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('AreaViewModel', () {
    late FakeAreaService svc;
    late AreaViewModel vm;

    setUp(() async {
      svc = FakeAreaService()
        ..seedGroup('5', 'อาคาร A')
        ..seedGroup('7', 'อาคาร B')
        ..seedZone('50', '5', 'โซน A1')
        ..seedZone('51', '5', 'โซน A2')
        ..seedLock('100', '50', lncode: 'A-001', ln: 'LN001');
      vm = _makeVM(svc);
      await _waitBootstrap(vm);
    });

    tearDown(() {
      vm.dispose();
    });

    test('bootstrap โหลด groups + sentinel "ทั้งหมด"', () {
      expect(vm.groups.length, 3);
      expect(vm.groups.first.isAll, isTrue);
      expect(vm.selectedGroupSer, '0');
    });

    test('onGroupChanged → reset zone + โหลด zones ของ group นั้น', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      expect(vm.selectedGroupSer, '5');
      expect(vm.selectedZoneSer, isNull);
      expect(vm.zones.length, 2);
      expect(vm.zones.map((z) => z.zn),
          containsAll(['โซน A1', 'โซน A2']));
    });

    test('onGroupChanged("0") → zones ว่าง (sentinel)', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      await vm.onGroupChanged('0', 'ทั้งหมด');
      expect(vm.zones, isEmpty);
    });

    test('onZoneChanged → เก็บ zone ser จริง', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      await vm.onZoneChanged('50', 'โซน A1');
      expect(vm.selectedZoneSer, '50');
      expect(vm.selectedZoneName, 'โซน A1');
      expect(vm.selectedZone, isNotNull);
      expect(vm.selectedZone!.zn, 'โซน A1');
    });

    // ---------- CRUD: Group ----------

    test('addGroup สำเร็จ → emit success event', () async {
      final events = <AreaEvent>[];
      final sub = vm.events.listen(events.add);
      final ok = await vm.addGroup(zn: 'อาคาร C', qty: 2);
      await Future<void>.delayed(Duration.zero);

      expect(ok, isTrue);
      expect(events.whereType<AreaSuccessEvent>().length, 1);
      expect(events.whereType<AreaSuccessEvent>().first.message,
          contains('เพิ่มหมวดสำเร็จ'));
      expect(vm.groups.any((g) => g.zn == 'อาคาร C'), isTrue);
      await sub.cancel();
    });

    test('addGroup fail → emit error event', () async {
      svc.failNext = true;
      final events = <AreaEvent>[];
      final sub = vm.events.listen(events.add);

      final ok = await vm.addGroup(zn: 'จะ fail');

      expect(ok, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<AreaErrorEvent>().length, 1);
      await sub.cancel();
    });

    test('updateGroup → emit success + ชื่ออัปเดต', () async {
      final events = <AreaEvent>[];
      final sub = vm.events.listen(events.add);

      final ok = await vm.updateGroup(ser: '5', zn: 'อาคาร A-ใหม่');

      expect(ok, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<AreaSuccessEvent>().first.message,
          contains('แก้ไขหมวดสำเร็จ'));
      expect(vm.groups.firstWhere((g) => g.ser == '5').zn, 'อาคาร A-ใหม่');
      await sub.cancel();
    });

    test('deleteGroup → reset เป็น sentinel ถ้าลบตัวที่เลือกอยู่', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      expect(vm.selectedGroupSer, '5');

      final ok = await vm.deleteGroup(ser: '5', name: 'อาคาร A');

      expect(ok, isTrue);
      expect(vm.selectedGroupSer, '0');
      expect(vm.selectedGroupName, 'ทั้งหมด');
      expect(vm.zones, isEmpty);
      expect(vm.groups.any((g) => g.ser == '5'), isFalse);
    });

    // ---------- CRUD: Zone ----------

    test('addZone duplicate → return false + emit error event', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      final events = <AreaEvent>[];
      final sub = vm.events.listen(events.add);

      final ok = await vm.addZone(groupSer: '5', zn: 'โซน A1');

      expect(ok, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<AreaErrorEvent>().first.message,
          contains('อยู่ในหมวดนี้แล้ว'));
      await sub.cancel();
    });

    test('addZone success → เพิ่มใน list', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      final ok = await vm.addZone(groupSer: '5', zn: 'โซน A3');

      expect(ok, isTrue);
      expect(vm.zones.any((z) => z.zn == 'โซน A3'), isTrue);
    });

    test('updateZone → เปลี่ยนชื่อใน list', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      final ok = await vm.updateZone(ser: '50', zn: 'โซน A1-renamed');

      expect(ok, isTrue);
      expect(vm.zones.firstWhere((z) => z.ser == '50').zn,
          'โซน A1-renamed');
    });

    test('deleteZone → ลบออกจาก list', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      final ok = await vm.deleteZone(ser: '50', name: 'โซน A1');

      expect(ok, isTrue);
      expect(vm.zones.any((z) => z.ser == '50'), isFalse);
    });

    // ---------- CRUD: Lock (Area) ----------

    test('addArea → lock ใหม่ปรากฏใน areas', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      await vm.onZoneChanged('50', 'โซน A1');

      final ok = await vm.addArea(
        zone: '50',
        lncode: 'A-NEW',
        ln: 'LNN',
        area: '10',
        rent: '500',
      );

      expect(ok, isTrue);
      expect(vm.areas.any((a) => a.lncode == 'A-NEW'), isTrue);
    });

    test('updateArea → เปลี่ยน rent', () async {
      final ok = await vm.updateArea(ser: '100', rent: '9999');

      expect(ok, isTrue);
      expect(vm.areas.firstWhere((a) => a.ser == '100').rent, '9999',
          reason: 'rent ต้องอัปเดต');
    });

    test('deleteArea → ลบออกจาก areas', () async {
      final target = vm.areas.firstWhere((a) => a.ser == '100');
      final ok = await vm.deleteArea(target);

      expect(ok, isTrue);
      expect(vm.areas.any((a) => a.ser == '100'), isFalse);
    });

    // ---------- Filter / Search ----------

    test('fetchLocks filter ตาม zone_ser', () async {
      await vm.onGroupChanged('5', 'อาคาร A');
      await vm.onZoneChanged('50', 'โซน A1');

      expect(vm.areas.length, 1);
      expect(vm.areaCount, 1);
    });

    test('search filter: q=lncode → match', () async {
      vm.setSearch('A-001');
      await vm.executeSearch();

      expect(vm.areas.length, 1);
      expect(vm.areas.first.lncode, 'A-001');
    });

    test('search filter: q ไม่ match → empty', () async {
      vm.setSearch('zzz-nothing');
      await vm.executeSearch();

      expect(vm.areas, isEmpty);
    });

    test('search sort by lncode (padLeft 8)', () async {
      svc.seedLock('101', '50', lncode: 'A-002', ln: 'LN002');
      svc.seedLock('102', '50', lncode: 'A-010', ln: 'LN010');
      await vm.refresh();

      final codes = vm.filtered.map((a) => a.lncode).toList();
      expect(codes, ['A-001', 'A-002', 'A-010']);
    });
  });
}
