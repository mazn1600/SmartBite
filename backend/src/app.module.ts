import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { OptionalDatabaseModule } from './database/database.module.optional';
import { FoodAnalysisModule } from './food-analysis/food-analysis.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';

/**
 * App Module
 * 
 * Main application module that imports:
 * - ConfigModule: For environment variables (.env file)
 * - FoodAnalysisModule: Food Analysis API proxy (doesn't need database)
 * - OptionalDatabaseModule: Database connection (optional, only if DB_ENABLED is not 'false')
 * - AuthModule: Authentication (only if database is enabled)
 * 
 * Note: Food Analysis API proxy will work even without database connection.
 * To disable database, set DB_ENABLED=false in .env file.
 */
@Module({
  imports: [
    // Load environment variables first (from .env file)
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      // Allow empty values for optional database config
      ignoreEnvFile: false,
      // Expand variables if needed
      expandVariables: false,
    }),
    // Food Analysis API proxy - always loaded (doesn't need database)
    FoodAnalysisModule,
    // Optional database module - loads if DB_ENABLED is not 'false'
    // Checks process.env at module load time
    OptionalDatabaseModule.forRoot(),
    // Note: AuthModule is conditionally loaded inside OptionalDatabaseModule
    // It will only be available if database connection succeeds
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
  constructor() {
    // Log database status at startup
    const dbEnabled = process.env.DB_ENABLED?.toLowerCase() !== 'false';
    if (dbEnabled) {
      console.log('ℹ️  Database module enabled - attempting to connect to Supabase');
    } else {
      console.log('ℹ️  Database module disabled (DB_ENABLED=false) - Food Analysis API proxy will work without database');
    }
  }
}
