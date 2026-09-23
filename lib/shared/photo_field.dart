import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../core/theme/phosphor_icons.dart';

/// Re-encodes [bytes] as JPEG, capped at [maxWidth] wide (never upscaled),
/// to keep uploads small on mobile connections (plan 06). Returns the
/// original bytes unchanged if they can't be decoded as an image.
Uint8List resizeForUpload(
  Uint8List bytes, {
  int maxWidth = 1600,
  int quality = 80,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final resized = decoded.width > maxWidth
      ? img.copyResize(decoded, width: maxWidth)
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
}

/// A square photo slot: shows the current photo (network or a freshly picked
/// local preview), a placeholder otherwise. Tapping opens the platform's
/// picker (`ImageSource.gallery`: on mobile web this offers both camera and
/// library, on desktop it's a plain file dialog -- no separate camera/gallery
/// chooser needed). Resizing happens here; uploading is the caller's job
/// (plan 06: the same component backs hole photos, avatars and, later,
/// session photos, each with its own storage path) -- [onPicked] is expected
/// to start that upload in the background and not block on it, so the caller
/// starts uploading the moment a photo is picked instead of waiting for the
/// rest of the form (PO, 2026-09-16). [uploading] only drives a small corner
/// badge here; the local preview is shown immediately either way. With
/// [onRemoved], a filled slot gets a corner button that empties it (PO,
/// 2026-09-23); the caller clears its stored path.
class PhotoField extends StatefulWidget {
  const PhotoField({
    super.key,
    required this.label,
    this.imageUrl,
    required this.onPicked,
    this.uploading = false,
    this.onRemoved,
    this.removeTooltip,
  });

  final String label;
  final String? imageUrl;
  final ValueChanged<Uint8List> onPicked;
  final bool uploading;
  final VoidCallback? onRemoved;
  final String? removeTooltip;

  @override
  State<PhotoField> createState() => _PhotoFieldState();
}

class _PhotoFieldState extends State<PhotoField> {
  Uint8List? _localPreview;
  bool _resizing = false;

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _resizing = true);
    final bytes = resizeForUpload(await picked.readAsBytes());
    if (!mounted) return;
    setState(() {
      _localPreview = bytes;
      _resizing = false;
    });
    widget.onPicked(bytes);
  }

  void _remove() {
    setState(() => _localPreview = null);
    widget.onRemoved!();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = _localPreview != null || widget.imageUrl != null;

    return GestureDetector(
      onTap: _resizing ? null : _pick,
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              // Expand, not the default loose fit: otherwise an empty slot
              // shrinks to its icon and the placeholder frame disappears.
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: hasImage
                        ? null
                        : Border.all(color: scheme.outlineVariant),
                    image: !hasImage
                        ? null
                        : DecorationImage(
                            image: _localPreview != null
                                ? MemoryImage(_localPreview!)
                                : NetworkImage(widget.imageUrl!)
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: _resizing
                      ? const Center(child: CircularProgressIndicator())
                      : !hasImage
                      ? Center(
                          child: Icon(
                            PhosphorIcons.camera,
                            size: 32,
                            color: scheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
                if (hasImage && widget.onRemoved != null && !_resizing)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton(
                      onPressed: _remove,
                      tooltip: widget.removeTooltip,
                      icon: const Icon(PhosphorIcons.xCircle, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.surface,
                        foregroundColor: scheme.onSurface,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                if (widget.uploading && !_resizing)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
