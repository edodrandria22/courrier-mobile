// ─── Entités de base ───────────────────────────────────────────────────────

// Remplacez cet import par le chemin vers votre vrai modèle Utilisateur
// import 'package:votre_app/models/Utilisateur.dart';

import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';

class PieceJointe {
  final int id;
  final String nom;
  final String type; // mime type (ex: application/pdf)
  final String? dateFin;
  final String createdAt;

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
  final String objet;
  final String? description;
  final String nomDemandeur;
  final String? prenomDemandeur;
  final String emailDemandeur;
  final String? dateFin;

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
  final String name;
  final String? prenom;
  final String? email;
  final String? telephone;

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
  final int? id;
  final String? reference;
  final String object;
  final String? description;
  final int? numero;
  final String? dateFin;
  final String? createdAt;
  final Utilisateur? createur;
  final Utilisateur? cloturePar;
  final String? statut;
  final String? isReadAt;
  final Utilisateur? expediteur;
  final Utilisateur? destinataire;
  final bool? isSend;
  final String? dateMessage;
  final bool? isConfidentiel;
  final int? historiqueId;
  final int? numRef;
  final String? observation;
  final List<DetailPersonne> detailPersonnes;
  final String? isTraiterAt;
  final String? messageId;

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
    this.isSend,
    this.dateMessage,
    this.isConfidentiel,
    this.historiqueId,
    this.numRef,
    this.observation,
    required this.detailPersonnes,
    this.isTraiterAt,
    this.messageId,
  });

  // La méthode copyWith permet de modifier juste un ou deux champs facilement
  // (très utilisé pour update isReadAt ou cloturePar dans l'interface)
  Courrier copyWith({
    Utilisateur? cloturePar,
    String? isReadAt,
    String? isTraiterAt,
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
        isSend: json['isSend'],
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
  final int id;
  final String createdAt;
  final String? isReadAt;
  final String? observation;
  final String? dateValidation;
  
  final Courrier courrier;
  
  final Utilisateur expediteur;
  final Utilisateur destinataire;

  final List<PieceJointe> fichiers;
  final int? numeroExpediteur;
  final int? numeroDestinataire;

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
        id: json['id'],
        createdAt: json['createdAt'],
        isReadAt: json['isReadAt'],
        observation: json['observation'],
        dateValidation: json['dateValidation'],
        courrier: Courrier.fromJson(json['courrier']),
        expediteur: Utilisateur.fromJson(json['expediteur']),
        destinataire: Utilisateur.fromJson(json['destinataire']),
        fichiers: json['fichiers'] != null
            ? List<PieceJointe>.from(json['fichiers'].map((x) => PieceJointe.fromJson(x)))
            : [],
        numeroExpediteur: json['numeroExpediteur'],
        numeroDestinataire: json['numeroDestinataire'],
      );
}

// ─── Statistiques ──────────────────────────────────────────────────────────

class Statistique {
  final int nonTraite;
  final int? recu;
  final int? envoye;
  final int? traite;
  final int? lu;
  final int? nonLu;

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