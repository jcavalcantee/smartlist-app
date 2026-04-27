String formatBRL(double value) {
  final str = value.toStringAsFixed(2);
  final parts = str.split('.');
  return 'R\$ ${parts[0]},${parts[1]}';
}

double? parseBRL(String text) {
  final normalized = text.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}
