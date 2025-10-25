import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { Food } from './food.entity';
import { Store } from './store.entity';

@Entity('food_prices')
@Unique(['food_id', 'store_id'])
export class FoodPrice {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  @Index()
  food_id: string;

  @Column({ type: 'uuid' })
  @Index()
  store_id: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column({ type: 'varchar', length: 20, default: 'kg' })
  unit: string;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  @Index()
  last_updated: Date;

  @Column({ type: 'boolean', default: true })
  is_available: boolean;

  @CreateDateColumn()
  created_at: Date;

  // Relations
  @ManyToOne(() => Food, (food) => food.prices)
  @JoinColumn({ name: 'food_id' })
  food: Food;

  @ManyToOne(() => Store, (store) => store.prices)
  @JoinColumn({ name: 'store_id' })
  store: Store;
}
