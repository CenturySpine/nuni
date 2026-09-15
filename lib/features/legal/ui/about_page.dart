import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/nuni_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const NuniLogo(size: 72),
                const SizedBox(height: 12),
                Text(l10n.appTitle, style: textTheme.headlineMedium),
                Text(l10n.tagline, style: textTheme.titleLarge),
                const SizedBox(height: 8),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version;
                    if (version == null) return const SizedBox.shrink();
                    return Text(
                      l10n.aboutVersionLabel(version),
                      style: textTheme.bodyMedium,
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => launchUrl(Uri.https('centuryspine.org')),
                  child: Text(l10n.aboutHomepageLink),
                ),
                TextButton(
                  onPressed: () =>
                      launchUrl(Uri.https('github.com', '/CenturySpine/nuni')),
                  child: Text(l10n.aboutSourceLink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
