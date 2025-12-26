import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

void main() {
  group('UrlValidator', () {
    const validator = UrlValidator();

    test('returns true for valid http/https URLs', () {
      expect(validator.isValid('https://example.com'), isTrue);
      expect(validator.isValid('http://example.com'), isTrue);
      expect(validator.isValid('https://example.com/path?q=1'), isTrue);
    });

    test('returns false for empty/blank', () {
      expect(validator.isValid(''), isFalse);
      expect(validator.isValid('   '), isFalse);
    });

    test('returns false when scheme is missing', () {
      expect(validator.isValid('example.com'), isFalse);
      expect(validator.isValid('www.example.com'), isFalse);
    });

    test('returns false for non-http(s) schemes', () {
      expect(validator.isValid('ftp://example.com'), isFalse);
      expect(validator.isValid('file:///tmp/a.txt'), isFalse);
    });

    test('returns false when host is empty', () {
      expect(validator.isValid('https:///path'), isFalse);
      expect(validator.isValid('http:///'), isFalse);
    });
  });
}
