import 'package:flutter/material.dart';

/// Common page shell: title bar, scrollable content, and an optional row of
/// actions pinned to the bottom (e.g. "Save" / "Cancel" on a form).
class NuniScaffold extends StatelessWidget {
  const NuniScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBarActions,
    this.stickyActions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? appBarActions;
  final Widget? stickyActions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: appBarActions),
      body: body,
      bottomNavigationBar: stickyActions == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: stickyActions,
              ),
            ),
      floatingActionButton: floatingActionButton,
    );
  }
}
