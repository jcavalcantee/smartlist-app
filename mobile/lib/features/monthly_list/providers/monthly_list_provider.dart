import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../history/providers/history_provider.dart';
import '../models/list_item.dart';

final monthlyListNotifierProvider =
    AsyncNotifierProviderFamily<MonthlyListNotifier, MonthlyList, String>(
  MonthlyListNotifier.new,
);

class MonthlyListNotifier extends FamilyAsyncNotifier<MonthlyList, String> {
  @override
  Future<MonthlyList> build(String yearMonth) async {
    final client = ref.read(apiClientProvider);
    final response = await client.get('/list/$yearMonth');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MonthlyList.fromJson(data);
    }

    if (response.statusCode == 404) {
      return MonthlyList(
        yearMonth: yearMonth,
        status: 'OPEN',
        updatedAt: DateTime.now().toIso8601String(),
        items: [],
      );
    }

    throw Exception('Erro ao carregar lista (${response.statusCode})');
  }

  Future<void> addItem(
    String displayName,
    double quantity,
    String unit,
    double? price,
  ) async {
    final client = ref.read(apiClientProvider);
    final response = await client.post('/items', body: {
      'displayName': displayName,
      'quantity': quantity,
      'unit': unit,
      if (price != null) 'price': price,
      'source': 'app',
      'yearMonth': arg,
    });

    if (response.statusCode != 201) {
      throw Exception('Erro ao adicionar item (${response.statusCode})');
    }

    ref.invalidateSelf();
  }

  Future<void> removeItem(String itemId) async {
    final client = ref.read(apiClientProvider);
    final response =
        await client.delete('/items/$itemId?yearMonth=${Uri.encodeComponent(arg)}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover item (${response.statusCode})');
    }

    ref.invalidateSelf();
  }

  Future<void> closePurchase({double? adjustedTotal}) async {
    final client = ref.read(apiClientProvider);
    final response = await client.post(
      '/list/$arg/close',
      body: adjustedTotal != null ? {'adjustedTotal': adjustedTotal} : {},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao fechar compra (${response.statusCode})');
    }

    ref.invalidateSelf();
    ref.invalidate(historyProvider);
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
}
