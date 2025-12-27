import 'package:flutter/material.dart';

class UrlInputBar extends StatelessWidget {
  const UrlInputBar({
    required this.controller,
    required this.isLoading,
    required this.isValidUrl,
    required this.onShortenPressed,
    super.key,
    this.hintText = 'Cole sua URL aqui',
    this.textFieldKey = const Key('url_input'),
    this.buttonKey = const Key('shorten_button'),
  });

  final TextEditingController controller;
  final bool isLoading;
  final bool Function(String url) isValidUrl;
  final Future<void> Function() onShortenPressed;

  final String hintText;
  final Key textFieldKey;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final trimmed = value.text.trim();
        final canSubmit = !isLoading && isValidUrl(trimmed);

        return Row(
          children: [
            Expanded(
              child: TextField(
                key: textFieldKey,
                controller: controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) async {
                  if (!canSubmit) return;
                  await onShortenPressed();
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              key: buttonKey,
              onPressed: canSubmit ? () async => onShortenPressed() : null,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Encurtar'),
            ),
          ],
        );
      },
    );
  }
}
