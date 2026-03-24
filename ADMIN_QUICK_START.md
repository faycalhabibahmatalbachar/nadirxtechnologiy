# Admin Dashboard - Quick Start Guide

## Start the Dashboard

```bash
cd admin
npm run dev
```

**Open in browser:** http://localhost:3000

## What You'll See

### Top Section: Statistics
- Cards showing total, confirmed, pending, rejected counts
- Progress bars showing status distribution
- Top cities chart
- Real-time percentages

### Middle Section: Filters
- Search box (type name, email, or phone)
- Status dropdown (Confirmé, En attente, Rejeté)
- City dropdown (auto-populated from data)

### Main Section: Enhanced Table
Columns in order:
1. **Photo** - Thumbnail of participant
2. **Name & Contact** - Person's info + email + phone
3. **Location** - City + neighborhood
4. **Profile** - Job type + tech level
5. **Status** - Badge (color-coded)
6. **Tag** - Admin category (if any)
7. **Date** - Registration date
8. **Actions** - "Détails" button

### Unviewed Inscriptions
Inscriptions not yet viewed have a **blue left border** - easy to spot!

## View Full Details

1. Click **"Détails"** button on any row
2. Modal opens with everything:
   - Participant photo (large)
   - CV document (if uploaded)
   - All personal info
   - Professional details
   - Admin fields

## Edit an Inscription

1. Open details modal
2. Click **"Modifier"** button
3. Edit:
   - Status (dropdown)
   - Tag (dropdown)
   - Admin notes (textarea)
4. Click **"Enregistrer"** to save
5. Changes saved to database instantly

## Download Files

Inside details modal:
- **Photo**: Click "Télécharger" under photo section
- **CV**: Click "Télécharger CV" under document section
- Files auto-named: `FirstName-LastName-photo.jpg` or `-cv.pdf`

## Export All Data

1. Use filters if needed (optional)
2. Click **"Export CSV"** in top-right
3. File downloads automatically
4. Contains: ID, Names, Email, Phone, City, Status, Date

## Filter Options

### Search
Type to filter by:
- First name
- Last name
- Email
- Phone number

**Real-time** - updates as you type

### Status Filter
Select from:
- Confirmé (Confirmed)
- En attente (Pending)
- Rejeté (Rejected)

### City Filter
Select from list of cities where people registered.

## Tags Explained

Admin tags you can assign:
- 🔴 **Prioritaire** - High priority (red highlight)
- 🔔 **À rappeler** - Needs follow-up
- ⚠️ **Doublon** - Duplicate registration
- ⭐ **VIP** - Special status

## Status Meanings

- **Confirmé** (Green) - Registration confirmed
- **En attente** (Purple) - Awaiting confirmation
- **Rejeté** (Red) - Registration rejected

## Navigation

**Top Header:**
- NADIRX ADMIN logo on left
- Total count of inscriptions shown
- Export CSV button on right

**Main Content:**
- Statistics above
- Filters below stats
- Table with all data

## Tips & Tricks

### Quick Search
- Click on any inscription name and press Ctrl+F
- Browser will search page

### Mobile View
- Dashboard is responsive
- Works on tablets and phones
- Stack layout on small screens

### Unread Entries
- Blue-bordered rows = not yet reviewed
- Click "Détails" to mark as viewed
- Status updates in real-time

### Bulk Review
1. Open each unread entry
2. Add notes/tags as needed
3. Change status if required
4. Click save

### Popular Cities
- Stats show top 5 cities
- See distribution in charts
- Filter by city to zoom in

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Search | Ctrl+F (in page) |
| Open Details | Click button |
| Save Changes | Ctrl+Enter (in modal) |
| Close Modal | Esc or click X |

## Common Tasks

### mark as reviewed
1. Open any inscription
2. See "Vu: Non" becomes "Vu: Oui" after edit
3. Save any change = marked viewed

### Change confirmation status
1. Open inscription
2. Click "Modifier"
3. Change Status dropdown
4. Click "Enregistrer"

### Add follow-up note
1. Open inscription
2. Click "Modifier"
3. Type in Notes field
4. Click "Enregistrer"

### Tag as VIP
1. Open inscription
2. Click "Modifier"
3. Select "VIP" in Tag dropdown
4. Click "Enregistrer"

### Find new inscriptions
1. See "À voir" count in stats (top-left area)
2. Number shows unreviewed entries
3. Filter or search if needed
4. Open and review

## Data Displayed in Table

Quick reference of what you see in each row:

| Column | Shows |
|--------|-------|
| Photo | 32x32 thumbnail |
| Name | Prénom + Nom |
| Contact | Email + Téléphone |
| Location | Ville + Quartier |
| Profession | Métier + Niveau tech |
| Status | Confirmé/Attente/Rejeté |
| Tag | Prioritaire/VIP/etc |
| Date | Registration date |
| Action | Details button |

## Features at a Glance

✅ View all inscriptions instantly
✅ Photos and CV access
✅ Real-time filtering
✅ Edit status and notes
✅ Download documents
✅ Export to CSV
✅ Statistics dashboard
✅ Tag system
✅ Mobile responsive

## Need Help?

**See comprehensive docs:**
- `ENHANCED_FEATURES.md` - Full feature documentation
- `ADMIN_ENHANCEMENT_SUMMARY.md` - What's new
- `SETUP_INSTRUCTIONS.md` - Config help
- `PROJECT_STATUS.md` - Project overview

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| Page won't load | Check: is `npm run dev` running? |
| No data shows | Wait 2 seconds and refresh page |
| Can't download file | Check browser downloads folder |
| Modal stuck | Press Esc key or click X |
| Filter not working | Clear cache, refresh page |
| Photos blank | Check Supabase buckets exist |

---

**Pro Tips:**
- 💡 Use search for quick finding
- 💡 Filter by city to see regional patterns
- 💡 Add meaningful notes for team
- 💡 Tag prioritaire for important cases
- 💡 Export weekly for backup
- 💡 Review "À voir" regularly

**Dashboard Status**: Ready to Use
**Version**: 2.0 Enhanced
**Last Update**: December 2024
