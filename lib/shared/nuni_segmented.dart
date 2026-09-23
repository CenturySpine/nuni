import 'package:flutter/material.dart';

/// One option of a [NuniSegmented] control.
class NuniSegment<T> {
  const NuniSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// The app's single-choice control for two or three exclusive options
/// (session type, ranking direction, language...): a full-width segmented
/// button styled by the theme.
class NuniSegmented<T> extends StatelessWidget {
  const NuniSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<NuniSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [
          for (final segment in segments)
            ButtonSegment<T>(
              value: segment.value,
              label: Text(
                segment.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              icon: segment.icon == null ? null : Icon(segment.icon, size: 18),
            ),
        ],
        selected: {selected},
        onSelectionChanged: onChanged == null
            ? null
            : (selection) => onChanged!(selection.first),
      ),
    );
  }
}
