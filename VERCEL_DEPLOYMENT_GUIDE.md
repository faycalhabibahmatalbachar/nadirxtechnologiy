# Déploiement Vercel - Guide Complet

## 📋 Résumé

Ce guide explique comment déployer :
1. **Admin Dashboard** (Next.js) sur Vercel
2. **Flutter Mobile App** pour pointer vers les URLs publiques
3. Configuration des variables d'environnement publiques

## 1️⃣ Déployer l'Admin Dashboard sur Vercel

### Étape 1: Créer un compte Vercel
1. Aller sur https://vercel.com
2. Créer un compte (GitHub recommandé)
3. Se connecter

### Étape 2: Vous avez deux options

#### **Option A: Déploiement Direct depuis GitHub** (Recommandé)

1. **Push le code sur GitHub**
   ```bash
   cd c:\Users\faycalhabibahmat\Desktop\NADIRX_TECHNOLOGIE
   git init
   git add .
   git commit -m "Initial commit: NADIRX app avec admin dashboard"
   git remote add origin https://github.com/YOUR_USERNAME/nadirx-technologie.git
   git branch -M main
   git push -u origin main
   ```

2. **Importer dans Vercel**
   - Aller sur https://vercel.com/new
   - Cliquer "Import Git Repository"
   - Sélectionner le repo NADIRX
   - Cliquer "Import"

3. **Configure les variables d'environnement**
   - Dans Vercel, aller à "Settings" > "Environment Variables"
   - Ajouter:
   ```
   NEXT_PUBLIC_SUPABASE_URL = https://xbrlpovbwwyjvefblmuz.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIs...
   ```
   - Cliquer "Save"

4. **Choisir le répertoire root**
   - Dans "Root Directory", sélectionner `admin`
   - Cliquer "Deploy"

#### **Option B: CLI Vercel**

1. **Installer la CLI Vercel**
   ```bash
   npm install -g vercel
   ```

2. **Se connecter à Vercel**
   ```bash
   vercel login
   ```

3. **Déployer l'admin**
   ```bash
   cd admin
   vercel --prod
   ```

4. **Suivre les prompts**
   - Confirmer le répertoire: `admin`
   - Laisser les paramètres par défaut
   - Vérifier le déploiement

### Étape 3: Configurer le domaine custom (optionnel)

**Sans custom domain:**
- URL par défaut: `https://nadirx-technologie.vercel.app`

**Avec custom domain:**
1. Dans Vercel, aller à "Settings" > "Domains"
2. Ajouter votre domaine
3. Suivre les instructions DNS

## 2️⃣ Mettre à jour l'app mobile

### Changer l'URL Supabase Edge Function

L'app mobile doit pointer vers l'URL publique du backend.

**Avant:** `http://localhost:8000` (local)
**Après:** `https://xbrlpovbwwyjvefblmuz.supabase.co` (public)

L'app mobile utilise déjà l'URL Supabase public, donc aucun changement nécessaire! ✅

### Paramètres mobiles (optional)

Si vous voulez ajouter un lien vers l'admin dashboard:

1. Éditer `lib/main.dart`
2. Ajouter une constante:
   ```dart
   const String ADMIN_DASHBOARD_URL = 'https://nadirx-technologie.vercel.app';
   ```
3. Utiliser cette URL pour les liens admin

## 3️⃣ URLs Publiques Finales

### Admin Dashboard
```
Production: https://nadirx-technologie.vercel.app
Development: http://localhost:3000
```

### Mobile App Backend
```
Supabase: https://xbrlpovbwwyjvefblmuz.supabase.co
API REST: https://xbrlpovbwwyjvefblmuz.supabase.co/rest/v1
Edge Functions: https://xbrlpovbwwyjvefblmuz.supabase.co/functions/v1
```

### Mobile App
```
iOS: TestFlight (après build)
Android: Google Play Store (après build)
```

## 4️⃣ Tester le Déploiement

### Vérifier l'admin dashboard
1. Ouvrir: https://nadirx-technologie.vercel.app
2. Vérifier que les inscriptions s'affichent
3. Tester les filtres
4. Télécharger une photo

### Vérifier l'app mobile
1. Ouvrir l'app sur téléphone
2. Soumettre une nouvelle inscription
3. La nouvelle inscription doit apparaître dans:
   - Dashboard admin (https://nadirx-technologie.vercel.app)
   - Base de données Supabase

## 5️⃣ Variables d'environnement - Résumé

### Admin Dashboard (.env.local)
```env
NEXT_PUBLIC_SUPABASE_URL=https://xbrlpovbwwyjvefblmuz.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```

### Mobile App (pubspec.yaml)
```yaml
# Déjà configuré pour Supabase public
dependencies:
  supabase_flutter: ^1.x.x
```

### Flutter Configuration
```dart
// lib/firebase_options.dart et supabase setup
// Déjà pointe vers Supabase public
final supabase = Supabase.instance.client;
```

## 6️⃣ Domaine Personnalisé (Optionnel)

### Ajouter un domaine personnalisé

**Exemple:** `admin.nadirx-td.com`

1. **Chez votre fournisseur DNS**
   - Ajouter un enregistrement CNAME:
   ```
   admin.nadirx-td.com → nadirx-technologie.vercel.app
   ```

2. **Dans Vercel**
   - Settings > Domains
   - Ajouter: `admin.nadirx-td.com`
   - Vérifier le CNAME
   - Waiting for DNS propagation (5-48h)

3. **Résultat**
   - Admin accessible sur: `https://admin.nadirx-td.com`

## 7️⃣ Problèmes Courants & Solutions

| Problème | Cause | Solution |
|----------|-------|----------|
| "404 Not Found" | Routes Next.js mal configurées | Vérifier `src/app/page.tsx` existe |
| "Missing env vars" | Vars non définies dans Vercel | Ajouter dans Vercel Settings > Env Vars |
| "Images not loading" | Domaine Supabase bloqué | Vérifier RLS policies et buckets publics |
| "Database 401" | Anon key invalide | Copier la KEY exacte depuis Supabase |

## 8️⃣ Workflow Continu

### Chaque mise à jour

1. **Localement**
   ```bash
   npm run dev  # Tester localement
   ```

2. **Commit et Push**
   ```bash
   git add .
   git commit -m "Description des changements"
   git push origin main
   ```

3. **Vercel déploie automatiquement**
   - Vercel détecte le push
   - Redéploie automatiquement
   - Voir status sur https://vercel.com/dashboard

4. **Vérifier en production**
   - Ouvrir: https://nadirx-technologie.vercel.app
   - Vérifier les changements

## 9️⃣ Optimisations Vercel

### Performance
- Vercel utilise edge network - ultra rapide ✅
- Images optimisées automatiquement ✅
- Code minifié et bundlé ✅

### Monitoring
- Vercel Analytics (gratuit)
- Voir: Vercel Dashboard > Analytics
- Monitore requests, temps de réponse

### Scaling
- Vercel scale automatiquement
- Zéro configuration
- Supporte 1000s d'utilisateurs simultanés

## 🔟 Checklist Déploiement Complet

### Admin Dashboard
- [ ] Code sur GitHub
- [ ] Projet créé dans Vercel
- [ ] Environnement variables configurées
- [ ] Déploiement réussi (green ✅)
- [ ] URL accessible depuis navigateur
- [ ] Inscriptions s'affichent
- [ ] Filtres fonctionnent
- [ ] Photos téléchar bien
- [ ] Modifications sauvegardées

### Mobile App
- [ ] Pointe vers Supabase public (déjà ok)
- [ ] Nouvelle inscription → visible dans l'admin
- [ ] Upload photo fonctionne
- [ ] Pas d'erreurs réseau

### Custom Domain (optionnel)
- [ ] Domaine acheté
- [ ] CNAME configuré chez DNS
- [ ] Vercel reconnaît le domaine
- [ ] SSL certificate auto-provisioned ✅

## 📊 Coûts

### Option Gratuite (Recommended)
- Vercel: **Gratuit** (Hobby plan)
  - 100 GB bandwidth/mois
  - 10,000 function invocations/mois
  - Auto-scaling

- Supabase: **Gratuit** (Free plan)
  - 500 MB stockage
  - 1 GB bande passante
  - Suffisant pour démarrage

### Option Payante (Si besoin)
- Vercel Pro: **20$/mois**
  - Support prioritaire
  - 500 GB bandwidth
  - Custom domains illimités

- Supabase Pro: **25$/mois**
  - 8 GB stockage
  - 100 GB bande passante
  - Support

## 🎯 Après Déploiement

### Tâches à faire

1. **Sauvegarder les URLs publiques**
   ```
   Admin: https://nadirx-technologie.vercel.app
   API: https://xbrlpovbwwyjvefblmuz.supabase.co
   ```

2. **Tester ensemble**
   - Admin ouverte dans navigateur
   - Mobile en main
   - Soumettre inscription  
   - Vérifier sync en temps réel

3. **Inviter l'équipe**
   - Partager URL admin
   - Créer comptes utilisateurs (optionnel)
   - Configurer permissions (optionnel)

4. **Monitoring continu**
   - Vérifier Vercel Analytics
   - Monitorer Supabase usage
   - Alertes si problèmes

---

**Statut**: Configuration Prête
**Next Step**: Exécuter le déploiement Vercel
**Support**: Vercel Support (gratuit) + Supabase Docs

💡 **Conseil**: Commencez par le déploiement GitHub > Vercel (plus simple automatisé)!
