import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from './user.entity';
import { MealFood } from './meal-food.entity';
import { UserFeedback } from './user-feedback.entity';

@Entity('meal_plans')
export class MealPlan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  @Index()
  user_id: string;

  @Column({ type: 'date' })
  @Index()
  week_start_date: Date;

  @Column({ type: 'date' })
  @Index()
  week_end_date: Date;

  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true })
  total_calories: number;

  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true })
  total_protein: number;

  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true })
  total_carbs: number;

  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true })
  total_fat: number;

  @Column({ type: 'boolean', default: false })
  is_generated: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.meal_plans)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @OneToMany(() => MealFood, (mealFood) => mealFood.meal_plan)
  meal_foods: MealFood[];

  @OneToMany(() => UserFeedback, (feedback) => feedback.meal_plan)
  feedback: UserFeedback[];

  // Computed properties
  get totalFiber(): number {
    return this.meal_foods?.reduce((sum, mealFood) => sum + mealFood.fiber, 0) || 0;
  }

  get totalSugar(): number {
    return this.meal_foods?.reduce((sum, mealFood) => sum + mealFood.sugar, 0) || 0;
  }

  get totalSodium(): number {
    return this.meal_foods?.reduce((sum, mealFood) => sum + mealFood.sodium, 0) || 0;
  }

  getMealsByType(mealType: string): MealFood[] {
    return this.meal_foods?.filter(mf => mf.meal_type === mealType) || [];
  }

  getMealsByDay(dayOfWeek: number): MealFood[] {
    return this.meal_foods?.filter(mf => mf.day_of_week === dayOfWeek) || [];
  }
}
