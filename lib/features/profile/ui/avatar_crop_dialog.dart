import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_button.dart';
import '../../../shared/nuni_loading.dart';

/// Full-screen square crop of a freshly picked photo, shown in a round
/// frame like the avatar it becomes -- or a square one ([circle] false) for
/// an association logo. Returns the cropped bytes, or null if cancelled.
Future<Uint8List?> showAvatarCropDialog(
  BuildContext context,
  Uint8List image, {
  bool circle = true,
}) => Navigator.of(context).push<Uint8List>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (context) => _AvatarCropPage(image: image, circle: circle),
  ),
);

class _AvatarCropPage extends StatefulWidget {
  const _AvatarCropPage({required this.image, required this.circle});

  final Uint8List image;
  final bool circle;

  @override
  State<_AvatarCropPage> createState() => _AvatarCropPageState();
}

class _AvatarCropPageState extends State<_AvatarCropPage> {
  final _controller = CropController();
  bool _ready = false;
  bool _cropping = false;

  void _onCropped(CropResult result) {
    if (!mounted) return;
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(croppedImage);
      case CropFailure():
        setState(() => _cropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePhotoCropTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Crop(
            image: widget.image,
            controller: _controller,
            onCropped: _onCropped,
            aspectRatio: 1,
            withCircleUi: widget.circle,
            interactive: true,
            baseColor: scheme.inverseSurface,
            maskColor: scheme.inverseSurface.withValues(alpha: 0.6),
            progressIndicator: const NuniLoading(),
            onStatusChanged: (status) {
              if (status == CropStatus.ready && !_ready) {
                setState(() => _ready = true);
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: NuniButton(
                  variant: NuniButtonVariant.secondary,
                  label: l10n.commonCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NuniButton(
                  label: l10n.profilePhotoCropConfirm,
                  onPressed: !_ready || _cropping
                      ? null
                      : () {
                          setState(() => _cropping = true);
                          _controller.crop();
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
