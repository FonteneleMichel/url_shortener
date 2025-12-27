import 'package:dio/dio.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

class UrlShortenerRemoteDatasourceImpl implements UrlShortenerRemoteDatasource {
  const UrlShortenerRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AliasResponseModel> createAlias({required String url}) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/alias',
        data: <String, dynamic>{'url': url},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const UnexpectedException('Invalid response body');
      }

      return AliasResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on FormatException catch (_) {
      throw const UnexpectedException('Invalid response format');
    }
  }

  InfrastructureException _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(e.message ?? 'Connection error');
    }

    final statusCode = e.response?.statusCode;

    if (statusCode == 400) {
      final msg = _extractBackendMessage(e.response?.data);
      return BadRequestException(msg ?? e.message ?? 'Bad request');
    }

    return UnexpectedException(e.message ?? 'Unexpected error');
  }

  String? _extractBackendMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
    }
    return null;
  }
}
