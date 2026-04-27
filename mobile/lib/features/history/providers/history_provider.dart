import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../monthly_list/models/list_item.dart';

final historyProvider = FutureProvider<List<MonthlyList>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return [
    MonthlyList(
      yearMonth: '2026-03',
      status: 'CLOSED',
      updatedAt: '2026-03-31T20:00:00Z',
      adjustedTotal: 94.50,
      items: [
        ListItem(itemId: '1', canonicalName: 'arroz',    displayName: 'Arroz',    quantity: 2,  unit: 'kg',   price: 5.99,  addedAt: '', source: 'app'),
        ListItem(itemId: '2', canonicalName: 'feijao',   displayName: 'Feijão',   quantity: 1,  unit: 'kg',   price: 8.50,  addedAt: '', source: 'alexa'),
        ListItem(itemId: '3', canonicalName: 'leite',    displayName: 'Leite',    quantity: 6,  unit: 'l',    price: 4.29,  addedAt: '', source: 'alexa'),
        ListItem(itemId: '4', canonicalName: 'manteiga', displayName: 'Manteiga', quantity: 1,  unit: 'un',   price: 12.90, addedAt: '', source: 'app'),
        ListItem(itemId: '5', canonicalName: 'cafe',     displayName: 'Café',     quantity: 1,  unit: 'kg',   price: 28.90, addedAt: '', source: 'app'),
      ],
    ),
    MonthlyList(
      yearMonth: '2026-02',
      status: 'CLOSED',
      updatedAt: '2026-02-28T18:30:00Z',
      adjustedTotal: 78.20,
      items: [
        ListItem(itemId: '1', canonicalName: 'arroz',  displayName: 'Arroz',  quantity: 2,  unit: 'kg',  price: 5.79, addedAt: '', source: 'app'),
        ListItem(itemId: '2', canonicalName: 'ovos',   displayName: 'Ovos',   quantity: 12, unit: 'un',  price: 0.85, addedAt: '', source: 'app'),
        ListItem(itemId: '3', canonicalName: 'frango', displayName: 'Frango', quantity: 2,  unit: 'kg',  price: 13.90, addedAt: '', source: 'alexa'),
        ListItem(itemId: '4', canonicalName: 'tomate', displayName: 'Tomate', quantity: 1,  unit: 'kg',  price: 5.90, addedAt: '', source: 'app'),
      ],
    ),
    MonthlyList(
      yearMonth: '2026-01',
      status: 'CLOSED',
      updatedAt: '2026-01-30T19:00:00Z',
      adjustedTotal: 112.00,
      items: [
        ListItem(itemId: '1', canonicalName: 'arroz',      displayName: 'Arroz',      quantity: 3,  unit: 'kg',  price: 5.50,  addedAt: '', source: 'app'),
        ListItem(itemId: '2', canonicalName: 'feijao',     displayName: 'Feijão',     quantity: 2,  unit: 'kg',  price: 8.20,  addedAt: '', source: 'app'),
        ListItem(itemId: '3', canonicalName: 'acucar',     displayName: 'Açúcar',     quantity: 2,  unit: 'kg',  price: 4.99,  addedAt: '', source: 'alexa'),
        ListItem(itemId: '4', canonicalName: 'oleo',       displayName: 'Óleo',       quantity: 1,  unit: 'l',   price: 8.90,  addedAt: '', source: 'app'),
        ListItem(itemId: '5', canonicalName: 'detergente', displayName: 'Detergente', quantity: 2,  unit: 'un',  price: 3.50,  addedAt: '', source: 'app'),
        ListItem(itemId: '6', canonicalName: 'sabao',      displayName: 'Sabão',      quantity: 1,  unit: 'cx',  price: 22.90, addedAt: '', source: 'alexa'),
      ],
    ),
  ];
});
