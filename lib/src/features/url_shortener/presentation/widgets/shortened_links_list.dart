import 'package:flutter/material.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/widgets/shortened_link_tile.dart';

class ShortenedLinksList extends StatelessWidget {
  const ShortenedLinksList({
    required this.links,
    super.key,
    this.listKey = const Key('history_list'),
  });

  final List<ShortenedLink> links;
  final Key listKey;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: listKey,
      itemCount: links.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => ShortenedLinkTile(link: links[index]),
    );
  }
}
