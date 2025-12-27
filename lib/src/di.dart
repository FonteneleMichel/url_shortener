import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart';
import 'package:url_shortener/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  // External
  sl
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://localhost:3000',
          ),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ),
    )
    // Data
    ..registerLazySingleton<UrlShortenerRemoteDatasource>(
      () => UrlShortenerRemoteDatasourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<UrlShortenerRepositoryImpl>(
      () => UrlShortenerRepositoryImpl(sl<UrlShortenerRemoteDatasource>()),
    )
    // Presentation
    ..registerFactory<UrlShortenerCubit>(
      () => UrlShortenerCubit(
        shortenUrl: sl<UrlShortenerRepositoryImpl>().call,
        isValidUrl: _isValidAbsoluteUrl,
      ),
    );
}

bool _isValidAbsoluteUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.hasScheme &&
      (uri.isScheme('http') || uri.isScheme('https')) &&
      uri.host.isNotEmpty;
}
