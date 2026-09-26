# Questions au product owner

Chaque question porte une suggestion argumentée par la technique et l'état de l'art Flutter /
Supabase, pas par une préférence. Tant qu'une question est ouverte, le plan concerné applique la
suggestion comme hypothèse de travail (marquée "H" dans les plans).

Statut : ☐ ouverte · ☑ tranchée (réponse notée en dessous).

## Palette et design (étape 4)

**Q1 ☑ — Une palette de 3 couleurs suffit-elle ?** (tranchée avec Q1b)
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

**Q74 ☑ — Refonte visuelle complète (remplace Q1, Q1b et les couleurs de Q23).**
Demande PO (2026-09-23) : refonte de toute l'identité visuelle, carte blanche, couleurs vives et
joyeuses sans excès, direction artistique moderne et conforme aux standards, contrôles
standardisés, aucun changement fonctionnel. Réalisé : palette "NUNI Pop" (fond `#F4F5FA`,
cartouches blancs, texte `#14172B`, violet `#5B4CF5` comme couleur principale, trois accents
vert `#12B76A`, mandarine `#FF7A45`, soleil `#FFC43D`, rouge `#CF2E3A` pour le danger), police
Plus Jakarta Sans (licence OFL, intégrée à l'app, fonctionne hors ligne), logo NU blanc / NI
jaune sur tuile en dégradé violet, icônes PWA régénérées. Le modèle "3 couleurs + dérivées" de
Q1 et les cinq variantes de Q1b sont retirés du code. Détail et règles d'usage :
[design/PALETTE.md](design/PALETTE.md), section "NUNI Pop".
Complément PO (2026-09-23) : variante orange "NUNI Sunset" (même design, violet remplacé par
un vrai orange, mandarine remplacée par un bleu ciel), devenue la palette par défaut ; voir Q76.

**Q76 ☑ — Choix de la palette par l'utilisateur.**
Demande PO (2026-09-23) : garder plusieurs palettes (violet "NUNI Pop" et orange "NUNI Sunset"
pour commencer) et laisser chaque utilisateur choisir la sienne. Lève l'interdit "pas de
réglage de thème exposé à l'utilisateur" (AGENTS.md).
Réalisé : section "Couleurs" dans les réglages, sous la langue ; orange par défaut. Les deux
hypothèses ci-dessous sont confirmées par le PO (2026-09-23). Complément PO (2026-09-23) : quatre
palettes de plus (corail, bleu, turquoise, olive), soit deux froides, deux chaudes, deux douces ;
détail et ajustements dans [design/PALETTE.md](design/PALETTE.md).
- Le choix est mémorisé **sur l'appareil**, comme la langue, et non sur le compte. Suggestion :
  en rester là ; le suivre d'un appareil à l'autre demanderait une colonne en base (donc une
  reconstruction du schéma distant, AGENTS.md règle 8) pour un gain faible, la plupart des
  joueurs n'utilisant qu'un téléphone.
- Le logo **dans l'app** suit la palette choisie (tuile et "NI"), sinon une tuile orange jure
  dans une app violette (Q23 le voulait fixe quand il n'y avait qu'une palette). L'icône de
  l'app installée sur l'écran d'accueil reste orange : elle est unique par installation et ne
  peut pas changer selon un réglage.

## Backend Supabase (étape 3)

**Q2 ☑ — Nouveau projet Supabase `nuni` ou nouveau schéma dans le projet existant ?**
Suggestion : nouveau projet. Isolation totale de l'ancienne app (qui reste utilisable pendant la
transition), migrations propres versionnées dans le dépôt, aucune contrainte héritée.
Réponse PO (2026-09-14) : nouveau projet, déjà créé. URL `https://zlxfmovibepgdmxacbpj.supabase.co`,
référence `zlxfmovibepgdmxacbpj`. La clé anon sera fournie hors dépôt (fichier `env/*.json`
ignoré par git et variables d'environnement du projet Vercel, Q17).

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
Révision (2026-09-15, Q24) : tout joueur créé par l'app est lié dès sa création (trigger à
l'inscription) ; `user_id` ne reste nul que pour les joueurs importés de LsgScores.

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

**Q34 ☑ — Pour les trois modes autres que Libre, quel `ranking_direction` déduire du mode
(Q7b) ?**
Réponse PO (2026-09-16) : suggestion retenue.
Contexte : Q7b tranche que la colonne est "déduite du mode et non modifiable" pour Stroke Play,
Match Play et Redistribution, mais ne dit pas quelle valeur pour chacun ; nécessaire avant
d'écrire `create_session` côté client (plan 07).
Ce que faisait LsgScores (information, pas une réponse à elle seule,
`docs/reference/features_lsgscores_android.md` §11) : tri croissant par coups en Stroke Play, tri
décroissant par score (points) dans les modes à points.
Suggestion : Stroke Play → `asc` (moins de coups gagne) ; Match Play → `desc` ; Redistribution →
`desc` (les deux à points, plus haut gagne) — reprend directement le comportement de l'ancienne
app.

**Q8 ☑ — Qui peut saisir le score d'une équipe ?**
Réponse PO (2026-09-14) : suggestion retenue. Un membre ne saisit que sa propre équipe ; le
créateur (et tout co-organisateur) saisit toutes les équipes, ce qui couvre le cas "un seul
téléphone sert de marqueur", puisque c'est celui du créateur.
Suggestion : chaque membre saisit sa propre équipe ; le créateur de la session peut saisir toutes
les équipes (comportement actuel). Toute écriture est "dernier écrit gagne" avec affichage de qui a
saisi et quand. Alternative plus ouverte : tout membre saisit toute équipe (utile si un seul
téléphone sert de "marqueur"). Les deux sont un simple paramètre de politique RLS.
Décision PO (2026-09-23) : la mention "Par X à HH:MM" sous chaque score n'est plus affichée
(n'apporte rien). L'auteur et l'heure restent enregistrés en base.

**Q9 ☑ — Une session en direct par créateur, ou plusieurs ?**
Réponse PO (2026-09-14) : suggestion retenue, plusieurs sessions en direct par utilisateur, listées
sur l'accueil.
L'ancienne règle "une session en cours par ville" disparaît avec le référentiel villes.
Suggestion : autoriser plusieurs sessions en direct par utilisateur, l'accueil listant "mes
sessions en direct". Le cas réel est rare et l'interdiction n'apporterait qu'une friction.

## Authentification (étapes 3, 5)

**Q75 ☑ — Connexion en local renvoyée vers le domaine de production.**
Réponse PO (2026-09-23) : Redirect URLs Supabase vérifiées, `http://localhost:3000/**` en place.
Constat PO (2026-09-23) : en debug, se connecter depuis `localhost:3000` ramène sur
`https://nuni.centuryspine.org` après Google. Côté app, rien d'anormal : elle demande à Supabase
de revenir sur l'adresse de la page (`http://localhost:3000`, `auth_repository.dart`). Supabase
ne respecte cette demande que si l'adresse figure dans sa liste "Redirect URLs" ; sinon il
renvoie silencieusement vers sa "Site URL" (la production). La comparaison est faite au
caractère près, ou par motif avec `*` / `**` : une entrée `http://localhost:3000/` (barre
finale), `http://127.0.0.1:3000` ou `https://localhost:3000` ne correspond pas à
`http://localhost:3000`. Vérifié (curl sur `/auth/v1/authorize`) : l'app transmet bien
`redirect_to=http://localhost:3000` ; le refus a lieu après le retour de Google, invisible
sans accès au tableau de bord.
Suggestion : dans Supabase, Authentication > URL Configuration > Redirect URLs, avoir
exactement `http://localhost:3000/**` (motif recommandé par la documentation Supabase, accepte
l'adresse avec ou sans chemin). Site URL inchangée (production). En debug, le serveur tourne
toujours sur `localhost:3000`, aucun autre port.

**Q20 ☑ — Client OAuth Google : réutiliser celui de LsgScores ou en créer un dédié à NUNI ?**
Réponse PO (2026-09-14) : client dédié à NUNI. À créer par le PO dans la console Google Cloud
(type "Application Web", origine `https://nuni.centuryspine.org`, URI de redirection
`https://zlxfmovibepgdmxacbpj.supabase.co/auth/v1/callback`), puis saisir l'identifiant et le
secret dans Supabase. Prérequis de l'étape 5, à faire au plus tard pendant l'étape 3.
Réalisation PO (2026-09-15) : projet Google Cloud `nuni`, client OAuth "Nuni PWA" (type
Application Web) avec pour seule URI de redirection le callback Supabase, identifiant et secret
saisis dans Supabase, fournisseur Google activé. Pas d'origine JavaScript déclarée : inutile en
flux de redirection via Supabase (plan 05), seul le flux "One Tap", non retenu, en aurait besoin.
Écran de consentement, publication et URL Supabase terminés le même jour : détail au plan 03,
étape 1. Q20 entièrement réalisée.
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

**Q10 ☑ — Rayon X par défaut pour proposer les trous ?**
Réponse PO (2026-09-16) : pas de choix de rayon, un seul rayon fixe de 1 km, non modifiable.
Suggestion initiale (écartée) : 1 km par défaut avec trois choix rapides (300 m, 1 km, 5 km).
Le bouton "tous mes trous" en secours si la géolocalisation échoue est conservé.
Révision PO (2026-09-16, plus tard le même jour) : finalement un curseur (slider) de 0 à 10 km
par pas de 500 m, défaut 1 km, valeur mémorisée sur l'appareil (reprend l'idée initiale écartée
ci-dessus).

**Q11 ☑ — Service de géocodage inverse pour détecter la ville à la création de session ?**
Réponse PO (2026-09-16) : suggestion retenue.
Suggestion : BigDataCloud "reverse-geocode-client" (gratuit, sans clé, conçu pour un appel direct
depuis le navigateur, CORS ouvert). Repli manuel : champ ville pré-rempli, toujours modifiable
avant confirmation. Alternative : Nominatim (OpenStreetMap), gratuit mais politique d'usage stricte
(1 requête/s, User-Agent obligatoire non paramétrable depuis un navigateur).

**Q12 ☑ — Position d'un trou : uniquement le point de départ (demandé) ou aussi la cible ?**
Réponse PO (2026-09-16) : suggestion retenue, départ seulement.
Suggestion : point de départ obligatoire (saisi "à ma position" ou déplaçable sur une carte),
cible facultative pour plus tard. Le rayon de proximité ne s'applique qu'au départ.
Révision PO (2026-09-16, plus tard le même jour) : la position de la cible se saisit dès
maintenant sur la même carte (bascule départ/cible, position de départ toujours obligatoire,
cible facultative), pour préparer un futur tracé du trajet entre les deux points. Le tracé
lui-même n'est pas fait maintenant.

**Q13 ☑ — Un trou privé est-il visible des autres membres d'une session où il a été joué ?**
Réponse PO (2026-09-15) : suggestion retenue, oui en lecture seule.
Suggestion : oui, en lecture seule, sinon les cartes de trous joués et les exports des autres
membres afficheraient "trou inconnu".

**Q33 ☑ — Visibilité par défaut d'un trou créé : public ou privé ?**
Réponse PO (2026-09-16) : suggestion retenue, public.
Contexte : le plan 06 écrit "public par défaut" (l'intérêt d'un référentiel partagé), mais le
schéma déjà appliqué en base (plan 03, colonne `holes.visibility`) a été créé avec un défaut
`private`. Les deux documents se contredisent ; à trancher avant d'écrire l'écran de création.
Conséquence pour l'utilisateur : avec le défaut `public`, un trou créé sans y toucher est
immédiatement visible et proposé aux autres joueurs à proximité, ce qui alimente le référentiel
partagé sans effort ; avec `private`, il faut penser à changer le réglage pour que le trou serve
à quelqu'un d'autre, et beaucoup resteront privés par oubli.
Suggestion : `public` par défaut, comme l'a déjà écrit le plan 06 — c'est un catalogue partagé de
lieux publics (rue, parc), pas des données personnelles, et le défaut actuel en base semble un
oubli plutôt qu'un choix. Si retenu, correction triviale : `alter table holes alter column
visibility set default 'public'`, à appliquer via la procédure de reconstruction du schéma
(§8 AGENTS.md, avec préavis au PO) puisque le fichier de migration déjà poussé serait modifié.

## Rejoindre une session (étape 9)

**Q14 ☑ — Faut-il un scanner QR intégré à l'app ?**
Suggestion : non au départ. Le QR code encode un lien `https://nuni.centuryspine.org/join/CODE` ;
l'appareil photo natif de tout téléphone l'ouvre directement dans la PWA. Un code court (6
caractères) saisissable à la main couvre le reste. Un scanner intégré reste ajoutable plus tard.
Réponse PO (2026-09-15) : pas de scanner dans l'app, on se repose sur l'appareil photo du téléphone.

**Q15 ☑ — Que voit un utilisateur qui rejoint une session sans avoir de joueur dans une équipe ?**
Suggestion initiale : il choisit une équipe existante ou reste "spectateur" ; le créateur peut
ajouter des joueurs après le démarrage.
Réponse PO (2026-09-15) : suggestion écartée, métier simplifié en trois cas (détail au plan 09).
Cas 1 : équipes préparées à l'avance, l'utilisateur dont le joueur figure dans une équipe est
rattaché sans rien faire. Cas 2 : aucune équipe, tout le monde rejoint un pool, l'organisateur
compose les équipes (manuellement ou aléatoirement) puis démarre. Cas 3 : des équipes existent et
le joueur n'y figure pas, rejoindre est refusé ; il demande à l'organisateur de l'ajouter. Jusqu'au
démarrage, l'organisateur retire membres, joueurs et équipes à volonté. Le démarrage n'attend pas
les absents : l'organisateur ou un coéquipier saisit leurs scores. Plus de choix d'équipe par le
joueur, plus de spectateur. Conséquence : la création (plan 07) ne démarre plus la session ; une
phase de préparation avec salle d'attente existe entre création et démarrage.

**Q24 ☑ — Les joueurs sans compte, créés à la volée par l'organisateur, restent-ils possibles ?**
Contexte : le PO définit les joueurs comme "les utilisateurs qui se sont connectés au moins une
fois", mais précise aussi que certains ne veulent pas utiliser l'app et que leurs scores sont
saisis par d'autres. Une personne qui n'ouvre jamais l'app n'a pas de fiche joueur si seule la
connexion en crée une.
Suggestion : conserver la création à la volée (plan 07, "+ Ajouter Marie"), déjà prévue par le
modèle (Q4 : `players.user_id` nullable). Elle couvre les personnes sans app et l'import des anciens
joueurs (plan 13). Si la personne se connecte plus tard, l'onboarding lui propose "c'est moi" sur
sa fiche (plan 05), donc pas de doublon. Appliquée comme hypothèse.
Réponse PO (2026-09-15) : **non**, suggestion écartée. La réclamation d'une fiche créée par un
tiers ne passe pas à l'échelle, laisse des fiches fantômes et permet de ne jamais utiliser l'app.
Règle : toute personne doit se connecter au moins une fois ; cette connexion crée son profil et sa
fiche joueur. Ensuite l'organisateur utilise cette fiche pour composer ses sessions, même si la
personne ne se reconnecte jamais. Radical mais simple ; une évolution sera étudiée si des
personnes refusent totalement l'app. Conséquences : plus de création de joueur à la volée (plan
07), plus d'onboarding "Qui es-tu ?" ni de "c'est moi" (plan 05) ; profil et joueur sont créés
ensemble par la base à l'inscription ; `players.user_id` ne reste nul que pour les joueurs importés
de LsgScores (plan 13), qui ne sont pas sélectionnables dans une nouvelle session.
Révision (2026-09-16, Q32) : plus de table `profiles` séparée, fusionnée dans `players` — la
phrase "profil et joueur créés ensemble" ci-dessus décrit un seul et même joueur créé à
l'inscription, pas deux lignes distinctes.

**Q32 ☑ — `profiles` et `players` sont-elles redondantes, une fois Q24 appliquée ?**
Question posée par le PO après une première connexion Google réelle, en observant les deux tables
dans le tableau de bord Supabase.
Contexte : Q4 (colonne `players.user_id`) date d'avant Q24. Après Q24 (joueur créé uniquement par
le trigger d'inscription, jamais réclamé), un profil et son joueur lié sont toujours 1:1 et
resynchronisés à chaque sauvegarde (plan 05) — même règles de lecture/écriture RLS, mêmes
colonnes dupliquées à chaque fois.
Réponse PO (2026-09-16) : oui, redondantes ; suggestion retenue (fusion dans `players`, qui
référence `auth.users` directement). `players.created_by` conservé sans utilité actuelle, au cas
où une création de joueur par anticipation serait réintroduite plus tard (coût nul). Conséquence
annexe : confirmé que l'UUID `auth.users` d'un même compte Google ne se reporte pas d'un projet
Supabase à l'autre (chaque projet génère le sien) — le plan 13 devra donc soit laisser `user_id`
nul jusqu'à reconnexion, soit pré-provisionner des comptes (question à trancher à ce moment-là).

**Q25 ☑ — Au démarrage, que faire d'un membre du pool qui n'est dans aucune équipe ?**
Contexte : cas 2 du plan 09, l'organisateur démarre alors qu'un arrivant n'a pas été placé.
Suggestion : le démarrage est refusé tant qu'un membre du pool n'est pas affecté, avec un message
qui le nomme ; l'organisateur l'affecte ou le retire, en un geste. Alternative : le laisser
membre sans équipe, en lecture seule ; écartée parce qu'elle réintroduit un "spectateur" que le PO
vient de supprimer. Appliquée comme hypothèse.
Réponse PO (2026-09-15) : suggestion retenue, blocage du démarrage ; pas de spectateur ni de
joueur orphelin.

**Q26 ☑ — Comment l'organisateur prépare-t-il une session à l'avance (cas 1) en individuel, où
aucune équipe n'existe avant le démarrage ?**
Contexte : PO (2026-09-15), en individuel 1 joueur = 1 équipe, pas de composition, "Démarrer"
crée les équipes. Le cas 1 du plan 09 suppose pourtant que l'organisateur puisse préparer la
liste des joueurs à l'avance, y compris ceux qui ne se reconnecteront pas.
Suggestion : un bouton "Ajouter un participant" dans la salle d'attente, dans les deux types de
session, qui ajoute la personne comme membre exactement comme si elle avait rejoint. En
individuel c'est la seule action de préparation ; en équipe, le composeur travaille ensuite sur
ces participants. Une seule notion (participant) pour les deux types, une seule liste à
l'écran. Appliquée comme hypothèse.
Réponse PO (2026-09-15) : suggestion retenue.

## Session en direct (étape 8)

**Q35 ☑ — `scores` et `team_players` n'ont pas de colonne `session_id` : comment les filtrer en
temps réel ?**
Réponse PO (2026-09-17) : suggestion retenue.
Contexte : le plan 08 prévoit un abonnement `postgres_changes` filtré `session_id=eq.<id>` sur
`scores` et `team_players`, au même titre que sur `teams`, `played_holes`, `session_members` et
`sessions`. Mais `scores` est identifiée par `(played_hole_id, team_id)` et `team_players` par
`(team_id, player_id)` : ni l'une ni l'autre n'a de colonne `session_id`, ce filtre est donc
impossible à écrire tel quel. S'abonner sans filtre est exclu (AGENTS.md, conventions : "temps
réel : abonnements Supabase filtrés par session, jamais sur une table entière").
Conséquence pour l'utilisateur si non résolu : une saisie de score ou une modification d'équipe
faite par un autre joueur ne remonterait pas en direct sur les autres téléphones.
Suggestion : ajouter une colonne `session_id` dénormalisée sur `scores` et `team_players`
(référence à `sessions`, renseignée par trigger à l'insertion depuis la ligne parente
`played_holes`/`teams`) — même schéma que celui déjà en place sur `teams.session_id` et
`played_holes.session_id`, filtrage direct, cohérent avec le reste de l'écran. Appliquée comme
hypothèse (H) dans le plan 08.

**Q36 ☑ — Sur un événement temps réel, corriger l'instantané localement ou recharger l'instantané
complet ?**
Réponse PO (2026-09-17) : suggestion retenue.
Contexte : le plan décrit un "réducteur d'événements temps réel" qui applique chaque événement
reçu à l'instantané local en mémoire. C'est le mécanisme qui a produit deux bugs réels trouvés en
testant les plans 07/09 : une ligne dupliquée sur `session_members` et une ligne supprimée de
`teams` qui restait affichée jusqu'à un rechargement manuel — dans les deux cas, la liste que
`.stream()` reconstruit lui-même en local avait divergé de la base, en particulier sur les
suppressions et les mises à jour touchant plusieurs lignes à la fois.
Conséquence pour l'utilisateur si non résolu : même classe de bug qu'en salle d'attente, mais sur
l'écran où elle compte le plus (scores et classement pendant la partie).
Suggestion : reprendre le correctif déjà retenu en salle d'attente (`session_room_page.dart`) —
les abonnements realtime ne servent qu'à détecter "quelque chose a changé" ; chaque déclenchement
relance un appel frais à la RPC `session_snapshot`, sans tenter de corriger l'instantané localement
à partir du contenu de l'événement. Plus simple à écrire et à tester (pas de réducteur), et évite
une classe de bug déjà rencontrée deux fois. Appliquée comme hypothèse (H) dans le plan 08.

## Exports et photos (étape 10)

**Q16 ☑ — Export image : garder la superposition sur une photo prise ou choisie (comme avant) ou
générer une carte de résultats stylée (sans photo) partageable ?**
Suggestion : les deux à partir du même composant Flutter rendu en image ; la version "carte de
résultats" est immédiate et lisible, la version "sur photo" reprend le rendu actuel.
Réponse PO (2026-09-17) : les deux, confirmé.

**Q37 ☑ — Photos de session : qui peut en ajouter et en supprimer ? Comment purger le bucket de
stockage quand une photo ou une session entière est supprimée ?**
Le texte initial du plan 10 proposait "ajout par tout membre, suppression par l'auteur ou le
créateur", mais le schéma posé au plan 03/06 restreint déjà l'écriture des photos (table
`session_photos` et bucket `session-photos`) au seul créateur de la session — écart relevé à la
revue du plan 10.
Suggestion : garder les policies existantes telles quelles (aucune migration à modifier) ; pour la
purge, suppression côté client (l'app appelle `storage.remove()` avant/après la suppression de la
ligne en base), sans Edge Function — pas de nouvelle brique d'infra pour un projet solo, même
principe que le reste de l'app (aucune autre suppression ne purge le stockage aujourd'hui non
plus).
Réponse PO (2026-09-17) : droits conservés au seul créateur de la session (ajout et suppression),
comme le schéma actuel ; purge côté client, comme suggéré.

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
Revirement PO (2026-09-15, après lecture des actions à faire pour Vercel au plan 11) : **Vercel
compile lui-même**, projet Vercel relié au dépôt GitHub, comme sur ses autres projets Flutter.
GitHub Actions supprimé (workflow retiré, plus de jeton ni de secrets GitHub). Mise en œuvre :
`vercel.json` (commande de build `tool/vercel_build.sh`, dossier de sortie `build/web`, pas
d'installation npm, réécritures et en-têtes)
et script qui installe la version Flutter de `.fvmrc`, puis enchaîne analyse, tests et build ;
un commit cassé n'est donc pas déployé (confirmé par le PO le 2026-09-15). `main` en production, toute autre branche en prévisualisation, coche verte
ou rouge remontée sur le commit GitHub par Vercel. Reste vrai : push direct sur `main`, pas de PR.
Complément (2026-09-15, après création du projet par le PO) : pas de prévisualisation sur ce
projet, seule `main` est déployée, en production sur `nuni.centuryspine.org`. La règle "ignorer
les commits de documentation" (`ignoreCommand`) a annulé le tout premier build (le dernier commit
ne touchait que `docs/`) et pouvait faire sauter un déploiement quand un push mêle code et
documentation : retirée, chaque push sur `main` construit. Vercel construisant aussi la branche de
session `claude/...` en prévisualisation, le PO a tranché : plus aucune branche poussée en dehors
de `main` (AGENTS.md, règle 7) ; branche de session supprimée, aucune règle Vercel nécessaire. Premier déploiement en ligne le 2026-09-15 sur `nuni.centuryspine.org`, build 2 min 21 s.

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
hypothèse dans le script de build Vercel et `docs/DEV.md` depuis le plan 02. La police par défaut (Roboto) est
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
d'icône blanc cassé `#F5F5F5`, trois valeurs modifiables dans le SVG. Réponse PO (2026-09-15) :
couleurs validées pour commencer. Le logo dans l'app (écran de
connexion, en-tête) est un widget Flutter de même construction, plan 04.

**Q18 ☑ — Mise à jour de l'app : remplacer le blocage au démarrage par un bandeau "nouvelle
version disponible, recharger" ?**
Suggestion : oui. Sur une PWA le service worker télécharge la nouvelle version en arrière-plan ;
bloquer l'utilisateur n'a plus de justification. La table `app_versions` disparaît.
Réponse PO (2026-09-15) : suggestion retenue.

## Outillage (étape 1)

**Q19 ☑ — Installation de Flutter : archive officielle dans `C:\dev\flutter` ou gestionnaire de
versions FVM ?**
Réponse PO (2026-09-14) : FVM retenu.
Suggestion : FVM (`winget install Leoafarias.FVM`), qui épingle la version Flutter dans le dépôt
(`.fvmrc`) et garantit la même version en local et en CI. L'archive officielle convient aussi si
un seul projet Flutter est prévu.

## Suppression de compte (étape 14)

Retirée du plan 05 (décision PO, 2026-09-16) : impacts sur les données d'autres utilisateurs à
trancher explicitement avant d'implémenter, pas d'hypothèse silencieuse sur ces points-là.

**Q27 ☐ — Que devient mon joueur (`players`) une fois mon compte supprimé, s'il est référencé dans
les sessions et scores d'autres utilisateurs ?**
Suggestion : garder la ligne `players`, délier (`user_id = null`), comme un joueur importé de
LsgScores — préserve l'historique et les scores des autres sans les casser ; le joueur redevient
non sélectionnable dans une nouvelle session (règle déjà en place pour `user_id` nul).

**Q28 ☐ — Que deviennent les sessions dont je suis propriétaire, y compris celles où d'autres
personnes ont des scores ?**
Suggestion : supprimées entièrement (cascade) si je suis seul propriétaire ; si un co-organisateur
existe (`session_members.role = owner`), la propriété (`sessions.owner_id`) lui est transférée
automatiquement plutôt que de supprimer l'historique d'autrui.

**Q29 ☐ — Que deviennent les trous (`holes`) que j'ai créés, notamment les trous publics utilisés
par d'autres dans leurs sessions passées ?**
Suggestion : conservés (utiles à l'historique et aux exports d'autres joueurs), propriétaire
délié — nécessite de rendre `holes.owner_id` nullable (changement de schéma).

**Q30 ☐ — Une session en direct (`status = live`) que je possède, avec d'autres joueurs en train
d'y jouer au moment de la suppression de mon compte : bloquer, avertir, ou traiter comme les
autres sessions ?**
Suggestion : bloquer la suppression tant qu'une session en direct m'appartient ("terminez ou
supprimez vos sessions en direct d'abord"), pour ne pas couper une partie en cours pour les autres
participants.

**Q31 ☐ — Exécution technique : fonction SQL `security definer` supprimant directement
`auth.users`, ou Edge Function utilisant l'API admin de Supabase ?**
Suggestion : Edge Function (déjà documentée comme la voie recommandée au plan 03) — supprimer un
utilisateur `auth` depuis une fonction SQL exige des privilèges que Postgres n'expose pas
proprement ; l'API admin de Supabase (rôle `service_role`) est le chemin prévu pour ça.

## Championnat individuel annuel (étape 15)

Décisions de principe déjà tranchées par le PO le 2026-09-21 (tagage par le créateur seul même
après clôture ; zones géographiques par proximité entre sessions, pas par nom de ville ; points de
classement selon la position et le nombre de participants du jour, plus un point de présence fixe
en plus). Détail complet : [plans/15_championnat_individuel_annuel.md](plans/15_championnat_individuel_annuel.md).

**Q38 ☑ — Bornes exactes de la "saison" du championnat (année scolaire, ex. 2026-2027) ?**
Réponse PO (2026-09-21) : suggestion retenue, du 1er septembre au 31 août de l'année suivante.
Suggestion : couvre toute l'année sans coupure ni zone grise (contrairement à une saison type
"septembre-juin" qui laisserait les sessions d'été hors de toute saison), et correspond à l'usage
courant du terme "année scolaire" pour nommer une saison (2026-2027).

**Q39 ☑ — Faut-il un nombre minimal de sessions championnat jouées pour apparaître au classement
(provisoire ou final) ?**
Réponse PO (2026-09-21) : suggestion retenue, aucun minimum.
Suggestion : le point de présence fixe (décision du 2026-09-21) décourage déjà les scores gonflés
par une seule bonne performance sans y ajouter une deuxième règle à expliquer aux joueurs ; un
joueur n'ayant joué qu'une session apparaîtra simplement avec un total faible, comparable à sa
seule participation.
Point d'attention conservé : tôt dans la saison, un joueur n'ayant joué qu'une seule session et bien
classé ce jour-là peut se retrouver provisoirement en tête, avant que les joueurs réguliers
n'accumulent davantage de sessions. Le classement est alors explicitement "provisoire" à l'écran
pour ne pas laisser croire à un résultat acquis.

**Q40 ☑ — Égalité de classement au sein d'une session championnat (deux joueurs ex æquo ce
jour-là) : mêmes points de classement aux deux, ou répartition ?**
Réponse PO (2026-09-21) : suggestion retenue, mêmes points aux deux.
Suggestion : celui de la meilleure des deux positions à égalité (pas de moyenne ni de partage).
Cohérent avec l'affichage déjà existant des égalités ("ex æquo") en mode Libre et Match Play (Q7b) ;
une règle de partage introduirait des demi-points ou des arrondis à expliquer sans bénéfice
fonctionnel clair.

**Q41 ☑ — Comment nommer une zone de championnat à l'écran, puisqu'il n'existe plus de référentiel
ville ?**
Réponse PO (2026-09-21) : suggestion retenue.
Suggestion : le nom affiché est déduit automatiquement du texte "ville" le plus fréquent parmi les
sessions qui composent la zone, recalculé à mesure que de nouvelles sessions s'y ajoutent. Aucune
saisie à faire par un administrateur au lancement. Une correction manuelle du nom pourra être
ajoutée plus tard si le nom déduit s'avère trompeur (par exemple une zone à cheval sur deux
communes), mais n'est pas indispensable pour démarrer.

**Q42 ☑ — Où caler cette étape dans l'ordre du plan d'ensemble ?**
Réponse PO (2026-09-21) : suggestion retenue, aucune contrainte avec les étapes non terminées.
Reformulation : le plan d'ensemble a encore trois étapes non terminées (11 mise en ligne
définitive, 13 récupération des anciennes données LsgScores, 14 suppression de compte). Le
championnat est développable dès maintenant, en parallèle ou avant : ces trois étapes ne touchent
pas au domaine des sessions et des scores, rien de leur travail ne serait cassé ou à refaire si le
championnat arrive avant ou en même temps.

**Q43 ☑ — Une session en mode Équipe compte-t-elle pour le championnat individuel, et si oui
comment répartir les points entre coéquipiers ?**
Réponse PO (2026-09-21) : oui, les deux types de session comptent ; les coéquipiers d'une même
équipe touchent tous les mêmes points ce jour-là (le classement et la présence de l'équipe leur
sont attribués identiquement).
Contexte découvert en rédigeant le plan technique : le plan fonctionnel ne distinguait pas
individuel/équipe. Suggestion initiale (écartée) : n'admettre que les sessions individuelles, pour
que chaque résultat du jour appartienne à une seule personne.

**Q44 ☑ — Quel rayon utiliser pour rapprocher automatiquement des sessions dans une même zone de
championnat ?**
Réponse PO (2026-09-21) : 15 km, fixe, non réglable.
Suggestion : échelle d'une agglomération et ses environs proches — assez large pour ne pas
fragmenter des communes limitrophes d'une même ville, assez étroit pour ne pas fusionner deux
villes clairement distinctes. À comparer au rayon de 1 km (glissable 0–10 km) déjà utilisé pour
retrouver les trous à proximité (Q10), qui répond à un besoin différent (retrouver un lieu précis,
pas rapprocher des villes).

**Q45 ☑ — En cas d'égalité du total de points en fin de saison entre deux joueurs, comment les
départager à l'affichage ?**
Réponse PO (2026-09-21) : le nombre de sessions championnat jouées départage en premier (le plus
présent gagne) ; si cette présence est elle aussi égale, égalité finale (affichés à la même
position, "ex æquo").
Suggestion initiale (écartée) : aucun départage forcé, tri alphabétique pour la seule stabilité de
l'affichage.

## Rôles applicatifs (étape 16)

Demande PO du 2026-09-22 : aucun compte n'a de droit élevé dans NUNI pour effectuer des
modifications structurantes (exemple donné : le tagage rétroactif de sessions LsgScores importées
comme "championnat", plan 13 M5). Détail complet :
[plans/16_roles_applicatifs.md](plans/16_roles_applicatifs.md).

**Q46 ☑ — Le rôle applicatif doit-il être lié à l'utilisateur authentifié (`auth.users`) ou au
joueur (`players`) ?**
Réponse PO (2026-09-22) : suggestion retenue, `auth.users`.
Suggestion : cohérent avec les contrôles d'accès déjà en place — `is_session_owner()` et
`is_session_member()` vérifient déjà `auth.uid()`, jamais un `player_id`. Un rôle applicatif
décrit qui a le droit d'agir dans l'app, pas quel joueur on incarne en partie ; il doit suivre la
même identité que le reste des contrôles. `players.user_id` peut en plus être vide (joueur importé
de LsgScores, Q24), ce qui aurait de toute façon fait retomber un rôle posé là sur l'utilisateur
authentifié dans ce cas.

**Q47 ☑ — Faut-il une vraie table catalogue des rôles ("Roles" avec les lignes super_admin/player,
telle que demandée initialement) ou un type énuméré Postgres avec une seule table de lien ?**
Réponse PO (2026-09-22) : suggestion retenue, type énuméré `app_role` (`player`, `super_admin`) +
table de lien `user_roles(user_id, role)`.
Suggestion : même famille que `member_role` (owner/player par session), déjà en place. AGENTS.md
interdit explicitement une table de référence pour un ensemble de valeurs fixe et connu d'avance
(déjà appliqué à `scoring_mode`/`game_mode`, jamais de table `scoring_modes`). Seule l'exception
(`super_admin`) est stockée dans `user_roles` ; un compte absent de la table est un `player`
implicite, sans ligne à créer pour chaque compte à l'inscription.

**Q48 ☑ — Plan 13 (M5), marquage rétroactif "championnat" des sessions importées de LsgScores :
script de migration à clé service, ou action côté app protégée par `is_super_admin()` ?**
Réponse PO (2026-09-22) : action côté app protégée par `is_super_admin()`.
Suggestion : maintenant que le rôle existe (plan 16), une action app dédiée (RPC `security
definer` posant `is_championship = true`, réservée à `is_super_admin()`) est préférable au script à
clé service envisagé initialement — le PO peut retagger depuis l'app à tout moment, sans dépendre
d'une exécution manuelle hors ligne, et le mécanisme sert aussi pour toute correction future sur
n'importe quelle session, pas seulement au moment de l'import. Détail technique (nom de la RPC,
politique exacte) à écrire lors du détail du plan 13.

## Migration LsgScores (étape 13)

Étape 1, import des trous seuls (demande PO du 2026-09-23). Détail :
[plans/13_migration_donnees_lsgscores.md](plans/13_migration_donnees_lsgscores.md).

**Q49 ☑ — Position des trous importés : rendre `holes.start` facultatif, ou mettre une position
provisoire ?**
Suggestion : facultatif (`null`), comme le prévoit déjà le plan 13. Aujourd'hui la colonne est
obligatoire ; une position provisoire (centre de la ville, 0/0) ferait apparaître de faux trous
dans « Autour de moi » et fausserait plus tard le centre géométrique des sessions importées et
leur zone de championnat. Coût : colonne rendue facultative (reconstruction du schéma distant),
quatre endroits de l'app à adapter (carte, liste, fiche, formulaire), mention « Position à
définir ». La création d'un trou dans l'app continue d'exiger une position.
Réponse PO (2026-09-23) : suggestion retenue (après examen de la demande de « trou générique »
(Q56) : les deux sujets sont indépendants, Q49 ne concerne que
les trous importés).

**Q50 ☑ — Propriétaire des trous importés ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : le compte du PO. L'identifiant de l'ancien compte n'existe pas dans NUNI (M3) et
seul le propriétaire peut modifier un trou (RLS) : c'est la condition pour que le PO puisse les
repositionner depuis l'écran d'édition existant. Les trous restent publics, donc visibles et
jouables par tous. Une réattribution à l'auteur d'origine pourra être traitée avec M2.

**Q51 ☑ — Visibilité des trous importés ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : `public`. Dans LsgScores tout utilisateur connecté voyait tous les trous ; les
passer en privé les rendrait invisibles des autres joueurs.

**Q52 ☑ — Photos des trous : les recopier dans NUNI maintenant ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : oui, dans le bucket `holes` de NUNI sous `<id du PO>/legacy-<ancien id>/start.jpg` (chemin précisé à l'implémentation : dossier du propriétaire, pour que les règles du stockage le laissent remplacer la photo depuis l'app). Le chemin
ne dépend pas de l'identifiant NUNI du trou (qui change à chaque reconstruction), et le stockage
survit aux reconstructions : un rejeu retrouve les photos sans rien retélécharger. Garder les URL
de l'ancien projet rendrait les photos dépendantes d'un projet destiné à être retiré. Les photos
aident aussi à retrouver l'emplacement réel des trous.

**Q53 ☑ — Zone de jeu d'origine (ex. « Parc X ») : où la conserver ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : nulle part en base, seulement dans le rapport d'import (fichier CSV local listant
chaque trou avec sa zone et sa ville d'origine), qui sert de feuille de route pour le
repositionnement. NUNI a abandonné les zones (plan d'ensemble) ; l'écrire dans la description
polluerait un champ visible de tous.

**Q54 ☑ — Outil d'import : script Dart lisant l'ancienne base en direct, ou fichier SQL généré une
fois et committé (comme `remote_seed.sql`) ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : script Dart (`tool/migrate_lsgscores.dart holes`), clés dans `env/migration.json`
(non committé). Le dépôt est public : un fichier SQL committé y publierait les données de tous
les anciens utilisateurs. Le script reste rejouable tant que l'ancien projet existe, il servira
aussi à l'étape 2 (sessions), et il reprend les trous créés dans LsgScores après la première
exécution. Pour l'exécuter, il faut la clé service (clé d'administration, qui ignore les règles
d'accès) des deux projets Supabase, à copier par le PO depuis leurs tableaux de bord.

**Q55 ☑ — Rejeu sans reconstruction : un trou déjà importé doit-il être écrasé par les données de
LsgScores ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : non, jamais (« ignorer les doublons »). Sinon un simple rejeu effacerait les
positions posées à la main. Conséquence à connaître : un trou importé puis supprimé dans NUNI
revient au rejeu suivant.

### Trou générique (demande PO du 2026-09-23)

Besoin : pouvoir jouer à tout moment un trou « one shot » (trou de test, partie rapide) sans le
créer dans le référentiel des trous ; ce trou n'a pas de position GPS. Constaté dans le code : le
par d'un trou n'intervient dans aucun calcul de score ni de classement (affichage seul), et une
même session peut déjà contenir plusieurs fois le même trou (seule la place du trou dans la
session doit être unique).

**Q56 ☑ — Comment représenter le trou générique : une ligne spéciale dans la table des trous, ou un
trou joué qui ne renvoie à aucun trou du référentiel ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : un trou joué sans trou de référence (`played_holes.hole_id` rendu facultatif ; vide
= trou générique). Une ligne spéciale dans `holes` exigerait un propriétaire (compte réel ou
compte technique à créer), devrait être masquée de « Mes trous », de la carte et de l'édition,
protégée contre la suppression, et porterait un nom figé dans une seule langue. Sans ligne, le nom
affiché vient des traductions (« Trou libre » / « Free hole »), il n'y a rien à protéger, et une
reconstruction de la base n'a rien à recréer. Coût : la requête SQL qui lit le détail d'une
session doit tolérer un trou absent, ainsi que les écrans qui affichent le nom d'un trou joué
(session en direct, historique, exports). Dans le sélecteur de trous, « Trou libre » est toujours
proposé en tête, quels que soient la position et le rayon. Ce choix ne dépend pas de Q49 : les
trous importés sans position restent un sujet séparé.

**Q57 ☑ — Le trou générique porte-t-il un libellé saisi au moment de l'ajout ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : oui, facultatif (colonne `played_holes.label`), ex. « Test escalier ». Sans libellé,
une session de cinq trous génériques affiche cinq fois « Trou libre » et l'historique ne permet
plus de les distinguer ; laissé vide, l'app affiche « Trou libre » avec le numéro du trou dans la
session. Ni par ni distance à saisir : le par ne sert à aucun calcul.

**Q58 ☑ — Une session contenant des trous génériques compte-t-elle pour le championnat ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : oui, sans règle particulière. Le championnat agrège le classement des sessions, pas
les trous. Seul effet : un trou générique n'entre pas dans le calcul du centre géométrique d'une
session (il n'a pas de position), ce qui ne concerne que les sessions importées (plan 13).

**Q59 ☑ — Dans quel plan et dans quel ordre ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : un plan 17 « Trou générique » séparé, implémenté avant l'étape 1 du plan 13. Les deux
changent le schéma et imposent une reconstruction de la base distante : les regrouper n'en fait
qu'une, suivie de l'import des trous.

### Retouches des trous (demandes PO du 2026-09-23, plan 06)

**Q60 ☑ — « Utiliser la position du dernier trou » : où retenir ce dernier trou, et que fait le
bouton ?**
Réponse PO (2026-09-23) : suggestion retenue, déplacement de la carte uniquement ; le départ se
pose à la main. But : rendre fluide la création d'un trou en ouvrant la carte au plus près de la
dernière zone éditée.
Suggestion appliquée en hypothèse : le dernier trou est lu en base (mon trou créé ou modifié le
plus récemment qui a une position, hors trou en cours d'édition, via `updated_at` déjà tenu à jour
par la base). Rien à sauvegarder à part, et le bouton suit l'utilisateur d'un appareil à l'autre
(une mémoire sur l'appareil serait perdue en changeant de téléphone ou en vidant le navigateur).
Le bouton, libellé « Aller au dernier trou : <nom> », déplace seulement la carte (zoom rapproché)
sans poser le départ : copier la position d'un autre trou placerait deux trous au même point, et
c'est le toucher sur la carte qui pose le vrai départ.

**Q61 ☑ — Photo supprimée : effacer aussi le fichier du stockage ?**
Réponse PO (2026-09-23) : suggestion non retenue. Supprimer ou remplacer une photo supprime
complètement l'ancienne : référence du trou et fichier du stockage. Mise en œuvre : à
l'enregistrement du trou, tout fichier photo que le trou référençait au chargement ou qui a été
envoyé pendant l'édition, et qu'il ne référence plus, est effacé du stockage. Un échec de cet
effacement ne fait pas échouer l'enregistrement (le trou est déjà enregistré). Un remplacement
d'une photo prise dans l'app réécrit le même fichier ; celui d'une photo importée de LsgScores
efface l'ancien fichier.
Suggestion appliquée en hypothèse : non, seule la référence du trou est effacée, comme c'est déjà
le cas quand une photo est remplacée. Effacer le fichier au moment de l'enregistrement ajoute un
cas d'échec partiel (trou enregistré mais fichier non effacé, ou l'inverse) pour un gain nul à
l'usage : le fichier n'est plus affiché nulle part. Conséquence à connaître : après une
reconstruction, le rejeu de l'import recopie les photos des trous importés depuis LsgScores, y
compris celles supprimées entre-temps (déjà accepté : une reconstruction efface les retouches
manuelles).

**Q62 ☑ — Plan 13, étape 2 : que devient l'ancien trou « Generic » (ancien trou 32, joué une fois,
session 219) ?**
Réponse PO (2026-09-23) : suggestion retenue.
Constat (vérification du 2026-09-23) : c'est le seul trou importé resté sans position, et son nom
indique qu'il servait déjà de trou « one shot » dans LsgScores, ce que fait désormais le trou libre
de NUNI (plan 17).
Suggestion : le convertir en trou libre. À l'import des sessions, la partie jouée sur l'ancien
trou 32 devient un trou libre sans libellé (affiché « Trou N · Trou libre »), et l'import des trous
l'exclut (liste d'exclusion explicite dans le script, avec la raison) ; le trou déjà importé est
supprimé de NUNI. Le score et le classement de la session 219 sont inchangés : un trou libre compte
comme un trou normal (Q58). L'alternative, le garder comme trou importé, le laisserait pour
toujours dans « Mes trous » avec « Position à définir », proposé dans le sélecteur comme un vrai
emplacement alors qu'il n'en a pas.

### Import des sessions (plan 13, étape 2, 2026-09-23)

**Q63 ☑ — Faut-il arrêter les reconstructions de la base dès maintenant ?**
Réponse PO (2026-09-23) : non, on continue à reconstruire ; les trous importés et retouchés
remplacent les trous de test dans `supabase/remote_seed.sql`, rejoué à chaque reconstruction
(régénéré depuis la base par `tool/export_remote_seed.dart`). Même principe prévu plus tard pour
les sessions et joueurs importés, une fois l'import terminé.
Constat : la règle 8 (AGENTS.md) autorise à tout effacer à chaque changement de schéma parce
qu'« aucune donnée n'est vitale ». Ce n'est plus vrai : les positions des 16 trous repositionnés à
la main sont perdues à chaque reconstruction, et l'étape 2 demande justement des changements de
schéma (droits, table privée, déclencheur, RPC).
Suggestion : oui. À partir de maintenant, migrations additives (un nouveau fichier par changement,
appliqué par `npx supabase db push`, jamais d'édition d'un fichier déjà appliqué), comme prévu
après la mise en service. C'est la pratique standard dès qu'une base contient des données à garder,
et elle évite d'écrire une sauvegarde/restauration des trous. AGENTS.md (règle 8) et docs/DEV.md
seraient mis à jour en conséquence.

**Q64 ☑ — Joueurs LsgScores sans compte NUNI (7 des 10 joueurs) : faut-il les rattacher
automatiquement à leur compte quand ils s'inscriront ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : oui, par adresse e-mail. L'import crée leur fiche joueur sans compte (`user_id` vide,
comme prévu par Q24) et note leur e-mail LsgScores dans une table privée (aucun droit pour les
utilisateurs de l'app, donc jamais lisible depuis l'app). À l'inscription, le déclencheur existant
cherche cet e-mail : s'il le trouve, il rattache le compte à la fiche importée au lieu d'en créer
une nouvelle, ajoute la personne aux sessions où elle a joué, puis efface la ligne de la table
privée. Sans ce rattachement, la personne aurait deux fiches, et ne verrait jamais son historique
LsgScores. Écart à AGENTS.md à valider : les interdits mentionnent « table de lien user↔joueur » ;
celle-ci n'en est pas une (elle ne relie aucun compte, elle se vide au fur et à mesure et ne sert
qu'à l'import), mais c'est une table de plus. Les 2 joueurs sans e-mail connu ne peuvent pas être
rattachés automatiquement ; ils restent des fiches importées tant que rien d'autre n'est décidé.

**Q65 ☑ — Faut-il importer les 4 fiches joueurs LsgScores qui n'ont jamais joué de partie ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : non. Ce sont une fiche de test, un doublon d'une fiche du PO et deux fiches créées à
l'inscription sans partie jouée ; rien ne les référence, et les personnes concernées qui ont déjà un
compte NUNI ont déjà leur fiche.

**Q66 ☑ — Photo des joueurs importés ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : une fiche importée sans compte NUNI reçoit la photo de LsgScores, recopiée dans le
bucket `avatars` de NUNI. Une fiche rapprochée d'un compte NUNI existant garde sa photo NUNI (celle
du compte Google), jamais écrasée par l'import.

**Q67 ☑ — Qui voit les sessions importées ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : les mêmes personnes que pour une session créée dans NUNI, c'est-à-dire ses membres :
le PO (propriétaire, créateur de toutes les sessions LsgScores) et les joueurs de la session qui ont
déjà un compte NUNI (3 aujourd'hui), chacun rattaché à son équipe. Les autres joueurs deviennent
membres au moment de leur inscription (Q64). Aucune règle de visibilité particulière aux sessions
importées.

**Q68 ☑ — Fuseau horaire des heures LsgScores ?**
Réponse PO (2026-09-23) : suggestion retenue.
Constat : les heures sont stockées sans fuseau (`2025-09-02T18:55:00`), telles qu'affichées par le
téléphone. Suggestion : les lire comme des heures de Paris (heure d'été ou d'hiver selon la date).
Toutes les sessions ont été jouées à Lyon ; sans fuseau, NUNI les décalerait de 1 ou 2 heures.

**Q69 ☑ — Météo des sessions importées ?**
Réponse PO (2026-09-23) : suggestion retenue.
Constat : LsgScores stockait le format OpenWeatherMap (code d'icône « 01d », description en
anglais), NUNI le format Open-Meteo (code WMO). Suggestion : convertir température et vent tels
quels et le code d'icône vers le code WMO équivalent (01 → ciel clair, 02 → peu nuageux,
03 → partiellement nuageux, 04 → couvert, 09/10 → pluie, 11 → orage, 13 → neige, 50 → brouillard) ;
la description anglaise n'est pas reprise, NUNI affiche son propre libellé à partir du code.

**Q70 ☑ — Photos des sessions : les recopier ?**
Réponse PO (2026-09-23) : suggestion retenue.
Suggestion : oui, les 14, dans le bucket `session-photos` de NUNI, au même emplacement qu'une photo
ajoutée dans l'app (`<id de la session NUNI>/<nom d'origine>`), pour que le propriétaire puisse les
gérer depuis l'app (les règles du stockage l'exigent). La photo `fav_` devient la photo de
couverture. Ce chemin dépend de l'identifiant NUNI de la session, qui change à chaque
reconstruction : c'est sans importance si Q63 est retenue.

**Q71 ☑ — Marquage « championnat » des sessions importées (M5, Q48) : où dans l'app ?**
Réponse PO (2026-09-23) : suggestion retenue, puis précisée à l'implémentation (réponse PO du
même jour) : rien à coder, la fiche d'édition existante de l'historique, ouverte au propriétaire,
contient déjà l'interrupteur « championnat », et le PO est propriétaire de toutes les sessions
importées (Q67).
Suggestion : un interrupteur « Session de championnat » dans le détail d'une session de
l'historique, visible du super_admin seul, appelant une RPC réservée à `is_super_admin()`. Le choix
des sessions à marquer reste une action du PO dans l'app après l'import ; le rattachement à une zone
est fait par le mécanisme existant (plan 15), puisque toutes les sessions importées auront une
position.

**Q72 — Plan 15 : comment accéder au classement d'une saison passée ?**
Constat (2026-09-23, après le marquage des sessions importées) : l'encart de l'accueil n'affiche que
la saison en cours (2026-2027 depuis le 1er septembre), comme le prévoit le plan 15 (parcours 2).
Les 4 sessions marquées sont bien rattachées à une zone, saison 2025-2026. Or cet encart est le seul
chemin vers l'écran de classement complet, qui a pourtant un sélecteur de saison : une saison
passée devient inaccessible dès qu'aucune session championnat n'a encore été jouée dans la
nouvelle, ce qui arrivera chaque année en septembre.
Suggestion : l'encart de l'accueil affiche la saison en cours si le joueur y a au moins une session
championnat, sinon sa saison la plus récente, avec la mention « saison terminée » à la place de
« provisoire ». Aucun nouvel écran ni nouveau menu : l'encart ouvre le classement complet, où le
sélecteur de saison existant permet ensuite de naviguer.
Réponse PO (2026-09-23) : suggestion non retenue ; un historique des championnats sur l'accueil,
comme l'historique des sessions. Conception détaillée dans le plan 15 (complément du 2026-09-23),
validée et implémentée le même jour.

### Sauvegarde des données par seed (demande PO du 2026-09-23)

Demande : compléter les seeds pour rejouer après une reconstruction les trous, sessions et
championnats actuels (données migrées de LsgScores et créées dans NUNI).

**Q73 ☑ — Le seed des sessions et championnats doit-il être committé dans le dépôt (public) ?**
Réponse PO (2026-09-23) : oui, mais chiffré par mot de passe (`openssl`, AES-256, dérivation
PBKDF2) et versionné ; mot de passe conservé par le PO dans son KeePass (entrée NUNI) et dans
`env/seed.json`, non versionné, pour le déchiffrement lors des reconstructions.
Constat : contrairement aux trous (publics dans l'app, photos de lieux), ce seed contiendrait les
noms des joueurs et les chemins des photos de session (des visages). Le bucket des photos est
lisible par quiconque connaît le chemin : le publier sur GitHub rend ces photos accessibles à
tous. Il contiendrait aussi, pour le rattachement à l'inscription (Q64), les e-mails des joueurs
importés sans compte, qui ne doivent jamais être publiés.
Suggestion : seed des trous inchangé (committé) ; seed des sessions, joueurs, scores, photos et
e-mails généré par le même outil dans un dossier ignoré par git (`supabase/private_seed/`), rejoué
par la procédure de reconstruction comme les autres. Le PO en garde une copie hors du poste (ex.
son espace de stockage personnel), puisqu'un fichier local seul ne protège pas d'une perte du
poste. Tant que l'ancien projet LsgScores existe, le script d'import reste en plus une seconde
voie de restauration pour les sessions importées.

## Associations (étape 18)

Demande PO du 2026-09-23 : rattacher joueurs, sessions et championnats à une association, page
des associations, responsables locaux et créations validés par un `super_admin`. Plan :
[plans/18_associations.md](plans/18_associations.md).

**Q77 ☑ — L'association remplace-t-elle les zones géographiques du championnat ?**
Réponse PO (2026-09-23) : oui, suggestion retenue.
Constat : aujourd'hui un championnat regroupe automatiquement les sessions jouées à moins de 15 km
les unes des autres (plan 15). Avec des sessions rattachées à une association, les deux
découpages coexisteraient et pourraient se contredire (deux associations d'une même ville dans une
seule zone).
Suggestion : oui. Un championnat = une association × une saison. On supprime les zones, le rayon
de 15 km, l'effet de chaîne et le nom de zone déduit des villes ; le calcul des points ne change
pas. Plus simple, et c'est exactement le cas que la demande veut couvrir.

**Q78 ☑ — Combien de responsables locaux par association ?**
Réponse PO (2026-09-23) : oui, un seul responsable approuvé à la fois.
Suggestion : un seul approuvé à la fois. Tant qu'il y en a un, le bouton « Je suis le responsable
local » est masqué ; un `super_admin` peut le révoquer, ce qui rouvre la revendication. Évite les
modifications concurrentes et donne un seul contact clair. Plusieurs responsables pourront venir
plus tard sans changer le modèle (une ligne par responsable).

**Q79 ☑ — Un joueur peut-il changer d'association après son premier choix ?**
Réponse PO (2026-09-23) : oui, suggestion retenue.
Suggestion : oui, librement depuis la fiche d'une association (« Rejoindre cette association »),
sans validation. Ses sessions passées gardent leur association (elles restent dans les
championnats où elles ont été jouées) ; seules ses futures sessions suivent. Couvre un
déménagement ou une erreur au premier choix.

**Q80 ☑ — L'association d'une session peut-elle changer après sa création ?**
Réponse PO (2026-09-23) : oui, suggestion retenue.
Suggestion : non, figée à la création (celle du créateur à ce moment-là). Un `super_admin` peut la
corriger en cas d'erreur. Évite qu'un championnat change sous les pieds des joueurs.

**Q81 ☑ — Pendant qu'une demande de création est en attente, à quelle association appartient le
demandeur ?**
Réponse PO (2026-09-23) : suggestion non retenue. Pour rester simple, on ne crée de sessions
que pour une association validée, approuvée et référencée. Le demandeur n'est donc rattaché à
aucune association tant que sa demande attend : il peut consulter l'app et rejoindre des
sessions, pas en créer. À l'approbation, il est rattaché à la nouvelle association ; en cas de
refus, l'écran de choix réapparaît.
Constat : l'écran de choix est obligatoire, mais l'association demandée n'existe pas encore.
Suggestion : le demandeur est rattaché tout de suite à son association en attente, visible de lui
seul et des super administrateurs ; il utilise l'app normalement et ses sessions y sont rattachées.
Si la demande est refusée, l'écran de choix réapparaît à sa prochaine ouverture et ses sessions
suivent l'association qu'il choisit alors.

**Q82 ☑ — Le demandeur d'une création devient-il automatiquement le responsable local ?**
Réponse PO (2026-09-23) : oui, c'était l'intention.
La demande prévoit « nom, mail et tel du responsable ». Seul un compte NUNI peut modifier une
association.
Suggestion : oui, le responsable est le demandeur ; son nom est pré-rempli depuis son profil et
il saisit son mail et son téléphone. Pour qu'une autre personne devienne responsable, elle crée
son compte et revendique le rôle (ou le demandeur transmet après coup).

**Q83 ☑ — Comment situer la ville d'une association ?**
Réponse PO (2026-09-23) : oui, suggestion retenue.
Constat : la suggestion par distance a besoin d'une position. L'app ne sait aujourd'hui que
transformer une position en nom de ville (BigDataCloud), pas l'inverse.
Suggestion : saisie du nom de la ville + un point posé sur une carte (même composant que la
position d'un trou), centrée sur la position du demandeur. Pas de nouveau service externe.

**Q84 ☑ — Quelle liste initiale d'associations ?**
Réponse PO (2026-09-23) : pour commencer, six associations seulement : Lyon Street Golf
(LSG, Lyon), Street Golf à l'Ouest (SGO, Morlaix), Wild Shrimp Crew (Grenoble), Médiéballes
(Laon), Urban Green Lille (Lille), Strasbourg Street Golf (Strasbourg). Les autres demanderont
leur création dans l'app.
Source trouvée : la carte « Associations et équipes françaises » de la Fédération
(streetgolf.fr/federation), qui charge un fichier public de nynjas.golf (35 contacts). Proposition
dans le plan 18 : les 20 contacts de type « Association » (nom, ville, site, position ; aucune
donnée personnelle reprise).
Points à trancher : (a) inclure aussi les équipes (« Team » seul), dont Strasbourg Street Golf et
Wild Shrimp Crew, membres du comité directeur de la Fédération ? (b) NYNJAS Golf apparaît sous 5
antennes (Paris, Toulouse, Luchon, Solenzara, Tahiti) : une seule association (Paris) ou une par
antenne ? (c) trois villes sont déduites de la position GPS (Reims, Charleville-Mézières, La
Possession) et une (Laon) du nom : à confirmer.
Suggestion : (a) non, elles demanderont leur création si elles utilisent l'app ; (b) une seule,
NYNJAS Golf, à Paris ; (c) villes conservées telles que déduites.

**Q85 ☑ — Où accéder à la page des associations ?**
Réponse PO (2026-09-23) : suggestion non retenue. Un onglet « Associations » dans la barre de
navigation du bas, pour mettre en avant le côté associatif et rendre visible le message « vous
pouvez déclarer votre association et commencer à utiliser l'app ».
Suggestion : une entrée « Associations » dans les Réglages, et un lien depuis mon association sur
le profil. Pas de quatrième onglet dans la barre de navigation : c'est une page consultée
rarement.

**Q86 ☑ — Comment le super administrateur apprend-il qu'une demande attend ?**
Réponse PO (2026-09-23) : oui, sans e-mail pour le moment, avec une page dédiée à la gestion
des demandes. Complément : les formulaires de demande de création et de demande de responsable
local ont un champ libre pour écrire un message au super administrateur.
Suggestion : un compteur « Demandes en attente » dans ses Réglages, qui ouvre l'écran de
validation. Pas d'e-mail : NUNI n'a aucun service d'envoi d'e-mails, en ajouter un (compte,
réglages, délivrabilité) est disproportionné pour quelques demandes par an.

**Q87 ☑ — Migration : reconstruction du schéma ou migration additive ?**
Réponse PO (2026-09-23) : suggestion non retenue, pas encore. L'app n'a pas encore été utilisée
de façon officielle ; le seed chiffré existe justement pour pouvoir encore réinitialiser puis
re-remplir la base. On reste sur la règle 8 : fichiers de migration édités en place,
reconstruction de la base distante (PO prévenu avant), rejeu des seeds.
Constat : la règle 8 (AGENTS.md) veut qu'avant la mise en service on édite les fichiers de
migration existants et reconstruise la base distante. Le plan 12 est clôturé et la première
session réelle a lieu la semaine prochaine : l'app est de fait en service, avec des données
réelles.
Suggestion : passer dès ce plan aux migrations additives (un nouveau fichier qui crée les tables,
rattache l'existant à LSG et retire les zones), sans reconstruction. Moins risqué pour les données
réelles, pas de rejeu des seeds. La règle 8 serait mise à jour en conséquence.

**Q88 ☑ — L'accueil ne montre-t-il que les sessions et championnats de mon association ?**
Constat (2026-09-23) : non. Les sessions listées sont celles dont je suis participant, quelle que
soit leur association ; les championnats affichés sont tous ceux où j'ai joué au moins une session,
visiteur compris (plan 18, décision 4).
Suggestion : garder cet affichage (une session jouée ailleurs reste la mienne et doit rester
accessible, par exemple pour la reprendre en direct), en mettant mon association en premier.
Réponse PO (2026-09-23) : suggestion retenue. Affichage inchangé ; les encarts de championnat de
l'accueil (saison en cours et championnats passés, au sein d'une même saison) et le sélecteur de la
page de classement placent mon association en premier.

**Q89 ☑ — Suppression d'une association : que deviennent ses sessions et ses membres ?**
Réponse PO (2026-09-23) : suggestion retenue, refus tant que des sessions appartiennent à l'association.
Demande PO (2026-09-23) : pouvoir supprimer une association, action réservée aux `super_admin`.
Constat : chaque session appartient à une association ; ses scores, photos et points de
championnat concernent aussi d'autres joueurs.
Suggestion (implémentée le 2026-09-23) : suppression refusée tant que des
sessions appartiennent à l'association (message explicatif) ; sinon, suppression avec son
responsable et ses coordonnées, et ses membres repassent sans association (l'app leur demande
d'en choisir une à la prochaine ouverture). Alternative si le besoin se présente : un
`super_admin` déplace d'abord les sessions vers une autre association (la fonction de correction
existe côté serveur, Q80), puis supprime.

**Q146 ☑ — Le choix d'une association à la première connexion est-il obligatoire ? Peut-on
quitter son association ?**
Demande PO (2026-09-25) : pouvoir utiliser l'app sans rejoindre d'association ; le choix reste
proposé à la première connexion, sans être imposé. Pouvoir aussi quitter une association.
Constat : l'écran de choix était obligatoire (plan 18, décision 1) ; on ne pouvait que changer
d'association (Q79), jamais la quitter. L'état « sans association » existait déjà (demande en
attente, Q81 ; association supprimée, Q89) : on peut rejoindre des sessions, pas en créer.
Réponses PO (2026-09-25) :
- (a) Sans association, pas de création de session : règle gardée (suggestion retenue). Une
  session appartient toujours à une association, donc pas de changement de schéma.
- (b) « Plus tard » est retenu sur l'appareil, comme la palette (suggestion retenue) : l'écran
  n'est reproposé que sur un nouvel appareil ou navigateur. Quitter une association vaut aussi
  « plus tard ».
- (c) Bouton « Quitter cette association » sur la fiche de mon association, avec confirmation
  (suggestion retenue).
- (d) Suggestion non retenue : un responsable local ne peut pas quitter l'association qu'il
  gère, pour garder une règle simple à comprendre. Conséquence directe appliquée : il ne peut
  pas non plus en rejoindre une autre (changer, c'est quitter). Contrôle fait dans l'app, pas
  en base (aucun changement de schéma, donc pas de reconstruction).

## Plans 19 à 25 — fiches synthétiques (2026-09-24)

Short list du PO (2026-09-24) : hors ligne, suppression de compte (plan 14, Q27–Q31 déjà
posées), statistiques joueur, statistiques trou, badges, calendrier et inscriptions, export
image vitrine, identité street. Priorité pour lundi 2026-09-28 : badges, statistiques joueur et
trou.

**Q90 ☑ — Statistiques joueur : quelles sessions comptent pour les statistiques de coups ?**
Réponse PO (2026-09-24) : suggestion retenue, restreinte aux **sessions individuelles** (un
trou en mode `individual` dans une session par équipes ne compte pas). Les statistiques peuvent
en plus comporter des « méta-statistiques » sur le jeu en équipe (équipier le plus fréquent,
etc. ; détail en Q107).
Constat : la base stocke un score par équipe et par trou (`scores.team_id`), jamais par joueur.
Un coup n'appartient à un joueur que si son équipe n'en compte qu'un.
Suggestion : les statistiques de coups (moyenne, rapport au par, meilleur trou) ne prennent que
les trous joués par une équipe d'un seul joueur (session individuelle, ou mode de jeu
`individual`). Les sessions par équipes comptent pour les sessions jouées, victoires et
podiums. Attribuer à chaque joueur le score de son équipe fausserait les moyennes (un scramble
à 4 joue mieux qu'un joueur seul). Tant que la question est ouverte, le plan 19 applique cette
suggestion.

**Q91 ☑ — Qui peut voir les statistiques d'un joueur ?**
Réponse PO (2026-09-24) : suggestion retenue, statistiques publiques par défaut ; chaque
utilisateur peut les rendre privées depuis son profil (étendue du masquage : Q106).
Constat : la RLS ne montre une session qu'à ses membres. Des statistiques calculées sur « ce
que je vois » différeraient d'une personne à l'autre.
Suggestion : les statistiques de tout joueur sont visibles de tout utilisateur connecté,
calculées sur toutes ses sessions terminées, via une RPC `security definer` qui ne renvoie que
des scores (ni photos ni commentaires). C'est le modèle déjà retenu pour le classement du
championnat. Alternative plus restrictive : visibles seulement des membres de la même
association.

**Q92 ☑ — Les sessions importées de LsgScores comptent-elles dans les statistiques et badges ?**
Réponse PO (2026-09-24) : suggestion retenue. Les statistiques existent ainsi avant même le
début de la saison 2026-2027.
Suggestion : oui. Elles sont vérifiées (plan 13) et elles donnent l'historique qui rend les
statistiques intéressantes dès le premier jour. Un joueur importé sans compte (`user_id` nul) a
aussi ses statistiques, consultables depuis l'historique.

**Q93 ☑ — Seuil minimal avant d'afficher une statistique ?**
Réponse PO révisée (2026-09-24, après essai du plan 19 sur les données réelles : un seul « X »
sur un trou joué une fois en faisait durablement le « pire trou ») : « meilleur / pire trou »
(plan 19) et « roi du trou » (plan 20) seulement à partir de **3 passages** du joueur sur le
trou. Les autres statistiques restent sans seuil ; le « X » compte toujours dans l'écart moyen
au par et la répartition. Tant qu'aucun trou n'atteint 3 passages, la fiche le dit.
Précision PO (2026-09-24, essai du plan 20) : à moyenne égale, le « roi du trou » est le joueur
qui a joué le trou le plus récemment (et non celui qui a le plus de passages), « toujours pour
inciter les gens à jouer des sessions », comme le record (Q94 révisée).
Première réponse PO (2026-09-24), remplacée : suggestion non retenue. Aucun seuil : statistiques joueur et trou
affichées dès le premier trou joué (meilleur / pire trou et « roi du trou » compris).
Suggestion : « meilleur / pire trou » et « roi du trou » à partir de 3 passages sur le trou ;
la moyenne générale dès 1 trou. En dessous du seuil, l'app affiche « pas encore assez de
parties ». Évite qu'un seul coup de chance fasse un record durable.

**Q94 ☑ — Statistiques trou : quels passages comptent pour le record d'un trou ?**
Réponse PO révisée (2026-09-24, après essai du plan 20) : à égalité, c'est **le plus récent**
qui prend le record. Raison : « un gros birdie risque de lock le titre pour toujours », alors
qu'accorder le titre au plus récent incite les joueurs à performer. Dans un même passage, l'ordre
alphabétique départage. Le reste de la suggestion est inchangé (scores d'un seul joueur, moyenne
et répartition selon la même règle). Conséquence pour le plan 21 : égaler un record suffit à
obtenir J1 (« a détenu le record d'un trou »).
Première réponse PO (2026-09-24), révisée : suggestion retenue telle quelle (le premier garde le
record).
Suggestion : même règle que Q90, uniquement les scores d'équipes d'un seul joueur. Le record
est le plus petit nombre de coups ; en cas d'égalité, le premier à l'avoir réalisé le garde. La
moyenne et la répartition du trou suivent la même règle.

**Q95 ☑ — Un trou public joué par plusieurs associations : record commun ou par association ?**
Réponse PO (2026-09-24) : pas de statistiques par association, cela n'a pas de sens
géographiquement : un trou a des statistiques et un record communs. La partie « trou privé » de
la suggestion n'a pas été tranchée : reprise en Q110.
Suggestion : record commun, avec le nom du joueur et son association. Le trou est le même
objet dans le référentiel ; un record par association diluerait le défi. Un trou privé n'a de
statistiques que pour son propriétaire.

**Q96 ☑ — Badges : catalogue de la première version ?**
Réponse PO (2026-09-24) : principe accepté ; lister les badges de façon exhaustive dans le plan
21 pour que le PO fasse le tri. Catalogue de 78 badges en 11 familles rédigé le 2026-09-24 dans
`docs/plans/21_badges.md`, trié par le PO le même jour : 6 supprimés, 1 ajouté (Hold-up),
9 seuils abaissés, 1 renommé ; tout badge non marqué « X » est accepté, soit 73 badges
retenus (détail dans le plan 21).
Suggestion : les 5 familles du plan 21 (premiers pas, exploits, victoires, explorateur,
fidélité), une quinzaine de badges au total, tous calculables avec les données existantes. Mieux
vaut peu de badges atteignables que beaucoup de badges impossibles : un badge jamais obtenu
n'incite à rien.

**Q97 ☑ — Badges : rétroactifs sur l'historique ?**
Réponse PO (2026-09-24, par Q92 qui portait sur statistiques et badges) : oui, sessions
importées comprises.
Suggestion : oui, automatiquement, puisque les badges sont recalculés à partir de l'historique
(aucune table). Conséquence : au premier lancement, les anciens joueurs découvrent d'un coup
tous leurs badges ; l'app les annonce en un seul écran, pas un par un.

**Q98 ☑ — Badges : visibles des autres joueurs ?**
Réponse PO (2026-09-24, avec Q106) : oui par défaut, sur la fiche du joueur ; l'utilisateur peut
les masquer (réglage commun ou séparé des statistiques : Q108).
Suggestion : oui, sur la fiche de statistiques du joueur, avec la même visibilité que Q91. Un
badge sert aussi à être montré.

**Q99 ☐ — Hors ligne : quel périmètre ?**
Suggestion : seulement la saisie et la correction des scores d'une session déjà ouverte.
Créer, rejoindre, ajouter un trou et clore restent en ligne. C'est le geste répété sur le
terrain ; le reste est rare et dépend de la géolocalisation ou d'autres joueurs.

**Q100 ☐ — Hors ligne : deux téléphones saisissent le même score sans réseau ?**
Suggestion : garder la règle actuelle, la dernière saisie envoyée gagne, sans message de
conflit. En pratique, une équipe saisit sur un seul téléphone ; gérer les conflits coûterait
cher pour un cas rare.

**Q101 ☑ — Calendrier : qui peut planifier une session ?**
Réponse PO (2026-09-25), dans les besoins du planning (plan 23) : tout membre de l'association
crée un événement à la main ; l'import d'un agenda est réservé au responsable local et au
super_admin. Qui modifie et supprime : Q151.
Suggestion : tout joueur de l'association, comme aujourd'hui tout joueur peut créer une
session. Un responsable d'association peut supprimer une session planifiée.

**Q102 ☑ — Calendrier : comment rappeler l'événement aux inscrits ?**
Réponse PO (2026-09-25) : pas pour le moment ; faisable après coup si nécessaire, sans effet
sur la base.
Suggestion : un bouton « Ajouter à mon agenda » (fichier `.ics`), sans notification push. Les
notifications d'une PWA restent peu fiables sur iPhone et demandent une infrastructure
d'envoi ; l'agenda du téléphone fait déjà très bien le rappel.
Mise à jour (2026-09-25, plan 23 détaillé) : le plan ne contient ni rappel ni bouton. Si le
bouton est retenu, il s'ajoute au détail d'un événement pour un coût faible (le plan sait déjà
lire le format) ; faute d'heure de fin, l'événement ajouté à l'agenda durerait 2 heures. Tant
que la question est ouverte, le plan 23 n'en contient pas.

**Q103 ☐ — Export vitrine : quels modèles pour la première version ?**
Suggestion : format story 9:16 avec deux modèles, « Podium » et « Classement complet ».
« Exploit » arrive après les plans 19 et 21, dont il dépend.

**Q104 ☐ — Identité street : quelle typographie pour les chiffres ?**
Suggestion : une police condensée et grasse gratuite (famille « Bebas Neue » ou « Barlow
Condensed », licence OFL), réservée aux scores et aux rangs, texte courant inchangé. Choix
final sur maquette dans `/dev/theme`.

**Q105 ☐ — Identité street : quelle place pour les animations et vibrations ?**
Suggestion : réservées à quatre moments (birdie ou mieux, changement de leader, badge obtenu,
podium de fin), courtes (moins d'une seconde), et désactivables dans les réglages. Au-delà,
elles fatiguent et ralentissent la saisie.

**Q106 ☑ — Statistiques privées (Q91) : qu'est-ce qui est masqué, et pour qui ?**
Réponse PO (2026-09-24) : « privé » ne porte que sur des informations du profil du joueur. La
fiche d'un joueur est toujours visible, avec seulement son pseudo et sa photo. Les statistiques
et les badges sont des informations en plus sur cette fiche, visibles par défaut quand on la
consulte ; l'utilisateur peut régler leur visibilité (nombre de réglages : Q108). Les classements
de session et de championnat ne sont pas concernés.
Constat : il n'existe pas aujourd'hui de fiche joueur consultable par les autres (`/profile` est
mon propre profil) ; le plan 19 la crée (`/players/:id`). Le réglage demande une modification de
schéma, donc une reconstruction de la base distante (règle 8, Q87).
Suggestion initiale (non retenue telle quelle) : masquer fiche et badges pour tous sauf le
joueur, auteur d'un record de trou affiché « Joueur masqué ».

**Q107 ☑ — Méta-statistiques d'équipe (Q90) : lesquelles pour la première version ?**
Réponse PO (2026-09-24) : suggestion retenue.
Suggestion : sessions par équipes jouées, victoires et podiums en équipe, équipier le plus
fréquent, meilleur duo (meilleur taux de victoire ensemble, au moins 3 sessions communes). Tout
se calcule depuis `team_players` et les classements, sans attribuer de coups à un joueur.

**Q108 ☑ — Visibilité du profil : un seul réglage ou un par section (statistiques, badges) ?**
Réponse PO (2026-09-24) : suggestion retenue, deux interrupteurs indépendants.
Suggestion : deux interrupteurs indépendants, « Statistiques publiques » et « Badges publics »,
tous deux activés par défaut (`players.stats_public` et `players.badges_public`). Cas d'usage
réel : fier de ses badges mais pas de sa moyenne. Le coût est le même qu'un seul réglage (deux
colonnes au lieu d'une, même écran).

**Q109 ☑ — Record d'un trou détenu par un joueur aux statistiques privées : quel nom afficher ?**
Réponse PO (2026-09-24) : suggestion retenue, pseudo et photo affichés.
Constat : le record appartient à la fiche du trou (plan 20), pas au profil du joueur. Avec la
définition de Q106, le pseudo et la photo sont toujours publics.
Suggestion : afficher le pseudo et la photo du détenteur (informations publiques) avec son
score, comme un classement de session. Le masquer rendrait le record anonyme sans protéger
grand-chose, puisque le résultat est déjà visible des participants de la session. Ses
statistiques détaillées restent masquées sur sa fiche.

**Q110 ☑ — Statistiques d'un trou privé : visibles par qui ?**
Réponse PO (2026-09-24) : question sans objet, la notion de trou privé est supprimée : tous
les trous sont visibles et utilisables par tous dans les sessions, seul leur auteur peut les
modifier. Plan 26, avec le clonage d'un trou et le par et le commentaire propres à une session.
Constat : un trou privé n'est visible que de son propriétaire et des membres des sessions où il
a été joué (RLS `holes`, Q13).
Suggestion : les statistiques d'un trou privé suivent la visibilité du trou lui-même : qui
peut ouvrir sa fiche voit ses statistiques. Aucune règle nouvelle, pas de fuite d'un trou privé
par ses statistiques.

**Q111 ☑ — Badge lié à un état qui change (record battu) : perdu ou gardé ?**
Réponse PO (2026-09-24) : suggestion retenue, un badge obtenu est gardé à vie.
Constat : les badges J1 à J3 (plan 21) dépendent d'un record ou d'une moyenne qui peut être
dépassé plus tard.
Suggestion : gardé à vie (« a détenu le record »). Un badge qui disparaît est vécu comme une
punition et rend l'affichage instable ; la fiche du trou montre déjà le détenteur actuel. Le
calcul rejoue l'historique dans l'ordre chronologique.

**Q112 ☑ — Badge Marathon : à partir de combien de trous ?**
Réponse PO (2026-09-24) : suggestion retenue, 9 trous.
Constat : au tri de Q96, le PO a jugé 18 trous beaucoup trop (« quand on fait 9 trous dans une
session c'est déjà énorme ») sans donner de nouveau seuil.
Suggestion : 9 trous. Le commentaire du PO décrit 9 trous comme exceptionnel, ce qui est le
rôle d'un badge « Marathon » ; un seuil plus bas le rendrait banal. Tant que la question est
ouverte, le plan 21 applique 9 trous.

**Q113 ☑ — Badge Hold-up : un joueur ex æquo en tête avant le dernier trou compte-t-il ?**
Réponse PO (2026-09-24) : Hold-up exige d'être **strictement derrière** le 1er avant le
dernier trou (un ex æquo en tête ne compte pas) et **1er seul** à la fin de la session (pas
d'ex æquo). Aucune égalité ne déclenche le badge, ni avant le dernier trou, ni à la fin.
Constat : Hold-up (ajouté par le PO au tri de Q96) = victoire alors que le joueur n'était pas
1er avant le dernier trou. Avec une égalité en tête avant ce trou, « pas 1er » est ambigu.
Suggestion : un ex æquo en tête compte comme 1er, donc pas de Hold-up. C'est la même règle que
pour la victoire (tous les ex æquo gagnent) : le badge récompense un vrai renversement, pas le
fait de départager une égalité. Tant que la question est ouverte, le plan 21 applique cette
règle.

**Q114 ☑ — Badges : quelle présentation visuelle ?**
Réponse PO (2026-09-24) : suggestion retenue pour commencer ; c'est du visuel, il pourra
évoluer.
Constat : 73 badges ; dessiner une illustration par badge coûte cher et reste difficile à
garder cohérent. L'app embarque déjà la police d'icônes Phosphor complète (environ 1 500
icônes, chacune en contour et en plein, `assets/fonts/Phosphor*.ttf`).
Suggestion : un médaillon rond unique pour tous les badges, avec une icône Phosphor au centre
et la couleur de sa famille (A à K), tirée de la palette choisie par l'utilisateur. Les séries
à paliers (5, 10, 25… sessions ; birdie, eagle, albatros ; 1re, 5e, 25e victoire…) partagent
une icône et se distinguent par un anneau bronze, argent ou or et le chiffre du seuil : environ
56 icônes distinctes au lieu de 73, toutes trouvables dans Phosphor (oiseau, trophée,
couronne, nuage de pluie, flocon, vent, lune, appareil photo, carte…). Badge obtenu : icône
pleine et colorée ; à obtenir (sur sa propre fiche) : icône en contour grise, avec la
progression pour les compteurs (« 7 / 10 sessions »). Fiche joueur : grille par famille ; un
appui ouvre le détail (nom, condition, date et session d'obtention). Les émojis sont écartés
(rendu différent selon le téléphone, hors charte), les illustrations sur mesure aussi (coût,
cohérence). Choix final sur maquette dans `/dev/theme`.

**Q115 ☑ — Badges : quelle heure fait foi pour « Oiseau de nuit », « Lève-tôt » et les dates ?**
Réponse PO (2026-09-24) : suggestion retenue, heure de l'appareil.
Constat : I5 (après 21 h) et I6 (avant 8 h), ainsi que les semaines, mois et saisons de la
famille B, dépendent d'un fuseau horaire. La base enregistre l'instant exact ; l'historique
l'affiche à l'heure de l'appareil qui le consulte.
Suggestion : l'heure de l'appareil, comme l'historique. Toutes les associations sont en France
aujourd'hui, donc le résultat est le même pour tout le monde ; fixer l'heure de Paris
demanderait une bibliothèque de fuseaux horaires en plus pour un cas qui n'existe pas encore.
Tant que la question est ouverte, le plan 21 applique cette suggestion.

**Q116 ☑ — Badges « Bâtisseur » : les trous et sessions importés de LsgScores comptent-ils ?**
Réponse PO (2026-09-24) : suggestion non retenue, les données importées comptent. Dans les
faits, le PO a tout créé dans l'ancienne app ; cela ne prive personne de ces badges, que
d'autres obtiendront en créant des trous sur d'autres spots.
Constat : les trous et sessions importés sont attribués d'office au compte du PO (Q50,
plan 13), pas à leur véritable auteur. Compter ces données donnerait au PO H1, H2, H4 et H5
d'un coup, pour des créations faites en partie par d'autres dans l'ancienne app.
Suggestion : non, la famille H ne compte que ce qui a été créé dans NUNI (trous et sessions sans
`legacy_id`, photos non copiées par l'import). Elle récompense une contribution à l'app, pas une
attribution technique. Les autres familles comptent l'historique importé (Q92). Tant que la
question est ouverte, le plan 21 applique cette suggestion.

**Q117 ☑ — Badges : valider les définitions de détail du plan 21 ?**
Réponse PO (2026-09-24), point par point :
- (a) plus large que la suggestion : **tous les badges** ne comptent que les sessions d'au
  moins 3 joueurs **et** d'au moins 3 trous joués, pour écarter le jeu seul, les duels et les
  sessions abandonnées (suite en Q123 et Q124) ;
- (b) dernier ex æquo, (c) semaine et saisons, (d) moitié de session, (e) « de suite » :
  suggestions retenues ;
- (f) non : Globe-trotter devient un critère géographique, 3 sessions éloignées d'au moins
  50 km les unes des autres, au lieu du nom de ville (texte fragile) ;
- (g) suggestion retenue (pas de golf sous l'orage), et nouveau badge « Sous la neige », même
  légère (I8, 74 badges) ;
- (h) sans réponse : reprise en Q125.
Constat : plusieurs conditions du catalogue ont besoin d'une règle précise pour être calculées.
Suggestion, à valider en bloc (détail dans `docs/plans/21_badges.md`, « Définitions
communes ») :
- une session à une seule équipe ne donne ni victoire, ni podium, ni dernière place ;
- « dernier » : la plus mauvaise place, ex æquo compris ;
- semaine du lundi au dimanche ; saisons par mois (hiver = décembre à février, etc.) ;
- moitié de session (Remontada) : après le trou n / 2 arrondi à l'inférieur ;
- « de suite » (Série de pars, Main chaude, Rebond) : un trou non saisi interrompt la série
  (les trous libres comptent, ils ont un par depuis le plan 26) ;
- ville (Globe-trotter) comparée sans majuscules, accents ni espaces autour ;
- pluie : codes météo de la bruine, de la pluie et des averses ;
- Oiseau de nuit : session démarrée à 21 h ou plus tard.
Chacune suit la règle la plus simple à expliquer à un joueur. Tant que la question est ouverte,
le plan 21 les applique.

## Trous tous publics, clonage, par et commentaire de session (plan 26, 2026-09-24)

**Q118 ☑ — Par d'un trou joué : copie figée à l'ajout, ou surcharge facultative ?**
Réponse PO (2026-09-24) : suggestion retenue.
Constat : demande PO (2026-09-24), un par propre à la session doit pouvoir prendre le pas sur le
par officiel du trou, et un trou libre doit toujours avoir un par. Aujourd'hui, le par n'existe
que sur le trou (`holes.par`) : si son auteur le change, toutes les sessions passées changent
de par, donc de statistiques et de badges.
Suggestion : une colonne `played_holes.par` toujours remplie. À l'ajout, elle reçoit le par
officiel du trou (modifiable tout de suite), ou le par choisi pour un trou libre. Tous les
calculs lisent ce seul champ ; l'historique ne bouge plus si le trou est modifié ensuite. Une
surcharge vide par défaut obligerait chaque calcul à choisir entre deux champs, et laisserait
l'historique suivre les changements du trou. Valeurs permises : 1 à 10, à la hausse comme à la
baisse (une variante peut aussi être plus facile). Tant que la question est ouverte, le plan 26
applique cette suggestion.

**Q119 ☑ — Cloner un trou : les photos sont-elles copiées ?**
Réponse PO (2026-09-24) : suggestion retenue, photos copiées.
Constat : les photos d'un trou sont rangées dans le dossier de son auteur, seul autorisé à les
remplacer ou les supprimer. Un clone qui pointerait vers ces fichiers perdrait ses photos si
l'auteur d'origine les change.
Suggestion : oui, les photos de départ et de cible sont copiées dans le dossier de la personne
qui clone. Le clone devient un trou indépendant, comme le reste de ses champs. Tant que la
question est ouverte, le plan 26 applique cette suggestion.

**Q120 ☑ — Un clone compte-t-il comme trou créé pour les badges « Bâtisseur » ?**
Réponse PO (2026-09-24) : suggestion retenue.
Constat : sans règle, cloner 5 trous suffirait à obtenir Paysagiste (plan 21, H2) sans poser un
seul nouveau drapeau.
Suggestion : non. Le trou retient d'où il a été cloné (`holes.cloned_from`), et H1 et H2 ne
comptent que les trous qui ne sont pas des clones. H3 (Architecte) compte le clone comme un
trou de son auteur, puisqu'il a pu le déplacer ou le modifier. Tant que la question est
ouverte, les plans 21 et 26 appliquent cette suggestion.

**Q121 ☑ — Commentaire et par d'un trou joué : qui les modifie, et quand ?**
Réponse PO (2026-09-24) : suggestion retenue, avec trois moments explicites : dans la
feuille de choix du trou pendant la session (à l'ajout), sur le trou déjà ajouté pendant la
session, et depuis l'historique.
Constat : ajouter ou retirer un trou joué est réservé à l'organisateur de la session (RLS
`played_holes_owner_write`).
Suggestion : la même règle : l'organisateur saisit commentaire et par à l'ajout du trou, et
peut les corriger ensuite depuis la carte du trou pendant la session, puis depuis le détail
de la session dans l'historique. Le commentaire s'affiche sous le nom du trou, en direct et
dans l'historique ; les exports PDF et image ne changent pas. Tant que la question est
ouverte, le plan 26 applique cette suggestion.

**Q122 ☑ — Trous libres déjà joués : quel par leur donner ?**
Réponse PO (2026-09-24) : suggestion retenue, par de 3. Le passage des trous privés en
publics est sans impact : l'app n'est pas encore utilisée et le PO est le seul à avoir créé des
trous.
Constat : les trous libres joués depuis le plan 17 n'ont pas de par, désormais obligatoire.
Suggestion : 3, la valeur par défaut d'un trou du référentiel (`holes.par`), posée une fois à
la reconstruction de la base. Ce sont surtout des trous de test ; l'organisateur peut corriger
ensuite (Q121). Tant que la question est ouverte, le plan 26 applique cette suggestion.

**Q123 ☑ — Records de trou : seulement les sessions de 3 joueurs et 3 trous ou plus ?**
Réponse PO (2026-09-24) : plus large que la suggestion : **toutes** les statistiques (joueur
et trou), tous les records et tous les badges suivent la règle des sessions d'au moins 3 joueurs
et 3 trous joués. Raison : à 3 joueurs ou plus, les scores sont saisis et vérifiés en groupe,
pas seul sans contrôle (limite de cet argument : Q127).
Constat : Q117 limite tous les badges à ces sessions, dont J1 à J3 (« a détenu le record d'un
trou »). Le record affiché sur la fiche du trou (plan 20) suit pour l'instant Q94 sans ce
filtre.
Suggestion : appliquer le même filtre au record et au « roi du trou » du plan 20. Sinon, un
joueur affiché comme détenteur du record, établi pendant un duel, n'aurait pas le badge
Recordman, et le joueur qui l'a ne serait pas celui affiché. Une seule règle, deux écrans
cohérents. Tant que la question est ouverte, les plans 20 et 21 appliquent cette suggestion.

**Q124 ☑ — Session éligible : faut-il aussi au moins 2 équipes ?**
Réponse PO (2026-09-24) : non, seul compte le nombre de joueurs. Vérifié dans le code : une
équipe compte exactement 2 joueurs (`session_kind.dart`, Q5) et chaque participant d'une
session par équipes est dans une équipe ; 3 joueurs ou plus garantissent donc au moins
2 équipes.
Constat : 3 joueurs dans une seule équipe (scramble à trois) remplissent la règle de Q117 mais
n'ont aucun adversaire : ils « gagnent » et sont « derniers » à la fois.
Suggestion : oui, une session éligible a en plus au moins 2 équipes. C'est le cas de la session
d'entraînement que Q117 veut écarter, sous une autre forme. Tant que la question est ouverte,
le plan 21 applique cette suggestion.

**Q125 ☑ — Oiseau de nuit et Lève-tôt : bornes exactes ?**
Réponse PO (2026-09-24) : Oiseau de nuit à partir de 21 h 00 ; Lève-tôt avant 9 h 00 (8 h
est trop tôt). Le PO demande aussi que les badges non obtenus restent visibles pour donner
envie de jouer (plan 21, décision 17).
Constat : point (h) de Q117, sans réponse. Une session démarrée à 21 h 00 pile est-elle « après
21 h » ?
Suggestion : oui, Oiseau de nuit compte à partir de 21 h 00 ; Lève-tôt compte avant 8 h 00
(7 h 59 compte, 8 h 00 non). Règle « à partir de » la plus simple à lire sur un écran. Tant
que la question est ouverte, le plan 21 applique cette suggestion.

**Q126 ☑ — Championnat : la règle des 3 joueurs et 3 trous s'applique-t-elle aussi ?**
Réponse PO finale (2026-09-24) : suggestion révisée retenue : pas de règle d'éligibilité pour
le classement du championnat ; la contrainte des 3 joueurs et 3 trous reste pour les
statistiques et les badges.
Réponse PO (2026-09-24), partielle : le marquage « championnat » est désormais réservé au
`super_admin` et au responsable local de l'association, et les sessions et le championnat
deviennent visibles par tous les membres de l'association (plan 26, volet B). La question
d'origine reste ouverte, reformulée : avec ce contrôle par le responsable, faut-il encore la
règle des 3 joueurs et 3 trous pour le classement du championnat ? Suggestion révisée : non,
le marquage par le responsable est le contrôle ; il peut ne pas marquer une session trop
petite, ou en marquer une exceptionnelle. Tant que la question est ouverte, rien ne change
pour le classement.
Constat : Q123 l'applique aux statistiques, records et badges. Le classement du championnat
(plan 15, livré) compte aujourd'hui toute session terminée marquée « championnat », quel que
soit le nombre de joueurs ou de trous. L'argument anti-triche de Q123 vaut aussi pour lui :
deux joueurs peuvent marquer un duel « championnat » et gagner des points de classement et de
présence.
Suggestion : oui, une session de championnat ne compte que si elle est éligible. Une seule
règle dans toute l'app, plus simple à expliquer. Conséquence : le classement de saison peut
changer si des sessions de championnat actuelles ont moins de 3 joueurs ou de 3 trous. Tant
que la question est ouverte, rien ne change pour le championnat (plan 15 livré, pas de
changement silencieux).

**Q127 ☑ — Anti-triche : la règle des 3 joueurs suffit-elle ?**
Réponse PO (2026-09-24) : suggestion retenue, on ne peut pas tout contrôler.
Constat : les joueurs d'une session peuvent être choisis sans être connectés (plan 07). Un
organisateur peut donc créer seul une session à 3 joueurs et saisir tous les scores : la règle
de Q123 écarte les parties d'entraînement honnêtes, pas une triche volontaire.
Suggestion : garder la règle simple, sans contrôle plus strict. Exiger par exemple 2 comptes
connectés ayant rejoint la session écarterait les nombreuses sessions où un seul téléphone
saisit pour tout le groupe, et toutes les sessions importées de LsgScores. Entre amis, avec des
badges sans enjeu, l'effort n'en vaut pas la peine. Tant que la question est ouverte, le plan
21 applique cette suggestion.

**Q128 ☑ — Badges : montrer aussi les badges proches en fin de session ?**
Réponse PO (2026-09-24) : suggestion retenue.
Constat : le PO veut que les badges non obtenus donnent envie de jouer (Q125). Le plan 21 les
affiche déjà tous, en gris avec leur progression, sur la fiche du joueur ; encore faut-il
l'ouvrir.
Suggestion : en fin de session, la feuille des nouveaux badges montre aussi jusqu'à 3 badges
proches, les plus avancés (« Plus qu'une session pour Pilier », « 8 / 10 birdies »). C'est le
moment où le joueur a le plus envie de rejouer, et cela ne demande aucun écran de plus. Tant
que la question est ouverte, le plan 21 applique cette suggestion.

**Q129 ☑ — Sessions de l'association : où les voir ?**
Réponse PO (2026-09-24) : suggestion non retenue. Par défaut, l'historique montre les sessions
de l'association, point ; un repère visuel simple et sobre signale celles où j'ai joué ; un
filtre n'affiche que les miennes ; aucune session en cours dans l'historique (suite en Q132).
Constat : décision PO du 2026-09-24 (plan 26, volet B) : toute session, en cours ou passée,
est visible par tous les membres de son association. L'onglet Historique ne montre
aujourd'hui que les sessions où l'on a joué.
Suggestion : l'onglet Historique propose deux portées, « Mes sessions » (par défaut, comme
aujourd'hui) et « Mon association », avec les sessions en cours en tête. Pas de nouvel onglet,
et l'usage actuel ne change pas pour qui ne regarde que ses parties. Tant que la question est
ouverte, le plan 26 applique cette suggestion.

**Q130 ☑ — Un super_admin voit-il les sessions de toutes les associations ?**
Réponse PO (2026-09-24) : non pour l'interface : le super_admin garde la possibilité (droit en
base, en secours), mais l'app ne lui liste pas toutes les sessions. Le responsable local est
l'acteur principal ; le PO, super_admin et membre de LSG, voit déjà les sessions LSG.
Constat : le super_admin peut marquer « championnat » n'importe quelle session (plan 26), il
doit donc pouvoir la trouver et l'ouvrir.
Suggestion : oui, lecture de toutes les sessions, sans droit d'écriture en plus (hors
marquage). Aujourd'hui, seul le PO a ce rôle (plan 16). Tant que la question est ouverte, le
plan 26 applique cette suggestion.

**Q131 ☑ — Sessions déjà marquées « championnat » par leur créateur : on les garde ?**
Réponse PO (2026-09-24) : oui, on garde l'existant.
Constat : jusqu'ici, le créateur d'une session la marquait lui-même (plan 15). Désormais seuls
le responsable local et le super_admin le peuvent.
Suggestion : oui, les marquages existants restent ; le responsable peut démarquer une session
s'il le juge utile. Retirer tout marquage changerait le classement de la saison sans raison.
Tant que la question est ouverte, le plan 26 applique cette suggestion.

**Q132 ☑ — Sessions en cours de l'association : où les suivre ?**
Réponse PO (2026-09-24) : suggestion retenue.
Constat : les sessions en cours de l'association sont visibles par ses membres (plan 26,
décision 12), mais l'historique n'en montre aucune (Q129). L'accueil liste déjà « mes
sessions en cours ».
Suggestion : la section « Sessions en cours » de l'accueil montre mes sessions, puis celles de
mon association auxquelles je ne participe pas ; un appui ouvre l'écran de session en lecture
seule. Les brouillons (salle d'attente) restent visibles de leurs seuls participants. Aucun
nouvel écran, et c'est là qu'on cherche une partie en train de se jouer. Tant que la question
est ouverte, le plan 26 applique cette suggestion.


## Statistiques joueur (plan 19, 2026-09-24)

**Q133 ☑ — Statistiques masquées mais badges publics : que peut-on lire de la base ?**
Réponse PO (2026-09-24) : le masquage sert à ne pas afficher publiquement ses aspects
négatifs, pas à protéger des données : les sessions et leurs scores sont lisibles, et n'importe
qui pourrait refaire les calculs. Donc l'historique d'un joueur est lisible en base sans
contrainte par tout compte connecté ; les interrupteurs « Statistiques publiques » et « Badges
publics » ne décident que de l'affichage des sections sur la fiche publique. La page
Confidentialité (`/privacy`) le mentionne et l'explique. Remplace, pour les statistiques et les
badges, le masquage côté serveur prévu par la fiche du plan 19 et le plan 21 (« même par un
appel direct »).
Constat (question d'origine) : les badges se calculent en Dart (règle du projet) à partir de l'historique du joueur,
le même que ses statistiques. Pour afficher les badges d'un joueur qui a masqué ses statistiques
mais pas ses badges, l'app doit recevoir cet historique ; quelqu'un qui appelle la base
directement pourrait alors recalculer les statistiques. Par ailleurs, depuis le plan 26, les
membres d'une association lisent déjà toutes ses sessions démarrées.
Suggestion : la RPC `player_history` renvoie l'historique si l'appelant est le joueur, ou si
l'un des deux interrupteurs est public ; la fiche n'affiche que les sections publiques. La
garantie « rien n'est lisible, même par appel direct » ne vaut donc que si les deux sont
masqués. L'alternative, calculer les badges dans la base, écrirait les 74 règles en SQL, contre
la règle « calcul en Dart, testé unitairement » et sans bénéfice réel puisque les partenaires de
club voient déjà les sessions. Tant que la question est ouverte, les plans 19 et 21 appliquent
cette suggestion.

**Q134 ☑ — Courbe de la saison : dessin maison ou bibliothèque de graphiques ?**
Réponse PO finale (2026-09-24), après un aperçu des deux graphiques sur données fictives : la
courbe de saison reste dans le plan 19, et le plan 20 aura l'histogramme de répartition des
scores ; dessin maison (suggestion retenue).
Première réponse PO (2026-09-24), révisée : pas de graphique pour le moment.
Constat : l'app n'a aucune bibliothèque de graphiques. La fiche joueur n'a besoin que d'une
courbe simple (un point par session, une ligne pour le par) ; le plan 20 envisage un histogramme
simple.
Suggestion : dessin maison (`CustomPainter` de Flutter, une centaine de lignes), aux couleurs de
la palette choisie. Aucune dépendance à suivre, poids de l'app inchangé, rendu identique à la
charte. Une bibliothèque (`fl_chart`, la référence Flutter) ne se justifierait qu'avec des
graphiques interactifs ou nombreux, ce que les plans 19 à 21 ne prévoient pas. Tant que la
question est ouverte, le plan 19 applique cette suggestion.

**Q135 ☑ — Statistiques d'un trou cloné : repartent-elles de zéro ?**
Réponse PO (2026-09-24) : suggestion retenue.
Constat : depuis le plan 26, n'importe qui peut cloner un trou (`holes.cloned_from`) pour en
faire sa version (départ, par ou description différents). Le clone est un nouveau trou : les
sessions jouées sur l'original restent rattachées à l'original.
Suggestion : chaque trou a ses propres statistiques, record et roi ; un clone part de zéro et
l'original garde les siens. Un clone sert justement à changer le trou (autre départ, autre
par) : additionner les scores de deux parcours différents fausserait le record et la
difficulté. C'est aussi le plus simple (aucun regroupement à maintenir si l'original change).

**Q136 ☑ — Badges J1 à J3 : les records et rois de saison comptent-ils ?**
Réponse PO (2026-09-24) : suggestion retenue, « badge d'exploit » : records et rois « toutes
saisons » seulement. Les records de saison restent affichés sur la fiche du trou, sans badge.
Constat : depuis le plan 20, la fiche d'un trou s'ouvre sur la saison la plus récente jouée, avec
son record et son roi de saison ; « Toutes saisons » montre ceux de tous les temps. Le plan 21
prévoit J1 « A détenu le record d'un trou », J2 « A détenu 5 records en même temps » et J3 « A été
roi du trou ».
Suggestion : seulement les records et rois « toutes saisons ». Au début de chaque saison, le
premier joueur à passer sur un trou en détient forcément le record de saison : J1 serait gratuit
chaque septembre, et J2 s'obtiendrait en jouant 5 trous au premier jour de la saison. Contrepartie
assumée : le détenteur affiché par défaut sur la fiche (celui de la saison) peut ne pas avoir J1,
tant qu'il n'a pas aussi le record de tous les temps. Tant que la question est ouverte, le plan 21
applique cette suggestion.

**Q137 ☑ — Plan 21 : livrer les badges en deux lots ?**
Réponse PO (2026-09-24) : suggestion retenue.
Constat : 64 des 74 badges (familles A à G, I et K) se calculent avec ce qui existe déjà
(`player_history`, classement du championnat). Les 10 autres (H, contributions ; J, records)
demandent deux nouvelles lectures en base, donc une reconstruction de la base distante (règle 8).
Suggestion : lot 1 = médaillon validé dans `/dev/theme`, puis les 64 badges, le bloc « Badges »
(profil et fiche publique, interrupteur) et l'annonce en fin de session, sans toucher à la base ;
lot 2 = familles H et J, avec la reconstruction. Chaque lot est essayé puis committé à part : un
premier résultat visible plus tôt, et un changement de base isolé, plus simple à vérifier. Tant
que la question est ouverte, le plan 21 applique cette suggestion.

**Q138 ☑ — Badges : égalités et sessions par équipes (demande du PO)**
Réponse PO (2026-09-25), après l'essai du lot 1 du plan 21 : pour rendre l'accès aux badges plus
dur, 1) les égalités ne comptent plus : un badge de place ne compte que si le joueur est seul
devant ou seul derrière ; 2) les sessions par équipes ne comptent plus pour les badges qui
reposent sur un classement (victoire, podium, dernière place), sauf « Collectif » (D12).
Précision du PO le même jour : elles comptent pour tous les badges qui ne dépendent pas des
scores (assiduité, régularité, météo, exploration, sessions de championnat, jeu en équipe). Le classement d'une session et les statistiques (plan
19) ne changent pas : victoires et podiums y gardent les ex æquo.

**Q139 ☑ — Badges : le podium et le top 5 gardent-ils les ex æquo ?**
Réponse PO (2026-09-25) : non, suggestion non retenue. En équipe comme en individuel, tout
badge de classement est strict : podium, victoire, top 3 ou top 5 de saison, dernière place ;
aucun ex æquo ne compte.
Constat : Q138 retire les égalités « devant ou derrière ». Le podium (D5, D6) et le top 3 ou
top 5 d'une saison de championnat (E4, E5) ne sont ni la première ni la dernière place.
Suggestion : les garder avec leurs ex æquo. Deux joueurs à égalité à la 2e place sont tous les
deux sur le podium sans ambiguïté ; les en priver donnerait le podium au 3e seul et pas aux
deux 2es. La règle « seul » reste pour tout ce qui désigne un premier ou un dernier : victoire,
titre de champion, lanterne rouge. Tant que la question est ouverte, le plan 21 applique cette
suggestion.

**Q140 ☑ — Badge « Solo » : le supprimer ?**
Réponse PO (2026-09-25) : réglé par Q141 : « Solo » et « Collectif » sont supprimés.
Constat : depuis Q138, seules les sessions individuelles comptent pour les victoires ; « Solo »
(D11, 1re victoire en session individuelle) s'obtient donc exactement en même temps que
« Première victoire » (D1).
Suggestion : supprimer « Solo » (63 badges au lieu de 64 dans le lot 1). Deux badges identiques
n'ajoutent rien à chercher et gonflent le compteur. « Collectif » (D12, victoire en session par
équipes) reste, puisqu'il est le seul à récompenser une victoire en équipe. Tant que la question
est ouverte, le badge est gardé.

**Q141 ☑ — Badges de classement : une version « équipe » de chacun ?**
Réponse PO (2026-09-25) : suggestion retenue. Même règle stricte (aucun ex æquo) en équipe.
Constat : depuis Q138, les sessions par équipes ne comptent pour aucun badge de classement, sauf
« Collectif » (D12). Le PO propose de dupliquer chaque badge de classement en version équipe, en
acceptant qu'elle soit plus facile à obtenir (un bon coéquipier aide). Les deux sessions par
équipes réelles comptent 3 et 4 équipes : un podium ou une dernière place en équipe y a un sens.
Suggestion : oui, une version équipe de D1 à D10 (victoires, hat-trick, podiums, de bout en
bout, remontada, photo-finish, hold-up) et de K1, K3 (dernière place), rangée dans la famille
« Jeu en équipe », avec la même icône que la version individuelle. « Solo » et « Collectif »
disparaissent : ils deviennent la « Première victoire » de chaque version. Le lot 1 passe de
64 à 74 badges. Les mêmes règles s'appliquent (seul devant ou derrière, Q138). Tant que la
question est ouverte, le plan 21 garde la règle actuelle (pas de version équipe).
Précision du PO le même jour : chaque famille affiche une pastille « Individuel », « Équipe » ou
« Individuel et équipe », selon les sessions que ses badges lisent.

**Q142 ☑ — Badges « se faire détrôner » et « se faire prendre le record » : les ajouter ?**
Réponse PO (2026-09-25) : oui, avec un badge de plus : « Détrôné » pour le roi qui perd son
titre (la première fois), « Régicide » pour celui qui le lui prend (il peut s'obtenir en même
temps que J3 « Roi du trou » ; devenir le premier roi d'un trou n'est pas un régicide).
« Record tombé » ajouté comme suggéré (pas d'objection du PO). Lot 2 : 87 badges.
Idée du PO (2026-09-25), pendant le lot 2 : des badges « stat trou » pour obtenir le record,
obtenir le titre de roi, se faire détrôner, se faire prendre le record.
Constat : obtenir le record et le titre de roi existent déjà (J1 « Recordman », J3 « Roi du
trou », lot 2). Les deux autres sont nouveaux. Le rejeu du lot 2 voit déjà chaque changement de
détenteur, trou par trou : les ajouter ne demande ni donnée ni appel de plus.
Suggestion : les ajouter au lot 2, dans la famille J, en badges uniques gardés à vie (Q111) :
J4 « Détrôné » (avoir été roi d'un trou puis perdu le titre au profit d'un autre joueur) et
J5 « Record tombé » (avoir détenu un record puis se l'être fait prendre), 86 badges au total.
Ils consolent sans rien coûter à obtenir un exploit, et donnent une raison de revenir reprendre
son titre. Une série (« 5 records perdus ») n'est pas proposée : elle récompenserait surtout de
perdre souvent. Tant que la question est ouverte, le lot 2 n'en contient aucun.

**Q143 ☑ — « Chasseur de records » : améliorer ou égaler son propre record compte-t-il ?**
Réponse PO (2026-09-25) : suggestion retenue, les compteurs ne comptent que la prise d'un
record sur quelqu'un d'autre. Confirmé le même jour : le premier record d'un trou (personne à qui le prendre) compte
aussi.
Demande du PO (2026-09-25) : un badge à compteur (10) du nombre de fois où le joueur a pris un
record : premier record d'un trou, record égalé plus récemment, ou record battu. Précision
du PO le même jour : J2 compte 5 records tenus en même temps sur 5 trous différents (c'est déjà
le cas, un seul record par trou).
Constat : quand le joueur détient déjà le record d'un trou et l'égale ou l'améliore, le
record ne change pas de mains.
Suggestion : ne compter que les records pris, quand le trou n'avait pas de record ou qu'un
autre joueur le détenait ; pas quand le joueur améliore ou égale le sien. Sinon, un joueur
seul sur un trou peu fréquenté ferait monter le compteur en rejouant son trou, sans jamais
rien prendre à personne. Un même trou compte à chaque reprise (pris, perdu, repris). Tant que
la question est ouverte, le lot 2 applique cette suggestion (J7 « Chasseur de records »).

**Q144 ☑ — Badge « garder son record 3 sessions d'affilée » : quelles règles ?**
Réponse PO (2026-09-25) : suggestion retenue pour (a) à (d), nom « Rempart » et icône
`castle-turret` validés. Codé : J8, compteur « 2 / 3 » (meilleure série).
Idée du PO (2026-09-25) : garder son record sur un trou pendant 3 sessions d'affilée où le
trou est joué ; une session où le trou est joué sans le joueur casse la série (d'où 3 et pas 5).
Constat : faisable sans donnée de plus, avec le rejeu du lot 2. Aucun frein bloquant ; quatre
points à fixer :
- (a) La session où le joueur prend le record compte-t-elle comme la 1re des 3 ?
- (b) Les sessions par équipes et en mode « Libre » ne comptent pas pour les records (Q90) :
  si le trou y est joué, cassent-elles la série ?
- (c) Les trous sont communs à toutes les associations (Q95) : une session d'une autre
  association sur ce trou casse la série alors que le joueur ne pouvait pas y être.
- (d) Égaler son propre record garde le titre (même détenteur) ; un autre joueur qui l'égale
  plus récemment le prend (Q94 révisée) et casse la série.
Suggestion : (a) non, 3 sessions après la prise : « garder » veut dire défendre, et avec la
prise le badge tomberait après 2 défenses seulement ; (b) non, elles sont ignorées, ni
comptées ni cassantes, puisqu'aucun record ne s'y joue ; (c) oui, elle casse la série, la
règle reste simple et c'est rare (un trou est surtout joué par son association) ; (d) comme
écrit. Badge unique gardé à vie, famille J, nom « Rempart » (icône `castle-turret`, le bouclier étant déjà pris). Tant que
la question est ouverte, rien n'est codé.

**Q145 ☑ — Badge « Confiance » : garder son record pendant une session jouée sans soi ?**
Réponse PO (2026-09-25) : suggestion retenue. Codé : J9.
Idée du PO (2026-09-25) : un badge « orgueil » ou « confiance » quand le record d'un joueur sur
un trou résiste à une session où ce trou est joué sans lui.
Constat : faisable avec le rejeu du lot 2, sans donnée de plus. C'est le pendant de Rempart :
la session sans le joueur casse la série de Rempart mais donne ce badge. Seul frein : il
s'obtient sans rien faire ce jour-là ; c'est l'esprit voulu (le record parle pour lui).
Suggestion : nom « Confiance » (EN « Confidence »), icône `hourglass` ; condition affichée
« Voir son record sur un trou résister à une session jouée sans vous ». Règle : le joueur
détient le record du trou avant une session éligible individuelle (Q90, Q117), de n'importe
quelle association (Q95), à laquelle il ne participe pas et où au moins un joueur a un score
sur ce trou ; il le détient encore à la fin de cette session. Sessions par équipes et « Libre »
ignorées, comme pour Rempart. Badge unique gardé à vie, famille J, sans lien vers la session
(il n'y était pas, elle peut appartenir à une autre association). Pas de version à compteur :
elle dépendrait surtout de l'activité des autres joueurs. Tant que la question est ouverte,
rien n'est codé.

## Planning d'association (plan 23, 2026-09-25)

Besoins exprimés par le PO le 2026-09-25 : événements créés à la main par tout membre ou
importés par le responsable local, lieu et libellé réutilisables, point sur la carte,
responsable, couleur, clonage, réponses présent / absent / peut-être, prochain événement sur
l'accueil, planning en liste avec séparateurs d'année et de mois. Les questions ci-dessous
portent sur ce que ces besoins ne fixent pas.

**Q147 ☑ — Planning : d'où vient la liste des libellés ?**
Réponse PO (2026-09-25) : suggestion retenue ; la gestion de ces libellés viendra plus tard.
Constat : le besoin demande une liste par association, enrichie par chaque saisie libre.
Suggestion : la liste est l'ensemble des libellés déjà utilisés dans les événements de
l'association, les plus récents d'abord, vide au départ ; pas de table ni d'écran de gestion.
C'est déjà ainsi que fonctionnent les zones des sessions. Une faute de frappe disparaît dès que
le dernier événement qui la porte est corrigé ou supprimé, sans écran d'administration à
construire. Une table dédiée ne se justifierait que pour une liste gérée par le responsable
(ordre imposé, libellés retirés à la main).

**Q148 ☑ — Planning : les lieux mémorisés sont-ils partagés avec le champ « Zone » des sessions ?**
Réponse PO (2026-09-25) : oui. **Remplacée le 2026-09-25 par le plan 28** (référentiel de spots,
Q178 à Q185) : les lieux proposés sont désormais les spots de l'association.
Constat : le besoin demande que les lieux saisis servent aux événements et aux sessions. La
création de session a déjà un champ « Zone (facultative) », qui propose les zones des sessions
précédentes de la même ville.
Suggestion : oui. Une seule liste de lieux par association, faite des lieux des événements et
des zones des sessions de l'association, proposée dans les deux formulaires, sans table dédiée
(même raison que Q147). Les suggestions de zone passent donc du filtre « même ville » au filtre
« même association », plus juste depuis le plan 18. Le champ garde son nom « Zone » ; le
renommer « Lieu » est possible mais toucherait l'historique et les exports.

**Q149 ☑ — Planning : quelles couleurs proposer pour un événement ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : huit teintes fixes (rouge, orange, jaune, vert, turquoise, bleu, violet, rose),
choisies par pastilles, plus « aucune ». La base ne stocke que le nom de la teinte ; sa couleur
exacte est définie par la palette choisie par l'utilisateur, en clair et en sombre, et passe le
test de contraste, comme toutes les couleurs de l'app (règle AGENTS.md). Un sélecteur libre
produirait des couleurs illisibles en mode sombre ou sur certaines palettes.

**Q150 ☑ — Planning : le lieu et le point sur la carte sont-ils obligatoires ?**
Réponse PO (2026-09-25) : suggestion non retenue, aucun des deux n'est obligatoire : on peut
créer un événement pour ouvrir les inscriptions et fixer lieu et point au dernier moment. Un
événement reste modifiable par son créateur, le responsable local et le super_admin. La date,
l'heure et le libellé restent obligatoires (besoin initial). À l'import, un événement sans lieu
reste sans lieu.
Constat : le besoin marque le responsable, la description et la couleur comme facultatifs,
mais ne dit rien du lieu ni du point.
Suggestion : lieu obligatoire, point facultatif. Un rendez-vous sans lieu ne sert à rien ;
le point, lui, manque dans presque tous les fichiers importés (le champ `GEO` est rarement
rempli) et le lieu suffit à qui connaît le spot. Choisir un lieu déjà utilisé pré-remplit le
dernier point connu pour ce lieu, ce qui rend le point quasi gratuit à la deuxième fois. À
l'import, les événements sans lieu reçoivent un lieu saisi une fois dans l'aperçu.

**Q151 ☑ — Planning : qui peut modifier et supprimer un événement ?**
Réponse PO (2026-09-25) : oui (voir Q150). Le cas du responsable désigné est précisé en Q161.
Suggestion : son créateur, son responsable, le responsable local de l'association et le
super_admin. Le responsable désigné porte l'événement et doit pouvoir le corriger ; le
responsable local fait le ménage (doublon, événement annulé). Ouvrir à tout membre exposerait
le planning à une suppression par erreur, sans historique pour la rattraper.

**Q152 ☑ — Planning : que reprend un clone ?**
Réponse PO (2026-09-25) : oui, avec le libellé préfixé « Clone - ».
Suggestion : tous les champs, avec la date décalée d'une semaine (même jour, même heure), dans
un formulaire à valider ; les réponses ne sont pas copiées. Le cas courant est une sortie
hebdomadaire reprogrammée ; la date reste modifiable avant d'enregistrer.

**Q153 ☑ — Planning : quels fichiers importer ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : Android (Google Agenda), iPhone et Mac (Calendrier Apple) et Outlook échangent leurs
agendas au format iCalendar, fichier `.ics`. Aucune de leurs applications mobiles n'exporte un
agenda entier : l'export se fait depuis calendar.google.com (un `.zip` contenant un `.ics` par
agenda), depuis Calendrier sur Mac (Fichier > Exporter) ou depuis Outlook sur ordinateur. Un
`.ics` reçu par mail ou messagerie s'enregistre en revanche sur le téléphone. L'ancien format
vCalendar (`.vcs`) n'est plus produit par ces applications.
Suggestion : `.ics` et `.zip` d'export Google (lu sans le décompresser à la main), rien
d'autre. L'abonnement par adresse (webcal) est écarté : les serveurs de Google et d'Apple
n'autorisent pas une page web à lire ces adresses, il faudrait un relais côté serveur.
Retour PO (2026-09-25) : « je ne sais pas, quelle pratique recommandes-tu ? »
Recommandation, en pratique : tenir l'agenda de l'association dans Google Agenda (le plus
répandu, gratuit, lisible sur Android comme sur iPhone), et l'importer dans NUNI depuis un
ordinateur : calendar.google.com > Paramètres > Importer et exporter > Exporter, puis dans NUNI
Planning > Importer un agenda, choisir le `.zip` téléchargé. Pour un agenda Apple : Calendrier
sur Mac > Fichier > Exporter, puis le `.ics` produit. Pour un seul événement reçu par mail ou
messagerie : enregistrer le `.ics` sur le téléphone puis le choisir dans NUNI. NUNI accepte donc
`.ics` et `.zip`, rien d'autre : ce sont les deux seuls fichiers que ces applications
produisent. Valider cette recommandation ?

**Q154 ☑ — Planning : import des événements répétés et des fuseaux horaires ?**
Réponse PO (2026-09-25) : pas de notion de répétition dans NUNI, chaque événement est un événement indépendant. Conséquence pour l'import d'un fichier qui contient une répétition : Q167.
Constat : un agenda d'association contient souvent une sortie répétée (« tous les jeudis »),
stockée comme un seul événement avec une règle de répétition. Les heures y sont écrites en temps
universel ou avec un fuseau horaire nommé (Europe/Paris).
Suggestion : développer chaque répétition en événements séparés sur les 12 prochains mois, en
tenant compte des dates exclues ; chacun devient un événement normal, que l'on peut modifier ou
supprimer seul, avec ses propres réponses. Au-delà de 12 mois, ré-importer le fichier plus tard.
Les fuseaux horaires sont convertis exactement (paquet `timezone`), pour qu'un événement créé à
19 h à Paris s'affiche à 19 h.
Retour PO (2026-09-25) : « je ne comprends pas ». Reformulation : dans Google Agenda, une
sortie « tous les jeudis » n'est pas enregistrée comme 52 événements, mais comme un seul
événement accompagné de la règle « se répète chaque jeudi, sans fin ». NUNI, lui, a besoin d'un
événement par date (chacun a ses réponses et ses commentaires). À l'import, NUNI doit donc
fabriquer les dates une par une, et il faut une limite puisque la règle peut être sans fin.
Suggestion : créer les dates des 12 prochains mois (les jeudis supprimés dans Google, par
exemple pendant les vacances, sont sautés). Au-delà, un nouvel import prolonge le planning. Les
fuseaux horaires ne demandent pas de décision : les heures sont toujours affichées justes.
Limite de 12 mois : convient-elle ?

**Q155 ☑ — Planning : ré-importer le même agenda crée-t-il des doublons ?**
Réponse PO (2026-09-25) : suggestion non retenue. Un import écrase tout, avec avertissement :
chaque événement est marqué « importé » ou « manuel » selon sa création, et seuls les
événements « importés » sont effacés avant le nouvel import ; ceux créés par les membres sont
conservés. Précision sur les importés passés : Q163.
Suggestion : non. Chaque événement d'un fichier `.ics` porte un identifiant stable ; ré-importer
met à jour l'événement déjà importé (date, libellé, lieu, description) en gardant ses réponses,
et l'aperçu signale « nouveau » ou « mis à jour ». Un événement retiré de l'agenda d'origine
n'est pas supprimé dans NUNI (il peut déjà avoir des réponses) : le responsable le supprime à
la main. Un événement modifié dans NUNI puis ré-importé reprend les valeurs du fichier.

**Q156 ☑ — Planning : où placer le point d'entrée du planning ?**
Réponse PO (2026-09-25) : oui pour le moment, à revoir après essai visuel ; l'onglet
n'apparaît pas pour un joueur sans association.
Suggestion : un cinquième onglet « Planning » (icône calendrier) dans la barre du bas, en plus
du lien depuis la carte « Prochain événement » de l'accueil. Consulter le planning est un geste
fréquent, qui mérite un accès direct ; cinq onglets restent dans les recommandations Material
(3 à 5). Le ranger dans l'onglet Associations le cacherait derrière la page de toutes les
associations, pensée pour autre chose.

**Q157 ☑ — Planning : quelles règles pour les réponses ?**
Réponse PO (2026-09-25) : oui.
Suggestion : chacun répond pour lui-même seulement, modifie sa réponse jusqu'à l'heure de
début, et voit la liste nominative des réponses de tous les membres (présents, peut-être,
absents) avec le nombre de membres sans réponse. Seuls les membres de l'association de
l'événement peuvent répondre. Le responsable ne répond pas à la place d'un autre : cela
brouillerait qui s'est vraiment engagé.

**Q158 ☑ — Planning : jusqu'à quand un événement est-il « le prochain » sur l'accueil ?**
Réponse PO (2026-09-25) : oui.
Suggestion : jusqu'à la fin de sa journée. Un événement n'a pas d'heure de fin ; le garder
toute la journée laisse le lieu et la liste des présents sous la main pendant la sortie. La
carte montre libellé, date, heure, lieu, mes trois boutons de réponse et le nombre de présents ;
elle disparaît s'il n'y a aucun événement à venir.

**Q159 ☑ — Planning : les événements passés restent-ils consultables ?**
Réponse PO (2026-09-25) : pas de sélecteur, les passés restent visibles dans le planning
global, cela suffit. Lecture de cette réponse : Q162.
Suggestion : oui, par un sélecteur « À venir / Passés » en haut du planning, « À venir » par
défaut ; les passés s'affichent du plus récent au plus ancien, avec les mêmes séparateurs. Ils
gardent leurs réponses (qui était là) et servent de modèle à cloner.

**Q160 ☑ — Planning : un événement est-il relié à une session ?**
Réponse PO (2026-09-25) : événement et session restent séparés, parce qu'un événement peut
concerner la vie de l'association sans jeu (repas de Noël, assemblée générale). Mais le lien
est à faire dans ce plan : un bouton « Démarrer la session » sur l'événement du jour crée la
session avec les inscrits, toujours complétable comme n'importe quelle session (ajouter ou
retirer des joueurs, inviter…) ; ce n'est qu'un raccourci. Détails : Q164.
Constat : l'ancienne fiche du plan 23 prévoyait de démarrer une session depuis l'événement,
avec les inscrits pré-sélectionnés ; le besoin du 2026-09-25 ne le demande pas.
Suggestion : non dans ce plan : événements et sessions restent indépendants. Le lien (bouton
« Démarrer la session » qui pré-sélectionne les présents) s'ajoute ensuite sans rien changer au
modèle, une fois le planning utilisé et le besoin confirmé.

Réponses du PO du 2026-09-25 (Q147 à Q160, Q102) et besoins ajoutés le même jour : vue
détaillée plein écran de chaque événement (toutes les informations, carte bien visible) et fil
de commentaires basique (auteur, date, texte libre avec liens web et mail reconnus, pas de
sélecteur d'emoji, pas de réponse ni de mention, fil linéaire), nombre de commentaires en
pastille sur l'accueil et le planning. Questions qui en découlent :

**Q161 ☑ — Planning : le responsable désigné d'un événement peut-il le modifier ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : la suggestion de Q151, acceptée, incluait le responsable désigné ; la réponse à Q150
cite seulement le créateur, le responsable local et le super_admin.
Suggestion : oui, il peut le modifier et le supprimer. Il porte l'événement (c'est souvent lui
qui fixe le lieu au dernier moment, Q150) ; sans ce droit, il dépendrait du créateur pour
corriger l'heure ou le lieu. Tant que la question est ouverte, le plan 23 applique cette
suggestion.

**Q162 ☑ — Planning : comment se présente la liste une fois les passés inclus ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : Q159 retire le sélecteur « À venir / Passés » ; les passés sont donc dans la même
liste que les événements à venir.
Suggestion : une seule liste dans l'ordre des dates, du plus ancien au plus récent, qui s'ouvre
positionnée sur le prochain événement ; on remonte pour voir les passés, on descend pour
l'avenir. Les événements passés sont légèrement estompés. S'ouvrir en haut d'une liste qui
commence par des mois d'événements passés obligerait à défiler à chaque visite. Tant que la
question est ouverte, le plan 23 applique cette suggestion.

**Q163 ☑ — Planning : un ré-import efface-t-il aussi les événements importés déjà passés ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : Q155 fait effacer les événements importés avant chaque nouvel import. L'import
ignore les événements passés du fichier (ils ne servent plus à s'inscrire) : un événement
importé passé effacé ne reviendrait donc jamais, avec ses réponses et ses commentaires.
Suggestion : n'effacer que les événements importés à venir ; les passés restent, comme
souvenir de qui était là. L'avertissement affiche le nombre d'événements à venir effacés et de
réponses et commentaires perdus. Tant que la question est ouverte, le plan 23 applique cette
suggestion.

**Q164 ☑ — Planning : règles du bouton « Démarrer la session » ?**
Retour PO (2026-09-25) : le bouton n'apparaît que pour le super_admin, le responsable local et le responsable de l'événement. Autres points de la suggestion (seuls les « présent » pré-sélectionnés, plusieurs sessions possibles depuis un même événement, affichées sur l'événement) retenus par le PO le même jour.
Suggestion :
- visible sur tout événement du jour (le planning ne distingue pas un repas d'une sortie de
  jeu ; un bouton inutile un soir de repas ne gêne pas), par tout membre de l'association,
  comme aujourd'hui tout joueur peut créer une session ; celui qui appuie en devient
  l'organisateur ;
- joueurs pré-sélectionnés : ceux qui ont répondu « présent » seulement ; les « peut-être »
  s'ajoutent en un geste s'ils sont là ;
- zone de la session pré-remplie avec le lieu de l'événement ;
- plusieurs sessions peuvent être démarrées depuis le même événement (deux groupes le même
  soir) ; la session garde le lien vers son événement, et l'événement affiche les sessions
  démarrées depuis lui, ce qui évite qu'un deuxième membre en démarre une en double sans le
  savoir.
Tant que la question est ouverte, le plan 23 applique cette suggestion.

**Q165 ☑ — Planning : les libellés « Clone - … » rejoignent-ils la liste des libellés ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : la liste des libellés est faite de ceux déjà utilisés (Q147). Un clone enregistré sans
retoucher son libellé y ajouterait « Clone - Session du jeudi », puis « Clone - Clone - … ».
Suggestion : ne pas proposer les libellés qui commencent par « Clone - ». La liste reste propre
sans écran de gestion ; le libellé du clone reste bien sûr celui enregistré. Tant que la
question est ouverte, le plan 23 applique cette suggestion.

**Q166 ☑ — Planning : règles des commentaires ?**
Réponse PO (2026-09-25) : l'auteur peut modifier et supprimer son commentaire ; mise à jour en direct si possible techniquement (à l'approche d'un événement, les gens surveilleront peut-être les commentaires) ; d'accord pour le reste (tout membre commente, avant comme après ; responsable local et super_admin peuvent aussi supprimer ; 2 000 caractères ; pas de « non lu »). Faisabilité vérifiée dans le dépôt : les sessions en direct utilisent déjà un abonnement Supabase filtré par session (`realtime.sql`) ; les commentaires suivent le même modèle, filtré par événement.
Suggestion :
- tout membre de l'association de l'événement commente, avant comme après l'événement ;
- un commentaire ne se modifie pas ; il se supprime par son auteur, le responsable local ou le
  super_admin (modération), après confirmation ;
- 2 000 caractères au plus ;
- pas de temps réel : le fil se recharge à l'ouverture, après chaque envoi et en tirant vers le
  bas. Un fil de commentaires n'est pas une messagerie instantanée ; le temps réel ajouterait un
  abonnement par événement ouvert pour un gain faible ;
- la pastille compte tous les commentaires, sans notion de « non lu » (qui demanderait de
  mémoriser ce que chacun a lu).
Tant que la question est ouverte, le plan 23 applique cette suggestion.

**Q167 ☑ — Planning : que devient, à l'import, un événement répété du fichier ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : NUNI n'a pas de notion de répétition (Q154). Mais un fichier exporté de Google Agenda
ou d'Apple contient les sorties régulières sous la forme d'un seul événement accompagné d'une
règle (« chaque jeudi »). L'import doit donc en faire quelque chose.
Suggestion : créer un événement indépendant par date, sur les 12 prochains mois, sans aucun
lien entre eux ; les dates supprimées dans l'agenda d'origine sont sautées. Une fois importés,
ce sont des événements comme les autres (modifiables et supprimables un par un, chacun avec ses
réponses et ses commentaires) : NUNI ne garde aucune trace de la répétition. Le ré-import
suivant prolonge le planning. L'autre voie, n'importer que la prochaine date, ferait perdre
silencieusement toutes les sorties régulières de l'agenda, qui sont le cas le plus courant
d'une association. Tant que la question est ouverte, le plan 23 applique cette suggestion.

**Q168 ☑ — Planning : que contient le message d'un événement partagé ?**
Réponse PO (2026-09-25) : suggestion retenue.
Révision PO (2026-09-25), après essai sur Chrome ordinateur (fenêtre de partage de Windows) : un partage simple, le bouton copie le lien seul, partout ; plus de feuille de partage ni de libellé, date et lieu autour du lien.
Demande PO (2026-09-25) : pouvoir partager un événement (par exemple dans WhatsApp), le lien
menant directement à sa vue détaillée, après connexion si nécessaire.
Constat : NUNI est une application d'une seule page ; WhatsApp, pour un lien, affiche un aperçu
lu dans la page d'accueil du site, donc le même pour tous les événements (« NUNI – Never Up,
Never In »). Un aperçu propre à chaque événement demanderait une page générée côté serveur pour
chaque lien. Par ailleurs, un compte d'une autre association n'a pas le droit de lire
l'événement.
Suggestion : le message partagé contient, avant le lien, le libellé, la date, l'heure et le
lieu (« Session du jeudi – jeudi 2 octobre, 19 h 00 – Parc de la Tête d'Or »), rédigés dans la
langue de celui qui partage : le groupe voit l'essentiel sans ouvrir le lien. Un compte d'une
autre association qui ouvre le lien voit « Cet événement appartient à une autre association »,
jamais le contenu. Tant que la question est ouverte, le plan 23 applique cette suggestion.

Décision du PO (2026-09-25), pendant l'essai de l'implémentation : un import vise toujours
l'association de celui qui importe, jamais une autre, même pour un super_admin (le choix de
l'association est retiré de l'écran ; la base le refuse aussi par un appel direct).

Décision du PO (2026-09-25), après essai sur l'app installée Android : un lien partagé ouvert
sans être connecté doit mener à l'événement après la connexion, dans l'app installée comme dans
Chrome (téléphone et ordinateur). Le lien est gardé pendant la connexion dans le stockage commun
du site (et non plus de l'onglet), valable 5 minutes.

**Q169 ☑ — Planning : importer l'agenda depuis un lien public ?**
Réponse PO (2026-09-25) : abandonné, l'import par fichier suffit (38 événements LSG importés et affichés correctement par le PO le même jour).
Constat du PO (2026-09-25) : l'agenda de LSG à importer est un lien public, pas un fichier.
Vérifié le même jour : le serveur de Google renvoie bien un agenda public au format iCalendar,
mais sans l'autorisation qui permet à une page web d'une autre adresse de le lire (en-tête
`Access-Control-Allow-Origin` absent) ; le navigateur du téléphone refuse donc de le lire
directement. Il faut qu'un serveur aille le chercher pour l'app.
Suggestion :
- c'est la base qui va chercher l'agenda (extension `http` de Postgres, proposée par Supabase),
  dans une fonction réservée au responsable local et au super_admin, pour leur propre
  association, qui ne lit que des adresses `https` (ou `webcal`, converties) ; le texte revient
  à l'app, lu comme un fichier aujourd'hui (même aperçu, mêmes règles, même avertissement).
  Aucun nouveau service à déployer, tout reste dans les fichiers de migration. L'autre voie, une
  « Edge Function » Supabase, ajouterait une étape de déploiement à part ;
- le lien est mémorisé sur l'association : un bouton « Mettre à jour depuis le lien » refait
  l'import en un geste (mêmes règles de remplacement) ; pas de mise à jour automatique
  périodique, qui demanderait une tâche planifiée pour un gain faible ;
- liens acceptés : l'« adresse publique au format iCal » de Google Agenda (`.../basic.ics`), un
  lien de partage ou d'intégration Google (`calendar.google.com/calendar/embed?src=...` ou
  `.../u/0?cid=...`, dont l'adresse iCal se déduit), un lien `webcal://` (Calendrier Apple) ;
- l'import par fichier reste possible.
Tant que la question est ouverte, rien n'est codé.

## Administrateurs locaux et partenaires d'association (plan 27, 2026-09-25)

Demande du PO du 2026-09-25 : le responsable local (ou un super_admin) nomme un ou plusieurs
administrateurs parmi les membres, avec les droits du responsable sauf la modification des
informations de l'association ; les informations de l'association listent des partenaires
(libellé libre + lien). Les questions ci-dessous portent sur ce que la demande ne fixe pas.

**Q170 ☑ — Administrateurs : un administrateur peut-il renoncer lui-même à son rôle ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : la demande fixe qui nomme (responsable local, super_admin), pas qui peut mettre fin
au rôle.
Suggestion : oui, bouton « Ne plus être administrateur » sur la page de l'association. Un rôle
qu'on ne peut pas quitter oblige à passer par le responsable pour un simple désistement ; le
renoncement ne donne aucun droit nouveau, donc aucun risque. Tant que la question est ouverte,
le plan 27 applique cette suggestion.

**Q171 ☑ — Administrateurs : que se passe-t-il quand un administrateur quitte l'association ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : un responsable local ne peut pas quitter l'association qu'il gère (Q146) ; rien n'est
fixé pour un administrateur.
Suggestion : il peut la quitter, et perd alors automatiquement le rôle (la base le retire,
quelle que soit la façon dont il part ou change d'association). L'interdiction de Q146 existe
parce qu'une association sans responsable n'a plus personne pour modifier ses informations ;
un administrateur n'a pas ce rôle, rien ne justifie de le retenir. Tant que la question est
ouverte, le plan 27 applique cette suggestion.

**Q172 ☑ — Administrateurs : restent-ils en place quand le responsable local est retiré ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : un super_admin peut retirer le responsable local (Q78), ce qui rouvre la revendication
du rôle.
Suggestion : oui, les administrateurs gardent leurs droits ; en l'absence de responsable, seul
le super_admin peut en nommer ou en retirer, et le nouveau responsable, une fois validé, les
gère. Les retirer tous d'un coup laisserait l'association sans personne pour le championnat et
le planning pendant la vacance, précisément au moment où c'est le plus utile. Tant que la
question est ouverte, le plan 27 applique cette suggestion.

**Q173 ☑ — Administrateurs : un nombre maximal par association ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : pas de limite. Le responsable choisit ses administrateurs parmi ses membres et en
répond ; une limite ne protège de rien et gênerait une grande association. Tant que la question
est ouverte, le plan 27 applique cette suggestion.

**Q174 ☑ — Administrateurs : qui voit la liste des administrateurs ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : le nom du responsable local est visible de tout compte connecté sur la page de
l'association.
Suggestion : pareil pour les administrateurs (nom et photo, sans coordonnées) : les membres
savent à qui s'adresser pour une session à marquer « championnat » ou un événement à corriger.
Le plan 27 applique cette suggestion.

**Q175 ☑ — Partenaires : titre de la section, et le lien est-il obligatoire ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : la demande parle de « sponsors ou collaborateurs », avec un libellé libre et un lien.
Suggestion : une seule liste intitulée « Partenaires » (« Partners »), sans distinguer sponsor
et collaborateur : le libellé libre peut le préciser (« Boulangerie Dupont — sponsor ») sans
ajouter de champ. Lien **facultatif** : un partenaire sans site (commerçant local, mairie) peut
figurer quand même ; son libellé s'affiche alors sans lien. Tant que la question est ouverte, le
plan 27 applique cette suggestion.

**Q176 ☑ — Partenaires : ordre d'affichage et nombre maximal ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : l'ordre est choisi par le responsable (glisser pour réordonner dans le
formulaire, composant standard de Flutter), car un sponsor principal se met en tête ; au plus
20 partenaires, pour que la page reste lisible et qu'une erreur de saisie ne la remplisse pas.
Le plan 27 applique cette suggestion.

**Q177 ☑ — Administrateurs locaux : quel nom à l'écran, alors qu'« administrateur » désigne déjà le super_admin ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat (implémentation du plan 27, 2026-09-25) : l'app appelle déjà « administrateur » le
super_admin, dans une dizaine de textes : « Un administrateur valide la demande », « Message
pour l'administrateur », et surtout la confidentialité : « votre e-mail, votre téléphone et
votre message, visibles seulement de vous et des administrateurs ». Un administrateur local ne
voit pas ces coordonnées : garder le même mot rendrait ces phrases fausses aux yeux des membres.
Suggestion : le nouveau rôle s'appelle partout « administrateur local » (« local admin »),
jamais « administrateur » seul, et les textes existants gardent « administrateur » pour le
super_admin. C'est le terme de la demande du PO, et le mot « local » le rattache au
« responsable local », dont il partage les droits. L'autre voie, renommer le super_admin
« l'équipe NUNI » dans les textes existants, lèverait toute ambiguïté mais changerait des
textes déjà validés. Le plan 27 applique la suggestion.

## Référentiel de spots (plan 28, 2026-09-25)

Demande du PO du 2026-09-25 : un référentiel de spots par association (libellé, description,
point et adresse synchronisés), géré par le responsable local et les administrateurs locaux ;
choix libre ou dans le référentiel pour un événement, obligatoire dans le référentiel pour une
session, avec création rapide « + » à la position courante. Remplace Q148 pour les lieux. Réponses du PO du 2026-09-25 : toutes les suggestions retenues.

**Q178 ☑ — Spots : quel service pour passer d'une adresse à un point et inversement ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : l'app n'utilise que BigDataCloud, qui donne la ville d'un point mais ni l'adresse
complète ni la recherche d'adresse.
Suggestion : Photon (komoot), fondé sur OpenStreetMap comme les cartes de l'app : gratuit, sans
clé, appelable depuis le navigateur, dans les deux sens, et il accepte la recherche au fil de la
frappe. Nominatim (le service officiel d'OpenStreetMap) interdit justement cette recherche au
fil de la frappe ; Google et Mapbox exigent une clé et un compte de facturation. BigDataCloud
reste pour la ville à la création de session tant qu'il sert ailleurs. Le plan 28 applique
cette suggestion.

**Q179 ☑ — Spots : l'adresse peut-elle être tapée librement, sans correspondre à un point ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : non. L'adresse ne s'écrit que par la recherche (on tape, on choisit une
proposition, le point suit) ou par le point (on le pose, l'adresse suit). Une adresse tapée à la
main sans être retrouvée ne peut pas placer le point : les deux divergeraient, ce que la demande
exclut. Si le lieu n'a pas d'adresse (un parc), on pose le point et l'adresse proposée est la
plus proche ; la description sert aux précisions (« entrée côté fontaine »). Le plan 28 applique
cette suggestion.

**Q180 ☑ — Spots : qui peut créer un spot par le « + » de la création de session, et qui voit l'écran « Spots » ?**
Réponse PO (2026-09-25) : suggestion retenue. Complément PO du même jour, après essai : l'écran « Spots » est visible de tout compte connecté, y compris hors de l'association (lecture seule), et sa tuile passe au-dessus des partenaires sur la page de l'association.
Constat : tout membre d'une association peut créer une session ; le « + » doit donc lui être
ouvert, sinon un membre ordinaire serait bloqué sur un spot absent.
Suggestion : le « + » est ouvert à tout membre (nom et point seulement) ; modifier, compléter et
supprimer restent réservés au responsable local, aux administrateurs locaux et au super_admin.
L'écran « Spots » (liste et carte) est visible de tous les membres en lecture, pour qu'ils
trouvent où l'on joue ; les boutons d'édition n'apparaissent qu'aux responsables. Le plan 28
applique cette suggestion.

**Q181 ☑ — Spots : un spot peut-il exister sans point sur la carte ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : non pour un spot créé dans l'app : à défaut de position (géolocalisation refusée),
le « + » affiche la carte pour poser le point. Seuls les spots repris de l'existant sans point
connu (Q185) en sont dépourvus, signalés « à compléter » dans l'écran « Spots ». Un référentiel
dont chaque spot est placé permet de proposer d'abord les spots les plus proches à la création
de session. Le plan 28 applique cette suggestion.

**Q182 ☑ — Spots : que deviennent les sessions et événements d'un spot supprimé ou renommé ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : chaque session ou événement garde un lien vers le spot **et** une copie de son nom.
Tant que le spot existe, on affiche son nom actuel (un renommage se voit partout) ; s'il est
supprimé, le lien tombe et la copie reste affichée : l'historique ne perd jamais son lieu, et
la suppression n'est jamais bloquée. Interdire la suppression d'un spot utilisé obligerait à
garder des spots fermés dans la liste. Le plan 28 applique cette suggestion.

**Q183 ☑ — Spots : deux spots de la même association peuvent-ils porter le même nom ?**
Réponse PO (2026-09-25) : suggestion retenue.
Suggestion : non, sans tenir compte des majuscules : « Parc Borély » et « parc borély » seraient
indiscernables dans la liste de la création de session, et le « + » propose le spot existant au
lieu d'en créer un doublon. Deux associations peuvent avoir chacune leur « Vieux-Port ». Le plan
28 applique cette suggestion.

**Q184 ☑ — Spots : la ville d'une session devient-elle celle de son spot ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : la création de session détecte aujourd'hui la ville par la position (Q11), dans un
champ modifiable ; la ville sert au filtre de l'historique et à l'affichage.
Suggestion : oui. La ville est tirée de l'adresse du spot et copiée dans la session ; le champ
ville disparaît du formulaire. Un champ de moins, et la ville ne peut plus contredire le spot
(créateur qui prépare la session depuis chez lui). Le plan 28 applique cette suggestion.

**Q185 ☑ — Spots : faut-il pré-remplir le référentiel avec les lieux déjà saisis ?**
Réponse PO (2026-09-25) : suggestion retenue. Liste relue le même jour : les 7 lieux sont des
spots de jeu ; « INSA » et « Campus de la Doua » ne font qu'un (« INSA », adresse du campus),
« Hôpital de la Croix-Rousse » devient « Croix-Rousse » et « DOCKS 40 » devient « Confluence »
(leur ancien texte devient leur adresse), « Tee Time » et « Auditorium » restent tels quels,
« Surprise » est un spot générique sans emplacement. Appliqué par `supabase/spots_backfill.sql`.
Constat : les événements ont des lieux en texte libre (souvent avec un point) et les sessions,
importées de LsgScores comprises, des zones en texte libre.
Suggestion : oui, une fois, au passage du plan 28 : un spot par nom distinct et par association
(sans tenir compte des majuscules), point repris du dernier événement ou de la dernière session
qui en a un, puis sessions et événements rattachés. Le PO relit la liste avant la reconstruction
et peut en retirer ; les responsables fusionnent ensuite les variantes en renommant. Partir
d'un référentiel vide obligerait à tout ressaisir et laisserait l'historique sans lien. Le plan
28 applique cette suggestion.

**Q186 ☑ — Spots : comment gérer un spot « générique » (« Surprise ») dont l'emplacement change à chaque fois ?**
Réponse PO (2026-09-25) : suggestion retenue ; couvre aussi l'événement programmé des semaines à l'avance dont le lieu n'est révélé que la veille (modification de l'événement : point posé sur sa carte, ou spot choisi).
Constat : le PO a besoin d'un nom réutilisable (« Surprise ») dont l'emplacement diffère d'une
session ou d'un événement à l'autre. Le plan 28 tel que codé le permet déjà en partie : un spot
sans point laisse à chaque événement son propre point (posé sur la carte du formulaire) et à
chaque session le sien (la position de son créateur). Trois manques : la création d'un tel spot
dans l'app est impossible (point obligatoire, Q181), l'écran « Spots » l'affiche « À compléter »,
et une session sur ce spot n'aurait pas de ville (elle vient du spot, Q184).
Suggestion : une case « Emplacement variable » dans le formulaire de spot (responsables
seulement). Cochée, le spot n'a ni point ni adresse, n'est jamais « À compléter » ; chaque
événement garde le point posé sur sa carte, chaque session la position de son créateur (ou le
point de l'événement dont elle est démarrée), et sa ville est détectée depuis cette position
comme avant le plan 28 (Q11). Un simple drapeau sur la table, sans nouvelle table. L'autre voie,
créer un spot par occurrence (« Surprise 12/10 »), encombrerait la liste et casserait le
regroupement par nom dans les statistiques à venir.

## Natures de session (plan 29, 2026-09-25)

Demande du PO du 2026-09-25 : enregistrer toute activité de l'association comme une session
(parcours, entraînement, simulateur, repas, AG…), avec des pastilles cumulables qui décident de
l'écran, des statistiques et de nouveaux badges. Idée de départ du PO : des tags libres,
éventuellement hiérarchiques ; remplacée, avec son accord, par deux axes (scores oui/non et tags
de contexte), présentés comme une seule rangée de pastilles.

**Q187 ☑ — Natures de session : comment qualifier une session ?**
Réponse PO (2026-09-25) : deux axes présentés comme une seule rangée de pastilles d'aspect
identique. « Parcours » (la session a une carte de score) est coché par défaut à la création,
parce que c'est la nature la plus programmée ; le décocher masque le scoring. Toute session
porte au moins une pastille de nature. L'organisation technique est laissée à l'assistant.
Constat : `scoring_mode` et `kind` sont obligatoires, une session sans scores est impossible ;
« individuel / équipe » existe déjà (`kind`), le championnat aussi (`is_championship`).
Suggestion retenue : pas de tags libres ni de hiérarchie (vocabulaire fixe, nécessaire aux
badges et aux stats) ; Parcours = présence d'un mode de scoring ; tags de contexte cumulables
dans une énumération Postgres, sans table de référence.

**Q188 ☑ — Natures de session : lesquelles comptent dans les statistiques et les records ?**
Réponse PO (2026-09-25) : une session Training ou Simulateur, même avec des scores, ne compte
ni dans les stats ni dans les records ; elle reste dans l'historique et compte pour les badges
de la famille L. Une session Parcours taguée Vie de l'asso (tournoi de Noël) compte.

**Q189 ☑ — Natures de session : sur quels trous se joue une session Simulateur ?**
Réponse PO (2026-09-25) : uniquement des trous libres (plan 17) quand on saisit des scores.
Une séance au simulateur sans scores est taguée Simulateur et Training : une session conteneur
avec compte rendu, photos et export.

**Q190 ☑ — Natures de session : le seuil de 3 joueurs vaut-il pour les nouveaux badges ?**
Réponse PO (2026-09-25) : oui, au moins 3 présents pour tout badge, quelle que soit la nature.

**Q191 ☑ — Natures de session : qui pose les tags ?**
Réponse PO (2026-09-25) : l'organisateur, le responsable local, les administrateurs locaux et
le `super_admin`, comme les autres droits.

**Q192 ☑ — Natures de session : quels tags de contexte ?**
Réponse PO (2026-09-25) : Training, Simulateur, Vie de l'association (ajouté pour les repas,
AG et autres moments sans jeu). Aucun autre pour l'instant.

**Q193 ☑ — Natures de session : le choix avec ou sans scores peut-il changer ?**
Réponse PO (2026-09-25) : non, il est figé dès la création. Les tags pouvant être ajoutés ou
retirés après coup restent à préciser (Q197).

**Q194 ☑ — Natures de session : comment se remplissent les présents d'une session sans scores ?**
Réponse PO (2026-09-25) : comme les joueurs d'aujourd'hui. L'organisateur ou un administrateur
peut tout saisir seul, à la main, sans partager de QR code, comme un carnet de bord ; le code
et le QR restent possibles.

**Q195 ☑ — Natures de session : quel lieu pour une session sans scores ?**
Réponse PO (2026-09-25) : suggestion retenue. Un spot ou un lieu libre, comme un événement du
planning ; le lieu libre passe par la recherche d'adresse, qui donne le point de la météo. Une
session avec Parcours garde le spot obligatoire (plan 28).

**Q196 ☑ — Natures de session : quels nouveaux badges ?**
Réponse PO (2026-09-25) : premier training, 5 trainings, 10 trainings ; première session Vie
de l'asso, 5 sessions Vie de l'asso (pas 10, trop sur une année) ; un combo « une session de
parcours, une de training et une de vie de l'asso ». L'assistant peut en suggérer d'autres
(Q199, Q200). Noms et icônes proposés dans le plan 29.

**Q197 ☑ — Natures de session : quelles pastilles restent modifiables après coup, et lesquelles sont figées ?**
Réponse PO (2026-09-25) : suggestion retenue. Exemple du PO : les lundis au simulateur seront
tagués Training, Simulateur et Vie de l'asso, sans scores. Effet d'un retag Training sur un
parcours terminé, vérifié dans le code : les stats et badges sont recalculés au prochain
affichage ; un badge perdu disparaît sans annonce (`badge_announcer.dart` n'annonce que les
gains) ; s'il revient, il n'est pas réannoncé sur l'appareil qui l'avait déjà montré
(`SeenBadgesStore`), mais l'est sur un autre appareil ; le record et le roi du trou étant
rejoués (`HoleReplay`), un autre joueur peut gagner ce que le premier perd. Aucune donnée
perdue : retirer le tag rétablit tout.
Reformulation PO (2026-09-25) : la vraie question n'est pas « jusqu'à quand », mais de séparer
les pastilles sans risque à modifier, même longtemps après, de celles qui ne doivent plus bouger.
Constat : rien de ce qui dépend des pastilles n'est stocké (stats, records et badges sont
recalculés à chaque affichage) : une modification ne casse aucune donnée, elle change ce que
voient les joueurs. Le mode de scoring et le format (individuel / équipe) ne sont déjà plus
modifiables après la création aujourd'hui (`session_edit_sheet.dart` : date, heures,
commentaire). Le risque est donc de deux ordres : structure (les trous et scores saisis ne
correspondraient plus à la pastille) ou effet silencieux sur les stats, records et badges de
tous les présents.
Suggestion, trois catégories :
- **Figées dès la création** : Parcours (Q193) ; Individuel / Équipe (déjà le cas) ; Simulateur
  sur une session avec Parcours, qui décide des trous proposés (Q189) : l'ajouter après coup
  laisserait des trous du référentiel dans une session Simulateur, le retirer ferait compter
  dans les stats une partie jouée sur écran.
- **Libres à tout moment** (organisateur et staff) : Vie de l'asso, sur toute session ; Training
  et Simulateur sur une session sans Parcours. Leur seul effet est sur les badges L, recalculés
  à l'affichage ; aucune statistique ni aucun record ne bouge.
- **Sensibles** : Training sur une session avec Parcours, qui fait entrer ou sortir la session
  des stats, records, roi du trou et badges A à K de tous les joueurs. L'organisateur jusqu'à la
  fin de la session, puis le responsable local, les administrateurs locaux et le `super_admin`
  à tout moment, comme le marquage championnat (plan 26), qui reste inchangé.
Le plan 29 applique cette suggestion.

**Q198 ☑ — Natures de session : les badges existants (A à K) comptent-ils les sessions Training, Simulateur ou sans scores ?**
Réponse PO (2026-09-25) : suggestion retenue.
Constat : les familles A (sessions jouées), B (régularité) et I (conditions de jeu)
pourraient compter n'importe quelle session ; les autres parlent de coups, de victoires, de
trous ou de records et n'ont de sens que pour une session de jeu.
Suggestion : non, les 90 badges existants ne lisent que les sessions de jeu éligibles, et la
famille L couvre le reste. Sinon, dix trainings donneraient « Pilier » sans un seul trou joué,
et les badges déjà obtenus changeraient de sens. Un seul critère pour A à K, le même que celui
des stats, reste simple à expliquer. Le plan 29 applique cette suggestion.

**Q199 ☑ — Natures de session : un badge « première session Simulateur » ?**
Réponse PO (2026-09-25) : suggestion retenue, « Joueur virtuel ».
Constat : la demande initiale du PO citait « première session de simulateur » ; le catalogue
de Q196 ne l'a pas repris.
Suggestion : oui, un seul badge (L7 « Joueur virtuel »), sans palier : les séances au
simulateur seront rares, un palier à 5 ne serait presque jamais atteint. Le plan 29 applique
cette suggestion.

**Q200 ☑ — Natures de session : un badge pour l'organisateur des trainings ?**
Réponse PO (2026-09-25) : oui, en trois paliers : 1er, 5e et 10e training organisé (créé et
terminé, au moins 3 présents).
Constat : la famille H récompense déjà l'organisation de sessions (H4, H5), mais seulement des
sessions de jeu (Q198).
Suggestion : oui, L8 « Coach » : 5 sessions Training créées et terminées, chacune avec au moins
3 présents. Il valorise ceux qui animent les entraînements, un rôle que les badges de jeu ne
voient pas. Le plan 29 applique cette suggestion.

## Photos : plantage iPhone et miniatures (plan 30, 2026-09-26)

Constat du PO (vidéo du 2026-09-26) : sur iPhone, l'onglet Safari de NUNI plante en faisant
défiler la liste des trous, puis affiche « Un problème récurrent est survenu ». Cause : chaque
vignette de 48 px était décodée à la pleine taille de la photo (jusqu'à 1600 px pour une photo
envoyée depuis l'app, sans limite pour une photo importée de LsgScores, copiée telle quelle par
`tool/migrate_lsgscores.dart`), et iOS ferme un onglet qui dépasse sa mémoire. Corrigé le
2026-09-26 sans question (défaut) : toute image réseau est décodée à sa taille d'affichage
(`lib/shared/display_sized_image.dart`). Reste le téléchargement, qui est toujours celui de la
photo entière.

**Q201 ☑ — Photos : créer une miniature à l'envoi pour ne plus télécharger la photo entière dans les listes ?**
Réponse PO (2026-09-26) : suggestion retenue.
Constat : la liste des trous télécharge deux photos entières par trou (souvent plusieurs
centaines de Ko, davantage pour les photos importées) pour afficher 48 px ; même chose pour la
couverture d'une session dans l'historique (64 px) et la galerie de photos (84 px). Sur le
terrain, en données mobiles, la liste est lente à remplir et consomme du forfait.
Suggestion : oui. À l'envoi, l'app produit en plus une miniature de 256 px (le même
redimensionnement qu'aujourd'hui, `resizeForUpload`), rangée à côté de la photo sous un nom
dérivé (`<chemin>.thumb.jpg`) : aucune colonne ni migration, et une photo sans miniature
s'affiche comme aujourd'hui. Les photos déjà en ligne reçoivent leur miniature par un script
lancé une fois (`tool/`, même principe que l'import LsgScores). Alternative écartée : les
transformations d'images de Supabase, qui fabriquent la miniature à la demande, mais sont
réservées aux formules payantes et facturées au volume. Le plan 30 applique cette suggestion.

**Q202 ☑ — Photos : réduire à 1600 px les photos importées de LsgScores ?**
Réponse PO (2026-09-26) : suggestion retenue.
Constat : les photos envoyées depuis NUNI sont plafonnées à 1600 px ; celles importées de
LsgScores sont restées à leur taille d'origine (photo d'appareil, souvent 4000 px et plusieurs
Mo). Elles ralentissent la fiche trou, qui les affiche en grand.
Suggestion : oui, dans le même script que Q201 : chaque photo de plus de 1600 px est
réencodée à 1600 px au même emplacement. La perte n'est pas visible à l'écran d'un téléphone,
et le téléchargement de la fiche trou est divisé par cinq à dix. Le plan 30 applique cette
suggestion.

**Q203 ☑ — Photos : quelle image s'affiche quand on touche une photo, et les photos de la fiche trou s'agrandissent-elles ?**
Réponse PO (2026-09-26) : toute image qu'on touche pour l'agrandir s'affiche en version
d'origine, jamais réduite ; les photos de départ et d'arrivée de la fiche trou s'ouvrent en
plein écran avec zoom, comme la galerie de session.
Constat : seule la visionneuse de la galerie de session agrandissait une photo ; les photos de
la fiche trou ne réagissaient pas au toucher.
Suggestion retenue : réutiliser la visionneuse de la galerie, pour que le zoom sur le départ ou
l'arrivée aide à repérer l'emplacement exact sur le terrain. Le plan 30 applique cette décision.
