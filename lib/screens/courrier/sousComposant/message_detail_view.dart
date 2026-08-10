import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/piece_jointe_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageDetailView extends StatefulWidget {
  final Courrier courrier;
  final MessageCourrier message;
  final List<MessageCourrier> messages;
  final String? currentUserId;
  final VoidCallback onBack;
  final ValueChanged<int>? onMessageRead;
  final Future<void> Function(int id) onCloture;
  final Future<Map<String, dynamic>> Function(int messageId)? onRecupererExterne;

  const MessageDetailView({
    super.key,
    required this.courrier,
    required this.message,
    required this.messages,
    this.currentUserId,
    required this.onBack,
    this.onMessageRead,
    required this.onCloture,
    this.onRecupererExterne,
  });

  @override
  State<MessageDetailView> createState() => _MessageDetailViewState();
}

class _MessageDetailViewState extends State<MessageDetailView> {
  bool _loadingCloturer = false;
  bool _loadingExterne = false;

  // --- Logique métier / Permissions ---
  bool get canTransfer => true; // À adapter avec votre hook useMessagePermissions

  bool isLastMessage(MessageCourrier msg) {
    if (widget.messages.isEmpty) return false;
    return widget.messages.last.id == msg.id;
  }

  bool get isValidExterne {
    return widget.message.destinataire.id == 2 &&
        widget.currentUserId == widget.message.expediteur.id.toString();
  }

  // --- Utilitaires de formatage ---
  String _formatDate(String? dt) {
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

  String _getInitials(String nom, [String? prenom]) {
    final first = prenom?.trim().isNotEmpty == true ? prenom!.trim()[0] : '';
    final last = nom.trim().isNotEmpty ? nom.trim()[0] : '';
    final res = (first + last).toUpperCase();
    return res.isEmpty ? '?' : res;
  }

  // --- Actions ---
  Future<void> _handleRecupererExterne() async {
    if (widget.onRecupererExterne == null) return;
    setState(() => _loadingExterne = true);

    try {
      final result = await widget.onRecupererExterne!(widget.message.id);
      if (mounted) {
        if (result['success'] == true) {
          Navigator.of(context).pushReplacementNamed('/message/courrier/receive');
        } else {
          _showToast(result['error'] ?? 'Erreur lors du transfert', isError: true);
        }
      }
    } catch (e) {
      if (mounted) _showToast("Erreur lors de la récupération", isError: true);
    } finally {
      if (mounted) setState(() => _loadingExterne = false);
    }
  }

  Future<void> _handleCloturer() async {
    setState(() => _loadingCloturer = true);
    try {
      await widget.onCloture(widget.courrier.id ?? 0);
    } catch (e) {
      if (mounted) _showToast("Erreur lors de la clôture", isError: true);
    } finally {
      if (mounted) setState(() => _loadingCloturer = false);
    }
  }

  // void _onSuccessTransfere() {
  //   Navigator.of(context).pushReplacementNamed('/message/courrier/send');
  // }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfidentiel = widget.courrier.isConfidentiel ?? false;
    final bool isClotured = widget.courrier.cloturePar != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= EN-TÊTE =================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: widget.onBack,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges & Référence
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                widget.courrier.reference ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                                ),
                              ),
                              if (isConfidentiel)
                                _buildBadge(
                                  label: "Confidentiel",
                                  icon: Icons.lock,
                                  bgColor: Colors.amber.shade50,
                                  textColor: Colors.amber.shade900,
                                  borderColor: Colors.amber.shade200,
                                ),
                              if (widget.message.isReadAt != null)
                                _buildBadge(
                                  label: "Lu",
                                  icon: Icons.check_circle_outline,
                                  bgColor: Colors.green.shade50,
                                  textColor: Colors.green.shade700,
                                  borderColor: Colors.green.shade200,
                                ),
                              if (isClotured)
                                _buildBadge(
                                  label: "Finalisé",
                                  icon: Icons.check_circle,
                                  bgColor: Colors.green.shade100,
                                  textColor: Colors.green.shade800,
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Objet
                          Row(
                            children: [
                              if (isConfidentiel) ...[
                                Icon(Icons.lock, size: 18, color: Colors.amber.shade800),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  widget.courrier.object,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isConfidentiel ? Colors.amber.shade900 : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Date
                          Text(
                            _formatDate(widget.message.createdAt),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ================= CONTENU =================
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Block Transfert (Expéditeur -> Destinataire) ---
                    _buildSectionHeader(Icons.person_outline, "Transfert"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Expéditeur
                          Expanded(
                            child: _buildUserTile(
                              personne: widget.message.expediteur,
                              isRightAligned: false,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                          ),
                          // Destinataire
                          Expanded(
                            child: _buildUserTile(
                              personne: widget.message.destinataire,
                              isRightAligned: true,
                              highlightColor: widget.message.dateValidation != null
                                  ? Colors.green.shade600
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Block Observation ---
                    // _buildSectionHeader(Icons.chat_bubble_outline, "Observation"),
                    // const SizedBox(height: 8),
                    // Container(
                    //   width: double.infinity,
                    //   constraints: const BoxConstraints(minHeight: 80),
                    //   padding: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey.shade50,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey.shade200),
                    //   ),
                    //   child: Text(
                    //     (widget.message.observation != null && widget.message.observation!.isNotEmpty)
                    //         ? widget.message.observation!
                    //         : "Aucun commentaire",
                    //     style: TextStyle(
                    //       fontSize: 13,
                    //       height: 1.4,
                    //       fontStyle: (widget.message.observation == null || widget.message.observation!.isEmpty)
                    //           ? FontStyle.italic
                    //           : FontStyle.normal,
                    //       color: (widget.message.observation == null || widget.message.observation!.isEmpty)
                    //           ? Colors.grey
                    //           : Colors.black87,
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 20),

                    // --- Block Pièces Jointes ---
                    if (widget.message.fichiers.isNotEmpty) ...[
                      _buildSectionHeader(
                        Icons.attach_file,
                        "Pièces jointes (${widget.message.fichiers.length})",
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3,
                        ),
                        itemCount: widget.message.fichiers.length,
                        itemBuilder: (context, index) {
                          final pj = widget.message.fichiers[index];
                          return PieceJointeCard(pj: pj);
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(height: 1),

              // ================= FOOTER / ACTIONS =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Bouton Retour
                    OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Text("Retour aux transferts", style: TextStyle(fontSize: 12)),
                    ),

                    // Bouton Externe
                    if (isValidExterne)
                      OutlinedButton(
                        onPressed: _loadingExterne ? null : _handleRecupererExterne,
                        child: _loadingExterne
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Retourner l'externe", style: TextStyle(fontSize: 12)),
                      ),

                    // Actions de transfert / clôture
                    if (canTransfer && isLastMessage(widget.message) && !isClotured)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dialogue de transfert
                          // ElevatedButton.icon(
                          //   onPressed: () {
                          //     showDialog(
                          //       context: context,
                          //       builder: (_) => TransfererDialog(
                          //         messageId: widget.message.id,
                          //         onSuccess: _onSuccessTransfere,
                          //       ),
                          //     );
                          //   },
                          //   icon: const Icon(Icons.send, size: 14),
                          //   label: const Text("Transférer", style: TextStyle(fontSize: 12)),
                          // ),
                          const SizedBox(width: 8),

                          // Bouton Clôturer
                          OutlinedButton.icon(
                            onPressed: _loadingCloturer ? null : _handleCloturer,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.amber.shade800,
                              side: BorderSide(color: Colors.amber.shade300),
                            ),
                            icon: _loadingCloturer
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.lock, size: 14),
                            label: Text(
                              _loadingCloturer ? "Clôture..." : "Clôturer",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Composants de construction internes ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile({
    required Utilisateur personne,
    required bool isRightAligned,
    Color? highlightColor,
  }) {
    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: (highlightColor ?? Colors.grey.shade300).withOpacity(0.2),
      child: Text(
        _getInitials(personne.nom, personne.prenom),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: highlightColor ?? Theme.of(context).primaryColor,
        ),
      ),
    );

    final details = Column(
      crossAxisAlignment: isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          personne.nom,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: highlightColor ?? Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (personne.adresse.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isRightAligned) const Icon(Icons.location_on, size: 10, color: Colors.grey),
              Flexible(
                child: Text(
                  personne.adresse,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRightAligned) const Icon(Icons.location_on, size: 10, color: Colors.grey),
            ],
          ),
      ],
    );

    return Row(
      mainAxisAlignment: isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: isRightAligned
          ? [Expanded(child: details), const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), Expanded(child: details)],
    );
  }
}