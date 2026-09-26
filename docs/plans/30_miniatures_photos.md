# Plan 30 — Photos : miniatures et allègement

## Statut

Plan rédigé le 2026-09-26, à la suite du plantage de la liste des trous sur iPhone (vidéo du
PO du même jour). **Validé par le PO le 2026-09-26** (Q201 à Q203 tranchées) ; implémentation
demandée le même jour.

**Code écrit et poussé sur `main` le 2026-09-26 à la demande du PO, avant son essai (il essaie en local).** Vérifié : `flutter analyze --fatal-infos`
sans remarque (script compris), 469 tests Flutter verts (dont les nouveaux : taille et chemin de
la miniature, repli miniature → photo → vide, visionneuse en version d'origine), build web
release compilé.
**Essai navigateur fait le 2026-09-26** (poste du PO, compte connecté) : les listes demandent
la miniature et retombent sur la photo entière quand elle manque ; la photo de la fiche trou
s'ouvre en plein écran ; un changement de photo par le PO (« Cool down », « Rhino ahead ») crée
bien la miniature. **Script de reprise lancé le 2026-09-26** : 32 photos réduites à 1600 px,
46 miniatures créées, aucun échec ; un second passage à blanc ne trouve plus rien à faire (un
passage lancé juste après a encore vu d'anciennes versions en cache, disparues ensuite).
**Pas encore vérifié** : la liste sur iPhone.
Écarts avec le plan, décidés à l'implémentation :
- La miniature est limitée par son plus petit côté (256 px), pas par sa largeur : une photo en
  paysage garde ainsi assez de hauteur pour une case carrée nette.
- Le formulaire d'un trou garde la photo entière dans sa case de 120 px (hors listes, une seule
  photo à la fois, décodée à sa taille d'affichage).
- La visionneuse de la galerie de session devient un composant partagé, `NuniPhotoViewer`,
  réutilisé par la fiche trou ; elle affiche une icône quand une photo ne se charge pas.
- Correctif après l'essai du PO (2026-09-26 : changement de photo très long, rien ne bouge
  pendant le traitement ; miniature de 65 Ko). Dans le navigateur, la réduction de la photo et
  la création de la miniature passent par le décodeur d'image et le canevas du navigateur
  (`lib/shared/photo_resize.dart`) : rapide, et la page reste réactive, donc l'indicateur de
  chargement tourne. Le code Dart pur (`photo_bytes.dart`) ne sert plus que hors navigateur
  (tests, script de reprise) ou quand le navigateur ne sait pas lire l'image ; il encode
  désormais en 4:2:0 comme les appareils photo, ce qui divise environ par deux le poids.
- Défaut corrigé au passage : `resizeForUpload` levait une exception sur un fichier illisible
  au lieu de renvoyer le fichier tel quel, comme l'annonce son commentaire.

Déjà fait (correctif du défaut, hors plan) : toute image réseau est décodée à sa taille
d'affichage (`lib/shared/display_sized_image.dart`), ce qui supprime le plantage. Ce plan traite
ce qui reste : la quantité de données téléchargées.

## Objectif

Qu'une liste de trous ou de sessions ne télécharge que de petites images, et qu'une fiche trou
ne télécharge jamais une photo de plusieurs Mo.

## Périmètre

- Photos de trou (bucket `holes`) : départ et arrivée.
- Photos de session (bucket `session-photos`) : galerie et couverture dans l'historique.
- Hors périmètre : photos de profil et logos d'association, déjà réduits à 512 px à l'envoi.

## Fonctionnement

1. **À l'envoi (Q201).** `PhotoField` et la galerie de session envoient la photo (1600 px, comme
   aujourd'hui) puis une miniature de 256 px (`resizeForUpload(bytes, maxWidth: 256)`) sous
   `<chemin>.thumb.jpg`, dans le même bucket, avec les mêmes droits.
2. **À l'affichage.** Les listes (trous, historique, galerie, bandeau de l'export image)
   demandent la miniature ; si elle n'existe pas encore (erreur de chargement), elles retombent
   sur la photo entière, toujours décodée à la taille d'affichage. La fiche trou et la
   visionneuse plein écran gardent la photo entière.
   Toute image qu'on touche pour l'agrandir s'ouvre en version d'origine (Q203) ; les photos de
   départ et d'arrivée de la fiche trou s'ouvrent dans la même visionneuse que la galerie de
   session (plein écran, zoom, balayage de l'une à l'autre).
3. **Suppression et clonage.** Toute suppression d'une photo supprime aussi sa miniature ; le
   clonage d'un trou (Q119) copie les deux.
4. **Reprise de l'existant (Q201, Q202).** Script `tool/backfill_photo_thumbnails.dart`, lancé une
   fois par le PO avec la clé de service, comme `migrate_lsgscores.dart` : pour chaque photo des
   deux buckets, crée la miniature manquante et réduit à 1600 px une photo plus grande.
   Relançable sans effet de bord (une miniature existante n'est pas refaite). Mode `--dry-run`
   qui compte sans écrire.

Aucun changement de schéma, de RLS ni de RPC : les chemins de miniature sont dérivés, pas
stockés.

## Critères d'acceptation

- La liste des trous défile sans plantage sur iPhone (déjà vrai après le correctif) et ne
  télécharge que des miniatures (vérifié dans l'onglet réseau du navigateur).
- Une photo ajoutée ou remplacée depuis l'app a sa miniature ; une photo supprimée n'en laisse
  pas.
- Après le script, chaque photo des buckets `holes` et `session-photos` a sa miniature, et
  aucune ne dépasse 1600 px.
- Toucher une photo de la fiche trou l'ouvre en plein écran, en version d'origine, avec zoom.
- Tests : dérivation du chemin de miniature, repli sur la photo entière, envoi des deux
  fichiers.
- `flutter analyze --fatal-infos` sans remarque, tests verts.
