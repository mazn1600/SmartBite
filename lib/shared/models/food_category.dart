/// Food Category model
///
/// Represents a category of foods (e.g., proteins, vegetables, fruits)
class FoodCategory {
  final String id;
  final String name;
  final String? nameArabic;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodCategory({
    required this.id,
    required this.name,
    this.nameArabic,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_arabic': nameArabic,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: json['id'] ?? json['id'],
      name: json['name'] ?? '',
      nameArabic: json['name_arabic'] ?? json['nameArabic'],
      description: json['description'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  factory FoodCategory.fromMap(Map<String, dynamic> map) {
    return FoodCategory.fromJson(map);
  }

  FoodCategory copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

