import 'package:flutter/material.dart';
import 'package:url_shortener/src/app.dart';
import 'package:url_shortener/src/di.dart';

void main() {
  configureDependencies();
  runApp(const App());
}
