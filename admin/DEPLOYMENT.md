# NADIRX Admin Dashboard - Deployment Guide

## Quick Start (Local Development)

### ERROR: "supabaseUrl is required"

If you see this error, you need to set up environment variables:

### ✅ Fix the Error

#### 1. Get Your Supabase Anon Key
- Go to [Supabase Dashboard](https://app.supabase.com)
- Select project `xbrlpovbwwyjvefblmuz`
- Click **Settings** → **API**
- Copy the **`anon` key** (under "Project API keys")

#### 2. Create `.env.local` in `/admin` folder

Copy `.env.example` to `.env.local`:
```bash
cp .env.example .env.local
```

Edit `.env.local` and replace `PLACEHOLDER_REPLACE_WITH_YOUR_ACTUAL_KEY`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xbrlpovbwwyjvefblmuz.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.YOUR_ACTUAL_ANON_KEY_HERE
```

#### 3. Restart Dev Server
Kill the current server (Ctrl+C) and restart:
```bash
npm run dev
```

---

## Setup Checklist

- [ ] `.env.local` file created
- [ ] `NEXT_PUBLIC_SUPABASE_URL` set to `https://xbrlpovbwwyjvefblmuz.supabase.co`
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY` set to your actual key (not PLACEHOLDER)
- [ ] Dev server restarted after changes
- [ ] No "supabaseUrl is required" error in browser console

---

## Production Deployment

### Option 1: Deploy to Vercel (Recommended)
1. Push to GitHub
2. Connect repo to Vercel
3. Add environment variables in Vercel dashboard
4. Deploy

### Option 2: Deploy to Any Node.js Host

```bash
# Build the app
npm run build

# Start production server
npm start
```

### Option 3: Export as Static Site
```bash
npm run export
```

This creates an `out/` folder ready for static hosting (AWS S3, Netlify, etc.)

---

## Environment Setup for Public URLs

### Update Flutter App Configuration

In `lib/core/config/app_config.dart`:
```dart
// Change from localhost to public URL
static const String adminDashboardUrl = 'https://admin.nadirx.tech';
```

Update your Supabase functions and CORS policies to accept your public admin domain.

---

## Features Currently Available

✅ **Inscriptions Listing**
- View all registered participants
- Pagination support
- Real-time data from Supabase

✅ **Filtering & Search**
- Filter by status (Confirmé, En attente, Rejeté)
- Filter by city
- Full-text search on name, email, phone

✅ **Export**
- Download filtered results as CSV
- Include all columns for analysis

✅ **Responsive Design**
- Works on desktop, tablet, mobile
- Dark theme with matrix/cyberpunk aesthetic

---

## Coming Soon Features

⏳ **Individual Inscription Details**
- View full participant information
- Download uploaded photo and CV
- Phone number clickable

⏳ **Admin Actions**
- Add notes to inscriptions
- Assign tags (prioritaire, a_rappeler, doublon, vip)
- Change participant status
- Mark as reviewed

⏳ **Communications**
- Send bulk SMS notifications (Twilio)
- Email confirmations
- WhatsApp messages (Twilio)

⏳ **Analytics Dashboard**
- Charts showing registrations over time
- Demographics analysis
- City/field distribution

---

## Troubleshooting

### "Table 'public.inscriptions' not found"
- Ensure Supabase schema.sql has been executed
- Check table exists in Supabase SQL editor

### "CORS errors"
- Update Supabase RLS policies for your admin domain
- Ensure anon key has read access to inscriptions table

### "Environment variables not loading"
- Restart dev server after updating `.env.local`
- Variables must start with `NEXT_PUBLIC_` to be accessible in browser

---

## Database Access Levels

**Admin Dashboard uses ANON KEY** (read-only access to inscriptions)

For write access (updating notes, tags, status), you'll need to:
1. Create API route that uses SERVICE ROLE KEY
2. Add authentication middleware
3. Implement authorization checks

Example structure coming in next update.

---

## Support

For issues or questions:
1. Check Supabase logs
2. Verify RLS policies allow reads
3. Test database connection in Supabase console
