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
