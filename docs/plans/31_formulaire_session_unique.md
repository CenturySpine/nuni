# Plan 31 — Un seul formulaire pour créer et modifier une session

## Statut

Plan rédigé le 2026-09-27 à la demande du PO du même jour, après son essai du plan 29 (AG du
14 septembre saisie après coup : impossible ensuite de corriger le nom ou le lieu). Réponses
du PO le 2026-09-27 : Q205, Q206, Q207, Q209, Q210 retenues ; Q208 refusée (rien ne change
des règles du plan 29). Toutes les questions sont tranchées. **Plan validé par le PO le
2026-09-27**, implémentation demandée le même jour.

**Implémenté le 2026-09-27** : `sessions.title`, date passée à la création (`create_session`,
`start_session` et « Terminer » la gardent), RPC `update_session` ; `SessionCreatePage` sert à
la création (`/session/new`) et à la modification (`/session/:id/edit`), les fiches
« Modifier », natures et compte rendu sont supprimées. Seeds régénérés, base distante
reconstruite, `rls_smoke.sql` vert (127 tests), 491 tests Flutter verts. **Essayé et validé par
le PO, clôturé le 2026-09-27.** Dernière reconstruction de la base : le projet passe ensuite en
migrations additives (version 1.0.0).

## Objectif

Créer et modifier une session avec **le même écran**, champs pré-remplis en modification, pour
que tout ce qu'on choisit à la création se corrige après coup : nom, lieu, date et heure,
natures, compte rendu, championnat. Ce qui ne peut plus changer reste visible, grisé, avec la
raison.

## Existant (constat)

- **Pas de nom de session.** Ce qui s'affiche comme titre partout (accueil, historique, détail,
  export) est le lieu : `zone` (nom du spot ou du lieu libre) et `city`. Pour l'AG, le titre
  est donc le nom de la salle.
- **Pas de date à la création.** `started_at` est posé au démarrage (`start_session`, heure du
  moment) ou par « Terminer » depuis le brouillon (plan 29). Une session saisie après coup a la
  date du jour de saisie, à corriger ensuite.
- **Modification éclatée en quatre endroits**, chacun limité :
  - « Modifier » (historique, organisateur, session terminée seulement) : date, heures de début
    et de fin, compte rendu ;
  - crayon des natures (plan 29) : les tags ;
  - crayon du compte rendu (plan 29) ;
  - interrupteur du championnat (staff).
  Le lieu, lui, ne se modifie nulle part.
- **Parcours, format et mode de scoring figés dès la création** (Q193, plan 29), même au
  brouillon, alors qu'aucun score n'existe encore.

## Décisions proposées

### Un seul écran (H)

`SessionFormPage` remplace `SessionCreatePage` et la fiche « Modifier » : `/session/new`
(création, éventuellement depuis un événement) et `/session/:id/edit` (modification). Mêmes
sections dans le même ordre :

1. Association (lecture seule).
2. **Nom** (facultatif, Q205).
3. **Natures** : Parcours et les tags.
4. **Lieu** : spot, ou lieu libre sans Parcours.
5. **Date et heure** (Q206).
6. **Format et mode de scoring** (avec Parcours).
7. **Compte rendu** (Q210).
8. **Championnat** (staff).

Les crayons du plan 29 (natures, compte rendu) et « Modifier » ouvrent tous cet écran ; les
fiches `SessionEditSheet`, natures et compte rendu disparaissent. Un seul bouton en bas :
« Créer la session » ou « Enregistrer ».

### Nom de session (Q205, décidé)

Nouvelle colonne `sessions.title`, facultative (80 caractères). Affiché en titre quand il
existe, le lieu passant en sous-titre ; sinon rien ne change (le lieu reste le titre). Aucune
session existante n'est touchée.

### Date et heure (Q206, hypothèse)

- **Création** : « Date et heure de début », « maintenant » par défaut, jamais dans le futur
  (une session à venir se prévoit dans le planning, plan 23). Une date passée fait une session
  **saisie après coup** : `started_at` est posé tout de suite, `start_session` ne l'écrase plus,
  et une « Heure de fin » apparaît (début + 2 h par défaut) pour « Terminer ». La météo est lue
  dans les archives d'Open-Meteo, comme aujourd'hui à la modification.
- **Modification** : date, heure de début et de fin, avec les contrôles actuels (pas dans le
  futur, fin après le début). Météo relue si le début ou le lieu change.

### Lieu modifiable (Q207, décidé)

Spot, ou lieu libre sans Parcours, comme à la création ; à tout moment, par l'organisateur. Une
session avec Parcours garde un spot obligatoire (plan 28). Vérifié, rien ne bloque :
- le spot choisi doit être de l'association de la session, ce que la base contrôle déjà
  (`sessions_copy_spot`), et qui recopie aussi son nom et sa ville ;
- le point de la session devient celui du nouveau spot ou du lieu libre, et la météo est relue
  (archives) ; pour un spot à emplacement variable (Q186), qui n'a pas de point, la session
  garde le sien (H) ;
- les trous joués ne dépendent pas du spot : rien à défaire ;
- les badges « Explorateur » (G) lisent le point de la session ; recalculés à l'affichage, ils
  suivent le nouveau lieu.

### Parcours, format et mode restent figés (Q208, décidé : non)

Aucune règle du plan 29 ne change (Q193, Q197). En modification, Parcours, format, mode et sens
sont affichés grisés avec « Fixé à la création de la session » ; les tags suivent exactement
les règles actuelles (Simulateur figé avec Parcours, Training avec Parcours au staff une fois
la session terminée, etc.), avec les mêmes explications que le crayon des natures
d'aujourd'hui.

### Qui modifie quoi (Q209, hypothèse)

- **Organisateur** : tout, dans les limites ci-dessus.
- **Staff de l'association et `super_admin`** (pas organisateurs) : le même écran, avec
  seulement natures, compte rendu et championnat actifs (leurs droits du plan 29) ; le reste
  grisé.

### Compte rendu dans le formulaire (Q210, hypothèse)

Un champ « Compte rendu » en texte long, en création et en modification. La carte du compte
rendu reste affichée sur la salle et le détail, son crayon ouvrant l'écran de modification.

## Données

- `tables.sql` : `sessions.title text` (vide = aucun, 80 caractères au plus).
- `rpc.sql` :
  - `create_session` accepte `title`, `started_at` (passé seulement) et `ended_at` ;
  - `start_session` garde un `started_at` déjà posé ;
  - nouvelle RPC `update_session(p_session_id, payload)` : une seule écriture pour nom, lieu,
    date, heures, tags et compte rendu, qui vérifie qui modifie quoi (Q209) ;
  - `set_session_tags`, `set_session_report` restent (l'écran les appelle pour le staff).
- `triggers.sql` : inchangé (`sessions_guard_nature` garde ses règles, `sessions_copy_spot`
  recopie déjà le nom et la ville du spot).
- `session_snapshot` : ajoute `title`. Seeds étendus à `title`.
- Reconstruction de la base (règle 8, PO prévenu avant, seeds régénérés d'abord).

## Étapes

1. Schéma, RPC `update_session`, déclencheur, `rls_smoke.sql`.
2. `SessionFormPage` (création et modification), routes, suppression des trois fiches.
3. Affichage du nom (accueil, historique, détail, salle, export).
4. Date et heure à la création, saisie après coup, météo d'archive.
5. Chaînes EN/FR, analyse, tests, reconstruction, essai dans le navigateur.

## Critères d'acceptation

- « Modifier » ouvre le même écran que la création, rempli.
- Une session terminée peut changer de nom, de lieu, de date, d'heures, de natures (règles du
  plan 29) et de compte rendu ; la météo suit la date et le lieu.
- Une session créée avec une date passée garde cette date, sans correction après coup.
- En modification, Parcours, format et mode sont grisés et expliqués ; les tags suivent les
  règles du plan 29.
- Le staff non organisateur ne peut changer que natures, compte rendu et championnat.
- Sans nom, l'affichage est identique à aujourd'hui.

## Hors périmètre

- Une date future à la création (le planning s'en charge).
- Déplacer une session vers une autre association (déjà réservé au `super_admin`).
