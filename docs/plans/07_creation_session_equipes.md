# Plan 07 — Création d'une session et composition des équipes

## Objectif

Créer une session en quelques gestes : ville détectée et confirmée, zone facultative, type et mode
de scoring, équipes composées à partir de joueurs existants ou créés à la volée, sans que ces
joueurs aient rejoint quoi que ce soit. La session démarre immédiatement en direct.

## Prérequis

Plans 05 et 06 (géolocalisation partagée).

## Décisions retenues

- Un seul écran de création en deux volets défilants (paramètres puis équipes), avec un bouton
  collant "Démarrer la session". Pas d'écran intermédiaire.
- Ville : au chargement, position → géocodage inverse (H Q11 : BigDataCloud client, sans clé) →
  champ "Ville" pré-rempli, modifiable, à confirmer. Si la position est refusée, champ vide
  facultatif. La position de création est stockée sur la session (utile pour l'historique et pour
  proposer les trous).
- Zone : champ texte libre facultatif, avec suggestions des zones déjà saisies par l'utilisateur
  dans cette ville (requête distincte sur `sessions.zone`).
- Type : individuel ou équipe. Mode de scoring : Stroke Play, Match Play, Redistribution, Libre,
  avec une fiche d'explication (bouton info). En mode Libre, un sélecteur supplémentaire "Le plus
  haut gagne / Le plus bas gagne" (Q7b, défaut : le plus haut). Le dernier choix est proposé par
  défaut.
- Météo : appel Open‑Meteo (sans clé, CORS ouvert) à la création si la position est connue ;
  stockée en `weather` (température, vent, code). Échec silencieux.
- Équipes :
  - liste de joueurs = tous les joueurs du référentiel partagé, avec recherche par nom et les
    joueurs récents en tête (ceux des dernières sessions de l'utilisateur) ;
  - **créer un joueur à la volée** depuis la barre de recherche ("+ Ajouter Marie") ;
  - mode manuel : sélection puis "former une équipe" (1 joueur en individuel, 2 en équipe, Q5
    tranchée : table de jointure, la taille est une règle applicative) ;
  - mode aléatoire : sélection d'un nombre pair ≥ 4, tirage par paires, résultat modifiable ;
  - un joueur n'appartient qu'à une équipe ; suppression d'une équipe libère ses joueurs.
  - Le joueur lié à l'utilisateur est pré-sélectionné.
- Démarrage : insertion `sessions` (status `live`, `started_at = now`), `teams`, `team_players`,
  `session_members` (créateur = `owner`, rattaché à l'équipe de son joueur), puis navigation vers
  `/session/:id`. Une seule transaction via RPC `create_session(payload jsonb)` pour éviter un état
  partiel si le réseau tombe en cours de route.
- Q9 tranchée : plusieurs sessions en direct par utilisateur autorisées ; aucune contrainte
  d'unicité en base, l'accueil liste "mes sessions en direct".

## Étapes

1. Paquets : `http` (géocodage inverse, météo) ; modèles `freezed` pour ville détectée et météo.
2. `core/geocoding/` et `core/weather/` : clients avec délais courts (3 s) et repli silencieux.
3. `features/sessions/domain` : enums `SessionKind`, `ScoringMode`, règles de composition des
   équipes (pures, testées), tirage aléatoire (injectable pour les tests).
4. `features/sessions/data` : repository (`create_session`, zones distinctes, joueurs récents).
5. `features/sessions/ui` : écran de création, sélecteur de joueurs avec création rapide,
   composant équipe.
6. Tests : règles d'équipe, tirage aléatoire, formulaire.

## Livrables

- Écran de création, RPC de création atomique, joueurs à la volée.

## Critères d'acceptation

- Créer une session à 4 joueurs dont un nouveau prend moins de 60 s sur téléphone.
- Refus du réseau au moment de "Démarrer" : aucune session partielle en base, message clair,
  nouvel essai possible sans ressaisie.
- La ville détectée correspond à la commune réelle sur trois positions de test.

## Questions PO liées

Q5, Q9, Q11.
