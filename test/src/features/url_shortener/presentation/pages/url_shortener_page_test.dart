import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/core/errors/network_failure.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/pages/url_shortener_page.dart';

void main() {
  testWidgets('render inicial (lista vazia)', (tester) async {
    final cubit = UrlShortenerCubit(
      shortenUrl: ({required String url}) async =>
          const Left(UnexpectedFailure()),
      isValidUrl: (_) => false,
    );

    await tester.pumpWidget(MaterialApp(home: UrlShortenerPage(cubit: cubit)));
    await tester.pump();

    expect(find.byKey(const Key('empty_state')), findsOneWidget);
    expect(find.byKey(const Key('history_list')), findsNothing);
  });

  testWidgets('button disabled when url invalid; enabled when valid', (
    tester,
  ) async {
    final cubit = UrlShortenerCubit(
      shortenUrl: ({required String url}) async =>
          const Left(UnexpectedFailure()),
      isValidUrl: (url) => url.startsWith('https://'),
    );

    await tester.pumpWidget(MaterialApp(home: UrlShortenerPage(cubit: cubit)));
    await tester.pump();

    final buttonFinder = find.byKey(const Key('shorten_button'));

    final initialButton = tester.widget<ElevatedButton>(buttonFinder);
    expect(initialButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('url_input')),
      'https://example.com',
    );
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(buttonFinder);
    expect(enabledButton.onPressed, isNotNull);
  });

  testWidgets('digitar URL + clicar -> mostra loading -> lista atualiza', (
    tester,
  ) async {
    final completer = Completer<Either<UnexpectedFailure, ShortenedLink>>();

    final cubit = UrlShortenerCubit(
      shortenUrl: ({required String url}) => completer.future,
      isValidUrl: (_) => true,
    );

    await tester.pumpWidget(MaterialApp(home: UrlShortenerPage(cubit: cubit)));
    await tester.pump();

    const url = 'https://example.com';

    await tester.enterText(find.byKey(const Key('url_input')), url);
    await tester.pump();

    await tester.tap(find.byKey(const Key('shorten_button')));
    await tester.pump();

    expect(find.byKey(const Key('shorten_loading')), findsOneWidget);

    completer.complete(
      Right<UnexpectedFailure, ShortenedLink>(
        ShortenedLink(
          originalUrl: url,
          alias: 'abc',
          createdAt: DateTime(2025, 12, 27, 10),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shorten_loading')), findsNothing);
    expect(find.text('abc'), findsOneWidget);
    expect(find.byKey(const Key('history_list')), findsOneWidget);
  });

  testWidgets('shows SnackBar when shortening fails with NetworkFailure', (
    tester,
  ) async {
    final cubit = UrlShortenerCubit(
      shortenUrl: ({required String url}) async => const Left(NetworkFailure()),
      isValidUrl: (_) => true,
    );

    await tester.pumpWidget(MaterialApp(home: UrlShortenerPage(cubit: cubit)));
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('url_input')),
      'https://example.com',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('shorten_button')));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Network error. Check your connection.'), findsOneWidget);
  });

  testWidgets(
    'clear history flow: confirm dialog clears list and shows SnackBar',
    (tester) async {
      final cubit = UrlShortenerCubit(
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

      await tester.pumpWidget(
        MaterialApp(home: UrlShortenerPage(cubit: cubit)),
      );
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('url_input')),
        'https://example.com',
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('shorten_button')));
      await tester.pump();
      await tester.pump();

      expect(find.text('abc'), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear_history_button')));
      await tester.pumpAndSettle();

      expect(find.text('Clear history?'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_state')), findsOneWidget);
      expect(find.text('History cleared.'), findsOneWidget);
    },
  );
}
