# Plan 34 — Performances du chargement

## Statut

Plan rédigé le 2026-09-29 à la demande du PO du même jour. Réponses du PO le 2026-09-30 :
Q239 (cache d'un mois), Q240 (différé pour l'export PDF et l'import d'agenda, pas pour le scan
de QR code), Q238 (logo fixe et trois points, reformulée) et Q243 (carte différée). Toutes les
questions sont tranchées. **Plan validé par le PO le 2026-09-30.**

## Demande du PO (reformulée)

Pendant la session du 2026-09-28, un joueur sur un réseau mobile très faible n'a pas réussi à
afficher la page de connexion ; tout s'est chargé une fois son téléphone passé sur le partage de
connexion du PO. Rendre l'app utilisable sur un mauvais réseau, en premier lieu son ouverture.

## Existant (constat, mesuré le 2026-09-29)

Tailles de la compilation de production (`build/web`), transférées compressées (Brotli, ce que
Vercel envoie réellement, vérifié sur nuni.centuryspine.org) :

| Fichier | Rôle | Brut | Transféré |
|---|---|---|---|
| `main.dart.js` | tout le code de l'app | 6,4 Mo | 1,3 Mo |
| `canvaskit/chromium/canvaskit.wasm` | moteur d'affichage (Chrome, Android) | 5,4 Mo | 1,5 Mo |
| `canvaskit/canvaskit.wasm` | moteur d'affichage (Safari, iPhone, Firefox) | 7,3 Mo | 2,3 Mo |
| Polices Plus Jakarta Sans (5 graisses) | texte | 5 × 129 Ko | ≈ 0,4 Mo |
| Polices Phosphor, icônes Material, divers | icônes | ≈ 70 Ko | ≈ 50 Ko |

- **Environ 3,5 Mo (Android) à 4 Mo (iPhone) doivent arriver avant le premier affichage.**
  Pendant ce temps, l'écran reste blanc : `index.html` ne contient rien de visible. Sur un
  réseau à 500 kbit/s, cela fait environ une minute ; l'utilisateur croit l'app cassée.
- **Aucun cache durable.** Tout est servi avec `Cache-Control: public, max-age=0,
  must-revalidate` (réglage par défaut de Vercel) : à chaque ouverture, le navigateur redemande
  au serveur, fichier par fichier, si rien n'a changé. Sur un réseau lent, chaque question coûte
  un aller-retour, même quand la réponse est « rien n'a changé ».
- **Aucun service worker ne garde l'app** : celui de Flutter est retiré depuis le plan 33
  (`web/flutter_bootstrap.js`), `web/nuni_sw.js` ne sert qu'aux notifications.
- Les 5 graisses de police sont toutes utilisées (400 à 800, relevé dans `lib/`) : rien à
  retirer de ce côté.
- Vérifié dans le code de `supabase_flutter` 2.17.2 : `Supabase.initialize` (attendu dans
  `main.dart`) ne patiente pas pour rafraîchir une session enregistrée, ce rafraîchissement part
  en arrière-plan. Le démarrage n'attend donc pas le serveur : cette piste est écartée.
- Historique : Q22 (2026-09-15) sert le moteur depuis le site plutôt que depuis Google
  (`--no-web-resources-cdn`), pour ne pas dépendre d'un serveur tiers. Le plan 11 prévoyait de
  mesurer sur 4G et, au besoin, le chargement différé ou `--wasm` ; la mesure n'a pas été faite.

## Ce qui change pour l'utilisateur

1. **Un écran de chargement s'affiche tout de suite** : le logo NUNI fixe, avec sous lui trois
   points qui clignotent, aux couleurs de la palette par défaut, dès les premiers kilo-octets,
   au lieu d'une page blanche. Il disparaît quand l'app s'affiche (Q238).
2. **Les ouvertures suivantes sont plus rapides** : le moteur d'affichage est gardé un mois par
   le téléphone et n'est plus redemandé entre-temps (Q239).
3. **Le premier chargement est plus léger** : l'export PDF, l'import d'agenda et la carte (si
   la mesure le justifie pour chacun) ne sont téléchargés qu'à leur première utilisation (Q240, Q243). Le
   scan de QR code, le plus utilisé, reste disponible tout de suite.

Rien ne change dans les écrans eux-mêmes.

## Décisions techniques

1. **Mesure d'abord, puis après chaque étape.** Lighthouse (outil de mesure de Google, lancé en
   ligne de commande par `npx lighthouse`) sur l'app déployée et sur une compilation locale,
   avec un réseau lent simulé (profil « Slow 4G ») : temps avant le premier affichage, octets
   transférés. Les chiffres avant/après sont consignés dans ce plan. Si Chrome manque au terminal
   de l'assistant, demande au PO (règle 3).
2. **Écran de chargement dans `web/index.html`** (Q238) : HTML et CSS seuls, sans image externe
   (logo SVG en ligne, fixe ; sous lui, trois points qui clignotent l'un après l'autre en CSS),
   donc affiché avec le seul `index.html` (quelques Ko transférés). Aucun texte : pas de langue à choisir avant que l'app soit chargée, et pas
   d'exception à la règle des ARB. Retiré au premier affichage de Flutter (l'écran de Flutter se
   pose par-dessus, puis le bloc est supprimé dans `flutter_bootstrap.js` quand
   `_flutter.loader.load` rend la main). Couleurs : celles de la palette par défaut, écrites
   dans `index.html` (hors `lib/`, la règle des couleurs de `lib/core/theme/` ne s'y applique
   pas ; commentaire qui renvoie à `palettes.dart`).
3. **Moteur d'affichage dans un dossier versionné, gardé un mois** (Q239) :
   - `tool/vercel_build.sh` déplace `build/web/canvaskit/` vers
     `build/web/canvaskit/<révision du moteur Flutter>/` (lue dans `build/web/flutter_bootstrap.js`
     ou `flutter --version --machine`) ;
   - `web/flutter_bootstrap.js` passe `canvasKitBaseUrl` à `_flutter.loader.load` ;
   - `vercel.json` sert `/canvaskit/(.*)` avec `Cache-Control: public, max-age=2592000,
     immutable` (30 jours, Q239). Une mise à jour de Flutter change le dossier : pas de mélange
     possible entre un ancien moteur gardé et un nouveau code.
   - `main.dart.js`, `index.html` et les polices gardent la revalidation actuelle : ils ne
     portent pas de numéro de version dans leur nom, les garder longtemps servirait une
     ancienne version après une mise en ligne.
4. **Chargement différé** (Q240, Q243) : `import … deferred as` de Dart pour les écrans et
   services qui tirent `pdf`/`printing` (export) et `ics_parser.dart` (import d'agenda), et
   `flutter_map` (carte, Q243). **Jamais `mobile_scanner`** (scan de QR code,
   Q240). La mesure (`flutter build web --dump-info` donne la part de chaque paquet dans
   `main.dart.js`) décide : on ne diffère que ce qui retire au moins 100 Ko transférés. Chaque point
   d'entrée affiche un indicateur le temps du téléchargement, et un message d'erreur traduit si
   le réseau manque.
5. **`--wasm` (moteur « skwasm »)** : essayé et mesuré sur une compilation locale, adopté
   seulement si le premier affichage est plus rapide sur Android **et** si tous les paquets
   compilent. Safari (iPhone) ne le prend pas en charge et retombe sur la version actuelle :
   aucun risque pour lui, mais aucun gain non plus. Sinon, abandonné et consigné ici.
6. **Hors ligne complet : pas dans ce plan.** Un service worker qui garde toute l'app relève du
   plan 22 (hors ligne) : il doit gérer les mises à jour (Q99, Q100), ce qui dépasse le
   chargement.

## Étapes

1. Mesure de référence (décision 1), consignée dans ce plan.
2. Écran de chargement (décision 2) ; essai dans le navigateur intégré avec le réseau ralenti.
3. Moteur versionné et cache long (décision 3) ; vérification des en-têtes sur un déploiement
   Vercel, puis d'une deuxième ouverture sans téléchargement du moteur.
4. `--dump-info`, puis chargement différé des paquets qui passent le seuil (décision 4) ;
   tests de widgets des points d'entrée (indicateur, erreur réseau).
5. Essai `--wasm` (décision 5), adopté ou abandonné sur mesure.
6. Mesure finale, `docs/DEV.md` à jour (build, dossier du moteur), `AGENTS.md` relu.
7. Essai du PO sur un réseau lent réel (téléphone en 3G ou partage de connexion bridé).

## Hors périmètre

- Hors ligne, file d'attente des scores, service worker de cache : plan 22.
- Vitesse des écrans une fois l'app ouverte (requêtes Supabase, images) : les miniatures du
  plan 30 couvrent déjà les listes ; à rouvrir sur un constat précis.
- Retour du moteur servi par Google (Q22) : écarté, il ferait dépendre l'ouverture d'un
  serveur tiers, pour un gain que le cache versionné apporte aussi.

## Critères d'acceptation

- [ ] Mesures avant/après consignées (temps avant premier affichage en « Slow 4G », octets
      transférés au premier chargement et à une deuxième ouverture).
- [ ] Sur un réseau lent, un écran de chargement apparaît en moins de 2 s, sans page blanche.
- [ ] À une deuxième ouverture, le moteur d'affichage n'est pas retéléchargé (vérifié dans
      l'onglet réseau : servi par le cache).
- [ ] Après une montée de version de Flutter, l'app s'ouvre sans erreur sur un téléphone qui
      avait l'ancien moteur en cache.
- [ ] Export PDF, import d'agenda et carte fonctionnent comme avant, avec un
      indicateur pendant leur premier chargement et un message traduit sans réseau.
- [ ] Le scan de QR code s'ouvre sans téléchargement supplémentaire du code de l'app.
- [ ] Décision `--wasm` consignée avec sa mesure.
- [ ] Essai du PO sur un réseau lent réel.
- [ ] Chaînes EN et FR, `flutter analyze` et tests verts, build Vercel vert.

## Questions PO liées

Q238 (écran de chargement), Q239 (moteur gardé par le téléphone), Q240 (chargement différé),
Q243 (carte).
