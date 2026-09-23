import 'package:flutter/material.dart';

/// The heading above a group of cards or fields ("Sessions en cours",
/// "Équipes", ...), with an optional trailing widget (count, text action).
/// The only section title style in the app.
class NuniSectionHeader extends StatelessWidget {
  const NuniSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.only(left: 4, right: 4, bottom: 10),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
