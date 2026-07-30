import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:courrier_mobile/screens/courrier/courrier_template.dart';
import 'package:courrier_mobile/screens/courrier/courrier_template_send.dart';
import 'package:courrier_mobile/screens/home_page.dart';
import 'package:courrier_mobile/screens/login/login_page.dart';
import 'utils/navigator_key.dart'; // 👈 Votre clé globale

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 👈 Ajoute ceci pour vérifier que l'app démarre bien
  debugPrint('🚀 L\'application démarre correctement !');

  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      '🚨 [ERREUR FLUTTER UI]',
      error: details.exception,
        stackTrace: details.stack,
      );
    };
  // 2. Intercepte les erreurs Asynchrones (API, Futures...) non gérées
  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      '🚨 [ERREUR ASYNCHRONE]',
      error: error,
      stackTrace: stack,
    );
    return true; // Évite le crash brut de l'application
  };

  // 3. Remplace l'écran rouge de Flutter sur le téléphone par une interface discrète
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Un problème est survenu.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 Rattachement de la clé globale
      debugShowCheckedModeBanner: false, // Masque le bandeau rouge "DEBUG"
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/courrierReceive': (context) => const CourrierTemplate(),
        '/courrierSend': (context) => const CourrierTemplateSend(),
      },
    );
  }
}