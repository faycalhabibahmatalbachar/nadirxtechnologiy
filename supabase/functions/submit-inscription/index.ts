// Supabase Edge Function: submit-inscription
// Inscription (sans email) + notification FCM (optionnelle)

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const FCM_KEY = Deno.env.get('FCM_SERVER_KEY') || '';
const FCM_SERVICE_ACCOUNT_JSON = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON') || '';

const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
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
  possede_ordinateur?: boolean | null;
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
  // Ex: null value in column "email" violates not-null constraint
  const match = message.match(/column\s+\"([^\"]+)\"/i);
  return match?.[1] ?? null;
}

function isNetworkTlsError(message: unknown, details: unknown): boolean {
  const text = `${message ?? ''}\n${details ?? ''}`.toLowerCase();
  return (
    text.includes('tls handshake eof') ||
    text.includes('client error (connect)') ||
    text.includes('connection refused') ||
    text.includes('network') ||
    text.includes('timed out') ||
    text.includes('timeout')
  );
}

function base64UrlEncode(input: Uint8Array): string {
  let str = '';
  for (let i = 0; i < input.length; i++) str += String.fromCharCode(input[i]);
  const b64 = btoa(str);
  return b64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/g, '');
}

function textToUint8(text: string): Uint8Array {
  return new TextEncoder().encode(text);
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const cleaned = pem
    .replace(/-----BEGIN [^-]+-----/g, '')
    .replace(/-----END [^-]+-----/g, '')
    .replace(/\s+/g, '');
  const raw = atob(cleaned);
  const bytes = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
  return bytes.buffer;
}

async function getFcmAccessToken(serviceAccountJson: string): Promise<{
  accessToken: string;
  projectId: string;
}> {
  const sa = JSON.parse(serviceAccountJson);
  const clientEmail = String(sa.client_email || '');
  const privateKey = String(sa.private_key || '');
  const projectId = String(sa.project_id || '');
  if (!clientEmail || !privateKey || !projectId) {
    throw new Error('FCM service account JSON incomplet (client_email/private_key/project_id)');
  }

  const header = base64UrlEncode(textToUint8(JSON.stringify({ alg: 'RS256', typ: 'JWT' })));
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 60 * 50;
  const payload = base64UrlEncode(
    textToUint8(
      JSON.stringify({
        iss: clientEmail,
        scope: 'https://www.googleapis.com/auth/firebase.messaging',
        aud: 'https://oauth2.googleapis.com/token',
        iat,
        exp,
      }),
    ),
  );

  const signingInput = `${header}.${payload}`;

  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToArrayBuffer(privateKey),
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    textToUint8(signingInput),
  );
  const jwt = `${signingInput}.${base64UrlEncode(new Uint8Array(signature))}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  const text = await res.text();
  if (!res.ok) {
    throw new Error(`OAuth token error ${res.status}: ${text}`);
  }
  const json = JSON.parse(text);
  const accessToken = String(json.access_token || '');
  if (!accessToken) throw new Error('OAuth token response missing access_token');
  return { accessToken, projectId };
}

async function sendFcmHttpV1(params: {
  serviceAccountJson: string;
  token: string;
  title: string;
  body: string;
  imageUrl?: string;
  data?: Record<string, string>;
}): Promise<boolean> {
  const { accessToken, projectId } = await getFcmAccessToken(params.serviceAccountJson);
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const message: any = {
    token: params.token,
    notification: {
      title: params.title,
      body: params.body,
    },
    data: params.data ?? {},
    android: {
      priority: 'HIGH',
      notification: {
        channel_id: 'nadirx_channel',
        color: '#00FF88',
        icon: 'ic_notification',
        image: params.imageUrl || undefined,
      },
    },
  };

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({ message }),
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => '');
    console.error('FCM v1 response not ok:', res.status, txt);
  }
  return res.ok;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: { ...corsHeaders, 'Content-Type': 'text/plain' },
      status: 200,
    });
  }

  try {
    const body = (await req.json()) as InscriptionBody;
    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

    console.log('Données reçues:', body);

    const nom = requiredString(body.nom);
    const prenom = requiredString(body.prenom);
    const date_naissance = requiredString(body.date_naissance);
    const telephone = requiredString(body.telephone);
    const ville = requiredString(body.ville);
    const situation_actuelle = requiredString(body.situation_actuelle);
    const niveau_informatique = requiredString(body.niveau_informatique);
    const photo_participant_url = requiredString(body.photo_participant_url);
    const possede_ordinateur =
      typeof body.possede_ordinateur === 'boolean' ? body.possede_ordinateur : null;

    const requiredPairs: Array<[string, string | null]> = [
      ['nom', nom],
      ['prenom', prenom],
      ['date_naissance', date_naissance],
      ['telephone', telephone],
      ['ville', ville],
      ['situation_actuelle', situation_actuelle],
      ['niveau_informatique', niveau_informatique],
      ['photo_participant_url', photo_participant_url],
    ];

    console.log('Champs obligatoires:', requiredPairs);

    for (const [field, value] of requiredPairs) {
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

    if (possede_ordinateur === null) {
      return jsonResponse(
        {
          success: false,
          error_code: 'VALIDATION_ERROR',
          field: 'possede_ordinateur',
          error: 'Champ obligatoire manquant: possede_ordinateur.',
        },
        400,
      );
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
        possede_ordinateur,
        objectif_formation: body.objectif_formation ?? null,
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
      const insertMessage = (insertError as any)?.message ?? '';
      const insertDetails = (insertError as any)?.details ?? '';

      if (isNetworkTlsError(insertMessage, insertDetails)) {
        return jsonResponse(
          {
            success: false,
            error_code: 'NETWORK_ERROR',
            error:
              'Incident réseau temporaire entre la fonction et la base de données. Réessayez dans quelques instants.',
            details: insertDetails || null,
          },
          503,
        );
      }

      if (pgCode === '23505') {
        const duplicateField =
          inferDuplicateField((insertError as any)?.details) ?? 'unknown';
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
        const field =
          inferNotNullField((insertError as any)?.message) ?? 'unknown';
        const hint = null;
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
          error: insertMessage || 'Erreur base de données',
          details: insertDetails || null,
        },
        400,
      );
    }

    let notification_attempted = false;
    let notification_sent = false;

    if (inscription?.fcm_token && (FCM_SERVICE_ACCOUNT_JSON || FCM_KEY)) {
      notification_attempted = true;
      try {
        const fullName = `${inscription.nom} ${inscription.prenom}`;
        const title = `Félicitations ${fullName} !`;
        const bodyText =
          'Votre inscription est confirmée. Rendez-vous chez LALEKOU INFORMATIQUE.';

        if (FCM_SERVICE_ACCOUNT_JSON) {
          notification_sent = await sendFcmHttpV1({
            serviceAccountJson: FCM_SERVICE_ACCOUNT_JSON,
            token: inscription.fcm_token,
            title,
            body: bodyText,
            imageUrl: inscription.photo_participant_url || undefined,
            data: {
              type: 'bienvenue',
              inscription_id: inscription.id,
              full_name: fullName,
              nom: String(inscription.nom ?? ''),
              prenom: String(inscription.prenom ?? ''),
              telephone: String(inscription.telephone ?? ''),
              ville: String(inscription.ville ?? ''),
              photo_url: inscription.photo_participant_url || '',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
          });
        } else {
          const res = await fetch('https://fcm.googleapis.com/fcm/send', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `key=${FCM_KEY}`,
            },
            body: JSON.stringify({
              to: inscription.fcm_token,
              notification: {
                title,
                body: bodyText,
                sound: 'default',
                image: inscription.photo_participant_url || undefined,
              },
              data: {
                type: 'bienvenue',
                inscription_id: inscription.id,
                full_name: fullName,
                nom: String(inscription.nom ?? ''),
                prenom: String(inscription.prenom ?? ''),
                telephone: String(inscription.telephone ?? ''),
                ville: String(inscription.ville ?? ''),
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
            }),
          });

          notification_sent = res.ok;
          if (!res.ok) {
            const text = await res.text().catch(() => '');
            console.error('FCM response not ok:', res.status, text);
          }
        }
      } catch (fcmError) {
        console.error('FCM error:', fcmError);
      }
    } else {
      if (!inscription?.fcm_token) {
        console.log('FCM skipped: no fcm_token provided');
      } else if (!FCM_SERVICE_ACCOUNT_JSON && !FCM_KEY) {
        console.error('FCM skipped: missing FCM_SERVICE_ACCOUNT_JSON and FCM_SERVER_KEY');
      }
    }

    try {
      await supabase.from('notifications_log').insert({
        inscription_id: inscription.id,
        type: 'bienvenue',
        titre: `Bienvenue, ${inscription.prenom} !`,
        corps: 'Votre place est confirmée chez LALEKOU INFORMATIQUE.',
        envoyee: notification_sent,
        envoyee_at: notification_attempted ? new Date().toISOString() : null,
      });
    } catch (logError) {
      console.error('notifications_log error:', logError);
    }

    return jsonResponse(
      {
        success: true,
        inscription_id: inscription.id,
        data: inscription,
        notification_attempted,
        notification_sent,
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

