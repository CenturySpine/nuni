import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_empty_state.dart';
import '../domain/join_link.dart';

/// Opens the in-app QR scanner (PO, 2026-09-29) and returns the session
/// code it read, or null if closed. On the root navigator, so it covers the
/// app shell's bars.
Future<String?> showQrScanPage(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const QrScanPage(),
      ),
    );

/// The camera, full screen, until it reads a session's QR code (the invite
/// link, or a bare code). Anything else is reported and scanning goes on.
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  String? _lastRejected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final code = codeFromScan(raw);
      if (code != null) {
        _done = true;
        Navigator.of(context).pop(code);
        return;
      }
      // The same foreign code is seen many times a second: say it once.
      if (raw != _lastRejected) {
        _lastRejected = raw;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.joinScanNotRecognized)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinScanTitle)),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => NuniEmptyState(
                icon: PhosphorIcons.camera,
                message:
                    error.errorCode == MobileScannerErrorCode.permissionDenied
                    ? l10n.joinScanPermissionDenied
                    : l10n.joinScanUnavailable,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.joinScanHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
