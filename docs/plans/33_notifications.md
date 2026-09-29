# Plan 33 — Notifications du planning

## Statut

Plan rédigé le 2026-09-29 à la demande du PO du même jour. Toutes les questions (Q224 à Q237)
sont tranchées le même jour. **Plan validé par le PO le 2026-09-29**, implémentation demandée
le même jour.

**Implémenté le 2026-09-29**, poussé sur `main` à la demande du PO le même jour. `flutter analyze` et tests verts (règles de
permission testées). Clés mises en place par le PO le 2026-09-29 (étapes 1 à 5 de `docs/DEV.md`), migration
poussée par le PO, `notifications_smoke.sql` et `rls_smoke.sql` joués par le PO : tous les
tests passent. **Non vérifié** : aucune notification réelle n'a pu être envoyée ni reçue. Vérifié dans le navigateur
intégré, sur une compilation de production servie en local : l'app démarre, `nuni_sw.js` est
installé, actif et contrôle tout le site, sans erreur dans la console. Le réglage lui-même n'a
pas pu être affiché : il faut être connecté, et la session de l'assistant n'a pas les clés
Supabase.

**Essayé et validé par le PO sur Android le 2026-09-29** (notifications reçues ; badge « N » de
la barre d'état corrigé dans la foulée). **Clôturé par le PO le 2026-09-29** sans essai sur iPhone :
sur iPhone, les notifications d'une PWA dépendent d'Apple et restent au mieux, sans levier
supplémentaire côté NUNI ; elles seront observées en usage réel la semaine suivante, et les
défauts éventuels traités au fil de l'eau.

## Demande du PO (reformulée)

Premier lot de notifications, en sachant qu'une PWA ne les garantit pas :

1. Le **responsable de l'événement** est prévenu quand un joueur **change** sa réponse (présent,
   absent, peut-être), y compris quand il répond pour la première fois.
2. Le **responsable de l'événement** est prévenu d'un nouveau commentaire sur l'événement.
3. Tout joueur ayant répondu **présent** ou **peut-être** est prévenu d'un nouveau commentaire.
4. Tout joueur ayant répondu **présent** est prévenu quand la session de l'événement démarre.
5. **Tous les membres de l'association** sont prévenus quand un membre publie **un** événement ;
   **jamais** lors d'un import (plusieurs événements d'un coup).
6. L'app gère la **permission** des notifications : une seule permission globale pour l'instant
   (pas de réglage par type).

## Existant (constat)

- Aucune notification aujourd'hui, aucune fonction serveur (Supabase Edge Function) dans le
  projet.
- **Service worker** (petit script que le navigateur garde en arrière-plan pour un site, seul
  capable de recevoir une notification app fermée) : celui que Flutter publie
  (`flutter_service_worker.js`) **se désinstalle lui-même** à chaque chargement (vérifié le
  2026-09-29 sur nuni.centuryspine.org : il appelle `registration.unregister()`). Il n'y a donc
  aucun service worker actif, et NUNI doit fournir le sien.
- Événements : `events.manager_player_id` (responsable, facultatif), `events.origin`
  (`manual` pour tout événement saisi dans l'app, clone compris ; `imported` seulement par la RPC
  `import_events`). Réponses : `event_responses` (insertion, modification, et suppression quand
  le joueur retire sa réponse, `events_repository.dart`). Commentaires : `event_comments`.
- Démarrage de session : la RPC `start_session` passe `sessions.status` de `draft` à `live` ;
  la session d'un événement porte `sessions.event_id` (une seule par événement, Q223).
- Réglages : `settings_page.dart` (langue, couleurs, association, version).

## Ce qui change pour l'utilisateur

1. **Activées par défaut** (Q225) : aucun navigateur n'accorde la permission sans un toucher de
   l'utilisateur. Pas d'écran d'explication propre à NUNI (Q235) : la fenêtre du téléphone
   (« Autoriser / Ne pas autoriser ») s'affiche au **premier toucher dans l'app** après la
   connexion, une fois par appareil, tant qu'elle n'a pas reçu de réponse (Q235). Sur
   iPhone/iPad sans l'app installée, rien ne s'affiche (iOS 16.4 et plus n'autorise les
   notifications qu'à une PWA installée) ; la page Réglages l'explique.
2. **Réglages → « Notifications »** : un interrupteur, **allumé par défaut**, propre à
   l'appareil (« Sur cet appareil uniquement »). Sous l'interrupteur, une phrase selon le cas :
   - navigateur incompatible, ou iPhone/iPad sans l'app installée : invitation à installer ;
     interrupteur grisé ;
   - fenêtre du téléphone fermée sans réponse : elle réapparaît au prochain toucher de
     l'interrupteur ;
   - permission refusée dans le navigateur : explique qu'il faut la rétablir dans les réglages du
     navigateur ou du téléphone (l'app ne peut plus la redemander) ; interrupteur grisé ;
   - l'éteindre désabonne l'appareil ; le rallumer le réabonne sans nouvelle demande.
3. **Notifications reçues** (textes : Q231 ; langue choisie dans l'app, pas celle du système :
   Q230) :
   - réponse : « Paul sera présent — Sortie du 12 oct. » (absent, peut-être, « a retiré sa
     réponse », Q226) ;
   - commentaire : « Paul a commenté — Sortie du 12 oct. » + début du commentaire (100
     caractères) ;
   - session démarrée : « La session a démarré — Sortie du 12 oct. » ;
   - nouvel événement : « Nouvel événement : Sortie du 12 oct. » + date, heure et lieu.
   Toucher la notification ouvre la page de l'événement (`/planning/:id`), app installée ou
   non (Q233).
4. On n'est **jamais** prévenu de sa propre action (sa réponse, son commentaire, son événement,
   la session qu'on a démarrée). Un destinataire concerné à deux titres (responsable et présent)
   ne reçoit qu'une notification.
5. Les changements de réponse répétés d'un même joueur sur un même événement **remplacent** la
   notification précédente au lieu de s'empiler (Q232) ; de même pour les commentaires d'un
   même événement.
6. **Confidentialité** : ajout des services de notification des navigateurs (Q234).

### Règles de destinataires (écrites une seule fois, en base)

| Déclencheur | Destinataires | Exclus |
|---|---|---|
| Réponse créée, changée ou retirée (`event_responses`) | Responsable de l'événement ; personne s'il n'y en a pas (Q227) | L'auteur de la réponse |
| Commentaire créé (`event_comments`, pas les modifications ni suppressions, Q228) | Responsable + joueurs « présent » ou « peut-être » | L'auteur |
| Session de l'événement passée de `draft` à `live` | Joueurs « présent » | Celui qui démarre |
| Événement enregistré pour la première fois (`insert`) avec `origin = 'manual'` et commençant dans le futur (Q229, Q236) | Membres de l'association de l'événement | Le créateur |

Tous les destinataires doivent encore être membres de l'association de l'événement (on ne
prévient pas quelqu'un qui l'a quittée et ne peut plus lire l'événement). L'import passe par
`origin = 'imported'` : la règle 5 l'exclut par construction, quel que soit le nombre
d'événements importés. Seul l'enregistrement notifie (Q229) : un clone n'est qu'un formulaire
prérempli, son enregistrement est une création comme une autre, sans cas particulier ; ses
modifications ultérieures ne notifient pas.

## Décisions techniques

- **Web Push standard** (Q224) : protocole ouvert des navigateurs, clés VAPID (une paire de
  clés qui identifie l'expéditeur auprès des services de Google, Apple et Mozilla ; la clé
  publique va dans l'app, la privée ne quitte pas Supabase). Pas de Firebase ni de OneSignal :
  aucun compte ni SDK supplémentaire. Fonctionne sur Android (Chrome, Firefox, Edge),
  ordinateur, et iPhone/iPad 16.4+ **app installée seulement**. Non garanti : le navigateur ou
  le système peut retarder ou couper les notifications (économie d'énergie, permission retirée,
  PWA désinstallée) ; aucune relance ni accusé de réception.
- **Service worker NUNI** : `web/nuni_sw.js`, écrit à la main (JavaScript, seul langage possible
  pour un service worker) : affiche la notification reçue (`push`) et ouvre ou ramène l'app sur
  l'adresse de l'événement au toucher (`notificationclick`). Aucun cache, aucune autre fonction.
  Pour que Flutter ne l'écrase pas, `web/flutter_bootstrap.js` personnalisé charge Flutter sans
  son service worker (modèle officiel `{{flutter_js}}` / `{{flutter_build_config}}` puis
  `_flutter.loader.load()` sans `serviceWorkerSettings`). `vercel.json` : `nuni_sw.js` en
  `no-cache`. Effet pour l'utilisateur : aucun (le service worker Flutter ne faisait déjà rien).
- **Abonnement** : table `push_subscriptions` (utilisateur, adresse d'envoi `endpoint` unique,
  clés `p256dh` et `auth`, langue, date). Une ligne par appareil. Lisible et modifiable par son
  seul propriétaire (RLS). Le choix de l'interrupteur est gardé sur l'appareil
  (`shared_preferences`, allumé par défaut, Q225), comme la palette. Allumé et permission accordée = abonnement du navigateur + ligne ; éteint =
  désabonnement + suppression. À chaque ouverture de l'app, l'abonnement existant est
  réenregistré (le navigateur peut le renouveler) et sa langue mise à jour ; un changement de
  langue dans l'app met aussi la ligne à jour. À la déconnexion, la ligne de l'appareil est
  supprimée (sinon le compte suivant sur ce téléphone recevrait les notifications du précédent).
- **Code Dart** : `lib/features/notifications/` : `data/web_push.dart` (appel au navigateur
  par `package:web` et `dart:js_interop`, déjà utilisés : état de la permission, demande,
  abonnement, désabonnement ; version vide pour les tests), `data/push_subscriptions_repository.dart`,
  `data/notifications_controller.dart` (choix de l’appareil, abonnement),
  `domain/notifications_status.dart` (Dart pur, testé : incompatible / à installer /
  permission à demander / refusée / éteinte / active), `ui/notifications_tile.dart` (dans les
  réglages), `ui/notifications_gate.dart` (monté une fois dans `app.dart` : fenêtre du téléphone au
  premier toucher, Q235 ; abonnement tenu à jour à la connexion, au changement de langue et au
  retour au premier plan ; notification touchée app ouverte). Clé publique
  VAPID lue dans `env/*.json` (`VAPID_PUBLIC_KEY`), comme les clés Supabase ;
  `tool/vercel_build.sh` l'ajoute à `env/prod.json`.
- **Envoi** : une nouvelle migration (règle 8, additive) :
  - active l'extension `pg_net` (appels HTTP depuis la base, livrée avec Supabase) ;
  - `_notify(p_user_ids uuid[], p_payload jsonb)` : envoie à la fonction serveur, par un appel
    HTTP asynchrone qui ne part qu'une fois l'écriture validée (une réponse annulée ne notifie
    personne) et qui ne bloque ni ne fait échouer l'action du joueur si l'envoi échoue ;
  - quatre déclencheurs (`after insert/update/delete` sur `event_responses`, `after insert`
    sur `event_comments` et `events`, `after update of status` sur `sessions`) qui appliquent
    le tableau ci-dessus ; les destinataires sont calculés par une fonction SQL par règle,
    testée.
  - L'adresse de la fonction serveur et son secret d'appel sont dans le coffre de Supabase
    (Vault), jamais dans le dépôt.
- **Fonction serveur** `supabase/functions/send-push/` (TypeScript/Deno, la seule forme de
  fonction serveur de Supabase) : vérifie le secret d'appel, lit les abonnements des
  destinataires, compose le texte dans la langue de chaque appareil, chiffre et envoie
  (bibliothèque `web-push`), supprime les abonnements que le service déclare expirés (réponse
  404 ou 410). Les textes des notifications vivent dans cette fonction (EN et FR), pas dans les
  ARB : ils sont écrits côté serveur, l'app n'est pas ouverte. Exception à documenter dans
  `AGENTS.md`.
- Déploiement : `npx supabase functions deploy send-push`, nouvelle commande dans `docs/DEV.md`.

### Fichiers

- `web/nuni_sw.js`, `web/flutter_bootstrap.js`, `vercel.json`, `tool/vercel_build.sh`,
  `env/example.json`.
- `supabase/migrations/20260929120000_push_notifications.sql`, `supabase/tests/notifications_smoke.sql`
  (destinataires de chaque règle, exclusions, abonnements), `supabase/config.toml`
  (`send-push` sans jeton de connexion : appelée par la base avec son propre secret).
- `supabase/functions/send-push/index.ts`.
- `lib/features/notifications/…`, `lib/features/settings/ui/settings_page.dart`,
  `lib/app.dart`, `lib/main.dart`, déconnexion dans les réglages, icône `bell`.
- ARB EN et FR (réglages, confidentialité), `docs/DEV.md`, `AGENTS.md`.

## Prérequis du PO (au moment de l'implémentation)

Procédure complète et commandes exactes : `docs/DEV.md`, section « Notifications ».


1. Générer la paire de clés VAPID sur son poste : `npx web-push generate-vapid-keys` ; mettre
   la publique dans `env/dev.json`, `env/prod.json` et dans les variables d'environnement Vercel
   (`VAPID_PUBLIC_KEY`) ; la privée dans Supabase : `npx supabase secrets set
   VAPID_PRIVATE_KEY=… VAPID_PUBLIC_KEY=… VAPID_SUBJECT=mailto:…`. But : identifier NUNI
   auprès des services de notification ; sans elles, aucun envoi possible.
2. Valider la migration avant son `db push` (règle 8) : elle ajoute une table, une extension,
   des déclencheurs, et ne modifie ni ne supprime aucune donnée.
3. Enregistrer dans le coffre Supabase l'adresse de la fonction et le secret d'appel (deux
   lignes SQL fournies, à coller dans l'éditeur SQL du tableau de bord). But : que la base
   puisse appeler la fonction sans que le secret soit dans le dépôt public.

## Hors périmètre

- Réglage par type de notification, heures de silence (Q225 : une permission globale).
- Notifications sur modification ou suppression d'un événement, rappel avant l'événement,
  notifications des sessions (scores, fin de session), badges.
- Historique des notifications dans l'app, pastille de compteur sur l'icône.
- Garantie de réception : impossible en PWA.

## Critères d'acceptation

- [x] Après la connexion sur un appareil, le premier toucher dans l'app affiche la fenêtre du
      téléphone ; « Autoriser » abonne l'appareil sans autre geste.
- [x] Réglages : l'interrupteur, allumé par défaut, abonne ou désabonne l'appareil, et affiche le bon
      message pour navigateur incompatible, iPhone sans installation, permission refusée.
- [x] Éteindre l'interrupteur ou se déconnecter : l'appareil ne reçoit plus rien.
- [x] Les quatre règles notifient les bons destinataires, jamais l'auteur, une seule fois
      chacun (test SQL).
- [x] Import d'un agenda (un ou plusieurs événements) : aucune notification.
- [x] Toucher une notification ouvre la page de l'événement.
- [x] Un envoi en échec n'empêche ni la réponse, ni le commentaire, ni le démarrage.
- [x] Essai réel par le PO sur Android.
- [x] Essai réel par le PO sur iPhone (app installée) : levé par le PO le 2026-09-29, observé
      en usage réel après la clôture (notifications d'une PWA au mieux sur iPhone).
- [x] Confidentialité à jour, chaînes EN et FR, `flutter analyze` et tests verts.
