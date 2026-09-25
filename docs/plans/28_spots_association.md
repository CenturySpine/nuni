# Plan 28 — Associations : référentiel de spots

## Statut

Plan rédigé le 2026-09-25 à partir de la demande du PO du même jour. **Validé par le PO le
2026-09-25** (premier jet), toutes les suggestions retenues (Q178 à Q185 tranchées) ;
implémentation demandée le même jour.

**Implémenté, essayé et validé par le PO le 2026-09-25 ; plan clôturé.**

Complément PO après essai : l'écran « Spots » est ouvert à tout compte connecté (lecture seule hors de l'association) et sa tuile passe au-dessus des partenaires. La règle de lecture `spots_select` a été remplacée seule dans la base distante (suppression puis recréation, texte identique à `rls.sql`), au lieu d'une reconstruction complète : choix du PO, écart documenté à la règle 8 d'`AGENTS.md`. `rls_smoke.sql` relancé ensuite : 105 tests verts (un test corrigé pour ne chercher « Surprise » que dans l'association de test), nettoyage complet.

**Base distante reconstruite le 2026-09-25** (seeds commités avant, `fde20bc` ; étapes 1 à 7 et
6b par le PO, le contrôle automatique des permissions ayant bloqué l'assistant) : comptages
identiques à l'export, 6 spots, 7 sessions et 37 événements sur 38 rattachés (le 38e n'avait pas
de lieu). `rls_smoke.sql` : 105 tests d'accès verts, dont 18 du plan 28, nettoyage complet.
Essayé dans le navigateur intégré (compte du PO, super_admin) : tuile « Spots », liste et carte,
« Emplacement variable » pour Surprise, « À compléter » ; Croix-Rousse complété par la recherche
d'adresse (le point suit, et les 9 événements liés ont reçu le point, vérifié en base) ; point
posé sur la carte → adresse remplie ; création de session : champ Spot, liste, « + » avec nom
prérempli et carte faute de position, spot créé avec son adresse puis supprimé (confirmation
« aucune session ni aucun événement ») ; formulaire d'événement : spots proposés, point repris.
Trois défauts corrigés pendant l'essai : liste triée à l'envers, choix d'une adresse proposée
sans effet, carte non recadrée après ajout d'un point. **Non vérifié dans le navigateur** : la
création effective d'une session (elle aurait ajouté une vraie session), la vue d'un membre
simple (sans boutons d'édition) et le « + » avec position connue ; couverts par les tests
d'accès et d'écran.

Historique : **code écrit le 2026-09-25, avant reconstruction.** Vérifié : `flutter analyze
--fatal-infos` sans remarque, 455 tests Flutter verts (dont les nouveaux : règles des spots,
client de géocodage, champ Spot obligatoire à la création de session). Seeds réexportés (étape 0),
**non commités**. **Pas encore vérifié** : les 15 tests d'accès du plan 28 dans `rls_smoke.sql`
(ils exigent la base reconstruite), l'essai dans le navigateur intégré (même raison), la reprise
des lieux existants (liste relue par le PO, Q185 ; aperçu vérifié en lecture seule sur la base
actuelle : 6 spots, INSA avec 7 sessions et 20 événements).
Écarts avec le plan, décidés à l'implémentation :
- Une seule RPC de création, `create_spot`, au lieu de `create_spot` + `quick_create_spot` :
  ouverte à tout membre, elle ignore la description quand l'appelant n'est pas du staff. Même
  effet, une fonction de moins.
- Les copies (`sessions.zone` et `city`, `events.spot` et le point) sont tenues à jour par la
  base à chaque renommage ou déplacement du spot, au lieu que l'affichage lise le spot : tous
  les écrans, exports et l'historique continuent de lire la copie sans changement, pour le même
  résultat visible (nom actuel tant que le spot existe, dernier nom sinon).
- Le point d'une session reste la position de son créateur (celui du spot à défaut) : il sert à
  la météo et aux badges « Explorateur », qu'il ne fallait pas changer pour les sessions passées.
- Ajout demandé par le PO en cours d'implémentation (Q186) : case « Emplacement variable »
  (responsables seulement) pour un spot comme « Surprise » : ni point ni adresse, jamais « À
  compléter » ; chaque événement garde le point posé sur sa carte, chaque session le point de son
  événement ou la position de son créateur, et sa ville est déduite de ce point (Q11). Un spot
  repris sans point et non variable (Tee Time…) reste modifiable sans en ajouter un.
- Événement : le lien au spot se fait par le nom tapé ou choisi (identique à un spot, sans tenir
  compte de la casse), sans case à cocher.

## Objectif

1. Chaque association a un **référentiel de spots** : libellé libre, description libre,
   emplacement (point sur la carte et adresse, toujours synchronisés).
2. Le responsable local, les administrateurs locaux et le `super_admin` le gèrent (création,
   modification, suppression) sur un **écran séparé**, ouvert depuis la page de l'association.
3. **Événement** : le lieu se choisit parmi les spots **ou** reste une saisie libre (AG, repas
   de Noël…).
4. **Session** : le spot est **obligatoire et choisi dans le référentiel**. Un bouton « + »
   crée un spot à la volée : un nom, la position courante du créateur ; il rejoint le
   référentiel, que les responsables complètent ensuite.

Ce plan remplace Q148 (lieux déduits de l'existant, sans table) pour les sessions et les
événements. Les libellés d'événements (Q147) ne changent pas.

## Existant (pour mémoire)

- `sessions` : `city` (détectée par géocodage inverse, Q11), `zone` (texte libre facultatif,
  suggestions tirées des zones et lieux déjà utilisés dans l'association), `location` (position
  du créateur).
- `events` : `spot` (texte libre), `location` (point facultatif, `NuniLocationPicker`).
- Géocodage : BigDataCloud, sens point → ville seulement ; aucun service adresse → point.

## Décisions retenues

- **Table `spots`** : `id`, `association_id`, `name` (unique par association, sans tenir compte
  de la casse, Q183), `description`, `address`, `city`, `location` (obligatoire, Q181),
  `created_by`, dates. Lecture : tout compte connecté, pour une association validée (complément PO du 2026-09-25 à Q180). Écriture : RPC `security definer`,
  comme pour les associations : `update_spot` / `delete_spot` réservées à
  `is_association_staff`, `create_spot` ouverte à tout membre (Q180 ; description réservée au
  staff).
- **Lien et copie** (Q182) : `sessions.spot_id` et `events.spot_id` (nullables, `on delete set
  null`). Le nom du spot est copié dans `sessions.zone` / `events.spot` à l'enregistrement.
  L'affichage lit le nom actuel du spot s'il existe encore, sinon la copie : un renommage se
  voit partout, une suppression ne vide pas l'historique. Même logique que `played_holes.par`.
- **Session** : `create_session` exige un `spot_id` de l'association du créateur (les sessions
  importées et anciennes gardent `spot_id` nul). Le champ « Zone » devient « Spot » (liste du
  référentiel, les plus proches de la position d'abord, puis « + »). La ville de la session est
  celle du spot, le champ ville disparaît du formulaire (Q184). Une session démarrée depuis un
  événement lié à un spot le reprend.
- **Événement** : le champ lieu propose les spots ; en choisir un pose `spot_id` et le point ;
  taper un texte qui n'est pas un spot reste permis (`spot_id` nul, point facultatif comme
  aujourd'hui). L'import d'agenda reste en texte libre, rapproché d'un spot quand le nom est
  identique.
- **Adresse ↔ point** (Q178, Q179) : un service de géocodage gratuit sans clé (Photon, données
  OpenStreetMap). Poser le point remplit l'adresse ; choisir une adresse dans les propositions
  place le point. L'adresse n'est modifiable que par cette recherche, pour ne jamais diverger
  du point.
- **Reprise de l'existant** (Q185) : le référentiel de chaque association est pré-rempli, une
  fois, avec les lieux d'événements et zones de sessions déjà saisis (point repris quand il est
  connu, sinon à compléter), puis les sessions et événements concernés sont liés.
- **Écran « Spots »** (Q180) : liste + carte de tous les spots, lisible par
  les membres, boutons d'édition pour les responsables. Un spot sans point ou sans adresse est
  signalé « à compléter ».

## Parcours

- Page de l'association → tuile « Spots », au-dessus des partenaires, visible de tous → liste (nom, adresse, nombre de sessions) et carte.
  Responsables : « Ajouter », toucher un spot pour le modifier, supprimer avec confirmation
  (« utilisé par N sessions et M événements, qui garderont son nom »).
- Formulaire spot : nom, description, carte (`NuniLocationPicker`) et champ adresse avec
  propositions, synchronisés.
- Création de session : champ « Spot » obligatoire ; « + » ouvre une petite feuille : nom seul,
  point = position courante (si la position est refusée, la carte s'affiche pour poser le
  point). Le spot est créé et sélectionné.
- Formulaire d'événement : même champ, avec saisie libre permise.

## Étapes

1. Schéma : table `spots`, colonnes `spot_id`, RLS, RPC, `create_session` modifiée,
   `rls_smoke.sql` complété. Reprise de l'existant (script SQL relu par le PO).
2. Client de géocodage (recherche d'adresse, point → adresse et ville), testé avec un client
   HTTP simulé.
3. Domaine et dépôt `lib/features/spots/`, écran liste/carte, formulaire.
4. Création de session : champ Spot, « + », suppression du champ ville.
5. Formulaire d'événement et import d'agenda.
6. Affichages (historique, live, exports, planning) : nom actuel du spot ou copie.
7. Seeds régénérés et commités avec l'accord du PO, base reconstruite (règle 8, PO prévenu
   avant), export des seeds étendu à `spots`.
8. Chaînes EN/FR, tests, essai dans le navigateur intégré.

## Critères d'acceptation

- Un responsable ou administrateur local crée, modifie, supprime un spot ; un membre ne voit
  que la liste et la carte.
- Poser un point remplit l'adresse ; choisir une adresse déplace le point.
- Impossible de créer une session sans spot ; « + » crée un spot à la position courante, visible
  ensuite dans le référentiel.
- Un événement accepte un spot ou un texte libre.
- Renommer un spot change son nom dans les sessions et événements liés ; le supprimer laisse
  l'ancien nom affiché.
- Sessions et événements existants rattachés aux spots repris.

## Hors périmètre

- Trous rattachés à un spot (les trous restent communs à toutes les associations, plan 26).
- Fusion de deux spots en doublon (on renomme puis supprime ; à voir si le besoin apparaît).
- Gestion des libellés d'événements (Q147, plus tard).
