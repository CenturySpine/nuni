# Plan 27 — Associations : administrateurs locaux et partenaires

## Statut

Plan rédigé le 2026-09-25 à partir de la demande du PO du même jour. **Validé par le PO le
2026-09-25**, toutes les suggestions retenues (Q170 à Q176 tranchées) ; implémentation
demandée le même jour.

**Implémenté, essayé et validé par le PO le 2026-09-25 ; plan clôturé.** Vérifié : `flutter analyze --fatal-infos` sans remarque, 445
tests Flutter verts (dont 6 nouveaux : lecture des partenaires, sections Administrateurs
locaux et Partenaires de la page de l'association). Seeds commités avant (`eaee2e0`), base
distante reconstruite le même jour (étape 1 par l'assistant, avec un script de suppression
nommant chaque objet ; étapes 2 à 7 par le PO, le contrôle automatique des permissions ayant
bloqué l'assistant), comptages identiques à l'export. `rls_smoke.sql` : 87 tests d'accès verts,
dont les 17 du plan 27, nettoyage complet. Essayé dans le navigateur intégré (compte du PO,
super_admin) : nomination d'un compte de test (le responsable est exclu de la liste, recherche
par nom), retrait avec confirmation ; formulaire : ajout de deux partenaires, « Lien invalide »
refusé, ordre changé par glisser, enregistrement, affichage dans l'ordre sur la page avec
l'icône de lien seulement pour le partenaire qui en a un, contenu vérifié en base.
**Non vérifié dans le navigateur** : ce que voit un administrateur local lui-même (bouton
« Ne plus être administrateur local », interrupteur « Championnat », actions du planning) :
il faudrait se connecter avec un autre compte. Couvert par les tests d'accès et d'écran.
Écarts avec le plan, décidés à l'implémentation :
- Libellé à l'écran : « Administrateurs locaux » (« Local admins »), car « administrateur »
  seul désigne déjà le `super_admin` dans l'app (Q177).
- Le bloc Partenaires n'apparaît que dans la modification d'une association existante, pas
  dans la demande de création (comme le logo).
- Un administrateur qui devient responsable local perd sa ligne d'administrateur (il a déjà
  tous les droits).
- L'export des seeds lit toutes les colonnes des associations (partenaires compris) et les
  administrateurs locaux, pour qu'ils survivent aux reconstructions.

## Objectif

1. Le responsable local (ou un `super_admin`) peut nommer un ou plusieurs **administrateurs**
   parmi les membres de l'association, et les retirer.
2. Un administrateur a les mêmes droits que le responsable local, **sauf la modification des
   informations de l'association**.
3. Les informations de l'association peuvent lister un ou plusieurs **partenaires** (sponsors
   ou collaborateurs) : un libellé libre et un lien internet chacun.

## État actuel : droits du responsable local (pour vérification)

Relevé dans le code le 2026-09-25 (SQL de `supabase/migrations/` et écrans). Le `super_admin`
a partout les mêmes droits que le responsable local, en plus des siens.

| # | Droit du responsable local | Où c'est appliqué | Administrateur (plan 27) |
|---|---|---|---|
| 1 | Modifier les informations de l'association : nom, abréviation, ville, position sur la carte, site web | RPC `update_association` ; bouton « Modifier » de la page de l'association | **Non** |
| 2 | Ajouter, changer ou retirer le logo de l'association | Stockage `association-logos` | **Non** (fait partie des informations) |
| 3 | Modifier son propre mail et son propre téléphone de responsable (jamais visibles des membres) | RPC `update_association`, table `association_manager_contacts` | Sans objet (un administrateur n'a pas de coordonnées de responsable) |
| 4 | Marquer ou démarquer une session « championnat », à tout moment, avant, pendant ou après la partie, qu'il y joue ou non | RPC `set_session_championship`, déclencheur de garde ; interrupteur à la création, en salle d'attente, en direct et dans l'historique | Oui |
| 5 | Planning : modifier et supprimer n'importe quel événement de l'association (pas seulement les siens) | `can_manage_event` | Oui |
| 6 | Planning : supprimer n'importe quel commentaire (modération) | Politique `event_comments_delete` | Oui |
| 7 | Planning : importer un agenda (fichier `.ics`), qui remplace les événements importés à venir | RPC `import_events` et `import_events_preview` ; bouton « Importer » du planning | Oui |
| 8 | Planning : « Démarrer la session » depuis l'événement du jour (session liée à l'événement, présents ajoutés) | Déclencheur `sessions_guard_event` | Oui |
| — | Contrainte : ne peut pas quitter l'association qu'il gère (Q146) | Page de l'association | Non : un administrateur peut la quitter (Q171) |

Ce que le responsable local **ne peut pas** faire, réservé au `super_admin` : valider ou
refuser une création d'association ou une revendication de responsable, retirer un
responsable, supprimer une association, changer l'association d'une session.

Nouveau droit introduit par ce plan, réservé au responsable local et au `super_admin` (pas aux
administrateurs) : nommer et retirer les administrateurs.

## Décisions retenues

1. **Un administrateur est un membre de l'association** (joueur lié à un compte, dont
   l'association est celle-ci). Le responsable local n'est pas administrateur de sa propre
   association : il a déjà tous les droits.
2. **Qui nomme, qui retire** : le responsable local et le `super_admin`. Un administrateur ne
   nomme personne.
3. **Droits de l'administrateur** : les droits 4 à 8 du tableau, et eux seuls.
4. **Pas de validation par un `super_admin`** pour une nomination : le responsable local est
   déjà validé, il engage son association. Effet immédiat.
5. **Hypothèses en attente** (questions ouvertes) : un administrateur peut renoncer lui-même
   (Q170) ; il perd le rôle en quittant l'association, et peut la quitter (Q171) ; les
   administrateurs restent en place quand le responsable est retiré (Q172) ; pas de nombre
   maximal (Q173) ; la liste des administrateurs est visible de tous sur la page de
   l'association (Q174).
6. **Partenaires** : une liste ordonnée de couples libellé + lien, modifiée dans le formulaire
   de l'association, donc par le responsable local et le `super_admin` seulement (droit 1).
   Affichée sur la page de l'association, visible de tous, chaque libellé ouvrant son lien
   dans un nouvel onglet. Titre de section, lien obligatoire ou non, ordre et limite : Q175 et
   Q176.

### Choix techniques

- **Administrateurs : une table `association_admins`** (association, joueur, nommé par, date),
  clé unique (association, joueur). Lecture pour tout compte connecté, écriture uniquement par
  RPC `security definer` (`add_association_admin`, `remove_association_admin`), comme les
  autres tables d'associations (règle d'`AGENTS.md`). Une table plutôt qu'une colonne sur
  `players` : la fiche joueur est modifiable par son propriétaire, une colonne demanderait une
  garde de plus pour l'empêcher de se nommer lui-même, et la table garde qui a nommé qui.
- **Une seule fonction de droit** `is_association_staff(association)` = responsable local
  approuvé **ou** administrateur. Elle remplace `is_association_manager` aux points 4 à 8
  (`set_session_championship`, garde du championnat, `can_manage_event`, suppression de
  commentaire, import, `sessions_guard_event`). `is_association_manager` reste seule pour
  `update_association`, le stockage des logos et la nomination des administrateurs. Ainsi un
  futur droit « de gestion » s'ajoute en un seul endroit.
- **Départ de l'association** : un déclencheur sur `players` supprime la ligne
  d'administrateur quand `association_id` change (départ ou changement d'association,
  quelle qu'en soit la voie). La suppression d'un compte la supprime aussi (clé étrangère
  en cascade).
- **Partenaires : une colonne `associations.partners`** (liste JSON de
  `{ "label", "url" }`), écrite par `update_association` (nouvelle clé `partners` du
  `payload`), contrôlée en SQL (libellé non vide, lien `http`/`https`, nombre maximal). Pas de
  table : la liste n'est lue qu'avec l'association, n'est jamais recherchée ni liée ailleurs,
  et une colonne évite une table, ses droits et sa RPC. Le lien est normalisé comme le site
  web actuel (ajout de `https://` s'il manque).
- **App** : un fournisseur Riverpod unique `canManageAssociation(associationId)` (super_admin,
  responsable ou administrateur) ; `canTagChampionship` et `canModeratePlanning` s'appuient
  dessus au lieu de relire le responsable. Seul le bouton « Modifier » de la page de
  l'association reste sur « responsable ou super_admin ».
- **Reconstruction de la base distante** (règle 8 d'`AGENTS.md`) : les changements modifient
  les fichiers `tables.sql`, `indexes.sql`, `utility_functions.sql`, `rls.sql`, `triggers.sql`
  et `rpc.sql`. Seeds régénérés, relus et committés avec l'accord du PO avant, rejoués après.
  **Le PO sera prévenu avant de lancer la reconstruction.**

## Parcours

### Page de l'association

- Sous le responsable local, une section **« Administrateurs »** : nom et photo de chacun ;
  « Aucun administrateur » si la liste est vide (section masquée pour les comptes hors
  responsable/super_admin quand elle est vide).
- Responsable local et `super_admin` : bouton **« Ajouter un administrateur »**, qui ouvre la
  liste des membres de l'association (recherche par nom), sans ceux déjà administrateurs ni le
  responsable. Un geste ajoute. Sur chaque administrateur, **« Retirer »** avec confirmation.
- L'administrateur lui-même : **« Ne plus être administrateur »** avec confirmation (Q170).
- Quitter l'association (bouton existant) : pour un administrateur, la confirmation précise
  qu'il perd son rôle (Q171).
- Section **« Partenaires »** (titre selon Q175) après les informations : chaque libellé est
  un lien. Masquée si la liste est vide.

### Formulaire de l'association (responsable local, super_admin)

- Bloc « Partenaires » : lignes libellé + lien, bouton « Ajouter un partenaire », suppression
  par ligne, réordonnancement par glisser (Q176). Contrôles à la saisie : libellé non vide,
  lien valide ; message traduit sinon.

### Ailleurs dans l'app

Aucun nouvel écran : un administrateur voit apparaître ce que voit déjà le responsable local
(interrupteur « Championnat » dans les sessions, boutons Modifier / Supprimer sur tous les
événements, suppression des commentaires, « Importer », « Démarrer la session »).

## Étapes

1. SQL : table `association_admins` et son index ; `associations.partners` ; fonction
   `is_association_staff` ; remplacement de `is_association_manager` aux points 4 à 8 ; RPC
   `add_association_admin` / `remove_association_admin` (retrait par le responsable, le
   `super_admin` ou l'intéressé) ; clé `partners` dans `update_association` ; déclencheur de
   départ ; droits de lecture (RLS) ; publication temps réel non nécessaire.
2. Tests d'accès dans `rls_smoke.sql` : un administrateur marque le championnat, gère tout
   événement, supprime un commentaire, importe, démarre une session ; il ne modifie pas
   l'association ni son logo, ne nomme personne ; un membre ordinaire ne peut rien de tout
   cela ; nommer un non-membre échoue ; quitter l'association retire le rôle ; partenaires
   invalides refusés.
3. Dart : modèle `AssociationAdmin` et `Partner` (freezed), dépôt (lecture, ajout, retrait,
   partenaires), fournisseur `canManageAssociation`, rebranchement de `canTagChampionship` et
   `canModeratePlanning`.
4. Écrans : sections Administrateurs et Partenaires de la page de l'association, feuille de
   choix d'un membre, bloc Partenaires du formulaire, confirmation de départ adaptée. Chaînes
   EN et FR.
5. Tests unitaires et d'écran (droits, affichage des sections, formulaire).
6. Seeds régénérés et committés (accord du PO), reconstruction de la base (PO prévenu), seeds
   rejoués, `seed_super_admin.sql` rejoué.
7. Essai dans le navigateur intégré, puis essai par le PO.

## Livrables

- Fichiers SQL modifiés, `rls_smoke.sql` complété.
- Code `lib/features/associations/` (et droits `championship` / `planning` rebranchés).
- Chaînes `app_en.arb` / `app_fr.arb`.
- Ce plan, `QUESTIONS_PO.md` et `AGENTS.md` (convention « Associations ») mis à jour.

## Critères d'acceptation

- [ ] Le responsable local nomme un membre administrateur ; celui-ci voit aussitôt
      l'interrupteur « Championnat » et les actions de gestion du planning.
- [ ] Un administrateur ne voit pas « Modifier » sur la page de l'association, et la base
      refuse un appel direct à `update_association` ou un envoi de logo de sa part.
- [ ] Un administrateur ne peut nommer personne (écran et base).
- [ ] Le `super_admin` nomme et retire les administrateurs de toute association.
- [ ] Retrait par le responsable, renoncement par l'intéressé, départ de l'association :
      chacun retire le rôle.
- [ ] Le responsable ajoute, réordonne et supprime des partenaires ; ils s'affichent sur la page
      de l'association, chaque lien s'ouvre dans un nouvel onglet ; un lien invalide est refusé.
- [ ] `flutter analyze --fatal-infos` sans remarque, tests verts, `rls_smoke.sql` vert, build
      Vercel vert, chaînes EN et FR.

## Hors périmètre

- Notification à la personne nommée (l'app n'a pas de notifications).
- Logo des partenaires, affichage des partenaires sur les exports ou le partage d'événement
  (possible plus tard, notamment avec le plan 24).
- Coordonnées de contact pour les administrateurs.
