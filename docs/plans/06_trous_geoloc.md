# Plan 06 — Trous géolocalisés

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
- Position d'un trou (H Q12) : point de départ obligatoire, saisi par "utiliser ma position"
  (précision affichée) ou en déplaçant un marqueur sur une carte. Carte : `flutter_map` avec tuiles
  OpenStreetMap (gratuit, sans clé, usage raisonnable) ; pas de Google Maps (clé et facturation).
- Proximité (H Q10) : RPC `holes_nearby` (PostGIS) avec rayon choisi parmi 300 m / 1 km / 5 km,
  défaut 1 km, mémorisé localement ; bouton "tous mes trous" si la géolocalisation échoue.
- Photos : `image_picker` (sur mobile, ouvre l'appareil photo ou la galerie ; sur desktop, le
  sélecteur de fichiers). Redimensionnement côté client avant envoi (largeur max 1600 px, JPEG
  qualité 80) avec le paquet `image` pour économiser le stockage et la bande passante mobile. Pas
  de recadrage (brique jugée non essentielle ; ajoutable plus tard). Envoi vers le bucket `holes`
  sous `holes/<holeId>/start.jpg` et `end.jpg`. Le même composant `PhotoField` sert aux avatars et
  aux photos de session.
- Visibilité : `public` par défaut (l'intérêt d'un référentiel partagé), `private` sur demande.
  Seul le propriétaire modifie ou supprime ; suppression refusée si le trou a été joué (contrainte
  base, message clair).

## Écrans

- `/holes` : liste "autour de moi" (distance affichée, tri par distance) avec sélecteur de rayon,
  bascule "tous mes trous", bouton créer. Carte facultative en second onglet (même données).
- `/holes/new` et `/holes/:id` (édition) : nom, par (défaut 3), distance en mètres (facultatif),
  description, visibilité, position (bouton "ma position" + mini-carte), photos départ / cible.
- Fiche en lecture : photos, infos, "à 240 m", bouton "y aller" (lien geo:/maps universel).

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

- Sur téléphone, en extérieur, la liste propose les trous dans le rayon choisi en moins de 3 s après
  obtention de la position.
- Un trou privé n'apparaît pas pour un autre utilisateur (test RLS).
- Une photo de 4 Mo prise au téléphone est envoyée en moins de 300 ko.

## Questions PO liées

Q10, Q12, Q13.
