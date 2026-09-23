# Plan 12 — Recette, reprise de données, mise en service

## Statut

Clôturé par le PO le 2026-09-23. Les tests menés pendant le développement sont jugés suffisants
pour la première version ; les scénarios formels, le guide d'installation et le backlog ne sont
pas produits. La première session réelle a lieu la semaine suivante ; les bugs éventuels seront
traités au fil de l'eau.

## Objectif

Vérifier NUNI dans les conditions réelles, décider de la reprise éventuelle des données de
LsgScores, et mettre l'app en service pour le groupe de joueurs.

## Prérequis

Plans 05 à 11 livrés.

## Décisions retenues

- Versions : à chaque mise en service, la version de `pubspec.yaml` est incrémentée et un tag git
  `vX.Y.Z` identique est posé sur le commit déployé (décision du 2026-09-15, en remplacement du
  tag de départ du plan 02). C'est la version affichée dans les réglages de l'app.

- Recette sur téléphones réels (au moins un Android Chrome et un iPhone Safari), en extérieur,
  avec 3 à 4 personnes. Scénarios écrits dans `docs/recette/scenarios.md` et cochés à chaque
  passe.
- Q3 tranchée : la migration des anciennes données est critique et fait l'objet de l'étape 13,
  dont le plan détaillé est rédigé après cette recette. Ce plan 12 ne migre rien ; il vérifie que
  NUNI fonctionne à vide.
- L'ancienne app Android et son projet Supabase restent en place, en lecture, jusqu'à la fin de
  l'étape 13 ; aucune modification n'y est apportée.
- Sauvegardes : activer les sauvegardes du projet Supabase (selon plan tarifaire) et exporter un
  dump SQL avant la mise en service.

## Scénarios de recette (résumé, détaillés dans docs/recette)

1. Premier lancement, connexion Google, création de mon joueur.
2. Création de trous à proximité, public et privé, avec photos.
3. Création d'une session à 4 joueurs dont un nouveau, ville détectée, zone saisie.
4. Invitation par QR : deux téléphones rejoignent, un avec joueur lié, un sans.
5. Saisie collaborative sur 3 trous, corrections par le créateur, mode Stroke Play puis Match
   Play sur une seconde session.
6. Passage en arrière-plan, perte de réseau, reprise.
7. Clôture, historique, photos, export PDF et image partagés dans WhatsApp.
8. Installation de la PWA, mise à jour après un déploiement.
9. Suppression de compte d'un utilisateur test et vérification de la cohérence.

## Étapes

1. Rédiger les scénarios, jouer une première passe, corriger, rejouer.
2. Rédiger le plan détaillé 13 (migration) à partir des constats de la recette.
3. Communiquer le lien et le guide d'installation en une page (`docs/guide_installation.md`,
   EN/FR) aux joueurs.
4. Mise en service : bascule, surveillance des erreurs pendant les premières sessions, correctifs.
5. Rétrospective : liste des évolutions candidates (scanner intégré, mode hors ligne, mode
   sombre, statistiques joueurs) dans `docs/BACKLOG.md`.

## Livrables

- Scénarios de recette joués et archivés, décision de reprise appliquée, guide d'installation,
  backlog d'évolutions.

## Critères d'acceptation

- Les 9 scénarios passent sur Android et iOS.
- Une session réelle complète a été jouée avec NUNI sans recours à l'ancienne app.

## Questions PO liées

Q3. Jalon de validation 4 du plan d'ensemble.
