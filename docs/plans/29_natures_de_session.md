# Plan 29 — Natures de session : parcours, training, simulateur, vie de l'association

## Statut

Plan rédigé le 2026-09-25 à partir de la demande du PO du même jour et de trois échanges de
cadrage. Décisions du PO : Q187 à Q200, toutes tranchées. Les points marqués (H) sont des
choix de mise en œuvre de l'assistant. **Plan validé entièrement par le PO le 2026-09-25**,
choix (H) compris ; rien n'est implémenté.

## Objectif

Enregistrer dans NUNI **toute activité de l'association qui a vraiment eu lieu**, pas seulement
les parcours avec scores : entraînements, séances au simulateur, repas de Noël, AG… Chaque
session a une trace (présents, compte rendu, photos, export) qui forme l'histoire de
l'association. Le planning prévoit, la session garde la trace de ce qui s'est passé (séparation
du plan 23 inchangée).

Une session porte des **pastilles de nature**, cumulables. Elles décident :
1. de l'écran : carte de score et classement, ou seulement présents, compte rendu et photos ;
2. de ce qui compte dans les statistiques et les records ;
3. de nouveaux badges (famille L).

## Existant (pour mémoire)

- `sessions.scoring_mode`, `kind` (individuel / équipe) et `ranking_direction` sont
  obligatoires : une session sans scores est impossible aujourd'hui.
- `sessions.is_championship` est déjà une pastille de fait, posée par le staff
  (`set_session_championship`).
- Les stats, records et badges ne lisent que les sessions éligibles : terminées, au moins
  3 joueurs et 3 trous joués (`lib/features/stats/domain/eligible_session.dart`, Q117, Q123).
  Les sessions en équipe comptent déjà dans une partie des stats (sessions jouées, victoires,
  fiche trou) ; seuls les coups par joueur sont réservés à l'individuel (Q90).
- Une session exige un spot du référentiel (plan 28).
- La date de début d'une session terminée se corrige déjà après coup, et la météo est alors
  relue dans les archives d'Open-Meteo (`session_edit_sheet.dart`) : un compte rendu saisi le
  lendemain aura la bonne date et la bonne météo.

## Décisions retenues

### Deux axes, une seule rangée de pastilles

Pour l'utilisateur, une seule rangée de pastilles d'aspect identique (Q187). Techniquement, deux
axes indépendants :

| Pastille | Signification | Stockage | Modifiable |
|---|---|---|---|
| **Parcours** | la session a une carte de score | `scoring_mode` non nul | jamais, figée à la création (Q193) |
| Individuel / Équipe | format du parcours, affichée seulement avec Parcours | `kind` (existant) | jamais (déjà le cas) |
| **Training** | entraînement | `tags` contient `training` | libre sans Parcours ; sensible avec Parcours (Q197) |
| **Simulateur** | séance au simulateur | `tags` contient `simulator` | libre sans Parcours ; figée avec Parcours (Q197) |
| **Vie de l'asso** | repas, AG, sortie… | `tags` contient `association_life` | libre (Q197) |
| Championnat | compte pour le championnat | `is_championship` (existant) | staff (plan 26) |

- **Création** : Parcours est coché par défaut (Q187). Décocher Parcours masque le mode de
  scoring, le format et le sens du classement. Toute session porte au moins une pastille de
  nature : Parcours, ou au moins un tag (Q187).
- **Tags** : énumération Postgres `session_tag` (`training`, `simulator`, `association_life`),
  colonne `sessions.tags session_tag[]`, sans table de référence (règle d'`AGENTS.md`). Aucune
  autre valeur pour l'instant (Q192) ; en ajouter une coûte une ligne d'énumération et deux
  chaînes.
- **Championnat** : réservé à une session avec Parcours, sans Training ni Simulateur.
  Contrainte en base, la case est grisée à l'écran sinon.
- **Qui pose les tags** (Q191) : l'organisateur, le responsable local, les administrateurs
  locaux (`is_association_staff`) et le `super_admin`.
- **Modification après coup** (Q197) : rien de ce qui dépend des pastilles n'est stocké, une
  modification ne casse aucune donnée ; elle change ce que voient les joueurs. Trois catégories :
  - *figées* : Parcours, Individuel / Équipe, Simulateur avec Parcours (il décide des trous) ;
  - *libres à tout moment* (organisateur et staff) : Vie de l'asso ; Training et Simulateur sans
    Parcours (effet limité aux badges L) ;
  - *sensibles* : Training avec Parcours (fait entrer ou sortir la session des stats, records et
    badges A à K) : l'organisateur jusqu'à la fin de la session, le staff et le `super_admin` à
    tout moment. Un badge perdu ainsi disparaît sans annonce ; un record ou un titre de roi du
    trou peut passer à un autre joueur ; retirer le tag rétablit tout.

Exemples :

| Situation | Pastilles |
|---|---|
| Parcours classique | Parcours · Individuel |
| Entraînement avec quelques trous comptés | Parcours · Individuel · Training |
| Entraînement sans scores | Training |
| Simulateur sans scores | Simulateur · Training (Q189) |
| Simulateur avec scores | Parcours · Individuel · Simulateur |
| Repas de Noël, AG | Vie de l'asso |
| Tournoi de Noël | Parcours · Équipe · Vie de l'asso |

### Statistiques et records

Une session compte pour les statistiques (plans 19 et 20), les records et le roi du trou si
elle est **éligible** (règle inchangée) **et** une **session de jeu** : Parcours, sans Training
ni Simulateur (Q188). Un tournoi tagué « Vie de l'asso » compte donc. Définition écrite une fois
dans `eligible_session.dart` (`isGameSession`), lue par les stats, `HoleReplay` et les badges
A à K.

### Simulateur

Avec Parcours, une session Simulateur ne propose que des trous libres (plan 17) : le sélecteur
de trous du référentiel est masqué (Q189). Sans Parcours, c'est une session « conteneur » :
présents, compte rendu, photos, export.

### Session sans Parcours

- **Présents** (Q194) : même mécanique que les joueurs d'aujourd'hui. L'organisateur les ajoute
  à la main, sans avoir à partager de QR code ; le code et le QR restent possibles ; une session
  démarrée depuis un événement reprend ses « présents ». L'organisateur est pré-inscrit parmi
  eux et peut se retirer (H). Techniquement, les présents sont les joueurs d'une **équipe
  unique** (`teams` / `team_players` existants) : ajout, retrait, code, temps réel,
  `player_history` et droits de lecture (`can_read_session`) fonctionnent sans nouvelle table.
  L'autre voie, une table `session_attendees`, dupliquerait tout cela pour le même résultat.
- **Lieu** (Q195) : un spot du référentiel **ou** un lieu libre, comme un événement du
  planning. Le lieu libre passe par la recherche d'adresse (Photon, plan 28), qui donne le point
  nécessaire à la météo et la ville. Une session avec Parcours garde le spot obligatoire.
- **Compte rendu** : le champ commentaire existant (`sessions.comment`), présenté comme
  « Compte rendu » en texte long, modifiable par l'organisateur et le staff. Il reste visible
  sur toutes les sessions.
- **Cycle de vie** : brouillon, en cours, terminée, comme aujourd'hui (la date, la saison et la
  météo en dépendent). Pour le carnet de bord saisi après coup, « Terminer » est permis
  directement depuis le brouillon ; la date se corrige ensuite comme aujourd'hui (H).
- **Écran** : pastilles, lieu, date et météo, présents, compte rendu, photos. Ni trous, ni
  scores, ni classement.
- **Export** : l'export image garde la photo et les mentions habituelles (association, date,
  heure, lieu, météo), sans tableau des scores. L'export PDF, qui est une carte de score, n'est
  pas proposé (H).

### Historique et accueil

- Chaque carte de session affiche ses pastilles (`NuniChip` ou `NuniStatusPill`, un seul style
  défini dans `app_theme.dart`).
- L'historique gagne un filtre par pastille (Parcours, Training, Simulateur, Vie de l'asso,
  Championnat), à côté de « Mes sessions » et de la ville.
- Les sessions existantes, importées de LsgScores comprises, deviennent « Parcours » sans tag,
  sans action de reprise.

### Badges : famille L « Vie du club »

Les badges L comptent les **sessions d'activité** : terminées, avec **au moins 3 présents**
(Q190), quelles que soient leurs pastilles. Un parcours compte comme Parcours s'il est une
session de jeu (définition ci-dessus). Les 90 badges existants (A à K) ne lisent que les
sessions de jeu éligibles (Q198).

| # | Nom (proposé) | Condition | Icône Phosphor (proposée) |
|---|---|---|---|
| L1 | Échauffement | 1re session Training | `barbell` (bronze) |
| L2 | Studieux | 5 sessions Training | `barbell` (argent) |
| L3 | Forçat | 10 sessions Training | `barbell` (or) |
| L4 | De la fête | 1re session Vie de l'asso | `confetti` (bronze) |
| L5 | Âme du club | 5 sessions Vie de l'asso | `confetti` (argent) |
| L6 | Touche-à-tout | Au moins une session de jeu, une Training et une Vie de l'asso | `puzzle-piece` |
| L7 | Joueur virtuel | 1re session Simulateur (Q199) | `monitor-play` |
| L8 | Moniteur | 1re session Training organisée (Q200) | `chalkboard-teacher` (bronze) |
| L9 | Coach | 5 sessions Training organisées (Q200) | `chalkboard-teacher` (argent) |
| L10 | Entraîneur en chef | 10 sessions Training organisées (Q200) | `chalkboard-teacher` (or) |

Catalogue décidé par le PO (Q196, Q199, Q200) ; noms et icônes proposés, modifiables. « Organisée »
= créée par le joueur et terminée, avec au moins 3 présents. Une session
Training + Simulateur compte pour L1 à L3 et pour L7. Les points de code des icônes ne sont pas
vérifiés : ce conteneur n'a pas accès au site de Phosphor. Ils seront relevés à
l'implémentation, et une icône absente sera remplacée par une voisine, sous le contrôle du PO.

## Données et calcul

- `supabase/migrations` (règle 8, fichiers thématiques existants modifiés) :
  - `extensions_and_enums.sql` : type `session_tag`.
  - `tables.sql` : `sessions.tags session_tag[] not null default '{}'` ; `scoring_mode`,
    `kind` et `ranking_direction` nullables, tous nuls ou tous renseignés ; au moins une nature
    (`scoring_mode` non nul ou `tags` non vide) ; championnat seulement pour une session de jeu.
  - `rpc.sql` : `create_session` accepte `tags` et l'absence de scoring ; il exige un spot
    seulement avec Parcours, accepte sinon un lieu libre, et pré-inscrit l'organisateur dans
    l'équipe unique. Nouvelle RPC `set_session_tags` (droits Q191, catégories Q197), qui refuse
    de toucher aux pastilles figées. `set_session_championship` refuse une session qui n'est pas de jeu.
    `join_session` place directement un joueur qui rejoint une session sans Parcours dans
    l'équipe unique.
  - `triggers.sql` : `sessions_copy_spot` accepte l'absence de spot sans Parcours.
  - `rls_smoke.sql` : tests des droits sur les tags et des contraintes.
- Dart :
  - `SessionTag` (énumération, miroir de Postgres) ; `Session.tags` ; `scoringMode`, `kind` et
    `rankingDirection` nullables ; `Session.hasScoring`.
  - `eligible_session.dart` : `isGameSession`, `isActivitySession` (terminée, au moins
    3 présents).
  - `BadgeFacts` : sessions de jeu éligibles (existant) et sessions d'activité (nouveau) ;
    règle `rules/club_life.dart`.
  - Écrans : création (rangée de pastilles), salle et détail sans Parcours, historique
    (pastilles, filtre), export image.
- Seeds : `export_remote_seed.dart` et les seeds étendus à `tags` ; régénérés et commités avec
  l'accord du PO avant la reconstruction.

## Étapes

1. Schéma, RPC, triggers, `rls_smoke.sql`.
2. Domaine Dart (`SessionTag`, nullabilité, `isGameSession`, `isActivitySession`) et tests
   unitaires ; tous les appelants de `scoringMode` et `kind` relus.
3. Création de session : pastilles, Parcours figé, lieu libre sans Parcours, trous libres
   seuls pour Simulateur.
4. Salle et détail d'une session sans Parcours : présents, compte rendu, « Terminer » depuis le
   brouillon.
5. Historique et accueil : pastilles et filtre ; modification des tags (Q197).
6. Export image sans tableau des scores ; PDF masqué sans Parcours.
7. Stats, records et badges A à K limités aux sessions de jeu ; famille L.
8. Seeds régénérés et commités avec l'accord du PO, puis base reconstruite (règle 8, PO
   prévenu avant).
9. Chaînes EN/FR, `flutter analyze`, tests, essai dans le navigateur intégré ; `AGENTS.md` mis
   à jour (définition des sessions de jeu et d'activité, tags).

## Critères d'acceptation

- Une nouvelle session a Parcours coché par défaut ; le décocher masque tout le scoring ;
  impossible d'enregistrer une session sans aucune pastille de nature.
- Parcours, le format et Simulateur avec Parcours ne changent plus après la création ; Vie de
  l'asso se modifie à tout moment ; Training avec Parcours seulement par le staff une fois la
  session terminée.
- Une session Training seule s'enregistre avec présents, compte rendu et photos, sans QR code
  partagé, et s'exporte en image sans tableau des scores.
- Une session Vie de l'asso accepte un lieu libre, avec météo.
- Une session Simulateur avec Parcours ne propose que des trous libres.
- Une session Training ou Simulateur, avec ou sans scores, n'apparaît dans aucune statistique,
  aucun record, aucun roi du trou, aucun badge A à K ; un tournoi Vie de l'asso avec Parcours y
  apparaît.
- Une session Training ou Simulateur ne peut pas être marquée championnat.
- L'historique affiche les pastilles de chaque session et filtre par pastille.
- Les badges L1 à L10 s'obtiennent à partir de 3 présents, pas avant.
- Les sessions existantes s'affichent « Parcours » et leurs stats et badges sont inchangés.

## Hors périmètre

- Pastilles pré-cochées selon le libellé de l'événement du planning (un « Training » du
  planning qui donnerait une session Training) : à voir à l'usage.
- Statistiques propres aux trainings (nombre de trainings sur le profil…).
- Autres valeurs de tag (Q192).
