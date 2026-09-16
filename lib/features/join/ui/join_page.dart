import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_loading.dart';
import '../../sessions/data/sessions_repository.dart';

/// `/join/:code` (plan 09, Q15): calls `join_session` once on entry and
/// moves on to the waiting room / session route on success. A signed-out
/// visitor never reaches this page directly -- `authGuard` remembers the
/// code and sends them through `/login` first.
class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key, required this.code});

  final String code;

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Deferred past the first frame, not called synchronously from
    // initState: a mocked (or otherwise synchronously-failing) repository
    // call can throw before any `await` ever yields, and every branch below
    // reads `context` (for `AppLocalizations.of`) -- unsafe before the
    // widget has finished mounting.
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  Future<void> _join() async {
    try {
      final session = await ref
          .read(sessionsRepositoryProvider)
          .joinByCode(widget.code);
      if (mounted) context.go('/session/${session.id}');
    } on PostgrestException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loading = false;
        _error = switch (error.message) {
          'session_unavailable' => l10n.joinErrorUnavailable,
          'not_in_team' => l10n.joinErrorNotInTeam,
          _ => describeError(error, l10n),
        };
      });
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loading = false;
        _error = describeError(error, l10n);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Scaffold(body: NuniLoading(message: l10n.joinLoading));
    }
    return Scaffold(
      body: NuniEmptyState(
        icon: PhosphorIcons.warningCircle,
        message: _error ?? l10n.errorGeneric,
        action: NuniButton(
          label: l10n.sessionsRoomBackHome,
          onPressed: () => context.go('/'),
        ),
      ),
    );
  }
}
