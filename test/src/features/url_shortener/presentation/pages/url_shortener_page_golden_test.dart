import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_shortener/src/core/errors/network_failure.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/pages/url_shortener_page.dart';

void main() {
  testGoldens('UrlShortenerPage empty', (tester) async {
    final cubit = UrlShortenerCubit(
      shortenUrl: ({required String url}) async => const Left(NetworkFailure()),
      isValidUrl: (_) => true,
    );

    addTearDown(cubit.close);

    await tester.pumpWidgetBuilder(
      UrlShortenerPage(cubit: cubit),
      surfaceSize: const Size(420, 900),
    );

    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'url_shortener_page_empty');
  });

  testGoldens('UrlShortenerPage with history', (tester) async {
    const url = 'https://example.com';

    final cubit = UrlShortenerCubit(
      shortenUrl: ({required String url}) async {
        return Right(
          ShortenedLink(
            originalUrl: url,
            alias: 'abc123',
            createdAt: DateTime(2025, 12, 27, 10),
          ),
        );
      },
      isValidUrl: (_) => true,
    );

    addTearDown(cubit.close);

    await cubit.shorten(url: url);

    await tester.pumpWidgetBuilder(
      UrlShortenerPage(cubit: cubit),
      surfaceSize: const Size(420, 900),
    );

    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'url_shortener_page_with_history');
  });
}
