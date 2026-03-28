import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please create .env.local file with:\n' +
    'NEXT_PUBLIC_SUPABASE_URL=https://xbrlpovbwwyjvefblmuz.supabase.co\n' +
    'NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here'
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface Inscription {
  id: string;
  nom: string;
  prenom: string;
  telephone: string;
  ville: string;
  quartier?: string;
  date_naissance: string;
  genre?: string;
  nationalite?: string;
  situation_actuelle: string;
  domaine_activite?: string;
  niveau_informatique: string;
  possede_ordinateur: boolean;
  objectif_formation: string;
  photo_participant_url: string;
  cv_url?: string;
  fcm_token?: string;
  statut: 'confirme' | 'en_attente' | 'rejetee';
  consentement_rgpd: boolean;
  comment_connu?: string;
  note_admin?: string;
  tag_admin?: string;
  admin_viewed: boolean;
  created_at: string;
  updated_at: string;
}
