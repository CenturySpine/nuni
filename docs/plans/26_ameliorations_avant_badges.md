# Plan 26 — Améliorations avant les badges : trous, par de session, association, profil public

## Statut

Demande PO du 2026-09-24 (réponse à Q110), **prioritaire** : à implémenter avant les plans 19,
20 et 21, qui en dépendent (tous les calculs de coups lisent le par du trou joué). Plan détaillé
rédigé le 2026-09-24. **Mise en œuvre demandée par le PO le 2026-09-24** (« prio pour
l'implem ») : premier lot, avant les badges. Trois volets : A (trous, par et commentaire de
session ; Q118 à Q122 tranchées), B (sessions et championnat visibles par l'association,
marquage « championnat » réservé aux responsables ; Q126, Q129 à Q132 tranchées) et C (profil
public d'un joueur, pseudo et photo seulement). Plus de question ouverte.

## En bref, pour les joueurs

- Il n'y a plus de trou privé : tout trou est visible par tous et jouable dans n'importe quelle
  session. Seul son auteur peut le modifier.
- On peut cloner un trou existant pour en faire sa propre version : le clone s'appelle
  « Clone - <nom> », on en devient l'auteur et on peut le modifier librement.
- En ajoutant un trou à une session, l'organisateur peut lui donner un commentaire (« départ
  depuis le banc ») et un par propre à cette session, par exemple pour une variante plus dure.
- Un trou libre demande désormais son par : chaque trou joué a un par, ce qui permet de
  calculer statistiques et badges sur tous les trous.
- Toutes les sessions de mon association, en cours ou passées, me sont visibles, même si je n'y
  ai pas joué. Je peux suivre une session en cours sans y saisir de score.
- Seuls le responsable local de l'association et le super administrateur peuvent marquer une
  session « championnat », à tout moment, même s'ils n'y ont pas joué.
- L'historique montre les sessions terminées de mon association ; un repère discret signale
  celles où j'ai joué, et un filtre n'affiche que les miennes.
- Un appui sur un joueur (classement, équipe, historique) ouvre sa fiche publique : son pseudo
  et sa photo, rien de plus pour l'instant.

## Objectif

Simplifier le référentiel des trous (une seule visibilité), permettre de s'approprier un trou
existant, et rendre chaque trou joué autonome : son par et son commentaire appartiennent à la
session, pas au trou. Faire de l'association le cadre commun des sessions : tout membre les
voit, et le championnat est contrôlé par le responsable local plutôt que par chaque
organisateur.

## Prérequis

Plans 06 (trous), 08 (session en direct), 10 (historique), 15 (championnat), 16 (rôles), 17
(trou libre) et 18 (associations, responsables locaux) livrés.

## Décisions retenues

### Volet A — trous, par et commentaire de session

1. **Tous les trous sont publics (PO, Q110).** Visibles et utilisables par tous dans les
   sessions ; modification et suppression réservées à l'auteur (inchangé). La notion de trou
   privé disparaît de la base et de l'app. Les trous aujourd'hui privés deviennent visibles par
   tous à la reconstruction de la base ; sans impact selon le PO (2026-09-24) : l'app n'est pas
   encore utilisée et il est le seul à avoir créé des trous.
2. **Clonage (PO).** Depuis la fiche d'un trou, « Cloner » crée un nouveau trou dont on devient
   l'auteur, nommé « Clone - » suivi du nom d'origine (préfixe identique en français et en
   anglais), avec tous les autres champs recopiés : description, par, distance, départ, cible,
   tracé. Le clone s'ouvre aussitôt en édition. Cloner un clone ajoute un nouveau préfixe ; on
   peut renommer.
3. **Commentaire de trou joué (PO).** Texte facultatif propre au passage du trou dans la
   session (`played_holes.comment`), jamais au trou lui-même.
4. **Par de trou joué (PO).** Un par propre à la session prend le pas sur le par officiel du
   trou, pour une variante plus dure (ou plus facile) le temps d'une session.
5. **Par obligatoire pour un trou libre (PO).** L'ajout d'un trou libre exige un par ; ainsi
   tout trou joué a un par, et les calculs de coups (plans 19 à 21) valent pour tous les trous.
   Remplace la décision Q57 du plan 17 (« ni par ni distance »).
6. **Par figé (Q118).** `played_holes.par` toujours rempli, copié du par officiel à l'ajout et
   modifiable, valeurs 1 à 10. Un par officiel modifié plus tard ne change pas les sessions
   passées.
7. **Photos du clone (Q119).** Copiées dans le dossier de la personne qui clone.
8. **Clones et badges (Q120).** `holes.cloned_from` retient le trou d'origine ; un clone ne
   compte pas pour les badges H1 et H2 (plan 21).
9. **Qui et quand (Q121).** L'organisateur saisit par et commentaire à trois moments : dans la
   feuille de choix du trou pendant la session, au moment de l'ajouter ; sur la carte du trou
   déjà ajouté, pendant la session ; depuis le détail de la session dans l'historique. Le
   commentaire s'affiche en direct et dans l'historique, pas dans les exports.
10. **Trous libres déjà joués (Q122).** Par de 3, posé à la reconstruction de la base.

### Volet B — sessions et championnat de l'association (PO, 2026-09-24, suite de Q126)

11. **Marquage « championnat » réservé (PO).** Seuls un `super_admin` (plan 16) et le
    responsable local approuvé de l'association de la session (plan 18) peuvent marquer ou
    démarquer une session « championnat », à tout moment, y compris après sa fin et sans y
    avoir joué. Remplace la décision 1 du plan 15 (« seul le créateur tague »). Un organisateur
    qui n'est pas responsable ne voit plus la case « championnat » à la création.
12. **Sessions visibles par l'association (PO).** Toute session, en cours ou terminée, est
    lisible par tous les membres de son association (`players.association_id =
    sessions.association_id`), en plus de ses participants (inchangé, y compris les visiteurs
    d'une autre association). Détail : équipes, trous joués, scores, photos, classement.
13. **Lecture seule pour les non-participants.** Un membre de l'association qui n'a pas rejoint
    la session la suit sans rien modifier : les règles d'écriture actuelles (scores par l'équipe
    rattachée ou l'organisateur, trous par l'organisateur) ne changent pas. L'écran de session
    masque les commandes de saisie à ceux qui ne peuvent pas écrire.
14. **Championnat visible par l'association.** Déjà le cas pour le classement
    (`championship_association_results`, lisible par tout compte connecté) ; la décision 12
    ajoute l'accès au détail de chaque session du championnat.

15. **Championnat sans règle d'éligibilité (Q126).** Le classement du championnat compte
    toutes les sessions marquées : le marquage par le responsable est le contrôle. La règle
    des 3 joueurs et 3 trous reste pour les statistiques et les badges (plans 19 à 21).
16. **Historique (Q129).** Par défaut, les sessions **terminées** de mon association ; un
    repère visuel simple et sobre signale celles où j'ai joué ; un filtre « Mes sessions »
    n'affiche que celles-là. Les sessions en cours n'apparaissent pas dans l'historique.
17. **super_admin (Q130).** Il garde le droit de lire et marquer toute session (base), en
    secours ; l'interface ne lui liste rien de plus : il voit, comme tout membre, les sessions
    de sa propre association. Le responsable local reste l'acteur principal.
18. **Marquages existants (Q131).** Les sessions déjà marquées « championnat » le restent.

19. **Sessions en cours de l'association (Q132).** Les sessions **en cours** de mon
    association, auxquelles je ne participe pas, apparaissent sur l'accueil, dans la section « Sessions en cours » existante, après les
  miennes ; un appui ouvre l'écran de session en lecture seule. Les sessions en brouillon
  (salle d'attente) restent visibles de leurs seuls participants.

### Volet C — profil public d'un joueur (PO, 2026-09-24)

20. **Fiche publique minimale.** Nouvelle route `/players/:id` : photo (ou avatar à initiales,
    `NuniAvatar`) et pseudo, **rien d'autre** pour l'instant. Les statistiques (plan 19) et les
    badges (plan 21) s'y ajouteront plus tard. Tout compte connecté peut ouvrir la fiche de
    n'importe quel joueur (la table `players` est déjà lisible par tous), joueurs importés sans
    compte compris.
21. **Points d'entrée.** Un appui sur le nom ou l'avatar d'un joueur ouvre sa fiche :
    classement d'une session (en direct et dans l'historique), composition des équipes,
    classement du championnat. Mon profil (`/profile`) propose « Voir mon profil public ».

## Parcours et écrans

- **Trous** (`holes_page.dart`, `hole_detail_sheet.dart`, `hole_form_page.dart`) : le choix
  « Public / Privé » et la pastille de visibilité disparaissent. La fiche d'un trou gagne un
  bouton « Cloner », visible par tout utilisateur connecté, y compris l'auteur.
- **Ajout d'un trou à la session** (`add_played_hole_sheet.dart`) :
  - trou du référentiel : après le choix du trou, un sélecteur de par préréglé sur le par
    officiel et un champ « Commentaire » facultatif ;
  - trou libre : libellé facultatif (inchangé), par **obligatoire sans valeur préréglée** (le
    bouton d'ajout reste inactif tant qu'il n'est pas choisi), commentaire facultatif.
- **Carte du trou joué** (`played_hole_card.dart`) : affiche le par du trou joué (et « par
  officiel 3 » en petit s'il diffère), le commentaire sous le nom ; pour l'organisateur, une
  action « Modifier » ouvre la même feuille par + commentaire. La pastille « privé » disparaît.
- **Historique** (`history_detail_page.dart`) : par du trou joué et commentaire affichés ;
  l'organisateur peut les corriger (Q121).
- **Historique, liste** (`history_page.dart`) : sessions terminées de mon association ; repère
  discret (petite icône ou pastille) sur celles où j'ai joué ; filtre « Mes sessions » (puce
  `NuniChip`) ; pas de session en cours (Q129).
- **Accueil** (`home_page.dart`), section « Sessions en cours » : mes sessions, puis celles de
  mon association en cours (Q132), ouvertes en lecture seule pour un non-participant.
- **Fiche joueur** (nouvelle, `lib/features/players/ui/player_page.dart`) : `NuniHero` ou
  en-tête simple avec avatar et pseudo. Points d'entrée listés en décision 21.
- **Création de session** (`session_create_page.dart`) : la case « championnat » n'apparaît
  que pour un responsable local de l'association ou un `super_admin`.
- **Marquage après coup** : dans le détail d'une session (`history_detail_page.dart`,
  `session_edit_sheet.dart`) et sur l'écran d'une session en cours, un interrupteur
  « Championnat » visible seulement du responsable local et des `super_admin`, même s'ils n'y
  ont pas joué.

## Modèle de données

Fichiers thématiques existants modifiés (règle 8), pas de nouvelle migration.

- `extensions_and_enums.sql` : suppression du type `hole_visibility`.
- `tables.sql` :
  - `holes` : suppression de `visibility` ; ajout de `cloned_from uuid references holes (id) on
    delete set null` (Q120).
  - `played_holes` : ajout de `par int not null check (par between 1 and 10)` (Q118) et
    `comment text` (vide = pas de commentaire).
- `rls.sql` : `holes_select` devient « tout utilisateur connecté lit tous les trous » ; les
  politiques d'écriture ne changent pas. `played_holes_owner_write` couvre déjà la modification
  du par et du commentaire par l'organisateur.
- `rpc.sql` :
  - `holes_nearby` : plus de colonne `visibility`, renvoie tous les trous du rayon ;
  - `add_played_hole` : nouveaux paramètres `p_par` et `p_comment`. Trou du référentiel : `p_par`
    vide = par officiel du trou. Trou libre : `p_par` obligatoire, erreur sinon (le client ne
    peut pas contourner la règle) ;
  - `session_snapshot` : ajoute `par` et `comment` à chaque trou joué, retire `visibility` du
    trou ;
  - nouvelle `clone_hole(p_hole_id uuid)`, `security invoker` : insère la copie avec l'appelant
    comme auteur, le préfixe « Clone - » et `cloned_from`, et renvoie la nouvelle ligne. Les
    photos sont copiées ensuite par l'app dans `holes/<id de l'appelant>/<id du clone>/`, ce que
    les règles actuelles du stockage autorisent (lecture publique du bucket, écriture dans son
    propre dossier), puis enregistrées sur le clone (Q119).
- `storage.sql` : inchangé (le bucket des photos de session est déjà en lecture publique).
- Volet B :
  - `utility_functions.sql` : nouvelle `can_read_session(p_session_id)` = participant
    (`is_session_member`) **ou** membre de l'association de la session **ou** `is_super_admin()`
    (Q130 : possibilité gardée en base, rien de plus dans l'interface) ;
  - `rls.sql` : les politiques de lecture de `sessions`, `teams`, `team_players`,
    `session_members`, `played_holes`, `scores` et `session_photos` passent de
    `is_session_member` à `can_read_session` ; les politiques d'écriture ne changent pas, sauf
    `sessions_update_owner`, qui ne permet plus à l'organisateur de changer
    `is_championship` (garde dans `triggers.sql`, même mécanisme que `association_id`) ;
  - `rpc.sql` : nouvelle `set_session_championship(p_session_id uuid, p_value boolean)`,
    `security definer`, autorisée au seul `super_admin` et au responsable approuvé de
    l'association de la session (`is_association_manager`) ; `create_session` ignore
    `is_championship` si l'appelant n'est ni l'un ni l'autre ; `history_snapshots` renvoie les
    sessions terminées de l'association de l'appelant, avec pour chacune un indicateur « j'y
    ai joué » (le filtre « Mes sessions » est appliqué dans l'app) ; nouvelle
    `association_live_sessions()` pour l'accueil (Q132).
- Volet C : aucun changement de base (`players_select` lit déjà tous les joueurs).

## Code

- `lib/features/holes/domain/hole.dart` : suppression de `HoleVisibility`, ajout de
  `clonedFrom`.
- `lib/features/holes/data/holes_repository.dart` : plus de `visibility` ; méthode `cloneHole`
  (RPC puis copie des photos).
- `lib/features/live/domain/played_hole.dart` : `par` et `comment` sur le trou joué ; le trou du
  référentiel perd `visibility`.
- `lib/features/live/data/live_repository.dart` : `addPlayedHole` avec par et commentaire,
  `updatePlayedHole(par, comment)`.
- Écrans cités plus haut ; nouvelle feuille `played_hole_settings_sheet.dart` (par +
  commentaire), réutilisée à l'ajout et en modification.
- Les calculs existants n'utilisent pas le par (classements en coups et en points) : aucun
  changement de classement ni de championnat.
- Chaînes EN/FR : bouton « Cloner », « Commentaire », « Par de la session », « par officiel »,
  message d'erreur « par obligatoire », etc. Les chaînes de visibilité sont supprimées.

- Volet B : `lib/features/history/data/history_repository.dart` (portée « mes sessions /
  association »), `sessions_repository.dart` (`setChampionship` par la RPC), écran de session
  en lecture seule pour un non-participant, droits « responsable ou super_admin » lus une fois
  par un fournisseur Riverpod.
- Volet C : `lib/features/players/` (données : lecture d'un joueur par id ; écran ; route
  dans `app_router.dart`) ; les listes de joueurs existantes deviennent cliquables.
- Temps réel : les abonnements restent filtrés par session ; Supabase applique la nouvelle
  lecture (RLS), donc un spectateur reçoit les scores en direct sans rien de plus.

## Reprise de l'existant et reconstruction

La reconstruction suit `docs/DEV.md` (règle 8), **PO prévenu avant de la lancer** :

1. Adapter `tool/export_remote_seed.dart` pour qu'il écrive les seeds au nouveau format à
   partir de la base actuelle : plus de `visibility` sur les trous ; `par` de chaque trou joué =
   par officiel du trou, ou 3 pour un trou libre (Q122) ; `comment` vide.
2. Régénérer les seeds, relire le diff, les committer avec l'accord du PO.
3. Reconstruire le schéma distant, rejouer les seeds.
4. `tool/migrate_lsgscores.dart` : retirer `visibility`, poser `played_holes.par` depuis le trou
   importé (outil gardé pour un éventuel rejeu).

## Étapes (développement)

1. Schéma, RLS et RPC dans les fichiers thématiques ; tests d'accès dans
   `supabase/tests/rls_smoke.sql` (lecture de tous les
   trous par tout compte, modification refusée à un non-auteur, trou libre sans par refusé par
   `add_played_hole`, clone appartenant à l'appelant).
2. Modèles Dart, dépôts, génération (`build_runner`), tests unitaires (lecture des snapshots
   avec par et commentaire, clonage).
3. Écrans des trous : retrait de la visibilité, bouton « Cloner ».
4. Session en direct et historique : feuille par + commentaire, affichage sur la carte.
5. Volet B : `can_read_session`, politiques de lecture, garde sur `is_championship`, RPC
   `set_session_championship` et `history_snapshots` ; tests d'accès (membre de l'association
   non participant : lit, ne peut pas écrire un score ; membre d'une autre association : ne lit
   pas ; organisateur non responsable : ne peut pas marquer « championnat », même par appel
   direct ; responsable non participant : peut). Écrans : Historique à deux portées, lecture
   seule, interrupteur « Championnat », historique de l'association avec repère et filtre,
   sessions en cours de l'association sur l'accueil.
6. Volet C : route `/players/:id`, écran, points d'entrée, « Voir mon profil public ».
7. Outils de seed et d'import ; seeds régénérés ; **reconstruction de la base, PO prévenu**.
8. Mise à jour des plans et de la documentation : plans 06, 15 et 17 (note de mise à jour),
   19, 20, 21 (par du trou joué, trous libres compris dans les calculs de coups), `AGENTS.md`
   relu.
9. Vérification : `fvm dart format`, `fvm flutter analyze --fatal-infos`, `fvm flutter test`,
   essai dans le navigateur (cloner un trou avec photos, session avec un trou à par modifié, un
   trou libre, un commentaire), puis test par le PO.

## Critères d'acceptation

- Un trou créé par un autre utilisateur est visible dans la liste, sur la carte et proposé à
  l'ajout dans une session ; seul son auteur voit « Modifier ».
- « Cloner » crée « Clone - <nom> » appartenant à l'utilisateur, avec ses propres photos ; le
  modifier ne change pas l'original, et inversement.
- Un trou libre ne peut pas être ajouté sans par, ni depuis l'app ni par un appel direct à la
  base.
- Un trou joué affiche son par de session et son commentaire, en direct et dans l'historique ;
  l'organisateur peut les modifier, les autres joueurs non.
- Modifier le par officiel d'un trou ne change pas le par des sessions passées.
- Après reconstruction : mêmes trous (ceux qui étaient privés compris), mêmes sessions, chaque
  trou joué a un par ; classements et championnat inchangés.
- L'historique montre les sessions terminées de mon association, y compris celles où je n'ai
  pas joué ; un repère signale les miennes ; le filtre « Mes sessions » n'affiche qu'elles ;
  aucune session en cours n'y figure.
- Un membre de l'association suit une session en cours depuis l'accueil, sans pouvoir y saisir
  de score ; un membre d'une autre association qui n'y a pas joué ne la voit pas.
- Un appui sur un joueur dans un classement ou une équipe ouvre sa fiche : photo et pseudo
  seulement ; « Voir mon profil public » depuis mon profil y mène aussi.
- Seuls le responsable local et un `super_admin` peuvent marquer une session « championnat »,
  depuis l'app ou par un appel direct à la base ; le responsable le peut sans avoir joué.
- Chaînes EN/FR, `flutter analyze` sans remarque, tests verts, build Vercel vert.

## Hors périmètre

- Fusionner ou lier des trous (un clone est un trou indépendant).
- Commentaire ou par dans les exports PDF et image (Q121).

## Questions PO liées

Volet A, toutes tranchées : Q110 (plus de trou privé), Q57 (plan 17, remplacée par la
décision 5), Q118 (par figé), Q119 (photos copiées), Q120 (clone hors badges H1, H2), Q121 (à
l'ajout, sur la carte, dans l'historique), Q122 (par 3 pour les trous libres déjà joués).
Volet B, tranchées : Q126 (championnat sans règle d'éligibilité), Q129 (historique de
l'association, repère, filtre), Q130 (super_admin en secours, sans liste dédiée), Q131
(marquages existants conservés). Q132 (sessions en cours de l'association sur
l'accueil).
