import 'package:flutter/material.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/widgets/shortened_link_tile.dart';

class ShortenedLinksList extends StatelessWidget {
  const ShortenedLinksList({
    required this.links,
    super.key,
  });

  final List<ShortenedLink> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return const Center(
        key: Key('empty_state'),
        child: Text('No links yet. Shorten your first URL.'),
      );
    }

    return ListView.separated(
      key: const Key('history_list'),
      itemCount: links.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ShortenedLinkTile(link: links[index]);
      },
    );
  }
}
