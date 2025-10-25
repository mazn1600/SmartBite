# 🚀 Supabase Setup Guide for SmartBite

This guide will help you set up Supabase for your SmartBite Flutter app.

## 📋 Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. Flutter development environment set up
3. Git (for version control)

## 🛠 Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `smartbite`
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose the closest region to your users
5. Click "Create new project"
6. Wait for the project to be created (usually takes 2-3 minutes)

## 🔑 Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Anon public key** (starts with `eyJ...`)

## ⚙️ Step 3: Configure Your Flutter App

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values with your actual credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_ACTUAL_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
  // ... rest of the code
}
```

## 🗄️ Step 4: Set Up the Database

1. In your Supabase dashboard, go to **SQL Editor**
2. Click "New query"
3. Copy and paste the entire content of `supabase_schema.sql`
4. Click "Run" to execute the SQL
5. This will create all necessary tables, indexes, and policies

## 🔐 Step 5: Configure Authentication

1. In your Supabase dashboard, go to **Authentication** → **Settings**
2. Configure the following:

### Site URL
- Set to: `io.supabase.smartbite://login-callback/`

### Redirect URLs
Add these URLs:
- `io.supabase.smartbite://login-callback/`
- `io.supabase.smartbite://reset-password/`

### Email Settings
- Enable email confirmations (recommended)
- Customize email templates if desired

### OAuth Providers (Optional)
- Enable Google OAuth if you want Google sign-in
- Enable Apple OAuth if you want Apple sign-in

## 📱 Step 6: Configure Deep Links (Android)

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="io.supabase.smartbite" />
    </intent-filter>
</activity>
```

## 🍎 Step 7: Configure Deep Links (iOS)

1. Open `ios/Runner/Info.plist`
2. Add the following inside the `<dict>` tag:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>io.supabase.smartbite</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.smartbite</string>
        </array>
    </dict>
</array>
```

## 🚀 Step 8: Install Dependencies and Run

1. Install the new dependencies:
```bash
flutter pub get
```

2. Run your app:
```bash
flutter run
```

## 🧪 Step 9: Test the Integration

1. **Test Authentication**:
   - Try signing up with a new account
   - Check if the user appears in Supabase dashboard under **Authentication** → **Users**

2. **Test Database Operations**:
   - Create a meal plan
   - Check if it appears in the `meal_plans` table in Supabase dashboard

3. **Test Real-time Features**:
   - Open the app on two devices
   - Create a meal plan on one device
   - Verify it appears on the other device in real-time

## 🔧 Step 10: Environment Configuration

For production, consider using environment variables:

1. Create a `.env` file in your project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

2. Add `.env` to your `.gitignore` file

3. Use a package like `flutter_dotenv` to load environment variables

## 📊 Step 11: Monitor Your App

1. **Database**: Monitor queries in **Database** → **Logs**
2. **Authentication**: Monitor auth events in **Authentication** → **Users**
3. **API**: Monitor API usage in **Settings** → **API**

## 🛡️ Security Best Practices

1. **Row Level Security (RLS)**: Already enabled in the schema
2. **API Keys**: Never commit your service role key to version control
3. **CORS**: Configure CORS settings in **Settings** → **API**
4. **Rate Limiting**: Consider implementing rate limiting for public endpoints

## 🐛 Troubleshooting

### Common Issues:

1. **"Invalid API key"**:
   - Check if you copied the correct anon key
   - Ensure there are no extra spaces or characters

2. **"CORS error"**:
   - Add your app's URL to the CORS settings in Supabase dashboard

3. **"Deep link not working"**:
   - Check if the URL scheme is correctly configured
   - Test on a physical device (not simulator)

4. **"Database connection failed"**:
   - Check if the database is running
   - Verify your connection string

### Getting Help:

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)

## 🎉 You're All Set!

Your SmartBite app is now connected to Supabase! You have:

✅ Real-time database
✅ User authentication
✅ Row-level security
✅ Real-time subscriptions
✅ Scalable backend infrastructure

Happy coding! 🚀
