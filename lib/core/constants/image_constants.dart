/// Image Constants
///
/// Centralized constants for all asset image paths in the app.
/// Provides easy access to food images, store logos, meal type images, and placeholders.
class ImageConstants {
  // ========== Base Asset Path ==========
  static const String _basePath = 'assets/images';

  // ========== Food Images ==========
  static const String chicken = '$_basePath/foods/chicken.jpg';
  static const String salmon = '$_basePath/foods/salmon.jpg';
  static const String brownRice = '$_basePath/foods/brown_rice.jpg';
  static const String broccoli = '$_basePath/foods/broccoli.jpg';
  static const String apple = '$_basePath/foods/apple.jpg';
  static const String grilledChicken = '$_basePath/foods/grilled_chicken.jpg';
  static const String mediterraneanQuinoa =
      '$_basePath/foods/mediterranean_quinoa.jpg';
  static const String salad = '$_basePath/foods/salad.jpg';
  static const String oatmeal = '$_basePath/foods/oatmeal.jpg';
  static const String yogurt = '$_basePath/foods/yogurt.jpg';

  // ========== Store Logos ==========
  static const String othaim = '$_basePath/stores/othaim.jpg';
  static const String panda = '$_basePath/stores/panda.jpg';
  static const String lulu = '$_basePath/stores/lulu.jpg';
  static const String carrefour = '$_basePath/stores/carrefour.jpg';
  static const String danube = '$_basePath/stores/danube.jpg';

  // ========== Meal Type Images ==========
  static const String breakfast = '$_basePath/meals/breakfast.jpg';
  static const String lunch = '$_basePath/meals/lunch.jpg';
  static const String dinner = '$_basePath/meals/dinner.jpg';
  static const String snack = '$_basePath/meals/snack.jpg';

  // ========== Profile Images ==========
  static const String defaultProfile = '$_basePath/profile/default_avatar.png';

  // ========== Placeholder Images ==========
  static const String foodPlaceholder =
      '$_basePath/placeholders/food_placeholder.jpg';
  static const String storePlaceholder =
      '$_basePath/placeholders/store_placeholder.jpg';
  static const String mealPlaceholder =
      '$_basePath/placeholders/meal_placeholder.jpg';

  // ========== Helper Methods ==========

  /// Get food image by category
  /// Returns appropriate asset image path based on food category
  static String getFoodImageByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
      case 'proteins':
      case 'chicken':
        return chicken;
      case 'fish':
      case 'salmon':
        return salmon;
      case 'carbohydrate':
      case 'carbohydrates':
      case 'rice':
      case 'grains':
        return brownRice;
      case 'vegetable':
      case 'vegetables':
      case 'broccoli':
        return broccoli;
      case 'fruit':
      case 'fruits':
      case 'apple':
        return apple;
      case 'dairy':
      case 'yogurt':
        return yogurt;
      default:
        return foodPlaceholder;
    }
  }

  /// Get food image by name
  /// Returns appropriate asset image path based on food name
  static String getFoodImageByName(String foodName) {
    final name = foodName.toLowerCase();
    if (name.contains('chicken')) return chicken;
    if (name.contains('salmon') || name.contains('fish')) return salmon;
    if (name.contains('rice')) return brownRice;
    if (name.contains('broccoli')) return broccoli;
    if (name.contains('apple')) return apple;
    if (name.contains('yogurt')) return yogurt;
    if (name.contains('oatmeal')) return oatmeal;
    if (name.contains('salad')) return salad;
    if (name.contains('quinoa')) return mediterraneanQuinoa;
    return foodPlaceholder;
  }

  /// Get store logo by store name
  /// Returns appropriate asset image path based on store name
  static String getStoreLogoByName(String storeName) {
    final name = storeName.toLowerCase();
    if (name.contains('othaim')) return othaim;
    if (name.contains('panda')) return panda;
    if (name.contains('lulu')) return lulu;
    if (name.contains('carrefour')) return carrefour;
    if (name.contains('danube')) return danube;
    return storePlaceholder;
  }

  /// Get meal type image
  /// Returns appropriate asset image path based on meal type
  static String getMealTypeImage(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfast;
      case 'lunch':
        return lunch;
      case 'dinner':
        return dinner;
      case 'snack':
        return snack;
      default:
        return mealPlaceholder;
    }
  }
}
