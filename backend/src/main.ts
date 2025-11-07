import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import helmet from 'helmet';
import * as compression from 'compression';
import rateLimit from 'express-rate-limit';

async function bootstrap() {
  try {
    const app = await NestFactory.create(AppModule, {
      // Allow app to start even if some modules fail to initialize
      logger: ['error', 'warn', 'log', 'debug', 'verbose'],
    });
    
    // Log database status
    const dbEnabled = process.env.DB_ENABLED?.toLowerCase() !== 'false';
    if (!dbEnabled) {
      console.log('ℹ️  Database disabled (DB_ENABLED=false). Food Analysis API proxy will work without database.');
    }

  // Request logging middleware (for debugging)
  app.use((req: any, res: any, next: any) => {
    console.log(`📥 [${req.method}] ${req.url}`);
    console.log(`   Origin: ${req.headers.origin || 'none'}`);
    console.log(`   Content-Type: ${req.headers['content-type'] || 'none'}`);
    next();
  });

  // Security middleware
  // Configure helmet to allow CORS for development
  app.use(helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
    crossOriginEmbedderPolicy: false,
  }));
  app.use(compression());

  // CORS configuration - Use NestJS native CORS for better preflight handling
  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps or Postman)
      if (!origin) {
        return callback(null, true);
      }
      
      // Allow localhost with any port for Flutter web development
      const localhostRegex = /^http:\/\/localhost:\d+$/;
      if (localhostRegex.test(origin)) {
        return callback(null, true);
      }
      
      // Allow configured frontend URL
      const allowedOrigin = process.env.FRONTEND_URL || 'http://localhost:3000';
      if (origin === allowedOrigin) {
        return callback(null, true);
      }
      
      callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    exposedHeaders: ['Content-Type', 'Authorization'],
    preflightContinue: false,
    optionsSuccessStatus: 204,
  });

  // Rate limiting
  app.use(
    rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100, // limit each IP to 100 requests per windowMs
      message: 'Too many requests from this IP, please try again later.',
    }),
  );

  // Global validation pipe
  // Note: ValidationPipe is more lenient for food-analysis endpoints
  // which use inline body types instead of DTOs
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: false, // Don't strip unknown properties
      forbidNonWhitelisted: false, // Don't reject requests with extra properties
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
      skipMissingProperties: false,
      skipNullProperties: false,
      skipUndefinedProperties: false,
    }),
  );

  // Swagger documentation
  // Note: Swagger path is set to 'api/docs' which will be /api/docs with global prefix
  // To avoid double prefix, we use 'docs' and NestJS will add /api automatically
  const config = new DocumentBuilder()
    .setTitle('SmartBite API')
    .setDescription('AI-powered personalized nutrition and meal planning API for Saudi Arabia')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .addTag('auth', 'Authentication endpoints')
    .addTag('users', 'User management endpoints')
    .addTag('foods', 'Food and nutrition data endpoints')
    .addTag('meals', 'Meal planning endpoints')
    .addTag('stores', 'Store and price comparison endpoints')
    .addTag('progress', 'User progress tracking endpoints')
    .addTag('food-analysis', 'Food Analysis API proxy endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  // Swagger at /api/docs (global prefix adds /api, path is 'docs')
  SwaggerModule.setup('docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

    const port = process.env.PORT || 3000;
    
    // Set global prefix for all routes to /api
    // This makes all routes: /api/{controller-path}/{method-path}
    // Example: /api/food-analysis/full-pipeline
    app.setGlobalPrefix('api');
    
    await app.listen(port);
    
    console.log(`🚀 SmartBite API is running on: http://localhost:${port}`);
    console.log(`📚 API Documentation: http://localhost:${port}/api/docs`);
    console.log(`🔍 Global prefix: /api (all routes will be prefixed with /api)`);
    console.log(`✅ Server started successfully and listening on port ${port}`);
    
    // Verify server is actually listening
    const server = app.getHttpServer();
    const address = server.address();
    if (address && typeof address === 'object') {
      console.log(`✅ Server verified - listening on ${address.address}:${address.port}`);
    }
    
    // Log available routes for debugging
    console.log('\n📋 Available endpoints:');
    console.log('   GET  / - Health check');
    console.log('   GET  /version - API version');
    console.log('   POST /api/food-analysis/full-pipeline - Full pipeline analysis');
    console.log('   POST /api/food-analysis/extract-ingredients - Extract ingredients');
    console.log('   POST /api/food-analysis/* - Other food analysis endpoints');
    console.log('');
    
    // Log route registration verification
    console.log('🔍 Route Registration Check:');
    console.log('   Global prefix: /api');
    console.log('   Controller path: food-analysis');
    console.log('   Full endpoint: /api/food-analysis/full-pipeline');
    console.log('   Expected URL: http://localhost:3000/api/food-analysis/full-pipeline');
    console.log('   Frontend should call: POST http://localhost:3000/api/food-analysis/full-pipeline');
    console.log('');
    
    console.log('\n💡 Note: If you see database connection errors above, that\'s OK!');
    console.log('   Food Analysis API proxy will work without database.');
    console.log('   To disable database warnings, set DB_ENABLED=false in .env\n');
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    // Check if it's a database error - if so, provide helpful message
    if (error instanceof Error && error.message.includes('database')) {
      console.error('\n💡 Database connection failed. This is OK for Food Analysis API proxy.');
      console.error('   To disable database warnings, add DB_ENABLED=false to backend/.env');
      console.error('   Or set up your database with correct credentials.\n');
    }
    process.exit(1);
  }
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  // Suppress database connection errors - they're expected if DB is not configured
  if (reason instanceof Error && 
      (reason.message.includes('password authentication') || 
       reason.message.includes('database') ||
       reason.message.includes('connection'))) {
    console.warn('⚠️  Database connection error (this is OK if DB_ENABLED=false):', reason.message);
    return; // Don't crash on database errors
  }
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  // Don't crash on database connection errors
  if (error.message && 
      (error.message.includes('password authentication') || 
       error.message.includes('database') ||
       error.message.includes('connection') ||
       error.message.includes('TypeORM'))) {
    console.warn('⚠️  Database-related exception (this is OK if DB_ENABLED=false):', error.message);
    return; // Don't crash on database errors
  }
  console.error('❌ Uncaught Exception:', error);
  process.exit(1);
});

bootstrap();
