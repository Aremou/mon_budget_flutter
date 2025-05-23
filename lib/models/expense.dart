class Expense {
  final int? id;
  final String date;
  final int categoryId;
  final double amount;
  final String label;
  final String? note;
  Expense({
    this.id,
    required this.date,
    required this.categoryId,
    required this.amount,
    required this.label,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'categoryId': categoryId,
        'amount': amount,
        'label': label,
        'note': note,
      };

  static Expense fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        date: map['date'],
        categoryId: map['categoryId'],
        amount: map['amount'],
        label: map['label'],
        note: map['note'],
      );

  @override
  String toString() =>
      'Expense(id: $id, date: $date, categoryId: $categoryId, amount: $amount, label: $label, note: $note)';
}
