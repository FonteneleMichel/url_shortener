#!/usr/bin/env bash
set -euo pipefail

mkdir -p lib/src/core/errors
mkdir -p lib/src/features/url_shortener/data/datasources
mkdir -p lib/src/features/url_shortener/data/models
mkdir -p lib/src/features/url_shortener/data/repositories
mkdir -p test/src/features/url_shortener/data/datasources
mkdir -p test/src/features/url_shortener/data/models
mkdir -p test/src/features/url_shortener/data/repositories

cat > lib/src/core/errors/infrastructure_exceptions.dart <<'EOF'
abstract class InfrastructureException implements Exception {
  const InfrastructureException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends InfrastructureException {
  const NetworkException([super.message = 'Network error']);
}

final class BadRequestException extends InfrastructureException {
  const BadRequestException([super.message = 'Bad request']);
}

final class UnexpectedException extends InfrastructureException {
  const UnexpectedException([super.message = 'Unexpected error']);
}
EOF

cat > lib/src/features/url_shortener/data/models/alias_response_model.dart <<'EOF'
import '../../domain/entities/shortened_link.dart';

class AliasResponseModel {
  const AliasResponseModel({
    required this.alias,
  });

  final String alias;

  factory AliasResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic aliasValue = json['alias'];

    if (aliasValue is! String || aliasValue.isEmpty) {
      throw const FormatException('Invalid alias response: "alias" is missing');
    }

    return AliasResponseModel(alias: aliasValue);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'alias': alias};

  ShortenedLink toEntity({required String originalUrl}) {
    return ShortenedLink(
      originalUrl: originalUrl,
      alias: alias,
    );
  }
}
EOF

cat > lib/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart <<'EOF'
import '../models/alias_response_model.dart';

abstract class UrlShortenerRemoteDatasource {
  Future<AliasResponseModel> createAlias({required String url});
}
EOF

cat > lib/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart <<'EOF'
import 'package:dio/dio.dart';

import '../../../../core/errors/infrastructure_exceptions.dart';
import '../models/alias_response_model.dart';
import 'url_shortener_remote_datasource.dart';

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
EOF

cat > lib/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart <<'EOF'
import '../../../../core/errors/infrastructure_exceptions.dart';
import '../../domain/entities/shortened_link.dart';
import '../../domain/repositories/url_shortener_repository.dart';
import '../datasources/url_shortener_remote_datasource.dart';

class UrlShortenerRepositoryImpl implements UrlShortenerRepository {
  const UrlShortenerRepositoryImpl(this._remote);

  final UrlShortenerRemoteDatasource _remote;

  @override
  Future<ShortenedLink> shortenUrl({required String url}) async {
    try {
      final model = await _remote.createAlias(url: url);
      return model.toEntity(originalUrl: url);
    } on InfrastructureException {
      rethrow;
    } catch (_) {
      throw const UnexpectedException();
    }
  }
}
EOF

cat > test/src/features/url_shortener/data/models/alias_response_model_test.dart <<'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

void main() {
  group('AliasResponseModel', () {
    test('fromJson parses alias', () {
      final model = AliasResponseModel.fromJson(<String, dynamic>{'alias': 'abc'});
      expect(model.alias, 'abc');
    });

    test('fromJson throws FormatException when alias missing', () {
      expect(
        () => AliasResponseModel.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson serializes alias', () {
      const model = AliasResponseModel(alias: 'abc');
      expect(model.toJson(), <String, dynamic>{'alias': 'abc'});
    });
  });
}
EOF

cat > test/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl_test.dart <<'EOF'
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  group('UrlShortenerRemoteDatasourceImpl', () {
    test('POST /api/alias returns AliasResponseModel', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      final datasource = UrlShortenerRemoteDatasourceImpl(dio);

      const url = 'https://google.com';
      adapter.onPost(
        '/api/alias',
        (server) => server.reply(200, <String, dynamic>{'alias': 'abc'}),
        data: <String, dynamic>{'url': url},
      );

      final result = await datasource.createAlias(url: url);
      expect(result.alias, 'abc');
    });

    test('maps 400 to BadRequestException', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      final datasource = UrlShortenerRemoteDatasourceImpl(dio);

      const url = 'not-a-url';
      adapter.onPost(
        '/api/alias',
        (server) => server.reply(400, <String, dynamic>{'message': 'Invalid url'}),
        data: <String, dynamic>{'url': url},
      );

      expect(
        () => datasource.createAlias(url: url),
        throwsA(isA<BadRequestException>()),
      );
    });

    test('maps connectionError to NetworkException', () async {
      final dio = _DioMock();
      final datasource = UrlShortenerRemoteDatasourceImpl(dio);

      const url = 'https://google.com';

      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
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
EOF

cat > test/src/features/url_shortener/data/repositories/url_shortener_repository_impl_test.dart <<'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';
import 'package:url_shortener/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart';

class _RemoteDatasourceMock extends Mock implements UrlShortenerRemoteDatasource {}

void main() {
  group('UrlShortenerRepositoryImpl', () {
    late _RemoteDatasourceMock remote;
    late UrlShortenerRepositoryImpl repository;

    setUp(() {
      remote = _RemoteDatasourceMock();
      repository = UrlShortenerRepositoryImpl(remote);
    });

    test('returns entity mapped from model', () async {
      const url = 'https://google.com';
      when(() => remote.createAlias(url: url))
          .thenAnswer((_) async => const AliasResponseModel(alias: 'abc'));

      final entity = await repository.shortenUrl(url: url);

      expect(entity.originalUrl, url);
      expect(entity.alias, 'abc');

      verify(() => remote.createAlias(url: url)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('rethrows InfrastructureException', () async {
      const url = 'https://google.com';
      when(() => remote.createAlias(url: url))
          .thenThrow(const NetworkException('offline'));

      expect(
        () => repository.shortenUrl(url: url),
        throwsA(isA<NetworkException>()),
      );
    });

    test('wraps unknown errors into UnexpectedException', () async {
      const url = 'https://google.com';
      when(() => remote.createAlias(url: url)).thenThrow(StateError('boom'));

      expect(
        () => repository.shortenUrl(url: url),
        throwsA(isA<UnexpectedException>()),
      );
    });
  });
}
EOF

echo "Arquivos criados e preenchidos com sucesso."
