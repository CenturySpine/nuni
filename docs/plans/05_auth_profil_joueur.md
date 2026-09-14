# Plan 05 — Authentification, profil, joueur lié

## Objectif

Connexion Google via Supabase dans une PWA, création automatique du profil, onboarding "mon
joueur" sans référentiel de ville, édition du profil, déconnexion, suppression de compte.

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
- Profil (`profiles`) créé par trigger base à l'inscription (display name, avatar Google).
- Onboarding : au premier lancement, si l'utilisateur n'a pas de joueur lié, écran "Qui es-tu ?" :
  soit **créer mon joueur** (nom pré-rempli avec le nom Google, avatar Google proposé), soit **c'est
  moi** dans la liste des joueurs existants non liés (cas des joueurs créés par un autre
  utilisateur lors d'une session, avant que la personne ne s'inscrive). Plus de sélection de ville.
- L'onboarding peut être **différé** : un utilisateur qui arrive par un lien `/join/CODE` doit
  pouvoir rejoindre d'abord et se rattacher ensuite ; le bandeau "Tu n'as pas encore de joueur"
  reste visible sur l'accueil tant que le lien n'est pas fait.
- Profil : nom d'affichage, avatar (photo : voir plan 06 pour le composant d'upload partagé),
  langue. Le joueur lié reprend le nom et l'avatar du profil (synchronisation à la sauvegarde).
- Suppression de compte : appel de `delete_my_account` (Edge Function, plan 03), puis déconnexion
  locale. Les sessions créées par l'utilisateur sont supprimées ; les joueurs qu'il a créés et qui
  sont utilisés dans les sessions d'autres utilisateurs sont conservés mais déliés (règle
  documentée dans la page "suppression de compte" déjà existante côté Play Store, à réécrire pour
  NUNI).

## Étapes

1. `core/supabase/` : initialisation `Supabase.initialize` avec URL et clé anon issues de
   `--dart-define`, fournisseur Riverpod du client et du flux `onAuthStateChange`.
2. `features/auth/` : page `/login` (logo, titre, sous-titre, bouton Google), garde du routeur
   branchée sur l'état d'auth, écran de transition pendant la restauration de session (évite le
   "flash" du login observé dans l'ancienne app).
3. `features/profile/` : repository `profiles` et `players` (lecture du joueur lié par
   `players.user_id = auth.uid()`), écran d'onboarding, écran profil, page réglages complétée (déconnexion,
   suppression de compte avec double confirmation).
4. Gestion des erreurs : bandeau standard pour "hors ligne", "session expirée", erreurs RLS.
5. Tests : unitaires sur les repositories (mocks du client), widget sur le login et l'onboarding.

## Livrables

- Connexion, onboarding, profil, réglages compte.

## Critères d'acceptation

- Connexion depuis Chrome desktop, Chrome Android et Safari iOS (PWA installée) : retour sur l'app
  avec session persistée après fermeture et réouverture.
- Un joueur créé par quelqu'un d'autre peut être réclamé ("c'est moi") une seule fois.
- La suppression de compte laisse la base cohérente (tests RLS du plan 03 étendus).

## Questions PO liées

Q4 tranchée (colonne `players.user_id`), Q15 (arrivée par lien sans joueur).
