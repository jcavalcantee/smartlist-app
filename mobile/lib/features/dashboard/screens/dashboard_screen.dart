import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_format.dart';
import '../../../core/utils/month_format.dart';
import '../../history/providers/history_provider.dart';
import '../../monthly_list/models/list_item.dart';
import '../../monthly_list/providers/monthly_list_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(monthlyListNotifierProvider(currentYearMonth()));
    final historyAsync = ref.watch(historyProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartList',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Meses anteriores',
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Olá 👋',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Acompanhe suas compras do mês.',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          listAsync.when(
            loading: () => const _MonthCardSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => Column(
              children: [
                _CurrentMonthCard(
                  month: formatYearMonth(list.yearMonth),
                  itemCount: list.items.length,
                  total: list.adjustedTotal ?? list.calculatedTotal,
                  isOpen: list.isOpen,
                  onTap: () => context.push('/list/${list.yearMonth}'),
                ),
                const SizedBox(height: 8),
                if (!list.isOpen)
                  _StartNextMonthCard(
                    nextMonth: nextYearMonth(list.yearMonth),
                  ),
                _PastMonthButton(currentYearMonth: list.yearMonth),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Análise de gastos',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          historyAsync.when(
            loading: () => const _AnalysisSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (history) {
              if (history.isEmpty) return const _AnalysisEmpty();
              return Column(
                children: [
                  _SpendingCard(history: history),
                  const SizedBox(height: 12),
                  _TopProductsCard(history: history),
                  const SizedBox(height: 12),
                  _PriceVariationCard(history: history),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Start next month ─────────────────────────────────────────────────────────

class _StartNextMonthCard extends StatelessWidget {
  final String nextMonth;
  const _StartNextMonthCard({required this.nextMonth});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/list/$nextMonth'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciar compra de ${formatYearMonth(nextMonth)}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      'Comece a lista do próximo mês',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Past month button ─────────────────────────────────────────────────────────

class _PastMonthButton extends StatelessWidget {
  final String currentYearMonth;
  const _PastMonthButton({required this.currentYearMonth});

  List<String> _pastMonths() {
    final parts = currentYearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return List.generate(12, (i) {
      final d = DateTime(year, month - 1 - i);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showPicker(context),
      icon: const Icon(Icons.add_circle_outline, size: 16),
      label: const Text('Registrar compra de mês anterior'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final months = _pastMonths();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Selecione o mês',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...months.map((ym) => ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: Text(formatYearMonth(ym)),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/list/$ym');
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Spending chart + KPI ──────────────────────────────────────────────────────

class _SpendingCard extends StatelessWidget {
  final List<MonthlyList> history;
  const _SpendingCard({required this.history});

  double _monthTotal(MonthlyList m) => m.adjustedTotal ?? m.calculatedTotal;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sorted = [...history]
      ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));

    final totals = sorted.map(_monthTotal).toList();
    final average = totals.reduce((a, b) => a + b) / totals.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.trending_up_rounded,
                    size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor médio por compra',
                    style: textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    formatBRL(average),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: colorScheme.outline.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 20),

          Text(
            'Últimas compras',
            style: textTheme.labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          _BarChart(months: sorted, totals: totals),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<MonthlyList> months;
  final List<double> totals;

  const _BarChart({required this.months, required this.totals});

  static const _shortMonths = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  String _label(String yearMonth) {
    final m = int.tryParse(yearMonth.split('-')[1]) ?? 1;
    return _shortMonths[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxVal = totals.reduce(max);
    const maxBarH = 100.0;

    return SizedBox(
      height: maxBarH + 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (i) {
          final barH = maxVal > 0 ? (totals[i] / maxVal) * maxBarH : 4.0;
          final isMax = totals[i] == maxVal;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatBRL(totals[i]),
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isMax
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: barH,
                    decoration: BoxDecoration(
                      color: isMax
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _label(months[i].yearMonth),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Top 5 products ────────────────────────────────────────────────────────────

class _TopProductsCard extends StatelessWidget {
  final List<MonthlyList> history;
  const _TopProductsCard({required this.history});

  List<ListItem> _top5() {
    final Map<String, ListItem> best = {};
    for (final month in history) {
      for (final item in month.items) {
        final existing = best[item.canonicalName];
        if (existing == null || item.subtotal > existing.subtotal) {
          best[item.canonicalName] = item;
        }
      }
    }
    final sorted = best.values.toList()
      ..sort((a, b) => b.subtotal.compareTo(a.subtotal));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = _top5();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: 18, color: Color(0xFFE65100)),
              ),
              const SizedBox(width: 12),
              Text(
                '5 produtos mais caros',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final isFirst = rank == 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$rank°',
                      style: textTheme.labelMedium?.copyWith(
                        color: isFirst
                            ? const Color(0xFFE65100)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.displayName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isFirst ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formatBRL(item.subtotal),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isFirst
                          ? const Color(0xFFE65100)
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Price variation ───────────────────────────────────────────────────────────

class _VarItem {
  final String displayName;
  final double minPrice;
  final double maxPrice;
  double get variation => maxPrice - minPrice;

  const _VarItem({
    required this.displayName,
    required this.minPrice,
    required this.maxPrice,
  });
}

class _PriceVariationCard extends StatelessWidget {
  final List<MonthlyList> history;
  const _PriceVariationCard({required this.history});

  List<_VarItem> _top5() {
    final sorted = [...history]
      ..sort((a, b) => b.yearMonth.compareTo(a.yearMonth));
    final recent = sorted.take(3).toList();

    final Map<String, String> names = {};
    final Map<String, List<double>> prices = {};

    for (final month in recent) {
      for (final item in month.items) {
        if (item.price != null && item.price! > 0) {
          names.putIfAbsent(item.canonicalName, () => item.displayName);
          prices.putIfAbsent(item.canonicalName, () => []).add(item.price!);
        }
      }
    }

    final items = <_VarItem>[];
    for (final key in prices.keys) {
      final ps = prices[key]!;
      if (ps.length >= 2) {
        items.add(_VarItem(
          displayName: names[key]!,
          minPrice: ps.reduce(min),
          maxPrice: ps.reduce(max),
        ));
      }
    }

    items.sort((a, b) => b.variation.compareTo(a.variation));
    return items.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = _top5();

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    size: 18, color: Color(0xFF1565C0)),
              ),
              const SizedBox(width: 12),
              Text(
                'Variação de preço',
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Text(
                '(últimos 3 meses)',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final pct = item.minPrice > 0
                ? ((item.variation / item.minPrice) * 100).round()
                : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '$rank°',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.displayName,
                      style: textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatBRL(item.minPrice),
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 12, color: Colors.grey),
                          Text(
                            formatBRL(item.maxPrice),
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFB71C1C),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+${formatBRL(item.variation)} ($pct%)',
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFE65100),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Estados auxiliares ────────────────────────────────────────────────────────

class _AnalysisSkeleton extends StatelessWidget {
  const _AnalysisSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _AnalysisEmpty extends StatelessWidget {
  const _AnalysisEmpty();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_graph_rounded,
              size: 48, color: colorScheme.outline.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'Nenhuma compra fechada ainda.\nOs gráficos aparecerão aqui.',
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Widgets existentes (sem alteração) ────────────────────────────────────────

class _CurrentMonthCard extends StatelessWidget {
  final String month;
  final int itemCount;
  final double total;
  final bool isOpen;
  final VoidCallback onTap;

  const _CurrentMonthCard({
    required this.month,
    required this.itemCount,
    required this.total,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    month,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOpen ? 'Aberta' : 'Fechada',
                      style: textTheme.labelSmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                formatBRL(total),
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'itens'}',
                style: textTheme.bodySmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver lista',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16, color: Colors.white.withValues(alpha: 0.85)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCardSkeleton extends StatelessWidget {
  const _MonthCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
