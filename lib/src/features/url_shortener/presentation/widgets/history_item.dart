import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({
    required this.link,
    required this.onCopy,
    super.key,
  });

  final ShortenedLink link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          link.originalUrl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(link.alias),
        trailing: IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy),
          onPressed: onCopy,
        ),
      ),
    );
  }

  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }
}
