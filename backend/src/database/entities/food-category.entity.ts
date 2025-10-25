import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Food } from './food.entity';

@Entity('food_categories')
export class FoodCategory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column()
  name_arabic: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'uuid', nullable: true })
  @Index()
  parent_id: string;

  @CreateDateColumn()
  created_at: Date;

  // Relations
  @ManyToOne(() => FoodCategory, (category) => category.children)
  @JoinColumn({ name: 'parent_id' })
  parent: FoodCategory;

  @OneToMany(() => FoodCategory, (category) => category.parent)
  children: FoodCategory[];

  @OneToMany(() => Food, (food) => food.food_category)
  foods: Food[];
}
