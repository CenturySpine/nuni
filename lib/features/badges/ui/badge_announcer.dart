import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../data/badges_repository.dart';
import '../data/seen_badges_store.dart';
import '../domain/badge.dart';
import '../domain/compute_badges.dart';
import 'badge_medal.dart';
import 'badge_texts.dart';

/// Announces my new badges (plan 21, "Annonce d'un nouveau badge"), once
/// for the whole app: whenever my badges are (re)computed -- at start, and
/// when a session I play in ends (the live screen reloads my history) --
/// badges this device hasn't announced yet show in one sheet, with up to 3
/// badges close to being earned (Q128). The very first time, every badge
/// already earned is announced in a single sheet (Q97).
class BadgeAnnouncer extends ConsumerStatefulWidget {
  const BadgeAnnouncer({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  /// The router's navigator, which shows the sheet above any page.
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<BadgeAnnouncer> createState() => _BadgeAnnouncerState();
}

class _BadgeAnnouncerState extends ConsumerState<BadgeAnnouncer> {
  StreamSubscription<AuthState>? _auth;
  String? _userId;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(supabaseClientProvider).auth;
    _userId = auth.currentUser?.id;
    _auth = auth.onAuthStateChange.listen((state) {
      final userId = state.session?.user.id;
      if (userId != _userId && mounted) setState(() => _userId = userId);
    });
  }

  @override
  void dispose() {
    _auth?.cancel();
    super.dispose();
  }

  Future<void> _check(List<BadgeResult> results) async {
    final userId = _userId;
    if (userId == null || _showing) return;
    final store = SeenBadgesStore(userId);
    final announced = await store.announced();
    final earned = [
      for (final r in results)
        if (r.earned) r,
    ];
    final fresh = [
      for (final r in earned)
        if (announced == null || !announced.contains(r.id)) r,
    ];
    await store.markAnnounced([for (final r in earned) r.id]);
    if (fresh.isEmpty) return;

    final context = widget.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    _showing = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => NewBadgesSheet(
          badges: fresh,
          near: announced == null ? const [] : nearBadges(results),
          firstTime: announced == null,
        ),
      );
    } finally {
      _showing = false;
    }
  }

  /// The last computation checked, so a rebuild never announces twice.
  List<BadgeResult>? _checked;

  @override
  Widget build(BuildContext context) {
    if (_userId != null) {
      // Watching also keeps my badges computed while the app runs.
      final results = ref.watch(myBadgesProvider).value;
      if (results != null && !identical(results, _checked)) {
        _checked = results;
        WidgetsBinding.instance.addPostFrameCallback((_) => _check(results));
      }
    }
    return widget.child;
  }
}

/// "New badges!" (plan 21): the medals just earned, then the badges close
/// to being earned. The first time, "Your badges" with every badge already
/// earned by past sessions, and no near badges.
class NewBadgesSheet extends StatelessWidget {
  const NewBadgesSheet({
    super.key,
    required this.badges,
    required this.near,
    required this.firstTime,
  });

  final List<BadgeResult> badges;
  final List<BadgeResult> near;
  final bool firstTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                firstTime ? l10n.badgesFirstTitle : l10n.badgesNewTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (firstTime) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.badgesFirstSubtitle(badges.length),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 16,
                children: [
                  for (final badge in badges)
                    SizedBox(
                      width: 96,
                      child: Column(
                        children: [
                          BadgeMedal(id: badge.id, earned: true, size: 72),
                          const SizedBox(height: 6),
                          Text(
                            l10n.badgeName(badge.id),
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (near.isNotEmpty) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.badgesNearTitle,
                    style: textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                for (final badge in near)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        BadgeMedal(id: badge.id, earned: false, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.badgeName(badge.id),
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: badge.ratio,
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.badgesProgress(badge.progress, badge.id.target!),
                          style: textTheme.labelMedium?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: NuniButton(
                  label: l10n.badgesClose,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
