import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/url_validation_exception.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/domain/repositories/url_shortener_repository.dart';
import 'package:url_shortener/src/features/url_shortener/domain/usecases/shorten_url.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

class _MockUrlShortenerRepository extends Mock {
  Future<Either<Failure, ShortenedLink>> call({required String url});
}

class _MockUrlValidator extends Mock implements UrlValidator {}

void main() {
  late _MockUrlShortenerRepository repositoryMock;
  late UrlShortenerRepository repository;
  late UrlValidator validator;
  late ShortenUrl usecase;

  setUp(() {
    repositoryMock = _MockUrlShortenerRepository();
    repository = repositoryMock.call;
    validator = _MockUrlValidator();
    usecase = ShortenUrl(repository: repository, validator: validator);
  });

  test(
    'returns Left(InvalidUrlFailure) and does not call repository '
    'when url is invalid',
    () async {
      when(() => validator.isValid(any())).thenReturn(false);

      final result = await usecase.call(url: 'not-a-url');

      expect(result.isLeft(), isTrue);

      result.fold(
        (failure) => expect(failure, isA<InvalidUrlFailure>()),
        (_) => fail('Expected Left, got Right'),
      );

      verify(() => validator.isValid('not-a-url')).called(1);
      verifyNever(() => repositoryMock.call(url: any(named: 'url')));
      verifyNoMoreInteractions(repositoryMock);
    },
  );

  test(
    'calls repository and returns Right(ShortenedLink) when url is valid',
    () async {
      const inputUrl = 'https://example.com';
      final now = DateTime(2025, 12, 31);

      final expected = ShortenedLink(
        originalUrl: inputUrl,
        alias: 'abc123',
        createdAt: now,
      );

      when(() => validator.isValid(any())).thenReturn(true);
      when(() => repositoryMock.call(url: any(named: 'url'))).thenAnswer(
        (_) async => Right<Failure, ShortenedLink>(expected),
      );

      final result = await usecase.call(url: inputUrl);

      expect(result.isRight(), isTrue);

      result.fold(
        (failure) => fail('Expected Right, got Left: $failure'),
        (value) => expect(value, expected),
      );

      verify(() => validator.isValid(inputUrl)).called(1);
      verify(() => repositoryMock.call(url: inputUrl)).called(1);
      verifyNoMoreInteractions(repositoryMock);
    },
  );
}
