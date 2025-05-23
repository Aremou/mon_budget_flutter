class Budget {
  final int? id;
  final String period;
  final double amount;
  final int categoryId;
  Budget({
    this.id,
    required this.period,
    required this.amount,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'period': period,
        'amount': amount,
        'categoryId': categoryId,
      };

  static Budget fromMap(Map<String, dynamic> map) => Budget(
        id: map['id'],
        period: map['period'],
        amount: map['amount'],
        categoryId: map['categoryId'],
      );

  @override
  String toString() =>
      'Budget(id: $id, period: $period, amount: $amount, categoryId: $categoryId)';
}
