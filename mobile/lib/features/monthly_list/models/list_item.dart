class ListItem {
  final String itemId;
  final String canonicalName;
  final String displayName;
  final double quantity;
  final String unit;
  final double? price;
  final String addedAt;
  final String source;

  const ListItem({
    required this.itemId,
    required this.canonicalName,
    required this.displayName,
    required this.quantity,
    required this.unit,
    this.price,
    required this.addedAt,
    required this.source,
  });

  double get subtotal => quantity * (price ?? 0);

  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        itemId: json['itemId'] as String,
        canonicalName: json['canonicalName'] as String,
        displayName: json['displayName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        price: (json['price'] as num?)?.toDouble(),
        addedAt: json['addedAt'] as String,
        source: json['source'] as String,
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'canonicalName': canonicalName,
        'displayName': displayName,
        'quantity': quantity,
        'unit': unit,
        if (price != null) 'price': price,
        'addedAt': addedAt,
        'source': source,
      };

  ListItem copyWith({double? quantity, double? price}) => ListItem(
        itemId: itemId,
        canonicalName: canonicalName,
        displayName: displayName,
        quantity: quantity ?? this.quantity,
        unit: unit,
        price: price ?? this.price,
        addedAt: addedAt,
        source: source,
      );
}

class MonthlyList {
  final String yearMonth;
  final String status;
  final List<ListItem> items;
  final String updatedAt;
  final double? adjustedTotal;

  const MonthlyList({
    required this.yearMonth,
    required this.status,
    required this.items,
    required this.updatedAt,
    this.adjustedTotal,
  });

  bool get isOpen => status == 'OPEN';

  double get calculatedTotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double? get difference =>
      adjustedTotal != null ? adjustedTotal! - calculatedTotal : null;

  factory MonthlyList.fromJson(Map<String, dynamic> json) => MonthlyList(
        yearMonth: json['yearMonth'] as String,
        status: json['status'] as String,
        items: (json['items'] as List)
            .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        updatedAt: json['updatedAt'] as String,
        adjustedTotal: (json['adjustedTotal'] as num?)?.toDouble(),
      );
}
