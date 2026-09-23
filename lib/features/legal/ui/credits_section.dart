import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/phosphor_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_grouped_list.dart';
import '../../../shared/nuni_logo.dart';

/// A third-party work NUNI relies on: its name, licence and home page.
/// Licences are read from each package's own LICENSE file.
class _Credit {
  const _Credit(this.name, this.licence, this.url);

  final String name;
  final String licence;
  final String url;
}

String _pub(String package) => 'https://pub.dev/packages/$package';

const _mapsAndData = [
  _Credit('OpenStreetMap', 'ODbL', 'https://www.openstreetmap.org/copyright'),
  _Credit('Open-Meteo', 'CC BY 4.0', 'https://open-meteo.com'),
  _Credit('BigDataCloud', 'API', 'https://www.bigdatacloud.com'),
];

const _fontsAndIcons = [
  _Credit(
    'Plus Jakarta Sans',
    'SIL OFL 1.1',
    'https://github.com/tokotype/PlusJakartaSans',
  ),
  _Credit('Phosphor Icons', 'MIT', 'https://phosphoricons.com'),
];

final _libraries = [
  const _Credit('Flutter', 'BSD-3-Clause', 'https://flutter.dev'),
  _Credit('supabase_flutter', 'MIT', _pub('supabase_flutter')),
  _Credit('flutter_map', 'BSD-3-Clause', _pub('flutter_map')),
  _Credit('latlong2', 'Apache-2.0', _pub('latlong2')),
  _Credit('Riverpod', 'MIT', _pub('flutter_riverpod')),
  _Credit('go_router', 'BSD-3-Clause', _pub('go_router')),
  _Credit('freezed', 'MIT', _pub('freezed')),
  _Credit('json_serializable', 'BSD-3-Clause', _pub('json_serializable')),
  _Credit('geolocator', 'MIT', _pub('geolocator')),
  _Credit('pdf', 'Apache-2.0', _pub('pdf')),
  _Credit('printing', 'Apache-2.0', _pub('printing')),
  _Credit('qr_flutter', 'BSD-3-Clause', _pub('qr_flutter')),
  _Credit('crop_your_image', 'Apache-2.0', _pub('crop_your_image')),
  _Credit('image', 'MIT', _pub('image')),
  _Credit('image_picker', 'BSD-3-Clause', _pub('image_picker')),
  _Credit('share_plus', 'BSD-3-Clause', _pub('share_plus')),
  _Credit('package_info_plus', 'BSD-3-Clause', _pub('package_info_plus')),
  _Credit('url_launcher', 'BSD-3-Clause', _pub('url_launcher')),
  _Credit('shared_preferences', 'BSD-3-Clause', _pub('shared_preferences')),
  _Credit('http', 'BSD-3-Clause', _pub('http')),
  _Credit('intl', 'BSD-3-Clause', _pub('intl')),
  _Credit('uuid', 'MIT', _pub('uuid')),
];

/// The "Credits" block of the legal notice: services and data, fonts and
/// icons, then the main libraries, each linking to its home page, plus the
/// complete licence texts of every package (Flutter's licence page).
class CreditsSection extends StatelessWidget {
  const CreditsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    Widget group(String title, List<_Credit> credits) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(title, style: textTheme.titleSmall),
        ),
        NuniGroupedList(
          children: [
            for (final credit in credits)
              ListTile(
                dense: true,
                title: Text(credit.name),
                subtitle: Text(credit.licence),
                trailing: Icon(
                  PhosphorIcons.arrowSquareOut,
                  size: 18,
                  color: context.nuni.primaryInk,
                ),
                onTap: () => launchUrl(Uri.parse(credit.url)),
              ),
          ],
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.legalCreditsHeading, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(l10n.legalCreditsBody, style: textTheme.bodyMedium),
        group(l10n.legalCreditsMapsData, _mapsAndData),
        group(l10n.legalCreditsFontsIcons, _fontsAndIcons),
        group(l10n.legalCreditsLibraries, _libraries),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationLegalese: l10n.tagline,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: NuniLogo(size: 56),
              ),
            ),
            child: Text(l10n.legalCreditsAllLicenses),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
