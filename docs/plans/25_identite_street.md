# Plan 25 — Identité visuelle « street »

## Statut

Fiche synthétique (2026-09-24). Plan détaillé à rédiger après réponse à Q104 et Q105 et une
planche d'inspiration validée par le PO.

## Objectif

Que NUNI ressemble à un jeu de rue plutôt qu'à une app de gestion, sans perdre la lisibilité
ni le système de composants existant.

## Prérequis

Plan 04 (thème, composants `lib/shared/`) livré. Idéalement après les plans 19 à 21, qui
créent les écrans où l'identité a le plus d'effet (classement, badges, statistiques).

## Pistes envisagées (hypothèse)

- Typographie condensée et grasse pour les chiffres (scores, rangs), texte courant inchangé.
- Classement en direct façon tableau de bord sportif : grands chiffres, écart au leader,
  flèches animées quand une place change.
- Moments célébrés : animation courte et vibration pour un birdie, un changement de leader, un
  badge ; écran podium en fin de session.
- Motifs discrets inspirés du marquage au sol et de la signalétique urbaine (bandeaux, en-têtes).
- Photos des trous en grand plutôt qu'en vignettes.

## Principes techniques

- Tout passe par `core/theme/` et les composants `Nuni*` : aucun style recréé dans les écrans.
- Galerie `/dev/theme` d'abord (maquettes jugées sur pièce), écrans réels ensuite.
- Les six palettes restent compatibles ; test de contraste inchangé.

## Questions PO liées

Q104 (typographie), Q105 (ampleur des animations et vibrations).

## Critères d'acceptation (esquisse)

- Maquettes validées par le PO dans `/dev/theme` avant toute modification d'écran réel.
- Test de contraste vert pour les six palettes.
