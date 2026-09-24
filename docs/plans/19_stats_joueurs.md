# Plan 19 — Statistiques joueur

## Statut

Fiche synthétique (2026-09-24), demandée par le PO. Priorité 1 avec le plan 20. Q90 à Q93
et Q106 à Q108 tranchées le 2026-09-24 : plan détaillé à rédiger, plus de question ouverte.

## Objectif

Donner à chaque joueur une fiche de statistiques qui donne envie de revenir entre deux sessions :
forme du moment, points forts, progression sur la saison.

## Prérequis

Plans 08 et 10 (scores et historique) et 13 (sessions importées de LsgScores) livrés.

## Contrainte structurante

La base stocke **un score par équipe et par trou** (`scores.team_id`), jamais par joueur. Un
coup n'est attribuable à un joueur que si son équipe ne compte qu'un joueur (session
individuelle, ou mode de jeu `individual`). En session par équipes, un joueur n'a que les
résultats de son équipe (victoire, place).

## Décisions retenues

- Q90 : statistiques de coups calculées **uniquement sur les sessions individuelles**. Les
  sessions par équipes alimentent des méta-statistiques d'équipe (Q107), jamais des coups.
- Q91 et Q106 : chaque joueur a une **fiche consultable par tous** (`/players/:id`, nouvelle),
  qui montre toujours son pseudo et sa photo. Les statistiques et les badges sont des sections en
  plus sur cette fiche, **visibles par défaut** ; le joueur peut les masquer depuis son profil
  par deux interrupteurs indépendants, « Statistiques publiques » et « Badges publics » (Q108).
  Les classements de session et de championnat ne changent pas.
- Q93 : aucun seuil, toute statistique s'affiche dès le premier trou joué.
- Conséquence technique (pas une décision) : le mode de scoring « Libre » est exclu des
  statistiques de coups, car sa valeur saisie est un nombre de points et non de coups
  (`score_calculator.dart`). Ses sessions comptent pour les sessions jouées et les victoires.
- Q107 : méta-statistiques d'équipe = sessions, victoires et podiums en équipe, équipier le plus
  fréquent, meilleur duo (au moins 3 sessions communes, seuil propre à Q107).
- Q92 : les sessions importées de LsgScores comptent : statistiques disponibles avant la saison
  2026-2027.

## Contenu

- Chiffres clés : sessions jouées, victoires, podiums, trous joués.
- Rapport au par : moyenne de coups par rapport au par (trous du référentiel seulement, un trou
  libre n'a pas de par), répartition birdie / par / bogey et plus.
- Meilleur et pire trou (moyenne par rapport au par, dès un passage, Q93).
- Courbe de la saison (septembre à août, comme le championnat) : moyenne par session.
- Méta-statistiques d'équipe (Q107).
- Mon profil : les deux interrupteurs de visibilité, activés par défaut (Q108).
- Fiche joueur `/players/:id` : pseudo, photo, puis sections « Statistiques » et « Badges »
  (plan 21) si le joueur les laisse visibles, sinon une mention « Statistiques privées ».
  Accès depuis un avatar dans un classement, un historique, une équipe ; mon propre profil y
  mène aussi (je vois toujours mes propres sections).

## Principes techniques

- Calcul en Dart, testé unitairement (règle du projet : la base ne stocke que les valeurs
  saisies). Nouveau module `lib/features/stats/` partagé avec les plans 20 et 21.
- Lecture par une RPC `security definer` qui renvoie les scores bruts nécessaires (même logique
  que `championship_association_results`), car la RLS actuelle ne montre une session qu'à ses
  membres. La RPC applique le choix « privé » côté serveur. Aucune nouvelle table ; deux colonnes
  `players.stats_public` et `players.badges_public`, vraies par défaut (Q108), donc reconstruction de la base
  distante selon la règle 8 (PO prévenu avant, seeds régénérés puis rejoués).

## Questions PO liées

Q90 à Q93, Q106 à Q108, toutes tranchées.

## Critères d'acceptation (esquisse)

- Les chiffres d'un joueur sont identiques quel que soit l'appareil ou la personne qui les
  consulte.
- La fiche d'un joueur est toujours accessible (pseudo et photo) ; quand il a masqué ses
  statistiques, la RPC ne les renvoie à personne d'autre que lui, même appelée directement
  (vérifié par un test).
- Chaque calcul est couvert par un test unitaire, y compris trous libres et sessions par
  équipes.
- Chaînes EN/FR, `flutter analyze` sans remarque.
