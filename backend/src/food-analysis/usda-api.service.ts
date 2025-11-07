import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

/**
 * USDA FoodData Central API Service
 * 
 * Primary API for nutrition data.
 * Documentation: https://fdc.nal.usda.gov/api-guide/
 * 
 * Uses POST requests for search as recommended by USDA API documentation.
 */
@Injectable()
export class UsdaApiService {
  private readonly logger = new Logger(UsdaApiService.name);
  private readonly apiKey: string;
  private readonly baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
  ) {
    this.apiKey = this.configService.get<string>('USDA_API_KEY');
    if (!this.apiKey) {
      this.logger.warn('USDA_API_KEY not found in environment variables');
    }
  }

  /**
   * Search for foods by name
   * 
   * Uses POST request with JSON body as recommended by USDA API documentation
   * 
   * @param query Food name to search for
   * @param pageSize Number of results to return (default: 10)
   * @returns List of matching foods with basic nutrition data
   */
  async searchFoods(query: string, pageSize = 10): Promise<any> {
    if (!this.apiKey) {
      throw new HttpException(
        'USDA API key not configured',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    try {
      const url = `${this.baseUrl}/foods/search`;
      const params = {
        api_key: this.apiKey,
      };
      
      // Use POST request with JSON body as shown in USDA API documentation
      const body = {
        query: query,
        pageSize: pageSize,
        dataType: ['Foundation', 'SR Legacy'], // Focus on reliable data sources
        sortBy: 'fdcId',
        sortOrder: 'desc',
      };

      this.logger.log(`Searching USDA API for: ${query}`);
      this.logger.debug(`USDA search body: ${JSON.stringify(body)}`);
      
      const response = await firstValueFrom(
        this.httpService.post(url, body, { 
          params,
          headers: {
            'Content-Type': 'application/json',
          },
        }),
      );

      if (response.status === 200 && response.data) {
        this.logger.log(`Found ${response.data.foods?.length || 0} results from USDA`);
        return response.data;
      }

      throw new HttpException(
        'USDA API returned unexpected response',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    } catch (error: any) {
      if (error.response) {
        this.logger.error(`USDA API error: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
        throw new HttpException(
          `USDA API error: ${error.response.data?.message || error.response.statusText}`,
          error.response.status,
        );
      }
      this.logger.error(`USDA API request failed: ${error.message}`);
      throw new HttpException(
        `USDA API request failed: ${error.message}`,
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }

  /**
   * Get detailed food information by FDC ID
   * 
   * Uses GET request as shown in USDA API documentation
   * 
   * @param fdcId FoodData Central ID
   * @returns Detailed food nutrition data
   */
  async getFoodDetails(fdcId: number): Promise<any> {
    if (!this.apiKey) {
      throw new HttpException(
        'USDA API key not configured',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    try {
      const url = `${this.baseUrl}/food/${fdcId}`;
      const params = {
        api_key: this.apiKey,
        // Note: nutrients parameter is optional - omitting gets all nutrients
      };

      this.logger.log(`Fetching USDA food details for FDC ID: ${fdcId}`);
      const response = await firstValueFrom(
        this.httpService.get(url, { params }),
      );

      if (response.status === 200 && response.data) {
        this.logger.debug(`Successfully fetched USDA food details for FDC ID: ${fdcId}`);
        return response.data;
      }

      throw new HttpException(
        'USDA API returned unexpected response',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    } catch (error: any) {
      if (error.response) {
        this.logger.error(`USDA API error: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
        throw new HttpException(
          `USDA API error: ${error.response.data?.message || error.response.statusText}`,
          error.response.status,
        );
      }
      this.logger.error(`USDA API request failed: ${error.message}`);
      throw new HttpException(
        `USDA API request failed: ${error.message}`,
        HttpStatus.SERVICE_UNAVAILABLE,
      );
    }
  }

  /**
   * Convert USDA food data to a simplified nutrition format
   * Compatible with our meal generation system
   * 
   * @param usdaFood USDA food data object
   * @returns Simplified nutrition data
   */
  convertUsdaToNutritionData(usdaFood: any): {
    name: string;
    calories: number;
    protein: number;
    carbs: number;
    fat: number;
    fiber?: number;
    sugar?: number;
    sodium?: number;
    servingSize?: string;
  } {
    const nutrients = usdaFood.foodNutrients || [];
    
    // Helper to find nutrient by ID or name
    const findNutrient = (id: number, name?: string) => {
      return nutrients.find((n: any) => 
        n.nutrient?.id === id || 
        (name && n.nutrient?.name?.toLowerCase().includes(name.toLowerCase()))
      );
    };

    // Standard nutrient IDs from USDA
    // Energy (kcal) = 1008
    // Protein = 1003
    // Carbohydrate = 1005
    // Total lipid (fat) = 1004
    // Fiber = 1079
    // Sugars = 2000
    // Sodium = 1093

    const energy = findNutrient(1008, 'energy')?.amount || 0;
    const protein = findNutrient(1003, 'protein')?.amount || 0;
    const carbs = findNutrient(1005, 'carbohydrate')?.amount || 0;
    const fat = findNutrient(1004, 'total lipid')?.amount || 0;
    const fiber = findNutrient(1079, 'fiber')?.amount || 0;
    const sugar = findNutrient(2000, 'sugars')?.amount || 0;
    const sodium = findNutrient(1093, 'sodium')?.amount || 0;

    return {
      name: usdaFood.description || usdaFood.foodDescription || 'Unknown Food',
      calories: Math.round(energy),
      protein: Math.round(protein * 10) / 10, // Round to 1 decimal
      carbs: Math.round(carbs * 10) / 10,
      fat: Math.round(fat * 10) / 10,
      fiber: Math.round(fiber * 10) / 10,
      sugar: Math.round(sugar * 10) / 10,
      sodium: Math.round(sodium * 10) / 10,
      servingSize: usdaFood.servingSize || '100g',
    };
  }

  /**
   * Search for a food and return the best match with nutrition data
   * 
   * @param foodName Name of the food to search for
   * @returns Nutrition data for the best matching food, or null if not found
   */
  async searchAndGetNutrition(foodName: string): Promise<any | null> {
    try {
      // Search for the food using POST request
      const searchResults = await this.searchFoods(foodName, 5);
      
      if (!searchResults.foods || searchResults.foods.length === 0) {
        this.logger.warn(`No USDA results found for: ${foodName}`);
        return null;
      }

      // Get the first result (best match)
      const bestMatch = searchResults.foods[0];
      
      // If we have detailed data, use it; otherwise fetch details
      let foodData = bestMatch;
      if (bestMatch.fdcId && (!bestMatch.foodNutrients || bestMatch.foodNutrients.length === 0)) {
        foodData = await this.getFoodDetails(bestMatch.fdcId);
      }

      // Convert to our format
      const nutritionData = this.convertUsdaToNutritionData(foodData);
      
      this.logger.log(`USDA API successful for: ${foodName}`);
      return {
        source: 'usda',
        foodName: nutritionData.name,
        nutrition: nutritionData,
        rawData: foodData, // Keep raw data for reference
      };
    } catch (error: any) {
      this.logger.error(`USDA API failed for ${foodName}: ${error.message}`);
      return null;
    }
  }
}

