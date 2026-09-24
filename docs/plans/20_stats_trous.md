# Plan 20 — Statistiques trou

## Statut

Fiche synthétique (2026-09-24), demandée par le PO. Priorité 1 avec le plan 19, après le plan 26.
Q93, Q94, Q95, Q109 et Q110 tranchées le 2026-09-24 ; Q123 tranchée le même jour : plan
détaillé à rédiger. Q110 : plus de trou privé (plan 26), toutes les statistiques de trou sont publiques.

## Objectif

Transformer la fiche d'un trou en petit défi : record, difficulté réelle, « roi du trou ».

## Prérequis

Plan 06 (trous) livré ; socle de calcul `lib/features/stats/` du plan 19.

## Contenu envisagé (hypothèse)

- Nombre de passages, moyenne de coups, écart moyen au par (« ce par 3 se joue en 4,2 »).
- Record du trou (meilleur score individuel) avec son auteur et sa date, et le « roi du trou »
  (meilleure moyenne, parmi les joueurs qui ont au moins 3 passages sur le trou : Q93 révisée
  le 2026-09-24, même seuil que le meilleur et le pire trou du plan 19).
- Répartition des scores (histogramme simple : passages par nombre de coups), confirmée par le
  PO le 2026-09-24 après aperçu (Q134), dessin maison comme la courbe du plan 19.
- Affichage dans la fiche trou existante (`hole_detail_sheet.dart`), section « Statistiques ».
- Les trous libres (plan 17) n'ont pas de statistiques : ils n'existent pas dans le référentiel.

## Principes techniques

- Même socle et même RPC de lecture que le plan 19, filtrée par trou.
- Statistiques et record communs à tous les joueurs, sans distinction d'association (Q95).
- Écart au par calculé avec le par de chaque passage (`played_holes.par`, plan 26), qui peut
  différer du par officiel du trou.
- Mode de scoring « Libre » exclu : sa valeur saisie est un nombre de points, pas de coups
  (`score_calculator.dart`).
- Statistiques, record et « roi du trou » : seulement les sessions éligibles, d'au moins
  3 joueurs et 3 trous joués, comme les statistiques joueur et les badges (Q117, Q123). Limite
  les saisies non contrôlées, faites seul.
- Un record n'a de sens que sur un score individuel : seuls comptent les passages en session
  individuelle (Q90, tranchée), sessions importées comprises (Q92).
- Auteur d'un record : pseudo et photo toujours affichés, même s'il a masqué ses statistiques
  (Q109, tranchée).

## Questions PO liées

Q93, Q94 (seuls les scores individuels comptent pour un record ; à égalité, le premier le
garde), Q95, Q109 et Q110 (plus de trou privé, plan 26), et Q123 (sessions éligibles
seulement), toutes tranchées.

## Critères d'acceptation (esquisse)

- La fiche d'un trou joué au moins une fois affiche ses statistiques ; un trou jamais joué
  affiche un état vide explicite.
- Record et « roi du trou » cohérents avec l'historique (vérifiés sur des sessions importées).
- Chaînes EN/FR, tests unitaires des calculs.
