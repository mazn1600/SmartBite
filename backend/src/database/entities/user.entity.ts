import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { MealPlan } from './meal-plan.entity';
import { UserProgress } from './user-progress.entity';
import { UserFavorite } from './user-favorite.entity';
import { UserFeedback } from './user-feedback.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  @Index()
  email: string;

  @Column()
  password_hash: string;

  @Column()
  name: string;

  @Column({ type: 'int' })
  age: number;

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  height: number;

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  weight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  target_weight: number;

  @Column({ type: 'varchar', length: 20 })
  gender: string;

  @Column({ type: 'varchar', length: 50 })
  activity_level: string;

  @Column({ type: 'varchar', length: 50 })
  goal: string;

  @Column({ type: 'text', array: true, default: '{}' })
  allergies: string[];

  @Column({ type: 'text', array: true, default: '{}' })
  health_conditions: string[];

  @Column({ type: 'text', array: true, default: '{}' })
  food_preferences: string[];

  @Column({ type: 'varchar', length: 500, nullable: true })
  profile_image_url: string;

  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  @Column({ type: 'boolean', default: false })
  email_verified: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  // Relations
  @OneToMany(() => MealPlan, (mealPlan) => mealPlan.user)
  meal_plans: MealPlan[];

  @OneToMany(() => UserProgress, (progress) => progress.user)
  progress_records: UserProgress[];

  @OneToMany(() => UserFavorite, (favorite) => favorite.user)
  favorites: UserFavorite[];

  @OneToMany(() => UserFeedback, (feedback) => feedback.user)
  feedback: UserFeedback[];

  // Computed properties
  get bmi(): number {
    return this.weight / Math.pow(this.height / 100, 2);
  }

  get bmr(): number {
    if (this.gender.toLowerCase() === 'male') {
      return 10 * this.weight + 6.25 * this.height - 5 * this.age + 5;
    } else {
      return 10 * this.weight + 6.25 * this.height - 5 * this.age - 161;
    }
  }

  get tdee(): number {
    const activityMultipliers = {
      sedentary: 1.2,
      lightly_active: 1.375,
      moderately_active: 1.55,
      very_active: 1.725,
      extremely_active: 1.9,
    };
    return this.bmr * (activityMultipliers[this.activity_level] || 1.2);
  }

  get target_calories(): number {
    switch (this.goal.toLowerCase()) {
      case 'weight_loss':
        return this.tdee - 500;
      case 'weight_gain':
        return this.tdee + 500;
      case 'maintenance':
      default:
        return this.tdee;
    }
  }
}
