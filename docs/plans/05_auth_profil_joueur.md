# Plan 05 — Authentification, profil, joueur lié

## Objectif

Connexion Google via Supabase dans une PWA, création automatique du joueur lié (qui porte aussi
les réglages de compte), sans onboarding ni référentiel de ville, édition du profil, déconnexion.

La suppression de compte est retirée de ce plan (décision PO, 2026-09-16) : sujet à part entière,
avec ses propres impacts à examiner (sessions et scores d'autrui référençant mon joueur, données
déjà partagées, etc.), traité dans [14_suppression_compte.md](14_suppression_compte.md).

## Prérequis

Plans 03 et 04.

## Décisions retenues

- Auth Google via Supabase conservée. Sur le web, `signInWithOAuth(OAuthProvider.google)` en flux
  de redirection (pas de popup : les popups sont bloquées dans les PWA installées sur iOS). Le
  retour se fait sur l'URL courante ; `supabase_flutter` gère le fragment de session et la
  persistance (localStorage) et le rafraîchissement automatique du jeton.
  Il n'existe pas d'option "meilleure" garantie : Google Identity Services (One Tap) donnerait un
  bouton natif plus élégant mais ajoute une configuration et un échange de jeton supplémentaires,
  sans gain fonctionnel. Recommandation ferme : garder Supabase OAuth.
- Le joueur lié (`players`, `user_id = auth.uid()`) créé par trigger à l'inscription, avec le nom
  d'affichage et l'avatar Google (Q24, PO 2026-09-15). Pas de table `profiles` séparée : le joueur
  lié EST la table de compte (nom, avatar, langue) — décision PO, 2026-09-16, après coup, une fois
  connecté pour de vrai à l'app (deux tables identiques en pratique, voir plan 03).
- Plus d'écran d'onboarding "Qui es-tu ?", plus de "c'est moi" (Q24) : une personne existe comme
  joueur dès sa première connexion, et seulement ainsi. Plus de sélection de ville. Le nom et
  l'avatar se corrigent dans le profil.
- Rejoindre une session exige un joueur lié (Q15) : toujours vrai, puisqu'il est créé à
  l'inscription.
- Profil : nom d'affichage, avatar (photo : voir plan 06 pour le composant d'upload partagé),
  langue.

## Étapes

1. `core/supabase/` : initialisation `Supabase.initialize` avec URL et clé anon issues de
   `--dart-define`, fournisseur Riverpod du client et du flux `onAuthStateChange`.
2. `features/auth/` : page `/login` (logo, titre, sous-titre, bouton Google), garde du routeur
   branchée sur l'état d'auth, écran de transition pendant la restauration de session (évite le
   "flash" du login observé dans l'ancienne app).
3. `features/profile/` : repository `players` (lecture du joueur lié par
   `players.user_id = auth.uid()`), écran profil, page réglages complétée (déconnexion).
4. Gestion des erreurs : bandeau standard pour "hors ligne", "session expirée", erreurs RLS.
5. Tests : unitaires sur les repositories (mocks du client), widget sur le login et le profil.

## Livrables

- Connexion, profil et joueur lié automatiques, réglages compte.

## Critères d'acceptation

- Connexion depuis Chrome desktop, Chrome Android et Safari iOS (PWA installée) : retour sur l'app
  avec session persistée après fermeture et réouverture.
- À la première connexion, le joueur lié existe déjà avec le nom Google ; le renommer dans le
  profil se reflète partout.

## Vérifié, non vérifié

- Connexion Google réelle vérifiée par le PO sur Chrome desktop et Chrome Android (navigation
  interne comprise). Safari iOS (PWA installée) non vérifié, faute d'iPhone disponible ; accepté
  tel quel par le PO (2026-09-16).
- Langue des réglages synchronisée dans `players.locale` en plus du stockage local (2026-09-16,
  [profile_repository.dart](../../lib/features/profile/data/profile_repository.dart)) : seul un
  choix explicite (français/anglais) est envoyé au compte, "Système" n'ayant pas de valeur unique
  à stocker dans cette colonne ; un échec d'écriture est ignoré silencieusement, la bascule locale
  ayant déjà pris effet et cette synchronisation n'étant qu'un confort multi-appareil.
- Tests unitaires des repositories (`auth_repository`, `profile_repository`) avec client mocké :
  écartés par le PO (2026-09-16) -- `signInWithGoogle` lit `Uri.base.origin`, qui lève en
  environnement de test VM (`flutter test`, hors navigateur) hors scheme http/https, seul le test
  widget (déjà en place) exerce ce chemin de façon réaliste.

## Questions PO liées

Q4 tranchée (colonne `players.user_id`), Q15 (arrivée par lien sans joueur).
