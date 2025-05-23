class Revenue {
  final int? id;
  final String date;
  final double amount;
  final String label;
  final String? note;
  Revenue({
    this.id,
    required this.date,
    required this.amount,
    required this.label,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'amount': amount,
        'label': label,
        'note': note,
      };

  static Revenue fromMap(Map<String, dynamic> map) => Revenue(
        id: map['id'],
        date: map['date'],
        amount: map['amount'],
        label: map['label'],
        note: map['note'],
      );

  @override
  String toString() =>
      'Revenue(id: $id, date: $date, amount: $amount, label: $label, note: $note)';
}
