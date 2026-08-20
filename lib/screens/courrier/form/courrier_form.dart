import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

// Classe utilitaire pour garder les états des TextField dynamiques
class PersonneControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController prenom = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController telephone = TextEditingController();

  void dispose() {
    name.dispose();
    prenom.dispose();
    email.dispose();
    telephone.dispose();
  }
}

class CourrierForm extends StatefulWidget {
  final Courrier? courrier;
  final VoidCallback onSuccess;
  final VoidCallback? onClose;

  const CourrierForm({super.key, required this.onSuccess, this.courrier, this.onClose});

  @override
  State<CourrierForm> createState() => _CourrierFormState();
}

class _CourrierFormState extends State<CourrierForm> {
  final TextEditingController objectCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController obsCtrl = TextEditingController();
  
  bool isConfidentiel = false;
  bool loading = false;
  String? createdReference;

  // Stockage temporaire en cas de toggle confidentiel
  String backupObject = '';
  List<PersonneControllers> backupPersonnes = [];
  
  List<PersonneControllers> personnes = [];
  List<PlatformFile> attachments = [];

  @override
  void initState() {
    super.initState();
    if (widget.courrier != null) {
      objectCtrl.text = widget.courrier!.object;
      descCtrl.text = widget.courrier!.description ?? '';
      obsCtrl.text = widget.courrier!.observation ?? '';
      isConfidentiel = widget.courrier!.isConfidentiel ?? false;
      
      for (var p in widget.courrier!.detailPersonnes) {
        final ctrl = PersonneControllers();
        ctrl.name.text = p.name;
        ctrl.prenom.text = p.prenom ?? '';
        ctrl.email.text = p.email ?? '';
        ctrl.telephone.text = p.telephone ?? '';
        personnes.add(ctrl);
      }
    }
  }

  void toggleConfidentiel(bool value) {
    setState(() {
      isConfidentiel = value;
      if (value) {
        backupObject = objectCtrl.text;
        backupPersonnes = List.from(personnes);
        
        objectCtrl.text = 'Pli fermé';
        descCtrl.clear();
        personnes.clear();
      } else {
        objectCtrl.text = backupObject;
        personnes = List.from(backupPersonnes);
      }
    });
  }

  void addPersonne() {
    setState(() {
      personnes.add(PersonneControllers());
    });
  }

  void removePersonne(int index) {
    setState(() {
      personnes[index].dispose();
      personnes.removeAt(index);
    });
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        attachments.addAll(result.files);
      });
    }
  }

  Future<void> handleSubmit() async {
    setState(() => loading = true);
    
    // Simuler un appel API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      loading = false;
      createdReference = "REF-${(100000 + DateTime.now().millisecondsSinceEpoch % 900000)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (createdReference != null) {
      return _buildSuccessScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Toggle Confidentiel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1️⃣ AJOUTEZ EXPANDED ICI
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.courrier != null ? 'Modifier le Courrier ${widget.courrier!.reference}' : 'Nouveau Courrier',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (widget.courrier == null)
                          Text(
                            'Enregistrement d\'un nouveau courrier entrant.', 
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                  
                  // 2️⃣ AJOUTEZ UN PETIT ESPACE POUR EVITER QUE LE TEXTE COLLE AU SWITCH
                  const SizedBox(width: 8),

                  Row(
                    mainAxisSize: MainAxisSize.min, // 3️⃣ SÉCURITÉ SUPPLÉMENTAIRE
                    children: [
                      const Icon(Icons.lock, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      const Text('Confidentiel', style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(value: isConfidentiel, onChanged: loading ? null : toggleConfidentiel),
                    ],
                  )
                ],
              ),
              const Divider(height: 32),

              // Détails du document
              const Text('DÉTAILS DU DOCUMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              _buildTextField('Objet', objectCtrl, disabled: isConfidentiel || loading, required: true),
              const SizedBox(height: 16),
              _buildTextField('Description', descCtrl, maxLines: 4, disabled: isConfidentiel || loading),
              
              if (widget.courrier == null) ...[
                const SizedBox(height: 16),
                _buildTextField('Observation', obsCtrl, maxLines: 3, disabled: isConfidentiel || loading),
                const SizedBox(height: 16),
                
                // Pièces jointes
                const Text('Documents (optionnel)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: loading ? null : pickFiles,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), // Simule dashed
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.attach_file, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Cliquez pour ajouter des fichiers', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...attachments.map((file) => ListTile(
                    leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                    title: Text(file.name, style: const TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: () => setState(() => attachments.remove(file)),
                    ),
                    dense: true,
                  )),
                ]
              ],

              const SizedBox(height: 32),
              
              // Liste des demandeurs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('INFORMATIONS DEMANDEURS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  if (!isConfidentiel)
                    OutlinedButton.icon(
                      onPressed: loading ? null : addPersonne,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              ...personnes.asMap().entries.map((entry) {
                int idx = entry.key;
                PersonneControllers p = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      if (!isConfidentiel && !loading)
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => removePersonne(idx),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Nom', p.name, disabled: isConfidentiel || loading)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Prénom', p.prenom, disabled: isConfidentiel || loading)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Email', p.email, disabled: isConfidentiel || loading)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Téléphone', p.telephone, disabled: isConfidentiel || loading)),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              // Actions
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onClose != null)
                    TextButton(
                      onPressed: loading ? null : widget.onClose,
                      child: const Text('Annuler', style: TextStyle(color: Colors.black)),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: loading ? null : handleSubmit,
                    icon: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send, size: 16),
                    label: Text(widget.courrier != null ? 'Enregistrer la modification' : 'Créer le courrier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool disabled = false, int maxLines = 1, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: !disabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: disabled ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(widget.courrier != null ? 'Courrier modifié !' : 'Courrier enregistré !', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Le document a été indexé avec succès dans le système.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RÉFÉRENCE UNIQUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text(createdReference!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: createdReference!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copié !')));
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onSuccess,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Continuer', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    objectCtrl.dispose();
    descCtrl.dispose();
    obsCtrl.dispose();
    for (var p in personnes) {
      p.dispose();
    }
    super.dispose();
  }
}