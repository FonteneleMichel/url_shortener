import 'package:equatable/equatable.dart';
import 'package:url_shortener/src/core/errors/failure.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class UrlShortenerState extends Equatable {
  const UrlShortenerState({
    this.isLoading = false,
    this.history = const <ShortenedLink>[],
    this.failure,
  });

  final bool isLoading;
  final List<ShortenedLink> history;
  final Failure? failure;

  UrlShortenerState copyWith({
    bool? isLoading,
    List<ShortenedLink>? history,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return UrlShortenerState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, history, failure];
}
