# Plan 14 — Suppression de compte

## Objectif

Permettre à un utilisateur de supprimer son compte NUNI (données personnelles et auth) sans
casser les données partagées d'autres utilisateurs (sessions, scores, trous) qui référencent ce
qu'il a créé.

## Prérequis

Plan 05 (le compte, le profil et le joueur lié existent).

## Décisions retenues

Aucune pour l'instant : ce plan a été retiré du plan 05 (2026-09-16) précisément parce que ses
impacts sur les données d'autres utilisateurs n'avaient pas été examinés. Q27 à Q31
(`docs/QUESTIONS_PO.md`) doivent être tranchées avant d'écrire les étapes détaillées :

- Q27 : devenir du joueur lié (`players`) référencé ailleurs.
- Q28 : devenir des sessions dont je suis propriétaire.
- Q29 : devenir des trous que j'ai créés.
- Q30 : sessions en direct au moment de la suppression.
- Q31 : fonction SQL ou Edge Function pour la suppression du compte `auth`.

Confirmation utilisateur : double confirmation avant suppression (reprise du plan 05 initial,
non remise en cause).

## Étapes

À écrire une fois Q27–Q31 tranchées. Esquisse, sous réserve des réponses :

1. Migration Supabase : fonction `delete_my_account` (SQL `security definer` ou Edge Function
   selon Q31), politiques RLS et contraintes ajustées selon Q27–Q29 (ex. `holes.owner_id`
   nullable si Q29 le demande).
2. Tests RLS étendus (`supabase/tests/`) : la suppression laisse la base cohérente, un
   non-propriétaire ne peut pas déclencher la suppression d'un autre compte.
3. `features/profile/` : action "Supprimer mon compte" dans les réglages, double confirmation,
   message adapté au résultat (transfert de propriété, sessions bloquantes si Q30 le prévoit).
4. Pages légales (`/privacy`) : texte à jour sur le droit à l'effacement et son étendue réelle
   (ce qui est supprimé vs délié), cohérent avec les réponses Q27–Q29.

## Livrables

À définir avec les étapes détaillées.

## Critères d'acceptation

À définir avec les étapes détaillées. Doit au minimum couvrir : la base reste cohérente après
suppression (tests RLS), les données d'autres utilisateurs référençant ce que j'ai créé restent
consultables (selon Q27–Q29), pas de suppression de compte possible tant qu'une session en direct
m'appartient (si Q30 retient cette règle).

## Questions PO liées

Q27, Q28, Q29, Q30, Q31 — toutes ouvertes, à trancher avant de démarrer l'implémentation.
