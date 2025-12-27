import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/network_failure.dart';

String failureMessage(Failure failure) {
  if (failure is NetworkFailure) {
    return 'Network error. Check your connection.';
  }

  if (failure is BadRequestFailure) {
    return 'Invalid URL. Please try again.';
  }

  return 'Unexpected error. Please try again.';
}
