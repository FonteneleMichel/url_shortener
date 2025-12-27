import 'package:dartz/dartz.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/infrastructure_exceptions.dart';
import 'package:url_shortener/src/core/errors/network_failure.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

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
    } on Object {
      return const Left(UnexpectedFailure());
    }
  }

  Failure _mapInfraToFailure(InfrastructureException e) {
    if (e is NetworkException) return const NetworkFailure();
    if (e is BadRequestException) return const BadRequestFailure();
    return const UnexpectedFailure();
  }
}
