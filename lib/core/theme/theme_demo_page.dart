import 'package:flutter/material.dart';

import '../../shared/nuni_avatar.dart';
import '../../shared/nuni_button.dart';
import '../../shared/nuni_card.dart';
import '../../shared/nuni_chip.dart';
import '../../shared/nuni_confirm_dialog.dart';
import '../../shared/nuni_empty_state.dart';
import '../../shared/nuni_error_banner.dart';
import '../../shared/nuni_grouped_list.dart';
import '../../shared/nuni_hero.dart';
import '../../shared/nuni_icon_tile.dart';
import '../../shared/nuni_list_card.dart';
import '../../shared/nuni_loading.dart';
import '../../shared/nuni_logo.dart';
import '../../shared/nuni_rank_badge.dart';
import '../../shared/nuni_section_header.dart';
import '../../shared/nuni_segmented.dart';
import '../../shared/nuni_status_pill.dart';
import 'app_theme.dart';
import 'phosphor_icons.dart';

/// Internal-only page (`/dev/theme`, wired only in debug builds) showing
/// every shared component under the active palette, for the PO's visual
/// validation. Not localised: this screen never ships.
class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  bool _chipSelected = true;
  bool _switch = true;
  bool _check = true;
  double _slider = 500;
  String _segment = 'a';

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nuni = context.nuni;
    const gap = SizedBox(height: 16);

    Widget swatch(String name, Color color) => Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(NuniRadius.control),
            border: Border.all(color: nuni.border),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: text.labelMedium),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('Theme -- ${nuni.palette.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          NuniHero(
            child: Row(
              children: [
                const NuniLogo(size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'NUNI',
                    style: text.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          gap,
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              swatch('bg', nuni.palette.background),
              swatch('text', nuni.palette.text),
              swatch('primary', nuni.palette.primary),
              swatch('fairway', nuni.fairway.base),
              swatch('highlight', nuni.highlight.base),
              swatch('sunshine', nuni.sunshine.base),
              swatch('danger', nuni.danger.base),
            ],
          ),
          gap,
          const NuniSectionHeader(title: 'Typographie'),
          Text('Display', style: text.displaySmall),
          Text('Headline', style: text.headlineMedium),
          Text('Title large', style: text.titleLarge),
          Text('Title medium', style: text.titleMedium),
          Text('Corps de texte courant, lisible.', style: text.bodyMedium),
          Text('Légende secondaire', style: text.bodySmall),
          gap,
          const NuniSectionHeader(title: 'Boutons'),
          NuniButton(
            label: 'Primaire',
            icon: PhosphorIcons.plus,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          NuniButton(
            label: 'Secondaire',
            variant: NuniButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          NuniButton(
            label: 'Danger',
            icon: PhosphorIcons.trash,
            variant: NuniButtonVariant.danger,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          const NuniButton(label: 'Désactivé', onPressed: null),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('Lien texte')),
          gap,
          const NuniSectionHeader(title: 'Saisie'),
          NuniCard(
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Nom du trou'),
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Avec erreur',
                    errorText: 'Le nom est obligatoire.',
                  ),
                ),
                const SizedBox(height: 12),
                NuniSegmented<String>(
                  segments: const [
                    NuniSegment(value: 'a', label: 'Individuel'),
                    NuniSegment(value: 'b', label: 'Équipes'),
                  ],
                  selected: _segment,
                  onChanged: (v) => setState(() => _segment = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Compte pour le championnat'),
                  value: _switch,
                  onChanged: (v) => setState(() => _switch = v),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Case à cocher'),
                  value: _check,
                  onChanged: (v) => setState(() => _check = v ?? false),
                ),
                Slider(
                  value: _slider,
                  min: 100,
                  max: 2000,
                  onChanged: (v) => setState(() => _slider = v),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    NuniChip(
                      label: 'Scramble',
                      selected: _chipSelected,
                      onTap: () =>
                          setState(() => _chipSelected = !_chipSelected),
                    ),
                    const NuniChip(label: 'Meilleure balle'),
                  ],
                ),
              ],
            ),
          ),
          gap,
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: nuni.border,
              borderRadius: BorderRadius.circular(NuniRadius.control),
            ),
            child: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(height: 40, text: 'Liste'),
                Tab(height: 40, text: 'Carte'),
              ],
            ),
          ),
          gap,
          const NuniSectionHeader(
            title: 'Cartouches',
            trailing: NuniStatusPill(label: '3', tone: NuniTone.neutral),
          ),
          NuniListCard(
            leading: const NuniIconTile(
              icon: PhosphorIcons.golf,
              tone: NuniTone.fairway,
            ),
            title: 'Lyon · Croix-Rousse',
            badge: const NuniStatusPill(
              label: 'En direct',
              tone: NuniTone.fairway,
              dot: true,
            ),
            subtitle: 'Individuel · Organisateur · 23 sept. 2026',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          NuniListCard(
            leading: const NuniIconTile(icon: PhosphorIcons.users),
            title: 'Paris · Canal Saint-Martin',
            badge: const NuniStatusPill(
              label: 'En préparation',
              tone: NuniTone.highlight,
            ),
            subtitle: 'Équipes · Participant',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          NuniCard(
            child: Column(
              children: [
                for (final (i, name) in const [
                  (1, 'Alice Martin'),
                  (2, 'Bruno'),
                  (3, 'Chloé Durand'),
                  (4, 'David'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        NuniRankBadge(label: '$i', position: i),
                        const SizedBox(width: 12),
                        NuniAvatar(name: name, size: 32),
                        const SizedBox(width: 10),
                        Expanded(child: Text(name)),
                        Text('${20 - i * 3} pts', style: text.labelLarge),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          NuniGroupedList(
            children: [
              ListTile(
                leading: const NuniIconTile(
                  icon: PhosphorIcons.filePdf,
                  size: 36,
                ),
                title: const Text('Exporter en PDF'),
                trailing: const Icon(PhosphorIcons.caretRight, size: 18),
                onTap: () {},
              ),
              ListTile(
                leading: const NuniIconTile(
                  icon: PhosphorIcons.trash,
                  tone: NuniTone.danger,
                  size: 36,
                ),
                title: Text(
                  'Supprimer',
                  style: TextStyle(color: nuni.danger.onContainer),
                ),
                onTap: () {},
              ),
            ],
          ),
          gap,
          const NuniErrorBanner(message: 'Scores incomplets'),
          gap,
          const SizedBox(
            height: 160,
            child: NuniEmptyState(message: 'Aucun trou à proximité'),
          ),
          const SizedBox(
            height: 100,
            child: NuniLoading(message: 'Chargement…'),
          ),
          FilledButton(
            onPressed: () => NuniConfirmDialog.show(
              context,
              title: 'Supprimer la session ?',
              message: 'Action irréversible.',
              danger: true,
            ),
            child: const Text('Boîte de confirmation'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (context) => const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: Text('Feuille du bas'),
                ),
              ),
            ),
            child: const Text('Feuille du bas'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profil enregistré.'))),
            child: const Text('Snackbar'),
          ),
        ],
      ),
    );
  }
}
