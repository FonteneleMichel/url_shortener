import 'package:url_shortener/src/core/errors/url_validation_exception.dart';

class UrlValidator {
  const UrlValidator();

  bool isValid(String url) {
    final uri = Uri.tryParse(url);

    return uri != null &&
        uri.hasScheme &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  void validate(String url) {
    if (!isValid(url)) {
      throw const UrlValidationException('Invalid URL');
    }
  }
}
