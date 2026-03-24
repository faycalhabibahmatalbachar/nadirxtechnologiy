# Admin Dashboard - Enhanced Features Documentation

## Overview

The admin dashboard has been enriched with comprehensive features to view, manage, and analyze all inscription data submitted through the mobile app.

## Features

### 1. **Statistics Dashboard**
Displays real-time analytics of all inscriptions:

- **Total Inscriptions**: Overall count of all registrations
- **Confirmed**: Number of confirmed registrations
- **Pending**: Registrations awaiting confirmation
- **Rejected**: Rejected applications
- **With CV**: Percentage of applicants who uploaded CV
- **Photos**: Percentage of applicants with photo
- **Cities**: Number of unique cities represented
- **To Review**: Unviewed inscriptions by admin

#### Status Distribution Chart
Visual representation showing:
- Percentage of confirmed vs pending vs rejected
- Horizontal progress bars for quick visualization
- Color-coded indicators

#### Top Cities Chart
Shows the distribution of inscriptions by city with counts and percentages.

### 2. **Enhanced Inscriptions Table**

The main table displays:

| Column | Details |
|--------|---------|
| **Photo** | Thumbnail of participant picture |
| **Nom & Contact** | Name, email, phone number |
| **Localisation** | City and neighborhood |
| **Profil** | Current profession, tech skill level |
| **Statut** | Confirmation status (badge) |
| **Tag** | Admin tags (Prioritaire, VIP, etc.) |
| **Date** | Registration date |
| **Actions** | View Details button |

#### Row Highlighting
- Unviewed inscriptions have a **left blue border** for quick identification
- Striped background for better readability
- Hover effects for interactivity

#### Table Stats Bar
Summary stats shown below table:
- Total inscriptions in view
- Number of confirmed
- Number with CV
- Number awaiting review

### 3. **Detailed Inspection Modal**

Click the "Détails" button on any row to open a comprehensive view showing:

#### Personal Information
- Full name (prénom + nom)
- Date of birth with formatted display
- Gender
- Nationality
- Email and phone number
- City and neighborhood

#### Professional Profile
- Current employment status
- Industry/domain
- Computer skill level (beginner/intermediate/advanced)
- Training objectives (full text)
- How they learned about NADIRX

#### Documents
- **Photo Participant**: Thumbnail with download button
  - Download as: `Prenom-Nom-photo.jpg`
- **CV**: PDF document with download button
  - Download as: `Prenom-Nom-cv.pdf`

#### Admin Controls
- **Status**: Change confirmation status (Confirmé/En attente/Rejeté)
- **Tag**: Add admin tags:
  - 🔴 **Prioritaire** - High priority
  - 🔔 **À rappeler** - Follow-up needed
  - ⚠️ **Doublon** - Duplicate registration
  - ⭐ **VIP** - Special importance
- **Notes**: Add internal admin notes
- **View Status**: Shows if admin has reviewed

#### Edit & Save
- Click "Modifier" button to enter edit mode
- Edit notes, tags, and status
- Click "Enregistrer" to save changes to database
- Changes saved with timestamp and admin viewed flag

### 4. **Filtering & Search**

#### Search Filter
Search by:
- First name (prénom)
- Last name (nom)
- Email address
- Phone number

Real-time filtering as you type.

#### Status Filter
Filter by confirmation status:
- Confirmé (Confirmed)
- En attente (Pending)
- Rejeté (Rejected)

#### City Filter
Select from dropdown of all cities represented in inscriptions.

### 5. **CSV Export**

Export filtered inscriptions as CSV with columns:
- ID
- Prénom (First name)
- Nom (Last name)
- Email
- Téléphone (Phone)
- Ville (City)
- Statut (Status)
- Date (Registration date)

Only exports currently visible **filtered** inscriptions.

## Data Structure

### Inscription Fields Displayed

**Personal**
- `id`: Unique identifier
- `prenom`: First name
- `nom`: Last name
- `date_naissance`: Birth date
- `genre`: Gender
- `nationalite`: Nationality

**Contact**
- `email`: Email address
- `telephone`: Phone number
- `ville`: City
- `quartier`: Neighborhood/District

**Professional**
- `situation_actuelle`: Current employment status
- `domaine_activite`: Industry/field
- `niveau_informatique`: Computer skill level
- `objectif_formation`: Training goals

**Documents**
- `photo_participant_url`: Photo file path (auto-loaded from Supabase storage)
- `cv_url`: CV file path (auto-loaded from Supabase storage)

**Status**
- `statut`: Current status (confirme/en_attente/rejetee)
- `comment_connu`: How they found NADIRX
- `consentement_rgpd`: RGPD consent (always true)

**Admin Fields**
- `note_admin`: Internal admin notes
- `tag_admin`: Admin tag (prioritaire/a_rappeler/doublon/vip)
- `admin_viewed`: Whether admin has reviewed
- `created_at`: Registration timestamp
- `updated_at`: Last modification timestamp

## File Storage

### Photo Storage
- **Bucket**: `participant-photos`
- **Path**: Stored with inscription ID
- **Format**: JPEG/PNG
- **Display**: Auto-loaded by app

### CV Storage
- **Bucket**: `participant-cvs`
- **Path**: Stored with inscription ID
- **Format**: PDF
- **Download**: Available in details modal

## UI Components

### New Components Created

1. **InscriptionDetails.tsx**
   - Modal component showing full inscription details
   - Edit functionality for admin notes and status
   - Photo and CV display with download buttons
   - Professional styling with cyberpunk theme

2. **EnhancedInscriptionsTable.tsx**
   - Improved table with photo thumbnails
   - Column: Photo | Name | Location | Profile | Status | Tag | Date | Actions
   - Row highlighting for unviewed entries
   - Stats bar below table
   - Enhanced visual design

3. **Stats.tsx**
   - Statistics widgets showing key metrics
   - Status distribution with progress bars
   - Top cities chart
   - Real-time calculation of percentages
   - Color-coded indicators

### Updated Components

1. **page.tsx (Main Dashboard)**
   - Integrated new components
   - Added state management for selected inscription
   - Modal rendering logic
   - Update callbacks

2. **InscriptionsTable.tsx**
   - Added callback for detail view
   - Updated styling and labels

## Usage Guide

### Viewing Inscriptions

1. **Dashboard loads** with statistics and inscribed list
2. **Browse list** - scroll through enhanced table
3. **Search/Filter** - use filters to narrow results
4. **View Details** - click "Détails" button on any row

### Managing Inscriptions

1. **Click "Détails"** to open modal
2. **Review** all information
3. **Check documents** - photo and CV
4. **Click "Modifier"** to edit
5. **Update**:
   - Status (Confirmé/En attente/Rejeté)
   - Tag (Prioritaire/À rappeler/Doublon/VIP)
   - Admin notes
6. **Click "Enregistrer"** to save

### Exporting Data

1. **Apply filters** (optional) to narrow results
2. **Click "Export CSV"** in header
3. **File downloads** with current date

## Styling & Theme

- **Cyberpunk Theme**: Neon glows, dark backgrounds, bright accents
- **Colors**:
  - Primary (cyan): Main highlights, confirmed status
  - Secondary (purple): Secondary info, pending status
  - Error (red): Rejects, warnings
- **Responsive**: Works on mobile, tablet, and desktop
- **Dark Mode**: Optimized for dark theme

## Technical Details

### Database Queries

- **Fetch**: `SELECT *` from inscriptions with full join
- **Filter**: Real-time client-side filtering
- **Update**: Direct update to inscriptions table
- **RLS**: Public read, service role write

### Storage Access

- **Photos**: Public read via Supabase storage URL
- **CVs**: Public read via Supabase storage URL
- **Format**: `NEXT_PUBLIC_SUPABASE_URL/storage/v1/object/public/bucket/path`

### Real-time Updates

When inscription is updated:
1. Changes saved to database with timestamp
2. `admin_viewed` flag set to `true`
3. `updated_at` timestamp updated
4. Local state updated in dashboard
5. Table re-renders with new data

## Performance Considerations

- **Initial Load**: All inscriptions loaded once
- **Filtering**: Done client-side (fast)
- **Details Modal**: Lazy loads image on demand
- **Stats**: Computed from already-loaded data

## Known Limitations

- Modal images pre-loaded when details opened
- CSV export limited to filtered view
- No bulk actions yet (future enhancement)
- Edit only for admin fields (statut, tag, note)

## Future Enhancements

- Bulk status updates
- Advanced filters (date range, profession)
- Email notifications for new inscriptions
- Duplicate detection
- Custom report generation
- Inscription timeline/activity log
- Batch operations (export, update, delete)

## Troubleshooting

### Photos not showing
- Verify bucket name: `participant-photos`
- Check file paths in database
- Verify Supabase public access enabled

### CV not downloading
- Check bucket: `participant-cvs`
- Verify file format (should be PDF)
- Check browser popup blockers

### Modal won't open
- Ensure InscriptionDetails imported
- Check browser console for errors
- Verify inscription data is complete

### Filters not working
- Clear cache and refresh
- Check that data is loaded
- Verify filter dropdown has values

---

**Last Updated**: December 2024
**Version**: 2.0 (Enhanced)
**Status**: Production Ready
