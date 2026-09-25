import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_form_section.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/photo_field.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/ui/avatar_crop_dialog.dart';
import '../data/associations_repository.dart';
import '../domain/association.dart';
import '../../../shared/nuni_location_picker.dart';
import 'association_logo.dart';

/// `/associations/new` (a creation request, plan 18 decision 8) and
/// `/associations/:id/edit` (its local manager or a super_admin, decision 7).
/// Mandatory for a request: name, city and its point on the map, e-mail and
/// phone; abbreviation, website and the message are optional. The logo is
/// only offered once the association exists.
class AssociationFormPage extends ConsumerStatefulWidget {
  const AssociationFormPage({super.key, this.associationId});

  /// Null for a creation request.
  final String? associationId;

  @override
  ConsumerState<AssociationFormPage> createState() =>
      _AssociationFormPageState();
}

class _AssociationFormPageState extends ConsumerState<AssociationFormPage> {
  final _name = TextEditingController();
  final _shortName = TextEditingController();
  final _city = TextEditingController();
  final _website = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  final _partners = <_PartnerRow>[];
  LatLng? _location;
  LatLng? _myPosition;
  Association? _association;

  /// Whether the e-mail/phone fields apply: always for a request; for an
  /// edit, only when I am this association's manager (a super_admin editing
  /// someone else's association has no contact details of their own here).
  bool _hasContact = false;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingLogo = false;
  bool _submitted = false;

  bool get _isRequest => widget.associationId == null;

  @override
  void initState() {
    super.initState();
    // Once a submit was tried, field errors follow the typing.
    for (final controller in [_name, _city, _email, _phone]) {
      controller.addListener(() {
        if (_submitted) setState(() {});
      });
    }
    _load();
  }

  Future<void> _load() async {
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (position != null) {
      _myPosition = LatLng(position.latitude, position.longitude);
    }
    if (_isRequest) {
      _hasContact = true;
    } else {
      final association = await ref.read(
        associationByIdProvider(widget.associationId!).future,
      );
      final contact = await ref
          .read(associationsRepositoryProvider)
          .fetchMyContact(widget.associationId!);
      if (association != null) {
        _association = association;
        _name.text = association.name;
        _shortName.text = association.shortName ?? '';
        _city.text = association.city;
        _website.text = association.websiteUrl ?? '';
        _location = LatLng(association.locationLat, association.locationLng);
        _partners.addAll([
          for (final partner in association.partners)
            _PartnerRow(label: partner.label, url: partner.url),
        ]);
      }
      if (contact != null) {
        _hasContact = true;
        _email.text = contact.email;
        _phone.text = contact.phone;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _shortName,
      _city,
      _website,
      _email,
      _phone,
      _message,
    ]) {
      controller.dispose();
    }
    for (final row in _partners) {
      row.dispose();
    }
    super.dispose();
  }

  void _addPartner() => setState(() => _partners.add(_PartnerRow()));

  void _removePartner(_PartnerRow row) {
    setState(() => _partners.remove(row));
    row.dispose();
  }

  void _reorderPartners(int from, int to) => setState(() {
    final row = _partners.removeAt(from);
    _partners.insert(to, row);
  });

  String? _required(TextEditingController controller) =>
      _submitted && controller.text.trim().isEmpty
      ? AppLocalizations.of(context)!.associationsFieldRequired
      : null;

  String? _emailError() {
    final l10n = AppLocalizations.of(context)!;
    if (!_submitted || !_hasContact) return null;
    final email = _email.text.trim();
    if (email.isEmpty) return l10n.associationsFieldRequired;
    return email.contains('@') ? null : l10n.associationsEmailInvalid;
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty &&
      _location != null &&
      (!_hasContact ||
          (_email.text.trim().contains('@') &&
              _phone.text.trim().isNotEmpty)) &&
      _partners.every((row) => row.isBlank || row.isValid);

  AssociationDraft _draft() => (
    name: _name.text.trim(),
    shortName: _shortName.text.trim(),
    city: _city.text.trim(),
    lat: _location?.latitude,
    lng: _location?.longitude,
    websiteUrl: _website.text.trim(),
    partners: _isRequest
        ? null
        : [
            for (final row in _partners)
              if (!row.isBlank)
                AssociationPartner(
                  label: row.label.text.trim(),
                  url: row.url.text.trim().isEmpty ? null : row.url.text.trim(),
                ),
          ],
    email: _hasContact ? _email.text.trim() : null,
    phone: _hasContact ? _phone.text.trim() : null,
    message: _isRequest ? _message.text.trim() : null,
  );

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_valid) return;
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(associationsRepositoryProvider);
    setState(() => _saving = true);
    try {
      if (_isRequest) {
        await repo.request(_draft());
      } else {
        await repo.update(widget.associationId!, _draft());
      }
      ref
        ..invalidate(associationsProvider)
        ..invalidate(associationManagersProvider)
        ..invalidate(myManagerRowsProvider)
        ..invalidate(myPlayerProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRequest ? l10n.associationsRequestSent : l10n.associationsSaved,
          ),
        ),
      );
      context.pop();
    } on PostgrestException catch (error) {
      if (!mounted) return;
      final message = switch (error.message) {
        'request_already_pending' => l10n.associationsErrorRequestPending,
        _ => describeError(error, l10n),
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Pick, crop square, upload: saved right away, like a profile photo.
  Future<void> _changeLogo(Association association) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    final cropped = await showAvatarCropDialog(context, bytes, circle: false);
    if (cropped == null || !mounted) return;

    setState(() => _uploadingLogo = true);
    try {
      await ref
          .read(associationsRepositoryProvider)
          .uploadLogo(
            association,
            resizeForUpload(cropped, maxWidth: 512, quality: 85),
          );
      ref.invalidate(associationsProvider);
      final updated = await ref.read(
        associationByIdProvider(association.id).future,
      );
      if (!mounted) return;
      setState(() => _association = updated ?? association);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.associationsLogoUpdated)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final association = _association;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRequest
              ? l10n.associationsRequestTitle
              : l10n.associationsEditTitle,
        ),
      ),
      body: _loading
          ? const NuniLoading()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (_isRequest) ...[
                  Text(
                    l10n.associationsRequestIntro,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                ],
                if (association != null) ...[
                  Center(
                    child: Column(
                      children: [
                        AssociationLogo(association: association, size: 88),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _uploadingLogo
                              ? null
                              : () => _changeLogo(association),
                          icon: const Icon(PhosphorIcons.camera, size: 18),
                          label: Text(l10n.associationsLogoChange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                NuniFormSection(
                  title: l10n.associationsSectionIdentity,
                  children: [
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.associationsFieldName,
                        errorText: _required(_name),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _shortName,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.associationsFieldShortName,
                        helperText: l10n.associationsFieldShortNameHelp,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _website,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: l10n.associationsFieldWebsite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                NuniFormSection(
                  title: l10n.associationsSectionCity,
                  children: [
                    TextField(
                      controller: _city,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.associationsFieldCity,
                        errorText: _required(_city),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.associationsFieldLocationHelp,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    NuniLocationPicker(
                      value: _location,
                      initialCenter: _myPosition,
                      onChanged: (point) => setState(() => _location = point),
                    ),
                    if (_submitted && _location == null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.associationsFieldLocationRequired,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.nuni.danger.base),
                      ),
                    ],
                  ],
                ),
                if (!_isRequest) ...[
                  const SizedBox(height: 20),
                  NuniFormSection(
                    title: l10n.associationsPartnersTitle,
                    children: [
                      Text(
                        l10n.associationsPartnersHelp,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorderItem: _reorderPartners,
                        children: [
                          for (final (index, row) in _partners.indexed)
                            _PartnerFields(
                              key: row.key,
                              row: row,
                              index: index,
                              submitted: _submitted,
                              onChanged: () => setState(() {}),
                              onRemove: () => _removePartner(row),
                            ),
                        ],
                      ),
                      if (_partners.length < _maxPartners)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: _addPartner,
                            icon: const Icon(PhosphorIcons.plus, size: 18),
                            label: Text(l10n.associationsPartnerAdd),
                          ),
                        )
                      else
                        Text(
                          l10n.associationsPartnersMax(_maxPartners),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
                if (_hasContact) ...[
                  const SizedBox(height: 20),
                  NuniFormSection(
                    title: l10n.associationsSectionContact,
                    children: [
                      Text(
                        l10n.associationsContactPrivate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.associationsFieldEmail,
                          errorText: _emailError(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.associationsFieldPhone,
                          errorText: _required(_phone),
                        ),
                      ),
                      if (_isRequest) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _message,
                          minLines: 3,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: l10n.associationsFieldMessage,
                            helperText: l10n.associationsFieldMessageHelp,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
      // The form's one action stays reachable without scrolling.
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: NuniButton(
                  label: _isRequest
                      ? l10n.associationsRequestSubmit
                      : l10n.associationsSave,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ),
    );
  }
}

/// Same cap as the `associations.partners` check (plan 27, Q176).
const _maxPartners = 20;

/// One partner being edited (plan 27): a required label, an optional link
/// (Q175). A row left entirely empty is dropped on save.
class _PartnerRow {
  _PartnerRow({String label = '', String? url})
    : label = TextEditingController(text: label),
      url = TextEditingController(text: url ?? '');

  final key = UniqueKey();
  final TextEditingController label;
  final TextEditingController url;

  bool get isBlank => label.text.trim().isEmpty && url.text.trim().isEmpty;

  bool get hasLabel => label.text.trim().isNotEmpty;

  /// A host with a dot, no spaces, an optional http(s) scheme:
  /// "boulangerie.fr", "https://www.example.org/page".
  bool get hasValidUrl {
    final text = url.text.trim();
    return text.isEmpty ||
        RegExp(r'^(https?://)?[^\s/.]+(\.[^\s/.]+)+(/\S*)?$').hasMatch(text);
  }

  bool get isValid => hasLabel && hasValidUrl && label.text.trim().length <= 80;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}

class _PartnerFields extends StatelessWidget {
  const _PartnerFields({
    super.key,
    required this.row,
    required this.index,
    required this.submitted,
    required this.onChanged,
    required this.onRemove,
  });

  final _PartnerRow row;
  final int index;
  final bool submitted;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showErrors = submitted && !row.isBlank;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Tooltip(
              message: l10n.associationsPartnerMove,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 8, 16),
                child: Icon(PhosphorIcons.list),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: row.label,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: l10n.associationsPartnerLabel,
                    counterText: '',
                    errorText: showErrors && !row.hasLabel
                        ? l10n.associationsFieldRequired
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: row.url,
                  keyboardType: TextInputType.url,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: l10n.associationsPartnerUrl,
                    errorText: showErrors && !row.hasValidUrl
                        ? l10n.associationsPartnerUrlInvalid
                        : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.associationsPartnerRemove,
            onPressed: onRemove,
            icon: const Icon(PhosphorIcons.trash),
          ),
        ],
      ),
    );
  }
}
