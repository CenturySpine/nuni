# Plan 11 — PWA, déploiement Vercel, domaine

## Objectif

Faire de NUNI une PWA installable et à jour, déployée en continu sur nuni.centuryspine.org. La
première partie (coquille déployée) est réalisée juste après le plan 02 ; la finition (icônes,
mise à jour douce, performances) en fin de projet.

## Prérequis

Plan 02 (premiers commits). Projet Vercel à créer après ces commits.

## Décisions retenues

- Q17 (PO 2026-09-15) : build dans GitHub Actions (`subosito/flutter-action`) puis livraison à
  Vercel dans le même job de `ci.yml` : `vercel pull`, `vercel build`, `vercel deploy --prebuilt`
  avec les secrets GitHub `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`. Sur `main` :
  `--prod`. Sur toute autre branche : prévisualisation (sans `--prod`), URL écrite dans le résumé
  du job GitHub, pas de commentaire de PR (pas de PR obligatoire). Le projet Vercel est créé par
  `vercel link` et **n'est pas relié au dépôt GitHub** : Vercel n'exécute aucun build, il héberge.
  Le build lit `SUPABASE_URL` et `SUPABASE_ANON_KEY` depuis les secrets GitHub (Q2) ; la clé anon
  n'est pas un secret au sens strict (elle est embarquée dans le site), c'est RLS qui protège.
  Vérifié le 2026-09-15 dans le code source public du CLI Vercel : sans framework ni commande de
  build, avec un dossier de sortie `build/web` non vide, `vercel build` empaquette ce dossier tel
  quel (`@vercel/static`, `packages/fs-detectors/src/detect-builders.ts`) sans rien compiler ; les
  variables `VERCEL_ORG_ID` et `VERCEL_PROJECT_ID` remplacent le fichier de liaison
  `.vercel/project.json` (`packages/cli/src/util/projects/link.ts`), donc pas de `vercel link`
  dans le workflow. `vercel.json` porte `"framework": null` et `"outputDirectory": "build/web"`
  pour que ces réglages soient versionnés et non seulement saisis dans l'interface Vercel.
- Option écartée mais documentée : faire compiler Flutter par Vercel (commande de build qui
  télécharge Flutter). Éprouvée, sans jeton ni workflow, mais 3 à 6 min de plus par build et
  dépendante de l'image Vercel. Repli possible sans toucher au code de l'app.
- `vercel.json` : `rewrites` de toutes les routes vers `/index.html` (routage côté client),
  en-têtes `Cache-Control: no-cache` sur `index.html`, `flutter_service_worker.js`, `version.json`
  et `manifest.json` ; cache long sur les assets versionnés.
- Domaine : `nuni.centuryspine.org` ajouté au projet Vercel, enregistrement CNAME chez le
  registrar (comme les autres apps du domaine).
- Manifest : nom "NUNI", nom court "NUNI", description "Never Up, Never In", `display:
  standalone`, orientation portrait, couleur de thème = fond de la palette, icônes 192/512 et
  maskable générées depuis le logo NUNI (Q23, `web/icons/nuni_logo.svg`, faites au plan 02),
  icône Apple touch et balises meta iOS dans `index.html`.
- H (Q18) : mise à jour douce. Le service worker Flutter précharge la nouvelle version ; l'app
  compare périodiquement `version.json` (généré par Flutter à chaque build, contient
  `build_number`) et affiche un bandeau "Nouvelle version disponible — Recharger". Version affichée
  dans les réglages. Plus de blocage ni de table `app_versions`.
- Build : `flutter build web --release` avec le moteur par défaut du canal stable (CanvasKit/Wasm
  selon la version) ; mesurer le temps de premier affichage sur 4G et, si nécessaire, activer
  `--wasm` ou ajuster. Chargement différé des paquets lourds (PDF, carte) via `deferred as` si le
  bundle initial dépasse 3 Mo compressés.
- Analytique et journaux : aucun dans cette version (simplicité, RGPD). Erreurs remontées
  seulement dans la console. Une intégration Sentry est possible plus tard.
- Pages légales : ce sont des routes de l'app (`/legal`, `/privacy`, `/about`, plan 04), donc
  déjà servies par Vercel grâce à la réécriture vers `index.html`. Les URL
  `https://nuni.centuryspine.org/privacy` et `/legal` sont déclarées dans l'écran de consentement
  Google (Q20). Pas de fichiers HTML séparés.

## Étapes

1. **Quand : maintenant, dès que `main` contient le plan 02** (fait le 2026-09-15). Deux parties.

   **1a. À faire par le PO lui-même (demande explicite du 2026-09-15, Claude ne le fait pas en
   automatique)**, depuis son terminal, dans le dépôt :
   - `vercel project add nuni` : crée le projet Vercel `nuni`, **sans le relier au dépôt GitHub**
     (c'est GitHub Actions qui livre ; si Vercel était relié à GitHub, il tenterait lui aussi un
     build à chaque push et échouerait faute de Flutter).
   - `vercel link --yes --project nuni` : écrit `.vercel/project.json` (ignoré par git) qui
     contient `orgId` et `projectId`.
   - Sur vercel.com, Account Settings → Tokens : créer un jeton nommé `nuni-github-actions`,
     portée limitée au compte, expiration au choix. Le jeton s'affiche une seule fois.
   - Sur github.com, dépôt `nuni` → Settings → Secrets and variables → Actions → New repository
     secret, cinq secrets : `VERCEL_TOKEN` (le jeton), `VERCEL_ORG_ID` et `VERCEL_PROJECT_ID`
     (les deux valeurs de `.vercel/project.json`), `SUPABASE_URL` et `SUPABASE_ANON_KEY` (Q2,
     tableau de bord Supabase → Project Settings → API).
   - Prévenir Claude que c'est fait. Aucune de ces valeurs ne doit être collée dans une
     conversation ni dans le dépôt.

   **1b. Claude ensuite** : `vercel.json` (`framework: null`, `outputDirectory: build/web`,
   réécritures et en-têtes de cache), étapes `vercel pull` / `vercel build` / `vercel deploy
   --prebuilt` ajoutées au job de `ci.yml` (`--prod` sur `main`, prévisualisation ailleurs),
   push sur `main`, vérification du premier déploiement sur l'URL `*.vercel.app`, puis ajout du
   domaine `nuni.centuryspine.org` (le CNAME chez le registrar est fait par le PO, valeur
   fournie par Vercel), vérification HTTPS. Relever la région du projet Vercel et la reporter
   dans la page Mentions légales (Q21).
2. Ajouter l'URL de production aux redirections autorisées de Supabase Auth (plan 03).
3. Fin de projet : icônes et manifest définitifs, bandeau de mise à jour, mesure Lighthouse (PWA
   installable, performance mobile), vérification que `/privacy`, `/legal` et `/about` répondent
   en accès direct sans connexion.
4. Test d'installation : "Ajouter à l'écran d'accueil" sur Android (Chrome) et iOS (Safari),
   lancement en plein écran, retour d'auth Google dans la PWA installée.

## Livrables

- Déploiement continu, domaine actif, PWA installable, mise à jour douce.

## Critères d'acceptation

- Un push sur `main` est en ligne en moins de 10 minutes.
- Lighthouse : installable, performance mobile ≥ 80.
- Après un déploiement, une app ouverte propose la mise à jour en moins de 5 minutes sans casser
  une saisie en cours.

## Questions PO liées

Q17, Q18.
