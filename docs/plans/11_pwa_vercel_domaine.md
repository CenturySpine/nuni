# Plan 11 — PWA, déploiement Vercel, domaine

## Objectif

Faire de NUNI une PWA installable et à jour, déployée en continu sur nuni.centuryspine.org. La
première partie (coquille déployée) est réalisée juste après le plan 02 ; la finition (icônes,
mise à jour douce, performances) en fin de projet.

## Prérequis

Plan 02 (premiers commits). Projet Vercel à créer après ces commits.

## Décisions retenues

- H (Q17) : build dans GitHub Actions (`subosito/flutter-action`) puis `vercel deploy --prebuilt
  --prod` avec les secrets `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`. Prévisualisation par
  PR : même job sans `--prod`, URL commentée sur la PR. Vercel n'exécute aucun build.
- `vercel.json` : `rewrites` de toutes les routes vers `/index.html` (routage côté client),
  en-têtes `Cache-Control: no-cache` sur `index.html`, `flutter_service_worker.js`, `version.json`
  et `manifest.json` ; cache long sur les assets versionnés.
- Domaine : `nuni.centuryspine.org` ajouté au projet Vercel, enregistrement CNAME chez le
  registrar (comme les autres apps du domaine).
- Manifest : nom "NUNI", nom court "NUNI", description "Never Up, Never In", `display:
  standalone`, orientation portrait, couleur de thème = fond de la palette, icônes 192/512 et
  maskable générées à partir du logo "tee" actuel (extrait de l'ancien dépôt), icône Apple touch
  et balises meta iOS dans `index.html`.
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

1. Après le plan 02 : `vercel link` (crée le projet, type "Other", pas de build command), récupérer
   les identifiants, secrets GitHub, job de déploiement dans `ci.yml`, `vercel.json`, premier
   déploiement de la coquille, ajout du domaine et du CNAME, vérification HTTPS. Relever la
   région du projet Vercel et la reporter dans la page Mentions légales (Q21).
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
