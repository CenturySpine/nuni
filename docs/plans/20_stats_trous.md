# Plan 20 — Statistiques trou

## Statut

Fiche synthétique (2026-09-24), demandée par le PO. Priorité 1 avec le plan 19. Q93, Q95 et Q109
tranchées le 2026-09-24 ; plan détaillé à rédiger après réponse à Q94 et Q110.

## Objectif

Transformer la fiche d'un trou en petit défi : record, difficulté réelle, « roi du trou ».

## Prérequis

Plan 06 (trous) livré ; socle de calcul `lib/features/stats/` du plan 19.

## Contenu envisagé (hypothèse)

- Nombre de passages, moyenne de coups, écart moyen au par (« ce par 3 se joue en 4,2 »).
- Record du trou (meilleur score individuel) avec son auteur et sa date, et le « roi du trou »
  (meilleure moyenne, dès un passage, Q93).
- Répartition des scores (histogramme simple).
- Affichage dans la fiche trou existante (`hole_detail_sheet.dart`), section « Statistiques ».
- Les trous libres (plan 17) n'ont pas de statistiques : ils n'existent pas dans le référentiel.

## Principes techniques

- Même socle et même RPC de lecture que le plan 19, filtrée par trou.
- Statistiques et record communs à tous les joueurs, sans distinction d'association (Q95).
- Mode de scoring « Libre » exclu : sa valeur saisie est un nombre de points, pas de coups
  (`score_calculator.dart`).
- Un record n'a de sens que sur un score individuel : seuls comptent les passages en session
  individuelle (Q90, tranchée), sessions importées comprises (Q92).
- Auteur d'un record : pseudo et photo toujours affichés, même s'il a masqué ses statistiques
  (Q109, tranchée).

## Questions PO liées

Q94 (quels passages comptent pour un record), Q110 (statistiques d'un trou privé), Q93, Q95
et Q109 (tranchées).

## Critères d'acceptation (esquisse)

- La fiche d'un trou joué au moins une fois affiche ses statistiques ; un trou jamais joué
  affiche un état vide explicite.
- Record et « roi du trou » cohérents avec l'historique (vérifiés sur des sessions importées).
- Chaînes EN/FR, tests unitaires des calculs.
