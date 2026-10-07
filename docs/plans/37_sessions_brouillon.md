# Plan 37 — Sessions brouillon

## Statut

Plan rédigé le 2026-10-07 à la demande du PO du même jour, revu trois fois le même jour après
ses réponses. Q253 à Q262 tranchées le 2026-10-07 (Q255 sans objet). **Plan validé par le PO le
2026-10-07**, avec Q262 (le `super_admin` peut tout modifier dans toute session) incluse dans ce
plan, sans plan à part.

## Demande du PO (reformulée)

1. On peut créer une session **en brouillon**, pour la préparer, éventuellement à plusieurs.
   Un brouillon est une session normale, mais **seuls son créateur et ses co-organisateurs la
   voient** : ni les autres membres de l'association, ni les participants qui ne sont pas
   co-organisateurs. Les « co admin » de la demande sont les co-organisateurs qui existent déjà
   (« Nommer co-organisateur », rôle `owner` de `session_members`) : aucun nouveau rôle. Le
   `super_admin` le voit aussi, comme toute session (Q254).
2. **Par défaut, une nouvelle session n'est pas un brouillon.**
3. **Un co-organisateur peut rejoindre un brouillon par son code ou son QR code** (Q254) ;
   quiconque n'en a pas été nommé co-organisateur est **refusé poliment, avec un message**
   (Q260).
4. **La partie d'un brouillon ne se lance pas** (Q261) : il reste « En préparation ».
5. **Un brouillon ne se publie qu'au moment de créer une session** (Q256) : « Créer une
   session » sur l'accueil ou « Démarrer la session » sur un événement. **Si et seulement si**
   la personne a des brouillons, l'app lui propose de créer une nouvelle session ou d'utiliser
   un de ses brouillons ; en choisir un le publie (Q259). Jamais de publication depuis la
   session elle-même. Sans brouillon, rien ne change : le formulaire s'ouvre directement.
6. **Le `super_admin` peut tout modifier dans toute session** (Q262), brouillon ou non.

## Vocabulaire

Deux notions portent aujourd'hui le mot anglais « draft » ; le plan les sépare :

- **Session « en préparation »** (existant, statut `draft` en base, « En préparation » /
  « Preparing » dans l'app) : la salle d'attente, avant « Démarrer ». Inchangée.
- **Brouillon** (nouveau, « Brouillon » / « Draft » dans l'app, Q253) : une session visible de
  ses seuls organisateurs, jusqu'à ce qu'on la choisisse à la création d'une session. En base,
  colonne `published` (« publiée »), fausse pour un brouillon : le mot `draft` est déjà pris
  par le statut, et le réemployer ferait confondre les deux à chaque lecture du code.

Dans les plans antérieurs (dont le 36), « brouillon » désigne la session en préparation ; ils ne
sont pas réécrits.

## Existant (constat, relevé dans le code le 2026-10-07)

- **Qui lit une session** : une seule règle, `can_read_session` : ses participants, tout membre
  de son association une fois démarrée, le `super_admin`. Les sept tables de la session
  (`sessions`, `teams`, `team_players`, `session_members`, `played_holes`, `scores`,
  `session_photos`) la reprennent toutes pour la lecture, temps réel compris.
- **Qui modifie une session** : une seule règle en base, `is_session_owner` (membre de la
  session avec le rôle `owner`), reprise par toutes les règles d'écriture des sept tables, du
  stockage des photos et par `start_session`, `update_session`, `set_session_tags`,
  `set_session_report`. Dans l'app, cinq écrans décident de ce qu'ils affichent selon ce rôle :
  salle d'attente (`session_room_page.dart`), salle des présents (`attendance_room_view.dart`),
  partie en cours (`session_live_page.dart`), fiche d'historique (`history_detail_page.dart`),
  formulaire (`session_create_page.dart`). Le `super_admin` n'y a aujourd'hui que la lecture,
  les natures, le compte rendu et le championnat (Q130, plan 29).
- **Lectures qui passent outre `can_read_session`** (fonctions `security definer`) :
  `join_session` (code et QR code) ; `player_history`, `holes_history`,
  `player_contributions`, `championship_association_results` (statistiques, records, badges,
  championnat), qui ne lisent que des sessions **terminées** ; `event_session` ; les
  destinataires des notifications (seule la session d'un événement qui démarre en envoie).
- **Création** : RPC `create_session`, appelée par le formulaire, ouvert par deux boutons :
  « Créer une session » (`home_page.dart`) et « Démarrer la session » (`event_detail_page.dart`,
  `/session/new?event=…`). Depuis un événement, la session y est liée (`sessions.event_id`, une
  seule session par événement, Q223) et ses « présents » sont ajoutés à la salle d'attente.
- **Co-organisateur** : un participant promu par un organisateur, y compris un participant
  ajouté depuis la liste des joueurs et pas encore venu ; il a tous les droits du créateur.
- **Sauvegarde** : `tool/export_remote_seed.dart` exporte `sessions` avec une liste de colonnes
  fixe ; l'archive du plan 36 copie toutes les colonnes et n'a rien à changer.

## Ce qui change pour l'utilisateur

**Créer un brouillon.** Le formulaire de création gagne un interrupteur « Brouillon », éteint
par défaut, avec une ligne d'explication : visible seulement des organisateurs, à choisir plus
tard dans « Créer une session » pour la jouer. Il n'apparaît pas quand la session est démarrée
depuis un événement (Q257), ni en modification.

**Préparer un brouillon, à plusieurs** :
- ses organisateurs le voient sur l'accueil (« Mes sessions en cours ») et dans sa salle
  d'attente, marqué d'une pastille « Brouillon » ; personne d'autre ne le voit, hormis le
  `super_admin` ;
- sa salle d'attente est celle d'aujourd'hui (participants, équipes, co-organisateurs, code et
  QR code ; nom, lieu et natures par « Modifier »), **sans le bouton « Démarrer »**, remplacé
  par une ligne : « Brouillon : visible seulement des organisateurs. Pour le jouer,
  choisissez-le dans « Créer une session » ou « Démarrer la session » d'un événement. » ;
- pour préparer à plusieurs : un organisateur ajoute quelqu'un depuis la liste des joueurs et
  le nomme co-organisateur ; celui-ci voit le brouillon sur son accueil, sans code, ou le
  rejoint par le code ;
- quiconque tape le code d'un brouillon sans en être co-organisateur est refusé : « Cette
  session est un brouillon : seuls ses organisateurs peuvent la rejoindre pour l'instant. »
  Il n'est pas inscrit ;
- les participants ajoutés qui ne sont pas co-organisateurs ne le voient qu'une fois publié.

**Créer une session quand on a des brouillons** (Q258, Q259). « Créer une session » et
« Démarrer la session » ouvrent d'abord un panneau :
- « Nouvelle session » : le formulaire, comme aujourd'hui ;
- la liste de mes brouillons (nom ou lieu, date de création), avec une ligne qui dit qu'utiliser
  un brouillon le rend visible des membres.

Toucher un brouillon le publie et ouvre sa salle d'attente, désormais celle d'une session
ordinaire (« Démarrer » compris). Depuis un événement, il est en plus lié à l'événement et ses
présents sont ajoutés à la salle d'attente, exactement comme pour une nouvelle session ; le
brouillon garde son nom, son lieu, sa carte de score, ses participants et ses équipes.

Brouillons proposés : ceux dont je suis organisateur (créateur ou co-organisateur) ; depuis un
événement, seulement ceux de l'association de l'événement. Si aucun n'est proposable, le
panneau n'apparaît pas. Le `super_admin` ne se voit proposer que ses propres brouillons, pas
tous ceux de l'app.

La publication n'envoie aucune notification. Les présents d'un événement sont prévenus au
démarrage, comme aujourd'hui.

**Le `super_admin`** (Q262) : sur toute session, il a les boutons et les droits d'un
organisateur (modifier, gérer participants, équipes, trous, scores et photos, démarrer,
terminer, supprimer), sans en devenir participant. Pour les autres comptes, rien ne change.

## Décisions techniques

1. **Colonne `sessions.published boolean not null default true`.** Toutes les sessions
   existantes sont publiées (valeur par défaut) : la migration ne transforme ni ne supprime
   aucune donnée, pas de sauvegarde préalable obligatoire (règle 8), mais le PO est prévenu
   avant le `db push`.
2. **Deux contraintes en base**, qui valent pour tout chemin d'écriture :
   - `sessions_draft_not_started check (published or status = 'draft')` : un brouillon reste en
     préparation (Q261) ; `start_session` et la fin de session échouent sur un brouillon ;
   - `sessions_draft_without_event check (published or event_id is null)` : un brouillon n'a
     jamais d'événement (Q257).

   Conséquence : un brouillon n'est jamais terminé, donc n'apparaît dans aucune des lectures
   qui ne lisent que des sessions terminées (statistiques, records, badges, championnat), et
   n'a jamais d'événement, donc n'apparaît ni dans `event_session` ni dans les notifications.
   Ces fonctions ne changent pas, et aucune lecture future n'a à filtrer les brouillons (Q255).
3. **Sens unique** (Q256) : un déclencheur `sessions_guard_published` refuse de repasser une
   session publiée en brouillon (`cannot_unpublish`) quand un utilisateur est connecté ;
   l'administrateur de la base (éditeur SQL, restauration du plan 36) garde les mains libres,
   comme pour les autres déclencheurs de `sessions`.
4. **`is_session_owner` répond oui pour le `super_admin`** (Q262). Toutes les règles
   d'écriture qui la reprennent suivent, sans être réécrites une à une. Les lectures et
   décisions qui doivent connaître le vrai rôle dans la session (rejoindre un brouillon, liste
   des brouillons proposés) lisent `session_members.role` directement.
5. **`can_read_session` réécrite** : pour un brouillon, `is_session_owner` (créateur,
   co-organisateur, et donc `super_admin`) ; pour une session publiée, la règle d'aujourd'hui.
   Les sept tables suivent sans toucher à leurs règles.
6. **`create_session`** accepte `"draft": true` dans sa charge (`published = false`) ; avec un
   `event_id`, la contrainte du point 2 refuse. L'ajout des présents d'un événement passe dans
   une fonction interne `_add_event_attendees(session, événement)`, partagée avec le point 8.
7. **`join_session`** : pour un brouillon, seul un membre de rôle `owner` passe (il est marqué
   venu, comme aujourd'hui) ; tout autre appelant, `super_admin` compris (il n'a pas besoin de
   rejoindre pour voir ou modifier), reçoit `draft_session`, que l'app traduit par le message
   du refus poli (Q260). Session publiée : comportement inchangé.
8. **RPC `publish_session(p_session_id uuid, p_event_id uuid default null)`**,
   `security definer`, seule voie de publication, appelée par le panneau de création :
   - réservée aux organisateurs de la session (`not_owner`), pour un brouillon seulement
     (`already_published`) ;
   - sans événement : `published = true` ;
   - avec un événement : `published = true` et `event_id` posés ensemble ; le déclencheur
     existant `sessions_guard_event` vérifie le reste (même association, événement de ±24 h,
     droit de démarrer, une seule session par événement) ; puis `_add_event_attendees`.

   Une publication par écriture directe de la colonne reste techniquement possible pour un
   organisateur (règle `sessions_update_owner`) : sans conséquence (mêmes droits que la RPC sans
   événement), et l'app ne la propose nulle part.
9. **Côté app** :
   - `Session.published` (vrai par défaut) ;
   - `SessionsRepository` : création avec `draft`, `myDrafts()` (brouillons dont je suis membre
     de rôle `owner`), `publishSession(id, eventId)` ;
   - une fonction pure `offerableDrafts(drafts, {eventAssociationId})` décide des brouillons
     proposés (testée) ; un seul point d'entrée `startNewSession(context, ref, {eventId})`
     appelé par les deux boutons, qui ouvre le panneau ou directement le formulaire ;
   - pastille « Brouillon » (`NuniStatusPill`) sur les cartes de l'accueil et dans les salles
     d'attente ; « Démarrer » remplacé par la ligne d'explication dans les deux salles d'attente ;
   - refus `draft_session` traduit dans `describeError` ;
   - `super_admin` (Q262) : les cinq écrans de session calculent « je peux organiser » comme
     « rôle `owner` ou `super_admin` », en un seul endroit par écran ;
   - chaînes EN et FR dans les ARB.
10. **Sauvegarde** : `published` ajoutée à la liste des colonnes exportées de `sessions`
    (`tool/export_remote_seed.dart`) ; sans elle, une relecture de la sauvegarde publierait tous
    les brouillons.
11. **Une seule migration**, additive : colonne, contraintes, déclencheur, fonctions réécrites
    (`is_session_owner`, `can_read_session`, `create_session`, `join_session`),
    `_add_event_attendees`, `publish_session`. Les fichiers déjà appliqués ne sont pas modifiés
    (règle 8).

## Étapes

1. Migration `<horodatage>_session_drafts.sql` (`npx supabase migration new session_drafts`).
2. `Session` (champ `published`, `build_runner`), `SessionsRepository`.
3. Formulaire : interrupteur « Brouillon » à la création, hors événement.
4. `startNewSession` et son panneau ; branchement sur l'accueil et la page d'événement.
5. Pastilles et salles d'attente d'un brouillon (pas de « Démarrer », ligne d'explication) ;
   message du refus `draft_session`.
6. `super_admin` : droits d'organisateur dans les cinq écrans de session.
7. Chaînes EN et FR.
8. `tool/export_remote_seed.dart` : colonne `published`.
9. Tests Dart (`offerableDrafts`, lecture de `published`) ; section « plan 37 » de
   `supabase/tests/rls_smoke.sql`.
10. `fvm dart format`, `fvm flutter analyze --fatal-infos`, `fvm flutter test`.
11. Annonce au PO de ce que change la migration, puis, sur son accord : `npx supabase db push`
    et `rls_smoke.sql`.
12. Essai dans le navigateur intégré (localhost:3000) ; puis essai du PO.
13. `AGENTS.md` (conventions : brouillons, droits du `super_admin`), ce plan,
    `QUESTIONS_PO.md`, plan d'ensemble.

## Tests (`rls_smoke.sql`, section plan 37)

- Brouillon créé par A, C ajouté comme participant : A et un `super_admin` le lisent avec ses
  tables ; C, un autre membre de l'association et un membre du staff n'en lisent aucune ligne.
- B ajouté par A puis nommé co-organisateur, sans être venu : B lit le brouillon ; B rejoint
  ensuite par le code : marqué venu, toujours co-organisateur.
- `join_session` avec le code du brouillon : refusé (`draft_session`) pour C, pour un autre
  membre et pour le `super_admin` ; aucune ligne ajoutée.
- `start_session` sur un brouillon : refusé ; passage direct du statut à « en cours » ou
  « terminé » : refusé.
- `create_session` avec `draft` et `event_id` : refusé. Repasser une session publiée en
  brouillon : refusé.
- `publish_session` : refusé à C ; accepté pour B sans événement ; avec un événement du jour :
  session liée, présents ajoutés ; refusé si l'événement a déjà une session ou si l'appelant
  n'a pas le droit de démarrer l'événement ; une deuxième publication est refusée.
- Après publication : rejoindre par le code fait un participant, comme aujourd'hui ; la
  session démarre et se termine normalement.
- `super_admin` sur une session publiée dont il n'est pas membre : modifie le nom, ajoute un
  participant, démarre, saisit un score, ajoute une photo, termine, supprime.
- Sessions ordinaires : les tests existants restent verts.

## Critères d'acceptation

- [ ] Une nouvelle session n'est pas un brouillon sauf interrupteur allumé ; l'interrupteur
      n'existe pas depuis un événement.
- [ ] Un brouillon n'est visible que de son créateur, de ses co-organisateurs et du
      `super_admin`.
- [ ] Un co-organisateur rejoint un brouillon par code ou QR code ; tout autre compte est
      refusé avec un message, sans être inscrit.
- [ ] La partie d'un brouillon ne se lance pas ; sa salle d'attente dit comment le jouer.
- [ ] Aucune publication possible depuis la session.
- [ ] Avec des brouillons proposables, « Créer une session » et « Démarrer la session » proposent
      « Nouvelle session » ou un brouillon ; sans, le formulaire s'ouvre directement.
- [ ] Choisir un brouillon le publie ; depuis un événement, il est en plus lié à l'événement et
      les présents sont ajoutés.
- [ ] Le `super_admin` a les droits et les boutons d'un organisateur sur toute session.
- [ ] `flutter analyze` sans avertissement, tests verts, `rls_smoke.sql` entièrement vert, build
      Vercel vert, chaînes EN et FR.
- [ ] `AGENTS.md`, ce plan, `QUESTIONS_PO.md` et le plan d'ensemble à jour.
- [ ] Essai par le PO.

## Hors périmètre

- Publier depuis la session, remettre en brouillon une session publiée (Q256).
- Jouer une partie de test en privé : un brouillon ne se lance pas (Q261).
- Modèles de session réutilisables plusieurs fois : un brouillon utilisé devient la session,
  il ne se copie pas.
- Nouveau rôle de session : les co-organisateurs existants suffisent.
- Notification à la publication d'un brouillon.
