# Plan 04 — Socle applicatif : design system minimal, i18n, navigation

## Objectif

Poser le thème unique, les traductions EN/FR, la coquille de navigation et les composants de base
sur lesquels tous les écrans suivants s'appuient. Le mot d'ordre est la simplicité : peu de
couleurs, peu de composants, tout en Material 3 standard.

## Prérequis

Plan 02. Peut se dérouler en parallèle du plan 03.

## Décisions retenues

- Logo (Q23) : widget `NuniLogo` reproduisant `web/icons/nuni_logo.svg` ("NU" sur "NI", blocs
  de même largeur et hauteur, deux couleurs neutres), utilisé sur l'écran de connexion et
  l'en-tête. Construction en formes Flutter (CustomPainter) ou rendu du SVG via `flutter_svg` :
  à choisir ici selon la simplicité, le SVG restant la source unique.

- Un seul thème clair. Pas de mode sombre (sauf demande ultérieure).
- Q1 et Q1b tranchées : cinq variantes de palette documentées dans `docs/design/PALETTE.md`
  (01-A, 01-B, 02-A, 02-B, 03-B) sont définies dans `core/theme/palettes.dart`, chacune avec ses
  5 couleurs nommées (fond, texte, accent, erreur `#E24B4A`, succès `#1D9E75`) et sa couleur de
  cartouche. Une constante `activePalette` désigne la palette utilisée : **03-B "Urban claire"**
  (fond `#E9E6E7`, texte `#5E5653`, accent `#6B7C98`, cartouches blancs). Aucun réglage de thème
  n'est exposé à l'utilisateur ; changer de palette = changer la constante. Tout le reste est
  dérivé par opacité ou mélange, jamais par nouvelle teinte :
  - surface des cartouches : fond mélangé à 6 % d'accent ;
  - bordures, séparateurs : texte à 15 % ;
  - texte secondaire : texte à 60 % ; désactivé : 40 % ;
  - sélection / focus : accent à 12 % en fond, accent plein en contour.
  Implémentation : `ColorScheme` Material 3 construit explicitement à partir de ces 5 couleurs
  (pas `fromSeed`, qui génère justement des dizaines de nuances), exposé via `ThemeData`.
- Typographie : police système (aucune police embarquée), 4 tailles utilisées (titre, sous-titre,
  corps, étiquette).
- Composants de base (dossier `shared/`) : `NuniScaffold` (barre de titre + contenu + actions
  collantes en bas), `NuniCard`, `NuniButton` (primaire / secondaire / danger), `NuniChip`,
  `NuniEmptyState`, `NuniConfirmDialog`, `NuniLoading`, `NuniErrorBanner`.
- i18n : mécanisme officiel Flutter (`flutter_localizations` + fichiers ARB `app_en.arb`,
  `app_fr.arb`, génération `gen-l10n`). Langue = celle du navigateur par défaut, surcharge
  possible dans les réglages, mémorisée localement et dans `profiles.locale`.
- Navigation : `go_router` avec un shell à barre du bas de 3 entrées : **Accueil** (mes sessions
  en direct, créer, rejoindre), **Trous**, **Historique**. Le profil et les réglages sont
  accessibles depuis l'avatar en haut à droite. Plus de tiroir latéral.
- Routes : `/` accueil, `/join/:code`, `/session/new`, `/session/:id` (live), `/session/:id/hole/:playedHoleId`
  (saisie), `/history`, `/history/:id`, `/holes`, `/holes/new`, `/holes/:id`, `/profile`, `/settings`,
  `/login`, et trois pages publiques : `/legal` (mentions légales), `/privacy` (politique de
  confidentialité, RGPD), `/about` (à propos). Garde d'authentification par redirection dans le
  routeur ; routes publiques sans connexion : `/login`, `/legal`, `/privacy`, `/about`, et
  `/join/:code` qui mémorise le code puis redirige vers `/login`.
- Pages usuelles :
  - **Mentions légales** `/legal` (Q21 tranchée) : éditeur Bruno Chappe, contact
    bruno.chappe@gmail.com, hébergeur du site Vercel (région du projet, à reporter après le
    plan 11), hébergeur des données Supabase, région West EU (Paris).
  - **Confidentialité** `/privacy` : données traitées (identité Google : e-mail, nom, avatar ;
    joueurs, sessions et coups ; position GPS au moment de la création d'une session ou d'un trou,
    jamais en continu ; photos envoyées volontairement), finalités, durée de conservation (tant que
    le compte existe), droits (accès, rectification, effacement via "Supprimer mon compte" dans
    l'app, contact e-mail), absence de suivi et d'analytique, cookies limités à la session de
    connexion. Cette page sert aussi d'URL de politique de confidentialité pour l'écran de
    consentement Google (Q20).
  - **À propos** `/about` : NUNI, "Never Up, Never In", version de l'app, lien vers la page
    unifiée https://centuryspine.org, lien vers le code source si le dépôt est public.
  - Les trois pages sont des écrans Flutter ordinaires (texte traduit EN/FR dans les ARB), avec
    un pied de page commun dans les réglages et sur l'écran de connexion qui y renvoie. Pas de
    fichiers HTML séparés : une seule source, une seule mise en page, une seule traduction.
- Format des dates : `intl` selon la locale.

## Étapes

1. `core/theme/`: `palettes.dart` (les cinq variantes + `activePalette`), construction du
   `ColorScheme` et du `ThemeData` à partir de la palette active, page de démonstration interne
   `/dev/theme` (désactivée en production) montrant tous les composants avec la palette active.
   Un test unitaire vérifie pour chaque variante le contraste texte/fond (≥ 4,5:1, AA) afin qu'un
   changement de constante ne dégrade pas la lisibilité. Pas de test automatique sur accent/fond :
   en écrivant le test, 01-B et 02-B se sont révélées sous les 3:1 (2,15:1 et 2,51:1) — l'accent y
   sert de surface de bouton plein, pas de texte ni de contour libre sur le fond, et c'est le
   contraste texte-sur-accent qui compte (bon partout, vérifié à la main dans
   `docs/design/PALETTE.md`). Décision PO (2026-09-15) : garder les 5 variantes codées, sans
   assertion automatique sur l'accent.
2. `core/l10n/` : configuration `l10n.yaml`, ARB EN et FR avec les premières clés (navigation,
   actions communes, erreurs), fournisseur de locale Riverpod.
3. `core/router/` : routeur, shell, garde d'auth (bouchon en attendant le plan 05), page 404.
4. `shared/` : composants listés ci-dessus, chacun avec un test widget minimal.
5. Réglages : page `/settings` avec langue, version, et liens vers Mentions légales,
   Confidentialité, À propos. Pages `/legal`, `/privacy`, `/about` avec un composant commun de
   page de texte long (titre, sections, liens), contenus dans les ARB, textes de première version
   rédigés par Claude et validés par le PO (Q21).
6. Vérification sur téléphone réel via Chrome (adresse locale du PC) : zones tactiles ≥ 44 px,
   marges, lisibilité en plein soleil (contraste texte/fond ≥ 4,5:1 vérifié).

## Livrables

- Thème, composants, i18n, routeur, page réglages, pages Mentions légales / Confidentialité /
  À propos (EN et FR).
- Capture d'écran de la page de démonstration du thème (palette active 03-B) pour validation PO,
  archivée dans `docs/design/PALETTE.md`.

## Critères d'acceptation

- Basculer la langue change toute l'interface sans rechargement.
- La page de démonstration n'utilise que les 5 couleurs nommées (vérification par revue de code :
  aucune `Color(0x…)` hors `core/theme`).
- Contraste AA respecté ; le test de contraste passe pour les cinq variantes.
- Changer `activePalette` et relancer l'app suffit à basculer toute l'interface.

## Questions PO liées

Q1 et Q1b tranchées (cinq palettes codées, 03-B active, aucun choix utilisateur). Jalon de
validation 2 du plan d'ensemble.
