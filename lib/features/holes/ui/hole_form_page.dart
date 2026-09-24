import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/location/location_service.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_chip.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_error_banner.dart';
import '../../../shared/nuni_form_section.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/nuni_map_attribution.dart';
import '../../../shared/photo_field.dart';
import '../data/holes_repository.dart';
import '../domain/hole.dart';

const _fallbackMapCenter = LatLng(48.8566, 2.3522);

enum _ActivePoint { start, end, path }

/// A throwaway storage-path segment for a hole that doesn't have a row id
/// yet: photo uploads start the moment a photo is picked (PO, 2026-09-16),
/// well before the "Enregistrer" tap that creates the row.
// Not `1 << 32`: dart2js/web compiles `<<` down to JS's 32-bit bitwise
// operator, where a shift of exactly 32 wraps around to 0 -- Random.nextInt
// then throws on a zero range. A plain decimal literal has no such trap.
String _generatePhotoFolderId() =>
    '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(2000000000)}';

/// Create (`/holes/new`) and edit (`/holes/:id`) share this form (plan 06).
class HoleFormPage extends ConsumerStatefulWidget {
  const HoleFormPage({super.key, this.holeId});

  final String? holeId;

  bool get isEditing => holeId != null;

  @override
  ConsumerState<HoleFormPage> createState() => _HoleFormPageState();
}

class _HoleFormPageState extends ConsumerState<HoleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parController = TextEditingController(text: '3');
  final _distanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  LatLng? _startPosition;
  LatLng? _endPosition;
  final List<LatLng> _path = [];
  _ActivePoint _activePoint = _ActivePoint.start;
  double? _accuracy;
  late final String _photoFolderId;
  String? _startPhotoPath;
  String? _endPhotoPath;
  Future<String>? _startUploadFuture;
  Future<String>? _endUploadFuture;
  // Every photo path this hole referenced when loaded or received during this
  // edit: whichever of them the saved hole no longer references is deleted
  // from storage after a successful save (PO, 2026-09-23, Q61).
  final _photoPathsSeen = <String>{};
  bool _startUploading = false;
  bool _endUploading = false;
  bool _saving = false;
  bool _locating = false;
  String? _loadedFor;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _photoFolderId = widget.holeId ?? _generatePhotoFolderId();
    if (!widget.isEditing) _useMyPosition(silent: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parController.dispose();
    _distanceController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// The only situation allowed to move/zoom the map on its own (PO,
  /// 2026-09-18): every other position change (tapping the map, undoing or
  /// clearing a path point) leaves the current view exactly as the user left
  /// it, so `_PositionPicker` never touches the map camera itself.
  Future<void> _useMyPosition({bool silent = false}) async {
    if (!silent) setState(() => _locating = true);
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (position != null) {
        _startPosition = LatLng(position.latitude, position.longitude);
        _accuracy = position.accuracy;
        // An explicit "use my position" places the start like a tap does;
        // the silent fill when a new form opens doesn't (nothing was placed
        // by the user yet).
        if (!silent && _activePoint == _ActivePoint.start) {
          _advanceActivePoint();
        }
        _syncParAndDistanceFromPath();
      }
    });
    if (position != null && mounted) {
      _mapController.move(_startPosition!, 16);
    }
  }

  /// Empties a photo slot (PO, 2026-09-23): on save, the hole row loses its
  /// path and the file is deleted from storage (Q61).
  void _removePhoto({required bool isStart}) {
    setState(() {
      if (isStart) {
        _startPhotoPath = null;
        _startUploadFuture = null;
        _startUploading = false;
      } else {
        _endPhotoPath = null;
        _endUploadFuture = null;
        _endUploading = false;
      }
    });
  }

  void _onStartPhotoPicked(Uint8List bytes) {
    final future = ref
        .read(holesRepositoryProvider)
        .uploadPhoto(folderId: _photoFolderId, isStart: true, bytes: bytes);
    setState(() {
      _startUploading = true;
      _startUploadFuture = future;
    });
    future
        .then((path) {
          if (!mounted) return;
          // Photo removed (or replaced) while this upload was running.
          _photoPathsSeen.add(path);
          if (_startUploadFuture != future) return;
          setState(() {
            _startPhotoPath = path;
            _startUploading = false;
          });
        })
        .catchError((Object error) {
          if (!mounted) return;
          setState(() => _startUploading = false);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
        });
  }

  void _onEndPhotoPicked(Uint8List bytes) {
    final future = ref
        .read(holesRepositoryProvider)
        .uploadPhoto(folderId: _photoFolderId, isStart: false, bytes: bytes);
    setState(() {
      _endUploading = true;
      _endUploadFuture = future;
    });
    future
        .then((path) {
          if (!mounted) return;
          // Photo removed (or replaced) while this upload was running.
          _photoPathsSeen.add(path);
          if (_endUploadFuture != future) return;
          setState(() {
            _endPhotoPath = path;
            _endUploading = false;
          });
        })
        .catchError((Object error) {
          if (!mounted) return;
          setState(() => _endUploading = false);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
        });
  }

  /// Once start is placed, moves on to the target, then to the path (PO,
  /// 2026-09-23), so drawing a new hole takes no mode switch. Only moves on
  /// to a point not placed yet: correcting the start of a hole that already
  /// has a target leaves the start mode active, so the next tap can't move
  /// the target by surprise. The chips still switch mode manually.
  void _advanceActivePoint() {
    if (_activePoint == _ActivePoint.start && _endPosition == null) {
      _activePoint = _ActivePoint.end;
    } else if (_activePoint == _ActivePoint.end && _path.isEmpty) {
      _activePoint = _ActivePoint.path;
    }
  }

  void _handleMapTap(LatLng point) {
    setState(() {
      switch (_activePoint) {
        case _ActivePoint.start:
          _startPosition = point;
        case _ActivePoint.end:
          _endPosition = point;
        case _ActivePoint.path:
          _path.add(point);
      }
      _advanceActivePoint();
      _syncParAndDistanceFromPath();
    });
  }

  void _undoLastPathPoint() {
    setState(() {
      _path.removeLast();
      _syncParAndDistanceFromPath();
    });
  }

  void _clearPath() {
    setState(() {
      _path.clear();
      _syncParAndDistanceFromPath();
    });
  }

  /// Par and length in metres, deduced from the path (PO, 2026-09-18): par
  /// defaults to the number of points on the path (start and end included)
  /// plus one, distance to the path's total length. Both fields stay plain
  /// editable text fields, but the path always takes the pen back over a
  /// manual edit on the next point added or removed (PO's explicit call --
  /// simpler than tracking whether the field was touched, and the path is
  /// the source of truth while it's being built). Only kicks in once there
  /// is an actual path (at least two points) to measure; a lone start point
  /// leaves both fields as they were.
  void _syncParAndDistanceFromPath() {
    final points = [?_startPosition, ..._path, ?_endPosition];
    if (points.length < 2) return;

    const distanceCalculator = Distance();
    var metres = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      metres += distanceCalculator.distance(points[i], points[i + 1]);
    }
    _distanceController.text = metres.round().toString();
    _parController.text = (points.length + 1).toString();
  }

  void _prefill(Hole hole) {
    _loadedFor = hole.id;
    _nameController.text = hole.name;
    _descriptionController.text = hole.description ?? '';
    _parController.text = hole.par.toString();
    _distanceController.text = hole.distanceM?.toString() ?? '';
    _startPosition = hole.hasPosition
        ? LatLng(hole.startLat!, hole.startLng!)
        : null;
    _endPosition = (hole.endLat != null && hole.endLng != null)
        ? LatLng(hole.endLat!, hole.endLng!)
        : null;
    _path
      ..clear()
      ..addAll([
        for (final point in hole.path ?? const <HolePathPoint>[])
          LatLng(point.lat, point.lng),
      ]);
    _startPhotoPath = hole.photoStartPath;
    _endPhotoPath = hole.photoEndPath;
    _photoPathsSeen.addAll([?hole.photoStartPath, ?hole.photoEndPath]);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _startPosition == null) {
      setState(() {});
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(holesRepositoryProvider);
    try {
      final par = int.parse(_parController.text.trim());
      final distanceText = _distanceController.text.trim();
      final distanceM = distanceText.isEmpty ? null : int.parse(distanceText);
      final descriptionText = _descriptionController.text.trim();
      final description = descriptionText.isEmpty ? null : descriptionText;

      // Photo uploads started in the background the moment they were picked
      // (PO, 2026-09-16); usually already finished by the time Save is
      // pressed. A failed upload is reported where it happened (the picker)
      // and just leaves that slot at its previous value here.
      if (_startUploadFuture != null) {
        try {
          _startPhotoPath = await _startUploadFuture;
        } catch (_) {
          // Already surfaced to the user when the upload failed.
        }
      }
      if (_endUploadFuture != null) {
        try {
          _endPhotoPath = await _endUploadFuture;
        } catch (_) {
          // Already surfaced to the user when the upload failed.
        }
      }

      final String id;
      if (widget.isEditing) {
        id = widget.holeId!;
        await repo.update(
          id: id,
          name: _nameController.text.trim(),
          description: description,
          par: par,
          distanceM: distanceM,
          lat: _startPosition!.latitude,
          lng: _startPosition!.longitude,
          endLat: _endPosition?.latitude,
          endLng: _endPosition?.longitude,
          path: _pathPoints,
          photoStartPath: _startPhotoPath,
          photoEndPath: _endPhotoPath,
        );
      } else {
        id = await repo.create(
          name: _nameController.text.trim(),
          description: description,
          par: par,
          distanceM: distanceM,
          lat: _startPosition!.latitude,
          lng: _startPosition!.longitude,
          endLat: _endPosition?.latitude,
          endLng: _endPosition?.longitude,
          path: _pathPoints,
          photoStartPath: _startPhotoPath,
          photoEndPath: _endPhotoPath,
        );
      }

      await repo.deletePhotos(
        _photoPathsSeen.difference({?_startPhotoPath, ?_endPhotoPath}),
      );

      ref.invalidate(nearbyHolesProvider);
      ref.invalidate(myHolesProvider);
      ref.invalidate(lastPlacedHoleProvider);
      if (widget.isEditing) ref.invalidate(holeByIdProvider(id));

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.holesFormSaved)));
        // Callers that need the saved id (plan 08's "Créer un trou ici",
        // which pushes this route and awaits the result) get it; every
        // other caller today fires this route with `push` and ignores the
        // return value, so carrying it costs them nothing.
        context.pop(id);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<HolePathPoint>? get _pathPoints => _path.isEmpty
      ? null
      : [
          for (final point in _path)
            HolePathPoint(lat: point.latitude, lng: point.longitude),
        ];

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.holesFormDeleteConfirmTitle,
      message: l10n.holesFormDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref.read(holesRepositoryProvider).delete(widget.holeId!);
      ref.invalidate(nearbyHolesProvider);
      ref.invalidate(myHolesProvider);
      ref.invalidate(lastPlacedHoleProvider);
      if (mounted) context.pop();
    } on PostgrestException catch (error) {
      if (mounted) {
        final message = error.code == '23503'
            ? l10n.holesFormDeleteBlocked
            : describeError(error, l10n);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error, l10n))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!widget.isEditing) return _buildScaffold(context, l10n);

    final holeAsync = ref.watch(holeByIdProvider(widget.holeId!));
    return holeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.holesFormTitleEdit)),
        body: const NuniLoading(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.holesFormTitleEdit)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NuniErrorBanner(
            message: describeError(error, l10n),
            onRetry: () => ref.invalidate(holeByIdProvider(widget.holeId!)),
          ),
        ),
      ),
      data: (hole) {
        if (_loadedFor != hole.id) _prefill(hole);
        return _buildScaffold(context, l10n, hole: hole);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n, {
    Hole? hole,
  }) {
    final repo = ref.read(holesRepositoryProvider);
    final currentUserId = ref
        .watch(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    final isOwner = hole == null || hole.ownerId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.holesFormTitleEdit : l10n.holesFormTitleNew,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            NuniFormSection(
              title: l10n.holesFormSectionInfo,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.holesFormNameLabel,
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.holesFormNameRequired
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _parController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.holesFormParLabel,
                        ),
                        validator: (value) {
                          final par = int.tryParse(value ?? '');
                          return (par == null || par < 1 || par > 10)
                              ? l10n.holesFormParInvalid
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.holesFormDistanceLabel,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.holesFormDescriptionLabel,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.holesFormSectionPosition,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NuniChip(
                      label: l10n.holesFormPointStart,
                      selected: _activePoint == _ActivePoint.start,
                      onTap: () =>
                          setState(() => _activePoint = _ActivePoint.start),
                    ),
                    NuniChip(
                      label: l10n.holesFormPointEnd,
                      selected: _activePoint == _ActivePoint.end,
                      onTap: () =>
                          setState(() => _activePoint = _ActivePoint.end),
                    ),
                    NuniChip(
                      label: l10n.holesFormPointPath,
                      selected: _activePoint == _ActivePoint.path,
                      onTap: () =>
                          setState(() => _activePoint = _ActivePoint.path),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PositionPicker(
                  mapController: _mapController,
                  startPosition: _startPosition,
                  endPosition: _endPosition,
                  path: _path,
                  activePoint: _activePoint,
                  onTap: _handleMapTap,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    NuniButton(
                      variant: NuniButtonVariant.secondary,
                      icon: PhosphorIcons.crosshair,
                      label: l10n.holesFormUseMyPosition,
                      onPressed: _locating ? null : () => _useMyPosition(),
                    ),
                    // Only moves the map (PO, 2026-09-23): the start is then
                    // placed by tapping, never copied from the other hole.
                    if (ref.watch(lastPlacedHoleProvider(widget.holeId)).value
                        case final lastHole?)
                      NuniButton(
                        variant: NuniButtonVariant.secondary,
                        icon: PhosphorIcons.mapPin,
                        label: l10n.holesFormGoToLastHole(lastHole.name),
                        onPressed: () => _mapController.move(
                          LatLng(lastHole.startLat!, lastHole.startLng!),
                          17,
                        ),
                      ),
                    if (_locating)
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                if (_activePoint == _ActivePoint.path) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      NuniButton(
                        variant: NuniButtonVariant.secondary,
                        label: l10n.holesFormPathUndo,
                        onPressed: _path.isEmpty ? null : _undoLastPathPoint,
                      ),
                      const SizedBox(width: 12),
                      NuniButton(
                        variant: NuniButtonVariant.secondary,
                        icon: PhosphorIcons.trash,
                        label: l10n.holesFormPathClear,
                        onPressed: _path.isEmpty ? null : _clearPath,
                      ),
                    ],
                  ),
                ],
                if (_startPosition == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      // Editing a hole imported from LsgScores without a
                      // position (plan 13): nothing failed, it just has to
                      // be placed.
                      widget.isEditing
                          ? l10n.holesFormPositionToSet
                          : l10n.holesFormPositionUnavailable,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (_accuracy != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.holesFormAccuracy(_accuracy!.round().toString()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            NuniFormSection(
              title: l10n.holesFormSectionPhotos,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PhotoField(
                      label: l10n.holesFormPhotoStart,
                      imageUrl: _startPhotoPath == null
                          ? null
                          : repo.photoUrl(_startPhotoPath!),
                      uploading: _startUploading,
                      onPicked: _onStartPhotoPicked,
                      onRemoved: () => _removePhoto(isStart: true),
                      removeTooltip: l10n.holesFormPhotoRemove,
                    ),
                    PhotoField(
                      label: l10n.holesFormPhotoEnd,
                      imageUrl: _endPhotoPath == null
                          ? null
                          : repo.photoUrl(_endPhotoPath!),
                      uploading: _endUploading,
                      onPicked: _onEndPhotoPicked,
                      onRemoved: () => _removePhoto(isStart: false),
                      removeTooltip: l10n.holesFormPhotoRemove,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            NuniButton(
              label: l10n.commonSave,
              onPressed: _saving ? null : _save,
            ),
            if (widget.isEditing && isOwner) ...[
              const SizedBox(height: 12),
              NuniButton(
                variant: NuniButtonVariant.danger,
                icon: PhosphorIcons.trash,
                label: l10n.holesFormDelete,
                onPressed: _saving ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tap-to-place position picker for both points: a "Départ"/"Cible" toggle
/// above the map (PO, 2026-09-16) selects which marker a tap moves. There is
/// no drag gesture on the base `flutter_map` marker layer, and tapping is at
/// least as usable on a phone.
class _PositionPicker extends StatelessWidget {
  const _PositionPicker({
    required this.mapController,
    required this.startPosition,
    required this.endPosition,
    required this.path,
    required this.activePoint,
    required this.onTap,
  });

  final MapController mapController;
  final LatLng? startPosition;
  final LatLng? endPosition;
  final List<LatLng> path;
  final _ActivePoint activePoint;
  final ValueChanged<LatLng> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = startPosition ?? endPosition;
    return ClipRRect(
      borderRadius: BorderRadius.circular(NuniRadius.control),
      child: SizedBox(
        height: 340,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initial ?? _fallbackMapCenter,
            initialZoom: initial == null ? 5 : 16,
            onTap: (tapPosition, point) => onTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'org.centuryspine.nuni',
            ),
            if (startPosition != null || endPosition != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [?startPosition, ...path, ?endPosition],
                    color: scheme.secondary,
                    strokeWidth: 3,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final point in path)
                  Marker(
                    point: point,
                    width: 14,
                    height: 14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.onPrimary, width: 2),
                      ),
                    ),
                  ),
                if (startPosition != null)
                  Marker(
                    point: startPosition!,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      PhosphorIcons.mapPinFill,
                      color: scheme.primary,
                      size: 36,
                    ),
                  ),
                if (endPosition != null)
                  Marker(
                    point: endPosition!,
                    width: 40,
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Icon(
                      PhosphorIcons.mapPinFill,
                      color: scheme.tertiary,
                      size: 36,
                    ),
                  ),
              ],
            ),
            const NuniMapAttribution(),
          ],
        ),
      ),
    );
  }
}
