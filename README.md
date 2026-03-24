# NADIRX TECHNOLOGIE — Formation Cybersécurité

Application Flutter pour la gestion des inscriptions à la formation en cybersécurité de NADIRX TECHNOLOGIE.

## 🛡️ Fonctionnalités

- **Formulaire d'inscription unique** — Pas d'écran de connexion/inscription séparé
- **Acceptation immédiate** — Statut confirmé dès la soumission
- **Univers visuel cyber** — Thème sombre avec accents vert néon
- **Notifications push** — Firebase Cloud Messaging
- **Dashboard admin** — Gestion des inscrits (accès caché)

## 📱 Flux utilisateur

```
Splash → Formulaire → Confirmation → Mon Espace
```

## 🏗️ Architecture

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x
- **Navigation**: GoRouter
- **Backend**: Supabase (PostgreSQL + Auth + Storage + Edge Functions)
- **Notifications**: Firebase Cloud Messaging

## 🚀 Installation

### 1. Cloner le projet

```bash
git clone <repo-url>
cd NADIRX_TECHNOLOGIE
flutter pub get
```

### 2. Configurer Firebase

```bash
flutterfire configure
```

Ou modifier manuellement `lib/firebase_options.dart` avec vos clés Firebase.

### 3. Configurer Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Exécuter le SQL dans `supabase/schema.sql` dans l'éditeur SQL
3. Créer un bucket Storage nommé `participants` (public)
4. Déployer l'Edge Function:

```bash
supabase functions new submit-inscription
# Copier le contenu de supabase/functions/submit-inscription/index.ts
supabase functions deploy submit-inscription
```

5. Ajouter les secrets dans Supabase Dashboard → Edge Functions → Settings:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `FCM_SERVER_KEY`

6. Modifier `lib/core/config/app_config.dart`:

```dart
static const String supabaseUrl = 'https://votre-projet.supabase.co';
static const String supabaseAnonKey = 'votre-anon-key';
```

### 4. Lancer l'application

```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── config/          # Configuration (routes, thème, app)
│   ├── constants/       # Couleurs, chaînes, dimensions
│   ├── painters/        # CustomPainters (grille, matrix)
│   ├── widgets/         # Widgets réutilisables
│   └── utils/           # Validateurs, stockage local
├── features/
│   ├── inscription/     # Feature principale
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── admin/           # Dashboard admin
└── shared/
    └── providers/       # Providers Riverpod
```

## 🎨 Identité visuelle

- **Fond**: `#050508` (noir quasi-pur)
- **Accent principal**: `#00FF88` (vert néon cyber)
- **Accent secondaire**: `#00D4FF` (cyan électrique)
- **Police titres**: ShareTechMono
- **Icônes**: Phosphor Icons

## 🔐 Accès Admin

1. Long press sur le logo NADIRX dans "Mon Espace"
2. Se connecter avec un compte admin Supabase Auth

Pour créer un admin:
```sql
UPDATE auth.users 
SET raw_app_meta_data = raw_app_meta_data || '{"role": "admin"}'::jsonb
WHERE email = 'admin@nadirx.td';
```

## 📦 Dépendances principales

- `supabase_flutter` — Backend
- `flutter_riverpod` — State management
- `go_router` — Navigation
- `firebase_core` / `firebase_messaging` — Notifications
- `google_fonts` — Typographie
- `phosphor_flutter` — Icônes
- `flutter_animate` — Animations
- `image_picker` / `image_cropper` — Photos

## 📄 Licence

Propriétaire — NADIRX TECHNOLOGIE
