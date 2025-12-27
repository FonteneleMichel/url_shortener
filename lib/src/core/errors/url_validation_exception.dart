import 'package:url_shortener/src/core/errors/failure.dart';

class InvalidUrlFailure extends Failure {
  const InvalidUrlFailure(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

class UrlValidationException implements Exception {
  const UrlValidationException(this.message);

  final String message;

  @override
  String toString() => 'UrlValidationException: $message';
}
