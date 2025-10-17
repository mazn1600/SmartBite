import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';

  static Future<Map<String, dynamic>?> fetchProductByBarcode(
      String barcode) async {
    final uri = Uri.parse('$_baseUrl/$barcode.json');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['status'] != 1) return null; // 1 means found
    return data['product'] as Map<String, dynamic>;
  }

  static Map<String, dynamic> parseNutrition(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return {
      'name': product['product_name'] ?? product['brands'] ?? 'Unknown',
      'imageUrl': product['image_front_url'] ?? product['image_url'] ?? '',
      'caloriesPer100g': toDouble(nutriments['energy-kcal_100g']),
      'proteinPer100g': toDouble(nutriments['proteins_100g']),
      'carbsPer100g': toDouble(nutriments['carbohydrates_100g']),
      'fatPer100g': toDouble(nutriments['fat_100g']),
      'servingSize': product['serving_quantity']?.toString() ?? '100',
      'brands': product['brands'] ?? '',
    };
  }
}
