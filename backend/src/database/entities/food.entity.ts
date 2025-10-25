import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { MealFood } from './meal-food.entity';
import { FoodPrice } from './food-price.entity';
import { UserFavorite } from './user-favorite.entity';
import { UserFeedback } from './user-feedback.entity';
import { FoodCategory } from './food-category.entity';

@Entity('foods')
export class Food {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  name_arabic: string;

  @Column({ type: 'varchar', length: 100 })
  @Index()
  category: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  calories_per_100g: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  protein_per_100g: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  carbs_per_100g: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  fat_per_100g: number;

  @Column({ type: 'decimal', precision: 8, scale: 2, default: 0 })
  fiber_per_100g: number;

  @Column({ type: 'decimal', precision: 8, scale: 2, default: 0 })
  sugar_per_100g: number;

  @Column({ type: 'decimal', precision: 8, scale: 2, default: 0 })
  sodium_per_100g: number;

  @Column({ type: 'jsonb', default: '{}' })
  vitamins: Record<string, number>;

  @Column({ type: 'jsonb', default: '{}' })
  minerals: Record<string, number>;

  @Column({ type: 'text', array: true, default: '{}' })
  allergens: string[];

  @Column({ type: 'varchar', length: 500, nullable: true })
  image_url: string;

  @Column({ type: 'text', nullable: true })
  recipe_instructions: string;

  @Column({ type: 'int', default: 0 })
  preparation_time: number;

  @Column({ type: 'int', default: 1 })
  servings: number;

  @Column({ type: 'text', array: true, default: '{}' })
  tags: string[];

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relations
  @ManyToOne(() => FoodCategory, (category) => category.foods)
  @JoinColumn({ name: 'category' })
  food_category: FoodCategory;

  @OneToMany(() => MealFood, (mealFood) => mealFood.food)
  meal_foods: MealFood[];

  @OneToMany(() => FoodPrice, (price) => price.food)
  prices: FoodPrice[];

  @OneToMany(() => UserFavorite, (favorite) => favorite.food)
  favorites: UserFavorite[];

  @OneToMany(() => UserFeedback, (feedback) => feedback.food)
  feedback: UserFeedback[];

  // Computed properties
  getNutritionForServing(servingSizeGrams: number): Record<string, number> {
    const multiplier = servingSizeGrams / 100;
    return {
      calories: this.calories_per_100g * multiplier,
      protein: this.protein_per_100g * multiplier,
      carbs: this.carbs_per_100g * multiplier,
      fat: this.fat_per_100g * multiplier,
      fiber: this.fiber_per_100g * multiplier,
      sugar: this.sugar_per_100g * multiplier,
      sodium: this.sodium_per_100g * multiplier,
    };
  }

  getMacroPercentages(): Record<string, number> {
    const totalCalories = this.calories_per_100g;
    return {
      protein: (this.protein_per_100g * 4) / totalCalories * 100,
      carbs: (this.carbs_per_100g * 4) / totalCalories * 100,
      fat: (this.fat_per_100g * 9) / totalCalories * 100,
    };
  }

  containsAllergen(allergen: string): boolean {
    return this.allergens.some(a => 
      a.toLowerCase().includes(allergen.toLowerCase())
    );
  }
}
