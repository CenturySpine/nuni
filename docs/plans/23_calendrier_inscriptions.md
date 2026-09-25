# Plan 23 — Planning d'association : événements, inscriptions et commentaires

## Statut

Plan détaillé rédigé le 2026-09-25 à partir des besoins exprimés par le PO le même jour ; il
remplace la fiche synthétique du 2026-09-24 (sessions « planifiées »), dont l'approche est
abandonnée : un événement est un objet à part, pas une session dans un nouveau statut (décision
1). Révisé le même jour après les réponses du PO à Q147 à Q160 et Q102, et l'ajout de la vue
détaillée plein écran et des commentaires. Q153, Q161, Q162, Q163 et Q165 tranchées le même
jour, puis Q154, Q164, Q166 à Q168 (partage d'un événement, demandé par le PO) le même
jour. Plus aucune question ouverte. **En attente de validation par le PO** avant implémentation
(règle 1, AGENTS.md).

## En bref, pour les membres

- Chaque association a un planning : la liste de ses événements (sorties de jeu, mais aussi
  repas de Noël, assemblée générale…), dans l'ordre des dates, avec un séparateur par année et
  par mois. Pas de grille de calendrier : seulement les événements prévus.
- Tout membre de l'association peut créer un événement : date et heure, libellé, et s'il le
  veut lieu, point précis sur la carte, responsable, description et couleur. Le lieu et le
  point peuvent être fixés au dernier moment : on peut ouvrir les inscriptions avant.
- Tout membre peut cloner un événement pour le reprogrammer en deux gestes.
- Le lieu et le libellé se choisissent dans une liste propre à l'association, ou se tapent
  librement ; ce qui est tapé rejoint la liste pour les fois suivantes. Les lieux sont aussi
  proposés à la création d'une session.
- Le responsable local (et le super administrateur) peut importer les événements d'un agenda
  (Google Agenda, Calendrier Apple, Outlook). Un nouvel import remplace les événements importés
  la fois précédente, jamais ceux créés par les membres.
- Chaque membre répond en un geste : présent, absent ou peut-être. Tous les membres voient qui
  vient.
- Chaque événement s'ouvre en plein écran avec toutes ses informations et une grande carte, et
  porte un fil de commentaires simple (liens web et mail cliquables).
- Le prochain événement de mon association s'affiche sur l'accueil, avec mes boutons de réponse
  et le nombre de commentaires.
- Le jour J, un bouton « Démarrer la session » crée une session de jeu avec les présents déjà
  sélectionnés ; on la complète ensuite comme n'importe quelle session.
- Tout événement se partage (WhatsApp, SMS, mail…) : le lien ouvre directement sa vue
  détaillée, après connexion si besoin.

## Objectif

Donner à chaque association un planning partagé et léger, alimenté par ses membres ou importé
d'un agenda existant, savoir à l'avance qui viendra, échanger autour de chaque événement, et
démarrer la session du jour sans ressaisir les joueurs.

## Prérequis

Plans 07 (création de session), 18 (associations, responsables locaux,
`is_association_manager`) et 26 (lecture ouverte à l'association) livrés. Carte OpenStreetMap
déjà en place (`flutter_map`, plans 06 et 18).

## Décisions retenues

1. **Un événement n'est pas une session** (confirmé par le PO, Q160) : un événement peut
   concerner la vie de l'association sans aucun jeu (repas, assemblée générale). Nouvelle table
   `events`, indépendante de `sessions` ; une session peut seulement être démarrée depuis un
   événement (décision 13).
2. **Qui fait quoi** : création à la main, clonage, réponse et commentaire par tout membre de
   l'association de l'événement (Q101) ; import réservé au responsable local et au
   `super_admin`. Modification et suppression : le créateur, le responsable local et le
   `super_admin` (Q150, Q151), ainsi que le responsable désigné de l'événement (Q161).
   La suppression est définitive et emporte réponses et commentaires, après
   confirmation.
3. **Champs d'un événement** :
   - date et heure de début (jour, mois, année, heure, minute), obligatoires ; pas d'heure de
     fin ;
   - libellé, obligatoire, choisi dans la liste de l'association ou saisi librement ;
   - lieu (« spot »), facultatif (Q150), choisi dans la liste ou saisi librement ;
   - emplacement précis, un seul point sur la carte OpenStreetMap, facultatif (Q150),
     pré-rempli par le dernier point connu du lieu choisi ;
   - responsable, un joueur de l'association, facultatif, par défaut le créateur ;
   - description, facultative ;
   - couleur, facultative, parmi huit teintes fixes (rouge, orange, jaune, vert, turquoise,
     bleu, violet, rose) ou aucune (Q149) ; la base stocke le nom de la teinte, la palette
     choisie par l'utilisateur donne la couleur exacte, en clair et en sombre ;
   - origine, « manuel » ou « importé », posée par la base, jamais saisie (Q155).
4. **Listes réutilisables sans table dédiée** (Q147, Q148) : les libellés proposés sont ceux
   déjà utilisés dans les événements de l'association, les plus récents d'abord ; les lieux
   proposés sont ceux des événements et les zones des sessions de l'association, dans le
   formulaire d'événement comme dans celui de session (le filtre des zones passe de « même
   ville » à « même association »). La gestion de ces listes viendra plus tard. Les libellés
   commençant par « Clone - » ne sont pas proposés (Q165).
5. **Clonage** (Q152) : ouvre le formulaire pré-rempli avec tous les champs, libellé préfixé
   « Clone - », date décalée d'une semaine ; les réponses et les commentaires ne sont pas
   copiés. Le clone est un événement « manuel » créé par celui qui clone.
6. **Réponses** (Q157) : présent / absent / peut-être, chacun pour soi seulement, modifiables
   jusqu'à l'heure de début ; liste nominative visible de tous les membres, avec le nombre de
   membres sans réponse.
7. **Commentaires** (demande PO) : fil linéaire, du plus ancien au plus récent ; chaque
   commentaire a un auteur (avatar et pseudo), une date et un texte libre. Liens web et
   adresses mail reconnus et cliquables. Ni sélecteur d'emoji (ceux du clavier du téléphone
   passent tels quels), ni réponse à un commentaire, ni mention. Tout membre de l'association
   commente, avant comme après l'événement ; 2 000 caractères au plus. L'auteur modifie et
   supprime son commentaire (un commentaire modifié porte la mention « modifié ») ; le
   responsable local et le `super_admin` peuvent aussi le supprimer (modération). La pastille
   compte tous les commentaires, sans notion de « non lu ». **Fil mis à jour en direct** tant
   que la vue détaillée est ouverte (Q166, voir décision 17).
8. **Pastille du nombre de commentaires** (demande PO) sur toutes les vues condensées d'un
   événement : carte de l'accueil et lignes du planning. Aucune pastille à zéro.
9. **Vue détaillée plein écran** (demande PO) : page dédiée avec toutes les informations, carte
   bien visible, réponses et commentaires (voir « Parcours et écrans »).
10. **Accueil** (Q158) : carte « Prochain événement », le premier événement de mon association
    dont la journée n'est pas finie, avec libellé, date, heure, lieu, mes trois boutons de
    réponse, le nombre de présents et la pastille des commentaires ; un appui ouvre la vue
    détaillée, un lien ouvre le planning. Rien s'il n'y a aucun événement à venir.
11. **Point d'entrée** (Q156) : un cinquième onglet « Planning » dans la barre du bas, masqué
    pour un joueur sans association (la carte de l'accueil aussi). Placement à revoir après
    essai visuel.
12. **Liste du planning** (Q159) : une seule liste, sans sélecteur « À venir / Passés » ; elle
    contient les événements passés et à venir dans l'ordre des dates, s'ouvre positionnée sur le
    prochain événement, et laisse remonter vers les passés, légèrement estompés (Q162). En-têtes d'année
    puis de mois. Chaque ligne : bande de couleur, jour et heure, libellé, lieu, ma réponse,
    nombre de présents, pastille des commentaires.
13. **Démarrer la session** (Q160, Q164) : sur un événement du jour, un bouton visible
    seulement du responsable de l'événement, du responsable local et du `super_admin` ouvre la
    création de session habituelle, pré-remplie avec les joueurs ayant répondu « présent » et
    la zone égale au lieu de l'événement ; celui qui appuie devient l'organisateur. Tout le
    reste de la création (mode, équipes, ajout ou retrait de joueurs, invitations) est
    inchangé : le bouton n'est qu'un raccourci. La session garde le lien vers son événement ;
    l'événement affiche les sessions démarrées depuis lui, et plusieurs sessions peuvent en
    partir (deux groupes le même soir).
14. **Import** : fichier iCalendar (Q153). Aperçu des événements trouvés avant
    enregistrement ; événements passés écartés. NUNI n'a aucune notion de répétition : chaque
    événement est indépendant (Q154). Une répétition trouvée dans le fichier (« chaque
    jeudi ») devient des événements indépendants, un par date, sur les 12 prochains mois, sans
    lien entre eux (Q167). Heures converties exactement depuis le fuseau horaire du fichier, pour
    qu'un événement de 19 h à Paris s'affiche à 19 h. Correspondance : `SUMMARY` → libellé,
    `DTSTART` → date et heure, `LOCATION` → lieu, `GEO` → point, `DESCRIPTION` → description ;
    responsable et créateur = l'importateur ; pas de couleur ; origine « importé ». Un
    `super_admin` choisit l'association cible, un responsable local importe dans la sienne.
15. **Ré-import** (Q155) : un import remplace les événements « importés » de l'association,
    après un avertissement qui dit combien d'événements seront effacés, avec combien de
    réponses et de commentaires. Les événements « manuels » ne sont jamais touchés. Seuls les
    événements importés **à venir** sont effacés, les passés restent (Q163).
16. **Pas de rappel ni de bouton « Ajouter à mon agenda »** (Q102 : pas pour le moment,
    ajoutable plus tard sans toucher à la base).
17. **Temps réel pour les commentaires seulement** (Q166) : la vue détaillée ouverte s'abonne
    aux commentaires de cet événement (abonnement Supabase filtré par `event_id`, comme les
    sessions en direct sont filtrées par `session_id`) ; un commentaire ajouté, modifié ou
    supprimé apparaît sans recharger. Le reste (planning, réponses, pastilles de l'accueil et
    du planning) se recharge à l'ouverture et en tirant vers le bas.
18. **Partage** (demande PO) : un bouton « Partager » sur la vue détaillée, pour tout membre,
    ouvre la feuille de partage du téléphone (WhatsApp, SMS, mail…), ou copie le lien quand le
    navigateur n'en a pas (ordinateur), comme l'invitation à une session (plan 09). Le lien est
    `https://nuni.centuryspine.org/planning/<id>` et ouvre directement la vue détaillée. Un
    visiteur non connecté passe par la connexion puis arrive sur l'événement, pas sur
    l'accueil ; le lien voulu est gardé sur l'appareil pendant la connexion Google, qui
    recharge la page. Le message partagé porte, avant le lien, le libellé, la date, l'heure et
    le lieu (Q168) : WhatsApp n'affiche pour le lien qu'un aperçu générique de
    NUNI, identique pour tous les événements (l'app ne fabrique pas de page par événement côté
    serveur). Un compte d'une autre association qui ouvre le lien voit « Cet événement
    appartient à une autre association » (Q168).

## Parcours et écrans

- **Onglet Planning** (`/planning`) : liste groupée par année et mois (`NuniSectionHeader`),
  lignes `NuniListCard` avec une bande de la couleur de l'événement, ouverte sur le prochain
  événement. Bouton flottant « Nouvel événement ». Menu « Importer un agenda » pour le
  responsable local et le `super_admin` seulement. État vide : `NuniEmptyState` invitant à créer
  le premier événement.
- **Vue détaillée plein écran** (`/planning/:id`), hors de la coquille à onglets (comme le
  détail d'une session) :
  - en tête, bande de couleur, libellé, date et heure en toutes lettres, mention « Importé » le
    cas échéant ;
  - carte haute (environ un tiers de l'écran) centrée sur le point, avec le nom du lieu et un
    bouton « Itinéraire » qui ouvre l'application de cartes du téléphone (`url_launcher`) ; un
    appui sur la carte l'ouvre en plein écran. Sans point : le lieu seul, ou « Lieu à préciser » ;
  - responsable (avatar, lien vers sa fiche publique), description avec liens cliquables ;
  - bouton « Démarrer la session » le jour de l'événement, liens vers les sessions déjà
    démarrées depuis lui ;
  - mes trois boutons de réponse, puis « Présents », « Peut-être », « Absents » et le nombre de
    membres sans réponse ;
  - fil des commentaires, champ de saisie en bas de page ;
  - action Partager (tout membre) dans la barre du haut ; actions selon les droits : Modifier,
    Cloner, Supprimer.
- **Formulaire** (`/planning/new`, `/planning/:id/edit`, `/planning/new?from=:id` pour un
  clone) : sélecteurs de date et d'heure Material, libellé avec suggestions (`Autocomplete`),
  lieu avec suggestions, carte de pose du point (sélecteur des associations généralisé en
  composant partagé `NuniLocationPicker`, avec un bouton pour retirer le point), responsable
  parmi les joueurs de l'association, description, rangée de pastilles de couleur.
- **Import** (`/planning/import`) : choix du fichier ; aperçu (date, libellé, lieu), tout coché
  par défaut ; avertissement de remplacement s'il existe des événements importés ; bouton
  « Importer N événements » ; retour au planning avec le nombre importé.
- **Accueil** : carte « Prochain événement » avant la section championnat.
- **Création de session** (`/session/new?event=:id`) : joueurs et zone pré-remplis depuis
  l'événement ; suggestions de zone par association.

## Modèle de données

Fichiers thématiques existants modifiés (règle 8) :

- `extensions_and_enums.sql` : enums `event_response` (`yes`, `no`, `maybe`), `event_color`
  (les huit teintes), `event_origin` (`manual`, `imported`).
- `tables.sql` :
  - `events` : `id`, `association_id` (not null), `created_by` (`auth.users`, not null),
    `manager_player_id` (`players`, nullable), `starts_at timestamptz not null`,
    `label text not null` (non vide), `spot text`, `location geography(point)` avec
    `location_lat` / `location_lng` générées (comme `sessions`), `description text`,
    `color event_color`, `origin event_origin not null default 'manual'`, `created_at`,
    `updated_at`.
  - `event_responses` : `event_id` (cascade), `player_id` (cascade), `response`, `updated_at`,
    clé primaire (`event_id`, `player_id`).
  - `event_comments` : `id`, `event_id` (cascade), `author_player_id` (`players`), `body text
    not null` (non vide, 2 000 caractères au plus), `created_at`, `edited_at` (null tant que
    le commentaire n'a pas été modifié).
  - `sessions.event_id` (nullable, `on delete set null`) : l'événement d'où la session a été
    démarrée.
- `indexes.sql` : `events (association_id, starts_at)`, `event_comments (event_id,
  created_at)`, `sessions (event_id)`.
- `triggers.sql` : à l'insertion par l'app, association = celle du créateur, responsable = son
  joueur s'il n'est pas fourni, origine forcée à `manual` ; `updated_at` ; refus d'un
  responsable hors de l'association ; refus d'une réponse posée ou modifiée après `starts_at` ;
  `sessions.event_id` accepté seulement pour un événement du jour de l'association de la
  session, et posé seulement par le responsable de l'événement, le responsable local ou le
  `super_admin` (Q164) ; `edited_at` posé à chaque modification d'un commentaire.
- `rls.sql` :
  - `events` : lecture par les membres de l'association et le `super_admin` ; insertion par un
    membre, pour sa propre association ; modification et suppression selon la décision 2.
  - `event_responses` : lecture par les membres de l'association ; écriture de sa seule ligne.
  - `event_comments` : lecture et insertion par les membres de l'association (auteur = son
    joueur) ; modification par l'auteur seul, texte uniquement ; suppression selon la
    décision 7.
- `realtime.sql` : `event_comments` ajoutée à la publication, `replica identity full` pour
  qu'une suppression porte `event_id` et atteigne l'abonnement filtré (même piège que `teams`
  et `scores`, déjà documenté dans ce fichier).
- `rpc.sql` : `import_events(p_association_id uuid, p_events jsonb)`, `security definer`,
  réservée à `is_association_manager(p_association_id)` ou `is_super_admin()` ; dans une seule
  transaction, supprime les événements importés à venir de l'association (Q163) puis insère les
  nouveaux avec l'origine `imported` ; renvoie le nombre d'événements supprimés et créés.
  `import_events_preview(p_association_id uuid)` renvoie ce que l'avertissement affiche
  (événements, réponses et commentaires qui seraient effacés).
- Nombre de commentaires et de présents dans les vues condensées : agrégats PostgREST
  (`event_comments(count)`) dans la même requête que la liste, sans colonne stockée.

## Code

- `lib/features/planning/`
  - `domain/` : `Event`, `EventResponse`, `EventComment` (freezed) ; enums miroirs ;
    `groupByMonth` (séparateurs année / mois) ; `nextEvent` (règle de la décision 10) ;
    `ics/ics_parser.dart` (dépliage des lignes, échappements, dates en UTC, en heure locale,
    avec `TZID` ou en date seule, `RRULE` quotidienne, hebdomadaire, mensuelle et annuelle avec
    `COUNT` / `UNTIL` / `INTERVAL` / `BYDAY`, `EXDATE`) ; tous testés unitairement, l'analyseur
    sur des fichiers d'exemple Google, Apple et Outlook placés dans `test/fixtures/ics/`.
  - `data/` : `EventsRepository` (liste, détail, création, modification, suppression, réponse,
    commentaires, suggestions, import) et ses fournisseurs Riverpod.
  - `ui/` : `PlanningPage`, `EventDetailPage`, `EventFormPage`, `EventImportPage`,
    `EventCommentsSection`, `NextEventHomeCard`, `EventCommentCountBadge`.
- `lib/shared/nuni_location_picker.dart` : extrait de `AssociationLocationPicker`, réutilisé
  par les associations et les événements.
- `lib/shared/nuni_linked_text.dart` : texte avec liens web et mail cliquables (paquet
  `linkify`, ouverture par `url_launcher`), pour les commentaires et la description.
- Couleurs des événements dans `lib/core/theme/` pour chaque palette, lues par `context.nuni`.
- Création de session : paramètre `event` qui pré-remplit joueurs et zone et pose
  `sessions.event_id`.
- Nouveaux paquets : `file_picker` (choix du fichier), `archive` (lecture du `.zip` Google,
  Q153), `timezone` (fuseaux horaires), `linkify` (reconnaissance des liens). Pas de paquet
  d'analyse iCalendar : les paquets existants gèrent mal les répétitions ou ne sont plus
  maintenus, et le sous-ensemble utile tient en un fichier testé.
- Partage : la logique de partage de `invite_sheet.dart` (Web Share API si disponible, sinon
  copie du lien) extraite dans `lib/shared/` et réutilisée par l'invitation et l'événement.
- Garde d'authentification (`auth_guard.dart`) : le mécanisme qui garde `/join/:code` pendant
  la connexion (`PendingJoinCode`) est généralisé en « lien en attente » pour tout chemin
  protégé (au moins `/join/:code` et `/planning/:id`), mémorisé dans le stockage du navigateur
  pour survivre au rechargement de la connexion Google, et effacé une fois utilisé.
- Barre du bas : cinquième destination, branche ajoutée au `StatefulShellRoute`, masquée sans
  association ; chemins de `NuniStandaloneBottomNav` mis à jour.
- Chaînes EN et FR dans les ARB, dates formatées par `intl` dans la langue de l'app.

## Reprise de l'existant et reconstruction

Aucune donnée existante n'est transformée : trois tables, trois enums et une colonne
facultative de `sessions` s'ajoutent. Les fichiers de migration étant édités en place (règle
8), la base distante doit être reconstruite selon `docs/DEV.md`, **PO prévenu avant** :
régénération et commit des seeds (étape 0), puis reconstruction et rejeu.
`tool/export_remote_seed.dart` exporte aussi `events`, `event_responses`, `event_comments` et
`sessions.event_id` dans le seed chiffré des données (noms de joueurs, textes libres).

## Étapes (développement)

1. Schéma, déclencheurs, RLS, RPC ; tests d'accès dans `supabase/tests/rls_smoke.sql` (membre :
   crée, lit, répond, commente ; membre d'une autre association : ne lit rien ; membre simple :
   ne modifie ni ne supprime l'événement d'un autre ni le commentaire d'un autre ; membre
   simple : ne pose pas `sessions.event_id` ; import
   refusé hors responsable local et `super_admin` ; ré-import qui garde les événements manuels
   et les importés passés ; réponse après le début refusée ; réponse au nom d'un autre
   refusée).
2. Modèles, dépôt, génération, tests unitaires (regroupement par mois, prochain événement).
3. Analyseur iCalendar et ses tests sur fichiers d'exemple.
4. Écrans : planning, vue détaillée, formulaire (création, modification, clone), réponses,
   commentaires.
5. Carte de l'accueil, onglet de la barre du bas, pastilles de commentaires, suggestions de
   lieux dans la création de session, « Démarrer la session ».
6. Import : choix du fichier, aperçu, avertissement, enregistrement.
7. Outil d'export des seeds ; **reconstruction de la base, PO prévenu**.
8. Documentation : `00_plan_ensemble.md`, `AGENTS.md` (convention « Planning »),
   `QUESTIONS_PO.md`.
9. Vérification : `fvm dart format`, `fvm flutter analyze --fatal-infos`, `fvm flutter test`,
   essai dans le navigateur intégré (créer, cloner, répondre, commenter avec un lien, démarrer
   la session, partager puis ouvrir le lien déconnecté, importer un fichier Google puis le
   ré-importer), puis test par le PO.

## Critères d'acceptation

- Un membre crée un événement avec seulement une date, une heure et un libellé ; sans libellé
  ou sans date, l'enregistrement est refusé. Lieu et point s'ajoutent ou se retirent plus tard.
- Un lieu ou un libellé tapé une fois est proposé à l'événement suivant de la même association,
  et pas dans une autre ; un lieu du planning est proposé à la création d'une session.
- Cloner un événement ouvre le formulaire pré-rempli, libellé « Clone - … », une semaine plus
  tard, sans réponses ni commentaires.
- Le planning n'affiche que des événements, groupés par année puis par mois, ouvert sur le
  prochain.
- L'accueil montre le prochain événement de mon association ; y répondre met à jour la vue
  détaillée. Sans association, ni onglet Planning ni carte sur l'accueil.
- La vue détaillée montre toutes les informations et une carte bien visible ; « Itinéraire »
  ouvre l'application de cartes.
- Un membre répond présent, absent ou peut-être et voit les réponses de tous ; il ne peut plus
  changer sa réponse après le début.
- Un commentaire contenant une adresse web et une adresse mail les rend cliquables ; la
  pastille de l'accueil et du planning montre le nombre de commentaires.
- Un commentaire ajouté, modifié ou supprimé sur un téléphone apparaît sur un autre téléphone
  qui a la vue détaillée ouverte, sans recharger ; un commentaire modifié porte « modifié ».
  Seul son auteur le modifie ; l'auteur, le responsable local et le `super_admin` le
  suppriment.
- Le jour de l'événement, « Démarrer la session » n'apparaît qu'au responsable de l'événement,
  au responsable local et au `super_admin` ; il ouvre la création de session avec les présents
  sélectionnés et la zone remplie ; la session créée apparaît sur l'événement.
- Ré-importer un agenda avertit, remplace les événements importés à venir et laisse intacts les
  événements créés par les membres.
- Un fichier exporté de Google Agenda et un fichier exporté de Calendrier Apple s'importent aux
  bonnes dates et heures ; une répétition du fichier donne des événements indépendants.
- Un membre d'une autre association ne voit ni l'événement, ni ses réponses, ni ses
  commentaires, ni dans l'app ni par un appel direct à la base ; `import_events` est refusée à
  tout compte autre que le responsable local et le `super_admin`.
- « Partager » ouvre la feuille de partage sur téléphone et copie le lien sur ordinateur ; le
  message collé dans WhatsApp montre libellé, date, heure, lieu et lien. Ouvert sans être
  connecté, le lien mène à la connexion puis directement à la vue détaillée de l'événement ;
  ouvert par un compte d'une autre association, il affiche un message clair, jamais le
  contenu.
- Chaînes EN/FR, `flutter analyze` sans remarque, tests verts, build Vercel vert.

## Hors périmètre

- Gestion des listes de libellés et de lieux (renommer, retirer ; Q147, plus tard).
- Rappels, notifications, « Ajouter à mon agenda » (Q102, plus tard).
- Abonnement à un agenda en ligne par son adresse (webcal) : Google et Apple ne permettent pas
  à une page web de lire ces adresses directement, il faudrait un relais côté serveur.
- Réponse à un commentaire, mention, sélecteur d'emoji, indicateur « non lu ».
- Vue en grille de calendrier (écartée par le PO).
- Événements communs à plusieurs associations.
- Aperçu WhatsApp propre à chaque événement (titre et image de l'événement dans la vignette du
  lien) : il faudrait une page générée côté serveur pour chaque lien.

## Questions PO liées

Toutes tranchées : Q101, Q102, Q147 à Q168.
