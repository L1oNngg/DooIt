class Board {
  final String id;
  final String name;
  final String description;
  final bool isDefault;

  Board({
    required this.id,
    required this.name,
    required this.description,
    required this.isDefault,
  });

  factory Board.fromMap(Map<String, dynamic> map, String id) {
    return Board(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isDefault': isDefault,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
