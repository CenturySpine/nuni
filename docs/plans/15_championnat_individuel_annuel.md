# Plan 15 — Championnat individuel annuel

## En bref, pour les membres de l'association

Certaines parties compteront pour un classement annuel, un peu comme un championnat de club.
Concrètement, pour un joueur :

- Quand on crée une partie, on peut cocher une case "elle compte pour le championnat" — ou cocher
  cette case après coup, une fois la partie terminée.
- Le championnat se déroule sur une saison, du 1er septembre au 31 août (par exemple "saison
  2026-2027").
- Les parties qui comptent sont regroupées automatiquement par secteur géographique : personne n'a
  besoin de définir des limites de ville ou de quartier, l'appli les devine toute seule d'après les
  lieux où l'on joue réellement.
- Chaque partie qui compte rapporte des points selon le classement du jour, plus un petit point
  supplémentaire simplement pour être venu, même sans bien se classer. Ça encourage à venir
  régulièrement, sans jamais permettre à quelqu'un de doubler un meilleur résultat juste en
  cumulant des présences.
- Ces points s'additionnent sur toute la saison, quel que soit le type de partie jouée (au nombre
  de coups, en duel, en points libres...) : tout se mélange dans un seul classement.
- Sur la page d'accueil de l'appli, chaque joueur voit sa position actuelle, mise à jour au fil des
  parties.

## Note pour les personnes qui suivent le développement du projet

Plan **fonctionnel**. Le détail technique (comment c'est calculé et stocké) sera écrit dans une
révision ultérieure de ce document, une fois les décisions ci-dessous validées par le PO.

## Objectif

Permettre un classement individuel qui se déroule sur une année scolaire (ex. 2026-2027), limité
aux sessions que leur créateur a marquées "championnat", regroupées automatiquement par zone
géographique, et affiché de façon provisoire sur l'accueil pour chaque joueur concerné.

## Prérequis

- Historique des sessions et des scores (étapes 8 et 10, déjà livrées).
- Position géographique connue pour chaque session, capturée à sa création (étape 7).

## Décisions retenues (validées par le PO le 2026-09-21)

1. **Qui tague, et quand.** Seul le créateur d'une session peut la marquer "championnat", à la
   création ou à n'importe quel moment ensuite, y compris après que la session est terminée.
   Personne d'autre ne peut la marquer ou la démarquer.
2. **Zones géographiques, sans configuration.** Il n'existe plus de référentiel ville/zone dans
   NUNI (la ville d'une session est un simple texte détecté à sa création, modifiable, pas une
   entité administrée). Un regroupement "par ville" au sens strict serait donc soit trop rigide
   (des sessions à quelques rues d'écart mais avec un nom de ville légèrement différent se
   retrouveraient dans deux championnats séparés), soit exigerait qu'un administrateur découpe des
   zones à la main — explicitement écarté par la demande.
   Retenu à la place : les sessions marquées championnat se regroupent **automatiquement entre
   elles par proximité géographique réelle**, sur le même principe que le rayon déjà utilisé pour
   proposer les trous à proximité (étape 6). Une session rejoint une zone existante si elle est
   raisonnablement proche d'autres sessions championnat déjà jouées ; sinon, elle fonde une
   nouvelle zone. Aucun réglage préalable, aucune liste de villes à maintenir : les zones émergent
   des lieux où l'on joue réellement.
   Le nom affiché d'une zone reste un sujet ouvert (Q41 ci-dessous).
3. **Points d'une session championnat.** Le nombre de points de classement gagné dépend de la
   position finale du joueur ce jour-là et du nombre de participants à cette session : une
   victoire dans une session à beaucoup de monde vaut plus qu'une victoire dans une petite session,
   et même la dernière place d'une grande session rapporte un point de classement non nul (jamais
   zéro). Le mode de jeu de la session (stroke play, match play, redistribution, libre) n'entre pas
   en compte : seule la position finale du jour compte, ce qui permet d'agréger des sessions de
   modes différents dans un même total.
   S'ajoute un **point de présence automatique et fixe**, gagné par toute personne ayant joué une
   session championnat, quel que soit son classement ce jour-là. Il incite à venir même sans
   viser la victoire, sans jamais permettre à une simple présence de dépasser un résultat mieux
   classé : l'écart entre deux positions de classement reste toujours supérieur à ce point fixe.
4. **Score du championnat.** Somme, sur toute la saison, des points de classement et de présence de
   toutes les sessions championnat jouées par le joueur dans sa zone. Pas de moyenne, pas de
   meilleurs résultats retenus en excluant les autres : chaque session championnat jouée compte.
5. **Portée d'un joueur.** Un joueur peut apparaître dans plusieurs zones la même saison s'il a
   joué des sessions championnat à des endroits suffisamment éloignés les uns des autres (aucune
   règle d'unicité n'est nécessaire, la zone découle uniquement des sessions jouées).

## Décisions complémentaires (validées par le PO le 2026-09-21)

Reprises de `QUESTIONS_PO.md` (Q38–Q42), toutes tranchées :

- **Q38** — Saison du 1er septembre au 31 août de l'année suivante.
- **Q39** — Pas de nombre minimal de sessions jouées pour apparaître au classement, provisoire ou
  final.
- **Q40** — En cas d'égalité de classement au sein d'une session (deux joueurs ex æquo ce jour-là),
  les deux touchent les mêmes points de classement.
- **Q41** — Le nom affiché d'une zone de championnat est déduit automatiquement du texte "ville" le
  plus fréquent parmi les sessions qui la composent, sans saisie manuelle.
- **Q42** — Cette fonctionnalité est indépendante des étapes 11 (déploiement), 13 (migration) et 14
  (suppression de compte) du plan d'ensemble ; son développement détaillé peut être planifié dès
  maintenant, sans attendre ces trois étapes.

## Parcours et écrans (grandes lignes fonctionnelles)

1. **Marquer une session "championnat".** Une case à cocher visible à la création de la session,
   et dans ses réglages tant qu'elle appartient à son créateur, y compris après clôture. Dès qu'elle
   est cochée, l'app affiche la zone et la saison détectées ("Cette session compte pour le
   championnat de [zone], saison [année]"), pour que le créateur vérifie avant de continuer — le
   rattachement automatique n'est jamais un calcul invisible.
2. **Encart classement sur l'accueil.** Pour tout joueur ayant au moins une session championnat
   dans sa zone pour la saison en cours : sa position actuelle, son total de points, et les deux ou
   trois joueurs autour de lui au classement. Un lien ouvre le classement complet. Si le joueur n'a
   aucune session championnat, l'encart ne s'affiche pas (pas d'écran vide à expliquer).
3. **Écran de classement complet.** Liste ordonnée des joueurs d'une zone pour une saison : position,
   total de points, nombre de sessions championnat jouées. Sélecteur de saison, pour consulter les
   années précédentes une fois qu'il y en a. Si le joueur appartient à plusieurs zones, il peut
   basculer entre elles.
4. **Détail d'une session depuis le classement.** Ouvre l'écran d'historique de session déjà
   existant (étape 10), avec en plus la mention des points de classement et de présence gagnés ce
   jour-là par chaque joueur.

## Critères d'acceptation

- Une session marquée championnat rejoint automatiquement une zone et une saison, sans qu'un
  administrateur ait rien configuré au préalable.
- Le classement additionne correctement les points de classement et de présence de toutes les
  sessions championnat d'un joueur dans sa zone et sa saison, quel que soit le mode de jeu de
  chaque session.
- Le classement provisoire est visible sur l'accueil pour tout joueur ayant au moins une session
  championnat dans la saison en cours, et absent sinon.
- (Q38 à Q42 tranchées, plus de décision fonctionnelle en attente avant d'écrire le plan technique
  détaillé de cette étape.)

## Questions PO liées

Q38, Q39, Q40, Q41, Q42 — voir [QUESTIONS_PO.md](../QUESTIONS_PO.md).
