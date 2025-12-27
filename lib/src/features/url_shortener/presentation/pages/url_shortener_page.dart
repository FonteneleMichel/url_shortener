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

  /// Permite injeção direta.
  /// No app/testes atuais, o Cubit vem via BlocProvider acima.
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

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

            _showErrorSnackBar(context, failureMessage(failure));
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

          return Scaffold(
            appBar: AppBar(title: const Text('URL Shortener')),
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
