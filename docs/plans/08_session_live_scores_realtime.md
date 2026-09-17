# Plan 08 — Session en direct : trous joués, saisie collaborative, classement temps réel

## Objectif

Le cœur de l'app : pendant la session, tout membre voit le classement et les trous joués se
mettre à jour en direct, saisit les coups de son équipe, et le créateur pilote le déroulé (ajout
de trous, corrections, clôture).

## Prérequis

Plans 03 (temps réel, RLS), 06, 07.

## Décisions retenues

- Source de vérité : la base. L'écran charge l'instantané de la session via la RPC
  `session_snapshot(session_id)` (session, équipes, joueurs, trous joués, coups) puis s'abonne aux
  changements `postgres_changes` filtrés `session_id=eq.<id>` sur `played_holes`, `scores`,
  `teams`, `team_players`, `session_members` et `sessions` (clôture). Q35 : `scores` et
  `team_players` n'ont pas de colonne `session_id` ; une colonne dénormalisée leur est ajoutée
  (triggers depuis `played_holes`/`teams`) pour permettre ce filtre, comme il existe déjà sur
  `teams` et `played_holes`.
  Q36 : les abonnements ne servent qu'à détecter qu'un événement est survenu — aucun événement
  n'est appliqué à l'instantané local ; chaque déclenchement relance `session_snapshot` et
  remplace l'instantané, comme le fait déjà la salle d'attente (`session_room_page.dart`) depuis
  que la première approche (corriger l'instantané avec le contenu de l'événement) a produit deux
  bugs réels en plans 07/09 (ligne dupliquée, suppression non répercutée). Le classement est
  recalculé en Dart à partir de l'instantané reçu. Reconnexion : à la reprise de l'onglet ou du
  réseau, rechargement de l'instantané (les événements manqués ne sont pas rejoués par Supabase).
- Calcul des scores : réécriture en Dart des trois calculateurs (Stroke Play, Match Play,
  Redistribution) avec les tests existants transposés, plus le mode **Libre** (Q7 : la valeur
  saisie est le nombre de points, aucun calcul) ; classement : coups croissants en Stroke Play,
  selon `ranking_direction` en Libre (Q7b), sinon points décroissants puis coups croissants ;
  positions ex æquo affichées à égalité. L'en-tête affiche le mode et, en Libre, le sens du
  classement.
- Écran `/session/:id` : tant que `status = draft`, il affiche la salle d'attente du plan 07 ;
  l'événement temps réel sur `sessions` (passage à `live`) bascule vers l'écran en direct sans
  rechargement. Équipes figées après le démarrage (Q15).
- Écran `/session/:id` en direct (membre) :
  - en-tête : ville · zone · date, mode de scoring (info), bouton "Inviter" (code, lien, QR :
    plan 09) ;
  - carte de classement repliable (leader en résumé), avertissement "scores incomplets" ;
  - liste des trous joués, dernier en tête et mis en évidence, chaque carte montrant chaque équipe
    avec coups et points (ou points seuls en Stroke Play) et les équipes sans score signalées ;
  - saisie inline : toucher une équipe ouvre une feuille en bas d'écran avec les chips 0–9 et "X"
    (10+), enregistrement immédiat (upsert `scores`), sans écran dédié ni bouton "Enregistrer".
    Le score calculé s'affiche en direct. En mode Libre la feuille demande des points (Q7b) et
    n'affiche pas de coups. Q8 tranchée : membre = sa propre équipe, créateur et co-organisateurs =
    toutes les équipes. H (Q8) : je peux saisir mon équipe ; le créateur
    peut saisir toutes les équipes ; les autres équipes sont en lecture seule.
- Ajout d'un trou joué (créateur) : feuille "Ajouter un trou" avec les trous à proximité
  (RPC `holes_nearby` avec le rayon mémorisé, position actuelle), recherche par nom, "tous mes
  trous", bouton "Créer un trou ici" (formulaire du plan 06 pré-rempli avec la position, retour
  automatique), choix du mode de jeu (Individual en individuel ; Scramble, Greensome, Best Ball
  en équipe, défaut Scramble, info). Un trou peut être joué plusieurs fois dans la session
  (positions distinctes).
- Suppression d'un trou joué (créateur) avec confirmation ; les coups sont supprimés en cascade.
- Clôture (créateur) : "Terminer la session" → `status = completed`, `ended_at = now` →
  redirection vers le détail historique. Annulation : "Supprimer la session" avec confirmation
  forte (suppression en cascade).
- Fin de session côté membres : l'événement sur `sessions` déclenche un bandeau "Session terminée
  par X" et un bouton vers l'historique ; si supprimée, retour à l'accueil avec message.
- Créateur absent : le créateur peut promouvoir un membre en co-organisateur (rôle `owner`
  multiple) pour que la session ne dépende pas d'un seul téléphone. Simple ajout de rôle, aucune
  logique supplémentaire.
- Hors ligne : affichage en lecture des dernières données connues ; la saisie est refusée avec
  message tant que le réseau est absent (pas de file d'attente hors ligne dans cette version,
  mentionné comme évolution).

## Étapes

1. `features/live/domain` : modèle d'instantané de session, calculateurs et classement (tests
   transposés de `ScoringModeTest`).
2. Migration : colonne `session_id` dénormalisée sur `scores` et `team_players`, triggers de
   renseignement (Q35).
3. `features/live/data` : RPC `session_snapshot(session_id)` (JSON unique, limite les
   allers-retours sur mobile) ; abonnements realtime utilisés uniquement comme déclencheurs, qui
   rechargent `session_snapshot` à chaque événement (Q36) ; upsert de coups, ajout/suppression
   de trous joués, clôture.
4. `features/live/ui` : écran de session, carte de classement, carte de trou joué, feuille de
   saisie, feuille d'ajout de trou, bandeaux de fin.
5. Tests : calculateurs, widget de saisie.
6. Test de charge léger : 4 téléphones saisissant en même temps ; vérifier l'absence de doublons
   (clé primaire composite) et la convergence des écrans en moins de 2 s.

## Livrables

- Session en direct complète, temps réel, saisie collaborative, clôture.

## Critères d'acceptation

- Une saisie sur un téléphone apparaît sur les autres en moins de 2 s.
- Après passage en arrière-plan de 10 minutes et retour, l'écran est à jour sans action.
- Les tests des calculateurs reproduisent les cas de l'ancienne app.

## Questions PO liées

Q7, Q8, Q9, Q35, Q36 (tranchées). Jalon de validation 3 du plan d'ensemble (première session
réelle).

## Notes d'implémentation (2026-09-17)

Code écrit (étapes 1 à 5 : domaine, migration, data, ui, tests calculateurs + widget de saisie) ;
`flutter analyze`, `flutter test` (71 tests) et `dart format` verts. Étape 6 (test de charge à 4
téléphones) et le jalon de validation 3 restent à faire par le PO, et supposent d'abord la
reconstruction du schéma distant (voir point bloquant ci-dessous).

Points où le texte du plan laissait un doute, tranchés par la technique faute de mieux, à corriger
si la lecture est mauvaise une fois vu à l'écran :
- "chaque carte montrant chaque équipe avec coups et points (ou points seuls en Stroke Play)" :
  lu comme probablement inversé (Stroke Play n'a pas de notion de points séparée du nombre de
  coups). Implémenté : Stroke Play affiche les coups seuls ; Match Play et Redistribution
  affichent coups et points ; Libre affiche les points seuls (aucun coup saisi, Q7b).
- "bandeau 'Session terminée par X'" : aucune colonne ne mémorise qui a cliqué sur "Terminer la
  session" (seul `sessions.ended_at` existe) ; le bandeau affiche "Session terminée" sans nommer
  X. Ajouter cette colonne est possible mais non fait, faute de le voir demandé ailleurs dans le
  schéma.
- Hors ligne : pas de dépendance de détection réseau ajoutée. La saisie est tentée normalement ;
  un échec réseau affiche un message d'erreur au lieu de refuser la saisie par anticipation. Le
  lecture seule "dernières données connues" est déjà le comportement par défaut (aucune requête ne
  peut aboutir hors ligne, l'écran garde donc l'instantané précédent).

Point bloquant pour la suite : les migrations modifiées (colonnes `session_id` sur `scores` et
`team_players`, RPC `session_snapshot` et `add_played_hole`) éditent des fichiers déjà appliqués
sur le projet distant `nuni` — comme le prévoit AGENTS.md §8, cela exige de reconstruire le schéma
distant depuis zéro (procédure `docs/DEV.md`), à ne lancer qu'après accord explicite du PO. Rien
n'a été testé dans le navigateur ni poussé sur le projet distant.
