# Plan 10 — Historique, photos, exports

## Objectif

Conserver et consulter les sessions terminées, y attacher des photos, exporter un PDF et une image
partageable, corriger les horaires.

## Prérequis

Plan 08.

## Décisions retenues

- Historique `/history` : mes sessions terminées (créées ou rejointes), triées par date, carte
  avec ville · zone, date et heure, durée, mode de scoring, météo, vignette de couverture,
  podium résumé. Filtre simple par ville.
- Détail `/history/:id` : mêmes composants que la session en direct (en-tête, classement,
  trous joués) en lecture seule, plus la galerie et les actions.
- Photos : bucket `session-photos`, table `session_photos`, upload multiple (compression client
  comme au plan 06), galerie avec plein écran par balayage, photo de couverture (`cover_photo_id`),
  suppression. Ajout et suppression réservés au créateur de la session, comme le posent déjà les
  policies RLS existantes (Q37) — aucune migration à modifier sur ce point. Suppression du fichier
  dans le bucket faite côté client au moment de la suppression de la photo (Q37), sans Edge
  Function.
- Édition (créateur) : date, heure de début, heure de fin (validation : pas dans le futur, fin
  après début) ; un changement de la date ou de l'heure de **début** seulement (PO, 2026-09-17)
  recalcule la météo via Open‑Meteo historique (archive) avec la position de la session si connue
  — la météo capturée au démarrage (plan 07, corrigé) devient fausse si cette date/heure est
  corrigée après coup ; l'heure de fin seule n'a pas d'effet sur la météo. Commentaire libre de
  session (existait en base dans l'ancienne app sans
  jamais être saisi ; ici un champ réel).
- Export PDF : paquet `pdf` (génération pure Dart) + `printing` (téléchargement / partage sur le
  web) ; contenu : en-tête (ville, zone, date, heures, durée, type, mode, météo, commentaire),
  tableau équipes × trous (nom du trou, mode de jeu, coups et points, totaux), classement, photo
  de couverture, pied "NUNI — Never Up, Never In". Coups masqués en Stroke Play comme avant.
- Export image (H Q16) : un widget "carte de résultats" (classement, ville, date, météo, logo)
  rendu en PNG via `RepaintBoundary`, partagé avec `share_plus` (Web Share avec fichier sur mobile,
  téléchargement sur desktop). Variante "sur photo" : même widget superposé à une photo choisie.
  Beaucoup plus simple et fidèle au thème que le dessin sur canvas de l'ancienne app.
- Suppression d'une session terminée (créateur) avec confirmation forte, cascade base + purge
  des photos du bucket faite côté client avant la suppression de la session (Q37).

## Étapes

1. Paquets : `pdf`, `printing`, `share_plus` (déjà), `image` (déjà).
2. `features/history/` : liste, détail, édition, galerie.
3. `features/exports/` : modèle d'export (calcul partagé avec le live), générateur PDF, widget
   carte de résultats, service de partage/téléchargement multiplateforme.
4. Tests : générateur PDF (golden léger sur le contenu textuel), règles de validation des
   horaires, modèle d'export.

## Livrables

- Historique, galerie, exports, édition.

## Critères d'acceptation

- Un PDF d'une session à 6 équipes et 9 trous tient sur une page A4 lisible.
- L'image de résultats se partage dans WhatsApp depuis Chrome Android et Safari iOS.
- Une photo supprimée disparaît du bucket.

## Questions PO liées

Q16, Q37 (tranchées).

## Notes d'implémentation (2026-09-17)

Toutes les étapes faites : paquets (`pdf`, `printing`, `uuid`, `web` en direct),
`features/history/` (liste, détail, édition, galerie), `features/exports/` (modèle d'export,
générateur PDF, carte de résultats, capture image, partage/téléchargement). `session_snapshot`
étendu (météo, commentaire, photo de couverture) et nouvelle RPC `history_snapshots` qui le
réutilise tel quel pour chaque session terminée, plutôt que dupliquer la requête. Détail
`/history/:id` : mêmes composants que la session en direct (`RankingCard`, `PlayedHoleCard`) en
lecture seule. `flutter analyze`, `dart format` et 81 tests verts (calculateurs déjà couverts par
le plan 08 ; nouveaux : validation des horaires, modèle d'export, génération PDF). Schéma distant
reconstruit et testé en direct dans le navigateur : création → démarrage → saisie → clôture →
détail → édition (commentaire seul, puis changement d'heure de début) → export PDF → export image
→ suppression.

Deux bugs réels trouvés et corrigés pendant ce test, tous deux hors du périmètre strict du plan 10
mais découverts par lui :
- `closeSession` (plan 08, `live_repository.dart`) enregistrait `ended_at` avec l'heure locale du
  navigateur sans conversion UTC : Postgres la lisait comme si elle était déjà UTC, décalant la
  valeur de l'écart de fuseau du poste qui clôture la session. Corrigé (`.toUtc()`). Sans effet sur
  les sessions déjà closes avant ce correctif (leur `ended_at` reste faussé ; aucune n'est une
  vraie donnée à ce stade).
- La feuille d'édition comparait l'heure de début tapée par l'utilisateur (précision à la minute)
  à la valeur brute de la base (précision à la milliseconde) pour décider si la météo devait être
  recalculée : cet écart de précision déclenchait un recalcul à chaque sauvegarde, même sans
  changement réel. Corrigé (comparaison tronquée à la minute des deux côtés). Revérifié : un
  enregistrement sans toucher aux horaires laisse la météo intacte ; un changement d'heure de
  début la recalcule.

Upload de photo revérifié ensuite avec une vraie photo (fournie par le PO) : import dans la
galerie, définition en couverture, incrustation dans le PDF et dans l'image de résultats, tous
confirmés fonctionnels (export PDF récupéré et transmis au PO pour inspection directe).

Retours PO sur l'image de résultats (2026-09-17/18), chacun revérifié à l'écran :
- Proposer les photos déjà importées dans la session au lieu de forcer un nouveau choix sur le
  système de fichiers (la bande de sélection montre désormais les photos de la session en premier,
  "+" pour en ajouter une nouvelle en dernier recours).
- L'assombrissement de toute la photo pour lire le texte altérait trop l'image : remplacé par un
  calque semi-transparent localisé sous chaque bloc de texte, le reste de la photo intact.
- Marges de la carte réduites (64 → 40 → 20 px).
- Logo replacé à côté du titre (au lieu d'au-dessus) pour gagner en hauteur.
- Le canevas carré fixe avec la photo en `contain` laissait des bandes noires quand elle ne
  remplissait pas le carré ; la carte prend maintenant exactement la forme (le ratio) de la photo
  choisie plutôt qu'un carré imposé — plus aucune bande, quelle que soit la photo.

## Clôture (2026-09-18)

Plan accepté par le PO. Le critère d'acceptation "PDF à 6 équipes et 9 trous tient sur une page"
n'a pas été testé manuellement (jugé peu prioritaire par le PO) ; le tableau du générateur PDF n'a
pas de logique de pagination ou de réduction automatique de police au-delà d'une certaine taille,
donc une session à beaucoup d'équipes/trous pourrait déborder d'une page A4 — à ajuster plus tard
si le cas se présente réellement.
