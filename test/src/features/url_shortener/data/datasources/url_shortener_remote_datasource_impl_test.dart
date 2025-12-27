import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  group('UrlShortenerRemoteDatasourceImpl', () {
    late Dio dio;
    late UrlShortenerRemoteDatasourceImpl datasource;

    setUp(() {
      dio = _DioMock();
      datasource = UrlShortenerRemoteDatasourceImpl(dio);
    });

    test('POST /api/alias returns model', () async {
      const url = 'https://google.com';

      when(
        () => dio.post<dynamic>(
          '/api/alias',
          data: <String, dynamic>{'url': url},
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/alias'),
          statusCode: 200,
          data: <String, dynamic>{'alias': 'abc'},
        ),
      );

      final result = await datasource.createAlias(url: url);
      expect(result.alias, 'abc');
    });

    test('maps 400 to BadRequestException', () async {
      const url = 'not-a-url';

      when(
        () => dio.post<dynamic>(
          '/api/alias',
          data: <String, dynamic>{'url': url},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/alias'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/api/alias'),
            statusCode: 400,
            data: <String, dynamic>{'message': 'Invalid url'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => datasource.createAlias(url: url),
        throwsA(isA<BadRequestException>()),
      );
    });

    test('maps connectionError to NetworkException', () async {
      const url = 'https://google.com';

      when(
        () => dio.post<dynamic>(
          '/api/alias',
          data: <String, dynamic>{'url': url},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/alias'),
          type: DioExceptionType.connectionError,
          message: 'No internet',
        ),
      );

      expect(
        () => datasource.createAlias(url: url),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
