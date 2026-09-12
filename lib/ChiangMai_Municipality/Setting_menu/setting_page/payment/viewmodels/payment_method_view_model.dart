import 'package:flutter/foundation.dart';

import '../models/payment_method_model.dart';
import '../services/payment_method_service.dart';

enum PaymentMethodViewMode { card, table }

class PaymentMethodViewModel extends ChangeNotifier {
  PaymentMethodViewModel({PaymentMethodService? service})
      : _service = service ?? PaymentMethodService() {
    load();
  }

  final PaymentMethodService _service;
  List<PaymentMethodModel> _items = const [];
  bool _loading = false;
  String? _error;
  PaymentMethodViewMode _viewMode = PaymentMethodViewMode.table;
  String _searchQuery = '';
  int _currentPage = 1;

  static const int _pageSize = 20;

  List<PaymentMethodModel> get items => _items;
  bool get loading => _loading;
  String? get error => _error;
  PaymentMethodViewMode get viewMode => _viewMode;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  List<PaymentMethodModel> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) {
      final searchable = [
        item.code,
        item.nameTh,
        item.description,
        item.paymentSystem,
        ...item.payTypes,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList(growable: false);
  }

  int get totalPages {
    final total = filteredItems.length;
    return total == 0 ? 1 : (total / _pageSize).ceil();
  }

  List<PaymentMethodModel> get pagedItems {
    final filtered = filteredItems;
    final start = (_currentPage - 1) * _pageSize;
    if (start >= filtered.length) return const [];
    final end = (start + _pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  void setViewMode(PaymentMethodViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void setSearch(String value) {
    _searchQuery = value;
    _currentPage = 1;
    notifyListeners();
  }

  void clearSearch() => setSearch('');

  void previousPage() {
    if (_currentPage <= 1 || _loading) return;
    _currentPage -= 1;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage >= totalPages || _loading) return;
    _currentPage += 1;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = (await _service.fetchAll())
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _clampCurrentPage();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String code,
    required String nameTh,
    required String description,
    required String paymentSystem,
    required List<String> payTypes,
    required int sortOrder,
    required bool active,
  }) async {
    try {
      await _service.create(
        code: code,
        nameTh: nameTh,
        description: description,
        paymentSystem: paymentSystem,
        payTypes: payTypes,
        sortOrder: sortOrder,
        active: active,
      );
      await load();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(
    PaymentMethodModel item, {
    required String nameTh,
    required String description,
    required String paymentSystem,
    required List<String> payTypes,
    required int sortOrder,
    required bool active,
  }) async {
    try {
      await _service.update(
        uuid: item.uuid,
        nameTh: nameTh,
        description: description,
        paymentSystem: paymentSystem,
        payTypes: payTypes,
        sortOrder: sortOrder,
        active: active,
      );
      await load();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(PaymentMethodModel item) async {
    try {
      await _service.delete(item.uuid);
      await load();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void _clampCurrentPage() {
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;
  }
}
