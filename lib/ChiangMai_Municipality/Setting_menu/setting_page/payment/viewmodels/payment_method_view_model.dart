import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/payment_method_event.dart';
import '../models/payment_method_form_data.dart';
import '../models/payment_method_model.dart';
import '../services/payment_method_service.dart';

enum PaymentMethodViewMode { card, table }

class PaymentMethodViewModel extends ChangeNotifier {
  PaymentMethodViewModel({PaymentMethodService? service})
      : _service = service ?? PaymentMethodService() {
    load();
  }

  final PaymentMethodService _service;
  final StreamController<PaymentMethodEvent> _eventController =
      StreamController<PaymentMethodEvent>.broadcast();
  Stream<PaymentMethodEvent> get events => _eventController.stream;

  List<PaymentMethodModel> _items = const [];
  bool _loading = false;
  bool _isSubmitting = false;
  String? _error;
  PaymentMethodViewMode _viewMode = PaymentMethodViewMode.table;
  String _searchQuery = '';
  int _currentPage = 1;

  static const int _pageSize = 20;

  List<PaymentMethodModel> get items => _items;
  bool get loading => _loading;
  bool get isSubmitting => _isSubmitting;
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

  void onCreate() => _emit(const PaymentMethodOpenCreateEvent());

  void onEdit(PaymentMethodModel item) =>
      _emit(PaymentMethodOpenEditEvent(item));

  Future<bool> save({
    PaymentMethodModel? initial,
    required PaymentMethodFormData data,
  }) async {
    if (_isSubmitting) return false;
    final validationError = _validate(data);
    if (validationError != null) {
      _emit(PaymentMethodErrorEvent(validationError));
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      if (initial == null) {
        await _service.create(
          code: data.code,
          nameTh: data.nameTh,
          description: data.description,
          paymentSystem: data.paymentSystem,
          payTypes: data.payTypes,
          sortOrder: data.sortOrder,
          active: data.active,
        );
      } else {
        await _service.update(
          uuid: initial.uuid,
          nameTh: data.nameTh,
          description: data.description,
          paymentSystem: data.paymentSystem,
          payTypes: data.payTypes,
          sortOrder: data.sortOrder,
          active: data.active,
        );
      }
      await load();
      _emit(PaymentMethodSuccessEvent(
        initial == null ? 'เพิ่มช่องทางสำเร็จ' : 'แก้ไขช่องทางสำเร็จ',
      ));
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      _error = message;
      _emit(PaymentMethodErrorEvent(message));
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String? _validate(PaymentMethodFormData data) {
    if (data.code.trim().isEmpty) return 'กรุณาระบุ Code';
    if (data.nameTh.trim().isEmpty) return 'กรุณาระบุชื่อภาษาไทย';
    if (data.sortOrder < 0) return 'ลำดับต้องไม่ติดลบ';
    return null;
  }

  void _emit(PaymentMethodEvent event) {
    if (!_eventController.isClosed) _eventController.add(event);
  }

  void _clampCurrentPage() {
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
