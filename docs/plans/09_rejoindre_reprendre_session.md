# Plan 09 — Rejoindre et reprendre une session

## Objectif

Permettre à n'importe qui de rejoindre une session en direct depuis son téléphone en quelques
secondes (lien, QR, code court), de se rattacher à son équipe, et de retrouver ses sessions en
direct depuis n'importe quel appareil.

## Prérequis

Plans 05, 07, 08.

## Décisions retenues

- Identifiant de partage : `sessions.code` (6 caractères sans ambiguïté, sans 0/O/1/I), généré en
  base. Lien : `https://nuni.centuryspine.org/join/CODE`.
- Écran "Inviter" (depuis la session en direct) : code en grand, bouton "Copier le lien", bouton
  "Partager" (API Web Share via `share_plus`, repli copie), QR code généré localement avec
  `qr_flutter` encodant le lien.
- H (Q14) : pas de scanner intégré ; l'appareil photo natif lit le QR et ouvre la PWA. L'accueil
  propose "Rejoindre avec un code" pour la saisie manuelle.
- Route `/join/:code` :
  1. non connecté : mémoriser le code (localStorage), aller au login, revenir sur `/join/:code` ;
  2. connecté : appeler `join_session(code)` ;
  3. session introuvable ou terminée : message et retour à l'accueil ;
  4. rattachement automatique si mon joueur lié est dans une équipe ; sinon choix d'équipe
     (H Q15 : rejoindre une équipe non pleine avec mon joueur, ou rester spectateur) ; sans joueur
     lié : proposition de créer / réclamer mon joueur à ce moment (plan 05, onboarding différé) ;
  5. navigation vers `/session/:id`.
- Reprise : l'accueil liste "Mes sessions en direct" (requête sur `session_members` join
  `sessions.status = live`), avec rôle et date, et "Reprendre". Plus aucun état de participation
  dans le stockage local : l'appartenance est en base, donc valable sur tous les appareils.
- Départ volontaire : "Quitter la session" retire le membre (les coups déjà saisis restent).
- Le créateur voit la liste des membres et peut retirer quelqu'un ou le nommer co-organisateur.

## Étapes

1. Paquets : `qr_flutter`, `share_plus`.
2. `features/join/` : page `/join/:code`, feuille de choix d'équipe, écran "Inviter", saisie
   manuelle de code.
3. Accueil : sections "Mes sessions en direct", "Créer", "Rejoindre", "Dernières sessions".
4. Tests : parcours join (mocks de l'RPC), génération du lien, validation du code saisi.

## Livrables

- Invitation, adhésion, reprise, gestion des membres.

## Critères d'acceptation

- Un téléphone jamais connecté scanne le QR, se connecte avec Google et arrive sur la session en
  direct rattaché à la bonne équipe, sans autre action.
- Fermer l'onglet puis rouvrir l'app sur un autre appareil retrouve la session en direct.

## Questions PO liées

Q14, Q15.
