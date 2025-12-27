import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  late Dio dio;
  late UrlShortenerRemoteDatasourceImpl datasource;

  setUp(() {
    dio = _DioMock();
    datasource = UrlShortenerRemoteDatasourceImpl(dio);
  });

  group('UrlShortenerRemoteDatasourceImpl', () {
    const url = 'https://google.com';

    test('POST /api/alias returns model', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/alias'),
          statusCode: 201,
          data: const <String, dynamic>{'alias': 'abc'},
        ),
      );

      final result = await datasource.createAlias(url: url);

      expect(result, const AliasResponseModel(alias: 'abc'));

      verify(
        () => dio.post<dynamic>(
          '/api/alias',
          data: const <String, dynamic>{'url': url},
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).called(1);
    });

    test('maps 400 to BadRequestException', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/alias'),
          statusCode: 400,
          data: const <String, dynamic>{},
        ),
      );

      expect(
        () => datasource.createAlias(url: url),
        throwsA(isA<BadRequestException>()),
      );
    });

    test('maps connectionError to NetworkException', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/alias'),
          type: DioExceptionType.connectionError,
          message: 'connection error',
        ),
      );

      expect(
        () => datasource.createAlias(url: url),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
