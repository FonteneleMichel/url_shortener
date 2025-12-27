import 'package:dio/dio.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/core/http/api_config.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

class UrlShortenerRemoteDatasourceImpl implements UrlShortenerRemoteDatasource {
  UrlShortenerRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AliasResponseModel> createAlias({required String url}) async {
    try {
      final response = await _dio.post<dynamic>(
        ApiConfig.aliasPath,
        data: <String, dynamic>{'url': url},
        options: Options(
          headers: const <String, dynamic>{
            'Content-Type': 'application/json',
          },
        ),
      );

      final status = response.statusCode ?? 0;

      // API esperada: 201 { "alias": "...", "_links": {...} }
      if (status == 201 || status == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return AliasResponseModel.fromJson(data);
        }
        throw const UnexpectedException('Invalid response body');
      }

      if (status == 400) {
        throw const BadRequestException();
      }

      throw UnexpectedException('Unexpected status code: $status');
    } on DioException catch (e) {
      // Timeout / sem rede / DNS etc.
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(e.message ?? 'Network error');
      }

      // Resposta HTTP com status >= 400
      final status = e.response?.statusCode;
      if (status == 400) {
        throw const BadRequestException();
      }

      throw UnexpectedException(e.message ?? 'Unexpected Dio error');
    } on InfrastructureException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }
}
