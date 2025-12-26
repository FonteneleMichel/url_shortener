import '../entities/shortened_link.dart';
import '../repositories/url_shortener_repository.dart';
import '../validators/url_validator.dart';

final class ShortenUrl {
  final UrlShortenerRepository repository;
  final UrlValidator validator;

  const ShortenUrl({
    required this.repository,
    required this.validator,
  });

  Future<ShortenedLink> call(String url) async {
    validator.validate(url);

    final normalized = url.trim();
    return repository.shortenUrl(url: normalized);
  }
}
