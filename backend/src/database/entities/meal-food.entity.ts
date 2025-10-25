import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { MealPlan } from './meal-plan.entity';
import { Food } from './food.entity';

@Entity('meal_foods')
export class MealFood {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  @Index()
  meal_plan_id: string;

  @Column({ type: 'uuid' })
  @Index()
  food_id: string;

  @Column({ type: 'varchar', length: 20 })
  @Index()
  meal_type: string;

  @Column({ type: 'int' })
  @Index()
  day_of_week: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  serving_size: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  calories: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  protein: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  carbs: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  fat: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  fiber: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  sugar: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  sodium: number;

  @Column({ type: 'boolean', default: false })
  is_consumed: boolean;

  @Column({ type: 'timestamp', nullable: true })
  consumed_at: Date;

  @CreateDateColumn()
  created_at: Date;

  // Relations
  @ManyToOne(() => MealPlan, (mealPlan) => mealPlan.meal_foods)
  @JoinColumn({ name: 'meal_plan_id' })
  meal_plan: MealPlan;

  @ManyToOne(() => Food, (food) => food.meal_foods)
  @JoinColumn({ name: 'food_id' })
  food: Food;
}
