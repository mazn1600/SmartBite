# Security Guidelines for SmartBite

## Overview

This document outlines the security considerations and best practices for the SmartBite application.

## Supabase Row Level Security (RLS)

### Current RLS Policies

#### Public Read Access (Intentional)

The following tables allow anonymous read access to enable browsing before user login:

1. **`public.foods`** - ✅ Allows anonymous users to browse food database
   - Policy: "Anyone can view foods"
   - Justification: Users need to see available foods before creating an account

2. **`public.stores`** - ✅ Allows anonymous users to view stores
   - Policy: "Anyone can view stores"
   - Justification: Store locations are public information

3. **`public.food_prices`** - ✅ Allows anonymous users to compare prices
   - Policy: "Anyone can view food prices"
   - Justification: Price comparison feature should work without login

4. **`public.food_categories`** - ✅ Allows anonymous users to browse categories
   - Policy: "Anyone can view food categories"
   - Justification: Categories are public metadata

#### User-Specific Data (Protected)

The following tables are protected and only accessible to authenticated users:

1. **`public.users`**
   - Policies:
     - "Users can view own profile" - `auth.uid() = id`
     - "Users can update own profile" - `auth.uid() = id`
   - ✅ Properly secured with RLS

2. **`public.meal_plans`**
   - Policies:
     - "Users can view own meal plans" - `auth.uid() = user_id`
     - "Users can update own meal plans" - `auth.uid() = user_id`
     - "Users can delete own meal plans" - `auth.uid() = user_id`
   - ✅ Properly secured with RLS

3. **`public.user_progress`**
   - Policies:
     - "Users can view own progress" - `auth.uid() = user_id`
     - "Users can update own progress" - `auth.uid() = user_id`
     - "Users can delete own progress" - `auth.uid() = user_id`
   - ✅ Properly secured with RLS

4. **`public.user_favorites`**
   - Policies:
     - "Users can view own favorites" - `auth.uid() = user_id`
     - "Users can delete own favorites" - `auth.uid() = user_id`
   - ✅ Properly secured with RLS

5. **`public.user_feedback`**
   - Policies:
     - "Users can view own feedback" - `auth.uid() = user_id`
   - ✅ Properly secured with RLS

### ⚠️ Security Advisors

#### 1. Policies on `auth.users` Table

**Issue**: Supabase detects policies on the `auth.users` table.

**Status**: ⚠️ **Review Required**

**Recommendation**: 
- Remove RLS policies from `auth.users` table
- Use `public.users` table instead for user profile data
- Keep authentication data separate from application data

**Action Items**:
```sql
-- Remove policies from auth.users
DROP POLICY IF EXISTS "Users can view own profile" ON auth.users;
DROP POLICY IF EXISTS "Users can update own profile" ON auth.users;

-- Ensure policies exist on public.users instead
-- (These should already be in place)
```

#### 2. Function Search Path Mutability

**Issue**: Function `public.update_updated_at_column` has a mutable search_path.

**Severity**: ⚠️ Warning

**Recommendation**:
```sql
-- Set immutable search_path for security
ALTER FUNCTION public.update_updated_at_column() 
  SET search_path = pg_catalog, pg_temp;
```

**Reference**: [Supabase Database Linter Guide](https://supabase.com/docs/guides/database/database-linter?lint=0011_function_search_path_mutable)

#### 3. Leaked Password Protection

**Issue**: Leaked password protection is currently disabled in Supabase Auth.

**Severity**: ⚠️ Warning

**Action**: Enable in Supabase Dashboard
1. Go to Authentication → Policies
2. Enable "Password Dictionary Attack Prevention"
3. This checks passwords against HaveIBeenPwned.org database

**Reference**: [Password Security Guide](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection)

## Application-Level Security

### 1. Environment Variables

**✅ Implemented**: Supabase credentials use `--dart-define` with fallback defaults.

```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://pnihaeljbyjiexnfolir.supabase.co',
);
```

**Production Build**:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

### 2. Secure Storage

**✅ Implemented**: Using `flutter_secure_storage` for sensitive data.

### 3. Error Handling

**✅ Implemented**: 
- Errors are logged using `debugPrint` (not exposed to users)
- User-facing error messages are generic
- Stack traces are only shown in debug mode

### 4. Input Validation

**✅ Implemented**:
- Email validation using regex
- Password strength requirements
- Form validation mixins

### 5. API Key Protection

**✅ Implemented**:
- Keys loaded from environment variables
- No hardcoded secrets in production builds
- `.gitignore` includes sensitive files

## Security Checklist for Production

Before deploying to production:

- [ ] Enable leaked password protection in Supabase Auth
- [ ] Remove RLS policies from `auth.users` table
- [ ] Fix function search_path mutability
- [ ] Use environment variables for all credentials
- [ ] Enable HTTPS only (Supabase handles this)
- [ ] Review and audit all RLS policies
- [ ] Test authentication flows thoroughly
- [ ] Enable rate limiting (Supabase project settings)
- [ ] Set up monitoring and alerts
- [ ] Review Supabase security advisors regularly

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do not** create a public GitHub issue
2. Email: security@smartbite.com (or team email)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## References

- [Supabase Security Best Practices](https://supabase.com/docs/guides/database/securing-your-database)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)

---

**Last Updated**: November 7, 2025  
**Reviewed By**: Development Team

