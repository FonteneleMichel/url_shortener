import 'package:flutter/material.dart';

class UrlInputBar extends StatelessWidget {
  const UrlInputBar({
    required this.controller,
    required this.isLoading,
    required this.isValidUrl,
    required this.onShortenPressed,
    super.key,
  });

  final TextEditingController controller;
  final bool isLoading;
  final bool Function(String) isValidUrl;
  final VoidCallback onShortenPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text.trim();
        final canSubmit = text.isNotEmpty && isValidUrl(text) && !isLoading;

        return Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('url_input'),
                controller: controller,
                enabled: !isLoading,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Enter a URL',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  if (canSubmit) onShortenPressed();
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                key: const Key('shorten_button'),
                onPressed: canSubmit ? onShortenPressed : null,
                child: isLoading
                    ? const SizedBox(
                        key: Key('shorten_loading'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Shorten'),
              ),
            ),
          ],
        );
      },
    );
  }
}
