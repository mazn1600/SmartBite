import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/store.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class PriceComparisonService extends ChangeNotifier {
  List<Store> _stores = [];
  List<FoodPrice> _foodPrices = [];
  bool _isLoading = false;
  String? _error;

  List<Store> get stores => _stores;
  List<FoodPrice> get foodPrices => _foodPrices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PriceComparisonService() {
    _initializeStores();
    _initializeFoodPrices();
  }

  void _initializeStores() {
    // Initialize with Saudi supermarkets
    _stores = [
      Store(
        id: '1',
        name: 'Othaim Markets',
        nameArabic: 'أسواق العثيم',
        address: 'King Fahd Road, Riyadh',
        city: 'Riyadh',
        latitude: 24.7136,
        longitude: 46.6753,
        phoneNumber: '+966 11 123 4567',
        workingHours: ['8:00 AM - 12:00 AM'],
        imageUrl: 'https://example.com/othaim.jpg',
        rating: 4.2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Store(
        id: '2',
        name: 'Panda Retail Company',
        nameArabic: 'شركة الباندا للتجزئة',
        address: 'Prince Mohammed bin Abdulaziz Road, Jeddah',
        city: 'Jeddah',
        latitude: 21.4858,
        longitude: 39.1925,
        phoneNumber: '+966 12 345 6789',
        workingHours: ['8:00 AM - 12:00 AM'],
        imageUrl: 'https://example.com/panda.jpg',
        rating: 4.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Store(
        id: '3',
        name: 'Lulu Hypermarket',
        nameArabic: 'لولو هايبرماركت',
        address: 'King Abdulaziz Road, Dammam',
        city: 'Dammam',
        latitude: 26.4207,
        longitude: 50.0888,
        phoneNumber: '+966 13 456 7890',
        workingHours: ['8:00 AM - 12:00 AM'],
        imageUrl: 'https://example.com/lulu.jpg',
        rating: 4.3,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Store(
        id: '4',
        name: 'Carrefour',
        nameArabic: 'كارفور',
        address: 'King Khalid Road, Riyadh',
        city: 'Riyadh',
        latitude: 24.7136,
        longitude: 46.6753,
        phoneNumber: '+966 11 234 5678',
        workingHours: ['8:00 AM - 12:00 AM'],
        imageUrl: 'https://example.com/carrefour.jpg',
        rating: 4.1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Store(
        id: '5',
        name: 'Danube',
        nameArabic: 'دانوب',
        address: 'Prince Sultan Road, Jeddah',
        city: 'Jeddah',
        latitude: 21.4858,
        longitude: 39.1925,
        phoneNumber: '+966 12 456 7890',
        workingHours: ['8:00 AM - 12:00 AM'],
        imageUrl: 'https://example.com/danube.jpg',
        rating: 4.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _initializeFoodPrices() {
    // Initialize with sample food prices
    _foodPrices = [
      // Chicken Breast prices
      FoodPrice(
        id: '1',
        foodId: '1',
        storeId: '1',
        storeName: 'Othaim Markets',
        price: 25.50,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: false,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      FoodPrice(
        id: '2',
        foodId: '1',
        storeId: '2',
        storeName: 'Panda Retail Company',
        price: 24.90,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: true,
        salePrice: 22.90,
        saleEndDate: DateTime.now().add(const Duration(days: 7)),
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      FoodPrice(
        id: '3',
        foodId: '1',
        storeId: '3',
        storeName: 'Lulu Hypermarket',
        price: 26.00,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: false,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),

      // Salmon prices
      FoodPrice(
        id: '4',
        foodId: '2',
        storeId: '1',
        storeName: 'Othaim Markets',
        price: 45.00,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: false,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      FoodPrice(
        id: '5',
        foodId: '2',
        storeId: '2',
        storeName: 'Panda Retail Company',
        price: 47.50,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: false,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),

      // Brown Rice prices
      FoodPrice(
        id: '6',
        foodId: '3',
        storeId: '1',
        storeName: 'Othaim Markets',
        price: 8.50,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: false,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      FoodPrice(
        id: '7',
        foodId: '3',
        storeId: '3',
        storeName: 'Lulu Hypermarket',
        price: 7.90,
        currency: AppConstants.currency,
        unit: 'per kg',
        quantity: 1000,
        isOnSale: true,
        salePrice: 6.90,
        saleEndDate: DateTime.now().add(const Duration(days: 5)),
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Find cheapest prices for a specific food with Result pattern
  Result<List<FoodPrice>> findCheapestPrices(String foodId) {
    try {
      if (foodId.isEmpty) {
        return Result.error('Food ID cannot be empty');
      }

      List<FoodPrice> foodPrices =
          _foodPrices.where((price) => price.foodId == foodId).toList();

      if (foodPrices.isEmpty) {
        return Result.error('No prices found for this food item');
      }

      // Sort by effective price (considering sales)
      foodPrices.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));

      return Result.success(foodPrices);
    } catch (e) {
      return Result.error('Error finding cheapest prices: ${e.toString()}');
    }
  }

  // Find cheapest store for a list of foods with Result pattern
  Result<Map<String, dynamic>> findCheapestStoreForMeal(List<String> foodIds) {
    try {
      if (foodIds.isEmpty) {
        return Result.error('Food IDs list cannot be empty');
      }

      Map<String, double> storeTotalCosts = {};
      Map<String, List<FoodPrice>> storeFoodPrices = {};

      // Calculate total cost for each store
      for (String foodId in foodIds) {
        List<FoodPrice> prices =
            _foodPrices.where((price) => price.foodId == foodId).toList();

        for (FoodPrice price in prices) {
          if (!storeTotalCosts.containsKey(price.storeId)) {
            storeTotalCosts[price.storeId] = 0.0;
            storeFoodPrices[price.storeId] = [];
          }

          storeTotalCosts[price.storeId] =
              storeTotalCosts[price.storeId]! + price.effectivePrice;
          storeFoodPrices[price.storeId]!.add(price);
        }
      }

      if (storeTotalCosts.isEmpty) {
        return Result.error('No prices found for any of the food items');
      }

      // Find cheapest store
      String? cheapestStoreId;
      double minCost = double.infinity;

      storeTotalCosts.forEach((storeId, cost) {
        if (cost < minCost) {
          minCost = cost;
          cheapestStoreId = storeId;
        }
      });

      if (cheapestStoreId == null) {
        return Result.error('Unable to determine cheapest store');
      }

      // Calculate savings compared to most expensive store
      double maxCost = storeTotalCosts.values.reduce((a, b) => a > b ? a : b);
      double savings = maxCost - minCost;

      return Result.success({
        'store': _stores.firstWhere((store) => store.id == cheapestStoreId),
        'totalCost': minCost,
        'foodPrices': storeFoodPrices[cheapestStoreId]!,
        'savings': savings,
      });
    } catch (e) {
      return Result.error('Error finding cheapest store: ${e.toString()}');
    }
  }

  // Find stores near user location with Result pattern
  Result<List<Store>> findNearbyStores(
      double userLatitude, double userLongitude, double radiusKm) {
    try {
      if (radiusKm <= 0) {
        return Result.error('Radius must be greater than 0');
      }

      if (userLatitude < -90 || userLatitude > 90) {
        return Result.error('Invalid latitude value');
      }

      if (userLongitude < -180 || userLongitude > 180) {
        return Result.error('Invalid longitude value');
      }

      List<Store> nearbyStores = [];

      for (Store store in _stores) {
        double distance = _calculateDistance(
          userLatitude,
          userLongitude,
          store.latitude,
          store.longitude,
        );

        if (distance <= radiusKm) {
          nearbyStores.add(store);
        }
      }

      // Sort by distance
      nearbyStores.sort((a, b) {
        double distanceA = _calculateDistance(
            userLatitude, userLongitude, a.latitude, a.longitude);
        double distanceB = _calculateDistance(
            userLatitude, userLongitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });

      return Result.success(nearbyStores);
    } catch (e) {
      return Result.error('Error finding nearby stores: ${e.toString()}');
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get price comparison for multiple foods
  Map<String, List<FoodPrice>> getPriceComparison(List<String> foodIds) {
    Map<String, List<FoodPrice>> comparison = {};

    for (String foodId in foodIds) {
      final result = findCheapestPrices(foodId);
      if (result.isSuccess && result.data != null) {
        comparison[foodId] = result.data!;
      } else {
        comparison[foodId] = [];
      }
    }

    return comparison;
  }

  // Get stores by city
  List<Store> getStoresByCity(String city) {
    return _stores
        .where((store) => store.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  // Get all cities with stores
  List<String> getAvailableCities() {
    return _stores.map((store) => store.city).toSet().toList();
  }

  // Add new store
  void addStore(Store store) {
    _stores.add(store);
    notifyListeners();
  }

  // Update store information
  void updateStore(Store updatedStore) {
    int index = _stores.indexWhere((store) => store.id == updatedStore.id);
    if (index != -1) {
      _stores[index] = updatedStore;
      notifyListeners();
    }
  }

  // Add new food price
  void addFoodPrice(FoodPrice foodPrice) {
    _foodPrices.add(foodPrice);
    notifyListeners();
  }

  // Update food price
  void updateFoodPrice(FoodPrice updatedPrice) {
    int index = _foodPrices.indexWhere((price) => price.id == updatedPrice.id);
    if (index != -1) {
      _foodPrices[index] = updatedPrice;
      notifyListeners();
    }
  }

  // Get price history for a food item
  List<FoodPrice> getPriceHistory(String foodId, String storeId) {
    return _foodPrices
        .where((price) => price.foodId == foodId && price.storeId == storeId)
        .toList();
  }

  // Find best deals (items on sale)
  List<FoodPrice> findBestDeals() {
    List<FoodPrice> deals =
        _foodPrices.where((price) => price.isOnSale).toList();

    // Sort by discount percentage
    deals.sort((a, b) {
      double discountA = ((a.price - a.salePrice!) / a.price) * 100;
      double discountB = ((b.price - b.salePrice!) / b.price) * 100;
      return discountB.compareTo(discountA);
    });

    return deals;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
