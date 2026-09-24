import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/text/compare_names.dart';

void main() {
  test('ignores case and accents', () {
    final names = ['Zoé', 'émile', 'Eric', 'bruno', 'Œdipe', 'Alice'];
    expect(names..sort(compareNames), [
      'Alice',
      'bruno',
      'émile',
      'Eric',
      'Œdipe',
      'Zoé',
    ]);
  });

  test('breaks ties on the raw strings', () {
    expect(compareNames('Eric', 'éric'), isNot(0));
    expect(compareNames('Eric', 'Eric'), 0);
  });
}
