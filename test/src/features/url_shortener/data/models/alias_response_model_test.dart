import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

void main() {
  group('AliasResponseModel', () {
    test('fromJson parses alias', () {
      final model = AliasResponseModel.fromJson(<String, dynamic>{
        'alias': 'abc',
      });
      expect(model.alias, 'abc');
    });

    test('fromJson throws FormatException when alias missing', () {
      expect(
        () => AliasResponseModel.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson serializes alias', () {
      const model = AliasResponseModel(alias: 'abc');
      expect(model.toJson(), <String, dynamic>{'alias': 'abc'});
    });
  });
}
