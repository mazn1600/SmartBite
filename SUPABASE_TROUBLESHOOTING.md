# 🔍 Supabase Troubleshooting Guide - Step by Step

## Step 1: Verify Supabase Credentials ✅

### Check Your Current Configuration

Open `lib/core/config/supabase_config.dart` and verify:

```dart
static const String supabaseUrl = 'https://pnihaeljbyjiexnfolir.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### Get Your Supabase Credentials

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Select your project: `pnihaeljbyjiexnfolir`
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** → `supabaseUrl`
   - **anon/public key** → `supabaseAnonKey`

### Test Credentials

Run this in your terminal:

```bash
# Test if URL is accessible
curl https://pnihaeljbyjiexnfolir.supabase.co/rest/v1/

# Should return JSON (even if it's an error, it means connection works)
```

**✅ Step 1 Complete:** Credentials verified

---

## Step 2: Test Supabase Initialization 🔌

### Check App Startup Logs

When you run `flutter run -d chrome`, look for these messages in the terminal:

```
🔌 Initializing Supabase connection...
✅ Supabase initialized successfully
✅ Supabase connection test successful
```

### If You See Errors:

**Error: "Failed to initialize Supabase"**
- Check your internet connection
- Verify Supabase URL is correct
- Check if Supabase project is active (not paused)

**Error: "Invalid API key"**
- Verify `supabaseAnonKey` is correct
- Make sure you're using the **anon/public** key, not the **service_role** key

### Manual Test

Add this temporary test in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔌 Step 2: Testing Supabase initialization...');
    await SupabaseConfig.initialize();
    print('✅ Step 2 PASSED: Supabase initialized');
    
    // Test client access
    final client = SupabaseConfig.client;
    print('✅ Step 2 PASSED: Client accessible');
    
    // Test connection
    final response = await client.from('users').select('count').limit(1);
    print('✅ Step 2 PASSED: Database connection works');
  } catch (e) {
    print('❌ Step 2 FAILED: $e');
  }
  
  runApp(const SmartBiteApp());
}
```

**✅ Step 2 Complete:** Initialization working

---

## Step 3: Test Authentication 🔐

### Test Login Flow

1. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Navigate to login screen**
3. **Try to login with test credentials**

### Check Authentication Logs

Look for these messages in terminal:

```
AuthService: Attempting to sign in...
AuthService: Sign in successful
AuthService: User profile fetched from database
```

### Common Authentication Issues:

**Issue: "Invalid login credentials"**
- Verify user exists in Supabase Auth
- Check email/password are correct
- Check Supabase Auth settings allow email/password

**Issue: "User not found in database"**
- User might be in Auth but not in `users` table
- Check if user profile creation is working

### Manual Authentication Test

Add this test function:

```dart
Future<void> testAuthentication() async {
  try {
    print('🔐 Step 3: Testing authentication...');
    
    final client = SupabaseConfig.client;
    
    // Test sign up (if needed)
    final response = await client.auth.signUp(
      email: 'test@example.com',
      password: 'testpassword123',
    );
    
    if (response.user != null) {
      print('✅ Step 3 PASSED: Sign up works');
    }
    
    // Test sign in
    final signInResponse = await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'testpassword123',
    );
    
    if (signInResponse.user != null) {
      print('✅ Step 3 PASSED: Sign in works');
      print('   User ID: ${signInResponse.user!.id}');
    }
    
  } catch (e) {
    print('❌ Step 3 FAILED: $e');
  }
}
```

**✅ Step 3 Complete:** Authentication working

---

## Step 4: Test Database Connection 📊

### Test Database Queries

1. **Check if tables exist:**
   ```dart
   Future<void> testDatabaseTables() async {
     try {
       print('📊 Step 4: Testing database tables...');
       final client = SupabaseConfig.client;
       
       // Test users table
       final users = await client.from('users').select('count').limit(1);
       print('✅ Step 4 PASSED: users table accessible');
       
       // Test foods table
       final foods = await client.from('foods').select('count').limit(1);
       print('✅ Step 4 PASSED: foods table accessible');
       
       // Test stores table
       final stores = await client.from('stores').select('count').limit(1);
       print('✅ Step 4 PASSED: stores table accessible');
       
     } catch (e) {
       print('❌ Step 4 FAILED: $e');
       print('   Check: Table exists? RLS policies allow access?');
     }
   }
   ```

### Common Database Issues:

**Error: "relation does not exist"**
- Table doesn't exist in Supabase
- Check table name spelling
- Run migrations if needed

**Error: "permission denied"**
- RLS (Row Level Security) policies blocking access
- Check Supabase Dashboard → Authentication → Policies
- Verify policies allow anonymous or authenticated access

**Error: "JWT expired"**
- Token refresh might be failing
- Check `autoRefreshToken: true` in config

**✅ Step 4 Complete:** Database accessible

---

## Step 5: Test User Profile Creation 👤

### Test Profile Flow

1. **Register a new user**
2. **Check if profile is created in `users` table**

### Check Profile Creation

```dart
Future<void> testProfileCreation() async {
  try {
    print('👤 Step 5: Testing profile creation...');
    final client = SupabaseConfig.client;
    final user = SupabaseConfig.currentUser;
    
    if (user == null) {
      print('⚠️  Step 5 SKIPPED: No user logged in');
      return;
    }
    
    // Check if profile exists
    final profile = await client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    
    if (profile != null) {
      print('✅ Step 5 PASSED: User profile exists');
      print('   Name: ${profile['first_name']} ${profile['last_name']}');
    } else {
      print('⚠️  Step 5 WARNING: User profile not found');
      print('   Profile should be created during registration');
    }
    
  } catch (e) {
    print('❌ Step 5 FAILED: $e');
  }
}
```

### Common Profile Issues:

**Issue: "Profile not created after registration"**
- Check `auth_service.dart` → `createUserProfile()` method
- Verify it's called after successful sign up
- Check for errors in registration flow

**Issue: "Profile update fails"**
- Check RLS policies allow UPDATE on `users` table
- Verify user can only update their own profile

**✅ Step 5 Complete:** Profile creation working

---

## Step 6: Check RLS Policies 🔒

### Verify Row Level Security

1. Go to Supabase Dashboard
2. Navigate to **Authentication** → **Policies**
3. Check each table has appropriate policies:

**Required Policies:**

| Table | Policy Type | Who Can Access |
|-------|-------------|----------------|
| `users` | SELECT, UPDATE | Authenticated users (own data) |
| `foods` | SELECT | Everyone (anonymous + authenticated) |
| `stores` | SELECT | Everyone |
| `food_prices` | SELECT | Everyone |
| `meal_plans` | ALL | Authenticated users (own data) |
| `user_favorites` | ALL | Authenticated users (own data) |

### Test RLS Policies

```dart
Future<void> testRLSPolicies() async {
  try {
    print('🔒 Step 6: Testing RLS policies...');
    final client = SupabaseConfig.client;
    
    // Test anonymous read (should work for foods, stores)
    final foods = await client.from('foods').select().limit(1);
    print('✅ Step 6 PASSED: Anonymous can read foods');
    
    // Test authenticated write (should work if logged in)
    final user = SupabaseConfig.currentUser;
    if (user != null) {
      final profile = await client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      print('✅ Step 6 PASSED: Authenticated can read own profile');
    }
    
  } catch (e) {
    print('❌ Step 6 FAILED: $e');
    print('   Check RLS policies in Supabase Dashboard');
  }
}
```

**✅ Step 6 Complete:** RLS policies configured correctly

---

## Step 7: Test Real-Time Features (Optional) ⚡

### Check Realtime Connection

```dart
Future<void> testRealtime() async {
  try {
    print('⚡ Step 7: Testing realtime connection...');
    final client = SupabaseConfig.client;
    
    final channel = client
        .channel('test-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            print('✅ Step 7 PASSED: Realtime working');
          },
        )
        .subscribe();
    
    await Future.delayed(Duration(seconds: 2));
    await channel.unsubscribe();
    
  } catch (e) {
    print('❌ Step 7 FAILED: $e');
  }
}
```

**✅ Step 7 Complete:** Realtime working (optional)

---

## Quick Diagnostic Script

Create a test file: `test_supabase.dart`

```dart
import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Starting Supabase Diagnostics...\n');
  
  // Step 1: Initialize
  try {
    await SupabaseConfig.initialize();
    print('✅ Step 1: Initialization PASSED\n');
  } catch (e) {
    print('❌ Step 1: Initialization FAILED - $e\n');
    return;
  }
  
  // Step 2: Test connection
  try {
    final client = SupabaseConfig.client;
    await client.from('users').select('count').limit(1);
    print('✅ Step 2: Database connection PASSED\n');
  } catch (e) {
    print('❌ Step 2: Database connection FAILED - $e\n');
  }
  
  // Step 3: Test authentication
  try {
    final response = await client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'testpassword',
    );
    if (response.user != null) {
      print('✅ Step 3: Authentication PASSED\n');
    }
  } catch (e) {
    print('⚠️  Step 3: Authentication - $e\n');
  }
  
  print('🔍 Diagnostics complete!');
}
```

Run it:
```bash
flutter run -d chrome test_supabase.dart
```

---

## Common Error Solutions

### Error: "Network request failed"
- **Solution:** Check internet connection
- **Solution:** Verify Supabase project is not paused
- **Solution:** Check firewall/proxy settings

### Error: "Invalid API key"
- **Solution:** Verify you're using the **anon/public** key
- **Solution:** Regenerate key in Supabase Dashboard if needed

### Error: "JWT expired"
- **Solution:** Check `autoRefreshToken: true` in config
- **Solution:** Re-login to get fresh token

### Error: "permission denied for table"
- **Solution:** Check RLS policies in Supabase Dashboard
- **Solution:** Verify policies allow your operation (SELECT, INSERT, UPDATE, DELETE)

### Error: "relation does not exist"
- **Solution:** Table doesn't exist - create it or run migrations
- **Solution:** Check table name spelling (case-sensitive)

---

## Next Steps

Once all steps pass:

1. ✅ Remove test code
2. ✅ Test full user flow (register → login → use app)
3. ✅ Monitor Supabase Dashboard for errors
4. ✅ Check browser console for client-side errors

---

## Need Help?

If you're stuck on a specific step, share:
1. Which step failed
2. The exact error message
3. What you've tried so far

Then we can debug that specific issue together! 🚀

