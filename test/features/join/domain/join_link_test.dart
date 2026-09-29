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

  group('codeFromScan', () {
    test('reads the code out of an invite link', () {
      expect(
        codeFromScan('https://nuni.centuryspine.org/join/ABC234'),
        'ABC234',
      );
      expect(codeFromScan('http://localhost:3000/join/abc234 '), 'ABC234');
    });

    test('takes a bare code as is', () {
      expect(codeFromScan(' k7m2pq '), 'K7M2PQ');
    });

    test('refuses anything else', () {
      expect(codeFromScan('https://example.com/some/page'), isNull);
      expect(codeFromScan('https://example.com/join/'), isNull);
      expect(codeFromScan('https://example.com/join/ABC234/x'), isNull);
      expect(codeFromScan('hello world'), isNull);
      expect(codeFromScan(''), isNull);
    });
  });
}
