# Plan 22 — Saisie des scores hors ligne

## Statut

Fiche synthétique (2026-09-24). Plan détaillé à rédiger après réponse à Q99 et Q100.

## Objectif

Qu'une saisie de score faite sans réseau ne soit jamais perdue : elle est gardée sur le
téléphone, affichée « en attente », puis envoyée dès le retour du réseau.

## Prérequis

Plan 08 (session en direct) livré.

## Périmètre envisagé (hypothèse)

- Hors ligne : saisie et correction des scores d'une session déjà ouverte sur l'appareil.
- Reste en ligne obligatoire : créer ou rejoindre une session, ajouter un trou, clore.
- Indicateur discret « hors ligne » et pastille « en attente » sur chaque score non envoyé.

## Principes techniques

- File d'attente locale (IndexedDB ou `shared_preferences`) rejouée à la reconnexion.
- Conflit : la règle actuelle reste (dernier écrit gagne, clé trou joué × équipe).
- Dernier instantané de la session gardé localement pour l'afficher sans réseau.

## Questions PO liées

Q99 (périmètre hors ligne), Q100 (conflit entre deux saisies hors ligne de la même équipe).

## Critères d'acceptation (esquisse)

- Mode avion activé, trois scores saisis, mode avion désactivé : les trois scores arrivent sur
  les autres téléphones sans action de l'utilisateur.
- Tests unitaires de la file d'attente (ordre, reprise après échec).
