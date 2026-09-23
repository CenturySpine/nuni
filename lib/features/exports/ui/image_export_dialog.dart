import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/photo_field.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/history_entry.dart';
import '../../history/domain/session_photo.dart';
import 'image_export.dart';
import 'results_card.dart';

/// "Exporter en image" (plan 10, Q16 -- both variants): a full-screen
/// preview of the `ResultsCard`, scaled to fit via `FittedBox` for on-screen
/// display while the `RepaintBoundary` underneath stays at the card's real
/// size -- 1080 wide, shaped to the chosen photo's own ratio (or a
/// 1080x1080 square without one) -- which is what actually gets captured.
/// The background photo strip offers the session's own photos first (PO
/// feedback, 2026-09-17: no point asking to pick from the filesystem when
/// photos are already in the session), with "add from device" only as one
/// more tile alongside them.
Future<void> showImageExportDialog(BuildContext context, HistoryEntry entry) =>
    showDialog<void>(
      context: context,
      builder: (context) => _ImageExportDialog(entry: entry),
    );

class _ImageExportDialog extends ConsumerStatefulWidget {
  const _ImageExportDialog({required this.entry});

  final HistoryEntry entry;

  @override
  ConsumerState<_ImageExportDialog> createState() => _ImageExportDialogState();
}

class _ImageExportDialogState extends ConsumerState<_ImageExportDialog> {
  final _repaintKey = GlobalKey();
  Uint8List? _backgroundPhoto;
  double? _backgroundAspectRatio;
  String? _selectedPhotoId;
  bool _busy = false;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// The card is shaped to match the photo exactly (PO feedback,
  /// 2026-09-18), so its ratio has to be known before the card can lay
  /// itself out -- decoded here, once, rather than in `build()`.
  double? _aspectRatioOf(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null || decoded.height == 0) return null;
    return decoded.width / decoded.height;
  }

  Future<void> _useSessionPhoto(SessionPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _selectedPhotoId = photo.id;
    });
    try {
      final url = ref
          .read(historyRepositoryProvider)
          .photoUrl(photo.storagePath);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('download_failed');
      if (mounted) {
        setState(() {
          _backgroundPhoto = response.bodyBytes;
          _backgroundAspectRatio = _aspectRatioOf(response.bodyBytes);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _selectedPhotoId = null);
        _showSnack(describeError(error, l10n));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFromDevice() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final bytes = resizeForUpload(await picked.readAsBytes(), maxWidth: 1080);
    setState(() {
      _backgroundPhoto = bytes;
      _backgroundAspectRatio = _aspectRatioOf(bytes);
      _selectedPhotoId = null;
    });
  }

  void _clearPhoto() {
    setState(() {
      _backgroundPhoto = null;
      _backgroundAspectRatio = null;
      _selectedPhotoId = null;
    });
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      // A frame so the RepaintBoundary reflects the current
      // `_backgroundPhoto` before it's captured.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final bytes = await captureAsPng(_repaintKey);
      await shareOrDownloadPng(bytes, filename: 'nuni-resultats.png');
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionId = widget.entry.snapshot.session.id;
    final photosAsync = ref.watch(sessionPhotosProvider(sessionId));

    return Dialog.fullscreen(
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(l10n.historyExportImageTitle),
              leading: IconButton(
                icon: const Icon(PhosphorIcons.xCircle),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AspectRatio(
                    // Matches the card's own computed shape so the preview
                    // never shows bars the actual export doesn't have.
                    aspectRatio: _backgroundAspectRatio ?? 1,
                    child: FittedBox(
                      child: RepaintBoundary(
                        key: _repaintKey,
                        child: ResultsCard(
                          entry: widget.entry,
                          backgroundImageBytes: _backgroundPhoto,
                          photoAspectRatio: _backgroundAspectRatio,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 72,
              child: photosAsync.when(
                loading: () => const NuniLoading(),
                error: (_, _) => const SizedBox.shrink(),
                data: (photos) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _PhotoStripTile(
                      selected: _backgroundPhoto == null,
                      onTap: _busy ? null : _clearPhoto,
                      child: Icon(
                        PhosphorIcons.imageSquare,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    for (final photo in photos)
                      _PhotoStripTile(
                        selected: _selectedPhotoId == photo.id,
                        onTap: _busy ? null : () => _useSessionPhoto(photo),
                        child: Image.network(
                          ref
                              .read(historyRepositoryProvider)
                              .photoUrl(photo.storagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    _PhotoStripTile(
                      selected: false,
                      onTap: _busy ? null : _pickFromDevice,
                      child: Icon(
                        PhosphorIcons.plus,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: NuniButton(
                icon: PhosphorIcons.shareNetwork,
                label: l10n.sessionsInviteShare,
                onPressed: _busy ? null : _share,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoStripTile extends StatelessWidget {
  const _PhotoStripTile({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(NuniRadius.control),
            border: Border.all(
              color: selected ? context.nuni.primaryInk : Colors.transparent,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
