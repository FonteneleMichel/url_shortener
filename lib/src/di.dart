import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:url_shortener/src/core/http/api_config.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart';
import 'package:url_shortener/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart';
import 'package:url_shortener/src/features/url_shortener/domain/usecases/shorten_url.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  sl
    // Dio
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          headers: const <String, dynamic>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ),
    )
    // Validator (Domain)
    ..registerLazySingleton<UrlValidator>(UrlValidator.new)
    // Datasource
    ..registerLazySingleton<UrlShortenerRemoteDatasource>(
      () => UrlShortenerRemoteDatasourceImpl(sl<Dio>()),
    )
    // Repository (callable)
    ..registerLazySingleton<UrlShortenerRepositoryImpl>(
      () => UrlShortenerRepositoryImpl(sl<UrlShortenerRemoteDatasource>()),
    )
    // Use case (agora com validator)
    ..registerLazySingleton<ShortenUrl>(
      () => ShortenUrl(
        repository: sl<UrlShortenerRepositoryImpl>(),
        validator: sl<UrlValidator>(),
      ),
    )
    // Cubit
    ..registerFactory<UrlShortenerCubit>(
      () => UrlShortenerCubit(
        shortenUrl: ({required String url}) => sl<ShortenUrl>()(url),
        isValidUrl: sl<UrlValidator>().isValid,
      ),
    );
}
