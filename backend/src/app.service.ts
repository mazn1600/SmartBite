import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth(): { status: string; message: string; timestamp: string } {
    return {
      status: 'healthy',
      message: 'SmartBite API is running successfully',
      timestamp: new Date().toISOString(),
    };
  }

  getVersion(): { version: string; name: string; description: string } {
    return {
      version: '1.0.0',
      name: 'SmartBite API',
      description: 'AI-powered personalized nutrition and meal planning API for Saudi Arabia',
    };
  }
}
