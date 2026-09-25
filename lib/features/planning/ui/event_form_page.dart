import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_empty_state.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_form_section.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_location_picker.dart';
import '../../associations/data/associations_repository.dart';
import '../../players/data/players_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player.dart';
import '../data/events_repository.dart';
import '../domain/event.dart';
import '../domain/planning.dart';
import 'event_widgets.dart';

/// `/planning/new`, `/planning/new?from=:id` (a clone, Q152) and
/// `/planning/:id/edit` (plan 23): date and time and a label are required,
/// everything else is optional -- an event can open for answers before its
/// place is decided (Q150).
class EventFormPage extends ConsumerWidget {
  const EventFormPage({super.key, this.eventId, this.cloneOfId});

  /// The event edited, or null for a new one.
  final String? eventId;

  /// The event a new one is cloned from.
  final String? cloneOfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final title = eventId == null
        ? l10n.planningFormNewTitle
        : l10n.planningFormEditTitle;
    final sourceId = eventId ?? cloneOfId;
    final player = ref.watch(myPlayerProvider);

    Widget scaffold(Widget body) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );

    if (sourceId == null) {
      return player.when(
        data: (player) => player.associationId == null
            ? scaffold(
                NuniEmptyState(
                  icon: PhosphorIcons.calendarDots,
                  message: l10n.planningNoAssociation,
                ),
              )
            : _EventForm(
                title: title,
                associationId: player.associationId!,
                initial: EventDraft(
                  startsAt: _defaultStart(),
                  label: '',
                  managerPlayerId: player.id,
                ),
              ),
        loading: () => scaffold(const NuniLoading()),
        error: (error, _) =>
            scaffold(NuniErrorBanner(message: describeError(error, l10n))),
      );
    }

    return ref
        .watch(eventByIdProvider(sourceId))
        .when(
          data: (event) => event == null
              ? scaffold(
                  NuniEmptyState(
                    icon: PhosphorIcons.calendarBlank,
                    message: l10n.planningEventNotFound,
                  ),
                )
              : _EventForm(
                  title: title,
                  eventId: eventId,
                  associationId: event.associationId,
                  initial: eventId != null
                      ? EventDraft(
                          startsAt: event.startsAt.toLocal(),
                          label: event.label,
                          spot: event.spot,
                          lat: event.locationLat,
                          lng: event.locationLng,
                          managerPlayerId: event.managerPlayerId,
                          description: event.description,
                          color: event.color,
                        )
                      : cloneDraft(event),
                ),
          loading: () => scaffold(const NuniLoading()),
          error: (error, _) =>
              scaffold(NuniErrorBanner(message: describeError(error, l10n))),
        );
  }

  /// Next week, same weekday, 19:00: a starting point, changed in two taps.
  static DateTime _defaultStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 7, 19);
  }
}

class _EventForm extends ConsumerStatefulWidget {
  const _EventForm({
    required this.title,
    required this.associationId,
    required this.initial,
    this.eventId,
  });

  final String title;
  final String associationId;
  final EventDraft initial;
  final String? eventId;

  @override
  ConsumerState<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends ConsumerState<_EventForm> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.initial.label);
  late final _spot = TextEditingController(text: widget.initial.spot);
  late final _description = TextEditingController(
    text: widget.initial.description,
  );
  final _labelFocus = FocusNode();
  final _spotFocus = FocusNode();

  late DateTime _startsAt = widget.initial.startsAt;
  late LatLng? _point = widget.initial.lat == null || widget.initial.lng == null
      ? null
      : LatLng(widget.initial.lat!, widget.initial.lng!);
  late String? _managerId = widget.initial.managerPlayerId;
  late EventColor? _color = widget.initial.color;

  /// Bumped when the point is set from outside the map (a known spot), so the
  /// map is rebuilt centred on it.
  int _mapVersion = 0;
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _spot.dispose();
    _description.dispose();
    _labelFocus.dispose();
    _spotFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (picked == null) return;
    setState(() {
      _startsAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _startsAt.hour,
        _startsAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (picked == null) return;
    setState(() {
      _startsAt = DateTime(
        _startsAt.year,
        _startsAt.month,
        _startsAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _chooseSpot(SpotSuggestion spot) {
    _spot.text = spot.name;
    if (spot.lat != null && spot.lng != null) {
      setState(() {
        _point = LatLng(spot.lat!, spot.lng!);
        _mapVersion++;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final draft = EventDraft(
      startsAt: _startsAt,
      label: _label.text,
      spot: _spot.text,
      lat: _point?.latitude,
      lng: _point?.longitude,
      managerPlayerId: _managerId,
      description: _description.text,
      color: _color,
    );
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final id = widget.eventId;
      if (id == null) {
        final created = await repo.create(draft);
        ref.invalidate(myPlanningProvider);
        if (mounted) context.pushReplacement('/planning/$created');
      } else {
        await repo.update(id, draft);
        ref
          ..invalidate(myPlanningProvider)
          ..invalidate(eventByIdProvider(id));
        if (mounted) context.pop();
      }
      ref
        ..invalidate(eventLabelSuggestionsProvider(widget.associationId))
        ..invalidate(spotSuggestionsForProvider(widget.associationId));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(describePlanningError(error, l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final labels =
        ref.watch(eventLabelSuggestionsProvider(widget.associationId)).value ??
        const <String>[];
    final spots =
        ref.watch(spotSuggestionsForProvider(widget.associationId)).value ??
        const <SpotSuggestion>[];
    final members =
        ref.watch(associationPlayersProvider(widget.associationId)).value ??
        const <Player>[];
    final association = ref
        .watch(associationByIdProvider(widget.associationId))
        .value;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            NuniFormSection(
              title: l10n.planningFormDate,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(PhosphorIcons.calendarBlank, size: 18),
                        label: Text(
                          DateFormat.yMMMEd(locale).format(_startsAt),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(PhosphorIcons.clock, size: 18),
                      label: Text(DateFormat.Hm(locale).format(_startsAt)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SuggestField<String>(
                  controller: _label,
                  focusNode: _labelFocus,
                  label: l10n.planningFormLabel,
                  options: labels,
                  display: (label) => label,
                  onSelected: (label) => _label.text = label,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.planningFormLabelRequired
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.sessionsCreateSectionLocation,
              children: [
                _SuggestField<SpotSuggestion>(
                  controller: _spot,
                  focusNode: _spotFocus,
                  label: l10n.planningFormSpot,
                  options: spots,
                  display: (spot) => spot.name,
                  onSelected: _chooseSpot,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.planningFormPoint,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.planningFormPointHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                NuniLocationPicker(
                  // Rebuilt when the association arrives, to open on its city.
                  key: ValueKey((_mapVersion, association?.id)),
                  value: _point,
                  initialCenter: association == null
                      ? null
                      : LatLng(
                          association.locationLat,
                          association.locationLng,
                        ),
                  zoom: 16,
                  centerZoom: 13,
                  onChanged: (point) => setState(() => _point = point),
                ),
                if (_point != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _point = null),
                      icon: const Icon(PhosphorIcons.x, size: 18),
                      label: Text(l10n.planningFormPointClear),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.planningFormManager,
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: members.any((m) => m.id == _managerId)
                      ? _managerId
                      : null,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(child: Text(l10n.planningFormNoManager)),
                    for (final member in members)
                      DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _managerId = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.planningFormDescription,
              children: [
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.planningFormColor,
              children: [
                _ColorPicker(
                  value: _color,
                  onChanged: (color) => setState(() => _color = color),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: NuniButton(
            label: widget.eventId == null
                ? l10n.planningFormSubmitCreate
                : l10n.commonSave,
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
    );
  }
}

/// A text field offering what the association already used (labels, spots:
/// Q148), filtered as one types; anything typed is accepted too.
class _SuggestField<T extends Object> extends StatelessWidget {
  const _SuggestField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.options,
    required this.display,
    required this.onSelected,
    this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final List<T> options;
  final String Function(T) display;
  final ValueChanged<T> onSelected;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: display,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        return options.where(
          (option) =>
              display(option).toLowerCase().contains(query) &&
              display(option) != value.text,
        );
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(labelText: label),
            textCapitalization: TextCapitalization.sentences,
            validator: validator,
            onFieldSubmitted: (_) => onSubmitted(),
          ),
      optionsViewBuilder: (context, onSelect, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(NuniRadius.control),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 480),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    dense: true,
                    title: Text(display(option)),
                    onTap: () => onSelect(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// No colour, or one of the eight hues (Q149), as round swatches.
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.value, required this.onChanged});

  final EventColor? value;
  final ValueChanged<EventColor?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    Widget swatch(EventColor? color, String name) {
      final selected = value == color;
      final hue = eventHue(color);
      return Tooltip(
        message: name,
        child: Semantics(
          label: name,
          selected: selected,
          button: true,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => onChanged(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hue ?? scheme.surface,
                border: Border.all(
                  color: selected ? scheme.onSurface : context.nuni.border,
                  width: selected ? 3 : 1,
                ),
              ),
              child: hue == null
                  ? Icon(
                      PhosphorIcons.x,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    )
                  : selected
                  ? Icon(PhosphorIcons.check, size: 20, color: scheme.surface)
                  : null,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        swatch(null, l10n.planningFormNoColor),
        for (final color in EventColor.values)
          swatch(color, eventColorName(l10n, color)),
      ],
    );
  }
}
