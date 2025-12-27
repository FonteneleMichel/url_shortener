import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class AliasResponseModel {
  const AliasResponseModel({
    required this.alias,
  });

  factory AliasResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic aliasValue = json['alias'];

    if (aliasValue is! String || aliasValue.isEmpty) {
      throw const FormatException('Invalid alias response: "alias" is missing');
    }

    return AliasResponseModel(alias: aliasValue);
  }

  final String alias;

  Map<String, dynamic> toJson() => <String, dynamic>{'alias': alias};

  ShortenedLink toEntity({
    required String originalUrl,
    required DateTime createdAt,
  }) {
    return ShortenedLink(
      originalUrl: originalUrl,
      alias: alias,
      createdAt: createdAt,
    );
  }
}
