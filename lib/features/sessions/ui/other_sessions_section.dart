import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_card.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_section_header.dart';
import '../../../shared/nuni_status_pill.dart';
import '../data/show_other_sessions_pref.dart';

/// A super_admin's "Autres sessions" (plan 38), under home's own sessions
/// and under the history: its heading, the "Voir toutes les sessions"
/// switch -- one setting for both pages (Q278), so it stays visible when
/// off -- then, when on, [entries] built by [itemBuilder]. [entries] is
/// only read while the switch is on, so nothing is fetched while it's off.
class OtherSessionsSection<T> extends ConsumerWidget {
  const OtherSessionsSection({
    super.key,
    required this.entries,
    required this.itemBuilder,
    this.emptyMessage,
  });

  /// Reads the section's list; called only while the switch is on.
  final AsyncValue<List<T>> Function(WidgetRef ref) entries;
  final Widget Function(T entry) itemBuilder;

  /// Shown instead of the list when it's empty (a filter that matches
  /// nothing); "no other session" by default.
  final String? emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final show = ref.watch(showOtherSessionsPrefProvider).value ?? true;
    final list = show ? entries(ref) : null;
    final count = list?.asData?.value.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NuniSectionHeader(
          title: l10n.otherSessionsTitle,
          trailing: count == 0
              ? null
              : NuniStatusPill(label: '$count', tone: NuniTone.neutral),
        ),
        NuniCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: SwitchListTile(
            title: Text(l10n.otherSessionsShowAll),
            subtitle: Text(l10n.otherSessionsShowAllHelp),
            value: show,
            onChanged: (value) =>
                ref.read(showOtherSessionsPrefProvider.notifier).set(value),
          ),
        ),
        if (list != null) ...[
          const SizedBox(height: 10),
          list.when(
            data: (items) => items.isEmpty
                ? NuniCard(
                    child: Text(
                      emptyMessage ?? l10n.otherSessionsEmpty,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items) ...[
                        itemBuilder(item),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: NuniLoading(),
            ),
            error: (error, _) =>
                NuniErrorBanner(message: describeError(error, l10n)),
          ),
        ],
      ],
    );
  }
}
