# Quick Fix: Add Supabase Database to .env

## Option 1: Add Supabase Database (Recommended)

Add these lines to your `backend/.env` file:

```env
# Supabase Database Configuration
DB_HOST=db.pnihaeljbyjiexnfolir.supabase.co
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=YOUR_SUPABASE_PASSWORD_HERE
DB_NAME=postgres
DB_ENABLED=true
```

**Important:** Replace `YOUR_SUPABASE_PASSWORD_HERE` with your actual Supabase database password.

### How to Get Your Password:

1. Go to: https://supabase.com/dashboard/project/pnihaeljbyjiexnfolir/settings/database
2. Find **Database Password** section
3. If you don't remember it, click **"Reset database password"**
4. Copy the password
5. Paste it in `.env` file

---

## Option 2: Disable Database (Quick Fix)

If you just want the Food Analysis API proxy to work without database:

Add this line to your `backend/.env` file:

```env
DB_ENABLED=false
```

This will skip database connection and the server will start immediately.

---

## After Adding to .env

1. Save the file
2. Restart backend: `cd backend && npm run start:dev`
3. You should see: `✅ Server started successfully`

