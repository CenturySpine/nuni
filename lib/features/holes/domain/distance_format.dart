/// Formats a distance in metres the way the hole list shows it: metres
/// below 1 km (rounded), kilometres with one decimal beyond that.
String formatDistanceM(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
