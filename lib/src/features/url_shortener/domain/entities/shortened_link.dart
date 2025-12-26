final class ShortenedLink {
  final String originalUrl;
  final String alias;
  final DateTime createdAt;

  const ShortenedLink({
    required this.originalUrl,
    required this.alias,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShortenedLink &&
              runtimeType == other.runtimeType &&
              originalUrl == other.originalUrl &&
              alias == other.alias &&
              createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(originalUrl, alias, createdAt);
}
