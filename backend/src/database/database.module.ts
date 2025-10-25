import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { User } from './entities/user.entity';
import { Food } from './entities/food.entity';
import { MealPlan } from './entities/meal-plan.entity';
import { MealFood } from './entities/meal-food.entity';
import { Store } from './entities/store.entity';
import { FoodPrice } from './entities/food-price.entity';
import { UserProgress } from './entities/user-progress.entity';
import { UserFavorite } from './entities/user-favorite.entity';
import { UserFeedback } from './entities/user-feedback.entity';
import { FoodCategory } from './entities/food-category.entity';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get('DB_PORT', 5432),
        username: configService.get('DB_USERNAME', 'smartbite'),
        password: configService.get('DB_PASSWORD', 'smartbite123'),
        database: configService.get('DB_NAME', 'smartbite'),
        entities: [
          User,
          Food,
          MealPlan,
          MealFood,
          Store,
          FoodPrice,
          UserProgress,
          UserFavorite,
          UserFeedback,
          FoodCategory,
        ],
        synchronize: configService.get('NODE_ENV') === 'development',
        logging: configService.get('NODE_ENV') === 'development',
        ssl: configService.get('NODE_ENV') === 'production' ? { rejectUnauthorized: false } : false,
      }),
      inject: [ConfigService],
    }),
  ],
})
export class DatabaseModule {}
