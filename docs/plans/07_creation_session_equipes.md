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
- Salle d'attente (organisateur) : code et bouton "Inviter" (plan 09), liste des participants
  (membres arrivés d'eux-mêmes ou ajoutés par l'organisateur, mise à jour en temps réel), bouton
  "Ajouter un participant" (recherche dans les joueurs liés, Q24 ; Q26 : l'ajout crée un membre
  comme si la personne avait rejoint), puis selon le type de session (PO, 2026-09-15) :
  - **individuel** : rien d'autre, 1 joueur = 1 équipe ; "Démarrer" crée automatiquement une
    équipe par participant, l'organisateur ne compose rien ;
  - **équipe** : composeur d'équipes (manuel ou aléatoire) depuis les participants, équipes
    composées affichées, "Démarrer" quand tout le monde est placé (Q25).
  Pour un membre : "En attente du démarrage par X", son équipe si elle existe, les autres
  participants présents.
- Ville : au chargement, position → géocodage inverse (Q11 : BigDataCloud client, sans clé) →
  champ "Ville" pré-rempli, modifiable, à confirmer. Si la position est refusée, champ vide
  facultatif. La position de création est stockée sur la session (utile pour l'historique et pour
  proposer les trous).
- Zone : champ texte libre facultatif, avec suggestions des zones déjà saisies par l'utilisateur
  dans cette ville (requête distincte sur `sessions.zone`).
- Type : individuel ou équipe. Mode de scoring : Stroke Play, Match Play, Redistribution, Libre,
  avec une fiche d'explication (bouton info). En mode Libre, un sélecteur supplémentaire "Le plus
  haut gagne / Le plus bas gagne" (Q7b, défaut : le plus haut). Le dernier choix est proposé par
  défaut. Pour les trois autres modes, `ranking_direction` est déduit côté client (Q34) : Stroke
  Play `asc`, Match Play et Redistribution `desc`.
- Météo : appel Open‑Meteo (sans clé, CORS ouvert) au **démarrage** de la session (pas à la
  création — corrigé le 2026-09-17 : une session peut être préparée à l'avance, Q26 "cas 1", la
  météo qui compte est celle du moment joué) si la position est connue ; stockée en `weather`
  (température, vent, code). Échec silencieux.
- Équipes (composeur, dans la salle d'attente, **mode équipe seulement**) :
  - liste de joueurs = les participants de la session (pool) ; "Ajouter un participant" cherche
    dans tous les joueurs liés à un utilisateur (toute personne connectée au moins une fois, Q24),
    avec recherche par nom et les joueurs récents en tête (ceux des dernières sessions de
    l'organisateur) ;
  - **pas de création de joueur à la volée** (Q24, PO 2026-09-15) : une personne absente de la
    liste doit se connecter une fois à l'app ; les joueurs importés de LsgScores sans compte ne
    sont pas proposés ;
  - mode manuel : sélection puis "former une équipe" (2 joueurs, Q5 tranchée : table de
    jointure, la taille est une règle applicative ; en individuel la taille est 1 et les équipes
    sont créées par le démarrage) ;
  - mode aléatoire : sélection d'un nombre pair ≥ 4, tirage par paires, résultat modifiable ;
  - un joueur n'appartient qu'à une équipe ; suppression d'une équipe libère ses joueurs ;
  - modifications (ajouter, retirer, supprimer une équipe, retirer un membre du pool) possibles
    tant que `status = draft` ; figées au démarrage.
  - Le joueur lié à l'organisateur est pré-sélectionné.
- Création : RPC `create_session(payload jsonb)` insère `sessions` (status `draft`), les équipes
  déjà composées le cas échéant (`teams`, `team_players`) et `session_members` (créateur = `owner`,
  rattaché à l'équipe de son joueur si elle existe), en une transaction.
- Démarrage : RPC `start_session(session_id)` : en individuel, crée une équipe par participant
  (au moins un participant) ; en équipe, exige au moins une équipe et aucun participant non
  affecté (Q25, message nommant les personnes). Puis `status = live`, `started_at = now`, chaque
  membre rattaché à l'équipe de son joueur. Les membres voient l'écran passer en direct par
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

- Écran de création, salle d'attente, RPC de création et de démarrage.

## Critères d'acceptation

- Créer une session à 4 joueurs et la démarrer prend moins de 60 s sur téléphone.
- Cas 2 (plan 09), mode équipe : trois arrivants apparaissent dans la salle sans rafraîchir ; un
  tirage aléatoire les répartit ; le démarrage est refusé tant qu'un arrivant reste non affecté.
- Mode individuel : quatre participants, aucun écran d'équipe ; "Démarrer" produit quatre équipes
  d'une personne et l'écran en direct les affiche.
- Refus du réseau au moment de "Démarrer" : aucune session partielle en base, message clair,
  nouvel essai possible sans ressaisie.
- La ville détectée correspond à la commune réelle sur trois positions de test.

## Questions PO liées

Q5, Q9, Q11, Q15, Q24, Q25, Q26, Q34 (tranchées).
