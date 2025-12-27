import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/core/errors/failures.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_state.dart';

void main() {
  group('UrlShortenerCubit', () {
    blocTest<UrlShortenerCubit, UrlShortenerState>(
      'emits loading then adds item to history on success',
      build: () {
        return UrlShortenerCubit(
          shortenUrl: ({required String url}) async {
            return Right(
              ShortenedLink(
                originalUrl: url,
                alias: 'abc',
                createdAt: DateTime(2025, 12, 27, 10),
              ),
            );
          },
          isValidUrl: (_) => true,
        );
      },
      act: (cubit) => cubit.shorten(url: 'https://example.com'),
      expect: () => <dynamic>[
        const UrlShortenerState.initial().copyWith(
          status: UrlShortenerStatus.loading,
          clearFailure: true,
        ),
        isA<UrlShortenerState>().having(
          (s) => s.history.length,
          'history length',
          1,
        ),
      ],
    );

    blocTest<UrlShortenerCubit, UrlShortenerState>(
      'emits loading then failure on error',
      build: () {
        return UrlShortenerCubit(
          shortenUrl: ({required String url}) async =>
              const Left(NetworkFailure()),
          isValidUrl: (_) => true,
        );
      },
      act: (cubit) => cubit.shorten(url: 'https://example.com'),
      expect: () => <dynamic>[
        const UrlShortenerState.initial().copyWith(
          status: UrlShortenerStatus.loading,
          clearFailure: true,
        ),
        isA<UrlShortenerState>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );
  });
}
