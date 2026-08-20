// ─── Entités de base ───────────────────────────────────────────────────────

// Remplacez cet import par le chemin vers votre vrai modèle Utilisateur
// import 'package:votre_app/models/Utilisateur.dart';

import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';

class PieceJointe {
   int id;
   String nom;
   String type; // mime type (ex: application/pdf)
   String? dateFin;
   String createdAt;

  PieceJointe({
    required this.id,
    required this.nom,
    required this.type,
    this.dateFin,
    required this.createdAt,
  });

  factory PieceJointe.fromJson(Map<String, dynamic> json) => PieceJointe(
        id: json['id'],
        nom: json['nom'],
        type: json['type'],
        dateFin: json['dateFin'],
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'type': type,
        'dateFin': dateFin,
        'createdAt': createdAt,
      };
}

// ─── Formulaire ────────────────────────────────────────────────────────────

class CourrierFormData {
   String objet;
   String? description;
   String nomDemandeur;
   String? prenomDemandeur;
   String emailDemandeur;
   String? dateFin;

  CourrierFormData({
    required this.objet,
    this.description,
    required this.nomDemandeur,
    this.prenomDemandeur,
    required this.emailDemandeur,
    this.dateFin,
  });

  Map<String, dynamic> toJson() => {
        'objet': objet,
        'description': description,
        'nomDemandeur': nomDemandeur,
        'prenomDemandeur': prenomDemandeur,
        'emailDemandeur': emailDemandeur,
        'dateFin': dateFin,
      };
}

// ─── Détail Personne ───────────────────────────────────────────────────────

class DetailPersonne {
   String name;
   String? prenom;
   String? email;
   String? telephone;

  DetailPersonne({
    required this.name,
    this.prenom,
    this.email,
    this.telephone,
  });

  factory DetailPersonne.fromJson(Map<String, dynamic> json) => DetailPersonne(
        name: json['name'],
        prenom: json['prenom'],
        email: json['email'],
        telephone: json['telephone'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
      };
}

// ─── Courrier ──────────────────────────────────────────────────────────────

class Courrier {
   int? id;
   String? reference;
   String object;
   String? description;
   int? numero;
   String? dateFin;
   String? createdAt;
   Utilisateur? createur;
   Utilisateur? cloturePar;
   String? statut;
   String? isReadAt;
   Utilisateur? expediteur;
   Utilisateur? destinataire;
   bool isSend;
   String? dateMessage;
   bool? isConfidentiel;
   int? historiqueId;
   int? numRef;
   String? observation;
   List<DetailPersonne> detailPersonnes;
   String? isTraiterAt;
   String? messageId;

  Courrier({
    this.id,
    this.reference,
    required this.object,
    this.description,
    this.numero,
    this.dateFin,
    this.createdAt,
    this.createur,
    this.cloturePar,
    this.statut,
    this.isReadAt,
    this.expediteur,
    this.destinataire,
    this.isSend = false,
    this.dateMessage,
    this.isConfidentiel,
    this.historiqueId,
    this.numRef,
    this.observation,
    required this.detailPersonnes,
    this.isTraiterAt,
    this.messageId,
  });
  Courrier.empty() : this(
    object: '',
    detailPersonnes: [],
  );

  // La méthode copyWith permet de modifier juste un ou deux champs facilement
  // (très utilisé pour update isReadAt ou cloturePar dans l'interface)
  Courrier copyWith({
    Utilisateur? cloturePar,
    String? isReadAt,
    String? isTraiterAt,
    int? numero,
    int? numRef,
    // ... ajoutez d'autres champs au besoin
  }) {
    return Courrier(
      id: id,
      reference: reference,
      object: object,
      description: description,
      numero: numero,
      dateFin: dateFin,
      createdAt: createdAt,
      createur: createur,
      cloturePar: cloturePar ?? this.cloturePar,
      statut: statut,
      isReadAt: isReadAt ?? this.isReadAt,
      expediteur: expediteur,
      destinataire: destinataire,
      isSend: isSend,
      dateMessage: dateMessage,
      isConfidentiel: isConfidentiel,
      historiqueId: historiqueId,
      numRef: numRef,
      observation: observation,
      detailPersonnes: detailPersonnes,
      isTraiterAt: isTraiterAt ?? this.isTraiterAt,
      messageId: messageId,
    );
  }

  factory Courrier.fromJson(Map<String, dynamic> json) => Courrier(
        id: json['id'],
        reference: json['reference'],
        object: json['object'] ?? '',
        description: json['description'],
        numero: json['numero'],
        dateFin: json['dateFin'],
        createdAt: json['createdAt'],
        createur: json['createur'] != null ? Utilisateur.fromJson(json['createur']) : null,
        cloturePar: json['cloturePar'] != null ? Utilisateur.fromJson(json['cloturePar']) : null,
        statut: json['statut'],
        isReadAt: json['isReadAt'],
        expediteur: json['expediteur'] != null ? Utilisateur.fromJson(json['expediteur']) : null,
        destinataire: json['destinataire'] != null ? Utilisateur.fromJson(json['destinataire']) : null,
        isSend: json['isSend'] == true,
        dateMessage: json['dateMessage'],
        isConfidentiel: json['isConfidentiel'],
        historiqueId: json['historiqueId'],
        numRef: json['numRef'],
        observation: json['observation'],
        detailPersonnes: json['detailPersonnes'] != null
            ? List<DetailPersonne>.from(json['detailPersonnes'].map((x) => DetailPersonne.fromJson(x)))
            : [],
        isTraiterAt: json['isTraiterAt'],
        messageId: json['messageId']?.toString(),
      );
}

// ─── Message (transfert d'un courrier) ────────────────────────────────────

class MessageCourrier {
   int id;
   String createdAt;
   String? isReadAt;
   String? observation;
   String? dateValidation;
  
   Courrier courrier;
  
   Utilisateur expediteur;
   Utilisateur destinataire;

   List<PieceJointe> fichiers;
   int? numeroExpediteur;
   int? numeroDestinataire;

  MessageCourrier({
    required this.id,
    required this.createdAt,
    this.isReadAt,
    this.observation,
    this.dateValidation,
    required this.courrier,
    required this.expediteur,
    required this.destinataire,
    required this.fichiers,
    this.numeroExpediteur,
    this.numeroDestinataire,
  });

  MessageCourrier copyWith({
    String? isReadAt,
    String? observation,
    int? numeroExpediteur,
    int? numeroDestinataire,
  }) {
    return MessageCourrier(
      id: id,
      createdAt: createdAt,
      isReadAt: isReadAt ?? this.isReadAt,
      observation: observation ?? this.observation,
      dateValidation: dateValidation,
      courrier: courrier,
      expediteur: expediteur,
      destinataire: destinataire,
      fichiers: fichiers,
      numeroExpediteur: numeroExpediteur,
      numeroDestinataire: numeroDestinataire,
    );
  }

  factory MessageCourrier.fromJson(Map<String, dynamic> json) => MessageCourrier(
      // Parsing sécurisé de l'ID en int
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      // Champs pouvant être nulls dans le JSON
      createdAt: json['createdAt'] as String, // Mettez String? dans votre constructeur
      isReadAt: json['isReadAt'] as String?,
      observation: json['observation'] as String?,
      dateValidation: json['dateValidation'] as String?,

      // Relations d'objets sécurisées
      courrier: json['courrier'] != null 
          ? Courrier.fromJson(json['courrier'] as Map<String, dynamic>) 
          : Courrier.empty(),

      expediteur: json['expediteur'] != null 
          ? Utilisateur.fromJson(json['expediteur'] as Map<String, dynamic>) 
          : Utilisateur.empty(), // Vérification ajoutée par sécurité

      destinataire: json['destinataire'] != null 
          ? Utilisateur.fromJson(json['destinataire'] as Map<String, dynamic>) 
          : Utilisateur.empty(), // Vérification ajoutée par sécurité

      // Liste de fichiers
      fichiers: json['fichiers'] != null && json['fichiers'] is List
          ? (json['fichiers'] as List)
              .map((x) => PieceJointe.fromJson(x as Map<String, dynamic>))
              .toList()
          : [],

      // Champs optionnels ou absents du JSON Mercure
      numeroExpediteur: json['numeroExpediteur'] is int 
          ? json['numeroExpediteur'] 
          : int.tryParse(json['numeroExpediteur']?.toString() ?? ''),
      
      numeroDestinataire: json['numeroDestinataire'] is int 
          ? json['numeroDestinataire'] 
          : int.tryParse(json['numeroDestinataire']?.toString() ?? ''),
    );
}

// ─── Statistiques ──────────────────────────────────────────────────────────

class Statistique {
   int nonTraite;
   int? recu;
   int? envoye;
   int? traite;
   int? lu;
   int? nonLu;

  Statistique({
    required this.nonTraite,
    this.recu,
    this.envoye,
    this.traite,
    this.lu,
    this.nonLu,
  });

  factory Statistique.fromJson(Map<String, dynamic> json) => Statistique(
        nonTraite: json['nonTraite'] ?? 0,
        recu: json['recu'],
        envoye: json['envoye'],
        traite: json['traite'],
        lu: json['lu'],
        nonLu: json['nonLu'],
      );
}

class CourrierSearchCriteria {
  final String? reference;
  final String? object;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final int? utilisateurId;
  final bool? isSend;
  final int? numero;
  final String? dateDebut;
  final String? dateFin;
  final String? statut; // 'en_cours' | 'finalise'
  final String? date; // Pour la pagination (dans le DTO)
  final bool? isConfidentiel;
  final int? numeroExpediteur;
  final int? numeroDestinataire;
  final String? dateMessageDebut;
  final String? dateMessageFin;
  final String? dateReceptionDebut;
  final String? dateReceptionFin;

  CourrierSearchCriteria({
    this.reference,
    this.object,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.utilisateurId,
    this.isSend,
    this.numero,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.date,
    this.isConfidentiel,
    this.numeroExpediteur,
    this.numeroDestinataire,
    this.dateMessageDebut,
    this.dateMessageFin,
    this.dateReceptionDebut,
    this.dateReceptionFin,
  });

  /// Convertit l'objet en Map JSON pour l'envoi vers l'API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (reference != null) data['reference'] = reference;
    if (object != null) data['object'] = object;
    if (nom != null) data['nom'] = nom;
    if (prenom != null) data['prenom'] = prenom;
    if (email != null) data['email'] = email;
    if (telephone != null) data['telephone'] = telephone;
    if (utilisateurId != null) data['utilisateurId'] = utilisateurId;
    if (isSend != null) data['isSend'] = isSend;
    if (numero != null) data['numero'] = numero;
    if (dateDebut != null) data['dateDebut'] = dateDebut;
    if (dateFin != null) data['dateFin'] = dateFin;
    if (statut != null) data['statut'] = statut;
    if (date != null) data['date'] = date;
    if (isConfidentiel != null) data['isConfidentiel'] = isConfidentiel;
    if (numeroExpediteur != null) data['numeroExpediteur'] = numeroExpediteur;
    if (numeroDestinataire != null) data['numeroDestinataire'] = numeroDestinataire;
    if (dateMessageDebut != null) data['dateMessageDebut'] = dateMessageDebut;
    if (dateMessageFin != null) data['dateMessageFin'] = dateMessageFin;
    if (dateReceptionDebut != null) data['dateReceptionDebut'] = dateReceptionDebut;
    if (dateReceptionFin != null) data['dateReceptionFin'] = dateReceptionFin;

    return data;
  }

  /// Crée une instance depuis une réponse JSON
  factory CourrierSearchCriteria.fromJson(Map<String, dynamic> json) {
    return CourrierSearchCriteria(
      reference: json['reference'] as String?,
      object: json['object'] as String?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      utilisateurId: json['utilisateurId'] as int?,
      isSend: json['isSend'] as bool?,
      numero: json['numero'] as int?,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String?,
      date: json['date'] as String?,
      isConfidentiel: json['isConfidentiel'] as bool?,
      numeroExpediteur: json['numeroExpediteur'] as int?,
      numeroDestinataire: json['numeroDestinataire'] as int?,
      dateMessageDebut: json['dateMessageDebut'] as String?,
      dateMessageFin: json['dateMessageFin'] as String?,
      dateReceptionDebut: json['dateReceptionDebut'] as String?,
      dateReceptionFin: json['dateReceptionFin'] as String?,
    );
  }

  /// Permet d'immuablement mettre à jour certains champs dans vos formulaires
  CourrierSearchCriteria copyWith({
    String? reference,
    String? object,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    int? utilisateurId,
    bool? isSend,
    int? numero,
    String? dateDebut,
    String? dateFin,
    String? statut,
    String? date,
    bool? isConfidentiel,
    int? numeroExpediteur,
    int? numeroDestinataire,
    String? dateMessageDebut,
    String? dateMessageFin,
    String? dateReceptionDebut,
    String? dateReceptionFin,
  }) {
    return CourrierSearchCriteria(
      reference: reference ?? this.reference,
      object: object ?? this.object,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      isSend: isSend ?? this.isSend,
      numero: numero ?? this.numero,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      date: date ?? this.date,
      isConfidentiel: isConfidentiel ?? this.isConfidentiel,
      numeroExpediteur: numeroExpediteur ?? this.numeroExpediteur,
      numeroDestinataire: numeroDestinataire ?? this.numeroDestinataire,
      dateMessageDebut: dateMessageDebut ?? this.dateMessageDebut,
      dateMessageFin: dateMessageFin ?? this.dateMessageFin,
      dateReceptionDebut: dateReceptionDebut ?? this.dateReceptionDebut,
      dateReceptionFin: dateReceptionFin ?? this.dateReceptionFin,
    );
  }
}