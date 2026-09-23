import 'package:flutter/material.dart';

import 'nuni_card.dart';
import 'nuni_section_header.dart';

/// A titled cartouche grouping related form fields (essai visuel, PO
/// 2026-09-16): a label above a [NuniCard], instead of a flat, undifferentiated
/// list of fields.
class NuniFormSection extends StatelessWidget {
  const NuniFormSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NuniSectionHeader(title: title),
        NuniCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
