import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

/// Domain contract for URL shortener feature.
abstract class UrlShortenerRepository {
  /// Shortens a URL using the underlying data source.
  Future<ShortenedLink> shortenUrl(String url);

  /// Returns the locally stored history (in-memory for this take-home).
  Future<List<ShortenedLink>> getHistory();

  /// Adds a link to history.
  Future<void> saveToHistory(ShortenedLink link);

  /// Clears history.
  Future<void> clearHistory();
}
