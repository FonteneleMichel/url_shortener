/// Deterministic URL validator (pure Dart).
///
/// Rules (simple and testable):
/// - Must be parseable by [Uri.tryParse]
/// - Must be absolute
/// - Must have scheme http/https
/// - Must have non-empty host
class UrlValidator {
  const UrlValidator();

  bool isValid(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;

    if (!uri.isAbsolute) return false;

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return false;

    if (uri.host.trim().isEmpty) return false;

    return true;
  }
}
