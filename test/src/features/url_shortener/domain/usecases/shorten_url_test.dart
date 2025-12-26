import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/url_validation_exception.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/domain/repositories/url_shortener_repository.dart';
import 'package:url_shortener/src/features/url_shortener/domain/usecases/shorten_url.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

class _MockUrlShortenerRepository extends Mock implements UrlShortenerRepository {}

void main() {
  group('ShortenUrl', () {
    late UrlShortenerRepository repository;
    late ShortenUrl usecase;

    setUp(() {
      repository = _MockUrlShortenerRepository();
      usecase = ShortenUrl(
        repository: repository,
        validator: const UrlValidator(),
      );
    });

    test('throws UrlValidationException when url is invalid and does not call repository', () async {
      expect(
            () => usecase('not-a-url'),
        throwsA(isA<UrlValidationException>()),
      );

      verifyNever(() => repository.shortenUrl(url: any(named: 'url')));
    });

    test('calls repository with trimmed url and returns ShortenedLink', () async {
      const input = '  https://example.com  ';

      final expected = ShortenedLink(
        originalUrl: 'https://example.com',
        alias: 'abc123',
        createdAt: DateTime(2025, 12, 26),
      );

      when(() => repository.shortenUrl(url: any(named: 'url')))
          .thenAnswer((invocation) async {
        final url = invocation.namedArguments[#url] as String;
        expect(url, 'https://example.com');
        return expected;
      });

      final result = await usecase(input);

      expect(result, expected);
      verify(() => repository.shortenUrl(url: 'https://example.com')).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
