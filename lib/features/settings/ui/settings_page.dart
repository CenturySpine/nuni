import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_legal_footer.dart';
import '../../../shared/nuni_section_header.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final player = ref.watch(myPlayerProvider).value;
    final danger = context.nuni.danger;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          NuniCard(
            onTap: () => context.push('/profile'),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                NuniAvatar(
                  name: player?.name,
                  imageUrl: player?.avatarUrl,
                  size: 52,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player?.name ?? l10n.profileTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.profileTitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.caretRight,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          NuniSectionHeader(title: l10n.settingsLanguage),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Locale?>(
              showSelectedIcon: false,
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
          const SizedBox(height: 28),
          NuniGroupedList(
            children: [
              ListTile(
                leading: const NuniIconTile(
                  icon: PhosphorIcons.info,
                  tone: NuniTone.neutral,
                  size: 36,
                ),
                title: Text(l10n.settingsVersion),
                trailing: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) =>
                      Text(snapshot.data?.version ?? ''),
                ),
              ),
              ListTile(
                leading: const NuniIconTile(
                  icon: PhosphorIcons.signOut,
                  tone: NuniTone.danger,
                  size: 36,
                ),
                title: Text(
                  l10n.settingsSignOut,
                  style: TextStyle(color: danger.onContainer),
                ),
                onTap: () => ref.read(authRepositoryProvider).signOut(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const NuniLegalFooter(),
        ],
      ),
    );
  }
}
