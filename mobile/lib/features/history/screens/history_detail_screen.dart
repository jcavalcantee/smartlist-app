import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/month_format.dart';
import '../../monthly_list/widgets/list_item_tile.dart';
import '../providers/history_provider.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final String yearMonth;
  const HistoryDetailScreen({super.key, required this.yearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return historyAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (months) {
        final list = months.where((m) => m.yearMonth == yearMonth).firstOrNull;
        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: Text(formatYearMonth(yearMonth))),
            body: const Center(child: Text('Lista não encontrada.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(formatYearMonth(yearMonth)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Fechada',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: list.items.length,
            itemBuilder: (context, i) => IgnorePointer(
              child: ListItemTile(item: list.items[i]),
            ),
          ),
        );
      },
    );
  }
}
