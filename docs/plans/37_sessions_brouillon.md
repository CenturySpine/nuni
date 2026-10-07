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

**Implémenté le 2026-10-07** (étapes 1 à 10 et 13) : migration
`20261007081311_session_drafts.sql`, app, tests Dart (532 réussis, analyse sans avertissement),
section « plan 37 » de `rls_smoke.sql`, `AGENTS.md`, export.

**Étape 11 faite le 2026-10-07, sur accord du PO**, par l'assistant :
- répétition sur la base de production (migration et `rls_smoke.sql` dans une transaction
  annulée par une erreur volontaire qui porte le verdict) : un premier essai s'est arrêté sur
  une erreur des nouveaux tests (ils utilisaient le spot de test que la section du plan 28
  supprime, comme au plan 36), tout annulé, vérifié en base ; corrigé (spot propre au plan 37),
  puis 179 tests sur 179 réussis, aucun reste ;
- `npx supabase db push` : seule cette migration était en attente, appliquée ;
- `rls_smoke.sql` : 179 sur 179, aucun reste ; relu en base : les 12 sessions existantes sont
  publiées, `publish_session` exécutable par `authenticated` seulement (pas `anon`),
  `_add_event_attendees` et `sessions_guard_published` par aucun compte de l'app.

**Étape 12 (essai dans le navigateur intégré) faite le 2026-10-07**, avec le compte du PO, sur
son accord, en largeur de téléphone : formulaire ouvert directement sans brouillon ; brouillon
« Test brouillon (Claude) » créé (interrupteur éteint par défaut) ; salle d'attente avec
pastille, phrase d'explication, code et « Inviter », sans « Démarrer » ; pastille « Brouillon »
sur l'accueil ; « Créer une session » ouvre le panneau avec ce brouillon ; le choisir l'a publié
(vérifié en base : publié, en salle d'attente, sans événement) et a ouvert sa salle d'attente
avec « Démarrer » ; supprimé depuis l'app (vérifié en base : disparu, pas d'archive, aucun
brouillon restant). Défaut trouvé et corrigé : une double touche sur « Créer une session »
ouvrait deux fois le formulaire (ou le panneau), la recherche des brouillons laissant un
moment sans réaction ; un verrou ignore désormais toute touche tant que la recherche ou le
panneau sont en cours (`startNewSession`), vérifié dans le navigateur. Non essayé dans
l'app : le choix depuis un événement (pour ne toucher à aucun événement réel ; couvert par
`rls_smoke.sql`) et les droits du `super_admin` sur la session d'un autre.

**Reste** : essai du PO ; code ni commité ni poussé.

**Avenant du 2026-10-07 (demande PO, après l'essai) : préparer et ordonner les trous.**
Q263 à Q269 tranchées ; **avenant validé par le PO le 2026-10-07** ; section « Avenant » ci-dessous.
Implémenté le même jour : migration `20261007130438_played_holes_order.sql`, app (salle
d'attente, partie en cours), tests Dart (540 réussis, analyse sans avertissement), section
« avenant » de `rls_smoke.sql`, export, `AGENTS.md`.
Sur accord du PO le même jour : répétition annulée sur la production (190 tests sur 190, aucun
reste), migration appliquée (seule en attente), `rls_smoke.sql` 190 sur 190, aucun reste ;
aucune session existante en « trou 1 en haut ». Essai dans le navigateur intégré, avec le compte
du PO, sur une session de test « Test trous (Claude) » : brouillon créé ; section « Trous »
avec son invitation ; trois trous libres ajoutés depuis la salle d'attente ; bouton d'ordre et
poignées dès deux trous ; inversion (« Trou 1 en haut », gardée après rechargement) ;
glisser-déposer du trou 3 en tête, renuméroté 1, les autres décalés (vérifié en base) ; brouillon
choisi depuis « Créer une session » (recherche des brouillons mesurée à 0,3 s), trous et ordre
conservés ; partie démarrée, trou 1 mis en avant puis trou 2 après sa saisie ; fin de partie :
la confirmation annonce le retrait, les deux trous sans score retirés, le restant renuméroté
(vérifié en base) ; session supprimée depuis sa fiche (archivée, plan 36). Limite : le
glisser-déposer n'a été reconnu qu'avec un geste de souris réaliste en taille bureau ; en
émulation tactile, les gestes simulés ne le déclenchent pas : essai sur téléphone à faire par le
PO. Code ni commité ni poussé.

**Demandes du PO du 2026-10-07, après son essai** : passer une session en brouillon après sa
création (Q270) et retirer le rôle de co-organisateur (Q271), tranchées le même jour.
Implémentées : migration `20261007134654_draft_later_and_co_organizers.sql` (verrou du
brouillon assoupli pour une salle d'attente sans événement ; rôle du créateur protégé),
interrupteur « Brouillon » dans « Modifier » avec confirmation, couronne qui bascule
(`CoOrganizerCrown`) dans les deux listes de la salle d'attente et le panneau « Participants »
de la partie, tests Dart (543) et `rls_smoke.sql`. Sur accord du PO : répétition annulée
(196 sur 196, aucun reste), migration appliquée, `rls_smoke.sql` 196 sur 196. Essai dans le
navigateur intégré sur la session de test du PO VQ35QT, avec son accord : rôle de Christophe
(pas encore venu) retiré puis redonné par la couronne, vérifié en base à chaque fois ;
couronnes vides sur Fabien et Ryan, figée sur le PO lui-même ; « Modifier » montre
l'interrupteur « Brouillon » ; passage en brouillon avec la confirmation prévue ; salle
d'attente en brouillon, sans « Démarrer » ; en base : brouillon, en préparation, 4
participants et 2 trous gardés. VQ35QT reste en brouillon (elle s'intitule « [Test] session en
mode "brouillon" ») ; la choisir dans « Créer une session » la republie.

**Essai du PO validé le 2026-10-07** (« tests ok ») ; commit et push sur sa demande le même
jour. « Training test », supprimée à 12:46 UTC avec le compte du PO pendant les essais : c'est
le PO qui l'a supprimée (archivée, plan 36). L'archive de la session de test « Test trous
(Claude) » est gardée.

## Notes d'implémentation (2026-10-07)

Choix techniques faits en implémentant, dans le cadre des décisions ci-dessous :

- **La migration est compatible avec l'app en ligne** : toutes les sessions existantes restent
  publiées, l'app actuelle n'envoie jamais `draft`, et les règles d'une session publiée sont
  inchangées (seul le `super_admin` gagne des droits en base, que l'app actuelle ne lui montre
  pas). Elle peut donc être appliquée avant la mise en ligne de l'app.
- **Refus « brouillon avec événement »** : `create_session` le refuse elle-même
  (`draft_with_event`) avant toute écriture ; l'app ne peut pas l'envoyer (l'interrupteur
  n'existe pas depuis un événement), d'où aucun message dédié.
- **Lancer un brouillon** : refusé par la seule contrainte `sessions_draft_not_started`, sans
  réécrire `start_session` ; l'app n'affiche pas « Démarrer » (ni « Terminer » dans la salle des
  présents) sur un brouillon.
- **Recherche des brouillons à la création** : deux requêtes avant l'ouverture du panneau ou du
  formulaire ; en cas d'échec, le formulaire s'ouvre comme avant.
- **`super_admin` hors de la session** : l'interrupteur « Moi parmi les présents » n'apparaît
  qu'à un membre de la session ; sur la partie en cours, il n'est plus « spectateur » (il peut
  saisir et inviter).
- **`LiveSessionSnapshot.isOwner`** supprimée : plus aucun écran ne décide par le seul rôle.

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

- [x] Une nouvelle session n'est pas un brouillon sauf interrupteur allumé ; l'interrupteur
      n'existe pas depuis un événement.
- [x] Un brouillon n'est visible que de son créateur, de ses co-organisateurs et du
      `super_admin`.
- [x] Un co-organisateur rejoint un brouillon par code ou QR code ; tout autre compte est
      refusé avec un message, sans être inscrit.
- [x] La partie d'un brouillon ne se lance pas ; sa salle d'attente dit comment le jouer.
- [x] Aucune publication possible depuis la session.
- [x] Avec des brouillons proposables, « Créer une session » et « Démarrer la session » proposent
      « Nouvelle session » ou un brouillon ; sans, le formulaire s'ouvre directement.
- [x] Choisir un brouillon le publie ; depuis un événement, il est en plus lié à l'événement et
      les présents sont ajoutés.
- [x] Le `super_admin` a les droits et les boutons d'un organisateur sur toute session.
- [ ] `flutter analyze` sans avertissement, tests verts, `rls_smoke.sql` entièrement vert, build
      Vercel vert, chaînes EN et FR. (Tout vert sauf le build Vercel, vérifié après le push.)
- [x] `AGENTS.md`, ce plan, `QUESTIONS_PO.md` et le plan d'ensemble à jour.
- [x] Essai par le PO.

## Avenant (2026-10-07) : préparer les trous avant la partie

### Demande du PO

« Il faut qu'on puisse ajouter/préparer des trous dans une session brouillon. »

### Existant (relevé dans le code le 2026-10-07)

- **Base** : les organisateurs peuvent déjà écrire les trous joués d'une session à tout stade
  (règle `played_holes_owner_write`, sans condition de statut ; `add_played_hole` non plus).
  Rien à changer en base pour ajouter, modifier ou retirer un trou avant le démarrage.
- **App** : les trous ne s'ajoutent que sur l'écran de la partie en cours, par le panneau
  « Ajouter un trou » (`add_played_hole_sheet.dart` : trou proche, de l'annuaire, créé sur
  place, ou trou libre ; par, commentaire, mode de jeu). Ils se modifient (par, commentaire) et
  se retirent au même endroit. Pas de réordonnancement : l'ordre est celui de l'ajout.
- **Identité et ordre sont séparés** (vérifié le 2026-10-07 à la demande du PO) : un trou joué
  est identifié par `played_holes.id` (identifiant unique), auquel les scores sont rattachés
  (`scores.played_hole_id`) ; le trou physique de l'annuaire est `hole_id` ; sa place dans le
  parcours est `position`, une colonne métier à part, unique par session. Seul le numéro
  affiché (« Trou 3 », cartes, export PDF) est tiré de `position`, au moment de l'affichage ; il
  n'est stocké nulle part. Les statistiques lisent aussi `position` comme ordre de jeu dans la
  session (passages successifs d'un même trou, `holePassages`). Déplacer un trou change donc sa
  place et son numéro affiché, jamais son identité ni ses scores.
- **Présentation pendant la partie** : la liste montre le trou le plus récent en haut, mis en
  avant (`playedHolesRecentFirst`), parce que chaque trou est ajouté au moment d'être joué.
- **Un trou sans aucun score compte quand même** : nombre de trous de la session (au moins 3
  pour les statistiques et badges, `isEligibleSession`), historique du trou (`holes_history` :
  la session y figure comme jouée sur ce trou), « x / y trous » du classement
  (`TeamStanding.holesTotal`). Les moyennes, records et roi du trou, eux, ne lisent que les
  scores saisis.

### Ce que prévoit l'avenant

Q263, Q264 (sauf l'ordre), Q265 (remplacée par la conception du PO) et Q266 tranchées le
2026-10-07, puis Q267 à Q269 le même jour (suggestions acceptées).

1. **Où** (Q263) : une section « Trous » dans toute salle d'attente (« En préparation »),
   brouillon ou non, gérée par les organisateurs, lue par les participants.
2. **Quoi** (Q264) : ce que permet la partie en cours, avec ses panneaux : ajouter (proche,
   annuaire, créé sur place, libre ; par, commentaire, mode de jeu), modifier par et
   commentaire, retirer. Pas de score avant « Démarrer ».
3. **Ordre** (Q265, conception du PO) : une seule liste dont l'ordre se règle, réservé aux
   organisateurs (créateur, co-organisateurs, `super_admin`) :
   - une icône de déplacement sur chaque trou : glisser-déposer pour l'intercaler entre deux
     autres. Le numéro d'un trou étant sa place dans le parcours, le déplacer renumérote les
     trous concernés (Q267) ;
   - en haut de la liste, un bouton qui inverse l'ordre d'affichage (le plus récent en haut ou
     le trou n° 1 en haut), commun à tous les joueurs de la session (Q267) ;
   - par défaut, rien ne change : le plus récent en haut, comme aujourd'hui ;
   - dans la salle d'attente et pendant la partie, pas après la fin (Q269).
4. **Trou mis en avant pendant la partie** (Q268) : le prochain à jouer, c'est-à-dire le premier
   du parcours où une équipe n'a pas encore de score ; quand tout est saisi, le dernier du
   parcours. Pour une session jouée au fil de l'eau, c'est le même qu'aujourd'hui.
5. **Fin de partie** (Q266) : les trous restés sans aucun score sont retirés quand la session
   se termine, par un déclencheur en base (vrai pour tout chemin), les trous restants
   renumérotés sans trou manquant (Q269), et la confirmation de fin le dit.

### Décisions techniques

- **Sens d'affichage** : colonne `sessions.holes_ascending boolean not null default false`
  (faux = le plus récent en haut, l'affichage actuel), écrite par les organisateurs (règle
  `sessions_update_owner` existante). Toutes les sessions existantes gardent l'affichage actuel.
- **Déplacement** : RPC `move_played_hole(p_played_hole_id uuid, p_position int)`, qui place le
  trou à sa nouvelle place et décale ceux d'entre les deux, en une transaction. La contrainte
  d'unicité `(session_id, position)` n'étant pas différable, les places sont d'abord passées en
  négatif puis réécrites. Réservée aux organisateurs (`is_session_owner`), refusée après la fin
  de la session (Q269). Les scores restent attachés à leur trou, pas à sa place.
- **Fin de partie** : déclencheur `sessions_drop_unplayed_holes`, au passage d'une session à
  « terminée » : suppression de ses trous sans aucun score, puis renumérotation des restants.
- **App** : une liste réordonnable commune (`ReorderableListView` à poignée) pour la salle
  d'attente et la partie en cours, avec le bouton d'inversion ; une fonction pure pour l'ordre
  d'affichage et le trou mis en avant (testée), à la place de `playedHolesRecentFirst` et de
  « la carte du haut ». Salle d'attente : trous lus par `session_snapshot` ; panneaux
  `showAddPlayedHoleSheet` et `showPlayedHoleSettingsSheet` réutilisés. Icône de poignée
  ajoutée à `phosphor_icons.dart`.
- **Migration additive unique** pour l'avenant (colonne, RPC, déclencheur), répétée sur la
  production dans une transaction annulée puis appliquée, sur accord du PO, comme la première ;
  tests dans `rls_smoke.sql` (déplacement, droits, refus après la fin, suppression et
  renumérotation à la fin).

## Hors périmètre

- Publier depuis la session, remettre en brouillon une session publiée (Q256).
- Jouer une partie de test en privé : un brouillon ne se lance pas (Q261).
- Modèles de session réutilisables plusieurs fois : un brouillon utilisé devient la session,
  il ne se copie pas.
- Nouveau rôle de session : les co-organisateurs existants suffisent.
- Notification à la publication d'un brouillon.
