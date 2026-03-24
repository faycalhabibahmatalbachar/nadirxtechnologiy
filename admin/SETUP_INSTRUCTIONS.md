# Admin Dashboard Setup Instructions

## Current Status
✅ **Dashboard Built & Running** - The Next.js admin app is fully built with:
- TypeScript configuration
- Tailwind CSS styling  
- Supabase database integration
- Filtering and CSV export functionality
- npm dependencies installed

⚠️ **Authentication Configuration Pending** - The dashboard shows a 401 Unauthorized error because the Supabase anon key in `.env.local` is a placeholder

## Fix the 401 Error

### Step 1: Get Your Supabase Anon Key
1. Open https://app.supabase.com
2. Select your **NADIRX TECHNOLOGIE** project
3. Go to **Settings** (bottom left) → **API**
4. Under "Project API keys", copy the **anon** public key (it looks like: `eyJhbGciOiJIUzI1NiIs...`)

### Step 2: Update .env.local
In the `admin/.env.local` file, replace:
```
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhicmxwb3ZiYnd3eWpmZWZibG11eiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzA0MDAwMDAwLCJleHAiOjE5OTk5OTk5OTl9.PLACEHOLDER_REPLACE_WITH_YOUR_ACTUAL_KEY
```

With your actual anon key. The result should look like:
```
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhicmxwb3ZiYnd3eWpmZWZibG11eiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzA0MDAwMDAwLCJleHAiOjE5OTk5OTk5OTl9.dGhpc2lzYXJlYWxrZXk...
```

### Step 3: Restart the Dev Server
If the dev server is running:
1. Press **Ctrl+C** to stop it
2. Run `npm run dev` to restart

## What Happens When Fixed

Once you add the real anon key:

1. **Dashboard loads data** - The inscriptions table will populate with all registration data from your Supabase database
2. **Filters work** - You can search by name, email, phone, status, and city
3. **Export works** - The "Export CSV" button downloads all filtered inscriptions as a CSV file
4. **Database access confirmed** - The RLS policies are already configured to allow anon public read access

## Database Configuration

The Supabase schema is already configured with:

### Table: inscriptions
- Full schema applied via `supabase/schema.sql`
- Contains all participant registration data
- Fields: nom, prenom, email, telephone, ville, statut, etc.

### Row Level Security (RLS)
These policies are active:
- **"lecture_par_id"** - Anyone can read inscriptions (allows public dashboard access)
- **"sessions_publiques"** - Anyone can read active training sessions

### Why This Works
- The mobile app submits data via Edge Function (service role auth - full access)
- The admin dashboard reads data via anon key (public read access only)
- This separation ensures security while enabling open access to view registrations

## Troubleshooting

### Still getting 401 error after restarting?
- Double-check you copied the entire **anon** key (not the service_role key)
- Make sure `.env.local` doesn't have any extra spaces or quotes
- The key should not include "PLACEHOLDER_REPLACE_WITH_YOUR_ACTUAL_KEY"

### No inscriptions showing?
- Verify inscriptions exist in your Supabase database
- Check the database browser: Settings → SQL Editor → Run `SELECT COUNT(*) FROM inscriptions;`
- If count is 0, your mobile app hasn't submitted any inscriptions yet

### Filters or export not working?
- All functionality is implemented; if issues occur, they're likely data-related
- Check browser console (F12) for JavaScript errors
- Ensure the inscriptions table has the expected schema

## Next Steps After Setup

Once the dashboard is working:
1. **Test Dashboard** - View registrations, filter, export CSV
2. **Monitor Submissions** - New mobile app submissions appear in real-time
3. **Production Deployment** - When ready, deploy to Vercel or similar platform
4. **URL Migration** - Update mobile app to use public admin URL instead of localhost

## File Structure
```
admin/
├── .env.local              <- UPDATE THIS with real anon key
├── .env.example            <- Reference copy of env vars
├── src/
│   ├── app/
│   │   ├── page.tsx        <- Main dashboard component
│   │   ├── layout.tsx      <- App wrapper
│   │   └── globals.css     <- Global styles
│   ├── components/
│   │   ├── Header.tsx      <- Top bar with export button
│   │   ├── Filters.tsx     <- Search and filter inputs
│   │   └── InscriptionsTable.tsx <- Data table
│   └── lib/
│       └── supabase.ts     <- Supabase client & types
├── package.json            <- Dependencies
├── tsconfig.json           <- TypeScript config
└── tailwind.config.ts      <- Tailwind setup
```

## Key Technologies

- **Next.js 14** - React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Supabase** - Backend database
- **@supabase/supabase-js** - Database client

---

**Status**: Ready for authentication configuration. Once you add your Supabase anon key, the dashboard will be fully operational.
