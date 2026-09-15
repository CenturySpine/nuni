import 'package:flutter/material.dart';

import '../../shared/nuni_button.dart';
import '../../shared/nuni_card.dart';
import '../../shared/nuni_chip.dart';
import '../../shared/nuni_confirm_dialog.dart';
import '../../shared/nuni_empty_state.dart';
import '../../shared/nuni_error_banner.dart';
import '../../shared/nuni_loading.dart';
import '../../shared/nuni_logo.dart';
import 'app_theme.dart';
import 'palettes.dart';

/// Internal-only page (`/dev/theme`, wired only in debug builds) showing
/// every shared component under the active palette, for the PO's visual
/// validation (plan 04 jalon 2). Not localised: this screen never ships.
class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  bool _chipSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Theme demo -- ${activePalette.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: NuniLogo(size: 80)),
          const SizedBox(height: 24),
          Text('Titre', style: Theme.of(context).textTheme.headlineMedium),
          Text('Sous-titre', style: Theme.of(context).textTheme.titleLarge),
          Text(
            'Corps de texte courant, sur plusieurs mots pour juger la lisibilité.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text('Étiquette', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              NuniButton(label: 'Primaire', onPressed: () {}),
              const NuniButton(
                label: 'Secondaire',
                onPressed: null,
                variant: NuniButtonVariant.secondary,
              ),
              const NuniButton(
                label: 'Danger',
                onPressed: null,
                variant: NuniButtonVariant.danger,
              ),
            ],
          ),
          const SizedBox(height: 16),
          NuniChip(
            label: 'Scramble',
            selected: _chipSelected,
            onTap: () => setState(() => _chipSelected = !_chipSelected),
          ),
          const SizedBox(height: 16),
          const NuniCard(child: Text('Cartouche')),
          const SizedBox(height: 16),
          const NuniErrorBanner(message: 'Scores incomplets'),
          const SizedBox(height: 16),
          const SizedBox(
            height: 120,
            child: NuniLoading(message: 'Chargement…'),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 160,
            child: NuniEmptyState(message: 'Aucun trou à proximité'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => NuniConfirmDialog.show(
              context,
              title: 'Supprimer ?',
              message: 'Action irréversible.',
              danger: true,
            ),
            child: const Text('Ouvrir la boîte de confirmation'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Autres variantes (non actives) :'),
          for (final palette in allPalettes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Theme(
                data: buildAppTheme(palette),
                child: Builder(
                  builder: (context) => Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            palette.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Bouton'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
