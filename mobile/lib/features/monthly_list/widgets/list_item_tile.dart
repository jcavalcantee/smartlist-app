import 'package:flutter/material.dart';

import '../../../core/utils/currency_format.dart';
import '../models/list_item.dart';

class ListItemTile extends StatelessWidget {
  final ListItem item;

  const ListItemTile({super.key, required this.item});

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
          item.source == 'alexa' ? 'Alexa' : 'App',
        ].join(' · '),
        style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
      ),
      trailing: hasPrice
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
    );
  }

  String _formatQty(double qty) =>
      qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();
}
