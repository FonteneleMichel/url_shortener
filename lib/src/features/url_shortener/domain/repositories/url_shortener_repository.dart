import 'package:dartz/dartz.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

typedef UrlShortenerRepository =
    Future<Either<Failure, ShortenedLink>> Function({
      required String url,
    });
