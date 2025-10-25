-- SmartBite Database Schema for Supabase
-- This file contains all the necessary tables and policies for the SmartBite app

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE gender_type AS ENUM ('male', 'female');
CREATE TYPE activity_level_type AS ENUM ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active');
CREATE TYPE goal_type AS ENUM ('weight_loss', 'weight_gain', 'maintenance');
CREATE TYPE meal_type AS ENUM ('breakfast', 'lunch', 'dinner', 'snack');

-- Users table
CREATE TABLE users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender gender_type,
    height DECIMAL(5,2), -- in cm
    weight DECIMAL(5,2), -- in kg
    activity_level activity_level_type,
    goal goal_type,
    bmi DECIMAL(4,2),
    bmr DECIMAL(8,2),
    tdee DECIMAL(8,2),
    dietary_preferences TEXT[],
    allergies TEXT[],
    health_conditions TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Food categories table
CREATE TABLE food_categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_arabic VARCHAR(100),
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Foods table
CREATE TABLE foods (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_arabic VARCHAR(255),
    category_id UUID REFERENCES food_categories(id),
    category VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    calories INTEGER NOT NULL,
    protein DECIMAL(6,2) NOT NULL,
    carbs DECIMAL(6,2) NOT NULL,
    fat DECIMAL(6,2) NOT NULL,
    fiber DECIMAL(6,2) DEFAULT 0,
    sugar DECIMAL(6,2) DEFAULT 0,
    sodium DECIMAL(6,2) DEFAULT 0,
    serving_size VARCHAR(50) NOT NULL,
    serving_unit VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stores table
CREATE TABLE stores (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_arabic VARCHAR(255),
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    phone_number VARCHAR(20),
    working_hours TEXT[],
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Food prices table
CREATE TABLE food_prices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    food_id UUID REFERENCES foods(id) ON DELETE CASCADE,
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'SAR',
    unit VARCHAR(20) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    is_on_sale BOOLEAN DEFAULT false,
    sale_price DECIMAL(10,2),
    sale_start_date TIMESTAMP WITH TIME ZONE,
    sale_end_date TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Meal plans table
CREATE TABLE meal_plans (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type meal_type NOT NULL,
    items JSONB NOT NULL, -- Array of meal items
    total_calories DECIMAL(8,2) NOT NULL,
    total_protein DECIMAL(8,2) NOT NULL,
    total_carbs DECIMAL(8,2) NOT NULL,
    total_fat DECIMAL(8,2) NOT NULL,
    total_cost DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    rating DECIMAL(3,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User progress table
CREATE TABLE user_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    weight DECIMAL(5,2),
    body_fat_percentage DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    water_intake DECIMAL(6,2), -- in liters
    calories_consumed DECIMAL(8,2),
    calories_burned DECIMAL(8,2),
    steps INTEGER DEFAULT 0,
    sleep_hours DECIMAL(4,2),
    mood_rating INTEGER CHECK (mood_rating >= 1 AND mood_rating <= 10),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User favorites table
CREATE TABLE user_favorites (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, food_id)
);

-- User feedback table
CREATE TABLE user_feedback (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    meal_plan_id UUID REFERENCES meal_plans(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    feedback_type VARCHAR(50), -- 'meal', 'food', 'recommendation'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_foods_name ON foods(name);
CREATE INDEX idx_foods_category ON foods(category);
CREATE INDEX idx_food_prices_food_id ON food_prices(food_id);
CREATE INDEX idx_food_prices_store_id ON food_prices(store_id);
CREATE INDEX idx_meal_plans_user_id ON meal_plans(user_id);
CREATE INDEX idx_meal_plans_date ON meal_plans(date);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_date ON user_progress(date);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_feedback_user_id ON user_feedback(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

-- Create RLS policies

-- Users can only see and modify their own data
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Foods are public (read-only for users)
CREATE POLICY "Anyone can view foods" ON foods
    FOR SELECT USING (true);

CREATE POLICY "Only authenticated users can insert foods" ON foods
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Food categories are public (read-only for users)
CREATE POLICY "Anyone can view food categories" ON food_categories
    FOR SELECT USING (true);

-- Stores are public (read-only for users)
CREATE POLICY "Anyone can view stores" ON stores
    FOR SELECT USING (true);

-- Food prices are public (read-only for users)
CREATE POLICY "Anyone can view food prices" ON food_prices
    FOR SELECT USING (true);

-- Meal plans are private to users
CREATE POLICY "Users can view own meal plans" ON meal_plans
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meal plans" ON meal_plans
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meal plans" ON meal_plans
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meal plans" ON meal_plans
    FOR DELETE USING (auth.uid() = user_id);

-- User progress is private to users
CREATE POLICY "Users can view own progress" ON user_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress" ON user_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress" ON user_progress
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own progress" ON user_progress
    FOR DELETE USING (auth.uid() = user_id);

-- User favorites are private to users
CREATE POLICY "Users can view own favorites" ON user_favorites
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites" ON user_favorites
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites" ON user_favorites
    FOR DELETE USING (auth.uid() = user_id);

-- User feedback is private to users
CREATE POLICY "Users can view own feedback" ON user_feedback
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own feedback" ON user_feedback
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foods_updated_at BEFORE UPDATE ON foods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_categories_updated_at BEFORE UPDATE ON food_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON stores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meal_plans_updated_at BEFORE UPDATE ON meal_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO food_categories (name, name_arabic, description) VALUES
('Breakfast', 'الإفطار', 'Morning meals and breakfast items'),
('Lunch', 'الغداء', 'Midday meals and lunch items'),
('Dinner', 'العشاء', 'Evening meals and dinner items'),
('Snacks', 'الوجبات الخفيفة', 'Light snacks and beverages'),
('Fruits', 'الفواكه', 'Fresh and dried fruits'),
('Vegetables', 'الخضروات', 'Fresh and cooked vegetables'),
('Meat', 'اللحوم', 'Beef, chicken, lamb, and other meats'),
('Seafood', 'المأكولات البحرية', 'Fish, shrimp, and other seafood'),
('Dairy', 'منتجات الألبان', 'Milk, cheese, yogurt, and dairy products'),
('Grains', 'الحبوب', 'Rice, wheat, oats, and other grains');

-- Insert sample stores
INSERT INTO stores (name, name_arabic, address, city, latitude, longitude, phone_number, working_hours, rating) VALUES
('Othaim Markets', 'أسواق العثيم', 'King Fahd Road, Riyadh', 'Riyadh', 24.7136, 46.6753, '+966 11 123 4567', ARRAY['8:00 AM - 12:00 AM'], 4.2),
('Panda Retail Company', 'شركة الباندا للتجزئة', 'Prince Mohammed bin Abdulaziz Road, Jeddah', 'Jeddah', 21.4858, 39.1925, '+966 12 345 6789', ARRAY['8:00 AM - 12:00 AM'], 4.0),
('Lulu Hypermarket', 'لولو هايبرماركت', 'King Abdulaziz Road, Dammam', 'Dammam', 26.4207, 50.0888, '+966 13 456 7890', ARRAY['8:00 AM - 12:00 AM'], 4.3),
('Carrefour', 'كارفور', 'King Khalid Road, Riyadh', 'Riyadh', 24.7136, 46.6753, '+966 11 234 5678', ARRAY['8:00 AM - 12:00 AM'], 4.1),
('Danube', 'دانوب', 'Prince Sultan Road, Jeddah', 'Jeddah', 21.4858, 39.1925, '+966 12 456 7890', ARRAY['8:00 AM - 12:00 AM'], 4.0);

-- Insert sample foods
INSERT INTO foods (name, name_arabic, category, calories, protein, carbs, fat, fiber, sugar, sodium, serving_size, serving_unit) VALUES
('Oatmeal with Berries', 'دقيق الشوفان مع التوت', 'Breakfast', 300, 12.0, 50.0, 8.0, 8.0, 15.0, 5.0, '1', 'cup'),
('Grilled Chicken Salad', 'سلطة الدجاج المشوي', 'Lunch', 400, 35.0, 15.0, 20.0, 5.0, 8.0, 300.0, '1', 'plate'),
('Salmon with Quinoa', 'سمك السلمون مع الكينوا', 'Dinner', 500, 40.0, 45.0, 25.0, 3.0, 2.0, 400.0, '1', 'plate'),
('Greek Yogurt', 'الزبادي اليوناني', 'Dairy', 150, 20.0, 10.0, 5.0, 0.0, 8.0, 50.0, '1', 'cup'),
('Apple', 'تفاح', 'Fruits', 80, 0.3, 21.0, 0.2, 4.0, 16.0, 1.0, '1', 'medium'),
('Brown Rice', 'الأرز البني', 'Grains', 220, 5.0, 45.0, 2.0, 4.0, 1.0, 5.0, '1', 'cup'),
('Grilled Chicken Breast', 'صدر دجاج مشوي', 'Meat', 165, 31.0, 0.0, 3.6, 0.0, 0.0, 74.0, '100', 'g'),
('Mixed Vegetables', 'خضروات مشكلة', 'Vegetables', 50, 2.0, 10.0, 0.5, 3.0, 5.0, 20.0, '1', 'cup');
