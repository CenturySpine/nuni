# Plan 11 — PWA, déploiement Vercel, domaine

## Objectif

Faire de NUNI une PWA installable et à jour, déployée en continu sur nuni.centuryspine.org. La
première partie (coquille déployée) est réalisée juste après le plan 02 ; la finition (icônes,
mise à jour douce, performances) en fin de projet.

## Prérequis

Plan 02 (premiers commits). Projet Vercel à créer après ces commits.

## Décisions retenues

- Q17 (revirement PO 2026-09-15) : **Vercel compile et déploie**, projet Vercel relié au dépôt
  GitHub `CenturySpine/nuni`. `vercel.json` : `framework: null`, `installCommand: ""` (pas de
  `npm install`, vérifié dans le code source du builder Vercel : une commande vide saute
  l'étape), `buildCommand: bash tool/vercel_build.sh`, `outputDirectory: build/web`,
  `ignoreCommand` qui saute le build quand seul `docs/` ou des `.md` changent. Le script installe
  la version Flutter de `.fvmrc` (clone superficiel du tag, retéléchargé à chaque build faute de
  cache, compter 3 à 6 min), écrit `env/prod.json` depuis les variables d'environnement Vercel
  `SUPABASE_URL` et `SUPABASE_ANON_KEY`, puis `pub get`, `analyze --fatal-infos`, `test`, `build
  web --release --no-web-resources-cdn`. `main` = production, autres branches = prévisualisation,
  état du déploiement remonté sur le commit GitHub. Option écartée : GitHub Actions + `vercel
  deploy --prebuilt` (mise en place le matin, retirée le jour même : jeton, secrets et projet
  hors Git en plus, pour un gain de 2 à 3 min par build).
- `vercel.json` : `rewrites` de toutes les routes vers `/index.html` (routage côté client),
  en-têtes `Cache-Control: no-cache` sur `index.html`, `flutter_bootstrap.js`,
  `flutter_service_worker.js`, `version.json` et `manifest.json`. Pas de cache long sur le reste :
  Flutter ne versionne pas ses fichiers (`main.dart.js` garde le même nom), c'est le service
  worker qui gère le cache côté client.
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

1. **Quand : maintenant, `main` contient `vercel.json` et le script de build** (2026-09-15).

   **1a. À faire par le PO lui-même (demande explicite du 2026-09-15, Claude ne le fait pas en
   automatique)**, sur vercel.com :
   - Add New → Project → Import Git Repository → `CenturySpine/nuni`. Nom du projet : `nuni`.
   - Framework Preset : "Other" (les réglages de build sont de toute façon pris dans
     `vercel.json` du dépôt ; ne rien saisir dans Build Command, Output Directory ni Install
     Command).
   - Environment Variables : `SUPABASE_URL` et `SUPABASE_ANON_KEY` (tableau de bord Supabase →
     Project Settings → API), pour les trois environnements (Production, Preview, Development).
     Elles peuvent être ajoutées après le premier build, qui passera avec des valeurs vides.
   - Deploy. Le premier build dure 3 à 6 min (téléchargement de Flutter). Puis Settings → Git :
     Production Branch = `main` (défaut).
   - Prévenir Claude : URL `*.vercel.app` obtenue, et durée du premier build affichée par Vercel.

   **1b. Claude ensuite** : vérification de la page d'accueil sur l'URL `*.vercel.app` et de la
   coche verte sur le commit GitHub, puis ajout du domaine `nuni.centuryspine.org` dans le
   projet (Settings → Domains ; le CNAME chez le registrar est saisi par le PO avec la valeur
   indiquée par Vercel), vérification HTTPS. Relever la région du projet Vercel et la reporter
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
