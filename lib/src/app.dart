import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_shortener/src/di.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/cubit/url_shortener_cubit.dart';
import 'package:url_shortener/src/features/url_shortener/presentation/pages/url_shortener_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Shortener',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: BlocProvider<UrlShortenerCubit>(
        create: (_) => sl<UrlShortenerCubit>(),
        child: const UrlShortenerPage(),
      ),
    );
  }
}
