import 'dart:convert';
import 'dart:io';
import 'package:courrier_mobile/utils/navigator_key.dart';
import 'package:http/http.dart' as http;
import '../../constants/config_constants.dart';
import '../utils/token_service.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = ConfigConstants.backendUrl});

  /// Récupère le token stocké localement
  Future<String?> _getToken() async {
    return await TokenService.getToken();
  }

  /// Déconnexion locale : efface le token et redirige vers la page de login
  Future<void> _handleUnauthorized() async {
    // 1. Supprimer le token/session localement
    await TokenService.deleteToken();

    // 2. Rediriger vers l'écran de login
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false, // Efface tout l'historique de navigation
    );
  }

    /// Équivalent de votre fetchWithAuth
  Future<http.Response> fetchWithAuth(
    String endpoint, {
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
    bool isFormDataFile = false, // 👈 Nouvel argument avec valeur par défaut false
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint');

    http.Response response;

    // 1. SI C'EST UNE REQUÊTE MULTIPART (Envoi de fichiers)
    if (isFormDataFile && body is Map<String, dynamic>) {
      var request = http.MultipartRequest(method.toUpperCase(), uri);

      // En-têtes (sans Content-Type car MultipartRequest le génère automatiquement avec le boundary)
      final multipartHeaders = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };
      multipartHeaders.remove('Content-Type'); // Sécurité pour éviter tout conflit
      request.headers.addAll(multipartHeaders);

      // Extraction des champs texte et des fichiers
      for (var entry in body.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is File) {
          // Fichier unique
          request.files.add(await http.MultipartFile.fromPath(key, value.path));
        } else if (value is List<File>) {
          // Liste de fichiers (ex: fichiers[])
          for (var file in value) {
            request.files.add(await http.MultipartFile.fromPath(key, file.path));
          }
        } else if (value != null) {
          // Champ texte / standard
          request.fields[key] = value.toString();
        }
      }

      // Exécution de la requête multipart
      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } 
    // 2. SINON : REQUÊTE CLASSIQUE (JSON / Standard)
    else {
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: defaultHeaders, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: defaultHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: defaultHeaders, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PATCH': // 👈 AJOUTE CE CASE ICI !
          response = await http.patch(uri, headers: defaultHeaders, body: jsonEncode(body));
          break;
        case 'GET':
        default:
          response = await http.get(uri, headers: defaultHeaders);
          break;
      }
    }

    // 🚨 Interception 401 / 403 (Non autorisé / Interdit)
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleUnauthorized();
      throw Exception('Non autorisé, redirection en cours...');
    }

    return response;
  }
  // --- Raccourcis de méthodes pour simplifier l'utilisation ---

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) {
    return fetchWithAuth(
      endpoint, 
      method: 'GET', 
      headers: headers,
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    bool isFormDataFile = false, // 👈 Ajout du paramètre
  }) {
    return fetchWithAuth(
      endpoint,
      method: 'POST',
      body: body,
      headers: headers,
      isFormDataFile: isFormDataFile,
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    bool isFormDataFile = false, // 👈 Ajout du paramètre
  }) {
    return fetchWithAuth(
      endpoint,
      method: 'PUT',
      body: body,
      headers: headers,
      isFormDataFile: isFormDataFile,
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    bool isFormDataFile = false, // 👈 Ajout du paramètre
  }) {
    return fetchWithAuth(
      endpoint,
      method: 'DELETE',
      body: body,
      headers: headers,
      isFormDataFile: isFormDataFile,
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    bool isFormDataFile = false, // 👈 Ajout du paramètre
  }) {
    return fetchWithAuth(
      endpoint,
      method: 'PATCH',
      body: body,
      headers: headers,
      isFormDataFile: isFormDataFile,
    );
  }
}
