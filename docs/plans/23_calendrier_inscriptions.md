# Plan 23 — Calendrier et inscriptions (sessions planifiées)

## Statut

Fiche synthétique (2026-09-24). Plan détaillé à rédiger après réponse à Q101 et Q102.

## Objectif

Annoncer une session à venir (date, heure, lieu de rendez-vous), laisser les joueurs de
l'association répondre « je viens / je ne viens pas », puis démarrer la session le jour J à
partir des inscrits.

## Prérequis

Plans 07 et 18 (création de session, associations) livrés.

## Contenu envisagé (hypothèse)

- Nouveau statut de session « planifiée » (avant « en préparation ») avec date prévue et lieu.
- Onglet ou section « À venir » sur l'accueil, filtré par association (Q88).
- Réponse en un geste ; liste des inscrits visible de tous les membres de l'association.
- Au démarrage, les inscrits sont pré-sélectionnés comme joueurs.
- Ajout à l'agenda du téléphone par un fichier `.ics` (pas de notification push, fragile en
  PWA sur iPhone).

## Principes techniques

- Valeur ajoutée à l'enum `session_status` et table `session_rsvps` (session × joueur ×
  réponse). Migration selon la règle 8 en vigueur à ce moment-là (Q87 : fichiers édités en
  place et reconstruction tant que l'app n'est pas officiellement en service).

## Questions PO liées

Q101 (qui peut planifier), Q102 (rappels : `.ics` seul ou notifications).

## Critères d'acceptation (esquisse)

- Une session planifiée est visible et ouverte aux réponses pour tous les membres de
  l'association, et seulement pour eux.
- Démarrer une session planifiée reprend les inscrits sans ressaisie.
