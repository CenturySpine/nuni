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
