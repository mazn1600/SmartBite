import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from '../database/entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.userRepository.findOne({ where: { email } });
    if (user && await bcrypt.compare(password, user.password_hash)) {
      return user;
    }
    return null;
  }

  async login(loginDto: LoginDto): Promise<{ access_token: string; user: User }> {
    const user = await this.validateUser(loginDto.email, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload: JwtPayload = { sub: user.id, email: user.email };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user,
    };
  }

  async register(registerDto: RegisterDto): Promise<{ access_token: string; user: User }> {
    // Check if user already exists
    const existingUser = await this.userRepository.findOne({ where: { email: registerDto.email } });
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const saltRounds = 12;
    const password_hash = await bcrypt.hash(registerDto.password, saltRounds);

    // Create user
    const user = this.userRepository.create({
      ...registerDto,
      password_hash,
    });

    const savedUser = await this.userRepository.save(user);

    // Generate JWT token
    const payload: JwtPayload = { sub: savedUser.id, email: savedUser.email };
    const access_token = this.jwtService.sign(payload);

    return {
      access_token,
      user: savedUser,
    };
  }

  async findUserById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async findUserByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }
}
