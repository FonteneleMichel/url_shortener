import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:url_shortener/src/core/http/api_config.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource.dart';
import 'package:url_shortener/src/features/url_shortener/data/datasources/url_shortener_remote_datasource_impl.dart';
import 'package:url_shortener/src/features/url_shortener/data/repositories/url_shortener_repository_impl.dart';
import 'package:url_shortener/src/features/url_shortener/domain/repositories/url_shortener_repository.dart';
import 'package:url_shortener/src/features/url_shortener/domain/usecases/shorten_url.dart';
import 'package:url_shortener/src/features/url_shortener/domain/validators/url_validator.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';

final GetIt sl = GetIt.instance;

typedef DiOverrides = void Function(GetIt sl);

void configureDependencies({Dio? dio, DiOverrides? overrides}) {
  sl
    ..registerLazySingleton<Dio>(
      () =>
          dio ??
          Dio(
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
    ..registerLazySingleton<UrlShortenerRemoteDatasource>(
      () => UrlShortenerRemoteDatasourceImpl(sl.get<Dio>()),
    )
    ..registerLazySingleton<UrlShortenerRepository>(
      () => UrlShortenerRepositoryImpl(
        sl.get<UrlShortenerRemoteDatasource>(),
      ).call,
    )
    ..registerLazySingleton<UrlValidator>(() => const UrlValidator())
    ..registerLazySingleton<ShortenUrl>(
      () => ShortenUrl(
        repository: sl.get<UrlShortenerRepository>(),
        validator: sl.get<UrlValidator>(),
      ),
    )
    ..registerFactory<UrlShortenerCubit>(
      () {
        final usecase = sl.get<ShortenUrl>();
        final validator = sl.get<UrlValidator>();

        return UrlShortenerCubit(
          shortenUrl: usecase.call,
          isValidUrl: validator.isValid,
        );
      },
    );

  overrides?.call(sl);
}
