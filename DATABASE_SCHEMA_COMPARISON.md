# Database Schema Comparison: Flutter App vs Supabase

This document compares the Flutter app models (`lib/shared/models/`) with the Supabase database schema to identify discrepancies, missing columns, and missing relations.

## Summary

| Table | Status | Missing in App | Missing in Supabase | Notes |
|-------|--------|----------------|---------------------|-------|
| `users` | ⚠️ Partial | phone_number, health_conditions, stored bmi/bmr/tdee | targetWeight | Mapping exists but incomplete |
| `foods` | ⚠️ Major Differences | category_id, serving_size, serving_unit, is_active | vitamins, minerals, allergens, recipeInstructions | Different nutrition structure |
| `meal_plans` | ⚠️ Format Mismatch | JSONB serialization | - | Items stored as JSONB vs List<MealItem> |
| `food_prices` | ✅ Mostly Aligned | sale_start_date | storeName (computed) | Minor discrepancy |
| `stores` | ✅ Aligned | - | - | No issues |
| `food_categories` | ❌ Missing | Entire table | - | Not modeled in app |
| `user_favorites` | ❌ Missing | Entire table | - | Not modeled in app |
| `user_feedback` | ❌ Missing | Entire table | - | Not modeled in app |
| `user_progress` | ❌ Missing | Entire table | - | Not modeled in app |
| `intrest_api_tokens` | ❌ Missing | Entire table | - | Tokens only in SharedPreferences |

---

## 1. USERS Table

### Supabase Schema
```sql
CREATE TABLE public.users (
  id uuid NOT NULL, -- FK to auth.users(id)
  email character varying NOT NULL UNIQUE,
  first_name character varying,
  last_name character varying,
  phone_number character varying,
  date_of_birth date,
  gender USER-DEFINED, -- ENUM: 'male', 'female'
  height numeric,
  weight numeric,
  activity_level USER-DEFINED, -- ENUM
  goal USER-DEFINED, -- ENUM
  bmi numeric, -- STORED
  bmr numeric, -- STORED
  tdee numeric, -- STORED
  dietary_preferences ARRAY,
  allergies ARRAY,
  health_conditions ARRAY,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

### App Model (`lib/shared/models/user.dart`)
```dart
class User {
  final String id;
  final String email;
  final String name; // COMPUTED from first_name + last_name
  final int age; // COMPUTED from date_of_birth
  final double height;
  final double weight;
  final double? targetWeight; // NOT in Supabase
  final String gender;
  final String activityLevel;
  final String goal;
  final List<String> allergies;
  final List<String> foodPreferences; // Maps to dietary_preferences
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Computed properties (NOT stored in DB):
  double get bmi => ...;
  double get bmr => ...;
  double get tdee => ...;
}
```

### Discrepancies

**Missing in App Model:**
- ❌ `phone_number` (varchar)
- ❌ `health_conditions` (ARRAY)
- ❌ `first_name` (stored separately, app uses computed `name`)
- ❌ `last_name` (stored separately, app uses computed `name`)
- ❌ `date_of_birth` (stored as date, app uses computed `age`)
- ⚠️ `bmi`, `bmr`, `tdee` are computed in app but stored in Supabase

**Missing in Supabase:**
- ❌ `targetWeight` (double) - App has this but Supabase doesn't

**Mapping Status:**
- ✅ Partial mapping exists in `auth_service.dart` `_mapDatabaseUserToAppUser()`
- ✅ Handles first_name/last_name → name conversion
- ✅ Handles date_of_birth → age calculation
- ❌ Missing phone_number mapping
- ❌ Missing health_conditions mapping
- ❌ Missing bmi/bmr/tdee storage on update

---

## 2. FOODS Table

### Supabase Schema
```sql
CREATE TABLE public.foods (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  name_arabic character varying,
  category_id uuid, -- FK to food_categories(id)
  category character varying NOT NULL, -- Redundant with category_id?
  description text,
  image_url text,
  calories integer NOT NULL, -- Absolute value
  protein numeric NOT NULL,
  carbs numeric NOT NULL,
  fat numeric NOT NULL,
  fiber numeric DEFAULT 0,
  sugar numeric DEFAULT 0,
  sodium numeric DEFAULT 0,
  serving_size character varying NOT NULL,
  serving_unit character varying NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

### App Model (`lib/shared/models/food.dart`)
```dart
class Food {
  final String id;
  final String name;
  final String nameArabic;
  final String category; // String, NOT category_id
  final String description;
  final double caloriesPer100g; // Per 100g, NOT absolute
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double sodiumPer100g;
  final Map<String, double> vitamins; // NOT in Supabase
  final Map<String, double> minerals; // NOT in Supabase
  final List<String> allergens; // NOT in Supabase
  final String imageUrl;
  final String recipeInstructions; // NOT in Supabase
  final int preparationTime; // NOT in Supabase
  final int servings; // NOT in Supabase
  final List<String> tags; // NOT in Supabase
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Discrepancies

**Missing in App Model:**
- ❌ `category_id` (uuid, FK to food_categories)
- ❌ `serving_size` (varchar)
- ❌ `serving_unit` (varchar)
- ❌ `is_active` (boolean)
- ⚠️ Nutrition values: App uses `caloriesPer100g`, Supabase uses absolute `calories`

**Missing in Supabase:**
- ❌ `vitamins` (Map<String, double>)
- ❌ `minerals` (Map<String, double>)
- ❌ `allergens` (List<String>)
- ❌ `recipeInstructions` (String)
- ❌ `preparationTime` (int)
- ❌ `servings` (int)
- ❌ `tags` (List<String>)

**Structural Differences:**
- App uses per-100g nutrition values, Supabase uses absolute values
- App has `category` as string, Supabase has both `category` (string) and `category_id` (FK)
- App has additional recipe/cooking fields not in Supabase

---

## 3. MEAL_PLANS Table

### Supabase Schema
```sql
CREATE TABLE public.meal_plans (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid, -- FK to users(id)
  date date NOT NULL,
  meal_type USER-DEFINED NOT NULL, -- ENUM: 'breakfast', 'lunch', 'dinner', 'snack'
  items jsonb NOT NULL, -- Stored as JSONB
  total_calories numeric NOT NULL,
  total_protein numeric NOT NULL,
  total_carbs numeric NOT NULL,
  total_fat numeric NOT NULL,
  total_cost numeric DEFAULT 0,
  notes text,
  rating numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

### App Model (`lib/shared/models/meal_plan.dart`)
```dart
class MealPlan {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType;
  final List<MealItem> items; // Structured class, NOT JSONB
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalCost;
  final String? notes;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class MealItem {
  final String id;
  final String foodId;
  final String foodName;
  final double quantity;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double cost;
  final String? notes;
}
```

### Discrepancies

**Format Mismatch:**
- ⚠️ Supabase stores `items` as JSONB
- ⚠️ App uses `List<MealItem>` structured class
- ✅ Need JSONB serialization/deserialization

**Status:** Structure is compatible, needs proper JSONB handling

---

## 4. FOOD_PRICES Table

### Supabase Schema
```sql
CREATE TABLE public.food_prices (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  food_id uuid, -- FK to foods(id)
  store_id uuid, -- FK to stores(id)
  price numeric NOT NULL,
  currency character varying DEFAULT 'SAR',
  unit character varying NOT NULL,
  quantity numeric NOT NULL,
  is_on_sale boolean DEFAULT false,
  sale_price numeric,
  sale_start_date timestamp with time zone, -- MISSING in app
  sale_end_date timestamp with time zone,
  last_updated timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now()
);
```

### App Model (`lib/shared/models/store.dart` - FoodPrice class)
```dart
class FoodPrice {
  final String id;
  final String foodId;
  final String storeId;
  final String storeName; // COMPUTED, NOT in DB
  final double price;
  final String currency;
  final String unit;
  final double quantity;
  final bool isOnSale;
  final double? salePrice;
  final DateTime? saleEndDate; // Has end, missing start
  final DateTime lastUpdated;
  final DateTime createdAt;
}
```

### Discrepancies

**Missing in App Model:**
- ❌ `sale_start_date` (timestamp)

**Missing in Supabase:**
- ❌ `storeName` (computed field, not stored)

**Status:** Minor discrepancy, easy to fix

---

## 5. STORES Table

### Supabase Schema
```sql
CREATE TABLE public.stores (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  name_arabic character varying,
  address text NOT NULL,
  city character varying NOT NULL,
  latitude numeric NOT NULL,
  longitude numeric NOT NULL,
  phone_number character varying,
  working_hours ARRAY,
  image_url text,
  rating numeric DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

### App Model (`lib/shared/models/store.dart`)
```dart
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
}
```

### Status
✅ **Fully Aligned** - No discrepancies

---

## 6. Missing Tables in App

### 6.1 FOOD_CATEGORIES Table

**Supabase Schema:**
```sql
CREATE TABLE public.food_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  name_arabic character varying,
  description text,
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

**App Status:** ❌ Not modeled - App uses string `category` field in Food model

**Impact:** Cannot properly relate foods to categories, no category management

---

### 6.2 USER_FAVORITES Table

**Supabase Schema:**
```sql
CREATE TABLE public.user_favorites (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid, -- FK to users(id)
  food_id uuid, -- FK to foods(id)
  created_at timestamp with time zone DEFAULT now()
);
```

**App Status:** ❌ Not modeled

**Impact:** Cannot track user favorite foods

---

### 6.3 USER_FEEDBACK Table

**Supabase Schema:**
```sql
CREATE TABLE public.user_feedback (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid, -- FK to users(id)
  meal_plan_id uuid, -- FK to meal_plans(id)
  food_id uuid, -- FK to foods(id)
  rating integer CHECK (rating >= 1 AND rating <= 5),
  feedback_text text,
  feedback_type character varying,
  created_at timestamp with time zone DEFAULT now()
);
```

**App Status:** ❌ Not modeled

**Impact:** Cannot collect user feedback on meals/foods

---

### 6.4 USER_PROGRESS Table

**Supabase Schema:**
```sql
CREATE TABLE public.user_progress (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid, -- FK to users(id)
  date date NOT NULL,
  weight numeric,
  body_fat_percentage numeric,
  muscle_mass numeric,
  water_intake numeric,
  calories_consumed numeric,
  calories_burned numeric,
  steps integer DEFAULT 0,
  sleep_hours numeric,
  mood_rating integer CHECK (mood_rating >= 1 AND mood_rating <= 10),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

**App Status:** ❌ Not modeled

**Impact:** Cannot track user health progress over time

---

## 7. INTREST API TOKENS (New Requirement)

### Current State
- Tokens stored only in SharedPreferences
- No database persistence
- No user association
- Tokens lost on app uninstall

### Token Structure (from Intrest API)
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...", // JWT token string
  "refreshToken": "YkWB7Zw8YjUcmdUOoQJiwb9zl", // String token
  "expiresIn": 1762570500000 // Timestamp in milliseconds (epoch)
}
```

### Proposed Schema

**Option A: Separate Table (Recommended)**
```sql
CREATE TABLE public.intrest_api_tokens (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL UNIQUE, -- FK to users(id)
  access_token text NOT NULL,
  refresh_token text NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT intrest_api_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT intrest_api_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);
```

**Option B: Add to Users Table**
```sql
ALTER TABLE public.users ADD COLUMN intrest_access_token text;
ALTER TABLE public.users ADD COLUMN intrest_refresh_token text;
ALTER TABLE public.users ADD COLUMN intrest_token_expires_at timestamp with time zone;
```

**Recommendation:** Use Option A (separate table) for better scalability and separation of concerns.

---

## Priority Actions

### High Priority
1. ✅ Create missing model classes (FoodCategory, UserFavorite, UserFeedback, UserProgress)
2. ✅ Add Intrest API token storage to Supabase
3. ✅ Update User model to include phone_number, health_conditions
4. ✅ Update Food model to include category_id, serving fields
5. ✅ Fix MealPlan JSONB serialization

### Medium Priority
1. ✅ Update FoodPrice to include sale_start_date
2. ✅ Add proper mapping utilities for all models
3. ✅ Update auth_service.dart to handle all User fields

### Low Priority
1. ⚠️ Consider storing vitamins/minerals/allergens as JSONB in Supabase
2. ⚠️ Add targetWeight to Supabase schema or remove from app
3. ⚠️ Decide on nutrition value structure (per-100g vs absolute)

---

## Next Steps

See implementation plan in the main plan document for detailed steps to align the schemas.

