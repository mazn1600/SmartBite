class Store {
  final String id;
  final String name;
  final String nameArabic;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final List<String> workingHours;
  final String imageUrl;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.workingHours,
    required this.imageUrl,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'workingHours': workingHours,
      'imageUrl': imageUrl,
      'rating': rating,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      nameArabic: json['nameArabic'],
      address: json['address'],
      city: json['city'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      phoneNumber: json['phoneNumber'],
      workingHours: List<String>.from(json['workingHours']),
      imageUrl: json['imageUrl'],
      rating: json['rating'].toDouble(),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class FoodPrice {
  final String id;
  final String foodId;
  final String storeId;
  final String storeName;
  final double price;
  final String currency;
  final String unit; // per kg, per piece, per pack
  final double quantity;
  final bool isOnSale;
  final double? salePrice;
  final DateTime? saleStartDate; // Added for Supabase alignment
  final DateTime? saleEndDate;
  final DateTime lastUpdated;
  final DateTime createdAt;

  FoodPrice({
    required this.id,
    required this.foodId,
    required this.storeId,
    required this.storeName,
    required this.price,
    required this.currency,
    required this.unit,
    required this.quantity,
    required this.isOnSale,
    this.salePrice,
    this.saleStartDate,
    this.saleEndDate,
    required this.lastUpdated,
    required this.createdAt,
  });

  double get effectivePrice => isOnSale ? (salePrice ?? price) : price;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'storeId': storeId,
      'storeName': storeName,
      'price': price,
      'currency': currency,
      'unit': unit,
      'quantity': quantity,
      'isOnSale': isOnSale,
      'salePrice': salePrice,
      'saleStartDate': saleStartDate?.toIso8601String(),
      'saleEndDate': saleEndDate?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodPrice.fromJson(Map<String, dynamic> json) {
    return FoodPrice(
      id: json['id'],
      foodId: json['foodId'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      unit: json['unit'],
      quantity: json['quantity'].toDouble(),
      isOnSale: json['isOnSale'] ?? json['is_on_sale'] ?? false,
      salePrice: json['salePrice']?.toDouble() ?? json['sale_price']?.toDouble(),
      saleStartDate: json['saleStartDate'] != null
          ? DateTime.parse(json['saleStartDate'])
          : json['sale_start_date'] != null
              ? DateTime.parse(json['sale_start_date'])
              : null,
      saleEndDate: json['saleEndDate'] != null
          ? DateTime.parse(json['saleEndDate'])
          : json['sale_end_date'] != null
              ? DateTime.parse(json['sale_end_date'])
              : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : json['last_updated'] != null
              ? DateTime.parse(json['last_updated'])
              : DateTime.now(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
