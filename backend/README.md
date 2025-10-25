# SmartBite Backend API

A comprehensive NestJS backend API for the SmartBite nutrition and meal planning application.

## 🚀 Features

- **Authentication & Authorization** - JWT-based user authentication
- **User Management** - Complete user profile and health data management
- **Food Database** - Comprehensive nutrition database with Saudi food data
- **Meal Planning** - AI-powered personalized meal recommendations
- **Price Comparison** - Real-time price tracking across Saudi supermarkets
- **Progress Tracking** - Health metrics and progress visualization
- **API Documentation** - Swagger/OpenAPI documentation

## 🛠 Tech Stack

- **Framework**: NestJS (Node.js)
- **Database**: PostgreSQL with TypeORM
- **Authentication**: JWT with Passport
- **Validation**: Class-validator & Class-transformer
- **Documentation**: Swagger/OpenAPI
- **Security**: Helmet, CORS, Rate Limiting

## 📋 Prerequisites

- Node.js (v18 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smartbite/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your configuration:
   ```env
   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=smartbite
   DB_PASSWORD=smartbite123
   DB_NAME=smartbite

   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-here
   JWT_EXPIRES_IN=7d

   # Application Configuration
   NODE_ENV=development
   PORT=3000
   FRONTEND_URL=http://localhost:3000
   ```

4. **Set up the database**
   ```bash
   # Create PostgreSQL database
   createdb smartbite

   # Run migrations (when available)
   npm run migration:run
   ```

5. **Start the development server**
   ```bash
   npm run start:dev
   ```

## 📚 API Documentation

Once the server is running, visit:
- **API Documentation**: http://localhost:3000/api/docs
- **Health Check**: http://localhost:3000

## 🗄 Database Schema

The API uses PostgreSQL with the following main entities:

- **Users** - User profiles and health data
- **Foods** - Nutrition database with Saudi food data
- **MealPlans** - Weekly meal planning
- **MealFoods** - Individual meal items
- **Stores** - Saudi supermarket chains
- **FoodPrices** - Price tracking across stores
- **UserProgress** - Health metrics tracking
- **UserFavorites** - User's favorite foods
- **UserFeedback** - Meal recommendations feedback

## 🔐 Authentication

The API uses JWT-based authentication:

1. **Register**: `POST /auth/register`
2. **Login**: `POST /auth/login`
3. **Get Profile**: `GET /auth/profile` (requires JWT token)

## 📊 API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/profile` - Get user profile

### Users
- `GET /users` - Get all users (admin)
- `GET /users/:id` - Get user by ID
- `PUT /users/:id` - Update user profile
- `DELETE /users/:id` - Delete user (admin)

### Foods
- `GET /foods` - Get all foods
- `GET /foods/:id` - Get food by ID
- `POST /foods` - Create new food (admin)
- `PUT /foods/:id` - Update food (admin)
- `DELETE /foods/:id` - Delete food (admin)

### Meals
- `GET /meals` - Get user's meal plans
- `POST /meals` - Create new meal plan
- `PUT /meals/:id` - Update meal plan
- `DELETE /meals/:id` - Delete meal plan

### Stores
- `GET /stores` - Get all stores
- `GET /stores/:id` - Get store by ID
- `GET /stores/:id/prices` - Get store prices

### Progress
- `GET /progress` - Get user progress
- `POST /progress` - Record progress
- `GET /progress/stats` - Get progress statistics

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 🚀 Deployment

1. **Build the application**
   ```bash
   npm run build
   ```

2. **Start production server**
   ```bash
   npm run start:prod
   ```

## 📝 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_HOST` | Database host | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_USERNAME` | Database username | smartbite |
| `DB_PASSWORD` | Database password | smartbite123 |
| `DB_NAME` | Database name | smartbite |
| `JWT_SECRET` | JWT secret key | - |
| `JWT_EXPIRES_IN` | JWT expiration | 7d |
| `NODE_ENV` | Environment | development |
| `PORT` | Server port | 3000 |
| `FRONTEND_URL` | Frontend URL | http://localhost:3000 |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support, email support@smartbite.com or create an issue in the repository.
