import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_error_message.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_confirm_dialog.dart';
import '../../../shared/nuni_loading.dart';
import '../../../shared/photo_field.dart';
import '../data/history_repository.dart';
import '../domain/session_photo.dart';

/// The history detail's photo section (plan 10): a grid, add (owner only,
/// multi-pick), tap for a full-screen swipeable viewer with set-cover/delete
/// (owner only, from the viewer's own action bar rather than a per-thumbnail
/// menu -- fewer controls competing for a small grid tile).
class PhotoGallery extends ConsumerStatefulWidget {
  const PhotoGallery({
    super.key,
    required this.sessionId,
    required this.isOwner,
    required this.coverPhotoId,
  });

  final String sessionId;
  final bool isOwner;
  final String? coverPhotoId;

  @override
  ConsumerState<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends ConsumerState<PhotoGallery> {
  bool _uploading = false;

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _add() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(historyRepositoryProvider);
      for (final file in picked) {
        final bytes = resizeForUpload(await file.readAsBytes());
        await repo.uploadPhoto(sessionId: widget.sessionId, bytes: bytes);
      }
      ref.invalidate(sessionPhotosProvider(widget.sessionId));
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _openViewer(List<SessionPhoto> photos, int initialIndex) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => _PhotoViewerDialog(
        sessionId: widget.sessionId,
        photos: photos,
        initialIndex: initialIndex,
        isOwner: widget.isOwner,
        coverPhotoId: widget.coverPhotoId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photosAsync = ref.watch(sessionPhotosProvider(widget.sessionId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.historyPhotosTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        photosAsync.when(
          loading: () => const NuniLoading(),
          error: (error, _) =>
              Text(describeError(error, l10n), style: const TextStyle()),
          data: (photos) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < photos.length; i++)
                _Thumbnail(
                  photo: photos[i],
                  isCover: photos[i].id == widget.coverPhotoId,
                  onTap: () => _openViewer(photos, i),
                ),
              if (widget.isOwner)
                GestureDetector(
                  onTap: _uploading ? null : _add,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: _uploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            PhosphorIcons.plus,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends ConsumerWidget {
  const _Thumbnail({
    required this.photo,
    required this.isCover,
    required this.onTap,
  });

  final SessionPhoto photo;
  final bool isCover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.read(historyRepositoryProvider).photoUrl(photo.storagePath);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, width: 84, height: 84, fit: BoxFit.cover),
          ),
          if (isCover)
            Positioned(
              right: 4,
              top: 4,
              child: Icon(
                PhosphorIcons.starFill,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoViewerDialog extends ConsumerStatefulWidget {
  const _PhotoViewerDialog({
    required this.sessionId,
    required this.photos,
    required this.initialIndex,
    required this.isOwner,
    required this.coverPhotoId,
  });

  final String sessionId;
  final List<SessionPhoto> photos;
  final int initialIndex;
  final bool isOwner;
  final String? coverPhotoId;

  @override
  ConsumerState<_PhotoViewerDialog> createState() => _PhotoViewerDialogState();
}

class _PhotoViewerDialogState extends ConsumerState<_PhotoViewerDialog> {
  late final PageController _controller;
  late int _index;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setCover(SessionPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref
          .read(historyRepositoryProvider)
          .setCoverPhoto(sessionId: widget.sessionId, photoId: photo.id);
      ref.invalidate(historyDetailProvider(widget.sessionId));
      ref.invalidate(historyEntriesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      _showSnack(describeError(error, l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(SessionPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await NuniConfirmDialog.show(
      context,
      title: l10n.historyPhotosDeleteConfirmTitle,
      message: l10n.historyPhotosDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(historyRepositoryProvider).deletePhoto(photo);
      ref.invalidate(sessionPhotosProvider(widget.sessionId));
      if (photo.id == widget.coverPhotoId) {
        ref.invalidate(historyDetailProvider(widget.sessionId));
        ref.invalidate(historyEntriesProvider);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      _showSnack(describeError(error, l10n));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(historyRepositoryProvider);
    final current = widget.photos[_index];

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  repo.photoUrl(widget.photos[i].storagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            left: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(PhosphorIcons.xCircle, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                if (widget.isOwner)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          current.id == widget.coverPhotoId
                              ? PhosphorIcons.starFill
                              : PhosphorIcons.star,
                          color: Colors.white,
                        ),
                        tooltip: l10n.historyPhotosSetCover,
                        onPressed: _busy ? null : () => _setCover(current),
                      ),
                      IconButton(
                        icon: const Icon(
                          PhosphorIcons.trash,
                          color: Colors.white,
                        ),
                        tooltip: l10n.historyPhotosDeleteConfirmTitle,
                        onPressed: _busy ? null : () => _delete(current),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
