import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/authorization/authorization_repository.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/palette_controller.dart';
import '../../../core/theme/palettes.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_avatar.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_icon_tile.dart';
import '../../../shared/nuni_legal_footer.dart';
import '../../../shared/nuni_section_header.dart';
import '../../associations/data/associations_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final palette = ref.watch(paletteControllerProvider);
    final player = ref.watch(myPlayerProvider).value;
    final danger = context.nuni.danger;
    final myAssociation = player?.associationId == null
        ? null
        : ref.watch(associationByIdProvider(player!.associationId!)).value;
    final isSuperAdmin = ref.watch(isSuperAdminProvider).value ?? false;
    final pendingCount = isSuperAdmin
        ? ref.watch(pendingRequestsProvider).value?.length ?? 0
        : 0;

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
          NuniSectionHeader(title: l10n.settingsColors),
          for (var row = 0; row < allPalettes.length; row += 2) ...[
            if (row > 0) const SizedBox(height: 12),
            Row(
              children: [
                for (final (index, option)
                    in allPalettes.skip(row).take(2).indexed) ...[
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _PaletteOption(
                      palette: option,
                      label: _paletteLabel(l10n, option),
                      selected: option == palette,
                      onTap: () => ref
                          .read(paletteControllerProvider.notifier)
                          .setPalette(option),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 28),
          NuniGroupedList(
            children: [
              ListTile(
                leading: const NuniIconTile(
                  icon: PhosphorIcons.usersThree,
                  tone: NuniTone.primary,
                  size: 36,
                ),
                title: Text(l10n.settingsMyAssociation),
                subtitle: Text(
                  myAssociation?.name ?? l10n.settingsNoAssociation,
                ),
                trailing: const Icon(PhosphorIcons.caretRight, size: 18),
                onTap: () => context.push(
                  myAssociation == null
                      ? '/associations'
                      : '/associations/${myAssociation.id}',
                ),
              ),
              // Super_admin only (plan 18, Q86): requests awaiting review.
              if (isSuperAdmin)
                ListTile(
                  leading: const NuniIconTile(
                    icon: PhosphorIcons.shieldCheck,
                    tone: NuniTone.highlight,
                    size: 36,
                  ),
                  title: Text(l10n.associationsAdminTitle),
                  trailing: pendingCount == 0
                      ? const Icon(PhosphorIcons.caretRight, size: 18)
                      : Badge(label: Text('$pendingCount')),
                  onTap: () => context.push('/admin/requests'),
                ),
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

String _paletteLabel(AppLocalizations l10n, Palette palette) =>
    switch (palette.id) {
      'coral' => l10n.settingsPaletteCoral,
      'pop' => l10n.settingsPalettePop,
      'ocean' => l10n.settingsPaletteOcean,
      'lagoon' => l10n.settingsPaletteLagoon,
      'olive' => l10n.settingsPaletteOlive,
      _ => l10n.settingsPaletteSunset,
    };

/// One choice of the colour picker: a strip of the palette's brand gradient
/// and accents, its name, and a check when selected.
class _PaletteOption extends StatelessWidget {
  const _PaletteOption({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Palette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nuni = context.nuni;
    return Semantics(
      selected: selected,
      button: true,
      child: NuniCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        borderColor: selected ? nuni.primaryInk : null,
        color: selected ? nuni.primaryTone.container : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.heroStart, palette.heroEnd],
                ),
                borderRadius: BorderRadius.circular(NuniRadius.small),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final accent in [
                    palette.highlight.base,
                    palette.fairway.base,
                    palette.sunshine.base,
                  ])
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.onPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (selected)
                  Icon(
                    PhosphorIcons.checkCircle,
                    size: 20,
                    color: nuni.primaryInk,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
