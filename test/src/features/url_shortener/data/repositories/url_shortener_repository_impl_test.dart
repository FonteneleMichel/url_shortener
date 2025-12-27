import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/core/errors/network_failure.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';
import 'package:url_shortener/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class _RemoteDatasourceMock extends Mock
    implements UrlShortenerRemoteDatasource {}

void main() {
  group('UrlShortenerRepositoryImpl', () {
    late _RemoteDatasourceMock remote;

    setUp(() {
      remote = _RemoteDatasourceMock();
    });

    test('returns Right(entity) mapped from model', () async {
      const url = 'https://google.com';
      final fixedNow = DateTime(2025, 12, 27, 10);

      final repo = UrlShortenerRepositoryImpl(remote, now: () => fixedNow);

      when(
        () => remote.createAlias(url: url),
      ).thenAnswer((_) async => const AliasResponseModel(alias: 'abc'));

      final result = await repo(url: url);

      expect(result, isA<Either<Failure, ShortenedLink>>());

      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) {
          expect(r.originalUrl, url);
          expect(r.alias, 'abc');
          expect(r.createdAt, fixedNow);
        },
      );

      verify(() => remote.createAlias(url: url)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('maps NetworkException to Left(NetworkFailure)', () async {
      const url = 'https://google.com';
      final repo = UrlShortenerRepositoryImpl(remote);

      when(
        () => remote.createAlias(url: url),
      ).thenThrow(const NetworkException('offline'));

      final result = await repo(url: url);

      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('Expected Left, got Right: $r'),
      );
    });

    test('maps BadRequestException to Left(BadRequestFailure)', () async {
      const url = 'https://google.com';
      final repo = UrlShortenerRepositoryImpl(remote);

      when(
        () => remote.createAlias(url: url),
      ).thenThrow(const BadRequestException('invalid'));

      final result = await repo(url: url);

      result.fold(
        (l) => expect(l, isA<BadRequestFailure>()),
        (r) => fail('Expected Left, got Right: $r'),
      );
    });
  });
}
