// Supabase Edge Function: submit-inscription
// Cette fonction gère l'inscription avec la service role key
// et envoie les notifications FCM

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FCM_KEY      = Deno.env.get("FCM_SERVER_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { 
      headers: { ...corsHeaders, "Content-Type": "text/plain" },
      status: 200 
    });
  }

  try {
    const body = await req.json();
    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

    // ── 1. Insérer l'inscription avec statut 'confirme' immédiatement ──
    const { data: inscription, error: insertError } = await supabase
      .from("inscriptions")
      .insert({
        nom:                   body.nom,
        prenom:                body.prenom,
        date_naissance:        body.date_naissance,
        genre:                 body.genre,
        nationalite:           body.nationalite ?? 'Tchadienne',
        email:                 body.email,
        telephone:             body.telephone,
        ville:                 body.ville,
        quartier:              body.quartier,
        situation_actuelle:    body.situation_actuelle,
        domaine_activite:      body.domaine_activite,
        niveau_informatique:   body.niveau_informatique,
        objectif_formation:    body.objectif_formation,
        photo_participant_url: body.photo_participant_url,
        cv_url:                body.cv_url ?? null,
        fcm_token:             body.fcm_token ?? null,
        comment_connu:         body.comment_connu ?? null,
        consentement_rgpd:     true,
        statut:                "confirme",  // ← TOUJOURS confirmé
      })
      .select()
      .single();

    if (insertError) {
      console.error("Insert error:", insertError);
      throw insertError;
    }

    // ── 2. Notification push FCM ──
    if (inscription.fcm_token && FCM_KEY) {
      try {
        await fetch("https://fcm.googleapis.com/fcm/send", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `key=${FCM_KEY}`,
          },
          body: JSON.stringify({
            to: inscription.fcm_token,
            notification: {
              title: `Bienvenue, ${inscription.prenom} ! 🛡️`,
              body:  "Votre place est confirmée. NADIRX TECHNOLOGIE vous attend.",
              sound: "default",
            },
            data: {
              type:           "bienvenue",
              inscription_id: inscription.id,
              click_action:   "FLUTTER_NOTIFICATION_CLICK",
            },
            android: {
              priority: "high",
              notification: {
                channel_id: "nadirx_channel",
                color:      "#00FF88",
                icon:       "ic_notification",
              },
            },
          }),
        });
      } catch (fcmError) {
        console.error("FCM error:", fcmError);
        // Ne pas échouer l'inscription si FCM échoue
      }
    }

    // ── 3. Logger notification ──
    await supabase.from("notifications_log").insert({
      inscription_id: inscription.id,
      type:           "bienvenue",
      titre:          `Bienvenue, ${inscription.prenom} !`,
      corps:          "Votre place est confirmée chez NADIRX TECHNOLOGIE.",
      envoyee:        inscription.fcm_token ? true : false,
      envoyee_at:     new Date().toISOString(),
    });

    return new Response(
      JSON.stringify({ 
        success: true, 
        inscription_id: inscription.id, 
        data: inscription 
      }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" }, 
        status: 200 
      }
    );

  } catch (err) {
    console.error("Error:", err);
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" }, 
        status: 400 
      }
    );
  }
});
