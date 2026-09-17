# Plan 10 — Historique, photos, exports

## Objectif

Conserver et consulter les sessions terminées, y attacher des photos, exporter un PDF et une image
partageable, corriger les horaires.

## Prérequis

Plan 08.

## Décisions retenues

- Historique `/history` : mes sessions terminées (créées ou rejointes), triées par date, carte
  avec ville · zone, date et heure, durée, mode de scoring, météo, vignette de couverture,
  podium résumé. Filtre simple par ville.
- Détail `/history/:id` : mêmes composants que la session en direct (en-tête, classement,
  trous joués) en lecture seule, plus la galerie et les actions.
- Photos : bucket `session-photos`, table `session_photos`, upload multiple (compression client
  comme au plan 06), galerie avec plein écran par balayage, photo de couverture (`cover_photo_id`),
  suppression. Ajout et suppression réservés au créateur de la session, comme le posent déjà les
  policies RLS existantes (Q37) — aucune migration à modifier sur ce point. Suppression du fichier
  dans le bucket faite côté client au moment de la suppression de la photo (Q37), sans Edge
  Function.
- Édition (créateur) : date, heure de début, heure de fin (validation : pas dans le futur, fin
  après début) ; un changement de la date ou de l'heure de **début** seulement (PO, 2026-09-17)
  recalcule la météo via Open‑Meteo historique (archive) avec la position de la session si connue
  — la météo capturée au démarrage (plan 07, corrigé) devient fausse si cette date/heure est
  corrigée après coup ; l'heure de fin seule n'a pas d'effet sur la météo. Commentaire libre de
  session (existait en base dans l'ancienne app sans
  jamais être saisi ; ici un champ réel).
- Export PDF : paquet `pdf` (génération pure Dart) + `printing` (téléchargement / partage sur le
  web) ; contenu : en-tête (ville, zone, date, heures, durée, type, mode, météo, commentaire),
  tableau équipes × trous (nom du trou, mode de jeu, coups et points, totaux), classement, photo
  de couverture, pied "NUNI — Never Up, Never In". Coups masqués en Stroke Play comme avant.
- Export image (H Q16) : un widget "carte de résultats" (classement, ville, date, météo, logo)
  rendu en PNG via `RepaintBoundary`, partagé avec `share_plus` (Web Share avec fichier sur mobile,
  téléchargement sur desktop). Variante "sur photo" : même widget superposé à une photo choisie.
  Beaucoup plus simple et fidèle au thème que le dessin sur canvas de l'ancienne app.
- Suppression d'une session terminée (créateur) avec confirmation forte, cascade base + purge
  des photos du bucket faite côté client avant la suppression de la session (Q37).

## Étapes

1. Paquets : `pdf`, `printing`, `share_plus` (déjà), `image` (déjà).
2. `features/history/` : liste, détail, édition, galerie.
3. `features/exports/` : modèle d'export (calcul partagé avec le live), générateur PDF, widget
   carte de résultats, service de partage/téléchargement multiplateforme.
4. Tests : générateur PDF (golden léger sur le contenu textuel), règles de validation des
   horaires, modèle d'export.

## Livrables

- Historique, galerie, exports, édition.

## Critères d'acceptation

- Un PDF d'une session à 6 équipes et 9 trous tient sur une page A4 lisible.
- L'image de résultats se partage dans WhatsApp depuis Chrome Android et Safari iOS.
- Une photo supprimée disparaît du bucket.

## Questions PO liées

Q16, Q37 (tranchées).
