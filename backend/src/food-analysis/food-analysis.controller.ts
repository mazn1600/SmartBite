import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  HttpException,
  Logger,
  Req,
  Options,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { FoodAnalysisService } from './food-analysis.service';
import { Request } from 'express';

@ApiTags('food-analysis')
@Controller('food-analysis') // Will be /api/food-analysis/* if global prefix is set, or /food-analysis/* if not
export class FoodAnalysisController {
  private readonly logger = new Logger(FoodAnalysisController.name);

  constructor(private readonly foodAnalysisService: FoodAnalysisService) {}

  // Handle OPTIONS preflight requests for CORS
  @Options('*')
  @HttpCode(HttpStatus.NO_CONTENT)
  handleOptions(@Req() req: Request) {
    this.logger.log(`OPTIONS preflight request for: ${req.url}`);
    return '';
  }

  @Post('extract-ingredients')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Extract ingredients from a dish name' })
  @ApiResponse({ status: 200, description: 'Ingredients extracted successfully' })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async extractIngredients(@Body() body: { dishName: string }) {
    try {
      return await this.foodAnalysisService.extractIngredients(body.dishName);
    } catch (error) {
      throw error;
    }
  }

  @Post('analyze-allergens/dish')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Analyze allergens by dish name' })
  @ApiResponse({ status: 200, description: 'Allergens analyzed successfully' })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async analyzeAllergensByDish(@Body() body: { dishName: string }) {
    try {
      return await this.foodAnalysisService.analyzeAllergensByDish(
        body.dishName,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('analyze-allergens/ingredients')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Analyze allergens by ingredient list' })
  @ApiResponse({ status: 200, description: 'Allergens analyzed successfully' })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async analyzeAllergensByIngredients(
    @Body() body: { ingredients: string[] },
  ) {
    try {
      return await this.foodAnalysisService.analyzeAllergensByIngredients(
        body.ingredients,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('extract-ingredients-analyze-allergens')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Extract ingredients and analyze allergens in one call',
  })
  @ApiResponse({ status: 200, description: 'Analysis completed successfully' })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async extractIngredientsAndAnalyzeAllergens(
    @Body() body: { dishName: string },
  ) {
    try {
      return await this.foodAnalysisService.extractIngredientsAndAnalyzeAllergens(
        body.dishName,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('analyze-diet-compatibility/dish')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Analyze diet compatibility by dish name' })
  @ApiResponse({
    status: 200,
    description: 'Diet compatibility analyzed successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async analyzeDietCompatibilityByDish(
    @Body() body: { dishName: string; dietTypes?: string[] },
  ) {
    try {
      return await this.foodAnalysisService.analyzeDietCompatibilityByDish(
        body.dishName,
        body.dietTypes,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('analyze-diet-compatibility/ingredients')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Analyze diet compatibility by ingredient list' })
  @ApiResponse({
    status: 200,
    description: 'Diet compatibility analyzed successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async analyzeDietCompatibilityByIngredients(
    @Body() body: { ingredients: string[]; dietTypes?: string[] },
  ) {
    try {
      return await this.foodAnalysisService.analyzeDietCompatibilityByIngredients(
        body.ingredients,
        body.dietTypes,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('extract-ingredients-analyze-diet')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Extract ingredients and analyze diet compatibility',
  })
  @ApiResponse({
    status: 200,
    description: 'Analysis completed successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async extractIngredientsAndAnalyzeDiet(
    @Body() body: { dishName: string; dietTypes?: string[] },
  ) {
    try {
      return await this.foodAnalysisService.extractIngredientsAndAnalyzeDiet(
        body.dishName,
        body.dietTypes,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('calculate-nutrients')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Calculate nutrients for ingredient list' })
  @ApiResponse({
    status: 200,
    description: 'Nutrients calculated successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async calculateNutrients(
    @Body()
    body: {
      ingredients: string[];
      quantities?: Record<string, number>;
    },
  ) {
    try {
      return await this.foodAnalysisService.calculateNutrients(
        body.ingredients,
        body.quantities,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('generate-nutrient-labels')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Generate nutrient labels from nutrient list' })
  @ApiResponse({
    status: 200,
    description: 'Labels generated successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async generateNutrientLabels(@Body() body: { nutrients: any[] }) {
    try {
      return await this.foodAnalysisService.generateNutrientLabels(
        body.nutrients,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('extract-ingredients-calculate-nutrients')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Extract ingredients and calculate nutrients',
  })
  @ApiResponse({
    status: 200,
    description: 'Analysis completed successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async extractIngredientsAndCalculateNutrients(
    @Body()
    body: {
      dishName: string;
      quantities?: Record<string, number>;
    },
  ) {
    try {
      return await this.foodAnalysisService.extractIngredientsAndCalculateNutrients(
        body.dishName,
        body.quantities,
      );
    } catch (error) {
      throw error;
    }
  }

  @Post('full-pipeline')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Full pipeline analysis using USDA FoodData Central API - calculates nutrients and generates nutrition data',
  })
  @ApiResponse({
    status: 200,
    description: 'Full pipeline analysis completed successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  async fullPipelineAnalysis(
    @Body() body: { dishName: string; dietTypes?: string[] },
    @Req() req: Request,
  ) {
    const requestId = Date.now().toString();
    try {
      this.logger.log(`[${requestId}] Full pipeline request received`);
      this.logger.log(`[${requestId}] Request body: ${JSON.stringify(body)}`);
      this.logger.log(`[${requestId}] Request method: ${req.method}`);
      this.logger.log(`[${requestId}] Request URL: ${req.url}`);
      this.logger.log(`[${requestId}] Request headers: ${JSON.stringify(req.headers)}`);
      this.logger.log(`[${requestId}] Request origin: ${req.headers.origin || 'none'}`);
      
      if (!body) {
        this.logger.error(`[${requestId}] Invalid request: body is null or undefined`);
        throw new HttpException(
          'Request body is required',
          HttpStatus.BAD_REQUEST,
        );
      }

      if (!body.dishName) {
        this.logger.error(`[${requestId}] Invalid request body: missing dishName`);
        this.logger.error(`[${requestId}] Received body keys: ${Object.keys(body).join(', ')}`);
        throw new HttpException(
          'dishName is required in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      this.logger.log(`[${requestId}] Calling FoodAnalysisService.fullPipelineAnalysis with dishName: ${body.dishName}`);
      const startTime = Date.now();
      
      const result = await this.foodAnalysisService.fullPipelineAnalysis(
        body.dishName,
        body.dietTypes,
      );
      
      const duration = Date.now() - startTime;
      this.logger.log(`[${requestId}] Full pipeline analysis completed successfully in ${duration}ms`);
      this.logger.log(`[${requestId}] Response keys: ${Object.keys(result || {}).join(', ')}`);
      
      return result;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      const errorStack = error instanceof Error ? error.stack : 'No stack trace';
      
      this.logger.error(`[${requestId}] Full pipeline error occurred`);
      this.logger.error(`[${requestId}] Error type: ${error?.constructor?.name || 'Unknown'}`);
      this.logger.error(`[${requestId}] Error message: ${errorMessage}`);
      this.logger.error(`[${requestId}] Error stack: ${errorStack}`);
      
      // Log full error details if available
      if (error instanceof HttpException) {
        this.logger.error(`[${requestId}] HTTP Status: ${error.getStatus()}`);
        this.logger.error(`[${requestId}] HTTP Response: ${JSON.stringify(error.getResponse())}`);
      }
      this.logger.error(`[${requestId}] Request details: ${JSON.stringify({
        method: req.method,
        url: req.url,
        body: body,
        headers: req.headers,
      })}`);
      
      // Re-throw to let NestJS handle the HTTP response
      throw error;
    }
  }
}

