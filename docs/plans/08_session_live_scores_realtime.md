# Plan 08 — Session en direct : trous joués, saisie collaborative, classement temps réel

## Objectif

Le cœur de l'app : pendant la session, tout membre voit le classement et les trous joués se
mettre à jour en direct, saisit les coups de son équipe, et le créateur pilote le déroulé (ajout
de trous, corrections, clôture).

## Prérequis

Plans 03 (temps réel, RLS), 06, 07.

## Décisions retenues

- Source de vérité : la base. L'écran charge un instantané de la session (session, équipes,
  joueurs, trous joués, coups) puis s'abonne aux changements `postgres_changes` filtrés
  `session_id=eq.<id>` sur `played_holes`, `scores`, `teams`, `team_players`, `session_members`
  et `sessions` (clôture). À chaque événement, l'instantané local est mis à jour et le classement
  recalculé en Dart. Reconnexion : à la reprise de l'onglet ou du réseau, rechargement de
  l'instantané (les événements manqués ne sont pas rejoués par Supabase).
- Calcul des scores : réécriture en Dart des trois calculateurs (Stroke Play, Match Play,
  Redistribution) avec les tests existants transposés, plus le mode **Libre** (Q7 : la valeur
  saisie est le nombre de points, aucun calcul) ; classement : coups croissants en Stroke Play,
  selon `ranking_direction` en Libre (Q7b), sinon points décroissants puis coups croissants ;
  positions ex æquo affichées à égalité. L'en-tête affiche le mode et, en Libre, le sens du
  classement.
- Écran `/session/:id` (membre) :
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
   transposés de `ScoringModeTest`), réducteur d'événements temps réel (pur, testé).
2. `features/live/data` : chargement de l'instantané (une requête par table, ou une RPC
   `session_snapshot(session_id)` retournant un JSON unique — retenue pour limiter les allers-retours
   sur mobile), abonnement realtime, upsert de coups, ajout/suppression de trous joués, clôture.
3. `features/live/ui` : écran de session, carte de classement, carte de trou joué, feuille de
   saisie, feuille d'ajout de trou, bandeaux de fin.
4. Tests : réducteur (chaque type d'événement), calculateurs, widget de saisie.
5. Test de charge léger : 4 téléphones saisissant en même temps ; vérifier l'absence de doublons
   (clé primaire composite) et la convergence des écrans en moins de 2 s.

## Livrables

- Session en direct complète, temps réel, saisie collaborative, clôture.

## Critères d'acceptation

- Une saisie sur un téléphone apparaît sur les autres en moins de 2 s.
- Après passage en arrière-plan de 10 minutes et retour, l'écran est à jour sans action.
- Les tests des calculateurs reproduisent les cas de l'ancienne app.

## Questions PO liées

Q7, Q8, Q9. Jalon de validation 3 du plan d'ensemble (première session réelle).
