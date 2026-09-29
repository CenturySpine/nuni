// Delivers the planning notifications (plan 33). Called only by the database (_notify in
// migration 20260929120000_push_notifications.sql) with the recipients' account ids and the
// event's fields; writes the text in each device's app language (Q230) and sends it through
// the browser's push service with the VAPID keys (standard Web Push, no third party, Q224).
//
// The texts live here, not in the app's ARB files: they are written on the server, while the
// app is closed (exception noted in AGENTS.md). Deploy: npx supabase functions deploy send-push
// (docs/DEV.md). Secrets: VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, VAPID_SUBJECT and
// PUSH_FUNCTION_SECRET (the same value as the push_function_secret Vault secret).

import { createClient } from "jsr:@supabase/supabase-js@2";
import webpush from "npm:web-push@3.6.7";

type Kind = "response" | "comment" | "session_started" | "new_event";
type Locale = "fr" | "en";

interface Payload {
  kind: Kind;
  user_ids: string[];
  event_id: string;
  event_label: string;
  starts_at: string;
  place: string | null;
  actor: string | null;
  // "response" only: the new answer, null once withdrawn (Q226).
  response?: "yes" | "no" | "maybe" | null;
  player_id?: string;
  // "comment" only: the comment's first 100 characters (Q231).
  excerpt?: string;
}

interface Subscription {
  endpoint: string;
  p256dh: string;
  auth: string;
  locale: Locale;
}

// Every association is French for now: event times read in Paris time, as the app shows them.
const timeZone = "Europe/Paris";

function formatStart(iso: string, locale: Locale): string {
  const date = new Date(iso);
  const day = new Intl.DateTimeFormat(locale === "fr" ? "fr-FR" : "en-GB", {
    weekday: "short",
    day: "numeric",
    month: "short",
    timeZone,
  }).format(date);
  const time = new Intl.DateTimeFormat(locale === "fr" ? "fr-FR" : "en-GB", {
    hour: "2-digit",
    minute: "2-digit",
    timeZone,
  }).format(date);
  return locale === "fr" ? `${day} à ${time}` : `${day} at ${time}`;
}

function someone(locale: Locale): string {
  return locale === "fr" ? "Quelqu'un" : "Someone";
}

// Title, body and tag of one notification. The tag makes a newer notification replace the
// previous one of the same kind instead of piling up (Q232).
export function compose(p: Payload, locale: Locale): { title: string; body: string; tag: string } {
  const actor = p.actor ?? someone(locale);
  const when = formatStart(p.starts_at, locale);
  const fr = locale === "fr";
  switch (p.kind) {
    case "response": {
      const answer = {
        yes: fr ? `${actor} sera présent` : `${actor} will be there`,
        no: fr ? `${actor} sera absent` : `${actor} won't be there`,
        maybe: fr ? `${actor} viendra peut-être` : `${actor} might come`,
      };
      const title = p.response
        ? answer[p.response]
        : fr
        ? `${actor} a retiré sa réponse`
        : `${actor} withdrew their answer`;
      return {
        title,
        body: `${p.event_label} · ${when}`,
        tag: `response-${p.event_id}-${p.player_id}`,
      };
    }
    case "comment":
      return {
        title: fr ? `${actor} a commenté · ${p.event_label}` : `${actor} commented · ${p.event_label}`,
        body: p.excerpt ?? "",
        tag: `comments-${p.event_id}`,
      };
    case "session_started":
      return {
        title: fr ? "La session a démarré" : "The session has started",
        body: p.event_label,
        tag: `session-${p.event_id}`,
      };
    case "new_event":
      return {
        title: fr ? `Nouvel événement : ${p.event_label}` : `New event: ${p.event_label}`,
        body: p.place ? `${when} · ${p.place}` : when,
        tag: `event-${p.event_id}`,
      };
  }
}

Deno.serve(async (request) => {
  if (request.headers.get("x-push-secret") !== Deno.env.get("PUSH_FUNCTION_SECRET")) {
    return new Response("forbidden", { status: 403 });
  }

  const payload = (await request.json()) as Payload;
  if (!payload.user_ids?.length) {
    return new Response("nothing to send");
  }

  webpush.setVapidDetails(
    Deno.env.get("VAPID_SUBJECT")!,
    Deno.env.get("VAPID_PUBLIC_KEY")!,
    Deno.env.get("VAPID_PRIVATE_KEY")!,
  );

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data, error } = await supabase
    .from("push_subscriptions")
    .select("endpoint, p256dh, auth, locale")
    .in("user_id", payload.user_ids);
  if (error) {
    console.error("push_subscriptions read failed", error.message);
    return new Response("read failed", { status: 500 });
  }

  const expired: string[] = [];
  await Promise.all(
    (data as Subscription[]).map(async (subscription) => {
      const { title, body, tag } = compose(payload, subscription.locale);
      try {
        await webpush.sendNotification(
          {
            endpoint: subscription.endpoint,
            keys: { p256dh: subscription.p256dh, auth: subscription.auth },
          },
          JSON.stringify({ title, body, tag, url: `/planning/${payload.event_id}` }),
          { TTL: 60 * 60 * 24 },
        );
      } catch (e) {
        const status = (e as { statusCode?: number }).statusCode;
        // The browser dropped this subscription (app uninstalled, permission withdrawn).
        if (status === 404 || status === 410) {
          expired.push(subscription.endpoint);
        } else {
          console.error("push send failed", status, (e as Error).message);
        }
      }
    }),
  );

  if (expired.length > 0) {
    await supabase.from("push_subscriptions").delete().in("endpoint", expired);
  }
  return new Response(`sent ${data.length - expired.length}`);
});
