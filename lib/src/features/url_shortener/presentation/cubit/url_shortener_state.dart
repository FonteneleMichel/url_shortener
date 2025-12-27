import 'package:equatable/equatable.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

enum UrlShortenerStatus { idle, loading }

class UrlShortenerState extends Equatable {
  const UrlShortenerState({
    required this.status,
    required this.history,
    required this.failure,
  });

  const UrlShortenerState.initial()
    : status = UrlShortenerStatus.idle,
      history = const <ShortenedLink>[],
      failure = null;

  final UrlShortenerStatus status;
  final List<ShortenedLink> history;
  final Failure? failure;

  bool get isLoading => status == UrlShortenerStatus.loading;

  UrlShortenerState copyWith({
    UrlShortenerStatus? status,
    List<ShortenedLink>? history,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return UrlShortenerState(
      status: status ?? this.status,
      history: history ?? this.history,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, history, failure];
}
