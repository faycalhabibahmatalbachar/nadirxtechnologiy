# NADIRX TECHNOLOGIE - Complete Application Suite

Welcome! This project contains a complete registration and management system for NADIRX TECHNOLOGIE training programs, consisting of a Flutter mobile app and a Next.js admin dashboard.

## 📱 Quick Start

### For the Mobile App (Flutter)
```bash
flutter pub get
flutter run
```

### For the Admin Dashboard (Next.js)
```bash
cd admin
npm install  # (already done)
npm run dev  # Starts on http://localhost:3000
```

## ⚠️ IMPORTANT: Admin Dashboard Setup

The admin dashboard is **BUILT AND READY** but requires one critical configuration step to work:

### Add Your Supabase Anon Key
**Current Status**: ❌ `.env.local` contains a placeholder
**Required**: Add your real Supabase authentication key

**Steps:**
1. Visit https://app.supabase.com
2. Select your **NADIRX TECHNOLOGIE** project
3. Go to **Settings** → **API**
4. Copy the **anon** public key (not the service role key)
5. Edit `admin/.env.local` and replace the placeholder with your key
6. Restart the dev server: `npm run dev`

**Result:** The admin dashboard will immediately start displaying inscriptions from your database.

For detailed instructions, see [admin/SETUP_INSTRUCTIONS.md](admin/SETUP_INSTRUCTIONS.md)

---

## 📁 Project Structure

```
NADIRX_TECHNOLOGIE/
├── lib/                          # Flutter mobile app
│   ├── main.dart                 # App entry point
│   ├── core/                     # Shared utilities and widgets
│   └── features/
│       ├── inscription/          # User registration feature
│       ├── admin/                # Admin features (future)
│       └── shared/               # Shared providers and services
│
├── admin/                        # Next.js admin dashboard
│   ├── src/
│   │   ├── app/                 # Pages and layouts
│   │   ├── components/          # React components
│   │   └── lib/                 # Utilities and config
│   ├── .env.local               # ⚠️ NEEDS SUPABASE KEY
│   ├── package.json
│   └── README.md
│
├── supabase/
│   ├── schema.sql               # Database schema
│   └── functions/               # Edge Functions
│       └── submit-inscription/  # Form submission handler
│
├── ios/                         # iOS build files
├── android/                     # Android build files
├── web/                         # Web build files
├── linux/                       # Linux build files
├── macos/                       # macOS build files
├── windows/                     # Windows build files
│
├── pubspec.yaml                 # Flutter dependencies
├── PROJECT_STATUS.md            # Detailed project overview
└── README.md                    # This file
```

---

## ✨ Features

### Mobile App (Flutter)
✅ **User-Friendly Registration Form**
- Photo capture with gallery selection
- Form validation (phone, email, etc.)
- Real-time error feedback
- Automatic timestamp and location tracking

✅ **Fixed Issues**
- RenderFlex overflow resolved
- CORS preflight errors fixed
- Phone validation updated
- RGPD consent removed
- Form header simplified

✅ **Backend Integration**
- Secure submission via Supabase Edge Function
- Photo upload to cloud storage
- Real-time database sync
- Error handling and retry logic

### Admin Dashboard (Next.js)
✅ **Inscription Management**
- View all registrations in a responsive table
- Real-time search, filter, and sort
- CSV export functionality
- Status tracking (Pending, Confirmed, Rejected)

✅ **User-Friendly Interface**
- Cyberpunk-themed design
- Mobile-responsive layout
- Fast and intuitive navigation
- Dark mode optimized

✅ **Data Analytics**
- Filter by city
- Search by name, email, phone
- Export filtered results as CSV
- Sort by date (newest first)

---

## 🗄️ Database (Supabase)

### Tables
- **inscriptions** - User registration data
- **sessions_formation** - Training program information
- **notifications_log** - System activity logging

### Key Features
✅ Row Level Security (RLS) configured
✅ Public read access configured for dashboard
✅ Automatic timestamps on all records
✅ Edge Functions for secure submissions

### Schema
Your Supabase database has been populated with:
- Complete training session information
- Instructor details
- Contact information
- Registration fields for participants

---

## 🔐 Authentication & Security

### How It Works
```
Mobile App                          Admin Dashboard
    ↓                                    ↓
Edge Function (service role)      Supabase Anon Key
    ↓                                    ↓
Database INSERT                   Database SELECT
(Full write access)               (Public read only)
```

### RLS Policies
- **"lecture_par_id"** - Anyone can read inscriptions (dashboard access)
- **"sessions_publiques"** - Anyone can read active training sessions
- Database is protected: only service role can INSERT/UPDATE/DELETE

---

## 🚀 Deployment

### Mobile App
Deploy to:
- **iOS App Store** - Via TestFlight → App Store
- **Google Play Store** - Via Google Play Console
- **Web** - Flutter web build (future)

### Admin Dashboard
Deploy to:
- **Vercel** (recommended) - `vercel deploy`
- **Netlify** - Connect Git repository
- **Custom Server** - `npm run build && npm start`

See [admin/DEPLOYMENT.md](admin/DEPLOYMENT.md) for detailed instructions.

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | Complete project overview and status |
| [admin/SETUP_INSTRUCTIONS.md](admin/SETUP_INSTRUCTIONS.md) | Admin dashboard setup guide |
| [admin/DEPLOYMENT.md](admin/DEPLOYMENT.md) | Deployment instructions |
| [admin/README.md](admin/README.md) | Admin dashboard technical docs |
| [supabase/schema.sql](supabase/schema.sql) | Database schema definition |

---

## 🔧 Technologies Used

### Mobile App (Flutter)
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart** - Programming language
- **Riverpod** - State management
- **Supabase** - Backend-as-a-Service
- **Google Fonts** - Typography
- **Phosphor Icons** - Icon library

### Admin Dashboard (Next.js)
- **Next.js 14** - React framework
- **TypeScript** - Type-safe JavaScript
- **Tailwind CSS** - Utility-first CSS
- **React 18** - UI library
- **Supabase JS SDK** - Database client
- **Lucide React** - Modern icons

### Backend
- **Supabase** - PostgreSQL database
- **Edge Functions** - Serverless backend
- **Row Level Security** - Database access control

---

## 🐛 Troubleshooting

### Admin Dashboard - 401 Unauthorized
**Problem**: Dashboard loads but can't fetch inscriptions
**Cause**: Placeholder in `.env.local` instead of real Supabase key
**Solution**: See [Adding Your Supabase Anon Key](#add-your-supabase-anon-key) section above

### Mobile App - Form Won't Submit
**Check**:
1. Is device connected to internet?
2. Has Supabase Edge Function been deployed?
3. Are database tables created?
4. Check Console for error messages

### Database Issues
**Check**:
1. Login to Supabase dashboard
2. Verify tables exist in SQL Editor
3. Check RLS policies are enabled
4. Verify inscriptions table has data

---

## 📞 Support & Contact

### For NADIRX TECHNOLOGIE
- **Phone**: +23568881226 - 91912191
- **WhatsApp**: +23568663737
- **Email**: nadirxtechnology@gmail.com
- **Location**: Quartier Khazala, Rond Point 10 Octobre, N'Djaména, Tchad

### For Technical Issues
1. Check [PROJECT_STATUS.md](PROJECT_STATUS.md) for detailed logs
2. Review [admin/SETUP_INSTRUCTIONS.md](admin/SETUP_INSTRUCTIONS.md) for setup help
3. Check Supabase dashboard for database errors

---

## 📊 Project Status

| Component | Status | Notes |
|-----------|--------|-------|
| Mobile App | ✅ Complete | Fully functional, all bugs fixed |
| Admin Dashboard | ✅ Built | Ready after adding Supabase key |
| Database Schema | ✅ Applied | All tables and policies configured |
| Edge Functions | ✅ Deployed | Form submission working |
| Documentation | ✅ Complete | Comprehensive guides provided |

**Overall Progress: 95% → 100% upon adding Supabase key to `.env.local`**

---

## 🎯 Next Steps

1. **Configure Admin Dashboard**: Add Supabase anon key to `admin/.env.local`
2. **Test Dashboard**: Open http://localhost:3000 and verify inscriptions load
3. **Submit Test Registration**: Use mobile app to submit a test inscription
4. **Verify in Dashboard**: Check that new registration appears immediately
5. **Deploy**: When ready, deploy both apps to production

---

## 📝 License

This project is proprietary to NADIRX TECHNOLOGIE. All rights reserved.

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Status**: Ready for Production (after env configuration)

For the most detailed information, see [PROJECT_STATUS.md](PROJECT_STATUS.md)
