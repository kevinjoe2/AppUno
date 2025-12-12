import 'package:flutter/foundation.dart';

class CartService {
  // Badge total
  static final ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  // Grouped by storeId -> productId -> quantity
  static final Map<String, Map<String, int>> _byStore = {};

  // Legacy helpers (still usable for quick demos)
  static void addItems(int n) {
    if (n <= 0) return;
    itemCount.value += n;
  }

  static void removeItems(int n) {
    if (n <= 0) return;
    itemCount.value = (itemCount.value - n).clamp(0, 1 << 31);
  }

  static void clear() {
    _byStore.clear();
    itemCount.value = 0;
  }

  // New API
  static void addProduct({
    required String storeId,
    required String productId,
    int qty = 1,
  }) {
    if (qty <= 0) return;
    final store = _byStore.putIfAbsent(storeId, () => {});
    store[productId] = (store[productId] ?? 0) + qty;
    _recomputeTotal();
  }

  static void removeProduct({
    required String storeId,
    required String productId,
    int qty = 1,
  }) {
    if (!_byStore.containsKey(storeId)) return;
    final store = _byStore[storeId]!;
    final current = store[productId] ?? 0;
    final next = current - qty;
    if (next > 0) {
      store[productId] = next;
    } else {
      store.remove(productId);
      if (store.isEmpty) _byStore.remove(storeId);
    }
    _recomputeTotal();
  }

  static int countForStore(String storeId) {
    final store = _byStore[storeId];
    if (store == null) return 0;
    return store.values.fold(0, (a, b) => a + b);
  }

  static Map<String, Map<String, int>> snapshot() => {
    for (final e in _byStore.entries) e.key: Map<String, int>.from(e.value),
  };

  static void _recomputeTotal() {
    final total = _byStore.values.fold<int>(
      0,
      (sum, m) => sum + m.values.fold(0, (a, b) => a + b),
    );
    itemCount.value = total;
  }
}
