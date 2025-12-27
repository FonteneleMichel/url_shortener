import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/failures.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_state.dart';

typedef ShortenUrlFn =
    Future<Either<Failure, ShortenedLink>> Function({
      required String url,
    });

class UrlShortenerCubit extends Cubit<UrlShortenerState> {
  UrlShortenerCubit({
    required ShortenUrlFn shortenUrl,
    required bool Function(String url) isValidUrl,
    int maxHistoryItems = 20,
  }) : _shortenUrl = shortenUrl,
       _isValidUrl = isValidUrl,
       _maxHistoryItems = maxHistoryItems,
       super(const UrlShortenerState());

  final ShortenUrlFn _shortenUrl;
  final bool Function(String url) _isValidUrl;
  final int _maxHistoryItems;

  bool isValid(String url) => _isValidUrl(url);

  Future<void> shorten({required String url}) async {
    final trimmed = url.trim();

    if (!isValid(trimmed)) {
      emit(state.copyWith(failure: const BadRequestFailure()));
      return;
    }

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final result = await _shortenUrl(url: trimmed);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (link) {
        final next = <ShortenedLink>[link, ...state.history];
        final capped = next.length > _maxHistoryItems
            ? next.take(_maxHistoryItems).toList()
            : next;

        emit(
          state.copyWith(
            isLoading: false,
            history: capped,
            clearFailure: true,
          ),
        );
      },
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  void clearHistory() {
    if (state.history.isEmpty) return;
    emit(state.copyWith(history: const <ShortenedLink>[], clearFailure: true));
  }
}
