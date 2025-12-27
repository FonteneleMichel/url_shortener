import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

void main() {
  group('UrlValidator', () {
    const validator = UrlValidator();

    test('returns true for valid https URL', () {
      expect(validator.isValid('https://nubank.com.br'), isTrue);
    });

    test('returns true for valid http URL with path and query', () {
      expect(
        validator.isValid('http://example.com/path?a=1&b=2'),
        isTrue,
      );
    });

    test('returns false for empty string', () {
      expect(validator.isValid(''), isFalse);
      expect(validator.isValid('   '), isFalse);
    });

    test('returns false when missing scheme', () {
      expect(validator.isValid('google.com'), isFalse);
      expect(validator.isValid('www.google.com'), isFalse);
    });

    test('returns false for unsupported scheme', () {
      expect(validator.isValid('ftp://example.com'), isFalse);
    });

    test('returns false for invalid absolute URL', () {
      expect(validator.isValid('http://'), isFalse);
      expect(validator.isValid('not a url'), isFalse);
    });
  });
}
