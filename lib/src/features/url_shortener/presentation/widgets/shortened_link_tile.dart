import 'package:flutter/material.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class ShortenedLinkTile extends StatelessWidget {
  const ShortenedLinkTile({
    required this.link,
    super.key,
  });

  final ShortenedLink link;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.link),
      title: Text(
        link.alias,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        link.originalUrl,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
