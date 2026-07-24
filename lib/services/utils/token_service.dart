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
  
  // Enregistrer l'utilisateur
  static Future<void> saveUser(Utilisateur user) async {
    await _storage.write(key: _keyUser, value: user.toString());
  }
  
  // Récupérer l'utilisateur
  static Future<Utilisateur?> getUser() async {
    final user = await _storage.read(key: _keyUser);
    if (user != null) {
      return Utilisateur.fromString(user);
    }
    return null;
  }
  
  // Supprimer l'utilisateur (pour la déconnexion)
  static Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }
}