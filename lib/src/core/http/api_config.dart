abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://url-shortener-server.onrender.com',
  );

  static const String aliasPath = '/api/alias';
}
