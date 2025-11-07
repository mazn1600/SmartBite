import { DynamicModule, Module } from '@nestjs/common';
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

/**
 * Optional Database Module
 * Only loads if DB_ENABLED is not 'false'
 * This allows the Food Analysis API proxy to work without a database
 */
@Module({})
export class OptionalDatabaseModule {
  static forRoot(): DynamicModule {
    const dbEnabled = process.env.DB_ENABLED?.toLowerCase() !== 'false';
    
    if (!dbEnabled) {
      console.log('⚠️  Database module disabled (DB_ENABLED=false). Food Analysis API proxy will work without database.');
      return {
        module: OptionalDatabaseModule,
        imports: [],
        exports: [],
      };
    }

    return {
      module: OptionalDatabaseModule,
      imports: [
        TypeOrmModule.forRootAsync({
          imports: [ConfigModule],
          useFactory: (configService: ConfigService) => {
            // Prefer DATABASE_URL if provided (Supabase connection string)
            const databaseUrl = configService.get('DATABASE_URL');
            const directUrl = configService.get('DIRECT_URL');
            
            // Use connection URL if available (recommended for Supabase)
            if (databaseUrl || directUrl) {
              const url = directUrl || databaseUrl;
              
              return {
                type: 'postgres',
                url: url,
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
                // Supabase requires SSL
                ssl: { rejectUnauthorized: false },
                retryAttempts: 3,
                retryDelay: 2000,
                autoLoadEntities: false,
                extra: {
                  max: 10,
                  idleTimeoutMillis: 30000,
                  connectionTimeoutMillis: 10000,
                },
              };
            }
            
            // Fallback to individual parameters if DATABASE_URL not provided
            const dbHost = configService.get('DB_HOST', 'db.pnihaeljbyjiexnfolir.supabase.co');
            const isSupabase = dbHost.includes('supabase.co');
            const dbPassword = configService.get('DB_PASSWORD');
            
            if (!dbPassword) {
              throw new Error('Database password is required. Set DB_PASSWORD in .env or use DATABASE_URL connection string.');
            }
            
            return {
              type: 'postgres',
              host: dbHost,
              port: configService.get('DB_PORT', 5432),
              username: configService.get('DB_USERNAME', 'postgres'),
              password: dbPassword,
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
              ssl: isSupabase ? { rejectUnauthorized: false } : (configService.get('NODE_ENV') === 'production' ? { rejectUnauthorized: false } : false),
              retryAttempts: 3,
              retryDelay: 2000,
              autoLoadEntities: false,
              extra: isSupabase ? {
                max: 10,
                idleTimeoutMillis: 30000,
                connectionTimeoutMillis: 10000,
              } : {},
            };
          },
          inject: [ConfigService],
        }),
      ],
      exports: [TypeOrmModule],
    };
  }
}

