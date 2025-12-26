import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class ShortenedLink extends Equatable {
  const ShortenedLink({
    required this.originalUrl,
    required this.shortUrl,
    required this.createdAt,
  });

  final String originalUrl;
  final String shortUrl;
  final DateTime createdAt;

  @override
  List<Object?> get props => [originalUrl, shortUrl, createdAt];
}
