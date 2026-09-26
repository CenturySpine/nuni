import 'package:flutter/material.dart';

import '../core/theme/phosphor_icons.dart';

/// Full-screen, zoomable, swipeable photo viewer: session gallery and hole
/// detail (plan 30, Q203). It always shows the original photos, never a
/// thumbnail or a display-sized decode (PO, 2026-09-26), so zooming stays
/// sharp. [actionsBuilder] adds buttons for the photo on screen, next to the
/// close button.
class NuniPhotoViewer extends StatefulWidget {
  const NuniPhotoViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
    this.actionsBuilder,
  });

  final List<String> urls;
  final int initialIndex;
  final Widget Function(BuildContext context, int index)? actionsBuilder;

  /// Opens a viewer showing [urls], starting at [initialIndex].
  static Future<void> show(
    BuildContext context, {
    required List<String> urls,
    int initialIndex = 0,
  }) => showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (context) =>
        NuniPhotoViewer(urls: urls, initialIndex: initialIndex),
  );

  @override
  State<NuniPhotoViewer> createState() => _NuniPhotoViewerState();
}

class _NuniPhotoViewerState extends State<NuniPhotoViewer> {
  late final PageController _controller;
  late int _index;

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

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  widget.urls[i],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    PhosphorIcons.imageSquare,
                    size: 48,
                    color: Colors.white,
                  ),
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
                if (widget.actionsBuilder != null)
                  widget.actionsBuilder!(context, _index),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
