import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:url_shortener/src/core/errors/url_validation_exception.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/domain/repositories/url_shortener_repository.dart';
import 'package:url_shortener/src/features/url_shortener/domain/usecases/shorten_url.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

class _MockUrlShortenerRepository extends Mock
    implements UrlShortenerRepository {}

class _MockUrlValidator extends Mock implements UrlValidator {}

void main() {
  late UrlShortenerRepository repository;
  late UrlValidator validator;
  late ShortenUrl usecase;

  setUp(() {
    repository = _MockUrlShortenerRepository();
    validator = _MockUrlValidator();
    usecase = ShortenUrl(repository: repository, validator: validator);
  });

  test('does not call repository when url is invalid', () async {
    when(() => validator.validate(any())).thenThrow(
      const UrlValidationException('Invalid URL'),
    );

    expect(
      () => usecase('not-a-url'),
      throwsA(isA<UrlValidationException>()),
    );

    verify(() => validator.validate('not-a-url')).called(1);
    verifyNever(() => repository.shortenUrl(any()));
  });

  test(
    'calls repository and returns shortened link when url is valid',
    () async {
      const inputUrl = 'https://example.com';

      // Use non-default month/day to avoid avoid_redundant_argument_values lint.
      final now = DateTime(2025, 12, 31);

      final expected = ShortenedLink(
        originalUrl: inputUrl,
        shortUrl: 'https://short.ly/abc123',
        createdAt: now,
      );

      when(() => validator.validate(any())).thenReturn(null);
      when(
        () => repository.shortenUrl(any()),
      ).thenAnswer((_) async => expected);

      final result = await usecase(inputUrl);

      expect(result, expected);

      verify(() => validator.validate(inputUrl)).called(1);
      verify(() => repository.shortenUrl(inputUrl)).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
