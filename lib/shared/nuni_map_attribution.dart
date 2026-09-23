import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';

/// The credit every map showing OpenStreetMap tiles must carry, on the map
/// itself (OSMF attribution guidelines: a credit only on a legal page is not
/// enough). Always visible in the bottom-right corner; tapping it opens the
/// OSM copyright page. Add it as the last child of a [FlutterMap].
class NuniMapAttribution extends StatelessWidget {
  const NuniMapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SimpleAttributionWidget(
      source: Text(l10n.mapAttributionOsm),
      onTap: () => launchUrl(Uri.https('www.openstreetmap.org', '/copyright')),
    );
  }
}
