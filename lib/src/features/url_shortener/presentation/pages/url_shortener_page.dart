import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_state.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/utils/failure_message.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/widgets/shortened_links_list.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/widgets/url_input_bar.dart';

class UrlShortenerPage extends StatefulWidget {
  const UrlShortenerPage({
    super.key,
    this.cubit,
  });

  /// Permite injeção direta em testes (opcional).
  final UrlShortenerCubit? cubit;

  @override
  State<UrlShortenerPage> createState() => _UrlShortenerPageState();
}

class _UrlShortenerPageState extends State<UrlShortenerPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmAndClearHistory(
    BuildContext context,
    UrlShortenerCubit cubit,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear history?'),
          content: const Text('This will remove all shortened links.'),
          actions: [
            TextButton(
              key: const Key('cancel_clear_history'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('confirm_clear_history'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (shouldClear ?? false) {
      cubit.clearHistory();
      _showSnackBar(context, 'History cleared.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = MultiBlocListener(
      listeners: [
        BlocListener<UrlShortenerCubit, UrlShortenerState>(
          listenWhen: (previous, current) {
            return previous.failure != current.failure &&
                current.failure != null;
          },
          listener: (context, state) {
            final failure = state.failure;
            if (failure == null) return;

            _showSnackBar(context, failureMessage(failure));
            context.read<UrlShortenerCubit>().clearFailure();
          },
        ),
        BlocListener<UrlShortenerCubit, UrlShortenerState>(
          listenWhen: (previous, current) {
            return current.history.length > previous.history.length;
          },
          listener: (context, state) {
            _controller.clear();
            FocusScope.of(context).unfocus();
          },
        ),
      ],
      child: BlocBuilder<UrlShortenerCubit, UrlShortenerState>(
        builder: (context, state) {
          final cubit = context.read<UrlShortenerCubit>();

          final canClearHistory = state.history.isNotEmpty && !state.isLoading;
          final onClearHistoryPressed = canClearHistory
              ? () => _confirmAndClearHistory(context, cubit)
              : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('URL Shortener'),
              actions: [
                IconButton(
                  key: const Key('clear_history_button'),
                  tooltip: 'Clear history',
                  onPressed: onClearHistoryPressed,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    UrlInputBar(
                      controller: _controller,
                      isLoading: state.isLoading,
                      isValidUrl: cubit.isValid,
                      onShortenPressed: () async {
                        final url = _controller.text.trim();
                        await cubit.shorten(url: url);
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ShortenedLinksList(links: state.history),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    final injectedCubit = widget.cubit;
    if (injectedCubit == null) return page;

    return BlocProvider<UrlShortenerCubit>.value(
      value: injectedCubit,
      child: page,
    );
  }
}
