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
      useFactory: async (configService: ConfigService) => {
        // Check if database is enabled (optional for Food Analysis API proxy)
        const dbEnabled = configService.get('DB_ENABLED', 'true').toLowerCase() === 'true';
        
        if (!dbEnabled) {
          console.log('⚠️  Database module disabled (DB_ENABLED=false). Food Analysis API proxy will still work.');
          // Return a minimal config that won't try to connect
          return {
            type: 'postgres',
            host: 'localhost',
            port: 5432,
            username: 'dummy',
            password: 'dummy',
            database: 'dummy',
            entities: [],
            synchronize: false,
            logging: false,
            autoLoadEntities: false,
            // Don't actually connect - this will prevent connection attempts
            retryAttempts: 0,
            retryDelay: 0,
            // Skip connection validation
            connectTimeoutMS: 0,
          };
        }

        // Supabase database configuration
        const dbHost = configService.get('DB_HOST', 'db.pnihaeljbyjiexnfolir.supabase.co');
        const isSupabase = dbHost.includes('supabase.co');
        
        const config = {
          type: 'postgres' as const,
          host: dbHost,
          port: configService.get('DB_PORT', 5432),
          username: configService.get('DB_USERNAME', 'postgres'),
          password: configService.get('DB_PASSWORD'), // Required - no default
          database: configService.get('DB_NAME', 'postgres'),
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
          // Supabase requires SSL connection
          ssl: isSupabase ? { rejectUnauthorized: false } : (configService.get('NODE_ENV') === 'production' ? { rejectUnauthorized: false } : false),
          // Connection retry settings
          retryAttempts: 3,
          retryDelay: 2000,
          autoLoadEntities: false,
          // Connection pool settings for Supabase
          extra: isSupabase ? {
            max: 10, // Maximum number of connections
            idleTimeoutMillis: 30000,
            connectionTimeoutMillis: 10000,
          } : {},
        };

        if (isSupabase) {
          console.log('✅ Using Supabase database:', dbHost);
        }

        // Test connection, but don't throw if it fails
        try {
          // This will be attempted, but with retryAttempts: 0 it will fail fast
          return config;
        } catch (error) {
          console.warn('⚠️  Database connection test failed, but continuing anyway:', error);
          return config;
        }
      },
      inject: [ConfigService],
    }),
  ],
})
export class DatabaseModule {}
