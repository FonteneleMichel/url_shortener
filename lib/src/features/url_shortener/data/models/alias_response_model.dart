import 'package:equatable/equatable.dart';
import 'package:url_shortener/src/features/url_shortener/domain/entities/shortened_link.dart';

class AliasResponseModel extends Equatable {
  const AliasResponseModel({required this.alias});

  factory AliasResponseModel.fromJson(Map<String, dynamic> json) {
    final value = json['alias'];
    if (value is! String) {
      throw const FormatException('Invalid alias field');
    }
    return AliasResponseModel(alias: value);
  }

  final String alias;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'alias': alias,
  };

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

  @override
  List<Object?> get props => <Object?>[alias];
}
