# Inventaire des fonctionnalités — app Android LsgScores (référence)

Version analysée : 1.1.0 (versionCode 10), branche `master`.
Périmètre : uniquement l'application Android (Kotlin / Jetpack Compose). Le dossier `web-guest` est
hors périmètre (palliatif historique).

---

## 1. Authentification et compte

- Connexion Google via Supabase Auth (OAuth, deep link `lsgscores://auth-callback`).
- Bouton Facebook présent mais désactivé ("coming soon").
- Porte d'authentification (`AuthGate`) : loader pendant la restauration de session, état "sticky"
  pour éviter le flash de l'écran de login au retour en avant-plan, débounce de 2 s sur les états
  non authentifiés transitoires.
- Création automatique de la ligne `app_user` (email, display name, avatar, provider) à chaque
  connexion.
- Onboarding premier lancement : dialogue non fermable de sélection de ville, avec possibilité de
  créer une nouvelle ville (avec confirmation). Crée ensuite le joueur lié à l'utilisateur
  (nom = display name Google ou email) et la ligne `user_player_link`.
- Lien utilisateur ↔ joueur : un utilisateur = un joueur "moi".
- Déconnexion.
- Suppression de compte : purge stricte et ordonnée de toutes les données de l'utilisateur
  (scores des sessions → played_holes → teams → sessions → lien → joueur → trous → zones →
  app_user), avec vérification post-suppression, puis déconnexion et fermeture de l'app.
- Lien vers la politique de confidentialité (hébergée sur Supabase Storage).

## 2. Contrôle de version au démarrage

- Avant tout affichage, lecture de la table `app_versions` (ligne `is_current = true`).
- Si la version distante diffère de la version installée : dialogue bloquant "Mise à jour requise"
  avec lien Play Store, puis fermeture de l'app.
- Si la version ne peut pas être lue : dialogue d'erreur puis fermeture.
- Affichage de la version installée en bas du tiroir latéral.

## 3. Navigation et structure

- Barre du bas : Accueil, Nouvelle session, Session en cours, Profil (avatar du joueur lié).
  - "Nouvelle session" désactivé si une session est en cours pour la ville.
  - "Session en cours" désactivé s'il n'y en a pas.
  - "Profil" désactivé tant qu'aucun joueur n'est lié.
- Tiroir latéral : Zones (Areas), Joueurs, Trous, Historique des sessions, Paramètres.
- Garde "ville sélectionnée" : accès aux écrans du tiroir et à la création de session refusé avec
  une alerte tant qu'aucune ville n'est sélectionnée.
- Titre de la barre supérieure adapté à chaque écran.

## 4. Accueil

- Logo LSG, message de bienvenue, nom de la ville de l'utilisateur.
- Bouton "Rejoindre une session" (scan QR).

## 5. Villes et zones de jeu (écran "Areas")

- Liste des villes (lecture seule dans l'UI ; ajout/édition existent dans le code mais boutons
  commentés).
- Liste des zones de jeu de la ville courante.
- Édition et suppression d'une zone, réservées au propriétaire (créateur).
- Suppression bloquée si la zone est référencée par des trous ou des sessions (dialogues d'erreur
  dédiés).
- Ajout de zone : logique et dialogue présents dans le code, bouton "+" commenté (non accessible
  dans l'UI actuelle).
- Sélection de ville persistée en préférences ; tous les flux (joueurs, trous, zones, sessions)
  sont filtrés par la ville sélectionnée.

## 6. Joueurs

- Liste des joueurs de la ville (triée par nom, photo ou icône par défaut).
- Fiche joueur : photo ronde, nom, ville.
- Navigation par balayage horizontal entre fiches (mode lecture), avec animation de transition.
- Édition (nom, photo) réservée au joueur lié à l'utilisateur connecté.
- Photo : caméra ou galerie, recadrage (Android Image Cropper), sauvegarde locale puis upload
  Supabase Storage (bucket joueurs), suppression de l'ancienne photo distante.
- Pas d'écran de création de joueur : le seul joueur créé est celui de l'onboarding.
- Suppression de joueur : chaînes et dialogues présents, mais aucun bouton dans l'UI actuelle.

## 7. Trous

- Liste des trous de la ville (nom + miniatures départ/arrivée).
- Suppression depuis la liste (propriétaire uniquement) avec confirmation.
- Création : nom (obligatoire), zone de jeu (obligatoire), description, distance (m), par
  (défaut 3), photo de départ et photo de cible (caméra ou galerie + recadrage).
- Fiche trou : lecture (photos, description, distance, par), balayage horizontal entre trous,
  édition et suppression réservées au propriétaire.
- Upload parallèle des deux photos vers Supabase Storage (bucket trous), suppression des
  anciennes photos lors d'un changement ou d'une suppression.

## 8. Création d'une session (admin)

- Étape 1 : date/heure (non éditable = maintenant), type de session (Individuel / Équipe), zone de
  jeu (liste déroulante, pré-sélection "Unknown Zone" ou première zone), mode de scoring (grille
  radio avec bouton info et description localisée).
- Brouillon de session conservé par ville.
- Étape 2 : composition des équipes.
  - Mode manuel : chips joueurs, 1 joueur par équipe en Individuel, 1 ou 2 en Équipe, un joueur ne
    peut appartenir qu'à une équipe, suppression d'une équipe créée libère ses joueurs.
  - Mode aléatoire (Équipe seulement) : sélectionner un nombre pair ≥ 4 de joueurs, tirage
    aléatoire par paires (icône dé), message d'erreur si nombre impair.
- Démarrage : refus si une session est déjà en cours pour la ville (toast).
- Capture météo au démarrage (Open‑Meteo forecast, via localisation GPS) stockée dans la session.
- Insertion session + équipes, navigation vers l'écran de session en cours.

## 9. Session en cours

- Bandeau de bienvenue : avatars et prénoms des joueurs de l'équipe de l'utilisateur.
- Bandeau d'en-tête : date, mode de scoring (cliquable → dialogue de description), bouton QR
  (admin seulement).
- Classement en carte repliable : replié = leader + score ; déplié = tableau complet (position
  avec badges or/argent/bronze, équipe, coups, score). Colonne "coups" masquée en Stroke Play.
- Mention "Classement provisoire : des scores manquants" si une équipe n'a pas de score sur un
  trou.
- Ajout d'un trou joué (admin) : dialogue avec choix du trou (liste), choix du mode de jeu
  (Individuel seul en session individuelle ; Scramble / Greensome / Best Ball en équipe, avec
  info), bouton "Créer un nouveau trou" (redirige vers le formulaire trou). Pas de navigation
  automatique vers la saisie après ajout.
- Liste des trous joués (du plus récent au plus ancien), le dernier joué est mis en évidence
  (bordure verte). Chaque carte affiche toutes les équipes, en rouge celles sans score, avec
  "coups - score" (ou score seul en Stroke Play).
- Clic sur une carte → écran de saisie des scores.
- Suppression d'un trou joué (admin) avec confirmation.
- Boutons collants (admin) : Annuler (supprime la session et toutes ses données, confirmation) et
  Valider (clôture la session, `endDateTime = now`, redirection vers l'historique).
- Participant : lecture seule sur la structure, saisie limitée à sa propre équipe, messages
  adaptés au rôle quand il n'y a pas de trou.
- Participant : détection en temps réel de la fin de session (validée ou supprimée) → toast,
  réinitialisation du mode participant, retour à l'accueil. Confirmation différée (1,2 s) pour
  distinguer suppression réelle et émission nulle transitoire, y compris au retour en avant-plan.

## 10. Saisie des scores d'un trou joué

- Une ligne par équipe, chips compactes 0–9 et "X" (= 10 coups), sélection unique avec
  désélection possible.
- Score calculé en direct selon le mode de scoring, affiché à côté.
- Pré-remplissage avec les scores déjà enregistrés.
- Participant : ne voit et ne saisit que son équipe.
- Admin : voit sa propre équipe ; les autres équipes sont masquées par défaut avec boutons
  Afficher/Masquer pour les révéler et les saisir. Sauvegarde partielle autorisée.
- Sauvegarde par upsert (conflit `playedholeid, teamid` → dernier écrit gagne).

## 11. Modes de scoring et de jeu

- Modes de scoring lus depuis la table `scoring_modes` (noms/descriptions localisés côté app) :
  1. Stroke Play (total des coups, le plus bas gagne).
  2. Match Play (1 point au meilleur unique du trou, sinon 0).
  3. Redistribution (2 pts solo 1er + 1 pt solo 2e ; 1 pt chacun si deux ex æquo 1ers + 1 pt solo
     2e ; ≥ 3 ex æquo 1ers : 0).
  - Un 4e calculateur "3 au leader solo / 2 aux leaders ex æquo" existe dans le code (id 3 dans la
    factory) mais l'ordre factory ≠ seed SQL : factory 3 = FirstThreeElseTwo, 4 = TwoOne, alors que
    la seed nomme l'id 3 "Redistribution" (règle TwoOne). Point à vérifier lors d'un portage.
- Tri du classement : Stroke Play par coups croissants ; modes à points par score décroissant
  puis coups croissants.
- Modes de jeu par trou (liste en dur) : Individual, Scramble, Greensome, Best Ball, avec
  descriptions localisées.
- Tests unitaires JUnit sur les quatre calculateurs.

## 12. Rejoindre une session (participant)

- Écran QR côté admin : QR code ZXing du payload `LSGSESSION:<id>`, payload affiché en clair.
- Scanner côté participant : CameraX + ML Kit, demande de permission caméra, repli "Analyser une
  photo" depuis la galerie.
- Après scan : vérification que la session existe et est en cours.
- Auto-join : si le joueur lié à l'utilisateur figure dans une équipe de la session, entrée
  directe en mode participant sans choix.
- Sinon : choix manuel de l'équipe (radio) puis "Rejoindre".
- Mode participant persisté en préférences (mode, id session, id équipe) ; la ville sélectionnée
  est forcée sur celle de la session.

## 13. Historique des sessions

- Liste des sessions terminées de la ville, triées par date décroissante.
- Carte : date + heure, zone de jeu, mode de scoring, durée, météo (icône, température, vent).
- Clic → détail de session passée.
- Actions réservées au propriétaire : menu Partager (export image avec photo caméra, export image
  avec photo galerie, export PDF), Éditer, Supprimer (cascade, confirmation).
- Édition date/heures : date (DatePicker, pas de futur), heure de début, heure de fin optionnelle
  (effaçable), validations (pas de futur, fin après début). Recalcul de la météo historique
  (Open‑Meteo archive) pour la nouvelle date.
- État vide avec message.

## 14. Détail d'une session passée (lecture seule)

- Même bandeau que la session en cours, sans QR.
- Carte info : zone + heure de début, durée, météo.
- Galerie photos de session (bucket Supabase `sessions/<id>/`) : image principale avec flèches
  précédent/suivant, vignettes cliquables.
- Propriétaire : ajout de plusieurs photos depuis la galerie, marquage d'une photo favorite
  (renommage `fav_` dans le storage, une seule favorite), suppression d'une photo avec
  confirmation. La favorite est affichée par défaut.
- Classement repliable et liste des trous joués (sans clic ni suppression, sans surbrillance du
  dernier).

## 15. Exports et partage

- PDF A4 (PdfDocument natif) : zone, date, heures, type, mode de scoring, météo, commentaire,
  tableau équipes × trous (nom de trou + mode de jeu en en-tête, score et coups par cellule,
  total), position, pied de page. Coups masqués en Stroke Play. Partage via FileProvider.
- Image : superposition sur une photo (caméra ou galerie) de la zone, date, météo, classement
  (position, équipe, score et coups), pied de page ; sauvegarde dans `Pictures/LsgScores` via
  MediaStore puis partage.
- Chaînes pour un export Markdown présentes, mais aucune implémentation.

## 16. Météo et localisation

- Open‑Meteo (sans clé) : météo courante à la création de session, météo historique horaire lors
  de l'édition de la date. Mapping code météo → description + icône.
- Localisation via FusedLocationProvider (permission ACCESS_FINE_LOCATION demandée au besoin).
  Échec silencieux : la session est créée sans météo.

## 17. Temps réel et synchronisation

- Flux Supabase Realtime (`selectAsFlow`) sur `sessions` et `played_hole_scores` ; les scores,
  classements et cartes de trous se mettent à jour en direct chez tous les participants.
- Compteur de rafraîchissement forcé après chaque mutation (start, validate, delete, add hole,
  save score).
- Écran de debug Realtime (route non câblée, code commenté dans Settings) : logs des événements
  sessions / played_holes / played_hole_scores.

## 18. Paramètres

- Thème : Default (Material You dynamique sur Android 12+), LSG Brand, Ocean, Sunset ; chacun en
  clair/sombre, aperçu couleurs.
- Langue : système, anglais, français (recréation de l'activité). Toutes les chaînes UI sont
  localisées EN/FR (quelques libellés du flux "rejoindre" restent en français en dur).
- Section Légal : politique de confidentialité.
- Section Compte : déconnexion, suppression de compte.

## 19. Images et stockage

- Composant `RemoteImage` (Coil) : signature automatique des URLs Supabase Storage (7 jours),
  clé de cache stable indépendante du token signé, placeholder/erreur.
- Trois buckets : joueurs, trous, sessions (noms configurables via `local.properties`).
- Photos caméra sauvegardées aussi dans la galerie de l'appareil (`Pictures/LsgScores`).

## 20. Backend Supabase (contrat de données)

- Tables : `app_user`, `app_roles`, `app_versions`, `cities`, `game_zones`, `holes`, `players`,
  `user_player_link`, `scoring_modes`, `sessions`, `teams`, `played_holes`,
  `played_hole_scores`.
- RLS : lecture pour tout utilisateur authentifié ; écriture réservée au propriétaire
  (`user_id = auth.uid()`) sauf `played_hole_scores` (écriture ouverte à tout authentifié, pour
  la saisie collaborative) et `cities` (insert/update ouverts).
- Contrainte d'unicité `(playedholeid, teamid)` sur les scores.
- Politiques Storage : lecture publique, upload authentifié, modification/suppression par le
  propriétaire.

## 21. Plateforme et distribution

- minSdk 29, targetSdk 35, compileSdk 36.
- Hilt (DI), Navigation Compose, Kotlinx Serialization, Retrofit/Gson (météo), Ktor (Supabase).
- Signature release via propriétés `RELEASE_*` ou variables d'environnement.
- CI GitHub Actions : `assembleDebug` sur push master et sur PR.
- Publication Play Store (privacy policy, page de suppression de compte dans `app/src/doc`).

---

## Points à noter pour un portage (Flutter / PWA)

- Rôle admin = propriétaire de la session (`user_id`), rôle participant = mode local persisté.
- Fonctions présentes dans le code mais non exposées dans l'UI : ajout de ville, édition de
  ville, ajout de zone de jeu, suppression de joueur, écran de debug Realtime, export Markdown,
  commentaire de session (champ en base et en PDF, jamais saisi).
- Incohérence factory / seed sur les ids de modes de scoring (voir § 11).
- Vestiges Room (`AppDatabase`, `Migrations`, converters) : la persistance est en réalité 100 %
  Supabase.
