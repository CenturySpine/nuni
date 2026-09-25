import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_form_section.dart';
import '../../../shared/nuni_loading.dart';
import '../../associations/data/associations_repository.dart';
import '../../planning/data/events_repository.dart';
import '../data/spots_repository.dart';
import '../domain/spot.dart';
import 'spot_place_field.dart';

/// `/associations/:id/spots/new` and `/associations/:id/spots/:spotId`
/// (plan 28, staff only -- the base refuses anyone else): a spot's name,
/// description and place. The point is required (Q181).
class SpotFormPage extends ConsumerWidget {
  const SpotFormPage({super.key, required this.associationId, this.spotId});

  final String associationId;

  /// The spot edited, or null for a new one.
  final String? spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (spotId == null) {
      return _SpotForm(associationId: associationId);
    }
    Widget scaffold(Widget body) => Scaffold(
      appBar: AppBar(title: Text(l10n.spotsEditTitle)),
      body: body,
    );
    return ref
        .watch(associationSpotsProvider(associationId))
        .when(
          data: (spots) {
            final spot = spots.where((s) => s.id == spotId).firstOrNull;
            return spot == null
                ? scaffold(
                    NuniEmptyState(
                      icon: PhosphorIcons.mapPin,
                      message: l10n.spotsNotFound,
                    ),
                  )
                : _SpotForm(associationId: associationId, spot: spot);
          },
          loading: () => scaffold(const NuniLoading()),
          error: (error, _) =>
              scaffold(NuniErrorBanner(message: describeError(error, l10n))),
        );
  }
}

class _SpotForm extends ConsumerStatefulWidget {
  const _SpotForm({required this.associationId, this.spot});

  final String associationId;
  final Spot? spot;

  @override
  ConsumerState<_SpotForm> createState() => _SpotFormState();
}

class _SpotFormState extends ConsumerState<_SpotForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.spot?.name);
  late final _description = TextEditingController(
    text: widget.spot?.description,
  );
  late SpotPlace? _place = widget.spot?.hasLocation ?? false
      ? (
          lat: widget.spot!.locationLat!,
          lng: widget.spot!.locationLng!,
          address: widget.spot!.address,
          city: widget.spot!.city,
        )
      : null;
  late bool _variable = widget.spot?.variableLocation ?? false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _refreshLists() {
    ref
      ..invalidate(associationSpotsProvider(widget.associationId))
      // Renames and deletions reach the events' places (spots_propagate).
      ..invalidate(myPlanningProvider);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final place = _place;
    // A point is required (Q181), except for a variable location (Q186), or
    // to edit a spot taken over without one (Q185). Turning a variable
    // location into a fixed one needs a point too.
    if (!_variable &&
        place == null &&
        (widget.spot == null || widget.spot!.variableLocation)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.spotsErrorLocationRequired)));
      return;
    }
    setState(() => _busy = true);
    // Empty strings clear a field on an edit; null would keep it.
    final draft = _variable
        ? SpotDraft(
            name: _name.text,
            description: _description.text.trim(),
            variableLocation: true,
          )
        : SpotDraft(
            name: _name.text,
            description: _description.text.trim(),
            address: place == null ? null : place.address ?? '',
            city: place == null ? null : place.city ?? '',
            lat: place?.lat,
            lng: place?.lng,
            variableLocation: false,
          );
    try {
      final repo = ref.read(spotsRepositoryProvider);
      if (widget.spot == null) {
        await repo.create(widget.associationId, draft);
      } else {
        await repo.update(widget.spot!.id, draft);
      }
      _refreshLists();
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(describeSpotError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final spot = widget.spot!;
    setState(() => _busy = true);
    try {
      final usage = await ref.read(spotsRepositoryProvider).usage(spot.id);
      if (!mounted) return;
      final confirmed = await NuniConfirmDialog.show(
        context,
        title: l10n.spotsDeleteTitle(spot.name),
        message: usage.sessions + usage.events == 0
            ? l10n.spotsDeleteUnused
            : l10n.spotsDeleteUsed(usage.sessions, usage.events),
        confirmLabel: l10n.spotsDelete,
        danger: true,
      );
      if (!confirmed) return;
      await ref.read(spotsRepositoryProvider).delete(spot.id);
      _refreshLists();
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(describeSpotError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final association = ref
        .watch(associationByIdProvider(widget.associationId))
        .value;
    final isNew = widget.spot == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.spotsNewTitle : l10n.spotsEditTitle),
        actions: [
          if (!isNew)
            IconButton(
              tooltip: l10n.spotsDelete,
              icon: const Icon(PhosphorIcons.trash),
              onPressed: _busy ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            NuniFormSection(
              title: l10n.spotsSectionSpot,
              children: [
                TextFormField(
                  controller: _name,
                  maxLength: spotNameMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(labelText: l10n.spotsNameLabel),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.spotsNameRequired
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.spotsDescriptionLabel,
                    hintText: l10n.spotsDescriptionHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.spotsSectionPlace,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.spotsVariableLabel),
                  subtitle: Text(l10n.spotsVariableHint),
                  value: _variable,
                  onChanged: (value) => setState(() => _variable = value),
                ),
                if (!_variable) ...[
                  const SizedBox(height: 8),
                  SpotPlaceField(
                    // Rebuilt when the association arrives, to open on its city.
                    key: ValueKey(association?.id),
                    value: _place,
                    initialCenter: association == null
                        ? null
                        : LatLng(
                            association.locationLat,
                            association.locationLng,
                          ),
                    onChanged: (place) => setState(() => _place = place),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: NuniButton(
            label: isNew ? l10n.spotsAdd : l10n.commonSave,
            onPressed: _busy ? null : _save,
          ),
        ),
      ),
    );
  }
}
