# 🥗 SmartBite

**SmartBite** is a cross-platform health and nutrition recommendation system that provides *personalized meal plans* and *price optimization* for users in Saudi Arabia based on their **BMI, BMR, and dietary preferences**.

Built with **Flutter**, **NestJS**, **Supabase**, and **PostgreSQL**, following modern software engineering practices.

---

## 🚀 Project Overview

SmartBite helps users improve their eating habits by combining **AI-driven meal recommendations** with **real-time price comparisons** across Saudi supermarkets. It aims to promote affordable and healthy eating habits for students and health-conscious individuals.

---

## 🧠 Features

- 🧩 **Personalized Meal Recommendations** (AI-powered)
- 📊 **Health Metrics** — BMI, BMR, and TDEE calculations
- 🛒 **Price Comparison** — Find cheapest meal ingredients across major stores (Othaim, Panda, Lulu, Carrefour, Danube, Tamimi)
- 📱 **Cross-platform App** — Built with Flutter for Android & iOS
- 🔐 **Secure Authentication** — Supabase Auth with JWT
- 📈 **Progress Tracking** — Visualize health progress over time
- 🍽️ **Meal Planning** — Create and manage weekly meal plans
- 🔍 **Food Search & Barcode Scanning** — Quickly find nutritional information
- 👤 **User Profiles** — Track personal health goals and preferences

---

## 🏗 Tech Stack

| Layer | Technology | Description |
|-------|-------------|-------------|
| **Frontend** | Flutter (Dart) | Cross-platform mobile app |
| **Backend** | Supabase | Backend-as-a-Service with PostgreSQL |
| **Database** | PostgreSQL | Relational database via Supabase |
| **Authentication** | Supabase Auth | Secure user authentication |
| **State Management** | Provider | Flutter state management |
| **Navigation** | GoRouter | Declarative routing |
| **API Integration** | HTTP/Dio | RESTful API communication |
| **Version Control** | GitHub | Source code management |

---

## 📂 Project Structure

```
smartbite/
├── lib/
│   ├── core/
│   │   ├── config/           # App configuration (Supabase, APIs)
│   │   ├── constants/        # Theme, constants, assets
│   │   └── routing/          # Navigation setup
│   ├── features/
│   │   ├── auth/             # Authentication screens & services
│   │   ├── food/             # Food search, barcode scanning
│   │   ├── home/             # Dashboard and quick stats
│   │   ├── meal_planning/    # Meal plans and recommendations
│   │   ├── onboarding/       # Splash and onboarding
│   │   ├── profile/          # User profile and settings
│   │   ├── progress/         # Health progress tracking
│   │   ├── store/            # Store locator and price comparison
│   │   └── voice/            # Voice food logging
│   ├── shared/
│   │   ├── models/           # Data models
│   │   ├── services/         # Shared services
│   │   ├── utils/            # Utilities and helpers
│   │   └── widgets/          # Reusable widgets
│   └── main.dart             # App entry point
├── assets/                   # Images and static assets
├── analysis_options.yaml     # Dart linting rules
├── pubspec.yaml             # Dependencies
└── README.md                # This file
```

---

## ⚙️ Getting Started

### Prerequisites

- **Flutter SDK** (>=3.4.3)
- **Dart SDK** (>=3.4.3 <4.0.0)
- **Supabase Account** (for backend)
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/smartbite.git
   cd smartbite
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Supabase credentials**:
   
   Create a `.env` file or use `--dart-define` flags:
   
   ```bash
   # Using dart-define (recommended for production)
   flutter run \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

   Or update `lib/core/config/supabase_config.dart` with your credentials (for development only).

4. **Run the app**:
   ```bash
   # Development mode
   flutter run

   # Release mode
   flutter run --release
   ```

---

## 🔧 Configuration

### Environment Variables

The app uses `--dart-define` for secure configuration:

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous key | Yes |

### Build Configuration

For production builds, use:

```bash
# Android
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx

# iOS
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📋 Code Quality

### Linting & Formatting

```bash
# Format code
dart format lib/

# Analyze code
flutter analyze

# Apply fixes
dart fix --apply
```

### Analysis Rules

The project uses strict linting rules defined in `analysis_options.yaml`:
- Prefer const constructors
- Avoid print statements (use `debugPrint`)
- Require explicit return types
- Enforce null safety

---

## 🔒 Security Notes

### Supabase Security Advisors

The project has the following security considerations:

1. **Anonymous Access Policies**: Several tables (`foods`, `stores`, `food_prices`, `food_categories`) allow anonymous read access for browsing before login. This is intentional for better UX.

2. **User Authentication**: User-specific data (meal plans, progress, favorites) is protected by RLS policies that check `auth.uid()`.

3. **Leaked Password Protection**: Enable in Supabase Auth settings for production:
   [Password Security Guide](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection)

4. **Search Path Security**: Database functions should have immutable search_path. Review:
   [Database Linter Guide](https://supabase.com/docs/guides/database/database-linter?lint=0011_function_search_path_mutable)

---

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- 🚧 Web (in development)
- 🚧 Desktop (future)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow the [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Run `flutter analyze` to catch issues
- Write meaningful commit messages

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

- **Developer**: [Your Name]
- **Project Type**: Senior Project / Capstone
- **Institution**: [Your University]
- **Year**: 2024-2025

---

## 📧 Contact

For questions or support, please contact:
- Email: your-email@example.com
- GitHub Issues: [Submit an issue](https://github.com/your-org/smartbite/issues)

---

## 🙏 Acknowledgments

- Supabase for backend infrastructure
- Open Food Facts for nutrition data
- Flutter community for excellent packages
- Saudi market data providers

---

Made with ❤️ for healthier eating in Saudi Arabia
