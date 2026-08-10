import 'dart:convert';
import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/services/api/api_client.dart';
import 'package:courrier_mobile/services/utils/download_file.dart';
import 'package:courrier_mobile/services/utils/service_result.dart';
import 'package:courrier_mobile/utils/app_logger.dart';

// Remplacez ces imports par vos propres modèles et votre logger

class CourrierService {
  final ApiClient _apiClient;
  static const String _defaultLimit = "10";

  CourrierService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ─── Courriers ───────────────────────────────────────────────────────────

  Future<List<Courrier>> getCourriers() async {
    try {
      final response = await _apiClient.get('/courriers');

      if (response.statusCode != 200) {
        await AppLogger.error('CourrierService.getCourriers', response.body);
        throw Exception('Impossible de charger les courriers');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => Courrier.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getCourriers - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Courrier>> getCourriersByUser({
    String? dateCursor,
    bool? isTraiterAt,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': _defaultLimit,
      };

      if (dateCursor != null && dateCursor.isNotEmpty) {
        queryParams['date'] = dateCursor;
      }

      if (isTraiterAt != null) {
        queryParams['isTraiterAt'] = isTraiterAt.toString();
      }

      final uri = Uri(
        path: '/courriers/getAllbyUser',
        queryParameters: queryParams,
      );

      final response = await _apiClient.get(uri.toString());

      if (response.statusCode != 200) {
        await AppLogger.error(
          'CourrierService.getCourriersByUser (date: $dateCursor)',
          response.body,
        );
        throw Exception('Impossible de charger vos courriers');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => Courrier.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getCourriersByUser - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<List<Courrier>> getCourriersByUserSend({String? dateCursor}) async {
    try {
      final queryParams = <String, String>{
        'limit': _defaultLimit,
      };

      if (dateCursor != null && dateCursor.isNotEmpty) {
        queryParams['date'] = dateCursor;
      }

      final uri = Uri(
        path: '/courriers/getAllbyUserSend',
        queryParameters: queryParams,
      );

      final response = await _apiClient.get(uri.toString());

      if (response.statusCode != 200) {
        await AppLogger.error(
          'CourrierService.getCourriersByUserSend (date: $dateCursor)',
          response.body,
        );
        throw Exception('Impossible de charger vos courriers');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => Courrier.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getCourriersByUserSend - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<Courrier?> getCourrierById(int id) async {
    try {
      final response = await _apiClient.get('/courriers/$id');

      if (response.statusCode != 200) {
        await AppLogger.error('CourrierService.getCourrierById($id)', response.body);
        return null;
      }

      final json = jsonDecode(response.body);
      return Courrier.fromJson(json['data']);
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getCourrierById - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<ServiceResult<Courrier>> createCourrier(Courrier data) async {
    try {
      final response = await _apiClient.post(
        '/courriers',
        body: {
          'object': data.object,
          'description': data.description,
          'isConfidentiel': data.isConfidentiel ?? false,
          'detailPersonnes': data.detailPersonnes,
        },
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        await AppLogger.error('CourrierService.createCourrier', response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors de la création',
        );
      }

      return ServiceResult(
        success: true,
        data: Courrier.fromJson(json['data']),
      );
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.createCourrier - Exception', error, stackTrace);
      return ServiceResult(success: false, error: 'Erreur lors de la création');
    }
  }

  // ─── Messages d'un courrier ──────────────────────────────────────────────

  Future<List<MessageCourrier>> getMessagesByCourrier(
    int idCourrier, {
    String? dateCursor,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': _defaultLimit,
      };

      if (dateCursor != null && dateCursor.isNotEmpty) {
        queryParams['date'] = dateCursor;
      }

      final uri = Uri(
        path: '/courriers/$idCourrier/messages',
        queryParameters: queryParams,
      );

      final response = await _apiClient.get(uri.toString());

      if (response.statusCode != 200) {
        await AppLogger.error(
          'CourrierService.getMessagesByCourrier($idCourrier, $dateCursor)',
          response.body,
        );
        throw Exception('Impossible de charger les messages');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      
      return data.map((item) => MessageCourrier.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getMessagesByCourrier - Exception', error, stackTrace);
      rethrow;
    }
  }

  // ─── Fichiers ─────────────────────────────────────────────────────────────

  Future<DownloadedFile> downloadFichier(int id) async {
    try {
      final response = await _apiClient.get('/fichiers/$id/download');

      if (response.statusCode != 200) {
        throw Exception('Impossible de télécharger le fichier');
      }

      final disposition = response.headers['content-disposition'] ?? '';
      final match = RegExp(r'filename="?([^"]+)"?').firstMatch(disposition);
      final filename = match?.group(1) ?? 'fichier';
      final contentType = response.headers['content-type'] ?? 'application/octet-stream';

      return DownloadedFile(
        bytes: response.bodyBytes,
        filename: filename,
        contentType: contentType,
      );
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.downloadFichier - Exception', error, stackTrace);
      rethrow;
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<Courrier> cloturerCourrier(int id) async {
    try {
      final response = await _apiClient.post(
        '/courriers/$id/cloturer',
        body: {},
      );

      if (response.statusCode != 200) {
        await AppLogger.error('CourrierService.cloturerCourrier($id)', response.body);
        throw Exception('Impossible de clôturer le courrier');
      }

      final json = jsonDecode(response.body);
      return Courrier.fromJson(json['data']);
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.cloturerCourrier - Exception', error, stackTrace);
      rethrow;
    }
  }

  // ─── Recherche ─────────────────────────────────────────────────────────────

  Future<List<Courrier>> searchCourriers(
    CourrierSearchCriteria criteria, {
    String? date,
  }) async {
    try {
      final searchMap = criteria.toJson();
      searchMap['date'] = date;

      final uri = Uri(
        path: '/courriers/recherche',
        queryParameters: {'limit': _defaultLimit},
      );

      final response = await _apiClient.post(uri.toString(), body: searchMap);

      if (response.statusCode != 200) {
        throw Exception('Impossible de rechercher les courriers');
      }

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data.map((item) => Courrier.fromJson(item)).toList();
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.searchCourriers - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<ServiceResult<Courrier>> updateCourrier(int id, Courrier data) async {
    try {
      final response = await _apiClient.put(
        '/courriers/$id',
        body: {
          'object': data.object,
          'description': data.description,
          'isConfidentiel': data.isConfidentiel ?? false,
          'detailPersonnes': data.detailPersonnes,
        },
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        await AppLogger.error('CourrierService.updateCourrier', response.body);
        return ServiceResult(
          success: false,
          error: json['error'] ?? json['message'] ?? 'Erreur lors de la mise à jour',
        );
      }

      return ServiceResult(
        success: true,
        data: Courrier.fromJson(json['data']),
      );
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.updateCourrier - Exception', error, stackTrace);
      return ServiceResult(success: false, error: 'Erreur lors de la mise à jour');
    }
  }

  Future<Courrier> updateHistorique(int id, String observation) async {
    try {
      final response = await _apiClient.put(
        '/courriers/historique/$id',
        body: {'observation': observation},
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          json['error'] ?? json['message'] ?? 'Erreur lors de la mise à jour',
        );
      }

      return Courrier.fromJson(json['data']);
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.updateHistorique - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<Statistique> getStatistique(String dateDebut, String dateFin) async {
    try {
      final response = await _apiClient.get(
        '/courriers/statistique?dateDebut=$dateDebut&dateFin=$dateFin',
      );

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          json['error'] ?? json['message'] ?? 'Erreur lors de la récupération des statistiques',
        );
      }

      return Statistique.fromJson(json['data']);
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getStatistique - Exception', error, stackTrace);
      rethrow;
    }
  }

  Future<Statistique> getNombreNonTraite() async {
    try {
      final response = await _apiClient.get('/courriers/nonTraite');

      final json = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          json['error'] ?? json['message'] ??
              'Erreur lors de la récupération des nombres courrier non traités',
        );
      }

      return Statistique.fromJson(json['data']);
    } catch (error, stackTrace) {
      AppLogger.exception('CourrierService.getNombreNonTraite - Exception', error, stackTrace);
      rethrow;
    }
  }
  
}