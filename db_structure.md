# 🗄️ SmartBite Database Structure

## 📊 Database Overview

SmartBite uses **PostgreSQL** as the primary database with two main schemas:
1. **Nutrition Database** - Saudi food nutritional values and recipes
2. **User Database** - User profiles, preferences, and meal history

---

## 🍎 Nutrition Database Schema

### `foods` Table
Stores comprehensive nutritional information for Saudi foods.

```sql
CREATE TABLE foods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    name_arabic VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    calories_per_100g DECIMAL(8,2) NOT NULL,
    protein_per_100g DECIMAL(8,2) NOT NULL,
    carbs_per_100g DECIMAL(8,2) NOT NULL,
    fat_per_100g DECIMAL(8,2) NOT NULL,
    fiber_per_100g DECIMAL(8,2) DEFAULT 0,
    sugar_per_100g DECIMAL(8,2) DEFAULT 0,
    sodium_per_100g DECIMAL(8,2) DEFAULT 0,
    vitamins JSONB DEFAULT '{}',
    minerals JSONB DEFAULT '{}',
    allergens TEXT[] DEFAULT '{}',
    image_url VARCHAR(500),
    recipe_instructions TEXT,
    preparation_time INTEGER DEFAULT 0, -- in minutes
    servings INTEGER DEFAULT 1,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `food_categories` Table
Categorizes foods for better organization and filtering.

```sql
CREATE TABLE food_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    name_arabic VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES food_categories(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `stores` Table
Saudi supermarket chains for price comparison.

```sql
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    name_arabic VARCHAR(100) NOT NULL,
    logo_url VARCHAR(500),
    website VARCHAR(255),
    api_endpoint VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `food_prices` Table
Price tracking for foods across different stores.

```sql
CREATE TABLE food_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    food_id UUID NOT NULL REFERENCES foods(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) DEFAULT 'kg', -- kg, piece, liter, etc.
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_available BOOLEAN DEFAULT true,
    UNIQUE(food_id, store_id)
);
```

---

## 👤 User Database Schema

### `users` Table
Core user profile information and health metrics.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 13 AND age <= 120),
    height DECIMAL(5,2) NOT NULL, -- in cm
    weight DECIMAL(5,2) NOT NULL, -- in kg
    target_weight DECIMAL(5,2), -- in kg
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    activity_level VARCHAR(50) NOT NULL CHECK (activity_level IN (
        'sedentary', 'lightly_active', 'moderately_active', 
        'very_active', 'extremely_active'
    )),
    goal VARCHAR(50) NOT NULL CHECK (goal IN (
        'weight_loss', 'weight_gain', 'maintenance', 'muscle_gain'
    )),
    allergies TEXT[] DEFAULT '{}',
    health_conditions TEXT[] DEFAULT '{}',
    food_preferences TEXT[] DEFAULT '{}',
    profile_image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `user_sessions` Table
JWT session management and security.

```sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    device_info JSONB,
    ip_address INET,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `meal_plans` Table
Weekly meal planning and scheduling.

```sql
CREATE TABLE meal_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    total_calories DECIMAL(8,2),
    total_protein DECIMAL(8,2),
    total_carbs DECIMAL(8,2),
    total_fat DECIMAL(8,2),
    is_generated BOOLEAN DEFAULT false, -- AI-generated vs manual
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `meal_foods` Table
Individual meals within meal plans.

```sql
CREATE TABLE meal_foods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_plan_id UUID NOT NULL REFERENCES meal_plans(id) ON DELETE CASCADE,
    food_id UUID NOT NULL REFERENCES foods(id) ON DELETE CASCADE,
    meal_type VARCHAR(20) NOT NULL CHECK (meal_type IN (
        'breakfast', 'lunch', 'dinner', 'snack'
    )),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    serving_size DECIMAL(8,2) NOT NULL, -- in grams
    calories DECIMAL(8,2) NOT NULL,
    protein DECIMAL(8,2) NOT NULL,
    carbs DECIMAL(8,2) NOT NULL,
    fat DECIMAL(8,2) NOT NULL,
    is_consumed BOOLEAN DEFAULT false,
    consumed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `user_progress` Table
Health metrics tracking over time.

```sql
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight DECIMAL(5,2) NOT NULL,
    bmi DECIMAL(4,2) NOT NULL,
    bmr DECIMAL(8,2) NOT NULL,
    tdee DECIMAL(8,2) NOT NULL,
    body_fat_percentage DECIMAL(4,2),
    muscle_mass DECIMAL(5,2),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
```

### `user_favorites` Table
User's favorite foods and recipes.

```sql
CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    food_id UUID NOT NULL REFERENCES foods(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, food_id)
);
```

### `user_feedback` Table
User ratings and feedback for meal recommendations.

```sql
CREATE TABLE user_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_plan_id UUID REFERENCES meal_plans(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    feedback_type VARCHAR(50) CHECK (feedback_type IN (
        'meal_plan', 'food_item', 'recommendation'
    )),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔗 Relationships and Indexes

### Key Relationships
- `users` → `meal_plans` (1:many)
- `meal_plans` → `meal_foods` (1:many)
- `foods` → `meal_foods` (1:many)
- `users` → `user_progress` (1:many)
- `users` → `user_favorites` (1:many)
- `stores` → `food_prices` (1:many)
- `foods` → `food_prices` (1:many)

### Performance Indexes
```sql
-- User queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Meal planning
CREATE INDEX idx_meal_plans_user_id ON meal_plans(user_id);
CREATE INDEX idx_meal_plans_week_dates ON meal_plans(week_start_date, week_end_date);
CREATE INDEX idx_meal_foods_meal_plan_id ON meal_foods(meal_plan_id);
CREATE INDEX idx_meal_foods_day_meal ON meal_foods(day_of_week, meal_type);

-- Food search
CREATE INDEX idx_foods_category ON foods(category);
CREATE INDEX idx_foods_calories ON foods(calories_per_100g);
CREATE INDEX idx_foods_name_search ON foods USING gin(to_tsvector('english', name));
CREATE INDEX idx_foods_arabic_search ON foods USING gin(to_tsvector('arabic', name_arabic));

-- Price comparison
CREATE INDEX idx_food_prices_food_store ON food_prices(food_id, store_id);
CREATE INDEX idx_food_prices_last_updated ON food_prices(last_updated);

-- Progress tracking
CREATE INDEX idx_user_progress_user_date ON user_progress(user_id, recorded_at);
```

---

## 📊 Data Types and Constraints

### Nutritional Values
- **Calories**: DECIMAL(8,2) - Up to 999,999.99 calories
- **Macros**: DECIMAL(8,2) - Up to 999,999.99 grams
- **Vitamins/Minerals**: JSONB for flexible micronutrient storage

### User Metrics
- **Height**: DECIMAL(5,2) - Up to 999.99 cm (3.28m max)
- **Weight**: DECIMAL(5,2) - Up to 999.99 kg
- **BMI**: DECIMAL(4,2) - Up to 99.99

### Validation Rules
- **Age**: 13-120 years
- **Gender**: Enum values only
- **Activity Level**: Predefined categories
- **Goal**: Predefined health goals
- **Email**: Unique constraint with validation

---

## 🔄 Data Migration and Seeding

### Initial Data Population
1. **Saudi Food Database** - Import from nutrition APIs
2. **Store Information** - Major Saudi supermarket chains
3. **Food Categories** - Hierarchical category structure
4. **Sample Users** - Test accounts for development

### Data Maintenance
- **Price Updates** - Daily price synchronization
- **Nutrition Updates** - Weekly food database updates
- **User Cleanup** - Inactive account management
- **Session Cleanup** - Expired token removal

---

## 🔒 Security and Privacy

### Data Protection
- **Password Hashing** - bcrypt with salt rounds
- **JWT Tokens** - Secure session management
- **Input Validation** - SQL injection prevention
- **Data Encryption** - Sensitive data at rest

### Privacy Compliance
- **GDPR Compliance** - User data export/deletion
- **Data Retention** - Automatic cleanup policies
- **Audit Logging** - User action tracking
- **Access Control** - Role-based permissions

---

*Last Updated: January 2025*
*Version: 1.0.0*
