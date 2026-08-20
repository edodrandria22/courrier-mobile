import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class CourrierListView extends StatefulWidget {
  final List<Courrier> courriers;
  final bool loading;
  final String? error;
  final Function(Courrier) onSelect;
  final Function(Courrier)? onEdit;
  final bool isUpdate;
  final bool? isTraiterAt;
  final Function(bool?)? setIsTraiterAt;
  final Function(bool)? setHasMoreCourriers;
  final int? nbNonTraite;

  const CourrierListView({
    super.key,
    required this.courriers,
    this.loading = false,
    this.error,
    required this.onSelect,
    this.onEdit,
    this.isUpdate = false,
    this.isTraiterAt,
    this.setIsTraiterAt,
    this.setHasMoreCourriers,
    this.nbNonTraite,
  });

  @override
  State<CourrierListView> createState() => _CourrierListViewState();
}

class _CourrierListViewState extends State<CourrierListView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _searchField = 'nom';

  final List<Map<String, dynamic>> _searchFields = [
    {'value': 'nom', 'label': 'Nom', 'icon': Icons.person, 'placeholder': 'Rechercher par nom...'},
    {'value': 'reference', 'label': 'Référence', 'icon': Icons.numbers, 'placeholder': 'Ex: ESPA-2026-001'},
    {'value': 'description', 'label': 'Contenu', 'icon': Icons.description, 'placeholder': 'Rechercher dans l\'objet...'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Courrier> get _filteredCourriers {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return widget.courriers;

    return widget.courriers.where((c) {
      if (_searchField == 'nom') {
        return c.detailPersonnes.any((p) {
          final nomComplet = '${p.name } ${p.prenom ?? ''}'.toLowerCase();
          return nomComplet.contains(q);
        });
      }
      if (_searchField == 'reference') {
        return (c.reference ?? '').toLowerCase().contains(q);
      }
      if (_searchField == 'description') {
        return (c.description ?? '').toLowerCase().contains(q) ||
               (c.object ).toLowerCase().contains(q);
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCourriers;

    return Column(
      children: [
        _buildHeader(),
        _buildCountBar(filtered.length),
        Expanded(
          child: _buildContent(filtered),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final activeField = _searchFields.firstWhere((f) => f['value'] == _searchField);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche type Gmail
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: activeField['placeholder'],
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Puces de filtrage
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._searchFields.map((field) {
                  final isActive = _searchField == field['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(field['icon'], size: 16, color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(field['label']),
                        ],
                      ),
                      selected: isActive,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _searchField = field['value'];
                            _searchController.clear();
                          });
                        }
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isActive ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }),
                if (widget.setIsTraiterAt != null) ...[
                  const SizedBox(width: 16),
                  _buildTriStateFilter(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriStateFilter() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterButton('Tous', null),
          _buildFilterButton('Traiter', true, icon: Icons.check_box),
          _buildFilterButton(
            'Non traiter ${widget.nbNonTraite != null && widget.nbNonTraite! > 0 ? "(${widget.nbNonTraite})" : ""}', 
            false, 
            icon: Icons.check_box_outline_blank
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool? value, {IconData? icon}) {
    final isActive = widget.isTraiterAt == value;
    return InkWell(
      onTap: () {
        widget.setIsTraiterAt?.call(value);
        widget.setHasMoreCourriers?.call(true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))] : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade600),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? (value == true ? Theme.of(context).primaryColor : Colors.black87) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBar(int count) {
    if (widget.loading || widget.error != null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Text(
        count > 0 ? '$count courrier(s)' : '0 courrier',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildContent(List<Courrier> filtered) {
    if (widget.loading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.circle, color: Colors.black12, size: 16),
          title: Container(height: 14, color: Colors.black12),
          subtitle: Container(height: 14, width: 100, color: Colors.black12),
        ), // Remplacer par package 'shimmer' si besoin
      );
    }

    if (widget.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(widget.error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _query.isNotEmpty ? 'Aucun courrier trouvé' : 'Votre boîte est vide',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _query.isNotEmpty 
                  ? 'Essayez de modifier vos critères pour "$_query".' 
                  : 'Les nouveaux courriers apparaîtront ici.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) => _buildCourrierItem(filtered[index]),
    );
  }

  Widget _buildCourrierItem(Courrier courrier) {
    final isLu = courrier.isReadAt != null;
    final isSend = courrier.isSend ;
    final cible = isSend ? courrier.destinataire : courrier.expediteur;
    final nomComplet = '${cible?.nom ?? ''} ${cible?.prenom ?? ''}'.trim();
    final isFinalise = courrier.cloturePar;

    // Définissez bien isLu en amont si ce n'est pas déjà fait :

    return InkWell( // gardez votre widget InkWell existant
      onTap: () => widget.onSelect(courrier),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // 💡 Différence de fond marquée : Blanc éclatant pour le non-lu, Gris très clair pour le lu
        color: isLu ? Colors.grey.shade100 : Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 💡 Indicateur Visuel (Point bleu pour non lu + Icône de statut)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Point bleu discret si non lu
                  if (!isLu) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  // Icône de statut (Check ou Horloge)
                  Icon(
                    isFinalise != null ? Icons.check_circle : Icons.access_time,
                    size: 16,
                    color: isFinalise != null ? Colors.green : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Expéditeur / Destinataire
                      if(!widget.isUpdate)
                      ...[
                        Expanded(
                          child: Text(
                            '${isSend ? "À :" : "De :"} $nomComplet',
                            style: TextStyle(
                              // 💡 Gras et Noir foncé si non lu, Normal et Grisé si lu
                              fontWeight: isLu ? FontWeight.normal : FontWeight.bold,
                              color: isLu ? Colors.grey.shade700 : Colors.black,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      // Date
                      Text(
                        _formatDate(_parseDate(courrier.dateMessage ?? courrier.createdAt)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isLu ? FontWeight.normal : FontWeight.bold,
                          color: isLu ? Colors.grey.shade500 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Objet & Badges
                  Row(
                    children: [
                      if (courrier.isConfidentiel == true)
                        const Padding(
                          padding: EdgeInsets.only(right: 6.0),
                          child: Icon(Icons.lock, size: 14, color: Colors.orange),
                        ),
                      Expanded(
                        child: Text(
                          courrier.object,
                          style: TextStyle(
                            fontWeight: isLu ? FontWeight.normal : FontWeight.bold,
                            color: courrier.isConfidentiel == true 
                                ? Colors.orange.shade700 
                                : (isLu ? Colors.grey.shade600 : Colors.black87),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Référence et Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLu ? Colors.grey.shade200 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          courrier.reference ?? 'N/A',
                          style: TextStyle(
                            fontSize: 10, 
                            color: isLu ? Colors.black54 : Colors.black87,
                            fontWeight: isLu ? FontWeight.normal : FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Actions (Eye & Edit)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: Colors.grey.shade600,
                            onPressed: () {
                              // generateCourrierPDF(courrier, 'view')
                            },
                          ),
                          // if (widget.isUpdate) ...[
                          //   const SizedBox(width: 12),
                          //   IconButton(
                          //     icon: const Icon(Icons.edit, size: 18),
                          //     padding: EdgeInsets.zero,
                          //     constraints: const BoxConstraints(),
                          //     color: Colors.grey.shade600,
                          //     onPressed: () => widget.onEdit?.call(courrier),
                          //   ),
                          // ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Adapter selon le format souhaité (ex: package intl)
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  DateTime _parseDate(dynamic dateValue) {
  if (dateValue is DateTime) return dateValue;
  if (dateValue is String && dateValue.isNotEmpty) {
    return DateTime.tryParse(dateValue) ?? DateTime.now();
  }
  return DateTime.now();
}
}