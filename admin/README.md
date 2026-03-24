# NADIRX Admin Dashboard

Admin dashboard for managing NADIRX TECHNOLOGIE inscriptions.

## Setup

1. Copy `.env.example` to `.env.local` and add your Supabase credentials:
```bash
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

2. Install dependencies:
```bash
npm install
```

3. Run development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000)

## Features

- ✅ View all inscriptions with pagination
- ✅ Filter by status, city, and search terms
- ✅ Export data to CSV
- ✅ Responsive design with cyberpunk theme
- ⏳ Coming: Individual inscription details
- ⏳ Coming: Admin notes and tags
- ⏳ Coming: Email notifications

## Tech Stack

- **Next.js 14** - React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Supabase** - Backend & Database
- **Lucide React** - Icons

## Environment Variables

```env
NEXT_PUBLIC_SUPABASE_URL=https://xbrlpovbwwyjvefblmuz.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
```

## Database

The admin dashboard connects to your existing Supabase database. Ensure the `inscriptions` table exists with proper RLS policies.
