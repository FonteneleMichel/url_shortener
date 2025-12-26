import '../../../../core/errors/url_validation_exception.dart';

final class UrlValidator {
  const UrlValidator();

  bool isValid(String input) {
    final value = input.trim();
    if (value.isEmpty) return false;

    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    if (!isHttp) return false;

    if (uri.host.isEmpty) return false;

    return true;
  }

  void validate(String input) {
    if (!isValid(input)) {
      throw UrlValidationException('Invalid URL: "$input"');
    }
  }
}
