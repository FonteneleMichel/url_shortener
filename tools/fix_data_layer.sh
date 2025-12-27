#!/usr/bin/env bash
set -euo pipefail

# ---------- AliasResponseModel (corrige createdAt + package imports) ----------
cat > lib/src/features/url_shortener/data/models/alias_response_model.dart <<'EOF'
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

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

  ShortenedLink toEntity({
    required String originalUrl,
    required DateTime createdAt,
  }) {
    return ShortenedLink(
      originalUrl: originalUrl,
      alias: alias,
      createdAt: createdAt,
    );
  }
}
EOF

# ---------- Datasource contrato (package import + ignore lint) ----------
cat > lib/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart <<'EOF'
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

// ignore: one_member_abstracts
abstract class UrlShortenerRemoteDatasource {
  Future<AliasResponseModel> createAlias({required String url});
}
EOF

# ---------- Datasource impl (package imports) ----------
cat > lib/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart <<'EOF'
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
EOF

# ---------- Repository impl (callable: resolve typedef issue) ----------
cat > lib/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart <<'EOF'
import 'package:dartz/dartz.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

/// NOTE:
/// No seu Domain, `UrlShortenerRepository` é um typedef de função.
/// Em Dart, a forma correta de implementar isso com classe é torná-la "callable"
/// via método `call({required String url})`.
class UrlShortenerRepositoryImpl {
  UrlShortenerRepositoryImpl(
    this._remote, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final UrlShortenerRemoteDatasource _remote;
  final DateTime Function() _now;

  Future<Either<Failure, ShortenedLink>> call({required String url}) async {
    try {
      final model = await _remote.createAlias(url: url);
      final entity = model.toEntity(
        originalUrl: url,
        createdAt: _now(),
      );
      return Right(entity);
    } on InfrastructureException catch (e) {
      return Left(_mapInfraToFailure(e));
    } catch (_) {
      return Left(const UnexpectedFailure());
    }
  }

  Failure _mapInfraToFailure(InfrastructureException e) {
    if (e is NetworkException) return const NetworkFailure();
    if (e is BadRequestException) return const BadRequestFailure();
    return const UnexpectedFailure();
  }
}
EOF

# ---------- Tests: Model (ok) ----------
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

# ---------- Tests: Datasource impl (remove http_mock_adapter; mock Dio) ----------
cat > test/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl_test.dart <<'EOF'
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
EOF

# ---------- Tests: Repository (callable + clock determinística) ----------
cat > test/src/features/url_shortener/data/repositories/url_shortener_repository_impl_test.dart <<'EOF'
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';
import 'package:url_shortener/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class _RemoteDatasourceMock extends Mock implements UrlShortenerRemoteDatasource {}

void main() {
  group('UrlShortenerRepositoryImpl', () {
    late _RemoteDatasourceMock remote;

    setUp(() {
      remote = _RemoteDatasourceMock();
    });

    test('returns Right(entity) mapped from model', () async {
      const url = 'https://google.com';
      const fixedNow = DateTime(2025, 12, 27, 10, 0);

      final repo = UrlShortenerRepositoryImpl(remote, now: () => fixedNow);

      when(() => remote.createAlias(url: url))
          .thenAnswer((_) async => const AliasResponseModel(alias: 'abc'));

      final result = await repo(url: url);

      expect(result, isA<Either<Failure, ShortenedLink>>());

      result.fold(
        (l) => fail('Expected Right, got Left: $l'),
        (r) {
          expect(r.originalUrl, url);
          expect(r.alias, 'abc');
          expect(r.createdAt, fixedNow);
        },
      );

      verify(() => remote.createAlias(url: url)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('maps NetworkException to Left(NetworkFailure)', () async {
      const url = 'https://google.com';
      final repo = UrlShortenerRepositoryImpl(remote, now: () => DateTime(2025, 12, 27));

      when(() => remote.createAlias(url: url)).thenThrow(const NetworkException('offline'));

      final result = await repo(url: url);

      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('Expected Left, got Right: $r'),
      );
    });
  });
}
EOF

echo "Fix aplicado (data layer + tests)."
