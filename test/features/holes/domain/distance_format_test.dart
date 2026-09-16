import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/holes/domain/distance_format.dart';

void main() {
  test('formats sub-kilometre distances as rounded metres', () {
    expect(formatDistanceM(42.4), '42 m');
    expect(formatDistanceM(999), '999 m');
  });

  test('formats distances of 1 km and beyond in kilometres, one decimal', () {
    expect(formatDistanceM(1000), '1.0 km');
    expect(formatDistanceM(2350), '2.4 km');
  });
}
