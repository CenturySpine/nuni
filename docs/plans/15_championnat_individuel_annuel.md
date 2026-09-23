# Plan 15 — Championnat individuel annuel

## En bref, pour les membres de l'association

Certaines parties compteront pour un classement annuel, un peu comme un championnat de club.
Concrètement, pour un joueur :

- Quand on crée une partie, on peut cocher une case "elle compte pour le championnat" — ou cocher
  cette case après coup, une fois la partie terminée.
- Le championnat se déroule sur une saison, du 1er septembre au 31 août (par exemple "saison
  2026-2027").
- Les parties qui comptent sont regroupées automatiquement par secteur géographique : personne n'a
  besoin de définir des limites de ville ou de quartier, l'appli les devine toute seule d'après les
  lieux où l'on joue réellement.
- Chaque partie qui compte rapporte des points selon le classement du jour, plus un petit point
  supplémentaire simplement pour être venu, même sans bien se classer. Ça encourage à venir
  régulièrement, sans jamais permettre à quelqu'un de doubler un meilleur résultat juste en
  cumulant des présences.
- Ces points s'additionnent sur toute la saison, quel que soit le type de partie jouée (au nombre
  de coups, en duel, en points libres...) : tout se mélange dans un seul classement.
- Sur la page d'accueil de l'appli, chaque joueur voit sa position actuelle, mise à jour au fil des
  parties.

## Note pour les personnes qui suivent le développement du projet

À partir d'ici, le document devient technique : modèle de données, mécanismes de calcul, écrans au
sens développement. La partie ci-dessus reste la référence fonctionnelle.

## Objectif

Permettre un classement individuel qui se déroule sur une année scolaire (ex. 2026-2027), limité
aux sessions que leur créateur a marquées "championnat", regroupées automatiquement par zone
géographique, et affiché de façon provisoire sur l'accueil pour chaque joueur concerné.

## Prérequis

- Historique des sessions et des scores (étapes 8 et 10, déjà livrées).
- Position géographique connue pour chaque session, capturée à sa création (étape 7).

## Décisions retenues (validées par le PO le 2026-09-21)

1. **Qui tague, et quand.** Seul le créateur d'une session peut la marquer "championnat", à la
   création ou à n'importe quel moment ensuite, y compris après que la session est terminée.
   Personne d'autre ne peut la marquer ou la démarquer.
2. **Zones géographiques, sans configuration.** Il n'existe plus de référentiel ville/zone dans
   NUNI (la ville d'une session est un simple texte détecté à sa création, modifiable, pas une
   entité administrée). Un regroupement "par ville" au sens strict serait donc soit trop rigide
   (des sessions à quelques rues d'écart mais avec un nom de ville légèrement différent se
   retrouveraient dans deux championnats séparés), soit exigerait qu'un administrateur découpe des
   zones à la main — explicitement écarté par la demande.
   Retenu à la place : les sessions marquées championnat se regroupent **automatiquement entre
   elles par proximité géographique réelle**, sur le même principe que le rayon déjà utilisé pour
   proposer les trous à proximité (étape 6). Une session rejoint une zone existante si elle est
   raisonnablement proche d'autres sessions championnat déjà jouées ; sinon, elle fonde une
   nouvelle zone. Aucun réglage préalable, aucune liste de villes à maintenir : les zones émergent
   des lieux où l'on joue réellement.
   Le nom affiché d'une zone reste un sujet ouvert (Q41 ci-dessous).
3. **Points d'une session championnat.** Le nombre de points de classement gagné dépend de la
   position finale du jour et du nombre de participants à cette session : une victoire dans une
   session à beaucoup de monde vaut plus qu'une victoire dans une petite session, et même la
   dernière place d'une grande session rapporte un point de classement non nul (jamais zéro). Le
   mode de jeu de la session (stroke play, match play, redistribution, libre) n'entre pas en
   compte : seule la position finale du jour compte, ce qui permet d'agréger des sessions de modes
   différents dans un même total.
   S'ajoute un **point de présence automatique et fixe**, gagné par toute personne ayant joué une
   session championnat, quel que soit son classement ce jour-là. Il incite à venir même sans
   viser la victoire, sans jamais permettre à une simple présence de dépasser un résultat mieux
   classé : l'écart entre deux positions de classement reste toujours supérieur à ce point fixe.
   **Sessions en mode Équipe (Q43) :** elles comptent aussi pour le championnat individuel. Les
   points de classement et de présence de l'équipe sont attribués identiquement à chacun de ses
   membres ce jour-là (pas de partage ni de pondération par mérite individuel supposé).
4. **Score du championnat.** Somme, sur toute la saison, des points de classement et de présence de
   toutes les sessions championnat jouées par le joueur dans sa zone. Pas de moyenne, pas de
   meilleurs résultats retenus en excluant les autres : chaque session championnat jouée compte.
5. **Portée d'un joueur.** Un joueur peut apparaître dans plusieurs zones la même saison s'il a
   joué des sessions championnat à des endroits suffisamment éloignés les uns des autres (aucune
   règle d'unicité n'est nécessaire, la zone découle uniquement des sessions jouées).

## Décisions complémentaires (validées par le PO le 2026-09-21)

Reprises de `QUESTIONS_PO.md` (Q38–Q42), toutes tranchées :

- **Q38** — Saison du 1er septembre au 31 août de l'année suivante.
- **Q39** — Pas de nombre minimal de sessions jouées pour apparaître au classement, provisoire ou
  final.
- **Q40** — En cas d'égalité de classement au sein d'une session (deux joueurs ex æquo ce jour-là),
  les deux touchent les mêmes points de classement.
- **Q41** — Le nom affiché d'une zone de championnat est déduit automatiquement du texte "ville" le
  plus fréquent parmi les sessions qui la composent, sans saisie manuelle.
- **Q42** — Cette fonctionnalité est indépendante des étapes 11 (déploiement), 13 (migration) et 14
  (suppression de compte) du plan d'ensemble ; son développement détaillé peut être planifié dès
  maintenant, sans attendre ces trois étapes.
- **Q43** — Une session en mode Équipe compte aussi pour le championnat individuel ; ses coéquipiers
  touchent tous les mêmes points ce jour-là.
- **Q44** — Rayon de rapprochement géographique des zones de championnat : 15 km, fixe.
- **Q45** — Égalité de points en fin de saison entre deux joueurs : départagée d'abord par le
  nombre de sessions championnat jouées (le plus présent gagne) ; si cette présence est elle aussi
  égale, égalité finale ("ex æquo").

## Parcours et écrans (grandes lignes fonctionnelles)

1. **Marquer une session "championnat".** Une case à cocher visible à la création de la session,
   et dans ses réglages tant qu'elle appartient à son créateur, y compris après clôture. Dès qu'elle
   est cochée, l'app affiche la zone et la saison détectées ("Cette session compte pour le
   championnat de [zone], saison [année]"), pour que le créateur vérifie avant de continuer — le
   rattachement automatique n'est jamais un calcul invisible.
2. **Encart classement sur l'accueil.** Pour tout joueur ayant au moins une session championnat
   dans sa zone pour la saison en cours : sa position actuelle, son total de points, et les deux ou
   trois joueurs autour de lui au classement. Un lien ouvre le classement complet. Si le joueur n'a
   aucune session championnat, l'encart ne s'affiche pas (pas d'écran vide à expliquer).
   Modifié par le PO (2026-09-23) : l'encart affiche d'abord le podium (3 premières places), puis
   la ligne du joueur s'il n'y figure pas, précédée de "⋯", et un lien "Voir tout le classement".
3. **Écran de classement complet.** Liste ordonnée des joueurs d'une zone pour une saison : position,
   total de points, nombre de sessions championnat jouées. Sélecteur de saison, pour consulter les
   années précédentes une fois qu'il y en a. Si le joueur appartient à plusieurs zones, il peut
   basculer entre elles.
4. **Détail d'une session depuis le classement.** Ouvre l'écran d'historique de session déjà
   existant (étape 10), avec en plus la mention des points de classement et de présence gagnés ce
   jour-là par chaque joueur.

## Modèle de données

Migrations éditées (fichiers thématiques existants, règle 8 AGENTS.md — aucun nouveau fichier),
et **préavis au PO avant de reconstruire le schéma distant** (même règle) :

- `20260915100000_extensions_and_enums.sql` : inchangé, aucun nouvel enum nécessaire.
- `20260915100100_tables.sql` :
  - Nouvelle table `championship_zones (id uuid primary key default gen_random_uuid(), created_at
    timestamptz not null default now())`. Volontairement minimale : pas de colonne `name`, le nom
    affiché (Q41) se déduit à la lecture (voir RPC ci-dessous), jamais stocké — évite une écriture
    supplémentaire à chaque nouvelle session qui rejoint la zone, et tout risque de nom figé qui se
    désynchronise des sessions réelles.
  - Nouvelles colonnes sur `sessions` :
    - `is_championship boolean not null default false` — posée par le créateur (Q du tagage,
      décidée le 2026-09-21).
    - `championship_zone_id uuid references championship_zones (id)` — **jamais posée par le
      client** (même principe que `team_players.session_id`, déjà dénormalisée par trigger) :
      calculée automatiquement, voir "Regroupement géographique" ci-dessous.
    - `championship_season text` — dérivée de la date de la session (Q38), jamais saisie. **Pas**
      une colonne générée comme `start_lat`/`location_lat` : Postgres exige une expression
      `IMMUTABLE` pour une colonne générée, et extraire l'année/le mois d'un `timestamptz` n'est
      que `STABLE` (dépend du réglage de fuseau horaire de la session) -- constaté à la
      reconstruction du 2026-09-22, `create table` refusée avec "generation expression is not
      immutable". Recalculée à la place par le même trigger que la zone (ci-dessous), sur chaque
      insertion/mise à jour (pas gelée comme la zone : une date de début corrigée après coup,
      étape 10, doit déplacer la session vers la bonne saison).
- `20260915100200_indexes.sql` : index spatial partiel `create index sessions_championship_location_idx
  on sessions using gist (location) where is_championship;` — n'indexe que les sessions
  championnat, utilisé uniquement par le rattachement de zone (ci-dessous) ; index simple sur
  `(championship_zone_id, championship_season)` pour les lectures du classement.
- `20260915100300_utility_functions.sql` : fonction `assign_championship_zone(session sessions)
  returns uuid` — cherche une session championnat existante à moins de 15 km (Q44, `ST_DWithin` sur
  `location`, en mètres) ayant déjà une zone ; la réutilise si trouvée, sinon insère une nouvelle
  ligne dans `championship_zones` et retourne son id. Fonction `championship_zone_label(zone_id
  uuid) returns text` — ville la plus fréquente parmi les sessions de la zone (`group by city order
  by count(*) desc limit 1`), utilisée par l'écran de classement et par la confirmation à la
  création (Q41).
- `20260915100400_rls.sql` :
  - `championship_zones` : lecture accordée à `authenticated` (`using (true)`) — un classement de
    championnat n'est pas une donnée confidentielle, contrairement au détail d'une session member-only.
    Aucun droit d'écriture accordé au rôle `authenticated` : seule la fonction du trigger (ci-dessous,
    propriétaire de la table) y écrit.
  - Droit d'exécution des deux nouvelles fonctions RPC (ci-dessous) révoqué à `PUBLIC`, regranté à
    `authenticated` seulement, même traitement que les RPC existantes.
- `20260915100500_triggers.sql` : trigger dédié `before insert or update on sessions` qui :
  1. Recalcule `championship_season` à chaque fois (voir ci-dessus) — jamais gelée, contrairement
     à la zone : une date de début corrigée après coup (étape 10) déplace la session vers la bonne
     saison.
  2. Fige `championship_zone_id` à sa valeur précédente (`OLD.championship_zone_id` ou `null` à la
     création) — toute valeur envoyée par le client est ignorée, jamais une erreur silencieuse côté
     client, juste un champ qu'il n'a jamais eu à remplir.
  3. Si `NEW.is_championship = true` et que la zone n'est pas encore posée, appelle
     `assign_championship_zone(NEW)` et l'assigne. Une fois posée, elle ne change plus, même si la
     session est démarquée puis remarquée plus tard (Q du tagage) : pas d'oscillation, un
     comportement simple à expliquer et à tester.
  4. Si la session n'a pas de position connue (`location is null` — géolocalisation refusée à la
     création, plan 07), `is_championship` ne peut pas passer à `true` : la fonction lève une
     erreur explicite, remontée à l'écran (case à cocher désactivée, message "position inconnue
     pour cette partie").
- `20260915100600_rpc.sql` : deux fonctions `security definer` (même famille que
  `is_session_member`/`is_session_owner`) :
  - `championship_zone_results(zone_id uuid, season text)` — pour chaque session où
    `is_championship = true`, `status = 'completed'`, `championship_zone_id = zone_id` et
    `championship_season = season` : son mode de scoring, son sens de classement, ses équipes, les
    joueurs de chaque équipe, et les scores saisis trou par trou. **Volontairement le même type de
    contenu que ce que l'écran de session lit déjà**, mais agrégé sur plusieurs sessions et
    restreint aux seules sessions ayant explicitement rejoint un championnat — une session normale,
    non marquée, reste invisible à quiconque n'en est pas membre, RLS inchangée pour elle.
  - `championship_zone_label(zone_id uuid)` — le nom déduit (ci-dessus), exposé séparément pour
    l'affichage (en-tête d'écran, confirmation de tagage) sans redemander tout le détail des
    sessions.
- `20260915100700_realtime.sql` : **pas de changement.** Le classement est une agrégation de
  sessions déjà terminées, pas un flux en direct comme la saisie de scores (plan 08) ; l'écran se
  recharge à l'ouverture et par tirer-pour-rafraîchir, sans abonnement `postgres_changes` dédié.
- `20260915100800_storage.sql` : inchangé.

## Regroupement géographique (mécanisme)

Rattachement au fil de l'eau, jamais recalculé globalement : quand une session est marquée
championnat, on cherche si une session championnat déjà existante est à moins de 15 km (Q44) et
possède déjà une zone ; si oui, la nouvelle session la rejoint ; sinon elle fonde sa propre zone.
Une fois posée, l'appartenance d'une session à une zone ne bouge plus.

Limite connue, acceptée pour la simplicité (aucune configuration à faire porter par un
administrateur, cohérent avec la demande) : ce rattachement "de proche en proche" peut en théorie
faire s'étendre une zone de proche en proche sur une longue distance si des sessions s'enchaînent
tous les 15 km sans discontinuité (effet de chaîne). Sans objet à l'échelle d'une association
locale ; à surveiller seulement si l'usage dépasse largement ce cadre.

**Compatibilité avec les sessions importées de LsgScores (plan 13, M5).** Ce mécanisme ne suppose
rien de spécifique à une session créée dans NUNI : il ne regarde que `sessions.location`. Le plan
13 prévoit que les sessions importées reçoivent cette position au moment de la migration (centre
géométrique des trous qu'elles référencent, repositionnés au préalable dans l'app) — une fois
posée, ces sessions rejoignent une zone exactement comme n'importe quelle autre, y compris une zone
déjà peuplée par de vraies sessions NUNI jouées au même endroit. Le tagage "championnat" de ces
sessions importées ne passe pas par la règle normale "seul le créateur" de ce plan, puisque le
propriétaire d'une session importée n'a souvent aucun compte NUNI encore rattaché (plan 13, M2) :
il se fait par une action côté app réservée au rôle `super_admin` (plan 16, Q48), pas par un script
de migration à clé service — détail technique (RPC dédiée) écrit lors du plan 13 détaillé.

## Calcul des points (mécanisme)

Respecte la convention déjà en place (AGENTS.md : "calcul des scores et du classement en Dart,
testé unitairement ; la base ne stocke que les valeurs saisies") : aucune valeur de classement
n'est calculée ni stockée côté base, `championship_zone_results` ne renvoie que des données brutes
déjà saisies (scores, équipes, mode). Le calcul se fait en Dart, à chaque lecture de l'écran de
classement ou de l'encart d'accueil — pas de valeur mise en cache à invalider, même principe déjà
retenu pour l'écran de session en direct (Q36 : on relit et on recalcule, on ne corrige jamais un
état stocké). Sans risque de performance à l'échelle d'une association (quelques dizaines de
sessions par saison, quelques joueurs).

Étapes du calcul, par zone et par saison :

1. Pour chaque session reçue de `championship_zone_results`, exécuter le **même calculateur de
   classement déjà utilisé et testé pour l'écran de session** (`stroke_play` / `match_play` /
   `redistribution` / `free`, `features/sessions/domain`) sur ses scores bruts, pour obtenir
   l'ordre d'arrivée des équipes ce jour-là (aucune nouvelle logique de classement par mode :
   réutilisation directe).
2. Convertir cet ordre en points de classement du jour : une équipe à la position *p* sur *n*
   équipes reçoit `n − p + 1` points (la dernière équipe reçoit 1, jamais 0). Deux équipes ex æquo
   (Q40) reçoivent toutes les deux les points de la meilleure des deux positions.
3. Chaque joueur de chaque équipe (Q43 : tous les coéquipiers, à l'identique) reçoit ces points de
   classement, plus 1 point de présence fixe.
4. Sommer, par joueur, les points de toutes les sessions de la zone/saison : c'est le score du
   championnat affiché au classement.
5. Trier par score décroissant ; égalité de score final (Q45) : départager par le nombre de
   sessions championnat jouées dans la zone/saison (le plus présent gagne) ; si cette présence est
   elle aussi égale, égalité finale affichée ("ex æquo").

Fonctions pures et testées unitairement (`features/championship/domain`), aucune dépendance à
Supabase : `sessionRankingPoints(rankedTeamIds) -> Map<teamId, int>`,
`seasonStandings(List<SessionResult>) -> List<PlayerStanding>`.

## Parcours et écrans — détail technique

1. **Case à cocher "championnat"** (création et réglages de session, tant que `owner`) :
   `features/sessions/ui`, appelle une mise à jour normale de `sessions.is_championship` (RLS déjà
   en place, propriétaire). Après écriture, relit la session (le trigger a posé
   `championship_zone_id`/`championship_season`) puis appelle `championship_zone_label` pour
   afficher "Cette session compte pour le championnat de [zone], saison [saison]". Case désactivée
   avec message si `location` est absente.
2. **Mes zones de championnat, saison en cours** : requête directe sur `sessions` (RLS existante,
   pas de RPC) — `championship_zone_id`, `championship_season` des sessions championnat terminées
   où le joueur lié à l'utilisateur figure dans une équipe. Alimente l'encart d'accueil (une entrée
   par zone si plusieurs).
3. **Encart d'accueil** (`features/home/ui`) : pour chaque zone trouvée à l'étape 2, appelle
   `championship_zone_results` + calcule le classement (ci-dessus), extrait la position du joueur,
   son total, les joueurs autour de lui. N'affiche rien si aucune zone.
4. **Écran de classement complet** (`features/championship/ui`) : sélecteur de saison (liste des
   saisons distinctes déjà vues pour cette zone, calculée côté client à partir des sessions
   retournées, pas de nouvelle RPC), bascule de zone si le joueur en a plusieurs, liste triée
   complète.
5. **Détail d'une session depuis le classement** : réutilise l'écran d'historique existant (plan
   10), complété par les points de classement et de présence calculés à l'étape "Calcul des
   points" pour cette session précise.

## Étapes (développement)

1. Migrations : table `championship_zones`, colonnes et trigger sur `sessions`, fonctions et RPC
   (`utility_functions.sql`, `rpc.sql`, `triggers.sql`, `rls.sql`, `indexes.sql`, `tables.sql`) —
   **préavis PO puis reconstruction du schéma distant** (règle 8 AGENTS.md), `docs/reference/modele_de_donnees.md`
   mis à jour en même temps.
2. `features/championship/domain` : modèles `freezed` (résultat brut par session, classement d'un
   joueur), calculateurs de points, agrégation de saison — tests unitaires en priorité (barème,
   égalités, sessions équipe, plusieurs zones).
3. `features/championship/data` : repository (`championship_zone_results`, `championship_zone_label`,
   requête "mes zones de la saison").
4. `features/championship/ui` : écran de classement, sélecteurs saison/zone.
5. `features/sessions/ui` : case à cocher championnat (création + réglages), confirmation de zone/saison.
6. `features/home/ui` : encart de classement provisoire.
7. Chaînes ARB (EN/FR) pour tous les textes visibles (case à cocher, encart, écran de classement,
   messages d'erreur "position inconnue").

## Critères d'acceptation

- Une session marquée championnat rejoint automatiquement une zone et une saison, sans qu'un
  administrateur ait rien configuré au préalable, et sans que le client ne puisse choisir ou
  modifier directement cette zone.
- Le classement additionne correctement les points de classement et de présence de toutes les
  sessions championnat d'un joueur dans sa zone et sa saison, quel que soit le mode de jeu de
  chaque session, y compris les sessions en mode Équipe (Q43).
- Une session non marquée championnat reste invisible à quiconque n'en est pas membre : la RPC de
  classement n'élargit l'accès qu'aux sessions explicitement marquées et terminées.
- Le classement provisoire est visible sur l'accueil pour tout joueur ayant au moins une session
  championnat dans la saison en cours, et absent sinon.
- Les calculateurs de points (barème, égalités, agrégation de saison) sont couverts par des tests
  unitaires, sans appel réseau.
- `fvm flutter analyze` sans avertissement, tests verts, build Vercel vert, chaînes traduites
  EN et FR (définition de "terminé", AGENTS.md).

## Complément du 2026-09-23 : historique des championnats sur l'accueil (Q72, validé et implémenté le 2026-09-23)

Constat : l'encart de l'accueil n'affiche que la saison en cours et c'est le seul chemin vers le
classement complet ; une saison passée (ex. 2025-2026, sessions LsgScores importées puis marquées)
devient inaccessible. Demande PO : un historique des championnats sur l'accueil, comme il existe
un historique des sessions.

Conception proposée :

- Section « Championnat » de l'accueil, en deux parties :
  1. Saison en cours : encarts actuels inchangés (classement provisoire autour du joueur).
  2. « Championnats passés » : une ligne par couple zone/saison où le joueur a au moins une session
     championnat, la plus récente en premier : nom de la zone, saison, position finale du joueur
     et nombre de joueurs classés, total de points (ex. « INSA · 2025-2026 — 2e sur 8 · 42 pts »).
     Toutes les saisons passées sont listées (quelques lignes par an au plus).
- La section s'affiche dès que le joueur a une session championnat, quelle que soit la saison ;
  rien sinon (inchangé).
- Toucher un encart ou une ligne ouvre le classement complet directement sur cette zone et cette
  saison (`/championship?zone=<id>&season=<saison>`) ; sans paramètre, comportement actuel.
- Aucune donnée ni requête nouvelle : mêmes appartenances et même calcul de classement que
  l'encart actuel.
- Chaînes EN/FR : « Championnats passés », « {position}e sur {total} » et l'équivalent anglais.
- Tests : section avec une saison en cours et une saison passée ; seule une saison passée ;
  ouverture du classement sur la bonne zone/saison.

## Questions PO liées

Q38 à Q45 — voir [QUESTIONS_PO.md](../QUESTIONS_PO.md). Toutes tranchées. Q72 (complément du
2026-09-23).
