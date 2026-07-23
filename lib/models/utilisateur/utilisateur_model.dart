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
}