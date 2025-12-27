class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    const env = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://url-shortener-server.onrender.com',
    );

    if (env.endsWith('/')) {
      return env.substring(0, env.length - 1);
    }
    return env;
  }

  static const String aliasPath = '/api/alias';
}
