import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

/// Abstração mantida intencionalmente para:
/// - permitir mocks/stubs em testes sem acoplar em Dio
/// - permitir evolução (ex.: cache/local datasource) sem mudar o repository
// ignore: one_member_abstracts
abstract class UrlShortenerRemoteDatasource {
  Future<AliasResponseModel> createAlias({required String url});
}
