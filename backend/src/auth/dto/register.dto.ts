import { IsEmail, IsString, MinLength, MaxLength, IsInt, Min, Max, IsDecimal, IsOptional, IsArray, IsIn } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';

export class RegisterDto {
  @ApiProperty({
    description: 'User email address',
    example: 'user@example.com',
  })
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @ApiProperty({
    description: 'User password',
    example: 'password123',
    minLength: 8,
  })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  @MaxLength(50, { message: 'Password must be less than 50 characters' })
  password: string;

  @ApiProperty({
    description: 'User full name',
    example: 'Ahmed Al-Rashid',
  })
  @IsString()
  @MinLength(2, { message: 'Name must be at least 2 characters long' })
  @MaxLength(50, { message: 'Name must be less than 50 characters' })
  name: string;

  @ApiProperty({
    description: 'User age',
    example: 25,
    minimum: 13,
    maximum: 120,
  })
  @IsInt({ message: 'Age must be a valid integer' })
  @Min(13, { message: 'Age must be at least 13' })
  @Max(120, { message: 'Age must be less than 120' })
  @Transform(({ value }) => parseInt(value))
  age: number;

  @ApiProperty({
    description: 'User height in centimeters',
    example: 175.5,
    minimum: 100,
    maximum: 250,
  })
  @IsDecimal({}, { message: 'Height must be a valid decimal number' })
  @Min(100, { message: 'Height must be at least 100 cm' })
  @Max(250, { message: 'Height must be less than 250 cm' })
  @Transform(({ value }) => parseFloat(value))
  height: number;

  @ApiProperty({
    description: 'User weight in kilograms',
    example: 70.5,
    minimum: 20,
    maximum: 300,
  })
  @IsDecimal({}, { message: 'Weight must be a valid decimal number' })
  @Min(20, { message: 'Weight must be at least 20 kg' })
  @Max(300, { message: 'Weight must be less than 300 kg' })
  @Transform(({ value }) => parseFloat(value))
  weight: number;

  @ApiProperty({
    description: 'User target weight in kilograms',
    example: 65.0,
    required: false,
  })
  @IsOptional()
  @IsDecimal({}, { message: 'Target weight must be a valid decimal number' })
  @Min(20, { message: 'Target weight must be at least 20 kg' })
  @Max(300, { message: 'Target weight must be less than 300 kg' })
  @Transform(({ value }) => value ? parseFloat(value) : undefined)
  target_weight?: number;

  @ApiProperty({
    description: 'User gender',
    example: 'male',
    enum: ['male', 'female', 'other'],
  })
  @IsString()
  @IsIn(['male', 'female', 'other'], { message: 'Gender must be male, female, or other' })
  gender: string;

  @ApiProperty({
    description: 'User activity level',
    example: 'moderately_active',
    enum: ['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'],
  })
  @IsString()
  @IsIn(['sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active'], {
    message: 'Activity level must be one of: sedentary, lightly_active, moderately_active, very_active, extremely_active',
  })
  activity_level: string;

  @ApiProperty({
    description: 'User goal',
    example: 'weight_loss',
    enum: ['weight_loss', 'weight_gain', 'maintenance', 'muscle_gain'],
  })
  @IsString()
  @IsIn(['weight_loss', 'weight_gain', 'maintenance', 'muscle_gain'], {
    message: 'Goal must be one of: weight_loss, weight_gain, maintenance, muscle_gain',
  })
  goal: string;

  @ApiProperty({
    description: 'User allergies',
    example: ['gluten', 'dairy'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  allergies?: string[];

  @ApiProperty({
    description: 'User health conditions',
    example: ['diabetes', 'hypertension'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  health_conditions?: string[];

  @ApiProperty({
    description: 'User food preferences',
    example: ['vegetarian', 'halal'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  food_preferences?: string[];
}
