class Portfolio {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final DateTime createdAt;

  const Portfolio({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
