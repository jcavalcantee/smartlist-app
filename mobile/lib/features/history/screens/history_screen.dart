import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_format.dart';
import '../../../core/utils/month_format.dart';
import '../../monthly_list/models/list_item.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meses anteriores')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (months) => months.isEmpty
            ? const Center(child: Text('Nenhum histórico disponível.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: months.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _MonthCard(list: months[i]),
              ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final MonthlyList list;
  const _MonthCard({required this.list});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final diff = list.difference;
    final hasDiff = diff != null && diff.abs() > 0.001;
    final isOver = (diff ?? 0) > 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/history/${list.yearMonth}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.receipt_long_rounded,
                        color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatYearMonth(list.yearMonth),
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${list.items.length} itens',
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
              const SizedBox(height: 12),

              // Totais
              _TotalRow(
                label: 'Total calculado',
                value: formatBRL(list.calculatedTotal),
                textTheme: textTheme,
                colorScheme: colorScheme,
                valueWeight: FontWeight.w500,
              ),
              if (list.adjustedTotal != null) ...[
                const SizedBox(height: 6),
                _TotalRow(
                  label: 'Total real',
                  value: formatBRL(list.adjustedTotal!),
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                  valueWeight: FontWeight.w600,
                ),
              ],
              if (hasDiff) ...[
                const SizedBox(height: 10),
                _DiffChip(diff: diff!, isOver: isOver),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final FontWeight valueWeight;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
    required this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: valueWeight),
        ),
      ],
    );
  }
}

class _DiffChip extends StatelessWidget {
  final double diff;
  final bool isOver;

  const _DiffChip({required this.diff, required this.isOver});

  @override
  Widget build(BuildContext context) {
    final color = isOver ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    final bg = isOver ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    final sign = isOver ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOver ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Diferença',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            '$sign${formatBRL(diff)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
