# Plan 20 — Statistiques trou

## Statut

Fiche synthétique (2026-09-24), demandée par le PO. Priorité 1 avec le plan 19, après le plan 26.
Q93, Q94, Q95, Q109 et Q110 tranchées le 2026-09-24 ; Q123 tranchée le même jour. Q110 : plus
de trou privé (plan 26), toutes les statistiques de trou sont publiques.

**Plan détaillé rédigé et validé par le PO le 2026-09-24** (règle 1, AGENTS.md), avec une
demande : un découpage par saison, comme pour les statistiques joueur. Le plan 19 est clôturé
(`ddde5ae`) ; son socle `lib/features/stats/` est réutilisé tel quel. Q135 (statistiques d'un
clone) tranchée le même jour : suggestion retenue. Plus de question ouverte.

**Clôturé le 2026-09-24 : implémenté, testé et validé par le PO.** Fait : RPC `hole_history` et
fonction interne `stats_snapshot` (partagée avec `player_history`), domaine `hole_stats.dart` et
ses tests, section « Statistiques » de la fiche trou, histogramme, chaînes EN/FR ;
`flutter analyze --fatal-infos` sans remarque, 277 tests verts. Base distante reconstruite le
2026-09-24 avec l'accord du PO (seeds `71698a1`, comptages identiques après rejeu) ;
`rls_smoke.sql` : 50 tests verts. Chiffres de Radioactive recoupés par une requête SQL directe.
Précisions demandées par le PO après ses essais :
- Record à égalité : le plus récent le prend (Q94 révisée), pour qu'un coup de chance ne
  verrouille pas le titre.
- Roi à égalité de moyenne : le dernier à avoir joué le trou (Q93, précision).
- Icônes médaille (record) et couronne (roi) à côté des libellés.
- Ouverture sur la saison la plus récente jouée, sur la fiche trou comme sur la fiche joueur.

## En bref, pour les joueurs

- La fiche d'un trou (appui sur un trou dans la liste ou sur la carte) gagne une section
  « Statistiques », sous les boutons (la fiche défile).
- On y lit la difficulté réelle du trou : combien de fois il a été joué, la moyenne de coups
  (« ce par 3 se joue en 4,2 ») et l'écart moyen au par.
- Le **record** : le plus petit nombre de coups jamais réalisé, avec le pseudo, la photo et la
  date de son auteur. Égaler le record suffit à le prendre : le plus récent le détient (Q94
  révisée), pour qu'un coup de chance ne verrouille pas le titre pour toujours.
- Le **roi du trou** : le joueur qui a la meilleure moyenne sur ce trou, parmi ceux qui l'ont
  joué au moins 3 fois. À moyenne égale, le dernier à avoir joué le trou prend le titre.
- Un **histogramme** : combien de fois le trou a été fait en 2 coups, en 3, en 4…, la colonne
  du par mise en évidence.
- Mêmes règles que les statistiques joueur : seules comptent les sessions terminées d'au moins
  3 joueurs et 3 trous joués, et seulement les scores en session individuelle (en équipe, le
  score n'est pas celui d'un joueur). Les anciennes sessions LsgScores comptent.
- Les statistiques sont communes à tout le monde, quelle que soit l'association.
- Comme sur la fiche joueur, des pastilles « Toutes saisons » puis une par saison jouée
  (septembre à août) : chiffres, record, roi et histogramme de la saison choisie. La fiche
  s'ouvre sur la saison la plus récente jouée : records et rois sont remis en jeu chaque
  septembre.

## Objectif

Transformer la fiche d'un trou en petit défi : record à battre, difficulté réelle, « roi du trou ».

## Prérequis

Plan 06 (trous) et plan 26 (trous publics, par propre à une session) livrés ; plan 19 clôturé :
définition des sessions éligibles (`eligible_session.dart`), `computeStandings` inutile ici.

## Décisions retenues

| Sujet | Décision | Source |
|---|---|---|
| Sessions prises en compte | Éligibles seulement : terminées, ≥ 3 joueurs, ≥ 3 trous joués | Q117, Q123 |
| Scores pris en compte | Sessions individuelles, hors mode « Libre » (`countsStrokes`) | Q90, Q94 |
| Sessions importées | Comptent | Q92 |
| Record | Plus petit nombre de coups ; à égalité, le plus récent le prend | Q94 révisée |
| Roi du trou | Meilleure moyenne au par, à partir de 3 passages du joueur ; à égalité, le plus récent | Q93 révisée, PO 2026-09-24 |
| Seuil des autres chiffres | Aucun : affichés dès le premier passage ; le « X » compte | Q93 |
| Portée | Commune à toutes les associations | Q95 |
| Visibilité | Publique ; auteur du record et roi affichés même s'ils ont masqué leurs statistiques | Q109, Q110, Q133 |
| Par de référence | Celui du passage (`played_holes.par`), pas celui de la fiche | Plan 26 |
| Graphique | Histogramme en dessin maison, comme la courbe du plan 19 | Q134 |
| Clone d'un trou | Statistiques propres, qui repartent de zéro | Q135 |
| Saisons | « Toutes saisons », puis chaque saison où le trou a été joué ; ouverture sur la plus récente jouée | PO, 2026-09-24 |

## Définitions

- **Passage** : un score saisi pour un joueur sur ce trou, dans une session éligible
  individuelle hors « Libre ». Un trou joué deux fois dans la même session compte deux
  passages. Le « X » est un nombre de coups comme un autre (celui saisi) : il compte partout.
- **Écart au par d'un passage** : coups − par du passage.
- **Moyenne de coups** et **écart moyen au par** : sur tous les passages. Comme le par peut
  changer d'une session à l'autre (plan 26), l'écart moyen est la mesure qui fait foi ; la
  moyenne de coups est donnée pour parler concrètement.
- **Record** : passage au plus petit nombre de coups. Égalité : le plus récent (date de la
  session, puis ordre des trous dans la session) le prend ; dans un même passage (même trou
  joué, même session), l'ordre alphabétique départage, faute de savoir qui a fini le premier. Le record porte sur les coups,
  pas l'écart au par, pour rester lisible (« record : 2 coups »). Si les passages n'ont pas
  tous le même par, le record reste celui du plus petit nombre de coups (cas rare, corrigeable
  par l'organisateur, Q121).
- **Roi du trou** : joueur à la meilleure moyenne d'écart au par, parmi ceux qui ont au moins
  `minHolePassages` (3) passages. Égalité (décision PO du 2026-09-24,
  même esprit que le record) : le joueur dont le dernier passage sur le trou est le plus récent
  prend le titre, quel que soit son nombre de passages, pour inciter à jouer ; dans ce même
  dernier passage, l'ordre alphabétique départage.
- **Sessions** : nombre de sessions éligibles où le trou a été joué, **toutes sortes
  confondues** (individuelles, équipes, « Libre ») : c'est une mesure de popularité, pas de
  score. Les autres chiffres ne portent que sur les passages.

## Contenu de la section « Statistiques »

Dans `hole_detail_sheet.dart`, sous les boutons « Modifier », « Y aller » et « Cloner », qui
restent visibles à l'ouverture (même choix que le bloc du profil, plan 19) ; la fiche devient
défilante :

0. **Saisons** : pastilles « Toutes saisons » puis une par saison où le trou
   a été joué dans une session éligible, la plus récente d'abord (même composant et même règle
   que le plan 19 : affichées dès qu'une saison existe). À l'ouverture, la saison la plus récente jouée à l'ouverture (demande PO
  du 2026-09-24 : records et rois remis en jeu chaque septembre ; une saison qui n'a pas encore de
  session laisse la place à la précédente plutôt qu'à un bloc vide). Tout ce qui
   suit porte sur le choix (`displayedSeason`, commun aux deux fiches).

1. **Chiffres clés** (même présentation que le plan 19) : sessions, passages, moyenne de coups,
   écart moyen au par (`formatToPar`, ex. « +1,2 »).
2. **Record** : avatar, pseudo, nombre de coups, date. Appui : fiche publique du joueur.
3. **Roi du trou** : avatar, pseudo, moyenne au par, nombre de passages. Appui : fiche publique.
   Sans joueur à 3 passages : « Pas encore de roi : il faut 3 passages sur ce trou. »
4. **Répartition des scores** : une barre par nombre de coups, du plus petit au plus grand
   réalisé (colonnes vides comprises), hauteur = nombre de passages, effectif au-dessus de
   chaque barre, colonne du par du trou (celui de la fiche) mise en évidence.

États vides :
- Jamais joué dans une session éligible : « Ce trou n'a pas encore été joué dans une session
  qui compte (au moins 3 joueurs et 3 trous). »
- Joué seulement en équipe ou en « Libre » : chiffre « Sessions » affiché, puis « Pas encore de
  score individuel sur ce trou. »

Chargement : la section s'affiche à part (indicateur de chargement propre), la fiche du trou
n'attend pas les statistiques.

## Principes techniques

- **RPC `hole_history(p_hole_id uuid) returns jsonb`**, `security definer`, ouverte à
  `authenticated` seulement : les sessions terminées où le trou a été joué, au format
  `session_snapshot`, nettoyées comme `player_history` (sans commentaires, photo de couverture
  ni membres). La partie commune (nettoyage d'un instantané) devient une fonction SQL interne
  `stats_snapshot(p_session_id)` utilisée par les deux RPC, sans droit pour l'app. Le filtre
  d'éligibilité reste en Dart (une seule définition, `eligible_session.dart`).
  Raison du `security definer` : un trou est joué dans des sessions d'autres associations,
  que la RLS des sessions (plan 26) ne laisse pas lire ; les statistiques sont communes (Q95).
- **Domaine** `lib/features/stats/domain/hole_stats.dart` : `computeHoleStats(holeId,
  snapshots)` → `HoleStats` (sessions, passages, moyenne de coups, écart moyen, record,
  roi, répartition `Map<int, int>`), fonction pure testée unitairement, avec un paramètre
  `season` comme `computePlayerStats`, et `playedHoleSeasons(holeId, snapshots)`. Réutilise
  `isEligibleSession`, `countsStrokes`, `sessionDate`, `minHolePassages`, `compareNames`.
- **Données** : `StatsRepository.fetchHoleHistory` et le provider `holeHistory(holeId)`.
- **Interface** : `lib/features/stats/ui/hole_stats_section.dart` (section) et
  `score_histogram.dart` (barres en widgets simples, plus court qu'un `CustomPainter` pour des
  rectangles, couleurs de la palette par `colorScheme`). Les pastilles de saison et les chiffres
  clés deviennent des widgets communs aux deux fiches (`stats_widgets.dart`).
  Photos des joueurs : lues par le provider existant de la fiche joueur (`playerByIdProvider`),
  l'instantané ne portant que le pseudo.
- **Base** : ajout dans `20260915100600_rpc.sql` (règle 8, édition du fichier existant), donc
  **reconstruction du schéma distant** avec rejeu des seeds, comme au plan 19. Le PO est
  prévenu avant. `build/reset.sql` (non committé) gagne `drop function if exists hole_history`
  et `stats_snapshot`.
- **Tests d'accès** (`rls_smoke.sql`) : un compte connecté lit l'historique d'un trou joué dans
  une session d'une autre association ; le nettoyage est bien fait (pas de commentaire) ; un
  trou jamais joué renvoie une liste vide ; un visiteur non connecté est refusé.
- Performance : le calcul se fait à l'ouverture de la fiche ; un trou joué dans quelques
  dizaines de sessions reste instantané (le plan 19 calcule 7 sessions en 9 ms). Pas de cache
  en base tant que ce n'est pas mesuré comme nécessaire.

## Étapes (développement)

1. SQL : `stats_snapshot`, `player_history` réécrite dessus (même résultat), `hole_history`,
   droits ; tests `rls_smoke.sql`.
2. Domaine `hole_stats.dart` et ses tests (fixtures du plan 19 réutilisées) : éligibilité,
   sessions d'équipe comptées en sessions mais pas en passages, « Libre » exclu, par propre au
   passage, record à égalité (le plus récent le prend), roi à 3 passages et ses égalités (le plus récent l'emporte), trou joué
   deux fois dans une session, histogramme avec colonnes vides, filtre par saison.
3. Données : repository et provider.
4. Interface : section, histogramme, états vides, chaînes EN/FR.
5. Reconstruction de la base distante (PO prévenu), seeds rejoués, `rls_smoke.sql` vert.
6. Vérification dans le navigateur sur les trous réels (un trou très joué, un trou jamais joué),
   puis essai du PO.

## Livrables

- `supabase/migrations/20260915100600_rpc.sql`, `supabase/tests/rls_smoke.sql`.
- `lib/features/stats/domain/hole_stats.dart`, `data/stats_repository.dart`,
  `ui/hole_stats_section.dart`, `ui/score_histogram.dart`, `ui/stats_widgets.dart`.
- `lib/features/holes/ui/hole_detail_sheet.dart` (section ajoutée).
- `app_en.arb`, `app_fr.arb` ; tests `test/features/stats/domain/hole_stats_test.dart`.
- Ce plan, `QUESTIONS_PO.md`, `AGENTS.md` (mention de `hole_history`).

## Critères d'acceptation

- La fiche d'un trou joué dans une session éligible affiche ses chiffres clés, son record, son
  roi (ou l'explication du seuil) et l'histogramme ; un trou jamais joué affiche l'état vide.
- Les chiffres ne prennent que les passages individuels des sessions éligibles, avec le par de
  chaque passage ; les sessions d'équipe comptent seulement dans « Sessions ».
- Les pastilles de saison changent chiffres, record, roi et histogramme ; la saison la plus
  récente jouée est le choix à l'ouverture, sur la fiche trou comme sur la fiche joueur.
- Record : le plus petit nombre de coups, le plus récent à égalité ; son auteur et le roi
  sont affichés même s'ils ont masqué leurs statistiques, et mènent à leur fiche.
- Résultats cohérents avec l'historique réel (vérifiés sur un trou importé très joué).
- Un compte connecté de n'importe quelle association voit les mêmes statistiques.
- Chaînes EN/FR ; tests unitaires et `rls_smoke.sql` verts ; `flutter analyze --fatal-infos`
  sans remarque ; build Vercel vert.

## Hors périmètre

- Statistiques des trous libres (plan 17) : ils n'existent pas dans le référentiel.
- Classement complet des joueurs sur un trou, historique des records successifs : le badge
  « a détenu le record » (plan 21) calculera cet historique de son côté.
- Statistiques dans la liste ou sur la carte des trous (seulement dans la fiche).

## Questions PO liées

Q93, Q94, Q95, Q109, Q110, Q123, Q133, Q134 et Q135 (un clone a ses propres statistiques),
toutes tranchées.
