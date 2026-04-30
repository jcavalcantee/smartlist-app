import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/currency_format.dart';
import '../../../core/utils/month_format.dart';
import '../models/list_item.dart';
import '../providers/monthly_list_provider.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/calculator_panel.dart';
import '../widgets/list_item_tile.dart';

class MonthlyListScreen extends ConsumerStatefulWidget {
  final String yearMonth;
  const MonthlyListScreen({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyListScreen> createState() => _MonthlyListScreenState();
}

class _MonthlyListScreenState extends ConsumerState<MonthlyListScreen>
    with SingleTickerProviderStateMixin {
  bool _calculatorOpen = false;
  bool _isSearching = false;
  final _searchController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCalculator() {
    setState(() {
      _calculatorOpen = !_calculatorOpen;
      if (_calculatorOpen) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(monthlyListNotifierProvider(widget.yearMonth));
    final panelWidth = MediaQuery.of(context).size.width * 0.78;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_isSearching
              ? Icons.arrow_back_rounded
              : Icons.arrow_back_rounded),
          onPressed: _isSearching ? _toggleSearch : () => context.go('/home'),
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
            : (listAsync.whenOrNull(
                    data: (l) => Text(formatYearMonth(l.yearMonth))) ??
                const Text('Lista')),
        actions: [
          IconButton(
            icon: Icon(
                _isSearching ? Icons.close : Icons.search_rounded),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.calculate_outlined),
              tooltip: 'Calculadora',
              onPressed: _toggleCalculator,
            ),
          if (!_isSearching)
            listAsync.whenOrNull(
                  data: (list) => list.isOpen
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilledButton.icon(
                            onPressed: () => _confirmClose(context, list),
                            icon: const Icon(Icons.lock_outline_rounded,
                                size: 16),
                            label: const Text('Fechar compra'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB71C1C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 0),
                              minimumSize: const Size(0, 36),
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        )
                      : null,
                ) ??
                const SizedBox.shrink(),
        ],
      ),
      body: Stack(
        children: [
          listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (list) => _buildBody(context, list),
          ),
          AnimatedOpacity(
            opacity: _calculatorOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_calculatorOpen,
              child: GestureDetector(
                onTap: _toggleCalculator,
                child: Container(color: Colors.black54),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: SlideTransition(
              position: _slideAnimation,
              child: CalculatorPanel(onClose: _toggleCalculator),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, MonthlyList list) {
    final query = _searchController.text.toLowerCase().trim();
    final items = query.isEmpty
        ? list.sortedItems
        : list.sortedItems
            .where((i) => i.displayName.toLowerCase().contains(query))
            .toList();

    return Column(
      children: [
        if (!list.isOpen)
          MaterialBanner(
            content: const Text('Esta lista foi fechada e não pode ser editada.'),
            backgroundColor: Colors.orange.shade50,
            actions: [const SizedBox.shrink()],
          ),
        Expanded(
          child: list.items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Nenhum item ainda.\nAdicione o primeiro!',
                          textAlign: TextAlign.center),
                    ],
                  ),
                )
              : items.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum item encontrado para "$query".',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: items.length,
                      itemBuilder: (context, i) => ListItemTile(
                        item: items[i],
                        onDelete: list.isOpen
                            ? () => ref
                                .read(monthlyListNotifierProvider(
                                        widget.yearMonth)
                                    .notifier)
                                .removeItem(items[i].itemId)
                            : null,
                      ),
                    ),
        ),
        if (list.isOpen)
          InkWell(
            onTap: () => _showAddSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar item',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        _TotalPanel(list: list, ref: ref, yearMonth: widget.yearMonth),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddItemSheet(
        onAdd: (name, qty, unit, price) => ref
            .read(monthlyListNotifierProvider(widget.yearMonth).notifier)
            .addItem(name, qty, unit, price),
      ),
    );
  }

  Future<void> _confirmClose(BuildContext context, MonthlyList list) async {
    final controller = TextEditingController(
      text: list.adjustedTotal?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => _CloseDialog(
        calculatedTotal: list.calculatedTotal,
        controller: controller,
      ),
    );
    if (result != null) {
      await ref
          .read(monthlyListNotifierProvider(widget.yearMonth).notifier)
          .closePurchase(adjustedTotal: result);
    }
  }
}

class _CloseDialog extends StatefulWidget {
  final double calculatedTotal;
  final TextEditingController controller;

  const _CloseDialog({
    required this.calculatedTotal,
    required this.controller,
  });

  @override
  State<_CloseDialog> createState() => _CloseDialogState();
}

class _CloseDialogState extends State<_CloseDialog> {
  String? _error;

  void _submit() {
    final v = parseBRL(widget.controller.text);
    if (v == null || v <= 0) {
      setState(() => _error = 'Informe o valor pago no caixa');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fechar compra'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total calculado: ${formatBRL(widget.calculatedTotal)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Total pago no caixa (R\$)',
              hintText: '0,00',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
          Text(
            'Este valor será usado nas análises de gasto.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
          child: const Text('Fechar compra'),
        ),
      ],
    );
  }
}

class _TotalPanel extends StatelessWidget {
  final MonthlyList list;
  final WidgetRef ref;
  final String yearMonth;

  const _TotalPanel({required this.list, required this.ref, required this.yearMonth});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final diff = list.difference;
    final hasDiff = diff != null && diff.abs() > 0.001;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row(
            label: 'Total calculado',
            value: formatBRL(list.calculatedTotal),
            labelStyle: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            valueStyle: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (list.adjustedTotal != null) ...[
            const SizedBox(height: 8),
            _Row(
              label: 'Total real',
              value: formatBRL(list.adjustedTotal!),
              labelStyle: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              valueStyle: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              trailing: list.isOpen
                  ? GestureDetector(
                      onTap: () => _editAdjusted(context),
                      child: Icon(Icons.edit_outlined,
                          size: 16, color: colorScheme.primary),
                    )
                  : null,
            ),
            if (hasDiff) ...[
              const SizedBox(height: 6),
              Divider(color: colorScheme.outline.withOpacity(0.3), height: 1),
              const SizedBox(height: 6),
              _DifferenceRow(diff: diff!),
            ],
          ],
          if (list.isOpen && list.adjustedTotal == null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _editAdjusted(context),
              icon: const Icon(Icons.receipt_outlined, size: 18),
              label: const Text('Informar total real'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editAdjusted(BuildContext context) async {
    final controller = TextEditingController(
      text: list.adjustedTotal?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Total real da compra'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Valor (R\$)',
            hintText: '0,00',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final v = parseBRL(controller.text);
              if (v != null) Navigator.pop(ctx, v);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(monthlyListNotifierProvider(yearMonth).notifier)
          .setAdjustedTotal(result);
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? trailing;

  const _Row({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

class _DifferenceRow extends StatelessWidget {
  final double diff;
  const _DifferenceRow({required this.diff});

  @override
  Widget build(BuildContext context) {
    final isOver = diff > 0;
    final color = isOver ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    final bg = isOver ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    final sign = isOver ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOver ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Diferença',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$sign${formatBRL(diff)}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
