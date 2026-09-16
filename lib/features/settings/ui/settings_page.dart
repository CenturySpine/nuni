import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/phosphor_icons.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../../shared/nuni_legal_footer.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(PhosphorIcons.userCircle),
            title: Text(l10n.profileTitle),
            trailing: const Icon(PhosphorIcons.caretRight),
            onTap: () => context.push('/profile'),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsLanguage),
            trailing: SegmentedButton<Locale?>(
              segments: [
                ButtonSegment(
                  value: null,
                  label: Text(l10n.settingsLanguageSystem),
                ),
                ButtonSegment(
                  value: const Locale('fr'),
                  label: Text(l10n.settingsLanguageFrench),
                ),
                ButtonSegment(
                  value: const Locale('en'),
                  label: Text(l10n.settingsLanguageEnglish),
                ),
              ],
              selected: {locale},
              onSelectionChanged: (selection) async {
                final newLocale = selection.first;
                await ref
                    .read(localeControllerProvider.notifier)
                    .setLocale(newLocale);
                // Only a concrete language syncs to the account -- "System"
                // has no single value the `players.locale` column (a plain
                // language code) could hold.
                if (newLocale != null) {
                  try {
                    await ref
                        .read(profileRepositoryProvider)
                        .updateMyLocale(newLocale.languageCode);
                  } catch (_) {
                    // The local override already applied; account sync is a
                    // cross-device convenience, not worth surfacing a retry.
                  }
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsVersion),
            trailing: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) =>
                  Text(snapshot.data?.version ?? ''),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(PhosphorIcons.signOut),
            title: Text(l10n.settingsSignOut),
            onTap: () => ref.read(authRepositoryProvider).signOut(),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: NuniLegalFooter(),
          ),
        ],
      ),
    );
  }
}
