import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/failures.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_state.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/widgets/history_item.dart';

class UrlShortenerPage extends StatefulWidget {
  const UrlShortenerPage({required this.cubit, super.key});

  final UrlShortenerCubit cubit;

  @override
  State<UrlShortenerPage> createState() => _UrlShortenerPageState();
}

class _UrlShortenerPageState extends State<UrlShortenerPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmAndClearHistory(BuildContext context) async {
    final cubit = context.read<UrlShortenerCubit>();
    if (cubit.state.history.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This will remove all shortened links from the list.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed != true) return;

    cubit.clearHistory();
    messenger.showSnackBar(
      const SnackBar(content: Text('History cleared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UrlShortenerCubit>.value(
      value: widget.cubit,
      child: BlocConsumer<UrlShortenerCubit, UrlShortenerState>(
        listenWhen: (prev, curr) =>
            prev.failure != curr.failure && curr.failure != null,
        listener: (context, state) {
          final message = _failureMessage(state.failure!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          context.read<UrlShortenerCubit>().clearFailure();
        },
        builder: (context, state) {
          final cubit = context.read<UrlShortenerCubit>();
          final url = _controller.text.trim();
          final canSubmit = !state.isLoading && cubit.isValid(url);

          Future<void> submit() async {
            final currentUrl = _controller.text.trim();
            await cubit.shorten(url: currentUrl);

            if (!context.mounted) return;
            FocusScope.of(context).unfocus();
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('URL Shortener'),
              actions: <Widget>[
                IconButton(
                  key: const Key('clear_history_button'),
                  tooltip: 'Clear history',
                  onPressed: state.history.isEmpty
                      ? null
                      : () async => _confirmAndClearHistory(context),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    key: const Key('url_input'),
                    controller: _controller,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Paste a URL',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) async {
                      if (!canSubmit) return;
                      await submit();
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('shorten_button'),
                      onPressed: canSubmit ? submit : null,
                      child: state.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Shorten'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.history.isEmpty
                        ? const Center(
                            child: Text(
                              'No links yet',
                              key: Key('empty_state'),
                            ),
                          )
                        : ListView.builder(
                            key: const Key('history_list'),
                            itemCount: state.history.length,
                            itemBuilder: (context, index) {
                              final item = state.history[index];
                              return HistoryItem(
                                link: item,
                                onCopy: () => HistoryItem.copyToClipboard(
                                  context,
                                  item.alias,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _failureMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Network error. Check your connection.';
    }
    if (failure is BadRequestFailure) {
      return 'Invalid URL.';
    }
    if (failure is UnexpectedFailure) {
      return 'Unexpected error.';
    }
    return 'Something went wrong.';
  }
}
