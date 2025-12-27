import 'package:url_shortener/src/core/errors/failure.dart';

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class BadRequestFailure extends Failure {
  const BadRequestFailure();
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
