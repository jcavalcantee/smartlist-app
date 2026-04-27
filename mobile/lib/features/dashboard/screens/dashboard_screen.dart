import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/month_format.dart';
import '../../../core/utils/currency_format.dart';
import '../../monthly_list/providers/monthly_list_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(monthlyListNotifierProvider);
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

          // Card do mês atual
          listAsync.when(
            loading: () => const _MonthCardSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (list) => _CurrentMonthCard(
              month: formatYearMonth(list.yearMonth),
              itemCount: list.items.length,
              total: list.calculatedTotal,
              isOpen: list.isOpen,
              onTap: () => context.push('/list'),
            ),
          ),

          const SizedBox(height: 32),

          // Seção de análise
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.auto_graph_rounded,
                    size: 48, color: colorScheme.outline.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text(
                  'Futuros gráficos de gastos aqui',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
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
                    ?.copyWith(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver lista',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16, color: Colors.white.withOpacity(0.85)),
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
