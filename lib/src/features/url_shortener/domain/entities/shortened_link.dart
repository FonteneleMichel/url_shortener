import 'package:equatable/equatable.dart';

class ShortenedLink extends Equatable {
  const ShortenedLink({
    required this.originalUrl,
    required this.alias,
    required this.createdAt,
  });

  final String originalUrl;
  final String alias;
  final DateTime createdAt;

  @override
  List<Object?> get props => [originalUrl, alias, createdAt];
}
