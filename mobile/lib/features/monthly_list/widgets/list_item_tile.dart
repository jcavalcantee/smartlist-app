import 'package:flutter/material.dart';

import '../../../core/utils/currency_format.dart';
import '../models/list_item.dart';

class ListItemTile extends StatelessWidget {
  final ListItem item;
  final VoidCallback? onDelete;

  const ListItemTile({super.key, required this.item, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPrice = item.price != null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        child: Text(
          item.displayName[0].toUpperCase(),
          style: TextStyle(
              color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(item.displayName,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(
        [
          '${_formatQty(item.quantity)} ${item.unit}',
          if (hasPrice) '${formatBRL(item.price!)}/un',
        ].join(' · '),
        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          hasPrice
              ? Text(
                  formatBRL(item.subtotal),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                )
              : Text(
                  '—',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              iconSize: 20,
              color: Colors.red.shade400,
              visualDensity: VisualDensity.compact,
              tooltip: 'Excluir item',
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }

  String _formatQty(double qty) =>
      qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();
}
