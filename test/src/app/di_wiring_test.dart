import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:url_shortener/src/core/http/api_config.dart';
import 'package:url_shortener/src/di.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  test(
    'DI wiring: UrlShortenerCubit shortens URL end-to-end with mocked Dio',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final adapter = DioAdapter(dio: dio)
        ..onPost(
          ApiConfig.aliasPath,
          (server) => server.reply(
            200,
            <String, dynamic>{'alias': 'abc123'},
          ),
          data: <String, dynamic>{'url': 'https://example.com'},
        );

      dio.httpClientAdapter = adapter;

      configureDependencies(dio: dio);

      final cubit = sl.get<UrlShortenerCubit>();

      await cubit.shorten(url: 'https://example.com');

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.history, isNotEmpty);
      expect(cubit.state.history.first.alias, 'abc123');
      expect(cubit.state.history.first.originalUrl, 'https://example.com');
    },
  );
}
