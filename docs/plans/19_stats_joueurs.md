# Plan 19 — Statistiques joueur

## Statut

Fiche synthétique (2026-09-24), demandée par le PO. Priorité 1 avec le plan 20. Q90 à Q93,
Q106 à Q108, Q117 et Q123 tranchées le 2026-09-24.

Mise à jour du 2026-09-24 : la fiche `/players/:id` (pseudo et photo seulement) et ses points
d'entrée sont livrés en avance par le plan 26 (volet C) ; ce plan y ajoute les statistiques.

**Plan détaillé rédigé et validé par le PO le 2026-09-24** (règle 1, AGENTS.md). Le PO a
choisi le même jour de faire 19 puis 20 avant les badges (21). Q133 (masquage = affichage
seulement) et Q134 (courbe de saison gardée après aperçu, dessin maison) tranchées le même
jour. Plus de question ouverte.

**Clôturé le 2026-09-24 : implémenté, testé et validé par le PO.** Fait : colonnes, RPC
`player_history`, tests d'accès ajoutés à `rls_smoke.sql`, domaine et ses tests, bloc
« Statistiques » (profil et fiche publique), découpage par saison, courbe, interrupteur, texte
de la page Confidentialité, chaînes EN/FR ; `flutter analyze --fatal-infos` sans remarque,
260 tests verts. Base distante reconstruite le 2026-09-24 avec l'accord du PO (seeds
`fd84f08`, comptages identiques après rejeu) ; `rls_smoke.sql` : 47 tests verts, après
correction d'un test du plan 26 qui lisait la session en brouillon (voir plus bas) ; calcul
vérifié sur l'historique réel du PO (7 sessions, calcul en 9 ms). Précisions décidées à
l'implémentation ou demandées par le PO après ses essais :
- Meilleur duo : il faut aussi au moins une victoire ensemble ; un duo sans victoire n'est le
  « meilleur » de rien.
- Demande du PO après son premier essai (2026-09-24) : les statistiques forment un bloc unique
  (`PlayerStatsSection`), affiché aussi sur mon propre profil (`/profile`, en bas, après le nom
  et son bouton « Enregistrer »), sans passer par ma fiche publique. Sur mon profil, le bloc
  porte l'interrupteur « Statistiques publiques » ; sur la fiche publique, il s'affiche si
  l'interrupteur l'autorise (toujours pour moi, avec le rappel « vous seul les voyez ici »).
- L'outil d'export lit toutes les colonnes de `players` (comme `played_holes` au plan 26) : il
  fonctionne sur la base avant comme après la reconstruction.
- `rls_smoke.sql`, test du plan 26 `association_member_reads_session` : il vérifiait qu'un
  membre de l'association lit une session encore en brouillon, ce que le plan 26 interdit
  volontairement (décision 19). Le script vérifie désormais que le brouillon reste caché
  (`association_member_cannot_read_draft`), démarre la session, puis vérifie la lecture.

## En bref, pour les joueurs

- La fiche de chaque joueur (appui sur son nom dans un classement, une équipe, l'historique)
  montre, sous son pseudo et sa photo, ses statistiques : sessions, victoires, podiums, trous
  joués, rapport au par, meilleur et pire trou, courbe de la saison et bilan en équipe.
- Seules comptent les vraies parties : sessions terminées d'au moins 3 joueurs et d'au moins
  3 trous joués. Un entraînement seul, un duel ou une session abandonnée ne comptent pas.
- Les coups ne comptent qu'en session individuelle : en équipe, le score est celui de
  l'équipe, pas du joueur. Les sessions par équipes comptent pour les sessions jouées, les
  victoires, les podiums et le bilan en équipe.
- Les anciennes sessions LsgScores comptent : les statistiques sont riches dès le premier jour.
- Chacun peut masquer ses statistiques depuis son profil (« Statistiques publiques »). Masquées,
  la fiche n'affiche plus que le pseudo, la photo et la mention « Statistiques privées » ; le
  joueur continue de voir les siennes. C'est un choix d'affichage : les sessions et leurs
  scores restent lisibles, comme aujourd'hui, et la page Confidentialité l'explique. Les
  classements de session et de championnat ne changent pas.

## Objectif

Donner à chaque joueur une fiche de statistiques qui donne envie de revenir entre deux sessions :
résultats, points forts et points faibles, progression sur la saison, jeu en équipe.

## Prérequis

Plans 08 et 10 (scores et historique), 13 (sessions importées de LsgScores), 15 (saison de
championnat), 26 (par de chaque trou joué, fiche `/players/:id`) livrés.

## Contrainte structurante

La base stocke **un score par équipe et par trou** (`scores.team_id`), jamais par joueur. Un
coup n'est attribuable à un joueur que si son équipe ne compte qu'un joueur. En session par
équipes, un joueur n'a que les résultats de son équipe (victoire, place).

## Décisions retenues

1. **Coups en session individuelle seulement (Q90).** Seules les sessions `kind = individual`
   donnent des coups ; un trou en mode `individual` dans une session par équipes ne compte pas.
2. **Mode « Libre » exclu des coups.** Conséquence technique : sa valeur saisie est un nombre
   de points, pas de coups (`score_calculator.dart`). Ses sessions comptent pour les sessions
   jouées, victoires et podiums.
3. **Fiche publique, statistiques masquables (Q91, Q106, Q108, Q133).** La fiche montre
   toujours pseudo et photo ; la section « Statistiques » est visible par défaut et masquable
   par l'interrupteur « Statistiques publiques » du profil. Le masquage ne porte que sur
   l'affichage (Q133) : l'historique reste lisible en base par tout compte connecté, puisque
   les sessions et scores dont il est fait le sont déjà et que chacun pourrait refaire les
   calculs. La page Confidentialité le dit. Deux colonnes `players.stats_public` et
   `players.badges_public`, vraies par défaut ; `badges_public` est créée dès ce plan pour ne
   reconstruire la base qu'une fois, son interrupteur n'apparaît qu'avec les badges (plan 21).
4. **Seuil (Q93, révisée le 2026-09-24).** Toute statistique s'affiche dès le premier trou
   joué, sauf le meilleur et le pire trou : seulement les trous joués au moins 3 fois par le
   joueur, pour qu'un passage isolé (un « X », un coup de chance) ne garde pas le titre
   longtemps.
5. **Sessions importées comprises (Q92)**, joueurs importés sans compte compris : leur fiche
   montre aussi leurs statistiques ; sans compte, ils ne peuvent pas les masquer.
6. **Sessions éligibles (Q117, Q123).** Terminées, d'au moins 3 joueurs et d'au moins 3 trous
   joués. Définition écrite une seule fois dans `lib/features/stats/domain/`, reprise par les
   plans 20 et 21.
7. **Méta-statistiques d'équipe (Q107).** Sessions, victoires et podiums en équipe, équipier le
   plus fréquent, meilleur duo (au moins 3 sessions communes).

## Définitions

Les mêmes que le plan 21 (« Définitions communes »), qui s'appuiera sur ce plan :

- **Session éligible** : `status = completed`, au moins 3 joueurs répartis dans ses équipes
  (`team_players`), au moins 3 trous joués (`played_holes`).
- **Session jouée** par un joueur : session éligible où il figure dans une équipe.
- **Trou joué** : trou d'une session jouée où l'équipe du joueur a un score saisi.
- **Victoire** : place 1 au classement final (`computeStandings`, le calcul de l'écran de
  session), ex æquo compris. **Podium** : places 1 à 3.
- **Date d'une session** : `started_at`, à défaut `created_at`.
- **Écart au par** d'un trou : coups − par du trou joué (`played_holes.par`, plan 26).
- **Saison** : de septembre à août, comme le championnat (`championship_season`), selon la
  date de la session.

## Contenu de la section « Statistiques »

**Période (demande PO du 2026-09-24)** : en tête du bloc, des pastilles « Toutes saisons » puis
chaque saison où le joueur a une session comptée, la plus récente d'abord. Toutes les parties
ci-dessous sont recalculées pour la période choisie. « Toutes saisons » par défaut. Les
pastilles s'affichent même quand le joueur n'a joué qu'une saison (cas de toutes les données
réelles au 2026-09-24, toutes en 2025-2026) : elles disent aussi de quelle saison viennent les
chiffres.

Sur la fiche `/players/:id`, sous le pseudo et la photo, dans cet ordre :

1. **Chiffres clés** : sessions jouées, victoires, podiums, trous joués (toutes sessions
   jouées, individuelles et par équipes). Quatre tuiles.
2. **Rapport au par** (sessions individuelles, hors « Libre ») : écart moyen au par par trou
   (« +0,8 par trou »), puis la répartition en trois parts : birdie ou mieux, par, bogey ou
   pire, en pourcentage. Précise « sur N trous ».
3. **Meilleur et pire trou** : parmi les trous du référentiel joués au moins 3 fois en
   session individuelle (Q93 révisée), celui dont l'écart moyen au par est le plus bas, et le
   plus haut, avec le nombre de passages. Aucun trou à 3 passages : « pas encore assez de
   passages sur un même trou ». Les trous libres n'y figurent pas : chacun est unique à sa session, sans fiche, il
   ne peut pas être « un trou où l'on est bon ». À égalité, le trou le plus joué, puis l'ordre
   alphabétique. Un seul trou joué : il est affiché comme meilleur, pas de pire.
4. **Courbe de progression** : un point par session individuelle (hors « Libre ») de la
   période choisie, dans l'ordre chronologique, à la hauteur de l'écart moyen au par de cette
   session ; une ligne pointillée marque le par. « Moyenne par session » de la fiche synthétique
   est lue comme l'écart moyen au par, et non la moyenne brute de coups, qui dépend surtout des
   pars des trous du jour. Aperçu validé par le PO le 2026-09-24 (Q134).
5. **En équipe** : sessions par équipes jouées, victoires et podiums en équipe ; équipier le
   plus fréquent (nom, nombre de sessions ensemble, lien vers sa fiche) ; meilleur duo :
   l'équipier avec le meilleur taux de victoire ensemble sur au moins 3 sessions communes et au
   moins une victoire (« 3 victoires sur 4 »), à égalité le plus de sessions communes, puis l'ordre alphabétique.
   Section cachée si le joueur n'a joué aucune session par équipes.

États :

- Aucune session jouée : « Aucune session comptée pour l'instant », suivi de la règle
  (« seules les sessions terminées d'au moins 3 joueurs et 3 trous comptent »).
- Des sessions, mais aucune individuelle : chiffres clés et bilan en équipe seulement, les
  parties 2 à 4 sont remplacées par « Pas encore de session individuelle ».
- Statistiques masquées, fiche d'un autre joueur : « Statistiques privées ».
- Ma propre fiche : toujours mes statistiques, avec un rappel discret si je les ai masquées
  (« Visible par vous seul »).

Profil (`/profile`) : le même bloc « Statistiques », précédé de l'interrupteur « Statistiques
publiques », activé par défaut, avec une phrase d'explication ; il enregistre aussitôt
(demande PO du 2026-09-24 : voir ses statistiques sans ouvrir sa fiche publique).

## Principes techniques

- **Calcul en Dart**, testé unitairement (règle du projet : la base ne stocke que les valeurs
  saisies). Nouveau module `lib/features/stats/`, partagé avec les plans 20 et 21.
- **Lecture par une RPC `security definer`** `player_history(p_player_id uuid)` dans
  `supabase/migrations/…_rpc.sql` (règle 8 : fichier thématique existant), sur le modèle de
  `championship_association_results` : la RLS ne montre une session qu'à ses participants et à
  son association, ce qui donnerait des statistiques différentes selon qui regarde. Elle renvoie
  toutes les sessions terminées où le joueur figure dans une équipe, au format de
  `session_snapshot` (le client réutilise `LiveSessionSnapshot` et `computeStandings`), sans ce
  que les calculs ne lisent pas : commentaires de session et de trou, photo de couverture, liste
  des comptes membres. Le filtre « session éligible » reste en Dart, écrit une seule fois.
- **Masquage à l'affichage seulement (Q133).** La RPC renvoie l'historique de n'importe quel
  joueur à tout compte connecté, quels que soient ses interrupteurs ; la fiche lit
  `stats_public` (colonne de `players`, déjà lisible par tous) pour afficher la section ou la
  mention « Statistiques privées ». Une seule lecture, la même pour les badges (plan 21).
- **Page Confidentialité** : la section « Qui voit ou reçoit vos données » ajoute que les
  statistiques et badges sont calculés à partir des sessions et scores, que les interrupteurs
  du profil les retirent de la fiche publique mais que ces sessions et scores restent lisibles
  par les utilisateurs connectés ; date de mise à jour changée.
- **Schéma** : colonnes `players.stats_public` et `players.badges_public`
  (`boolean not null default true`) dans `…_tables.sql`. Modifiables par le joueur lui-même
  (politique `players_update_self` existante). L'outil `tool/export_remote_seed.dart` les
  exporte, pour qu'un choix « privé » survive à la prochaine reconstruction.
- **Courbe** : dessinée avec un `CustomPainter` aux couleurs du thème, sans nouvelle
  dépendance (Q134) ; le même dessin maison servira à l'histogramme du plan 20.
- **Code** :
  - `lib/features/stats/domain/eligible_session.dart` : `isEligibleSession`, `playedBy`,
    `sessionDate` (définitions communes aux plans 19 à 21).
  - `lib/features/stats/domain/player_stats.dart` : `PlayerStats computePlayerStats(playerId,
    snapshots)` et ses sous-modèles (chiffres clés, rapport au par, trous, saison, équipe).
  - `lib/features/stats/data/stats_repository.dart` : appel de `player_history`.
  - `lib/features/stats/ui/player_stats_section.dart`, `season_chart.dart`.
  - `lib/features/players/ui/player_page.dart` : ajoute la section.
  - `lib/features/profile/` : champ `statsPublic` du modèle `Player`, interrupteur.
  - Riverpod : `playerStatsProvider(playerId)`, recalculé à chaque visite de la fiche.
- **Volume** : quelques dizaines de sessions par joueur aujourd'hui, au plus quelques centaines
  à terme ; calcul en mémoire, sans pagination. Mesure sur les données réelles à
  l'implémentation.

## Étapes (développement)

1. **Domaine** : `eligible_session.dart`, `player_stats.dart` et leurs tests
   (`test/features/stats/domain/`) : session non terminée, 2 joueurs, 2 trous, session par
   équipes (pas de coups), mode « Libre » (pas de coups), trou libre (rapport au par oui,
   meilleur trou non), ex æquo à la 1re place, trou sans score saisi, joueur importé, égalités
   du meilleur trou et du meilleur duo, saison à cheval sur septembre.
2. **Schéma et RPC** : colonnes, `player_history`, test dans `supabase/tests/rls_smoke.sql`
   (un compte d'une autre association lit l'historique d'un joueur ; seules les sessions
   terminées où il figure sont renvoyées ; un joueur ne peut modifier que ses propres
   interrupteurs), export des colonnes dans l'outil de seed.
3. **Écrans** : section « Statistiques » de la fiche, courbe, états vides et privés,
   interrupteur du profil, texte de la page Confidentialité.
4. **Chaînes EN/FR** dans les ARB.
5. **Mise en service** : reconstruction de la base distante selon la règle 8, **PO prévenu
   avant**, seeds régénérés, committés avec son accord, puis rejoués.
6. **Vérification** : `fvm dart format`, `fvm flutter analyze --fatal-infos`,
   `fvm flutter test`, essai dans le navigateur sur les données réelles (fiche d'un ancien
   joueur LSG, fiche d'un joueur importé sans compte, interrupteur), puis test par le PO.

## Livrables

- `lib/features/stats/` (domaine, données, écrans) et ses tests.
- Colonnes `stats_public`, `badges_public` ; RPC `player_history` ; son test dans
  `rls_smoke.sql`.
- Section de la fiche joueur, interrupteur du profil, chaînes EN/FR.
- Ce plan, `QUESTIONS_PO.md`, `00_plan_ensemble.md` et `AGENTS.md` à jour.

## Critères d'acceptation

- Les chiffres d'un joueur sont identiques quel que soit l'appareil ou la personne qui les
  consulte.
- Une session de 2 joueurs, de 2 trous, ou non terminée ne change aucun chiffre.
- Une session par équipes compte pour les chiffres clés et le bilan en équipe, jamais pour le
  rapport au par, les trous ni la courbe.
- La fiche d'un joueur est toujours accessible (pseudo et photo) ; quand il a masqué ses
  statistiques, sa fiche affiche « Statistiques privées » à tout autre compte, et ses propres
  statistiques à lui-même.
- La page Confidentialité explique, en EN et FR, que le masquage porte sur la fiche et non sur
  les sessions et scores.
- Un choix « privé » survit à une reconstruction de la base (seed).
- Chaque calcul est couvert par un test unitaire, y compris trous libres et sessions par
  équipes.
- Chaînes EN/FR, `flutter analyze` sans remarque, tests verts, build Vercel vert.

## Hors périmètre

- Statistiques d'un trou (plan 20) et badges (plan 21).
- Comparaison entre joueurs, classements de statistiques.
- Statistiques d'un joueur restreintes à une association ou une saison autre que la courbe.
- Graphique interactif (zoom, survol) : la courbe est un dessin fixe.

## Questions PO liées

Tranchées : Q90 à Q93, Q106 à Q108, Q117, Q123, Q133, Q134. Aucune ouverte.
