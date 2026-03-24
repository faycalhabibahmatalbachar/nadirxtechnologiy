# Flutter Mobile App - Codebase Exploration Report

## 🎯 Executive Summary

The NADIRX TECHNOLOGIE mobile app is a Flutter-based registration system with a cyberpunk-themed UI. It uses **Supabase as backend** (no localhost hardcoding), **Firebase for messaging/notifications**, and **Riverpod for state management**.

---

## 1️⃣ BACKEND URLs & CONFIGURATION

### ✅ No Localhost - Production Ready
- **No hardcoded `localhost:3000` or `http://` development URLs found**
- All endpoints use **Supabase Cloud** (production)

### 🔗 Backend Configuration ([app_config.dart](lib/core/config/app_config.dart))
```dart
// Supabase Production
static const String supabaseUrl = 'https://xbrlpovbwwyjvefblmuz.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

// Edge Function for submissions
static const String submitFunction = 'submit-inscription';

// Storage bucket for photos/documents
static const String participantsBucket = 'participants';
```

### 📍 Contact Info (Hardcoded)
```
WhatsApp:  +23568663737
Phone:     +23568881226
Email:     nadirxtechnology@gmail.com
```

---

## 2️⃣ INSCRIPTION FORM - CAPTURED FIELDS

### 📋 Fields in the Inscription Form
**Location:** [lib/features/inscription/presentation/screens/inscription_form_screen.dart](lib/features/inscription/presentation/screens/inscription_form_screen.dart)

#### **Section: Identity** (identité)
- ✅ **Prenom** (First name) - Required
- ✅ **Nom** (Last name) - Required
- ✅ **Date de Naissance** (Date of birth) - Required, min 16 years old
- ✅ **Genre** (Gender) - Optional: Homme, Femme, Autre

#### **Section: Contact** (contact)
- ✅ **Telephone** - Required, formatted with +235 country code
- ✅ **Ville** (City) - Required dropdown with options:
  - N'Djaména, Moundou, Sarh, Abéché, Bongor, Doba, Kélo, Autre
- ❌ **Email** - NOT in form (but submitted as empty string)
- ✅ **Quartier** (Neighborhood) - Optional text field

#### **Section: Level/Understanding** (niveau)
- ✅ **Niveau Informatique** - Required selection:
  - Débutant, Intermédiaire, Avancé

#### **Section: Photo** (photo)
- ✅ **Photo Participant** - Required, can be:
  - Taken from camera
  - Selected from gallery
  - Cropped/edited

#### **Additional Hidden/Auto-filled**
- **Nationalite** → "Tchadienne" (hardcoded)
- **Situation Actuelle** → "etudiant" (hardcoded)
- **Consentement RGPD** → true (hardcoded)
- **Comment Connu** → Not in form (optional)
- **CV** → Optional document upload (field exists but not fully visible in form)

### ⚠️ Data Discrepancy
- **Email is NOT captured in the form**, but database expects it (NOT NULL)
- **Objectif Formation is NOT in the form**, but submitted in JSON
- These are sent to Edge Function which handles insertion

---

## 3️⃣ AUTHENTICATION & DATA ISOLATION

### 🔐 Architecture
```
Mobile App (anon key)  →  Supabase Edge Function (service role)  →  Database
   ↓                                      ↓
Photo/CV upload          Insert inscription
(Storage API)            (Full DB access)
```

### 👤 User Authentication
- **No Firebase Auth for users** in mobile app
- Users are **anonymous** (identified only by their inscription ID)
- `inscriptionId` saved locally in `SharedPreferences`
- Users can view **only their own inscription** via localStorage retrieval

### 🛡️ How Users See Only Their Data
1. User completes form → submits via Edge Function
2. Edge Function returns `inscription_id` in response
3. App saves ID locally: `LocalStorage.saveInscriptionId(inscriptionId)`
4. "Mon Espace" screen retrieves ID and fetches data
5. Public RLS policy `"lecture_par_id"` allows read access to any inscription

**Limitation:** Users could theoretically guess other IDs and see their data
- **Solution needed:** Either require email verification or use UUID-based anonymous auth

---

## 4️⃣ POST-SIGNUP SCREENS & DASHBOARD

### 🎬 Navigation Flow
```
Splash Screen
    ↓
Inscription Form Screen (fill form, upload photo)
    ↓
[Submit Button] → Upload photo/CV → Call Edge Function
    ↓
Confirmed Screen ✅ (success page with details)
    ↓
Mon Espace Screen (user dashboard - accessible anytime)
```

### ✅ **Confirmed Screen** ([confirmed_screen.dart](lib/features/inscription/presentation/screens/confirmed_screen.dart))
Shown immediately after successful submission:
- 🎉 Success animation
- 📸 Participant photo
- 📋 Formation details card
- 📍 Training location & dates
- 📞 Contact buttons (WhatsApp, Phone, Email)
- 🔄 Share button
- 📋 Dossier number (short ID)

### 📱 **Mon Espace Screen** ([mon_espace_screen.dart](lib/features/inscription/presentation/screens/mon_espace_screen.dart))
Dashboard accessible after signup:

#### **Status Badge**
- "PARTICIPATION CONFIRMÉE" (green with shield icon)

#### **Profile Card**
- User photo (circular with glow)
- Full name
- Dossier/Inscription ID (short 8-char uppercase)

#### **Formation Card**
- **Date Range** → Shows "5 – 9 mai 2026"
- **Time** → "08h00 – 17h30"
- **Location** → "NADIRX TECHNOLOGIE, N'Djaména"
- **Days Until** → "Dans J-XX jours" countdown

#### **Programme Section** (Expandable)
- **Day 1-5** titled cards with collapsible modules
- Shows modules for each day (e.g., "Ethical Hacking", "Forensics", etc.)

#### **Equipment/Materials Card**
```
- 💻 Ordinateur avec accès internet
- 📝 Carnet et stylo
- 🪪 Pièce d'identité
```

#### **Contact Section** (3 buttons)
- 💬 **WhatsApp** → Opens https://wa.me/23568663737
- ☎️ **Appeler** → Calls +23568881226
- ✉️ **Email** → Opens nadirxtechnology@gmail.com

---

## 5️⃣ ERROR HANDLING & FORM SUBMISSION

### 📤 Submit Flow ([inscription_form_controller.dart](lib/features/inscription/presentation/controllers/inscription_form_controller.dart))

**Submission called from:** `inscription_form_screen.dart` → `_submitForm()` button

**Steps:**
1. **Form Validation** → Checks all required fields
2. **Photo Required Check** → Fails if no photo uploaded
3. **Upload Photo** → To Supabase Storage → Get public URL
4. **Upload CV (optional)** → To Supabase Storage
5. **Get FCM Token** → Firebase Messaging token (Android/iOS only)
6. **Call Edge Function** `submit-inscription` with data:
   ```dart
   {
     'prenom', 'nom', 'date_naissance', 'genre',
     'email', 'telephone', 'ville', 'quartier',
     'situation_actuelle', 'domaine_activite',
     'niveau_informatique', 'objectif_formation',
     'photo_participant_url', 'cv_url', 'fcm_token',
     'comment_connu', 'consentement_rgpd'
   }
   ```

### ✅ Success Handling
```dart
if (response.data['success'] != true) {
  throw Exception(response.data['error'] ?? 'Erreur serveur');
}
// Navigate to /confirmed with inscription & session data
```

### ❌ Error Handling
```dart
catch (e) {
  state.copyWith(
    status: InscriptionStatus.error,
    errorMessage: e.toString()
  );
  // Show SnackBar with error message
}
```

### 📊 UI Progress States
- **Loading**: Shows `TerminalProgressOverlay` with messages:
  - "Sécurisation des données..."
  - "Upload de la photo..."
  - "Upload des documents..."
  - "Enregistrement du dossier..."
  - "Confirmation envoyée !"

---

## 6️⃣ MODULES - WHERE TO ADD 4 TRAINING MODULES

### 🏗️ Current Module Structure
Module selection is **hardcoded in database** via Edge Function

**Current Location:** `supabase/schema.sql`:
```sql
INSERT INTO sessions_formation (
  titre, date_debut, date_fin, programme, instructeurs
) VALUES (
  'Formation Cybersécurité — Fondamentals & Pratique',
  '2026-05-05', '2026-05-09',
  '[
    {"jour": 1, "titre": "Day 1: Foundations", "modules": [...]},
    {"jour": 2, "titre": "Day 2: ...", "modules": [...]}
  ]',
  '[
    {"nom": "Ing. Abdelhalim Abdoulaye", "specialite": "Ethical Hacking"}
  ]'
)
```

### ✅ WHERE TO ADD: 4 NEW MODULES

#### **Option A: Create New Training Sessions** (RECOMMENDED)
- Add 4 separate `sessions_formation` records in database
- Each session has its own `titre`, `programme`, `instructeurs`
- Users would select which session to take
- **Requires**: Add session selection screen before inscription form

#### **Option B: Convert Modules to Mini-Programs**
- Add `module_type` field (Crypto, IoT, Security, Malware)
- Users select module → Form fills with that module's name
- All use same form, different database target

#### **Option C: Add Post-Formation Module Selection**
- After signup, in "Mon Espace", add **"Choisir Module Supplémentaire"** section
- Users can enroll in: Crypto, IoT Risks, System Security, Malware Detection
- New table: `inscriptions_modules` (links modules to users)

### 📌 Implementation Architecture

**Database structure needed:**
```sql
CREATE TABLE modules (
  id UUID PRIMARY KEY,
  nom TEXT NOT NULL,
  description TEXT,
  duree_jours INT,
  prix NUMERIC,
  specialite TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE inscriptions_modules (
  id UUID PRIMARY KEY,
  inscription_id UUID REFERENCES inscriptions(id),
  module_id UUID REFERENCES modules(id),
  statut TEXT DEFAULT 'en_attente',
  enrolled_at TIMESTAMPTZ DEFAULT NOW()
);
```

**UI Locations:**
1. **Module Selection Screen** → New route after splash/before inscription
2. **Module Info Cards** → Before form with descriptions
3. **Module Progress** → In Mon Espace dashboard
4. **Module Completion** → New confirmation modal

---

## 7️⃣ PUSH NOTIFICATIONS SETUP

### 🔔 Current Setup Status: ✅ CONFIGURED

**Technologies:**
- **Firebase Messaging (FCM)** → For push notifications
- **Flutter Local Notifications** → For displaying notifications

### 📲 Initialization ([main.dart](lib/main.dart))
```dart
// Firebase init
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// Local notifications
await initializeNotifications();

// FCM background handler
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// Request notification permission
await FirebaseMessaging.instance.requestPermission(
  alert: true, badge: true, sound: true
);
```

### 📡 FCM Configuration ([fcm_provider.dart](lib/shared/providers/fcm_provider.dart))

**Providers Available:**
```dart
final fcmTokenProvider = FutureProvider<String?>(...); // Get device token
final notificationPermissionProvider = FutureProvider<bool>(...); // Check permission
final firebaseMessagingProvider = Provider<FirebaseMessaging>(...);
final flutterLocalNotificationsProvider = Provider<FlutterLocalNotificationsPlugin>(...);
```

**Function to send local notifications:**
```dart
Future<void> showLocalNotification({
  required String title,
  required String body,
}) async {
  await FlutterLocalNotificationsPlugin().show(
    0, title, body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'nadirx_channel',
        'NADIRX Technologie',
        channelDescription: 'Notifications de formation',
        color: Color(0xFF00FF88), // Cyangreen
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}
```

### 🚀 WHERE TO ADD ENRICHED NOTIFICATIONS

#### **Current:** Basic local notification on signup
```dart
showLocalNotification(
  title: 'Bienvenue, ${next.inscription!.prenom} ! 🛡️',
  body: 'Votre place est confirmée. NADIRX TECHNOLOGIE vous attend.',
);
```

#### **Enhancement Points:**

**1. Assignment Confirmation** ([confirmed_screen.dart](lib/features/inscription/presentation/screens/confirmed_screen.dart))
```dart
// After successful submission, add:
showLocalNotification(
  title: '✅ Inscription Confirmée!',
  body: 'Dossier #${inscription.shortId} - Rejoignez-nous le 5 mai!',
);
```

**2. Pre-Training Reminders** (NEW - needs scheduling)
```dart
// Send 3 days before training
// 1 day before training
// 2 hours before training
// Requires: FlutterLocalNotifications with scheduled notifications

final plugin = FlutterLocalNotificationsPlugin();
await plugin.zonedSchedule(
  1,
  'La formation commence dans 3 jours! 🚀',
  'Vérifiez que vous avez votre ordinateur et votre pièce d\'identité.',
  tz.TZDateTime.now(tz.local).add(const Duration(days: 3)),
  const NotificationDetails(...),
  uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  matchDateTimeComponents: DateTimeComponents.dateAndTime,
);
```

**3. Module Results** (After module completion)
```dart
showLocalNotification(
  title: 'Bravo! 🎓',
  body: 'Vous avez complété le module "Crypto". Certificat disponible dans Mon Espace.',
);
```

**4. Announcement Broadcast** (From admin via FCM topic)
```dart
// Subscribe users to announcements channel
await FirebaseMessaging.instance.subscribeToTopic('formation_updates');

// Admin sends via Firebase Console or Supabase Edge Function:
// - Schedule changes
// - Room updates
// - Instructor communications
```

### 📝 Firebase Config Status
**Location:** [firebase_options.dart](lib/firebase_options.dart)
- ⚠️ Currently using **PLACEHOLDER values**
- Need to run: `flutterfire configure` to auto-populate with real keys
- Keys needed from Firebase Console:
  - Android API Key
  - iOS Client ID
  - Project ID
  - Storage Bucket

---

## 8️⃣ SOCIAL & CONTACT INFO

### 📞 Current Contact Integration

**Static Contact Info** ([app_config.dart](lib/core/config/app_config.dart))
```dart
static const String contactWhatsapp = '+23568663737';
static const String contactEmail = 'nadirxtechnology@gmail.com';
static const String contactPhone = '+23568881226';
```

### 🔗 Contact Info Display Locations

**1. Mon Espace Screen** ([mon_espace_screen.dart](lib/features/inscription/presentation/screens/mon_espace_screen.dart#L495))
```dart
_buildContactSection() // 3 buttons: WhatsApp, Phone, Email
  ├─ _openWhatsapp() → https://wa.me/23568663737
  ├─ _makeCall() → tel:+23568881226
  └─ _sendEmail() → mailto:nadirxtechnology@gmail.com
```

**2. Confirmed Screen** ([confirmed_screen.dart](lib/features/inscription/presentation/screens/confirmed_screen.dart))
- Contact buttons also appear on success page

**3. Session Formation Card** (Mon Espace)
- Shows training location & dates
- Contact section below

### 🔴 WHERE TO ADD FACEBOOK LINK

**Option 1: Add to Contact Buttons** (Recommended)
```dart
Widget _buildContactSection() {
  return Row(
    children: [
      Expanded(child: _buildContactButton('WhatsApp', ...)),
      Expanded(child: _buildContactButton('Phone', ...)),
      Expanded(child: _buildContactButton('Email', ...)),
      Expanded(child: _buildContactButton('Facebook', PhosphorIcons.facebookLogo(), _openFacebook)), // NEW
    ],
  );
}

Future<void> _openFacebook() async {
  final url = Uri.parse('https://facebook.com/nadirxtech'); // Update URL
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
```

**Option 2: Add to App Config**
```dart
// app_config.dart
static const String contactFacebook = 'https://facebook.com/nadirxtech';
```

**Option 3: Add to Session Formation Contacts**
```dart
// In session_formation database record, add:
"contacts": {
  "email": "...",
  "phone": "...",
  "whatsapp": "...",
  "facebook": "https://facebook.com/nadirxtech"  // NEW
}
```

**Implementation Example:**
```dart
Future<void> _openFacebook() async {
  try {
    // Try to open Facebook app first
    final fbAppUrl = Uri.parse('fb://page/YOUR_PAGE_ID');
    if (await canLaunchUrl(fbAppUrl)) {
      await launchUrl(fbAppUrl);
    } else {
      // Fall back to browser
      final fbUrl = Uri.parse('https://www.facebook.com/nadirxtech');
      await launchUrl(fbUrl, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    debugPrint('Error opening Facebook: $e');
  }
}
```

---

## 📊 CODEBASE STRUCTURE SUMMARY

```
lib/
├── main.dart                          ← App entry, Firebase/Supabase init
├── core/
│   ├── config/
│   │   ├── app_config.dart           ← Backend URLs, contact info
│   │   ├── router_config.dart        ← Navigation routes
│   │   └── theme_config.dart         ← Colors, fonts
│   ├── constants/
│   ├── utils/
│   └── widgets/
├── features/
│   └── inscription/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── splash_screen.dart
│       │   │   ├── inscription_form_screen.dart    ← FORM FIELDS HERE
│       │   │   ├── confirmed_screen.dart           ← SUCCESS PAGE
│       │   │   └── mon_espace_screen.dart          ← DASHBOARD
│       │   └── controllers/
│       │       ├── inscription_form_controller.dart ← SUBMIT LOGIC
│       │       └── photo_upload_controller.dart
│       ├── data/
│       │   ├── datasources/
│       │   │   └── inscription_remote_datasource.dart ← API CALLS
│       │   ├── models/
│       │   │   └── inscription_model.dart
│       │   └── repositories/
│       └── domain/
│           ├── entities/
│           │   ├── inscription_entity.dart
│           │   └── session_formation_entity.dart    ← MODULE STRUCTURE
│           └── repositories/
└── shared/
    └── providers/
        ├── fcm_provider.dart         ← NOTIFICATIONS SETUP
        └── supabase_provider.dart    ← SUPABASE CONFIG
```

---

## 🎯 KEY FINDINGS CHECKLIST

| Requirement | Status | Location |
|---|---|---|
| Backend URLs | ✅ Production Supabase | `app_config.dart` |
| Localhost hardcoding | ✅ NONE FOUND | - |
| Inscription form fields | ✅ Name, phone, city, photo | `inscription_form_screen.dart` |
| Email field | ❌ NOT in form (DB issue) | - |
| Ville/City field | ✅ YES, dropdown | `inscription_form_screen.dart` |
| User authentication | ✅ Anonymous + localStorage | `mon_espace_screen.dart` |
| Data isolation | ⚠️ By localStorage ID only | `app_config.dart` |
| Dashboard screens | ✅ Yes, 3 screens | `/screens/` |
| Submit endpoint | ✅ Edge Function | `inscription_form_controller.dart` |
| Error handling | ✅ Try-catch + snackbars | `inscription_form_controller.dart` |
| Push notifications | ✅ FCM configured | `fcm_provider.dart` |
| Contact buttons | ✅ WhatsApp, Phone, Email | `mon_espace_screen.dart` |
| Facebook integration | ❌ NOT added yet | - |
| 4 Modules display | ✅ From database | `mon_espace_screen.dart` |
| Module selection | ❌ NOT implemented | - |
| Firebase config | ⚠️ Placeholder values | `firebase_options.dart` |

---

## 🚀 NEXT STEPS

### 1. **Add Email to Form** (HIGH PRIORITY)
   - Update [inscription_form_screen.dart](lib/features/inscription/presentation/screens/inscription_form_screen.dart)
   - Add email validator
   - Sync with database schema

### 2. **Enhance Notifications** (MEDIUM)
   - Add scheduled reminders
   - Send FCM from admin dashboard
   - Show notification badges

### 3. **Add Facebook Link** (LOW)
   - Update contact section with Facebook button
   - Add URL to `app_config.dart`

### 4. **Implement Module Selection** (HIGH)
   - Create new `modules_selection_screen.dart`
   - Add 4 module options (Crypto, IoT, Security, Malware)
   - Update database schema with `inscriptions_modules` table

### 5. **Security Improvement** (CRITICAL)
   - Implement proper user authentication instead of localStorage
   - Use Supabase Anon Auth with email verification
   - Prevent ID guessing attacks

---

**Document Generated:** March 24, 2026
**App Status:** ✅ Functional with minor data integrity issues
