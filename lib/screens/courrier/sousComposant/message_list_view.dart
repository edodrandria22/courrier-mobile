import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/transferer_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates (flutter pub add intl)

class MessageListView extends StatefulWidget {
  final Courrier courrier;
  final List<MessageCourrier> messages;
  final bool loading;
  final String? error;
  final String? currentUserId;
  final bool isRecherche;
  final ValueChanged<MessageCourrier> onSelect;
  final VoidCallback onBack;
  final Future<Courrier> Function(int id, String observation) updateHistorique;
  final Future<void> Function(int messageId)? onMarquerLu;
  final VoidCallback? onTransferer;

  const MessageListView({
    super.key, // <-- Remplace "Key? key"
    required this.courrier,
    required this.messages,
    required this.loading,
    this.error,
    this.currentUserId,
    this.isRecherche = false,
    required this.onSelect,
    required this.onBack,
    required this.updateHistorique,
    this.onMarquerLu,
    this.onTransferer,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late TextEditingController _obsController;
  bool _isEditingObs = false;
  bool _isUpdatingObs = false;
  bool _loadingMarquer = false;

  @override
  void initState() {
    super.initState();
    _obsController = TextEditingController(text: widget.courrier.observation ?? '');
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  // Permet de simuler les vérifications de permissions
  bool get isLastRecipient {
    // Insérez ici votre logique métier pour savoir si l'utilisateur est le dernier destinataire
    return true; 
  }

  bool isMessageVisible(MessageCourrier message) {
    // Insérez ici votre logique de visibilité du message
    return true;
  }

  String _formatDateTime(String? dt) {
  // 1. On filtre si dt est null, vide, ou s'il contient le texte "null"
    if (dt == null || dt.trim().isEmpty || dt == "null") {
      return "—";
    }

    // 2. tryParse évite de lever une exception si le format n'est pas ISO
    final parsedDate = DateTime.tryParse(dt);
    if (parsedDate == null) {
      return "—";
    }

    // 3. Formate uniquement la date valide
    return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
  }

  Future<void> _handleMarquerLu() async {
    if (widget.courrier.messageId == null || widget.onMarquerLu == null) return;
    setState(() => _loadingMarquer = true);
    try {
      await widget.onMarquerLu!(int.parse(widget.courrier.messageId!));
    } finally {
      if (mounted) setState(() => _loadingMarquer = false);
    }
  }

  Future<void> _handleUpdateObservation() async {
    if (widget.courrier.historiqueId == null) return;
    setState(() => _isUpdatingObs = true);
    try {
      final updatedCourrier = await widget.updateHistorique(
        widget.courrier.historiqueId!,
        _obsController.text,
      );
      setState(() {
        widget.courrier.observation = updatedCourrier.observation;
        _isEditingObs = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour : $e")),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingObs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isButtonLu = isLastRecipient && widget.courrier.isReadAt == null;
    final bool isConfidentiel = widget.courrier.isConfidentiel ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: !widget.isRecherche
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        title: const Text("Détails du courrier", style: TextStyle(fontSize: 16)),
        actions: [
        if (isLastRecipient && widget.courrier.cloturePar == null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TransfererButton(
              messageId: int.parse(widget.courrier.messageId!), // 👈 Passe l'ID de ton courrier ici
              onSuccess: () {
                // 👈 Appel du callback existant lors du succès pour rafraîchir l'écran
                if (widget.onTransferer != null) {
                  widget.onTransferer!();
                }
              },
            ),
          ),
      ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principale du courrier
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bouton "Marquer comme arrivée"
                    if (isButtonLu) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loadingMarquer ? null : _handleMarquerLu,
                          child: Text(_loadingMarquer ? 'Enregistrement...' : 'Marquer comme arrivée'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // En-tête : Référence + Objet
                    Text(
                      widget.courrier.reference ?? "Sans référence",
                      style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isConfidentiel) ...[
                          const Icon(Icons.lock, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            widget.courrier.object,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isConfidentiel ? Colors.amber[800] : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Badges de statut
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (isConfidentiel)
                          Chip(
                            avatar: const Icon(Icons.lock, size: 14, color: Colors.amber),
                            label: const Text("Confidentiel"),
                            backgroundColor: Colors.amber.shade50,
                          ),
                        if (widget.courrier.cloturePar != null)
                          Chip(
                            avatar: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                            label: Text("Finalisé par ${widget.courrier.cloturePar?.nom ?? 'un utilisateur'}"),
                            backgroundColor: Colors.green.shade50,
                          )
                        else
                          Chip(
                            avatar: const Icon(Icons.access_time, size: 14),
                            label: Text(widget.courrier.isReadAt != null ? 'Arrivée' : 'Non arrivée'),
                          ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Description
                    if (widget.courrier.description != null && widget.courrier.description!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.description, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(widget.courrier.description!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Numéros Départ / Arrivée
                    if (widget.courrier.isSend) ...[
                      if (widget.courrier.numero != null) Text("Numéro départ : ${widget.courrier.numero}"),
                      if (widget.courrier.numRef != null) Text("Numéro arrivée : ${widget.courrier.numRef}"),
                    ] else ...[
                      if (widget.courrier.numRef != null) Text("Numéro départ : ${widget.courrier.numRef}"),
                      if (widget.courrier.numero != null) Text("Numéro arrivée : ${widget.courrier.numero}"),
                    ],

                    const SizedBox(height: 12),

                    // Encadré Expéditeur / Destinataire
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPersonneTile(
                              title: "Expéditeur :",
                              personne: widget.courrier.expediteur,
                              initials: "EX",
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            child: _buildPersonneTile(
                              title: "Destinataire initial :",
                              personne: widget.courrier.destinataire,
                              initials: "DE",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Informations Demandeurs
                    const Text("Informations Demandeur(s)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (widget.courrier.detailPersonnes.isNotEmpty)
                      ...widget.courrier.detailPersonnes.map((p) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text("${p.name} ${p.prenom}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (p.email != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(p.email!),
                                    ],
                                  ),
                                ],
                                if (p.telephone != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(p.telephone!),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ))
                    else
                      const Text("Aucun demandeur renseigné", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),

                    const Divider(height: 24),

                    // Dates & Traçabilité
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildDateInfo("Créé le", widget.courrier.createdAt != null ? DateTime.parse(widget.courrier.createdAt!) : null),
                        _buildDateInfo("Date de départ", widget.courrier.dateMessage != null ? DateTime.parse(widget.courrier.dateMessage!) : null),
                        _buildDateInfo("Date d'arrivée", widget.courrier.isReadAt != null ? DateTime.parse(widget.courrier.isReadAt!) : null),
                        _buildDateInfo("Échéance", widget.courrier.dateFin != null ? DateTime.parse(widget.courrier.dateFin!) : null, isDestructive: widget.courrier.dateFin != null),
                      ],
                    ),

                    const Divider(height: 24),

                    // Zone Observation avec Édition
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("OBSERVATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                        if (!_isEditingObs)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => setState(() => _isEditingObs = true),
                          ),
                      ],
                    ),
                    if (_isEditingObs) ...[
                      TextField(
                        controller: _obsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Saisissez une nouvelle observation...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isUpdatingObs
                                ? null
                                : () {
                                    setState(() {
                                      _isEditingObs = false;
                                      _obsController.text = widget.courrier.observation ?? '';
                                    });
                                  },
                            child: const Text("Annuler"),
                          ),
                          ElevatedButton(
                            onPressed: _isUpdatingObs ? null : _handleUpdateObservation,
                            child: Text(_isUpdatingObs ? "Enregistrement..." : "Enregistrer"),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        (widget.courrier.observation != null && widget.courrier.observation!.isNotEmpty)
                            ? widget.courrier.observation!
                            : "Aucune observation",
                        style: TextStyle(
                          fontStyle: (widget.courrier.observation == null || widget.courrier.observation!.isEmpty)
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: (widget.courrier.observation == null || widget.courrier.observation!.isEmpty)
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section Historique des transferts
            Row(
              children: [
                const Text("Historique des transferts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Chip(label: Text("${widget.messages.length}")),
              ],
            ),

            const SizedBox(height: 12),

            // États : Loading / Error / Empty / Liste
            if (widget.loading)
              const Center(child: CircularProgressIndicator())
            else if (widget.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.error!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              )
            else if (widget.messages.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.swap_horiz, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("AUCUN TRANSFERT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text("Ce courrier n'a pas encore été transféré.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
            else
              // Tableau / Liste des transferts
              Card(
                elevation: 1,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("#")),
                      DataColumn(label: Text("Expéditeur")),
                      DataColumn(label: Text("Destinataire")),
                      DataColumn(label: Text("Statut")),
                      DataColumn(label: Text("N° Départ")),
                      DataColumn(label: Text("N° Arrivée")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("")),
                    ],
                    rows: List<DataRow>.generate(widget.messages.length, (index) {
                      final message = widget.messages[index];
                      final bool accessible = isMessageVisible(message);
                      final bool isRead = message.isReadAt != null;

                      return DataRow(
                        onSelectChanged: accessible ? (_) => widget.onSelect(message) : null,
                        cells: [
                          DataCell(CircleAvatar(
                            radius: 12,
                            child: Text("${index + 1}", style: const TextStyle(fontSize: 10)),
                          )),
                          DataCell(Text("${message.expediteur.nom} ${message.expediteur.prenom}")),
                          DataCell(Text("${message.destinataire.nom} ${message.destinataire.prenom}")),
                          DataCell(Chip(
                            label: Text(isRead ? 'Arrivée' : 'Non arrivée'),
                            backgroundColor: isRead ? Colors.green.shade50 : Colors.blue.shade50,
                          )),
                          DataCell(Text(message.numeroExpediteur?.toString() ?? "—")),
                          DataCell(Text(message.numeroDestinataire?.toString() ?? "—")),
                          DataCell(Text(_formatDateTime(message.createdAt))),
                          DataCell(accessible
                              ? const Icon(Icons.arrow_forward_ios, size: 14)
                              : const Icon(Icons.lock, size: 14, color: Colors.grey)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper pour afficher une personne dans un pavé
  Widget _buildPersonneTile({required String title, required Utilisateur? personne, required String initials}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              child: Text(initials, style: const TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${personne?.nom ?? '—'} ${personne?.prenom ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (personne?.adresse != null)
                    Text(
                      personne!.adresse,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper pour l'affichage des dates
  Widget _buildDateInfo(String label, DateTime? date, {bool isDestructive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          _formatDateTime(date.toString()),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}