# Configuration for Vercel Deployment

## Environment Variables for Vercel

When deploying to Vercel, add these environment variables in the Vercel Dashboard:

### Step 1: Go to Vercel Dashboard
https://vercel.com/dashboard

### Step 2: Select Your Project
- Click on the NADIRX project
- Go to Settings → Environment Variables

### Step 3: Add Variables

Copy and paste these exact names and values:

#### Variable 1: Supabase URL
```
Name: NEXT_PUBLIC_SUPABASE_URL
Value: https://xbrlpovbwwyjvefblmuz.supabase.co
Environments: All
```

#### Variable 2: Supabase Anon Key
```
Name: NEXT_PUBLIC_SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhicmxwb3Zid3d5anZlZmJsbXV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDg2ODMsImV4cCI6MjA4ODkyNDY4M30.SPPTQJg9aknHd1EL6kwl1VVHh1MMLv7Qdlkp3fsfbRg
Environments: All
```

### Step 4: Save
Click "Save" after each variable

### Step 5: Redeploy
- Go to "Deployments"
- Click "Redeploy" on the latest deployment
- Wait for green checkmark ✅

## Vercel.json Configuration

The file `admin/vercel.json` is already configured with:
- Framework: Next.js
- Build command: `npm run build`
- Output directory: `.next`

No changes needed - Vercel will auto-detect this!

## Testing After Deployment

1. **Open your deployment URL**
   - Default: https://nadirx-technologie.vercel.app
   - Or custom domain if configured

2. **Check these work:**
   - [ ] Page loads without errors
   - [ ] Statistics display
   - [ ] Inscriptions appear in table
   - [ ] Photos load with thumbnails
   - [ ] Filters work in real-time
   - [ ] Export CSV downloads
   - [ ] Modal opens when clicking "Détails"
   - [ ] Can edit notes and status
   - [ ] Changes save to database

3. **Test with Mobile App**
   - Submit inscription from mobile
   - Check appears in admin within 2 seconds
   - Photo displays correctly

## Domain Setup (Optional)

### Without Custom Domain
- Your admin is live at: `https://nadirx-technologie.vercel.app`
- This works great for internal use!

### With Custom Domain
Example: `admin.nadirx-td.com`

1. **Buy domain** (GoDaddy, Namecheap, etc)

2. **In Vercel Dashboard**
   - Go to Settings → Domains
   - Add your domain
   - Get the CNAME record Vercel provides

3. **At your DNS provider**
   - Add CNAME record pointing to Vercel
   - Wait 5-48 hours for propagation

4. **Result**
   - Admin will be at your custom domain ✅

## Public URLs Summary

After deployment, you have:

```
Admin Dashboard
URL: https://nadirx-technologie.vercel.app
Status: ✅ Public & Accessible

Supabase Backend
URL: https://xbrlpovbwwyjvefblmuz.supabase.co
Status: ✅ Public & Accessible

Mobile App Submissions
Endpoint: /functions/v1/submit-inscription
Status: ✅ Working with deployed admin
```

## Performance & Monitoring

Vercel includes FREE monitoring:
- Analytics tab shows performance
- Serverless Function logs
- Deployment history
- Performance metrics

Access via: Vercel Dashboard → Your Project → Analytics

## Auto-deploy on Changes

Once deployed, Vercel automatically redeploys when you push to GitHub:

```bash
git commit -am "Fix inscriptions modal"
git push origin main
# Vercel detects → Auto-builds → Auto-deploys
```

No manual deployment needed! ✅

---

**Status**: Configuration Ready
**Next**: Execute the deployment steps above
**Support**: https://vercel.com/support
