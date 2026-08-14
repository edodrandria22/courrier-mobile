import 'dart:convert';
import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/services/api/api_client.dart';
import 'package:courrier_mobile/services/utils/service_result.dart';
import 'package:courrier_mobile/utils/app_logger.dart';

class MessageService {
  final ApiClient _apiClient;

  MessageService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ─── Récupération ──────────────────────────────────────────────────────────

  Future<List<MessageCourrier>> getMessages({String folder = 'inbox'}) async {
    try {
      final uri = Uri(
        path: '/message', // Ton code React utilise /api/message
        queryParameters: {'folder': folder},
      );

      final response = await _apiClient.get(uri.toString());

      if (response.statusCode != 200) {
        await AppLogger.error('MessageService.getMessages', response.body);
        throw Exception('Impossible de charger les messages');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      
      return data.map((item) => MessageCourrier.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('MessageService.getMessages - Exception', error, stackTrace);
      rethrow;
    }
  }

  // ─── Actions (Création / Transfert) ────────────────────────────────────────

  /// Remarque : En React, tu utilisais `FormData`. 
  /// En Flutter, si tu envoies des fichiers, ton `ApiClient` doit gérer le format MultipartRequest.
  /// S'il s'agit juste de données textuelles, un `Map<String, dynamic>` suffit.

  Future<ServiceResult<void>> transfererMessage(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        '/messages/transferer',
        body: data,
        isFormDataFile: true,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        await AppLogger.error('MessageService.transfererMessage', response.body);
        final json = jsonDecode(response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors du transfert',
        );
      }

      return ServiceResult(success: true);
    } catch (error, stackTrace) {
      AppLogger.exception('MessageService.transfererMessage - Exception', error, stackTrace);
      return ServiceResult(success: false, error: error.toString());
    }
  }

  // ─── Mise à jour de l'état ─────────────────────────────────────────────────

  Future<ServiceResult<void>> marquerLu(int id) async {
    try {
      // Ton React utilise PATCH. Assure-toi que ApiClient possède une méthode patch.
      // Si ce n'est pas le cas, tu peux la remplacer par _apiClient.put ou post selon ton API.
      final response = await _apiClient.patch('/messages/$id/lire', body: {});

      if (response.statusCode != 200) {
        await AppLogger.error('MessageService.marquerLu($id)', response.body);
        final json = jsonDecode(response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors du marquage',
        );
      }

      return ServiceResult(success: true);
    } catch (error, stackTrace) {
      AppLogger.exception('MessageService.marquerLu - Exception', error, stackTrace);
      return ServiceResult(success: false, error: error.toString());
    }
  }

  Future<ServiceResult<void>> marquerNonLu(int id) async {
    try {
      final response = await _apiClient.patch('/messages/$id/non-lu', body: {});

      if (response.statusCode != 200) {
        await AppLogger.error('MessageService.marquerNonLu($id)', response.body);
        final json = jsonDecode(response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors du marquage',
        );
      }

      return ServiceResult(success: true);
    } catch (error, stackTrace) {
      AppLogger.exception('MessageService.marquerNonLu - Exception', error, stackTrace);
      return ServiceResult(success: false, error: error.toString());
    }
  }

  // ─── Récupération Externe ──────────────────────────────────────────────────

  Future<ServiceResult<void>> recupererExterne(int id) async {
    try {
      // Plus besoin de créer un FormData manuellement comme en web, 
      // on envoie directement l'ID dans le body.
      final response = await _apiClient.post(
        '/messages/recupererExterne',
        body: {'id': id.toString()},
      );

      if (response.statusCode != 200) {
        await AppLogger.error('MessageService.recupererExterne', response.body);
        final json = jsonDecode(response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors du transfert',
        );
      }

      return ServiceResult(success: true);
    } catch (error, stackTrace) {
      AppLogger.exception('MessageService.recupererExterne - Exception', error, stackTrace);
      return ServiceResult(success: false, error: error.toString());
    }
  }
}