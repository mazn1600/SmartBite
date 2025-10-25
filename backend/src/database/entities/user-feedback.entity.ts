import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from './user.entity';
import { MealPlan } from './meal-plan.entity';
import { Food } from './food.entity';

@Entity('user_feedback')
export class UserFeedback {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  @Index()
  user_id: string;

  @Column({ type: 'uuid', nullable: true })
  @Index()
  meal_plan_id: string;

  @Column({ type: 'uuid', nullable: true })
  @Index()
  food_id: string;

  @Column({ type: 'int', nullable: true })
  rating: number;

  @Column({ type: 'text', nullable: true })
  feedback_text: string;

  @Column({ type: 'varchar', length: 50 })
  feedback_type: string;

  @CreateDateColumn()
  created_at: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.feedback)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => MealPlan, (mealPlan) => mealPlan.feedback)
  @JoinColumn({ name: 'meal_plan_id' })
  meal_plan: MealPlan;

  @ManyToOne(() => Food, (food) => food.feedback)
  @JoinColumn({ name: 'food_id' })
  food: Food;
}
