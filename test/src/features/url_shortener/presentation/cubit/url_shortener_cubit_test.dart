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
      'emits loading then success with item added to history',
      build: () => UrlShortenerCubit(
        shortenUrl: ({required String url}) async => Right(
          ShortenedLink(
            originalUrl: url,
            alias: 'abc',
            createdAt: DateTime(2025, 12, 27, 10),
          ),
        ),
        isValidUrl: (_) => true,
      ),
      act: (cubit) => cubit.shorten(url: 'https://example.com'),
      expect: () => <UrlShortenerState>[
        const UrlShortenerState(isLoading: true),
        UrlShortenerState(
          history: <ShortenedLink>[
            ShortenedLink(
              originalUrl: 'https://example.com',
              alias: 'abc',
              createdAt: DateTime(2025, 12, 27, 10),
            ),
          ],
        ),
      ],
    );

    blocTest<UrlShortenerCubit, UrlShortenerState>(
      'emits failure when invalid url',
      build: () => UrlShortenerCubit(
        shortenUrl: ({required String url}) async =>
            const Left(UnexpectedFailure()),
        isValidUrl: (_) => false,
      ),
      act: (cubit) => cubit.shorten(url: 'invalid'),
      expect: () => <UrlShortenerState>[
        const UrlShortenerState(failure: BadRequestFailure()),
      ],
    );

    blocTest<UrlShortenerCubit, UrlShortenerState>(
      'clearHistory emits empty history when there are items',
      build: () => UrlShortenerCubit(
        shortenUrl: ({required String url}) async =>
            const Left(UnexpectedFailure()),
        isValidUrl: (_) => true,
      ),
      seed: () => UrlShortenerState(
        history: <ShortenedLink>[
          ShortenedLink(
            originalUrl: 'https://example.com',
            alias: 'abc',
            createdAt: DateTime(2025, 12, 27, 10),
          ),
        ],
      ),
      act: (cubit) => cubit.clearHistory(),
      expect: () => <UrlShortenerState>[
        const UrlShortenerState(),
      ],
    );
  });
}
