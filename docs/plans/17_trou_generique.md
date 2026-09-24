# Plan 17 — Trou générique (« Trou libre »)

> **Mise à jour du 2026-09-24 (plan 26, décision 5)** : un trou libre exige désormais un par à
> l'ajout, sans valeur préréglée ; ceux joués avant ont reçu 3 (Q122). Remplace « ni par ni
> distance » de Q57.

## Statut

Demande PO du 2026-09-23, décisions Q56 à Q59 retenues le même jour. Plan détaillé rédigé le
2026-09-23, validé par le PO le même jour ; implémenté, base distante reconstruite et testé par le PO
le 2026-09-23. Livré avec l'étape 1 du plan 13 (import des trous) pour
ne reconstruire la base distante qu'une fois (Q59).

## Objectif

Pouvoir ajouter à tout moment, dans une session en direct, un trou « one shot » (trou de test,
partie rapide) sans le créer dans le référentiel des trous. Ce trou n'a pas de position GPS.

## Prérequis

Plans 06 (trous) et 08 (session en direct) livrés.

## Décisions retenues

- Q56 : pas de ligne spéciale dans `holes`. Un trou générique est un trou joué dont
  `played_holes.hole_id` est vide. Son nom vient des traductions : « Trou libre » / « Free hole ».
- Q57 : libellé facultatif saisi à l'ajout (`played_holes.label`). Vide, l'app affiche « Trou
  libre » après le numéro du trou dans la session, déjà présent dans le titre de chaque trou joué
  (« Trou 3 · Trou libre ») : plusieurs trous libres sans libellé restent distincts. Ni par ni
  distance.
- Q58 : une session contenant des trous génériques compte pour le championnat, sans règle
  particulière. Un trou générique n'entre pas dans le centre géométrique d'une session importée.
- Q59 : plan séparé, livré en même temps que l'étape 1 du plan 13.

## Étapes

1. Schéma (`..._tables.sql`) : `played_holes.hole_id` devient facultatif ; nouvelle colonne
   `label text`, renseignée seulement pour un trou générique (la RPC ci-dessous s'en charge).
2. RPC `add_played_hole` : `p_hole_id` accepte `null`, nouveau paramètre `p_label text default
   null` (enregistré seulement si `p_hole_id` est `null`, libellé vide ramené à `null`).
3. RPC `session_snapshot` : jointure `left join holes` ; `hole` vaut `null` pour un trou
   générique ; ajout de `label` dans chaque trou joué. `history_snapshots` en hérite.
4. Modèle `PlayedHole` : `hole` facultatif, `label` facultatif ; fonction `playedHoleName(l10n, …)`
   utilisée par la carte de trou joué (les exports PDF et image n'affichent pas le nom des trous).
5. Écran « Ajouter un trou » : une entrée « Trou libre » toujours en tête de liste, quels que
   soient le mode (autour de moi / mes trous), la position et le rayon. Elle ouvre le même choix
   de mode de jeu qu'un trou normal, plus un champ « Libellé (facultatif) ».
6. Carte de trou joué : pas de par ni d'icône « privé » pour un trou générique.
7. Chaînes EN/FR : « Trou libre », « Libellé (facultatif) », aide courte.
8. Tests : `PlayedHole.fromJson` avec `hole: null` et `label`, `playedHoleName` (avec et sans
   libellé), sélecteur montrant « Trou libre » en tête sans position.

## Livrables

Migrations modifiées (`tables`, `rpc`), modèle et écrans ci-dessus, chaînes ARB, tests.

## Critères d'acceptation

- Dans une session en direct, « Trou libre » est proposé même sans géolocalisation et sans aucun
  trou à proximité.
- Deux trous génériques, l'un avec libellé et l'autre sans, s'affichent distinctement dans la
  session, l'historique et les exports.
- Les scores d'un trou générique comptent dans le classement comme ceux d'un trou normal.
- `flutter analyze` sans remarque, tests verts, chaînes EN/FR.

## Questions PO liées

Q56, Q57, Q58, Q59 (toutes tranchées le 2026-09-23).
