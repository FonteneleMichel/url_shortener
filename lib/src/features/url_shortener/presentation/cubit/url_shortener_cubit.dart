import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/core/errors/network_failure.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_state.dart';

typedef ShortenUrlFn =
    Future<Either<Failure, ShortenedLink>> Function({required String url});

typedef IsValidUrlFn = bool Function(String url);

class UrlShortenerCubit extends Cubit<UrlShortenerState> {
  UrlShortenerCubit({
    required ShortenUrlFn shortenUrl,
    required IsValidUrlFn isValidUrl,
  }) : _shortenUrl = shortenUrl,
       _isValidUrl = isValidUrl,
       super(const UrlShortenerState());

  final ShortenUrlFn _shortenUrl;
  final IsValidUrlFn _isValidUrl;

  bool isValid(String url) => _isValidUrl(url);

  Future<void> shorten({required String url}) async {
    if (!_isValidUrl(url)) {
      emit(
        state.copyWith(
          isLoading: false,
          failure: const BadRequestFailure(),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        clearFailure: true,
      ),
    );

    final result = await _shortenUrl(url: url);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            failure: failure,
          ),
        );
      },
      (link) {
        final updatedHistory = <ShortenedLink>[link, ...state.history];
        emit(
          state.copyWith(
            isLoading: false,
            history: updatedHistory,
            clearFailure: true,
          ),
        );
      },
    );
  }

  void clearFailure() => emit(state.copyWith(clearFailure: true));

  void clearHistory() {
    emit(
      state.copyWith(
        history: const <ShortenedLink>[],
        clearFailure: true,
      ),
    );
  }
}
