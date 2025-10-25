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

@Entity('user_progress')
export class UserProgress {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  @Index()
  user_id: string;

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  weight: number;

  @Column({ type: 'decimal', precision: 4, scale: 2 })
  bmi: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  bmr: number;

  @Column({ type: 'decimal', precision: 8, scale: 2 })
  tdee: number;

  @Column({ type: 'decimal', precision: 4, scale: 2, nullable: true })
  body_fat_percentage: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  muscle_mass: number;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  @Index()
  recorded_at: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  created_at: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.progress_records)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
