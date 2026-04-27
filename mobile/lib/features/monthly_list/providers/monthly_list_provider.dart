import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/month_format.dart';
import '../models/list_item.dart';

final monthlyListNotifierProvider =
    AsyncNotifierProvider<MonthlyListNotifier, MonthlyList>(
  MonthlyListNotifier.new,
);

class MonthlyListNotifier extends AsyncNotifier<MonthlyList> {
  @override
  Future<MonthlyList> build() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return MonthlyList(
      yearMonth: currentYearMonth(),
      status: 'OPEN',
      updatedAt: DateTime.now().toIso8601String(),
      items: [
        ListItem(itemId: '1', canonicalName: 'arroz',   displayName: 'Arroz',        quantity: 2,   unit: 'kg',   price: 5.99,  addedAt: '', source: 'app'),
        ListItem(itemId: '2', canonicalName: 'feijao',  displayName: 'Feijão',       quantity: 1,   unit: 'kg',   price: 8.50,  addedAt: '', source: 'alexa'),
        ListItem(itemId: '3', canonicalName: 'leite',   displayName: 'Leite',        quantity: 6,   unit: 'l',    price: 4.29,  addedAt: '', source: 'alexa'),
        ListItem(itemId: '4', canonicalName: 'ovos',    displayName: 'Ovos',         quantity: 12,  unit: 'un',   price: 0.89,  addedAt: '', source: 'app'),
        ListItem(itemId: '5', canonicalName: 'pao',     displayName: 'Pão de Forma', quantity: 2,   unit: 'pack', price: 7.90,  addedAt: '', source: 'app'),
        ListItem(itemId: '6', canonicalName: 'frango',  displayName: 'Frango',       quantity: 1.5, unit: 'kg',   price: 14.90, addedAt: '', source: 'alexa'),
        ListItem(itemId: '7', canonicalName: 'tomate',  displayName: 'Tomate',       quantity: 1,   unit: 'kg',   price: 6.50,  addedAt: '', source: 'app'),
      ],
    );
  }

  Future<void> addItem(String displayName, double quantity, String unit, double? price) async {
    final current = await future;
    final newItem = ListItem(
      itemId: DateTime.now().millisecondsSinceEpoch.toString(),
      canonicalName: displayName.toLowerCase().trim(),
      displayName: displayName.trim(),
      quantity: quantity,
      unit: unit,
      price: price,
      addedAt: DateTime.now().toIso8601String(),
      source: 'app',
    );
    state = AsyncData(MonthlyList(
      yearMonth: current.yearMonth,
      status: current.status,
      updatedAt: DateTime.now().toIso8601String(),
      items: [...current.items, newItem],
      adjustedTotal: current.adjustedTotal,
    ));
  }

  Future<void> setAdjustedTotal(double total) async {
    final current = await future;
    state = AsyncData(MonthlyList(
      yearMonth: current.yearMonth,
      status: current.status,
      updatedAt: DateTime.now().toIso8601String(),
      items: current.items,
      adjustedTotal: total,
    ));
  }

  Future<void> closePurchase(String yearMonth) async {
    final current = await future;
    state = AsyncData(MonthlyList(
      yearMonth: current.yearMonth,
      status: 'CLOSED',
      updatedAt: DateTime.now().toIso8601String(),
      items: current.items,
      adjustedTotal: current.adjustedTotal,
    ));
  }
}
