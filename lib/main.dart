import 'package:flutter/material.dart';
// Importe le fichier que tu viens de créer
import 'screens/home_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courrier Mesupres',
      // Enlève le petit bandeau "DEBUG" en haut à droite
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // On utilise la couleur bleue principale de ton design (AppColors.primary)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E40AF)),
        useMaterial3: true,
      ),
      // C'EST ICI QUE TOUT CHANGE : On appelle ta nouvelle page
      home: const HomePage(), 
    );
  }
}