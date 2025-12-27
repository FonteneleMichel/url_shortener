import 'package:flutter/material.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/widgets/shortened_link_tile.dart';

/// Compat layer: mantém referências antigas (HistoryItem) funcionando.
class HistoryItem extends StatelessWidget {
  const HistoryItem({
    required this.link,
    super.key,
  });

  final ShortenedLink link;

  @override
  Widget build(BuildContext context) {
    return ShortenedLinkTile(link: link);
  }
}
