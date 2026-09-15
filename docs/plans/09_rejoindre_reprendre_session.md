# Plan 09 — Rejoindre et reprendre une session

## Objectif

Permettre à un joueur de rejoindre une session depuis son téléphone en quelques secondes (lien,
QR, code court), d'être automatiquement rattaché à son équipe quand elle existe, et de retrouver
ses sessions en direct depuis n'importe quel appareil.

## Prérequis

Plans 05, 07, 08.

## Règles métier (PO, 2026-09-15, Q15)

Vocabulaire : l'**organisateur** est le créateur de la session (et tout co-organisateur) ; un
**joueur** est une fiche `players`, liée à un utilisateur (`user_id`) quand la personne s'est
connectée au moins une fois et a fait son onboarding (plan 05) ; le **pool** de la session est
l'ensemble des membres qui ont rejoint sans être encore dans une équipe.

- **Cas 1, équipes préparées à l'avance.** L'organisateur crée la session et compose au moins une
  équipe avec des joueurs existants (plan 07). Quand un utilisateur rejoint, si son joueur lié
  figure dans une équipe, il n'a rien à faire : il est membre, rattaché à cette équipe, et pourra
  saisir les scores de son équipe (Q8).
- **Cas 2, aucune équipe.** La session existe sans équipe : n'importe qui peut la rejoindre et
  entre dans le pool. L'organisateur compose les équipes depuis le pool (manuellement ou par
  tirage aléatoire, plan 07) quand il estime que tout le monde est là, puis démarre.
- **Cas 3, équipes existantes et joueur absent.** Si au moins une équipe existe et que le joueur
  lié de l'utilisateur n'est dans aucune, rejoindre est **refusé**, avec le message : demander à
  l'organisateur de l'ajouter dans une équipe (ou de réorganiser les équipes). Ce cas couvre
  l'arrivée dans une session déjà configurée ou démarrée.
- Jusqu'au démarrage, l'organisateur peut retirer des membres du pool, retirer des joueurs des
  équipes et supprimer des équipes. Après le démarrage, les équipes sont figées.
- Une session peut démarrer sans que tous les utilisateurs aient rejoint : certains n'utilisent
  pas l'app ; l'organisateur ou un coéquipier saisit les scores pour eux (Q8). Un joueur dont
  l'équipe existe peut rejoindre après le démarrage (cas 1) ; il retrouve alors la saisie.
- Plus de choix d'équipe par le joueur, plus de mode spectateur.
- Session **individuelle** (PO, 2026-09-15) : aucune équipe n'existe avant le démarrage (elles sont
  créées par "Démarrer", une par participant) ; jusque-là tout le monde peut rejoindre (cas 2) ;
  après, le cas 3 s'applique à qui n'est pas participant. Le cas 1 en individuel = l'organisateur
  a ajouté la personne comme participant à l'avance (H Q26).
- Q24 (PO 2026-09-15) : pas de joueur sans compte ; toute personne se connecte au moins une fois,
  ce qui crée sa fiche joueur ; l'organisateur compose ensuite avec ces fiches, que la personne
  se reconnecte ou non.
- Q25 (PO 2026-09-15) : au démarrage, un membre du pool non affecté à une équipe bloque le
  démarrage avec un message qui le nomme ; l'organisateur l'affecte ou le retire.

## Décisions retenues

- Identifiant de partage : `sessions.code` (6 caractères sans ambiguïté, sans 0/O/1/I), généré en
  base. Lien : `https://nuni.centuryspine.org/join/CODE`.
- Écran "Inviter" (depuis la session, en préparation ou en direct) : code en grand, bouton
  "Copier le lien", bouton "Partager" (API Web Share via `share_plus`, repli copie), QR code
  généré localement avec `qr_flutter` encodant le lien.
- Q14 (PO 2026-09-15) : pas de scanner intégré ; l'appareil photo natif lit le QR et ouvre la
  PWA. L'accueil propose "Rejoindre avec un code" pour la saisie manuelle.
- Route `/join/:code` :
  1. non connecté : mémoriser le code (localStorage), aller au login (la première connexion crée
     profil et joueur, plan 05), revenir sur `/join/:code` ;
  2. appel de la RPC `join_session(code)` qui applique les trois cas : session introuvable ou
     terminée → message et retour à l'accueil ; cas 3 → message "demande à l'organisateur de
     t'ajouter" et retour à l'accueil ; cas 1 → membre rattaché à son équipe ; cas 2 → membre
     dans le pool ;
  3. navigation vers `/session/:id` : salle d'attente si la session est en préparation (plan 07),
     écran en direct sinon (plan 08). Rejoindre une session déjà rejointe est sans effet.
- Reprise : l'accueil liste "Mes sessions en cours" (`session_members` join `sessions.status in
  (draft, live)`), avec rôle, état et date, et "Reprendre". Aucun état de participation dans le
  stockage local : l'appartenance est en base, donc valable sur tous les appareils.
- Départ volontaire : "Quitter la session" retire le membre tant que la session n'est pas
  démarrée ; après, seul l'organisateur retire un membre (les coups saisis restent).
- L'organisateur voit la liste des membres (pool et équipes) et peut retirer quelqu'un ou le
  nommer co-organisateur.

## Étapes

1. Paquets : `qr_flutter`, `share_plus`.
2. `features/join/` : page `/join/:code` (les trois étapes ci-dessus, messages des refus), écran
   "Inviter", saisie manuelle de code.
3. Accueil : sections "Mes sessions en cours", "Créer", "Rejoindre", "Dernières sessions".
4. Tests : parcours join dans les trois cas (mocks de la RPC), génération du lien, validation du
   code saisi.

## Livrables

- Invitation, adhésion selon les trois cas, reprise, gestion des membres.

## Critères d'acceptation

- Cas 1 : un téléphone jamais connecté scanne le QR, se connecte avec Google et arrive sur la
  session rattaché à la bonne équipe, sans autre action (son joueur ayant été créé par une
  connexion antérieure et placé par l'organisateur).
- Cas 2 : trois téléphones rejoignent une session sans équipe ; l'organisateur les voit arriver
  dans le pool en temps réel, compose les équipes et démarre ; chacun voit l'écran en direct.
- Cas 3 : un utilisateur absent des équipes est refusé avec le message attendu ; après ajout par
  l'organisateur, le même lien le fait entrer.
- Fermer l'onglet puis rouvrir l'app sur un autre appareil retrouve la session en cours.

## Questions PO liées

Q14, Q15, Q24, Q25 (tranchées).
