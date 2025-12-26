import 'package:url_shortener/src/core/errors/app_exception.dart';

class UrlValidationException extends AppException {
  const UrlValidationException(super.message);

  @override
  String toString() => 'UrlValidationException: $message';
}
