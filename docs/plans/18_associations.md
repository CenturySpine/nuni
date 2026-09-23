# Plan 18 — Associations

## Statut

Demande PO du 2026-09-23. Questions Q77 à Q87 tranchées le même jour (`docs/QUESTIONS_PO.md`).
Plan rédigé et validé par le PO le 2026-09-23 ; implémenté le même jour, base distante
reconstruite (données rattachées à Lyon Street Golf, tests RLS verts) ; testé et validé par le PO le
2026-09-23.
**Plan clôturé le 2026-09-23** (suppression d'une association par un super_admin comprise, Q89).

## En bref, pour les membres

- Chaque joueur appartient à une association (Lyon Street Golf, Street Golf à l'Ouest,
  Médiéballes…), choisie à la première connexion. L'app propose d'office l'association la plus
  proche.
- Une session appartient à l'association de la personne qui la crée ; tout le monde peut y jouer,
  quelle que soit son association (les visiteurs sont les bienvenus).
- Le championnat devient celui d'une association pour une saison (ex. « LSG · 2026–2027 »). Il
  remplace le regroupement automatique par zone géographique.
- Un nouvel onglet « Associations » liste toutes les associations : ville, responsable local, site
  internet. On peut y déclarer son association pour commencer à utiliser l'app.
- On peut se déclarer responsable local de son association, ou demander la création d'une
  association absente de la liste. Un super administrateur valide chaque demande.
- Tout l'historique actuel (sessions, championnats, joueurs) est rattaché à Lyon Street Golf.

## Objectif

Rattacher sessions et championnats à une association plutôt qu'à une zone géographique : cela
distingue deux associations d'une même ville, et ouvre l'app à d'autres pratiques que le street
golf (disc golf, ou toute association qui veut l'utiliser pour son scoring interne).

## Prérequis

- Rôle `super_admin` (plan 16, livré) : c'est lui qui approuve les demandes.
- Championnat (plan 15, livré) : son regroupement par zone est remplacé ici (Q77).
- Photo de profil avec recadrage (livrée le 2026-09-23) : même mécanisme pour le logo.

## Décisions retenues (PO, 2026-09-23)

1. **Association d'un joueur.** À la première connexion, un joueur sans association doit en
   choisir une parmi les associations approuvées. L'app pré-sélectionne celle dont la ville est la
   plus proche de sa position (géolocalisation refusée : liste alphabétique, rien de
   pré-sélectionné). Il peut en changer ensuite librement, sans validation ; ses sessions passées
   gardent leur association (Q79).
2. **Demande de création en attente (Q81).** Seule une association approuvée peut recevoir des
   sessions. Un joueur qui demande la création de son association n'est rattaché à aucune
   association tant que la demande attend : il peut consulter l'app et rejoindre des sessions,
   pas en créer (le bouton de création explique pourquoi). À l'approbation, il est rattaché à la
   nouvelle association et en devient le responsable local (Q82). En cas de refus, l'écran de
   choix réapparaît à sa prochaine ouverture.
3. **Association d'une session.** Celle de son créateur au moment de la création, sans saisie, et
   figée ensuite ; un `super_admin` peut la corriger (Q80). Elle ne restreint pas les
   participants : des joueurs d'autres associations peuvent jouer.
4. **Championnat (Q77).** Un championnat = une association × une saison. Les zones
   géographiques (rayon de 15 km, nom déduit des villes) disparaissent ; le calcul des points
   (plan 15) ne change pas. Un visiteur est classé comme les autres dans le championnat de
   l'association qui l'accueille.
5. **Historique.** Toutes les données actuelles (joueurs, y compris ceux importés de LsgScores
   sans compte, sessions, championnats) sont rattachées à Lyon Street Golf.
6. **Page des associations (Q85).** Quatrième onglet de la barre de navigation du bas,
   « Associations », pour mettre en avant le côté associatif et rendre visible qu'on peut déclarer
   son association. Pour chacune : nom, abréviation, logo, ville, responsable local, lien vers le
   site. Le mail et le téléphone du responsable ne sont **jamais** affichés publiquement.
7. **Responsable local (Q78).** Un seul responsable approuvé par association. Un joueur le
   revendique depuis l'app avec son mail, son téléphone et un message libre au super
   administrateur ; seul un `super_admin` approuve, et peut révoquer (ce qui rouvre la
   revendication). Le responsable modifie ensuite son association : nom, abréviation (ex. « Lyon
   Street Golf » → LSG, « Street Golf à l'Ouest » → SGO), ville, site, logo, ainsi que son mail et
   son téléphone. Le logo reste vide tant qu'un responsable ne l'a pas fourni.
8. **Création d'une association.** Un joueur la demande en saisissant : nom, ville de
   rattachement (nom + point sur une carte, Q83), mail et téléphone du responsable (le demandeur,
   son nom est repris de son profil, Q82), et un message libre facultatif. Abréviation et site
   sont facultatifs ; le logo vient après l'approbation. Seul un `super_admin` approuve.
9. **Gestion des demandes (Q86).** Une page dédiée, réservée aux `super_admin`, liste les demandes
   en attente (créations et revendications) avec leur message et les coordonnées du demandeur,
   et permet d'approuver ou de refuser. Un compteur dans les Réglages y mène. Pas d'e-mail pour
   le moment.
10. **Suppression d'une association (PO, 2026-09-23, Q89).** Réservée aux `super_admin`, depuis
    la fiche de l'association. Refusée tant que des sessions lui appartiennent ; sinon ses
    membres repassent sans association (écran de choix) et son responsable perd son rôle.

## Liste initiale (Q84)

Six associations, approuvées, sans responsable ni logo au départ. Position et site repris de la
carte « Associations et équipes françaises » de la Fédération (streetgolf.fr/federation, fichier
public de nynjas.golf) ; aucune donnée personnelle reprise de ce fichier.

| Association | Abréviation | Ville | Site |
|---|---|---|---|
| Lyon Street Golf | LSG | Lyon | lyonstreetgolf.fr |
| Street Golf à l'Ouest | SGO | Morlaix | streetgolfalouest.com |
| Wild Shrimp Crew | | Grenoble | |
| Médiéballes | | Laon | |
| Urban Green Lille | | Lille | |
| Strasbourg Street Golf | | Strasbourg | |

Les autres associations et équipes demanderont leur création dans l'app.

## Parcours et écrans

- **Onglet « Associations »** (barre du bas, après Historique) :
  - En tête, un encart qui invite à déclarer son association (« Votre association n'est pas dans
    la liste ? Déclarez-la et commencez à utiliser NUNI »), qui ouvre la demande de création.
  - Mon association en premier, marquée ; puis les autres par ordre alphabétique. Chaque carte :
    logo (ou initiales), nom, abréviation, ville, responsable local ou « Pas encore de
    responsable ».
  - Pour un joueur dont la demande de création attend : un encart « Demande en attente de
    validation ».
- **Fiche d'une association** : mêmes informations, lien vers le site ; actions selon le cas :
  - « Rejoindre cette association » (Q79) ;
  - « Je suis le responsable local » (s'il n'y en a pas) → mail, téléphone, message → « Demande
    envoyée » ; une revendication en attente est signalée à son auteur ;
  - « Modifier » (responsable approuvé) → nom, abréviation, ville (nom + point sur une carte),
    site, logo (import + recadrage carré), mail, téléphone.
- **Choix de l'association** (première connexion, ou joueur sans association ni demande en
  attente) : écran plein, liste triée par distance, la plus proche pré-sélectionnée, « Valider ».
  En bas, « Mon association n'est pas dans la liste » ouvre la demande de création.
- **Profil** : mon association, avec lien vers sa fiche.
- **Création de session** : l'association de la session est affichée (lecture seule).
- **Championnat** : l'encart de l'accueil, son historique et la page de classement affichent
  l'association (abréviation, ou nom s'il n'y en a pas) au lieu du nom de zone. L'accueil garde
  tous les championnats où j'ai joué, visiteur compris, mon association en premier (Q88).
- **Demandes en attente** (`super_admin`) : page listant créations et revendications, avec pour
  chacune le demandeur, ses coordonnées, son message et les informations saisies ; « Approuver » /
  « Refuser ». Accessible depuis les Réglages, avec le nombre de demandes en attente.

## Modèle de données

Nouvelles tables :

- `associations` : `id`, `name`, `short_name` (nullable), `city` (texte), `location` (point, sert
  à la suggestion par distance), `website_url`, `logo_path` (nullable), `status` (`pending` /
  `approved` / `rejected`), `created_by`, `created_at`, `updated_at`, `reviewed_by`,
  `reviewed_at`.
- `association_managers` : un responsable ou une revendication par ligne : `association_id`,
  `user_id`, `status` (`pending` / `approved` / `rejected` / `revoked`), dates de demande et de
  décision, `reviewed_by`. Une demande de création crée aussi la revendication de son demandeur
  (Q82), approuvée en même temps que l'association. Au plus une ligne `approved` par association
  (contrainte d'unicité partielle, Q78). Lisible par tous pour afficher le nom du responsable
  approuvé.
- `association_manager_contacts` : `manager_id`, `email`, `phone`, `request_message` (le message
  de la demande, création ou revendication : placé ici plutôt que sur les deux tables publiques,
  pour qu'il ne soit jamais lisible au-delà du demandeur et des `super_admin`). **Table séparée et
  privée** :
  lisible et modifiable uniquement par le responsable concerné et par `super_admin`. Séparée
  plutôt que colonnes masquées : une requête de liste ordinaire ne peut pas les exposer par
  erreur, et les règles d'accès restent simples à tester.

Colonnes ajoutées :

- `players.association_id` (nullable : `null` = choix à faire, sauf demande de création en
  attente).
- `sessions.association_id` (non nul), posé par un déclencheur à la création depuis
  l'association du créateur, jamais par le client (même principe que la saison de championnat).
  La création est refusée si le créateur n'a pas d'association (Q81).

Retirés (Q77) : `championship_zones`, `sessions.championship_zone_id`, le déclencheur de
rattachement par proximité, la fonction de libellé de zone. Les fonctions de classement prennent
une association au lieu d'une zone.

Stockage : bucket `association-logos`, écriture réservée au responsable approuvé de
l'association et à `super_admin`, lecture publique comme les avatars.

Règles d'accès (RLS) :

- Lecture des associations `approved` par tout utilisateur connecté ; une association `pending`
  ou `rejected` n'est visible que de son demandeur et de `super_admin`.
- Création d'une demande par tout utilisateur connecté (statut forcé à `pending`), une seule
  demande de création en attente par personne.
- Modification : responsable approuvé de l'association, ou `super_admin`. Approbation, refus,
  révocation : `super_admin` uniquement, via des fonctions dédiées (qui rattachent aussi le
  demandeur à l'association créée).
- `players.association_id` : modifiable par le joueur lui-même, vers une association approuvée
  uniquement.

## Reprise de l'existant et migration (Q87)

L'app n'est pas encore utilisée officiellement : on reste sur la règle 8 (AGENTS.md).

- Les fichiers de migration thématiques existants sont modifiés en place (tables, RLS,
  déclencheurs, fonctions), pas de nouveau fichier.
- Avant la reconstruction : export des seeds depuis la base actuelle
  (`tool/export_remote_seed.dart`), relu, committé avec l'accord du PO.
- L'outil de seed est étendu : les associations (données publiques) vont dans le seed en clair
  avec les trous ; les rattachements des joueurs et des sessions, les responsables et leurs
  coordonnées dans le seed chiffré.
- Au premier rejeu après ce plan, les données actuelles n'ont pas encore d'association : le seed
  (ou un script de reprise joué juste après) crée les six associations et rattache tous les
  joueurs et toutes les sessions à Lyon Street Golf. Les championnats sont recalculés par
  association : mêmes sessions, mêmes points.
- **Le PO est prévenu avant la reconstruction** de la base distante (règle 8).

## Étapes (développement)

1. Schéma : tables, colonnes, déclencheur de la session, fonctions d'approbation, RLS, bucket,
   retrait des zones, fonctions de classement par association ; tests RLS (`supabase/tests/`).
2. Outil de seed étendu et script de reprise (six associations, rattachement à LSG).
3. `features/associations/` : modèles, dépôt, onglet Associations, fiche, modification,
   revendication de responsable, demande de création, logo.
4. Écran de choix à la première connexion (garde de navigation) et suggestion par distance ;
   blocage de la création de session sans association.
5. Championnat : classement par association, libellés de l'accueil et de la page de classement.
6. Page `super_admin` des demandes en attente, compteur dans les Réglages.
7. `/privacy` complétée : mail et téléphone des responsables, et message des demandes, visibles
   seulement du responsable et des super administrateurs.
8. Chaînes FR/EN, tests unitaires et de widgets, vérification dans le navigateur.
9. Reconstruction de la base distante (PO prévenu), rejeu des seeds et de la reprise, test PO.

## Critères d'acceptation

- Un nouveau compte doit choisir une association ; la plus proche est pré-sélectionnée quand la
  position est connue.
- Un joueur dont la demande de création attend peut rejoindre une session mais pas en créer ; à
  l'approbation, il est rattaché à sa nouvelle association et en est le responsable.
- Une session créée prend l'association de son créateur ; un joueur d'une autre association peut
  la rejoindre et apparaît dans le championnat de l'association de la session.
- Tout l'historique actuel apparaît sous Lyon Street Golf, avec les mêmes classements et les
  mêmes points qu'avant.
- L'onglet Associations n'affiche jamais un mail ni un téléphone ; les tests RLS prouvent qu'un
  utilisateur ordinaire ne peut lire ni les coordonnées ni les messages des demandes.
- Une revendication et une création restent sans effet tant qu'un `super_admin` ne les a pas
  approuvées ; un responsable approuvé peut modifier son association, personne d'autre (hors
  `super_admin`).
- `flutter analyze` sans avertissement, tests verts, build Vercel vert, chaînes FR/EN.

## Hors périmètre

- Rattacher les trous à une association (ils restent publics ou privés, sans association).
- Type d'activité d'une association (street golf, disc golf…) : pas de champ tant qu'aucun usage
  ne le demande.
- E-mails de notification, et motif de refus transmis au demandeur : le super administrateur
  dispose de ses coordonnées pour le contacter.

## Questions PO liées

Q77 à Q87, toutes tranchées le 2026-09-23.
