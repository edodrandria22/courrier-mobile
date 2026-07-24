import 'dart:convert';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:http/http.dart' as http;
import 'package:courrier_mobile/constants/config_constants.dart';


class AuthService {
  // ⚠️ ASTUCE IP :
  // - Sur émulateur Android : utilise 'http://10.0.2.2:8000'
    // - Sur ton smartphone physique : utilise l'adresse IP de ton PC (ex: 'http://192.168.1.15:8000')
  static const String baseUrl = ConfigConstants.backendUrl; 

  static Future<Map<String, dynamic>> login(String email, String mdp) async {
    final url = Uri.parse('$baseUrl/utilisateurs/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'mdp': mdp, // Correspond à la clé requise par ton API
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == 'success') {
          // Extraction du token et du membre
          final String token = data['data']['token'];
          final Utilisateur utilisateur = Utilisateur.fromJson(data['data']['membre']);

          return {
            'success': true,
            'token': token,
            'utilisateur': utilisateur,
          };
        }
      }

      // En cas de refus de l'API (ex: mauvais identifiants)
      return {
        'success': false,
        'message': data['message'] ?? data['error'] ?? 'Identifiants incorrects',
      };

    } catch (e) {
      // En cas d'erreur réseau / serveur inaccessible
      return {
        'success': false,
        'message': 'Impossible de se connecter au serveur ($e)',
      };
    }
  }
}