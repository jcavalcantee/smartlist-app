const _ptMonths = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

String formatYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final month = int.parse(parts[1]);
  return '${_ptMonths[month - 1]} ${parts[0]}';
}

String currentYearMonth() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

String nextYearMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final next = DateTime(int.parse(parts[0]), int.parse(parts[1]) + 1);
  return '${next.year}-${next.month.toString().padLeft(2, '0')}';
}
