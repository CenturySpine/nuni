# Plan 07 — Création d'une session et composition des équipes

## Objectif

Créer une session en quelques gestes : ville détectée et confirmée, zone facultative, type et mode
de scoring, puis composer les équipes, soit à l'avance à partir de joueurs existants ou créés à la
volée, soit depuis le pool des joueurs qui ont rejoint (plan 09, Q15). La session est créée en
**préparation** et démarre sur action de l'organisateur.

## Prérequis

Plans 05 et 06 (géolocalisation partagée).

## Décisions retenues

- Écran de création : paramètres, puis bouton "Créer la session" → session en `draft`, puis
  **salle d'attente** `/session/:id` (même route que l'écran en direct, plan 08, qui affiche la
  salle tant que `status = draft`). La composition des équipes se fait dans la salle d'attente,
  à l'avance (cas 1) ou après l'arrivée des joueurs (cas 2).
- Salle d'attente (organisateur) : code et bouton "Inviter" (plan 09), liste du pool (membres
  arrivés sans équipe, mise à jour en temps réel), équipes composées, composeur d'équipes, bouton
  "Démarrer". Pour un membre : "En attente du démarrage par X", son équipe si elle existe, les
  autres membres présents.
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
- Équipes (composeur, dans la salle d'attente) :
  - liste de joueurs = d'abord le pool de la session (joueurs liés des membres arrivés), puis tous
    les joueurs du référentiel partagé, avec recherche par nom et les joueurs récents en tête
    (ceux des dernières sessions de l'utilisateur) ;
  - **créer un joueur à la volée** depuis la barre de recherche ("+ Ajouter Marie") (H Q24) ;
  - mode manuel : sélection puis "former une équipe" (1 joueur en individuel, 2 en équipe, Q5
    tranchée : table de jointure, la taille est une règle applicative) ;
  - mode aléatoire : sélection d'un nombre pair ≥ 4, tirage par paires, résultat modifiable ;
  - un joueur n'appartient qu'à une équipe ; suppression d'une équipe libère ses joueurs ;
  - modifications (ajouter, retirer, supprimer une équipe, retirer un membre du pool) possibles
    tant que `status = draft` ; figées au démarrage.
  - Le joueur lié à l'organisateur est pré-sélectionné.
- Création : RPC `create_session(payload jsonb)` insère `sessions` (status `draft`), les équipes
  déjà composées le cas échéant (`teams`, `team_players`) et `session_members` (créateur = `owner`,
  rattaché à l'équipe de son joueur si elle existe), en une transaction.
- Démarrage : RPC `start_session(session_id)` : au moins une équipe, aucun membre du pool non
  affecté (H Q25, message nommant les personnes), `status = live`, `started_at = now`, rattache
  chaque membre à l'équipe de son joueur. Les membres voient l'écran passer en direct par
  l'événement temps réel sur `sessions`.
- Q9 tranchée : plusieurs sessions en direct par utilisateur autorisées ; aucune contrainte
  d'unicité en base, l'accueil liste "mes sessions en direct".

## Étapes

1. Paquets : `http` (géocodage inverse, météo) ; modèles `freezed` pour ville détectée et météo.
2. `core/geocoding/` et `core/weather/` : clients avec délais courts (3 s) et repli silencieux.
3. `features/sessions/domain` : enums `SessionKind`, `ScoringMode`, règles de composition des
   équipes (pures, testées), tirage aléatoire (injectable pour les tests).
4. `features/sessions/data` : repository (`create_session`, zones distinctes, joueurs récents).
5. `features/sessions/ui` : écran de création, salle d'attente (pool en temps réel, composeur
   d'équipes, démarrage), sélecteur de joueurs avec création rapide, composant équipe.
6. Tests : règles d'équipe, tirage aléatoire, conditions de démarrage, formulaire.

## Livrables

- Écran de création, salle d'attente, RPC de création et de démarrage, joueurs à la volée.

## Critères d'acceptation

- Créer une session à 4 joueurs dont un nouveau, et la démarrer, prend moins de 60 s sur téléphone.
- Cas 2 (plan 09) : trois arrivants apparaissent dans le pool sans rafraîchir ; un tirage
  aléatoire les répartit ; le démarrage est refusé tant qu'un arrivant reste non affecté.
- Refus du réseau au moment de "Démarrer" : aucune session partielle en base, message clair,
  nouvel essai possible sans ressaisie.
- La ville détectée correspond à la commune réelle sur trois positions de test.

## Questions PO liées

Q5, Q9, Q11, Q15 (tranchée), Q24, Q25 (hypothèses).
