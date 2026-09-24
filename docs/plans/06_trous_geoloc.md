# Plan 06 — Trous géolocalisés

> **Mise à jour du 2026-09-24 (plan 26, Q110)** : la notion de trou privé est supprimée. Tout
> trou est visible et jouable par tous ; seul son auteur le modifie. Un trou peut être cloné
> (« Clone - <nom> ») par n'importe qui, qui en devient l'auteur. Les passages sur les trous
> privés ci-dessous restent comme historique.

## Objectif

Référentiel de trous public/privé avec position de départ, photos de départ et de cible, et
recherche par proximité de la position de l'utilisateur. Ce référentiel remplace le couple
ville/zone de l'ancienne app comme unique prérequis d'une session (et même lui n'est pas
bloquant : une session peut démarrer sans trou).

## Prérequis

Plans 03, 04, 05.

## Décisions retenues

- Géolocalisation navigateur via le paquet `geolocator` (API Geolocation du navigateur, HTTPS
  obligatoire, ce qui est le cas sur Vercel et en local avec `localhost`).
- Position d'un trou (Q12, révisé 2026-09-16) : point de départ obligatoire, saisi par "utiliser
  ma position" (précision affichée) ou en touchant la carte ; position de cible facultative,
  saisie sur la même carte via une bascule départ/cible (prépare un futur tracé du trajet entre
  les deux points, pas fait maintenant). Carte : `flutter_map` avec tuiles OpenStreetMap (gratuit,
  sans clé, usage raisonnable) ; pas de Google Maps (clé et facturation). Pas de glisser-déposer du
  repère (non supporté par la couche de marqueurs de base de `flutter_map`) : on touche la carte à
  l'endroit voulu.
- Proximité (Q10, révisé 2026-09-16) : RPC `holes_nearby` (PostGIS) avec un rayon choisi par
  curseur (0 à 10 km, pas de 500 m, défaut 1 km), valeur mémorisée sur l'appareil
  (`shared_preferences`) ; bouton "tous mes trous" si la géolocalisation échoue.
- Photos : `image_picker` (sur mobile, ouvre l'appareil photo ou la galerie ; sur desktop, le
  sélecteur de fichiers). Redimensionnement côté client avant envoi (largeur max 1600 px, JPEG
  qualité 80) avec le paquet `image` pour économiser le stockage et la bande passante mobile. Pas
  de recadrage (brique jugée non essentielle ; ajoutable plus tard). Envoi vers le bucket `holes`
  sous `holes/<ownerId>/<holeId>/start.jpg` et `end.jpg` (le premier segment doit être l'id du
  propriétaire : c'est ce que vérifie la politique de stockage déjà appliquée, pas l'id du trou
  seul). Le même composant `PhotoField` sert aux avatars et aux photos de session.
- Tracé (PO, 2026-09-18) : trajet du départ à la cible dessiné sur la carte (trait rouge), avec des
  points intermédiaires ajoutés par toucher successif de la carte (3e bascule "Tracé" à côté de
  "Départ"/"Cible", même logique tap-only que les deux autres, pas de glisser). Boutons "annuler le
  dernier point" et "effacer le tracé" ; pas de réordonnancement ni de suppression d'un point
  précis en v1. Stocké dans une nouvelle colonne `holes.path` (`jsonb`, tableau ordonné
  `{"lat":..,"lng":..}`) : simple `jsonb` plutôt qu'un type PostGIS `linestring` puisque ce tracé
  n'est jamais utilisé dans une requête spatiale (contrairement à `start`/`end_point`), seulement
  affiché. Colonne ajoutée directement dans `20260915100100_tables.sql` (schéma pas encore en
  service, AGENTS.md point 8) ; `holes_nearby` n'est pas modifiée (le tracé n'est utilisé que dans
  le formulaire d'édition, pas dans la liste/carte "autour de moi").
- Par et distance déduits du tracé (PO, 2026-09-18) : distance = longueur totale du tracé (somme
  des segments départ→...→cible, formule de Haversine via `latlong2`) ; par = nombre de points du
  tracé (départ et cible compris) + 1. Les deux champs restent des champs texte normaux et
  éditables, mais le tracé reprend toujours la main dessus dès qu'un point est ajouté ou retiré
  (choix explicite du PO : pas de mémorisation d'une saisie manuelle qui "gèlerait" le champ). Ne
  se déclenche qu'à partir de deux points (un simple départ seul ne change rien).
- Visibilité (Q33) : `public` par défaut (l'intérêt d'un référentiel partagé), `private` sur
  demande. Le schéma déjà appliqué (plan 03) a un défaut `private` à corriger avant d'écrire
  l'écran de création (migration à modifier, reconstruction du schéma distant à prévenir auprès
  du PO — AGENTS.md point 8). Seul le propriétaire modifie ou supprime ; suppression refusée si le
  trou a été joué (contrainte base, message clair).

## Écrans

- `/holes` : liste "autour de moi" dans un rayon réglable par curseur (distance affichée, tri par
  distance), bascule "tous mes trous", bouton créer. Carte facultative en second onglet (même
  données) : une épingle par trou dans le rayon sélectionné.
- `/holes/new` et `/holes/:id` (édition) : nom, par (défaut 3), distance en mètres (facultatif),
  description, visibilité, position départ + cible (bouton "ma position" pour le départ, bascule
  départ/cible + mini-carte), photos départ / cible. Champs groupés en cartouches titrées
  (Détails, Position, Photos), essai visuel en cours (voir Décisions retenues).
- Fiche en lecture : photos, infos, "à 240 m", bouton "y aller" (lien geo:/maps universel).

## Aspect visuel (essai en cours, PO 2026-09-16)

Le PO juge l'aspect des formulaires daté et demande une modernisation, par itérations avec retour
avant de figer quoi que ce soit dans `docs/design/PALETTE.md`. Références citées : l'app Planerz
(même auteur, cartouches arrondies) et l'app mobile ZenChef (non consultable depuis l'outillage de
l'assistant). Premier essai sur le formulaire des trous validé par le PO (2026-09-16) : champs remplis et
arrondis (thème partagé `core/theme/app_theme.dart`, profite à tous les formulaires de l'app),
sections groupées en cartouches titrées, carte agrandie (220 px → 340 px). La page liste/carte des
trous reste à retravailler dans le même esprit (PO, 2026-09-16) : premier essai fait (bandeau
filtres en cartouche, repères de liste en badge rond), pas encore validé. Pas encore consigné comme
décision définitive dans `docs/design/PALETTE.md` tant que le PO n'a pas validé l'ensemble.

## Étapes

1. Paquets : `geolocator`, `flutter_map`, `latlong2`, `image_picker`, `image`.
2. `core/location/` : service de position (permission, erreurs, dernier point connu), fournisseur
   Riverpod.
3. `features/holes/data` : repository (CRUD, `holes_nearby`), upload de photos.
4. `features/holes/ui` : liste, formulaire, fiche, carte.
5. Tests : règles de tri/distance, formulaire (validation), repository mocké.

## Livrables

- Référentiel des trous complet et géolocalisé.

## Critères d'acceptation

- Sur téléphone, en extérieur, la liste propose les trous dans le rayon choisi en moins de 3 s
  après obtention de la position.
- Un trou privé n'apparaît pas pour un autre utilisateur (test RLS).
- Une photo de 4 Mo prise au téléphone est envoyée en moins de 300 ko.

## Vérifié, non vérifié

- Cycle complet (créer, lister, carte, fiche, modifier, supprimer, bascule "tous mes trous",
  curseur de rayon avec mémorisation, deux points départ/cible) vérifié par le PO sur mobile réel
  (2026-09-16) : fonctionnel, aspect visuel de la liste/carte à reprendre plus tard (voir
  Décisions retenues).
- Liste en moins de 3 s après la position, en extérieur : non chronométré précisément, jugé
  satisfaisant par le PO ("nickel") -- accepté tel quel.
- Trou privé invisible d'un autre utilisateur : non rejoué avec deux comptes distincts sur cette
  étape ; repose sur la politique RLS `holes_select` (validée au plan 3, jalon 1). Accepté tel
  quel par le PO (2026-09-16).
- Photo de 4 Mo compressée sous 300 ko : couvert par un test unitaire sur images synthétiques
  (`test/shared/photo_field_test.dart`), pas sur une vraie photo de téléphone. Accepté tel quel
  par le PO (2026-09-16).
- Tests automatisés : `flutter analyze` sans avertissement, 32 tests verts, build web release
  réussi.

## Retouches du 2026-09-23 (demandées par le PO pendant le repositionnement des trous importés, plan 13)

- Chaque photo (départ, cible) se supprime individuellement dans le formulaire (croix en coin).
  Supprimer ou remplacer une photo efface l'ancien fichier du stockage à l'enregistrement (Q61).
- Formulaire : bouton « Aller au dernier trou : <nom> » à côté de « Utiliser ma position ». Il
  déplace seulement la carte vers mon dernier trou créé ou modifié qui a une position (lu en base
  via `updated_at`) ; le départ se pose ensuite en touchant la carte (Q60).
- Emplacement photo vide du formulaire : icône centrée, cadre visible.
- Fiche d'aperçu : les deux emplacements photo toujours affichés, avec un emplacement vide pour
  une photo manquante.
- Liste des trous : l'icône de position est remplacée par les miniatures des photos de départ et
  de cible (emplacement vide si absente).
- Pose des points enchaînée : une fois le départ posé (toucher la carte ou « Utiliser ma
  position »), le mode passe seul à « Cible », puis à « Tracé » une fois la cible posée. Le passage
  automatique ne se fait que vers un point pas encore posé (corriger le départ d'un trou qui a déjà
  une cible laisse le mode sur « Départ »). Les boutons de mode restent utilisables à tout moment.

## Retouche du 2026-09-24 : trou en lecture seule

- Fiche d'aperçu d'un trou dont je ne suis pas l'auteur : bouton « Voir le trou » à la place de
  « Modifier ». Il ouvre le même écran que la modification (`/holes/:id`), en lecture seule :
  champs non modifiables, carte avec départ, cible et tracé, photos, sans boutons de pose de
  points, d'enregistrement ni de suppression. Le mode est déduit de l'auteur du trou, donc un lien
  direct vers `/holes/:id` s'ouvre aussi en lecture seule pour un non-auteur.

## Questions PO liées

Q10, Q12, Q13, Q33, Q60, Q61.
