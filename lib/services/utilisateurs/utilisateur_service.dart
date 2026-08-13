import 'dart:convert';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/services/api/api_client.dart';
import 'package:courrier_mobile/services/utils/service_result.dart';
import 'package:courrier_mobile/utils/app_logger.dart';

class UtilisateurService {
  final ApiClient _apiClient;
  
  // Équivalent de process.env.NEXT_PUBLIC_NB_LIMIT_UTILISATEUR
  static const String _defaultLimit = "2"; 

  UtilisateurService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ─── Récupération ──────────────────────────────────────────────────────────

  Future<List<Utilisateur>> getUtilisateurs({String? date}) async {
    try {
      final queryParams = <String, String>{
        'limit': _defaultLimit,
      };

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final uri = Uri(
        path: '/utilisateurs',
        queryParameters: queryParams,
      );

      final response = await _apiClient.get(uri.toString());

      if (response.statusCode != 200) {
        await AppLogger.error('UtilisateurService.getUtilisateurs', response.body);
        throw Exception('Impossible de charger les utilisateurs');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      
      return data.map((item) => Utilisateur.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('UtilisateurService.getUtilisateurs - Exception', error, stackTrace);
      rethrow;
    }
  }

  // ─── Recherche ─────────────────────────────────────────────────────────────

  Future<List<Utilisateur>> rechercheUtilisateurs(String nomComplet, String? date) async {
    try {
      final uri = Uri(
        path: '/utilisateurs/recherche',
        queryParameters: {'limit': _defaultLimit},
      );

      final body = <String, dynamic>{
        'nomComplet': nomComplet,
      };
      
      if (date != null && date.isNotEmpty) {
        body['date'] = date;
      }

      final response = await _apiClient.post(
        uri.toString(), 
        body: body,
      );

      if (response.statusCode != 200) {
        await AppLogger.error('UtilisateurService.rechercheUtilisateurs', response.body);
        throw Exception('Impossible de rechercher les utilisateurs');
      }

      final json = jsonDecode(response.body);
      final dynamic responseData = json['data'] ?? json;
      
      if (responseData is List) {
        return responseData.map((item) => Utilisateur.fromJson(item)).toList();
      }
      
      return [];
    } catch (error, stackTrace) {
      AppLogger.exception('UtilisateurService.rechercheUtilisateurs - Exception', error, stackTrace);
      rethrow;
    }
  }

  // ─── Actions (Création / Mise à jour) ──────────────────────────────────────

  Future<ServiceResult<Utilisateur>> createUtilisateur(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/utilisateurs',
        body: data,
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        await AppLogger.error('UtilisateurService.createUtilisateur', response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors de la création',
        );
      }

      return ServiceResult(
        success: true,
        data: Utilisateur.fromJson(json['data'] ?? json),
      );
    } catch (error, stackTrace) {
      AppLogger.exception('UtilisateurService.createUtilisateur - Exception', error, stackTrace);
      return ServiceResult(success: false, error: 'Erreur lors de la création');
    }
  }

  Future<ServiceResult<Utilisateur>> updateUtilisateur(int id, Map<String, dynamic> data) async {
    try {
      // Préparation du payload
      final payload = <String, dynamic>{
        'email': data['email'],
        'nom': data['nom'],
        'prenom': data['prenom'],
        'adresse': data['adresse'],
        'idRole': int.tryParse(data['idRole'].toString()) ?? 0,
      };

      if (data['mdp'] != null && data['mdp'].toString().trim().isNotEmpty) {
        payload['mdp'] = data['mdp'];
      }

      // Ton API React utilisait /api/utilisateurs?id=${id}
      final uri = Uri(
        path: '/utilisateurs',
        queryParameters: {'id': id.toString()},
      );

      final response = await _apiClient.put(
        uri.toString(),
        body: payload,
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        await AppLogger.error('UtilisateurService.updateUtilisateur($id)', response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors de la mise à jour',
        );
      }

      return ServiceResult(
        success: true,
        data: Utilisateur.fromJson(json['data'] ?? json),
      );
    } catch (error, stackTrace) {
      AppLogger.exception('UtilisateurService.updateUtilisateur - Exception', error, stackTrace);
      return ServiceResult(success: false, error: 'Erreur lors de la mise à jour');
    }
  }
}