import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('app')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'Get API health status' })
  @ApiResponse({ status: 200, description: 'API is healthy' })
  getHealth(): { status: string; message: string; timestamp: string } {
    return this.appService.getHealth();
  }

  @Get('version')
  @ApiOperation({ summary: 'Get API version information' })
  @ApiResponse({ status: 200, description: 'API version information' })
  getVersion(): { version: string; name: string; description: string } {
    return this.appService.getVersion();
  }
}
