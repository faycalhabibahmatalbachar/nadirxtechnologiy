// Supabase Edge Function: submit-inscription
// Gère l'inscription avec la Service Role Key + notification FCM (optionnelle)

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const FCM_KEY = Deno.env.get('FCM_SERVER_KEY') || '';

const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

type InscriptionBody = {
  nom?: string;
  prenom?: string;
  date_naissance?: string;
  genre?: string | null;
  nationalite?: string | null;
  telephone?: string;
  ville?: string;
  quartier?: string | null;
  situation_actuelle?: string;
  domaine_activite?: string | null;
  niveau_informatique?: string;
  objectif_formation?: string;
  photo_participant_url?: string;
  cv_url?: string | null;
  fcm_token?: string | null;
  comment_connu?: string | null;
  consentement_rgpd?: boolean;
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status,
  });
}

function requiredString(value: unknown): string | null {
  const s = (value ?? '').toString().trim();
  return s.length > 0 ? s : null;
}

function inferDuplicateField(details: unknown): string | null {
  if (typeof details !== 'string') return null;
  const match = details.match(/Key\s+\(([^)]+)\)=/i);
  return match?.[1] ?? null;
}

function inferConstraintName(message: unknown): string | null {
  if (typeof message !== 'string') return null;
  const match = message.match(/constraint\s+\"([^\"]+)\"/i);
  return match?.[1] ?? null;
}

function inferNotNullField(message: unknown): string | null {
  if (typeof message !== 'string') return null;
  const match = message.match(/column\s+\"([^\"]+)\"/i);
  return match?.[1] ?? null;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: { ...corsHeaders, 'Content-Type': 'text/plain' },
      status: 200,
    });
  }

  try {
    const body = (await req.json()) as InscriptionBody;
    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

    const nom = requiredString(body.nom);
    const prenom = requiredString(body.prenom);
    const date_naissance = requiredString(body.date_naissance);
    const telephone = requiredString(body.telephone);
    const ville = requiredString(body.ville);
    const situation_actuelle = requiredString(body.situation_actuelle);
    const niveau_informatique = requiredString(body.niveau_informatique);
    const objectif_formation = requiredString(body.objectif_formation);
    const photo_participant_url = requiredString(body.photo_participant_url);

    const requiredFields: Array<[string, string | null]> = [
      ['nom', nom],
      ['prenom', prenom],
      ['date_naissance', date_naissance],
      ['telephone', telephone],
      ['ville', ville],
      ['situation_actuelle', situation_actuelle],
      ['niveau_informatique', niveau_informatique],
      ['objectif_formation', objectif_formation],
      ['photo_participant_url', photo_participant_url],
    ];

    for (const [field, value] of requiredFields) {
      if (!value) {
        return jsonResponse(
          {
            success: false,
            error_code: 'VALIDATION_ERROR',
            field,
            error: `Champ obligatoire manquant: ${field}.`,
          },
          400,
        );
      }
    }

    const { data: inscription, error: insertError } = await supabase
      .from('inscriptions')
      .insert({
        nom,
        prenom,
        date_naissance,
        genre: body.genre ?? null,
        nationalite: body.nationalite ?? 'Tchadienne',
        telephone,
        ville,
        quartier: body.quartier ?? null,
        situation_actuelle,
        domaine_activite: body.domaine_activite ?? null,
        niveau_informatique,
        objectif_formation,
        photo_participant_url,
        cv_url: body.cv_url ?? null,
        fcm_token: body.fcm_token ?? null,
        comment_connu: body.comment_connu ?? null,
        consentement_rgpd: true,
        statut: 'confirme',
      })
      .select()
      .single();

    if (insertError) {
      console.error('Insert error:', insertError);
      const pgCode = (insertError as any)?.code?.toString() ?? '';

      if (pgCode === '23505') {
        const duplicateField = inferDuplicateField((insertError as any)?.details) ?? 'unknown';
        const constraint = inferConstraintName((insertError as any)?.message);
        return jsonResponse(
          {
            success: false,
            error_code: 'DUPLICATE',
            field: duplicateField,
            constraint,
            error: 'Cette inscription existe déjà.',
          },
          409,
        );
      }

      if (pgCode === '23502') {
        const field = inferNotNullField((insertError as any)?.message) ?? 'unknown';
        const hint =
          field === 'email'
            ? "La base de données attend encore le champ email. Exécutez le SQL (schema.sql) pour supprimer/rendre nullable la colonne email."
            : null;
        return jsonResponse(
          {
            success: false,
            error_code: 'NOT_NULL_VIOLATION',
            field,
            hint,
            error: `Champ obligatoire manquant côté serveur: ${field}.`,
          },
          400,
        );
      }

      if (pgCode === '42703') {
        return jsonResponse(
          {
            success: false,
            error_code: 'SCHEMA_MISMATCH',
            error:
              "La table Supabase ne correspond pas au schéma attendu (colonne manquante/renommée). Vérifiez la table 'inscriptions'.",
            details: (insertError as any)?.message ?? null,
          },
          400,
        );
      }

      return jsonResponse(
        {
          success: false,
          error_code: pgCode || 'DB_ERROR',
          error: (insertError as any)?.message ?? 'Erreur base de données',
          details: (insertError as any)?.details ?? null,
        },
        400,
      );
    }

    if (inscription?.fcm_token && FCM_KEY) {
      try {
        const fullName = `${inscription.prenom} ${inscription.nom}`;
        await fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `key=${FCM_KEY}`,
          },
          body: JSON.stringify({
            to: inscription.fcm_token,
            notification: {
              title: `Bienvenue ${fullName}!`,
              body: 'Votre inscription est confirmée. Vous pouvez consulter votre profil.',
              sound: 'default',
              image: inscription.photo_participant_url || undefined,
            },
            data: {
              type: 'bienvenue',
              inscription_id: inscription.id,
              full_name: fullName,
              photo_url: inscription.photo_participant_url || '',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
              priority: 'high',
              notification: {
                channel_id: 'nadirx_channel',
                color: '#00FF88',
                icon: 'ic_notification',
                image: inscription.photo_participant_url || undefined,
              },
            },
            webpush: {
              notification: {
                title: `Bienvenue ${fullName}!`,
                body: 'Votre inscription est confirmée.',
                image: inscription.photo_participant_url || undefined,
                badge:
                  'https://xbrlpovbwwyjvefblmuz.supabase.co/storage/v1/object/public/participant-photos/nadirx-badge.png',
              },
            },
          }),
        });
      } catch (fcmError) {
        console.error('FCM error:', fcmError);
      }
    }

    try {
      await supabase.from('notifications_log').insert({
        inscription_id: inscription.id,
        type: 'bienvenue',
        titre: `Bienvenue, ${inscription.prenom} !`,
        corps: 'Votre place est confirmée chez NADIRX TECHNOLOGY.',
        envoyee: inscription.fcm_token ? true : false,
        envoyee_at: new Date().toISOString(),
      });
    } catch (logError) {
      console.error('notifications_log error:', logError);
    }

    return jsonResponse(
      {
        success: true,
        inscription_id: inscription.id,
        data: inscription,
      },
      200,
    );
  } catch (err) {
    console.error('Error:', err);
    return jsonResponse(
      {
        success: false,
        error_code: (err as any)?.code ?? 'UNKNOWN',
        error: (err as any)?.message ?? String(err),
        details: (err as any)?.details ?? null,
      },
      400,
    );
  }
});

