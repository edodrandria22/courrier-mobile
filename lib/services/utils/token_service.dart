import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyUser = 'user';

  // Enregistrer le token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Supprimer le token (pour la déconnexion)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }
  
  // Enregistrer l'utilisateur (CORRIGÉ)
  static Future<void> saveUser(Utilisateur user) async {
    // On convertit l'objet en JSON stringifiable
    final String userJson = jsonEncode(user.toJson());
    await _storage.write(key: _keyUser, value: userJson);
  }
  
  // Récupérer l'utilisateur (CORRIGÉ)
  static Future<Utilisateur?> getUser() async {
    final String? userStr = await _storage.read(key: _keyUser);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(userStr);
        return Utilisateur.fromJson(jsonMap);
      } catch (e) {
        // Si les données en cache sont corrompues, on nettoie pour éviter le crash
        await deleteUser();
        return null;
      }
    }
    return null;
  }
  
  // Supprimer l'utilisateur (pour la déconnexion)
  static Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }
}