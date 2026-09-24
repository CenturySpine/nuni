# Plan 21 — Badges

## Statut

Fiche synthétique (2026-09-24), demandée par le PO pour lundi 2026-09-28. Catalogue trié par
le PO le 2026-09-24 (Q96) ; Q97, Q98, Q111, Q112, Q113 et Q114 tranchées le même jour. Plan détaillé à
rédiger. Dépend du socle de calcul des plans 19 et 20 : à implémenter juste après eux.

## Objectif

Récompenser des exploits et la régularité pour donner une raison de rejouer et de partager.

## Prérequis

Socle `lib/features/stats/` (plans 19 et 20).

## Catalogue retenu (Q96)

Tri du PO (2026-09-24) sur le catalogue exhaustif de 78 badges : 6 badges supprimés, 1 ajouté,
plusieurs seuils abaissés ; **73 badges** retenus (tout badge non marqué « X » est accepté). Les noms sont provisoires et seront traduits
EN/FR dans les ARB. Décisions du tri :
- Supprimés : 500 et 1 000 trous joués (ex-A9, A10), Polyvalent (ex-D10), 25 équipiers
  différents (ex-F3), Toutes les formules (ex-F5), Cartographe, 50 trous différents (ex-G3).
- Ajouté : Hold-up (D10), victoire arrachée au dernier trou.
- Seuils abaissés : Saison pleine 10 → 5 sessions de championnat (une saison LSG n'en compte
  que 9) ; Top 10 → Top 5 de saison (peu d'associations ont 10 joueurs réguliers) ; Rassembleur
  10 → 5 équipiers ; Duo de choc 10 → 5 sessions ; Curieux 10 → 5 trous ; Explorateur 25 → 15
  trous ; Paysagiste 10 → 5 trous publics ; Photographe 25 → 10 photos ; Marathon 18 → 9 trous
  (Q112 : une session de 9 trous est déjà exceptionnelle).
- Renommé : Carton plein → « Réservé aux adultes » (clin d'œil au « X »).
- Numérotation refaite dans chaque famille après ces changements.

Vocabulaire : par = nombre de coups prévu du trou ; birdie = par − 1 ; eagle = par − 2 ;
albatros = par − 3 ; bogey = par + 1 ; « X » = 10 coups (valeur maximale saisie).

Règles communes, conséquences de décisions déjà prises :
- **Coups** (familles C et J) : seulement les sessions individuelles (Q90), hors mode de
  scoring « Libre » (sa valeur saisie est un nombre de points, pas de coups), hors trous libres
  (pas de par, plan 17).
- **Victoire** = 1re place au classement final d'une session terminée ; en cas d'égalité, tous
  les ex æquo gagnent. **Podium** = places 1 à 3.
- Sessions importées de LsgScores comprises (Q92, Q97).

### A. Assiduité

| # | Badge | Condition |
|---|---|---|
| A1 | Premier départ | 1re session terminée |
| A2 | Habitué | 5 sessions |
| A3 | Pilier | 10 sessions |
| A4 | Accro | 25 sessions |
| A5 | Légende de la rue | 50 sessions |
| A6 | Centurion | 100 sessions |
| A7 | Cinquante trous | 50 trous joués (toutes sessions) |
| A8 | Cent trous | 100 trous joués |

### B. Fidélité et régularité

| # | Badge | Condition |
|---|---|---|
| B1 | Rendez-vous | Au moins 1 session 4 semaines de suite |
| B2 | Métronome | Au moins 1 session 8 semaines de suite |
| B3 | Semaine chargée | 3 sessions dans la même semaine |
| B4 | Quatre saisons | Au moins 1 session en hiver, printemps, été et automne |
| B5 | Vétéran | 1re session il y a plus d'un an, et au moins 1 session dans les 3 derniers mois |
| B6 | Toute l'année | Au moins 1 session dans chacun des 12 mois (années cumulées) |

### C. Exploits de coups (sessions individuelles)

| # | Badge | Condition |
|---|---|---|
| C1 | Dans le par | 1er trou joué au par |
| C2 | Petit oiseau | 1er birdie |
| C3 | Aigle | 1er eagle |
| C4 | Albatros | 1er albatros |
| C5 | Trou en un | 1 coup sur un trou |
| C6 | Volée d'oiseaux | 10 birdies cumulés |
| C7 | Nuée d'oiseaux | 50 birdies cumulés |
| C8 | Série de pars | 3 trous de suite au par ou mieux dans une session |
| C9 | Main chaude | 3 birdies de suite dans une session |
| C10 | Sans faute | Session d'au moins 6 trous sans aucun bogey |
| C11 | Sous le par | Session terminée avec un total sous le par cumulé |
| C12 | Rebond | Birdie ou mieux juste après un trou à bogey + 2 ou pire |
| C13 | Régulier | Session d'au moins 6 trous où tous les scores sont dans ± 1 du par |

### D. Victoires et classement de session

| # | Badge | Condition |
|---|---|---|
| D1 | Première victoire | 1re victoire |
| D2 | Gagneur | 5 victoires |
| D3 | Dominateur | 25 victoires |
| D4 | Hat-trick | 3 victoires sur 3 sessions consécutives du joueur |
| D5 | Sur la boîte | 1er podium |
| D6 | Abonné au podium | 10 podiums |
| D7 | De bout en bout | Victoire en étant 1er après chaque trou de la session |
| D8 | Remontada | Victoire en étant dernier à la moitié de la session |
| D9 | Photo-finish | Victoire avec 1 coup ou 1 point d'écart |
| D10 | Hold-up | Strictement derrière le 1er avant le dernier trou, et 1er seul (sans ex æquo) à la fin de la session (Q113) |
| D11 | Solo | 1re victoire en session individuelle |
| D12 | Collectif | 1re victoire en session par équipes |

### E. Championnat

| # | Badge | Condition |
|---|---|---|
| E1 | Compétiteur | 1re session de championnat |
| E2 | Saison pleine | 5 sessions de championnat dans une même saison |
| E3 | Champion | 1er du championnat d'une saison terminée (après le 31 août) |
| E4 | Podium de saison | Top 3 d'une saison terminée |
| E5 | Top 5 | Top 5 d'une saison terminée |

### F. Jeu en équipe (méta-statistiques, Q107)

| # | Badge | Condition |
|---|---|---|
| F1 | Coéquipier | 1re session par équipes |
| F2 | Rassembleur | 5 équipiers différents |
| F3 | Duo de choc | 5 sessions avec le même équipier |

### G. Explorateur

| # | Badge | Condition |
|---|---|---|
| G1 | Curieux | 5 trous différents du référentiel joués |
| G2 | Explorateur | 15 trous différents |
| G3 | Globe-trotter | Sessions dans 3 villes différentes |
| G4 | Invité | 1 session créée par une autre association que la sienne |
| G5 | Improvisateur | 10 trous libres joués (plan 17) |

### H. Bâtisseur (contributions à l'app)

| # | Badge | Condition |
|---|---|---|
| H1 | Poseur de drapeau | 1er trou public créé |
| H2 | Paysagiste | 5 trous publics créés |
| H3 | Architecte | Un trou créé par le joueur, joué par 10 joueurs différents |
| H4 | Organisateur | 1re session créée et terminée |
| H5 | Chef de partie | 10 sessions créées et terminées |
| H6 | Reporter | 1re photo ajoutée à une session |
| H7 | Photographe | 10 photos ajoutées |

H1 à H7 ne concernent que les joueurs ayant un compte : les joueurs importés sans compte n'ont
jamais créé de trou, de session ou de photo dans NUNI.

### I. Conditions de jeu (météo relevée au démarrage de la session)

| # | Badge | Condition |
|---|---|---|
| I1 | Sous la pluie | Session démarrée sous la pluie (code météo « pluie » ou « averses ») |
| I2 | Givré | Session démarrée sous 3 °C |
| I3 | Canicule | Session démarrée au-dessus de 30 °C |
| I4 | Coup de vent | Session démarrée avec un vent au-dessus de 30 km/h |
| I5 | Oiseau de nuit | Session démarrée après 21 h |
| I6 | Lève-tôt | Session démarrée avant 8 h |
| I7 | Marathon | Session d'au moins 9 trous (Q112) |

Les sessions importées de LsgScores ont une météo seulement si l'ancienne app l'avait relevée ;
sinon elles ne comptent pas pour I1 à I4.

### J. Records de trou (plan 20)

| # | Badge | Condition |
|---|---|---|
| J1 | Recordman | A détenu le record d'un trou |
| J2 | Collectionneur de records | A détenu 5 records en même temps |
| J3 | Roi du trou | A été « roi du trou » (meilleure moyenne) sur un trou |

J1 à J3 dépendent d'un état qui peut changer (un record battu) : une fois obtenus, ils sont gardés
à vie, même si le record est battu ensuite (Q111).

### K. Badges humoristiques

| # | Badge | Condition |
|---|---|---|
| K1 | Lanterne rouge | 1re place de dernier d'une session |
| K2 | Réservé aux adultes | 1er « X » (10 coups) sur un trou |
| K3 | Persévérant | 5 fois dernier d'une session terminée |
| K4 | Montagnes russes | Birdie et « X » dans la même session |

## Principes techniques

- Badges **calculés à la volée** en Dart à partir de l'historique, testés unitairement : aucune
  table, ils s'appliquent donc rétroactivement aux sessions passées et importées.
- Catalogue = énumération dans le code (comme les modes de scoring), pas de table de référence.
- Emplacement des règles : `lib/features/badges/domain/`. Une énumération porte le catalogue
  (famille, seuil, palier, icône) ; chaque badge ou série à paliers a une fonction pure qui
  reçoit l'historique du joueur (fourni par la RPC de lecture du plan 19) et renvoie « obtenu
  ou non », la date et la session d'obtention, et la progression. Les classements (victoire,
  rang après chaque trou) réutilisent `lib/features/live/domain/score_calculator.dart` et
  `team_standing.dart`, pour que « 1er » veuille dire la même chose dans une session en direct
  et dans un badge. Changer un seuil = modifier le code et redéployer.
- Badges d'état (famille J) calculés en rejouant l'historique dans l'ordre chronologique, pour
  savoir si le joueur a détenu le record à un moment donné ; un badge obtenu n'est jamais
  retiré (Q111).
- « Nouveau badge ! » : les badges déjà vus sont retenus sur l'appareil
  (`shared_preferences`) ; un badge obtenu est annoncé à la fin d'une session et sur le profil.

## Questions PO liées

Q96 (catalogue, tranchée par le tri du PO), Q111 (badge d'état gardé à vie), Q112 (Marathon à
9 trous), Q113 (Hold-up : strictement derrière puis 1er seul), Q114 (médaillon, icône Phosphor, anneau
de palier), Q97 (rétroactivité), Q98 (visibilité par les autres joueurs : tranchée
avec Q106, visibles par défaut sur la fiche, masquables par l'interrupteur « Badges publics »
indépendant des statistiques, Q108). Q92 tranchée : les sessions importées comptent, les badges sont donc
rétroactifs sur l'historique LsgScores.

## Critères d'acceptation (esquisse)

- La fiche joueur (`/players/:id`, plan 19) affiche ses badges obtenus s'il les laisse visibles
  (par défaut, Q106) ; sur ma propre fiche, je vois aussi, grisés, ceux qui restent à obtenir.
- Chaque badge est couvert par un test (obtenu / pas obtenu).
- Chaînes EN/FR.
