class Category {
  final int? id;
  final String name;

  Category({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  static Category fromMap(Map<String, dynamic> map) => Category(
        id: map['id'],
        name: map['name'],
      );
  @override
  String toString() => 'Category(id: $id, name: $name)';
}
