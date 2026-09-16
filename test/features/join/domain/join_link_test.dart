import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/features/join/domain/join_link.dart';

void main() {
  test('builds a plain path under the given origin', () {
    final link = joinUrl(
      'ABC123',
      origin: Uri.parse('https://nuni.centuryspine.org'),
    );
    expect(link.toString(), 'https://nuni.centuryspine.org/join/ABC123');
  });

  test('resolves against a local dev origin the same way', () {
    final link = joinUrl('ABC123', origin: Uri.parse('http://localhost:3000'));
    expect(link.toString(), 'http://localhost:3000/join/ABC123');
  });
}
