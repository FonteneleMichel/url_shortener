import 'package:flutter/material.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/pages/url_shortener_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Shortener',
      theme: ThemeData(useMaterial3: true),
      home: const UrlShortenerPage(),
    );
  }
}
