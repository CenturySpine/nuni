import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A rounded square holding one icon on a tinted background: the leading
/// visual of list cards (a session, a hole, a settings row...).
class NuniIconTile extends StatelessWidget {
  const NuniIconTile({
    super.key,
    required this.icon,
    this.tone = NuniTone.primary,
    this.size = 44,
  });

  final IconData icon;
  final NuniTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.nuni.tone(tone);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: colors.onContainer),
    );
  }
}
