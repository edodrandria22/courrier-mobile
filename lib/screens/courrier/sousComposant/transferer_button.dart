import 'dart:async';
import 'dart:io';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

// ==========================================
// 💡 Services factices (équivalent de tes hooks)
// ==========================================
class TransfertService {
  Future<bool> transferer(int messageId, int userId, String observation, List<File> files) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulation API
    return true; // Succès
  }
}

class UtilisateurService {
  Future<List<Utilisateur>> rechercheUtilisateurs(String query, String dateFin) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulation API
    return [
      Utilisateur(id: 1, nom: 'Dupont', prenom: 'Jean', adresse: 'Paris', createdAt: dateFin, email: '', role: ''),
      Utilisateur(id: 2, nom: 'Martin', prenom: 'Alice', adresse: 'Lyon', createdAt: dateFin, email: '', role: ''),
    ];
  }
}

// ==========================================
// 💡 Le bouton qui déclenche la modale
// ==========================================
class TransfererButton extends StatelessWidget {
  final int messageId;
  final VoidCallback onSuccess;

  const TransfererButton({
    super.key,
    required this.messageId,
    required this.onSuccess,
  });

  void _showTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransfererDialog(
        messageId: messageId,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showTransferDialog(context),
      icon: const Icon(Icons.forward, size: 18),
      label: const Text('Transférer'),
    );
  }
}

// ==========================================
// 💡 Le contenu de la Modale (Dialog)
// ==========================================
class TransfererDialog extends StatefulWidget {
  final int messageId;
  final VoidCallback onSuccess;

  const TransfererDialog({
    super.key,
    required this.messageId,
    required this.onSuccess,
  });

  @override
  State<TransfererDialog> createState() => _TransfererDialogState();
}

class _TransfererDialogState extends State<TransfererDialog> {
  Utilisateur? _selectedUser;
  final TextEditingController _observationController = TextEditingController();
  List<PlatformFile> _attachments = [];
  
  bool _isTransferring = false;
  String? _transferError;

  final TransfertService _transfertService = TransfertService();

  Future<void> _pickFiles() async {
    if (_isTransferring) return;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _attachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(PlatformFile file) {
    setState(() {
      _attachments.remove(file);
    });
  }

  Future<void> _handleTransferer() async {
    if (_selectedUser == null) return;

    setState(() {
      _isTransferring = true;
      _transferError = null;
    });

    try {
      List<File> filesToUpload = _attachments
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      bool success = await _transfertService.transferer(
        widget.messageId,
        _selectedUser!.id,
        _observationController.text,
        filesToUpload,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(); // Ferme le dialog
          widget.onSuccess();
        }
      } else {
        setState(() => _transferError = "Échec du transfert.");
      }
    } catch (e) {
      setState(() => _transferError = "Une erreur s'est produite.");
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  // Ouvre un BottomSheet pour rechercher un utilisateur (Meilleure UX sur mobile)
  void _openUserSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet au sheet de prendre plus de place
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _UserSearchBottomSheet(
        onUserSelected: (user) {
          setState(() => _selectedUser = user);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transférer le message'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Sélection du destinataire
            const Text('Sélectionner le destinataire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _isTransferring ? null : _openUserSearchSheet,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedUser != null
                            ? '${_selectedUser!.nom} ${_selectedUser!.prenom}'
                            : 'Choisir un destinataire...',
                        style: TextStyle(
                          color: _selectedUser != null ? Colors.black87 : Colors.grey.shade600,
                          fontWeight: _selectedUser != null ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.unfold_more, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Observation
            RichText(
              text: const TextSpan(
                text: 'Observation ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                children: [TextSpan(text: '(optionnel)', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey))],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observationController,
              enabled: !_isTransferring,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Fichiers joints
            RichText(
              text: const TextSpan(
                text: 'Documents ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                children: [TextSpan(text: '(optionnel)', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey))],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFiles,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: const Column(
                  children: [
                    Icon(Icons.attach_file, color: Colors.grey, size: 28),
                    SizedBox(height: 8),
                    Text('Cliquez pour ajouter des fichiers', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            
            // Liste des fichiers sélectionnés
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._attachments.map((file) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(file.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: _isTransferring ? null : () => _removeAttachment(file),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              )),
            ],

            // 4. Erreur
            if (_transferError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_transferError!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTransferring ? null : () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: (_isTransferring || _selectedUser == null) ? null : _handleTransferer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          icon: _isTransferring
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send, size: 16),
          label: Text(_isTransferring ? 'Envoi...' : 'Transférer'),
        ),
      ],
    );
  }
}

// ==========================================
// 💡 BottomSheet pour la recherche d'utilisateur (Debounce + Pagination)
// ==========================================
class _UserSearchBottomSheet extends StatefulWidget {
  final Function(Utilisateur) onUserSelected;

  const _UserSearchBottomSheet({required this.onUserSelected});

  @override
  State<_UserSearchBottomSheet> createState() => _UserSearchBottomSheetState();
}

class _UserSearchBottomSheetState extends State<_UserSearchBottomSheet> {
  List<Utilisateur> _utilisateurs = [];
  bool _isLoading = false;
  bool _isPaginating = false;
  String _searchQuery = "";
  String _dateFin = "";
  
  Timer? _debounce;
  final UtilisateurService _utilisateurService = UtilisateurService();

  @override
  void initState() {
    super.initState();
    _dateFin = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    _performSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _dateFin = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      final results = await _utilisateurService.rechercheUtilisateurs(_searchQuery, _dateFin);
      setState(() {
        _utilisateurs = results;
        if (results.isNotEmpty) {
          _dateFin = results.last.createdAt;
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isPaginating) return;
    setState(() => _isPaginating = true);
    
    try {
      final results = await _utilisateurService.rechercheUtilisateurs(_searchQuery, _dateFin);
      setState(() {
        if (results.isNotEmpty) {
          // Filtrer les doublons potentiels comme en React
          final newUsers = results.where((r) => !_utilisateurs.any((u) => u.id == r.id)).toList();
          _utilisateurs.addAll(newUsers);
          _dateFin = results.last.createdAt;
        }
      });
    } finally {
      if (mounted) setState(() => _isPaginating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hauteur max = 80% de l'écran pour éviter que le clavier ne cache tout
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom, // Gère le clavier
      ),
      child: Column(
        children: [
          // Barre de drag (esthétique)
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          
          TextField(
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tapez le nom complet...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _utilisateurs.isEmpty
                ? const Center(child: Text("Aucun agent trouvé.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _utilisateurs.length + 1, // +1 pour le bouton "Voir plus"
                    itemBuilder: (context, index) {
                      if (index == _utilisateurs.length) {
                        return TextButton.icon(
                          onPressed: _isPaginating ? null : _loadMore,
                          icon: _isPaginating 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.keyboard_arrow_down),
                          label: Text(_isPaginating ? 'Chargement...' : 'Voir plus d\'agents'),
                        );
                      }

                      final user = _utilisateurs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(user.nom[0].toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor)),
                        ),
                        title: Text('${user.nom} ${user.prenom}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(user.adresse, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => widget.onUserSelected(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}