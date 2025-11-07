import { Injectable, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { UsdaApiService } from './usda-api.service';

/**
 * Food Analysis Service
 * 
 * Uses USDA FoodData Central API exclusively for nutrition data.
 * All IntRest API code has been removed.
 */
@Injectable()
export class FoodAnalysisService {
  private readonly logger = new Logger(FoodAnalysisService.name);

  constructor(
    private readonly usdaApiService: UsdaApiService,
  ) {
    this.logger.log('FoodAnalysisService initialized - using USDA API only');
  }

  /**
   * Full pipeline analysis - extracts ingredients, analyzes allergens,
   * checks diet compatibility, calculates nutrients, and generates labels
   * 
   * Uses USDA FoodData Central API directly
   */
  async fullPipelineAnalysis(
    dishName: string,
    dietTypes?: string[],
    foodDescription?: string,
    cuisineType?: string,
  ): Promise<any> {
    if (!dishName || dishName.trim().length < 2) {
      throw new HttpException(
        'Dish name must be at least 2 characters',
        HttpStatus.BAD_REQUEST,
      );
    }
    
    this.logger.log(`Full pipeline analysis using USDA API for: ${dishName}`);
    
    // Use USDA API directly
    return await this.getUsdaNutritionData(dishName);
  }

  /**
   * Get nutrition data from USDA API
   * 
   * @param dishName Name of the dish/food
   * @returns Nutrition data in a format compatible with the app
   */
  private async getUsdaNutritionData(dishName: string): Promise<any> {
    try {
      this.logger.log(`Fetching nutrition data from USDA API for: ${dishName}`);
      
      // Search USDA API for the food
      const usdaResult = await this.usdaApiService.searchAndGetNutrition(dishName);
      
      if (!usdaResult) {
        throw new HttpException(
          `No nutrition data found in USDA API for: ${dishName}`,
          HttpStatus.NOT_FOUND,
        );
      }

      const nutrition = usdaResult.nutrition;
      
      // Convert USDA format to app-compatible format
      // Maintains compatibility with existing Flutter app code
      // Ensure all string fields are non-null
      const foodName = nutrition.name || dishName || 'Unknown Food';
      const servingSize = nutrition.servingSize || '1 serving';
      
      return {
        source: 'usda',
        foodName: foodName,
        totalCalories: nutrition.calories || 0,
        macronutrients: {
          protein: nutrition.protein || 0,
          carbohydrates: nutrition.carbs || 0,
          fat: nutrition.fat || 0,
        },
        nutrients: [
          { name: 'Fiber', value: nutrition.fiber || 0, unit: 'g' },
          { name: 'Sugar', value: nutrition.sugar || 0, unit: 'g' },
          { name: 'Sodium', value: nutrition.sodium || 0, unit: 'mg' },
        ],
        ingredients: [
          {
            name: foodName,
            category: 'main',
            quantity: 1,
            unit: servingSize,
          },
        ],
        allergens: [], // USDA doesn't provide allergen info
        dietCompatibility: {}, // USDA doesn't provide diet compatibility
        labels: [], // USDA doesn't provide labels
        // Keep raw USDA data for reference
        _usdaData: usdaResult.rawData,
      };
    } catch (error: any) {
      this.logger.error(`USDA API failed: ${error.message}`);
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        `USDA API error: ${error.message}`,
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }
}
