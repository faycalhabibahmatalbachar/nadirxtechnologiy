-- ============================================================
-- NADIRX TECHNOLOGY — Base d'inscriptions cybersécurité
-- Exécuter dans Supabase SQL Editor
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLE PRINCIPALE : inscriptions
-- ============================================================
CREATE TABLE IF NOT EXISTS public.inscriptions (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- ── IDENTITÉ ──────────────────────────────────────────────
  nom                   VARCHAR(100) NOT NULL,
  prenom                VARCHAR(100) NOT NULL,
  date_naissance        DATE NOT NULL,
  genre                 VARCHAR(10),              -- 'homme','femme','autre'
  nationalite           VARCHAR(80) NOT NULL DEFAULT 'Tchadienne',

  -- ── CONTACT ───────────────────────────────────────────────
  telephone             VARCHAR(20) NOT NULL,
  ville                 VARCHAR(100) NOT NULL,
  quartier              VARCHAR(150),

  -- ── ACTIVITÉ PROFESSIONNELLE ──────────────────────────────
  situation_actuelle    VARCHAR(50) NOT NULL,
  -- Valeurs possibles : 'etudiant' | 'salarie_prive' | 'salarie_public' |
  -- 'freelance' | 'entrepreneur' | 'sans_emploi' | 'autre'
  domaine_activite      VARCHAR(200),
  niveau_informatique   VARCHAR(20) NOT NULL,
  -- Valeurs : 'debutant' | 'intermediaire' | 'avance'
  possede_ordinateur    BOOLEAN NOT NULL,
  objectif_formation    TEXT NOT NULL,

  -- ── PHOTO DU PARTICIPANT ──────────────────────────────────
  -- OBLIGATOIRE — Photo portrait du candidat
  photo_participant_url TEXT NOT NULL,

  -- ── DOCUMENT OPTIONNEL ────────────────────────────────────
  cv_url                TEXT,

  -- ── ÉTAT DU DOSSIER ───────────────────────────────────────
  -- TOUJOURS 'confirme' à l'insertion
  statut                VARCHAR(30) NOT NULL DEFAULT 'confirme',

  -- ── NOTIFICATION ──────────────────────────────────────────
  fcm_token             TEXT,

  -- ── MÉTADONNÉES ───────────────────────────────────────────
  consentement_rgpd     BOOLEAN NOT NULL DEFAULT TRUE,
  comment_connu         VARCHAR(100),
  -- 'reseaux_sociaux' | 'bouche_oreille' | 'affiche' | 'web' | 'ami'
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- ── CHAMPS ADMIN UNIQUEMENT ───────────────────────────────
  note_admin            TEXT,
  tag_admin             VARCHAR(50),
  -- 'prioritaire' | 'a_rappeler' | 'doublon' | 'vip'
  admin_viewed          BOOLEAN DEFAULT FALSE
);

-- ============================================================
-- TABLE : sessions_formation
-- ============================================================
CREATE TABLE IF NOT EXISTS public.sessions_formation (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  titre            VARCHAR(200) NOT NULL UNIQUE,
  sous_titre       VARCHAR(300),
  date_debut       DATE NOT NULL,
  date_fin         DATE NOT NULL,
  horaire          VARCHAR(100) DEFAULT '08h00 – 17h00',
  lieu             VARCHAR(300) NOT NULL,
  adresse_complete TEXT,
  programme        JSONB,
  instructeurs     JSONB,
  contacts         JSONB,
  places_max       INTEGER DEFAULT 25,
  active           BOOLEAN DEFAULT TRUE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- MIGRATION: Ajouter contraintes UNIQUE (si table existe déjà)
-- ============================================================
DO
$$
BEGIN
  -- Essayer d'ajouter la contrainte UNIQUE sur titre
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'sessions_formation'
    AND constraint_type = 'UNIQUE'
    AND constraint_name LIKE '%titre%'
  ) THEN
    ALTER TABLE public.sessions_formation ADD CONSTRAINT sessions_formation_titre_key UNIQUE (titre);
  END IF;

  -- Nettoyage: suppression du champ email (inscription sans email)
  ALTER TABLE public.inscriptions DROP CONSTRAINT IF EXISTS inscriptions_email_key;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'inscriptions'
    AND column_name = 'email'
  ) THEN
    ALTER TABLE public.inscriptions DROP COLUMN email;
  END IF;
END
$$;

-- ============================================================
-- TABLE : notifications_log
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications_log (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inscription_id   UUID REFERENCES public.inscriptions(id) ON DELETE CASCADE,
  type             VARCHAR(50),
  titre            VARCHAR(200),
  corps            TEXT,
  envoyee          BOOLEAN DEFAULT FALSE,
  envoyee_at       TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TRIGGER : updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS inscriptions_updated_at ON public.inscriptions;
CREATE TRIGGER inscriptions_updated_at
  BEFORE UPDATE ON public.inscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- RLS : Les candidats n'ont PAS d'auth Supabase
-- Toutes les insertions passent par Edge Function (service role)
-- ============================================================
ALTER TABLE public.inscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions_formation ENABLE ROW LEVEL SECURITY;

-- Lecture publique par ID
DROP POLICY IF EXISTS "lecture_par_id" ON public.inscriptions;
CREATE POLICY "lecture_par_id" ON public.inscriptions
  FOR SELECT USING (true);

-- Sessions : lisibles par tous
DROP POLICY IF EXISTS "sessions_publiques" ON public.sessions_formation;
CREATE POLICY "sessions_publiques" ON public.sessions_formation
  FOR SELECT USING (active = true);

-- ============================================================
-- DONNÉES INITIALES — Session de formation NADIRX TECHNOLOGY
-- ============================================================
INSERT INTO public.sessions_formation (
  titre, sous_titre, date_debut, date_fin, horaire,
  lieu, adresse_complete, programme, instructeurs, contacts, places_max
) VALUES (
  'Formation Cybersécurité — Fondamentaux & Pratique',
  'Ethical Hacking, Forensics & Sécurité des Réseaux',
  '2026-04-10',
  '2026-04-24',
  'SESSION: 8H-11H et 15H-18H',
  'LALEKOU INFORMATIQUE Abena, près de la clinique la Grâce',
  'Quartier Khazala, Rond Point 10 Octobre, N''Djaména, Tchad',
  '[
    {
      "jour": 1,
      "titre": "Modules 1 à 4",
      "modules": [
        "Vulnérabilités courantes des réseaux sans fil",
        "Panorama des objets connectés (caméras, capteurs, dispositifs domestiques)",
        "Gestion des accès et des privilèges",
        "Détection & élimination de malwares"
      ]
    }
  ]',
  '[
    {"nom": "Ing. Abdelhalim Abdoulaye", "specialite": "Ethical Hacking & Pentest"},
    {"nom": "Ing. Faycal Habib Ahmat", "specialite": "Forensics & Sécurité Réseau"}
  ]',
  '{"whatsapp": "+23568663737", "telephone": "+23568881226/91912191", "facebook": "https://www.facebook.com/faycalhabibahmat"}',
  25
) ON CONFLICT (titre) DO UPDATE SET 
  programme = EXCLUDED.programme,
  contacts = EXCLUDED.contacts,
  instructeurs = EXCLUDED.instructeurs;

-- ============================================================
-- CRÉER UN ADMIN (optionnel)
-- Exécuter après avoir créé un compte Supabase Auth
-- ============================================================
-- UPDATE auth.users 
-- SET raw_app_meta_data = raw_app_meta_data || '{"role": "admin"}'::jsonb
-- WHERE id = '...';
