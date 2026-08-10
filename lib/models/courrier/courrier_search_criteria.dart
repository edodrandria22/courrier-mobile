class CourrierSearchCriteria {
  String? reference;
  String? object;
  String? nom;
  String? prenom;
  String? email;
  String? telephone;
  int? utilisateurId;
  int? numero;
  String? dateDebut;
  String? dateFin;
  String? statut;
  bool? isConfidentiel;
  String? dateMessageDebut;
  String? dateMessageFin;
  String? dateReceptionDebut;
  String? dateReceptionFin;
  int? numeroExpediteur;
  int? numeroDestinataire;

  CourrierSearchCriteria({
    this.reference,
    this.object,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.utilisateurId,
    this.numero,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.isConfidentiel,
    this.dateMessageDebut,
    this.dateMessageFin,
    this.dateReceptionDebut,
    this.dateReceptionFin,
    this.numeroExpediteur,
    this.numeroDestinataire,
  });
}