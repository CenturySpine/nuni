# Plan 21 — Badges

## Statut

Fiche synthétique (2026-09-24), catalogue trié par le PO le même jour (Q96) ; Q97, Q98 et Q111 à
Q114 tranchées le 2026-09-24. **Plan détaillé rédigé le 2026-09-24, en attente de validation du
PO** (règle 1, AGENTS.md). Plus d'hypothèse en attente propre au plan 21 (Q126 porte sur le
championnat, plan 26). Q94, Q115 à Q117, Q120 et Q123 à Q128 tranchées le 2026-09-24. Dépend du plan 26 (par de chaque trou joué) et des plans 19 et 20 (fiche joueur, lectures des statistiques) : implémenté juste après eux.

## En bref, pour les joueurs

- Des badges récompensent l'assiduité, les exploits, les victoires, le championnat, le jeu en
  équipe, l'exploration de nouveaux trous, les contributions à l'app, les conditions de jeu, les
  records et quelques situations cocasses : 74 badges au total.
- Ils sont calculés à partir de tout l'historique, sessions LsgScores comprises : un ancien
  joueur les découvre tous d'un coup à la première ouverture.
- Seules comptent les vraies parties : au moins 3 joueurs et au moins 3 trous joués. Une partie
  d'entraînement seul, un duel ou une session abandonnée après deux trous ne donnent aucun badge.
- Chaque badge est un médaillon avec un pictogramme. Les séries (5, 10, 25… sessions) partagent
  le même pictogramme et se distinguent par un anneau bronze, argent ou or.
- La fiche de chaque joueur montre ses badges, sauf s'il les a masqués. Sur sa propre fiche, on
  voit aussi, en gris, ceux qui restent à obtenir, avec la progression (« 7 / 10 sessions »).
- Un badge obtenu est annoncé à la fin de la session et reste gardé à vie.

## Objectif

Récompenser des exploits et la régularité pour donner une raison de rejouer et de partager.

## Prérequis

- Plan 19 (statistiques joueur) livré : fiche joueur `/players/:id`, colonne
  `players.badges_public` (Q108) et lecture de l'historique d'un joueur par RPC.
- Plan 20 (statistiques trou) livré : lecture des passages individuels sur un trou (record).
- Plans 15 et 18 (championnat par association et saison) livrés.
- Plan 26 livré : par de chaque trou joué, trous tous publics, `holes.cloned_from`.

## Décisions retenues

1. **Catalogue (Q96).** 73 badges triés par le PO (tout badge non marqué « X » au tri est
   accepté), plus « Sous la neige » ajouté le 2026-09-24 (Q117) : 74 badges. Détail plus bas.
2. **Rétroactivité (Q92, Q97).** Les sessions importées de LsgScores comptent. À la première
   ouverture, les badges déjà obtenus sont annoncés en un seul écran, pas un par un.
3. **Visibilité (Q98, Q106, Q108, Q133).** Visibles par tous sur la fiche du joueur, masquables
   par l'interrupteur « Badges publics » du profil, indépendant des statistiques. Le masquage ne
   porte que sur l'affichage (Q133) : les données dont les badges sont calculés restent
   lisibles en base par tout compte connecté.
4. **Gardé à vie (Q111).** Un badge obtenu n'est jamais retiré, même si le record qui l'a donné
   est battu.
5. **Seuils (Q96, Q112).** Abaissés au tri ; Marathon à 9 trous.
6. **Hold-up (Q113).** Strictement derrière le 1er avant le dernier trou, et 1er seul (sans ex
   æquo) à la fin. Aucune égalité ne déclenche le badge.
7. **Présentation (Q114).** Médaillon, pictogramme Phosphor, anneau de palier ; pourra évoluer.
8. **Calcul en Dart, aucune table.** Les règles vivent dans `lib/features/badges/domain/`
   (règle du projet : la base ne stocke que les valeurs saisies). Un badge n'est jamais écrit en
   base ; il est recalculé depuis l'historique à chaque affichage. Changer un seuil = modifier le
   code et redéployer, et le nouveau seuil s'applique aussitôt à tout l'historique.
9. **Record de trou (Q94).** Seuls les scores d'équipes d'un seul joueur comptent ; à égalité,
   le premier à l'avoir réalisé garde le record. Concerne J1 et J2.
10. **Heure (Q115).** Les heures (I5, I6) et les dates (semaines, saisons, mois) sont lues à
    l'heure locale de l'appareil, comme l'historique.
11. **Données importées (Q116).** Elles comptent aussi pour la famille H : le PO a créé ces
    trous et sessions dans l'ancienne app ; les autres joueurs obtiendront ces badges en créant
    des trous sur d'autres spots.
12. **Par du trou joué (plan 26).** Tout calcul de coups lit le par du trou joué
    (`played_holes.par`), propre à la session ; tout trou joué en a un, trous libres compris.
13. **Clones (Q120).** Un trou cloné (`holes.cloned_from`, plan 26) ne compte pas pour H1 et H2.
14. **Sessions éligibles (Q117, Q123).** Badges, statistiques joueur (plan 19), statistiques et
    records de trou (plan 20) ne comptent que les sessions d'au moins 3 joueurs et d'au moins
    3 trous joués : cela écarte le jeu seul, les duels, les sessions abandonnées, et limite la
    triche, puisque les scores sont saisis devant un groupe. Une seule règle partout, donc le
    détenteur affiché d'un record est bien celui qui obtient J1 à J3. Les autres définitions de
    Q117 sont dans « Définitions communes ».
15. **Nombre de joueurs, pas d'équipes (Q124).** Seul compte le nombre de joueurs (voir
    « Session éligible »).
16. **Bornes horaires (Q125).** Oiseau de nuit à partir de 21 h 00 pile ; Lève-tôt avant
    9 h 00 (8 h 59 compte, 9 h 00 non), 8 h jugé trop tôt par le PO.
17. **Badges à obtenir visibles (PO).** Un joueur doit voir tous les badges possibles, y
    compris ceux qu'il n'a pas, pour avoir envie de les chercher : sur sa fiche, les 74 badges
    sont affichés, les non obtenus en gris avec leur condition et leur progression.

18. **Pas de contrôle plus strict (Q127).** La règle des 3 joueurs ne rend pas la triche
    impossible (un organisateur peut inscrire 3 joueurs et tout saisir seul) ; on ne peut pas
    tout contrôler, aucune règle plus stricte n'est ajoutée.
19. **Badges proches (Q128).** En fin de session, en plus des nouveaux badges, l'app montre
    jusqu'à 3 badges proches (« Plus qu'une session pour Pilier »).

## Définitions communes

Conséquences de décisions déjà prises (Q117 tranchée le 2026-09-24), sauf mention d'une
question ouverte.

- **Session éligible** (Q117, Q124) : session terminée (`status = completed`) d'au moins 3 joueurs
  (`team_players`) et d'au moins 3 trous joués (`played_holes`). Au moins 3 joueurs suffit à
  garantir un adversaire (Q124) : une équipe compte exactement 2 joueurs (Q5), donc 3 joueurs
  = 3 équipes individuelles, et une session par équipes en compte au moins 4 (2 équipes).
  Les sessions en brouillon ou en cours, et toutes les autres, ne comptent pour aucun badge.
- **Session jouée** par un joueur : session éligible où il figure dans une équipe.
- **Trou joué** : trou d'une session jouée où l'équipe du joueur a un score saisi.
- **Date d'une session** : `started_at` (à défaut `created_at`). L'ordre chronologique suit
  cette date.
- **Coups** (familles C et J, et K2, K4) : seulement les sessions individuelles
  (`kind = individual`, Q90), hors mode de scoring « Libre » (valeur saisie = points). Trous
  libres compris : ils ont un par depuis le plan 26. Seuls les records (famille J) restent
  limités aux trous du référentiel, un trou libre n'ayant pas de fiche.
- **Vocabulaire** : par = par du trou joué (plan 26) ; birdie = par − 1 ; eagle = par − 2 ;
  albatros = par − 3 ; bogey = par + 1.
- **« X »** : un score de **10 coups ou plus**. Correction du 2026-09-24 : la saisie propose les
  chiffres 0 à 9 et un bouton « X » qui ouvre un champ de 10 à 20
  (`lib/features/live/ui/score_entry_sheet.dart`) ; « X » n'est donc pas exactement 10.
- **Classement d'une session** : celui du direct, `computeStandings`
  (`lib/features/live/domain/team_standing.dart`), qui met les ex æquo à la même place. Le
  classement « après le trou n » est le même calcul limité aux n premiers trous. Un badge et
  l'écran de session disent donc toujours la même chose.
- **Victoire** : place 1 au classement final, ex æquo compris (tous les ex æquo gagnent), sauf
  Hold-up (Q113). **Podium** : places 1 à 3.
- **Dernier** (K1, K3, D8) : la plus mauvaise place du classement, ex æquo compris.
- **Semaine** : du lundi au dimanche. **Saisons de l'année** (B4) : saisons météorologiques par
  mois, hiver = décembre à février, printemps = mars à mai, été = juin à août, automne =
  septembre à novembre.
- **Moitié de session** (D8) : après le trou n / 2 arrondi à l'inférieur (après le trou 3 pour
  une session de 7 trous).
- **Écart** (D9) : entre le vainqueur et le 2e, en coups (Stroke Play) ou en points (autres
  modes).
- **Éloignement** (G3) : distance à vol d'oiseau entre les positions des sessions
  (`sessions.location`, calculée pour les sessions importées comme le centre de leurs trous,
  plan 13) ; une session sans position ne compte pas. Critère géographique plutôt que le nom
  de ville, texte libre et fragile (Q117).
- **Pluie** (I1) : codes météo WMO 51 à 67 (bruine et pluie) et 80 à 82 (averses) ; l'orage
  ne compte pas. **Neige** (I8) : codes 71 à 77 (neige, même légère) et 85 à 86 (averses de
  neige). Météo absente = la session ne compte pas pour I1 à I4 ni I8.
- **Saison de championnat terminée** (E3 à E5) : aujourd'hui est après le 31 août de sa
  seconde année. Place = celle du classement de saison existant (`seasonStandings`,
  `lib/features/championship/domain/player_standing.dart`), ex æquo compris. Ce classement
  reste celui du championnat, toutes sessions de championnat comprises : le filtre des sessions
  éligibles s'applique à E1 et E2, pas au classement lui-même, sauf décision contraire du PO
  (Q126, ouverte).
- **Date d'obtention** : la date de la session (ou du trou, de la photo, de la fin de saison) qui
  fait franchir le seuil. Elle est affichée dans le détail du badge.

## Catalogue retenu (Q96)

Tri du PO (2026-09-24) sur le catalogue exhaustif de 78 badges : 6 supprimés (500 et 1 000
trous joués, Polyvalent, 25 équipiers, Toutes les formules, Cartographe), 1 ajouté (Hold-up),
9 seuils abaissés, 1 renommé (Carton plein → « Réservé aux adultes ») ; numérotation refaite.
Puis 1 ajouté le même jour avec Q117 (Sous la neige, I8) : 74 badges.
Noms provisoires, traduits EN/FR dans les ARB.

Colonne « Icône » : nom Phosphor (phosphoricons.com), vérifié le 2026-09-24 dans les polices du
dépôt (`assets/fonts/Phosphor.ttf` et `Phosphor-Fill.ttf`, version 2.1.1). Une série partage
son icône ; le palier donne l'anneau (voir « Présentation »). 57 icônes distinctes.

### A. Assiduité

| # | Badge | Condition | Icône (palier) |
|---|---|---|---|
| A1 | Premier départ | 1re session jouée | `flag-banner` |
| A2 | Habitué | 5 sessions | `calendar-check` (bronze) |
| A3 | Pilier | 10 sessions | `calendar-check` (argent) |
| A4 | Accro | 25 sessions | `calendar-check` (or) |
| A5 | Légende de la rue | 50 sessions | `calendar-check` (or ★) |
| A6 | Centurion | 100 sessions | `calendar-check` (or ★★) |
| A7 | Cinquante trous | 50 trous joués (toutes sessions) | `sneaker-move` (bronze) |
| A8 | Cent trous | 100 trous joués | `sneaker-move` (argent) |

### B. Fidélité et régularité

| # | Badge | Condition | Icône |
|---|---|---|---|
| B1 | Rendez-vous | Au moins 1 session 4 semaines de suite | `calendar-dots` |
| B2 | Métronome | Au moins 1 session 8 semaines de suite | `metronome` |
| B3 | Semaine chargée | 3 sessions dans la même semaine | `fire-simple` |
| B4 | Quatre saisons | Au moins 1 session en hiver, printemps, été et automne (années cumulées) | `leaf` |
| B5 | Vétéran | 1re session il y a plus d'un an, et au moins 1 session dans les 3 derniers mois | `hourglass-high` |
| B6 | Toute l'année | Au moins 1 session dans chacun des 12 mois (années cumulées) | `calendar-star` |

B5 est le seul badge qui dépend du jour où on regarde ; une fois obtenu, il reste acquis (Q111).

### C. Exploits de coups (sessions individuelles)

| # | Badge | Condition | Icône (palier) |
|---|---|---|---|
| C1 | Dans le par | 1er trou joué au par | `equals` |
| C2 | Petit oiseau | 1er birdie | `bird` (bronze) |
| C3 | Aigle | 1er eagle | `bird` (argent) |
| C4 | Albatros | 1er albatros | `bird` (or) |
| C5 | Trou en un | 1 coup sur un trou | `golf` |
| C6 | Volée d'oiseaux | 10 birdies cumulés | `feather` (bronze) |
| C7 | Nuée d'oiseaux | 50 birdies cumulés | `feather` (argent) |
| C8 | Série de pars | 3 trous de suite au par ou mieux dans une session | `stack` |
| C9 | Main chaude | 3 birdies de suite dans une session | `fire` |
| C10 | Sans faute | Session d'au moins 6 trous sans aucun bogey | `shield-check` |
| C11 | Sous le par | Session terminée avec un total sous le par cumulé | `trend-down` |
| C12 | Rebond | Birdie ou mieux juste après un trou à bogey + 2 ou pire | `arrow-u-up-left` |
| C13 | Régulier | Session d'au moins 6 trous où tous les scores sont dans ± 1 du par | `ruler` |

« De suite » (C8, C9, C12) : trous consécutifs de la session qui comptent pour les coups ; un
trou non saisi entre deux trous interrompt la série (Q117).

### D. Victoires et classement de session

| # | Badge | Condition | Icône (palier) |
|---|---|---|---|
| D1 | Première victoire | 1re victoire | `trophy` (bronze) |
| D2 | Gagneur | 5 victoires | `trophy` (argent) |
| D3 | Dominateur | 25 victoires | `trophy` (or) |
| D4 | Hat-trick | 3 victoires sur 3 sessions consécutives du joueur | `lightning` |
| D5 | Sur la boîte | 1er podium | `ranking` (bronze) |
| D6 | Abonné au podium | 10 podiums | `ranking` (argent) |
| D7 | De bout en bout | Victoire en étant 1er après chaque trou de la session | `flag-checkered` |
| D8 | Remontada | Victoire en étant dernier à la moitié de la session | `rocket-launch` |
| D9 | Photo-finish | Victoire avec 1 coup ou 1 point d'écart | `timer` |
| D10 | Hold-up | Strictement derrière le 1er avant le dernier trou, et 1er seul (sans ex æquo) à la fin de la session (Q113) | `vault` |
| D11 | Solo | 1re victoire en session individuelle | `person` |
| D12 | Collectif | 1re victoire en session par équipes | `users-three` |

### E. Championnat

| # | Badge | Condition | Icône (palier) |
|---|---|---|---|
| E1 | Compétiteur | 1re session de championnat | `flag-pennant` |
| E2 | Saison pleine | 5 sessions de championnat dans une même saison | `calendar-plus` |
| E3 | Champion | 1er du championnat d'une saison terminée | `medal` (or) |
| E4 | Podium de saison | Top 3 d'une saison terminée | `medal` (argent) |
| E5 | Top 5 | Top 5 d'une saison terminée | `medal` (bronze) |

### F. Jeu en équipe (méta-statistiques, Q107)

| # | Badge | Condition | Icône |
|---|---|---|---|
| F1 | Coéquipier | 1re session par équipes | `handshake` |
| F2 | Rassembleur | 5 équipiers différents | `users-four` |
| F3 | Duo de choc | 5 sessions avec le même équipier | `hand-fist` |

Équipier : un autre joueur de la même équipe dans une session par équipes.

### G. Explorateur

| # | Badge | Condition | Icône (palier) |
|---|---|---|---|
| G1 | Curieux | 5 trous différents du référentiel joués | `compass` (bronze) |
| G2 | Explorateur | 15 trous différents | `compass` (argent) |
| G3 | Globe-trotter | 3 sessions éloignées d'au moins 50 km les unes des autres | `globe-hemisphere-west` |
| G4 | Invité | 1 session créée par une autre association que la sienne | `suitcase-rolling` |
| G5 | Improvisateur | 10 trous libres joués (plan 17) | `magic-wand` |

G4 compare l'association de la session à l'association actuelle du joueur.

### H. Bâtisseur (contributions à l'app)

| # | Badge | Condition | Icône (palier) |
|---|---|---|---|
| H1 | Poseur de drapeau | 1er trou créé (hors clone, Q120) | `map-pin-plus` (bronze) |
| H2 | Paysagiste | 5 trous créés (hors clones, Q120) | `map-pin-plus` (argent) |
| H3 | Architecte | Un trou créé par le joueur, joué par 10 joueurs différents (lui compris) | `blueprint` |
| H4 | Organisateur | 1re session créée et terminée | `megaphone` (bronze) |
| H5 | Chef de partie | 10 sessions créées et terminées | `megaphone` (argent) |
| H6 | Reporter | 1re photo ajoutée à une session | `camera` (bronze) |
| H7 | Photographe | 10 photos ajoutées | `camera` (argent) |

Seuls les joueurs ayant un compte sont concernés ; trous, sessions et photos importés
compris (Q116). Tous les trous sont publics depuis le plan 26. Sessions éligibles (Q117) : H3
ne compte que les passages en session éligible, H4 et H5 que les sessions éligibles créées,
H6 et H7 que les photos de sessions éligibles ; H1 et H2 ne dépendent d'aucune session.

### I. Conditions de jeu (météo relevée au démarrage de la session)

| # | Badge | Condition | Icône |
|---|---|---|---|
| I1 | Sous la pluie | Session démarrée sous la pluie | `cloud-rain` |
| I2 | Givré | Session démarrée sous 3 °C | `thermometer-cold` |
| I3 | Canicule | Session démarrée au-dessus de 30 °C | `thermometer-hot` |
| I4 | Coup de vent | Session démarrée avec un vent au-dessus de 30 km/h | `wind` |
| I5 | Oiseau de nuit | Session démarrée à 21 h ou plus tard (Q125) | `moon-stars` |
| I6 | Lève-tôt | Session démarrée avant 9 h (Q125) | `sun-horizon` |
| I7 | Marathon | Session d'au moins 9 trous (Q112) | `person-simple-run` |
| I8 | Sous la neige | Session démarrée sous la neige, même légère (Q117) | `cloud-snow` |

### J. Records de trou (plan 20)

| # | Badge | Condition | Icône |
|---|---|---|---|
| J1 | Recordman | A détenu le record d'un trou | `star` |
| J2 | Collectionneur de records | A détenu 5 records en même temps | `magnet` |
| J3 | Roi du trou | A été « roi du trou » (meilleure moyenne) sur un trou | `crown` |

Calcul en rejouant chronologiquement tous les passages individuels des trous que le joueur a
joués ; un badge obtenu est gardé à vie (Q111).

### K. Badges humoristiques

| # | Badge | Condition | Icône |
|---|---|---|---|
| K1 | Lanterne rouge | 1re place de dernier d'une session | `lamp` |
| K2 | Réservé aux adultes | 1er « X » (10 coups ou plus) sur un trou | `x-circle` |
| K3 | Persévérant | 5 fois dernier d'une session terminée | `repeat` |
| K4 | Montagnes russes | Birdie ou mieux et « X » dans la même session | `mountains` |

## Présentation

- **Médaillon** (`NuniBadgeMedal`, nouveau composant de `lib/shared/`) : disque de la couleur de
  la famille, icône Phosphor au centre, anneau de palier pour les séries. Taille grille 64 px,
  détail 120 px.
- **Couleur de famille.** Une palette NUNI n'a que quatre couleurs d'accent (principale, vert
  fairway, accent, jaune soleil), pas onze. Les familles sont donc regroupées : vert pour A, B et
  I (assiduité, régularité, conditions de jeu) ; principale pour C et J (coups, records) ; jaune
  pour D et E (victoires, championnat) ; accent pour F, G, H et K (équipe, exploration,
  contributions, humour). Précision de Q114, qui suit la palette choisie par l'utilisateur.
- **Anneau de palier.** Bronze, argent, or dans l'ordre de difficulté de la série ; au-delà du
  3e palier, or plus une étoile par palier (A5, A6). Badge seul : pas d'anneau. Bronze, argent
  et or sont trois nouvelles couleurs fixes ajoutées à `lib/core/theme/palettes.dart` (seul
  fichier autorisé pour les couleurs), identiques dans toutes les palettes et vérifiées par le
  test de contraste.
- **Obtenu / à obtenir.** Obtenu : icône pleine (police `PhosphorFill`) en couleur. À obtenir :
  icône en contour (police `PhosphorRegular`) grise sur fond neutre ; pour un badge à compteur,
  une barre de progression et « 7 / 10 ». Les badges à obtenir ne s'affichent que sur sa propre
  fiche.
- **Donner envie (décision 17).** Sur sa propre fiche, les 74 badges sont toujours visibles,
  obtenus ou non, chacun avec sa condition : un joueur découvre ainsi Lève-tôt ou Sous la neige
  avant de les avoir. En fin de session, la feuille « Nouveaux badges » montre aussi jusqu'à
  3 badges proches, ceux dont la progression est la plus avancée (Q128, décision 19).
- **Fiche joueur** (`/players/:id`, plan 19), section « Badges » : compteur « 23 / 74 », puis une
  grille par famille (en-tête `NuniSectionHeader`). Sur la fiche d'un autre joueur, seuls les
  badges obtenus ; une famille sans badge obtenu est cachée. Badges masqués : mention
  « Badges privés ».
- **Détail** : un appui ouvre une feuille du bas avec le médaillon, le nom, la condition, et pour
  un badge obtenu sa date et la session d'obtention (lien vers `/history/:id` si on y a accès).
- **Galerie** : le médaillon est ajouté à `/dev/theme` dans tous ses états (obtenu, à obtenir,
  trois paliers, étoiles) pour le valider sur téléphone avant le branchement des données.

## Annonce d'un nouveau badge

- L'appareil retient les badges déjà vus (`shared_preferences`, clé par compte).
- **Fin de session** : quand une session passe à « terminée » sur l'écran de session, l'app
  recalcule les badges du joueur connecté et affiche une feuille « Nouveaux badges » s'il y en a.
- **Fiche** : les badges obtenus et pas encore vus portent une pastille « Nouveau » ; ouvrir la
  section les marque vus.
- **Première ouverture** (anciens joueurs, Q97) : tous les badges déjà obtenus sont annoncés en
  une seule feuille, pas un par un.
- Limite assumée : la mémoire est propre à l'appareil. Sur un nouveau téléphone ou après avoir
  vidé le navigateur, les badges sont annoncés une fois de plus. L'éviter demanderait une table,
  contraire au principe « aucun badge stocké ».

## Données et calcul

- **Historique du joueur** : la RPC du plan 19, qui renvoie chaque session jouée au format
  `session_snapshot` (équipes, trous joués avec par, scores de toutes les équipes, météo,
  association, championnat). Tous les badges des familles A à G, I et K en découlent. Lisible
  par tout compte connecté ; la fiche lit `badges_public` pour afficher ou non la section
  (Q133).
- **Contributions (famille H)** : nouvelle RPC `security definer`
  `player_contributions(p_player_id uuid)`, dans `supabase/migrations/…_rpc.sql` (règle 8 : fichier
  thématique existant). Elle renvoie, pour le compte lié au joueur, données importées comprises
  (Q116) : dates de création de ses trous (hors clones, Q120), nombre de joueurs différents par trou créé,
  dates de fin de ses sessions créées et terminées, dates de ses photos. Rien pour un joueur
  sans compte. Pas de filtre selon `badges_public` (Q133).
- **Records (famille J)** : la lecture des passages individuels par trou du plan 20, appelée en
  une fois pour tous les trous joués par le joueur.
- **Championnat (E3 à E5)** : `championship_association_results` existante, pour chaque couple
  association × saison terminée où le joueur a joué une session de championnat, puis
  `seasonStandings`.
- **Code** :
  - `lib/features/badges/domain/badge.dart` : énumérations `BadgeFamily` et `BadgeId` (famille,
    série, palier, seuil, icône) ; `BadgeResult` (obtenu, date, session, progression).
  - `lib/features/badges/domain/badge_facts.dart` : modèle d'entrée, construit une fois depuis les
    trois lectures ci-dessus (sessions jouées triées, coups du joueur, classements trou par trou,
    contributions, passages par trou).
  - `lib/features/badges/domain/rules/` : un fichier par famille (`attendance.dart`,
    `regularity.dart`, `strokes.dart`, `wins.dart`, `championship.dart`, `team.dart`,
    `explorer.dart`, `builder.dart`, `conditions.dart`, `records.dart`, `fun.dart`), fonctions
    pures `BadgeFacts → BadgeResult`, une par badge ou par série.
  - `lib/features/badges/data/badges_repository.dart` : les appels RPC.
  - `lib/features/badges/ui/` : section de la fiche, grille, détail, feuille « Nouveaux badges »,
    `seen_badges_store.dart`.
  - Riverpod : un fournisseur par joueur, mis en cache le temps de la visite de la fiche.
- **Volume.** Les classements trou par trou et les records demandent de rejouer tout
  l'historique : quelques centaines de sessions au plus aujourd'hui. Mesure à faire à
  l'implémentation sur les données réelles (seed) ; cible : section affichée en moins d'une
  seconde après la réponse de la base.

## Étapes (développement)

1. **Domaine et règles** : énumérations, `BadgeFacts`, les onze fichiers de règles, avec leurs
   tests (`test/features/badges/domain/`) : pour chaque badge un cas obtenu et un cas non
   obtenu, plus les cas limites des définitions (ex æquo, trou libre, mode « Libre », « X »,
   session à une équipe, météo absente, saison non terminée).
2. **Médaillon** : couleurs bronze, argent, or dans `palettes.dart` et test de contraste ;
   `NuniBadgeMedal` ; ajout à `/dev/theme`. **Point de validation visuelle par le PO** avant la
   suite.
3. **Données** : RPC `player_contributions` et son test dans `rls_smoke.sql` ;
   interrupteur « Badges publics » du profil (colonne créée par le plan 19) ;
   `badges_repository.dart`. Changement de schéma avant
   la mise en service des badges : reconstruction de la base distante selon la règle 8, **PO
   prévenu avant**, seeds régénérés puis rejoués.
4. **Écrans** : section « Badges » de la fiche joueur, grille, détail, progression.
5. **Annonce** : mémoire des badges vus, feuille « Nouveaux badges » en fin de session et à la
   première ouverture, pastille « Nouveau ».
6. **Chaînes EN/FR** : nom et condition de chaque badge (146 chaînes), familles, textes des
   écrans.
7. **Vérification** : `fvm dart format`, `fvm flutter analyze --fatal-infos`, `fvm flutter test`,
   puis essai dans le navigateur sur les données réelles (fiche d'un ancien joueur LSG, fin d'une
   session de test), puis test par le PO.

## Livrables

- `lib/features/badges/` (domaine, règles, données, écrans) et ses tests.
- `lib/shared/nuni_badge_medal.dart`, couleurs de palier dans `lib/core/theme/palettes.dart`,
  entrée dans `/dev/theme`.
- RPC `player_contributions` dans le fichier RPC existant.
- Chaînes dans `app_en.arb` et `app_fr.arb`.
- Ce plan, `QUESTIONS_PO.md` et `AGENTS.md` à jour.

## Critères d'acceptation

- Les 74 badges du catalogue existent, chacun couvert par un test « obtenu » et un test « pas
  obtenu ».
- Sur les données réelles, un ancien joueur LSG voit ses badges dès la première ouverture,
  annoncés en une seule feuille.
- Les badges d'un joueur sont identiques quel que soit l'appareil ou la personne qui les
  consulte (hors I5 et I6 si les appareils ne sont pas dans le même fuseau horaire, Q115).
- La fiche d'un autre joueur ne montre que ses badges obtenus ; badges masqués → « Badges
  privés » (masquage d'affichage, Q133).
- Ma fiche montre en plus les badges à obtenir, en gris, avec la progression pour les
  compteurs.
- Clore une session qui fait franchir un seuil affiche la feuille « Nouveaux badges » ; le même
  badge n'est plus annoncé ensuite sur cet appareil.
- Un record battu ne retire pas J1, J2 ni J3.
- Le médaillon suit la palette choisie, validé par le PO dans `/dev/theme`.
- Chaînes EN/FR, `flutter analyze` sans remarque, tests verts, build Vercel vert.

## Hors périmètre

- Classement ou comparaison des badges entre joueurs.
- Badges créés ou attribués à la main.
- Partage d'un badge en image (plan 24, modèle « Exploit »).
- Animations et vibrations à l'obtention (plan 25, Q105).

## Questions PO liées

Tranchées : Q92, Q94 (règle du record), Q96 (catalogue), Q97 (rétroactivité), Q98, Q106, Q108
(visibilité), Q111 (gardé à vie), Q112 (Marathon à 9 trous), Q113 (Hold-up), Q114
(présentation), Q115 (heure de l'appareil), Q116 (données importées comprises), Q120 (clones
hors H1 et H2), Q133 (masquage d'affichage seulement), Q117 (sessions éligibles et définitions de détail), Q123 (même règle pour
statistiques et records), Q124 (nombre de joueurs), Q125 (21 h et 9 h). Q127 (pas de contrôle plus
strict), Q128 (badges proches en fin de session). Liée, sur le championnat : Q126 (plan 26).
