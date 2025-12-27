import 'package:flutter_test/flutter_test.dart';
import 'package:url_shortener/src/features/url_shortener/data/models/alias_response_model.dart';

void main() {
  group('AliasResponseModel', () {
    test('fromJson parses alias', () {
      final model = AliasResponseModel.fromJson(const <String, dynamic>{
        'alias': 'abc',
      });

      expect(model, const AliasResponseModel(alias: 'abc'));
    });

    test('toJson serializes alias', () {
      const model = AliasResponseModel(alias: 'abc');

      expect(model.toJson(), const <String, dynamic>{
        'alias': 'abc',
      });
    });
  });
}
