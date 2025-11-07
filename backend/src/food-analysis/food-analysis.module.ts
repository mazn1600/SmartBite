import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { FoodAnalysisController } from './food-analysis.controller';
import { FoodAnalysisService } from './food-analysis.service';
import { UsdaApiService } from './usda-api.service';

@Module({
  imports: [
    HttpModule.register({
      timeout: 30000,
      maxRedirects: 5,
    }),
    ConfigModule,
  ],
  controllers: [FoodAnalysisController],
  providers: [FoodAnalysisService, UsdaApiService],
  exports: [FoodAnalysisService],
})
export class FoodAnalysisModule {}


