import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_format.dart';
import '../providers/known_items_provider.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  final Future<void> Function(String name, double quantity, String unit, double? price) onAdd;

  const AddItemSheet({super.key, required this.onAdd});

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _unit = 'un';
  bool _loading = false;
  List<ItemSuggestion> _filtered = [];

  static const _units = ['un', 'kg', 'g', 'l', 'ml', 'pack'];

  void _onNameChanged(String value) {
    final suggestions = ref.read(knownItemsProvider);
    final query = value.toLowerCase().trim();
    setState(() {
      _filtered = query.isEmpty
          ? []
          : suggestions
              .where((s) => s.displayName.toLowerCase().contains(query))
              .take(5)
              .toList();
    });
  }

  void _selectSuggestion(ItemSuggestion s) {
    _nameController.text = s.displayName;
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: s.displayName.length),
    );
    setState(() {
      _unit = s.unit == 'unit' ? 'un' : s.unit;
      _filtered = [];
      if (s.lastPrice != null) {
        _priceController.text =
            s.lastPrice!.toStringAsFixed(2).replaceAll('.', ',');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Adicionar item', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // ── Nome com sugestões ────────────────────────────────────────────
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: _onNameChanged,
            decoration: const InputDecoration(
              labelText: 'Nome do item',
              border: OutlineInputBorder(),
            ),
          ),

          if (_filtered.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final s = _filtered[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded, size: 18),
                    title: Text(s.displayName),
                    trailing: s.lastPrice != null
                        ? Text(
                            formatBRL(s.lastPrice!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          )
                        : null,
                    onTap: () => _selectSuggestion(s),
                  );
                },
              ),
            ),

          const SizedBox(height: 12),

          // ── Qtd / Unidade / Preço ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _qtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Qtd',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: const InputDecoration(
                    labelText: 'Unidade',
                    border: OutlineInputBorder(),
                  ),
                  items: _units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Preço (R\$)',
                    border: OutlineInputBorder(),
                    hintText: '0,00',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qtyController.text) ?? 1;
    final price = parseBRL(_priceController.text);
    setState(() => _loading = true);
    await widget.onAdd(name, qty, _unit, price);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
