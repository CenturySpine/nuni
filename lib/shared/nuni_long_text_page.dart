import 'package:flutter/material.dart';

/// One heading + body pair on a [NuniLongTextPage].
class NuniLongTextSection {
  const NuniLongTextSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Common shell for the legal-style pages (Legal notice, Privacy, About):
/// a title and an ordered list of sections. One layout, one translation
/// source (the ARB files), no separate HTML.
class NuniLongTextPage extends StatelessWidget {
  const NuniLongTextPage({
    super.key,
    required this.title,
    required this.sections,
    this.footer,
  });

  final String title;
  final List<NuniLongTextSection> sections;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in sections) ...[
            Text(section.heading, style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(section.body, style: textTheme.bodyMedium),
            const SizedBox(height: 20),
          ],
          ?footer,
        ],
      ),
    );
  }
}
