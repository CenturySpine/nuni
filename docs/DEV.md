# Développer NUNI en local

Prérequis : plan 01 (FVM, Flutter 3.47.4 stable, Node, CLIs GitHub / Supabase / Vercel).

## Première fois

```powershell
fvm install                      # lit .fvmrc et installe la version épinglée (3.47.4)
fvm flutter pub get              # dépendances + génération des traductions (lib/l10n/generated)
npm install                      # CLIs supabase et vercel épinglées (npx supabase, npx vercel)
Copy-Item env/example.json env/dev.json   # puis renseigner SUPABASE_URL et SUPABASE_ANON_KEY
```

`env/dev.json` et `env/prod.json` sont ignorés par git. Ne jamais committer une clé.

## Au quotidien

```powershell
fvm flutter run -d chrome --web-port 3000 --dart-define-from-file=env/dev.json   # port fixe : URL de retour Google/Supabase
fvm dart run build_runner build -d                               # régénérer freezed / riverpod / json
fvm dart format lib test                                         # formater (la CI refuse un fichier non formaté)
fvm flutter analyze --fatal-infos                                # aucune remarque tolérée
fvm flutter test                                                 # tests unitaires et widgets
fvm flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/prod.json
```

Le build web produit `build/web/`, qui contient `version.json` (numéro de build lu par le bandeau de
mise à jour, plan 11). `--no-web-resources-cdn` fait servir le moteur de rendu CanvasKit depuis le
site lui-même au lieu d'un serveur Google (Q22) ; sans cette option, la page reste blanche dès que
ce serveur est inaccessible.

Pour vérifier le site construit sans Flutter : `python -m http.server 8765` dans `build/web`, puis
ouvrir http://127.0.0.1:8765/.

## Traductions

Les chaînes visibles sont dans `lib/l10n/app_en.arb` (référence, avec les descriptions) et
`lib/l10n/app_fr.arb`. Le code Dart est généré dans `lib/l10n/generated/` par `flutter pub get`
(dossier ignoré par git). Une chaîne ajoutée dans un seul fichier fait échouer l'analyse.

## Build et déploiement

Vercel est relié au dépôt GitHub. À chaque push sur `main`, il exécute `tool/vercel_build.sh` d'après `vercel.json` : installation de la
version Flutter de `.fvmrc`, `pub get`, analyze, test, build web. Un commit qui casse l'analyse ou
un test n'est pas déployé et le commit GitHub porte une coche rouge. `main` va en production sur
`nuni.centuryspine.org` ; pas de prévisualisation sur ce projet. `SUPABASE_URL` et `SUPABASE_ANON_KEY`
sont des variables d'environnement du projet Vercel. Pas de GitHub Actions.

Reproduire le build Vercel en local (Linux, macOS ou Git Bash) : `bash tool/vercel_build.sh`,
avec `FLUTTER_DIR` pointant sur un SDK déjà installé pour éviter le téléchargement.

## Photos : miniatures et réduction (plan 30)

Chaque photo de trou ou de session a une miniature de 256 px rangée à côté d'elle
(`<chemin>.thumb.jpg`), créée par l'app à l'envoi et lue par les listes. Pour les photos
envoyées avant le plan 30, lancer une fois le script de reprise, après la mise en ligne de
l'app du plan 30. Il crée les miniatures manquantes et réduit à 1600 px les photos plus
larges (celles importées de LsgScores). Relançable sans effet de bord ; le stockage survit
aux reconstructions du schéma, donc inutile de le relancer après l'une d'elles.
Nécessite `env/migration.json` (clé service NUNI).

```powershell
fvm dart run tool/backfill_photo_thumbnails.dart --dry-run   # compte sans rien écrire
fvm dart run tool/backfill_photo_thumbnails.dart
```

## Notifications (plan 33)

Web Push standard, sans prestataire (Q224). Chaîne complète : déclencheurs de la base
(migration `20260929120000_push_notifications`) → fonction serveur `send-push`
(`supabase/functions/send-push/index.ts`, textes FR/EN) → service de notification du navigateur
→ `web/nuni_sw.js` sur le téléphone. Mise en place, une seule fois (tout est sur le poste du PO,
aucun secret dans le dépôt) :

```powershell
# 1. Paire de clés VAPID : identifie NUNI auprès des services de Google, Apple et Mozilla.
#    Affiche "Public Key" et "Private Key".
npx web-push generate-vapid-keys

# 2. Clé PUBLIQUE dans l'app : ajouter "VAPID_PUBLIC_KEY": "<Public Key>" dans env/dev.json et
#    env/prod.json, et la variable d'environnement VAPID_PUBLIC_KEY (même valeur) dans le projet
#    Vercel (Settings > Environment Variables), puis redéployer. Sans elle, les Réglages disent
#    que le navigateur ne permet pas les notifications.

# 3. Secret d'appel de la fonction (une valeur au hasard, gardée pour l'étape 5) :
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# 4. Secrets de la fonction serveur (clé PRIVÉE comprise ; mailto = contact des services push).
npx supabase secrets set VAPID_PUBLIC_KEY=<Public Key> VAPID_PRIVATE_KEY=<Private Key> VAPID_SUBJECT=mailto:<e-mail> PUSH_FUNCTION_SECRET=<secret de l'étape 3>

# 5. Adresse et secret dans le coffre de la base (tableau de bord Supabase > SQL Editor) :
#    select vault.create_secret('https://<project-ref>.supabase.co/functions/v1/send-push', 'push_function_url');
#    select vault.create_secret('<secret de l''étape 3>', 'push_function_secret');

# 6. Déployer la fonction (à refaire après chaque modification de index.ts).
npx supabase functions deploy send-push
```

Tant que l'étape 5 n'est pas faite, la base n'envoie rien, sans erreur. Vérification des
destinataires (même procédure que `rls_smoke.sql`) :
`npx supabase db query --linked -f supabase/tests/notifications_smoke.sql`. Journal des envois :
tableau de bord Supabase > Edge Functions > send-push > Logs.

## Supabase : modifier le schéma (migrations additives, depuis la version 1.0.0)

Depuis le 2026-09-27 (version 1.0.0, décision du PO), la base de production contient des
données réelles et **n'est plus jamais reconstruite**. Les fichiers déjà présents dans
`supabase/migrations` sont appliqués en production : **ne plus jamais les modifier**. Tout
changement de schéma, de RLS, de RPC ou de déclencheur passe par un **nouveau** fichier de
migration, qui modifie l'existant (`alter table`, `create or replace function`, `drop ... if
exists`, `create policy`...).

```powershell
# 1. Créer la migration (nom en anglais, horodaté par le CLI).
npx supabase migration new add_something

# 2. L'écrire, la relire, et prévenir le PO de ce qu'elle change pour les utilisateurs.
#    Si elle transforme ou supprime des données : sauvegarder d'abord (étape 3).

# 3. Sauvegarde des données réelles (toujours utile avant une migration qui touche des données) :
#    supabase/remote_seed.sql (trous, en clair) et supabase/data_seed.sql.enc (le reste,
#    chiffré). Nécessite env/migration.json et env/seed.json. Ne jamais committer une copie
#    déchiffrée.
fvm dart run tool/export_remote_seed.dart

# 4. Appliquer : le CLI ne pousse que les migrations pas encore appliquées.
npx supabase db push

# 5. Vérifier les droits : crée des données de test jetables, les supprime à la fin, puis
#    affiche une ligne de verdict (Q250) : "not_passed" doit être vide ([]) et "leftovers" à 0
#    (données de test que le nettoyage aurait oubliées).
npx supabase db query --linked -f supabase/tests/rls_smoke.sql
```

Une migration qui modifie une fonction reprend sa définition complète (`create or replace`) ;
une fonction dont la signature change se supprime d'abord (`drop function if exists
public.<nom>(<paramètres>)`). Les commentaires restent en anglais, comme le code.

L'ancienne procédure de reconstruction complète (avant 1.0.0) figure dans l'historique git de ce
fichier ; elle ne doit plus être utilisée.

## Restaurer une session supprimée (plan 36)

Supprimer une session **terminée**, depuis l'app ou ailleurs, en garde une copie complète dans la
table privée `session_archives` (illisible depuis l'app, `super_admin` compris) ; ses photos
restent dans le stockage. Une session brouillon ou en cours n'est jamais archivée : sa
suppression est définitive. Les archives sont gardées indéfiniment et sauvegardées dans le seed
chiffré (`tool/export_remote_seed.dart`).

Restauration à la main, par le PO ou l'assistant, depuis le tableau de bord Supabase > SQL Editor :

```sql
-- 1. Retrouver la session : les archives, la plus récente en premier.
select a.session_id,
       a.deleted_at,
       coalesce(p.name, 'hors app') as supprimee_par,
       coalesce(a.data -> 'session' ->> 'title', a.data -> 'session' ->> 'zone') as session,
       a.data -> 'session' ->> 'started_at' as jouee_le
from session_archives a
left join players p on p.user_id = a.deleted_by
order by a.deleted_at desc;

-- 2. La restaurer (une seule transaction : en cas d'échec, rien n'est modifié).
select restore_session_archive('<session_id>');
```

Ou depuis la ligne de commande :

```powershell
npx supabase db query --linked "select restore_session_archive('<session_id>')"
```

La session revient à l'identique pour tous ses participants (équipes, présence, trous joués et
leur par, scores, photos et couverture, natures, championnat, compte rendu, météo) et réapparaît
dans l'historique, les statistiques, les badges et le championnat au prochain affichage. Aucune
notification n'est envoyée. L'archive est alors supprimée ; une nouvelle suppression en créera
une autre.

Le résultat dit ce qui a dû changer :

- `new_code: true` : son code avait été attribué à une autre session, un nouveau a été tiré ;
- `event_unlinked: true` : son événement a été supprimé ou a déjà une autre session (une seule
  par événement, Q223), elle revient sans lien avec lui ;
- `spot_unlinked: true` : son spot a été supprimé, elle revient sans lien avec lui (le nom du
  lieu et la ville restent).

Refus : si un trou, un compte, un joueur ou l'association de la session a été supprimé
entre-temps, la restauration échoue sans rien modifier et l'archive reste ; le message nomme
l'élément manquant, par exemple
`restore_refused: Key (hole_id)=(…) is not present in table "holes".`
