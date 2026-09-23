import 'package:flutter/material.dart';

import 'nuni_card.dart';

/// Rows (usually [ListTile]s) grouped in one card, separated by hairlines:
/// the standard layout for settings-like lists and member lists.
class NuniGroupedList extends StatelessWidget {
  const NuniGroupedList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NuniCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}
