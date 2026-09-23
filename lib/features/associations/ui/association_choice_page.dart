import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_list_card.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_logo.dart';
import '../../profile/data/profile_repository.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';
import 'association_logo.dart';

/// First sign-in (plan 18, decision 1): a player with no association, and no
/// creation request pending, picks one before anything else. The nearest
/// association is pre-selected when the position is known; otherwise the
/// list is alphabetical with nothing selected. "Mine isn't listed" opens a
/// creation request (Q81).
class AssociationChoicePage extends ConsumerStatefulWidget {
  const AssociationChoicePage({super.key});

  @override
  ConsumerState<AssociationChoicePage> createState() =>
      _AssociationChoicePageState();
}

class _AssociationChoicePageState extends ConsumerState<AssociationChoicePage> {
  ({double lat, double lng})? _position;
  bool _locating = true;
  String? _selectedId;
  bool _preselected = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  Future<void> _locate() async {
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (position != null) {
        _position = (lat: position.latitude, lng: position.longitude);
      }
    });
  }

  Future<void> _confirm() async {
    final id = _selectedId;
    if (id == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref.read(associationsRepositoryProvider).join(id);
      ref.invalidate(myPlayerProvider);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final associationsAsync = ref.watch(associationsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: associationsAsync.when(
          loading: () => const NuniLoading(),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: NuniErrorBanner(
              message: describeError(error, l10n),
              onRetry: () => ref.invalidate(associationsProvider),
            ),
          ),
          data: (all) {
            if (_locating) return const NuniLoading();
            final sorted = sortForChoice(
              [
                for (final a in all)
                  if (a.status == AssociationStatus.approved) a,
              ],
              lat: _position?.lat,
              lng: _position?.lng,
            );
            // Nearest one pre-selected, once, when the position is known.
            if (!_preselected) {
              _preselected = true;
              if (_position != null && sorted.isNotEmpty) {
                _selectedId = sorted.first.id;
              }
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                const Center(child: NuniLogo(size: 56)),
                const SizedBox(height: 20),
                Text(
                  l10n.associationsChoiceTitle,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _position == null
                      ? l10n.associationsChoiceIntroNoPosition
                      : l10n.associationsChoiceIntro,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                for (final association in sorted) ...[
                  _ChoiceRow(
                    association: association,
                    selected: association.id == _selectedId,
                    distanceKm: _position == null
                        ? null
                        : distanceKm(
                            _position!.lat,
                            _position!.lng,
                            association.locationLat,
                            association.locationLng,
                          ),
                    onTap: () => setState(() => _selectedId = association.id),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/associations/new'),
                    child: Text(l10n.associationsChoiceNotListed),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: NuniButton(
            label: l10n.associationsChoiceConfirm,
            onPressed: _selectedId == null || _saving ? null : _confirm,
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.association,
    required this.selected,
    required this.distanceKm,
    required this.onTap,
  });

  final Association association;
  final bool selected;
  final double? distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = context.nuni.primaryTone;
    return NuniListCard(
      leading: AssociationLogo(association: association),
      title: association.name,
      subtitle: distanceKm == null
          ? association.city
          : '${association.city} · ${l10n.associationsDistanceKm(distanceKm!.round())}',
      color: selected ? tone.container : null,
      borderColor: selected ? context.nuni.primaryInk : null,
      trailing: Icon(
        selected ? PhosphorIcons.checkCircle : null,
        color: context.nuni.primaryInk,
      ),
      onTap: onTap,
    );
  }
}
