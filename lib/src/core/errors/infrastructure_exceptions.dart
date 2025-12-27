abstract class InfrastructureException implements Exception {
  const InfrastructureException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends InfrastructureException {
  const NetworkException([super.message = 'Network error']);
}

final class BadRequestException extends InfrastructureException {
  const BadRequestException([super.message = 'Bad request']);
}

final class UnexpectedException extends InfrastructureException {
  const UnexpectedException([super.message = 'Unexpected error']);
}
