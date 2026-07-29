import 'dart:convert';

class Utilisateur {
  final int id;
  final String email;
  final String nom;
  final String prenom;
  final String adresse;
  final String role;

  Utilisateur({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.role,
  });
  

  // Factory pour créer un Utilisateur depuis le JSON de l'API
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      adresse: json['adresse'] ?? '',
      role: json['role'] ?? '',
    );
  }
  factory Utilisateur.empty() {
    return Utilisateur(
      id: 0,
      email: '',
      nom: '',
      prenom: '',
      adresse: '',
      role: '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'role': role,
    };
  }

  // 👈 CRÉATION DEPUIS UNE CHAÎNE STRING (JSON)
  factory Utilisateur.fromString(String source) {
    return Utilisateur.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
  
  Utilisateur.fromId({
    required this.id,
  }) : email = '',
       nom = '',
       prenom = '',
       adresse = '',
       role = '';
}
