import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
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
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.profileTitle),
            trailing: const Icon(Icons.chevron_right),
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
              onSelectionChanged: (selection) => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(selection.first),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: NuniLegalFooter(),
          ),
        ],
      ),
    );
  }
}
