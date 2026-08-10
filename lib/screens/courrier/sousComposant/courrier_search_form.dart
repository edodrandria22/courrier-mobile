import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:flutter/material.dart';


// ==========================================
// 2. Le Widget Principal
// ==========================================
class CourrierSearchForm extends StatefulWidget {
  final Function(CourrierSearchCriteria) onSearch;
  final bool loading;
  final VoidCallback? reinitialiser;
  final CourrierSearchCriteria? initialCriteria;

  const CourrierSearchForm({
    super.key,
    required this.onSearch,
    this.loading = false,
    this.reinitialiser,
    this.initialCriteria,
  });

  @override
  State<CourrierSearchForm> createState() => _CourrierSearchFormState();
}

class _CourrierSearchFormState extends State<CourrierSearchForm> {
  // Contrôleurs pour les champs texte et nombres
  late TextEditingController _refController;
  late TextEditingController _objController;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telController;
  late TextEditingController _numGenController;
  late TextEditingController _numDepController;
  late TextEditingController _numArrController;

  // Variables d'état pour les listes déroulantes et les dates
  String? _statut;
  bool? _isConfidentiel;
  
  String? _dateDebut;
  String? _dateFin;
  String? _dateMessageDebut;
  String? _dateMessageFin;
  String? _dateReceptionDebut;
  String? _dateReceptionFin;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final criteria = widget.initialCriteria;
    
    _refController = TextEditingController(text: criteria?.reference ?? '');
    _objController = TextEditingController(text: criteria?.object ?? '');
    _nomController = TextEditingController(text: criteria?.nom ?? '');
    _prenomController = TextEditingController(text: criteria?.prenom ?? '');
    _emailController = TextEditingController(text: criteria?.email ?? '');
    _telController = TextEditingController(text: criteria?.telephone ?? '');
    
    _numGenController = TextEditingController(text: criteria?.numero?.toString() ?? '');
    _numDepController = TextEditingController(text: criteria?.numeroExpediteur?.toString() ?? '');
    _numArrController = TextEditingController(text: criteria?.numeroDestinataire?.toString() ?? '');

    _statut = criteria?.statut;
    _isConfidentiel = criteria?.isConfidentiel;
    
    _dateDebut = criteria?.dateDebut;
    _dateFin = criteria?.dateFin;
    _dateMessageDebut = criteria?.dateMessageDebut;
    _dateMessageFin = criteria?.dateMessageFin;
    _dateReceptionDebut = criteria?.dateReceptionDebut;
    _dateReceptionFin = criteria?.dateReceptionFin;
  }

  @override
  void dispose() {
    _refController.dispose();
    _objController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _numGenController.dispose();
    _numDepController.dispose();
    _numArrController.dispose();
    super.dispose();
  }

  void _handleReset() {
    _refController.clear();
    _objController.clear();
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _telController.clear();
    _numGenController.clear();
    _numDepController.clear();
    _numArrController.clear();

    setState(() {
      _statut = null;
      _isConfidentiel = null;
      _dateDebut = null;
      _dateFin = null;
      _dateMessageDebut = null;
      _dateMessageFin = null;
      _dateReceptionDebut = null;
      _dateReceptionFin = null;
    });

    if (widget.reinitialiser != null) {
      widget.reinitialiser!();
    }
  }

  void _handleSubmit() {
    // Helper pour ne garder que les valeurs non vides
    String? cleanString(String text) => text.trim().isEmpty ? null : text.trim();
    int? cleanInt(String text) => text.trim().isEmpty ? null : int.tryParse(text.trim());

    final filteredCriteria = CourrierSearchCriteria(
      reference: cleanString(_refController.text),
      object: cleanString(_objController.text),
      nom: cleanString(_nomController.text),
      prenom: cleanString(_prenomController.text),
      email: cleanString(_emailController.text),
      telephone: cleanString(_telController.text),
      numero: cleanInt(_numGenController.text),
      numeroExpediteur: cleanInt(_numDepController.text),
      numeroDestinataire: cleanInt(_numArrController.text),
      statut: _statut,
      isConfidentiel: _isConfidentiel,
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      dateMessageDebut: _dateMessageDebut,
      dateMessageFin: _dateMessageFin,
      dateReceptionDebut: _dateReceptionDebut,
      dateReceptionFin: _dateReceptionFin,
    );

    widget.onSearch(filteredCriteria);
  }

  Future<void> _selectDate(BuildContext context, String? currentDate, ValueChanged<String?> onDateSelected) async {
    DateTime initialDate = DateTime.now();
    if (currentDate != null && currentDate.isNotEmpty) {
      initialDate = DateTime.tryParse(currentDate) ?? DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format YYYY-MM-DD
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      onDateSelected(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.search, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recherche de courriers',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Filtrez vos courriers par critères précis',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // 1. Informations générales & Contact
            _buildSectionTitle(Icons.description, 'Informations générales & Contact'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildTextField('Référence', 'ex: REF2024', _refController),
                  _buildTextField('Objet', 'Objet de la demande...', _objController),
                  _buildTextField('Nom', 'ex: MUPASA', _nomController),
                  _buildTextField('Prénom', 'ex: Jean', _prenomController),
                  _buildTextField('Email', 'exemple@mail.com', _emailController, TextInputType.emailAddress),
                  _buildTextField('Téléphone', '0340000000', _telController, TextInputType.phone),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Numérotation & Statuts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.tag, 'Numérotation'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _sectionDecoration(),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildTextField('N° Général', '10', _numGenController, TextInputType.number),
                            _buildTextField('N° Départ', '10', _numDepController, TextInputType.number),
                            _buildTextField('N° Arrivée', '10', _numArrController, TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.tune, "Filtres d'état"),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _sectionDecoration(),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildDropdownField(
                              'Statut',
                              value: _statut,
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Tous les statuts')),
                                DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                                DropdownMenuItem(value: 'finalise', child: Text('Finalisé')),
                              ],
                              onChanged: (val) => setState(() => _statut = val as String?),
                            ),
                            _buildDropdownField(
                              'Confidentialité',
                              value: _isConfidentiel,
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Tous')),
                                DropdownMenuItem(value: false, child: Text('Non confidentiel')),
                                DropdownMenuItem(value: true, child: Text('Confidentiel')),
                              ],
                              onChanged: (val) => setState(() => _isConfidentiel = val as bool?),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Périodes & Dates
            _buildSectionTitle(Icons.calendar_today, 'Filtres par dates'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _sectionDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateIntervalBox('Date de création', _dateDebut, _dateFin, 
                      (val) => setState(() => _dateDebut = val), 
                      (val) => setState(() => _dateFin = val)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateIntervalBox('Date du message', _dateMessageDebut, _dateMessageFin, 
                      (val) => setState(() => _dateMessageDebut = val), 
                      (val) => setState(() => _dateMessageFin = val)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateIntervalBox('Date de réception', _dateReceptionDebut, _dateReceptionFin, 
                      (val) => setState(() => _dateReceptionDebut = val), 
                      (val) => setState(() => _dateReceptionFin = val)
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _handleReset,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Réinitialiser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: widget.loading ? null : _handleSubmit,
                  icon: widget.loading 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.search, size: 18, color: Colors.white),
                  label: Text(
                    widget.loading ? 'Recherche...' : 'Rechercher',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Utilitaires ---

  BoxDecoration _sectionDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, [TextInputType type = TextInputType.text]) {
    return SizedBox(
      width: 250, // Fixer une largeur ou utiliser un Expanded dans un Row si besoin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: TextFormField(
              controller: controller,
              keyboardType: type,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, {required dynamic value, required List<DropdownMenuItem<dynamic>> items, required ValueChanged<dynamic> onChanged}) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField<dynamic>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateIntervalBox(
      String title, 
      String? debut, 
      String? fin, 
      ValueChanged<String?> onDebutSelected, 
      ValueChanged<String?> onFinSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          const Divider(),
          Row(
            children: [
              Expanded(child: _buildDateSelector('Du', debut, (val) => onDebutSelected(val))),
              const SizedBox(width: 8),
              Expanded(child: _buildDateSelector('Au', fin, (val) => onFinSelected(val))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, String? dateValue, ValueChanged<String?> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context, dateValue, onSelected),
          child: Container(
            height: 36,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              dateValue ?? 'aaaa-mm-jj',
              style: TextStyle(
                fontSize: 12,
                color: dateValue == null ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}