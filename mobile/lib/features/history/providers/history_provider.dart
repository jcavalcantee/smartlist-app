import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../monthly_list/models/list_item.dart';

final historyProvider = FutureProvider<List<MonthlyList>>((ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/history');

  if (response.statusCode != 200) return [];

  final items = jsonDecode(response.body) as List<dynamic>;
  return items.map((e) {
    final m = e as Map<String, dynamic>;
    return MonthlyList(
      yearMonth: m['yearMonth'] as String,
      status: 'CLOSED',
      updatedAt: m['closedAt'] as String,
      adjustedTotal: (m['adjustedTotal'] as num?)?.toDouble(),
      items: (m['items'] as List<dynamic>)
          .map((i) => ListItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }).toList();
});
