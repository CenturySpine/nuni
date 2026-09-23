# Plan d'ensemble — NUNI

Objectif : recoder les fonctionnalités de LsgScores (Android) sous forme d'une PWA Flutter adossée
à Supabase, sans reproduire l'ancienne app à l'identique. Les étapes sont ordonnées ; chaque étape
a un plan détaillé et n'est démarrée qu'une fois la précédente livrée et validée.

Convention : chaque plan détaillé contient Objectif, Prérequis, Décisions retenues (avec les
hypothèses en attente de validation), Étapes, Livrables, Critères d'acceptation, Questions PO
liées. Les questions sont centralisées dans [QUESTIONS_PO.md](../QUESTIONS_PO.md).

## Cibles non négociables (rappel)

- PWA uniquement (pas d'app store Android/iOS).
- Données sur Supabase ; schéma, RLS et temps réel retravaillés pour la nouvelle app.
- Auth Google via Supabase conservée.
- Plus de référentiel obligatoire ville / zone / joueur ; référentiel des trous conservé et
  géolocalisé (public/privé, rayon de proximité).
- Distinction utilisateur authentifié / joueur conservée (table de lien, profil éditable).
- i18n EN/FR, un seul thème ultra simple.
- Nom public : NUNI, sous-titre "Never Up, Never In", logo "tee" actuel.

## Étapes

| # | Étape | Plan détaillé | Résultat attendu |
|---|-------|---------------|------------------|
| 1 ✅ | Outillage du poste de travail | [01_outillage_poste.md](01_outillage_poste.md) | git, Flutter, Node, CLIs GitHub / Supabase / Vercel opérationnels ; `flutter doctor` OK pour le web |
| 2 ✅ | Bootstrap du projet Flutter web + dépôt + CI | [02_bootstrap_projet_flutter_ci.md](02_bootstrap_projet_flutter_ci.md) | Squelette Flutter web committé sur `main`, `AGENTS.md`, build Vercel (`vercel.json` + script : analyze + test + build web), push direct sur `main` sans PR, premiers commits techniques permettant de relier le projet Vercel au dépôt |
| 3 ✅| Backend Supabase : projet, schéma, RLS, RPC, stockage, temps réel | [03_supabase_schema_rls_realtime.md](03_supabase_schema_rls_realtime.md) | Projet Supabase `nuni`, migrations versionnées dans le dépôt, schéma cible appliqué, politiques testées |
| 4 ✅| Socle applicatif : design system minimal, i18n, navigation | [04_socle_design_i18n_navigation.md](04_socle_design_i18n_navigation.md) | Thème unique (palette réduite), EN/FR, coquille de navigation, composants de base |
| 5 ✅ | Authentification, profil, joueur lié | [05_auth_profil_joueur.md](05_auth_profil_joueur.md) | Connexion Google (redirect PWA), joueur lié créé automatiquement à l'inscription (plus d'onboarding, Q24), édition profil, déconnexion |
| 6 ✅ | Trous géolocalisés | [06_trous_geoloc.md](06_trous_geoloc.md) | CRUD trous (public/privé, position de départ, photos), recherche par proximité |
| 7 ✅ | Création de session et équipes | [07_creation_session_equipes.md](07_creation_session_equipes.md) | Ville auto-détectée et confirmée, zone libre, mode de scoring, équipes manuelles ou aléatoires, joueurs sélectionnables sans être connectés |
| 8 ✅ | Session en direct : trous joués, saisie collaborative, classement temps réel | [08_session_live_scores_realtime.md](08_session_live_scores_realtime.md) | Écran de session, ajout de trous par proximité, saisie des coups par équipe, classement live, clôture |
| 9 ✅ | Rejoindre et reprendre une session | [09_rejoindre_reprendre_session.md](09_rejoindre_reprendre_session.md) | Code + lien + QR, adhésion, rattachement à une équipe, reprise depuis n'importe quel appareil |
| 10 ✅ | Historique, photos, exports | [10_historique_photos_exports.md](10_historique_photos_exports.md) | Liste et détail des sessions passées, galerie photos, export PDF et image partageable, édition des horaires |
| 11 ✅ | PWA, déploiement Vercel, domaine. Clôturée le 2026-09-23 : installation testée par le PO, Lighthouse et bandeau de mise à jour abandonnés, métadonnées, pages légales et crédits validés par le PO | [11_pwa_vercel_domaine.md](11_pwa_vercel_domaine.md) | Manifest et icônes NUNI, installation sur l'écran d'accueil, mise à jour douce, déploiement continu sur nuni.centuryspine.org |
| 12 ✅ | Recette et mise en service. Clôturée par le PO le 2026-09-23 : tests jugés suffisants pour la première version, première session réelle la semaine suivante | [12_recette_migration_mise_en_service.md](12_recette_migration_mise_en_service.md) | Scénarios de recette joués sur mobile, bascule |
| 13 ✅ | Migration des données LsgScores (critique). Étapes 1 (trous), 2 (sessions, joueurs, scores, photos) et 3 (seeds) livrées et testées par le PO le 2026-09-23. Clôturée le 2026-09-23 : pas de retrait de l'ancienne app prévu (un plan dédié sera ouvert si besoin) | [13_migration_donnees_lsgscores.md](13_migration_donnees_lsgscores.md) | Sessions, équipes, joueurs, trous et coups de l'ancienne base importés dans NUNI, vérifiés et consultables dans l'historique |
| 14 | Suppression de compte (impacts sur les données d'autrui à trancher avant le détail des étapes, Q27–Q31) | [14_suppression_compte.md](14_suppression_compte.md) | Suppression de compte sans casser les sessions, scores et trous partagés avec d'autres utilisateurs |
| 15 ✅ | Championnat individuel annuel (implémenté et testé par le PO le 2026-09-22 : schéma distant reconstruit, parcours complet vérifié dans le navigateur) | [15_championnat_individuel_annuel.md](15_championnat_individuel_annuel.md) | Classement individuel annuel par zone géographique organique, agrégeant les sessions marquées "championnat", affiché en provisoire sur l'accueil |
| 16 ✅ | Rôles applicatifs (super_admin / player), implémenté et vérifié le 2026-09-22 (Q46–Q47) : schéma distant reconstruit, `user_roles` ne contient que le PO en `super_admin`, `flutter analyze`/tests/build Vercel verts | [16_roles_applicatifs.md](16_roles_applicatifs.md) | Rôle applicatif `super_admin` pour le PO seul, `player` par défaut pour tous les autres comptes, fondation pour de futures actions structurantes — aucun écran ni politique existante modifiés à ce stade |
| 17 ✅ | Trou générique (Q56–Q59), livré avec l'étape 1 du plan 13, testé par le PO le 2026-09-23 | [17_trou_generique.md](17_trou_generique.md) | « Trou libre » toujours proposé dans une session en direct, sans position ni référentiel, avec libellé facultatif |

## Ordre et dépendances

- 1 → 2 → 3 sont strictement séquentielles (le projet Vercel ne peut être créé qu'après les premiers
  commits de l'étape 2 ; les écrans de l'étape 5+ ont besoin du schéma de l'étape 3).
- 4 peut démarrer en parallèle de 3.
- 5 → 6 → 7 → 8 → 9 → 10 suivent l'ordre fonctionnel (chaque écran s'appuie sur le précédent).
- 11 est préparée dès l'étape 2 (déploiement d'une coquille vide sur Vercel) et finalisée en fin de
  projet.
- 13 est obligatoire mais son plan détaillé n'est rédigé qu'après l'étape 12, quand le modèle cible
  est stabilisé par l'usage. Le schéma de l'étape 3 la prépare (colonnes `legacy_id`).
- 14 dépend du plan 5 (compte et joueur lié) mais pas du reste : comme pour 13, le numéro ne fixe
  pas le moment de l'implémentation. Retirée du plan 05 (décision PO, 2026-09-16) parce que ses
  impacts sur les données d'autres utilisateurs (Q27–Q31) n'avaient pas été examinés ; son détail
  n'est écrit qu'une fois ces questions tranchées.
- 15 dépend fonctionnellement de 7 (ville détectée à la création) et 8/10 (historique des scores),
  déjà livrées ; indépendante de 11, 13 et 14 (Q42, tranchée). Plans fonctionnel et technique
  rédigés le 2026-09-21 ; implémentation à démarrer sur validation PO du plan technique (règle 1,
  AGENTS.md).
- 16 ne dépend d'aucune autre étape (schéma seul, aucun écran) ; prépare une alternative pour le
  plan 13 (M5, tagage rétroactif "championnat" des sessions importées) sans l'imposer — ce choix
  reste ouvert au moment où le plan 13 sera détaillé.

## Jalons de validation avec le product owner

1. ☑ Fin d'étape 3 : validation du modèle de données et des règles d'accès (point de non-retour le
   plus coûteux à changer ensuite). Validé par le PO le 2026-09-15.
2. ☑ Fin d'étape 4 : validation visuelle du thème et de la navigation sur téléphone. Validé par le
   PO le 2026-09-16.
3. Fin d'étape 8 : première session réelle jouée avec plusieurs téléphones.
4. ☑ Fin d'étape 12 : mise en service. Clôturée par le PO le 2026-09-23, première session
   réelle la semaine suivante.
5. ☑ Fin d'étape 13 : anciennes sessions visibles et correctes dans NUNI (2026-09-23). Le
   retrait de l'ancienne app n'est pas prévu.
