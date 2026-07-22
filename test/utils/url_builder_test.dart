import 'package:map_launcher/src/utils/url_builder.dart';
import 'package:test/test.dart';

void main() {
  group('buildUrl', () {
    test('builds URL with query params', () {
      final url = buildUrl(
        url: 'https://maps.example.com/',
        queryParams: {'q': '37.0,-122.0', 'z': '15'},
      );
      expect(url, contains('https://maps.example.com/'));
      expect(url, contains('q='));
      expect(url, contains('z=15'));
    });

    test('encodes special characters in query values', () {
      final url = buildUrl(
        url: 'https://maps.example.com/',
        queryParams: {'q': 'Coffee & Tea'},
      );
      expect(url, isNot(contains(' ')));
      expect(url, contains('Coffee'));
    });

    test('filters out empty-string values', () {
      final url = buildUrl(
        url: 'https://maps.example.com/',
        queryParams: {'q': '37.0,-122.0', 'name': '', 'label': '  '},
      );
      expect(url, contains('q='));
      expect(url, isNot(contains('name=')));
      expect(url, isNot(contains('label=')));
    });

    test('returns base URL when all values empty', () {
      final url = buildUrl(
        url: 'https://maps.example.com/',
        queryParams: {'name': '', 'label': ''},
      );
      expect(url, equals('https://maps.example.com/'));
    });

    test('strips existing query params from URL', () {
      final url = buildUrl(
        url: 'https://maps.example.com/?old=value',
        queryParams: {'new': 'param'},
      );
      expect(url, isNot(contains('old=value')));
      expect(url, contains('new=param'));
    });

    test('strips fragment from URL', () {
      final url = buildUrl(
        url: 'https://maps.example.com/#section',
        queryParams: {'q': 'test'},
      );
      expect(url, isNot(contains('#section')));
      expect(url, contains('q=test'));
    });

    test('handles scheme URLs (non-HTTPS)', () {
      final url = buildUrl(
        url: 'waze://',
        queryParams: {'ll': '37.0,-122.0', 'navigate': 'yes'},
      );
      expect(url, startsWith('waze://'));
      expect(url, contains('ll='));
      expect(url, contains('navigate=yes'));
    });

    test('handles geo: scheme URLs', () {
      final url = buildUrl(url: 'geo:0,0', queryParams: {'q': '37.0,-122.0'});
      expect(url, startsWith('geo:0,0'));
      expect(url, contains('q='));
    });
  });
}
