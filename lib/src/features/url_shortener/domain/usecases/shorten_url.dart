import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/domain/repositories/url_shortener_repository.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';

class ShortenUrl {
  ShortenUrl({
    required UrlShortenerRepository repository,
    required UrlValidator validator,
  }) : _repository = repository,
       _validator = validator;

  final UrlShortenerRepository _repository;
  final UrlValidator _validator;

  Future<ShortenedLink> call(String url) async {
    _validator.validate(url);
    return _repository.shortenUrl(url);
  }
}
