# Plan 32 — Prévision météo des événements à venir

## Statut

Plan rédigé le 2026-09-28 à la demande du PO du même jour. Réponses du PO le 2026-09-28 :
Q211 (le service déjà utilisé), Q212 et Q214 (heure de début seulement, pas de détail heure par
heure), Q213 et Q216 retenues, Q215 tranchée (limite de 7 jours, sans avertissement). Toutes les
questions sont tranchées.
**Plan validé par le PO le 2026-09-28**, implémentation demandée le même jour.

**Implémenté le 2026-09-28**, poussé sur `main` à la demande du PO le même jour. `flutter
analyze` et tests verts (tests unitaires du client et de la règle des 7 jours, tests de widgets
de la pastille et du bloc). L'assistant n'a pas pu l'essayer dans son navigateur (ni clés
Supabase, ni accès à Open-Meteo depuis sa session) ; le PO l'a essayé sur l'app déployée.
**Essayé et validé par le PO, clôturé le 2026-09-29.**

## Demande du PO (reformulée)

Pour chaque événement du planning qui commence dans les 7 prochains jours et a un point sur la
carte, la météo prévue **à son heure de début** :

- une **icône** sur la carte de l'événement, à l'accueil (« Prochain événement ») et dans le
  planning ;
- sur la page de l'événement, cette même prévision **détaillée** : icône, température,
  risque de pluie, vent.

## Existant (constat)

- L'app interroge déjà Open-Meteo (`lib/core/weather/weather_client.dart`) : conditions du
  moment à la création d'une session (`fetch`) et archives pour une session saisie après coup
  (`fetchArchive`). `weather_icon.dart` transforme le code météo en icône, déjà affichée dans
  l'historique et les exports. Open-Meteo figure déjà dans les crédits et dans la page de
  confidentialité (« météo de la session »).
- Un événement a une heure de début (`events.starts_at`), pas d'heure de fin.
- Un événement a un point (`location_lat`, `location_lng`) seulement si son spot en a un ou si
  un lieu libre a été placé sur la carte.
- La carte `EventCard` (`event_widgets.dart`) est partagée par l'accueil et le planning.

## Ce qui change pour l'utilisateur

1. **Carte d'événement** (accueil et planning) : une pastille avec l'icône météo, à côté du
   nombre de présents, pour un événement qui a un point et commence dans les 7 jours. Rien
   sinon (Q213), sans message.
2. **Page de l'événement** : sous le lieu, une ligne « Météo prévue » : icône, température
   (°C), risque de pluie (%), vent (km/h), chacun avec son icône (Q214). Rien dans les mêmes
   cas que la carte.
3. Un événement passé n'affiche plus de météo.
4. **Confidentialité** : « météo de la session » devient « météo des sessions et des
   événements », et Photon (adresses des spots), déjà utilisé mais absent, y est ajouté (Q216).
   Date de mise à jour de la page changée.

## Décisions techniques

- **Même service, même client** (Q211) : nouvelle méthode `WeatherClient.fetchForecast`,
  prévision horaire sur 8 jours (le 7ᵉ jour entier), en UTC, même contrat que les deux autres
  : tout échec rend `null`, en silence. Elle retient l'heure la plus proche du début, comme
  `fetchArchive`. Aucune table, aucune migration.
- Le résultat réutilise `Weather` (température, vent, code) avec un risque de pluie en plus,
  facultatif (`rainChance`), absent des météos de session déjà enregistrées : ce champ n'est
  pas écrit en base par les sessions, rien ne change pour elles.
- **Cache** : en mémoire (Riverpod), une requête par événement, gardée une heure ; le
  « tirer pour rafraîchir » existant la renouvelle. Rien sur l'appareil.
- **Icônes** : `weatherIcon` existant ; ajout de thermomètre, goutte et vent dans
  `phosphor_icons.dart`. Couleurs du thème, aucune nouvelle.

### Fichiers

- `lib/core/weather/weather.dart`, `weather_client.dart` : `rainChance`, `fetchForecast`.
- `lib/features/planning/domain/planning.dart` : `showsForecast` (Dart pur, testé) : un
  événement est-il à prévoir (point, jour pas terminé, début dans les 7 jours) ?
- `lib/features/planning/data/event_forecast.dart` : fournisseur par lieu et heure, gardé une
  heure.
- `lib/features/planning/ui/event_forecast_widgets.dart` : `EventForecastPill` (carte, dans
  `event_widgets.dart`) et `EventForecastBlock` (page, dans `event_detail_page.dart`).
- `lib/shared/nuni_status_pill.dart` : un libellé vide avec une icône dessine l'icône seule.
- `lib/core/theme/phosphor_icons.dart`, ARB EN et FR (textes et confidentialité).

## Hors périmètre

- Détail heure par heure (Q212, Q214), rafales, ressenti, direction du vent.
- Météo des sessions à venir, alertes, notifications.

## Critères d'acceptation

- [x] Un événement avec un point, dans les 7 jours, montre l'icône météo sur sa carte,
      à l'accueil et dans le planning.
- [x] Sa page montre à l'heure de début : icône, température, risque de pluie, vent.
- [x] Sans point, au-delà de 7 jours, passé, ou service injoignable : ni pastille, ni ligne,
      ni message.
- [x] Les météos de session (historique, exports, badges) sont inchangées.
- [x] Tests unitaires : fenêtre des 7 jours, lecture de la prévision (heure la plus proche,
      réponse incomplète).
- [x] Confidentialité à jour, chaînes EN et FR, `flutter analyze` et tests verts.
