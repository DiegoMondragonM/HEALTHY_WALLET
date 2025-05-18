class Budget {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String category;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
  });
}