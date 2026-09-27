import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_status_pill.dart';
import '../domain/session.dart';
import '../domain/session_kind.dart';
import '../domain/session_tag.dart';
import 'session_kind_label.dart';

String sessionTagLabel(AppLocalizations l10n, SessionTag tag) => switch (tag) {
  SessionTag.training => l10n.sessionTagTraining,
  SessionTag.simulator => l10n.sessionTagSimulator,
  SessionTag.associationLife => l10n.sessionTagAssociationLife,
};

IconData sessionTagIcon(SessionTag tag) => switch (tag) {
  SessionTag.training => PhosphorIcons.barbell,
  SessionTag.simulator => PhosphorIcons.monitorPlay,
  SessionTag.associationLife => PhosphorIcons.confetti,
};

/// Where a session was held, "city · place", or null when unknown.
String? sessionPlaceLine(Session session) {
  final parts = [
    if (session.city case final city? when city.isNotEmpty) city,
    if (session.zone case final zone? when zone.isNotEmpty) zone,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// A session's title (plan 31, Q205): its name when it has one, else its
/// place as before, else its code.
String sessionHeading(Session session) =>
    session.title ?? sessionPlaceLine(session) ?? session.code;

/// What goes under [sessionHeading]: the place, when the name took the
/// title's spot.
String? sessionSubheading(Session session) =>
    session.title == null ? null : sessionPlaceLine(session);

/// A session's natures as words (plan 29), for a one-line summary: "Course",
/// its format, then its tags.
List<String> sessionNatureLabels(AppLocalizations l10n, Session session) => [
  if (session.hasScoring) l10n.sessionNatureCourse,
  if (session.kind case final kind?) sessionKindLabel(l10n, kind),
  for (final tag in SessionTag.values)
    if (session.hasTag(tag)) sessionTagLabel(l10n, tag),
];

/// A session's pills (plan 29, Q187): one row, the same look for every
/// nature -- "Course" and its format, the tags -- then the championship.
class SessionNaturePills extends StatelessWidget {
  const SessionNaturePills({
    super.key,
    required this.session,
    this.trailing = const [],
  });

  final Session session;

  /// Pills appended to the row (the weather...).
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (session.hasScoring)
          NuniStatusPill(
            label: l10n.sessionNatureCourse,
            icon: PhosphorIcons.golf,
          ),
        if (session.kind case final kind?)
          NuniStatusPill(
            label: sessionKindLabel(l10n, kind),
            icon: kind == SessionKind.team
                ? PhosphorIcons.users
                : PhosphorIcons.user,
          ),
        for (final tag in SessionTag.values)
          if (session.hasTag(tag))
            NuniStatusPill(
              label: sessionTagLabel(l10n, tag),
              icon: sessionTagIcon(tag),
            ),
        if (session.isChampionship)
          NuniStatusPill(
            label: l10n.championshipTitle,
            icon: PhosphorIcons.crown,
            tone: NuniTone.sunshine,
          ),
        ...trailing,
      ],
    );
  }
}
