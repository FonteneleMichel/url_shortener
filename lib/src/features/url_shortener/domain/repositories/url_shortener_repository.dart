import '../entities/shortened_link.dart';

abstract interface class UrlShortenerRepository {
  Future<ShortenedLink> shortenUrl({required String url});
}
