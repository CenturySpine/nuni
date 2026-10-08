# Plan 38 — Le `super_admin` voit toutes les sessions (accueil et historique)

## Statut

Plan rédigé le 2026-10-08 à la demande du PO du même jour, revu le même jour après ses réponses :
Q274 à Q278 tranchées (Q274 : pas de sessions terminées sur l'accueil, et le même mécanisme dans
l'historique ; Q278 : un seul réglage pour les deux pages). **Plan validé par le PO le
2026-10-08.**

**Implémenté le 2026-10-08** (étapes 1, 3 à 9 et 11) : migration
`20261008072303_history_snapshots_others.sql`, section « plan 38 » de `rls_smoke.sql`, app,
tests Dart (562 réussis, analyse sans avertissement), `AGENTS.md`.

**Pas encore fait, faute d'accès à la base depuis la session de l'assistant** (aucun identifiant
Supabase dans son environnement) :
- étape 2 : migration en production et `rls_smoke.sql` ;
- étape 10 : essai dans le navigateur avec le compte du PO.

La migration et la section de tests ont seulement été exécutées sur une base PostgreSQL locale
réduite (tables et fonctions simplifiées, sans PostGIS ni Supabase) : la fonction se crée, les 7
contrôles de la section passent. Cela vérifie la syntaxe et la règle de complément, pas
l'exécution sur le vrai schéma.

**Code commité et poussé sur `main` le 2026-10-08**, à la demande du PO, avant la migration.

**Reste** : étape 2 (migration en production et `rls_smoke.sql`, par le PO depuis son poste), étape 10 et essai du PO.

## Demande du PO (reformulée)

1. **Accueil** : le `super_admin` voit, en plus de ses sessions, **toutes les sessions non
   terminées des autres** (brouillon, en préparation, en direct). Les sessions terminées restent
   l'affaire de l'historique (Q274).
2. **Historique** : le `super_admin` voit, en plus de son historique actuel, **toutes les
   sessions terminées de tout le monde** (Q274).
3. Un **interrupteur « Voir toutes les sessions »**, visible du seul `super_admin`, présent sur
   les deux pages et **commun aux deux** (Q278) : éteint, chaque page est réduite à **« ce qui me
   concerne »**, c'est-à-dire exactement la page d'aujourd'hui. Son état est **gardé sur
   l'appareil seulement** ; par défaut, **tout est affiché**.
4. Quand tout est affiché, **ce qui le concerne reste en haut**, et **le reste est dessous, dans
   une section à part**, « Autres sessions », dont l'en-tête porte l'interrupteur (Q275).
5. Quand il **ouvre une session à laquelle il ne participe pas**, pour la lire ou la modifier, un
   **bandeau rouge** l'avertit qu'il y agit avec ses droits de super admin (Q277).

## Existant (constat, relevé dans le code le 2026-10-08)

- **Lecture en base : déjà permise.** La règle de lecture des sessions (`sessions_select` →
  `can_read_session`) répond oui pour le `super_admin` sur toute session, brouillon compris
  (`20261007081311_session_drafts.sql`, Q254). Même chose pour leurs équipes, membres, trous,
  scores et photos.
- **Modification : déjà permise** (Q262) : `is_session_owner` répond oui pour lui, et les écrans
  lui montrent les actions d'organisateur par `canOrganizeSession`.
- **Ouvrir une session n'y écrit rien** pour un non-participant : `check_in_session` ne touche que
  la ligne de `session_members` de l'appelant, qu'il n'a pas. Il reste hors de la session.
- **L'accueil d'aujourd'hui** (`home_page.dart`) a deux listes :
  - « Mes sessions en cours » : les sessions en préparation ou en direct dont il est membre
    (`myOngoingSessions`), puis les sessions en direct de son association qu'il suit en
    spectateur (`associationLiveSessions`, plan 26) ;
  - « Dernières sessions » : ses 5 dernières sessions terminées (`myRecentSessions`).
- **L'historique d'aujourd'hui** (`history_page.dart`, RPC `history_snapshots` de `rpc.sql`) :
  toutes les sessions terminées **de son association**, jouées ou non, plus celles qu'il a
  jouées ailleurs, chacune avec tout son contenu (équipes, scores) pour afficher les gagnants sur
  la carte. Filtres en pastilles, non mémorisés : « Mes sessions » (celles où il a joué), une
  nature, une ville. La RPC ne renvoie rien d'autre, même au `super_admin` : son filtre est
  écrit dans la fonction, pas seulement dans les droits.
- **Aucune liste ne montre les sessions des autres associations** : il n'y accède qu'en tapant
  leur adresse.
- **Cinq écrans** affichent une session : la salle d'attente (`_WaitingRoomView` de
  `session_room_page.dart`), la salle des présents (`AttendanceRoomView`, sessions sans
  Parcours), la partie (`SessionLivePage`), le détail d'une session terminée
  (`HistoryDetailPage`), et le formulaire de modification (`SessionCreatePage` en mode édition).
- **Volume actuel** : 12 sessions en production (relevé du plan 37, 2026-10-07).

## Vocabulaire

- **Ce qui me concerne** : ce que la page montre aujourd'hui.
  - Accueil : sessions non terminées dont je suis membre, sessions en direct de mon association
    que je suis en spectateur, mes 5 dernières sessions terminées.
  - Historique : sessions terminées de mon association, et celles que j'ai jouées ailleurs.
- **Autres sessions** : ce que le `super_admin` peut lire en plus.
  - Accueil : les sessions **non terminées** dont il n'est pas membre et qui ne sont pas déjà dans
    « Mes sessions en cours » (brouillons et salles d'attente de tous, sessions en direct des
    autres associations).
  - Historique : les sessions **terminées** qui ne sont pas dans son historique actuel (autres
    associations, ou sans association, et auxquelles il n'a pas participé).
- **Hors participation** : le `super_admin` n'a aucune ligne dans `session_members` de la session.

## Ce qui change pour l'utilisateur

### Pour tout compte qui n'est pas `super_admin`

Rien. Aucune requête en plus, aucun élément visible en plus.

### Accueil du `super_admin`

- Le haut de l'accueil ne change pas : bannière, prochain événement, championnat, « Mes sessions
  en cours », « Dernières sessions ».
- **Sous « Dernières sessions », une section « Autres sessions »**, dont l'en-tête porte
  l'**interrupteur** « Voir toutes les sessions » :
  - **allumé** (par défaut) : la section liste toutes les autres sessions non terminées, de la
    plus récente à la plus ancienne ;
  - **éteint** : seul l'en-tête reste, avec l'interrupteur ; l'accueil redevient celui
    d'aujourd'hui.
- **Carte d'une autre session** (Q276) : même carte, avec la pastille d'état (« Brouillon »,
  « En préparation », « En direct ») et **le nom du créateur à la place du rôle** (« Créée par
  … »).
- Toucher la carte ouvre la session comme aujourd'hui (salle d'attente, présents ou partie).
- Le panneau « Créer une session » ne propose toujours que **ses propres** brouillons (réserve de
  Q262, inchangée).

### Historique du `super_admin`

- La liste d'aujourd'hui ne change pas.
- **Dessous, une section « Autres sessions »**, avec le même en-tête à interrupteur :
  - **allumé** (par défaut) : toutes les autres sessions terminées, de la plus récente à la plus
    ancienne, avec **la même carte que l'historique** (photo, date, lieu, natures, gagnants,
    météo), plus « Créée par … » (Q276) ;
  - **éteint** : seul l'en-tête reste ; l'historique redevient celui d'aujourd'hui.
- **Filtres** (conséquence, pas de nouvelle règle) : les trois pastilles (« Mes sessions »,
  nature, ville) s'appliquent aux deux sections, et la liste des villes proposées tient compte
  des deux. En pratique, « Mes sessions » (celles où j'ai joué) vide la section « Autres
  sessions », qui ne contient que des sessions auxquelles il n'a pas participé.
- Toucher la carte ouvre le détail, comme aujourd'hui.

### Interrupteur (Q278)

- **Un seul réglage, commun aux deux pages** : l'éteindre sur l'accueil l'éteint aussi dans
  l'historique, et inversement. L'en-tête « Autres sessions » reste visible sur les deux pages,
  interrupteur éteint : on voit toujours que la section est masquée, et où la rallumer.
- Gardé **sur l'appareil** (comme la palette), allumé par défaut : un autre appareil du même
  compte repart sur « allumé ».

### Rafraîchissement

- Tirer vers le bas et revenir dans l'app relisent aussi les sections « Autres sessions ».
- Supprimer une autre session depuis son détail la retire de l'historique, comme aujourd'hui.

### Bandeau d'avertissement (Q277)

- Affiché **quand le `super_admin` est hors participation**, sur les cinq écrans de session (salle
  d'attente, salle des présents, partie, détail d'une session terminée, formulaire de
  modification), qu'il y arrive par l'accueil, l'historique, un lien ou une autre liste.
- Y compris sur une session de son association qu'il suit en spectateur ou qu'il n'a pas jouée :
  il y voit les boutons d'organisateur, qu'un simple membre n'a pas.
- **Pas** de bandeau quand il est participant (joueur ou organisateur) : il est dans sa propre
  partie.
- **Rouge plein** (couleur « danger » de la palette, texte clair), en haut de l'écran, non
  refermable, avec une icône d'alerte. Texte : « Vous ne participez pas à cette session. Vous la
  voyez et la modifiez avec vos droits de super admin. » (EN : « You're not part of this session.
  You see and edit it with your super admin rights. »)

## Décisions techniques

- **Accueil : aucune migration.** `SessionsRepository.otherOngoingSessions`, appelée seulement si
  `isSuperAdmin` : une lecture de toutes les sessions `draft` et `live` (peu nombreuses par
  nature), triées en Dart par `otherSessionsForHome` : ni celles dont il est membre, ni celles
  en direct de son association (déjà dans « Mes sessions en cours »), de la plus récente à la
  plus ancienne (date de création). Écart avec la première rédaction, qui prévoyait un filtre
  d'absence côté serveur (PostgREST) : deux lectures simples, comme le reste du dépôt
  (`_mySessionsByStatus`), sans dépendre d'une fonction de PostgREST impossible à essayer depuis
  la session de l'assistant.
- **Rafraîchissement par dépendance** : « Autres sessions » de l'accueil est construite sur « Mes
  sessions en cours » (ses identifiants donnent les sessions à écarter), et celle de
  l'historique est lue après l'historique. Tout ce qui relit déjà ces listes (session démarrée,
  terminée, supprimée, rejointe, modifiée, tirer vers le bas, retour dans l'app) relit donc
  aussi les autres sessions, sans invalidation à ajouter ailleurs.
- **Historique : une migration, qui ne fait qu'ajouter une fonction** (règle 8 d'`AGENTS.md`).
  Nouvelle RPC `history_snapshots_others()`, même forme que `history_snapshots` (une liste de
  `session_snapshot`, lue par le même modèle `LiveSessionSnapshot` et le même calcul des
  gagnants) :
  - sessions terminées qui ne sont **pas** dans `history_snapshots` (complément exact de sa
    condition : non membre, et association différente de la sienne ou absente) ;
  - **vide pour tout compte qui n'est pas `super_admin`** (`is_super_admin()` dans la condition) :
    en plus des droits de lecture, qui ne lui laisseraient de toute façon rien de plus ;
  - `security invoker`, comme `history_snapshots` : les droits de lecture s'appliquent ;
  - exécutable par `authenticated` seulement.
  Rien ne change dans les données ni dans les fonctions existantes. Pas de sauvegarde
  nécessaire : aucune donnée transformée ni supprimée.
  Alternative écartée : lire la liste des sessions puis appeler `session_snapshot` pour chacune,
  qui ferait une requête par session (des dizaines d'allers-retours sur un téléphone).
- **Créateurs** : une lecture de `players` pour les noms (`user_id` = `owner_id`), pour les deux
  sections.
- **Répartition et règle du bandeau** écrites une fois, en Dart pur, testées unitairement
  (`lib/features/sessions/domain/other_sessions.dart`). Décision du bandeau dans une seule
  fonction, `isSuperAdminOutsider(...)`, à côté de `canOrganizeSession` (`session_member.dart`).
- **Interrupteur** : un seul fournisseur, `ShowOtherSessionsPref`, même modèle que
  `LibreRankingDirectionPref` (`shared_preferences`, clé `nuni.show_other_sessions`, `true` par
  défaut), lu par les deux pages : le changer sur l'une met l'autre à jour aussitôt. L'en-tête à
  interrupteur est un seul widget, partagé par les deux pages.
- **Bandeau** : `NuniAlertBanner` (`lib/shared/`), couleurs lues dans `colorScheme` (`error` /
  `onError`), jamais en dur, montré dans la galerie `/dev/theme` ; posé sur les écrans par
  `SuperAdminOutsiderBanner` (`features/sessions/ui/`), qui décide seul de s'afficher.
- Chaînes dans `app_en.arb` et `app_fr.arb` : titre de section, interrupteur, « Créée par … »,
  texte du bandeau.

## Étapes

1. Migration `history_snapshots_others` (`npx supabase migration new`), et sa section dans
   `supabase/tests/rls_smoke.sql` (voir Tests).
2. **Prévenir le PO de ce que change la migration** (une fonction ajoutée, rien d'autre), puis,
   sur son accord : répétition sur la base de production dans une transaction annulée, comme au
   plan 37, `npx supabase db push`, `rls_smoke.sql`.
3. Fonctions de répartition et règle du bandeau (domaine), avec leurs tests unitaires.
4. Requêtes et fournisseurs ; préférence de l'interrupteur.
5. Section « Autres sessions » de l'accueil, carte adaptée.
6. Section « Autres sessions » de l'historique, filtres sur les deux sections.
7. Bandeau sur les cinq écrans.
8. Chaînes EN et FR ; galerie `/dev/theme`.
9. `dart format`, `flutter analyze --fatal-infos`, `flutter test`.
10. Essai dans le navigateur intégré avec le compte du PO (`super_admin`), sur son accord :
    accueil et historique, interrupteur allumé et éteint depuis chaque page (l'autre suit),
    rechargement de la page (état gardé), ouverture d'une session d'un autre dans chaque état,
    bandeau présent ;
    ouverture d'une de ses sessions, bandeau absent. **Aucune modification d'une session réelle
    d'un autre.**
11. `AGENTS.md` (droits du `super_admin`, nouvelle RPC), plan et `QUESTIONS_PO.md` à jour.
12. Essai du PO. Commit et push seulement sur sa demande.

## Tests (`rls_smoke.sql`, section plan 38)

- Le `super_admin` reçoit, par `history_snapshots_others`, une session terminée d'une autre
  association à laquelle il n'a pas participé.
- Il n'y reçoit ni une session terminée de son association, ni une à laquelle il a participé (déjà
  dans `history_snapshots`), ni une session non terminée.
- Un membre ordinaire reçoit une liste vide.

## Critères d'acceptation

- [ ] Un compte qui n'est pas `super_admin` voit le même accueil et le même historique qu'avant,
  sans requête en plus.
- [ ] Accueil du `super_admin` : « Autres sessions » sous ses sessions, sans aucune session
  terminée, interrupteur allumé au premier lancement.
- [ ] Historique du `super_admin` : « Autres sessions » sous son historique, avec toutes les
  autres sessions terminées, interrupteur allumé au premier lancement.
- [ ] Éteint, chaque page est celle d'aujourd'hui ; l'interrupteur est le même sur les deux
  pages, et son état survit à un rechargement.
- [ ] Aucune session n'apparaît deux fois sur une même page.
- [ ] Chaque carte d'une autre session montre son créateur ; sur l'accueil, son état.
- [ ] Les trois filtres de l'historique s'appliquent aux deux sections.
- [ ] Le bandeau rouge apparaît sur les cinq écrans quand il est hors participation, et jamais
  quand il est participant.
- [ ] Ouvrir une session d'un autre n'y écrit rien (pas de ligne dans `session_members`).
- [ ] `rls_smoke.sql` vert en production ; chaînes EN et FR ; analyse sans avertissement ; tests
  verts.

## Hors périmètre

- Chargement par pages de l'historique : il charge déjà tout, avec le contenu de chaque session ;
  la section « Autres sessions » suit le même principe. À reprendre dans un plan à part si le
  volume le rend lent.
- Le `super_admin` participant comme simple joueur garde les actions d'organisateur sans
  bandeau (Q262, Q277).
- Recherche ou filtre par association ou par créateur.
- Statistiques, records, badges et championnat : inchangés (ils ne lisent pas l'historique).
- Toute autre liste réservée au `super_admin` (événements, trous…).
