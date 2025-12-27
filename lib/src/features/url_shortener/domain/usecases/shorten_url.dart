import 'package:dartz/dartz.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/url_validation_exception.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/domain/repositories/url_shortener_repository.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

class ShortenUrl {
  const ShortenUrl({
    required this.repository,
    required this.validator,
  });

  final UrlShortenerRepository repository;
  final UrlValidator validator;

  Future<Either<Failure, ShortenedLink>> call({required String url}) async {
    final trimmed = url.trim();

    if (!validator.isValid(trimmed)) {
      return Left(InvalidUrlFailure(trimmed));
    }

    return repository(url: trimmed);
  }
}
