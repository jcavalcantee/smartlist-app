import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/month_format.dart';
import '../../monthly_list/widgets/list_item_tile.dart';
import '../providers/history_provider.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final String yearMonth;
  const HistoryDetailScreen({super.key, required this.yearMonth});

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return historyAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (months) {
        final list =
            months.where((m) => m.yearMonth == widget.yearMonth).firstOrNull;

        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: Text(formatYearMonth(widget.yearMonth))),
            body: const Center(child: Text('Lista não encontrada.')),
          );
        }

        final query = _searchController.text.toLowerCase().trim();
        final items = query.isEmpty
            ? list.items
            : list.items
                .where((i) =>
                    i.displayName.toLowerCase().contains(query))
                .toList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed:
                  _isSearching ? _toggleSearch : () => Navigator.pop(context),
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar item...',
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Text(formatYearMonth(widget.yearMonth)),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
                onPressed: _toggleSearch,
              ),
              if (!_isSearching)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Fechada',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
          body: items.isEmpty
              ? Center(
                  child: Text(
                    query.isEmpty
                        ? 'Nenhum item.'
                        : 'Nenhum item encontrado para "$query".',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) => IgnorePointer(
                    child: ListItemTile(item: items[i]),
                  ),
                ),
        );
      },
    );
  }
}
