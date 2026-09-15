# Questions au product owner

Chaque question porte une suggestion argumentée par la technique et l'état de l'art Flutter /
Supabase, pas par une préférence. Tant qu'une question est ouverte, le plan concerné applique la
suggestion comme hypothèse de travail (marquée "H" dans les plans).

Statut : ☐ ouverte · ☑ tranchée (réponse notée en dessous).

## Palette et design (étape 4)

**Q1 ☐ — Une palette de 3 couleurs suffit-elle ?**
Réponse technique : 3 couleurs suffisent comme *entrée*, à condition que ce soient les trois rôles
suivants : **fond**, **accent** (boutons, liens, sélection), **texte**. Tout le reste est dérivé
mécaniquement, sans nouvelle teinte : cartouches = fond légèrement teinté par l'accent, bordures et
séparateurs = texte à 15 % d'opacité, texte secondaire = texte à 60 %, états désactivés = 40 %.
Deux couleurs sémantiques fixes s'ajoutent, que je choisis et qui ne bougent jamais : **erreur /
danger** (suppressions, scores manquants) et **succès** (leader, dernier trou). Total : 5 couleurs
nommées, aucune nuance supplémentaire. Mode sombre : non prévu (un seul thème), sauf demande.
Suggestion : me donner 3 couleurs (fond, accent, texte) et me laisser fixer erreur et succès.
Réponse PO (2026-09-14) : palette https://coolors.co/272838-f3de8a-eb9486, soit `#272838`
(bleu nuit), `#F3DE8A` (jaune pâle), `#EB9486` (corail). Aucune n'est un "fond" évident.
Deux répartitions cohérentes, contraste vérifié :
- **A, sombre** (hypothèse par défaut) : fond `#272838`, texte `#F3DE8A`, accent `#EB9486`.
  Contraste texte/fond 10:1, accent/fond 6:1. Les trois couleurs sont utilisées telles quelles,
  aucune couleur neutre ajoutée : c'est la répartition la plus fidèle et la plus simple.
- **B, claire** : fond = `#F3DE8A` éclairci par mélange au blanc (environ `#FCF7E3`), cartouches
  blancs, texte `#272838`, accent `#EB9486`. Contraste texte/fond 12:1. Plus lisible en plein
  soleil sur un écran peu lumineux, mais introduit le blanc comme neutre.
Décision reportée à la page de démonstration du thème (étape 4) : les deux répartitions y seront
basculables, choix sur téléphone en extérieur, puis la bascule est retirée. Erreur `#E24B4A` et
succès `#1D9E75` restent fixés par moi dans les deux cas.

**Q1b ☑ — Quelle palette et quelle répartition ?**
Réponse PO (2026-09-14) : les cinq variantes viables (01-A, 01-B, 02-A, 02-B, 03-B ; 03-A exclue)
sont codées dans l'app. La palette **active est 03-B "Urban claire"** (fond `#E9E6E7`, texte
`#5E5653`, accent `#6B7C98`). Les quatre autres restent prêtes et interchangeables par un simple
changement de référence dans le code ; elles ne sont **pas** proposées à l'utilisateur (aucun
réglage de thème). Plus de page de démonstration avec bascule : la comparaison sur téléphone se
fait, si besoin, en changeant la constante et en relançant l'app.
Suivi détaillé des essais (sources, valeurs, contrastes, maquettes) : [design/PALETTE.md](design/PALETTE.md).

## Backend Supabase (étape 3)

**Q2 ☑ — Nouveau projet Supabase `nuni` ou nouveau schéma dans le projet existant ?**
Suggestion : nouveau projet. Isolation totale de l'ancienne app (qui reste utilisable pendant la
transition), migrations propres versionnées dans le dépôt, aucune contrainte héritée.
Réponse PO (2026-09-14) : nouveau projet, déjà créé. URL `https://zlxfmovibepgdmxacbpj.supabase.co`,
référence `zlxfmovibepgdmxacbpj`. La clé anon sera fournie hors dépôt (fichier `env/*.json`
ignoré par git et secrets GitHub Actions).

**Q3 ☑ — Faut-il reprendre les anciennes données (trous, sessions passées) ?**
Suggestion initiale : pas de reprise automatique au démarrage, décision différée.
Réponse PO (2026-09-14) : pas de reprise au démarrage, mais la migration des données est
**nécessaire et critique** : les sessions existantes doivent pouvoir être importées. Le plan
détaillé de migration est établi une fois le reste fonctionnel ; partir d'un nouveau schéma permet
de le faire sereinement. Conséquences : étape 13 dédiée dans le plan d'ensemble ; le schéma
(plan 03) prévoit dès maintenant des colonnes `legacy_id` nullables sur `players`, `holes`,
`sessions`, `teams`, `played_holes` pour un import idempotent et traçable. Les questions fines de
la migration (position des anciens trous, ville des anciennes sessions, joueurs sans compte) sont
reportées au plan 13.

**Q4 ☑ — Lien utilisateur ↔ joueur : table de lien (comme demandé) ou colonne `user_id`
nullable et unique sur `players` ?**
Suggestion : la colonne est fonctionnellement identique (un joueur appartient à au plus un
utilisateur, un utilisateur a au plus un joueur) et simplifie toutes les requêtes et politiques.
Réponse PO (2026-09-14) : colonne retenue. L'exigence de fond est la séparation des notions
"joueur" et "utilisateur", qui est conservée : `players` reste une table indépendante de
`profiles`, un joueur peut exister sans utilisateur, et `players.user_id uuid null unique`
matérialise le lien. Plus de table `user_player_link`.

**Q5 ☑ — Composition des équipes : 1 ou 2 joueurs fixes (comme avant) ou table de jointure
`team_players` sans limite technique ?**
Suggestion : table de jointure avec une règle applicative "1 joueur en individuel, 2 en équipe".
Coût identique, et le jour où une session à 3 par équipe est souhaitée, seule la règle change.
Réponse PO (2026-09-14) : table de jointure retenue.

**Q6 ☑ — Modes de scoring et modes de jeu : table en base (comme avant) ou énumérations dans le
code ?**
Réponse PO (2026-09-14) : énumérations dans le code, stockées en texte (enum Postgres) sur la
session et le trou joué.
Suggestion : énumérations dans le code, stockées en texte sur la session et le trou joué. Les
règles de calcul sont de toute façon en Dart (testées unitairement), les libellés sont traduits
dans l'app, et l'ancienne table `scoring_modes` n'apportait qu'un risque d'incohérence
(la factory et la seed SQL étaient déjà désalignées sur l'id 3).

**Q7 ☑ — Les 3 modes de scoring actuels (Stroke Play, Match Play, Redistribution) sont-ils tous à
conserver ? Le 4e calculateur présent dans le code (3 points au leader solo, 2 aux ex æquo) doit-il
exister ?**
Suggestion : conserver les trois modes documentés et abandonner le 4e, jamais exposé.
Réponse PO (2026-09-14) : les trois modes sont conservés, le calculateur "3/2" est abandonné. Le PO
souhaite en plus un mode **Libre** (points saisis arbitrairement par trou, pour des règles
inventées sur le tas). Ce mode n'existait pas dans l'ancienne app ; il est ajouté au modèle
(enum `scoring_mode` : `stroke_play`, `match_play`, `redistribution`, `free`). Voir Q7b.

**Q7b ☑ — Paramètres du mode Libre.**
Suggestion : par trou et par équipe, on saisit un nombre de **points** (entier de 0 à 20, mêmes
chips que les coups, "X" remplacé par un champ numérique au-delà de 9), sans saisie de coups ;
égalités affichées ex æquo ; exports identiques aux modes à points avec la colonne coups masquée.
Pas de points négatifs.
Réponse PO (2026-09-14) : suggestion acceptée, avec une exigence supplémentaire : le mode Libre
doit préciser le **sens du classement**, "le plus élevé gagne" ou "le plus bas gagne".
Modélisation retenue : colonne `sessions.ranking_direction` (enum `desc` | `asc`), choisie à la
création de la session quand le mode Libre est sélectionné (défaut `desc`), affichée dans
l'en-tête de session et les exports ("Libre · le plus haut gagne"). Pour les trois autres modes
la colonne est déduite du mode et non modifiable.

**Q8 ☑ — Qui peut saisir le score d'une équipe ?**
Réponse PO (2026-09-14) : suggestion retenue. Un membre ne saisit que sa propre équipe ; le
créateur (et tout co-organisateur) saisit toutes les équipes, ce qui couvre le cas "un seul
téléphone sert de marqueur", puisque c'est celui du créateur.
Suggestion : chaque membre saisit sa propre équipe ; le créateur de la session peut saisir toutes
les équipes (comportement actuel). Toute écriture est "dernier écrit gagne" avec affichage de qui a
saisi et quand. Alternative plus ouverte : tout membre saisit toute équipe (utile si un seul
téléphone sert de "marqueur"). Les deux sont un simple paramètre de politique RLS.

**Q9 ☑ — Une session en direct par créateur, ou plusieurs ?**
Réponse PO (2026-09-14) : suggestion retenue, plusieurs sessions en direct par utilisateur, listées
sur l'accueil.
L'ancienne règle "une session en cours par ville" disparaît avec le référentiel villes.
Suggestion : autoriser plusieurs sessions en direct par utilisateur, l'accueil listant "mes
sessions en direct". Le cas réel est rare et l'interdiction n'apporterait qu'une friction.

## Authentification (étapes 3, 5)

**Q20 ☑ — Client OAuth Google : réutiliser celui de LsgScores ou en créer un dédié à NUNI ?**
Réponse PO (2026-09-14) : client dédié à NUNI. À créer par le PO dans la console Google Cloud
(type "Application Web", origine `https://nuni.centuryspine.org`, URI de redirection
`https://zlxfmovibepgdmxacbpj.supabase.co/auth/v1/callback`), puis saisir l'identifiant et le
secret dans Supabase. Prérequis de l'étape 5, à faire au plus tard pendant l'étape 3.
Contexte : Supabase Auth a besoin d'un identifiant et d'un secret de client OAuth Google (console
Google Cloud). Le nouveau projet Supabase `nuni` doit soit être ajouté aux URL de redirection
autorisées du client existant (`https://zlxfmovibepgdmxacbpj.supabase.co/auth/v1/callback`),
soit disposer de son propre client.
Suggestion : client dédié à NUNI. L'ancienne app n'est pas touchée, l'écran de consentement Google
affiche "NUNI", et les deux apps peuvent évoluer ou être retirées indépendamment. Coût : cinq
minutes dans la console Google Cloud, puis saisie de l'identifiant et du secret dans Supabase
(Authentication → Providers → Google) ; aucune de ces valeurs n'entre dans le dépôt.

## Pages légales (étape 4)

**Q21 ☑ — Contenu des pages Mentions légales, Confidentialité (RGPD) et À propos.**
Réponse PO (2026-09-14) : éditeur **Bruno Chappe**, contact **bruno.chappe@gmail.com**, hébergeur
du site **Vercel** (région à confirmer après la création du projet, plan 11 ; Vercel sert le site
depuis son réseau mondial, la région indiquée sera celle du projet). Hébergeur des données :
Supabase, projet `nuni`, région **West EU (Paris)** (confirmée par le PO le 2026-09-14).
Les textes EN/FR sont rédigés par Claude à l'étape 4 et validés par le PO.
Décision PO (2026-09-14) : les trois pages existent, "À propos" pointe vers
https://centuryspine.org. Reste à fournir pour les mentions légales : l'identité de l'éditeur
telle que vous voulez qu'elle apparaisse (nom ou raison sociale, ville ou adresse, e-mail de
contact). Suggestion : le minimum légal pour un site non commercial édité par un particulier est
nom, e-mail de contact et hébergeur ; l'adresse postale n'est pas obligatoire pour un particulier.
Claude rédige une première version EN/FR des trois pages à partir des traitements réels de l'app
(identité Google, joueurs, sessions, position GPS ponctuelle, photos ; aucune analytique) ; le PO
valide le texte avant mise en ligne.

## Trous et géolocalisation (étapes 6, 7)

**Q10 ☐ — Rayon X par défaut pour proposer les trous ?**
Suggestion : 1 km par défaut, avec trois choix rapides (300 m, 1 km, 5 km) et un bouton "tous mes
trous" en secours si la géolocalisation est refusée. Valeur mémorisée sur l'appareil.

**Q11 ☐ — Service de géocodage inverse pour détecter la ville à la création de session ?**
Suggestion : BigDataCloud "reverse-geocode-client" (gratuit, sans clé, conçu pour un appel direct
depuis le navigateur, CORS ouvert). Repli manuel : champ ville pré-rempli, toujours modifiable
avant confirmation. Alternative : Nominatim (OpenStreetMap), gratuit mais politique d'usage stricte
(1 requête/s, User-Agent obligatoire non paramétrable depuis un navigateur).

**Q12 ☐ — Position d'un trou : uniquement le point de départ (demandé) ou aussi la cible ?**
Suggestion : point de départ obligatoire (saisi "à ma position" ou déplaçable sur une carte),
cible facultative pour plus tard. Le rayon de proximité ne s'applique qu'au départ.

**Q13 ☐ — Un trou privé est-il visible des autres membres d'une session où il a été joué ?**
Suggestion : oui, en lecture seule, sinon les cartes de trous joués et les exports des autres
membres afficheraient "trou inconnu".

## Rejoindre une session (étape 9)

**Q14 ☐ — Faut-il un scanner QR intégré à l'app ?**
Suggestion : non au départ. Le QR code encode un lien `https://nuni.centuryspine.org/join/CODE` ;
l'appareil photo natif de tout téléphone l'ouvre directement dans la PWA. Un code court (6
caractères) saisissable à la main couvre le reste. Un scanner intégré reste ajoutable plus tard.

**Q15 ☐ — Que voit un utilisateur qui rejoint une session sans avoir de joueur dans une équipe ?**
Suggestion : il choisit une équipe existante à rejoindre (son joueur y est ajouté si la règle de
taille le permet) ou reste "spectateur" avec lecture seule. Le créateur peut aussi ajouter des
joueurs après le démarrage.

## Exports et photos (étape 10)

**Q16 ☐ — Export image : garder la superposition sur une photo prise ou choisie (comme avant) ou
générer une carte de résultats stylée (sans photo) partageable ?**
Suggestion : les deux à partir du même composant Flutter rendu en image ; la version "carte de
résultats" est immédiate et lisible, la version "sur photo" reprend le rendu actuel.

## Hébergement et mise à jour (étape 11)

**Q17 ☑ — Construction du site : GitHub Actions puis déploiement Vercel "prebuilt", ou construction
directement chez Vercel ? Pull request obligatoire ou push direct sur `main` ?**
Suggestion initiale : GitHub Actions (Flutter y est disponible via une action officielle) puis
`vercel deploy --prebuilt`, avec protection de branche et PR obligatoire.
Rectificatif (2026-09-15) : la question mélangeait deux décisions indépendantes, qui compile (Vercel
ou Actions) et comment on arrive sur `main` (PR ou push direct). Faire compiler Flutter par Vercel
est un mécanisme éprouvé (le PO l'a utilisé sur d'autres projets) ; son vrai coût est le temps de
build, Flutter étant retéléchargé à chaque fois, pas la fragilité. Les deux options acceptent le
push direct et remontent une coche verte ou rouge sur GitHub.
Réponse PO (2026-09-15) : **GitHub Actions minimal puis livraison à Vercel**, retenu aussi pour
voir ce que donne une CI sur ce projet. **Pas de PR obligatoire ni de protection de branche** : le
PO pousse directement sur `main` la plupart du temps ; les branches `claude/...` se fusionnent
librement (bouton GitHub ou fusion locale). Conséquences : un seul workflow `ci.yml` (analyze,
test, build, déploiement) déclenché par tout push ; `main` déploie en production, les autres
branches en prévisualisation avec l'URL dans le résumé du job ; le projet Vercel n'est pas relié
à GitHub, il n'exécute aucun build. Plans 02 et 11 mis à jour.

**Q22 ☑ — Moteur de rendu CanvasKit : servi depuis le site (`--no-web-resources-cdn`) ou depuis
le serveur Google par défaut ?**
Contexte : par défaut, un site Flutter charge à chaque lancement son moteur de rendu (CanvasKit,
un fichier de 5,4 Mo mesuré sur ce build, compressé à la volée par l'hébergeur et mis en cache par le navigateur ensuite) depuis `www.gstatic.com`,
un serveur de Google. Constaté le 2026-09-15 : si ce serveur est inaccessible (réseau filtré,
hors ligne), la page reste blanche. Une copie du moteur est de toute façon produite dans
`build/web/canvaskit/`.
Suggestion : servir la copie locale (`flutter build web --no-web-resources-cdn`). Conséquences
d'usage : l'app démarre dès que le site est joignable, sans dépendre d'un tiers ; le service
worker peut la mettre en cache pour un usage hors ligne (PWA) ; aucune requête vers Google au
lancement, ce qui simplifie la page Confidentialité (Q21). Coût : le premier chargement vient de
Vercel au lieu du réseau de Google, différence imperceptible pour quelques Mo. Appliquée comme
hypothèse dans la CI et `docs/DEV.md` depuis le plan 02. La police par défaut (Roboto) est
téléchargée de la même façon depuis Google ; la décision d'embarquer une police relève du
plan 04 (design system) et sera posée là.
Réponse PO (2026-09-15) : ne tranche pas faute d'éléments ; s'en remet à l'argument technique.
Décision : suggestion appliquée (moteur servi depuis le site). En termes d'usage : sans cette
option, un joueur dont le téléphone ne joint pas les serveurs de Google (réseau d'entreprise
filtré, hors ligne) voit une page blanche ; avec, l'app démarre dès que nuni.centuryspine.org
répond, et pourra démarrer hors ligne une fois installée. Aucun inconvénient identifié.

**Q23 ☑ — Logo et icône de l'application.**
Décision PO (2026-09-15) : le logo est constitué des quatre lettres NUNI en majuscules, empilées
sur deux lignes, "NU" au-dessus de "NI". Les deux blocs ont la même largeur et la même hauteur et
sont alignés. "NU" et "NI" ont chacun leur couleur, génériques, compatibles avec n'importe quelle
palette. L'icône est un fond uni aux tailles standard avec ce logo centré. Pas d'autre dessin.
Réalisation (plan 02, 2026-09-15) : logo dessiné en formes géométriques dans
`web/icons/nuni_logo.svg` (aucune police, donc rendu identique partout et redimensionnable sans
perte), icônes PWA 192/512 et variantes "maskable" (Android découpe l'icône en cercle : le logo
est réduit pour rester dans la zone sûre), favicon. Aperçu : `docs/design/nuni_logo_preview.png`.
Hypothèse à valider : couleurs charbon `#2B2B2B` pour "NU" et gris `#8A8A8A` pour "NI", fond
d'icône blanc cassé `#F5F5F5`, trois valeurs modifiables dans le SVG. Le logo dans l'app (écran de
connexion, en-tête) est un widget Flutter de même construction, plan 04.

**Q18 ☐ — Mise à jour de l'app : remplacer le blocage au démarrage par un bandeau "nouvelle
version disponible, recharger" ?**
Suggestion : oui. Sur une PWA le service worker télécharge la nouvelle version en arrière-plan ;
bloquer l'utilisateur n'a plus de justification. La table `app_versions` disparaît.

## Outillage (étape 1)

**Q19 ☑ — Installation de Flutter : archive officielle dans `C:\dev\flutter` ou gestionnaire de
versions FVM ?**
Réponse PO (2026-09-14) : FVM retenu.
Suggestion : FVM (`winget install Leoafarias.FVM`), qui épingle la version Flutter dans le dépôt
(`.fvmrc`) et garantit la même version en local et en CI. L'archive officielle convient aussi si
un seul projet Flutter est prévu.
