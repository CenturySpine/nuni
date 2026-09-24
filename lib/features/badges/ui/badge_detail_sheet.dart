import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../domain/badge.dart';
import 'badge_medal.dart';
import 'badge_texts.dart';

/// One badge in detail (plan 21, "Détail"): the large medal, its name and
/// condition, then when it was earned -- with a link to the session that
/// earned it on my own page -- or how far along a counter badge is.
Future<void> showBadgeDetailSheet(
  BuildContext context,
  BadgeResult result, {
  required bool isMe,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => _BadgeDetail(result: result, isMe: isMe),
);

class _BadgeDetail extends StatelessWidget {
  const _BadgeDetail({required this.result, required this.isMe});

  final BadgeResult result;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final id = result.id;
    final target = id.target;
    final earnedAt = result.earnedAt;
    final sessionId = result.sessionId;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeMedal(id: id, earned: result.earned, size: 120),
            const SizedBox(height: 16),
            Text(
              l10n.badgeName(id),
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.badgeFamilyName(id.family),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.badgeCondition(id),
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (earnedAt != null)
              Text(
                l10n.badgesEarnedOn(DateFormat.yMMMMd(locale).format(earnedAt)),
                style: textTheme.titleSmall,
              )
            else if (target != null && target > 1) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.ratio,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.badgesProgress(result.progress, target),
                style: textTheme.titleSmall,
              ),
            ] else
              Text(
                l10n.badgesToEarn,
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (isMe && sessionId != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: NuniButton(
                  variant: NuniButtonVariant.secondary,
                  icon: PhosphorIcons.clockCounterClockwise,
                  label: l10n.badgesSeeSession,
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/history/$sessionId');
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
